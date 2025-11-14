#include "system_summary.hpp"
#include "../hardware/cpu_monitor.hpp"
#include "../hardware/gpu_monitor.hpp"
#include "../hardware/memory_monitor.hpp"
#include "../hardware/disk_monitor.hpp"
#include "../network/network_monitor.hpp"
#include "../drivers/driver_manager.hpp"

#include <array>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iomanip>
#include <optional>
#include <sstream>
#include <string>
#include <tuple>
#include <unordered_set>
#include <vector>
#include <unistd.h>

#include <sys/statvfs.h>

namespace nanookjaro {
namespace {

std::string escape_json(const std::string& input) {
    std::string output;
    output.reserve(input.size());
    for (char c : input) {
        switch (c) {
            case '"':
                output += "\\\"";
                break;
            case '\\':
                output += "\\\\";
                break;
            case '\n':
                output += "\\n";
                break;
            case '\r':
                output += "\\r";
                break;
            case '\t':
                output += "\\t";
                break;
            default:
                output += c;
                break;
        }
    }
    return output;
}

std::string trim(const std::string& value) {
    const auto first = value.find_first_not_of(" \t\n\r");
    if (first == std::string::npos) {
        return {};
    }
    const auto last = value.find_last_not_of(" \t\n\r");
    return value.substr(first, last - first + 1);
}

std::string read_cpu_model() {
    std::ifstream file("/proc/cpuinfo");
    std::string line;
    while (std::getline(file, line)) {
        static constexpr const char* kKey = "model name";
        if (line.rfind(kKey, 0) == 0) {
            auto colon_pos = line.find(':');
            if (colon_pos != std::string::npos) {
                return line.substr(colon_pos + 1);
            }
        }
    }
    return {};
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

struct MemoryInfo {
    long total_kb = 0;
    long available_kb = 0;
    long free_kb = 0;
    long buffers_kb = 0;
    long cached_kb = 0;
    long swap_total_kb = 0;
    long swap_free_kb = 0;
};

MemoryInfo read_memory_info() {
    std::ifstream file("/proc/meminfo");
    std::string line;
    MemoryInfo info;

    auto parse_value = [](const std::string& raw_line) -> long {
        std::istringstream iss(raw_line);
        std::string label;
        long value = 0;
        std::string unit;
        if (iss >> label >> value >> unit) {
            return value;
        }
        return 0;
    };

    while (std::getline(file, line)) {
        if (line.rfind("MemTotal", 0) == 0) {
            info.total_kb = parse_value(line);
        } else if (line.rfind("MemAvailable", 0) == 0) {
            info.available_kb = parse_value(line);
        } else if (line.rfind("MemFree", 0) == 0) {
            info.free_kb = parse_value(line);
        } else if (line.rfind("Buffers", 0) == 0) {
            info.buffers_kb = parse_value(line);
        } else if (line.rfind("Cached", 0) == 0) {
            info.cached_kb = parse_value(line);
        } else if (line.rfind("SwapTotal", 0) == 0) {
            info.swap_total_kb = parse_value(line);
        } else if (line.rfind("SwapFree", 0) == 0) {
            info.swap_free_kb = parse_value(line);
        }

        if (info.total_kb > 0 && info.available_kb > 0 && info.swap_total_kb > 0 && info.swap_free_kb > 0) {
            if (info.buffers_kb > 0 && info.cached_kb > 0 && info.free_kb > 0) {
                break;
            }
        }
    }

    return info;
}

std::tuple<double, double, double> read_load_average() {
    std::ifstream file("/proc/loadavg");
    double one = 0.0;
    double five = 0.0;
    double fifteen = 0.0;
    if (file) {
        file >> one >> five >> fifteen;
    }
    return {one, five, fifteen};
}

std::string current_timestamp_iso8601() {
    const auto now = std::chrono::system_clock::now();
    const auto time = std::chrono::system_clock::to_time_t(now);
    std::tm utc{};
#if defined(_WIN32)
    gmtime_s(&utc, &time);
#else
    gmtime_r(&time, &utc);
#endif
    std::ostringstream oss;
    oss << std::put_time(&utc, "%FT%TZ");
    return oss.str();
}

struct FilesystemUsage {
    std::string mount_point;
    unsigned long long total_bytes;
    unsigned long long available_bytes;
};

struct CpuTimes {
    unsigned long long idle = 0;
    unsigned long long total = 0;
    bool valid = false;
};

CpuTimes read_cpu_times() {
    std::ifstream file("/proc/stat");
    if (!file) {
        return {};
    }

    std::string cpu_label;
    unsigned long long user = 0;
    unsigned long long nice = 0;
    unsigned long long system = 0;
    unsigned long long idle = 0;
    unsigned long long iowait = 0;
    unsigned long long irq = 0;
    unsigned long long softirq = 0;
    unsigned long long steal = 0;

    file >> cpu_label >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal;
    if (!file || cpu_label.rfind("cpu", 0) != 0) {
        return {};
    }

    const unsigned long long idle_all = idle + iowait;
    const unsigned long long non_idle = user + nice + system + irq + softirq + steal;
    const unsigned long long total = idle_all + non_idle;
    CpuTimes result;
    result.idle = idle_all;
    result.total = total;
    result.valid = true;
    return result;
}

std::vector<FilesystemUsage> read_filesystems() {
    std::ifstream file("/proc/mounts");
    std::string line;
    std::vector<FilesystemUsage> entries;
    std::unordered_set<std::string> seen;

    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string device;
        std::string mount;
        std::string type;
        if (!(iss >> device >> mount >> type)) {
            continue;
        }

        if (device.rfind("/dev/", 0) != 0) {
            continue;
        }

        if (!seen.insert(mount).second) {
            continue;
        }

        struct statvfs stats {
        };
        if (statvfs(mount.c_str(), &stats) != 0) {
            continue;
        }

        // Using 1024-based calculation for consistency
        const unsigned long long block_size = stats.f_frsize;
        const unsigned long long total = static_cast<unsigned long long>(stats.f_blocks) * block_size;
        const unsigned long long available = static_cast<unsigned long long>(stats.f_bavail) * block_size;
        entries.push_back(FilesystemUsage{mount, total, available});
    }

    return entries;
}

std::vector<std::string> read_gpu_controllers() {
    std::vector<std::string> controllers;
    static constexpr const char* kCommand =
        "lspci -d '*:*' | grep -E '(VGA|3D|Display)' | sed 's/.*: //g'";

    FILE* pipe = popen(kCommand, "r");
    if (!pipe) {
        return controllers;
    }

    std::array<char, 512> buffer{};
    while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe) != nullptr) {
        std::string line(buffer.data());
        line = trim(line);
        if (!line.empty()) {
            controllers.push_back(line);
        }
    }
    pclose(pipe);

    return controllers;
}

std::optional<std::string> read_proxy_setting(const char* env_name) {
    const char* value = std::getenv(env_name);
    if (value == nullptr) {
        return std::nullopt;
    }
    return std::string(value);
}

}

std::string set_proxy_config_json(const std::string& http_proxy, const std::string& https_proxy) {
    auto set_env = [](const char* name, const std::string& value) -> bool {
#if defined(_WIN32)
        if (value.empty()) {
            return _putenv_s(name, "") == 0;
        }
        return _putenv_s(name, value.c_str()) == 0;
#else
        if (value.empty()) {
            return unsetenv(name) == 0;
        }
        return setenv(name, value.c_str(), 1) == 0;
#endif
    };

    const bool http_ok = set_env("http_proxy", http_proxy);
    const bool https_ok = set_env("https_proxy", https_proxy);

    std::ostringstream json;
    json << '{'
         << "\"ok\":" << (http_ok && https_ok ? "true" : "false") << ','
         << "\"http_proxy\":\"" << escape_json(http_proxy) << "\",";
    json << "\"https_proxy\":\"" << escape_json(https_proxy) << "\"";
    if (!http_ok || !https_ok) {
        json << ",\"error\":\"failed_to_set_proxy\"";
    }
    json << '}';
    return json.str();
}

std::string system_summary_json() {
    const bool is_arch_system = access("/etc/arch-release", F_OK) != -1;
    
    // Get component information
    auto cpu_info = nanookjaro::hardware::cpu::get_cpu_info();
    auto gpu_info = nanookjaro::hardware::gpu::get_gpu_info();
    auto disk_info = nanookjaro::hardware::disk::get_disk_info();
    auto network_info = nanookjaro::network::get_network_interfaces();
    auto driver_info = nanookjaro::drivers::list_drivers();
    
    std::string cpu_model = trim(read_cpu_model());
    if (cpu_model.empty()) {
        cpu_model = "unknown";
    }

    const int cpu_cores = count_cpu_cores();
    const MemoryInfo memory = read_memory_info();
    const CpuTimes cpu_times = read_cpu_times();
    const auto [load_one, load_five, load_fifteen] = read_load_average();
    const std::string timestamp = current_timestamp_iso8601();
    const auto http_proxy = read_proxy_setting("http_proxy");
    const auto https_proxy = read_proxy_setting("https_proxy");
    
    int package_count = -1;
    if (is_arch_system) {
        FILE* pipe = popen("pacman -Qq | wc -l", "r");
        if (pipe) {
            char buffer[32];
            if (fgets(buffer, sizeof(buffer), pipe)) {
                package_count = std::stoi(std::string(buffer));
            }
            pclose(pipe);
        }
    }

    static unsigned long long previous_cpu_total = 0;
    static unsigned long long previous_cpu_idle = 0;
    static bool have_cpu_baseline = false;
    double cpu_usage_percent = 0.0;
    if (cpu_times.valid) {
        if (have_cpu_baseline) {
            const unsigned long long total_delta = cpu_times.total - previous_cpu_total;
            const unsigned long long idle_delta = cpu_times.idle - previous_cpu_idle;
            if (total_delta > 0 && idle_delta <= total_delta) {
                const unsigned long long active_delta = total_delta - idle_delta;
                cpu_usage_percent = static_cast<double>(active_delta) * 100.0 / static_cast<double>(total_delta);
            }
        }
        previous_cpu_total = cpu_times.total;
        previous_cpu_idle = cpu_times.idle;
        have_cpu_baseline = true;
    }

    const long used_kb = memory.total_kb > memory.available_kb ? (memory.total_kb - memory.available_kb) : 0;
    const long swap_used_kb =
        memory.swap_total_kb > memory.swap_free_kb ? (memory.swap_total_kb - memory.swap_free_kb) : 0;
    double memory_usage_percent = 0.0;
    if (memory.total_kb > 0) {
        memory_usage_percent = static_cast<double>(used_kb) * 100.0 / static_cast<double>(memory.total_kb);
    }
    double swap_usage_percent = 0.0;
    if (memory.swap_total_kb > 0) {
        swap_usage_percent = static_cast<double>(swap_used_kb) * 100.0 / static_cast<double>(memory.swap_total_kb);
    }

    std::ostringstream json;
    json << '{'
         << "\"timestamp\":\"" << escape_json(timestamp) << "\",";
    json << "\"cpu\":{"
        << "\"model\":\"" << escape_json(cpu_model) << "\",";
    json << "\"cores\":" << cpu_cores << ',';
    json << "\"usage_percent\":" << std::fixed << std::setprecision(2) << cpu_usage_percent << "},";
    json << "\"memory\":{"
         << "\"total_kb\":" << memory.total_kb << ','
         << "\"available_kb\":" << memory.available_kb << ','
         << "\"used_kb\":" << used_kb << ','
         << "\"usage_percent\":" << std::fixed << std::setprecision(2) << memory_usage_percent << ','
         << "\"free_kb\":" << memory.free_kb << ','
         << "\"buffers_kb\":" << memory.buffers_kb << ','
         << "\"cached_kb\":" << memory.cached_kb << ','
         << "\"swap_total_kb\":" << memory.swap_total_kb << ','
         << "\"swap_free_kb\":" << memory.swap_free_kb << ','
         << "\"swap_used_kb\":" << swap_used_kb << ','
         << "\"swap_usage_percent\":" << std::fixed << std::setprecision(2) << swap_usage_percent << "},";
    json << "\"load_average\":[" << load_one << ',' << load_five << ',' << load_fifteen << "],";
    json << "\"filesystems\":[";
    for (std::size_t i = 0; i < disk_info.size(); ++i) {
        if (i > 0) json << ',';
        const auto& disk = disk_info[i];
        json << '{'
             << "\"mount\":\"" << escape_json(disk.mount_point) << "\",";
        json << "\"total_bytes\":" << (disk.total_gb * 1024 * 1024 * 1024) << ',';
        json << "\"available_bytes\":" << (disk.available_gb * 1024 * 1024 * 1024) << '}';
    }
    json << "],";
    json << "\"gpu\":" << nanookjaro::hardware::gpu::gpu_info_to_json(gpu_info) << ",";
    
    if (is_arch_system && package_count >= 0) {
        json << "\"packages\":" << package_count << ",";
    }
    
    json << "\"network\":" << nanookjaro::network::network_interfaces_to_json(network_info) << ",";
    
    json << "\"proxy\":{";
    json << "\"http\":";
    if (http_proxy) {
        json << "\"" << escape_json(*http_proxy) << "\"";
    } else {
        json << "null";
    }
    json << ",\"https\":";
    if (https_proxy) {
        json << "\"" << escape_json(*https_proxy) << "\"";
    } else {
        json << "null";
    }
    json << "}";
    json << '}';

    return json.str();
}

std::string cpu_info_json() {
    auto cpu_info = nanookjaro::hardware::cpu::get_cpu_info();
    return nanookjaro::hardware::cpu::cpu_info_to_json(cpu_info);
}

std::string gpu_info_json() {
    auto gpu_info = nanookjaro::hardware::gpu::get_gpu_info();
    return nanookjaro::hardware::gpu::gpu_info_to_json(gpu_info);
}

std::string memory_info_json() {
    auto memory_info = nanookjaro::hardware::memory::get_memory_info();
    return nanookjaro::hardware::memory::memory_info_to_json(memory_info);
}

std::string disk_info_json() {
    auto disk_info = nanookjaro::hardware::disk::get_disk_info();
    return nanookjaro::hardware::disk::disk_info_to_json(disk_info);
}

std::string network_info_json() {
    auto network_info = nanookjaro::network::get_network_interfaces();
    return nanookjaro::network::network_interfaces_to_json(network_info);
}

std::string drivers_info_json() {
    auto driver_info = nanookjaro::drivers::list_drivers();
    return nanookjaro::drivers::drivers_to_json(driver_info);
}

} // namespace nanookjaro
