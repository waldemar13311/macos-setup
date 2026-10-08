# --- Кастомная тема ---
# Based on bira theme
setopt prompt_subst

# Промпт без жирности (%B...%b убраны): жирный остаётся инструментам - grep,
# bat и т.д. (терминальная настройка bold включена), а строки промпта - обычные.
# Цвета - bright-половина ANSI-палитры (8-15: green=10, red=9, cyan=14,
# yellow=11): обычные 0-7 в тёмных темах заметно тусклее, а раньше это
# компенсировала жирность. Исключение - каталог (177, #d787ff - светлый
# лавандово-розовый): 256-цветный индекс вместо слота палитры, чтобы цвет
# был одинаковый в Apple Terminal и VSCode (слоты 0-15 каждый терминал
# красит своим RGB из своей темы)

() {

local PR_USER PR_USER_OP PR_PROMPT PR_HOST

# Check the UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{10}%n%f'
  PR_USER_OP='%F{10}%#%f'
  PR_PROMPT='%f➤ %f'
else # root
  PR_USER='%F{9}%n%f'
  PR_USER_OP='%F{9}%#%f'
  PR_PROMPT='%F{9}➤ %f'
fi

# Check if we are on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{10}%M%f' # SSH
else
  if [[ $UID -ne 0 ]]; then
    PR_HOST='%F{10}%M%f'
  else
    PR_HOST='%F{9}%M%f'
  fi
fi

local user_host="${PR_USER}%F{14}@${PR_HOST}"
local current_dir="%F{177}%~%f"
local git_branch='$(git_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)'

PROMPT="╭─${venv_prompt}${user_host} ${current_dir} \$(ruby_prompt_info) ${git_branch}
╰─$PR_PROMPT "

ZSH_THEME_GIT_PROMPT_PREFIX="%F{11}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{9}✗%F{11}"
ZSH_THEME_RUBY_PROMPT_PREFIX="%F{9}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%f"
ZSH_THEME_VIRTUALENV_PREFIX="%F{9}("
ZSH_THEME_VIRTUALENV_SUFFIX=")%f "

}
