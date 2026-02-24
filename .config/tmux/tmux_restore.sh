#!/bin/zsh

tmux new-session -d -s del && tmux run-shell "~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh" && tmux kill-session -t del && tmux attach || tmux attach
