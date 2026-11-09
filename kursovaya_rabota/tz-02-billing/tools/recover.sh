#!/bin/bash
# Восстановление billing-02 по журналу работ. После съёма паспорта:
#   sudo bash tools/recover.sh
# Супервизор billingd не останавливается. Сервер не перезагружается.
set -eu
[ "$(id -u)" = 0 ] || { echo "Запустите через sudo: sudo bash $0"; exit 1; }

ROOT=$(cd "$(dirname "$0")/.." && pwd)
L=/var/log/billing
CONF=/etc/billing/billing.conf
SRC=$L/exports/export-2026-09.csv
DSTDIR=/var/lib/billing/exports
DST=$DSTDIR/export-2026-09.csv

step() { echo; echo "== $*"; }

restart_api() {
  local api="" new="" i
  api=$(pgrep -u billing -f '^/bin/bash /usr/local/bin/billing-api' | head -1 || true)
  [ -n "$api" ] || { echo "billing-api не найден" >&2; return 1; }
  kill -TERM "$api"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    sleep 1
    new=$(pgrep -u billing -f '^/bin/bash /usr/local/bin/billing-api' | head -1 || true)
    if [ -n "$new" ] && [ "$new" != "$api" ] && grep -q "pid=$new level=info started" "$L/api.log"; then
      echo "billing-api перезапущен, pid=$new, level=info"
      return 0
    fi
  done
  echo "billing-api не перешёл на level=info" >&2
  return 1
}

step "Перенос выгрузки, контрольная сумма до и после (2.2.3)"
mkdir -p "$DSTDIR"
if [ -f "$SRC" ]; then
  before=$(sha256sum "$SRC" | awk '{print $1}')
  owner=$(stat -c '%U:%G' "$SRC")
  cp -a "$SRC" "$DST"
  chown "$owner" "$DST"
  after=$(sha256sum "$DST" | awk '{print $1}')
  echo "до:    $before"
  echo "после: $after"
  [ "$before" = "$after" ]
  if [ -f /root/.billing-export.sha256 ]; then
    [ "$after" = "$(tr -d '[:space:]' < /root/.billing-export.sha256)" ]
  fi
  rm -f -- "$SRC"
  rmdir "$L/exports" 2>/dev/null || true
elif [ -f "$DST" ]; then
  echo "Выгрузка уже в $DST"
else
  echo "Нет $SRC и нет $DST" >&2
  exit 1
fi

step "Очистка журналов и дампа (2.2.1, 2.2.2)"
bash "$ROOT/cleanup-logs.sh" --apply

step "Настройки: уровень info, каталог выгрузок, права (2.3.2, 2.2.3, 2.4.1)"
sed -i 's/^LOG_LEVEL=.*/LOG_LEVEL=info/' "$CONF"
sed -i 's|^EXPORT_DIR=.*|EXPORT_DIR=/var/lib/billing/exports|' "$CONF"
chown root:billing "$CONF"
chmod 640 "$CONF"
runuser -u billing -- test -r "$CONF"
if runuser -u nobody -- test -r "$CONF"; then
  echo "Файл настроек всё ещё читает посторонний" >&2
  exit 1
fi

step "Перезапуск billing-api через супервизор (2.3.1, 2.3.2)"
restart_api

step "Если раздел всё ещё заполнен больше чем на 50 %, урезать отладочный api.log"
pct=$(df --output=pcent "$L" | tail -1 | tr -dc 0-9)
if [ "$pct" -gt 50 ]; then
  : > "$L/api.log"
  restart_api
fi

step "Остановить сверку и рабочие процессы (2.3.3)"
# Рабочий процесс 1 ловит TERM и не завершается, поэтому нужен KILL.
# billingd сверку сам не поднимает.
pkill -KILL -f '/usr/local/bin/billing-report' || true
sleep 1
if pgrep -f '/usr/local/bin/billing-report' >/dev/null 2>&1; then
  echo "Процессы billing-report ещё есть" >&2
  exit 1
fi
pgrep -u billing -f billingd.py >/dev/null

step "Готово"
df -h "$L" | tail -1
echo "Дальше: sudo bash ~/Downloads/billing-acceptance.sh"
