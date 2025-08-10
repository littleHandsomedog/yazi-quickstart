# 获取当前目录
CURRENT_DIR=$(pwd)
YAZI_DIR="$CURRENT_DIR/yazi-x86_64-unknown-linux-gnu"
ZIP_FILE="$CURRENT_DIR/yazi-x86_64-unknown-linux-gnu.zip"

# 删除 yazi 目录
if [ -d "$YAZI_DIR" ]; then
    rm -rf "$YAZI_DIR"
    echo "已删除 yazi 安装目录: $YAZI_DIR"
else
    echo "未找到 yazi 安装目录，无需删除。"
fi

# 删除软链接
if [ -L "$HOME/.local/bin/yazi" ]; then
    rm -f "$HOME/.local/bin/yazi"
    echo "已删除软链接: $HOME/.local/bin/yazi"
fi
if [ -L "$HOME/.local/bin/ya" ]; then
    rm -f "$HOME/.local/bin/ya"
    echo "已删除软链接: $HOME/.local/bin/ya"
fi

# 删除配置文件夹
CONFIG_DIR="$HOME/.config/yazi"

if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "已删除配置文件夹: $CONFIG_DIR"
else
    echo "未找到配置文件夹，无需删除。"
fi

# 询问是否删除下载的压缩包
if [ -f "$ZIP_FILE" ]; then
    echo -n "是否删除下载的压缩包 $ZIP_FILE？[y/n]: "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm "$ZIP_FILE"
        echo "已删除压缩包 $ZIP_FILE"
    fi
fi

echo "yazi 已彻底卸载。"
