#!/bin/bash
# Проверка матрицы доступа. Ничего не изменяет.
# Запуск после provision.sh: sudo bash optional/check-access.sh
[ "$(id -u)" = 0 ] || { echo "Запустите через sudo: sudo bash $0"; exit 1; }

fail=0
line() {
  local resource="$1" role="$2" expected="$3" got="$4"
  local mark="OK"
  if [ "$expected" != "$got" ]; then
    mark="FAIL"
    fail=$((fail + 1))
  fi
  printf '%s — %s — ожидается %s — получено %s — %s\n' \
    "$resource" "$role" "$expected" "$got" "$mark"
}

can() {
  sudo -u "$1" "${@:2}" >/dev/null 2>&1
}

probe() {
  local resource="$1" role="$2" user="$3" expected="$4"
  shift 4
  if can "$user" "$@"; then
    line "$resource" "$role" "$expected" "да"
  else
    line "$resource" "$role" "$expected" "нет"
  fi
}

echo "helpdesk.conf — чтение"
probe /etc/helpdesk/helpdesk.conf "служба helpdesk" helpdesk да test -r /etc/helpdesk/helpdesk.conf
probe /etc/helpdesk/helpdesk.conf "разработчик ivanov" ivanov да test -r /etc/helpdesk/helpdesk.conf
probe /etc/helpdesk/helpdesk.conf "разработчик petrova" petrova да test -r /etc/helpdesk/helpdesk.conf
probe /etc/helpdesk/helpdesk.conf "поддержка smirnova" smirnova нет test -r /etc/helpdesk/helpdesk.conf
probe /etc/helpdesk/helpdesk.conf "остальные nobody" nobody нет test -r /etc/helpdesk/helpdesk.conf

echo "secrets.env — чтение"
probe /etc/helpdesk/secrets.env "служба helpdesk" helpdesk да test -r /etc/helpdesk/secrets.env
probe /etc/helpdesk/secrets.env "разработчик ivanov" ivanov нет test -r /etc/helpdesk/secrets.env
probe /etc/helpdesk/secrets.env "разработчик petrova" petrova нет test -r /etc/helpdesk/secrets.env
probe /etc/helpdesk/secrets.env "поддержка smirnova" smirnova нет test -r /etc/helpdesk/secrets.env
probe /etc/helpdesk/secrets.env "остальные nobody" nobody нет test -r /etc/helpdesk/secrets.env

echo "/var/lib/helpdesk — вход и запись"
probe /var/lib/helpdesk "служба helpdesk" helpdesk да test -w /var/lib/helpdesk
probe /var/lib/helpdesk "разработчик ivanov" ivanov нет test -x /var/lib/helpdesk
probe /var/lib/helpdesk "поддержка smirnova" smirnova нет test -x /var/lib/helpdesk
probe /var/lib/helpdesk "остальные nobody" nobody нет test -x /var/lib/helpdesk

echo "журнал — чтение и запись"
probe /var/log/helpdesk/api.log "служба helpdesk" helpdesk да test -w /var/log/helpdesk/api.log
probe /var/log/helpdesk/api.log "разработчик ivanov" ivanov да test -r /var/log/helpdesk/api.log
probe /var/log/helpdesk/api.log "разработчик ivanov запись" ivanov нет test -w /var/log/helpdesk/api.log
probe /var/log/helpdesk/api.log "поддержка smirnova" smirnova да test -r /var/log/helpdesk/api.log
probe /var/log/helpdesk/api.log "поддержка smirnova запись" smirnova нет test -w /var/log/helpdesk/api.log
probe /var/log/helpdesk/api.log "остальные nobody" nobody нет test -r /var/log/helpdesk/api.log

echo "веб-интерфейс — чтение и запись"
probe /srv/helpdesk/static/index.html "служба helpdesk" helpdesk да test -r /srv/helpdesk/static/index.html
probe /srv/helpdesk/static "служба helpdesk запись" helpdesk нет test -w /srv/helpdesk/static
probe /srv/helpdesk/static "разработчик petrova запись" petrova да test -w /srv/helpdesk/static
probe /srv/helpdesk/static "разработчик ivanov запись" ivanov да test -w /srv/helpdesk/static
probe /srv/helpdesk/static "поддержка smirnova" smirnova нет test -x /srv/helpdesk/static
probe /srv/helpdesk/static "остальные nobody" nobody нет test -x /srv/helpdesk/static

if [ "$fail" -eq 0 ]; then
  echo "Матрица: расхождений нет"
else
  echo "Матрица: расхождений $fail"
  exit 1
fi
