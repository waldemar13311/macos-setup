# macos-setup

Личные Ansible-плейбуки для настройки macOS: Zsh с [Antidote](https://github.com/mattmc3/antidote), плагинами Oh My Zsh, тема, алиасы, утилиты из Homebrew, `~/.vimrc`. Всё собирается ролью `terminal_setup`; отдельно есть playbook для десктопных приложений.

### Подготовка

```bash
git clone https://github.com/waldemar13311/macos-setup.git
cd macos-setup
uv sync
source .venv/bin/activate
```

Перед запуском укажите свой хост в `inventory.yml` (по умолчанию там macOS по SSH).

### Установка ansible зависимостей

```bash
ansible-galaxy install -r .ansible/requirements.yml
```

### Запуск

```bash
# терминал: zsh, плагины, тема, утилиты, vim, docker completion
ansible-playbook playbooks/terminal_setup.ansible.yml

# десктоп: Chrome, VS Code и т. д. (Homebrew Cask)
ansible-playbook playbooks/desktop_apps_setup.ansible.yml
```

Списки плагинов и пакетов можно менять в `roles/terminal_setup/defaults/main.yml`.
