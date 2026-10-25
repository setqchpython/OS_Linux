#!/bin/bash
# Практика mobile-app (занятие 5). Запуск: sudo bash setup-mobile-lab.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Нужен root: sudo bash $0"; exit 1; }

LAB_PASS="${LAB_PASS:-LabPass123!}"

for g in mobile-dev mobile-qa; do
  getent group "$g" >/dev/null || groupadd "$g"
done

create_user() {
  local u="$1"; shift
  local groups="$*"
  if ! id "$u" &>/dev/null; then
    useradd -m -s /bin/bash "$u"
  fi
  echo "${u}:${LAB_PASS}" | chpasswd
  usermod -aG "$groups" "$u"
}

# lead: обе группы + sudo; dev; qa; guest — только своя группа
create_user lead  mobile-dev,mobile-qa,sudo
create_user dev   mobile-dev
create_user qa    mobile-qa
create_user guest guest

mkdir -p /srv/mobile/src /srv/mobile/reports
chgrp mobile-dev  /srv/mobile/src
chgrp mobile-qa   /srv/mobile/reports
chmod 2770 /srv/mobile/src /srv/mobile/reports

echo "OK: mobile-app lab users (пароль: \$LAB_PASS или ${LAB_PASS})"
echo "Проверка: sudo bash $(dirname "$0")/users-lab-kit/team-lab-check.sh"
