#include "../backend/src/system/system_summary.hpp"
#include "../backend/src/maintenance/package_manager.hpp"
#include <iostream>
#include <string>

namespace {

void print_usage() {
    std::cout << "Usage:\n"
              << "  nanookjaro-cli                  # system summary JSON\n"
              << "  nanookjaro-cli pacman list-updates\n"
              << "  nanookjaro-cli pacman upgrade [--assume-yes]\n"
              << "  nanookjaro-cli pacman install <pkg>... [--assume-yes]\n";
}

bool parse_assume_yes(int argc, char** argv, int start_index) {
    for (int i = start_index; i < argc; ++i) {
        const std::string_view arg{argv[i]};
        if (arg == "--assume-yes" || arg == "--yes" || arg == "-y") {
            return true;
        }
    }
    return false;
}

}

int main(int argc, char** argv) {
    try {
        if (argc <= 1) {
            const auto summary = nanookjaro::system_summary_json();
            std::cout << summary << std::endl;
            return 0;
        }

        const std::string_view command{argv[1]};
        if (command == "pacman") {
            if (argc >= 3) {
                const std::string_view subcommand{argv[2]};
                if (subcommand == "upgrade") {
                    const bool assume_yes = parse_assume_yes(argc, argv, 3);
                    const auto result_json =
                        nanookjaro::package_manager::pacman_sync_upgrade_json(assume_yes);
                    std::cout << result_json << std::endl;
                    return 0;
                }
                if (subcommand == "list-updates") {
                    const auto result_json =
                        nanookjaro::package_manager::pacman_list_updates_json();
                    std::cout << result_json << std::endl;
                    return 0;
                }
                if (subcommand == "install" && argc >= 4) {
                    std::vector<std::string> packages;
                    bool assume_yes = false;
                    for (int i = 3; i < argc; ++i) {
                        const std::string_view arg{argv[i]};
                        if (arg == "--assume-yes" || arg == "--yes" || arg == "-y") {
                            assume_yes = true;
                            continue;
                        }
                        packages.emplace_back(argv[i]);
                    }
                    const auto result_json = nanookjaro::package_manager::pacman_install_packages_json(
                        packages, assume_yes);
                    std::cout << result_json << std::endl;
                    return 0;
                }
            }
            print_usage();
            return 1;
        }

        print_usage();
        return 1;
    } catch (const std::exception& ex) {
        std::cerr << "Command failed: " << ex.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "Command failed: unknown error" << std::endl;
        return 1;
    }
}
