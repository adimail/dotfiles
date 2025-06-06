#!/bin/bash

DEST_DIR=$(pwd)

DEST_NEOFETCH_DIR="$DEST_DIR/neofetch"
DEST_NVIM_DIR="$DEST_DIR/nvim"
DEST_TMUX_DIR="$DEST_DIR/tmux"
DEST_ZSH_DIR="$DEST_DIR/zsh"
DEST_HTOP_DIR="$DEST_DIR/htop"
DEST_SCRIPTS_DIR="$DEST_DIR/scripts"
DEST_GHOSTTY_DIR="$DEST_DIR/ghostty"
DEST_CLANGD_DIR="$DEST_DIR/cland"
DEST_GIT_DIR="$DEST_DIR/git"
DEST_LAZYFFMPEG_DIR="$DEST_DIR/scripts/.lazyffmpeg"

DEST_PROGRAMMINGSETUP_DIR="$DEST_DIR/programmingsetup"
DEST_CODEFORCES_DIR="$DEST_PROGRAMMINGSETUP_DIR/codeforces"
DEST_LEETCODE_DIR="$DEST_PROGRAMMINGSETUP_DIR/leetcode"

mkdir -p "$DEST_NEOFETCH_DIR" "$DEST_NVIM_DIR" "$DEST_TMUX_DIR" "$DEST_ZSH_DIR" "$DEST_HTOP_DIR" "$DEST_SCRIPTS_DIR" "$DEST_GHOSTTY_DIR" "$DEST_CLANGD_DIR" "$DEST_GIT_DIR" "$DEST_CODEFORCES_DIR" "$DEST_LEETCODE_DIR"

SOURCE_ZSHRC="$HOME/.zshrc"
SOURCE_NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
SOURCE_NVIM_CONFIG_DIR="$HOME/.config/nvim"
SOURCE_TMUX_CONF="$HOME/.tmux/.tmux.conf"
SOURCE_HTOPRC="$HOME/.config/htop/htoprc"
SOURCE_SCRIPTS_DIR="$HOME/scripts"
SOURCE_GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
SOURCE_CLANGD="$HOME/.clangd"
SOURCE_FORMAT_CLANGD="$HOME/.clang-format"
SOURCE_GIT_CONFIG_DIR="$HOME/.config/git"
SOURCE_LAZYFFMPEG_CONFIG_DIR="$HOME/.lazyffmpeg/"

# Programming setup sources
SOURCE_NEWCF="$HOME/personal/cf/newcf"
SOURCE_GITIGNORE="$HOME/personal/cf/.gitignore"
SOURCE_TEMPLATES_CODEFORCES="$HOME/personal/cf/templates"
SOURCE_LC_NEW="$HOME/personal/lc/new"
SOURCE_TEMPLATES_LEETCODE="$HOME/personal/lc/templates"

# Function to copy file and show diff
copy_and_log() {
	local source=$1
	local destination=$2
	if [ -e "$source" ]; then
		if [ ! -e "$destination" ] || ! cmp -s "$source" "$destination"; then
			cp "$source" "$destination"
			echo "Copied: $source → $destination"
			git diff --no-index "$destination" "$source" | sed 's/^/    /'
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

copy_and_log "$SOURCE_ZSHRC" "$DEST_ZSH_DIR/.zshrc"
copy_and_log "$SOURCE_NEOFETCH_CONFIG" "$DEST_NEOFETCH_DIR/config.conf"
copy_dir_and_log "$SOURCE_NVIM_CONFIG_DIR" "$DEST_NVIM_DIR"
copy_and_log "$SOURCE_TMUX_CONF" "$DEST_TMUX_DIR/.tmux.conf"
copy_and_log "$SOURCE_HTOPRC" "$DEST_HTOP_DIR/htoprc"
copy_dir_and_log "$SOURCE_SCRIPTS_DIR" "$DEST_SCRIPTS_DIR"
copy_and_log "$SOURCE_GHOSTTY_CONFIG" "$DEST_GHOSTTY_DIR/config"
copy_and_log "$SOURCE_CLANGD" "$DEST_CLANGD_DIR/.clangd"
copy_and_log "$SOURCE_FORMAT_CLANGD" "$DEST_CLANGD_DIR/.clang-format"
copy_dir_and_log "$SOURCE_GIT_CONFIG_DIR" "$DEST_GIT_DIR"
copy_dir_and_log "$SOURCE_LAZYFFMPEG_CONFIG_DIR" "$DEST_LAZYFFMPEG_DIR"

######################################
# Codeforces Setup
######################################
copy_and_log "$SOURCE_NEWCF" "$DEST_CODEFORCES_DIR/newcf"
copy_and_log "$SOURCE_GITIGNORE" "$DEST_CODEFORCES_DIR/.gitignore"
copy_dir_and_log "$SOURCE_TEMPLATES_CODEFORCES" "$DEST_CODEFORCES_DIR/templates"

######################################
# Leetcode Setup
######################################
copy_and_log "$SOURCE_LC_NEW" "$DEST_LEETCODE_DIR/new"
copy_dir_and_log "$SOURCE_TEMPLATES_LEETCODE" "$DEST_LEETCODE_DIR/templates"
echo ""
echo "All configuration files and programming setup files have been processed."
