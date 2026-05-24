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

mkdir -p ~/.kubectl/completions
kubectl completion zsh > ~/.kubectl/completions/_kubectl
```

```bash
cat <<"EOT" >> ~/.zshrc.local
# Автодополнение
fpath=(
    $HOME/.docker/completions/
    $HOME/.kubectl/completions/

    # Автодополнение для multipass (возможно комментарии не сработают/не корректны)
    $HOME/.config/zsh/completions
    $fpath
)

autoload -Uz compinit
compinit
EOT
```
Дописать чтобы мои настройки vim ставились (~/.vimrc) !

Возможно стоит отказаться от Antigen на базу Antidote + OMZ libs !
