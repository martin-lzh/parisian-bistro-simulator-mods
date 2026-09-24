#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include "dispatch.hpp"
#include "pe_image.hpp"

template<class T> void put(std::vector<unsigned char>& data, std::size_t offset, const T& value) {
    std::memcpy(data.data() + offset, &value, sizeof(value));
}
void check_image_ranges() {
    // Original synthetic PE: code has disk bytes; writable data has a larger
    // virtual size, like the zero-filled data that caused startup to fail.
    std::vector<unsigned char> image(0x800);
    IMAGE_DOS_HEADER dos{};
    dos.e_magic = IMAGE_DOS_SIGNATURE; dos.e_lfanew = 0x80;
    put(image, 0, dos);
    put(image, 0x80, static_cast<DWORD>(IMAGE_NT_SIGNATURE));
    IMAGE_FILE_HEADER file{};
    file.NumberOfSections = 2; file.SizeOfOptionalHeader = sizeof(IMAGE_OPTIONAL_HEADER64);
    put(image, 0x84, file);
    const auto sections = 0x84 + sizeof(file) + file.SizeOfOptionalHeader;
    IMAGE_SECTION_HEADER code{}, data{};
    code.VirtualAddress = 0x1000; code.Misc.VirtualSize = code.SizeOfRawData = 0x200;
    code.PointerToRawData = 0x400; code.Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_EXECUTE;
    data.VirtualAddress = 0x2000; data.Misc.VirtualSize = 0x600; data.SizeOfRawData = 0x200;
    data.PointerToRawData = 0x600; data.Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE;
    put(image, sections, code); put(image, sections + sizeof(code), data);
    int checks = 0;
    auto check = [&](bool ok) {
        if (!ok) throw std::runtime_error("PE range regression failed");
        ++checks;
    };
    auto rejected = [&](auto operation) {
        bool failed = false;
        try { operation(); } catch (const std::runtime_error&) { failed = true; }
        check(failed);
    };
    check(delivery::pe::file_at(image, 0x1010, 4) == image.data() + 0x410);
    check(delivery::pe::file_at(image, 0x21fc, 4) == image.data() + 0x7fc);
    delivery::pe::require_writable_data(image, 0x2100, 4); ++checks;
    delivery::pe::require_writable_data(image, 0x2400, 4); ++checks;
    delivery::pe::require_writable_data(image, 0x25fc, 4); ++checks;
    rejected([&] { delivery::pe::file_at(image, 0x2400, 4); }); // the old lookup must reject this
    rejected([&] { delivery::pe::file_at(image, 0x21ff, 4); }); // no partial disk range
    rejected([&] { delivery::pe::require_writable_data(image, 0x25ff, 4); });
    rejected([&] { delivery::pe::require_writable_data(image, 0x2600, 4); });
    rejected([&] { delivery::pe::require_writable_data(image, 0x1010, 4); }); // code is not data
    rejected([&] { delivery::pe::file_at(image, 0x1010, SIZE_MAX); });
    image.resize(0x700);
    rejected([&] { delivery::pe::file_at(image, 0x21fc, 4); }); // truncated disk bytes
    image.resize(0x40);
    rejected([&] { delivery::pe::file_at(image, 0x1010, 4); }); // truncated headers
    std::cout << "PASS PE image ranges: " << checks << " cases\n";
}

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
    check_image_ranges();
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
