# Матрица доступа · helpdesk-01

Снято 2026-11-09 03:15 после выкладки. Команды выполнены на этой виртуальной машине.

## Фактические права

```
$ stat -c '%A %a %U:%G %n' /etc/helpdesk /etc/helpdesk/helpdesk.conf /etc/helpdesk/secrets.env /var/lib/helpdesk /var/lib/helpdesk/tickets.db /var/log/helpdesk /var/log/helpdesk/api.log /srv/helpdesk/static /srv/helpdesk/static/index.html /run/helpdesk
dr-xr-x--- 550 helpdesk:helpdesk-dev /etc/helpdesk
-r--r----- 440 helpdesk:helpdesk-dev /etc/helpdesk/helpdesk.conf
-r-------- 400 helpdesk:helpdesk /etc/helpdesk/secrets.env
drwx------ 700 helpdesk:helpdesk /var/lib/helpdesk
-rw------- 600 helpdesk:helpdesk /var/lib/helpdesk/tickets.db
drwxr-s--- 2750 helpdesk:helpdesk-readers /var/log/helpdesk
-rw-r----- 640 helpdesk:helpdesk-readers /var/log/helpdesk/api.log
dr-xrws--- 2570 helpdesk:helpdesk-dev /srv/helpdesk/static
-r--rw---- 460 helpdesk:helpdesk-dev /srv/helpdesk/static/index.html
drwxr-xr-x 755 helpdesk:helpdesk /run/helpdesk
```

### Кто в какой группе

```
$ id helpdesk; id ivanov; id petrova; id smirnova
uid=997(helpdesk) gid=986(helpdesk) groups=986(helpdesk)
uid=1015(ivanov) gid=1023(ivanov) groups=1023(ivanov),1020(helpdesk-dev),1022(helpdesk-readers)
uid=1016(petrova) gid=1024(petrova) groups=1024(petrova),1020(helpdesk-dev),1022(helpdesk-readers)
uid=1017(smirnova) gid=1025(smirnova) groups=1025(smirnova),1021(helpdesk-support),1022(helpdesk-readers)
```

### Чтение helpdesk.conf

```
$ sudo -u helpdesk test -r /etc/helpdesk/helpdesk.conf && echo helpdesk-читает; sudo -u petrova test -r /etc/helpdesk/helpdesk.conf && echo petrova-читает; sudo -u smirnova test -r /etc/helpdesk/helpdesk.conf && echo smirnova-читает || echo smirnova-не-читает; sudo -u nobody test -r /etc/helpdesk/helpdesk.conf && echo nobody-читает || echo nobody-не-читает
helpdesk-читает
petrova-читает
smirnova-не-читает
nobody-не-читает
```

### Секреты

```
$ sudo -u helpdesk test -r /etc/helpdesk/secrets.env && echo helpdesk-читает; sudo -u ivanov test -r /etc/helpdesk/secrets.env && echo ivanov-читает || echo ivanov-не-читает; sudo -u smirnova test -r /etc/helpdesk/secrets.env && echo smirnova-читает || echo smirnova-не-читает
helpdesk-читает
ivanov-не-читает
smirnova-не-читает
```

### Каталог данных

```
$ sudo -u helpdesk ls /var/lib/helpdesk; sudo -u ivanov ls /var/lib/helpdesk && echo ivanov-вошёл || echo ivanov-не-вошёл
tickets.db
ls: cannot open directory '/var/lib/helpdesk': Permission denied
ivanov-не-вошёл
```

### Журнал

```
$ sudo -u ivanov tail -n 1 /var/log/helpdesk/api.log; sudo -u smirnova tail -n 1 /var/log/helpdesk/api.log; sudo -u smirnova sh -c 'echo x >> /var/log/helpdesk/api.log' && echo smirnova-записала || echo smirnova-не-записала; sudo -u nobody tail -n 1 /var/log/helpdesk/api.log && echo nobody-прочитал || echo nobody-не-прочитал
2026-11-09 03:15:31 level=info GET /api/tickets 200
2026-11-09 03:15:31 level=info GET /api/tickets 200
sh: 1: cannot create /var/log/helpdesk/api.log: Permission denied
smirnova-не-записала
tail: cannot open '/var/log/helpdesk/api.log' for reading: Permission denied
nobody-не-прочитал
```

### Веб-интерфейс

```
$ sudo -u helpdesk test -r /srv/helpdesk/static/index.html && echo helpdesk-читает; sudo -u helpdesk test -w /srv/helpdesk/static && echo helpdesk-пишет || echo helpdesk-не-пишет; sudo -u petrova test -w /srv/helpdesk/static && echo petrova-пишет; sudo -u smirnova test -x /srv/helpdesk/static && echo smirnova-входит || echo smirnova-не-входит
helpdesk-читает
helpdesk-не-пишет
petrova-пишет
smirnova-не-входит
```

### Общий каталог setgid

```
$ f=/srv/helpdesk/static/.matrix-check; sudo -u petrova touch "$f"; stat -c '%A %U:%G %n' "$f"; sudo -u ivanov rm "$f"; echo 'ivanov удалил файл petrova'
-rw-rw-r-- petrova:helpdesk-dev /srv/helpdesk/static/.matrix-check
ivanov удалил файл petrova
```

### Маска процесса службы

```
$ pid=$(cat /run/helpdesk/api.pid); ps -o user,pid,cmd -p "$pid"; awk '/^Umask/ {print}' /proc/$pid/status
USER         PID CMD
helpdesk    2870 /bin/bash /usr/local/bin/helpdesk-api
Umask:	0027
```

### sudo -l -U ivanov

```
$ sudo -l -U ivanov
Matching Defaults entries for ivanov on Debian:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin,
    use_pty

User ivanov may run the following commands on Debian:
    (helpdesk) NOPASSWD: /usr/local/bin/helpdesk-ctl
```

### Файл sudoers

```
$ stat -c '%A %a %U:%G %n' /etc/sudoers.d/helpdesk; echo; cat /etc/sudoers.d/helpdesk
-r--r----- 440 root:root /etc/sudoers.d/helpdesk

# ПД-02: разработчики управляют только службой helpdesk, пароль не спрашивается.
%helpdesk-dev ALL=(helpdesk) NOPASSWD: /usr/local/bin/helpdesk-ctl
```

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
