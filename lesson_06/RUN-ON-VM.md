# Lesson 06 · ВМ

```bash
cd ~/OS_Linux
git fetch origin && git reset --hard origin/main
cd lesson_06
sudo apt install -y python3-pil util-linux   # taskset, PIL для PNG
# опционально для снимка 03: sudo apt install -y htop

bash capture-lesson06.sh
grep "Итог:" _capture/terminal.log    # нужно 11 из 11
python3 generate-screenshots.py
ls screenshots/
```

Свой инцидент (для `incident.md`):

```bash
bash run-homework-incident.sh
# допиши incident.md по _capture/homework-incident.log
```

Скрины → Telegram → **СКРИНЫ** →  
`C:\Users\voerc\OS_Linux\lesson_06\screenshots\`  
(можно заменить PNG из `generate-screenshots.py` на фото терминала/htop).

Напиши **«готово 06»** — допишу отчёт и запушу.

**Занимает ~2–3 мин:** блок 01-load ждёт 25 с; diag-lab — ещё ~30 с.
