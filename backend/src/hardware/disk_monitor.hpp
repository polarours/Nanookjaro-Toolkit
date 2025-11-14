#pragma once

#include <string>
#include <vector>

namespace nanookjaro::hardware::disk {

    struct DiskInfo {
        std::string device;
        std::string mount_point;
        long long total_gb;
        long long used_gb;
        long long available_gb;
        double read_rate_kbps;
        double write_rate_kbps;
        std::string smart_status;
    };

    std::vector<DiskInfo> get_disk_info();
    std::string disk_info_to_json(const std::vector<DiskInfo>& disks);

}
