#!/bin/bash
# Довести diag-lab до 11/11 после capture или ручных шагов.
# bash ~/OS_Linux/lesson_06/finish-diag-lab.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LAB="$HOME/diag-lab"

if ! pgrep -f "$LAB/bin/web-worker.sh" >/dev/null; then
  echo "web-worker не работает — перезапуск набора:"
  exec bash "$ROOT/run-diag-lab.sh"
fi

CALC="$LAB/bin/report-calc.sh"
BUILD="$LAB/bin/report-builder.sh"
SYNC="$LAB/bin/sync-agent.sh"

PIDS=$(pgrep -f "$CALC" | tr '\n' ' ' || true)
if [ -n "$PIDS" ]; then
  renice -n 19 -p $PIDS >/dev/null 2>&1 || true
  echo "renice 19 → report-calc, ждём записи в report.log…"
  sleep 12
fi

if pgrep -f "$BUILD" >/dev/null; then
  kill "$(pgrep -f "$BUILD" | head -1)" 2>/dev/null || true
  sleep 1
fi
if pgrep -f "$CALC" >/dev/null; then
  kill $(pgrep -f "$CALC") 2>/dev/null || true
  sleep 2
fi

if [ -f "$LAB/sync.lock" ]; then
  S=$(cat "$LAB/sync.lock")
  kill "$S" 2>/dev/null || true
  sleep 2
  kill -9 "$S" 2>/dev/null || true
  rm -f "$LAB/sync.lock"
  sleep 2
fi

NOW="$(date +%T)"
cat > "$LAB/postmortem.md" <<EOF
# Postmortem · учебный сервер diag-lab

## Симптом

$NOW · $(uptime)
Время ответа web-worker выросло (норма 60–100 ms).
$(tail -3 "$LAB/web.log")

## Причина

report-builder запустил $(nproc)×2 процессов $CALC — больше, чем ядер.
sync-agent завис и игнорировал TERM (PID в sync.lock).

## Действия

renice -n 19 всем report-calc; проверка report.log (nice=19).
kill -TERM report-builder; kill -TERM оставшихся report-calc.
kill -TERM sync-agent; kill -9; rm sync.lock.
web-worker не останавливали.

## Профилактика

Запускать отчёты с nice 19 и числом workers ≤ nproc.
После kill родителя проверять pgrep -af report-calc.
Для sync: таймаут lock и обработчик TERM; после KILL удалять sync.lock.
EOF
cp "$LAB/postmortem.md" "$ROOT/postmortem.md"

bash "$ROOT/diag-lab-kit/diag-lab-check.sh"
