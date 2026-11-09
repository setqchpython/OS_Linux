#!/bin/bash
# Паспорт helpdesk-01 ДО изменений. Запускать сразу после helpdesk-stand.sh
# и до provision.sh:
#   bash tools/collect-passport.sh | tee server-passport.md
set -u

run() {
  local title="$1"
  local cmd="$2"
  echo
  echo "### $title"
  echo
  echo '```'
  echo "\$ $cmd"
  bash -c "$cmd" 2>&1 || true
  echo '```'
}

echo "# Паспорт сервера · helpdesk-01 · $(date '+%F %H:%M')"
echo
echo "Снят сразу после развёртывания стенда, до создания учёток и переноса файлов."
echo "Каждый блок — команда и её вывод с этой виртуальной машины."

run "Версия системы и ядра" "cat /etc/os-release; uname -a"
run "Процессор и память" "nproc; free -h"
run "Разделы и заполнение" "df -hT"
run "Учётные записи из задания" "for u in helpdesk ivanov petrova smirnova; do getent passwd \"\$u\" || echo \"\$u: нет такой записи\"; done"
run "Группы из задания" "for g in helpdesk helpdesk-dev helpdesk-support sudo; do getent group \"\$g\" || echo \"\$g: нет такой группы\"; done; id"
run "Процессы helpdesk и владелец" "ps -eo user,pid,lstart,cmd | grep -E '[h]elpdesk' || echo 'процессов helpdesk нет'"
run "Каталог релиза 2.4.1" "ls -ld /tmp/helpdesk-release-2.4.1; ls -lR /tmp/helpdesk-release-2.4.1"
run "Права секретов и маска в поставке" "stat -c '%A %a %U:%G %n' /tmp/helpdesk-release-2.4.1/conf/* /tmp/helpdesk-release-2.4.1/bin/*; echo; grep -n UMASK /tmp/helpdesk-release-2.4.1/conf/helpdesk.conf"
run "Версия 2.3 в домашнем каталоге" "ls -ld \"\$HOME/helpdesk-2.3\" \"\$HOME/helpdesk-2.3/bin\" 2>&1; ls -l \"\$HOME/helpdesk-2.3/bin\" 2>&1"

cat << 'EOF'

## Что показалось неправильным

- Версия 2.3 запущена из домашнего каталога сотрудника, а не из `/usr/local/bin`, и не от служебной учётной записи. Так нельзя по СТ-01.
- Релиз 2.4.1 лежит в `/tmp`. Секреты в поставке доступны не только службе: режим файла шире, чем «только helpdesk».
- В `helpdesk.conf` стоит `UMASK=0002`. Для новых файлов службы это не закрывает группу на запись и не закрывает остальных.
- Учёток `helpdesk`, `ivanov`, `petrova`, `smirnova` и групп ролей на сервере ещё нет. Правил sudo для helpdesk нет.
EOF
