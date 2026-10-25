#!/bin/bash
# Домашнее задание: на TERM удалить temp-файл и выйти с кодом 0.
TMP="${TMPFILE:-$(mktemp /tmp/graceful.XXXXXX)}"
echo "$TMP" > /dev/null
touch "$TMP"

cleanup() {
  rm -f "$TMP"
  exit 0
}
trap cleanup TERM

echo "graceful: pid=$$, tmp=$TMP (send: kill -TERM $PPID or kill -TERM $$)"
while true; do sleep 1; done
