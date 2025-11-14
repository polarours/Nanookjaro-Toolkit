#pragma once

#include <string>
#include <vector>

namespace nanookjaro::package_manager {

std::string pacman_sync_upgrade_json(bool assume_yes);
std::string pacman_list_updates_json();
std::string pacman_install_packages_json(const std::vector<std::string>& packages,
										 bool assume_yes);
}
