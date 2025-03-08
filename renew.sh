#!/bin/bash

# Define destination directories
DEST_DIR=$(pwd) # Current folder
DEST_NEOFETCH_DIR="$DEST_DIR/neofetch"
DEST_NVIM_DIR="$DEST_DIR/nvim"
DEST_TMUX_DIR="$DEST_DIR/tmux"
DEST_ZSH_DIR="$DEST_DIR/zsh"
DEST_HTOP_DIR="$DEST_DIR/htop"
DEST_SCRIPTS_DIR="$DEST_DIR/scripts"
DEST_GHOSTTY_DIR="$DEST_DIR/ghostty"

# Create the destination directories
mkdir -p "$DEST_NEOFETCH_DIR" "$DEST_NVIM_DIR" "$DEST_TMUX_DIR" "$DEST_ZSH_DIR" "$DEST_HTOP_DIR" "$DEST_SCRIPTS_DIR" "$DEST_GHOSTTY_DIR"

# Define source directories and files
SOURCE_ZSHRC="$HOME/.zshrc"
SOURCE_NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
SOURCE_NVIM_CONFIG_DIR="$HOME/.config/nvim"
SOURCE_TMUX_CONF="$HOME/.tmux/.tmux.conf"
SOURCE_HTOPRC="$HOME/.config/htop/htoprc"
SOURCE_SCRIPTS_DIR="$HOME/scripts"
SOURCE_GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

# Function to copy file and show diff
copy_and_log() {
	local source=$1
	local destination=$2
	if [ -e "$source" ]; then
		if [ ! -e "$destination" ] || ! cmp -s "$source" "$destination"; then
			cp "$source" "$destination"
			echo "Copied: $source → $destination"
			git diff --no-index "$destination" "$source" | sed 's/^/    /'
		else
			echo "No changes in: $source"
		fi
	else
		echo "Source not found: $source"
	fi
}

# Function to copy directory and show diff
copy_dir_and_log() {
	local source_dir=$1
	local destination_dir=$2
	if [ -d "$source_dir" ]; then
		mkdir -p "$destination_dir"
		find "$source_dir" -type d -name ".git" -prune -o -type f -print | while IFS= read -r file; do
			local relative_path="${file#"$source_dir"/}"
			local dest_file="$destination_dir/$relative_path"
			mkdir -p "$(dirname "$dest_file")"
			copy_and_log "$file" "$dest_file"
		done
	else
		echo "Source directory not found: $source_dir"
	fi
}

# Zsh configuration
copy_and_log "$SOURCE_ZSHRC" "$DEST_ZSH_DIR/.zshrc"

# Neofetch configuration
copy_and_log "$SOURCE_NEOFETCH_CONFIG" "$DEST_NEOFETCH_DIR/config.conf"

# Neovim configuration
copy_dir_and_log "$SOURCE_NVIM_CONFIG_DIR" "$DEST_NVIM_DIR"

# Tmux configuration
copy_and_log "$SOURCE_TMUX_CONF" "$DEST_TMUX_DIR/.tmux.conf"

# Htop configuration
copy_and_log "$SOURCE_HTOPRC" "$DEST_HTOP_DIR/htoprc"

# Scripts
copy_dir_and_log "$SOURCE_SCRIPTS_DIR" "$DEST_SCRIPTS_DIR"

# Ghostty configuration
copy_and_log "$SOURCE_GHOSTTY_CONFIG" "$DEST_GHOSTTY_DIR/config"

echo "Configuration files and scripts have been processed."
