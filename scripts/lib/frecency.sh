#!/usr/bin/env bash

frecency_touch() {
	local target="$1"
	if command -v zoxide >/dev/null 2>&1; then
		zoxide add "$target"
	fi
}

frecency_list() {
	if command -v zoxide >/dev/null 2>&1; then
		zoxide query -l
	fi
}

frecency_parents() {
	frecency_list | while IFS= read -r dir; do
		parent=$(dirname "$dir")
		[[ -d "$parent" ]] && echo "$parent"
	done | awk '!seen[$0]++'
}

frecency_select_dir() {
	local prompt="${1:-Select directory: }"
	{
		frecency_list
		find "${SEARCH_ROOTS[@]}" -mindepth 0 -maxdepth 1 -type d 2>/dev/null
	} | awk '!seen[$0]++' | fzf --prompt="$prompt" --scheme=path --tiebreak=index
}
