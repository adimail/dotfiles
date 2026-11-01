#!/bin/bash
# Usage: ./sizes.sh          (top 15 per section)
#        TOP_N=30 ./sizes.sh (show more rows)

set -u

TOP_N="${TOP_N:-15}"
TMP="$(mktemp -d)"
TTY=0; [ -t 2 ] && TTY=1

clear_line() { [ "$TTY" -eq 1 ] && printf '\r\033[K' >&2; }
trap 'clear_line; rm -rf "$TMP"' EXIT
trap 'exit 130' INT TERM

SECTIONS=(
  "Library|$HOME/Library"
  "Application Support|$HOME/Library/Application Support"
  "Containers|$HOME/Library/Containers"
  "Group Containers|$HOME/Library/Group Containers"
  "Caches|$HOME/Library/Caches"
  "Applications|/Applications"
  "Downloads|$HOME/Downloads"
  "Desktop|$HOME/Desktop"
  "Documents|$HOME/Documents"
)

progress() {  # current total label
  [ "$TTY" -eq 1 ] || return 0
  local n=$1 total=$2 label=$3 w=28 pct filled bar
  pct=$(( total > 0 ? n * 100 / total : 100 ))
  filled=$(( pct * w / 100 ))
  bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' $((w - filled)) '' | tr ' ' '-')"
  printf '\r\033[K[%s] %3d%%  (%d/%d)  %.45s' "$bar" "$pct" "$n" "$total" "$label" >&2
}

scan() {  # index label path
  local idx=$1 label=$2 path=$3 out="$TMP/out" sorted="$TMP/sorted"
  local total n=0 item name kb

  if [ ! -d "$path" ]; then
    printf '\n===== %s =====\nNot found: %s\n' "$label" "$path"
    return 0
  fi

  : > "$out"
  total=$(find "$path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')

  while IFS= read -r -d '' item; do
    n=$((n + 1))
    name="${item##*/}"
    progress "$n" "$total" "[${idx}/${#SECTIONS[@]}] ${label}: ${name}"
    kb=$(du -sk "$item" 2>/dev/null | awk '{print $1}')
    printf '%s\t%s\n' "${kb:-0}" "$name" >> "$out"
  done < <(find "$path" -mindepth 1 -maxdepth 1 -print0 2>/dev/null)

  clear_line
  sort -t "$(printf '\t')" -k1,1nr "$out" > "$sorted"

  printf '\n===== %s  (%s) =====\n' "$label" "$path"
  awk -F'\t' -v top="$TOP_N" '
    function human(kb,   s, i, u) {
      split("KB MB GB TB", u, " "); s = kb; i = 1
      while (s >= 1024 && i < 4) { s /= 1024; i++ }
      return sprintf("%.1f %s", s, u[i])
    }
    { kb[NR] = $1; name[NR] = $2; sum += $1 }
    END {
      if (NR == 0) { print "(empty)"; exit }
      for (i = 1; i <= NR && i <= top; i++)
        printf "%10s  %5.1f%%  %s\n", human(kb[i]), (sum ? kb[i] * 100 / sum : 0), name[i]
      if (NR > top) printf "%10s  ......  (%d more items)\n", "", NR - top
      printf "%10s  total\n", human(sum)
    }' "$sorted"
}

i=0
for entry in "${SECTIONS[@]}"; do
  i=$((i + 1))
  scan "$i" "${entry%%|*}" "${entry#*|}"
done
