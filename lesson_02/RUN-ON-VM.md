# Lesson 02 · что сделать в Debian (ВМ darkle)

Материалы занятия 4 только. Лекция: части 1–7, квест — часть 7.

## 1. Скопировать kit с репозитория (один раз)

Если репо уже клонировано:

```bash
mkdir -p ~/files-lab
cp ~/OS_Linux/materials/zanyatie-04-fajly-maski-poisk/files-lab-kit/files-lab-setup.sh ~/files-lab/
cp ~/OS_Linux/materials/zanyatie-04-fajly-maski-poisk/files-lab-kit/files-lab-check.sh ~/files-lab/
cp ~/OS_Linux/materials/zanyatie-04-fajly-maski-poisk/files-lab-kit/journal-template.md ~/files-lab/journal.md
```

Если репо нет на ВМ — скопируй папку `files-lab-kit` с Windows или `git pull` на хосте и shared folder.

## 2. Подготовка к квесту

```bash
rm -rf ~/files-lab/sorted    # только если нужно начать квест заново
bash ~/files-lab/files-lab-setup.sh
cd ~/files-lab/inbox
```

## 3. Квест inbox (12 пунктов)

Выполняй из `~/files-lab/inbox`, если не указано иначе.

```bash
# 1
mkdir -p ~/files-lab/sorted/{docs,images,logs,data}

# 2
mv "my report.txt" my-report.txt

# 3 — сначала проверка маски
ls report-*.txt my-report.txt
mv report-*.txt my-report.txt ../sorted/docs/

# 4
ls *.{jpg,png}
mv *.{jpg,png} ../sorted/images/

# 5
mv app.log app.log.1 app.log.2 error.log ../sorted/logs/

# 6 — оригиналы csv остаются в inbox
cp *.csv ../sorted/data/

# 7
ls *.bak
rm -v *.bak

# 8
find ~/files-lab -type f -size +1M -ls
rm -v ~/files-lab/inbox/dump.bin   # после ls -lh убедись, что это нужный файл

# 9
find ~/files-lab/inbox -type f -mtime +30 > ~/files-lab/answers.txt

# 10
ls -A
grep -n . .settings
cat .settings >> ~/files-lab/answers.txt

# 11 — в man ls найти сортировку по размеру (-S)
echo 'ls -lS ~/files-lab/sorted/images' >> ~/files-lab/answers.txt

# 12
locate os-release | head -1 >> ~/files-lab/answers.txt
```

Журнал: допиши **≥12 команд** в `~/files-lab/journal.md` (команда, результат, безопасный вариант).

```bash
bash ~/files-lab/files-lab-check.sh
```

Должно быть **12 из 12**.

## 4. Отчёт по лекции (10 скринов)

По шаблону `lesson_02/report.md` — команды из частей 1–6 лекции (site, inbox, cp -i, rm/rmdir, маски, find, locate, man).  
Имена файлов: `screenshots/01-site-tree.png` … `10-check.png`.

## 5. Синхронизация с репо на Windows

Скопируй на ПК в `lesson_02/`:

- `~/files-lab/journal.md` → `lesson_02/journal.md`
- `~/files-lab/answers.txt` → `lesson_02/answers.txt`
- скрины в `lesson_02/screenshots/`

Заполни **Результат** и **Вывод** в `report.md` по своему терминалу.

`cheatsheet.md` уже в репо — при необходимости поправь примеры под свои формулировки.

## 6. Git

```bash
git add lesson_02/
git commit -m "lesson_02: files lab report and quest"
git push origin main
```
