# Диагностика процессов и управление ресурсами · отчёт

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: 25.10.2026  
Среда: Debian 13.7.0 (trixie) · VirtualBox · пользователь darkle · Bash

## Нагрузка

Команды:

```bash
nproc; uptime
yes > /dev/null & yes > /dev/null &
sleep 25; uptime; cat /proc/loadavg; free -h
```

![Нагрузка](screenshots/01-load.png)

Результат: **4** ядра; в покое load **0.36**; два `yes` в фоне; `/proc/loadavg` совпадает с uptime; available ≈ **3.5 GiB**.

Вывод: load average сравнивают с `nproc`; рост минутного значения — очередь к CPU.

## top

Команды:

```bash
yes > /dev/null & sleep 2; top -b -n 1 | head -12
```

![top](screenshots/02-top.png)

Результат: шапка — load, Tasks, **%Cpu** (us/sy/ni/id), память; `yes` в таблице с высоким **%CPU**, состояние **R**.

Вывод: **sy** растёт, когда процесс часто пишет в `/dev/null`; первые строки — кто грузит CPU сейчас.

## htop

Команды:

```bash
htop   # или top -b -n 1, если htop недоступен
```

![htop](screenshots/03-htop.png)

Результат: полосы загрузки ядер и памяти; `yes` наверху списка.

Вывод: htop удобнее для сигналов и nice (F7/F8/F9); смысл полос как us/sy в top.

## Поиск виновника

Команды:

```bash
bash -c 'cd /tmp; while true; do :; done' &
ps -eo pid,ppid,user,stat,%cpu,etime,cmd --sort=-%cpu | head -4
pstree -s -p $P; ls -l /proc/$P/cwd
```

![Поиск](screenshots/04-find.png)

Результат: «безымянный» bash-цикл ~100 %CPU; cwd **`/tmp`**; цепочка до терминала.

Вывод: `ps --sort=-%cpu`, предки `pstree -s -p`, каталог `/proc/PID/cwd`.

## nice и renice

Команды:

```bash
taskset -c 0 yes & taskset -c 0 nice -n 10 yes &
renice -n 19 -p …; renice -n 5 (отказ); sudo renice -n 5
```

![nice](screenshots/05-nice.png)

Результат: на одном ядре nice **0** vs **10** — доли CPU ~90/10; уменьшить nice без root нельзя.

Вывод: `renice` только увеличивает nice обычному пользователю; root может вернуть меньшее значение.

## time

Команды:

```bash
time sleep 2; time python3 …; time find /usr
/usr/bin/time -f "%e s, %M KB" python3 -c 'bytearray(300_000_000)'
```

![time](screenshots/06-time.png)

Результат: у **sleep** real≈2, user≈0; у Python real≈user; у **find** заметный **sys**; GNU time — пик памяти.

Вывод: real ≫ user+sys — ожидание; `/usr/bin/time` даёт **%M** (пик RSS).

## Память

Команды:

```bash
free -h; python3 bytearray(600M) &
ps --sort=-rss | head; kill; free -h
```

![Память](screenshots/07-memory.png)

Результат: **available** падает, python3 первый в rss; после kill память возвращается.

Вывод: искать «пожирателя» через **`ps --sort=-rss`**.

## Инцидент: симптом

Команды:

```bash
python3 ~/diag-lab/bin/incident.py &
uptime; tail ~/diag-lab/web.log
ps --sort=-%cpu; pstree -p incident.py
```

![Симптом](screenshots/08-lab-find.png)

Результат: ответ сайта **~200 ms**; сверху **report-calc**; дерево от **incident.py**; **sync-agent** спит.

Вывод: симптом в цифрах из **web.log** + load + ps/pstree.

## Инцидент: исправление

Команды:

```bash
renice -n 19 -p $(pgrep -f diag-lab/bin/report-calc.sh)
kill report-builder; kill report-calc; kill -9 sync-agent; rm sync.lock
```

![Исправление](screenshots/09-lab-fix.png)

Результат: renice по полному пути к calc; sync **8502** снят **-9**; lock удалён; web.log быстрее.

Вывод: сначала смягчить (renice), потом убрать builder/calc и зависший sync; web-worker не трогать.

## Проверка

Команды:

```bash
bash finish-diag-lab.sh
bash diag-lab-kit/diag-lab-check.sh
```

![Проверка](screenshots/10-lab-check.png)

Результат: после **capture** на снимке **8 из 11**; финально **`finish-diag-lab.sh` → 11 из 11** (все пункты OK).

Вывод: нужны renice с записью **nice=19**, завершение calc/builder/sync и postmortem — см. `postmortem.md`.

## Перед сдачей

- [x] Проверка diag-lab: 11 из 11 (после finish-diag-lab).
- [x] `postmortem.md` и `incident.md` заполнены.
