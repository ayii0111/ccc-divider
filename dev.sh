#!/usr/bin/env bash
# 本機開發：直接從這個目錄載入 plugin 啟動 CC。
# 不註冊市場、不安裝、不寫入設定，離開該 session 即失效，無需卸載。
set -e
NAME="ccc-divider"
DIR="$(cd "$(dirname "$0")" && pwd)"

# 正式版若已安裝，會與這裡載入的開發版同時生效（分隔線印兩條）
if claude plugin list 2>/dev/null | command grep -q "${NAME}@"; then
  echo "⚠ 偵測到已安裝的 ${NAME}，開發版會重複載入。" >&2
  echo "  先執行 ./uninstall.sh 再回來。" >&2
  exit 1
fi

exec claude --plugin-dir "$DIR" "$@"
