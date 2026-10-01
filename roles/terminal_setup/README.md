# terminal_setup

Роль настраивает Zsh на macOS и Debian/Ubuntu: ставит Antidote, полезные CLI-утилиты (eza, bat, fzf, kubectl, Docker и др.) и раскладывает dotfiles - `~/.zshrc`, `~/.vimrc`, тему и список плагинов. Плагины подключаются через Antidote (в т.ч. фрагменты Oh My Zsh); при изменении конфигов собирается `~/.zsh_plugins.zsh`.

macOS: запуск от обычного пользователя (`become: false`), нужен установленный Homebrew. Linux (Debian/Ubuntu, 24.04+): apt-пакеты ставятся с `become: true` (нужен sudo, при запуске флаг `-K`), antidote клонируется в `~/.local/share/antidote`, а недостающие в apt утилиты (kubectl, uv, tenv, fastfetch, gitlab-ci-local) - в `~/.local/bin` (таски в `tasks/debian_tools/`).

Переменные зависят от ОС и лежат в каталогах `vars/Darwin/` (Homebrew) и `vars/Debian/` (apt): `main.yml` - общие переменные, `*_vars.yml` - параметры установки инструментов без apt-пакета. Список плагинов и прочие общие переменные - в `defaults/main/`. Playbook: `playbooks/terminal_setup.ansible.yml`.
