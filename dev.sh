#!/usr/bin/env bash
# 本機開發：直接從這個目錄載入 plugin 啟動 CC，不註冊任何市場、不安裝。
# 離開該 session 即失效，不留殘留。
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
exec claude --plugin-dir "$DIR" "$@"
