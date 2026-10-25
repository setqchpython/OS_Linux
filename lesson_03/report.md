# Пользователи, группы и sudo · отчёт

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: 25.10.2026  
Среда: Debian 13.7.0 (trixie) · VirtualBox · пользователь darkle · Bash

## Учётная запись

Команды:

```bash
id, getent passwd $(whoami)
```

![Учётная запись](screenshots/01-id.png)

Результат: `uid=1000(darkle) gid=1000(darkle)`; в passwd — login, x, UID, GID, GECOS, home, shell.

Подпишите семь полей своей строки /etc/passwd.

Вывод: имя · пароль (x) · UID · GID · комментарий · домашний каталог · оболочка.

## passwd и shadow

Команды:

```bash
ls -l /etc/passwd /etc/shadow
```

![passwd и shadow](screenshots/02-shadow.png)

Результат: `/etc/passwd` читается всем; `/etc/shadow` только root (600).

Почему shadow закрыт для остальных пользователей.

Вывод: в shadow хранятся хеши паролей — их нельзя показывать обычным пользователям.

## Группы

Команды:

```bash
groups, getent group sudo
```

![Группы](screenshots/03-groups.png)

Результат: основная группа — первая в `id`/`groups`; `sudo` — дополнительная для администрирования.

Где основная группа, где дополнительные.

Вывод: основная задаётся в passwd; дополнительные — через `usermod -aG`.

## Правила sudo

Команды:

```bash
sudo -l
```

![Правила sudo](screenshots/04-sudo.png)

Результат: `sudo -l` показывает разрешённые команды для группы `sudo`.

Какое правило даёт вам права администратора.

Вывод: правило `%sudo ALL=(ALL:ALL) ALL` в sudoers (через группу sudo).

## Команда mobile-app

Команды:

```bash
getent group mobile-dev mobile-qa sudo
id lead dev qa guest
```

![Команда mobile-app](screenshots/05-team.png)

Результат: lead — mobile-dev, mobile-qa, sudo; dev — mobile-dev; qa — mobile-qa; guest — без project-групп.

Совпадают ли группы со схемой ролей.

Вывод: да, совпадает со схемой практики mobile-app.

## Каталоги проекта

Команды:

```bash
ls -l /srv/mobile
stat -c '%a %G' /srv/mobile/src /srv/mobile/reports
```

![Каталоги проекта](screenshots/06-dirs.png)

Результат: `src` — группа mobile-dev, `reports` — mobile-qa; права `2770`.

Что означает каждая цифра в 2770.

Вывод: 2 setgid; 7 rwx владелец (root); 7 rwx группа; 0 — остальным нет доступа.

## Тесты доступа

Команды:

```bash
sudo -u lead touch /srv/mobile/src/lead.txt
sudo -u dev ls /srv/mobile/reports
```

![Тесты доступа](screenshots/07-access.png)

Результат: lead/dev/qa — доступ по ролям; dev и qa не видят «чужой» каталог; guest — отказ.

Результаты таблицы тестов доступа.

Вывод: см. `access-tests.md`.

## Проверка

Команды:

```bash
sudo bash users-lab-kit/team-lab-check.sh
```

![Проверка](screenshots/08-check.png)

Результат: **21 из 21**.

Итог проверки; какие пункты потребовали исправления.

Вывод: все пункты OK с первого прогона после `setup-mobile-lab.sh`.

## Отказ sudo в журнале

Команды:

```bash
journalctl -t sudo | grep -i "not in sudoers"
```

![Отказ sudo в журнале](screenshots/09-denied.png)

Результат: guest выполнил `sudo whoami` — отказ; запись в `journalctl -t sudo`.

Кто, когда и какую команду пытался выполнить.

Вывод: пользователь guest не в sudoers; sudo зафиксировал отказ.

## setup-team.sh (свой проект)

![setup-team.sh](screenshots/10-setup-team.png)

Результат: `OK: shop-api team under /srv/shop-api`.

## Почему постоянная работа под root опасна

1. Любая опечатка в `rm`/`chmod` бьёт по всей системе.
2. Вредоносная программа сразу получает полные права.
3. Невозможно понять, какой человек выполнил действие — всё от root.

## Практика-тест · темы 04–05

Код результата:

```
…
```

## Перед сдачей

- [x] Проверка: 21 из 21.
- [x] access-tests.md заполнен.
- [x] access-model.md и setup-team.sh проверены на ВМ.
- [ ] Код теста 04–05 в отчёте.
