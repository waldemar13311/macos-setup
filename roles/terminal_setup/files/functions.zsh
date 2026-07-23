# --- Кастомные функции ---

# region === path ===
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
#endregion

# region === cpath ===
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
#endregion

# region === iconclean ===
# iconclean - очищает stdout от специальных unicode символов
# Пример использования: tree .config | iconclean
iconclean() {
    perl -CS -pe 's/[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFF}]\s?//g'
}
# endregion

# region === my_pbcopy ===
# Функция-обертка для копирования (на неё есть алиас)
my_pbcopy() {
    pbcopy

    echo "✅ Скопировано в буфер обмена"
}
# endregion

# region === tree wrapper ===
# tree - Умная обёртка над eza для вывода красивого дерева с поддержкой флага -i/--ignore
tree() {
  local root=""
  local -a ignore_list=()
  local -a eza_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--ignore)
        if [[ -n "$2" && "$2" != -* ]]; then
          ignore_list+=("$2")
          shift 2
        else
          echo "Ошибка: флаг $1 требует аргумент." >&2
          return 1
        fi
        ;;
      -i=*|--ignore=*)
        ignore_list+=("${1#*=}")
        shift
        ;;
      -*)
        eza_args+=("$1")
        shift
        ;;
      *)
        if [[ -z "$root" ]]; then
          root="$1"
        else
          echo "Ошибка: указано слишком много аргументов ($1)" >&2
          return 1
        fi
        shift
        ;;
    esac
  done

  root="${root:-.}"

  # Добавляем --ignore-glob только если список исключений не пустой
  if [[ ${#ignore_list[@]} -gt 0 ]]; then
    eza_args+=("--ignore-glob=${(j:|:)ignore_list}")
  fi

  command eza --tree -A \
    --classify=always \
    --icons=always \
    --group-directories-first \
    "${eza_args[@]}" \
    "$root"
}

_tree_wrapper() {
  _arguments -s \
    '*'{-i,--ignore}'[Игнорировать файл или каталог]:паттерн:_files' \
    '*:аргументы:_files'
}
compdef _tree_wrapper tree
# endregion

# region === treecat ===
# treecat - Вывод дерева каталога и содержимого файлов с возможностью игнорирования
# Использование: treecat [-i|--ignore <название>] [каталог]
treecat() {
  local root=""
  local -a ignore_dirs=()
  local item

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--ignore)
        if [[ -n "$2" && "$2" != -* ]]; then
          ignore_dirs+=("$2")
          shift 2
        else
          echo "Ошибка: флаг $1 требует аргумент." >&2
          return 1
        fi
        ;;
      -i=*|--ignore=*)
        ignore_dirs+=("${1#*=}")
        shift
        ;;
      -*)
        echo "Неизвестный флаг: $1" >&2
        return 1
        ;;
      *)
        if [[ -z "$root" ]]; then
          root="$1"
        else
          echo "Ошибка: указано слишком много аргументов ($1)" >&2
          return 1
        fi
        shift
        ;;
    esac
  done

  root="${root:-.}"

  local -a tree_args=()
  if [[ ${#ignore_dirs[@]} -gt 0 ]]; then
    tree_args+=("-I" "${(j:|:)ignore_dirs}")
  fi
  tree "${tree_args[@]}" "$root"

  dump_dir() {
    local current_dir="$1"
    local -a items dirs files
    local item ignore_name

    items=(
      "$current_dir"/*(N)
      "$current_dir"/.*(N)
    )

    for item in "${items[@]}"; do
      [[ "${item:t}" == "." || "${item:t}" == ".." ]] && continue

      for ignore_name in "${ignore_dirs[@]}"; do
        [[ "${item:t}" == "$ignore_name" ]] && continue 2
      done

      if [[ -d "$item" ]]; then
        dirs+=("$item")
      else
        files+=("$item")
      fi
    done

    dirs=(${(on)dirs})
    files=(${(on)files})

    for item in "${dirs[@]}"; do
      dump_dir "$item"
    done

    for item in "${files[@]}"; do
      echo
      echo "========================================"
      echo "=== Файл: $item ==="
      echo "========================================"
      echo

      if file --brief --mime "$item" | grep -qE '^text/|/json|/javascript'; then
        bat --style=plain --paging=never "$item"
      else
        echo "[binary file skipped]"
      fi
    done
  }

  dump_dir "$root"
}

_treecat() {
  _arguments -s \
    '*'{-i,--ignore}'[Игнорировать файл или каталог]:паттерн:_files' \
    '1:каталог:_files -/'
}
compdef _treecat treecat
# endregion

# region === tryssh ===
# tryssh - Аналог ssh (ssh в цикле), который не отваливается по таймауту,
# а просто заново начинает подключение (удобно при перезагрузке сервера).
# 1. Сама функция с циклом
tryssh () {
  # Ищем хост: берем последний аргумент, не начинающийся с дефиса,
  # и убираем из него "user@", если он есть
  local hostname
  for arg in "$@"; do
    [[ "$arg" != -* ]] && hostname="${arg##*@}"
  done

  echo "Подключение к ${hostname}..."

  while true; do
    # Пытаемся выполнить ssh со всеми переданными аргументами
    ssh "$@"

    # Получаем код возврата (255 обычно означает ошибку связи)
    local status=$?

    if [ $status -ne 255 ]; then
      # Если код не 255, значит подключение состоялось и мы вышли сами
      break
    fi

    echo "Ошибка подключения. Повтор через 3 секунды..."
    sleep 3
  done
}

# 2. Копирование автодополнения от ssh к tryssh (для Zsh)
if [ -n "$ZSH_VERSION" ]; then
  compdef tryssh=ssh
fi
# endregion

# region === http-proxy-vars-example ===
# http-proxy-vars-example - Выводит, какие переменные нужно задать для использования http прокси в терминале
http-proxy-vars-example () {
  echo 'Для использования http proxy в терминале задайте переменные по аналогии:'
  echo 'export http_proxy="http://myuser:mypassword123@proxy.home:3128 # для http сайтов'
  echo 'export https_proxy="http://myuser:mypassword123@proxy.home:3128 # для https сайтов'
}
# endregion
