source "$ZDOTDIR/variables.zsh"

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
fpath=($ZDOTDIR/completion $fpath)

# Настройка кэширования для быстрых автодополнений (Tab)
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Включаем compinit РАНО, чтобы появилась функция compdef и не было ошибок
autoload -U compinit && compinit -i

# Antidote (Загружаем плагины)
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# Инициализируем автодополнения
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"

source "$ZDOTDIR/fzf_options.zsh"

source "$ZDOTDIR/history_options.zsh"

source "$ZDOTDIR/hotkeys.zsh"

# Настройки zsh-autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=15        # Отсекает автодополнение для длинных вставок (больше 15-ти символов)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"  # Цвет текста-подсказки (темно-серый/графитовый цвет)

# Настройки для внешнего вида zi
export _ZO_FZF_OPTS="--height 100% --layout=reverse --border --preview-window=35% --preview='eza -1 --icons=always --color=always {2} 2>/dev/null || ls -1 --color=always {2} 2>/dev/null'"

# Инициализация утилиты zoxide/z
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

source "$ZDOTDIR/alias.zsh"

source "$ZDOTDIR/functions.zsh"

source "$ZDOTDIR/zsh-my-gnzh-theme.zsh-theme"
