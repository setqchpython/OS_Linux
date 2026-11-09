# Курсовая работа · бланк сдачи

**Студент:** Селезнев Александр
**Группа:** РПО25/1
**ТЗ:** № 1 helpdesk-01, № 2 billing-02, № 3 ops-03
**Я в паре:** работу выполнил один, без второго практиканта
**Напарник:** нет
**GitHub:** @setqchpython

## Ссылки

| Что | Ссылка |
|---|---|
| ТЗ 1 | https://github.com/setqchpython/OS_Linux/tree/main/kursovaya_rabota/tz-01-helpdesk |
| ТЗ 2 | https://github.com/setqchpython/OS_Linux/tree/main/kursovaya_rabota/tz-02-billing |
| ТЗ 3 | https://github.com/setqchpython/OS_Linux/tree/main/kursovaya_rabota/tz-03-offboarding |
| `acceptance.txt` ТЗ 1 | https://github.com/setqchpython/OS_Linux/blob/main/kursovaya_rabota/tz-01-helpdesk/acceptance.txt |
| `acceptance.txt` ТЗ 2 | https://github.com/setqchpython/OS_Linux/blob/main/kursovaya_rabota/tz-02-billing/acceptance.txt |
| `acceptance.txt` ТЗ 3 | https://github.com/setqchpython/OS_Linux/blob/main/kursovaya_rabota/tz-03-offboarding/acceptance.txt |

**Итог приёмки на финальном прогоне:** ТЗ 1 — 25 из 25, ТЗ 2 — 12 из 12, ТЗ 3 — 17 из 17
**Задачи по выбору:** сделаны. ТЗ 1: `optional/check-access.sh`, `optional/rollback.md`. ТЗ 2: `optional/disk-watch.sh`, `optional/snapshot.sh`. ТЗ 3: `optional/lock-user.sh`, `optional/access-review.md`.

## Перед отправкой

- [x] Решения трёх заданий лежат в `kursovaya_rabota`, репозиторий публичный
- [x] README каждого задания начинается с таблицы: автор, что выполнено, итог приёмки
- [x] Финальный прогон сделан на стенде, развёрнутом заново, вывод в `acceptance.txt`
- [x] В журнале работ у команд стоят номера требований
- [x] Снимки из задания лежат в `screenshots/`
- [x] В документах нет пустых `___` из шаблона бланка

**Не получилось:** приёмка снята на Debian 13, в задании указан Ubuntu 24.04. В ТЗ 3 `audit-user.sh` на этом прогоне не напечатал новый setuid, хотя копия `kbash` без этого бита попала в резервный каталог. Второго практиканта нет, повтор его части не делался.
**ИИ:** использовал для черновика скриптов и текста документов. Вывод команд в паспорте, журнале и `acceptance.txt` снят с виртуальной машины 2026-11-09.
