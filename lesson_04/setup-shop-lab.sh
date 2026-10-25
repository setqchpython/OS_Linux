#!/bin/bash
# Практика /srv/shop (занятие 6). Запуск: sudo bash setup-shop-lab.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "sudo bash $0"; exit 1; }

PASS="${LAB_PASS:-LabPass123!}"
getent group shop-dev >/dev/null || groupadd shop-dev

for u in alex bella chris; do
  id "$u" &>/dev/null || useradd -m -s /bin/bash "$u"
  echo "${u}:${PASS}" | chpasswd
done
usermod -aG shop-dev alex
usermod -aG shop-dev bella

mkdir -p /srv/shop/{src,releases,uploads}
chgrp shop-dev /srv/shop/src /srv/shop/releases /srv/shop/uploads
chmod 2770 /srv/shop/src
chmod 2775 /srv/shop/releases
chmod 3770 /srv/shop/uploads

sudo -u alex bash -c 'echo "# app" > /srv/shop/src/app.py'
sudo -u bella bash -c 'echo "# patch" >> /srv/shop/src/app.py'
sudo -u alex bash -c 'echo "SECRET=1" > /srv/shop/src/config.env && chmod 600 /srv/shop/src/config.env'
sudo -u alex bash -c 'echo "release v1" > /srv/shop/releases/v1.txt'
chown bella:shop-dev /srv/shop/releases/v1.txt
sudo -u bella bash -c 'echo "upload by bella" > /srv/shop/uploads/bella-file.txt'

echo "OK shop lab. Проверка: sudo bash $(dirname "$0")/perms-lab-kit/perms-lab-check.sh"
