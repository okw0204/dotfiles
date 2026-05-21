#!/usr/bin/env fish

function window_rows
    tmux list-windows -a -F '#{session_name}	#{window_index}	#{window_name}	#{pane_current_path}'
end

function select_window
    set -l header 'Enter: switch | Ctrl-r: rename | Ctrl-k: kill | Ctrl-u/d: move up/down | Ctrl-m: move session | Ctrl-n: new window | Ctrl-s: new session | Esc: close'

    window_rows | fzf \
        --delimiter '\t' \
        --with-nth '1,2,3,4' \
        --header "$header" \
        --prompt 'tmux organize> ' \
        --bind 'ctrl-r:become(tmux command-prompt -p "rename window:" "rename-window -t {1}:{2} -- \"%%\"")' \
        --bind 'ctrl-k:become(tmux confirm-before -p "kill window {1}:{2}? (y/n)" "kill-window -t {1}:{2}")' \
        --bind 'ctrl-u:execute-silent(fish -c "set target (math {2} - 1); tmux swap-window -s {1}:{2} -t {1}:\$target")+reload(eval "$reload_cmd")' \
        --bind 'ctrl-d:execute-silent(fish -c "set target (math {2} + 1); tmux swap-window -s {1}:{2} -t {1}:\$target")+reload(eval "$reload_cmd")' \
        --bind 'ctrl-m:become(fish -c "set target (tmux list-sessions -F \'#{session_name}\' | fzf --prompt \'move to session> \'); test -n \"\$target\"; and tmux move-window -s {1}:{2} -t \"\$target:\"")' \
        --bind 'ctrl-n:become(tmux new-window -c "#{pane_current_path}")' \
        --bind 'ctrl-s:become(tmux new-session -c "#{pane_current_path}")'
end

set -gx reload_cmd 'tmux list-windows -a -F "#{session_name}	#{window_index}	#{window_name}	#{pane_current_path}"'

set -l selected (select_window)
if test -z "$selected"
    exit 0
end

set -l fields (string split \t -- $selected)
set -l session $fields[1]
set -l window $fields[2]

tmux switch-client -t "$session"
tmux select-window -t "$session:$window"
