#pragma once

#include <string>
#include <vector>

namespace nanookjaro::performance {

struct PerformanceSample {
    double timestamp;
    double cpu_usage_percent;
    double memory_usage_percent;
    double disk_read_kbps;
    double disk_write_kbps;
    double network_rx_kbps;
    double network_tx_kbps;
};

class PerformanceMonitor {
public:
    PerformanceMonitor();
    ~PerformanceMonitor();
    
    void start_monitoring();
    void stop_monitoring();
    std::vector<PerformanceSample> get_history() const;
    void set_sampling_interval(int seconds);
    
private:
    bool monitoring_;
    int sampling_interval_;
    std::vector<PerformanceSample> history_;
};

std::string performance_history_to_json(const std::vector<PerformanceSample>& samples);

}
