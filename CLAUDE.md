# ccc-divider — 專案詞彙與調整指南

## 兩條分隔線

本專案提供兩條獨立可調的分隔線，**請使用以下名稱溝通**：

| 名稱 | 英文代號 | 觸發時機 | Hook | 寬度旋鈕 |
|---|---|---|---|---|
| **回覆線** | reply | 每則 Claude 回覆結尾 | `Stop` | `SEP_MARGIN_REPLY` |
| **提案線** | ask | agent 給使用者選項卡片時 | `PreToolUse(AskUserQuestion)` | `SEP_MARGIN_ASK` |

## 調整口訣

**margin 越小、線越長。**

```bash
# 在 ~/.claude/settings.json 的 env 區塊設定，或 shell profile 匯出
SEP_MARGIN_REPLY=6    # 回覆線（預設 6）
SEP_MARGIN_ASK=6      # 提案線（預設 6，與回覆線同基準）
```

## 注意事項

- **提案線**只有在**選完作答送出後**才會落到捲動區（scrollback），卡片顯示當下看不到，校長度要往上捲 scrollback 看。
- 兩條線現在共用同一基準：訊息以 `\n` 開頭，讓分隔線從 col 0 開始，前綴長度不再影響線寬。
- `SEP_MARGIN`（舊名）仍有效，是 `SEP_MARGIN_REPLY` 的 legacy alias。
