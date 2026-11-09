#!/bin/bash
# Аудит учётной записи. Ничего не изменяет.
# На чистом стенде: sudo bash audit-user.sh kozlov
set -u
if [ $# -ne 1 ]; then
  echo "Запуск: sudo bash audit-user.sh ИМЯ" >&2
  exit 2
fi
user=$1
if ! id "$user" >/dev/null 2>&1; then
  echo "Нет учётной записи $user" >&2
  exit 1
fi
home=$(getent passwd "$user" | cut -d: -f6)

echo "== учётная запись"
getent passwd "$user"
echo
echo "== группы"
id "$user"
echo
echo "== sudo"
if grep -R -n -F -- "$user" /etc/sudoers /etc/sudoers.d 2>/dev/null; then
  :
else
  echo "строк с именем $user в sudoers нет"
fi
sudo -l -U "$user" 2>&1 || true
echo
echo "== процессы"
if ps -u "$user" -o pid= >/dev/null 2>&1; then
  ps -u "$user" -o pid,ppid,lstart,etime,cmd || true
  for pid in $(ps -u "$user" -o pid= 2>/dev/null); do
    echo "-- pid $pid"
    if [ -r "/proc/$pid/cmdline" ]; then
      tr '\0' ' ' < "/proc/$pid/cmdline"
      echo
    fi
    echo -n "cwd: "; readlink "/proc/$pid/cwd" 2>/dev/null || echo "?"
    echo -n "exe: "; readlink "/proc/$pid/exe" 2>/dev/null || echo "?"
  done
else
  echo "процессов нет"
fi
echo
echo "== файлы вне домашнего каталога $home"
find / -xdev -user "$user" ! -path "${home}*" -printf '%m %u:%g %p\n' 2>/dev/null || true
echo
echo "== setuid, которых не было в снимке стенда"
if [ -r /root/.ops03-setuid.list ]; then
  find / -xdev -perm -4000 -type f 2>/dev/null | sort | comm -13 /root/.ops03-setuid.list - || true
else
  echo "снимка /root/.ops03-setuid.list нет"
fi
