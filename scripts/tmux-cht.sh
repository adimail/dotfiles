#!/usr/bin/env bash

source "$HOME/scripts/config.sh"
source "$HOME/scripts/lib/input.sh"

selected=$(cat "$CHT_LANGUAGES" "$CHT_COMMANDS" | fzf)
[[ -z "$selected" ]] && exit 0

prompt_input "Enter Query: " query

if grep -qs "$selected" "$CHT_LANGUAGES"; then
	query=$(echo "$query" | tr ' ' '+')
	tmux neww bash -c "curl cht.sh/$selected/$query; echo 'Press Enter to close'; read; tmux kill-window"
else
	tmux neww bash -c "curl -s cht.sh/$selected~$query | less; tmux kill-window"
fi
