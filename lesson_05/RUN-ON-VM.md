# Lesson 05 · ВМ

```bash
cd ~/OS_Linux
git fetch origin && git reset --hard origin/main
cd lesson_05
bash capture-lesson05.sh
python3 generate-screenshots.py
grep "Итог:" _capture/terminal.log
```

Должно **11 из 11**.

Скрины → **СКРИНЫ** на Windows → `lesson_05/screenshots/` → **«готово 05»**.

Дополнительно:

```bash
pstree -s -p $$   # в processes.md
bash graceful.sh &  # опыты TERM/KILL
cp ~/procs-lab/states.md ~/OS_Linux/lesson_05/states.md
```
