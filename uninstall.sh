#!/bin/bash
# ccc-divider uninstaller — removes the separator hooks from Claude Code's settings.json.
# Only touches entries whose command references separator.sh; everything else is left intact.
set -euo pipefail

SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
[ -f "$SETTINGS" ] || { echo "nothing to do — $SETTINGS does not exist"; exit 0; }

command -v node >/dev/null 2>&1 || { echo "✗ node not found" >&2; exit 1; }

node - "$SETTINGS" <<'NODE'
const fs = require('fs');
const [, , file] = process.argv;
const cfg = JSON.parse(fs.readFileSync(file, 'utf8').trim() || '{}');
const ours = (x) => (x.command || '').includes('separator.sh');

if (cfg.hooks) {
  for (const ev of Object.keys(cfg.hooks)) {
    cfg.hooks[ev] = (cfg.hooks[ev] || [])
      .map((g) => ({ ...g, hooks: (g.hooks || []).filter((x) => !ours(x)) }))
      .filter((g) => (g.hooks || []).length > 0);
    if (cfg.hooks[ev].length === 0) delete cfg.hooks[ev];
  }
  if (Object.keys(cfg.hooks).length === 0) delete cfg.hooks;
}

fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + '\n');
NODE

echo "✅ ccc-divider removed from $SETTINGS"
echo "   Open a new Claude Code session to apply."
