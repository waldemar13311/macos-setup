#!/bin/zsh
# history_delete_event.zsh <event_num> <fc_line>
# Удаляет событие <event_num> из файла истории $HISTFILE и печатает обновлённый
# список в формате fc -l. Используется виджетом fzf-find-delete-history (Ctrl+R):
#   fzf --bind="delete:reload(zsh $ZDOTDIR/history_delete_event.zsh {1} {...})"
# — удаление происходит внутри открытой fzf-сессии (без переоткрытия и мерцания).
#
# Событие N = N-я extended-запись файла (строка ": <ts>:<dur>;<команда>") —
# сверено с нумерацией fc на реальном файле истории.
# Многострочные записи (строка с trailing backslash + следующая) удаляются целиком.
# Текст выбранной строки (<fc_line>) — предохранитель от рассинхрона нумерации:
# если текст записи не совпал, ищем по тексту; не нашли (битая кодировка, которую
# fc «чинит» при чтении) — удаляем по номеру: запись выбрана явно.

emulate -L zsh
local event_num="$1"
local fc_line="$2"

# Печатаем текущий список истории (это новый источник данных для fzf reload)
_print_list() {
  HISTSIZE=200000 SAVEHIST=200000
  builtin fc -R "$HISTFILE"
  fc -l 1
}

[[ -n "$HISTFILE" && -f "$HISTFILE" && -s "$HISTFILE" ]] || exit 0

# head выбранной строки: без номера события и без литерала " \n" (хвост
# многострочной записи в fc-виде)
local target_head="$(print -r -- "$fc_line" | sed -E 's/^ *[0-9]+\*?  ?//')"
if [[ "$target_head" == *" \\n"* ]]; then
  target_head="${target_head%% \\n*}"
fi

# Формат файла: extended (": "-строки) или простой
local is_extended=0 first_line
{ IFS= read -r first_line && [[ "$first_line" == ": "* ]]; } < "$HISTFILE" && is_extended=1

# Проход: собираем записи (диапазоны строк + текст первой строки)
typeset -a rec_starts rec_ends rec_first_lines
rec_starts=() rec_ends=() rec_first_lines=()
local l lineno=0 cand_start=0 pending=0 rec_no=0 cand_first_line=""
while IFS= read -r l; do
  (( lineno++ ))
  if (( pending )); then
    # строка-продолжение предыдущей записи; если она сама кончается на backslash —
    # цепочка продолжается (многострочная запись может быть длиннее двух строк)
    if [[ "$l" == *\\ ]]; then
      pending=1
      continue
    fi
    pending=0
    rec_ends[$rec_no]=$lineno
    rec_first_lines[$rec_no]="$cand_first_line"
    continue
  fi
  if (( is_extended )) && [[ "$l" != ": "* ]]; then
    # строка-продолжение без ": " в extended-файле — пропускаем
    continue
  fi
  cand_start=$lineno
  (( rec_no++ ))
  local cmd_line="$l"
  if [[ "$cmd_line" == ": "*";"* ]]; then
    cmd_line="${cmd_line#*;}"
  fi
  cand_first_line="${cmd_line%\\}"
  rec_starts[$rec_no]=$lineno
  if [[ "$l" == *\\ ]]; then
    pending=1
  else
    rec_ends[$rec_no]=$lineno
    rec_first_lines[$rec_no]="$cand_first_line"
  fi
done < "$HISTFILE"

local del_start=0 del_end=0
if [[ "$event_num" == <-> && "$event_num" -ge 1 && "$event_num" -le $rec_no ]]; then
  del_start="${rec_starts[$event_num]}"
  del_end="${rec_ends[$event_num]}"
  # Предохранитель: сверяем текст записи с ожидаемым
  if [[ -n "$target_head" && "${rec_first_lines[$event_num]}" != "$target_head" ]]; then
    # нумерация разъехалась — ищем запись по тексту
    local i text_found=0
    for (( i=1; i<=rec_no; i++ )); do
      if [[ "${rec_first_lines[$i]}" == "$target_head" ]]; then
        del_start="${rec_starts[$i]}"
        del_end="${rec_ends[$i]}"
        text_found=1
        break
      fi
    done
    # текст не нашли (напр., битая кодировка) — оставляем номерную запись
  fi
elif [[ -n "$target_head" ]]; then
  # номера нет/вне диапазона — чистый текстовый поиск
  local i
  for (( i=1; i<=rec_no; i++ )); do
    if [[ "${rec_first_lines[$i]}" == "$target_head" ]]; then
      del_start="${rec_starts[$i]}"
      del_end="${rec_ends[$i]}"
      break
    fi
  done
fi

(( del_start )) && sed -i "" "${del_start},${del_end}d" "$HISTFILE"

_print_list
