#!/bin/bash
# Свой инцидент для incident.md (CPU). Запуск: bash run-homework-incident.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG="$ROOT/_capture/homework-incident.log"
mkdir -p "$ROOT/_capture"
{
  echo "=== до ==="
  nproc
  uptime
  free -h
  echo "=== во время (yes на CPU) ==="
  yes >/dev/null &
  Y=$!
  sleep 8
  uptime
  ps -eo pid,ppid,stat,%cpu,cmd --sort=-%cpu | head -5
  pstree -s -p "$Y" || true
  echo "=== после kill ==="
  kill "$Y"
  wait "$Y" 2>/dev/null || true
  sleep 2
  uptime
  free -h
  echo "=== GNU time (-f %e %M) ==="
  if [ -x /usr/bin/time ]; then
    /usr/bin/time -f '%e s, %M KB' python3 -c 'sum(range(20_000_000))'
  else
    echo "Нет /usr/bin/time — установите: sudo apt install -y time"
    echo "Пока встроенный time bash:"
    TIMEFORMAT='real %R s'
    time python3 -c 'sum(range(20_000_000))'
  fi
} | tee "$LOG"
echo "Лог: $LOG — перенесите факты в incident.md"
