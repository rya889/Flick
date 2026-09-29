#!/usr/bin/env bash
# Back-compat wrapper. Use scripts/to-phone.sh.
exec "$(cd "$(dirname "$0")" && pwd)/to-phone.sh" "$@"
