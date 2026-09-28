# macos-setup

Личные Ansible-плейбуки для настройки macOS: Zsh с [Antidote](https://github.com/mattmc3/antidote), плагинами Oh My Zsh, тема, алиасы, утилиты из Homebrew, `~/.vimrc`. Всё собирается ролью `terminal_setup`; отдельно есть playbook для десктопных приложений.

### Подготовка

```bash
git clone https://github.com/waldemar13311/macos-setup.git
cd macos-setup
uv sync
source .venv/bin/activate
```

Перед запуском, если не будете использовать localhost, укажите удалённый хост в `inventory.yml`.

### Выбор цели запуска

Оба плейбука объявлены с `hosts: all` — конкретную цель выбираем флагом `--limit`, а не правкой плейбука:

```bash
# локально на этой машине
ansible-playbook playbooks/terminal_setup.ansible.yml --limit localhost

# на удалённом macos-хосте из inventory.yml
ansible-playbook playbooks/terminal_setup.ansible.yml --limit macos
```

### Установка ansible зависимостей

```bash
ansible-galaxy install -r .ansible/requirements.yml
```

### Запуск

```bash
# терминал: zsh, плагины, тема, утилиты, vim, docker completion
ansible-playbook playbooks/terminal_setup.ansible.yml --limit localhost

# десктоп: Chrome, VS Code и т. д. (Homebrew Cask)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml --limit localhost
```

Списки плагинов и пакетов можно менять в `roles/terminal_setup/defaults/main.yml`.

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.
