#!/bin/bash
# =============================================================================
# pkg-audit.sh  -  READ-ONLY inventory of Homebrew + Python packages on macOS
#
# This script only LISTS things. It never installs, upgrades or removes anything.
#
# Usage:
#   chmod +x pkg-audit.sh
#   ./pkg-audit.sh                 # print report
#   ./pkg-audit.sh | less -R       # scroll through it
#   ./pkg-audit.sh > report.txt    # save to a file (colours switch off automatically)
#
# How to read the report:
#   Homebrew "Top-level" (leaf) = things YOU asked for; nothing else depends on them.
#                                 These are the safest candidates to review for removal.
#   Homebrew "Dependencies"     = pulled in by other packages; see REQUIRED BY column.
#                                 Removing these will break the packages that need them.
#   Python "Top-level"          = installed packages that no other package requires.
#   Python "Dependencies"       = required by something else (see REQUIRED BY).
# =============================================================================

set -u
TAB=$'\t'

# ---- colours (only when printing to a terminal) -----------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; CYAN=$'\033[36m'; YEL=$'\033[33m'; RST=$'\033[0m'
else
  BOLD=""; DIM=""; CYAN=""; YEL=""; RST=""
fi

# ---- helpers ----------------------------------------------------------------
line() { printf '%*s\n' 100 '' | tr ' ' '='; }

section() {
  echo
  line
  printf '%s%s%s\n' "$BOLD$CYAN" "$1" "$RST"
  line
}

sub() { printf '\n%s%s%s\n' "$BOLD$YEL" "$1" "$RST"; }

human_kb() {  # human_kb <kilobytes>
  awk -v k="${1:-0}" 'BEGIN{
    if (k >= 1048576)      printf "%.1f GB", k/1048576;
    else if (k >= 1024)    printf "%.1f MB", k/1024;
    else                   printf "%d KB", k }'
}

# table "<HEADER1<TAB>HEADER2...>" <size_col_index or 0>   (rows come from stdin, TAB separated)
# The size column must contain kilobytes; it is converted to KB/MB/GB and right-aligned.
table() {
  awk -F'\t' -v hdr="$1" -v sc="$2" -v B="$BOLD" -v D="$DIM" -v R="$RST" '
  function human(k) {
    if (k >= 1048576) return sprintf("%.1f GB", k/1048576);
    if (k >= 1024)    return sprintf("%.1f MB", k/1024);
    return sprintf("%d KB", k);
  }
  BEGIN {
    nh = split(hdr, H, "\t");
    W = 60;
    for (i = 1; i <= nh; i++) w[i] = length(H[i]);
  }
  {
    n = NR;
    for (i = 1; i <= nh; i++) {
      v = $i;
      if (i == sc) v = human(v + 0);
      if (i == nh && length(v) > W) v = substr(v, 1, W - 3) "...";
      c[NR, i] = v;
      if (length(v) > w[i]) w[i] = length(v);
    }
  }
  END {
    if (n == 0) { print "  (none)"; exit }
    printf "  %s", B;
    for (i = 1; i <= nh; i++) {
      if (i == sc) printf "%*s  ", w[i], H[i]; else printf "%-*s  ", w[i], H[i];
    }
    printf "%s\n  %s", R, D;
    for (i = 1; i <= nh; i++) {
      s = ""; for (j = 0; j < w[i]; j++) s = s "-";
      printf "%s  ", s;
    }
    printf "%s\n", R;
    for (r = 1; r <= n; r++) {
      printf "  ";
      for (i = 1; i <= nh; i++) {
        if (i == sc) printf "%*s  ", w[i], c[r, i]; else printf "%-*s  ", w[i], c[r, i];
      }
      printf "\n";
    }
    printf "  %s%d item(s)%s\n", D, n, R;
  }'
}

# =============================================================================
# HEADER
# =============================================================================
echo
printf '%s PACKAGE AUDIT (read-only) %s\n' "$BOLD" "$RST"
echo "  Generated : $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Machine   : $(sw_vers -productName 2>/dev/null) $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"

# =============================================================================
# HOMEBREW
# =============================================================================
section "HOMEBREW"

if ! command -v brew >/dev/null 2>&1; then
  echo "  Homebrew not found on PATH - skipping."
else
  CELLAR="$(brew --cellar)"
  CASKROOM="$(brew --caskroom)"

  LEAVES="$(brew leaves </dev/null 2>/dev/null)"
  DESCS="$(brew desc $LEAVES </dev/null 2>/dev/null)"
  REV="$(brew deps --installed --direct --for-each </dev/null 2>/dev/null | awk -F': ' '
        { n = split($2, a, " ");
          for (i = 1; i <= n; i++) r[a[i]] = r[a[i]] (r[a[i]] ? ", " : "") $1 }
        END { for (k in r) print k "\t" r[k] }')"

  N_FORMULAE=$(brew list --formula -1 </dev/null 2>/dev/null | wc -l | tr -d ' ')
  N_LEAVES=$(printf '%s\n' "$LEAVES" | grep -c .)
  N_CASKS=$(brew list --cask -1 </dev/null 2>/dev/null | wc -l | tr -d ' ')
  CELLAR_KB=$(du -sk "$CELLAR" 2>/dev/null | cut -f1)

  sub "Summary"
  echo "  Prefix               : $(brew --prefix)"
  echo "  Formulae installed   : $N_FORMULAE  (top-level: $N_LEAVES, dependencies: $((N_FORMULAE - N_LEAVES)))"
  echo "  Casks installed      : $N_CASKS"
  echo "  Disk used by formulae: $(human_kb "$CELLAR_KB")"
  echo "  Taps                 : $(brew tap </dev/null 2>/dev/null | tr '\n' ' ')"

  LEAF_ROWS=""
  DEP_ROWS=""
  while read -r name vers; do
    [ -z "$name" ] && continue
    vers="$(printf '%s' "$vers" | tr ' ' ',')"
    kb=$(du -sk "$CELLAR/$name" 2>/dev/null | cut -f1)
    kb=${kb:-0}
    case $'\n'"$LEAVES"$'\n' in
      *$'\n'"$name"$'\n'*)
        d=$(printf '%s\n' "$DESCS" | awk -F': ' -v n="$name" '$1==n { sub(/^[^:]*: /, ""); print; exit }')
        LEAF_ROWS="$LEAF_ROWS$name$TAB$vers$TAB$kb$TAB${d:--}"$'\n'
        ;;
      *)
        u=$(printf '%s\n' "$REV" | awk -F'\t' -v n="$name" '$1==n { print $2; exit }')
        DEP_ROWS="$DEP_ROWS$name$TAB$vers$TAB$kb$TAB${u:--}"$'\n'
        ;;
    esac
  done < <(brew list --formula --versions </dev/null 2>/dev/null)

  sub "Formulae - TOP-LEVEL (you installed these; nothing else needs them)  [largest first]"
  printf '%s' "$LEAF_ROWS" | grep . | sort -t "$TAB" -k3,3nr | table "NAME${TAB}VERSION${TAB}SIZE${TAB}DESCRIPTION" 3

  sub "Formulae - DEPENDENCIES (installed because another package needs them)  [largest first]"
  printf '%s' "$DEP_ROWS" | grep . | sort -t "$TAB" -k3,3nr | table "NAME${TAB}VERSION${TAB}SIZE${TAB}REQUIRED BY" 3

  sub "Casks (GUI apps / binaries)  [largest first; sizes are approximate]"
  CASK_ROWS=""
  while read -r name vers; do
    [ -z "$name" ] && continue
    vers="$(printf '%s' "$vers" | tr ' ' ',')"
    kb=$(du -skL "$CASKROOM/$name" 2>/dev/null | cut -f1)
    CASK_ROWS="$CASK_ROWS$name$TAB$vers$TAB${kb:-0}"$'\n'
  done < <(brew list --cask --versions </dev/null 2>/dev/null)
  printf '%s' "$CASK_ROWS" | grep . | sort -t "$TAB" -k3,3nr | table "NAME${TAB}VERSION${TAB}SIZE" 3
fi

# =============================================================================
# PYTHON
# =============================================================================
section "PYTHON"

read -r -d '' PYSNIP <<'PYEOF' || true
import os, re, sys
try:
    from importlib import metadata
except ImportError:
    sys.exit(3)

def norm(s):
    return re.sub(r"[-_.]+", "-", s).lower()

rows = {}
req_by = {}
for d in metadata.distributions():
    nm = d.metadata["Name"]
    if not nm:
        continue
    key = norm(nm)
    if key in rows:
        continue
    size = 0
    for f in (d.files or []):
        try:
            size += os.path.getsize(str(d.locate_file(f)))
        except OSError:
            pass
    rows[key] = (nm, d.version or "?", size)
    for r in (d.requires or []):
        if "extra ==" in r or "extra==" in r:
            continue
        n = re.split(r"[\s;<>=!~\[\(]", r.strip(), maxsplit=1)[0]
        req_by.setdefault(norm(n), set()).add(key)

for key in sorted(rows):
    nm, ver, size = rows[key]
    by = sorted(req_by.get(key, set()) - {key})
    kind = "dep" if by else "top"
    print("\t".join([kind, nm, ver, str(size // 1024), ", ".join(by) or "-"]))
PYEOF

# ---- discover interpreters ---------------------------------------------------
CANDIDATES=""
add_cand() { [ -x "$1" ] && CANDIDATES="$CANDIDATES$1"$'\n'; }

add_cand "$(command -v python3 2>/dev/null)"
add_cand "$(command -v python 2>/dev/null)"

if command -v brew >/dev/null 2>&1; then
  BP="$(brew --prefix)"
  for p in "$BP"/bin/python3 "$BP"/bin/python3.[0-9]*; do
    case "$p" in *-config) continue ;; esac
    add_cand "$p"
  done
fi
for p in "$HOME"/.pyenv/versions/*/bin/python; do add_cand "$p"; done
for p in /Library/Frameworks/Python.framework/Versions/*/bin/python3; do add_cand "$p"; done
# Apple's stub python3 triggers an install popup if Command Line Tools are missing, so check first
if xcode-select -p >/dev/null 2>&1; then add_cand /usr/bin/python3; fi

SEEN=""
FOUND=0
while IFS= read -r py; do
  [ -z "$py" ] && continue
  prefix="$("$py" -c 'import sys; print(sys.prefix)' 2>/dev/null </dev/null)" || continue
  [ -z "$prefix" ] && continue
  case $'\n'"$SEEN"$'\n' in *$'\n'"$prefix"$'\n'*) continue ;; esac
  SEEN="$SEEN$prefix"$'\n'
  FOUND=$((FOUND + 1))

  ver="$("$py" -c 'import sys; print(sys.version.split()[0])' 2>/dev/null </dev/null)"
  sub "Interpreter #$FOUND : Python $ver"
  echo "  Executable : $py"
  echo "  Prefix     : $prefix"

  DATA="$("$py" -c "$PYSNIP" 2>/dev/null </dev/null)"
  rc=$?
  if [ $rc -ne 0 ] || [ -z "$DATA" ]; then
    echo "  (could not read packages - interpreter too old or empty)"
    continue
  fi

  TOTAL_KB=$(printf '%s\n' "$DATA" | awk -F'\t' '{ s += $4 } END { print s + 0 }')
  echo "  Packages   : $(printf '%s\n' "$DATA" | wc -l | tr -d ' ')   (total size ~ $(human_kb "$TOTAL_KB"))"

  echo
  echo "  ${BOLD}Top-level packages (nothing else requires them)  [largest first]${RST}"
  printf '%s\n' "$DATA" | awk -F'\t' '$1=="top" { print $2 "\t" $3 "\t" $4 }' \
    | sort -t "$TAB" -k3,3nr | table "NAME${TAB}VERSION${TAB}SIZE" 3

  echo
  echo "  ${BOLD}Dependencies (required by other packages)  [largest first]${RST}"
  printf '%s\n' "$DATA" | awk -F'\t' '$1=="dep" { print $2 "\t" $3 "\t" $4 "\t" $5 }' \
    | sort -t "$TAB" -k3,3nr | table "NAME${TAB}VERSION${TAB}SIZE${TAB}REQUIRED BY" 3
done <<< "$CANDIDATES"

[ "$FOUND" -eq 0 ] && echo "  No Python interpreters found."

# ---- other python tooling ----------------------------------------------------
sub "Other Python tooling (if present)"
if command -v pipx >/dev/null 2>&1; then
  echo "  pipx apps:"
  pipx list --short </dev/null 2>/dev/null | sed 's/^/    /'
fi
if command -v uv >/dev/null 2>&1; then
  echo "  uv tools:"
  uv tool list </dev/null 2>/dev/null | sed 's/^/    /'
fi
if command -v pyenv >/dev/null 2>&1; then
  echo "  pyenv versions:"
  pyenv versions --bare </dev/null 2>/dev/null | sed 's/^/    /'
fi
if command -v conda >/dev/null 2>&1; then
  echo "  conda environments:"
  conda env list </dev/null 2>/dev/null | grep -v '^#' | sed 's/^/    /'
fi
command -v pipx >/dev/null 2>&1 || command -v uv >/dev/null 2>&1 || \
command -v pyenv >/dev/null 2>&1 || command -v conda >/dev/null 2>&1 || echo "  (none found)"

# =============================================================================
# FOOTER
# =============================================================================
section "DONE"
echo "  Nothing was changed. This script is read-only."
echo "  When you decide what to remove, do it yourself, e.g.:"
echo "    brew uninstall <formula>      brew uninstall --cask <cask>"
echo "    python3 -m pip uninstall <package>"
echo "  Tip: check the REQUIRED BY column before removing any dependency."
echo
