# __PROJECT_NAME__

Инструкция по запуску:

```bash
cd проект
uv sync
source .venv/bin/activate
ansible-galaxy install -r .ansible/requirements.yml
```

Проверка связи с хостами (после заполнения `inventory.yml`):

```bash
ansible-playbook playbooks/ping.ansible.yml
```

## Шпаргалка: создание роли

Роль создаётся командой `ansible-galaxy role init` (выполняется из корня проекта):

```bash
ansible-galaxy role init roles/my-role
```

```text
roles/my-role/
├── defaults/main.yml   # переменные по умолчанию (переопределяются из group_vars и extra-vars)
├── files/              # статические файлы для copy (без .j2)
├── handlers/main.yml   # хендлеры - запускаются через notify из задач
├── meta/main.yml       # метаданные роли (автор, лицензия, зависимости)
├── README.md
├── tasks/main.yml      # задачи роли (обязательный файл)
├── templates/          # шаблоны для template (с суффиксом .j2)
├── tests/
└── vars/main.yml       # переменные роли (высокий приоритет, не переопределяются снаружи)
```

Подключение роли в плейбук:

```yaml
- name: My playbook
  hosts: all
  become: false
  gather_facts: true

  roles:
    - my-role
```

Переменные роли задаются в `defaults/main.yml` (низкий приоритет) и
переопределяются в `group_vars/all.yml` или при запуске:

```bash
ansible-playbook playbooks/ping.ansible.yml -e "my_var=value"
```
