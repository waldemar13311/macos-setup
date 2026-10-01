# macos-setup

Личные Ansible-плейбуки для настройки macOS и Linux (Debian/Ubuntu): Zsh с [Antidote](https://github.com/mattmc3/antidote), плагинами Oh My Zsh, тема, алиасы, утилиты, `~/.vimrc`. Всё собирается ролью `terminal_setup`; отдельно есть playbook для десктопных приложений.

> [!WARNING]
> Роль перезаписывает существующие dotfiles: заменяет `~/.zshenv`, `~/.config/zsh/*`, `~/.config/vim/.vimrc`, `~/.terraformrc`, удаляет `~/.vimrc` и git-completion из Homebrew, переносит `~/.zsh_history` в XDG-каталог. Если у вас свои конфиги - сделайте бэкап перед запуском.

### Подготовка

```bash
git clone https://github.com/waldemar13311/macos-setup.git
cd macos-setup
uv sync
source .venv/bin/activate
```

Перед запуском, если не будете использовать localhost, укажите удалённый хост в `inventory.yml`.

### Установка ansible зависимостей

```bash
ansible-galaxy install -r .ansible/requirements.yml
```

### Запуск

Оба плейбука объявлены с `hosts: all` - конкретную цель выбираем флагом `--limit`, а не правкой плейбука:

```bash
# терминал: zsh, плагины, тема, утилиты, vim, docker completion
ansible-playbook playbooks/terminal_setup.ansible.yml --limit localhost

# на удалённом macos-хосте из inventory.yml
ansible-playbook playbooks/terminal_setup.ansible.yml --limit macos

# на удалённом ubuntu-хосте из inventory.yml
# -K (--ask-become-pass): apt-таски выполняются с become, попросит пароль sudo
ansible-playbook playbooks/terminal_setup.ansible.yml --limit ubuntu -K

# десктоп: Chrome, VS Code и т. д. (macOS - Homebrew Cask, Ubuntu - .deb из официальных репозиториев)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit localhost

# десктоп на ubuntu-хосте (apt-таски с become - нужен пароль sudo)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit ubuntu -K
```

Списки плагинов и общие переменные - в `roles/terminal_setup/defaults/main/`. Списки пакетов зависят от ОС и лежат в `roles/terminal_setup/vars/`: `Darwin/` (Homebrew) и `Debian/` (apt, по файлу на инструмент без apt-пакета).

### Отличия на Linux (Debian/Ubuntu)

- Установка apt-пакетов и .deb требует прав root: на apt-тасках включается `become`, поэтому при запуске нужен `-K`/`--ask-become-pass` (или NOPASSWD sudo на целевом хосте).
- antidote ставится не из пакетов, а git-клоном в `~/.local/share/antidote` (пин на релиз, см. `defaults/main/antidote_vars.yml`).
- Оболочка по умолчанию для пользователя переключается на zsh (на macOS это и так default).
- `bat`/`fd` в Ubuntu называются `batcat`/`fdfind` - роль создаёт симлинки в `~/.local/bin`.
- `fzf`, `kubectl`, `uv`, `tenv`, `fastfetch`, `gitlab-ci-local` в apt отсутствуют или устарели - ставятся в `~/.local/bin` без прав root (таски в `tasks/debian_tools/`, параметры в `vars/Debian/*_vars.yml`):
  - `fzf` - свежий релиз с GitHub (apt-версия 0.44 слишком старая для виджетов роли);
  - `kubectl` - последний стабильный релиз (резолвится при прогоне, хеш сверяется по `.sha256`);
  - `tenv`, `fastfetch`, `gitlab-ci-local` - пиновые версии релизов (обновляются правкой пина в vars);
  - `uv` - официальный инсталлятор, обновление - `uv self update`.
- Списки пакетов рассчитаны на Ubuntu 24.04 (noble) и новее.

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.
