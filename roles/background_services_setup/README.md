# background_services_setup

Роль ставит и настраивает фоновые службы (демоны), которые работают в системе постоянно. Сейчас - `dnsmasq` (локальный DNS/DHCP-сервер); структура рассчитана на добавление новых сервисов.

## Структура (по файлу-на-сервис, как в `terminal_setup`)

- `tasks/<service>_setup.ansible.yml` - настройка сервиса, включается из `tasks/main.yml`;
- `templates/<service>.conf.j2` - конфиг сервиса (шапка файла: `Ansible managed`, ручные правки перезаписываются);
- `defaults/main/<service>_vars.yml` - параметры сервиса, переопределяются через inventory (host_vars/group_vars);
- `vars/Darwin/main.yml`, `vars/Debian/main.yml` - ОС-зависимые пути (пути в `vars`, а не в `defaults`, поэтому через inventory не переопределяются).

## dnsmasq

Что делает роль:

1. Ставит пакет (`dnsmasq` через Homebrew на macOS, apt на Debian/Ubuntu).
2. Рендерит конфиг из переменных в `templates/dnsmasq.conf.j2`:
   - `interface=`, `listen-address=`, `cache-size=`, `local=/домен/`, `domain=` - из `defaults/main/dnsmasq_vars.yml`;
   - `server=...` - по списку `background_services_setup_dns_servers` (по умолчанию `8.8.8.8`, `8.8.4.4`);
   - `addn-hosts=` - ОС-зависимый путь (`/opt/homebrew/etc/dnsmasq.hosts` на macOS, `/etc/dnsmasq.hosts` на Debian) - файл наполняет Terraform, роль только создаёт пустой.
3. Запускает и включает автостарт: `brew services` на macOS (с `become: true` - dnsmasq занимает привилегированный порт 53, поэтому сервис оформляется как LaunchDaemon от root в `/Library/LaunchDaemons`), systemd на Debian.
4. При изменении конфига перезапускает сервис (handler `Restart dnsmasq`, ветвление по ОС через `listen`).

Пример переопределения DNS-серверов в `inventory.yml`:

```yaml
macos:
  hosts:
    mac-host:
      background_services_setup_dns_servers:
        - "217.10.36.5"
        - "1.1.1.1"
```

После прогона роль напоминает (debug), что нужно руками направить DNS на dnsmasq:

- macOS: добавить `listen-address` из конфига в DNS-серверы сетевой службы (Системные настройки -> Сеть, или `networksetup -setdnsservers`), а `local`-домены - в домены поиска;
- Linux: указать nameserver в `/etc/resolv.conf`/настройках сети; если включён `systemd-resolved` - отключить `DNSStubListener`, иначе его stub на `127.0.0.53` займёт порт 53 и dnsmasq не стартует.

## Запуск

Оба прогона требуют `-K` (--ask-become-pass): таски установки сервиса идут с `become` - на macOS dnsmasq занимает привилегированный порт 53 и запускается от root, на Debian apt-таски и systemd требуют root.

```bash
# macOS (локально или на удалённом macos-хосте из inventory.yml)
ansible-playbook playbooks/background_services_setup.ansible.yml --limit localhost -K

# Ubuntu/Debian
ansible-playbook playbooks/background_services_setup.ansible.yml --limit ubuntu -K
```
