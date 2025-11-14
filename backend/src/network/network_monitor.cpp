#include <array>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <chrono>
#include <thread>
#include <algorithm>
#include <iostream>

#include "network_monitor.hpp"

namespace nanookjaro::network {

namespace {

std::map<std::string, std::pair<unsigned long long, unsigned long long>> previous_stats;
std::map<std::string, std::chrono::steady_clock::time_point> previous_times;

std::string exec_command(const char* cmd) {
    std::array<char, 128> buffer;
    std::string result;
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return "";
    
    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
        result += buffer.data();
    }
    
    pclose(pipe);
    return result;
}

std::pair<unsigned long long, unsigned long long> read_network_stats(const std::string& interface_name) {
    std::ifstream file("/proc/net/dev");
    std::string line;
    
    std::getline(file, line);
    std::getline(file, line);
    
    while (std::getline(file, line)) {
        size_t colon_pos = line.find(':');
        if (colon_pos != std::string::npos) {
            std::string name = line.substr(0, colon_pos);
            name.erase(0, name.find_first_not_of(" \t"));
            name.erase(name.find_last_not_of(" \t") + 1);
            
            if (name == interface_name) {
                std::istringstream iss(line.substr(colon_pos + 1));
                std::vector<std::string> stats;
                std::string stat;
                
                while (iss >> stat) {
                    stats.push_back(stat);
                }
                
                if (stats.size() >= 9) {
                    unsigned long long rx_bytes = std::stoull(stats[0]);
                    unsigned long long tx_bytes = std::stoull(stats[8]);
                    return std::make_pair(rx_bytes, tx_bytes);
                }
            }
        }
    }
    
    return std::make_pair(0, 0);
}

}

std::vector<NetworkInterface> get_network_interfaces() {
    std::vector<NetworkInterface> interfaces;
    
    std::ifstream file("/proc/net/dev");
    std::string line;
    
    std::getline(file, line);
    std::getline(file, line);
    
    while (std::getline(file, line)) {
        size_t colon_pos = line.find(':');
        if (colon_pos != std::string::npos) {
            std::string interface_name = line.substr(0, colon_pos);
            interface_name.erase(0, interface_name.find_first_not_of(" \t"));
            interface_name.erase(interface_name.find_last_not_of(" \t") + 1);
            
            if (interface_name == "lo") {
                continue;
            }
            
            NetworkInterface netif;
            netif.name = interface_name;
            netif.mac_address = "N/A";
            netif.ipv4_address = "N/A";
            netif.ipv6_address = "N/A";
            netif.rx_rate_kbps = 0.0;
            netif.tx_rate_kbps = 0.0;
            netif.is_up = true;
            
            std::string mac_cmd = "cat /sys/class/net/" + interface_name + "/address 2>/dev/null";
            std::string mac_result = exec_command(mac_cmd.c_str());
            if (!mac_result.empty()) {
                if (!mac_result.empty() && mac_result.back() == '\n') {
                    mac_result.pop_back();
                }
                if (!mac_result.empty()) {
                    netif.mac_address = mac_result;
                }
            }
            
            std::string ip_cmd = "ip -4 addr show " + interface_name + " 2>/dev/null | grep inet | head -1 | awk '{print $2}' | cut -d'/' -f1";
            std::string ipv4_result = exec_command(ip_cmd.c_str());
            if (!ipv4_result.empty()) {
                if (!ipv4_result.empty() && ipv4_result.back() == '\n') {
                    ipv4_result.pop_back();
                }
                if (!ipv4_result.empty()) {
                    netif.ipv4_address = ipv4_result;
                }
            }
            
            std::string ipv6_cmd = "ip -6 addr show " + interface_name + " 2>/dev/null | grep inet6 | head -1 | awk '{print $2}' | cut -d'/' -f1";
            std::string ipv6_result = exec_command(ipv6_cmd.c_str());
            if (!ipv6_result.empty()) {
                if (!ipv6_result.empty() && ipv6_result.back() == '\n') {
                    ipv6_result.pop_back();
                }
                if (!ipv6_result.empty()) {
                    netif.ipv6_address = ipv6_result;
                }
            }

            std::string operstate_cmd = "cat /sys/class/net/" + interface_name + "/operstate 2>/dev/null";
            std::string operstate_result = exec_command(operstate_cmd.c_str());
            if (!operstate_result.empty()) {
                if (!operstate_result.empty() && operstate_result.back() == '\n') {
                    operstate_result.pop_back();
                }
                netif.is_up = (operstate_result == "up");
            }
            
            auto current_stats = read_network_stats(interface_name);
            auto current_time = std::chrono::steady_clock::now();
            
            if (previous_stats.find(interface_name) != previous_stats.end()) {
                auto previous_stat = previous_stats[interface_name];
                auto previous_time = previous_times[interface_name];
                
                auto time_diff = std::chrono::duration_cast<std::chrono::milliseconds>(
                    current_time - previous_time).count();
                
                if (time_diff > 0) {
                    unsigned long long rx_diff = current_stats.first - previous_stat.first;
                    unsigned long long tx_diff = current_stats.second - previous_stat.second;

                    netif.rx_rate_kbps = (rx_diff * 1.0) / time_diff;  
                    netif.tx_rate_kbps = (tx_diff * 1.0) / time_diff;  
                }
            }

            previous_stats[interface_name] = current_stats;
            previous_times[interface_name] = current_time;
            
            interfaces.push_back(netif);
        }
    }
    
    return interfaces;
}

std::string network_interfaces_to_json(const std::vector<NetworkInterface>& interfaces) {
    std::ostringstream json;
    json << "[";
    for (size_t i = 0; i < interfaces.size(); ++i) {
        if (i > 0) json << ",";
        const auto& interface = interfaces[i];
        json << "{";
        json << "\"name\":\"" << interface.name << "\",";
        json << "\"mac_address\":\"" << interface.mac_address << "\",";
        json << "\"ipv4_address\":\"" << interface.ipv4_address << "\",";
        json << "\"ipv6_address\":\"" << interface.ipv6_address << "\",";
        json << "\"rx_rate_kbps\":" << std::fixed << std::setprecision(2) << interface.rx_rate_kbps << ",";
        json << "\"tx_rate_kbps\":" << std::fixed << std::setprecision(2) << interface.tx_rate_kbps << ",";
        json << "\"is_up\":" << (interface.is_up ? "true" : "false");
        json << "}";
    }
    json << "]";
    return json.str();
}

}
