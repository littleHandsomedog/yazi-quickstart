#!/bin/bash

set -euo pipefail

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

	if command -v curl >/dev/null; then
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
if ! command -v unzip >/dev/null; then
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

mkdir -p "$HOME/.local/bin"
# 创建软链接
ln -sf "$YAZI_PATH" "$HOME/.local/bin/yazi"
ln -sf "$YA_PATH" "$HOME/.local/bin/ya"

# 确保将 ~/.local/bin 加入 PATH（在常见 shell rc 中追加）
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
add_path_line() {
	local rcfile="$1"
	# 如 rc 文件不存在则创建
	if [ ! -f "$rcfile" ]; then
		echo "$PATH_LINE" > "$rcfile"
		echo "已创建 $rcfile 并写入 PATH 设置（$HOME/.local/bin）"
		return
	fi
	# 若未包含 .local/bin 的 PATH 设置则追加
	if ! grep -qE '(^|\s)export PATH=\"\$HOME/\.local/bin:\$PATH\"' "$rcfile" \
		&& ! grep -qE '\.local/bin' "$rcfile"; then
		echo -e "\n$PATH_LINE" >> "$rcfile"
		echo "已向 $rcfile 添加 PATH 设置（$HOME/.local/bin）"
	else
		echo "$rcfile 已包含 PATH 设置，跳过。"
	fi
}

add_path_line "$HOME/.bashrc"
add_path_line "$HOME/.zshrc"

# 目标配置路径
CONFIG_DIR="${HOME}/.config/yazi"
# 创建目录
mkdir -p "${CONFIG_DIR}"

TOML_FILE="${CONFIG_DIR}/yazi.toml"
LUA_FILE="${CONFIG_DIR}/init.lua"
THEME_FILE="${CONFIG_DIR}/theme.toml"

# 写入yazi配置文件（覆盖写入）
cat >"${TOML_FILE}" <<'EOF'
# yazi.toml
[mgr]
show_hidden = true # 默认显示隐藏文件
linemode = "size_and_mtime" # 显示文件大小和修改时间
EOF

echo "已在${CONFIG_DIR}目录下创建${TOML_FILE}文件"

# 写入yazi linemode配置文件（覆盖写入）
cat >"${LUA_FILE}" <<'EOF'
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

echo "已在${CONFIG_DIR}目录下创建${LUA_FILE}文件"

# 安装yazi的 kanagawa 主题
cat >"${THEME_FILE}" <<'EOF'
# theme.toml
[flavor]
dark = "kanagawa"
EOF

echo "已在${CONFIG_DIR}目录下创建${THEME_FILE}文件"
echo "设置yazi的默认主题为:kanagawa"

echo "正在进行kanagawa主题安装..."

ya pack -a dangooddd/kanagawa

echo "kanagawa主题安装完成"

# 添加YY包装器
YY_FUNC='function yy() {\n\tlocal tmp="$(mktemp -t \"yazi-cwd.XXXXXX\")" cwd\n\tyazi "$@" --cwd-file="$tmp"\n\tIFS= read -r -d '' cwd < "$tmp"\n\t[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"\n\trm -f -- "$tmp"\n}'

add_func() {
	local rcfile="$1"
	if [ -f "$rcfile" ]; then
		if ! grep -q "function yy()" "$rcfile"; then
			echo -e "\n$YY_FUNC\n" >>"$rcfile"
			echo "已添加 yy 函数到 $rcfile"
			echo "请重新启动终端或运行 'source $rcfile' 以使更改生效。"
		else
			echo "$rcfile 已包含 yy 函数，无需重复添加。"
		fi
	fi
}

add_func "$HOME/.bashrc"
add_func "$HOME/.zshrc"

# 询问是否删除下载的压缩包
if [ -f "$TARGET_FILE" ]; then
    echo -n "是否删除下载的压缩包 $FILENAME？[y/n]: "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm "$TARGET_FILE"
        echo "已删除压缩包 $FILENAME"
    fi
fi