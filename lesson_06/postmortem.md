# Postmortem · учебный сервер diag-lab

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: 25.10.2026

## Симптом

04:38 · load average вырос; в `web.log` время «запроса» сайта **170–200 ms** вместо обычных **60–100 ms** (учебный web-worker).

## Причина

`report-builder.sh` запустил **8** процессов `report-calc.sh` (по 2 на каждое из **4** ядер) с бесконечным циклом — они заняли CPU.
`sync-agent.sh` завис в `sleep`, игнорировал TERM; PID был записан в `sync.lock`.

## Действия

1. `renice -n 19` всем `report-calc.sh`, пауза ~12 s — в `report.log` строки `nice=19`, ответ сайта улучшился.
2. `kill -TERM report-builder`; отдельно `kill` оставшихся `report-calc` (потомки не завершились с родителем).
3. TERM sync-agent → без эффекта → `kill -9`; `rm sync.lock`.
4. **web-worker** не останавливали. Проверка: **`finish-diag-lab.sh` → 11 из 11**.

## Профилактика

- Тяжёлые отчёты запускать с **nice 19** и числом workers **≤ nproc**.
- После завершения родителя проверять `pgrep -af report-calc`.
- У sync-agent — таймаут блокировки и обработчик TERM; после KILL удалять `sync.lock`.
