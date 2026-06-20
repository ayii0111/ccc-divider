#!/bin/bash
# ccc-divider — full-width separator with timestamp after each Claude response.
#
# How it works:
#   CC sets COLUMNS in the hook environment (even though the TTY is detached).
#   The only way to display output to the user is via JSON { "systemMessage": "..." }.
#   CC prepends "Stop says: " (11 chars) before the message, which is accounted for
#   in the width calculation. ANSI colour codes work inside systemMessage.
#
# Customisation via environment variables (set in your shell profile or CC settings env):
#   SEP_COLOR   — RGB colour as "R,G,B" (default: 129,161,193 = Nord frost blue)
#                 Set to "none" to disable colour.
#   SEP_ICON    — character shown before the timestamp (default: ⏱)
#                 Set to "" to disable the icon.
#   SEP_MARGIN  — integer fine-tune (default: 6). Increase if the line wraps;
#                 decrease if there is too much space before the timestamp.
#                 The default was calibrated on Ghostty with a Nerd Font where ◆
#                 renders as 2 columns. On other terminals it may differ by ±1–2.

INPUT=$(cat)   # consume stdin to avoid SIGPIPE

# --- terminal width ---
COLS=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}

# --- configurable values ---
COLOR=${SEP_COLOR:-"129,161,193"}   # Nord frost blue (nord9)
ICON=${SEP_ICON:-"⏱"}              # clock icon before timestamp (emoji = 2 cols)
MARGIN=${SEP_MARGIN:-6}

# --- compute line length ---
# total = PREFIX(11) + ◆(1) + LINE(N) + 2 spaces + ICON(2) + space(1) + TIME(8) + MARGIN
PREFIX=11
TIME=$(date '+%H:%M:%S')
N=$(( COLS - PREFIX - 1 - 2 - 2 - 1 - 8 - MARGIN ))
(( N < 1 )) && N=1
LINE=$(printf "%.0s━" $(seq 1 "$N"))

# --- build JSON systemMessage (pure bash, no python3 required) ---
#  is the literal 6-char JSON unicode escape for ESC.
if [ "$COLOR" = "none" ]; then
    MSG="◆${LINE}  ${ICON} ${TIME}"
else
    IFS=',' read -r R G B <<< "$COLOR"
    MSG="\\u001b[38;2;${R};${G};${B}m◆${LINE}\\u001b[0m  ${ICON} ${TIME}"
fi

printf '{"systemMessage":"%s"}\n' "$MSG"
