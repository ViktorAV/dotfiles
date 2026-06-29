#!/bin/sh

if hyprctl clients -j | jq -e '.[] | select(.class == "quake-term")' > /dev/null; then
    hyprctl dispatch togglespecialworkspace "quake-term"
else
    hyprctl --batch '
        dispatch togglespecialworkspace quake-term;
        dispatch exec kitty --class=quake-term --title=float
    '
    #dispatch exec kitty --class=quake-term --title=float sh -c "\
    #  tmux new-session -d -s del && tmux run-shell \"~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh\" &&\
    #  tmux kill-sesision -t del && tmux attach || tmux attach
    #"
fi
