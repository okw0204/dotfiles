# Split / Compact Keyboard Keybindings for Omarchy + Hyprland

Use this reference when the user is adapting Omarchy/Hyprland to a compact or split keyboard such as a 40–50 key board with layers, thumb keys, a trackball, or scroll controls.

## Durable takeaways

- Omarchy/Hyprland is a reasonable fit for split keyboards because many actions are `SUPER`-centric.
- Stock Omarchy bindings are still somewhat full-size-keyboard-oriented: number rows, arrow keys, Print/F keys, Delete, `-`/`=`, and multi-modifier combinations can be awkward on layer-heavy boards.
- Treat Omarchy as a convenient starting point, not a binding scheme that must be preserved.
- Never edit `~/.local/share/omarchy/`; read it for defaults, then override in `~/.config/hypr/bindings.conf`.
- If the user is trying to reduce Omarchy dependence, prefer portable Hyprland bindings that can be managed by chezmoi/dotfiles and reused on pure Arch.

## Discovery checklist

1. Inspect stock bindings:
   - `~/.local/share/omarchy/default/hypr/bindings/tiling-v2.conf`
   - `~/.local/share/omarchy/default/hypr/bindings/utilities.conf`
   - `~/.local/share/omarchy/default/hypr/bindings/clipboard.conf`
2. Inspect user overrides:
   - `~/.config/hypr/bindings.conf`
3. Identify existing collisions before proposing overrides.
4. For each override, add `unbind = MODS, KEY` before the new `bind`/`bindd`.
5. Tell the user what the old binding was.

## Bindings that often remain useful

These are usually worth preserving unless the user says otherwise:

- `SUPER + Space`: launcher
- `SUPER + Enter`: terminal
- `SUPER + V`: clipboard history / Walker + Elephant if already customized
- `SUPER + Tab`: next workspace
- `SUPER + Shift + Tab`: previous workspace
- `SUPER + F`: fullscreen
- `SUPER + T`: floating toggle

## Candidate home-row scheme

These are good candidates for compact/split keyboard window management:

```conf
# Focus with home row
unbind = SUPER, H
unbind = SUPER, J
unbind = SUPER, K
unbind = SUPER, L
bindd = SUPER, H, Focus left, movefocus, l
bindd = SUPER, J, Focus down, movefocus, d
bindd = SUPER, K, Focus up, movefocus, u
bindd = SUPER, L, Focus right, movefocus, r

# Swap/move with home row
unbind = SUPER SHIFT, H
unbind = SUPER SHIFT, J
unbind = SUPER SHIFT, K
unbind = SUPER SHIFT, L
bindd = SUPER SHIFT, H, Swap window left, swapwindow, l
bindd = SUPER SHIFT, J, Swap window down, swapwindow, d
bindd = SUPER SHIFT, K, Swap window up, swapwindow, u
bindd = SUPER SHIFT, L, Swap window right, swapwindow, r

# Workspace navigation without number row
unbind = SUPER ALT, H
unbind = SUPER ALT, L
bindd = SUPER ALT, H, Previous workspace, workspace, e-1
bindd = SUPER ALT, L, Next workspace, workspace, e+1
```

Adjust names/actions to match the user's desired semantics. Do not paste this blindly; verify collisions first.

## Common stock conflicts to mention

- `SUPER + J`: toggle window split
- `SUPER + L`: toggle workspace layout
- `SUPER + K`: show key bindings
- `SUPER + Arrow`: focus movement
- `SUPER + Shift + Arrow`: swap window
- `SUPER + number`: switch workspace
- `SUPER + Shift + number`: move window to workspace

## Keyboard-side design note

For 49-key class boards, the keyboard layout itself matters as much as WM bindings. Before over-tuning Hyprland, ensure the user has a comfortable symbol layer for development:

- Brackets: `{ }`, `[ ]`, `( )`, `< >`
- Operators/punctuation: `|`, `&`, `!`, `?`, `_`, `:`, `;`, `/`, `~`
- Quotes: `'`, `"`

For Rust/CLI/Neovim-heavy users, poor symbol placement will hurt more than imperfect window-manager shortcuts.
