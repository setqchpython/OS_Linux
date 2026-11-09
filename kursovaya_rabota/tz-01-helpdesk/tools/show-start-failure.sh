#!/bin/bash
# Первый отказ запуска — для снимка экрана и журнала (испытание И-04).
# Только на свежем стенде, ДО provision.sh:
#   sudo bash tools/show-start-failure.sh
# После снимка вернуть сервер: sudo bash ~/Downloads/helpdesk-stand.sh
set -u
[ "$(id -u)" = 0 ] || { echo "Запустите через sudo"; exit 1; }
R=/tmp/helpdesk-release-2.4.1
[ -d "$R" ] || { echo "Нет $R. Сначала разверните стенд и не удаляйте релиз."; exit 1; }

if [ -x /usr/sbin/nologin ]; then SH=/usr/sbin/nologin; else SH=/bin/false; fi
getent group helpdesk >/dev/null || groupadd --system helpdesk
id helpdesk >/dev/null 2>&1 || useradd --system --no-create-home --home-dir /var/lib/helpdesk --shell "$SH" --gid helpdesk helpdesk

install -d -o helpdesk -g helpdesk -m 755 /etc/helpdesk /var/log/helpdesk /var/lib/helpdesk /run/helpdesk
install -o root -g root -m 755 "$R/bin/helpdesk-api" /usr/local/bin/helpdesk-api
install -o root -g root -m 755 "$R/bin/helpdesk-ctl" /usr/local/bin/helpdesk-ctl
install -o root -g root -m 644 "$R/conf/helpdesk.conf" /etc/helpdesk/helpdesk.conf
install -o root -g root -m 644 "$R/conf/secrets.env" /etc/helpdesk/secrets.env

echo "Режим секретов в поставке: $(stat -c %a /etc/helpdesk/secrets.env)"
echo "Запуск от helpdesk без смены прав:"
runuser -u helpdesk -- /usr/local/bin/helpdesk-ctl start || true
echo
echo "Причина в последней строке журнала. Права ради запуска не расширялись."
echo "Снимок этого вывода — screenshots/start-refused.png"
echo "Дальше НЕ продолжайте на этом состоянии. Верните стенд:"
echo "  sudo bash ~/Downloads/helpdesk-stand.sh"
