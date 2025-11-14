# Nanookjaro Architecture 🏗️

## Overview 🌟

Nanookjaro Toolkit follows an elegant modular architecture with a clear separation between the backend (C++ core), frontend (Flutter GUI), and command-line interface. This sophisticated design enables maximum code reuse, maintainability, and extensibility while ensuring a cohesive system monitoring and management experience.

The architecture is built with a progressive enhancement approach, prioritizing Linux distributions (especially Arch-based ones) while maintaining a foundation for future platform expansions including macOS.

## High-Level Architecture 📐

```
┌────────────────────────────────────────────────────────┐
│                      FRONTEND LAYER                   │
│                                                        │
│              ┌─────────────────────────┐               │
│              │    Flutter Desktop App  │               │
│              │  Glassmorphism UI/UX    │               │
│              └─────────────────────────┘               │
│                                                        │
│              ┌─────────────────────────┐               │
│              │      CLI Interface      │               │
│              │    Terminal-Optimized   │               │
│              └─────────────────────────┘               │
└──────────────────────────┬─────────────────────────────┘
                           │ FFI Bridge (JSON)
┌──────────────────────────┴─────────────────────────────┐
│                      MIDDLEWARE LAYER                  │
│                                                        │
│              ┌─────────────────────────┐               │
│              │    C++ Core Library     │               │
│              │      (Nanookjaro Core)  │               │
│              └─────────────────────────┘               │
│                   System Information                   │
│                   Package Management                   │
│                   Performance Metrics                  │
│                   Data Export/Import                   │
└──────────────────────────┬─────────────────────────────┘
                           │ Platform Abstraction Layer
┌──────────────────────────┴─────────────────────────────┐
│                     PLATFORM LAYER                     │
│                                                        │
│  Linux (Primary)    macOS (Planned)    Windows (Future)│
│  /proc, sysfs       IOKit                              │
│  lspci, lsmod       sysctl                             │
│  udev, smartctl     system_profiler                    │
│  pacman (pacman)                                       │
└────────────────────────────────────────────────────────┘
```

## Project Structure 📁

```
.
├── backend/               # C++ backend implementation
│   ├── src/              # Source code
│   │   ├── hardware/     # Hardware monitoring modules
│   │   ├── network/      # Network monitoring modules
│   │   ├── system/       # System information modules
│   │   ├── maintenance/  # Maintenance and package management
│   │   ├── drivers/      # Driver management
│   │   ├── performance/  # Performance monitoring
│   │   ├── ffi.cpp       # FFI interface implementation
│   │   └── ...           # Additional modules
│   ├── include/          # Public headers
│   └── CMakeLists.txt    # Build configuration
├── frontend/             # Flutter frontend
│   └── flutter/          # Flutter application
├── cli/                  # Command-line interface
├── docs/                 # Documentation
├── cmake/                # CMake modules
├── scripts/              # Build and utility scripts
└── CMakeLists.txt        # Root build configuration
```

## Component Details 🧩

### Backend (C++ Core) ⚙️

The backend is implemented in modern C++ (C++20) and provides the core functionality of the toolkit:

1. **System Information Module**
   - CPU monitoring (usage, frequency, temperature)
   - Memory monitoring (RAM, swap)
   - Disk monitoring (usage, SMART data)
   - GPU monitoring (usage, temperature)
   - Network monitoring (bandwidth, connections)
   - Process monitoring

2. **Package Management Module**
   - Integration with system package managers
   - Primary support for pacman (Arch/Manjaro)
   - Planned support for apt (Debian/Ubuntu) and yum/dnf (RHEL/CentOS)

3. **Performance Monitoring**
   - Real-time data sampling
   - Historical data storage in circular buffers
   - Configurable sampling intervals

### Frontend (Flutter GUI) 🎨

The frontend is built with Flutter and provides a modern, responsive user interface:

1. **UI Components**
   - Dashboard with key metrics
   - Detailed system information views
   - Real-time performance charts
   - Package management interface
   - Settings and configuration

2. **State Management**
   - Uses Riverpod for state management
   - Reactive updates from backend
   - Local state for UI interactions

### Command-Line Interface 💻

The CLI provides access to toolkit functionality from the terminal:

1. **Commands**
   - System information display
   - Package management operations
   - Report generation
   - Headless operation mode

## Communication Patterns 🔄

### FFI Communication 🔌

The primary communication between the Flutter frontend and C++ backend uses Dart FFI:

1. **Function Calls**
   - Synchronous calls for immediate data
   - Asynchronous calls for long-running operations

2. **Data Exchange**
   - JSON strings for complex data structures
   - Simple values for scalar data
   - Memory management through explicit allocation/deallocation

## Data Flow 📊

1. **Data Collection**
   - Backend collects data from system APIs
   - Data is processed and formatted as JSON
   - Data is stored in circular buffers for historical access

2. **Data Distribution**
   - Frontend requests data through FFI
   - CLI accesses data through direct library calls

3. **Real-time Updates**
   - Backend pushes updates to registered listeners
   - Frontend polls for updates at configurable intervals
   - CLI can subscribe to streaming updates