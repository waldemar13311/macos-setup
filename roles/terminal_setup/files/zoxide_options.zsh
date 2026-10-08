# --- Настройки zoxide и внешний вид zi ---

# Настройки для внешнего вида zi (zoxide):
# zoxide 0.9.x читает _ZO_FZF_OPTS и ПОДМЕНЯЕТ ею FZF_DEFAULT_OPTS у запускаемого
# fzf, поэтому оформление выделенной строки (FZF_HIGHLIGHT_LINE_OPTS из
# variables.zsh) нужно явно указать и здесь
export _ZO_FZF_OPTS="--height 100% --no-mouse --layout=reverse --border $FZF_HIGHLIGHT_LINE_OPTS --preview-window=35% --preview='eza -1 -A --group-directories-first --classify=always --icons=always --color=always {2} 2>/dev/null || ls -1 --color=always {2} 2>/dev/null'"

# Инициализация утилиты zoxide/z
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
