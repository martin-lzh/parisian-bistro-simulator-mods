#pragma once
#include <cstdint>
#include <cstring>
#include <vector>

// Original x64 dispatch stub. It preserves RAX and the stack, selects a native
// fee multiplier, and resumes before affordability and order submission.
namespace delivery {
inline std::vector<unsigned char> dispatch(const volatile long* mode,
                                          const void* free_fee, const void* budget,
                                          const void* premium, const void* resume,
                                          unsigned char threshold) {
    std::vector<unsigned char> code;
    auto bytes = [&](std::initializer_list<unsigned char> b) { code.insert(code.end(), b); };
    auto pointer = [&](const void* p) {
        auto n = reinterpret_cast<std::uintptr_t>(p);
        for (int i = 0; i < 8; ++i) code.push_back(static_cast<unsigned char>(n >> (8 * i)));
    };
    auto jump = [&](const void* p) { bytes({0xff, 0x25, 0, 0, 0, 0}); pointer(p); };
    // Each route restores the displaced comparison's flags as well as RAX.
    auto restore = [&] { bytes({0x58, 0x83, 0xfe, threshold}); };
    bytes({0x50, 0x48, 0xb8}); // push rax; mov rax, mode
    pointer(const_cast<const long*>(mode));
    bytes({0x8b, 0x00, 0x83, 0xf8, 0x00, 0x74, 0});
    const auto free_branch = code.size() - 1;
    bytes({0x83, 0xf8, 0x01, 0x74, 0});
    const auto budget_branch = code.size() - 1;
    bytes({0x83, 0xf8, 0x02, 0x74, 0});
    const auto premium_branch = code.size() - 1;
    // Disabled: preserve the game's quantity-based choice.
    restore(); bytes({0x7c, 14});
    jump(premium);
    jump(budget);
    code[free_branch] = static_cast<unsigned char>(code.size() - free_branch - 1);
    bytes({0x48, 0xb8}); pointer(free_fee);
    bytes({0xf3, 0x0f, 0x59, 0x00}); // mulss xmm0,[rax]
    restore();
    jump(resume);
    code[budget_branch] = static_cast<unsigned char>(code.size() - budget_branch - 1);
    restore(); jump(budget);
    code[premium_branch] = static_cast<unsigned char>(code.size() - premium_branch - 1);
    restore(); jump(premium);
    return code;
}
}
