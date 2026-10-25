# Файловая система Linux · отчёт

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: 25.10.2026  
Среда: Debian 13.7.0 (trixie) · VirtualBox · пользователь darkle · Bash

## Корневой каталог

Команды:

```bash
pwd, ls -lah /
```

![Корневой каталог](screenshots/01-root.png)

Результат: `pwd` в каталоге лабораторной дал `/home/darkle/linux-fhs-lab`. `ls -lah /` показал единое дерево: каталоги `bin`, `boot`, `dev`, `etc`, `home`, `usr`, `var`, ссылки `bin -> usr/bin`, `lib -> usr/lib`.

Что такое корневой каталог, чем абсолютный путь отличается от относительного.

Вывод: Корневой каталог `/` — вершина единого дерева файловой системы Linux. Абсолютный путь всегда начинается с `/` и однозначен; относительный задаётся от текущего каталога (`pwd`) и меняется при `cd`.

## Домашний каталог

Команды:

```bash
cd ~, pwd, ls -a
```

![Домашний каталог](screenshots/02-home.png)

Результат: Домашний каталог — `/home/darkle`. `ls -a` показал скрытые `.bashrc`, `.bash_history`, `.config` и обычные `Desktop`, `Documents`, `linux-fhs-lab`.

Где находится домашний каталог, что такое скрытые файлы.

Вывод: Домашний каталог пользователя — `/home/имя` (для root — `/root`). Скрытые файлы и каталоги начинаются с точки; без ключа `-a` команда `ls` их не показывает.

## Каталог /etc

Команды:

```bash
cat /etc/os-release; getent passwd
```

![Каталог /etc](screenshots/03-system.png)

Результат: Debian GNU/Linux 13 (trixie), `DEBIAN_VERSION_FULL=13.7`. Учётная запись: `darkle:x:1000:1000:darkle,,,:/home/darkle:/bin/bash` — UID 1000, дом `/home/darkle`, оболочка `/bin/bash`.

Версия системы, UID, домашний каталог и оболочка.

Вывод: В `/etc/os-release` — сведения о дистрибутиве; `getent passwd` читает учётные записи (UID, домашний каталог, оболочка).

## Программы и PATH

Команды:

```bash
command -v, type, echo $PATH
```

![Программы и PATH](screenshots/04-programs.png)

Результат: `type cd` — `cd is a shell builtin`. `ls` задан как alias `ls --color=auto`. `$PATH` = `/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games`.

Как оболочка находит программу.

Вывод: Внешние команды ищутся по каталогам из `$PATH` слева направо; встроенные (`type cd` → builtin) выполняет сама оболочка.

## Изменяемые данные

Команды:

```bash
ls /var; findmnt -T /run
```

![Изменяемые данные](screenshots/05-var.png)

Результат: В `/var` есть `backups`, `cache`, `lib`, `local`, `log`, `mail`, `opt`, `run`, `spool`, `tmp`. `findmnt -T /run`: `/run` — **tmpfs**.

Назначение /var/lib, /var/log, /var/cache и /run.

Вывод: `/var/lib` — постоянные данные служб; `/var/log` — журналы; `/var/cache` — кэш; `/run` — volatile-данные работающей системы (часто tmpfs), очищается при перезагрузке.

## Устройства

Команды:

```bash
ls -l /dev/null; echo $?
```

![Устройства](screenshots/06-dev.png)

Результат: `crw-rw-rw- 1 root root 1, 3 … /dev/null` — символьное устройство (`c`). `echo $?` → `0`.

Тип устройства и код завершения.

Вывод: `/dev/null` — символьное устройство (`c`); запись в него отбрасывается. `$?` после успешной команды — `0`.

## Файлы /proc

Команды:

```bash
cat /proc/uptime; cp; sleep 5
```

![Файлы /proc](screenshots/07-proc.png)

Результат: Живой `/proc/uptime` сначала `70.12 175.85`, копия после `sleep 5` осталась `75.46 196.82`, повторное чтение `/proc/uptime` — `70.12 175.86`. `diff` показал расхождение.

Почему копия не меняется.

Вывод: Содержимое `/proc` формирует ядро при каждом чтении. Копия в обычный файл — снимок на момент `cp`; после `sleep` живой `/proc/uptime` уже другой.

## Сетевые интерфейсы

Команды:

```bash
ls /sys/class/net
```

![Сетевые интерфейсы](screenshots/08-sys.png)

Результат: `enp0s3` (сеть VirtualBox) и `lo` (петля).

Какие интерфейсы есть в системе.

Вывод: В `/sys/class/net` перечислены сетевые интерфейсы (например `lo`, `enp0s3` — зависит от ВМ).

## inode и ссылки

Команды:

```bash
ls -li; rm data/info.txt; cat info-link.txt
```

![inode и ссылки](screenshots/09-links.png)

Результат: inode **787518** у `data/info.txt` и `data/info-hard.txt` (число ссылок 2). `info-link.txt` — symlink (inode 785948) на `data/info.txt`. После `rm data/info.txt`: `cat info-link.txt` — ошибка, `cat data/info-hard.txt` — `Linux filesystem`.

Чем жёсткая ссылка отличается от символической.

Вывод: Жёсткая ссылка — второе имя того же inode; данные живы, пока есть хотя бы одно имя. Символическая ссылка хранит путь; при удалении цели чтение через symlink ломается, через жёсткую ссылку — нет.

## Место на диске

Команды:

```bash
findmnt /; df -h .; du -sh data
```

![Место на диске](screenshots/10-space.png)

Результат: `findmnt /` — `/dev/sda1`, **ext4**. `df -h .` — диск 33G, занято 5.6G, свободно 26G (19%). `du -sh data` — **8.0K**.

Чем df отличается от du.

Вывод: `df` — свободное/занятое место на всей файловой системе точки монтирования; `du` — суммарный размер конкретного каталога.

## Монтирование tmpfs

Команды:

```bash
findmnt -T mount-demo
```

![Монтирование tmpfs](screenshots/11-mount-before.png)

Результат: До монтирования в `mount-demo` был `before.txt`. После `sudo mount … tmpfs` `findmnt` показал tmpfs 16M на `…/mount-demo`; в каталоге видны только `.` и `..`.

Почему before.txt перестал быть виден.

Вывод: После `mount` каталог стал точкой монтирования tmpfs; видно содержимое tmpfs, файлы нижнего слоя (`before.txt`) временно скрыты.

## Отключение tmpfs

Команды:

```bash
cat mount-demo/before.txt
```

![Отключение tmpfs](screenshots/12-mount-after.png)

Результат: В tmpfs записан `inside.txt` (`inside tmpfs`). После `umount` снова читается `before.txt` (`on original filesystem`). `inside.txt` исчез вместе с tmpfs.

Что стало с inside.txt.

Вывод: После `umount` снова виден `before.txt`. `inside.txt` жил в tmpfs в RAM и исчез вместе с отмонтированием.

## Файлы shop-api

Команды:

```bash
find model-root -type f
```

![Файлы shop-api](screenshots/13-model.png)

Результат: `find` нашёл три файла модели:
`model-root/etc/shop-api/app.conf`, `model-root/var/lib/shop-api/info.txt`, `model-root/var/log/shop-api/app.log`.

Почему выбран каждый каталог.

Вывод: Настройки — `etc/shop-api`, данные — `var/lib/shop-api`, журнал — `var/log/shop-api` — по FHS и типу данных.

## Размещение shop-api (модель)

| Файл | Каталог | Основание |
|---|---|---|
| Исполняемый файл | `/usr/local/bin` | программа вне пакетов дистрибутива |
| Настройки | `/etc/shop-api` | конфигурационные файлы |
| База данных | `/var/lib/shop-api` | постоянные изменяемые данные |
| Журнал | `/var/log/shop-api` | журналы службы |
| Номер процесса | `/run/shop-api` | сведения о работающей службе до перезагрузки |

## Итоговая задача

| Путь в системе | Оставить / заменить | Правильный путь | Основание (часть урока) |
|---|---|---|---|
| `/home/admin/shop.log` | заменить | `/var/log/shop-api/access.log` (или `app.log`) | журнал — `/var/log`, не домашний каталог (ч. 4, 8) |
| `/usr/bin/config.json` | заменить | `/etc/shop-api/app.conf` | настройки — `/etc`, не каталог программ (ч. 2, 8) |
| `/tmp/database.db` | заменить | `/var/lib/shop-api/database.db` | БД постоянная — `/var/lib`, не `/tmp` (ч. 4, 8) |
| `/etc/shop-api/app.conf` | оставить | `/etc/shop-api/app.conf` | конфигурация по FHS |
| `/var/log/shop-api/access.log` | оставить | `/var/log/shop-api/access.log` | журнал службы |
| `/var/lib/shop-api/database.db` | оставить | `/var/lib/shop-api/database.db` | данные службы |

## Домашнее задание · backup-agent

| Файл / данные | Каталог | Основание |
|---|---|---|
| Программа `backup-agent` | `/usr/local/bin/backup-agent` | ПО, установленное вручную, вне пакетов — `/usr/local/bin` |
| Настройки | `/etc/backup-agent/` | Конфигурационные файлы — `/etc` |
| Журнал работы | `/var/log/backup-agent/backup.log` | Журналы служб — `/var/log` |
| Список сделанных копий (метаданные) | `/var/lib/backup-agent/` | Постоянные данные приложения — `/var/lib` |
| Номер процесса (PID-файл) | `/run/backup-agent/backup-agent.pid` | Сведения о работающем процессе — `/run` (tmpfs) |

Сами архивы резервных копий хранятся на отдельном носителе (вне этой таблицы размещения в FHS).

## Практика-тест · тема 03

Код результата (после прохождения теста на сайте занятия 3):

```
OS03.eyJ2IjoxLCJuIjoi0KHQtdC70LXQt9C90LXQsiDQkNC70LXQutGB0LDQvdC00YAiLCJnIjoi0KDQn9CeMjUvMiIsImEiOlsieDB4eHh4eHgiLCIiLCIiLCIiLCIwMDAwMTExMTEiLCIwMjM1Nzg5IiwiIiwiMCIsIjAiLCIwIiwiMDEyIiwiMCIsIjAxIiwiIiwiIiwiMCIsIjAiLCIwMTIzIiwiMTEwMDAxMSIsIiIsIjM0NTYiLCIyMzQiLCIiLCIwIiwiIiwiMyIsIjAxMjM0NSIsIjAiLCIwMTc4IiwiMDIiLCIwMzQiLCIwMzQiLCIxYyIsIjciLCIxNTY4IiwiIiwiNDA2NTIzIiwiMjIzMTEwMDAiLCIwIiwiMDMyMTQ1Il0sInMiOjI4LCJ0Ijo0MCwibSI6NCwiZCI6IjIwMjYtMTAtMjVUMDA6MDAiLCJ1Ijo2MCwibyI6MCwieCI6NX0.0ac0987bad
```

## Перед сдачей

- [x] tmpfs отключена (`umount` выполнен, снова виден `before.txt`)
- [x] Снимки открываются из `report.md`
- [x] Результаты получены в моей системе (Debian 13.7, пользователь darkle)
- [x] Работа в репозитории `OS_Linux`
