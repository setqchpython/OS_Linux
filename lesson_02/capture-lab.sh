#!/bin/bash
# Run on Debian or Git Bash. Writes _capture/terminal.log and fills lesson_02 outputs.
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
CAP="$ROOT/_capture"
mkdir -p "$CAP"
LOG="$CAP/terminal.log"
: > "$LOG"

section() { echo "=== $1 ===" >> "$LOG"; }

run() {
  echo "\$ $*" >> "$LOG"
  "$@" >> "$LOG" 2>&1 || true
  echo >> "$LOG"
}

section "01-site-tree"
cd "$HOME"
rm -rf site-demo
run mkdir site-demo
run mkdir -p site-demo/nested/deep
run touch site-demo/readme.txt
if command -v tree >/dev/null; then run tree site-demo; else run find site-demo -print | sort; fi

bash "$ROOT/run-quest.sh" >> "$LOG" 2>&1

section "02-inbox"
run ls "$HOME/files-lab/inbox"
run ls -A "$HOME/files-lab/inbox"

section "03-cp-i"
mkdir -p "$HOME/files-lab/backup"
cp "$HOME/files-lab/inbox/data.csv" "$HOME/files-lab/backup/" 2>/dev/null || true
printf 'n\n' | cp -i "$HOME/files-lab/inbox/data.csv" "$HOME/files-lab/backup/" >> "$LOG" 2>&1 || true
echo >> "$LOG"

section "04-rmdir"
cd "$HOME"
rm -rf rmdir-demo && mkdir -p rmdir-demo/empty rmdir-demo/full
echo x > rmdir-demo/full/a.txt
run rmdir rmdir-demo/empty
run rmdir rmdir-demo/full
run rm -rv rmdir-demo/full

section "05-masks"
run ls "$HOME/files-lab/sorted/docs"/report-2026-*.txt
run ls "$HOME/files-lab/sorted/images"/photo-00[1-3].jpg
run echo "*.docx"

section "06-find"
run find "$HOME/files-lab/inbox" -type f -size -1M 2>/dev/null | head -5
run find "$HOME/files-lab/inbox" -type f -mtime +30 2>/dev/null | head -8

section "07-locate"
if command -v locate >/dev/null 2>&1 && locate os-release 2>/dev/null | head -1 | grep -q .; then
  run locate os-release
  run locate -e os-release 2>/dev/null | head -3
else
  echo "# locate: база пуста или пакет не установлен; на Debian: sudo apt install plocate && sudo updatedb" >> "$LOG"
  run find /etc /usr/lib -name os-release 2>/dev/null
fi

section "08-man"
echo "# man ls: sort by file size → ключ -S (с -l: ls -lS)" >> "$LOG"
run ls -lS "$HOME/files-lab/sorted/images" | head -10

section "09-sorted"
if command -v tree >/dev/null; then
  run tree "$HOME/files-lab/sorted"
else
  echo "\$ find ~/files-lab/sorted -type f | sort" >> "$LOG"
  find "$HOME/files-lab/sorted" -type f 2>/dev/null | sort >> "$LOG"
  echo >> "$LOG"
fi
echo "docs: $(find "$HOME/files-lab/sorted/docs" -maxdepth 1 -type f | wc -l) files" >> "$LOG"
echo "images: $(find "$HOME/files-lab/sorted/images" -maxdepth 1 -type f | wc -l) files" >> "$LOG"
echo "logs: $(find "$HOME/files-lab/sorted/logs" -maxdepth 1 -type f | wc -l) files" >> "$LOG"
echo "data: $(find "$HOME/files-lab/sorted/data" -maxdepth 1 -type f | wc -l) files" >> "$LOG"

section "10-check"
run bash "$HOME/files-lab/files-lab-check.sh"

cp "$HOME/files-lab/journal.md" "$ROOT/journal.md"
cp "$HOME/files-lab/answers.txt" "$ROOT/answers.txt"
echo "Log: $LOG"
