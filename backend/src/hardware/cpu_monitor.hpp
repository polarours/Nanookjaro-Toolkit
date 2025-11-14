#pragma once

#include <string>

namespace nanookjaro::hardware::cpu {

struct CpuInfo {
    std::string model;
    int cores;
    int threads;
    double base_frequency_ghz;
    double current_frequency_ghz;
    double temperature_celsius;
    long long cache_l1_kb;
    long long cache_l2_kb;
    long long cache_l3_kb;
};

struct CpuUsage {
    double user_percent;
    double system_percent;
    double idle_percent;
    double iowait_percent;
};

CpuInfo get_cpu_info();
CpuUsage get_cpu_usage();
std::string cpu_info_to_json(const CpuInfo& info);
std::string cpu_usage_to_json(const CpuUsage& usage);

}
