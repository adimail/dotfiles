#!/usr/bin/env bash
selected=$(cat ~/scripts/tmux-cht-languages ~/scripts/tmux-cht-commands | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

if grep -qs "$selected" ~/.tmux-cht-languages; then
    query=$(echo "$query" | tr ' ' '+')
    tmux neww bash -c "curl cht.sh/$selected/$query; echo 'Press Enter to close'; read; tmux kill-window"
else
    tmux neww bash -c "curl -s cht.sh/$selected~$query | less; tmux kill-window"
fi
