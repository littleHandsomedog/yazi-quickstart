#!/bin/bash

# Strict error handling
set -euo pipefail

# Error handler function
error_exit() {
	echo "Error: $1" >&2
	exit 1
}

# Check for required commands
check_dependencies() {
	local missing_deps=()
	
	if ! command -v whiptail >/dev/null 2>&1; then
		missing_deps+=("whiptail")
	fi
	
	if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
		missing_deps+=("curl or wget")
	fi
	
	if ! command -v unzip >/dev/null 2>&1; then
		missing_deps+=("unzip")
	fi
	
	if [ ${#missing_deps[@]} -gt 0 ]; then
		echo "Error: Missing required dependencies: ${missing_deps[*]}"
		echo ""
		echo "To install on Ubuntu/Debian:"
		echo "  sudo apt install whiptail curl unzip"
		exit 1
	fi
}

# Check dependencies before proceeding
check_dependencies

CHOICE=$(whiptail --title "Menu Select" --menu "Please select an option" 15 60 4 \
	"1." "Install all (yazi theme function)" \
	"2." "Install yazi and configure yy wrapper function" \
	"3." "Only install yazi" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus != 0 ]; then
	exit 1
fi

# Get the current directory
CURRENT_DIR=$(pwd)

# The URL of the ZIP file to download
URL="https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-gnu.zip"

# ZIP file name extracted from the URL
FILENAME="${URL##*/}"

TARGET_FILE="$CURRENT_DIR/$FILENAME"

# Check if the file already exists
if [ -f "$TARGET_FILE" ]; then
	echo "File already exists: $TARGET_FILE"
	echo "Skipping download."
else
	# Download the ZIP file to the current directory
	echo "Downloading $FILENAME "

	if command -v curl >/dev/null 2>&1; then
		if ! curl -L -o "$TARGET_FILE" "$URL"; then
			error_exit "Download failed with curl. Please check your network or the URL."
		fi
	elif command -v wget >/dev/null 2>&1; then
		if ! wget -O "$TARGET_FILE" "$URL"; then
			error_exit "Download failed with wget. Please check your network or the URL."
		fi
	else
		error_exit "Neither curl nor wget is installed"
	fi

	echo "Download successful: $TARGET_FILE"
fi

EXPECTED_DIR_NAME=$(basename "$FILENAME" .zip)
TARGET_UNZIPPED_DIR="$CURRENT_DIR/$EXPECTED_DIR_NAME"

if [ -d "$TARGET_UNZIPPED_DIR" ]; then
	echo "Target directory already exists: $TARGET_UNZIPPED_DIR"
	echo "Skipping unzip to avoid overwriting existing files."
else
	# Unzip the file to the current directory
	echo "Unzipping: $FILENAME"
	
	if ! unzip -q "$TARGET_FILE" -d "$CURRENT_DIR/"; then
		error_exit "Unzip failed. The file may be corrupted."
	fi
	
	echo "Unzip successful! Files have been extracted to: $CURRENT_DIR"
fi

YAZI_PATH="$CURRENT_DIR/yazi-x86_64-unknown-linux-gnu/yazi"
YA_PATH="$CURRENT_DIR/yazi-x86_64-unknown-linux-gnu/ya"

# Verify extracted files exist
if [ ! -f "$YAZI_PATH" ]; then
	error_exit "yazi binary not found at: $YAZI_PATH"
fi

if [ ! -f "$YA_PATH" ]; then
	error_exit "ya binary not found at: $YA_PATH"
fi

# Create ~/.local/bin directory if it doesn't exist
if ! mkdir -p "$HOME/.local/bin"; then
	error_exit "Failed to create directory: $HOME/.local/bin"
fi

# Copy files to ~/.local/bin
if cp "$YAZI_PATH" "$HOME/.local/bin/yazi"; then
	echo "Copied file: $HOME/.local/bin/yazi"
else
	echo "Error: Failed to copy yazi to $HOME/.local/bin/"
	exit 1
fi

if cp "$YA_PATH" "$HOME/.local/bin/ya"; then
	echo "Copied file: $HOME/.local/bin/ya"
else
	echo "Error: Failed to copy ya to $HOME/.local/bin/"
	exit 1
fi

# Make the files executable
chmod +x "$HOME/.local/bin/yazi"
chmod +x "$HOME/.local/bin/ya"

USER_DEFAULT_SHELL="$SHELL"

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

add_path_line() {
	local rcfile="$1"
	local path_line="$2"

	if [ -f "$rcfile" ]; then
		if grep -qF "$path_line" "$rcfile"; then
			echo "PATH line with '.local/bin' already exists in $rcfile"
		else
			printf '%s\n' "" "$path_line" "" >>"$rcfile"
			echo "PATH line added to $rcfile"
		fi
	else
		# Configuration file $rcfile does not exist, skipping PATH addition.
		echo "Configuration file $rcfile does not exist, skipping PATH addition."
	fi
}

# Function to configure shell rc file based on detected shell
configure_shell_rc() {
	local config_type="$1"  # "path" or "function"
	local rcfile=""
	
	if [[ "$USER_DEFAULT_SHELL" == *zsh ]]; then
		rcfile="$HOME/.zshrc"
		echo "Current shell detected as Zsh, adding configuration to $rcfile"
	elif [[ "$USER_DEFAULT_SHELL" == *bash ]]; then
		rcfile="$HOME/.bashrc"
		echo "Current shell detected as Bash, adding configuration to $rcfile"
	else
		echo "Error: Bash or Zsh specific variable not detected. Configuration was not added automatically for safety reasons."
		if [ "$config_type" = "path" ]; then
			echo "If needed, please manually add the following line to your shell configuration file (e.g., .bashrc or .zshrc):"
			echo "$PATH_LINE"
		else
			echo "If needed, please manually add the yy function to your shell configuration file (e.g., .bashrc or .zshrc):"
			echo "$YY_FUNC"
		fi
		return 1
	fi
	
	if [ "$config_type" = "path" ]; then
		add_path_line "$rcfile" "$PATH_LINE"
	elif [ "$config_type" = "function" ]; then
		add_func "$rcfile"
	fi
}

# Add PATH to shell configuration
configure_shell_rc "path"

if [[ $CHOICE == "1." || $CHOICE == "2." ]]; then
	# Configure yy wrapper function
	YY_FUNC='function yy() {
    local tmp=$(mktemp) cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d "" cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f "$tmp"
}'
	add_func() {
		local rcfile="$1"
		if [ -f "$rcfile" ]; then
			if grep -F "function yy()" "$rcfile" >/dev/null; then
				echo "yy function already exists in $rcfile"
			else
				printf '%s\n' "" "$YY_FUNC" "" >>"$rcfile"
				echo "yy function added to $rcfile"
			fi
		fi
	}
	# Use configure_shell_rc to add function
	configure_shell_rc "function"
fi
if [ "$CHOICE" = "1." ]; then
	# Target yazi config directory
	CONFIG_DIR="${HOME}/.config/yazi"
	# Create config directory if it doesn't exist
	if ! mkdir -p "${CONFIG_DIR}"; then
		error_exit "Failed to create config directory: ${CONFIG_DIR}"
	fi

	TOML_FILE="${CONFIG_DIR}/yazi.toml"
	LUA_FILE="${CONFIG_DIR}/init.lua"
	THEME_FILE="${CONFIG_DIR}/theme.toml"
	# Write yazi configuration file (overwrite)
	if ! cat >"${TOML_FILE}" <<'EOF'
# yazi.toml
[mgr]
show_hidden = true # Show hidden files by default
linemode = "size_and_mtime" # Show file size and modification time
EOF
	then
		error_exit "Failed to create yazi.toml"
	fi
	echo "Successfully created yazi.toml in ${CONFIG_DIR}"
	# Write yazi linemode configuration file (overwrite)
	if ! cat >"${LUA_FILE}" <<'EOF'
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
	then
		error_exit "Failed to create init.lua"
	fi

	echo "Successfully created init.lua in ${CONFIG_DIR}"
	# Install kanagawa theme
	if ! cat >"${THEME_FILE}" <<'EOF'
# theme.toml
[flavor]
dark = "kanagawa"
EOF
	then
		error_exit "Failed to create theme.toml"
	fi

	echo "Successfully created theme.toml in ${CONFIG_DIR}"

	echo "Setting yazi's default theme to: kanagawa"

	echo "Installing kanagawa theme..."

	if ya pkg add dangooddd/kanagawa; then
		echo "kanagawa theme installation complete"
	else
		echo "Warning: Failed to install kanagawa theme"
	fi
fi

# Final prompt for shell restart
echo ""
echo "✓ Installation complete!"
echo ""
echo "To apply changes, please run:"
if [[ "$USER_DEFAULT_SHELL" == *zsh ]]; then
    echo "  source ~/.zshrc"
elif [[ "$USER_DEFAULT_SHELL" == *bash ]]; then
    echo "  source ~/.bashrc"
fi
echo ""
echo "Or restart your terminal."
exit 0