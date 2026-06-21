#!/usr/bin/env bash
set -e
NAME="ccc-divider"
# 本機執行：用本地路徑
if [ -f "$(dirname "$0")/.claude-plugin/plugin.json" ]; then
  DIR="$(cd "$(dirname "$0")" && pwd)"
  claude plugin marketplace add "$DIR"
else
  # curl | bash：用 GitHub source
  claude plugin marketplace add "ayii0111/$NAME"
fi
claude plugin install "${NAME}@${NAME}"
echo "✓ 安裝完成。在 CC 執行 /reload-plugins 或重啟 CC 套用。"
