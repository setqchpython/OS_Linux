#!/bin/bash
# cd ~/OS_Linux/lesson_06 && bash capture-lesson06.sh
ROOT="$(cd "$(dirname "$0")" && pwd)"
CAP="$ROOT/_capture"
LOG="$CAP/terminal.log"
mkdir -p "$CAP"
: > "$LOG"
section(){ echo "=== $1 ===" >> "$LOG"; }
run(){ echo "\$ $*" >> "$LOG"; eval "$@" >> "$LOG" 2>&1 || true; echo >> "$LOG"; }

cleanup_yes(){ pkill -f 'yes > /dev/null' 2>/dev/null || true; pkill -x yes 2>/dev/null || true; sleep 1; }

section "01-load"
run nproc
run uptime
run bash -c 'yes > /dev/null & yes > /dev/null & jobs -l'
run bash -c 'sleep 25; uptime'
run cat /proc/loadavg
run free -h
cleanup_yes

section "02-top"
run bash -c 'yes > /dev/null & sleep 2; top -b -n 1 | head -14'
cleanup_yes

section "03-htop"
if command -v htop >/dev/null 2>&1; then
  run bash -c 'yes > /dev/null & sleep 2; htop -n 1 2>&1 | head -35'
  cleanup_yes
else
  echo "(htop не установлен: sudo apt install -y htop; для снимка 03-htop можно сделать вручную)" >> "$LOG"
  run bash -c 'yes > /dev/null & sleep 2; top -b -n 1 | head -14'
  cleanup_yes
fi

section "04-find"
run bash -c "bash -c 'cd /tmp; while true; do :; done' & sleep 1"
run ps -eo pid,ppid,user,stat,%cpu,etime,cmd --sort=-%cpu | head -4
P=$(pgrep -f 'while true' | head -1 || true)
if [ -n "$P" ]; then
  run pstree -s -p "$P"
  run ls -l "/proc/$P/cwd"
  run ps -o lstart,etime -p "$P"
  run kill "$P"
fi

section "05-nice"
run bash -c 'taskset -c 0 yes > /dev/null & taskset -c 0 nice -n 10 yes > /dev/null & sleep 10; ps -o pid,ni,psr,%cpu,cmd -C yes; N=$(pgrep -f "nice -n 10 yes" | head -1); renice -n 19 -p "$N"; renice -n 5 -p "$N" 2>&1 || true; sudo renice -n 5 -p "$N" 2>&1 || true; pkill -x yes || true'

section "06-time"
run bash -c 'time sleep 2'
run bash -c 'time python3 -c "sum(range(30_000_000))"'
run bash -c 'time find /usr > /dev/null'
if [ -x /usr/bin/time ]; then
  run /usr/bin/time -f '%e s, %M KB' python3 -c 'b = bytearray(300_000_000)'
else
  echo "(sudo apt install -y time — для /usr/bin/time на снимке 06-time)" >> "$LOG"
  run bash -c 'TIMEFORMAT="real %R s"; time python3 -c "b = bytearray(300_000_000)"'
fi

section "07-memory"
run bash -c 'free -h; python3 -c "import time; b = bytearray(600_000_000); time.sleep(120)" & MP=$!; sleep 3; free -h; ps -eo pid,user,stat,%mem,rss,cmd --sort=-rss | head -4; kill $MP; sleep 1; free -h'

LAB="$HOME/diag-lab"
bash "$ROOT/diag-lab-kit/diag-lab-setup.sh" >> "$LOG" 2>&1
pkill -f "$LAB/bin/incident.py" 2>/dev/null || true
sleep 1
python3 "$LAB/bin/incident.py" >> "$LOG" 2>&1 &
sleep 10

section "08-lab-find"
run uptime
run tail -3 "$LAB/web.log"
run ps -eo pid,ppid,ni,stat,%cpu,cmd --sort=-%cpu | head -6
run bash -c "pstree -p \$(pgrep -f incident.py | head -1)"

section "09-lab-fix"
CALC="$LAB/bin/report-calc.sh"
BUILD="$LAB/bin/report-builder.sh"
run bash -c "renice -n 19 -p \$(pgrep -f '$CALC') 2>&1; sleep 12; tail -3 '$LAB/web.log'"
run bash -c "kill \$(pgrep -f '$BUILD' | head -1) 2>/dev/null; sleep 1; pgrep -af report || true"
run bash -c "kill \$(pgrep -f '$CALC') 2>/dev/null; sleep 3; tail -2 '$LAB/web.log'"
S=$(cat "$LAB/sync.lock" 2>/dev/null || echo "")
if [ -n "$S" ]; then
  run bash -c "kill $S 2>/dev/null; sleep 2; ps -o pid,stat,cmd -p $S || true"
  run bash -c "kill -9 $S 2>/dev/null; rm -f '$LAB/sync.lock'; sleep 2"
fi
run cat "$LAB/exit-codes.log"

bash "$ROOT/finish-diag-lab.sh" >> "$LOG" 2>&1 || true

section "10-lab-check"
run bash "$ROOT/diag-lab-kit/diag-lab-check.sh"

echo "Log: $LOG"
grep "Итог:" "$LOG" || true
