#pragma once

#include <string>
#include <vector>

namespace nanookjaro::network {

struct NetworkInterface {
    std::string name;
    std::string mac_address;
    std::string ipv4_address;
    std::string ipv6_address;
    double rx_rate_kbps;
    double tx_rate_kbps;
    bool is_up;
};

std::vector<NetworkInterface> get_network_interfaces();
std::string network_interfaces_to_json(const std::vector<NetworkInterface>& interfaces);

}