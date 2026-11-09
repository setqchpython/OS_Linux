#!/bin/bash
# Закрытие доступа kozlov по журналу работ. Сначала снимите паспорт.
#   sudo bash tools/offboard.sh
set -eu
[ "$(id -u)" = 0 ] || { echo "Запустите через sudo: sudo bash $0"; exit 1; }

ROOT=$(cd "$(dirname "$0")/.." && pwd)
B=/var/backups/offboarding/kozlov
step() { echo; echo "== $*"; }

step "Копия до удаления (2.3.2, 2.3.3)"
mkdir -p "$B/.ssh"
chmod 700 /var/backups/offboarding "$B"
chown root:root /var/backups/offboarding "$B"

{
  echo "# процессы kozlov $(date '+%F %T')"
  ps -u kozlov -o pid,ppid,lstart,etime,cmd || true
  for pid in $(ps -u kozlov -o pid= 2>/dev/null || true); do
    echo "-- pid $pid"
    tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true
    echo
    echo -n "cwd: "; readlink "/proc/$pid/cwd" 2>/dev/null || echo "?"
    echo -n "exe: "; readlink "/proc/$pid/exe" 2>/dev/null || echo "?"
  done
} > "$B/processes.txt"

if [ -f /home/kozlov/notes.txt ]; then
  mv /home/kozlov/notes.txt "$B/notes.txt"
fi
if [ -d /home/kozlov/.ssh ]; then
  cp -a /home/kozlov/.ssh/. "$B/.ssh/"
  rm -rf /home/kozlov/.ssh
fi
if [ -f /srv/share/db_dump_2026-09-28.sql ]; then
  mv /srv/share/db_dump_2026-09-28.sql "$B/db_dump_2026-09-28.sql"
fi
if [ -e /var/tmp/.cache-k/kbash ]; then
  cp -a /var/tmp/.cache-k/kbash "$B/kbash"
  chmod 755 "$B/kbash"
  rm -rf /var/tmp/.cache-k
fi
chmod 700 "$B"
chown root:root "$B"

step "Передача /srv/devops Анне Орловой (2.2.1, 2.2.2)"
chown -R orlova:devops /srv/devops
chmod 2770 /srv/devops /srv/devops/deploy /srv/devops/keys
chmod 750 /srv/devops/deploy/deploy.sh
chmod 640 /srv/devops/deploy/inventory.ini
chmod 600 /srv/devops/keys/prod_deploy_key
runuser -u orlova -- /srv/devops/deploy/deploy.sh 2.4 >/dev/null
runuser -u orlova -- test -r /srv/devops/keys/prod_deploy_key
runuser -u lebedeva -- test -r /srv/finance/payments-2026-09.csv

step "Три замка и группы (2.1.1, 2.1.2)"
bash "$ROOT/optional/lock-user.sh" kozlov
rm -f /etc/sudoers.d/90-kozlov
if [ "$(id -Gn kozlov)" != kozlov ]; then
  echo "У kozlov остались дополнительные группы: $(id -Gn kozlov)" >&2
  exit 1
fi

step "Завершение процессов (2.1.3)"
tunnel=$(pgrep -u kozlov -f 'sync-tunnel' | head -1 || true)
if [ -n "$tunnel" ]; then
  kill -TERM "$tunnel" || true
  sleep 1
  if kill -0 "$tunnel" 2>/dev/null; then
    echo "pid $tunnel игнорирует TERM, дальше KILL"
  fi
fi
pkill -KILL -u kozlov || true
sleep 1
if pgrep -u kozlov >/dev/null 2>&1; then
  echo "Процессы kozlov ещё есть" >&2
  exit 1
fi
[ -d /home/kozlov ]

step "Готово"
echo "Дальше: sudo bash ~/Downloads/offboarding-acceptance.sh"
