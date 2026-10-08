# desktop_apps_setup

Роль ставит десктопные приложения. macOS: через [Homebrew Cask](https://docs.brew.sh/Cask-Cookbook), Debian/Ubuntu: из apt-репозиториев плюс официальные `.deb` там, где apt-пакета нет.

Разделение по ОС - как в `terminal_setup`: проверка семейства ОС, переменные в `vars/Darwin/main.yml` (список cask) и `vars/Debian/` (apt-пакеты, URL `.deb`). Установка apt-пакетов идёт с `become: true` (нужен sudo, при запуске флаг `-K`), Homebrew на macOS работает от пользователя.

Структура Debian-части - по файлу на приложение без apt-пакета (как `tasks/debian_tools/` в `terminal_setup`):

- `vars/Debian/<app>_vars.yml` - URL официального `.deb` (`chrome_vars.yml`, `vscode_vars.yml`);
- `tasks/debian_tools/<app>_setup.ansible.yml` - скачать `.deb` и установить через apt.

Установка `.deb` подключает собственный apt-репозиторий (Google, Microsoft), так что обновления приедут через обычный `apt upgrade`. Сейчас: Chrome, VS Code (apt: шрифт `fonts-jetbrains-mono`).

Чтобы добавить приложение:

- **macOS** - дописать cask в `vars/Darwin/main.yml`;
- **Debian, есть в apt** - дописать пакет в `desktop_apps_setup_apt_packages` (`vars/Debian/main.yml`);
- **Debian, нет в apt** - создать `vars/Debian/<app>_vars.yml` (URL `.deb`) и `tasks/debian_tools/<app>_setup.ansible.yml`, добавить имя в loop таски `Install apps without apt package`.

Плейбук: `playbooks/desktop_apps_setup.ansible.yml`.

```bash
# macOS (локально или на удалённом macos-хосте из inventory.yml)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit localhost

# Ubuntu/Debian (apt-таски с become - нужен пароль sudo)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit ubuntu -K
```
