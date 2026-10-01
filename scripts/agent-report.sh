#!/usr/bin/env bash
# Print a paste-friendly diagnostic block for Cursor (no simulator run).
#
#   cd ~/dev/Flick && bash scripts/agent-report.sh
#
# Optional:
#   FLICK_REPORT_LOG=.flick/last-to-simulator.log bash scripts/agent-report.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/agent-report.sh
source "$ROOT/scripts/lib/agent-report.sh"

FLICK_REPORT_LOG="${FLICK_REPORT_LOG:-$ROOT/.flick/last-to-simulator.log}"
FLICK_REPORT_TAG="agent-report"

flick_emit_agent_block "${1:-0}" "manual agent-report"
