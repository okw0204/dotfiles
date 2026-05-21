#!/usr/bin/env fish

set -g self (realpath (status filename))

function window_rows
    tmux list-windows -a -F '#{session_name}	#{window_index}	#{window_name}	#{pane_current_path}'
end

function current_path
    tmux display-message -p '#{pane_current_path}'
end

function rename_window
    set -l session $argv[1]
    set -l window $argv[2]
    read -P 'rename window> ' name
    test -n "$name"; and tmux rename-window -t "$session:$window" -- "$name"
end

function kill_window
    set -l session $argv[1]
    set -l window $argv[2]
    read -P "kill window $session:$window? [y/N] " answer
    test "$answer" = y; and tmux kill-window -t "$session:$window"
end

function move_window_relative
    set -l session $argv[1]
    set -l window $argv[2]
    set -l delta $argv[3]
    set -l target (math $window + $delta)

    if test $target -lt 1
        tmux display-message "already at first window"
        return 0
    end

    tmux swap-window -s "$session:$window" -t "$session:$target" 2>/dev/null; or tmux display-message "cannot move window"
end

function move_window_to_session
    set -l session $argv[1]
    set -l window $argv[2]
    set -l target (tmux list-sessions -F '#{session_name}' | fzf --prompt 'move to session> ')
    test -n "$target"; and tmux move-window -s "$session:$window" -t "$target:"
end

function new_window
    set -l session $argv[1]
    tmux new-window -t "$session:" -c (current_path)
end

function new_session
    tmux new-session -d -c (current_path)
end

if test (count $argv) -gt 0
    switch $argv[1]
        case rename
            rename_window $argv[2] $argv[3]
        case kill
            kill_window $argv[2] $argv[3]
        case move-relative
            move_window_relative $argv[2] $argv[3] $argv[4]
        case move-session
            move_window_to_session $argv[2] $argv[3]
        case new-window
            new_window $argv[2]
        case new-session
            new_session
    end
    exit 0
end

function select_window
    set -l header 'Enter: switch | r: rename | x: kill | u/d: move up/down | m: move session | n: new window | s: new session | Esc: close'

    window_rows | fzf \
        --delimiter '\t' \
        --with-nth '1,2,3,4' \
        --header "$header" \
        --prompt 'tmux organize> ' \
        --bind 'enter:accept' \
        --bind "r:execute($self rename {1} {2})+reload(eval \"\$reload_cmd\")" \
        --bind "x:execute($self kill {1} {2})+reload(eval \"\$reload_cmd\")" \
        --bind "u:execute-silent($self move-relative {1} {2} -1)+reload(eval \"\$reload_cmd\")" \
        --bind "d:execute-silent($self move-relative {1} {2} 1)+reload(eval \"\$reload_cmd\")" \
        --bind "m:execute($self move-session {1} {2})+reload(eval \"\$reload_cmd\")" \
        --bind "n:execute-silent($self new-window {1})+reload(eval \"\$reload_cmd\")" \
        --bind "s:execute-silent($self new-session)+reload(eval \"\$reload_cmd\")"
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
