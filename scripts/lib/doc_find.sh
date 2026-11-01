#!/usr/bin/env bash

doc_find_and_copy() {
	local search_paths=("$@")
	local valid_paths=()

	for path_entry in "${search_paths[@]}"; do
		[[ -d "$path_entry" ]] && valid_paths+=("$path_entry")
	done

	if [[ ${#valid_paths[@]} -eq 0 ]]; then
		echo "Error: None of the search paths exist." >&2
		exit 1
	fi

	local list_cmd="find \"${valid_paths[@]}\" -type f -name \"*.md\" 2>/dev/null | sort"
	local name_cmd="find \"${valid_paths[@]}\" -type f -name \"*.md\" 2>/dev/null | grep -iF -- {q} | sort"

	local content_cmd
	if command -v rg >/dev/null 2>&1; then
		content_cmd="rg -l -i -F --glob \"*.md\" -- {q} \"${valid_paths[@]}\" 2>/dev/null | sort"
	else
		content_cmd="grep -rliF --include=\"*.md\" -- {q} \"${valid_paths[@]}\" 2>/dev/null | sort"
	fi

	local search_cmd="( $name_cmd; $content_cmd ) | awk '!seen[\$0]++'"

	local preview_cmd
	if command -v bat >/dev/null 2>&1; then
		preview_cmd="bat --style=plain --color=always --language=md {}"
	else
		preview_cmd="cat {}"
	fi

	local selected
	selected=$(
		eval "$list_cmd" |
		fzf \
			--disabled \
			--ansi \
			--prompt='search name, then content > ' \
			--bind "change:reload:if [ -z {q} ]; then $list_cmd; else $search_cmd; fi || true" \
			--preview "$preview_cmd" \
			--preview-window=right:60%:wrap
	)

	[[ -z "$selected" ]] && exit 0

	if [[ ! -f "$selected" ]]; then
		echo "Error: File $selected does not exist" >&2
		exit 1
	fi

	if [[ "$OSTYPE" == "darwin"* ]]; then
		pbcopy < "$selected"
	elif [[ -n "$WAYLAND_DISPLAY" ]]; then
		wl-copy < "$selected"
	elif [[ -n "$DISPLAY" ]]; then
		xclip -selection clipboard < "$selected"
	else
		echo "Error: No clipboard utility detected" >&2
		exit 1
	fi
}
