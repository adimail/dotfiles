#!/bin/bash

# Define directories
DEST_DIR=$(pwd) # Current folder
NEOFETCH_DIR="$DEST_DIR/neofetch"
NVIM_DIR="$DEST_DIR/nvim"
TMUX_DIR="$DEST_DIR/tmux"
ZSH_DIR="$DEST_DIR/zsh"
HTOP_DIR="$DEST_DIR/htop"
SCRIPTS_DIR="$DEST_DIR/scripts"
GITUI_DIR="$DEST_DIR/gitui"

# Create the directories
mkdir -p "$NEOFETCH_DIR" "$NVIM_DIR" "$TMUX_DIR" "$ZSH_DIR" "$HTOP_DIR" "$SCRIPTS_DIR" "$GITUI_DIR"

# Paths to source files
ZSHRC="$HOME/.zshrc"
NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TMUX_CONF="$HOME/.tmux.conf"
HTOPRC="$HOME/.config/htop/htoprc"
SCRIPTS_SRC_DIR="$HOME/scripts"
GITUI_SRC_DIR="$HOME/.config/gitui/"

# Copy files to their respective directories
if [ -f "$ZSHRC" ]; then
	cp "$ZSHRC" "$ZSH_DIR/"
else
	echo "Zsh configuration file not found."
fi

if [ -f "$NEOFETCH_CONFIG" ]; then
	cp "$NEOFETCH_CONFIG" "$NEOFETCH_DIR/"
else
	echo "Neofetch configuration file not found."
fi

if [ -d "$NVIM_CONFIG_DIR" ]; then
	cp -r "$NVIM_CONFIG_DIR"/* "$NVIM_DIR/"
else
	echo "Neovim configuration directory not found."
fi

if [ -f "$TMUX_CONF" ]; then
	cp "$TMUX_CONF" "$TMUX_DIR/"
else
	echo "Tmux configuration file not found."
fi

if [ -f "$HTOPRC" ]; then
	cp "$HTOPRC" "$HTOP_DIR/"
else
	echo "Htop configuration file not found."
fi

if [ -d "$SCRIPTS_SRC_DIR" ]; then
	cp -r "$SCRIPTS_SRC_DIR"/* "$SCRIPTS_DIR/"
else
	echo "Scripts directory not found."
fi

if [ -d "$GITUI_SRC_DIR" ]; then
	cp -r "$GITUI_SRC_DIR"/* "$GITUI_DIR/"
else
	echo "GitUI configuration directory not found."
fi

echo "Configuration files and scripts have been copied into their respective directories."
