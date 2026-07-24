#!/bin/sh

INPUT_SWAP_URLS="$(ruby "$(dirname "$0")/scripts/site_url_swaps.rb")"
export INPUT_SWAP_URLS

INPUT_IGNORE_URLS="$(ruby "$(dirname "$0")/scripts/common_ignores.rb")"
export INPUT_IGNORE_URLS

tries="${INPUT_RETRIES:-1}"
retry_wait="${INPUT_RETRY_WAIT:-60}"

code=1
run_log=""
while [ "$tries" -ge 1 ]; do
  tries=$((tries-1))
  run_log="$(mktemp)"
  ruby "$(dirname "$0")/lib/html_proofer_action.rb" >"$run_log" 2>&1
  code="$?"
  cat "$run_log"
  if [ "$code" -eq 0 ]; then
    break
  fi
  if [ "$tries" -ge 1 ]; then
    sleep "$retry_wait"
  fi
done

if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && [ -f "$GITHUB_STEP_SUMMARY" ] && [ -f "$run_log" ]; then
  {
    printf '## HTMLProofer\n\n'
    cat "$run_log"
  } >> "$GITHUB_STEP_SUMMARY"
fi

rm -f "$run_log"

exit "$code"
