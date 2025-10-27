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
	
	if [ ${#missing_deps[@]} -gt 0 ]; then
		echo "Error: Missing required dependencies: ${missing_deps[*]}"
		echo ""
		echo "To install on Ubuntu/Debian:"
		echo "  sudo apt install whiptail"
		exit 1
	fi
}

# Check dependencies before proceeding
check_dependencies

CHOICE=$(whiptail --title "Uninstall Menu" --menu "Please select uninstall option" 15 60 4 \
	"1." "Uninstall all (yazi, config, theme, shell function)" \
	"2." "Uninstall yazi and shell function only" \
	"3." "Only uninstall yazi" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus != 0 ]; then
	exit 1
fi

# Detect user's shell
USER_DEFAULT_SHELL="$SHELL"

# Function to remove lines from shell rc file
remove_from_rc() {
	local rcfile="$1"
	local pattern="$2"
	local description="$3"
	
	if [ -f "$rcfile" ]; then
		if grep -qF "$pattern" "$rcfile"; then
			# Create a backup
			cp "$rcfile" "${rcfile}.backup.$(date +%Y%m%d%H%M%S)"
			echo "Created backup: ${rcfile}.backup.$(date +%Y%m%d%H%M%S)"
			
			# Remove the pattern
			sed -i "/$(echo "$pattern" | sed 's/[^^]/[&]/g; s/\^/\\^/g')/d" "$rcfile"
			echo "Removed $description from $rcfile"
		else
			echo "$description not found in $rcfile"
		fi
	else
		echo "Configuration file $rcfile does not exist"
	fi
}

# Function to remove yy function from shell rc file
remove_yy_function() {
	local rcfile="$1"
	
	if [ -f "$rcfile" ]; then
		if grep -qF "function yy()" "$rcfile"; then
			# Create a backup
			cp "$rcfile" "${rcfile}.backup.$(date +%Y%m%d%H%M%S)"
			echo "Created backup: ${rcfile}.backup.$(date +%Y%m%d%H%M%S)"
			
			# Remove yy function (including all lines between function yy() and closing })
			sed -i '/^function yy()/,/^}/d' "$rcfile"
			echo "Removed yy function from $rcfile"
		else
			echo "yy function not found in $rcfile"
		fi
	else
		echo "Configuration file $rcfile does not exist"
	fi
}

# Determine which rc file to use
get_rc_file() {
	if [[ "$USER_DEFAULT_SHELL" == *zsh ]]; then
		echo "$HOME/.zshrc"
	elif [[ "$USER_DEFAULT_SHELL" == *bash ]]; then
		echo "$HOME/.bashrc"
	else
		echo ""
	fi
}

# Remove yazi and ya
echo "Removing yazi and ya from ~/.local/bin/"
if [ -f "$HOME/.local/bin/yazi" ]; then
	rm -f "$HOME/.local/bin/yazi"
	echo "Removed: $HOME/.local/bin/yazi"
else
	echo "File not found: $HOME/.local/bin/yazi"
fi

if [ -f "$HOME/.local/bin/ya" ]; then
	rm -f "$HOME/.local/bin/ya"
	echo "Removed: $HOME/.local/bin/ya"
else
	echo "File not found: $HOME/.local/bin/ya"
fi

# Remove PATH configuration and yy function based on choice
if [[ $CHOICE == "1." || $CHOICE == "2." ]]; then
	RCFILE=$(get_rc_file)
	
	if [ -n "$RCFILE" ]; then
		# Remove PATH line
		remove_from_rc "$RCFILE" 'export PATH="$HOME/.local/bin:$PATH"' "PATH configuration"
		
		# Remove yy function
		remove_yy_function "$RCFILE"
	else
		echo "Warning: Could not detect shell configuration file (Bash or Zsh not detected)"
		echo "Please manually remove the following from your shell configuration:"
		echo "  - export PATH=\"\$HOME/.local/bin:\$PATH\""
		echo "  - function yy() { ... }"
	fi
fi

# Remove yazi configuration directory based on choice
if [ "$CHOICE" = "1." ]; then
	CONFIG_DIR="${HOME}/.config/yazi"
	
	if [ -d "$CONFIG_DIR" ]; then
		# Ask for confirmation before removing config
		if whiptail --title "Confirm Removal" --yesno "Remove yazi configuration directory?\n\n$CONFIG_DIR\n\nThis will delete all your yazi configurations, themes, and plugins." 12 60; then
			rm -rf "$CONFIG_DIR"
			echo "Removed: $CONFIG_DIR"
		else
			echo "Skipped removing configuration directory"
		fi
	else
		echo "Configuration directory not found: $CONFIG_DIR"
	fi
fi

# Final message
echo ""
echo "✓ Uninstallation complete!"
echo ""
if [[ $CHOICE == "1." || $CHOICE == "2." ]]; then
	echo "To apply shell configuration changes, please run:"
	if [[ "$USER_DEFAULT_SHELL" == *zsh ]]; then
		echo "  source ~/.zshrc"
	elif [[ "$USER_DEFAULT_SHELL" == *bash ]]; then
		echo "  source ~/.bashrc"
	fi
	echo ""
	echo "Or restart your terminal."
fi
echo ""
echo "Note: Downloaded files in $(pwd) were not removed."
echo "You can manually delete yazi-x86_64-unknown-linux-gnu.zip and yazi-x86_64-unknown-linux-gnu/ if no longer needed."
exit 0
