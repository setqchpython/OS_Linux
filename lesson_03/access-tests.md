# Таблица тестов доступа · команда mobile-app

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: …

| № | Пользователь | Команда | Ожидается | Получено |
|---|---|---|---|---|
| 1 | lead | `sudo -u lead touch /srv/mobile/src/lead.txt` | разрешено | … |
| 2 | lead | `sudo -u lead ls /srv/mobile/reports` | разрешено | … |
| 3 | dev | `sudo -u dev touch /srv/mobile/src/main.kt` | разрешено | … |
| 4 | dev | `sudo -u dev ls /srv/mobile/reports` | отказ (Permission denied) | … |
| 5 | qa | `sudo -u qa touch /srv/mobile/reports/test-1.md` | разрешено | … |
| 6 | qa | `sudo -u qa ls /srv/mobile/src` | отказ (Permission denied) | … |
| 7 | guest | `sudo -u guest ls /srv/mobile/src` | отказ (Permission denied) | … |
| 8 | guest | `sudo -u guest ls /srv/mobile/reports` | отказ (Permission denied) | … |

## Схема ролей

| Роль | Учётная запись | Группы | Каталоги | Может | Не может |
|---|---|---|---|---|---|
| руководитель | lead | mobile-dev, mobile-qa, sudo | src, reports | писать в оба каталога, sudo | — |
| разработчик | dev | mobile-dev | src | писать в src | reports, sudo |
| тестировщик | qa | mobile-qa | reports | писать в reports | src, sudo |
| внешний сотрудник | guest | — | — | домашний каталог | src, reports, sudo |

## Почему постоянная работа под root опасна

1. Ошибка в команде (`rm -rf`) уничтожает систему без запроса прав.
2. Программы получают полный доступ — компрометация одного сервиса = вся машина.
3. Нет аудита «кто что сделал» — все действия выглядят как root (принцип минимальных привилегий).
