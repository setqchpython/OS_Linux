#!/bin/bash
# Контроль раздела: каталог и порог в процентах.
# Печатает заполнение и пять самых больших файлов.
# Выход 1, если заполнение строго выше порога.
set -eu
if [ $# -ne 2 ]; then
  echo "Запуск: bash disk-watch.sh КАТАЛОГ ПОРОГ" >&2
  exit 2
fi
dir=$1
limit=$2
[ -d "$dir" ] || { echo "Нет каталога $dir" >&2; exit 2; }
case $limit in
  ''|*[!0-9]*) echo "Порог — целое число процентов" >&2; exit 2 ;;
esac

pct=$(df --output=pcent "$dir" | tail -1 | tr -dc 0-9)
echo "Каталог: $dir"
df -h "$dir" | tail -1
echo "Заполнение: ${pct}% (порог ${limit}%)"
echo "Пять самых больших файлов:"
find "$dir" -xdev -type f -printf '%s %p\n' | sort -n -r | head -n 5 || true

if [ "$pct" -gt "$limit" ]; then
  exit 1
fi
