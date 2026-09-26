#include <iostream>
#include <thread>
#include "bridge.cpp"

namespace {
void check(bool condition, const char* message) { if (!condition) throw std::runtime_error(message); }
float price = 1;
DishScore* synthetic_score(const ScoreContext* context, DishScore* output, std::uint8_t dish) {
    output->dish = dish;
    output->value = (dish * 3.0f + context->profile * 7.0f + context->intent * 11.0f) * price;
    if (context->preferences) output->value += 13;
    return output;
}
void cache_tests() {
    int manager = 0, other = 0;
    ScoreCache cache(&manager); DishScore a{}, b{};
    ScoreContext context{&manager,0,0,{},nullptr};
    for (unsigned profile = 0; profile < 7; ++profile) for (unsigned intent = 0; intent < 9; ++intent) {
        context.profile = static_cast<std::uint8_t>(profile); context.intent = static_cast<std::uint8_t>(intent);
        for (unsigned id = 0; id < 256; ++id) {
            auto dish = static_cast<std::uint8_t>(id);
            synthetic_score(&context, &a, dish);
            cache.score(synthetic_score, &context, &b, dish);
            check(same_rate(a.value, b.value) && a.dish == b.dish, "Cache miss differs");
            cache.score(synthetic_score, &context, &b, dish);
            check(same_rate(a.value, b.value), "Cache hit differs");
        }
    }
    check(cache.hits == 7 * 9 * 256 && cache.misses == cache.hits, "Context partition failed");
    context.preferences = &other; cache.score(synthetic_score, &context, &b, 3);
    context.preferences = nullptr; context.manager = &other; cache.score(synthetic_score, &context, &b, 3);
    context.manager = &manager; context.profile = 255; cache.score(synthetic_score, &context, &b, 3);
    context.profile = 0; context.intent = 255; cache.score(synthetic_score, &context, &b, 3);
    cache.enabled = false; cache.score(synthetic_score, &context, &b, 3);
    check(cache.bypasses == 5, "Unsupported contexts must bypass cache");
    {
        ScoreCache raw(&manager);
        ScoreContext clean{&manager,0,0,{},nullptr};
        auto payload = [](const ScoreContext*, DishScore* output, std::uint8_t dish) -> DishScore* {
            const std::uint32_t bits = dish ? 0x7fc12345u : 0x80000000u;
            output->dish = dish; std::memcpy(&output->value, &bits, sizeof(bits)); return output;
        };
        for (auto dish : {std::uint8_t(0),std::uint8_t(1)}) {
            raw.score(payload, &clean, &a, dish); raw.score(payload, &clean, &b, dish);
            check(same_rate(a.value,b.value), "Cache changed raw float bits");
        }
    }
    context.intent = 0;
    ScoreCache next(&manager); price = 2;
    next.score(synthetic_score, &context, &b, 3); synthetic_score(&context, &a, 3);
    check(same_rate(a.value, b.value), "A new search retained stale price data"); price = 1;
    original_score = synthetic_score;
    active_cache = &next;
    const auto hits = next.hits;
    std::thread worker([&] { check(active_cache == nullptr, "Cache leaked to another thread"); cached_score(&context, &b, 3); });
    worker.join(); check(next.hits == hits, "Other thread used cache"); active_cache = nullptr;
}
void search_tests() {
    Domains domains; for (auto& domain : domains) domain = {0,1,2};
    Menu trial{2,1,{0,0,0,0,0}};
    auto oracle = [](const Menu& menu) {
        return menu.dishes[0] == 2 && menu.dishes[1] == 1 && menu.dishes[2] == 0 ? 0.812345f : 0.1f;
    };
    const auto result = solve(domains, trial, 1, oracle);
    check(result.evaluations == 243 && same_rate(result.rate, 0.812345f), "Joint optimum or coverage failed");
    check(result.menu.dishes[0] == 2 && result.menu.dishes[1] == 1 && result.menu.dishes[2] == 0, "Wrong best menu");
    domains[0] = {2,0,1};
    const auto tie = solve(domains, trial, 1, [](const Menu&) { return .5f; });
    check(tie.menu.dishes[0] == 2 && tie.menu.dishes[4] == 0, "First tie not retained");
    const auto ceiling = solve(domains, trial, .5f, [](const Menu&) { return .5f; });
    check(ceiling.evaluations == 1, "Exact ceiling did not stop");
    const auto empty = solve(domains, trial, 1, [](const Menu& menu) {
        return menu.dishes == std::array<std::uint8_t,5>{} ? .7f : .2f;
    });
    check(empty.menu.dishes == std::array<std::uint8_t,5>{}, "Empty menu omitted");
    auto menu = trial;
    try {
        RestoreMenu guard(&menu);
        solve(domains, trial, 1, [&](const Menu& current) -> float { menu = current; throw std::runtime_error("test"); });
    } catch (const std::runtime_error&) {}
    check(!std::memcmp(&menu, &trial, sizeof(Menu)), "Failed search did not restore menu");
    bool rejected = false;
    try { solve(domains, trial, 1, [](const Menu&) { return NAN; }); } catch (const std::runtime_error&) { rejected = true; }
    check(rejected, "Invalid score was accepted");
    check(!same_rate(0.86f, std::nextafter(0.86f, 0.0f)), "Float verification rounded values");
    const auto precise = solve(domains, trial, 1, [](const Menu& menu) {
        return menu.dishes[0] == 1 ? 0.86f : std::nextafter(0.86f, 0.0f);
    });
    check(precise.menu.dishes[0] == 1, "Sub-display improvement was lost");
}
void machine_adapter_tests() {
    auto* memory = static_cast<unsigned char*>(VirtualAlloc(nullptr, 4096, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE));
    check(memory != nullptr, "Cannot allocate owned adapter test");
    // Our own x64 test caller: shadow space, call rel32, stack restore, return.
    const unsigned char caller[]{0x48,0x83,0xec,0x28,0xe8,0,0,0,0,0x48,0x83,0xc4,0x28,0xc3};
    std::memcpy(memory, caller, sizeof(caller));
    emit_jump(memory + 32, reinterpret_cast<std::uintptr_t>(&synthetic_score));
    emit_jump(memory + 48, reinterpret_cast<std::uintptr_t>(&cached_score));
    const auto original = call_to(memory + 4, memory + 32);
    std::memcpy(memory + 4, original.data(), original.size());
    DWORD old;
    check(VirtualProtect(memory,4096,PAGE_EXECUTE_READ,&old) != 0, "Cannot protect test caller");
    check(FlushInstructionCache(GetCurrentProcess(),memory,4096) != 0, "Cannot flush test caller");
    auto caller_function = reinterpret_cast<ScoreFunction>(memory);
    int manager; ScoreContext context{&manager,2,3,{},nullptr}; DishScore expected{}, output{};
    check(caller_function(&context,&expected,4) == &expected, "Original return ABI failed");
    original_score = synthetic_score;
    write_call(memory + 4, call_to(memory + 4, memory + 48));
    ScoreCache cache(&manager); active_cache = &cache;
    check(caller_function(&context,&output,4) == &output, "Adapter return ABI failed");
    check(same_rate(expected.value,output.value) && output.dish == 4, "Adapter arguments changed");
    caller_function(&context,&output,4); check(cache.hits == 1 && cache.misses == 1, "Machine adapter did not cache");
    active_cache = nullptr;
    price = 2; caller_function(&context,&output,4); price = 1;
    check(output.value == expected.value * 2, "Adapter cached outside search");
    write_call(memory + 4, original);
    check(VirtualFree(memory,0,MEM_RELEASE) != 0, "Cannot release test caller");
}
struct FakeManager { Menu lunch{1,1,{0,0,0,0,0}}, dinner{2,0,{1,1,1,1,1}}; };
std::uint64_t projection_calls = 0, releases = 0;
unsigned fail_on = 0;
bool mismatch = false;
void* fake_projection(void* owner, void* memory, std::uint8_t period) {
    ++projection_calls;
    if (fail_on && projection_calls == fail_on) throw std::runtime_error("Synthetic native failure");
    auto* manager = static_cast<FakeManager*>(owner);
    const Menu& menu = period == 1 ? manager->lunch : manager->dinner;
    float value = 0;
    ScoreContext context{manager, static_cast<std::uint8_t>(period), 0, {}, nullptr};
    // Deliberate joint terms, missing-ingredient filtering, and two scoring
    // passes emulate consumers of the adapter without copying a game formula.
    for (unsigned pass = 0; pass < 2; ++pass) for (auto dish : menu.dishes) {
        if (!dish || dish == 2) continue;
        DishScore output{}; value += cached_score(&context, &output, dish)->value / 1000;
    }
    if (menu.dishes[0] == 1 && menu.dishes[1] == 3) value += .2f;
    if (mismatch && active_cache && active_cache->enabled) value += .01f;
    auto* output = static_cast<unsigned char*>(memory);
    std::memcpy(output + 8, &value, sizeof(value));
    void* fits = new unsigned char[12]; std::memcpy(output + 24, &fits, sizeof(fits));
    return memory;
}
void fake_release(void* fits) { ++releases; delete[] static_cast<unsigned char*>(fits); }
Request fake_request(FakeManager& manager, unsigned period) {
    Request request;
    request.owner = request.manager = &manager; request.period = period;
    request.storage = period == 1 ? &manager.lunch : &manager.dinner;
    request.original = *request.storage; request.ceiling = 1;
    for (auto& domain : request.domains) domain = {0,1,3};
    request.combinations = 243;
    request.baseline = project(&manager, static_cast<std::uint8_t>(period));
    return request;
}
void composition_tests() {
    original_score = synthetic_score; native_projection = fake_projection; native_release = fake_release;
    contract.menus = {0,7};
    FakeManager manager; const auto before = manager;
    for (unsigned period : {1u,2u}) {
        auto request = fake_request(manager, period);
        compose(request);
        check(!std::memcmp(&manager, &before, sizeof(manager)) && !active_cache, "Composition leaked trial state");
        std::ifstream file(module_path(nullptr).parent_path() / "auto-menu-result.txt");
        std::string ok; float rate; std::uint64_t evaluations, combinations, checks, hits, misses, bypasses; double seconds;
        file >> ok >> rate >> evaluations >> combinations >> checks >> hits >> misses >> bypasses >> seconds;
        check(ok == "ok" && evaluations == 243 && combinations == 243 && checks == 244 && hits > misses,
            "Native result or full differential coverage failed");
        check(misses == 2, "Repeated dishes were recomputed");
    }
    {
        auto large = fake_request(manager, 1);
        constexpr std::array<unsigned,5> counts{7,16,13,13,7};
        large.combinations = 1;
        for (std::size_t i = 0; i < counts.size(); ++i) {
            large.domains[i].clear(); large.combinations *= counts[i];
            for (unsigned id = 0; id < counts[i]; ++id) large.domains[i].push_back(static_cast<std::uint8_t>(id));
        }
        compose(large);
        std::ifstream file(module_path(nullptr).parent_path() / "auto-menu-result.txt");
        std::string ok; float rate; std::uint64_t evaluations, combinations, checks, hits, misses;
        file >> ok >> rate >> evaluations >> combinations >> checks >> hits >> misses;
        check(ok == "ok" && evaluations == 132496 && combinations == evaluations && checks == 33 && misses == 14,
            "Large search coverage or bounded verification failed");
        check(!std::memcmp(&manager, &before, sizeof(manager)), "Large search did not restore original");
    }
    auto request = fake_request(manager, 1); mismatch = true;
    bool rejected = false;
    try { compose(request); } catch (const std::runtime_error&) { rejected = true; }
    mismatch = false;
    check(rejected && !active_cache && !std::memcmp(&manager, &before, sizeof(manager)), "Differential failure leaked state");
    fail_on = static_cast<unsigned>(projection_calls + 3); rejected = false;
    try { compose(request); } catch (const std::runtime_error&) { rejected = true; }
    fail_on = 0;
    check(rejected && !active_cache && !std::memcmp(&manager, &before, sizeof(manager)), "Native exception leaked state");
    check(projection_calls == releases + 1, "Projection array ownership leaked");
}
void request_tests() {
    std::istringstream input("AutoMenu1 10 20 30 1 1 1 0 0 0 0 0 0.95 0 2 1 0 1 0 1 0 1 0 1 0");
    auto request = read_request(input); check(request.combinations == 2, "Request parsing failed");
    for (const auto& text : {"AutoMenu1 0 1 1 1", "AutoMenu1 1 1 1 3", "AutoMenu1 1 1 1 1 1 1 0 0 0 0 0 1 0 2 0 0"}) {
        bool rejected = false; std::istringstream bad(text);
        try { read_request(bad); } catch (const std::runtime_error&) { rejected = true; }
        check(rejected, "Malformed request accepted");
    }
}
}
int main(int argc, char** argv) {
    try {
        if (argc == 3 && std::string(argv[1]) == "--inspect") {
            const auto bytes = read_image(argv[2]);
            const auto found = ContractImage(bytes).discover();
            check(found.projection != found.score && found.release != found.score, "Discovery returned overlapping functions");
            std::cout << "PASS read-only native discovery: five score calls, projection ownership, menu storage\n";
            return 0;
        }
        cache_tests(); search_tests(); machine_adapter_tests(); composition_tests(); request_tests();
        bool rejected = false;
        try { ContractImage(read_image(module_path(nullptr))).discover(); } catch (const std::runtime_error&) { rejected = true; }
        check(rejected, "Non-game executable accepted");
        std::cout << "PASS native cache keys, exact enumeration, native differential checks, ownership, restoration, protocol and thread isolation\n";
        return 0;
    } catch (const std::exception& error) { std::cerr << error.what() << '\n'; return 1; }
}
