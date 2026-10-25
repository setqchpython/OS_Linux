#!/bin/bash
# Домашнее задание lesson_03: модель доступа проекта shop-api на /srv.
# Запуск на ВМ: sudo bash setup-team.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Нужен root: sudo bash $0"; exit 1; }

LAB_PASS="${LAB_PASS:-LabPass123!}"
ROOT="/srv/shop-api"

for g in shop-dev shop-support; do
  getent group "$g" >/dev/null || groupadd "$g"
done

create_user() {
  local u="$1"; shift
  local groups="$*"
  id "$u" &>/dev/null || useradd -m -s /bin/bash "$u"
  echo "${u}:${LAB_PASS}" | chpasswd
  usermod -aG "$groups" "$u"
}

# owner | developer | support | contractor
create_user owner      shop-dev,shop-support,sudo
create_user developer  shop-dev
create_user support    shop-support
create_user contractor contractor

mkdir -p "$ROOT/app" "$ROOT/logs"
chgrp shop-dev     "$ROOT/app"
chgrp shop-support "$ROOT/logs"
chmod 2770 "$ROOT/app" "$ROOT/logs"

echo "OK: shop-api team under $ROOT (пароль учёток: ${LAB_PASS})"
