# Shared logging + paste-friendly diagnostics for Flick scripts.
# shellcheck shell=bash

flick_report_init() {
  local tag="$1"
  FLICK_REPORT_TAG="$tag"
  FLICK_REPORT_LOG="${FLICK_REPORT_LOG:-$ROOT/.flick/last-${tag}.log}"
  mkdir -p "$(dirname "$FLICK_REPORT_LOG")"
  {
    echo "=== Flick ${tag} ==="
    echo "started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "host: $(uname -a 2>/dev/null || true)"
    echo "pwd: $ROOT"
  } >"$FLICK_REPORT_LOG"
}

flick_log() {
  local line="[$(date -u '+%H:%M:%S')] $*"
  echo "$line"
  if [[ -n "${FLICK_REPORT_LOG:-}" ]]; then
    echo "$line" >>"$FLICK_REPORT_LOG"
  fi
}

# Pass stdin through to stdout; append to log; highlight likely errors on stderr stream.
flick_run_filtered() {
  # Caller should pipe through `tee -a "$FLICK_REPORT_LOG"` first; we only format stdout.
  flick_highlight_errors
}

flick_highlight_errors() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    if flick_line_is_noise "$line"; then
      [[ "${FLICK_VERBOSE:-}" == "1" ]] && echo "$line"
      continue
    fi
    if flick_line_is_important "$line"; then
      printf '\033[1;31m▸ %s\033[0m\n' "$line"
    else
      echo "$line"
    fi
  done
}

flick_line_is_noise() {
  local line="$1"
  [[ "${FLICK_VERBOSE:-}" == "1" ]] && return 1
  [[ "$line" =~ ^[[:space:]]*$ ]] && return 0
  [[ "$line" =~ Waiting[[:space:]]on[[:space:]] ]] && return 0
  [[ "$line" =~ Elapsed= ]] && return 0
  [[ "$line" =~ ^[[:space:]]*Running[[:space:]]pod[[:space:]]install ]] && return 0
  [[ "$line" =~ ^[[:space:]]*Resolving[[:space:]]dependencies ]] && return 0
  return 1
}

flick_line_is_important() {
  local line="$1"
  [[ "$line" =~ [Ee]rror ]] && return 0
  [[ "$line" =~ [Ff]ailed ]] && return 0
  [[ "$line" =~ [Ee]xception ]] && return 0
  [[ "$line" =~ [Ff]atal ]] && return 0
  [[ "$line" =~ Unable[[:space:]]to ]] && return 0
  [[ "$line" =~ not[[:space:]]found ]] && return 0
  [[ "$line" =~ ^[[:space:]]*✗ ]] && return 0
  [[ "$line" =~ BUILD[[:space:]]FAILED ]] && return 0
  [[ "$line" =~ Command[[:space:]]PhaseScriptExecution ]] && return 0
  return 1
}

flick_collect_errors_from_log() {
  local log="$1"
  [[ -f "$log" ]] || return 0
  grep -iE 'error|failed|exception|fatal|unable to|not found|BUILD FAILED|✗' "$log" \
    | grep -v flick_line_is_noise \
    | tail -n "${FLICK_ERROR_TAIL:-60}" || true
}

flick_emit_agent_block() {
  local exit_code="${1:-0}"
  local step="${2:-unknown step}"
  local log="${FLICK_REPORT_LOG:-$ROOT/.flick/last-run.log}"

  {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " COPY FOR CURSOR AGENT — paste everything between the lines"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "script: ${FLICK_REPORT_TAG:-flick}"
    echo "failed_step: $step"
    echo "exit_code: $exit_code"
    echo "time_utc: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo ""
    echo "--- git ---"
    git -C "$ROOT" log -1 --oneline 2>/dev/null || echo "(no git)"
    echo "branch: $(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    echo ""
    echo "--- flutter ---"
    flutter --version 2>/dev/null | head -3 || echo "flutter not on PATH"
    echo ""
    echo "--- flutter devices ---"
    flutter devices 2>/dev/null || true
    echo ""
    echo "--- xcode ---"
    xcode-select -p 2>/dev/null || echo "xcode-select not set"
    echo ""
    echo "--- filtered errors (from log) ---"
    flick_collect_errors_from_log "$log"
    echo ""
    echo "--- log file (full) ---"
    echo "$log"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  } | tee -a "$log"
}
