#include "cpu_monitor.hpp"
#include <fstream>
#include <sstream>
#include <string>
#include <iomanip>
#include <algorithm>
#include <unistd.h>

namespace nanookjaro::hardware::cpu {

namespace {
    
std::string trim(const std::string& str) {
    const auto strBegin = str.find_first_not_of(" \t");
    if (strBegin == std::string::npos)
        return "";

    const auto strEnd = str.find_last_not_of(" \t");
    const auto strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
}

std::string read_cpu_model() {
    std::ifstream file("/proc/cpuinfo");
    std::string line;
    while (std::getline(file, line)) {
        if (line.rfind("model name", 0) == 0) {
            auto colonPos = line.find(':');
            if (colonPos != std::string::npos) {
                return trim(line.substr(colonPos + 1));
            }
        }
    }
    return "Unknown CPU";
}

int count_cpu_cores() {
    std::ifstream file("/proc/cpuinfo");
    std::string line;
    int count = 0;
    while (std::getline(file, line)) {
        if (line.rfind("processor", 0) == 0) {
            ++count;
        }
    }
    return count;
}

double read_cpu_temperature() {
    for (int i = 0; i < 10; ++i) {
        std::string path = "/sys/class/hwmon/hwmon" + std::to_string(i) + "/temp1_input";
        std::ifstream file(path);
        if (file.is_open()) {
            int temp;
            if (file >> temp) {
                return temp / 1000.0;
            }
        }
    }
    return -1.0;
}

struct CpuTimes {
    unsigned long long user = 0;
    unsigned long long nice = 0;
    unsigned long long system = 0;
    unsigned long long idle = 0;
    unsigned long long iowait = 0;
    unsigned long long irq = 0;
    unsigned long long softirq = 0;
    unsigned long long steal = 0;
};

CpuTimes read_cpu_times() {
    std::ifstream file("/proc/stat");
    CpuTimes times;
    std::string line;
    
    if (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string cpu_label;
        iss >> cpu_label 
            >> times.user >> times.nice >> times.system 
            >> times.idle >> times.iowait >> times.irq 
            >> times.softirq >> times.steal;
    }
    
    return times;
}

}

CpuInfo get_cpu_info() {
    CpuInfo info;
    info.model = read_cpu_model();
    info.cores = count_cpu_cores();
    info.threads = info.cores;
    info.base_frequency_ghz = 0.0;
    info.current_frequency_ghz = 0.0;
    info.temperature_celsius = read_cpu_temperature();
    info.cache_l1_kb = 0;// wait to implement cache reading if needed
    info.cache_l2_kb = 0;// wait to implement cache reading if needed
    info.cache_l3_kb = 0;// wait to implement cache reading if needed
    return info;
}

CpuUsage get_cpu_usage() {
    static CpuTimes previous_times;
    CpuTimes current_times = read_cpu_times();
    
    unsigned long long prev_idle = previous_times.idle + previous_times.iowait;
    unsigned long long curr_idle = current_times.idle + current_times.iowait;
    
    unsigned long long prev_total = previous_times.user + previous_times.nice + 
                                   previous_times.system + previous_times.idle + 
                                   previous_times.iowait + previous_times.irq + 
                                   previous_times.softirq + previous_times.steal;
    unsigned long long curr_total = current_times.user + current_times.nice + 
                                   current_times.system + current_times.idle + 
                                   current_times.iowait + current_times.irq + 
                                   current_times.softirq + current_times.steal;
    
    unsigned long long total_diff = curr_total - prev_total;
    unsigned long long idle_diff = curr_idle - prev_idle;
    
    CpuUsage usage;
    if (total_diff > 0) {
        usage.idle_percent = (100.0 * idle_diff) / total_diff;
        usage.user_percent = (100.0 * (current_times.user - previous_times.user)) / total_diff;
        usage.system_percent = (100.0 * (current_times.system - previous_times.system)) / total_diff;
        usage.iowait_percent = (100.0 * (current_times.iowait - previous_times.iowait)) / total_diff;
    } else {
        usage.idle_percent = 100.0;
        usage.user_percent = 0.0;
        usage.system_percent = 0.0;
        usage.iowait_percent = 0.0;
    }
    
    previous_times = current_times;
    return usage;
}

std::string cpu_info_to_json(const CpuInfo& info) {
    std::ostringstream json;
    json << "{";
    json << "\"model\":\"" << info.model << "\",";
    json << "\"cores\":" << info.cores << ",";
    json << "\"threads\":" << info.threads << ",";
    json << "\"base_frequency_ghz\":" << std::fixed << std::setprecision(2) << info.base_frequency_ghz << ",";
    json << "\"current_frequency_ghz\":" << std::fixed << std::setprecision(2) << info.current_frequency_ghz << ",";
    json << "\"temperature_celsius\":" << std::fixed << std::setprecision(2) << info.temperature_celsius << ",";
    json << "\"cache_l1_kb\":" << info.cache_l1_kb << ",";
    json << "\"cache_l2_kb\":" << info.cache_l2_kb << ",";
    json << "\"cache_l3_kb\":" << info.cache_l3_kb;
    json << "}";
    return json.str();
}

std::string cpu_usage_to_json(const CpuUsage& usage) {
    std::ostringstream json;
    json << "{";
    json << "\"user_percent\":" << std::fixed << std::setprecision(2) << usage.user_percent << ",";
    json << "\"system_percent\":" << std::fixed << std::setprecision(2) << usage.system_percent << ",";
    json << "\"idle_percent\":" << std::fixed << std::setprecision(2) << usage.idle_percent << ",";
    json << "\"iowait_percent\":" << std::fixed << std::setprecision(2) << usage.iowait_percent;
    json << "}";
    return json.str();
}

}
