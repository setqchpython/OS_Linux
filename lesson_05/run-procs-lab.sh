#!/bin/bash
# Практика procs-lab → 11/11. Запуск: bash ~/OS_Linux/lesson_05/run-procs-lab.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LAB="$HOME/procs-lab"

bash "$ROOT/procs-lab-kit/procs-lab-setup.sh"
pkill -f "$LAB/bin/manager.py" 2>/dev/null || true
sleep 1

python3 "$LAB/bin/manager.py" &
MGR=$!
sleep 2

pgrep -af manager.py | head -3
pstree -p "$MGR" || pstree -p $$

ps -o pid,ppid,stat,cmd --ppid "$MGR" > /tmp/procs-states.txt
{
  echo "# Состояния procs-lab"
  echo "| PID | процесс | stat |"
  echo "|---|---|---|"
  while read -r line; do
    pid=$(echo "$line" | awk '{print $1}')
    stat=$(echo "$line" | awk '{print $3}')
    cmd=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf $i" "; print ""}')
    echo "| $pid | $cmd | $stat |"
  done < /tmp/procs-states.txt
  echo ""
  echo "hog R (до STOP), paused T, worker S, stubborn S"
} > "$LAB/states.md"
grep -q hog "$LAB/states.md"

HOG=$(pgrep -f "$LAB/bin/hog.sh" | head -1)
PAUSED=$(pgrep -f "$LAB/bin/paused.sh" | head -1)
STUB=$(pgrep -f "$LAB/bin/stubborn.sh" | head -1)
WORK=$(pgrep -f "$LAB/bin/worker.sh" | head -1)
PARENT=$(pgrep -f lab-parent | head -1)

kill -STOP "$HOG"
sleep 1
kill -CONT "$HOG"
kill -TERM "$HOG"

kill -CONT "$PAUSED"
kill -TERM "$PAUSED"

kill -TERM "$STUB"
sleep 1
grep -q "TERM ignored" "$LAB/stubborn.log" || true
kill -KILL "$STUB"

ZOMB=$(ps -u "$USER" -o pid=,stat=,cmd= | awk '$2 ~ /Z/ {print $1; exit}')
if [ -n "${ZOMB:-}" ]; then
  kill -KILL "$ZOMB" 2>/dev/null || true
fi
kill -TERM "$PARENT"

kill -TERM "$WORK"
sleep 3
wait "$MGR" 2>/dev/null || true

bash "$ROOT/procs-lab-kit/procs-lab-check.sh"
