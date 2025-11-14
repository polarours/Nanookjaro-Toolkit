# Nanookjaro Toolkit User Guide 📘

## Introduction 👋

Welcome to the Nanookjaro Toolkit, a system monitoring and management solution designed primarily for Manjaro/Arch Linux users with compatibility across Linux distributions. This toolkit transforms system administration into a visually pleasing and intuitive experience.

This guide will walk you through installing, configuring, and using all features of the toolkit, from basic system monitoring to advanced package management.

## Getting Started 🚀

### System Requirements 💻

Before installing Nanookjaro Toolkit, ensure your system meets these requirements:

- Operating System: 
  - Primary: Manjaro Linux, Arch Linux (full feature support)
  - Secondary: Most Linux distributions (core monitoring features)
- Architecture: x86_64
- Minimum RAM: 2GB
- Disk Space: 100MB free space
- Display: X11 or Wayland compositor

For the complete feature set including package management, we recommend using an Arch-based distribution such as Manjaro or Arch Linux.

### Installation 🔧

There are two ways to install Nanookjaro Toolkit:

#### Method 1: Using AUR (Recommended) 🌟

If you have an AUR helper installed (like yay or paru):

```bash
yay -S nanookjaro-toolkit-git
# or
paru -S nanookjaro-toolkit-git
```

#### Method 2: Building from Source 🏗️

To build from source, you'll need these dependencies:
- CMake 3.20+
- C++20 compiler (GCC 10+ or Clang 10+)
- Flutter SDK 3.0+
- pacman-contrib
- pciutils
- smartmontools

Clone the repository and build:

```bash
git clone https://github.com/polarours/Nanookjaro-Toolkit.git
cd Nanookjaro-Toolkit
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

After building the backend, you'll need to build the Flutter frontend:

```bash
cd ../frontend/flutter
flutter build linux
```

## Using the Graphical Interface 🎨

### Launching the Application ▶️

After installation, you can launch the Nanookjaro Toolkit GUI in several ways:

1. From the application menu: Look for "Nanookjaro Toolkit" in the System or Utilities section
2. From terminal:
   ```bash
   nanookjaro-toolkit
   ```
3. By running the binary directly (if built from source):
   ```bash
   ./frontend/flutter/build/linux/x64/release/bundle/nanookjaro_frontend
   ```

### Dashboard Overview 📊

Upon launching, you'll see the dashboard which displays key system metrics:

- **CPU Usage**: Current processor utilization with per-core breakdown
- **Memory Usage**: RAM and swap usage statistics
- **Disk Usage**: Storage space usage for mounted filesystems
- **Network Activity**: Incoming and outgoing network traffic with real-time rates
- **System Load**: Current system load average
- **GPU Information**: Detected graphics cards

### Navigation 🧭

The left sidebar provides access to all sections:
- Dashboard: Overview of system metrics
- CPU: Detailed processor information
- Memory: Comprehensive memory statistics
- Storage: Disk and filesystem details
- Network: Network interface information
- GPU: Graphics card details
- Packages: Package management interface

## System Information Views 🔍

Each section provides detailed information about that system component:

#### CPU Section ⚙️
- Model and specifications
- Real-time usage graphs
- Per-core utilization
- Temperature readings (if available)

#### Memory Section 💾
- Total, used, and available memory
- Swap space usage
- Memory pressure indicators
- Detailed breakdown of memory usage

#### Storage Section 💿
- All mounted filesystems
- Available and used space
- SMART data for drives (if available)
- Read/write activity statistics

#### Network Section 🌐
- Active network interfaces
- IP addresses
- Traffic statistics with real-time rates (KB/s)
- Connection status

#### GPU Section 🎮
- Graphics card model
- Driver information
- Utilization statistics
- Temperature readings

## Package Management 📦

Nanookjaro Toolkit provides comprehensive package management integration with pacman, Arch Linux's powerful package manager. This feature is one of the key advantages of using Nanookjaro on Arch-based distributions.

Note: Package management features are currently only available on Arch-based distributions.

### Checking for Updates 🔍

Click on the "Packages" section in the sidebar to view:
- Number of available updates
- List of upgradable packages
- Package descriptions and versions

### Performing System Upgrades ⬆️

To upgrade your system:
1. Navigate to the Packages section
2. Click the "Check for Updates" button
3. Review the list of available updates
4. Click "Upgrade System" to begin the upgrade process
5. Enter your password when prompted (requires sudo access)

### Installing New Packages ➕

To install new packages:
1. Navigate to the Packages section
2. Use the search bar to find packages
3. Click the "+" button next to a package to mark it for installation
4. Click "Apply Changes" to install marked packages
5. Enter your password when prompted

## Using the Command-Line Interface 💻

The CLI provides all the functionality of the GUI in a terminal-friendly format.

### Basic Commands 📋

```bash
# Show system summary
nanookjaro-cli

# List available package updates
nanookjaro-cli pacman list-updates

# Perform system upgrade
nanookjaro-cli pacman upgrade

# Install packages
nanookjaro-cli pacman install <package-name> [<package-name>...]

# Set proxy configuration
nanookjaro-cli proxy set [--http URL] [--https URL]

# Clear proxy configuration
nanookjaro-cli proxy clear
```

### Command Output Formats 📤

Most commands support multiple output formats:
- Human-readable (default)
- JSON (`--json` flag)

Example:
```bash
nanookjaro-cli --json | jq .
```

## Configuration ⚙️

### Proxy Settings 🌐

Configure HTTP/HTTPS proxies through either:
1. GUI: Settings > Proxy
2. CLI: `nanookjaro-cli proxy set --http http://proxy:port --https https://proxy:port`

### Theme Settings 🎨

Switch between light and dark themes:
1. GUI: Settings > Appearance
2. The theme will be saved and applied on next launch

## Troubleshooting ❓

### Common Issues 🔧

#### Application Won't Start ❌
- Ensure all dependencies are installed
- Check that you're running on a supported platform
- Try running from terminal to see error messages

#### Package Operations Fail 🚫
- Verify you have sudo access
- Check that pacman is functioning correctly
- Ensure you have an active internet connection

#### Incorrect System Information ⚠️
- Some hardware sensors may not be detected
- Install additional tools like lm_sensors for better hardware monitoring

### Getting Help 🆘

For additional help:
1. Check the documentation in the docs/ directory
2. Visit the GitHub repository for issues and discussions
3. Contact the development team through GitHub

## Advanced Usage 🧠

### Customizing the Dashboard 🎛️

Widgets on the dashboard can be rearranged by dragging and dropping them to your preferred positions.

### Performance Monitoring 📈

The toolkit continuously monitors system performance and stores historical data for trend analysis. Access detailed historical data through the respective sections.

### Automation 🤖

Use the CLI for automation scripts:
```bash
#!/bin/bash
# Daily system check script
nanookjaro-cli pacman list-updates > /var/log/nanookjaro-updates.log
nanookjaro-cli > /var/log/nanookjaro-system-summary.log
```

## Contributing 🤝

We welcome contributions to the Nanookjaro Toolkit! Here's how you can help:

1. Report bugs and suggest features on GitHub
2. Submit pull requests with improvements
3. Help translate the application
4. Improve documentation

### Development Setup 🛠️

To set up a development environment:

```bash
git clone https://github.com/polarours/Nanookjaro-Toolkit.git
cd Nanookjaro-Toolkit
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```

Build the Flutter frontend for development:

```bash
cd ../frontend/flutter
flutter run -d linux
```

## License 📄

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments 🙏

Special thanks to:
- The Flutter team for the excellent UI framework
- The Arch Linux community for the robust package management system
- All contributors and testers who helped shape this toolkit