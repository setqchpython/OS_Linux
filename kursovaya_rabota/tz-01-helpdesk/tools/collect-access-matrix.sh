#!/bin/bash
# Фактическая матрица после provision.sh.
#   sudo bash tools/collect-access-matrix.sh | tee access-matrix.md
[ "$(id -u)" = 0 ] || { echo "Запустите через sudo" >&2; exit 1; }

show() {
  echo
  echo "### $1"
  echo
  echo '```'
  echo "\$ $2"
  bash -c "$2" 2>&1 || true
  echo '```'
}

echo "# Матрица доступа · helpdesk-01"
echo
echo "Снято $(date '+%F %H:%M') после выкладки. Команды выполнены на этой виртуальной машине."
echo
echo "## Фактические права"
echo
echo '```'
echo "\$ stat -c '%A %a %U:%G %n' /etc/helpdesk /etc/helpdesk/helpdesk.conf /etc/helpdesk/secrets.env /var/lib/helpdesk /var/lib/helpdesk/tickets.db /var/log/helpdesk /var/log/helpdesk/api.log /srv/helpdesk/static /srv/helpdesk/static/index.html /run/helpdesk"
stat -c '%A %a %U:%G %n' \
  /etc/helpdesk /etc/helpdesk/helpdesk.conf /etc/helpdesk/secrets.env \
  /var/lib/helpdesk /var/lib/helpdesk/tickets.db \
  /var/log/helpdesk /var/log/helpdesk/api.log \
  /srv/helpdesk/static /srv/helpdesk/static/index.html /run/helpdesk
echo '```'

show "Кто в какой группе" "id helpdesk; id ivanov; id petrova; id smirnova"
show "Чтение helpdesk.conf" "sudo -u helpdesk test -r /etc/helpdesk/helpdesk.conf && echo helpdesk-читает; sudo -u petrova test -r /etc/helpdesk/helpdesk.conf && echo petrova-читает; sudo -u smirnova test -r /etc/helpdesk/helpdesk.conf && echo smirnova-читает || echo smirnova-не-читает; sudo -u nobody test -r /etc/helpdesk/helpdesk.conf && echo nobody-читает || echo nobody-не-читает"
show "Секреты" "sudo -u helpdesk test -r /etc/helpdesk/secrets.env && echo helpdesk-читает; sudo -u ivanov test -r /etc/helpdesk/secrets.env && echo ivanov-читает || echo ivanov-не-читает; sudo -u smirnova test -r /etc/helpdesk/secrets.env && echo smirnova-читает || echo smirnova-не-читает"
show "Каталог данных" "sudo -u helpdesk ls /var/lib/helpdesk; sudo -u ivanov ls /var/lib/helpdesk && echo ivanov-вошёл || echo ivanov-не-вошёл"
show "Журнал" "sudo -u ivanov tail -n 1 /var/log/helpdesk/api.log; sudo -u smirnova tail -n 1 /var/log/helpdesk/api.log; sudo -u smirnova sh -c 'echo x >> /var/log/helpdesk/api.log' && echo smirnova-записала || echo smirnova-не-записала; sudo -u nobody tail -n 1 /var/log/helpdesk/api.log && echo nobody-прочитал || echo nobody-не-прочитал"
show "Веб-интерфейс" "sudo -u helpdesk test -r /srv/helpdesk/static/index.html && echo helpdesk-читает; sudo -u helpdesk test -w /srv/helpdesk/static && echo helpdesk-пишет || echo helpdesk-не-пишет; sudo -u petrova test -w /srv/helpdesk/static && echo petrova-пишет; sudo -u smirnova test -x /srv/helpdesk/static && echo smirnova-входит || echo smirnova-не-входит"
show "Общий каталог setgid" "f=/srv/helpdesk/static/.matrix-check; sudo -u petrova touch \"\$f\"; stat -c '%A %U:%G %n' \"\$f\"; sudo -u ivanov rm \"\$f\"; echo 'ivanov удалил файл petrova'"
show "Маска процесса службы" "pid=\$(cat /run/helpdesk/api.pid); ps -o user,pid,cmd -p \"\$pid\"; awk '/^Umask/ {print}' /proc/\$pid/status"
show "sudo -l -U ivanov" "sudo -l -U ivanov"
show "Файл sudoers" "stat -c '%A %a %U:%G %n' /etc/sudoers.d/helpdesk; echo; cat /etc/sudoers.d/helpdesk"

cat << 'EOF'

## Как тройка прав закрывает матрицу

| Ресурс | Владелец | Группа | Режим | Кто получает доступ |
|---|---|---|---|---|
| `helpdesk.conf` | helpdesk | helpdesk-dev | 440 | владелец читает, группа разработчиков читает, остальные нет |
| `secrets.env` | helpdesk | helpdesk | 400 | читает только владелец-служба; последняя цифра 0, иначе служба не стартует |
| `/var/lib/helpdesk` | helpdesk | helpdesk | 700 | войти и писать может только служба |
| `/var/log/helpdesk` | helpdesk | helpdesk-readers | 2750, setgid | служба пишет, разработчики и поддержка входят читать; новые файлы наследуют группу читателей |
| `api.log` | helpdesk | helpdesk-readers | 640 из-за umask 0027 | владелец пишет, группа читает, поддержка записать не может |
| `/srv/helpdesk/static` | helpdesk | helpdesk-dev | 2570, setgid | служба читает без записи, разработчики пишут, новый файл получает группу helpdesk-dev |

Группа `helpdesk-readers` нужна потому, что и разработчики, и поддержка должны читать журнал, а писать его должна только служба. Одной группы `helpdesk-dev` или `helpdesk-support` для этой клетки не хватает.
EOF
