# Паспорт сервера · helpdesk-01 · 2026-11-09 03:15

Снят сразу после развёртывания стенда, до создания учёток и переноса файлов.
Каждый блок — команда и её вывод с этой виртуальной машины.

### Версия системы и ядра

```
$ cat /etc/os-release; uname -a
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
NAME="Debian GNU/Linux"
VERSION_ID="13"
VERSION="13 (trixie)"
VERSION_CODENAME=trixie
DEBIAN_VERSION_FULL=13.7
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
Linux Debian 6.12.113+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.113-1 (2026-10-15) x86_64 GNU/Linux
```

### Процессор и память

```
$ nproc; free -h
4
               total        used        free      shared  buff/cache   available
Mem:           5.8Gi       1.1Gi       4.2Gi       8.1Mi       861Mi       4.8Gi
Swap:          1.8Gi          0B       1.8Gi
```

### Разделы и заполнение

```
$ df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  2.9G     0  2.9G   0% /dev
tmpfs          tmpfs     599M  1.2M  598M   1% /run
/dev/sda1      ext4       33G  5.8G   25G  19% /
tmpfs          tmpfs     3.0G   12K  3.0G   1% /dev/shm
tmpfs          tmpfs     5.0M  8.0K  5.0M   1% /run/lock
tmpfs          tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs          tmpfs     3.0G   48K  3.0G   1% /tmp
tmpfs          tmpfs     599M   92K  599M   1% /run/user/1000
```

### Учётные записи из задания

```
$ for u in helpdesk ivanov petrova smirnova; do getent passwd "$u" || echo "$u: нет такой записи"; done
helpdesk: нет такой записи
ivanov: нет такой записи
petrova: нет такой записи
smirnova: нет такой записи
```

### Группы из задания

```
$ for g in helpdesk helpdesk-dev helpdesk-support sudo; do getent group "$g" || echo "$g: нет такой группы"; done; id
helpdesk: нет такой группы
helpdesk-dev: нет такой группы
helpdesk-support: нет такой группы
sudo:x:27:darkle,lead,owner
uid=0(root) gid=0(root) groups=0(root)
```

### Процессы helpdesk и владелец

```
$ ps -eo user,pid,lstart,cmd | grep -E '[h]elpdesk' || echo 'процессов helpdesk нет'
darkle      2662 Mon Nov  9 03:15:26 2026 /bin/bash /home/darkle/helpdesk-2.3/bin/helpdesk-api
root        2677 Mon Nov  9 03:15:26 2026 bash -c ps -eo user,pid,lstart,cmd | grep -E '[h]elpdesk' || echo 'процессов helpdesk нет'
```

### Каталог релиза 2.4.1

```
$ ls -ld /tmp/helpdesk-release-2.4.1; ls -lR /tmp/helpdesk-release-2.4.1
drwxr-xr-x 6 darkle darkle 120 Nov  9 03:15 /tmp/helpdesk-release-2.4.1
/tmp/helpdesk-release-2.4.1:
total 0
drwxr-xr-x 2 darkle darkle 80 Nov  9 03:15 bin
drwxr-xr-x 2 darkle darkle 80 Nov  9 03:15 conf
drwxr-xr-x 2 darkle darkle 60 Nov  9 03:15 data
drwxr-xr-x 3 darkle darkle 80 Nov  9 03:15 static

/tmp/helpdesk-release-2.4.1/bin:
total 8
-rwxr-xr-x 1 darkle darkle 1368 Nov  9 03:15 helpdesk-api
-rwxr-xr-x 1 darkle darkle  928 Nov  9 03:15 helpdesk-ctl

/tmp/helpdesk-release-2.4.1/conf:
total 8
-rw-r--r-- 1 darkle darkle 239 Nov  9 03:15 helpdesk.conf
-rw-r--r-- 1 darkle darkle  84 Nov  9 03:15 secrets.env

/tmp/helpdesk-release-2.4.1/data:
total 4
-rw-r--r-- 1 darkle darkle 19 Nov  9 03:15 tickets.db

/tmp/helpdesk-release-2.4.1/static:
total 4
drwxr-xr-x 2 darkle darkle  60 Nov  9 03:15 css
-rw-r--r-- 1 darkle darkle 104 Nov  9 03:15 index.html

/tmp/helpdesk-release-2.4.1/static/css:
total 4
-rw-r--r-- 1 darkle darkle 29 Nov  9 03:15 app.css
```

### Права секретов и маска в поставке

```
$ stat -c '%A %a %U:%G %n' /tmp/helpdesk-release-2.4.1/conf/* /tmp/helpdesk-release-2.4.1/bin/*; echo; grep -n UMASK /tmp/helpdesk-release-2.4.1/conf/helpdesk.conf
-rw-r--r-- 644 darkle:darkle /tmp/helpdesk-release-2.4.1/conf/helpdesk.conf
-rw-r--r-- 644 darkle:darkle /tmp/helpdesk-release-2.4.1/conf/secrets.env
-rwxr-xr-x 755 darkle:darkle /tmp/helpdesk-release-2.4.1/bin/helpdesk-api
-rwxr-xr-x 755 darkle:darkle /tmp/helpdesk-release-2.4.1/bin/helpdesk-ctl

8:UMASK=0002
```

### Версия 2.3 в домашнем каталоге

```
$ ls -ld "$HOME/helpdesk-2.3" "$HOME/helpdesk-2.3/bin" 2>&1; ls -l "$HOME/helpdesk-2.3/bin" 2>&1
drwxr-xr-x 3 darkle darkle 4096 Nov  9 03:15 /home/darkle/helpdesk-2.3
drwxr-xr-x 2 darkle darkle 4096 Nov  9 03:15 /home/darkle/helpdesk-2.3/bin
total 4
-rwxr-xr-x 1 darkle darkle 62 Nov  9 03:15 helpdesk-api
```

## Что показалось неправильным

- Версия 2.3 запущена из домашнего каталога сотрудника, а не из `/usr/local/bin`, и не от служебной учётной записи. Так нельзя по СТ-01.
- Релиз 2.4.1 лежит в `/tmp`. Секреты в поставке доступны не только службе: режим файла шире, чем «только helpdesk».
- В `helpdesk.conf` стоит `UMASK=0002`. Для новых файлов службы это не закрывает группу на запись и не закрывает остальных.
- Учёток `helpdesk`, `ivanov`, `petrova`, `smirnova` и групп ролей на сервере ещё нет. Правил sudo для helpdesk нет.
