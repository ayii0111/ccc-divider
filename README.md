# ccc-divider

A Claude Code plugin that displays a full-width visual separator with timestamp after each Claude response.

```
Stop says: ◆━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  18:32:29
```

The line dynamically fills the current terminal width, with the timestamp aligned to the right edge. Colour is Nord frost blue by default — configurable via environment variable.

## How it works

Claude Code exposes a `Stop` hook that fires after every response. This plugin registers a shell script on that hook. The script reads `COLUMNS` from the environment (CC injects this even though the TTY is detached), computes the correct line length, and returns a `{ "systemMessage": "..." }` JSON payload — the only channel through which hook output is actually rendered to the user.

## Requirements

- Claude Code (claude CLI) — any recent version
- bash (macOS / Linux)
- No other dependencies (pure bash, no python3 required)

## Installation

### Option A — via your own marketplace (recommended for sharing)

Push this repo to GitHub (e.g. your account is `alice`, so the repo is `alice/ccc-divider`), then run in Claude Code:

```
/plugin marketplace add <your-github-username>/ccc-divider
/plugin install ccc-divider@ccc-divider
```

Replace `<your-github-username>` with your actual GitHub account name.

### Option B — local install (no GitHub needed)

Clone or copy this repo anywhere on your machine, then run in Claude Code:

```
/plugin marketplace add /absolute/path/to/ccc-divider
/plugin install ccc-divider@ccc-divider
```

Open Claude Code and run:

```
/plugin marketplace add ~/cc-projects/ccc-divider
/plugin install ccc-divider@ccc-divider
```

### Uninstall

```
/plugin uninstall ccc-divider@ccc-divider
```

## Calibration (if the line wraps or doesn't fill the terminal)

The default `SEP_MARGIN=6` was calibrated on Ghostty with a Nerd Font where `◆` renders as 2 terminal columns. Other terminals or fonts may need a different value.

**To adjust**, set `SEP_MARGIN` in your shell profile or in Claude Code's `env` settings:

```bash
# ~/.zshrc or ~/.bashrc
export SEP_MARGIN=6   # increase if line wraps; decrease if there is a gap
```

Or in `~/.claude/settings.json`:

```json
{
  "env": {
    "SEP_MARGIN": "6"
  }
}
```

**How to find the right value:** start at `6`. If the timestamp is pushed off-screen or the line wraps → increase by 1–2. If there is a noticeable gap before the timestamp → decrease by 1.

## Customisation

| Variable | Default | Description |
|---|---|---|
| `SEP_COLOR` | `129,161,193` | Line colour as `R,G,B`. Set to `none` to disable colour. |
| `SEP_ICON` | `⏱` | Icon shown before the timestamp. Set to `""` to disable. |
| `SEP_MARGIN` | `6` | Width fine-tune (see Calibration above). |

Example — switch to a muted green:

```bash
export SEP_COLOR="163,190,140"   # Nord aurora green (nord14)
```

## Background: why so many constraints?

If you are curious why the implementation is non-obvious:

1. **TTY is detached** — CC runs hooks in a subprocess that is disconnected from the controlling terminal (`ps -o tty` shows `??`). Writing to stdout, stderr, or `/dev/tty` all fail silently or error.
2. **TUI owns the screen** — CC is a full-screen TUI; raw ANSI writes from a subprocess would be swallowed or overwritten on the next redraw.
3. **`systemMessage` is the only channel** — returning `{ "systemMessage": "..." }` from a Stop hook asks CC itself to render the string, which it does correctly, including ANSI colour codes.
4. **`COLUMNS` survives the detach** — CC injects the current terminal width into the hook's environment, so the line can be sized dynamically even without a real TTY.
