#!/usr/bin/env bash

export search_path="$HOME/personal/prompts"

if [[ ! -d "$search_path" ]]; then
	echo "Error: Directory $search_path does not exist"
	exit 1
fi

# Command that lists all files (used when the query is empty)
list_cmd='cd "$search_path" && find . -type f -name "*.md" 2>/dev/null | sed "s|^\./||" | sort'

# Command that lists files whose CONTENT matches the query
if command -v rg >/dev/null 2>&1; then
	search_cmd='cd "$search_path" && rg -l -i -F --glob "*.md" -- {q} . 2>/dev/null | sed "s|^\./||" | sort'
else
	search_cmd='cd "$search_path" && grep -rliF --include="*.md" -- {q} . 2>/dev/null | sed "s|^\./||" | sort'
fi

# Preview: whole file
if command -v bat >/dev/null 2>&1; then
	preview_cmd='bat --style=plain --color=always --language=md "$search_path"/{}'
else
	preview_cmd='cat "$search_path"/{}'
fi

selected=$(
	eval "$list_cmd" |
	fzf \
		--disabled \
		--ansi \
		--prompt='search content > ' \
		--bind "change:reload:if [ -z {q} ]; then $list_cmd; else $search_cmd; fi || true" \
		--preview "$preview_cmd" \
		--preview-window=right:60%:wrap
)

if [[ -z "$selected" ]]; then
	exit 0
fi

selected="$search_path/$selected"

if [[ ! -f "$selected" ]]; then
	echo "Error: File $selected does not exist"
	exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
	pbcopy <"$selected"
elif [[ -n "$WAYLAND_DISPLAY" ]]; then
	wl-copy <"$selected"
elif [[ -n "$DISPLAY" ]]; then
	xclip -selection clipboard <"$selected"
else
	echo "Error: No clipboard utility detected"
	exit 1
fi
