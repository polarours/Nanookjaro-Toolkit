# Nanookjaro 工具包

语言: 中文 (zh-CN) | [English](README.md)

跨平台硬件检测、系统性能监控与包管理工具（Flutter frontend / C++ backend / dart:ffi）

## 一、项目简介（Project Overview）

Nanookjaro-Toolkit 是一个面向个人与工程用户的跨平台桌面工具，提供系统硬件检测、实时性能监控与包管理功能。它强调三个核心价值：

- 高颜值 UI：使用 Flutter 构建现代、流畅的界面，支持暗/亮主题与响应式布局。  
- 高性能底层能力：C++ 实现底层系统交互（CPU、GPU、磁盘、包管理等），通过 FFI 暴露给 Flutter。  
- 跨平台支持：完整支持 Linux（重点：Manjaro/Arch/Ubuntu），计划支持 macOS 和 Windows。

适用场景包含：个人桌面硬件监控、开发/测试环境诊断、教学/研究硬件采集等。

## 二、核心功能（Key Features）

### 硬件信息（Hardware Info）
- CPU: 型号、架构、核心与线程数量、基础频率与当前频率、温度（若可用）、缓存信息。
- GPU: 型号、厂商、驱动版本、显存大小、当前显存占用与利用率（NVIDIA/AMD/Intel 支持）。
- 内存: 总量、已用、可用、交换区信息。
- 磁盘: 分区、容量、使用率、读写速率、SMART 健康字段（支援 smartctl）。
- 网络: 接口、MAC、IPv4/IPv6、当前流量速率。
- 外设: USB 设备列表、声卡、摄像头、打印机等。

### 实时性能监控（Live Monitoring）
- 支持 1s / 2s / 自定义刷新周期。
- 实时绘制 CPU/Memory/Disk/Network/GPU 曲线图（历史滚动窗）。
- 支持多图层对比（例如：CPU temp vs CPU usage）。
- 告警策略：阈值报警（温度、CPU 占用、磁盘 IO 等），通知到桌面。

### 包管理（Package Management）
- 列出已安装包和可用更新。
- 集成系统包管理器（以 pacman 为主，计划支持 apt、dnf 等）。
- 系统升级功能及详细输出。
- 代理配置支持。

### 报表导出（Reports）
- 导出 JSON / HTML / Markdown 的系统报告，包含快照与历史数据。
- 支持定期导出与上传（可选，后续版本支持云端同步）。

### 命令行模式与 API
- GUI 与 CLI 双模式，支持 headless（无 GUI）服务器端采集。
- 简单的本地 REST / Unix Socket 接口用于远程集成（选配）。

## 三、跨平台支持（Cross-Platform Support）

| 平台 | 技术 / 方式 | 支持程度 |
|------|-------------|----------|
| Linux (Manjaro/Arch/Ubuntu等) | `/proc`, `sysfs`, `lspci`, `udev`, `smartctl` | ✅ 完整（首要平台） |
| Windows | Win32 API, WMI, PDH, SetupAPI | ⏳ 计划中 |
| macOS | IOKit, sysctl, system_profiler | ⏳ 计划中 |

注：不同平台对某些硬件信息的可见性存在限制（例如笔记本 GPU 温度受限），具体功能将根据平台能力退化或给出替代信息。

## 四、架构设计（Architecture）

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

设计要点
- 模块化：每个硬件子系统（CPU/GPU/Disk/Packages）单独实现，公共接口统一输出 JSON。
- 高性能采样：后端使用多线程采样与环形缓冲区，保证 UI 更新平滑且不会阻塞。
- 安全边界：后端权限提升操作（如安装包）需要用户确认，支持权限分离与日志审计。
- 可扩展性：后端库以 shared library 形式提供，未来可作为其他语言或服务的依赖。

## 五、技术栈（Tech Stack）

- Frontend: Flutter (stable), Dart, charts_flutter, animations package
- Backend: C++20 (建议使用 modern C++), CMake
- Build Tools: GitHub Actions（CI）
- Interop: dart:ffi / JSON for data interchange
- Optional Components: system utilities: `smartctl`（smartmontools）
- License: MIT（默认，便于社区贡献与企业采纳）

## 六、项目结构（Repository Layout）

```
Nanookjaro-Toolkit/
├── .github/
│   └── workflows/
│       ├── build.yml
│       └── release.yml
├── cmake/                 # CMake 模块和配置
├── config/                # 配置文件
├── backend/               # 核心 C++ 库
│   ├── include/           # 公共头文件
│   ├── src/               # 源代码文件
│   └── tests/             # 单元测试
├── cli/                   # 命令行接口
├── frontend/              # 前端应用
│   └── flutter/           # Flutter GUI 应用
├── docs/                  # 文档
├── scripts/               # 构建和工具脚本
├── tests/                 # 集成测试
├── assets/                # 应用资源
└── pkgbuilds/             # Arch Linux PKGBUILD 文件
```

## 七、构建与安装（Build & Installation）

### 前置依赖（示例）
- Linux: `build-essential`, `cmake`, `pkg-config`, `libssl-dev`, `libudev-dev`, `libpci-dev`, `smartmontools`, `pacman-contrib` 等
- Windows: Visual Studio 2022 (C++ workload), CMake
- macOS: Xcode, Homebrew, cmake

### 构建后端（C++）
在项目根目录下：
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release -j$(nproc)
```
结果：
- Linux: `libnanookjaro.so`

### 构建前端（Flutter）
在 `frontend/flutter` 下：
```bash
flutter pub get
flutter build linux    # linux
```
运行时确保 C++ shared library 在可加载路径（同一目录或系统库路径）。

## 八、使用示例（Usage Examples）

### 本地运行（带 GUI）
```bash
# 假设将 shared lib 放在 frontend 二进制同目录
./nanookjaro-desktop
```

### 命令行导出快照
```bash
./nanookjaro-cli --export report.json
```

### 以 headless 模式持续采样并保存
```bash
./nanookjaro-cli --headless --interval 5 --output /var/log/nanookjaro/logs.json
```

### 包管理
```bash
# 列出可用的包更新
./nanookjaro-cli pacman list-updates

# 升级系统
./nanookjaro-cli pacman upgrade

# 安装包
./nanookjaro-cli pacman install <包名称>
```

## 九、API（C++ shared library & JSON contract）

### 导出函数（示例）
```cpp
extern "C" const char* nj_get_system_summary();    // 返回 JSON 字符串（caller 负责复制/释放）
extern "C" const char* nj_get_cpu_info();
extern "C" const char* nj_get_memory_info();
extern "C" const char* nj_get_gpu_info();
extern "C" const char* nj_get_disk_info();
extern "C" const char* nj_pacman_list_updates();
extern "C" const char* nj_pacman_sync_upgrade(int assume_yes);
extern "C" const char* nj_free_string(const char* s); // 释放由后端分配的字符串（如果需要）
```

### JSON 示例（系统摘要）
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

## 十、开发细节与实现建议

### 后端（C++）实现建议
- 目录扫描与采样：在 Linux 使用 `/proc/stat`、`/proc/meminfo`、`/sys/class/hwmon`等。
- 温度读取：优先使用系统提供的 hwmon（Linux）或 NVML（NVIDIA）/ ROCm（AMD）等供应商 SDK。
- GPU 支持：集成 NVIDIA NVML（NVIDIA）、AMD ADL 或 ROCm API（如可用），并为不支持的设备降级为驱动版本展示。
- 包操作：对安装/升级操作需严格要求用户确认并记录日志；Linux 使用包管理器调用（pacman/apt/dnf）。
- 线程模型：将采样任务放在后台线程，使用锁或原子操作保护环形缓冲区，减少主线程阻塞。

### 前端（Flutter）实现建议
- State 管理：建议使用 Riverpod 或 Provider 管理全局状态，避免 setState 滥用。
- UI 组件：卡片 + 仪表盘 + 折线图为主；使用 Hero/AnimatedContainer/ImplicitAnimations 制作自然过渡。
- Theme：提供 3 个主题：Light / Dark / System，且主题颜色可自定义（支持品牌化）。
- FFI 层：对每个 exported C++ 函数封装 Dart wrapper，添加超时与错误处理，避免 UI 阻塞。

## 十一、Roadmap（详细）

| 版本 | 功能点（详述） |
|------|---------------|
| v0.1.0 | - C++ core: CPU/Memory info + basic sampling<br>- Flutter UI: Dashboard + Hardware page<br>- FFI bridge + JSON contract<br>- Build scripts & CI (Linux) |
| v0.2.0 | - 增加 GPU + Disk + Network 实时监控<br>- 图表性能优化<br>- 支持 report 导出（JSON/HTML） |
| v0.3.0 | - 包管理模块（列出、备份、提示更新）<br>- CLI 工具完善 & headless 模式<br>- 初步自动化测试覆盖 |
| v1.0.0 | - 完整跨平台功能稳定版<br>- 插件系统（第三方扩展）<br>- 远程监控 / 可选云同步服务 |

## 十二、CI / Release 策略（示例）

- 使用 GitHub Actions：
  - build.yml：在 Ubuntu 上构建 C++ lib 与 Flutter 桌面包，并执行单元测试。
  - release.yml：在 push tag 时生成 release 包（AppImage）并发布到 GitHub Releases。

CI 示例片段（简化）：
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

## 十三、贡献者指南（Contributing Guide）
- fork -> feature branch -> pull request，PR 模板需包含变更说明、测试步骤、兼容性影响。
- 代码风格：C++ 使用 clang-format，Dart 使用 dartfmt。
- unit tests：C++ 使用 GoogleTest，Dart 使用 flutter_test。

## 十四、许可证（License）
MIT

## 十五、联系方式（Contact）
- 项目组织：Nanookjaro Project / **polarours**
- GitHub: `https://github.com/polarours/Nanookjaro-Toolkit` (建议创建)
- Issues: 使用 GitHub Issues 跟踪 bug 与 feature request

## 十六、附录（示例命令、调试与常见问题）
### 常见调试命令（Linux）
- 检查 CPU 信息：`lscpu`
- 检查 GPU：`lspci | grep -i vga`、`nvidia-smi`
- 检查温度：`sensors`（需要 lm-sensors）
- SMART 检查：`smartctl -a /dev/sda`

### 常见问题
- Q: 为什么在某些设备上看不到 GPU 温度？  
  A: 设备可能不暴露 hwmon 数据，或需要供应商 SDK（如 NVIDIA NVML）。