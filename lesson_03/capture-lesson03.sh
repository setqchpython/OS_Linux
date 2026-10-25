#!/bin/bash
# На ВМ: cd ~/OS_Linux/lesson_03 && bash capture-lesson03.sh
# Один запрос sudo; пишет _capture/terminal.log для generate-screenshots.py
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
CAP="$ROOT/_capture"
mkdir -p "$CAP"
LOG="$CAP/terminal.log"
: > "$LOG"
GUEST_PASS="${GUEST_PASS:-LabPass123!}"

section() { echo "=== $1 ===" >> "$LOG"; }
run() { echo "\$ $*" >> "$LOG"; "$@" >> "$LOG" 2>&1 || true; echo >> "$LOG"; }
runs() { echo "\$ sudo $*" >> "$LOG"; sudo "$@" >> "$LOG" 2>&1 || true; echo >> "$LOG"; }

section "01-id"
run id
run getent passwd "$(whoami)"

section "02-shadow"
run ls -l /etc/passwd /etc/shadow

section "03-groups"
run groups
run getent group sudo

section "04-sudo"
runs -l

section "05-team"
run getent group mobile-dev mobile-qa sudo
run id lead dev qa guest

section "06-dirs"
run ls -l /srv/mobile
run stat -c '%a %G' /srv/mobile/src /srv/mobile/reports

section "07-access"
runs -u lead touch /srv/mobile/src/lead.txt
runs -u dev ls /srv/mobile/reports

section "08-check"
runs bash "$ROOT/users-lab-kit/team-lab-check.sh"

section "09-denied"
echo "\$ su - guest -c 'sudo whoami'" >> "$LOG"
echo "$GUEST_PASS" | su - guest -c 'sudo whoami' >> "$LOG" 2>&1 || true
echo >> "$LOG"
run journalctl -t sudo --no-pager -n 15

section "10-setup-team"
echo "# (setup-team уже выполнен; повтор безопасен)" >> "$LOG"
runs bash "$ROOT/setup-team.sh"

echo "Log: $LOG — на ПК: python3 generate-screenshots.py"
