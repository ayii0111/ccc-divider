#!/usr/bin/env bash
set -e
NAME="ccc-divider"
MARKET="custom-tools"

claude plugin uninstall "${NAME}@${MARKET}" 2>/dev/null || true

# --- 舊版殘留清理（本 repo 曾自帶同名市場）---
claude plugin uninstall "${NAME}@${NAME}" 2>/dev/null || true
claude plugin marketplace remove "$NAME" 2>/dev/null || true
# 注意：custom-tools 為多個 plugin 共用的索引市場，此處不移除。

echo "✓ 已移除 ${NAME}。重啟 CC 套用。"
