#pragma once
#include <array>
#include <string>
#include "pe_image.hpp"

namespace automenu {
struct Contract {
    std::size_t projection, release, score;
    std::array<std::size_t, 5> calls;
    std::array<std::uint32_t, 2> menus;
    std::vector<std::pair<std::size_t, std::size_t>> checked;
};

// Discover from a named Unreal native registration. Relative instruction
// offsets below describe the supported calling convention, not game RVAs.
// Unrecognized code is rejected before any pointer call or patch.
class ContractImage {
    const std::vector<unsigned char>& data;
    IMAGE_OPTIONAL_HEADER64 optional{};
    std::vector<IMAGE_SECTION_HEADER> sections;
    template<class T> T at(std::size_t rva) const {
        T value; std::memcpy(&value, pe::file_at(data, rva, sizeof(T)), sizeof(T)); return value;
    }
    std::size_t pointer(std::uint64_t va) const {
        if (va < optional.ImageBase || va - optional.ImageBase >= optional.SizeOfImage)
            throw std::runtime_error("Native pointer is outside the image");
        return static_cast<std::size_t>(va - optional.ImageBase);
    }
    void code(std::size_t rva, std::size_t count) const {
        if (!(pe::section_at(data, rva, count, true).Characteristics & IMAGE_SCN_MEM_EXECUTE))
            throw std::runtime_error("Native target is not executable");
        pe::file_at(data, rva, count);
    }
    void expect(std::size_t rva, std::initializer_list<int> bytes) const {
        code(rva, bytes.size());
        auto* p = pe::file_at(data, rva, bytes.size());
        for (auto value : bytes) {
            if (value >= 0 && *p != value) throw std::runtime_error("Native menu ABI changed");
            ++p;
        }
    }
    std::size_t call(std::size_t rva) const {
        expect(rva, {0xe8});
        const auto address = static_cast<std::int64_t>(rva + 5) + at<std::int32_t>(rva + 1);
        if (address < 0 || address >= optional.SizeOfImage) throw std::runtime_error("Invalid native call");
        code(static_cast<std::size_t>(address), 1); return static_cast<std::size_t>(address);
    }
    Contract resolve(std::size_t thunk) const {
        expect(thunk + 0x62, {0x48,0x8d,0x54,0x24,0x20,0x44,0x0f,0xb6,0x44,0x24,0x68});
        expect(thunk + 0x78, {0x48,0x8b,0xce,0x48,0x89,0x43,0x20});
        const auto projection = call(thunk + 0x7f);
        expect(thunk + 0x84, {0x48,0x8b,0xf0,0x4c,0x8d,0x77,0x18});
        expect(thunk + 0xf6, {0x8b,0x46,0x28,0x48,0x8b,0x4c,0x24,0x38,0x89,0x47,0x28,0x8b,0x46,0x2c});
        const auto release = call(thunk + 0xce);
        if (call(thunk + 0x10c) != release) throw std::runtime_error("Projection ownership ABI changed");
        expect(projection + 0x760, {0x44,0x0f,0xb6,0x0b,0x48,0x8d,0x54,0x24,0x3c,
            0x44,0x0f,0xb6,0x07,0x49,0x8b,0xcf,0x48,0xc7,0x44,0x24,0x20,0,0,0,0});
        const auto compatibility = call(projection + 0x779);
        // Context: manager, profile, intent, optional personal preferences.
        expect(compatibility + 0x86, {0x4c,0x89,0x7d,0xdf,0x44,0x88,0x6d,0xe7,
            0x44,0x88,0x65,0xe8,0x48,0x89,0x45,0xef});
        const auto score = call(compatibility + 0xa3);
        std::array<std::size_t, 5> calls{};
        constexpr std::array<std::size_t, 5> offsets{0xa3,0xf1,0x13f,0x18d,0x1db};
        for (std::size_t i = 0; i < calls.size(); ++i) {
            calls[i] = compatibility + offsets[i];
            expect(calls[i] - 8, {0x48,0x8d,0x55,0x5f,0x48,0x8d,0x4d,0xdf});
            if (call(calls[i]) != score) throw std::runtime_error("Dish scoring calls disagree");
        }
        // The helper writes a byte ID and float into caller-owned storage and
        // destroys its own temporary arrays. No owned object is cached.
        expect(score + 0x17, {0x48,0x8b,0xf1,0x41,0x0f,0xb6,0xd8,0x48,0x8b,0x09,
            0x48,0x8b,0xfa,0x88,0x1a,0x33,0xed,0x89,0x6a,0x04});
        expect(score + 0x10d, {0xf3,0x0f,0x11,0x47,0x04});
        for (auto offset : {0x117,0x129,0x138,0x147})
            if (call(score + offset) != release) throw std::runtime_error("Dish ownership ABI changed");
        expect(score + 0x154, {0x48,0x8b,0xc7});
        const auto getter = call(projection + 0x139);
        expect(getter, {0x41,0x80,0xf8,1,0x75,0x21,0x8b,0x81});
        expect(getter + 0x27, {0x41,0x80,0xf8,2,0x75,0x21,0x8b,0x81});
        const auto lunch = at<std::uint32_t>(getter + 8), dinner = at<std::uint32_t>(getter + 0x2f);
        if (lunch < 0x100 || lunch > 0x10000 || dinner != lunch + 7)
            throw std::runtime_error("Daily menu storage layout changed");
        return {projection, release, score, calls, {lunch,dinner},
            {{thunk,0x127},{projection,0x77e},{compatibility,0x1e0},{score,0x19f},{getter,0x62}}};
    }
public:
    explicit ContractImage(const std::vector<unsigned char>& image) : data(image) {
        const auto dos = pe::read<IMAGE_DOS_HEADER>(data, 0);
        if (dos.e_magic != IMAGE_DOS_SIGNATURE || dos.e_lfanew < 0) throw std::runtime_error("Invalid PE image");
        const auto nt = static_cast<std::size_t>(dos.e_lfanew);
        if (pe::read<DWORD>(data, nt) != IMAGE_NT_SIGNATURE) throw std::runtime_error("Invalid PE signature");
        const auto file = pe::read<IMAGE_FILE_HEADER>(data, nt + 4);
        optional = pe::read<IMAGE_OPTIONAL_HEADER64>(data, nt + 24);
        if (file.Machine != IMAGE_FILE_MACHINE_AMD64 || optional.Magic != IMAGE_NT_OPTIONAL_HDR64_MAGIC)
            throw std::runtime_error("Expected a Windows x64 image");
        const auto start = nt + 24 + file.SizeOfOptionalHeader;
        for (unsigned i = 0; i < file.NumberOfSections; ++i) {
            auto section = pe::read<IMAGE_SECTION_HEADER>(data, start + i * sizeof(IMAGE_SECTION_HEADER));
            if (section.PointerToRawData > data.size() || section.SizeOfRawData > data.size() - section.PointerToRawData)
                throw std::runtime_error("Truncated image section");
            sections.push_back(section);
        }
    }
    Contract discover() const {
        const std::string name = "GetDailyMenuProjection";
        std::vector<std::uint64_t> names;
        for (const auto& section : sections) {
            if (!(section.Characteristics & IMAGE_SCN_MEM_READ) || (section.Characteristics & IMAGE_SCN_MEM_EXECUTE)) continue;
            const auto begin = data.begin() + section.PointerToRawData, end = begin + section.SizeOfRawData;
            auto cursor = begin;
            while ((cursor = std::search(cursor, end, name.c_str(), name.c_str() + name.size() + 1)) != end) {
                names.push_back(optional.ImageBase + section.VirtualAddress + static_cast<std::size_t>(cursor - begin)); ++cursor;
            }
        }
        std::vector<Contract> matches;
        for (const auto& section : sections) {
            if (!(section.Characteristics & IMAGE_SCN_MEM_READ) ||
                (section.Characteristics & (IMAGE_SCN_MEM_WRITE | IMAGE_SCN_MEM_EXECUTE))) continue;
            for (std::size_t offset = 0; offset + 16 <= section.SizeOfRawData; offset += 8) {
                if (std::find(names.begin(), names.end(), pe::read<std::uint64_t>(data, section.PointerToRawData + offset)) == names.end()) continue;
                try { matches.push_back(resolve(pointer(at<std::uint64_t>(section.VirtualAddress + offset + 8)))); }
                catch (const std::runtime_error&) { continue; }
            }
        }
        if (matches.size() != 1) throw std::runtime_error("Unsupported native menu ABI; no patch applied");
        return matches.front();
    }
};
inline void require_unmodified(const std::vector<unsigned char>& data, const Contract& contract, const unsigned char* base) {
    for (const auto& range : contract.checked)
        if (std::memcmp(base + range.first, pe::file_at(data, range.first, range.second), range.second))
            throw std::runtime_error("Native menu code was modified by another module");
}
}
