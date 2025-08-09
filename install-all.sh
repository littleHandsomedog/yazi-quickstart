#!/bin/bash

set -euo pipefail

# 检查是否使用 sudo 启动脚本
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 启动此脚本。"
    exit 1
fi

# 依次执行所有安装和配置脚本
bash setup-yazi.sh
bash setup-yazi-config.sh
bash setup-yazi-theme.sh
bash setup-yazi-yy.sh

echo "所有Yazi相关脚本已执行完毕！"
