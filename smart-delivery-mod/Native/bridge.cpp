#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <bcrypt.h>
#include <array>
#include <filesystem>
#include <fstream>
#include <limits>
#include <stdexcept>
#include <string>
#include "dispatch.hpp"

namespace {
volatile long selected = -1;
HMODULE self_module;
unsigned char* site = nullptr;
void* stub = nullptr;
std::array<unsigned char, 5> original{}, installed{};
bool active = false;
// Compatibility contract for the verified Windows Steam build. No game bytes
// are embedded or distributed. Runtime bytes are compared to the hashed file.
constexpr std::size_t site_rva = 0x5061391, budget_rva = 0x50613a0;
constexpr std::size_t premium_rva = 0x5061396, resume_rva = 0x50613a8;
constexpr std::size_t free_fee_rva = 0x9145800;
constexpr const char* expected_hash = "914cc10f1d803725d88caabe31c90f9e2d129bdde742fdbc7e467a4cb7ab25d8";

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
std::vector<unsigned char> read_verified_image() {
    std::ifstream file(module_path(nullptr), std::ios::binary | std::ios::ate);
    if (!file) throw std::runtime_error("Cannot read game executable");
    auto size = file.tellg();
    if (size != 157978112) throw std::runtime_error("Unsupported game executable size");
    std::vector<unsigned char> data(static_cast<std::size_t>(size));
    file.seekg(0); file.read(reinterpret_cast<char*>(data.data()), size);
    if (!file) throw std::runtime_error("Cannot read game executable");
    std::array<unsigned char, 32> hash{};
    if (BCryptHash(BCRYPT_SHA256_ALG_HANDLE, nullptr, 0, data.data(),
                   static_cast<ULONG>(data.size()), hash.data(), static_cast<ULONG>(hash.size())) < 0)
        throw std::runtime_error("SHA-256 failed");
    const char* digits = "0123456789abcdef";
    std::string hex;
    for (auto byte : hash) { hex += digits[byte >> 4]; hex += digits[byte & 15]; }
    if (hex != expected_hash) throw std::runtime_error("Unsupported game build; no patch applied");
    return data;
}
const unsigned char* file_at(const std::vector<unsigned char>& data, std::size_t rva, std::size_t size) {
    const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(data.data());
    const auto* nt = reinterpret_cast<const IMAGE_NT_HEADERS64*>(data.data() + dos->e_lfanew);
    const auto* section = IMAGE_FIRST_SECTION(nt);
    for (unsigned i = 0; i < nt->FileHeader.NumberOfSections; ++i) {
        if (rva >= section[i].VirtualAddress && rva + size <= section[i].VirtualAddress + section[i].SizeOfRawData) {
            const auto offset = section[i].PointerToRawData + rva - section[i].VirtualAddress;
            if (offset + size <= data.size()) return data.data() + offset;
        }
    }
    throw std::runtime_error("Invalid compatibility range");
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
    if (active) { status("ready"); return; }
    const auto data = read_verified_image();
    auto* base = reinterpret_cast<unsigned char*>(GetModuleHandleW(nullptr));
    // Cover the complete evaluator and its free-service coefficient, catching
    // another mod's changes even when the on-disk executable still matches.
    if (std::memcmp(base + 0x5060e30, file_at(data, 0x5060e30, 0x88f), 0x88f) != 0 ||
        std::memcmp(base + free_fee_rva, file_at(data, free_fee_rva, 4), 4) != 0)
        throw std::runtime_error("Automatic order code was already modified");
    site = base + site_rva;
    std::memcpy(original.data(), site, original.size());
    const auto code = delivery::dispatch(&selected, base + free_fee_rva, base + budget_rva,
                                          base + premium_rva, base + resume_rva);
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
// status acknowledgment and invokes every entry point on the game thread.
extern "C" {
__declspec(dllexport) int delivery_initialize(void*) { return invoke(initialize); }
__declspec(dllexport) int delivery_free(void*) { return invoke([] { select(0); }); }
__declspec(dllexport) int delivery_budget(void*) { return invoke([] { select(1); }); }
__declspec(dllexport) int delivery_premium(void*) { return invoke([] { select(2); }); }
__declspec(dllexport) int delivery_disable(void*) { return invoke(disable); }
}
BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) { self_module = module; DisableThreadLibraryCalls(module); }
    return TRUE;
}
