# Модель доступа · проект shop-api (домашнее задание)

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: …

## Роли (4)

| Роль | Учётная запись | Группы | Назначение |
|---|---|---|---|
| владелец | owner | shop-dev, shop-support, sudo | администрирование, оба каталога |
| разработчик | developer | shop-dev | код и конфиг приложения в `app/` |
| поддержка | support | shop-support | журналы в `logs/` |
| подрядчик | contractor | — | только домашний каталог |

## Каталоги на /srv

| Путь | Группа | Права | Содержимое |
|---|---|---|---|
| `/srv/shop-api/app` | shop-dev | 2770 | исходники, конфиги |
| `/srv/shop-api/logs` | shop-support | 2770 | журналы службы |

`2770` — setgid-каталог: новые файлы наследуют группу; доступ только владельцу root и группе.

## Пять тестов доступа

| № | Команда | Ожидается | Получено |
|---|---|---|---|
| 1 | `sudo -u developer touch /srv/shop-api/app/deploy.yaml` | разрешено | … |
| 2 | `sudo -u developer ls /srv/shop-api/logs` | отказ | … |
| 3 | `sudo -u support touch /srv/shop-api/logs/access.log` | разрешено | … |
| 4 | `sudo -u contractor ls /srv/shop-api/app` | отказ | … |
| 5 | `sudo -u owner touch /srv/shop-api/logs/audit.log` | разрешено | … |

Создание: `sudo bash setup-team.sh` (см. репозиторий).
