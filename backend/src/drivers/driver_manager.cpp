#include "driver_manager.hpp"
#include <string>
#include <array>
#include <memory>
#include <sstream>
#include <vector>
#include <fstream>
#include <algorithm>
#include <filesystem>

namespace nanookjaro::drivers {

namespace {
    
std::string exec_command(const char* cmd) {
    std::array<char, 256> buffer;
    std::string result;
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return "";
    
    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
        result += buffer.data();
    }
    
    pclose(pipe);
    return result;
}

}

std::vector<DriverInfo> list_drivers() {
    std::vector<DriverInfo> drivers;
    
    std::string lsmod_output = exec_command("lsmod 2>/dev/null");
    
    if (!lsmod_output.empty()) {
        std::istringstream iss(lsmod_output);
        std::string line;

        std::getline(iss, line);
        
        while (std::getline(iss, line)) {
            if (line.empty()) continue;
            
            std::istringstream line_stream(line);
            std::string module_name, size, used_by;
            
            line_stream >> module_name >> size >> used_by;
            
            DriverInfo driver;
            driver.name = module_name;
            driver.version = "Unknown";
            driver.description = "Kernel module";
            driver.is_outdated = false;
            driver.update_available = "Unknown";
            
            drivers.push_back(driver);
        }
    }

    if (drivers.empty()) {
        DriverInfo driver;
        driver.name = "No drivers detected";
        driver.version = "Unknown";
        driver.description = "Unable to retrieve driver information";
        driver.is_outdated = false;
        driver.update_available = "Unknown";
        drivers.push_back(driver);
    }
    
    return drivers;
}

std::string drivers_to_json(const std::vector<DriverInfo>& drivers) {
    std::ostringstream json;
    json << "[";
    for (size_t i = 0; i < drivers.size(); ++i) {
        if (i > 0) json << ",";
        const auto& driver = drivers[i];
        json << "{";
        json << "\"name\":\"" << driver.name << "\",";
        json << "\"version\":\"" << driver.version << "\",";
        json << "\"description\":\"" << driver.description << "\",";
        json << "\"is_outdated\":" << (driver.is_outdated ? "true" : "false") << ",";
        json << "\"update_available\":\"" << driver.update_available << "\"";
        json << "}";
    }
    json << "]";
    return json.str();
}

bool backup_drivers(const std::string& output_file) {
    std::string command = "lsmod > " + output_file + " 2>/dev/null";
    int result = system(command.c_str());
    return result == 0;
}

bool update_driver(const std::string& driver_name) {
    return false;
}

}
