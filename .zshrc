ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Переменные
# export EDITOR="emacsclient -c -a 'emacs' --frame-parameters='(quote (name . \"float\"))'"
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export TERM="xterm-kitty"
export PATH=$PATH:/usr/sbin:~/.local/bin
export PAGER="less"
# export SUDO_ASKPASS="$HOME/yadisk/dotfiles/askpass.sh"
export SUDO_ASKPASS="/usr/bin/lxqt-openssh-askpass"

# История
HISTFILE=~/.history
HISTSIZE=2000
HISTFILESIZE=$HISTSIZE
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt APPENDHISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY # Синхронизация истории команд в нескольких сессиях
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

# Бинды, bindkey -L показать все бинды
bindkey -e # -v vi-like, -e emacs-like
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# C-G C-F - Git Files
# C-G C-B - Git Branches
# C-G C-T - Git Tags
# C-G C-R - Git Remotes
# C-G C-H - Git Stashes
# C-G C-L - Git Ref logs
# C-G C-W - Git Worktrees
# C-G C-E - Git For Each Ref
# bindkey '\t' autosuggest-accept

# Автокомплит
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Отключаем CASE поиск 
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Цвета
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Удаление слов (C-w)
WORDCHARS=' *?;!#$%/'
autoload -Uz select-word-style
select-word-style normal
zstyle ':zle:*' word-style unspecified

# Прочее
unsetopt beep # Отключение звука

# Псевдонимы
alias ls='ls --color'
# alias ls="exa --icons=always"
alias l="exa -l --icons=always"
alias lt="exa --tree --level=1 --icons=always"
# alias bat="batcat"
alias e="nvim"
# alias e="emacsclient -c -a 'emacs'"
# alias pg='ps aux | grep -v grep | grep $1'
# alias pyclean='find . \( -type f -name "*.py[co]" -o -type d -name "__pycache__" \) -delete && echo "Removed pycs and __pycache__"'
alias timestamp='date "+%s"'

# alias tmux_restore='tmux new-session -d -s del && tmux run-shell "~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh" && tmux kill-session -t del && tmux attach || tmux attach'
# if [ -z "$TMUX" ]; then
#   tmux attach || tmux_restore
# fi

eval "$(starship init zsh)"

# fzf
eval "$(fzf --zsh)"
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
