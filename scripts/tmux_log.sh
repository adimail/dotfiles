#!/bin/bash
# Usage: tmux_log.sh "{date}" "{action}" "[session_name]" "[session_path]"

BASE_LOG_DIR=~/personal/logs/tmux

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
	echo "Usage: $0 \"{date}\" \"{action}\" [\"session_name\"] [\"session_path\"]"
	exit 1
fi

TIMESTAMP="$1"
EVENT_TYPE="$2"
TMUX_SESSION_NAME="${3:-N/A}"
TMUX_SESSION_PATH="${4:-N/A}"

LOG_YEAR=$(date -d "$TIMESTAMP" +"%Y" 2>/dev/null || date -jf "%Y-%m-%d" "$TIMESTAMP" +"%Y")
LOG_MONTH=$(date -d "$TIMESTAMP" +"%-m" 2>/dev/null || date -jf "%Y-%m-%d" "$TIMESTAMP" +"%-m")

YEARLY_LOG_DIR="$BASE_LOG_DIR/$LOG_YEAR"
LOG_FILE_PATH="$YEARLY_LOG_DIR/$LOG_MONTH.csv"

mkdir -p "$YEARLY_LOG_DIR"

if [ ! -f "$LOG_FILE_PATH" ]; then
	echo "Timestamp,Event Type,Session Name,Session Path" >"$LOG_FILE_PATH"
fi

echo "\"$TIMESTAMP\",\"$EVENT_TYPE\",\"$TMUX_SESSION_NAME\",\"$TMUX_SESSION_PATH\"" >>"$LOG_FILE_PATH"
