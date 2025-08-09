#!/bin/bash

set -euo pipefail

# 目标配置路径
CONFIG_DIR="${HOME}/.config/yazi"
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
echo "默认主题为：kanagawa"
echo "请使用ya pack -a dangooddd/kanagawa进行安装主题文件"
echo "安装完成后，以应用主题"