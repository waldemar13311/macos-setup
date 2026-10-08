# --- Алиасы ---
alias ls="eza --icons=always"
alias ll="eza -lAgi --group-directories-first --classify=always --icons=always --time-style=long-iso"

# cat - bat в режиме plain (-pp: без нумерации строк и рамки). Раскраска -
# только на прямом выводе в терминал (дефолтный режим auto bat): в пайпах
# (| grep, | head, | jq, | ssh ...) и при редиректе вывод всегда чистый,
# без ANSI-кодов - предсказуемо для любых потребителей. Подсветку совпадений
# при | grep делает сам grep (GREP_COLORS в variables.zsh).
# Настоящий cat: command cat
alias cat="bat -pp"

# Подсветка совпадений в grep (стиль выделения - GREP_COLORS в variables.zsh).
# color=auto: красит только в терминал, пайпы и файлы остаются чистыми
alias grep="grep --color=auto"

alias less="bat --pager 'less -R'"

alias rm="trash"

alias copy="my_pbcopy"

# paste - вывести буфер обмена в stdout (напр.: paste | grep ...)
# ВНИМАНИЕ: перекрывает системную утилиту paste (склейка строк файлов) -
# если понадобится настоящая, вызывайте её как `command paste`
alias paste="my_pbpaste"

alias diff="git diff --no-index --color"

alias k="kubectl"
alias kctx="kubectx"
alias kns="kubens"

alias man=tldr

alias python="python3"

# Управление Docker-окружением (Colima) - только если colima установлен
# (на macOS это замена Docker Desktop, на Linux Docker работает нативно)
if (( $+commands[colima] )); then
    alias docker-start="colima start --cpus 4 --memory 8 --disk 60"
    alias docker-stop="colima stop"
    alias docker-stat="colima status"
fi

# In networking, the official term for emptying a cache is "flushing"
if [[ "$OSTYPE" == darwin* ]]; then
    alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
fi
