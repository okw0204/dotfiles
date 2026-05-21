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

## Organize mode

Enter with `prefix + o`.

The popup shows windows across sessions.

- `Enter`: switch to selected window
- `F2`: rename selected window
- `F4`: close selected window with confirmation
- `F5`: move selected window up
- `F6`: move selected window down
- `F7`: move selected window to another session
- `F8`: create new window
- `F9`: create new session
- `Esc`: close popup

## Useful commands

- `prefix + q`: reload `~/.config/tmux/tmux.conf`
- `tmux ls`: list sessions
- `tmux attach -t <name>`: attach to a session
- `tmux new -s <name>`: start a named session
