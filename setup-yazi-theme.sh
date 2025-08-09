#!/bin/bash

set -euo pipefail

# 检查是否使用 sudo 启动脚本
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 启动此脚本。"
    exit 1
fi

if [ -n "$SUDO_USER" ] && [ -z "$TARGET_USER" ]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
fi

# 目标配置路径
CONFIG_DIR="${TARGET_HOME}/.config/yazi"
THEME_FILE="${CONFIG_DIR}/theme.toml"
# 创建目录
mkdir -p "${CONFIG_DIR}"

# 写入配置（覆盖写入）
cat > "${THEME_FILE}" << 'EOF'
# theme.toml
[flavor]
dark = "kanagawa"
EOF

echo "已创建yazi的主题配置文件"
echo "默认主题为:kanagawa"

ya pack -a dangooddd/kanagawa

echo "kanagawa主题安装完成"