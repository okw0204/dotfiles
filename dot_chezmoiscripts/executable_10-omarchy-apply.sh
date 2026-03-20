#!/usr/bin/env bash
set -euo pipefail

theme_file="$HOME/.config/omarchy/current/theme.name"

if [[ -n ${OPENCODE:-} ]]; then
  echo "Skipping omarchy-theme-set in opencode session"
elif command -v omarchy-theme-set >/dev/null 2>&1 && [[ -f $theme_file ]]; then
  theme_name="$(tr -d '[:space:]' < "$theme_file")"
  if [[ -n $theme_name ]]; then
    omarchy-theme-set "$theme_name"
  fi
fi

if command -v omarchy-restart-waybar >/dev/null 2>&1; then
  omarchy-restart-waybar
fi
