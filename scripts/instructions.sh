#!/usr/bin/env bash

# Define the search path for .md files
search_path="$HOME/personal/instructions"

# Check if the directory exists
if [[ ! -d "$search_path" ]]; then
	echo "Error: Directory $search_path does not exist"
	exit 1
fi

# Find all .md files and use fzf to select one with preview
selected=$(find "$search_path" -type f -name "*.md" 2>/dev/null | fzf --preview 'bat --style=numbers --color=always {}' --preview-window=right:60%:wrap)

# Exit if no file was selected
if [[ -z "$selected" ]]; then
	exit 0
fi

# Check if the file exists
if [[ ! -f "$selected" ]]; then
	echo "Error: File $selected does not exist"
	exit 1
fi

# Copy the content to clipboard based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
	# macOS
	cat "$selected" | pbcopy
elif [[ -n "$WAYLAND_DISPLAY" ]]; then
	# Wayland
	cat "$selected" | wl-copy
elif [[ -n "$DISPLAY" ]]; then
	# X11
	cat "$selected" | xclip -selection clipboard
else
	echo "Error: No clipboard utility detected"
	exit 1
fi
