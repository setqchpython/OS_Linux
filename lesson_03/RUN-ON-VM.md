# Lesson 03 · Debian (darkle), только занятие 5 + тест 4–5

## 1. Подтянуть репо

```bash
cd ~/OS_Linux && git pull
```

## 2. Практика mobile-app → 21/21

```bash
cd ~/OS_Linux/lesson_03
sudo bash setup-mobile-lab.sh
sudo bash users-lab-kit/team-lab-check.sh
```

Пароль учёток lab по умолчанию: `LabPass123!` (или `export LAB_PASS=...` перед setup).

Заполни **access-tests.md** (ожидание уже в шаблоне — допиши «Получено»).

Опыт guest + sudo:

```bash
su - guest
sudo whoami   # отказ
exit
sudo journalctl -t sudo | tail -5
```

Снимки 01–09 — по `users-lab-kit/README.md` (шаблон отчёта).

## 3. Свой проект

```bash
sudo bash ~/OS_Linux/lesson_03/setup-team.sh
```

Проверь вручную 5 тестов из **access-model.md** (`sudo -u …`).

Скрин: **`screenshots/10-setup-team.png`** — запуск setup-team.sh.

## 4. Тест занятий 4 и 5

https://algorthimization-course-vvodnoe.vercel.app/op05-operacionnye-sistemy-i-sredy/testy/tema-04-05/index.html

Код результата → конец **report.md**.

## 5. Уборка (после сдачи всех ДЗ или перед снимками — по желанию препода)

```bash
for u in lead dev qa guest owner developer support contractor; do sudo userdel -r $u 2>/dev/null; done
sudo groupdel mobile-dev mobile-qa shop-dev shop-support 2>/dev/null
sudo rm -rf /srv/mobile /srv/shop-api
```

## 6. На Windows

Заполни **report.md**, скопируй скрины в `lesson_03/screenshots/`, `git add lesson_03 && git commit`.

Преподавателю ссылку на репо **не отправляем**, пока не готовы lesson_01…06.
