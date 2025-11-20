#!/usr/bin/env bash
set -e

SESSION=code

# If session exists, attach
if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach -t "$SESSION"
fi

# Otherwise create a new layout
tmux new-session -d -s "$SESSION" -n workspace

# Left pane: editor
tmux send-keys -t "$SESSION":0.0 'cd /work && nvim' C-m

# Right pane: terminal
tmux split-window -h -t "$SESSION":0
tmux send-keys -t "$SESSION":0.1 'cd /work' C-m

# Focus editor pane
tmux select-pane -t "$SESSION":0.0

exec tmux attach -t "$SESSION"
