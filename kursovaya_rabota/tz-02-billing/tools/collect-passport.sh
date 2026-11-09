#!/bin/bash
# Паспорт и замеры ДО любых изменений. Сразу после billing-stand.sh:
#   bash tools/collect-passport.sh | tee server-passport.md
set -u

run() {
  echo
  echo "### $1"
  echo
  echo '```'
  echo "\$ $2"
  bash -c "$2" 2>&1 || true
  echo '```'
}

echo "# Паспорт сервера · billing-02 · $(date '+%F %H:%M')"
echo
echo "Снят до очистки, переноса выгрузки и сигналов. Числа из этого файла переносятся в раздел «Симптом» postmortem."

run "Версия системы и ядра" "cat /etc/os-release; uname -a"
run "Процессор и память" "nproc; free -h"
run "Разделы" "df -hT; echo; df -h /var/log/billing"
run "Что занимает раздел журналов" "du -ah /var/log/billing | sort -h | tail -n 30"
run "Учётные записи из задания" "getent passwd billing; getent group billing; id billing; getent passwd lebedeva || echo 'lebedeva: нет такой записи'"
run "Настройки без пароля" "stat -c '%A %a %U:%G %n' /etc/billing/billing.conf; grep -E '^(LOG_LEVEL|EXPORT_DIR|LOG_FILE|REPORT_WORKERS)=' /etc/billing/billing.conf"
run "Процессы billing" "ps -u billing -o user,pid,ppid,stat,%cpu,etime,cmd --forest; echo; pstree -p billing || true"
run "Нагрузка" "uptime"
run "Выгрузка и дамп" "ls -lh /var/log/billing/exports /var/log/billing/core* 2>&1; echo; find /var/log/billing -type f -mtime +7 | wc -l"
