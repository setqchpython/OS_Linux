# Таблица состояний · procs-lab

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: …

После запуска `manager.py` заполните по `ps --ppid PID`:

| Процесс | Состояние (stat) | Комментарий |
|---|---|---|
| hog.sh | R | грузит CPU |
| worker.sh | S | спит в цикле |
| paused.sh | T | остановлен SIGSTOP |
| stubborn.sh | S | sleep в цикле |
| lab-parent | S | sleep, дочерний зомби |

Копия с ВМ: `~/procs-lab/states.md` (нужна для проверки 11/11).
