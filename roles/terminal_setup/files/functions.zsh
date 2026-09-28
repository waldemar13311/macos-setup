# --- Кастомные функции ---

# region === path ===
# path - Вывод полных путей для файлов, папок и шаблонов (масок)
# Использование: path имя_файла или path шаблон*
# В терминал выводится с финальным \n, а в пайп (| copy) — без него,
# чтобы в буфер обмена попадал чистый путь.
path_run() {
  if [[ -z "$1" ]]; then
    echo "Использование: path шаблон или path папка/шаблон"
    return 1
  fi

  local arg="$1"

  # 1. Точка и «точка-точка» — просто выдаем абсолютный путь текущей
  # или родительской директории
  if [[ "$arg" == "." || "$arg" == ".." ]]; then
    local target="${arg:a}"

    # В терминал отдаем через fd — он сам раскрасит директорию так же,
    # как и в основном выводе (папки берюзовым)
    if [[ -t 1 && "$target" != "/" ]]; then
      fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "${target:t}" --type d "${target:h}"
      return 0
    fi

    # В пайп — чистый путь без \n
    printf '%s' "$target"
    return 0
  fi

  # 2. Отсекаем финальный слэш, если только это не корень "/"
  # Это спасает от превращения 'folder/' в 'folder/*'
  if [[ "$arg" != "/" && "$arg" == */ ]]; then
    arg="${arg%/}"
  fi

  # 3. Если в аргументе нет метасимволов (*, ?, [) — это конкретный путь.
  # Проверяем существование: если пути нет, сообщаем об этом так же, как cd
  if [[ "$arg" != *[*\?\[]* ]]; then
    if [[ ! -e "$arg" ]]; then
      echo "path: no such file or directory: $arg" >&2
      return 1
    fi

    # Нормализуем путь (схлопывает '.', '..', 'dir/.'): macos-setup/. -> .../macos-setup.
    # Без этого fd с glob-именем "." ничего не найдет
    local target="${arg:a}"

    # В терминал отдаем через fd — он раскрасит путь (папки берюзовым,
    # файлы по LS_COLORS), как и в основном выводе
    if [[ -t 1 && "$target" != "/" ]]; then
      fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "${target:t}" --type d "${target:h}"
      fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "${target:t}" --type f "${target:h}"
      return 0
    fi

    # В пайп — чистый путь без \n (для "/" fd не подходит, см. выше)
    printf '%s' "$target"
    return 0
  fi

  # 4. Иначе это шаблон: делим аргумент на каталог и маску
  local search_dir="."
  local pattern="$arg"

  if [[ "$arg" == */* ]]; then
    search_dir="${arg%/*}"
    [[ -z "$search_dir" ]] && search_dir="/"

    pattern="${arg##*/}"
    [[ -z "$pattern" ]] && pattern="*"
  fi

  # 5. Если каталог из шаблона не существует (например, path nodir/*.zsh) —
  # сообщаем об этом так же, как это делает cd, и выходим
  if [[ ! -d "$search_dir" ]]; then
    echo "path: no such file or directory: $search_dir" >&2
    return 1
  fi

  # 6. Захватываем вывод fd: в терминале — с --color=always (иначе fd, увидев
  # пайп, сбросит раскраску), в пайп — без цвета
  local color_flag=()
  [[ -t 1 ]] && color_flag=(--color=always)

  local output
  output="$(
    fd --hidden --no-ignore --absolute-path --max-depth 1 "${color_flag[@]}" --glob "$pattern" --type d "$search_dir"
    fd --hidden --no-ignore --absolute-path --max-depth 1 "${color_flag[@]}" --glob "$pattern" --type f "$search_dir"
  )"

  # 7. Шаблон не совпал ни с чем — сообщаем, как это делает zsh для cd
  if [[ -z "$output" ]]; then
    echo "path: no matches found: $arg" >&2
    return 1
  fi

  # 8. Печатаем: в терминал с \n, в пайп — без него
  if [[ -t 1 ]]; then
    printf '%s\n' "$output"
  else
    printf '%s' "$output"
  fi
}

# Алиас для работы, который защищает звездочки от Zsh
alias path='noglob path_run'

# Привязка автодополнения (Tab работает как у cd/ls)
compdef _files path path_run
#endregion

# region === cpath ===
# cpath - Как path только копирует вывод в буфер обмена
# (path_run сама отдает вывод без \\n, когда stdout не терминал)
cpath_run() {
  # Если аргументов нет, вызываем без пайпа, чтобы usage вывелся на экран
  if [[ -z "$1" ]]; then
    path_run
    return 1
  fi

  # При ошибке path_run (нет пути/совпадений) ничего не копируем:
  # stderr path_run уже вывелся, а пайп вернул бы пустоту в буфер
  local output
  if ! output="$(path_run "$@")"; then
    return 1
  fi

  printf '%s' "$output" | my_pbcopy
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
# tryssh - Полный аналог ssh (те же флаги и автодополнение), который не отваливается
# по таймауту, а просто заново начинает подключение (удобно при перезагрузке сервера).
tryssh () {
  # 1. Ищем destination так же, как это делает ssh: первый аргумент после опций.
  # Нужно только для информационного сообщения.
  # Список опций ssh, требующих отдельного аргумента (по man ssh).
  local -r flags_with_arg='bcDeFiIiJLlmOopRSWw'

  local arg destination=''
  local -i skip_next=0
  for arg in "$@"; do
    if (( skip_next )); then
      skip_next=0
      continue
    fi
    if [[ "$arg" == -* ]]; then
      # Опция вида -X без слитного значения значит, что следующий
      # аргумент - её значение, а не destination
      if (( ${#arg} == 2 && ${flags_with_arg[(I)$arg[2]]} )); then
        skip_next=1
      fi
      continue
    fi
    # Первый не-опционный аргумент и есть хост; убираем "user@", если он есть
    destination="${arg##*@}"
    break
  done

  # 2. Если хост не найден (например, опечатка в опции) - просто вызываем ssh:
  # он сам покажет usage, и не надо вечно крутить цикл с ошибкой
  if [[ -z "$destination" ]]; then
    ssh "$@"
    return $?
  fi

  echo "Подключение к ${destination}..."

  while true; do
    # Пытаемся выполнить ssh со всеми переданными аргументами
    ssh "$@"

    # Получаем код возврата (255 обычно означает ошибку связи).
    # Не называем переменную status - в zsh это read-only спецпараметр ($?)
    local rc=$?

    if [ $rc -ne 255 ]; then
      # Если код не 255, значит подключение состоялось и мы вышли сами
      break
    fi

    echo "Ошибка подключения. Повтор через 3 секунды..."
    sleep 3
  done
}

# 3. Копирование автодополнения от ssh к tryssh (для Zsh)
if [ -n "$ZSH_VERSION" ]; then
  compdef tryssh=ssh
fi
# endregion

# region === http-proxy-vars-example ===
# http-proxy-vars-example - Выводит, какие переменные нужно задать для использования http прокси в терминале
http-proxy-vars-example () {
  echo 'Для использования http proxy в терминале задайте переменные по аналогии:'
  echo 'export http_proxy="http://myuser:mypassword123@proxy.home:3128" # для http сайтов'
  echo 'export https_proxy="http://myuser:mypassword123@proxy.home:3128" # для https сайтов'
}
# endregion

# region === https-proxy-vars-example ===
# https-proxy-vars-example - Выводит, какие переменные нужно задать для использования https прокси в терминале
https-proxy-vars-example () {
  echo 'Для использования https proxy в терминале задайте переменные по аналогии:'
  echo 'export http_proxy="https://myuser:mypassword123@proxy.home:3129" # для http сайтов'
  echo 'export https_proxy="https://myuser:mypassword123@proxy.home:3129" # для https сайтов'
}
# endregion
