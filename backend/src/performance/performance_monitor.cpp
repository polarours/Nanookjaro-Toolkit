#include <string>
#include <chrono>
#include <thread>

#include "performance_monitor.hpp"

namespace nanookjaro::performance {

PerformanceMonitor::PerformanceMonitor() 
    : monitoring_(false), sampling_interval_(1) {
}

PerformanceMonitor::~PerformanceMonitor() {
    stop_monitoring();
}

void PerformanceMonitor::start_monitoring() {
    if (monitoring_) return;
    
    monitoring_ = true;
}

void PerformanceMonitor::stop_monitoring() {
    monitoring_ = false;
    // In a real implementation, join the background thread here
}

std::vector<PerformanceSample> PerformanceMonitor::get_history() const {
    return history_;
}

void PerformanceMonitor::set_sampling_interval(int seconds) {
    sampling_interval_ = seconds;
    // In a real implementation, adjust the sampling thread's sleep duration here
}

std::string performance_history_to_json(const std::vector<PerformanceSample>& samples) {
    std::ostringstream json;
    json << "[";
    for (size_t i = 0; i < samples.size(); ++i) {
        if (i > 0) json << ",";
        const auto& sample = samples[i];
        json << "{";
        json << "\"timestamp\":" << sample.timestamp << ",";
        json << "\"cpu_usage_percent\":" << sample.cpu_usage_percent << ",";
        json << "\"memory_usage_percent\":" << sample.memory_usage_percent << ",";
        json << "\"disk_read_kbps\":" << sample.disk_read_kbps << ",";
        json << "\"disk_write_kbps\":" << sample.disk_write_kbps << ",";
        json << "\"network_rx_kbps\":" << sample.network_rx_kbps << ",";
        json << "\"network_tx_kbps\":" << sample.network_tx_kbps;
        json << "}";
    }
    json << "]";
    return json.str();
}

}
