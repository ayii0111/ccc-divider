#!/usr/bin/env bash
set -e
NAME="ccc-divider"

claude plugin uninstall "${NAME}@custom-tools" 2>/dev/null || true
# 舊版曾以 repo 自帶市場安裝，一併清理
claude plugin uninstall "${NAME}@${NAME}" 2>/dev/null || true
claude plugin marketplace remove "$NAME" 2>/dev/null || true
# custom-tools 為共用索引市場，不移除

echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
