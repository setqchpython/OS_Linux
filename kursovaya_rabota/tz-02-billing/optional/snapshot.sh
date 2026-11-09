#!/bin/bash
# Снимок состояния инцидента в файл с датой и временем в имени.
#   bash optional/snapshot.sh billing
set -eu
if [ $# -ne 1 ]; then
  echo "Запуск: bash snapshot.sh ПОЛЬЗОВАТЕЛЬ" >&2
  exit 2
fi
user=$1
id "$user" >/dev/null
out="snapshot-${user}-$(date '+%Y%m%d-%H%M%S').txt"

{
  echo "# снимок $user $(date '+%F %T')"
  echo
  echo "== uptime"
  uptime
  echo
  echo "== df -h"
  df -h
  echo
  echo "== top -b -n 1"
  COLUMNS=120 top -b -n 1
  echo
  echo "== дерево процессов $user"
  if pstree -p "$user"; then
    :
  else
    ps -u "$user" -o pid,ppid,stat,%cpu,etime,cmd --forest
  fi
} > "$out"

echo "Записано: $out"
