#!/bin/bash
# ccc-divider installer — wires the separator hooks into Claude Code's settings.json.
#
# Why this instead of the plugin flow:
#   - one command, no marketplace step
#   - the hook points directly at this repo's separator.sh, so editing the script
#     takes effect on the next session (no reinstall / cache copy)
#
# Safety:
#   - JSON is merged with node (which Claude Code already depends on, so it is
#     always present — no jq/python required). node parse/stringify cannot corrupt
#     the file the way a sed/grep merge could.
#   - idempotent: re-running replaces our entries instead of duplicating them.
#   - reversible: run ./uninstall.sh to remove everything this added.
set -euo pipefail

# --- resolve this repo's absolute path (follow symlinks) ---
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
REPO_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

SCRIPT="$REPO_DIR/hooks/separator.sh"
[ -f "$SCRIPT" ] || { echo "✗ cannot find $SCRIPT" >&2; exit 1; }

HOOK_CMD="bash \"$SCRIPT\""
SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"

command -v node >/dev/null 2>&1 || { echo "✗ node not found (Claude Code needs it; is your PATH set?)" >&2; exit 1; }

mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || printf '{}\n' > "$SETTINGS"

node - "$SETTINGS" "$HOOK_CMD" <<'NODE'
const fs = require('fs');
const [, , file, cmd] = process.argv;
const cfg = JSON.parse(fs.readFileSync(file, 'utf8').trim() || '{}');
cfg.hooks = cfg.hooks || {};

const ours = (x) => (x.command || '').includes('separator.sh');

function wire(event, matcher) {
  const arr = (cfg.hooks[event] = cfg.hooks[event] || []);
  let group = arr.find((g) => (matcher ? g.matcher === matcher : !g.matcher));
  if (!group) {
    group = matcher ? { matcher, hooks: [] } : { hooks: [] };
    arr.push(group);
  }
  group.hooks = (group.hooks || []).filter((x) => !ours(x)); // drop stale ours
  group.hooks.push({ type: 'command', command: cmd });
}

wire('Stop', null);                    // separator after each response
wire('PreToolUse', 'AskUserQuestion'); // separator before a fork/choice card

fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + '\n');
NODE

echo "✅ ccc-divider wired into $SETTINGS"
echo "   reply 回覆線 (Stop)  +  fork 分叉線 (PreToolUse/AskUserQuestion)  →  $SCRIPT"
echo "   Tune width via env: SEP_MARGIN_REPLY (default 5), SEP_MARGIN_FORK (default -6)."
echo "   Open a new Claude Code session (hooks load at startup) to see it."
echo "   To remove: $REPO_DIR/uninstall.sh"
