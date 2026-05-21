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

- `w`: choose window tree
- `s`: choose session tree
- `r`: rename current window
- `R`: rename current session
- `c`: create new window
- `C`: create new session
- `k`: close current window with confirmation
- `K`: close current session with confirmation
- `?`: show organize help menu
- `q` / `Esc`: cancel

## Useful commands

- `prefix + q`: reload `~/.config/tmux/tmux.conf`
- `tmux ls`: list sessions
- `tmux attach -t <name>`: attach to a session
- `tmux new -s <name>`: start a named session
