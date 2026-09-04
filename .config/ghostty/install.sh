#!/usr/bin/env sh
# Link the right platform fragment for this machine.
# Safe to re-run; it only touches platform/current.conf.
set -eu

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

case "$(uname -s)" in
  Darwin) target=darwin.conf ;;
  Linux)  target=linux.conf  ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

ln -sfn "$target" "$dir/platform/current.conf"
echo "Linked platform/current.conf -> $target"

if command -v ghostty >/dev/null 2>&1; then
  ghostty +validate-config && echo "Config valid."
else
  echo "Note: ghostty not on PATH, skipped validation."
fi
