#!/bin/bash
# Профилактика раздела журналов billing. Выгрузки не трогает.
#   sudo bash cleanup-logs.sh          только список
#   sudo bash cleanup-logs.sh --apply  удалить журналы старше 7 дней и дампы core*
set -eu
L=/var/log/billing
apply=0

if [ "${1:-}" = "--apply" ]; then
  apply=1
elif [ $# -gt 0 ]; then
  echo "Неизвестный ключ: $1" >&2
  echo "Запуск: sudo bash cleanup-logs.sh [--apply]" >&2
  exit 2
fi
[ -d "$L" ] || { echo "Нет каталога $L" >&2; exit 1; }

echo "Журналы старше 7 дней в $L:"
find "$L" -xdev -type f -mtime +7 \
  ! -path '*/exports/*' ! -name 'export-*' ! -name 'core*' -print | sort
echo
echo "Аварийные дампы core*:"
find "$L" -xdev -type f -name 'core*' \
  ! -path '*/exports/*' ! -name 'export-*' -print | sort
echo

if [ "$apply" -eq 0 ]; then
  echo "Без --apply ничего не удалено. Файлы export-* и каталоги exports не трогались."
  exit 0
fi

find "$L" -xdev -type f -mtime +7 \
  ! -path '*/exports/*' ! -name 'export-*' ! -name 'core*' -exec rm -f -- {} +
find "$L" -xdev -type f -name 'core*' \
  ! -path '*/exports/*' ! -name 'export-*' -exec rm -f -- {} +
echo "Удалены только журналы старше 7 дней и дампы. Выгрузки на месте."
