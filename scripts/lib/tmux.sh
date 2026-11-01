#!/usr/bin/env bash

tmux_sanitize_name() {
	basename "$1" | tr ' ' '_' | tr '.' '_'
}

tmux_hydrate() {
	local session="$1"
	local target="$2"

	if [[ -f "$target/.tmux-sessionizer" ]]; then
		tmux send-keys -t "$session" "source $target/.tmux-sessionizer" C-m
	elif [[ -f "$HOME/.tmux-sessionizer" ]]; then
		tmux send-keys -t "$session" "source $HOME/.tmux-sessionizer" C-m
	fi
}

tmux_open_or_switch() {
	local target="$1"
	local session_name
	session_name=$(tmux_sanitize_name "$target")
	local tmux_running
	tmux_running=$(pgrep tmux)

	if [[ -z "$TMUX" ]] && [[ -z "$tmux_running" ]]; then
		tmux new-session -s "$session_name" -c "$target"
		tmux_hydrate "$session_name" "$target"
		exit 0
	fi

	if ! tmux has-session -t "$session_name" 2>/dev/null; then
		tmux new-session -ds "$session_name" -c "$target"
		tmux_hydrate "$session_name" "$target"
	fi

	if [[ -z "$TMUX" ]]; then
		tmux attach-session -t "$session_name"
	else
		tmux switch-client -t "$session_name"
	fi
}
