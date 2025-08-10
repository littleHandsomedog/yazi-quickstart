# yazi-quickstart

在 Linux x86_64 环境一键下载并安装 Yazi（v25.5.31）。提供「为所有用户安装」与「为当前用户安装」两套脚本，同时附带主题与 yy 包装函数配置。

> 提示：原生 Windows 不适用，请在 WSL（如 Ubuntu）中执行这些脚本。

## 支持与前置
- 平台：Linux x86_64（glibc）/ WSL
- 依赖：bash、curl、unzip

## 仓库内脚本
- install-all-users.sh：以 root 安装，解压到当前目录并在 /usr/local/bin 下创建 yazi/ya 符号链接。
- install-current-user.sh：为当前用户安装，创建到 ~/.local/bin/yazi 与 ~/.local/bin/ya 的符号链接；写入 ~/.config/yazi 配置；通过 ya 安装 kanagawa 主题；注入 yy 函数；并确保将 ~/.local/bin 加入 PATH。
- uninstall-all-users.sh：以 root 卸载，移除 /usr/local/bin 链接并清理安装目录，可选删除压缩包。
- uninstall-current-user.sh：当前用户卸载，移除 ~/.local/bin 下链接与 ~/.config/yazi 配置，可选删除压缩包。

## 使用
在 WSL/Linux 终端进入此仓库目录：

```bash
# 为所有用户安装（需要 sudo）
chmod +x ./install-all-users.sh
sudo bash ./install-all-users.sh

# 仅为当前用户安装（无需 sudo）
chmod +x ./install-current-user.sh
bash ./install-current-user.sh
```

安装完成后验证：

```bash
yazi -V
ya -V
```

若输出版本号即为成功。

### PATH 说明（current-user）
install-current-user.sh 会自动在你的 ~/.bashrc 或 ~/.zshrc 中追加：

```
export PATH="$HOME/.local/bin:$PATH"
```

追加后请重启终端或执行：

```bash
source ~/.bashrc   # 或 source ~/.zshrc
```

### 配置与主题
install-current-user.sh 会创建以下文件：
- ~/.config/yazi/yazi.toml：显示隐藏文件与自定义行样式配置
- ~/.config/yazi/init.lua：为 linemode 提供实现
- ~/.config/yazi/theme.toml：默认主题设置为 kanagawa，并执行 `ya pack -a dangooddd/kanagawa`

### yy 便捷包装函数
install-current-user.sh 会向你的 rc 文件注入 yy 函数。退出 yazi 后，自动切换到 yazi 中的最后目录。如果 rc 文件未自动加载，请手动 source。

## 常见问题
- 未安装 unzip：
  - Ubuntu/Debian: `sudo apt install unzip`
  - CentOS/RHEL: `sudo yum install unzip`
- 符号链接已存在导致创建失败：先删除后重试。
- Windows：请在 WSL 中执行。

## 卸载
```bash
# 卸载所有用户安装
chmod +x ./uninstall-all-users.sh
sudo bash ./uninstall-all-users.sh

# 卸载当前用户安装
chmod +x ./uninstall-current-user.sh
bash ./uninstall-current-user.sh
```

## 主题资源
- Yazi 主题集合：https://github.com/yazi-rs/flavors

## 致谢
- Yazi 文件管理器：https://github.com/sxyazi/yazi
