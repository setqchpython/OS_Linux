# ТЗ № 1 · ввод в эксплуатацию helpdesk 2.4.1 на helpdesk-01

Курсовая работа по дисциплине ОП.05 «Операционные системы и среды».
Компания «Пятый склад», группа эксплуатации. Заявка CHG-2026-1047.

| | |
|---|---|
| Автор | Селезнев Александр, группа РПО25/1, GitHub @setqchpython |
| Кто выполнил | все разделы: учётные записи, sudo, размещение, права, запуск 2.4.1, приёмка |
| Сервер | helpdesk-01. Приёмка снята 2026-11-09 на Debian 13 (ядро 6.12.113), не на образе Ubuntu 24.04 |
| Итог приёмки | 25 из 25 |

## Состав репозитория

| Файл | Что в нём |
|---|---|
| [`server-passport.md`](server-passport.md) | паспорт сервера до изменений |
| [`runbook.md`](runbook.md) | журнал работ |
| [`access-matrix.md`](access-matrix.md) | матрица доступа |
| [`provision.sh`](provision.sh) | выкладка на стенде, развёрнутом заново |
| [`acceptance.txt`](acceptance.txt) | вывод приёмки после финального прогона |
| [`optional/check-access.sh`](optional/check-access.sh) | проверка каждой клетки матрицы, +2 |
| [`optional/rollback.md`](optional/rollback.md) | план возврата к 2.3, +2 |
| [`screenshots/`](screenshots/) | отказ запуска и приёмка со всеми OK |
| [`tools/`](tools/) | сбор паспорта, матрицы и первого отказа с виртуальной машины |

## Как воспроизвести

Команды выполняются в виртуальной машине Ubuntu 24.04. Каталог репозитория — тот, где лежит этот файл.

```bash
cd ~/Downloads
wget -O helpdesk-stand.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/helpdesk-stand.sh
wget -O helpdesk-acceptance.sh https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/proekty/ekspluataciya-servera/materials/helpdesk-acceptance.sh

sudo bash ~/Downloads/helpdesk-stand.sh
bash tools/collect-passport.sh | tee server-passport.md
sudo bash tools/show-start-failure.sh
sudo bash ~/Downloads/helpdesk-stand.sh

sudo bash provision.sh
sudo bash ~/Downloads/helpdesk-acceptance.sh | tee acceptance.txt
sudo bash tools/collect-access-matrix.sh | tee access-matrix.md
sudo bash optional/check-access.sh
```

Пароли стенда, которые задаёт `provision.sh`: `Ivanov-2026`, `Petrova-2026`, `Smirnova-2026`.

Не получилось: приёмка снята на Debian 13, а в задании указан образ Ubuntu 24.04.
Нейросеть использовалась для: черновика `provision.sh`, схемы прав и текста документов. Вывод команд в паспорт, журнал, матрицу и `acceptance.txt` снят с виртуальной машины 2026-11-09.
