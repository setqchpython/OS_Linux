# Таблица состояний · procs-lab

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: 25.10.2026

Снимок с ВМ после запуска `manager.py` (`~/procs-lab/states.md`):

| PID | Процесс | stat | Комментарий |
|---|---|---|---|
| 5805 | worker.sh | S+ | sleep в цикле |
| 5806 | hog.sh | R+ | нагрузка на CPU |
| 5807 | stubborn.sh | S+ | sleep, игнорирует первый TERM |
| 5808 | paused.sh | T+ | остановлен SIGSTOP |
| 5809 | lab-parent | S+ | sleep, дочерний зомби |

Кратко: hog **R**, paused **T**, worker и stubborn **S**.
