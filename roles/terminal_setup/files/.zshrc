# Инициализация Homebrew окружения и путей (PATH)
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Для авто дополнения brew
# Если команда brew существует в системе
if type brew &>/dev/null; then
    # brew --prefix вернет /opt/homebrew на реальном Mac
    # и /usr/local (или нужный путь) внутри виртуальной машины
    fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fi

# Подключаем кастомную папку автодополнений
fpath=($HOME/.zsh/completion $fpath)

# Настройка кэширования для быстрых автодополнений (Tab)
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Включаем compinit РАНО, чтобы появилась функция compdef и не было ошибок
autoload -U compinit && compinit -i

# Antidote (Загружаем плагины)
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# Инициализируем автодополнения
compinit

# --- Настройки fzf и fzf-widgets ---
export FZF_TMUX=0
# Настройка внешнего вида (на весь экран и список сверху вниз)
export FZF_DEFAULT_OPTS="--height 100% --reverse"

# Настройки fd
# Включаем fd для поиска в fzf-widgets (чтобы искало моментально)
export FZF_WIDGETS_FIND_COMMAND="fd"
export FZF_WIDGET_FIND_COMMAND="fd"
# Глобальный поиск файлов через fd (игнорирует hidden и .git папки, чтобы не лагать)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
# Применяется, когда ищем файлы внутри командной строки
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Настройка точного совпадения для истории
declare -p FZF_WIDGETS_OPTS > /dev/null 2>&1 && FZF_WIDGETS_OPTS[insert-history]="--exact"
declare -p FZF_WIDGET_OPTS > /dev/null 2>&1 && FZF_WIDGET_OPTS[insert-history]="--exact"

# --- Опции истории Zsh ---
setopt HIST_IGNORE_ALL_DUPS   # Удаляем старые дубликаты
setopt HIST_IGNORE_SPACE      # Не сохраняем команды с пробелом в начале
setopt HIST_REDUCE_BLANKS     # Удалять лишние пробелы из команд перед сохранением

# Настройки сквозной истории между вкладками
setopt INC_APPEND_HISTORY     # Команда записывается в историю сразу после нажатия Enter
setopt SHARE_HISTORY          # Вкладки делятся историей в реальном времени

# Хоткеи
bindkey '^r' fzf-insert-history # fzf-insert-history по нажатию Ctrl + R (быстрый поиск команд по истории)
bindkey '^t' fzf-insert-files   # fzf-insert-files по нажатию Ctrl + T (быстрый поиск файлов)

# Настройки zsh-autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=15        # Отсекает автодополнение для длинных вставок (больше 15-ти символов)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"  # Цвет текста-подсказки (темно-серый/графитовый цвет)

# Инициализация утилиты zoxide/z
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Алиасы
alias 'ls'="eza --icons=always"
alias 'll'="eza -lAgi --group-directories-first --classify=always --icons=always --time-style=long-iso"
alias 'tree'="eza --tree --icons=always --group-directories-first"

alias 'cat'="bat -pp"

alias 'less'="bat --pager 'less -R'"

alias 'rm'="trash"

alias 'copy'="pbcopy"

alias 'k'="kubectl"
alias 'kctx'="kubectx"
alias 'kns'="kubens"

alias 'man'='tldr'

# Управление Docker-окружением (Colima)
alias 'dstart'="colima start --cpus 4 --memory 8 --disk 60"
alias 'dstop'="colima stop"
alias 'dstat'="colima status"

# Подключаю свою тему
source ~/.zsh-my-gnzh-theme.zsh-theme

# --- Кастомные функции ---
# path - Вывод полных путей для файлов, папок и шаблонов (масок)
# Использование: path имя_файла или path шаблон*
path_run() {
  if [[ -z "$1" ]]; then
    echo "Использование: path шаблон или path папка/шаблон"
    return 1
  fi

  local arg="$1"

  # 1. Отсекаем финальный слэш, если только это не корень "/"
  # Это спасает от превращения 'folder/' в 'folder/*'
  if [[ "$arg" != "/" && "$arg" == */ ]]; then
    arg="${arg%/}"
  fi

  local search_dir="."
  local pattern="$arg"

  # 2. Если в аргументе есть слэш (например, path/to/folder или Desktop/*)
  if [[ "$arg" == */* ]]; then
    search_dir="${arg%/*}"
    [[ -z "$search_dir" ]] && search_dir="/"
    
    pattern="${arg##*/}"
    [[ -z "$pattern" ]] && pattern="*"
  fi

  # 3. Сначала выводим директории (--type d)
  fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "$pattern" --type d "$search_dir"
  
  # 4. Затем выводим всё остальное, кроме директорий (--type f)
  fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "$pattern" --type f "$search_dir"
}

# Алиас для работы, который защищает звездочки от Zsh
alias path='noglob path_run'

# Привязка автодополнения (Tab работает как у cd/ls)
compdef _files path path_run

# cpath - Как path только копирует вывод в буфер обмена
# Функция-обертка для копирования
cpath_run() {
  # Если аргументов нет, вызываем без pbcopy, чтобы сообщение об ошибке вывелось на экран
  if [[ -z "$1" ]]; then
    path_run
    return 1
  fi

  # Захватываем вывод функции в переменную (баш автоматически отрезает финальные \n при таком захвате)
  local current_path
  current_path=$(path_run "$@")

  # Через printf передаем строку строго БЕЗ \n в конце прямо в pbcopy
  printf "%s" "$current_path" | pbcopy

  echo "✅ Скопировано в буфер обмена"
}

# Алиас для cpath с такой же защитой звездочек
alias cpath='noglob cpath_run'

# Привязка автодополнения для функции и алиаса
compdef _files cpath cpath_run
