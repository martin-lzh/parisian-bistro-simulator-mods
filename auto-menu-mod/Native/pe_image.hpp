#pragma once
#include <windows.h>
#include <algorithm>
#include <cstring>
#include <stdexcept>
#include <vector>

namespace automenu::pe {
template<class T> T read(const std::vector<unsigned char>& data, std::size_t offset) {
    if (offset > data.size() || sizeof(T) > data.size() - offset)
        throw std::runtime_error("Truncated compatibility image");
    T value;
    std::memcpy(&value, data.data() + offset, sizeof(value));
    return value;
}

inline IMAGE_SECTION_HEADER section_at(const std::vector<unsigned char>& data,
                                      std::size_t rva, std::size_t size, bool on_disk) {
    const auto dos = read<IMAGE_DOS_HEADER>(data, 0);
    if (dos.e_magic != IMAGE_DOS_SIGNATURE || dos.e_lfanew < 0)
        throw std::runtime_error("Invalid compatibility image");
    const auto nt = static_cast<std::size_t>(dos.e_lfanew);
    if (read<DWORD>(data, nt) != IMAGE_NT_SIGNATURE)
        throw std::runtime_error("Invalid compatibility image");
    const auto file = read<IMAGE_FILE_HEADER>(data, nt + sizeof(DWORD));
    const auto sections = nt + sizeof(DWORD) + sizeof(IMAGE_FILE_HEADER) + file.SizeOfOptionalHeader;
    for (unsigned i = 0; i < file.NumberOfSections; ++i) {
        const auto section = read<IMAGE_SECTION_HEADER>(data, sections + i * sizeof(IMAGE_SECTION_HEADER));
        const std::size_t length = on_disk ? section.SizeOfRawData :
            (std::max)(section.Misc.VirtualSize, section.SizeOfRawData);
        if (rva >= section.VirtualAddress) {
            const auto offset = rva - section.VirtualAddress;
            if (size > 0 && offset < length && size <= length - offset) return section;
        }
    }
    throw std::runtime_error(on_disk ? "Invalid file-backed compatibility range" : "Invalid mapped compatibility range");
}

inline const unsigned char* file_at(const std::vector<unsigned char>& data, std::size_t rva, std::size_t size) {
    const auto section = section_at(data, rva, size, true);
    const auto offset = static_cast<std::size_t>(section.PointerToRawData) + rva - section.VirtualAddress;
    if (offset > data.size() || size > data.size() - offset)
        throw std::runtime_error("Truncated compatibility range");
    return data.data() + offset;
}

}
