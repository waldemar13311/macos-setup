# --- Алиасы ---
alias ls="eza --icons=always"
alias ll="eza -lAgi --group-directories-first --classify=always --icons=always --time-style=long-iso"

alias tree="eza --tree -A --classify=always --icons=always --group-directories-first"

alias cat="bat -pp"

alias less="bat --pager 'less -R'"

alias rm="trash"

alias copy="my_pbcopy"

alias grep="rg"

alias diff="git diff --no-index --color"

alias k="kubectl"
alias kctx="kubectx"
alias kns="kubens"

alias man=tldr

alias python="python3"

# Управление Docker-окружением (Colima)
alias dstart="colima start --cpus 4 --memory 8 --disk 60"
alias dstop="colima stop"
alias dstat="colima status"
