#!/bin/bash
# 自动将 yazi 包装器 yy 函数添加到 .bashrc 或 .zshrc

# 检查是否使用 sudo 启动脚本
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 启动此脚本。"
    exit 1
fi

if [ -n "$SUDO_USER" ] && [ -z "$TARGET_USER" ]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
fi

YY_FUNC='function yy() {\n\tlocal tmp="$(mktemp -t \"yazi-cwd.XXXXXX\")" cwd\n\tyazi "$@" --cwd-file="$tmp"\n\tIFS= read -r -d '' cwd < "$tmp"\n\t[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"\n\trm -f -- "$tmp"\n}'

add_func() {
	local rcfile="$1"
	if [ -f "$rcfile" ]; then
		if ! grep -q "function yy()" "$rcfile"; then
			echo -e "\n$YY_FUNC\n" >> "$rcfile"
			echo "已添加 yy 函数到 $rcfile"
			echo "请重新启动终端或运行 'source $rcfile' 以使更改生效。"
		else
			echo "$rcfile 已包含 yy 函数，无需重复添加。"
		fi
	fi
}

add_func "$TARGET_HOME/.bashrc"
add_func "$TARGET_HOME/.zshrc"
