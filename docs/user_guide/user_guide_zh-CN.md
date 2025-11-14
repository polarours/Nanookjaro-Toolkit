# Nanookjaro 工具包用户指南 📘

## 简介 👋

欢迎使用 Nanookjaro 工具包，这是一款主要为 Manjaro/Arch Linux 用户设计的系统监控和管理解决方案，同时兼容大多数 Linux 发行版。这款工具包将系统管理转变为视觉愉悦且直观的体验。

本指南将引导您完成工具包的安装、配置和使用所有功能，从基本的系统监控到高级的包管理。

## 入门指南 🚀

### 系统要求 💻

在安装 Nanookjaro 工具包之前，请确保您的系统满足以下要求：

- 操作系统：
  - 主要：Manjaro Linux、Arch Linux（完整功能支持）
  - 次要：大多数 Linux 发行版（核心监控功能）
- 架构：x86_64
- 最低内存：2GB
- 磁盘空间：100MB 可用空间
- 显示：X11 或 Wayland 合成器

为了获得包括包管理在内的完整功能集，我们推荐使用基于 Arch 的发行版，如 Manjaro 或 Arch Linux。

### 安装方式 🔧

有两种方式安装 Nanookjaro 工具包：

#### 方法一：使用 AUR（推荐）🌟

如果您已安装 AUR 助手（如 yay 或 paru）：

```bash
yay -S nanookjaro-toolkit-git
# 或
paru -S nanookjaro-toolkit-git
```

#### 方法二：从源码构建 🏗️

要从源码构建，您需要这些依赖项：
- CMake 3.20+
- C++20 编译器（GCC 10+ 或 Clang 10+）
- Flutter SDK 3.0+
- pacman-contrib
- pciutils
- smartmontools

克隆仓库并构建：

```bash
git clone https://github.com/polarours/Nanookjaro-Toolkit.git
cd Nanookjaro-Toolkit
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

构建后端后，您需要构建 Flutter 前端：

```bash
cd ../frontend/flutter
flutter build linux
```

## 使用图形界面 🎨

### 启动应用程序 ▶️

安装完成后，您可以通过以下几种方式启动 Nanookjaro 工具包 GUI：

1. 从应用程序菜单：在系统或实用工具部分查找 "Nanookjaro Toolkit"
2. 从终端：
   ```bash
   nanookjaro-toolkit
   ```
3. 直接运行二进制文件（如果从源码构建）：
   ```bash
   ./frontend/flutter/build/linux/x64/release/bundle/nanookjaro_frontend
   ```

### 仪表板概述 📊

启动后，您将看到显示关键系统指标的仪表板：

- **CPU 使用率**：当前处理器利用率及每核细分
- **内存使用率**：RAM 和交换空间使用统计
- **磁盘使用率**：已挂载文件系统的存储空间使用情况
- **网络活动**：入站和出站网络流量，带实时速率
- **系统负载**：当前系统平均负载
- **GPU 信息**：检测到的显卡

### 导航 🧭

左侧边栏提供对所有部分的访问：
- 仪表板：系统指标概览
- CPU：详细的处理器信息
- 内存：全面的内存统计数据
- 存储：磁盘和文件系统详情
- 网络：网络接口信息
- GPU：显卡详情
- 包管理：包管理界面

## 系统信息视图 🔍

每个部分都提供有关该系统组件的详细信息：

#### CPU 部分 ⚙️
- 型号和规格
- 实时使用率图表
- 每核利用率
- 温度读数（如果有）

#### 内存部分 💾
- 总内存、已用内存和可用内存
- 交换空间使用情况
- 内存压力指标
- 内存使用的详细分类

#### 存储部分 💿
- 所有已挂载的文件系统
- 可用和已用空间
- 驱动器的 SMART 数据（如果有）
- 读写活动统计

#### 网络部分 🌐
- 活跃的网络接口
- IP 地址
- 带实时速率的流量统计（KB/s）
- 连接状态

#### GPU 部分 🎮
- 显卡型号
- 驱动程序信息
- 利用率统计
- 温度读数

## 包管理 📦

Nanookjaro 工具包提供与 Arch Linux 强大的包管理器 pacman 的全面集成。这是在基于 Arch 的发行版上使用 Nanookjaro 的关键优势之一。

注意：包管理功能目前仅在基于 Arch 的发行版上可用。

### 检查更新 🔍

点击侧边栏中的 "包管理" 部分查看：
- 可用更新的数量
- 可升级的包列表
- 包描述和版本

### 执行系统升级 ⬆️

升级系统：
1. 导航到包管理部分
2. 点击 "检查更新" 按钮
3. 查看可用更新列表
4. 点击 "升级系统" 开始升级过程
5. 出现提示时输入密码（需要 sudo 权限）

### 安装新包 ➕

安装新包：
1. 导航到包管理部分
2. 使用搜索栏查找包
3. 点击包旁边的 "+" 按钮标记为待安装
4. 点击 "应用更改" 安装标记的包
5. 出现提示时输入密码

## 使用命令行界面 💻

CLI 以终端友好的格式提供 GUI 的所有功能。

### 基本命令 📋

```bash
# 显示系统摘要
nanookjaro-cli

# 列出可用的包更新
nanookjaro-cli pacman list-updates

# 执行系统升级
nanookjaro-cli pacman upgrade

# 安装包
nanookjaro-cli pacman install <包名称> [<包名称>...]

# 设置代理配置
nanookjaro-cli proxy set [--http URL] [--https URL]

# 清除代理配置
nanookjaro-cli proxy clear
```

### 命令输出格式 📤

大多数命令支持多种输出格式：
- 人类可读（默认）
- JSON（`--json` 标志）

示例：
```bash
nanookjaro-cli --json | jq .
```

## 配置 ⚙️

### 代理设置 🌐

通过以下方式配置 HTTP/HTTPS 代理：
1. GUI：设置 > 代理
2. CLI：`nanookjaro-cli proxy set --http http://proxy:port --https https://proxy:port`

### 主题设置 🎨

在浅色和深色主题之间切换：
1. GUI：设置 > 外观
2. 主题将在下次启动时保存并应用

## 故障排除 ❓

### 常见问题 🔧

#### 应用程序无法启动 ❌
- 确保所有依赖项已安装
- 检查您是否在受支持的平台上运行
- 尝试从终端运行以查看错误消息

#### 包操作失败 🚫
- 验证您是否有 sudo 权限
- 检查 pacman 是否正常运行
- 确保您有活跃的互联网连接

#### 系统信息不正确 ⚠️
- 某些硬件传感器可能未被检测到
- 安装额外的工具如 lm_sensors 以获得更好的硬件监控

### 获取帮助 🆘

如需更多帮助：
1. 查看 docs/ 目录中的文档
2. 访问 GitHub 仓库查看问题和讨论
3. 通过 GitHub 联系开发团队

## 高级用法 🧠

### 自定义仪表板 🎛️

可以通过拖放将仪表板上的小部件重新排列到您喜欢的位置。

### 性能监控 📈

工具包持续监控系统性能并存储历史数据以进行趋势分析。通过相应部分访问详细的歷史数据。

### 自动化 🤖

使用 CLI 进行自动化脚本：
```bash
#!/bin/bash
# 每日系统检查脚本
nanookjaro-cli pacman list-updates > /var/log/nanookjaro-updates.log
nanookjaro-cli > /var/log/nanookjaro-system-summary.log
```

## 贡献 🤝

我们欢迎对 Nanookjaro 工具包的贡献！以下是您可以提供帮助的方式：

1. 在 GitHub 上报告错误和建议功能
2. 提交改进的拉取请求
3. 帮助翻译应用程序
4. 改进文档

### 开发环境设置 🛠️

设置开发环境：

```bash
git clone https://github.com/polarours/Nanookjaro-Toolkit.git
cd Nanookjaro-Toolkit
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```

为开发构建 Flutter 前端：

```bash
cd ../frontend/flutter
flutter run -d linux
```

## 许可证 📄

本项目采用 MIT 许可证。有关详细信息，请参见 LICENSE 文件。

## 致谢 🙏

特别感谢：
- Flutter 团队提供的优秀 UI 框架
- Arch Linux 社区提供的强大包管理系统
- 所有帮助塑造此工具包的贡献者和测试人员