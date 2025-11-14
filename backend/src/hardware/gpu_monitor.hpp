#pragma once

#include <string>
#include <vector>

namespace nanookjaro::hardware::gpu {

struct GpuInfo {
    std::string name;
    std::string vendor;
    std::string driver_version;
    long long memory_mb;
    double usage_percent;
    double temperature_celsius;
};

std::vector<GpuInfo> get_gpu_info();
std::string gpu_info_to_json(const std::vector<GpuInfo>& gpus);

}