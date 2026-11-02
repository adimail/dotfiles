#!/usr/bin/env bash

prompt_input() {
	local prompt="$1"
	local var_name="$2"
	local raw_val
	bind 'set enable-bracketed-paste off' 2>/dev/null
	printf '\e[?2004l'
	read -e -r -p "$prompt" raw_val
	raw_val="${raw_val//$'\e[200~'/}"
	raw_val="${raw_val//$'\e[201~'/}"
	raw_val="${raw_val//$'\r'/}"
	printf -v "$var_name" '%s' "$raw_val"
}
