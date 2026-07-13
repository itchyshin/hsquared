#!/usr/bin/env bash
set -euo pipefail

# Non-skippable, local-only cross-twin gate for the v0.7 genomic activation.
# This is deliberately not a GitHub Actions job. Callers must pin both commits:
#
#   EXPECTED_R_COMMIT=<sha> EXPECTED_JULIA_COMMIT=<sha> \
#   HSQUARED_JULIA_PROJECT=/absolute/path/to/HSquared.jl \
#     bash tools/run-v07-genomic-live-gate.sh

v07_log_has_skips() {
  grep -Eq '══ Skipped|SKIP[[:space:]]+[1-9][0-9]*' "$1"
}

if [[ "${1:-}" == "--selftest" ]]; then
  ZERO="$(mktemp)"
  POSITIVE="$(mktemp)"
  trap 'rm -f "$ZERO" "$POSITIVE"' EXIT
  printf '%s\n' 'PASS 148 FAIL 0 WARN 0 SKIP 0' > "$ZERO"
  printf '%s\n' 'PASS 147 FAIL 0 WARN 0 SKIP 1' > "$POSITIVE"
  ! v07_log_has_skips "$ZERO" || { echo "zero-skip selftest failed" >&2; exit 1; }
  v07_log_has_skips "$POSITIVE" || { echo "positive-skip selftest failed" >&2; exit 1; }
  echo "V07_GENOMIC_LIVE_GATE_SELFTEST_PASS"
  exit 0
fi

: "${EXPECTED_R_COMMIT:?set EXPECTED_R_COMMIT to the exact hsquared commit}"
: "${EXPECTED_JULIA_COMMIT:?set EXPECTED_JULIA_COMMIT to the exact HSquared.jl commit}"
: "${HSQUARED_JULIA_PROJECT:?set HSQUARED_JULIA_PROJECT to the HSquared.jl checkout}"

R_ROOT="$(git rev-parse --show-toplevel)"
JULIA_ROOT="$(cd "$HSQUARED_JULIA_PROJECT" && git rev-parse --show-toplevel)"

R_COMMIT="$(git -C "$R_ROOT" rev-parse HEAD)"
JULIA_COMMIT="$(git -C "$JULIA_ROOT" rev-parse HEAD)"
[[ "$R_COMMIT" == "$EXPECTED_R_COMMIT" ]] || {
  echo "hsquared commit mismatch: expected $EXPECTED_R_COMMIT, got $R_COMMIT" >&2
  exit 2
}
[[ "$JULIA_COMMIT" == "$EXPECTED_JULIA_COMMIT" ]] || {
  echo "HSquared.jl commit mismatch: expected $EXPECTED_JULIA_COMMIT, got $JULIA_COMMIT" >&2
  exit 2
}
[[ -z "$(git -C "$R_ROOT" status --porcelain)" ]] || {
  echo "hsquared worktree must be clean" >&2
  exit 2
}
[[ -z "$(git -C "$JULIA_ROOT" status --porcelain)" ]] || {
  echo "HSquared.jl worktree must be clean" >&2
  exit 2
}

FIXTURE_TREE="$(git -C "$JULIA_ROOT" rev-parse \
  "$JULIA_COMMIT:test/fixtures/genomic_public_activation_target")"
export NOT_CRAN=true OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=1
export PATH="$HOME/.juliaup/bin:$PATH"

LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT
Rscript -e 'devtools::test(filter = "boundary-genomic|genomic", reporter = "summary")' \
  2>&1 | tee "$LOG"

if v07_log_has_skips "$LOG"; then
  echo "v0.7 live gate skipped required evidence" >&2
  exit 1
fi
grep -q 'Julia exit\.' "$LOG" || {
  echo "v0.7 live gate did not complete the JuliaCall lifecycle" >&2
  exit 1
}

echo "V07_GENOMIC_LIVE_GATE_PASS"
echo "hsquared_commit=$R_COMMIT"
echo "HSquared_jl_commit=$JULIA_COMMIT"
echo "fixture_tree=$FIXTURE_TREE"
