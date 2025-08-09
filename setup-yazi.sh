#!/bin/bash

# 检查是否使用 sudo 启动脚本
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 启动此脚本。"
    exit 1
fi

# 获取脚本执行时所在的当前目录（即用户启动脚本的目录）
CURRENT_DIR=$(pwd)

# 要下载的 ZIP 文件的 URL
URL="https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-gnu.zip"

# ZIP文件名
FILENAME="${URL##*/}"

TARGET_FILE="$CURRENT_DIR/$FILENAME"
# 检查文件是否已存在
if [ -f "$TARGET_FILE" ]; then
    echo "文件已存在：$TARGET_FILE"
    echo "跳过下载。"
else
    # 下载 ZIP 文件到当前目录
    echo "正在下载 $FILENAME "

    if command -v curl > /dev/null; then
       curl -L -o "$TARGET_FILE" "$URL"
    else
       echo "错误：系统中未安装 curl"
       exit 1
    fi

    # 检查下载是否成功
    if [ $? -ne 0 ]; then
       echo "下载失败，请检查网络或 URL 是否正确"
       exit 1
    fi

    echo "下载成功：$TARGET_FILE"
fi

# 检查是否安装 unzip
if ! command -v unzip > /dev/null; then
    echo "错误：系统未安装 unzip，请安装后重试"
    echo "Ubuntu/Debian: sudo apt install unzip"
    echo "CentOS/RHEL: sudo yum install unzip"
    exit 1
fi

# 解压文件到当前目录
echo "正在解压：$FILENAME"
unzip "$TARGET_FILE" -d "$CURRENT_DIR/"

if [ $? -eq 0 ]; then
    echo "解压成功！文件已解压到：$CURRENT_DIR"
else
    echo "解压失败，请检查文件是否损坏"
    exit 1
fi

YAZI_PATH="$CURRENT_DIR/yazi-x86_64-unknown-linux-gnu/yazi"
YA_PATH="$CURRENT_DIR/yazi-x86_64-unknown-linux-gnu/ya"

chmod +x "$YAZI_PATH"
chmod +x "$YA_PATH"

ln -sf "$YAZI_PATH" "/usr/local/bin"
ln -sf "$YA_PATH" "/usr/local/bin"

# 询问是否删除 ZIP 压缩包
echo -n "是否删除压缩包 $FILENAME？[y/n]: "
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm "$TARGET_FILE"
    echo "已删除 $FILENAME"
fi

echo "所有操作完成！"
echo "现在你可以尽情使用yazi了"



