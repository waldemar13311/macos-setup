# --- Переменные ---

# Оформление выделенной строки fzf. Общая настройка для fzf_options.zsh и
# zoxide_options.zsh - менять в одном месте:
#   --highlight-line        - закрашивать строку на всю ширину экрана
#   --color=bg+:...,fg+:... - фон и текст выделенной строки
export FZF_HIGHLIGHT_LINE_OPTS="--highlight-line --color=bg+:#49483E,fg+:#F8F8F2"

# Консольный редактор по умолчанию
export EDITOR="vim"

# Исполняемые файлы пользователя
export PATH="$HOME/.local/bin:$PATH"
# curl из homebrew, так как стандартный mac-овский не удобный
# /opt/homebrew - на Apple Silicon,
# /usr/local - на Intel Mac
if [[ -d "/opt/homebrew/opt/curl/bin" ]]; then
    export PATH="/opt/homebrew/opt/curl/bin:$PATH"
elif [[ -d "/usr/local/opt/curl/bin" ]]; then
    export PATH="/usr/local/opt/curl/bin:$PATH"
fi

# Зеркала для tenv
export TENV_TERRAFORM_REMOTE="https://hashicorp-releases.yandexcloud.net"
export TENV_OPENTOFU_REMOTE="https://github.com/opentofu/opentofu/releases/download"

setopt NOBEEP               # Убрать звуки терминала
setopt NUMERIC_GLOB_SORT    # Умная сортировка файлов с цифрами (file10 после file9, не после file1)
