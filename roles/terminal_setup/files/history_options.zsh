# --- Опции истории Zsh ---
export HISTFILE="$XDG_STATE_HOME/zsh/history" # Путь к файлу с историей команд

HISTSIZE=10000 # Помнить 10 тысяч команд в текущей сессии
SAVEHIST=10000 # Сохранять 10 тысяч команд в файл истории на диске

setopt HIST_IGNORE_DUPS       # Не записывать команду, если она совпадает с предыдущей
setopt HIST_IGNORE_ALL_DUPS   # Удаляем дубликаты
setopt HIST_IGNORE_SPACE      # Не сохраняем команды с пробелом в начале
setopt HIST_REDUCE_BLANKS     # Удалять лишние пробелы из команд перед сохранением

# Настройки истории между вкладками
unsetopt SHARE_HISTORY        # Отключаем агрессивный шаринг между вкладками
unsetopt INC_APPEND_HISTORY   # Отключаем мгновенную запись в файл после нажатия Enter

setopt APPEND_HISTORY         # Включаем классическое добавление при закрытии сессии

# Сохранять историю ПЕРЕД выполнением команды,
# но НЕ импортировать её в другие открытые окна
setopt INC_APPEND_HISTORY_TIME
