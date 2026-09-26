#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <sstream>
#include "contract.hpp"
#include "search.hpp"

namespace {
using namespace automenu;
HMODULE self_module;
Contract contract{};
unsigned char* image_base;
ScoreFunction original_score;
using ProjectionFunction = void* (*)(void*, void*, std::uint8_t);
ProjectionFunction native_projection;
void (*native_release)(void*);
thread_local ScoreCache* active_cache = nullptr;
bool initialized = false;
std::array<std::array<unsigned char, 5>, 5> installed{};

std::filesystem::path module_path(HMODULE module) {
    std::wstring path(32768, L'\0');
    const auto length = GetModuleFileNameW(module, path.data(), static_cast<DWORD>(path.size()));
    if (!length || length == path.size()) throw std::runtime_error("Cannot locate native module");
    path.resize(length); return path;
}
std::vector<unsigned char> read_image(const std::filesystem::path& path) {
    std::ifstream file(path, std::ios::binary | std::ios::ate);
    const auto length = file.tellg();
    if (!file || length <= 0 || static_cast<std::uint64_t>(length) > UINT32_MAX)
        throw std::runtime_error("Cannot read executable");
    std::vector<unsigned char> bytes(static_cast<std::size_t>(length));
    file.seekg(0); file.read(reinterpret_cast<char*>(bytes.data()), length);
    if (!file) throw std::runtime_error("Cannot read executable bytes");
    return bytes;
}
void status(const std::string& message) {
    std::ofstream file(module_path(self_module).parent_path() / "auto-menu-result.txt", std::ios::trunc);
    file << message << '\n'; file.flush();
    if (!file) throw std::runtime_error("Cannot write native result");
}
DishScore* cached_score(const ScoreContext* context, DishScore* output, std::uint8_t dish) {
    return active_cache ? active_cache->score(original_score, context, output, dish) : original_score(context, output, dish);
}
void write_call(unsigned char* site, const std::array<unsigned char, 5>& value) {
    DWORD protection;
    if (!VirtualProtect(site, value.size(), PAGE_EXECUTE_READWRITE, &protection))
        throw std::runtime_error("Cannot protect native scoring call");
    std::memcpy(site, value.data(), value.size());
    DWORD ignored;
    const bool restored = VirtualProtect(site, value.size(), protection, &ignored) != 0;
    const bool flushed = FlushInstructionCache(GetCurrentProcess(), site, value.size()) != 0;
    if (!restored || !flushed) throw std::runtime_error("Cannot finalize native scoring call");
}
void emit_jump(unsigned char* stub, std::uintptr_t destination) {
    stub[0] = 0x48; stub[1] = 0xb8;
    std::memcpy(stub + 2, &destination, sizeof(destination)); stub[10] = 0xff; stub[11] = 0xe0;
}
std::array<unsigned char, 5> call_to(unsigned char* site, unsigned char* stub) {
    const auto displacement = reinterpret_cast<std::intptr_t>(stub) - reinterpret_cast<std::intptr_t>(site + 5);
    if (displacement < INT32_MIN || displacement > INT32_MAX) throw std::runtime_error("Scoring adapter is too far away");
    const auto relative = static_cast<std::int32_t>(displacement);
    std::array<unsigned char, 5> call{0xe8,0,0,0,0}; std::memcpy(call.data() + 1, &relative, 4);
    return call;
}
void initialize() {
    if (initialized) {
        for (std::size_t i = 0; i < installed.size(); ++i)
            if (std::memcmp(image_base + contract.calls[i], installed[i].data(), 5))
                throw std::runtime_error("Another module replaced the Auto Menu scoring calls");
        return;
    }
    const auto bytes = read_image(module_path(nullptr));
    contract = ContractImage(bytes).discover();
    image_base = reinterpret_cast<unsigned char*>(GetModuleHandleW(nullptr));
    require_unmodified(bytes, contract, image_base);
    original_score = reinterpret_cast<ScoreFunction>(image_base + contract.score);
    native_projection = reinterpret_cast<ProjectionFunction>(image_base + contract.projection);
    native_release = reinterpret_cast<void (*)(void*)>(image_base + contract.release);
    SYSTEM_INFO info{}; GetSystemInfo(&info);
    auto origin = reinterpret_cast<std::uintptr_t>(image_base + contract.calls[0]);
    origin -= origin % info.dwAllocationGranularity;
    unsigned char* stub = nullptr;
    for (std::uintptr_t distance = info.dwAllocationGranularity; distance < 0x70000000; distance += info.dwAllocationGranularity) {
        stub = static_cast<unsigned char*>(VirtualAlloc(reinterpret_cast<void*>(origin + distance), 4096,
            MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE));
        if (stub) break;
    }
    if (!stub) throw std::runtime_error("Cannot allocate nearby scoring adapter");
    // Leaf tail-jump: preserve the native argument registers and stack. RAX is
    // volatile. The DLL's compiled function owns its normal unwind metadata.
    emit_jump(stub, reinterpret_cast<std::uintptr_t>(&cached_score));
    DWORD protection;
    if (!VirtualProtect(stub, 4096, PAGE_EXECUTE_READ, &protection) ||
        !FlushInstructionCache(GetCurrentProcess(), stub, 12)) throw std::runtime_error("Cannot finalize scoring adapter");
    std::array<std::array<unsigned char, 5>, 5> originals{};
    for (std::size_t i = 0; i < installed.size(); ++i) {
        auto* site = image_base + contract.calls[i];
        installed[i] = call_to(site, stub);
        std::memcpy(originals[i].data(), site, 5);
    }
    HMODULE pinned;
    if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_PIN,
        reinterpret_cast<LPCWSTR>(&cached_score), &pinned)) throw std::runtime_error("Cannot retain native adapter");
    std::size_t applied = 0;
    try {
        for (; applied < installed.size(); ) {
            const auto index = applied++;
            write_call(image_base + contract.calls[index], installed[index]);
        }
    } catch (...) {
        // All addresses were validated first. Restore any partially installed
        // transaction; keep the pinned stub alive even if restoration fails.
        while (applied) { --applied; write_call(image_base + contract.calls[applied], originals[applied]); }
        throw;
    }
    initialized = true;
}

struct Request {
    void* owner = nullptr;
    void* manager = nullptr;
    Menu* storage = nullptr;
    unsigned period = 0;
    Menu original{};
    float ceiling = 0, baseline = 0;
    Domains domains;
    std::uint64_t combinations = 1;
};
unsigned byte(std::istream& input) {
    unsigned value;
    if (!(input >> value) || value > 255) throw std::runtime_error("Invalid menu byte");
    return value;
}
Request read_request(std::istream& file) {
    Request request; std::string version; std::uintptr_t owner, manager, storage;
    if (!(file >> version >> std::hex >> owner >> manager >> storage >> std::dec >> request.period) ||
        version != "AutoMenu1" || !owner || !manager || !storage || (request.period != 1 && request.period != 2))
        throw std::runtime_error("Invalid native request");
    request.owner = reinterpret_cast<void*>(owner); request.manager = reinterpret_cast<void*>(manager);
    request.storage = reinterpret_cast<Menu*>(storage);
    request.original.period = static_cast<std::uint8_t>(byte(file));
    request.original.active = static_cast<std::uint8_t>(byte(file));
    if (request.original.active > 1) throw std::runtime_error("Invalid menu activation");
    for (auto& dish : request.original.dishes) dish = static_cast<std::uint8_t>(byte(file));
    if (!(file >> request.ceiling >> request.baseline) || !std::isfinite(request.ceiling) || !std::isfinite(request.baseline) ||
        request.ceiling < 0 || request.ceiling > 1 || request.baseline < 0 || request.baseline > 1)
        throw std::runtime_error("Invalid native rate input");
    for (auto& domain : request.domains) {
        unsigned count;
        if (!(file >> count) || count < 1 || count > 256) throw std::runtime_error("Invalid menu domain");
        std::array<bool, 256> seen{};
        for (unsigned i = 0; i < count; ++i) {
            const auto id = byte(file);
            if (seen[id]) throw std::runtime_error("Duplicate menu choice");
            seen[id] = true; domain.push_back(static_cast<std::uint8_t>(id));
        }
        if (!seen[0]) throw std::runtime_error("Empty menu choice missing");
        request.combinations *= count;
    }
    if (file >> version) throw std::runtime_error("Unexpected request data");
    return request;
}
float project(void* owner, std::uint8_t period) {
    alignas(16) std::array<unsigned char, 48> output{};
    native_projection(owner, output.data(), period);
    float rate; void* fits;
    std::memcpy(&rate, output.data() + 8, sizeof(rate));
    std::memcpy(&fits, output.data() + 24, sizeof(fits));
    if (fits) native_release(fits);
    return rate;
}
void compose(const Request& request) {
    if (active_cache) throw std::runtime_error("Native composition is already running");
    if (reinterpret_cast<unsigned char*>(request.manager) + contract.menus[request.period - 1] !=
        reinterpret_cast<unsigned char*>(request.storage)) throw std::runtime_error("Menu property address does not match native layout");
    if (std::memcmp(request.storage, &request.original, sizeof(Menu))) throw std::runtime_error("Menu request does not match live storage");
    const auto period = static_cast<std::uint8_t>(request.period);
    if (!same_rate(project(request.owner, period), request.baseline))
        throw std::runtime_error("Native projection differs from Lua baseline");
    ScoreCache cache(request.manager);
    Result result;
    std::uint64_t checks = 0, visited = 0;
    const auto started = std::chrono::steady_clock::now();
    {
        RestoreMenu restore(request.storage);
        struct CacheScope {
            explicit CacheScope(ScoreCache& value) { active_cache = &value; }
            ~CacheScope() { active_cache = nullptr; }
        } scope(cache);
        auto trial = request.original; trial.period = period;
        result = solve(request.domains, trial, request.ceiling, [&](const Menu& menu) {
            *request.storage = menu;
            const float value = project(request.owner, period);
            // Every menu in small domains, and the first 32 in larger domains,
            // is compared bit-for-bit with cache bypassed. No trial is saved.
            if (request.combinations <= 243 || visited < 32) {
                cache.enabled = false;
                const float reference = project(request.owner, period);
                cache.enabled = true; ++checks;
                if (!same_rate(value, reference)) throw std::runtime_error("Native cache differential check failed");
            }
            ++visited; return value;
        });
        *request.storage = result.menu; cache.enabled = false;
        ++checks;
        if (!same_rate(result.rate, project(request.owner, period)))
            throw std::runtime_error("Native winner verification failed");
    }
    const double elapsed = std::chrono::duration<double>(std::chrono::steady_clock::now() - started).count();
    std::ostringstream output;
    output << std::setprecision(17) << "ok " << result.rate << ' ' << result.evaluations << ' ' << request.combinations << ' '
           << checks << ' ' << cache.hits << ' ' << cache.misses << ' ' << cache.bypasses << ' ' << elapsed;
    for (auto dish : result.menu.dishes) output << ' ' << static_cast<unsigned>(dish);
    status(output.str());
}
}

// No Lua ABI or second Lua runtime. One bounded request/result exchange per
// click; enumeration, native calls and caching remain inside this invocation.
extern "C" __declspec(dllexport) int auto_menu_compose(void*) noexcept {
    try {
        initialize();
        std::ifstream input(module_path(self_module).parent_path() / "auto-menu-request.txt");
        compose(read_request(input));
    } catch (const std::exception& error) {
        active_cache = nullptr;
        try { status(std::string("error: ") + error.what()); } catch (...) {}
    }
    return 0;
}
BOOL WINAPI DllMain(HINSTANCE module, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) { self_module = module; DisableThreadLibraryCalls(module); }
    return TRUE;
}
