# Yazi Quickstart

[English](#english) | [中文](#中文)

---

## English

A quick installation script for [Yazi](https://github.com/sxyazi/yazi) - a blazing fast terminal file manager written in Rust.

### Features

- 🚀 Quick installation with interactive menu
- 🎨 Optional Kanagawa theme installation
- ⚙️ Automatic shell configuration (Bash/Zsh)
- 🔧 `yy` wrapper function for directory changing
- 📦 No root privileges required (user-level installation)
- 🧹 Complete uninstallation support

### Prerequisites

The script will check for required dependencies automatically. On Ubuntu/Debian:

```bash
sudo apt install whiptail curl unzip
```

### Installation Options

Run the installation script:

```bash
bash install-current-user-ubuntu24.04.sh
```

The script provides three installation options:

1. **Install all** - Installs yazi, configures the `yy` wrapper function, applies configuration, and installs the Kanagawa theme
2. **Install yazi and configure yy wrapper** - Installs yazi and configures the `yy` wrapper function only
3. **Only install yazi** - Minimal installation without configuration

### What Gets Installed

#### Binaries
- `~/.local/bin/yazi` - Main yazi executable
- `~/.local/bin/ya` - Yazi package manager

#### Configuration (Option 1 only)
- `~/.config/yazi/yazi.toml` - Main configuration file
- `~/.config/yazi/init.lua` - Custom linemode configuration
- `~/.config/yazi/theme.toml` - Theme configuration
- Kanagawa theme package

#### Shell Configuration
The script adds to `~/.bashrc` or `~/.zshrc`:
- PATH configuration for `~/.local/bin`
- `yy` wrapper function (Options 1 & 2)

### The `yy` Wrapper Function

The `yy` function allows you to change your shell's working directory when exiting yazi:

```bash
yy  # Launch yazi and cd to the directory you exit from
```

Without this wrapper, yazi cannot change your shell's directory since it runs in a subprocess.

### Configuration Highlights

**yazi.toml:**
- Show hidden files by default
- Display file size and modification time

**init.lua:**
- Custom linemode showing size and mtime in an elegant format

**theme.toml:**
- Uses Kanagawa dark theme for better aesthetics

### Uninstallation

Run the uninstallation script:

```bash
bash uninstall-current-user-ubuntu24.04.sh
```

Choose from three uninstallation options:

1. **Uninstall all** - Removes yazi, configuration, theme, and shell function
2. **Uninstall yazi and shell function only** - Keeps configuration files
3. **Only uninstall yazi** - Removes only the binaries

The script automatically creates backups of modified shell configuration files.

### Post-Installation

After installation, reload your shell configuration:

```bash
# For Bash
source ~/.bashrc

# For Zsh
source ~/.zshrc
```

Or simply restart your terminal.

### Usage

```bash
# Launch yazi with directory changing support
yy

# Or use yazi directly
yazi
```

### Supported Systems

- Ubuntu 24.04 (tested)
- x86_64 architecture

### License

This project is open source. See [LICENSE](LICENSE) for details.

### Creditsc

- [Yazi](https://github.com/sxyazi/yazi) - The amazing terminal file manager
- [Yazi Flavors](https://github.com/yazi-rs/flavors) - Yazi Flavors
- [Kanagawa theme](https://github.com/dangooddd/kanagawa.yazi) - Beautiful color scheme

---

## 中文

[Yazi](https://github.com/sxyazi/yazi) 的快速安装脚本 - 一个用 Rust 编写的超快终端文件管理器。

### 特性

- 🚀 交互式菜单快速安装
- 🎨 可选的 Kanagawa 主题安装
- ⚙️ 自动配置 Shell（Bash/Zsh）
- 🔧 `yy` 包装函数用于目录切换
- 📦 无需 root 权限（用户级安装）
- 🧹 完整的卸载支持

### 前置要求

脚本会自动检查必需的依赖项。在 Ubuntu/Debian 上：

```bash
sudo apt install whiptail curl unzip
```

### 安装选项

运行安装脚本：

```bash
bash install-current-user-ubuntu24.04.sh
```

脚本提供三个安装选项：

1. **全部安装** - 安装 yazi、配置 `yy` 包装函数、应用配置并安装 Kanagawa 主题
2. **安装 yazi 并配置 yy 包装函数** - 仅安装 yazi 和配置 `yy` 包装函数
3. **仅安装 yazi** - 最小化安装，不含配置

### 安装内容

#### 二进制文件
- `~/.local/bin/yazi` - 主程序可执行文件
- `~/.local/bin/ya` - Yazi 包管理器

#### 配置文件（仅选项 1）
- `~/.config/yazi/yazi.toml` - 主配置文件
- `~/.config/yazi/init.lua` - 自定义行模式配置
- `~/.config/yazi/theme.toml` - 主题配置
- Kanagawa 主题包

#### Shell 配置
脚本会添加到 `~/.bashrc` 或 `~/.zshrc`：
- `~/.local/bin` 的 PATH 配置
- `yy` 包装函数（选项 1 和 2）

### `yy` 包装函数

`yy` 函数允许你在退出 yazi 时改变 shell 的工作目录：

```bash
yy  # 启动 yazi 并 cd 到你退出时所在的目录
```

没有这个包装函数，yazi 无法改变你的 shell 目录，因为它运行在子进程中。

### 配置亮点

**yazi.toml:**
- 默认显示隐藏文件
- 显示文件大小和修改时间

**init.lua:**
- 自定义行模式，以优雅的格式显示大小和修改时间

**theme.toml:**
- 使用 Kanagawa 暗色主题以获得更好的视觉效果

### 卸载

运行卸载脚本：

```bash
bash uninstall-current-user-ubuntu24.04.sh
```

选择三个卸载选项之一：

1. **卸载全部** - 移除 yazi、配置、主题和 shell 函数
2. **仅卸载 yazi 和 shell 函数** - 保留配置文件
3. **仅卸载 yazi** - 只移除二进制文件

脚本会自动为修改的 shell 配置文件创建备份。

### 安装后

安装后，重新加载你的 shell 配置：

```bash
# 对于 Bash
source ~/.bashrc

# 对于 Zsh
source ~/.zshrc
```

或者简单地重启你的终端。

### 使用方法

```bash
# 使用支持目录切换的 yazi
yy

# 或直接使用 yazi
yazi
```

### 支持的系统

- Ubuntu 24.04
- x86_64 架构

### 许可证

本项目是开源的。详见 [LICENSE](LICENSE)。

### 致谢

- [Yazi](https://github.com/sxyazi/yazi) - 令人惊叹的终端文件管理器
- [Yazi 主题集合](https://github.com/yazi-rs/flavors) - Yazi 主题集合
- [Kanagawa 主题](https://github.com/dangooddd/kanagawa.yazi) - 漂亮的配色方案
