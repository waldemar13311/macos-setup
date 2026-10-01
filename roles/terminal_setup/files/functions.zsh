# --- Кастомные функции ---

# region === path ===
# path - Вывод полных путей для файлов, папок и шаблонов (масок)
# Использование: path имя_файла или path шаблон*
# В терминал выводится с финальным \n, а в пайп (| copy) - без него,
# чтобы в буфер обмена попадал чистый путь.
path_run() {
  if [[ -z "$1" ]]; then
    echo "Использование: path шаблон или path папка/шаблон"
    return 1
  fi

  local arg="$1"

  # 1. Точка и «точка-точка» - просто выдаем абсолютный путь текущей
  # или родительской директории
  if [[ "$arg" == "." || "$arg" == ".." ]]; then
    local target="${arg:a}"

    # В терминал отдаем через fd - он сам раскрасит директорию так же,
    # как и в основном выводе (папки берюзовым)
    if [[ -t 1 && "$target" != "/" ]]; then
      fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "${target:t}" --type d "${target:h}"
      return 0
    fi

    # В пайп - чистый путь без \n
    printf '%s' "$target"
    return 0
  fi

  # 2. Отсекаем финальный слэш, если только это не корень "/"
  # Это спасает от превращения 'folder/' в 'folder/*'
  if [[ "$arg" != "/" && "$arg" == */ ]]; then
    arg="${arg%/}"
  fi

  # 3. Если в аргументе нет метасимволов (*, ?, [) - это конкретный путь.
  # Проверяем существование: если пути нет, сообщаем об этом так же, как cd
  if [[ "$arg" != *[*\?\[]* ]]; then
    if [[ ! -e "$arg" ]]; then
      echo "path: no such file or directory: $arg" >&2
      return 1
    fi

    # Нормализуем путь (схлопывает '.', '..', 'dir/.'): macos-setup/. -> .../macos-setup.
    # Без этого fd с glob-именем "." ничего не найдет
    local target="${arg:a}"

    # В терминал отдаем через fd - он раскрасит путь (папки берюзовым,
    # файлы по LS_COLORS), как и в основном выводе
    if [[ -t 1 && "$target" != "/" ]]; then
      fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "${target:t}" --type d "${target:h}"
      fd --hidden --no-ignore --absolute-path --max-depth 1 --glob "${target:t}" --type f "${target:h}"
      return 0
    fi

    # В пайп - чистый путь без \n (для "/" fd не подходит, см. выше)
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

  # 5. Если каталог из шаблона не существует (например, path nodir/*.zsh) -
  # сообщаем об этом так же, как это делает cd, и выходим
  if [[ ! -d "$search_dir" ]]; then
    echo "path: no such file or directory: $search_dir" >&2
    return 1
  fi

  # 6. Захватываем вывод fd: в терминале - с --color=always (иначе fd, увидев
  # пайп, сбросит раскраску), в пайп - без цвета
  local color_flag=()
  [[ -t 1 ]] && color_flag=(--color=always)

  local output
  output="$(
    fd --hidden --no-ignore --absolute-path --max-depth 1 "${color_flag[@]}" --glob "$pattern" --type d "$search_dir"
    fd --hidden --no-ignore --absolute-path --max-depth 1 "${color_flag[@]}" --glob "$pattern" --type f "$search_dir"
  )"

  # 7. Шаблон не совпал ни с чем - сообщаем, как это делает zsh для cd
  if [[ -z "$output" ]]; then
    echo "path: no matches found: $arg" >&2
    return 1
  fi

  # 8. Печатаем: в терминал с \n, в пайп - без него
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
# Функция-обертка для копирования (на неё есть алиас).
# macOS - pbcopy; Linux - wl-copy (Wayland) или xclip (X11)
my_pbcopy() {
    if (( $+commands[pbcopy] )); then
        pbcopy
    elif (( $+commands[wl-copy] )); then
        wl-copy
    elif (( $+commands[xclip] )); then
        xclip -in -selection clipboard
    else
        echo "❌ Не найдена утилита буфера обмена (pbcopy/wl-copy/xclip)" >&2
        return 1
    fi

    echo "✅ Скопировано в буфер обмена"
}
# endregion

# region === my_pbpaste ===
# Функция-обертка для вставки из буфера (на неё есть алиас paste).
# Выводит содержимое буфера обмена в stdout без украшений - рассчитана
# на пайпы (paste | grep ...). macOS - pbpaste; Linux - wl-paste (Wayland)
# или xclip (X11)
my_pbpaste() {
    if (( $+commands[pbpaste] )); then
        pbpaste
    elif (( $+commands[wl-paste] )); then
        # --no-newline: не добавлять \n, если в буфере его нет (как у pbpaste)
        wl-paste --no-newline
    elif (( $+commands[xclip] )); then
        xclip -out -selection clipboard
    else
        echo "❌ Не найдена утилита буфера обмена (pbpaste/wl-paste/xclip)" >&2
        return 1
    fi
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

    echo "Ошибка подключения. Повтор через 3 секунды...\n"
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

# region === ansible-project-init ===
# ansible-project-init - Создает в новой папке скелет простого ansible-проекта
# на основе шаблона из ~/.config/zsh/templates-for-functions/ansible-project-init
# (структура повторяет этот репозиторий: macos-setup).
# Сам шаблон лежит в macos-setup: roles/terminal_setup/files/templates-for-functions/ansible-project-init
# и раскладывается ролью terminal_setup - правим структуру там.
# Имя проекта подставляется в pyproject.toml (name, description) и README.md.
# Использование:
#   ansible-project-init имя_проекта - создать папку имя_проекта и развернуть шаблон в ней
#                                      (имя можно с путём: ~/play/my-project)
#   ansible-project-init .           - развернуть шаблон в текущей папке,
#                                      имя проекта берется из имени папки
ansible-project-init() {
  emulate -L zsh

  if [[ -z "$1" ]]; then
    echo "Использование: ansible-project-init имя_проекта | ansible-project-init ."
    return 1
  fi

  local target project_name

  # "." - инициализация в текущей папке: имя проекта = имя текущего каталога
  if [[ "$1" == "." ]]; then
    target="$PWD"
    [[ "$target" == "/" ]] && {
      echo "ansible-project-init: инициализация в корне '/' - так нельзя" >&2
      return 1
    }
    project_name="${target:t}"

    # Разворачиваем только в пустую папку - чтобы случайно не засорить чужой проект
    if [[ -n "$(command ls -A "$target")" ]]; then
      echo "ansible-project-init: '$target' не пуста" >&2
      return 1
    fi
  else
    target="${1:a}"          # нормализуем путь (схлопывает '.', '..')
    project_name="${target:t}"

    # Не трогаем существующую папку
    if [[ -e "$target" ]]; then
      echo "ansible-project-init: '$target' уже существует" >&2
      return 1
    fi
    mkdir -p "${target:h}" || {
      echo "ansible-project-init: не удалось создать каталог '${target:h}'" >&2
      return 1
    }
  fi

  # Имя проекта попадает в pyproject.toml ([project] name) - поэтому оно должно
  # быть валидным python-именем: строчные латинские буквы, цифры, дефис,
  # начинаться с буквы (uv sync упадет уже после генерации, если имя невалидное)
  if [[ ! "$project_name" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "ansible-project-init: некорректное имя проекта: '$project_name'" >&2
    echo "Допустимы: строчные латинские буквы, цифры и дефис, начинаются с буквы" >&2
    return 1
  fi

  local -r template_dir="${ZDOTDIR:-$HOME/.config/zsh}/templates-for-functions/ansible-project-init"

  if [[ ! -d "$template_dir" ]]; then
    echo "ansible-project-init: шаблон не найден: $template_dir" >&2
    echo "Запустите плейбук playbooks/terminal_setup.ansible.yml, чтобы его развернуть" >&2
    return 1
  fi

  # Копируем шаблон (для "." - содержимое шаблона в текущую папку).
  # Служебные папки (.claude, .venv и др.) в шаблон не входят намеренно -
  # но на случай, если завелись, исключаем их из копирования
  cp -R "$template_dir"/ "$target"/ || {
    echo "ansible-project-init: не удалось скопировать шаблон в '$target'" >&2
    return 1
  }
  /bin/rm -rf "$target"/.claude "$target"/.venv

  # Подставляем имя проекта вместо плейсхолдера во всех файлах.
  # perl (а не sed) - чтобы работало одинаково на macOS (BSD sed) и Linux (GNU sed):
  # у них несовместимый синтаксис -i. Имя передаем через env - безопаснее интерполяции в код
  PNAME="$project_name" command find "$target" -type f \
    -exec perl -pi -e 's/__PROJECT_NAME__/$ENV{PNAME}/g' {} +

  echo "✅ Ansible проект '$project_name' успешно создан: $target\n"

  echo "Итоговая структура в виде дерева:"
  tree "$target"
}

compdef _arguments ansible-project-init '1:имя проекта: '
# endregion

# Сообщение пользователю: из zle-виджета через zle -M, иначе print (для тестов)
_history-widget-msg() {
  if (( $+ZLE_VERSION )); then
    zle -M "$1"
  else
    print -r -- "$1" >&2
  fi
}

# region === fzf-find-delete-history ===
# fzf-find-delete-history - Поиск по истории через fzf (замена fzf-insert-history по Ctrl+R)
# с возможностью удалить выбранную команду из истории:
#   Enter     - вставить команду в строку ввода (как обычно)
#   fn+Delete - удалить команду из истории (файл) прямо внутри открытой fzf-сессии:
#               fzf сам перезагружает список (reload), без переоткрытия и мерцания
#
# fn+Delete на Mac-клавиатуре = forward-delete (\e[3~), терминалы передают его
# приложению без настройки.
#
# Механика: fzf --bind="delete:reload(...)" по нажатию delete запускает скрипт
# history_delete_event.zsh (удаляет событие из HISTFILE и печатает обновлённый
# список) и мгновенно подменяет данные, не закрываясь. После выхода из fzf
# память сессии перечитывается из файла через fc -p.
# ВАЖНО: --expect=delete использовать нельзя - он несовместим с --bind на той же
# клавише и перехватывает нажатие, из-за чего reload не срабатывает.
fzf-find-delete-history() {
  emulate -L zsh

  if [[ -z "$HISTFILE" || ! -f "$HISTFILE" ]]; then
    _history-widget-msg "HISTFILE не найден - удаление из истории недоступно"
    return 1
  fi

  local query="$LBUFFER"
  local fzf_out cmd

  fzf_out="$(
    fc -l 1 2>/dev/null | fzf --tac --tiebreak=index \
      --exact \
      --query="$query" +m \
      --bind="delete:reload(zsh ${(q)${ZDOTDIR:-$HOME/.config/zsh}}/history_delete_event.zsh {1} {})" \
      --header="Enter - вставить | fn+Del - удалить из истории"
  )"

  # fzf завершился: синхронизируем память сессии с файлом (внутри fzf могли быть
  # удаления). ВАЖНО сделать при ЛЮБОМ выходе (Enter/Esc) - иначе при закрытии
  # шелла INC_APPEND_HISTORY_TIME перезапишет файл устаревшей памятью и удаления
  # потеряются
  builtin fc -p "$HISTFILE" "$HISTSIZE" "$SAVEHIST"

  # fzf_out пуст (Esc) - выходим без изменений
  [[ -z "$fzf_out" ]] && {
    BUFFER="$query"
    CURSOR=$#BUFFER
    zle redisplay
    return 0
  }

  # Enter: fzf_out = выбранная строка "  42  cmd..."
  # Вырезаем номер события и * (маркер измененной записи): "  42  cmd..." -> "cmd..."
  cmd="$(print -r -- "$fzf_out" | sed -E 's/^ *[0-9]+\*?  ?//')"

  # Обычная вставка выбранной команды
  BUFFER="$cmd"
  CURSOR=$#BUFFER
  zle redisplay
}

zle -N fzf-find-delete-history
# endregion

# region === sudo wrapper ===
# sudo - Обёртка над sudo: при запуске vim под root пробрасывает VIMINIT,
# иначе vim от root остаётся вообще без конфига (sudo очищает окружение,
# VIMINIT из .zshenv не наследуется) - нет ни темы, ни подсветки.
# Все остальные команды идут через обычный sudo без изменений.
# С флагами (sudo -H vim ...) тоже работает: vim ищется среди аргументов
sudo() {
  local -a args=()
  local arg found_vim=0

  for arg in "$@"; do
    if [[ "$arg" == vim ]]; then
      found_vim=1
      args+=(VIMINIT="source $HOME/.config/vim/.vimrc" vim)
    else
      args+=("$arg")
    fi
  done

  if (( found_vim )); then
    command sudo "${args[@]}"
  else
    command sudo "$@"
  fi
}
# endregion
