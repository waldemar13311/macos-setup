# --- Переменные ---

# Консольный редактор по умолчанию
export EDITOR="vim"

# Исполняемые файлы пользователя
export PATH="$HOME/.local/bin:$PATH"
# curl из homebrew, так как стандартный mac-овский не удобный
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Зеркала для tenv
export TENV_TERRAFORM_REMOTE="https://hashicorp-releases.yandexcloud.net"
export TENV_OPENTOFU_REMOTE="https://github.com/opentofu/opentofu/releases/download"

setopt NOBEEP               # Убрать звуки терминала
setopt NUMERIC_GLOB_SORT    # Умная сортировка файлов с цифрами (file10 после file9, не после file1)
