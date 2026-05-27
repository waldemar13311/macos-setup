# --- Кастомные функции ---
# === path ===
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

# === cpath ===
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

# === iconclean ===
# очищает stdout от специальных unicode символов
# Пример использования: tree .config | iconclean
iconclean() {
    perl -CS -pe 's/[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFF}]\s?//g'
}

# === my_pbcopy ===
# Функция-обертка для копирования
my_pbcopy() {
    pbcopy

    echo "✅ Скопировано в буфер обмена"
}
