#!/bin/bash
# cd ~/OS_Linux/lesson_05 && bash capture-lesson05.sh
ROOT="$(cd "$(dirname "$0")" && pwd)"
CAP="$ROOT/_capture"
LOG="$CAP/terminal.log"
mkdir -p "$CAP"
: > "$LOG"
section(){ echo "=== $1 ===" >> "$LOG"; }
run(){ echo "\$ $*" >> "$LOG"; "$@" >> "$LOG" 2>&1 || true; echo >> "$LOG"; }

section "01-process"
run bash -c 'sleep 300 & echo sleep_pid=$!; pgrep -a sleep | tail -1'
SP=$(pgrep -f 'sleep 300' | head -1)
[ -n "$SP" ] && run cat "/proc/$SP/status" | head -15
kill "$SP" 2>/dev/null || true

section "02-tree"
run echo "shell pid=$$"
run pstree -p $$

section "03-states"
run bash -c 'yes >/dev/null & Y=$!; sleep 1; ps -o pid,stat,cmd -p $Y; kill $Y'
run bash -c 'sleep 200 & S=$!; ps -o stat -p $S; kill -STOP $S; ps -o stat -p $S; kill -CONT $S; kill $S'

section "04-jobs"
echo "(jobs: см. интерактив Ctrl+Z — в логе демо sleep/bg)" >> "$LOG"
run bash -c 'sleep 500 & jobs -l 2>/dev/null; kill $(jobs -p) 2>/dev/null'

section "05-signals"
run bash -c 'sleep 999 & P=$!; kill -TERM $P; wait $P; echo exit=$?'

section "06-exit"
run bash -c 'sleep 1 & wait $!; echo ok=$?'
run bash -c 'sleep 1 & P=$!; kill -TERM $P; wait $P; echo term=$?'

bash "$ROOT/run-procs-lab.sh" >> "$LOG" 2>&1

section "07-lab-tree"
M=$(pgrep -f procs-lab/bin/manager.py | head -1 || echo "")
[ -n "$M" ] && run pstree -p "$M" || run cat "$HOME/procs-lab/states.md"

section "08-lab-signals"
run cat "$HOME/procs-lab/stubborn.log"
run cat "$HOME/procs-lab/exit-codes.log"

section "09-lab-check"
run bash "$ROOT/procs-lab-kit/procs-lab-check.sh"

section "10-graceful"
run bash -c "nohup bash '$ROOT/graceful.sh' >/tmp/graceful.out 2>&1 & echo gp=\$!; sleep 1; kill -TERM \$gp; sleep 1; cat /tmp/graceful.out"

echo "Log: $LOG"
