# Nanookjaro Toolkit

Language: English (en) | [中文](README_zh-CN.md)

Cross-platform hardware detection, system performance monitoring and package management toolkit (Flutter frontend / C++ backend / dart:ffi)

## Project Overview

Nanookjaro Toolkit is a cross-platform desktop tool for personal and engineering users, providing system hardware detection, real-time performance monitoring, and package management functionality. It emphasizes three core values:

- Beautiful UI: Built with Flutter to create a modern, smooth interface with dark/light themes and responsive layout.
- High-performance backend: Implemented in C++ for low-level system interaction (CPU, GPU, disk, packages, etc.), exposed to Flutter via FFI.
- Cross-platform support: Fully supports Linux (focus: Manjaro/Arch/Ubuntu), with planned support for macOS and Windows.

Use cases include: personal desktop hardware monitoring, development/testing environment diagnostics, and hardware data collection for teaching/research.

## Key Features

### Hardware Information
- CPU: Model, architecture, cores and threads, base and current frequency, temperature (if available), cache information.
- GPU: Model, vendor, driver version, memory size, current memory usage and utilization (NVIDIA/AMD/Intel support).
- Memory: Total, used, available, swap information.
- Disk: Partitions, capacity, usage, read/write rate, SMART health fields (supports smartctl).
- Network: Interfaces, MAC, IPv4/IPv6, current traffic rate.
- Peripherals: USB device list, sound cards, cameras, printers, etc.

### Real-time Performance Monitoring
- Supports 1s / 2s / customizable refresh cycles.
- Real-time plotting of CPU/Memory/Disk/Network/GPU curves (historical scrolling window).
- Supports multi-layer comparison (e.g., CPU temp vs CPU usage).
- Alert strategy: Threshold alerts (temperature, CPU usage, disk IO, etc.) with desktop notifications.

### Package Management
- List installed packages and available updates.
- Integration with system package managers (pacman as primary, with planned support for apt, dnf, etc.).
- System upgrade functionality with detailed output.
- Proxy configuration support.

### Reports Export
- Export system reports in JSON / HTML / Markdown formats, including snapshots and historical data.
- Support for scheduled exports and uploads (optional, future versions will support cloud synchronization).

### Command-line Mode and API
- Dual mode GUI and CLI, supporting headless (GUI-less) server-side collection.
- Simple local REST / Unix Socket interface for remote integration (optional).

## Cross-Platform Support

| Platform | Technology/Approach | Support Level |
|----------|---------------------|---------------|
| Linux (Manjaro/Arch/Ubuntu, etc.) | `/proc`, `sysfs`, `lspci`, `udev`, `smartctl` | ✅ Complete (primary platform) |
| Windows | Win32 API, WMI, PDH, SetupAPI | ⏳ Planned |
| macOS | IOKit, sysctl, system_profiler | ⏳ Planned |

Note: Different platforms have limitations on visibility of certain hardware information (e.g., laptop GPU temperature limitations). Specific features will degrade or provide alternative information based on platform capabilities.

## Architecture Design

```
┌──────────────────────────────────────────────────────────┐
│                        Frontend                          │
│                    Flutter Desktop App                   │
│  - UI layer (dashboard, details, settings)               │
│  - Providers / State management (Riverpod/Provider)      │
│  - FFI bridge -> serialize/deserialize JSON              │
└──────────────────────────┬───────────────────────────────┘
                           │ dart:ffi (synchronous/async)
┌──────────────────────────┴───────────────────────────────┐
│                        Backend                           │
│                      C++ Core Library                    │
│  - system_info (CPU/Mem/Disk/GPU)                        │
│  - performance (sampling scheduler, circular buffer)     │
│  - drivers (scan / backup / actions)                     │
│  - platform adapter layer (Windows/Linux/macOS)          │
│  - exporter (JSON/HTML/Markdown)                         │
└──────────────────────────┬───────────────────────────────┘
                           │ IPC / REST (optional)
┌──────────────────────────┴───────────────────────────────┐
│                       Platform APIs                      │
│ Windows: Win32 / WMI / PDH / SetupAPI                    │
│ Linux: /proc, sysfs, lspci, lsmod, udev, smartctl        │
│ macOS: IOKit, sysctl, system_profiler                    │
└──────────────────────────────────────────────────────────┘
```

Design Highlights
- Modularity: Each hardware subsystem (CPU/GPU/Disk/Packages) is implemented separately with a unified JSON output interface.
- High-performance sampling: Backend uses multithreading sampling and circular buffers to ensure smooth UI updates without blocking.
- Security boundaries: Backend privilege escalation operations (such as package installation) require user confirmation, supporting privilege separation and audit logging.
- Extensibility: Backend library provided as a shared library, potentially usable as a dependency for other languages or services.

## Tech Stack

- Frontend: Flutter (stable), Dart, charts_flutter, animations package
- Backend: C++20 (modern C++ recommended), CMake
- Build Tools: GitHub Actions (CI)
- Interop: dart:ffi / JSON for data interchange
- Optional Components: System utilities: `smartctl` (smartmontools)
- License: MIT (default, facilitating community contributions and enterprise adoption)

## Repository Layout

```
Nanookjaro-Toolkit/
├── .github/
│   └── workflows/
│       ├── build.yml
│       └── release.yml
├── cmake/                 # CMake modules and configurations
├── config/                # Configuration files
├── backend/               # Core C++ library
│   ├── include/           # Public headers
│   │   └── nanookjaro/    # Nanookjaro header files
│   ├── src/               # Source files
│   │   ├── system/        # System information modules
│   │   ├── hardware/      # Hardware monitoring modules
│   │   │   ├── cpu_monitor.cpp
│   │   │   ├── gpu_monitor.cpp
│   │   │   ├── memory_monitor.cpp
│   │   │   └── disk_monitor.cpp
│   │   ├── network/       # Network monitoring modules
│   │   │   └── network_monitor.cpp
│   │   ├── drivers/       # Driver management modules
│   │   │   └── driver_manager.cpp
│   │   ├── performance/   # Performance monitoring modules
│   │   │   └── performance_monitor.cpp
│   │   ├── maintenance/   # System maintenance modules
│   │   │   └── package_manager.cpp
│   │   ├── ffi.cpp        # FFI interface
│   │   └── system/
│   │       └── system_summary.cpp
│   └── tests/             # Unit tests
├── cli/                   # Command-line interface
├── frontend/              # Frontend applications
│   └── flutter/           # Flutter GUI application
├── docs/                  # Documentation
├── scripts/               # Build and utility scripts
├── tests/                 # Integration tests
├── assets/                # Application assets
└── pkgbuilds/             # Arch Linux PKGBUILDs
```

## Build & Installation

### Prerequisites (Examples)
- Linux: `build-essential`, `cmake`, `pkg-config`, `libssl-dev`, `libudev-dev`, `libpci-dev`, `smartmontools`, `pacman-contrib`, etc.
- Windows: Visual Studio 2022 (C++ workload), CMake
- macOS: Xcode, Homebrew, cmake

### Build Backend (C++)
In the root directory:
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release -j$(nproc)
```
Results:
- Linux: `libnanookjaro.so`

### Build Frontend (Flutter)
In the `frontend/flutter` directory:
```bash
flutter pub get
flutter build linux    # linux
```
Ensure the C++ shared library is in the loadable path (same directory or system library path) at runtime.

## Usage Examples

### Run Locally (with GUI)
```bash
# Assuming the shared lib is in the same directory as the frontend binary
./nanookjaro-desktop
```

### Export Snapshot via Command Line
```bash
./nanookjaro-cli --export report.json
```

### Sample Continuously in Headless Mode
```bash
./nanookjaro-cli --headless --interval 5 --output /var/log/nanookjaro/logs.json
```

### Package Management
```bash
# List available package updates
./nanookjaro-cli pacman list-updates

# Upgrade system
./nanookjaro-cli pacman upgrade

# Install packages
./nanookjaro-cli pacman install <package-name>
```

## API (C++ shared library & JSON contract)

### Exported Functions (Examples)
```cpp
extern "C" const char* nj_get_system_summary();    // Returns JSON string (caller responsible for copying/freeing)
extern "C" const char* nj_get_cpu_info();          // CPU information
extern "C" const char* nj_get_gpu_info();          // GPU information
extern "C" const char* nj_get_memory_info();       // Memory information
extern "C" const char* nj_get_disk_info();         // Disk information
extern "C" const char* nj_get_network_info();      // Network information
extern "C" const char* nj_get_drivers_info();      // Driver information
extern "C" const char* nj_pacman_list_updates();
extern "C" const char* nj_pacman_sync_upgrade(int assume_yes);
extern "C" const char* nj_free_string(const char* s); // Free strings allocated by backend (if needed)
```

### JSON Example (System Summary)
```json
{
  "timestamp": "2025-10-31T12:34:56Z",
  "cpu": { "model": "i7-14700HX", "cores": 20, "usage": 15.3 },
  "memory": { "total_kb": 33554432, "used_kb": 8314880 },
  "gpu": { "name": "NVIDIA GeForce RTX 4060", "usage_percent": 4.2 },
  "filesystems": [
    { "mount": "/", "total_bytes": 512000000000, "available_bytes": 384000000000 }
  ]
}
```

## Development Details and Implementation Suggestions

### Backend (C++) Implementation Suggestions
- Directory scanning and sampling: On Linux, use `/proc/stat`, `/proc/meminfo`, `/sys/class/hwmon`, etc.
- Temperature reading: Prioritize system-provided hwmon (Linux) or vendor SDKs like NVML (NVIDIA) / ROCm (AMD).
- GPU support: Integrate NVIDIA NVML (NVIDIA), AMD ADL or ROCm API (if available), and degrade to driver version display for unsupported devices.
- Package operations: Strictly require user confirmation for install/upgrade operations and log them; on Linux, use package manager calls (pacman/apt/dnf).
- Threading model: Place sampling tasks on background threads, use locks or atomic operations to protect circular buffers, reducing main thread blocking.

### Frontend (Flutter) Implementation Suggestions
- State management: Recommend using Riverpod or Provider to manage global state, avoiding setState abuse.
- UI Components: Card + dashboard + line charts as primary; use Hero/AnimatedContainer/ImplicitAnimations for natural transitions.
- Theme: Provide 3 themes: Light / Dark / System, with customizable theme colors (supporting branding).
- FFI Layer: Wrap each exported C++ function with a Dart wrapper, adding timeouts and error handling to prevent UI blocking.

## Roadmap

| Version | Features (Details) |
|---------|--------------------|
| v0.1.0 | - C++ core: CPU/Memory info + basic sampling<br>- Flutter UI: Dashboard + Hardware page<br>- FFI bridge + JSON contract<br>- Build scripts & CI (Linux) |
| v0.2.0 | - Add GPU + Disk + Network real-time monitoring<br>- Chart performance optimization<br>- Support report export (JSON/HTML) |
| v0.3.0 | - Package management module (list, backup, update notifications)<br>- CLI tool enhancement & headless mode<br>- Initial automated test coverage |
| v1.0.0 | - Stable cross-platform functionality<br>- Plugin system (third-party extensions)<br>- Remote monitoring / optional cloud sync service |

## CI / Release Strategy (Example)

- Using GitHub Actions:
  - build.yml: Build C++ lib and Flutter desktop packages on Ubuntu, and execute unit tests.
  - release.yml: Generate release packages (AppImage) and publish to GitHub Releases when pushing tags.

CI Example Snippet (Simplified):
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup CMake
        uses: lukka/get-cmake@v3
      - name: Build backend
        run: |
          mkdir build && cd build
          cmake .. && cmake --build . --config Release -j2
      - name: Build frontend
        run: |
          cd frontend/flutter
          flutter pub get
          flutter build linux
```

## Contributing Guide
- fork -> feature branch -> pull request, PR template should include change description, testing steps, and compatibility impact.
- Code style: C++ uses clang-format, Dart uses dartfmt.
- Unit tests: C++ uses GoogleTest, Dart uses flutter_test.

## License
MIT

## Contact
- Project organization: Nanookjaro Project / **polarours**
- GitHub: `https://github.com/polarours/Nanookjaro-Toolkit`
- Issues: Use GitHub Issues to track bugs and feature requests

## Appendix (Example Commands, Debugging, and FAQ)
### Common Debugging Commands (Linux)
- Check CPU info: `lscpu`
- Check GPU: `lspci | grep -i vga`, `nvidia-smi`
- Check temperature: `sensors` (requires lm-sensors)
- SMART check: `smartctl -a /dev/sda`

### Frequently Asked Questions
- Q: Why can't I see GPU temperature on some devices?
  A: The device may not expose hwmon data, or requires vendor SDKs (like NVIDIA NVML).