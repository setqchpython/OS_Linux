# Журнал команд · практическая работа №3

ФИО: Селезнев Александр  
Группа: 9/2-РПО-25/1  
Дата: 25.10.2026

| № | Команда | Что сделала | Безопасный пример |
|---|---|---|---|
| 1 | `mkdir -p ~/files-lab/sorted/{docs,images,logs,data}` | создала четыре каталога sorted | `mkdir -pv …` — показывает каждый каталог |
| 2 | `mv "my report.txt" my-report.txt` | убрала пробел в имени | `mv -i …` — спросит при замене |
| 3 | `mv report-*.txt my-report.txt ../sorted/docs/` | перенесла семь отчётов в docs | `ls report-*.txt my-report.txt` перед mv |
| 4 | `mv *.{jpg,png} ../sorted/images/` | перенесла шесть изображений | `ls *.{jpg,png}` |
| 5 | `mv app.log app.log.1 app.log.2 error.log ../sorted/logs/` | перенесла четыре журнала | `ls app.log* error.log` |
| 6 | `cp *.csv ../sorted/data/` | скопировала csv, оригиналы в inbox | `cp -i *.csv …` |
| 7 | `rm -v *.bak` | удалила резервные копии | `ls *.bak`, затем `rm -i *.bak` |
| 8 | `find ~/files-lab -type f -size +1M -ls` | нашла dump.bin >1 МБ | `find … -print` без rm |
| 9 | `find ~/files-lab/inbox -type f -mtime +30 > ~/files-lab/answers.txt` | список старых файлов в answers | `find … -mtime +30 -print` |
| 10 | `cat .settings >> ~/files-lab/answers.txt` | дописала скрытый token | `ls -A`, `cat .settings` |
| 11 | `man ls` (/size), `ls -S ~/files-lab/sorted/images` | ключ -S в answers | только чтение man |
| 12 | `locate os-release \| head -1 >> answers.txt` | путь к os-release | `locate -e os-release` |
