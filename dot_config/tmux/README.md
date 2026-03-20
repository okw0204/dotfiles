# tmux Cheat Sheet

Current prefix key:

- `Ctrl+Space`
- fallback: `Ctrl+b`

## Tabs (windows)

- `prefix + c`: create new tab
- `prefix + r`: rename current tab
- `prefix + k`: close current tab
- `Alt+1..Alt+9`: jump to tab by number
- `Alt+Left`: previous tab
- `Alt+Right`: next tab

## Panes (splits)

- `prefix + h`: split horizontally (new pane below)
- `prefix + v`: split vertically (new pane right)
- `prefix + x`: close current pane
- `Ctrl+Alt+Left/Right/Up/Down`: move focus between panes
- `Ctrl+Alt+Shift+Left/Right/Up/Down`: resize pane

## Sessions

- `prefix + d`: detach session
- `prefix + C`: create new session
- `prefix + R`: rename current session
- `prefix + K`: kill current session
- `Alt+Up`: previous session
- `Alt+Down`: next session

## Useful commands

- `prefix + q`: reload `~/.config/tmux/tmux.conf`
- `tmux ls`: list sessions
- `tmux attach -t <name>`: attach to a session
- `tmux new -s <name>`: start a named session
