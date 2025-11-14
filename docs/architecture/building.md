# Building Nanookjaro Toolkit 🛠️

## Prerequisites ⚙️

Before building Nanookjaro Toolkit, ensure you have the following tools installed:

### Linux (Primary Platform) 💻
- C++20 compatible compiler (GCC 10+ or Clang 10+)
- CMake 3.20 or higher
- Flutter SDK 3.0 or higher
- Git
- pkg-config
- System libraries:
  - libudev-dev
  - libpci-dev
  - libssl-dev
  - smartmontools (for disk health monitoring)
  - pacman-contrib (for Arch-based systems)

### Optional Dependencies 🧩
- nvidia-smi (for NVIDIA GPU monitoring)
- lm-sensors (for additional hardware sensors)

## Project Structure 📁

```
Nanookjaro-Toolkit/
├── backend/               # C++ core library
│   ├── src/              # Source code
│   ├── include/          # Public headers
│   └── CMakeLists.txt    # Build configuration
├── frontend/             # Flutter frontend
│   └── flutter/          # Flutter application
├── cli/                  # Command-line interface
├── docs/                 # Documentation
├── cmake/                # CMake modules
└── CMakeLists.txt        # Root build configuration
```

## Building the Backend ⚙️

The backend is a C++ library that provides system monitoring capabilities and package management integration.

### Linux Build Steps 🐧

1. Navigate to the project root directory:
   ```bash
   cd /path/to/Nanookjaro-Toolkit
   ```

2. Create a build directory and navigate to it:
   ```bash
   mkdir build && cd build
   ```

3. Configure the build with CMake:
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Release
   ```
   
   For development builds with debug symbols:
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Debug
   ```

4. Compile the project:
   ```bash
   cmake --build . --config Release -j$(nproc)
   ```

5. The build will produce:
   - `libnanookjaro.so` - The main shared library
   - Various object files in intermediate directories

### CMake Options 🔧

You can customize the build with the following CMake options:

- `-DNANOOKJARO_BUILD_TESTS=ON/OFF` - Enable/disable building tests (default: OFF)
- `-DNANOOKJARO_ENABLE_INSTALL=ON/OFF` - Enable/disable installation targets (default: ON)
- `-DCMAKE_INSTALL_PREFIX=/path` - Set installation prefix (default: /usr/local)

Example with custom options:
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release -DNANOOKJARO_BUILD_TESTS=ON
```

## Building the Frontend 🎨

The frontend is a Flutter application that provides the graphical user interface.

### Prerequisites ✅
- Flutter SDK 3.0 or higher
- System dependencies installed (as mentioned above)

### Build Steps 🏗️

1. Navigate to the Flutter frontend directory:
   ```bash
   cd /path/to/Nanookjaro-Toolkit/frontend/flutter
   ```

2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Build for Linux:
   ```bash
   flutter build linux
   ```

4. The build output will be located at:
   ```
   build/linux/x64/release/bundle/
   ```

### Development Workflow 🚀

For development, you can run the application directly:
```bash
flutter run -d linux
```

This will build and run the application in debug mode, with hot reload capabilities.

## Building the CLI 💻

The command-line interface provides access to toolkit functionality from the terminal.

### Build Steps 🔨

The CLI is automatically built as part of the main CMake build process. After building the backend, you'll find the CLI binary at:
```
build/cli/nanookjaro-cli
```

You can also build only the CLI with:
```bash
cd /path/to/Nanookjaro-Toolkit/build
make nanookjaro-cli
```

## Installation 💾

### Installing System-wide (Linux) 🖥️

After building, you can install the toolkit system-wide:

1. From the build directory:
   ```bash
   sudo cmake --install . --config Release
   ```

2. This will install:
   - The shared library to `/usr/local/lib/`
   - Headers to `/usr/local/include/nanookjaro/`
   - The CLI tool to `/usr/local/bin/nanookjaro-cli`
   - Documentation to `/usr/local/share/doc/nanookjaro/`

### Creating a Distribution Package 📦

#### Arch Linux (PKGBUILD) 🐧

For Arch-based distributions, you can use the provided PKGBUILD:

1. Navigate to the pkgbuilds directory:
   ```bash
   cd /path/to/Nanookjaro-Toolkit/pkgbuilds
   ```

2. Build the package:
   ```bash
   makepkg -si
   ```

This will create and install a package that can be managed with pacman.

## Troubleshooting ❓

### Common Build Issues 🔧

#### Missing Dependencies ⚠️
If you encounter errors about missing dependencies, make sure you've installed all required packages:
```bash
# Arch/Manjaro
sudo pacman -S base-devel cmake flutter git pkg-config libudev-dev libpci-dev smartmontools pacman-contrib

# Ubuntu/Debian
sudo apt-get install build-essential cmake flutter git pkg-config libudev-dev libpci-dev smartmontools
```

#### CMake Version Issues 📉
If you get CMake version errors, you may need to install a newer version:
```bash
# Arch/Manjaro
sudo pacman -S cmake

# Ubuntu/Debian
sudo apt-get install cmake
```

#### Flutter Issues 🐞
If Flutter commands fail, ensure Flutter is properly installed and in your PATH:
```bash
flutter doctor
```

#### Library Linking Issues 🔗
If the frontend can't find the backend library, ensure it's in the library path:
```bash
export LD_LIBRARY_PATH=/path/to/Nanookjaro-Toolkit/build:$LD_LIBRARY_PATH
```

### Clean Builds 🧹

To perform a clean build:

1. Remove the build directory:
   ```bash
   rm -rf build
   ```

2. For Flutter frontend:
   ```bash
   cd frontend/flutter
   flutter clean
   ```

## Testing ✅

### Backend Tests 🔬

If built with tests enabled (`-DNANOOKJARO_BUILD_TESTS=ON`), you can run backend tests:
```bash
cd build
ctest
```

### Frontend Tests 🧪

Run Flutter tests:
```bash
cd frontend/flutter
flutter test
```

## Performance Considerations ⚡

### Build Optimization 🚀

For faster builds, consider:

1. Using all available CPU cores:
   ```bash
   cmake --build . --config Release -j$(nproc)
   ```

2. Using Ninja generator for faster builds:
   ```bash
   cmake .. -G Ninja
   ninja
   ```

### Release vs Debug Builds 🆚

- Release builds are optimized for performance
- Debug builds include symbols for debugging but may be slower
- For production use, always use Release builds