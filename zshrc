# Zsh config for the dev user

# History & options
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

# Prompt (simple)
PROMPT='%n@%m:%~ %# '

# If we're not already inside tmux and this is an interactive shell, jump into the tmux "code" session
if [[ -z "$TMUX" && $- == *i* ]]; then
  /home/dev/tmux-session.sh
  exit
fi
