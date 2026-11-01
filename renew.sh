#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"

DRY_RUN=0

ENTRIES=(
	"file|$HOME/.zshrc|zsh/.zshrc"
	"file|$HOME/.config/neofetch/config.conf|neofetch/config.conf"
	"dir|$HOME/.config/nvim|nvim"
	"file|$HOME/.tmux/.tmux.conf|tmux/.tmux.conf"
	"file|$HOME/.config/htop/htoprc|htop/htoprc"
	"dir|$HOME/scripts|scripts"
	"file|$HOME/.config/ghostty/config|ghostty/config"
	"file|$HOME/.clangd|clangd/.clangd"
	"file|$HOME/.clang-format|clangd/.clang-format"
	"dir|$HOME/.config/git|git"
	"dir|$HOME/.lazyffmpeg|lazyffmpeg"
	"file|$HOME/personal/cf/newcf|programmingsetup/codeforces/newcf"
	"file|$HOME/personal/cf/.gitignore|programmingsetup/codeforces/.gitignore"
	"dir|$HOME/personal/cf/templates|programmingsetup/codeforces/templates"
	"file|$HOME/personal/lc/new|programmingsetup/leetcode/new"
	"dir|$HOME/personal/lc/templates|programmingsetup/leetcode/templates"
	"dir|$HOME/personal/instructions|llm/instructions"
	"dir|$HOME/personal/prompts|llm/prompts"
)

RSYNC_EXCLUDES=(
	".git"
	".DS_Store"
	".env"
	".env.*"
	"*.pem"
	"*.key"
	"id_rsa*"
	"id_ed25519*"
	"credentials*"
	"*.secret"
	"*.token"
)

WARNINGS=0

log() {
	printf '%s\n' "$*"
}

warn() {
	WARNINGS=$((WARNINGS + 1))
	printf 'Warning: %s\n' "$*" >&2
}

die() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}

usage() {
	log "Usage: $(basename "$0") [--dry-run] [--help]"
	log ""
	log "  --dry-run      Show what would change without touching the repo"
	log "  --help         Show this message"
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--dry-run) DRY_RUN=1 ;;
			--help) usage; exit 0 ;;
			*) usage >&2; die "Unknown option: $1" ;;
		esac
		shift
	done
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

verify_repo_root() {
	local toplevel
	toplevel="$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null)" \
		|| die "$REPO_ROOT is not inside a git repository"
	[ "$toplevel" = "$REPO_ROOT" ] \
		|| die "Script must live at the repository root ($toplevel), found in $REPO_ROOT"
}

preflight() {
	require_command git
	require_command rsync
	require_command cmp
	verify_repo_root
}

sync_file() {
	local source=$1
	local destination="$REPO_ROOT/$2"

	if [ ! -f "$source" ]; then
		warn "Source file not found, destination left untouched: $source"
		return 0
	fi

	if [ -f "$destination" ] && cmp -s "$source" "$destination"; then
		return 0
	fi

	if [ "$DRY_RUN" -eq 1 ]; then
		log "Would copy: $source -> $destination"
		return 0
	fi

	mkdir -p "$(dirname "$destination")"
	cp "$source" "$destination"
}

dir_has_content() {
	[ -n "$(find "$1" -mindepth 1 -maxdepth 1 -print -quit)" ]
}

sync_dir() {
	local source=$1
	local destination="$REPO_ROOT/$2"
	local -a flags=(-a --delete)
	local pattern

	if [ ! -d "$source" ]; then
		warn "Source directory not found, destination left untouched: $source"
		return 0
	fi

	if ! dir_has_content "$source"; then
		warn "Source directory is empty, skipping to protect destination: $source"
		return 0
	fi

	for pattern in "${RSYNC_EXCLUDES[@]}"; do
		flags+=(--exclude "$pattern")
	done

	if [ "$DRY_RUN" -eq 1 ]; then
		flags+=(--dry-run -v)
		rsync "${flags[@]}" "$source/" "$destination/"
		return 0
	fi

	mkdir -p "$destination"
	rsync "${flags[@]}" "$source/" "$destination/" >/dev/null
}

process_entry() {
	local kind source destination
	IFS='|' read -r kind source destination <<<"$1"

	case "$kind" in
		file) sync_file "$source" "$destination" ;;
		dir) sync_dir "$source" "$destination" ;;
		*) die "Invalid entry kind '$kind' in: $1" ;;
	esac
}

process_all_entries() {
	local entry
	for entry in "${ENTRIES[@]}"; do
		process_entry "$entry"
	done
}

report() {
	if [ "$DRY_RUN" -eq 1 ]; then
		log "Dry run complete. No files were changed."
		return 0
	fi

	local -a added_files=()
	local -a modified_files=()
	local -a deleted_files=()

	while IFS= read -r line; do
		local status="${line:0:2}"
		local file="${line:3}"
		file="${file#\"}"
		file="${file%\"}"
		if [[ "$status" =~ [A\?] ]]; then
			added_files+=("$file")
		elif [[ "$status" =~ D ]]; then
			deleted_files+=("$file")
		elif [[ "$status" =~ [MR] ]]; then
			modified_files+=("$file")
		fi
	done < <(git -C "$REPO_ROOT" status --porcelain -uall 2>/dev/null)

	local total=$((${#added_files[@]} + ${#modified_files[@]} + ${#deleted_files[@]}))
	if [ "$total" -eq 0 ]; then
		log "Sync complete: no changes."
		return 0
	fi

	log "Sync complete: ${#added_files[@]} added, ${#modified_files[@]} modified, ${#deleted_files[@]} deleted."
	log ""

	if [ "${#added_files[@]}" -gt 0 ]; then
		log "Added:"
		for file in "${added_files[@]}"; do
			log "  + $file"
		done
	fi

	if [ "${#modified_files[@]}" -gt 0 ]; then
		[ "${#added_files[@]}" -gt 0 ] && log ""
		log "Modified:"
		for file in "${modified_files[@]}"; do
			log "  ~ $file"
		done
	fi

	if [ "${#deleted_files[@]}" -gt 0 ]; then
		{ [ "${#added_files[@]}" -gt 0 ] || [ "${#modified_files[@]}" -gt 0 ]; } && log ""
		log "Deleted:"
		for file in "${deleted_files[@]}"; do
			log "  - $file"
		done
	fi

	if [ "$WARNINGS" -gt 0 ]; then
		log ""
		log "Finished with $WARNINGS warning(s)."
	fi
}

main() {
	parse_args "$@"
	preflight
	process_all_entries
	report
}

main "$@"
