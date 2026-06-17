# Соответствие стандарту XDG Base Directory
# Централизованные директории для config/cache/data
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"

# Домашняя папка для конфигов Zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Настройки vim
export VIMINIT='source $XDG_CONFIG_HOME/vim/.vimrc'

# Нужно для ansible
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
