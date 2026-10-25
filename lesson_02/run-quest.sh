#!/bin/bash
# Полный квест + проверка (запуск на Debian: bash run-quest.sh)
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
KIT="$ROOT/files-lab-kit"
LAB="$HOME/files-lab"
mkdir -p "$LAB"
cp "$KIT/files-lab-setup.sh" "$KIT/files-lab-check.sh" "$LAB/"
cp "$ROOT/journal-template-fill.md" "$LAB/journal.md"

rm -rf "$LAB/sorted"
bash "$LAB/files-lab-setup.sh"
cd "$LAB/inbox"

mkdir -p "$LAB/sorted"/{docs,images,logs,data}
mv "my report.txt" my-report.txt
ls report-*.txt my-report.txt
mv report-*.txt my-report.txt ../sorted/docs/
mv *.{jpg,png} ../sorted/images/
mv app.log app.log.1 app.log.2 error.log ../sorted/logs/
cp *.csv ../sorted/data/
ls *.bak
rm -v *.bak
find "$LAB" -type f -size +1M -ls
rm -v "$LAB/inbox/dump.bin"
find "$LAB/inbox" -type f -mtime +30 > "$LAB/answers.txt"
cat .settings >> "$LAB/answers.txt"
echo 'ls -S ~/files-lab/sorted/images' >> "$LAB/answers.txt"
loc="$(locate os-release 2>/dev/null | head -1)"
if [ -z "$loc" ]; then
  loc="$(find /etc /usr/lib / -maxdepth 4 -name os-release 2>/dev/null | head -1)"
fi
if [ -z "$loc" ] && [ -f /etc/os-release ]; then
  loc="/etc/os-release"
fi
echo "${loc:-/etc/os-release}" >> "$LAB/answers.txt"

bash "$LAB/files-lab-check.sh"
tree "$LAB/sorted" 2>/dev/null || find "$LAB/sorted" -type f | sort
