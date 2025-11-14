# 构建 Nanookjaro 工具包 🛠️

## 前置条件 ⚙️

在构建 Nanookjaro 工具包之前，请确保您已安装以下工具：

### Linux（主要平台）💻
- C++20 兼容编译器（GCC 10+ 或 Clang 10+）
- CMake 3.20 或更高版本
- Flutter SDK 3.0 或更高版本
- Git
- pkg-config
- 系统库：
  - libudev-dev
  - libpci-dev
  - libssl-dev
  - smartmontools（用于磁盘健康监控）
  - pacman-contrib（用于基于 Arch 的系统）

### 可选依赖 🧩
- nvidia-smi（用于 NVIDIA GPU 监控）
- lm-sensors（用于额外的硬件传感器）

## 项目结构 📁

```
Nanookjaro-Toolkit/
├── backend/               # C++ 核心库
│   ├── src/              # 源代码
│   ├── include/          # 公共头文件
│   └── CMakeLists.txt    # 构建配置
├── frontend/             # Flutter 前端
│   └── flutter/          # Flutter 应用程序
├── cli/                  # 命令行界面
├── docs/                 # 文档
├── cmake/                # CMake 模块
└── CMakeLists.txt        # 根构建配置
```

## 构建后端 ⚙️

后端是一个 C++ 库，提供系统监控功能和包管理集成。

### Linux 构建步骤 🐧

1. 导航到项目根目录：
   ```bash
   cd /path/to/Nanookjaro-Toolkit
   ```

2. 创建构建目录并导航到该目录：
   ```bash
   mkdir build && cd build
   ```

3. 使用 CMake 配置构建：
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Release
   ```
   
   对于带调试符号的开发构建：
   ```bash
   cmake .. -DCMAKE_BUILD_TYPE=Debug
   ```

4. 编译项目：
   ```bash
   cmake --build . --config Release -j$(nproc)
   ```

5. 构建将生成：
   - `libnanookjaro.so` - 主共享库
   - 各种中间目录中的目标文件

### CMake 选项 🔧

您可以使用以下 CMake 选项自定义构建：

- `-DNANOOKJARO_BUILD_TESTS=ON/OFF` - 启用/禁用构建测试（默认：OFF）
- `-DNANOOKJARO_ENABLE_INSTALL=ON/OFF` - 启用/禁用安装目标（默认：ON）
- `-DCMAKE_INSTALL_PREFIX=/path` - 设置安装前缀（默认：/usr/local）

带自定义选项的示例：
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release -DNANOOKJARO_BUILD_TESTS=ON
```

## 构建前端 🎨

前端是一个 Flutter 应用程序，提供图形用户界面。

### 前置条件 ✅
- Flutter SDK 3.0 或更高版本
- 已安装的系统依赖（如上所述）

### 构建步骤 🏗️

1. 导航到 Flutter 前端目录：
   ```bash
   cd /path/to/Nanookjaro-Toolkit/frontend/flutter
   ```

2. 获取 Flutter 依赖：
   ```bash
   flutter pub get
   ```

3. 为 Linux 构建：
   ```bash
   flutter build linux
   ```

4. 构建输出将位于：
   ```
   build/linux/x64/release/bundle/
   ```

### 开发工作流 🚀

对于开发，您可以直接运行应用程序：
```bash
flutter run -d linux
```

这将构建并在调试模式下运行应用程序，具有热重载功能。

## 构建 CLI 💻

命令行界面提供从终端访问工具包功能。

### 构建步骤 🔨

CLI 作为主 CMake 构建过程的一部分自动构建。构建后端后，您将在以下位置找到 CLI 二进制文件：
```
build/cli/nanookjaro-cli
```

您也可以仅构建 CLI：
```bash
cd /path/to/Nanookjaro-Toolkit/build
make nanookjaro-cli
```

## 安装 💾

### 系统范围安装（Linux）🖥️

构建后，您可以将工具包系统范围安装：

1. 从构建目录：
   ```bash
   sudo cmake --install . --config Release
   ```

2. 这将安装：
   - 共享库到 `/usr/local/lib/`
   - 头文件到 `/usr/local/include/nanookjaro/`
   - CLI 工具到 `/usr/local/bin/nanookjaro-cli`
   - 文档到 `/usr/local/share/doc/nanookjaro/`

### 创建分发包 📦

#### Arch Linux（PKGBUILD）🐧

对于基于 Arch 的发行版，您可以使用提供的 PKGBUILD：

1. 导航到 pkgbuilds 目录：
   ```bash
   cd /path/to/Nanookjaro-Toolkit/pkgbuilds
   ```

2. 构建包：
   ```bash
   makepkg -si
   ```

这将创建并安装一个可以用 pacman 管理的包。

## 故障排除 ❓

### 常见构建问题 🔧

#### 缺少依赖 ⚠️
如果您遇到关于缺少依赖的错误，请确保您已安装所有必需的包：
```bash
# Arch/Manjaro
sudo pacman -S base-devel cmake flutter git pkg-config libudev-dev libpci-dev smartmontools pacman-contrib

# Ubuntu/Debian
sudo apt-get install build-essential cmake flutter git pkg-config libudev-dev libpci-dev smartmontools
```

#### CMake 版本问题 📉
如果出现 CMake 版本错误，您可能需要安装更新版本：
```bash
# Arch/Manjaro
sudo pacman -S cmake

# Ubuntu/Debian
sudo apt-get install cmake
```

#### Flutter 问题 🐞
如果 Flutter 命令失败，请确保 Flutter 已正确安装并在您的 PATH 中：
```bash
flutter doctor
```

#### 库链接问题 🔗
如果前端找不到后端库，请确保它在库路径中：
```bash
export LD_LIBRARY_PATH=/path/to/Nanookjaro-Toolkit/build:$LD_LIBRARY_PATH
```

### 清理构建 🧹

要执行清理构建：

1. 删除构建目录：
   ```bash
   rm -rf build
   ```

2. 对于 Flutter 前端：
   ```bash
   cd frontend/flutter
   flutter clean
   ```

## 测试 ✅

### 后端测试 🔬

如果使用测试启用构建（`-DNANOOKJARO_BUILD_TESTS=ON`），您可以运行后端测试：
```bash
cd build
ctest
```

### 前端测试 🧪

运行 Flutter 测试：
```bash
cd frontend/flutter
flutter test
```

## 性能考虑 ⚡

### 构建优化 🚀

为了更快的构建，考虑：

1. 使用所有可用的 CPU 核心：
   ```bash
   cmake --build . --config Release -j$(nproc)
   ```

2. 使用 Ninja 生成器以获得更快的构建：
   ```bash
   cmake .. -G Ninja
   ninja
   ```

### 发布版 vs 调试版构建 🆚

- 发布版构建针对性能进行了优化
- 调试版构建包含调试符号但可能较慢
- 对于生产使用，请始终使用发布版构建