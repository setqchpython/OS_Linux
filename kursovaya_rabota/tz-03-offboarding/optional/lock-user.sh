#!/bin/bash
# Три замка входа и снятие дополнительных групп.
#   sudo bash optional/lock-user.sh --check ИМЯ
#   sudo bash optional/lock-user.sh ИМЯ
set -eu
check=0
user=""
for arg in "$@"; do
  case "$arg" in
    --check) check=1 ;;
    -*) echo "Неизвестный ключ: $arg" >&2; exit 2 ;;
    *) user=$arg ;;
  esac
done
if [ -z "$user" ]; then
  echo "Запуск: sudo bash lock-user.sh [--check] ИМЯ" >&2
  exit 2
fi
id "$user" >/dev/null
if [ "$(id -u)" -ne 0 ]; then
  echo "Нужен root" >&2
  exit 1
fi

if [ -x /usr/sbin/nologin ]; then
  nologin=/usr/sbin/nologin
elif [ -x /sbin/nologin ]; then
  nologin=/sbin/nologin
else
  nologin=/bin/false
fi

show() {
  echo "-- passwd -S"
  passwd -S "$user"
  echo "-- chage -l"
  chage -l "$user"
  echo "-- shell"
  getent passwd "$user" | cut -d: -f7
  echo "-- groups"
  id -Gn "$user"
}

if [ "$check" -eq 1 ]; then
  show
  exit 0
fi

passwd -l "$user"
usermod --expiredate 1970-01-02 --shell "$nologin" "$user"
primary=$(id -gn "$user")
for group in $(id -Gn "$user"); do
  if [ "$group" != "$primary" ]; then
    gpasswd -d "$user" "$group" || true
  fi
done
show
