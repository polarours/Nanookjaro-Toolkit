#pragma once

#include <string>

namespace nanookjaro::hardware::memory {

struct MemoryInfo {
    long long total_mb;
    long long used_mb;
    long long available_mb;
    long long swap_total_mb;
    long long swap_used_mb;
    long long swap_available_mb;
};

MemoryInfo get_memory_info();
std::string memory_info_to_json(const MemoryInfo& info);

}