# Паспорт сервера · ops-03 · 2026-11-09 03:20

Снят до блокировки kozlov. Содержимое заметок, ключей и дампа сюда не копируется.

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

### Процессор, память, разделы

```
$ nproc; free -h; df -hT
4
               total        used        free      shared  buff/cache   available
Mem:           5.8Gi       1.2Gi       3.6Gi       8.1Mi       1.3Gi       4.6Gi
Swap:          1.8Gi          0B       1.8Gi
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  2.9G     0  2.9G   0% /dev
tmpfs          tmpfs     599M  1.3M  598M   1% /run
/dev/sda1      ext4       33G  6.0G   25G  20% /
tmpfs          tmpfs     3.0G   12K  3.0G   1% /dev/shm
tmpfs          tmpfs     5.0M  8.0K  5.0M   1% /run/lock
tmpfs          tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs          tmpfs     3.0G   20K  3.0G   1% /tmp
tmpfs          tmpfs     599M   92K  599M   1% /run/user/1000
/dev/loop0     ext4      182M  3.1M  175M   2% /var/log/billing
```

### Учётные записи и группы

```
$ getent passwd kozlov orlova lebedeva; echo; id kozlov; id orlova; id lebedeva; echo; getent group sudo devops finance
kozlov:x:1018:1028:Kozlov Dmitry, DevOps:/home/kozlov:/bin/bash
orlova:x:1019:1029:Orlova Anna, DevOps:/home/orlova:/bin/bash
lebedeva:x:1020:1030:Lebedeva Irina, accountant:/home/lebedeva:/bin/bash

uid=1018(kozlov) gid=1028(kozlov) groups=1028(kozlov),27(sudo),1026(devops),1027(finance)
uid=1019(orlova) gid=1029(orlova) groups=1029(orlova),1026(devops)
uid=1020(lebedeva) gid=1030(lebedeva) groups=1030(lebedeva),1027(finance)

sudo:x:27:darkle,lead,owner,kozlov
devops:x:1026:kozlov,orlova
finance:x:1027:kozlov,lebedeva
```

### Вход и sudo до блокировки

```
$ passwd -S kozlov; getent passwd kozlov | cut -d: -f7; echo; sudo -l -U kozlov
kozlov P 2026-11-09 0 99999 7 -1
/bin/bash

Matching Defaults entries for kozlov on Debian:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin,
    use_pty

User kozlov may run the following commands on Debian:
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL
```

### Процессы kozlov

```
$ ps -u kozlov -o user,pid,ppid,lstart,etime,cmd; echo; for p in $(ps -u kozlov -o pid=); do echo PID $p; tr '\0' ' ' < /proc/$p/cmdline; echo; readlink /proc/$p/cwd; readlink /proc/$p/exe; done
USER         PID    PPID                  STARTED     ELAPSED CMD
kozlov      4505    1510 Mon Nov  9 03:20:03 2026       00:02 /bin/bash /home/kozlov/.local/bin/sync-tunnel.sh
kozlov      4507    1510 Mon Nov  9 03:20:03 2026       00:02 python3 -m http.server 8000 --directory /home/kozlov
kozlov      4508    4505 Mon Nov  9 03:20:03 2026       00:02 sleep 30

PID 4505
/bin/bash /home/kozlov/.local/bin/sync-tunnel.sh 
/home/darkle/labs/tz-03-offboarding
/usr/bin/bash
PID 4507
python3 -m http.server 8000 --directory /home/kozlov 
/home/darkle/labs/tz-03-offboarding
/usr/bin/python3.13
PID 4508
sleep 30 
/home/darkle/labs/tz-03-offboarding
/usr/bin/sleep
```

### Кто слушает порт

```
$ ss -ltnp || netstat -ltnp
State  Recv-Q Send-Q Local Address:Port Peer Address:PortProcess                           
LISTEN 0      4096       127.0.0.1:631       0.0.0.0:*    users:(("cupsd",pid=3485,fd=7))  
LISTEN 0      5            0.0.0.0:8000      0.0.0.0:*    users:(("python3",pid=4507,fd=3))
LISTEN 0      4096           [::1]:631          [::]:*    users:(("cupsd",pid=3485,fd=6))  
```

### Каталоги из задания

```
$ ls -ld /srv/devops /srv/devops/deploy /srv/devops/keys /srv/finance /srv/share /home/kozlov; echo; ls -lR /srv/devops /srv/finance /srv/share /home/kozlov
drwx------ 4 kozlov   kozlov  4096 Nov  9 03:19 /home/kozlov
drwxrws--- 4 kozlov   devops  4096 Nov  9 03:19 /srv/devops
drwxrws--- 2 kozlov   devops  4096 Nov  9 03:19 /srv/devops/deploy
drwxrws--- 2 kozlov   devops  4096 Nov  9 03:19 /srv/devops/keys
drwxrws--- 2 lebedeva finance 4096 Nov  9 03:19 /srv/finance
drwxrwxrwt 2 root     root    4096 Nov  9 03:19 /srv/share

/home/kozlov:
total 4
-rw------- 1 kozlov kozlov 68 Nov  9 03:19 notes.txt

/srv/devops:
total 8
drwxrws--- 2 kozlov devops 4096 Nov  9 03:19 deploy
drwxrws--- 2 kozlov devops 4096 Nov  9 03:19 keys

/srv/devops/deploy:
total 8
-rwxr-x--- 1 kozlov devops 188 Nov  9 03:19 deploy.sh
-rw-r----- 1 kozlov devops 107 Nov  9 03:19 inventory.ini

/srv/devops/keys:
total 4
-rw------- 1 kozlov devops 141 Nov  9 03:19 prod_deploy_key

/srv/finance:
total 4
-rw-rw---- 1 lebedeva finance 62 Nov  9 03:19 payments-2026-09.csv

/srv/share:
total 28
-rw-r--r-- 1 kozlov kozlov 24774 Nov  9 03:19 db_dump_2026-09-28.sql
```

### Файлы kozlov вне домашнего каталога

```
$ find / -xdev -user kozlov ! -path '/home/kozlov*' -printf '%m %u:%g %p\n'
644 kozlov:kozlov /srv/share/db_dump_2026-09-28.sql
2770 kozlov:devops /srv/devops
2770 kozlov:devops /srv/devops/keys
600 kozlov:devops /srv/devops/keys/prod_deploy_key
2770 kozlov:devops /srv/devops/deploy
750 kozlov:devops /srv/devops/deploy/deploy.sh
640 kozlov:devops /srv/devops/deploy/inventory.ini
```

### Новые setuid

```
$ find / -xdev -perm -4000 -type f | sort | comm -13 /root/.ops03-setuid.list -
```
