#!/bin/bash
# cd ~/OS_Linux/lesson_04 && bash capture-lesson04.sh  (sudo один раз)
ROOT="$(cd "$(dirname "$0")" && pwd)"
CAP="$ROOT/_capture"
LOG="$CAP/terminal.log"
mkdir -p "$CAP"
: > "$LOG"

section(){ echo "=== $1 ===" >> "$LOG"; }
run(){ echo "\$ $*" >> "$LOG"; "$@" >> "$LOG" 2>&1 || true; echo >> "$LOG"; }
runs(){ echo "\$ sudo $*" >> "$LOG"; sudo "$@" >> "$LOG" 2>&1 || true; echo >> "$LOG"; }

bash "$ROOT/perms-lab-kit/perms-lab-setup.sh" >> "$LOG" 2>&1
cd ~/perm-lab

section "01-ls-l"
run ls -l report.txt backup.sh docs
run stat -c '%a %U %G %n' report.txt docs

section "02-dir-rx"
run chmod u-x docs
run ls docs
run cat docs/notes.txt
run chmod u+x docs
run chmod u-r docs
run ls docs
run chmod u+r docs

section "03-dir-w"
run chmod u-w docs
run rm docs/notes.txt
run chmod u+w docs

section "04-chmod"
run chmod -v g-w report.txt
run chmod -v 664 report.txt
run chmod -v u+x backup.sh

section "05-chown"
run ls -l db.env
runs chown boris:boris db.env
run ls -l db.env

section "06-umask"
run umask
run bash -c 'umask 027; umask; touch /tmp/umask-file; mkdir /tmp/umask-dir 2>/dev/null; ls -ld /tmp/umask-file /tmp/umask-dir'

runs bash "$ROOT/setup-shop-lab.sh"

section "07-shop-dirs"
run ls -ld /srv/shop /srv/shop/src /srv/shop/releases /srv/shop/uploads

section "08-shop-access"
runs -u bella cat /srv/shop/src/config.env
runs -u chris ls /srv/shop/src
runs -u chris cat /srv/shop/releases/v1.txt
runs -u alex rm -f /srv/shop/uploads/bella-file.txt

section "09-shop-check"
runs bash "$ROOT/perms-lab-kit/perms-lab-check.sh"

echo "Log: $LOG"
