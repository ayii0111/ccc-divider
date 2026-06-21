# ccc-divider

A Claude Code add-on that draws full-width visual separators with a timestamp, so each
turn is easy to scan. It provides **two independently-tunable dividers**:

| Name | 名稱 | When it shows | Hook | Tuning knob |
|---|---|---|---|---|
| **reply** | 回覆線 | after each Claude response | `Stop` | `SEP_MARGIN_REPLY` |
| **ask** | 提案線 | with a choice / option card | `PreToolUse(AskUserQuestion)` | `SEP_MARGIN_ASK` |

```
Stop says: ◆━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ⏱ 18:32:29
```

Each line dynamically fills the current terminal width, timestamp aligned right. The two
dividers are tuned separately because Claude Code prepends a different prefix to each.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/ccc-divider/main/install.sh | bash
```

Open a new Claude Code session afterwards — hooks load at startup.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/ccc-divider/main/uninstall.sh | bash
```

## Tuning the two dividers

Set environment variables in Claude Code's `env` block in `~/.claude/settings.json`.
**Smaller margin = longer line.**

```json
{
  "env": {
    "SEP_MARGIN_REPLY": "5",
    "SEP_MARGIN_ASK": "-6"
  }
}
```

The ask (提案線) is only visible after you answer the card (it lands in the scrollback),
so calibrate it there.

## All variables

| Variable | Default | Divider | Description |
|---|---|---|---|
| `SEP_MARGIN_REPLY` | `5` | reply 回覆線 | Width fine-tune for the after-response line. |
| `SEP_MARGIN_ASK` | `-6` | ask 提案線 | Width fine-tune for the choice-card line. |
| `SEP_MARGIN` | — | reply | Legacy alias for `SEP_MARGIN_REPLY`. |
| `SEP_COLOR` | `129,161,193` | both | Line colour as `R,G,B`. Set to `none` to disable colour. |
| `SEP_ICON` | `⏱` | both | Icon before the timestamp. Set to `""` to disable. |

Defaults were calibrated on Ghostty with a Nerd Font where `◆` renders as 2 columns; other
terminals or fonts may differ by ±1–2.

## Background: why so many constraints?

1. **TTY is detached** — CC runs hooks in a subprocess disconnected from the terminal.
   Writing to stdout, stderr, or `/dev/tty` fails silently.
2. **TUI owns the screen** — raw ANSI writes from a subprocess are swallowed or overwritten.
3. **`systemMessage` is the only channel** — returning `{ "systemMessage": "..." }` from a
   hook asks CC itself to render the string, including ANSI colour.
4. **`COLUMNS` survives the detach** — CC injects the terminal width into the hook's
   environment, so the line can be sized dynamically even without a real TTY.
5. **Two prefixes** — CC prepends a different label to `Stop` vs `PreToolUse` messages,
   which is why reply and ask need separate margins.
