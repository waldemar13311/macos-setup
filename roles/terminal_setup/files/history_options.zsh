# --- Опции истории Zsh ---
export HISTFILE="$XDG_STATE_HOME/zsh/history" # Путь к файлу с историей команд

HISTSIZE=10000 # Помнить 10 тысяч команд в текущей сессии
SAVEHIST=10000 # Сохранять 10 тысяч команд в файл истории на диске

setopt HIST_IGNORE_ALL_DUPS   # Удаляем дубликаты
setopt HIST_IGNORE_SPACE      # Не сохраняем команды с пробелом в начале
setopt HIST_REDUCE_BLANKS     # Удалять лишние пробелы из команд перед сохранением

# Настройки сквозной истории между вкладками
setopt INC_APPEND_HISTORY     # Команда записывается в историю сразу после нажатия Enter
setopt SHARE_HISTORY          # Вкладки делятся историей в реальном времени
