#!/bin/sh

tries="${INPUT_RETRIES:-1}"

code=1
while [ "$tries" -ge 1 ]; do
  tries=$((tries-1))
  ruby "$(dirname "$0")/lib/html_proofer_action.rb"
  code="$?"
  if [ "$code" -eq 0 ]; then
    break
  fi
  if [ "$tries" -ge 1 ]; then
    sleep 30
  fi
done

exit "$code"
