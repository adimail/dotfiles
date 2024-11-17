#!/bin/bash

# Define destination directories
DEST_DIR=$(pwd) # Current folder
DEST_NEOFETCH_DIR="$DEST_DIR/neofetch"
DEST_NVIM_DIR="$DEST_DIR/nvim"
DEST_TMUX_DIR="$DEST_DIR/tmux"
DEST_ZSH_DIR="$DEST_DIR/zsh"
DEST_HTOP_DIR="$DEST_DIR/htop"
DEST_SCRIPTS_DIR="$DEST_DIR/scripts"

# Create the destination directories
mkdir -p "$DEST_NEOFETCH_DIR" "$DEST_NVIM_DIR" "$DEST_TMUX_DIR" "$DEST_ZSH_DIR" "$DEST_HTOP_DIR" "$DEST_SCRIPTS_DIR"

# Define source directories and files
SOURCE_ZSHRC="$HOME/.zshrc"
SOURCE_NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
SOURCE_NVIM_CONFIG_DIR="$HOME/.config/nvim"
SOURCE_TMUX_CONF="$HOME/.tmux.conf"
SOURCE_HTOPRC="$HOME/.config/htop/htoprc"
SOURCE_SCRIPTS_DIR="$HOME/scripts"

# Zsh configuration
if [ -f "$SOURCE_ZSHRC" ]; then
	cp "$SOURCE_ZSHRC" "$DEST_ZSH_DIR/"
else
	echo "Zsh configuration file not found."
fi

# Neofetch configuration
if [ -f "$SOURCE_NEOFETCH_CONFIG" ]; then
	cp "$SOURCE_NEOFETCH_CONFIG" "$DEST_NEOFETCH_DIR/"
else
	echo "Neofetch configuration file not found."
fi

# Neovim configuration
if [ -d "$SOURCE_NVIM_CONFIG_DIR" ]; then
	cp -r "$SOURCE_NVIM_CONFIG_DIR"/* "$DEST_NVIM_DIR/"
else
	echo "Neovim configuration directory not found."
fi

# Tmux configuration
if [ -f "$SOURCE_TMUX_CONF" ]; then
	cp "$SOURCE_TMUX_CONF" "$DEST_TMUX_DIR/"
else
	echo "Tmux configuration file not found."
fi

# Htop configuration
if [ -f "$SOURCE_HTOPRC" ]; then
	cp "$SOURCE_HTOPRC" "$DEST_HTOP_DIR/"
else
	echo "Htop configuration file not found."
fi

# Scripts
if [ -d "$SOURCE_SCRIPTS_DIR" ]; then
	cp -r "$SOURCE_SCRIPTS_DIR"/* "$DEST_SCRIPTS_DIR/"
else
	echo "Scripts directory not found."
fi

echo "Configuration files and scripts have been copied into their respective directories."
