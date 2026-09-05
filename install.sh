#!/usr/bin/env bash
set -e
NAME="ccc-divider"
MARKET="custom-tools"

claude plugin marketplace add "ayii0111/${MARKET}"
claude plugin install "${NAME}@${MARKET}"
echo "✓ 安裝完成。在 CC 執行 /reload-plugins 或重啟 CC 套用。"
