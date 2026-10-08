# workstation-setup

Личные Ansible-плейбуки для настройки рабочих станций под macOS и Linux (Debian/Ubuntu).

## Что внутри

| Роль | Что настраивает |
|---|---|
| `terminal_setup` | Zsh: [Antidote](https://github.com/mattmc3/antidote) + плагины Oh My Zsh, тема, алиасы, хоткеи. Современные утилиты (`eza`, `bat`, `fzf`, `zoxide`, ...), vim с темой, настройка `git`/`terraform`/`docker completion`. Единое оформление терминала: без жирного текста, яркая палитра |
| `desktop_apps_setup` | Десктопные приложения: macOS - Homebrew Cask, Ubuntu - apt, официальный `.deb`, GitHub или другой способ установки |
| `background_services_setup` | Фоновые службы: dnsmasq (локальный DNS - конфиг из переменных роли, автостарт через launchd/systemd, рестарт при изменении конфига) |

> [!WARNING]
> Роль перезаписывает существующие dotfiles: заменяет `~/.zshenv`, `~/.config/zsh/*`, `~/.config/vim/.vimrc`, `~/.terraformrc`, удаляет `~/.vimrc` и git-completion из Homebrew, переносит `~/.zsh_history` в XDG-каталог. Если у вас свои конфиги - сделайте бэкап перед запуском.

### Что нужно

- Контроллер: [uv](https://docs.astral.sh/uv/) - зависимости Ansible ставит `uv sync`.
- macOS-хост: установленный [Homebrew](https://brew.sh), остальное роль ставит сама.
- Ubuntu-хост: 24.04 (noble) или новее, пользователь с правами sudo (apt-таски выполняются с `become`).

### Подготовка

```bash
git clone https://github.com/waldemar13311/workstation-setup.git
cd workstation-setup
uv sync
source .venv/bin/activate
```

### inventory.yml

Плейбуки объявлены с `hosts: all` - конкретную цель выбираем флагом `--limit` (см. Запуск), а хосты и переопределения переменных ролей задаём в `inventory.yml`:

```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
    macos:
      ansible_host: 192.168.1.50
    ubuntu:
      ansible_host: 192.168.1.51
      ansible_user: waldemar

  # переменные из defaults/ ролей переопределяются так:
  vars:
    background_services_setup_dns_servers:
      - 217.10.36.5
      - 217.10.44.35
```

### Установка ansible зависимостей

```bash
ansible-galaxy install -r .ansible/requirements.yml
```

### Запуск
Плейбуки объявлены с `hosts: all` - конкретную цель выбираем флагом `--limit`, а не правкой плейбука:

#### terminal_setup.ansible.yml

```bash
# терминал: zsh, плагины, тема, утилиты, vim, docker completion
ansible-playbook playbooks/terminal_setup.ansible.yml --limit localhost

# на удалённом macos-хосте из inventory.yml
ansible-playbook playbooks/terminal_setup.ansible.yml --limit macos

# на удалённом ubuntu-хосте из inventory.yml
# -K (--ask-become-pass): apt-таски выполняются с become, попросит пароль sudo
ansible-playbook playbooks/terminal_setup.ansible.yml --limit ubuntu -K
```

#### background_services_setup.ansible.yml

```bash
# фоновые службы: dnsmasq (конфиг из переменных роли, автостарт, рестарт при изменении конфига)
# -K: таска сервиса идёт с become - dnsmasq занимает привилегированный порт 53
ansible-playbook playbooks/background_services_setup.ansible.yml --limit localhost -K

# на удалённом macos-хосте из inventory.yml
ansible-playbook playbooks/background_services_setup.ansible.yml --limit macos -K

# на удалённом ubuntu-хосте из inventory.yml
# -K: apt-таски выполняются с become, попросит пароль sudo
ansible-playbook playbooks/background_services_setup.ansible.yml --limit ubuntu -K
```

#### desktop_apps_setup.ansible.yml

```bash
# десктоп: Chrome, VS Code и т. д. (macOS - Homebrew Cask, Ubuntu - .deb из официальных репозиториев)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit localhost

# на удалённом macos-хосте из inventory.yml
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit macos

# на удалённом ubuntu-хосте из inventory.yml
# -K: apt-таски выполняются с become, попросит пароль sudo
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit ubuntu -K
```

### Как добавить своё

Роли построены по одному паттерну: запись в списке переменных + файл-рецепт. Куда добавить:

- **Плагин zsh** - список `terminal_setup_zsh_plugins` в `roles/terminal_setup/defaults/main/zsh_plugins.yml` (формат antidote).
- **Консольная утилита**, которая есть в Homebrew/apt - список `terminal_setup_modern_console_utils` или `terminal_setup_console_utils` в `roles/terminal_setup/vars/Darwin/main.yml` (Homebrew) / `vars/Debian/main.yml` (apt).
- **Консольная утилита без apt-пакета** (Debian) - по рецепту в `vars/Debian/main.yml` (`terminal_setup_debian_extra_tools`): vars-файл в `vars/Debian/`, таск в `tasks/debian_tools/`, запись в списке.
- **Десктопное приложение:**
  - macOS - cask в `desktop_apps_setup_casks` (`roles/desktop_apps_setup/vars/Darwin/main.yml`);
  - Ubuntu - apt-пакет в `desktop_apps_setup_apt_packages` или рецепт `desktop_apps_setup_debian_extra_apps` в `vars/Debian/main.yml` (apt, официальный `.deb`, GitHub или другой способ).
- **Параметр dnsmasq** - `roles/background_services_setup/defaults/main/dnsmasq_vars.yml`; точечные переопределения - через `inventory.yml`.

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

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.
