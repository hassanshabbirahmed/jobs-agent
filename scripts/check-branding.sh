#!/usr/bin/env bash
set -euo pipefail

needle='[Pp][Rr][Oo][Ff][Ii][Cc][Ii][Ee][Nn][Tt][Ll][Yy]'

if rg -n --hidden \
  --glob '!.git' \
  --glob '!node_modules' \
  --glob '!dist' \
  --glob '!build' \
  --glob '!coverage' \
  --glob '!*.lock' \
  "$needle" .; then
  printf '\nFound old brand references. Replace them with jobs-agent.\n'
  exit 1
fi

printf 'No old brand references found.\n'
