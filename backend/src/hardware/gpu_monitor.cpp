#include "gpu_monitor.hpp"
#include <array>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <memory>
#include <sstream>
#include <string>
#include <algorithm>

namespace nanookjaro::hardware::gpu {

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

std::string exec_command(const char* cmd) {
    std::array<char, 128> buffer{};
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        return "";
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}

}

std::vector<GpuInfo> get_gpu_info() {
    std::vector<GpuInfo> gpus;
    
    std::string lspci_output = exec_command("lspci -mm -d '*:*' | grep -E '\"(VGA|3D|Display).*Controller\"' 2>/dev/null");
    
    if (!lspci_output.empty()) {
        std::istringstream iss(lspci_output);
        std::string line;
        
        while (std::getline(iss, line)) {
            if (line.empty()) continue;
            
            GpuInfo gpu;
            gpu.vendor = "Unknown";
            gpu.driver_version = "Unknown";
            gpu.memory_mb = 0;
            gpu.usage_percent = 0.0;
            gpu.temperature_celsius = -1.0;
            
            std::istringstream line_stream(line);
            std::string token;
            std::vector<std::string> tokens;
            
            while (std::getline(line_stream, token, '"')) {
                if (!token.empty() && token != " ") {
                    tokens.push_back(token);
                }
            }
            
            if (tokens.size() >= 4) {
                std::ostringstream name_builder;
                name_builder << tokens[2] << " " << tokens[3];
                if (tokens.size() >= 7) {
                    name_builder << " (rev " << tokens[6] << ")";
                }
                gpu.name = name_builder.str();
                
                gpu.vendor = tokens[2];
                
                if (tokens.size() >= 8 && !tokens[7].empty()) {
                    gpu.driver_version = tokens[7];
                }
            } else {
                gpu.name = line;
            }
            
            gpus.push_back(gpu);
        }
    }
    
    if (gpus.empty()) {
        std::string lspci_simple = exec_command("lspci | grep -E '(VGA|3D|Display)' 2>/dev/null");
        if (!lspci_simple.empty()) {
            std::istringstream iss(lspci_simple);
            std::string line;
            
            while (std::getline(iss, line)) {
                if (line.empty()) continue;
                
                GpuInfo gpu;
                gpu.name = line;
                gpu.vendor = "Unknown";
                gpu.driver_version = "Unknown";
                gpu.memory_mb = 0;
                gpu.usage_percent = 0.0;
                gpu.temperature_celsius = -1.0;
                gpus.push_back(gpu);
            }
        }
    }
    
    if (gpus.empty()) {
        std::string nvidia_smi = exec_command("nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>/dev/null");
        if (!nvidia_smi.empty()) {
            std::istringstream iss(nvidia_smi);
            std::string line;
            
            while (std::getline(iss, line)) {
                if (line.empty()) continue;
                
                line.erase(std::remove(line.begin(), line.end(), '\n'), line.end());
                line.erase(std::remove(line.begin(), line.end(), '\r'), line.end());
                
                if (!line.empty()) {
                    GpuInfo gpu;
                    gpu.name = "NVIDIA " + line;
                    gpu.vendor = "NVIDIA";
                    gpu.driver_version = "Unknown";
                    gpu.memory_mb = 0;
                    gpu.usage_percent = 0.0;
                    gpu.temperature_celsius = -1.0;
                    gpus.push_back(gpu);
                }
            }
        }
    }
    
    if (gpus.empty()) {
        GpuInfo gpu;
        gpu.name = "No GPU detected";
        gpu.vendor = "Unknown";
        gpu.driver_version = "Unknown";
        gpu.memory_mb = 0;
        gpu.usage_percent = 0.0;
        gpu.temperature_celsius = -1.0;
        gpus.push_back(gpu);
    }
    
    return gpus;
}

std::string gpu_info_to_json(const std::vector<GpuInfo>& gpus) {
    std::ostringstream json;
    json << "[";
    for (size_t i = 0; i < gpus.size(); ++i) {
        if (i > 0) json << ",";
        const auto& gpu = gpus[i];
        json << "{";
        json << "\"name\":\"" << escape_json(gpu.name) << "\",";
        json << "\"vendor\":\"" << escape_json(gpu.vendor) << "\",";
        json << "\"driver_version\":\"" << escape_json(gpu.driver_version) << "\",";
        json << "\"memory_mb\":" << gpu.memory_mb << ",";
        json << "\"usage_percent\":" << std::fixed << std::setprecision(2) << gpu.usage_percent << ",";
        json << "\"temperature_celsius\":" << std::fixed << std::setprecision(2) << gpu.temperature_celsius;
        json << "}";
    }
    json << "]";
    return json.str();
}

}
