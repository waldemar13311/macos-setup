# --- Настройки fzf и fzf-widgets ---
export FZF_TMUX=0
# Настройка внешнего вида (на весь экран и список сверху вниз)
export FZF_DEFAULT_OPTS=" --height 100% --reverse"

# Настройки fd
# Включаем fd для поиска в fzf-widgets (чтобы искало моментально)
export FZF_WIDGETS_FIND_COMMAND="fd"
export FZF_WIDGET_FIND_COMMAND="fd"
# Глобальный поиск файлов через fd
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules --exclude .venv'
# Применяется, когда ищем файлы внутри командной строки
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Настройка точного совпадения для истории
declare -p FZF_WIDGETS_OPTS > /dev/null 2>&1 && FZF_WIDGETS_OPTS[insert-history]="--exact"
declare -p FZF_WIDGET_OPTS > /dev/null 2>&1 && FZF_WIDGET_OPTS[insert-history]="--exact"
