#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <directory> <expected-file> [expected-file ...]"
  exit 1
fi

directory="$1"
shift

expected=("$@")

mapfile -t actual < <(
  find "$directory" -type f -name '*.xml' -printf '%f\n' | sort
)

mapfile -t expected_sorted < <(
  printf '%s\n' "${expected[@]}" | sort
)

echo "Expected XML files:"
printf '  %s\n' "${expected_sorted[@]}"

echo "Found XML files:"
printf '  %s\n' "${actual[@]}"

if [[ "${#actual[@]}" -ne "${#expected_sorted[@]}" ]] ||
   [[ "$(printf '%s\n' "${actual[@]}")" != "$(printf '%s\n' "${expected_sorted[@]}")" ]]; then
  echo "ERROR: XML files do not match expected files."
  exit 1
fi

echo "XML files match."