# ccc-divider

A Claude Code add-on that draws full-width visual separators with a timestamp, so each
turn is easy to scan. It provides **two independently-tunable dividers**:

| Name | 名稱 | When it shows | Hook | Tuning knob |
|---|---|---|---|---|
| **reply** | 回覆線 | after each Claude response | `Stop` | `SEP_MARGIN_REPLY` |
| **fork** | 分叉線 | with a choice / option card | `PreToolUse(AskUserQuestion)` | `SEP_MARGIN_FORK` |

```
Stop says: ◆━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ⏱ 18:32:29
```

Each line dynamically fills the current terminal width, timestamp aligned right. The two
dividers are tuned separately because Claude Code prepends a different prefix to each.

## Install (recommended)

Clone this repo anywhere, then run the installer once:

```bash
git clone https://github.com/<your-username>/ccc-divider
cd ccc-divider
./install.sh
```

`install.sh` wires both hooks into `~/.claude/settings.json`, pointing them at this repo's
`hooks/separator.sh`. Because it references the script in place (not a copy), editing the
script takes effect on your **next** Claude Code session — no reinstall needed.

- Safe: the JSON is merged with `node` (which Claude Code already depends on), so it cannot
  corrupt your settings. It only adds entries that reference `separator.sh`.
- Idempotent: re-running replaces those entries instead of duplicating them.
- Hooks load at session startup, so **open a new session** to see the dividers.

### Uninstall

```bash
./uninstall.sh
```

Removes only the `separator.sh` entries; everything else in `settings.json` is left intact.

## Tuning the two dividers

Set environment variables in your shell profile, or in Claude Code's `env` block in
`~/.claude/settings.json`. Smaller margin = longer line.

```json
{
  "env": {
    "SEP_MARGIN_REPLY": "5",
    "SEP_MARGIN_FORK": "-6"
  }
}
```

**How to calibrate:** if a line wraps or the timestamp is pushed off-screen → increase that
margin. If there is a gap before the timestamp → decrease it. The fork line is only visible
after you answer the card (it lands in the scrollback), so judge it there.

## All variables

| Variable | Default | Divider | Description |
|---|---|---|---|
| `SEP_MARGIN_REPLY` | `5` | reply 回覆線 | Width fine-tune for the after-response line. |
| `SEP_MARGIN_FORK` | `-6` | fork 分叉線 | Width fine-tune for the choice-card line. |
| `SEP_MARGIN` | — | reply | Legacy alias for `SEP_MARGIN_REPLY`. |
| `SEP_COLOR` | `129,161,193` | both | Line colour as `R,G,B`. Set to `none` to disable colour. |
| `SEP_ICON` | `⏱` | both | Icon before the timestamp. Set to `""` to disable. |

Defaults were calibrated on Ghostty with a Nerd Font where `◆` renders as 2 columns; other
terminals or fonts may differ by ±1–2.

## Alternative: install as a plugin

The same hooks ship as a Claude Code plugin (`.claude-plugin/`, `hooks/hooks.json`). Prefer
`install.sh` for iterating on the script (a plugin install copies into a cache, so edits
need a reinstall). To use the plugin instead:

```
/plugin marketplace add /absolute/path/to/ccc-divider
/plugin install ccc-divider@ccc-divider
```

## Background: why so many constraints?

If you are curious why the implementation is non-obvious:

1. **TTY is detached** — CC runs hooks in a subprocess disconnected from the terminal
   (`ps -o tty` shows `??`). Writing to stdout, stderr, or `/dev/tty` fails silently.
2. **TUI owns the screen** — CC is a full-screen TUI; raw ANSI writes from a subprocess
   would be swallowed or overwritten on the next redraw.
3. **`systemMessage` is the only channel** — returning `{ "systemMessage": "..." }` from a
   hook asks CC itself to render the string, which it does correctly, including ANSI colour.
4. **`COLUMNS` survives the detach** — CC injects the current terminal width into the hook's
   environment, so the line can be sized dynamically even without a real TTY.
5. **Two prefixes** — CC prepends a different label to `Stop` vs `PreToolUse` messages, which
   is why reply and fork need separate margins.
