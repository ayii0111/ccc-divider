#!/bin/bash
# ccc-divider — full-width separators with timestamp:
#   回覆線 (reply) after each Claude response, and 提案線 (ask) on choice cards.
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
#   SEP_MARGIN_REPLY — 回覆線 (reply) fine-tune (default: 5). Smaller = longer line.
#   SEP_MARGIN_ASK   — 提案線 (ask)   fine-tune (default: -6). Tuned separately because
#                      CC prepends a different prefix to the choice-card message.
#   SEP_MARGIN_FORK  — legacy alias for SEP_MARGIN_ASK (still honoured).
#   SEP_MARGIN       — legacy alias for SEP_MARGIN_REPLY (still honoured).
#                 Increase a margin if the line wraps; decrease if there is a gap
#                 before the timestamp. Defaults were calibrated on Ghostty with a
#                 Nerd Font where ◆ renders as 2 columns; other terminals differ ±1–2.

INPUT=$(cat)   # consume stdin to avoid SIGPIPE

# Two named dividers, tuned independently (CC prepends a different prefix to each):
#   ask   — 提案線 — shown with a choice card  (PreToolUse / AskUserQuestion)
#   reply — 回覆線 — shown after each reply     (Stop)
if printf '%s' "$INPUT" | grep -q 'AskUserQuestion'; then MODE="ask"; else MODE="reply"; fi

# --- terminal width ---
COLS=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}

# --- configurable values ---
COLOR=${SEP_COLOR:-"129,161,193"}   # Nord frost blue (nord9)
ICON=${SEP_ICON:-"⏱"}              # clock icon before timestamp (emoji = 2 cols)
if [ "$MODE" = "ask" ]; then
    MARGIN=${SEP_MARGIN_ASK:-${SEP_MARGIN_FORK:--6}}   # 提案線 ask divider (SEP_MARGIN_FORK = legacy alias)
else
    MARGIN=${SEP_MARGIN_REPLY:-${SEP_MARGIN:-5}}        # 回覆線 reply divider (SEP_MARGIN = legacy alias)
fi

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
