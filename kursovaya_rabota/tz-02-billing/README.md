# ТЗ № 2 · инцидент на сервере приёма платежей billing-02

Курсовая работа по дисциплине ОП.05 «Операционные системы и среды».
Компания «Пятый склад», группа эксплуатации. Инцидент INC-2026-0312, уровень P1.

| | |
|---|---|
| Автор | Селезнев Александр, группа РПО25/1, GitHub @setqchpython |
| Кто выполнил | все разделы: диск, выгрузка, процессы, настройки, хронология, приёмка |
| Сервер | billing-02. Приёмка снята 2026-11-09 на Debian 13 (ядро 6.12.113), не на образе Ubuntu 24.04 |
| Итог приёмки | 12 из 12 |

## Состав репозитория

| Файл | Что в нём |
|---|---|
| [`server-passport.md`](server-passport.md) | паспорт и замеры до изменений |
| [`runbook.md`](runbook.md) | журнал работ |
| [`postmortem.md`](postmortem.md) | разбор инцидента |
| [`cleanup-logs.sh`](cleanup-logs.sh) | профилактика: список журналов и дампов, удаление только с `--apply` |
| [`acceptance.txt`](acceptance.txt) | вывод приёмки после финального прогона |
| [`tools/recover.sh`](tools/recover.sh) | те же команды, что в журнале, одним запуском |
| [`optional/disk-watch.sh`](optional/disk-watch.sh) | контроль заполнения раздела, +2 |
| [`optional/snapshot.sh`](optional/snapshot.sh) | снимок состояния инцидента, +2 |
| [`screenshots/`](screenshots/) | замеры до и после, дерево процессов, приёмка |

## Как воспроизвести

Только в виртуальной машине Ubuntu 24.04. После перезагрузки машины раздел журналов пропадает, стенд запускают заново. Сервер целиком не перезагружать.

```bash
cd ~/Downloads
wget -O billing-stand.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/billing-stand.sh
wget -O billing-acceptance.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/billing-acceptance.sh

cd ~/tz-02-billing
sudo bash ~/Downloads/billing-stand.sh
bash tools/collect-passport.sh | tee server-passport.md
sudo bash tools/recover.sh
sudo bash ~/Downloads/billing-acceptance.sh | tee acceptance.txt
bash optional/snapshot.sh billing
```

Проверка скрипта профилактики на чистом стенде, отдельно от восстановления:

```bash
sudo bash ~/Downloads/billing-stand.sh
sudo bash cleanup-logs.sh
sudo bash cleanup-logs.sh --apply
find /var/log/billing -name 'export-*'
```

Без ключа скрипт только печатает список. С ключом удаляет журналы старше 7 дней и `core*`. Файл выгрузки остаётся.

Не получилось: приёмка снята на Debian 13, а в задании указан образ Ubuntu 24.04.
Нейросеть использовалась для: черновика скриптов и текста разбора. Вывод команд в паспорте, журнале, postmortem и `acceptance.txt` снят с виртуальной машины 2026-11-09.
