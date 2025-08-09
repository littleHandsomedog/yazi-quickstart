#!/bin/bash

set -euo pipefail

# 目标配置路径
CONFIG_DIR="${HOME}/.config/yazi"

TOML_FILE="${CONFIG_DIR}/yazi.toml"
LUA_FILE="${CONFIG_DIR}/init.lua"
# 创建目录
mkdir -p "${CONFIG_DIR}"

# 写入配置（覆盖写入）
cat > "${TOML_FILE}" << 'EOF'
# yazi.toml
[mgr]
show_hidden = true # 默认显示隐藏文件
linemode = "size_and_mtime" # 显示文件大小和修改时间
EOF

echo "已创建/更新: ${TOML_FILE}"

# 写入配置（覆盖写入）
cat > "${LUA_FILE}" << 'EOF'
-- init.lua
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
EOF

echo "已创建/更新: ${LUA_FILE}"