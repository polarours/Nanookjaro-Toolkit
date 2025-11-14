#include "disk_monitor.hpp"
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <sys/statvfs.h>
#include <sys/stat.h>
#include <dirent.h>
#include <algorithm>
#include <map>
#include <queue>
#include <cstring>

namespace nanookjaro::hardware::disk {

namespace {
    
std::vector<std::string> get_mounted_filesystems() {
    std::vector<std::string> mounts;
    std::ifstream file("/proc/mounts");
    std::string line;
    
    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::string device, mount_point, fstype;
        
        if (iss >> device >> mount_point >> fstype) {
            if (device.substr(0, 5) == "/dev/" && 
                fstype != "tmpfs" && 
                fstype != "devtmpfs" && 
                fstype != "sysfs" && 
                fstype != "proc" && 
                fstype != "devpts") {
                mounts.push_back(mount_point);
            }
        }
    }
    
    return mounts;
}

}

std::vector<DiskInfo> get_disk_info() {
    std::vector<DiskInfo> disks;
    auto mount_points = get_mounted_filesystems();
    
    for (const auto& mount_point : mount_points) {
        struct statvfs buf;
        if (statvfs(mount_point.c_str(), &buf) == 0) {
            DiskInfo disk;
            disk.device = "Unknown";
            disk.mount_point = mount_point;
            const unsigned long long block_size = buf.f_frsize;
            const unsigned long long total_bytes = static_cast<unsigned long long>(buf.f_blocks) * block_size;
            const unsigned long long free_bytes = static_cast<unsigned long long>(buf.f_bfree) * block_size;
            const unsigned long long available_bytes = static_cast<unsigned long long>(buf.f_bavail) * block_size;
            
            disk.total_gb = total_bytes / (1024 * 1024 * 1024);
            disk.used_gb = (total_bytes - free_bytes) / (1024 * 1024 * 1024);
            disk.available_gb = available_bytes / (1024 * 1024 * 1024);
            disk.read_rate_kbps = 0.0; // wait to implement rate calculation if needed
            disk.write_rate_kbps = 0.0; // wait to implement rate calculation if needed
            disk.smart_status = "Unknown"; // wait to implement SMART status reading if needed
            
            disks.push_back(disk);
        }
    }
    
    return disks;
}

std::string disk_info_to_json(const std::vector<DiskInfo>& disks) {
    std::ostringstream json;
    json << "[";
    for (size_t i = 0; i < disks.size(); ++i) {
        if (i > 0) json << ",";
        const auto& disk = disks[i];
        json << "{";
        json << "\"device\":\"" << disk.device << "\",";
        json << "\"mount_point\":\"" << disk.mount_point << "\",";
        json << "\"total_gb\":" << disk.total_gb << ",";
        json << "\"used_gb\":" << disk.used_gb << ",";
        json << "\"available_gb\":" << disk.available_gb << ",";
        json << "\"read_rate_kbps\":" << std::fixed << std::setprecision(2) << disk.read_rate_kbps << ",";
        json << "\"write_rate_kbps\":" << std::fixed << std::setprecision(2) << disk.write_rate_kbps << ",";
        json << "\"smart_status\":\"" << disk.smart_status << "\"";
        json << "}";
    }
    json << "]";
    return json.str();
}

}
