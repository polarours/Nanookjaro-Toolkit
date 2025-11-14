# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- C++ backend with system monitoring capabilities
- Flutter frontend with glassmorphism UI
- CLI interface for headless operations
- Package management integration with pacman
- Cross-platform support (Linux/Windows/macOS)

### Changed
- Improved project structure with modular organization
- Moved header files to be co-located with source files
- Enhanced documentation with detailed platform support information
- Updated build instructions in documentation

### Fixed
- Namespace issues in package manager implementation
- Build system configuration for proper header file inclusion

## [0.1.0] - 2025-11-13

Initial development release.

### Added
- System information collection for CPU, memory, disk, and GPU
- Real-time hardware monitoring capabilities
- Basic package management integration with pacman
- Cross-platform GUI and CLI interfaces
- Primary support for Manjaro/Arch Linux distributions
- Secondary support for most Linux distributions
- Planned support for macOS
- Glassmorphism UI design with animated Aurora background
- System dashboard with key metrics visualization
- Detailed hardware information views (CPU, Memory, Storage, Network, GPU)
- Package update checking and system upgrade functionality
- Proxy configuration support
- Light and dark theme options
- Multi-language support (i18n)
- JSON API for backend communication
- FFI integration between Flutter frontend and C++ backend
- CMake build system for cross-platform compilation
- Comprehensive documentation (API, Architecture, Frontend, User Guide)

### Changed
- Improved UI responsiveness and performance
- Enhanced error handling throughout the application
- Optimized memory management in the C++ backend
- Refined build scripts and project structure

### Fixed
- AWK command escaping issues in system information retrieval
- UI layout overflow problems in system overview cards
- FFI library loading paths for proper cross-platform functionality
- Directory naming inconsistencies in project structure