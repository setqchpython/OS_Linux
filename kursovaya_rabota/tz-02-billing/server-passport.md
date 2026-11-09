# Паспорт сервера · billing-02 · 2026-11-09 03:17

Снят до очистки, переноса выгрузки и сигналов. Числа из этого файла переносятся в раздел «Симптом» postmortem.

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
Mem:           5.8Gi       1.2Gi       3.7Gi       8.1Mi       1.2Gi       4.7Gi
Swap:          1.8Gi          0B       1.8Gi
```

### Разделы

```
$ df -hT; echo; df -h /var/log/billing
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  2.9G     0  2.9G   0% /dev
tmpfs          tmpfs     599M  1.3M  598M   1% /run
/dev/sda1      ext4       33G  6.0G   25G  20% /
tmpfs          tmpfs     3.0G   12K  3.0G   1% /dev/shm
tmpfs          tmpfs     5.0M  8.0K  5.0M   1% /run/lock
tmpfs          tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs          tmpfs     3.0G   20K  3.0G   1% /tmp
tmpfs          tmpfs     599M   92K  599M   1% /run/user/1000
/dev/loop0     ext4      182M  157M   21M  89% /var/log/billing

Filesystem      Size  Used Avail Use% Mounted on
/dev/loop0      182M  157M   21M  89% /var/log/billing
```

### Что занимает раздел журналов

```
$ du -ah /var/log/billing | sort -h | tail -n 30
16K	/var/log/billing/api.log
1.0M	/var/log/billing/api-2026-11-06.log
1.0M	/var/log/billing/api-2026-11-07.log
1.0M	/var/log/billing/api-2026-11-08.log
7.0M	/var/log/billing/api-2026-10-18.log
7.0M	/var/log/billing/api-2026-10-19.log
7.0M	/var/log/billing/api-2026-10-20.log
7.0M	/var/log/billing/api-2026-10-21.log
7.0M	/var/log/billing/api-2026-10-22.log
7.0M	/var/log/billing/api-2026-10-23.log
7.0M	/var/log/billing/api-2026-10-24.log
7.0M	/var/log/billing/api-2026-10-25.log
7.0M	/var/log/billing/api-2026-10-26.log
7.0M	/var/log/billing/api-2026-10-27.log
7.0M	/var/log/billing/api-2026-10-28.log
7.0M	/var/log/billing/api-2026-10-29.log
7.0M	/var/log/billing/api-2026-10-30.log
7.0M	/var/log/billing/api-2026-10-31.log
7.0M	/var/log/billing/api-2026-11-01.log
9.0M	/var/log/billing/exports
9.0M	/var/log/billing/exports/export-2026-09.csv
40M	/var/log/billing/core.billing-api.4711
157M	/var/log/billing
```

### Учётные записи из задания

```
$ getent passwd billing; getent group billing; id billing; getent passwd lebedeva || echo 'lebedeva: нет такой записи'
billing:x:996:985::/var/lib/billing:/usr/sbin/nologin
billing:x:985:
uid=996(billing) gid=985(billing) groups=985(billing)
lebedeva: нет такой записи
```

### Настройки без пароля

```
$ stat -c '%A %a %U:%G %n' /etc/billing/billing.conf; grep -E '^(LOG_LEVEL|EXPORT_DIR|LOG_FILE|REPORT_WORKERS)=' /etc/billing/billing.conf
-rw-rw-rw- 666 root:root /etc/billing/billing.conf
LOG_LEVEL=debug
LOG_FILE=/var/log/billing/api.log
EXPORT_DIR=/var/log/billing/exports
REPORT_WORKERS=auto
```

### Процессы billing

```
$ ps -u billing -o user,pid,ppid,stat,%cpu,etime,cmd --forest; echo; pstree -p billing || true
USER         PID    PPID STAT %CPU     ELAPSED CMD
billing     3382    1510 Ss    0.0       03:49 python3 /usr/local/lib/billing/billingd.py
billing     3384    3382 S     0.0       03:49  \_ /bin/bash /usr/local/bin/billing-api
billing     3470    3384 R     0.0       00:02  |   \_ /bin/bash /usr/local/bin/billing-api
billing     3385    3382 S     0.0       03:49  \_ /bin/bash /usr/local/bin/billing-report
billing     3391    3385 R     0.8       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 1
billing     3392    3385 R     9.4       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 2
billing     3393    3385 R    95.6       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 3
billing     3395    3385 R    47.2       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 4
billing     3396    3385 R    92.0       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 5
billing     3397    3385 R    91.7       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 6
billing     3398    3385 R     6.7       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 7
billing     3399    3385 R    48.9       03:49      \_ /bin/bash /usr/local/bin/billing-report --worker 8

python3(3382)-+-billing-api(3384)
              `-billing-report(3385)-+-billing-report(3391)
                                     |-billing-report(3392)
                                     |-billing-report(3393)
                                     |-billing-report(3395)
                                     |-billing-report(3396)
                                     |-billing-report(3397)
                                     |-billing-report(3398)
                                     `-billing-report(3399)
```

### Нагрузка

```
$ uptime
 03:19:28 up 17 min,  1 user,  load average: 24.60, 9.42, 3.54
```

### Выгрузка и дамп

```
$ ls -lh /var/log/billing/exports /var/log/billing/core* 2>&1; echo; find /var/log/billing -type f -mtime +7 | wc -l
-rw-r--r-- 1 billing billing  40M Nov  7 03:15 /var/log/billing/core.billing-api.4711

/var/log/billing/exports:
total 9.0M
-rw-r--r-- 1 billing billing 9.0M Oct 28 03:15 export-2026-09.csv

16
```
