#pragma once
#include <array>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <stdexcept>
#include <vector>

namespace automenu {
// Only the value types crossing this adapter's boundary, not an engine SDK.
struct Menu {
    std::uint8_t period, active;
    std::array<std::uint8_t, 5> dishes;
};
static_assert(sizeof(Menu) == 7);
using Domains = std::array<std::vector<std::uint8_t>, 5>;
struct Result { Menu menu{}; float rate = -1; std::uint64_t evaluations = 0; };

template<class Oracle> Result solve(const Domains& domains, Menu trial, float ceiling, Oracle&& oracle) {
    Result result;
    auto visit = [&](auto&& self, std::size_t course) -> bool {
        if (course != domains.size()) {
            for (auto id : domains[course]) {
                trial.dishes[course] = id;
                if (self(self, course + 1)) return true;
            }
            return false;
        }
        const float rate = oracle(trial);
        if (!std::isfinite(rate) || rate < 0 || rate > 1)
            throw std::runtime_error("Invalid native selection rate");
        ++result.evaluations;
        if (rate > result.rate) { result.rate = rate; result.menu = trial; }
        return rate == ceiling; // Exact native bound; never a rounded percentage.
    };
    visit(visit, 0);
    if (!result.evaluations) throw std::runtime_error("Empty search domain");
    return result;
}

struct ScoreContext {
    void* manager;
    std::uint8_t profile, intent;
    std::uint8_t padding[6];
    void* preferences;
};
struct DishScore { std::uint8_t dish, padding[3]; float value; };
static_assert(sizeof(ScoreContext) == 24 && sizeof(DishScore) == 8);
using ScoreFunction = DishScore* (*)(const ScoreContext*, DishScore*, std::uint8_t);

// A cache lives for exactly one synchronous composition. Prices, weather and
// events cannot tick during it. Personal preferences are never cached. Values
// are the original function's float bits; no scoring formula is duplicated.
class ScoreCache {
    struct Entry { std::uint32_t bits = 0; bool valid = false; };
    std::vector<Entry> entries{7 * 9 * 256};
    void* manager;
public:
    std::uint64_t hits = 0, misses = 0, bypasses = 0;
    bool enabled = true;
    explicit ScoreCache(void* owner) : manager(owner) {}
    DishScore* score(ScoreFunction original, const ScoreContext* context, DishScore* output, std::uint8_t dish) {
        if (!enabled || context->manager != manager || context->preferences || context->profile >= 7 || context->intent >= 9) {
            ++bypasses;
            return original(context, output, dish);
        }
        auto& entry = entries[(context->profile * 9u + context->intent) * 256u + dish];
        if (entry.valid) {
            ++hits; output->dish = dish;
            std::memcpy(&output->value, &entry.bits, sizeof(entry.bits));
            return output;
        }
        ++misses;
        auto* result = original(context, output, dish);
        std::memcpy(&entry.bits, &result->value, sizeof(entry.bits)); entry.valid = true;
        return result;
    }
};

class RestoreMenu {
    Menu* destination;
    Menu original;
public:
    explicit RestoreMenu(Menu* menu) : destination(menu), original(*menu) {}
    ~RestoreMenu() { *destination = original; }
    RestoreMenu(const RestoreMenu&) = delete;
    RestoreMenu& operator=(const RestoreMenu&) = delete;
};
inline bool same_rate(float a, float b) {
    std::uint32_t first, second;
    std::memcpy(&first, &a, sizeof(a)); std::memcpy(&second, &b, sizeof(b));
    return first == second;
}
}
