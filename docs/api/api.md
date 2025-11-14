# Nanookjaro API Documentation 📚

## Overview 🌟

The Nanookjaro Toolkit provides a C++ backend library with C-style exported functions that can be accessed through FFI (Foreign Function Interface) from other languages. This API serves as the foundation for both the graphical and command-line interfaces, offering a comprehensive set of functionalities for system monitoring, package management, and configuration.

The primary interface is through a shared library that exposes well-defined functions for system information retrieval, package management, and configuration. This design ensures maximum compatibility and performance across different frontend implementations.

## Library Functions 🧩

### System Information Functions 🖥️

#### `const char* nj_get_system_summary()`

Retrieves a comprehensive summary of system information in JSON format.

**Returns**: A JSON string containing system information including:
- CPU details (model, cores, usage)
- Memory information (total, available, used, swap)
- Load averages
- Filesystem usage
- GPU information
- Network interface information
- Proxy settings

**Example Output**:
```json
{
  "timestamp": "2025-11-13T15:30:45Z",
  "cpu": {
    "model": "Intel(R) Core(TM) i7-14700HX",
    "cores": 28,
    "usage_percent": 12.5
  },
  "memory": {
    "total_kb": 16070652,
    "available_kb": 4322932,
    "used_kb": 11747720,
    "usage_percent": 73.10,
    "swap_total_kb": 0,
    "swap_free_kb": 0,
    "swap_used_kb": 0,
    "swap_usage_percent": 0.00
  },
  "load_average": [2.92, 2.82, 6.22],
  "filesystems": [
    {
      "mount": "/",
      "total_bytes": 1023892836352,
      "available_bytes": 569182707712
    }
  ],
  "gpu": [
    {
      "name": "Intel Corporation Raptor Lake-S UHD Graphics (rev 04)",
      "vendor": "Intel",
      "driver_version": "Unknown",
      "memory_mb": 0,
      "usage_percent": 0.00,
      "temperature_celsius": -1.00
    },
    {
      "name": "NVIDIA Corporation AD107M [GeForce RTX 4060 Max-Q / Mobile] (rev a1)",
      "vendor": "NVIDIA",
      "driver_version": "Unknown",
      "memory_mb": 0,
      "usage_percent": 0.00,
      "temperature_celsius": -1.00
    }
  ],
  "network": [
    {
      "name": "enp7s0",
      "mac_address": "bc:ec:a0:49:4d:b5",
      "ipv4_address": "192.168.1.100",
      "ipv6_address": "fe80::beec:a0ff:fe49:4db5",
      "rx_rate_kbps": 125.50,
      "tx_rate_kbps": 10.25,
      "is_up": true
    }
  ],
  "proxy": {
    "http": null,
    "https": null
  }
}
```

#### `void nj_free_string(const char* s)`

Frees memory allocated by the library for string returns.

**Parameters**:
- `s`: Pointer to the string to be freed

#### `const char* nj_get_cpu_info()`

Retrieves detailed CPU information.

**Returns**: A JSON string containing detailed CPU information.

#### `const char* nj_get_gpu_info()`

Retrieves detailed GPU information.

**Returns**: A JSON string containing detailed GPU information.

#### `const char* nj_get_memory_info()`

Retrieves detailed memory information.

**Returns**: A JSON string containing detailed memory information.

#### `const char* nj_get_disk_info()`

Retrieves detailed disk information.

**Returns**: A JSON string containing detailed disk information.

#### `const char* nj_get_network_info()`

Retrieves detailed network information.

**Returns**: A JSON string containing detailed network information.

#### `const char* nj_get_drivers_info()`

Retrieves system driver information.

**Returns**: A JSON string containing driver information.

### Package Management Functions 📦

#### `const char* nj_pacman_sync_upgrade(int assume_yes)`

Performs a system upgrade using pacman (Arch Linux specific).

**Parameters**:
- `assume_yes`: If non-zero, automatically answer yes to prompts

**Returns**: A JSON string with upgrade results:
- Command executed
- Exit code
- Output from the command

#### `const char* nj_pacman_list_updates()`

Lists available package updates using pacman.

**Returns**: A JSON string with update information:
- List of packages with updates
- Command executed
- Exit code

#### `const char* nj_pacman_install_packages_json(const char** packages, int count, int assume_yes)`

Installs specified packages using pacman.

**Parameters**:
- `packages`: Array of package names to install
- `count`: Number of packages in the array
- `assume_yes`: If non-zero, automatically answer yes to prompts

**Returns**: A JSON string with installation results.

### Configuration Functions ⚙️

#### `const char* nj_set_proxy(const char* http_proxy, const char* https_proxy)`

Sets HTTP and HTTPS proxy configuration.

**Parameters**:
- `http_proxy`: HTTP proxy URL (can be NULL)
- `https_proxy`: HTTPS proxy URL (can be NULL)

**Returns**: A JSON string indicating success or failure.

## Error Handling ❌

All functions that return `const char*` will return a JSON object with an "error" field if an error occurs. Always check for this field when processing results.

## Memory Management 💾

All strings returned by the library must be freed using `nj_free_string()` to avoid memory leaks.

## Thread Safety 🧵

The library is not guaranteed to be thread-safe. Access from multiple threads should be synchronized by the calling application.

## Platform Support 🖥️

Nanookjaro is designed with a progressive enhancement approach to platform support:

- **Linux (Arch/Manjaro)**: Full support with all features enabled
  - Complete system monitoring capabilities
  - Full package management integration with pacman
  - All API functions operational

- **Linux (Other Distributions)**: Core support with system monitoring
  - System information retrieval functions fully operational
  - Limited package management (planned for future releases)
  - Configuration functions available

- **macOS**: Planned support in future releases
  - Core system monitoring functions
  - Platform-specific enhancements

- **Windows**: Not currently supported
  - No immediate plans for support