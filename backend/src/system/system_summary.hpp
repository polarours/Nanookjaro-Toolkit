#pragma once

#include <string>

namespace nanookjaro {

std::string system_summary_json();
std::string set_proxy_config_json(const std::string& http_proxy, const std::string& https_proxy);

// Individual component functions
std::string cpu_info_json();
std::string gpu_info_json();
std::string memory_info_json();
std::string disk_info_json();
std::string network_info_json();
std::string drivers_info_json();

}
