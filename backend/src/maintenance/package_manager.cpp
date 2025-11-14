#include <array>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <filesystem>
#include <iomanip>
#include <memory>
#include <sstream>
#include <string>
#include <thread>
#include <vector>
#include <chrono>
#include <iostream>

#include "package_manager.hpp"

namespace nanookjaro::package_manager {

namespace {

struct CommandResult {
    int exit_code;
    std::string combined_output;
};

CommandResult run_command_capture(std::string command) {
    command.append(" 2>&1");
    std::array<char, 4096> buffer{};
    std::string output;

    FILE* stream = popen(command.c_str(), "r");
    if (!stream) {
        throw std::runtime_error("Failed to invoke shell command");
    }

    while (std::fgets(buffer.data(), static_cast<int>(buffer.size()), stream)) {
        output.append(buffer.data());
    }

    const int status = pclose(stream);
    int exit_code = -1;
    if (WIFEXITED(status)) {
        exit_code = WEXITSTATUS(status);
    }

    return CommandResult{exit_code, output};
}

bool contains_password_prompt(std::string_view output) {
    return output.find("password is required") != std::string_view::npos ||
           output.find("a password is required") != std::string_view::npos ||
           output.find("password for") != std::string_view::npos;
}

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

}

std::string pacman_sync_upgrade_json(bool assume_yes) {
    const bool is_root = (geteuid() == 0);
    std::ostringstream command_builder;
    if (!is_root) {
        command_builder << "sudo -n ";
    }
    command_builder << "pacman -Syu";
    if (assume_yes) {
        command_builder << " --noconfirm";
    }

    const std::string non_interactive_command = command_builder.str();

    bool requires_password = false;
    CommandResult result{0, {}};

    try {
        result = run_command_capture(non_interactive_command);
        if (result.exit_code != 0 && contains_password_prompt(result.combined_output)) {
            requires_password = true;
        }
    } catch (const std::exception& ex) {
        result.exit_code = -1;
        result.combined_output = ex.what();
    }

    std::ostringstream interactive_command;
    if (is_root) {
        interactive_command << "pacman -Syu";
    } else {
        interactive_command << "sudo pacman -Syu";
    }
    if (assume_yes) {
        interactive_command << " --noconfirm";
    }

    std::ostringstream json;
    json << '{';
    json << "\"command\":\"" << escape_json(non_interactive_command) << "\",";
    json << "\"interactive_command\":\"" << escape_json(interactive_command.str()) << "\",";
    json << "\"exit_code\":" << result.exit_code << ',';
    json << "\"requires_password\":" << (requires_password ? "true" : "false") << ',';
    json << "\"output\":\"" << escape_json(result.combined_output) << "\"";
    json << '}';

    return json.str();
}

std::string pacman_list_updates_json() {
    const bool is_arch_system = access("/etc/arch-release", F_OK) != -1;
    
    if (!is_arch_system) {
        return "{\"command\":\"none\",\"exit_code\":0,\"fallback_used\":false,\"updates\":[],\"output\":\"Not an Arch-based system\"}";
    }
    
    const char* first_command = "checkupdates";
    
    CommandResult result{0, {}};
    bool fallback_used = false;
    
    try {
        result = run_command_capture(first_command);
        if (result.exit_code == 127 || result.exit_code == -1) {
            fallback_used = true;
        }
    } catch (const std::exception& ex) {
        result.exit_code = -1;
        result.combined_output = ex.what();
        fallback_used = true;
    }

    CommandResult fallback_result{0, {}};
    if (fallback_used) {
        try {
            fallback_result = run_command_capture("pacman -Qu");
            result = fallback_result;
        } catch (const std::exception& ex) {
            result.exit_code = -1;
            result.combined_output = ex.what();
        }
    }

    struct UpdateEntry {
        std::string name;
        std::string current_version;
        std::string new_version;
    };

    std::vector<UpdateEntry> updates;

    if (result.exit_code == 0 || result.exit_code == 1 || result.exit_code == 2) {
        std::istringstream stream(result.combined_output);
        std::string line;
        while (std::getline(stream, line)) {
            if (line.empty()) {
                continue;
            }
            std::istringstream line_stream(line);
            UpdateEntry entry;
            std::string arrow;
            if (!(line_stream >> entry.name >> entry.current_version >> arrow >> entry.new_version)) {
                continue;
            }
            updates.push_back(entry);
        }
    }

    std::ostringstream json;
    json << '{';
    json << "\"command\":\"" << escape_json(fallback_used ? "pacman -Qu" : first_command)
         << "\",";
    json << "\"exit_code\":" << result.exit_code << ',';
    json << "\"fallback_used\":" << (fallback_used ? "true" : "false") << ',';
    json << "\"updates\":[";
    for (std::size_t i = 0; i < updates.size(); ++i) {
        const auto& entry = updates[i];
        if (i > 0) {
            json << ',';
        }
        json << '{';
        json << "\"name\":\"" << escape_json(entry.name) << "\",";
        json << "\"current\":\"" << escape_json(entry.current_version) << "\",";
        json << "\"available\":\"" << escape_json(entry.new_version) << "\"";
        json << '}';
    }
    json << "],";
    json << "\"output\":\"" << escape_json(result.combined_output) << "\"";
    json << '}';

    return json.str();
}

std::string pacman_install_packages_json(const std::vector<std::string>& packages,
                                         bool assume_yes) {
    if (packages.empty()) {
        return "{\"error\":\"no_packages\"}";
    }

    const bool is_root = (geteuid() == 0);

    auto build_command = [&](bool non_interactive) {
        std::ostringstream builder;
        if (!is_root) {
            builder << (non_interactive ? "sudo -n " : "sudo ");
        }
        builder << "pacman -S";
        if (assume_yes) {
            builder << " --noconfirm";
        }
        for (const auto& pkg : packages) {
            builder << ' ' << pkg;
        }
        return builder.str();
    };

    const std::string non_interactive_command = build_command(true);
    bool requires_password = false;
    CommandResult result{0, {}};

    try {
        result = run_command_capture(non_interactive_command);
        if (result.exit_code != 0 && contains_password_prompt(result.combined_output)) {
            requires_password = true;
        }
    } catch (const std::exception& ex) {
        result.exit_code = -1;
        result.combined_output = ex.what();
    }

    const std::string interactive_command = build_command(false);

    std::ostringstream packages_json;
    packages_json << '[';
    for (std::size_t i = 0; i < packages.size(); ++i) {
        if (i > 0) {
            packages_json << ',';
        }
        packages_json << "\"" << escape_json(packages[i]) << "\"";
    }
    packages_json << ']';

    std::ostringstream json;
    json << '{';
    json << "\"command\":\"" << escape_json(non_interactive_command) << "\",";
    json << "\"interactive_command\":\"" << escape_json(interactive_command) << "\",";
    json << "\"packages\":" << packages_json.str() << ',';
    json << "\"exit_code\":" << result.exit_code << ',';
    json << "\"requires_password\":" << (requires_password ? "true" : "false") << ',';
    json << "\"output\":\"" << escape_json(result.combined_output) << "\"";
    json << '}';

    return json.str();
}

}
