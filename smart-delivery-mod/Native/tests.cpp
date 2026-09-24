#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include "dispatch.hpp"

extern "C" float probe_dispatch(void*, float, int, std::uint64_t*);
void* executable(const std::vector<unsigned char>& code) {
    void* block = VirtualAlloc(nullptr, 4096, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
    if (!block) throw std::runtime_error("Test allocation failed");
    std::memcpy(block, code.data(), code.size());
    DWORD old;
    if (!VirtualProtect(block, 4096, PAGE_EXECUTE_READ, &old)) throw std::runtime_error("Test protection failed");
    FlushInstructionCache(GetCurrentProcess(), block, code.size());
    return block;
}
void* multiplier(const float* factor) {
    std::vector<unsigned char> code{0x50, 0x48, 0xb8};
    const auto address = reinterpret_cast<std::uintptr_t>(factor);
    for (int i = 0; i < 8; ++i) code.push_back(static_cast<unsigned char>(address >> (8 * i)));
    code.insert(code.end(), {0xf3, 0x0f, 0x59, 0x00, 0x58, 0xc3});
    return executable(code);
}
int main() {
    volatile long mode = -1;
    float free_fee = 0, budget_fee = 50, premium_fee = 150;
    auto budget = multiplier(&budget_fee), premium = multiplier(&premium_fee), resume = executable({0xc3});
    auto stub = executable(delivery::dispatch(&mode, &free_fee, budget, premium, resume));
    int checks = 0;
    for (float free_value : {0.f, 7.f}) {
        free_fee = free_value;
        for (long choice : {-1L, 0L, 1L, 2L, 999L}) {
            mode = choice;
            for (int quantity : {0, 1, 3, 4, 8, 100}) {
                for (float difficulty : {0.5f, 1.f, 1.25f, 2.f}) {
                    const float expected = difficulty * (choice == 0 ? free_fee : choice == 1 ? budget_fee :
                        choice == 2 ? premium_fee : quantity < 4 ? budget_fee : premium_fee);
                    std::uint64_t rax = 0;
                    const float actual = probe_dispatch(stub, difficulty, quantity, &rax);
                    if (actual != expected || rax != 0x1122334455667788ULL)
                        throw std::runtime_error("Dispatch fee or register preservation failed");
                    ++checks;
                }
            }
        }
    }
    for (auto block : {stub, budget, premium, resume}) VirtualFree(block, 0, MEM_RELEASE);
    std::cout << "PASS native dispatch: " << checks << " executable cases\n";
}
