#!/usr/bin/env bash
set -e
NAME="ccc-divider"
# 兩種來源都嘗試移除（索引市場 custom-tools／repo 自帶市場）
claude plugin uninstall "${NAME}@custom-tools" 2>/dev/null || true
claude plugin uninstall "${NAME}@${NAME}" 2>/dev/null || true
# 只移除本 plugin 專屬市場；custom-tools 為共用索引，保留
claude plugin marketplace remove "$NAME" 2>/dev/null || true
echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
