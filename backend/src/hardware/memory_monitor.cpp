#include <string>
#include <fstream>
#include <sstream>
#include <iomanip>

#include "memory_monitor.hpp"

namespace nanookjaro::hardware::memory {

namespace {
    
struct RawMemoryInfo {
    long long mem_total_kb = 0;
    long long mem_free_kb = 0;
    long long mem_available_kb = 0;
    long long buffers_kb = 0;
    long long cached_kb = 0;
    long long swap_total_kb = 0;
    long long swap_free_kb = 0;
};

RawMemoryInfo read_raw_memory_info() {
    std::ifstream file("/proc/meminfo");
    std::string line;
    RawMemoryInfo info;

    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string key;
        long long value;
        std::string unit;
        
        if (iss >> key >> value >> unit) {
            if (key == "MemTotal:") {
                info.mem_total_kb = value;
            } else if (key == "MemFree:") {
                info.mem_free_kb = value;
            } else if (key == "MemAvailable:") {
                info.mem_available_kb = value;
            } else if (key == "Buffers:") {
                info.buffers_kb = value;
            } else if (key == "Cached:") {
                info.cached_kb = value;
            } else if (key == "SwapTotal:") {
                info.swap_total_kb = value;
            } else if (key == "SwapFree:") {
                info.swap_free_kb = value;
            }
        }
    }

    return info;
}

}

MemoryInfo get_memory_info() {
    RawMemoryInfo raw = read_raw_memory_info();
    MemoryInfo info;
    
    info.total_mb = raw.mem_total_kb / 1024;
    info.used_mb = (raw.mem_total_kb - raw.mem_available_kb) / 1024;
    info.available_mb = raw.mem_available_kb / 1024;
    info.swap_total_mb = raw.swap_total_kb / 1024;
    info.swap_used_mb = (raw.swap_total_kb - raw.swap_free_kb) / 1024;
    info.swap_available_mb = raw.swap_free_kb / 1024;
    
    return info;
}

std::string memory_info_to_json(const MemoryInfo& info) {
    std::ostringstream json;
    json << "{";
    json << "\"total_mb\":" << info.total_mb << ",";
    json << "\"used_mb\":" << info.used_mb << ",";
    json << "\"available_mb\":" << info.available_mb << ",";
    json << "\"swap_total_mb\":" << info.swap_total_mb << ",";
    json << "\"swap_used_mb\":" << info.swap_used_mb << ",";
    json << "\"swap_available_mb\":" << info.swap_available_mb;
    json << "}";
    return json.str();
}

}
