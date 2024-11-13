#!/bin/bash

# Define directories
DEST_DIR=$(pwd) # Current folder
NEOFETCH_DIR="$DEST_DIR/neofetch"
NVIM_DIR="$DEST_DIR/nvim"
TMUX_DIR="$DEST_DIR/tmux"
ZSH_DIR="$DEST_DIR/zsh"
HTOP_DIR="$DEST_DIR/htop"

# Create the directories
mkdir -p "$NEOFETCH_DIR" "$NVIM_DIR" "$TMUX_DIR" "$ZSH_DIR" "$HTOP_DIR"

# Paths to source files
ZSHRC="$HOME/.zshrc"
NEOFETCH_CONFIG="$HOME/.config/neofetch/config.conf"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TMUX_CONF="$HOME/.tmux.conf"
HTOPRC="$HOME/.config/htop/htoprc"

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

echo "Configuration files have been copied into their respective directories."
