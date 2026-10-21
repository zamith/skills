#!/usr/bin/env bash
# Send a TypeSafe System One request (JSON on stdin) to Jev and print the response.
# Exits 3 when TYPESAFE_API_KEY is unset so callers can skip the Jev step.
set -euo pipefail

if [[ -z "${TYPESAFE_API_KEY:-}" ]]; then
  echo "TYPESAFE_API_KEY not set; skipping Jev" >&2
  exit 3
fi

body=$(cat)
delay=1
for attempt in 1 2 3 4 5; do
  out=$(curl -sS -w '\n%{http_code}' https://api.typesafe.ai/v1/systemone \
    -H "Authorization: Bearer ${TYPESAFE_API_KEY}" \
    -H "Content-Type: application/json" \
    --data-binary "$body")
  code=${out##*$'\n'}
  resp=${out%$'\n'*}
  if [[ "$code" == "429" || "$code" == "529" ]]; then
    sleep "$delay"
    delay=$((delay * 2))
    continue
  fi
  if [[ "$code" != 2* ]]; then
    echo "Jev request failed ($code): $resp" >&2
    exit 1
  fi
  printf '%s\n' "$resp"
  exit 0
done
echo "Jev still rate-limited after $attempt attempts" >&2
exit 1
