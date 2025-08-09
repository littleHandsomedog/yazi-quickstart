# yazi-quickstart

一个极简的一键脚本，用于在 Linux x86_64 环境下载并安装 Yazi（v25.5.31）二进制包，解压后将 `yazi` 与 `ya` 通过符号链接暴露到 `/usr/local/bin`。

> 提示：本脚本面向 Linux。若在 Windows，请使用 WSL（如 Ubuntu）进入该仓库后再执行。

## 功能
- 从 GitHub Releases 下载 `yazi-x86_64-unknown-linux-gnu.zip`
- 使用 `unzip` 解压到当前目录
- 为 `yazi` 与 `ya` 赋予可执行权限
- 在 `/usr/local/bin` 下创建符号链接（需要 `sudo` 或写入权限）
- 可选删除已下载的压缩包

## 适用平台
- Linux x86_64（glibc）
- macOS 与原生 Windows 不适用；Windows 请使用 WSL 执行

## 前置依赖
- bash
- curl
- unzip
- 对 `/usr/local/bin` 的写权限（通常需要 `sudo`）

## 使用
在 Linux 或 WSL 终端中：

```bash
# 赋予脚本可执行权限
chmod +x ./setup-yazi.sh

# 以 root 权限安装到 /usr/local/bin（推荐）
sudo bash ./setup-yazi.sh
```

安装完成后可验证：

```bash
yazi -V
ya -V
```

若命令能输出版本号，即已安装成功。

### 一键安装全部（推荐）
也可以直接运行整合脚本，依次完成安装 yazi、本地配置、主题与 yy 包装函数：

```bash
chmod +x ./install-all.sh
sudo bash ./install-all.sh
```

### 创建 yazi 扩展配置文件（可选）
使用附带的脚本一键创建 `~/.config/yazi/yazi.toml`：

```bash
chmod +x ./setup-yazi-config.sh
bash ./setup-yazi-config.sh
```

写入内容如下：

```
# yazi.toml
[mgr]
show_hidden = true # 默认显示隐藏文件
linemode = "size_and_mtime" # 显示文件大小和修改时间
```

此外，脚本还会写入 `~/.config/yazi/init.lua`，为上面的 `linemode = "size_and_mtime"` 提供实现，确保自定义行样式可用。

### 安装主题（可选）
使用脚本设置默认主题为 `kanagawa`，并通过 `ya pack` 安装对应主题包：

```bash
chmod +x ./setup-yazi-theme.sh
bash ./setup-yazi-theme.sh
```

该脚本会写入 `~/.config/yazi/theme.toml`，并执行 `ya pack -a dangooddd/kanagawa`。如需更换主题，可修改 `theme.toml` 的 `flavor.dark` 或重新执行脚本并调整命令。

### 添加 yy 快捷函数（可选）
`yy` 是一个便捷包装函数：退出 yazi 后，会自动 `cd` 到 yazi 中最后停留的目录。运行脚本将其注入 `~/.bashrc` 与/或 `~/.zshrc`：

```bash
chmod +x ./setup-yazi-yy.sh
bash ./setup-yazi-yy.sh
```

注：如果你的 shell 未加载对应 rc 文件，请手动 `source ~/.bashrc` 或 `source ~/.zshrc`。

## 安装位置与目录结构
- 解压目录：`./yazi-x86_64-unknown-linux-gnu/`
  - 可执行文件：`yazi`、`ya`
- 系统级链接：`/usr/local/bin/yazi`、`/usr/local/bin/ya`

## 常见问题
- 提示未安装 unzip：请先安装
  - Ubuntu/Debian: `sudo apt install unzip`
  - CentOS/RHEL: `sudo yum install unzip`
- 没有权限写入 `/usr/local/bin`：在执行脚本时使用 `sudo`。
- `ln: failed to create symbolic link ... File exists`：说明已存在同名链接或文件，可按需先删除
  ```bash
  sudo rm -f /usr/local/bin/yazi /usr/local/bin/ya
  ```
- Windows 环境：请在 WSL（Ubuntu 等）内进入仓库路径再执行脚本。


## 升级/更换版本
当前脚本固定下载 `v25.5.31`。如需更换版本，可编辑 `setup-yazi.sh` 中的 `URL`，改为目标版本的 Release 下载链接，然后重新执行脚本。

如遇已存在的符号链接，请先移除再安装：

```bash
sudo rm -f /usr/local/bin/yazi /usr/local/bin/ya
sudo bash ./setup-yazi.sh
```

## 卸载
有两种方式可卸载：

- 使用脚本（会删除链接、安装目录与配置目录，并可选择删除压缩包）：
  ```bash
  chmod +x ./remove-yazi.sh
  sudo bash ./remove-yazi.sh
  ```
- 手动卸载：
  ```bash
  sudo rm -f /usr/local/bin/yazi /usr/local/bin/ya
  rm -rf ./yazi-x86_64-unknown-linux-gnu
  ```
## 主题

- [Yazi 主题](https://github.com/yazi-rs/flavors)

## 致谢
- [Yazi 文件管理器](https://github.com/sxyazi/yazi)
