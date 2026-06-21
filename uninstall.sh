#!/usr/bin/env bash
set -e
NAME="ccc-divider"
claude plugin uninstall "${NAME}@${NAME}"
claude plugin marketplace remove "$NAME"
echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
