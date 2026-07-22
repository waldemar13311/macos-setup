# --- Алиасы ---
alias ls="eza --icons=always"
alias ll="eza -lAgi --group-directories-first --classify=always --icons=always --time-style=long-iso"

alias cat="bat -pp"

alias less="bat --pager 'less -R'"

alias rm="trash"

alias copy="my_pbcopy"

alias diff="git diff --no-index --color"

alias k="kubectl"
alias kctx="kubectx"
alias kns="kubens"

alias man=tldr

alias python="python3"

# Управление Docker-окружением (Colima)
alias docker-start="colima start --cpus 4 --memory 8 --disk 60"
alias docker-stop="colima stop"
alias docker-stat="colima status"

# In networking, the official term for emptying a cache is "flushing"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
