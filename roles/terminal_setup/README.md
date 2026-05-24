# terminal_setup

Роль настраивает Zsh на macOS: через Homebrew ставит Antidote, полезные CLI-утилиты (eza, bat, fzf, kubectl, Docker/Colima и др.) и раскладывает dotfiles — `~/.zshrc`, `~/.vimrc`, тему и список плагинов. Плагины подключаются через Antidote (в т.ч. фрагменты Oh My Zsh); при изменении конфигов собирается `~/.zsh_plugins.zsh`.

Запуск от обычного пользователя (`become: false`), нужен установленный Homebrew. Списки пакетов и плагинов — в `defaults/main.yml`. Playbook: `playbooks/terminal_setup.ansible.yml`.
