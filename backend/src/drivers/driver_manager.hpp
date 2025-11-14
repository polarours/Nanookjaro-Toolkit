#pragma once

#include <string>
#include <vector>

namespace nanookjaro::drivers {

struct DriverInfo {
    std::string name;
    std::string version;
    std::string description;
    bool is_outdated;
    std::string update_available;
};

std::vector<DriverInfo> list_drivers();
std::string drivers_to_json(const std::vector<DriverInfo>& drivers);
bool backup_drivers(const std::string& output_file);
bool update_driver(const std::string& driver_name);

}
