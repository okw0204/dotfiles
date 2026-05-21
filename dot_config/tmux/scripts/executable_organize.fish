#!/usr/bin/env fish

function window_rows
    tmux list-windows -a -F '#{session_name}	#{window_index}	#{window_name}	#{pane_current_path}'
end

function select_window
    set -l header 'Enter: switch | Alt-r: rename | Alt-k: kill | Alt-u/d: move up/down | Alt-m: move session | Alt-n: new window | Alt-s: new session | Esc: close'

    window_rows | fzf \
        --delimiter '\t' \
        --with-nth '1,2,3,4' \
        --header "$header" \
        --prompt 'tmux organize> ' \
        --bind 'enter:accept' \
        --bind 'alt-r:execute(fish -c "read -P \'rename window> \' name; test -n \"\$name\"; and tmux rename-window -t {1}:{2} -- \"\$name\"")+reload(eval "$reload_cmd")' \
        --bind 'alt-k:execute(fish -c "read -P \'kill window {1}:{2}? [y/N] \' answer; test \"\$answer\" = y; and tmux kill-window -t {1}:{2}")+reload(eval "$reload_cmd")' \
        --bind 'alt-u:execute-silent(fish -c "set target (math {2} - 1); tmux swap-window -s {1}:{2} -t {1}:\$target")+reload(eval "$reload_cmd")' \
        --bind 'alt-d:execute-silent(fish -c "set target (math {2} + 1); tmux swap-window -s {1}:{2} -t {1}:\$target")+reload(eval "$reload_cmd")' \
        --bind 'alt-m:execute(fish -c "set target (tmux list-sessions -F \'#{session_name}\' | fzf --prompt \'move to session> \'); test -n \"\$target\"; and tmux move-window -s {1}:{2} -t \"\$target:\"")+reload(eval "$reload_cmd")' \
        --bind 'alt-n:execute-silent(tmux new-window -c "#{pane_current_path}")+reload(eval "$reload_cmd")' \
        --bind 'alt-s:execute-silent(tmux new-session -c "#{pane_current_path}")+reload(eval "$reload_cmd")'
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
