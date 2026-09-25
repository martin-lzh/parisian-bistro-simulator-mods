#pragma once
#include <cstdint>
#include <string>
#include <utility>
#include "pe_image.hpp"

namespace delivery {
struct Contract {
    std::size_t evaluator, evaluator_size, site, budget, premium, resume, free_fee;
    unsigned char threshold;
    std::vector<std::pair<std::size_t, std::size_t>> code_ranges;
};

// Resolve native registration names and instruction operands from the installed
// image. There is no executable hash, file-size allowlist or fixed game RVA.
// This deliberately recognizes only the x64 ABI that our dispatch implements.
class ContractImage {
    const std::vector<unsigned char>& data;
    IMAGE_OPTIONAL_HEADER64 optional{};
    std::vector<IMAGE_SECTION_HEADER> sections;

    template<class T> T at(std::size_t rva) const {
        T value;
        std::memcpy(&value, pe::file_at(data, rva, sizeof(T)), sizeof(T));
        return value;
    }
    std::size_t pointer(std::uint64_t va) const {
        if (va < optional.ImageBase || va - optional.ImageBase >= optional.SizeOfImage)
            throw std::runtime_error("Native registration points outside the image");
        return static_cast<std::size_t>(va - optional.ImageBase);
    }
    void code(std::size_t rva, std::size_t size) const {
        const auto section = pe::section_at(data, rva, size, true);
        if (!(section.Characteristics & IMAGE_SCN_MEM_EXECUTE))
            throw std::runtime_error("Native delivery target is not executable code");
        pe::file_at(data, rva, size);
    }
    std::size_t relative(std::size_t end, std::int64_t displacement) const {
        const auto target = static_cast<std::int64_t>(end) + displacement;
        if (target < 0 || target >= optional.SizeOfImage)
            throw std::runtime_error("Native delivery operand is outside the image");
        return static_cast<std::size_t>(target);
    }
    std::size_t branch(std::size_t rva, unsigned char opcode) const {
        code(rva, 5);
        if (at<unsigned char>(rva) != opcode)
            throw std::runtime_error("Native delivery call structure changed");
        const auto result = relative(rva + 5, at<std::int32_t>(rva + 1));
        code(result, 1);
        return result;
    }
    bool named(std::uint64_t va, const std::string& name) const {
        try {
            return std::memcmp(pe::file_at(data, pointer(va), name.size() + 1),
                               name.c_str(), name.size() + 1) == 0;
        } catch (const std::runtime_error&) { return false; }
    }
    std::size_t getter(std::size_t registration, const std::string& name) const {
        // The native registration array is contiguous; remain in this class's
        // array instead of accepting a getter from a different widget class.
        for (std::size_t index = 1; index < 128; ++index) {
            const auto entry = registration + index * 16;
            const auto text = at<std::uint64_t>(entry);
            const auto function = at<std::uint64_t>(entry + 8);
            code(pointer(function), 1);
            pe::file_at(data, pointer(text), 1);
            if (named(text, name)) return branch(pointer(function) + 30, 0xe8); // call rel32
        }
        throw std::runtime_error("Native delivery fee registration is missing");
    }
    struct Fee { std::size_t function, factor, coefficient; };
    std::size_t multiply(std::size_t rva) const {
        code(rva, 8);
        // Decode scalar single-precision multiply, XMM0 <- XMM0 * [RIP+disp32].
        if (at<unsigned char>(rva) != 0xf3 || at<unsigned char>(rva + 1) != 0x0f ||
            at<unsigned char>(rva + 2) != 0x59 || at<unsigned char>(rva + 3) != 0x05)
            throw std::runtime_error("Native delivery fee operand changed");
        const auto value = relative(rva + 8, at<std::int32_t>(rva + 4));
        const auto section = pe::section_at(data, value, sizeof(float), false);
        if (!(section.Characteristics & IMAGE_SCN_MEM_READ) ||
            (section.Characteristics & IMAGE_SCN_MEM_EXECUTE))
            throw std::runtime_error("Native delivery fee is not readable data");
        return value;
    }
    Fee fee(std::size_t registration, const std::string& name) const {
        const auto function = getter(registration, name);
        code(function, 22);
        // Decode sub/add RSP,40 around a call, scalar multiply, and return.
        if (at<std::uint32_t>(function) != 0x28ec8348 ||
            at<std::uint32_t>(function + 17) != 0x28c48348 ||
            at<unsigned char>(function + 21) != 0xc3)
            throw std::runtime_error("Native delivery fee getter ABI changed");
        return {function, branch(function + 4, 0xe8), multiply(function + 9)};
    }
    std::size_t unwind_root(IMAGE_RUNTIME_FUNCTION_ENTRY entry) const {
        for (unsigned depth = 0; depth < 64; ++depth) {
            const auto header = at<std::uint32_t>(entry.UnwindInfoAddress);
            if ((header & 7) != 1) throw std::runtime_error("Unknown native unwind format");
            if (!((header >> 3) & UNW_FLAG_CHAININFO)) return entry.BeginAddress;
            const auto count = (header >> 16) & 255;
            entry = at<IMAGE_RUNTIME_FUNCTION_ENTRY>(entry.UnwindInfoAddress + 4 + ((count + 1) & ~1u) * 2);
        }
        throw std::runtime_error("Cyclic native unwind chain");
    }
    std::size_t function_size(std::size_t start) const {
        const auto directory = optional.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXCEPTION];
        if (!directory.Size || directory.Size % sizeof(IMAGE_RUNTIME_FUNCTION_ENTRY))
            throw std::runtime_error("Native function boundaries are missing");
        pe::file_at(data, directory.VirtualAddress, directory.Size);
        std::size_t end = start;
        bool found = false;
        for (std::size_t offset = 0; offset < directory.Size; offset += sizeof(IMAGE_RUNTIME_FUNCTION_ENTRY)) {
            const auto entry = at<IMAGE_RUNTIME_FUNCTION_ENTRY>(directory.VirtualAddress + offset);
            if (!found && entry.BeginAddress != start) continue;
            if (entry.EndAddress <= entry.BeginAddress || unwind_root(entry) != start) break;
            if (found && entry.BeginAddress != end) break;
            end = entry.EndAddress; found = true;
        }
        if (!found || end <= start || end - start > 0x10000)
            throw std::runtime_error("Cannot bound automatic order evaluator");
        code(start, end - start);
        return end - start;
    }
    Contract resolve(std::size_t registration) const {
        const auto evaluator = branch(pointer(at<std::uint64_t>(registration + 8)) + 21, 0xe9);
        const auto size = function_size(evaluator);
        const auto free = fee(registration, "GetNoDeliveryPersonServiceFeePrice");
        const auto budget = fee(registration, "GetCheapShippingFeePrice");
        const auto premium = fee(registration, "GetExpensiveShippingFeePrice");
        if (free.factor != budget.factor || free.factor != premium.factor ||
            free.coefficient == budget.coefficient || free.coefficient == premium.coefficient ||
            budget.coefficient == premium.coefficient)
            throw std::runtime_error("Native delivery fee getters disagree");
        pe::require_writable_data(data, free.coefficient, sizeof(float));
        std::vector<Contract> matches;
        // Recognize cmp ESI,imm8; jl budget; premium multiply; jmp resume;
        // budget multiply. Both coefficients and the preceding difficulty call
        // must agree with the named native getters, not just opcode shapes.
        for (std::size_t offset = 5; offset + 23 < size; ++offset) {
            const auto site = evaluator + offset;
            if (at<unsigned char>(site) != 0x83 || at<unsigned char>(site + 1) != 0xfe ||
                at<unsigned char>(site + 3) != 0x7c || at<unsigned char>(site + 13) != 0xeb) continue;
            try {
                const auto threshold = at<unsigned char>(site + 2);
                if (!threshold || threshold > 127 || branch(site - 5, 0xe8) != free.factor ||
                    relative(site + 5, at<std::int8_t>(site + 4)) != site + 15 ||
                    relative(site + 15, at<std::int8_t>(site + 14)) != site + 23 ||
                    multiply(site + 5) != premium.coefficient ||
                    multiply(site + 15) != budget.coefficient) continue;
                matches.push_back({evaluator, size, site, site + 15, site + 5, site + 23,
                    free.coefficient, threshold,
                    {{evaluator, size}, {free.function, 22}, {budget.function, 22}, {premium.function, 22}}});
            } catch (const std::runtime_error&) { continue; }
        }
        if (matches.size() != 1) throw std::runtime_error("Automatic delivery branch is missing or ambiguous");
        return matches.front();
    }
public:
    explicit ContractImage(const std::vector<unsigned char>& bytes) : data(bytes) {
        const auto dos = pe::read<IMAGE_DOS_HEADER>(data, 0);
        if (dos.e_magic != IMAGE_DOS_SIGNATURE || dos.e_lfanew < 0)
            throw std::runtime_error("Unsupported executable format");
        const auto nt = static_cast<std::size_t>(dos.e_lfanew);
        const auto file = pe::read<IMAGE_FILE_HEADER>(data, nt + sizeof(DWORD));
        if (pe::read<DWORD>(data, nt) != IMAGE_NT_SIGNATURE || file.Machine != IMAGE_FILE_MACHINE_AMD64 ||
            file.SizeOfOptionalHeader != sizeof(optional) || !file.NumberOfSections || file.NumberOfSections > 96)
            throw std::runtime_error("Unsupported executable format");
        optional = pe::read<IMAGE_OPTIONAL_HEADER64>(data, nt + sizeof(DWORD) + sizeof(file));
        if (optional.Magic != IMAGE_NT_OPTIONAL_HDR64_MAGIC ||
            optional.NumberOfRvaAndSizes <= IMAGE_DIRECTORY_ENTRY_EXCEPTION)
            throw std::runtime_error("Unsupported executable format");
        const auto first = nt + sizeof(DWORD) + sizeof(file) + sizeof(optional);
        for (unsigned i = 0; i < file.NumberOfSections; ++i) {
            const auto section = pe::read<IMAGE_SECTION_HEADER>(data, first + i * sizeof(IMAGE_SECTION_HEADER));
            if (section.PointerToRawData > data.size() || section.SizeOfRawData > data.size() - section.PointerToRawData ||
                section.VirtualAddress >= optional.SizeOfImage ||
                (std::max)(section.Misc.VirtualSize, section.SizeOfRawData) > optional.SizeOfImage - section.VirtualAddress)
                throw std::runtime_error("Truncated executable section");
            sections.push_back(section);
        }
    }
    Contract discover() const {
        std::vector<std::uint64_t> names;
        const std::string name = "EvaluateAutomaticSmartOrder";
        for (const auto& section : sections) {
            if (!(section.Characteristics & IMAGE_SCN_MEM_READ) || (section.Characteristics & IMAGE_SCN_MEM_EXECUTE)) continue;
            const auto begin = data.begin() + section.PointerToRawData;
            const auto end = begin + section.SizeOfRawData;
            auto cursor = begin;
            while ((cursor = std::search(cursor, end, name.c_str(), name.c_str() + name.size() + 1)) != end) {
                names.push_back(optional.ImageBase + section.VirtualAddress + static_cast<std::size_t>(cursor - begin));
                ++cursor;
            }
        }
        std::vector<Contract> matches;
        for (const auto& section : sections) {
            if (!(section.Characteristics & IMAGE_SCN_MEM_READ) ||
                (section.Characteristics & (IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE))) continue;
            for (std::size_t offset = 0; offset + 16 <= section.SizeOfRawData; offset += 8) {
                const auto va = pe::read<std::uint64_t>(data, section.PointerToRawData + offset);
                if (std::find(names.begin(), names.end(), va) == names.end()) continue;
                try { matches.push_back(resolve(section.VirtualAddress + offset)); }
                catch (const std::runtime_error&) { continue; }
            }
        }
        if (matches.size() != 1)
            throw std::runtime_error("Cannot uniquely resolve native automatic delivery code; no patch applied");
        return matches.front();
    }
};

inline void require_unmodified(const std::vector<unsigned char>& data,
                               const Contract& contract, const unsigned char* base) {
    for (const auto& range : contract.code_ranges) {
        if (std::memcmp(base + range.first, pe::file_at(data, range.first, range.second), range.second) != 0)
            throw std::runtime_error("Automatic delivery code was already modified");
    }
}
}
