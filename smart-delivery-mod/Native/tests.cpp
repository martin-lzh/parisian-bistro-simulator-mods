#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <array>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include "dispatch.hpp"
#include "pe_image.hpp"
#include "contract.hpp"

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

// Construct a small original PE fixture with relocatable native registration
// records, fee routines and chained unwind ranges. No game bytes are fixtures.
struct ContractFixture {
    std::vector<unsigned char> data = std::vector<unsigned char>(0x4600);
    DWORD text, table, writable, evaluator, site;
    std::uint64_t base;
    std::size_t section_headers;
    template<class T> void write(DWORD rva, const T& value) {
        const auto location = delivery::pe::file_at(data, rva, sizeof(T)) - data.data();
        put(data, static_cast<std::size_t>(location), value);
    }
    void bytes(DWORD rva, std::initializer_list<unsigned char> value) {
        for (auto byte : value) write(rva++, byte);
    }
    void relative(DWORD rva, DWORD target) {
        write(rva, static_cast<std::int32_t>(static_cast<std::int64_t>(target) - rva - 4));
    }
    void multiply(DWORD rva, DWORD target) {
        bytes(rva, {0xf3, 0x0f, 0x59, 0x05}); relative(rva + 4, target);
    }
    ContractFixture(DWORD shift = 0, std::uint64_t image_base = 0x180000000ULL, unsigned char threshold = 4)
        : text(shift + 0x1000), table(shift + 0x4000), writable(shift + 0x8000),
          evaluator(text + 0x300), site(evaluator + 0x30), base(image_base) {
        IMAGE_DOS_HEADER dos{}; dos.e_magic = IMAGE_DOS_SIGNATURE; dos.e_lfanew = 0x80;
        put(data, 0, dos); put(data, 0x80, static_cast<DWORD>(IMAGE_NT_SIGNATURE));
        IMAGE_FILE_HEADER file{}; file.Machine = IMAGE_FILE_MACHINE_AMD64;
        file.NumberOfSections = 3; file.SizeOfOptionalHeader = sizeof(IMAGE_OPTIONAL_HEADER64);
        put(data, 0x84, file);
        IMAGE_OPTIONAL_HEADER64 optional{};
        optional.Magic = IMAGE_NT_OPTIONAL_HDR64_MAGIC; optional.ImageBase = base;
        optional.SizeOfImage = shift + 0x9000; optional.NumberOfRvaAndSizes = IMAGE_NUMBEROF_DIRECTORY_ENTRIES;
        optional.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXCEPTION] = {table + 0x400, 24};
        put(data, 0x84 + sizeof(file), optional);
        section_headers = 0x84 + sizeof(file) + sizeof(optional);
        IMAGE_SECTION_HEADER code{}, names{}, values{};
        code.VirtualAddress = text; code.PointerToRawData = 0x400;
        code.Misc.VirtualSize = code.SizeOfRawData = 0x2000;
        code.Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_EXECUTE;
        names.VirtualAddress = table; names.PointerToRawData = 0x2400;
        names.Misc.VirtualSize = names.SizeOfRawData = 0x2000;
        names.Characteristics = IMAGE_SCN_MEM_READ;
        values.VirtualAddress = writable; values.PointerToRawData = 0x4400;
        values.Misc.VirtualSize = 0x600; values.SizeOfRawData = 0x200;
        values.Characteristics = IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE;
        put(data, section_headers, code); put(data, section_headers + sizeof(code), names);
        put(data, section_headers + 2 * sizeof(code), values);
        const std::array<const char*, 4> labels{"EvaluateAutomaticSmartOrder", "GetCheapShippingFeePrice",
            "GetExpensiveShippingFeePrice", "GetNoDeliveryPersonServiceFeePrice"};
        for (unsigned i = 0; i < labels.size(); ++i) {
            const auto name = table + 0x800 + i * 0x80;
            const auto thunk = i == 0 ? text + 0x100 : text + 0x1000 + i * 0x100;
            const std::string label = labels[i];
            for (unsigned j = 0; j <= label.size(); ++j) write(name + j, label.c_str()[j]);
            write(table + i * 16, base + name); write(table + i * 16 + 8, base + thunk);
            if (i == 0) { bytes(thunk + 21, {0xe9}); relative(thunk + 22, evaluator); }
            else {
                const auto function = text + 0x1500 + i * 0x40;
                bytes(thunk + 30, {0xe8}); relative(thunk + 31, function);
                bytes(function, {0x48, 0x83, 0xec, 0x28, 0xe8});
                relative(function + 5, text + 0x1800);
                multiply(function + 9, i == 3 ? writable + 0x400 : table + 0x1500 + i * 4);
                bytes(function + 17, {0x48, 0x83, 0xc4, 0x28, 0xc3});
            }
        }
        IMAGE_RUNTIME_FUNCTION_ENTRY first{}, chained{};
        first.BeginAddress = evaluator; first.EndAddress = evaluator + 0x20; first.UnwindInfoAddress = table + 0x500;
        chained.BeginAddress = first.EndAddress; chained.EndAddress = evaluator + 0x100;
        chained.UnwindInfoAddress = table + 0x520;
        write(table + 0x400, first); write(table + 0x40c, chained);
        write(table + 0x500, std::uint32_t{1});
        write(table + 0x520, std::uint32_t{1 | (UNW_FLAG_CHAININFO << 3)});
        write(table + 0x524, first);
        bytes(site - 5, {0xe8}); relative(site - 4, text + 0x1800);
        bytes(site, {0x83, 0xfe, threshold, 0x7c, 10});
        multiply(site + 5, table + 0x1508);
        bytes(site + 13, {0xeb, 8}); multiply(site + 15, table + 0x1504);
        // Valid but unrelated bytes may change across releases.
        bytes(evaluator + 0x80, {0xc3});
    }
};

void check_contracts() {
    int checks = 0;
    auto check = [&](bool ok) { if (!ok) throw std::runtime_error("Native discovery regression failed"); ++checks; };
    auto rejected = [&](auto operation) {
        bool failed = false;
        try { operation(); } catch (const std::runtime_error&) { failed = true; }
        check(failed);
    };
    for (DWORD shift : {0u, 0x23000u}) {
        for (auto base : {0x140000000ULL, 0x180000000ULL}) {
            ContractFixture fixture(shift, base, 7);
            fixture.data.push_back(0xaa); // Arbitrary overlay/file-size changes are allowed.
            fixture.bytes(fixture.evaluator + 0x80, {0x90, 0xc3});
            const auto c = delivery::ContractImage(fixture.data).discover();
            check(c.evaluator == fixture.evaluator && c.evaluator_size == 0x100 && c.site == fixture.site &&
                  c.premium == fixture.site + 5 && c.budget == fixture.site + 15 && c.resume == fixture.site + 23 &&
                  c.free_fee == fixture.writable + 0x400 && c.threshold == 7);
            std::vector<unsigned char> mapped(shift + 0x9000);
            for (const auto& range : c.code_ranges)
                std::memcpy(mapped.data() + range.first, delivery::pe::file_at(fixture.data, range.first, range.second), range.second);
            mapped[c.free_fee] = 77; // Runtime fee data must not be compared to file bytes.
            delivery::require_unmodified(fixture.data, c, mapped.data()); ++checks;
            mapped[c.site] ^= 1;
            rejected([&] { delivery::require_unmodified(fixture.data, c, mapped.data()); });
            mapped[c.site] ^= 1;
            mapped[c.code_ranges.back().first] ^= 1;
            rejected([&] { delivery::require_unmodified(fixture.data, c, mapped.data()); });
        }
    }
    auto invalid = [&](auto mutation) {
        ContractFixture fixture;
        mutation(fixture);
        rejected([&] { delivery::ContractImage(fixture.data).discover(); });
    };
    invalid([](auto& f) { f.bytes(f.site + 1, {0xff}); }); // Wrong quantity register.
    invalid([](auto& f) { f.bytes(f.site + 4, {9}); }); // Branch into an instruction.
    invalid([](auto& f) { f.relative(f.site + 9, f.table + 0x1510); }); // Wrong premium coefficient.
    invalid([](auto& f) { f.relative(f.site - 4, f.text + 0x1810); }); // Wrong difficulty getter.
    invalid([](auto& f) { f.bytes(f.text + 0x15c0 + 21, {0x90}); }); // Fee getter no longer returns.
    invalid([](auto& f) { f.write(f.table + 3 * 16, f.base + f.table + 0x1900); }); // Required name missing.
    invalid([](auto& f) {
        for (unsigned i = 0; i < 64; ++i) f.write(f.table + 0x1800 + i,
            *delivery::pe::file_at(f.data, f.table + i, 1));
    }); // Multiple eligible native registration arrays.
    invalid([](auto& f) {
        const auto src = delivery::pe::file_at(f.data, f.site - 5, 28);
        const std::vector<unsigned char> copy(src, src + 28);
        for (unsigned i = 0; i < copy.size(); ++i) f.write(f.site + 0x40 - 5 + i, copy[i]);
        f.relative(f.site + 0x40 - 4, f.text + 0x1800);
        f.relative(f.site + 0x40 + 9, f.table + 0x1508);
        f.relative(f.site + 0x40 + 19, f.table + 0x1504);
    }); // Multiple eligible delivery branches.
    invalid([](auto& f) { f.write(f.table + 0x524 + 8, f.table + 0x520); }); // Cyclic unwind chain.
    invalid([](auto& f) { f.data.resize(0x300); });
    invalid([](auto& f) { put(f.data, f.section_headers + 2 * sizeof(IMAGE_SECTION_HEADER) +
        offsetof(IMAGE_SECTION_HEADER, Characteristics), static_cast<DWORD>(IMAGE_SCN_MEM_READ)); });
    std::cout << "PASS native discovery: " << checks << " cases\n";
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
    check_contracts();
    volatile long mode = -1;
    float free_fee = 0, budget_fee = 50, premium_fee = 150;
    auto budget = multiplier(&budget_fee), premium = multiplier(&premium_fee), resume = executable({0xc3});
    int checks = 0;
    for (unsigned char threshold : std::array<unsigned char, 2>{4, 7}) {
        auto stub = executable(delivery::dispatch(&mode, &free_fee, budget, premium, resume, threshold));
        auto compare = executable({0x83, 0xfe, threshold, 0xc3});
        for (float free_value : {0.f, 7.f}) {
            free_fee = free_value;
            for (long choice : {-1L, 0L, 1L, 2L, 999L}) {
                mode = choice;
                for (int quantity : {0, 1, 3, 4, 6, 7, 8, 100}) {
                    for (float difficulty : {0.5f, 1.f, 1.25f, 2.f}) {
                        const float expected = difficulty * (choice == 0 ? free_fee : choice == 1 ? budget_fee :
                            choice == 2 ? premium_fee : quantity < threshold ? budget_fee : premium_fee);
                        std::uint64_t state[2]{}, original[2]{};
                        probe_dispatch(compare, difficulty, quantity, original);
                        const float actual = probe_dispatch(stub, difficulty, quantity, state);
                        if (actual != expected || state[0] != 0x1122334455667788ULL ||
                            (state[1] & 0x8d5) != (original[1] & 0x8d5))
                            throw std::runtime_error("Dispatch fee, register or comparison flags changed");
                        ++checks;
                    }
                }
            }
        }
        VirtualFree(stub, 0, MEM_RELEASE); VirtualFree(compare, 0, MEM_RELEASE);
    }
    for (auto block : {budget, premium, resume}) VirtualFree(block, 0, MEM_RELEASE);
    std::cout << "PASS native dispatch: " << checks << " executable cases\n";
}
