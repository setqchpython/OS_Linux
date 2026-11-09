#!/bin/bash
# Паспорт ops-03 до изменений. Сразу после стенда:
#   sudo bash tools/collect-passport.sh | tee server-passport.md
set -u
[ "$(id -u)" = 0 ] || { echo "Запустите через sudo" >&2; exit 1; }

run() {
  echo
  echo "### $1"
  echo
  echo '```'
  echo "\$ $2"
  bash -c "$2" 2>&1 || true
  echo '```'
}

echo "# Паспорт сервера · ops-03 · $(date '+%F %H:%M')"
echo
echo "Снят до блокировки kozlov. Содержимое заметок, ключей и дампа сюда не копируется."

run "Версия системы и ядра" "cat /etc/os-release; uname -a"
run "Процессор, память, разделы" "nproc; free -h; df -hT"
run "Учётные записи и группы" "getent passwd kozlov orlova lebedeva; echo; id kozlov; id orlova; id lebedeva; echo; getent group sudo devops finance"
run "Вход и sudo до блокировки" "passwd -S kozlov; getent passwd kozlov | cut -d: -f7; echo; sudo -l -U kozlov"
run "Процессы kozlov" "ps -u kozlov -o user,pid,ppid,lstart,etime,cmd; echo; for p in \$(ps -u kozlov -o pid=); do echo PID \$p; tr '\\0' ' ' < /proc/\$p/cmdline; echo; readlink /proc/\$p/cwd; readlink /proc/\$p/exe; done"
run "Кто слушает порт" "ss -ltnp || netstat -ltnp"
run "Каталоги из задания" "ls -ld /srv/devops /srv/devops/deploy /srv/devops/keys /srv/finance /srv/share /home/kozlov; echo; ls -lR /srv/devops /srv/finance /srv/share /home/kozlov"
run "Файлы kozlov вне домашнего каталога" "find / -xdev -user kozlov ! -path '/home/kozlov*' -printf '%m %u:%g %p\\n'"
run "Новые setuid" "find / -xdev -perm -4000 -type f | sort | comm -13 /root/.ops03-setuid.list -"
