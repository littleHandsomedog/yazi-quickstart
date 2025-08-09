#!/bin/bash
# 自动将 yazi 包装器 yy 函数添加到 .bashrc 或 .zshrc

YY_FUNC='function yy() {\n\tlocal tmp="$(mktemp -t \"yazi-cwd.XXXXXX\")" cwd\n\tyazi "$@" --cwd-file="$tmp"\n\tIFS= read -r -d '' cwd < "$tmp"\n\t[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"\n\trm -f -- "$tmp"\n}'

add_func() {
	local rcfile="$1"
	if [ -f "$rcfile" ]; then
		if ! grep -q "function yy()" "$rcfile"; then
			echo -e "\n$YY_FUNC\n" >> "$rcfile"
			echo "已添加 yy 函数到 $rcfile"
		else
			echo "$rcfile 已包含 yy 函数，无需重复添加。"
		fi
	fi
}

add_func "$HOME/.bashrc"
add_func "$HOME/.zshrc"
