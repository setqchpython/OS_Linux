# Диагностика процессов и управление ресурсами · отчёт

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: …  
Среда: Debian 13.7.0 (trixie) · VirtualBox · пользователь darkle · Bash

## Нагрузка

![Нагрузка](screenshots/01-load.png)

Результат: …

Вывод: load average сравнивают с `nproc`; два `yes` поднимают минутную нагрузку.

## top

![top](screenshots/02-top.png)

Результат: …

Вывод: шапка — load, Tasks, %Cpu (us/sy/id), память; yes в R с высоким %CPU.

## htop

![htop](screenshots/03-htop.png)

Результат: …

Вывод: полосы ядер и памяти; при отсутствии htop — см. `top -b -n 1` на снимке.

## Поиск виновника

![Поиск](screenshots/04-find.png)

Результат: …

Вывод: `ps --sort=-%cpu`, `pstree -s -p`, `/proc/PID/cwd`.

## nice и renice

![nice](screenshots/05-nice.png)

Результат: …

Вывод: на одном ядре nice 0 vs 10 ≈ 90/10 %; уменьшить nice может только root.

## time

![time](screenshots/06-time.png)

Результат: …

Вывод: sleep — real≈2; Python — real≈user; find — заметный sys; `/usr/bin/time` — пик %M.

## Память

![Память](screenshots/07-memory.png)

Результат: …

Вывод: `ps --sort=-rss`; после kill память возвращается (available растёт).

## Инцидент: симптом

![Симптом](screenshots/08-lab-find.png)

Результат: …

Вывод: web.log медленнее 60–100 ms; report-calc и sync-agent в ps/pstree.

## Инцидент: исправление

![Исправление](screenshots/09-lab-fix.png)

Результат: …

Вывод: renice → TERM builder/calc → KILL sync-agent → rm sync.lock; web-worker жив.

## Проверка

![Проверка](screenshots/10-lab-check.png)

Результат: …

Вывод: …

## Перед сдачей

- [ ] Проверка diag-lab: 11 из 11.
- [ ] `postmortem.md` и `incident.md` заполнены.
