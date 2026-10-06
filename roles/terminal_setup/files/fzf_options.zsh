# --- Настройки fzf и fzf-widgets ---
export FZF_TMUX=0
# Настройка внешнего вида (на весь экран и список сверху вниз)
# --no-mouse - не захватывать мышь: работает обычное терминальное выделение
# текста (drag без Shift), но клики по пунктам перестают выбирать строки
# --highlight-line - закрашивать фон выбранной строки на всю ширину экрана
# (по умолчанию fzf красит только область с текстом)
# --color - переопределяем ТОЛЬКО выбранную строку, остальное (курсор, подсветка
# совпадений, prompt и т.д.) - дефолтные цвета fzf:
#   bg+ - фон выбранной строки: чуть светлее дефолтного серого
#   fg+ - текст выбранной строки: яркий белый (дефолтный - приглушённый)
export FZF_DEFAULT_OPTS=" --height 100% --reverse --no-mouse --highlight-line \
  --color=bg+:#49483E,fg+:#F8F8F2"

# Настройки fd
# Включаем fd для поиска в fzf-widgets (чтобы искало моментально)
export FZF_WIDGETS_FIND_COMMAND="fd"
export FZF_WIDGET_FIND_COMMAND="fd"
# Глобальный поиск файлов через fd
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules --exclude .venv'
# Применяется, когда ищем файлы внутри командной строки
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
