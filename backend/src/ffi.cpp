#include <string>
#include <memory>

#include "nanookjaro/export.hpp"
#include "./system/system_summary.hpp"
#include "./hardware/disk_monitor.hpp"
#include "./performance/performance_monitor.hpp"
#include "./network/network_monitor.hpp"

const char* duplicate_as_c_string(const std::string& source) {
    const size_t len = source.length();
    char* dest = static_cast<char*>(malloc(len + 1));
    if (dest == nullptr) {
        return nullptr;
    }
    source.copy(dest, len);
    dest[len] = '\0';
    return dest;
}

const char* error_response() {
    return duplicate_as_c_string(R"({"error": "internal_error"})");
}

extern "C" {

NANOOKJARO_API const char* nj_get_system_summary() {
    try {
        std::string payload = nanookjaro::system_summary_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API void nj_free_string(const char* str) {
    free(const_cast<char*>(str));
}

NANOOKJARO_API const char* nj_set_proxy(const char* http_proxy, const char* https_proxy) {
    try {
        std::string payload = nanookjaro::set_proxy_config_json(
            http_proxy ? http_proxy : "",
            https_proxy ? https_proxy : "");
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API const char* nj_get_cpu_info() {
    try {
        std::string payload = nanookjaro::cpu_info_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API const char* nj_get_gpu_info() {
    try {
        std::string payload = nanookjaro::gpu_info_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API const char* nj_get_memory_info() {
    try {
        std::string payload = nanookjaro::memory_info_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API const char* nj_get_disk_info() {
    try {
        std::string payload = nanookjaro::disk_info_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API const char* nj_get_network_info() {
    try {
        std::string payload = nanookjaro::network_info_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

NANOOKJARO_API const char* nj_get_drivers_info() {
    try {
        std::string payload = nanookjaro::drivers_info_json();
        return duplicate_as_c_string(payload);
    } catch (...) {
        return error_response();
    }
}

}
