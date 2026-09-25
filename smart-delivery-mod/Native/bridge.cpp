#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <array>
#include <filesystem>
#include <fstream>
#include <limits>
#include <stdexcept>
#include <string>
#include "dispatch.hpp"
#include "pe_image.hpp"
#include "contract.hpp"

namespace {
volatile long selected = -1;
HMODULE self_module;
unsigned char* site = nullptr;
void* stub = nullptr;
std::array<unsigned char, 5> original{}, installed{};
bool active = false;

std::filesystem::path module_path(HMODULE module) {
    std::wstring name(32768, L'\0');
    const DWORD count = GetModuleFileNameW(module, name.data(), static_cast<DWORD>(name.size()));
    if (!count || count == name.size()) throw std::runtime_error("Cannot locate module");
    name.resize(count);
    return name;
}
void status(const std::string& message) {
    std::ofstream file(module_path(self_module).parent_path() / "bridge-status.txt", std::ios::trunc);
    file << message << '\n';
    file.flush();
    if (!file) throw std::runtime_error("Cannot write bridge status");
}
std::vector<unsigned char> read_image() {
    std::ifstream file(module_path(nullptr), std::ios::binary | std::ios::ate);
    if (!file) throw std::runtime_error("Cannot read game executable");
    auto size = file.tellg();
    if (size <= 0 || static_cast<std::uint64_t>(size) > (std::numeric_limits<DWORD>::max)())
        throw std::runtime_error("Invalid game executable size");
    std::vector<unsigned char> data(static_cast<std::size_t>(size));
    file.seekg(0); file.read(reinterpret_cast<char*>(data.data()), size);
    if (!file) throw std::runtime_error("Cannot read game executable");
    return data;
}
void* allocate_near(const void* address) {
    SYSTEM_INFO info{}; GetSystemInfo(&info);
    auto base = reinterpret_cast<std::uintptr_t>(address);
    base -= base % info.dwAllocationGranularity;
    for (std::uintptr_t distance = info.dwAllocationGranularity; distance < 0x70000000; distance += info.dwAllocationGranularity) {
        if (void* memory = VirtualAlloc(reinterpret_cast<void*>(base + distance), 4096,
                                        MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE)) return memory;
    }
    throw std::runtime_error("No nearby trampoline memory");
}
void write_patch(const std::array<unsigned char, 5>& bytes) {
    DWORD old;
    if (!VirtualProtect(site, bytes.size(), PAGE_EXECUTE_READWRITE, &old))
        throw std::runtime_error("Cannot change code protection");
    std::memcpy(site, bytes.data(), bytes.size());
    DWORD ignored;
    const bool restored = VirtualProtect(site, bytes.size(), old, &ignored) != 0;
    const bool flushed = FlushInstructionCache(GetCurrentProcess(), site, bytes.size()) != 0;
    if (!restored || !flushed) throw std::runtime_error("Cannot finalize code patch");
}
void initialize() {
    if (active) {
        if (std::memcmp(site, installed.data(), installed.size()) != 0)
            throw std::runtime_error("Another patch replaced Smart Delivery; cannot resume it");
        status("ready"); return;
    }
    const auto data = read_image();
    const auto contract = delivery::ContractImage(data).discover();
    auto* base = reinterpret_cast<unsigned char*>(GetModuleHandleW(nullptr));
    // The live free-service coefficient belongs to writable, zero-filled image
    // data, not file-backed code. Discovery validates its mapped location and
    // retains its runtime value. Only target code is compared with disk.
    delivery::require_unmodified(data, contract, base);
    site = base + contract.site;
    std::memcpy(original.data(), site, original.size());
    const auto code = delivery::dispatch(&selected, base + contract.free_fee, base + contract.budget,
                                          base + contract.premium, base + contract.resume, contract.threshold);
    stub = allocate_near(site);
    std::memcpy(stub, code.data(), code.size());
    DWORD ignored;
    if (!VirtualProtect(stub, 4096, PAGE_EXECUTE_READ, &ignored) ||
        !FlushInstructionCache(GetCurrentProcess(), stub, code.size()))
        throw std::runtime_error("Cannot finalize trampoline");
    const auto displacement = reinterpret_cast<std::intptr_t>(stub) - reinterpret_cast<std::intptr_t>(site + 5);
    if (displacement < INT32_MIN || displacement > INT32_MAX) throw std::runtime_error("Trampoline is too far away");
    installed[0] = 0xe9;
    const auto relative = static_cast<std::int32_t>(displacement);
    std::memcpy(installed.data() + 1, &relative, sizeof(relative));
    // Validate status-file access before installing; Lua requires a fresh ack.
    status("initializing");
    HMODULE pinned;
    if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
                           reinterpret_cast<LPCWSTR>(const_cast<long*>(&selected)), &pinned))
        throw std::runtime_error("Cannot retain bridge lifetime");
    active = true;
    write_patch(installed);
    status("ready");
}
void disable() {
    InterlockedExchange(&selected, -1);
    if (active) {
        if (std::memcmp(site, installed.data(), installed.size()) != 0)
            throw std::runtime_error("Another patch replaced Smart Delivery; refusing to overwrite it");
        write_patch(original);
        active = false;
        // Retain the tiny trampoline until process exit to avoid stale pointers.
    }
    status("disabled");
}
template<class F> int invoke(F fn) noexcept {
    try { fn(); }
    catch (const std::exception& error) {
        InterlockedExchange(&selected, -1);
        try { status(std::string("error: ") + error.what()); } catch (...) {}
    }
    return 0;
}
void select(long value) {
    if (!active) throw std::runtime_error("Bridge is not active");
    InterlockedExchange(&selected, value);
    status("ready");
}
}

// Lua C callbacks intentionally take no arguments and return no Lua values.
// They use no Lua ABI internals or second Lua runtime. The caller reads a fresh
// status acknowledgment and invokes patch-changing entry points on the game
// thread. Suspend is the exception: it only resets one aligned atomic value,
// leaves the pinned trampoline intact, and writes no status file or game code.
extern "C" {
__declspec(dllexport) int delivery_initialize(void*) { return invoke(initialize); }
__declspec(dllexport) int delivery_free(void*) { return invoke([] { select(0); }); }
__declspec(dllexport) int delivery_budget(void*) { return invoke([] { select(1); }); }
__declspec(dllexport) int delivery_premium(void*) { return invoke([] { select(2); }); }
__declspec(dllexport) int delivery_disable(void*) { return invoke(disable); }
__declspec(dllexport) int delivery_suspend(void*) { InterlockedExchange(&selected, -1); return 0; }
}
BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) { self_module = module; DisableThreadLibraryCalls(module); }
    return TRUE;
}
