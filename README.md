# My-zsh-installation
Мои личные Ansible-плейбуки для автоматической установки и настройки zsh с нужными мне плагинами, темой и полезными алиасами. Поддерживает macOS и Linux, автоматически выбирает нужные плагины в зависимости от операционной системы.

### Подготовка окружения
```bash
git clone https://github.com/waldemar13311/My-zsh-installation.git
uv sync
source .venv/bin/activate
```

### Установка ansible зависимостей
```bash
ansible-galaxy install -r .ansible/requirements.yml
```

### Запуск установки
```bash
# zsh + плагины
ansible-playbook playbooks/install-zsh.ansible.yml

# тема оформления
ansible-playbook playbooks/install-my-gnzh-theme.ansible.yml
```

### Дальнейшая настройка
```bash
mkdir -p ~/.docker/completions
docker completion zsh > ~/.docker/completions/_docker
```

```bash
cat <<"EOT" >> ~/.zshrc.local
# Автодополнение для docker (добавлено мной)
FPATH="$HOME/.docker/completions:$FPATH"

# Автодополнение для multipass
fpath=($HOME/.config/zsh/completions $fpath)

autoload -Uz compinit
compinit
EOT
```
