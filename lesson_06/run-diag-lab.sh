#!/bin/bash
# Практика diag-lab → 11/11. Запуск: bash ~/OS_Linux/lesson_06/run-diag-lab.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LAB="$HOME/diag-lab"

bash "$ROOT/diag-lab-kit/diag-lab-setup.sh"
pkill -f "$LAB/bin/incident.py" 2>/dev/null || true
sleep 1

python3 "$LAB/bin/incident.py" &
sleep 10

LOAD_SYM="$(uptime)"
WEB_SLOW="$(tail -3 "$LAB/web.log")"

renice -n 19 -p $(pgrep -f "$LAB/bin/report-calc.sh") >/dev/null 2>&1 || true
sleep 12
WEB_RENICE="$(tail -3 "$LAB/web.log")"

kill $(pgrep -f "$LAB/bin/report-builder") 2>/dev/null || true
sleep 1
kill $(pgrep -f "$LAB/bin/report-calc") 2>/dev/null || true
sleep 3
WEB_FIX="$(tail -2 "$LAB/web.log")"

S="$(cat "$LAB/sync.lock")"
kill "$S" 2>/dev/null || true
sleep 2
kill -9 "$S" 2>/dev/null || true
rm -f "$LAB/sync.lock"
sleep 2

NOW="$(date +%T)"
cat > "$LAB/postmortem.md" <<EOF
# Postmortem · учебный сервер diag-lab

## Симптом

$NOW · $LOAD_SYM
Время ответа web-worker выросло (обычно 60–100 ms):
$WEB_SLOW

## Причина

report-builder запустил $(nproc)×2 процессов report-calc с бесконечным циклом — больше, чем ядер; они отбирали CPU у web-worker.
sync-agent завис в sleep, игнорирует TERM; PID был в sync.lock.

## Действия

1. renice -n 19 всем report-calc → ответ улучшился: $WEB_RENICE
2. kill TERM report-builder; отдельно kill report-calc (потомки остались).
3. TERM sync-agent — без эффекта; kill -9; rm sync.lock.
4. web-worker не останавливали. Итог web.log: $WEB_FIX

## Профилактика

- Запускать тяжёлые расчёты с nice 19 и лимитом параллелизма ≤ числа ядер.
- При завершении родителя проверять pgrep -af report-calc.
- Для sync-agent: таймаут блокировки и обработчик TERM; после KILL удалять sync.lock.
EOF

cp "$LAB/postmortem.md" "$ROOT/postmortem.md"

bash "$ROOT/diag-lab-kit/diag-lab-check.sh"
