#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run-v07-genomic-recovery-v3.sh selftest R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh guard-selftest
  run-v07-genomic-recovery-v3.sh write-review R_ROOT PATH REVIEWER CLEAN|BLOCKED DOC49_SHA R_DRIVER_COMMIT R_RECOMPUTER_COMMIT JULIA_REPLAY_COMMIT R_AUTO_ROUTE_COMMIT JULIA_CANDIDATE_COMMIT
  run-v07-genomic-recovery-v3.sh prepare-adaptive OUT d2|d3|d4 R_ROOT D1_FINAL_ROOT

  run-v07-genomic-recovery-v3.sh prepare OUT d0f R_ROOT JULIA_ROOT RECEIPT_ROOT MAX_WORKERS
  run-v07-genomic-recovery-v3.sh prepare OUT d1 R_ROOT JULIA_ROOT RECEIPT_ROOT MAX_WORKERS D0F_ADJUDICATION_ROOT
  run-v07-genomic-recovery-v3.sh preseal OUT d0f R_ROOT JULIA_ROOT R_AUTO_ROUTE_COMMIT JULIA_CANDIDATE_COMMIT
  run-v07-genomic-recovery-v3.sh preseal OUT d1 R_ROOT JULIA_ROOT R_AUTO_ROUTE_COMMIT JULIA_CANDIDATE_COMMIT D0F_ADJUDICATION_ROOT
  run-v07-genomic-recovery-v3.sh materialize-bootstrap OUT d0f R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh preflight OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh smoke-n-ladder OUT d0f|d1 R_ROOT JULIA_ROOT [WORKERS]
  run-v07-genomic-recovery-v3.sh smoke-16 OUT d0f|d1 R_ROOT JULIA_ROOT [WORKERS]
  run-v07-genomic-recovery-v3.sh verify-official OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh recommend-workers OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh run-official OUT d0f|d1 R_ROOT JULIA_ROOT WORKERS
  run-v07-genomic-recovery-v3.sh lock-corpus OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh recompute-base-r OUT d0f|d1 R_ROOT JULIA_ROOT WORKERS
  run-v07-genomic-recovery-v3.sh summarize-r OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh replay-julia OUT d0f|d1 R_ROOT JULIA_ROOT WORKERS
  run-v07-genomic-recovery-v3.sh verify-replay OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh summarize-julia OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh write-postrun-review OUT d0f|d1 R_ROOT JULIA_ROOT REVIEWER CLEAN|BLOCKED REVIEWED_AT_UTC
  run-v07-genomic-recovery-v3.sh adjudicate OUT d0f|d1 R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v3.sh validate-final OUT d0f|d1 R_ROOT JULIA_ROOT

Official fitting uses one process per manifest row. Independent recomputation
and replay use one authenticated external batch per worker. Simulations never
run on GitHub Actions. Totoro production fan-out is capped at 96 workers and
must not exceed the smoke-derived RAM recommendation.
EOF
}

die() {
  echo "$*" >&2
  exit 64
}

require_stage() {
  [[ "$1" == d0f || "$1" == d1 ]] || die "stage must be d0f or d1"
}

require_adaptive_stage() {
  [[ "$1" == d2 || "$1" == d3 || "$1" == d4 ]] || \
    die "adaptive stage must be d2, d3, or d4"
}

require_predecessor_arity() {
  local stage=$1
  local phase=$2
  local argc=$3
  if [[ "$stage" == d1 ]]; then
    (( argc == 3 )) || die "D1 $phase requires D0F_ADJUDICATION_ROOT"
  else
    (( argc == 2 )) || die "D0F $phase accepts no predecessor root"
  fi
}

require_workers() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]] && (( "$1" <= 96 )) || die "workers must be 1..96"
}

require_worker_cap_value() {
  local workers=$1
  local cap=$2
  (( workers <= cap )) || die "workers=$workers exceeds presealed max_workers=$cap"
}

require_smoke_missing_count() {
  local count=$1
  (( count >= 16 )) || die "smoke-16 requires exactly 16 previously missing rows"
}

resumable_pair_state() {
  local primary=$1
  local sidecar="$primary.sha256"
  if [[ -f "$primary" && -f "$sidecar" && ! -L "$primary" && ! -L "$sidecar" ]]; then
    printf '%s\n' complete
    return 0
  fi
  if [[ ! -e "$primary" && ! -e "$sidecar" && ! -L "$primary" && ! -L "$sidecar" ]]; then
    printf '%s\n' missing
    return 0
  fi
  die "partial or nonregular resumable output pair: $primary"
}

emit_missing_pair_if_needed() {
  local primary=$1
  local group=$2
  local seed=$3
  local state
  state=$(resumable_pair_state "$primary") || return $?
  [[ "$state" == complete ]] && return 0
  printf '%s %s\n' "$group" "$seed"
}

compute_context_ok() {
  local host github_actions ci cluster
  host=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  github_actions=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')
  ci=$(printf '%s' "$3" | tr '[:upper:]' '[:lower:]')
  cluster=$(printf '%s' "$4" | tr '[:upper:]' '[:lower:]')
  local job_id=$5
  [[ "$github_actions" != true && "$ci" != true ]] || return 1
  [[ "$host" == totoro ]] && return 0
  case "$cluster" in
    fir|nibi|rorqual|trillium|narval|killarney|vulcan|tamia) ;;
    *) return 1 ;;
  esac
  [[ "$job_id" =~ ^[1-9][0-9]*$ ]]
}

assert_compute_context() {
  local host
  host=$(hostname -s | tr '[:upper:]' '[:lower:]')
  compute_context_ok \
    "$host" "${GITHUB_ACTIONS:-false}" "${CI:-false}" \
    "${SLURM_CLUSTER_NAME:-}" "${SLURM_JOB_ID:-}" || \
    die "recovery-v3 requires Totoro or an admitted live DRAC SLURM allocation; CI/GitHub Actions and login nodes are forbidden"
}

select_julia() {
  local candidate
  if [[ -n "${JULIA_BIN:-}" ]]; then
    candidate=$JULIA_BIN
  elif [[ -x "$HOME/hsq_work/julia-1.10.10/bin/julia" ]]; then
    candidate=$HOME/hsq_work/julia-1.10.10/bin/julia
  else
    candidate=$(command -v julia) || die "Julia executable not found; set JULIA_BIN"
  fi
  [[ -x "$candidate" ]] || die "selected Julia executable is not executable: $candidate"
  printf '%s\n' "$candidate"
}

export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export JULIA_NUM_THREADS=1
if [[ -d /home/snakagaw/R/v07-lib ]]; then
  export R_LIBS="/home/snakagaw/R/v07-lib:/home/snakagaw/R/lib"
fi

[[ $# -ge 1 ]] || { usage >&2; exit 64; }
mode=$1
shift

if [[ "$mode" == guard-selftest ]]; then
  [[ $# -eq 0 ]] || { usage >&2; exit 64; }
  compute_context_ok totoro false false "" "" || die "Totoro guard selftest failed"
  ! compute_context_ok login1 false false fir "" || die "DRAC login guard selftest failed"
  compute_context_ok cn001 false false fir 12345 || die "DRAC allocation guard selftest failed"
  ! compute_context_ok totoro true false "" "" || die "GitHub Actions guard selftest failed"
  ! compute_context_ok totoro false true "" "" || die "CI guard selftest failed"

  ( require_worker_cap_value 9 8 ) >/dev/null 2>&1 && \
    die "presealed worker-cap negative control failed"
  ( require_smoke_missing_count 15 ) >/dev/null 2>&1 && \
    die "smoke-16 count negative control failed"
  require_predecessor_arity d0f prepare 2
  require_predecessor_arity d0f preseal 2
  ( require_predecessor_arity d1 prepare 2 ) >/dev/null 2>&1 && \
    die "D1 prepare predecessor negative control failed"
  ( require_predecessor_arity d1 preseal 2 ) >/dev/null 2>&1 && \
    die "D1 preseal predecessor negative control failed"
  require_predecessor_arity d1 prepare 3
  require_predecessor_arity d1 preseal 3
  require_adaptive_stage d2
  require_adaptive_stage d3
  require_adaptive_stage d4
  ( require_adaptive_stage d1 ) >/dev/null 2>&1 && \
    die "adaptive-stage negative control failed"

  pair_root=$(mktemp -d "${TMPDIR:-/tmp}/v3-launcher-pairs.XXXXXX")
  trap 'rm -rf "$pair_root"' EXIT
  pair="$pair_root/1.tsv"
  [[ "$(emit_missing_pair_if_needed "$pair" group 1)" == "group 1" ]] || \
    die "missing resumable pair was not emitted"
  printf '%s\n' primary > "$pair"
  printf '%s\n' sidecar > "$pair.sha256"
  [[ -z "$(emit_missing_pair_if_needed "$pair" group 1)" ]] || \
    die "complete resumable pair was not skipped"
  rm "$pair.sha256"
  ( emit_missing_pair_if_needed "$pair" group 1 ) >/dev/null 2>&1 && \
    die "orphan resumable pair negative control failed"
  rm "$pair"
  ln -s nowhere "$pair"
  ( emit_missing_pair_if_needed "$pair" group 1 ) >/dev/null 2>&1 && \
    die "symlink resumable pair negative control failed"
  rm "$pair"
  mkdir "$pair"
  ( emit_missing_pair_if_needed "$pair" group 1 ) >/dev/null 2>&1 && \
    die "nonregular resumable pair negative control failed"
  if printf '%s\n' "group 1" | xargs -P 1 -n 2 sh -c 'exit 7' sh; then
    die "xargs child-failure propagation negative control failed"
  fi
  rm -rf "$pair_root"
  trap - EXIT
  echo "recovery-v3 launcher guard selftest: PASS"
  exit 0
fi

if [[ "$mode" == selftest ]]; then
  [[ $# -eq 2 ]] || { usage >&2; exit 64; }
  r_root=$1
  julia_root=$2
  julia_bin=$(select_julia)
  export PATH="$(dirname "$julia_bin"):$PATH"
  Rscript --vanilla "$r_root/tools/v07_genomic_recovery_v3.R" --mode=selftest
  Rscript --vanilla "$r_root/tools/v07_genomic_recovery_v3_recompute.R" --mode=selftest
  Rscript --vanilla "$r_root/tools/v07_genomic_recovery_v3_admission.R" --mode=selftest
  "$julia_bin" --project="$julia_root" --startup-file=no \
    "$julia_root/sim/phase2_v07_genomic_recovery_v3_stage_replay.jl" --mode=selftest
  exit 0
fi

if [[ "$mode" == write-review ]]; then
  [[ $# -eq 10 ]] || { usage >&2; exit 64; }
  r_root=$1
  exec Rscript --vanilla "$r_root/tools/v07_genomic_recovery_v3.R" \
    --mode=write-review --path="$2" --reviewer="$3" --verdict="$4" \
    --doc49-sha256="$5" --r-driver-commit="$6" \
    --r-recomputer-commit="$7" --julia-replay-commit="$8" \
    --r-auto-route-commit="$9" --julia-candidate-commit="${10}"
fi

if [[ "$mode" == prepare-adaptive ]]; then
  [[ $# -eq 4 ]] || { usage >&2; exit 64; }
  out=$1
  stage=$2
  r_root=$3
  d1_root=$4
  require_adaptive_stage "$stage"
  admission="$r_root/tools/v07_genomic_recovery_v3_admission.R"
  [[ -f "$admission" ]] || die "deployed adaptive admission tool is missing"
  exec Rscript --vanilla "$admission" --mode=prepare \
    --output-root="$out" --stage="$stage" \
    --d1-root="$d1_root"
fi

[[ $# -ge 4 ]] || { usage >&2; exit 64; }
out=$1
stage=$2
r_root=$3
julia_root=$4
shift 4
require_stage "$stage"

driver="$r_root/tools/v07_genomic_recovery_v3.R"
recomputer="$r_root/tools/v07_genomic_recovery_v3_recompute.R"
julia_replay="$julia_root/sim/phase2_v07_genomic_recovery_v3_stage_replay.jl"
julia_bin=$(select_julia)
export PATH="$(dirname "$julia_bin"):$PATH"
manifest="$out/${stage}_manifest.tsv"

validate_d0f_predecessor_once() {
  [[ "$stage" == d1 ]] || return 0
  local predecessor_root predecessor_sha
  predecessor_root=$(awk -F '\t' '$1 == "d0f_adjudication_root" { print $2 }' \
    "$out/stage_preseal.tsv")
  predecessor_sha=$(awk -F '\t' '$1 == "d0f_adjudication_receipt_sha256" { print $2 }' \
    "$out/stage_preseal.tsv")
  [[ -d "$predecessor_root" && "$predecessor_sha" =~ ^[0-9a-f]{64}$ ]] || \
    die "D1 predecessor binding is invalid"
  Rscript --vanilla "$recomputer" --mode=validate-final \
    --output-root="$predecessor_root" --stage=d0f
}

[[ -f "$driver" && -f "$recomputer" && -f "$julia_replay" ]] || \
  die "one or more deployed recovery-v3 tools are missing"

driver_common=(
  --output-root="$out" --stage="$stage" --driver-root="$r_root"
  --r-root="$r_root" --julia-root="$julia_root"
)

assert_compute_context

preseal_worker_cap() {
  local environment="$out/environment_manifest.tsv"
  [[ -f "$environment" && -f "$environment.sha256" ]] || \
    die "presealed environment manifest pair is missing"
  local cap
  cap=$(awk -F '\t' '$1 == "max_workers" {print $2}' "$environment")
  [[ "$cap" =~ ^[1-9][0-9]*$ ]] && (( cap <= 96 )) || \
    die "presealed max_workers is invalid"
  printf '%s\n' "$cap"
}

require_preseal_worker_cap() {
  local workers=$1
  local cap
  cap=$(preseal_worker_cap)
  require_worker_cap_value "$workers" "$cap"
}

manifest_pairs() {
  [[ -f "$manifest" && -f "$manifest.sha256" ]] || die "stage manifest pair is missing"
  local group_name
  if [[ "$stage" == d0f ]]; then group_name=design_id; else group_name=cell_id; fi
  awk -F '\t' -v group_name="$group_name" '
    NR == 1 {
      for (i = 1; i <= NF; i++) {
        if ($i == group_name) group_col = i
        if ($i == "seed") seed_col = i
      }
      if (!group_col || !seed_col) exit 65
      next
    }
    { print $group_col, $seed_col }
  ' "$manifest"
}

manifest_n_ladder() {
  [[ -f "$manifest" && -f "$manifest.sha256" ]] || die "stage manifest pair is missing"
  local group_name
  if [[ "$stage" == d0f ]]; then group_name=design_id; else group_name=cell_id; fi
  awk -F '\t' -v group_name="$group_name" '
    NR == 1 {
      for (i = 1; i <= NF; i++) {
        if ($i == group_name) group_col = i
        if ($i == "seed") seed_col = i
        if ($i == "n") n_col = i
      }
      if (!group_col || !seed_col || !n_col) exit 65
      next
    }
    !seen[$n_col]++ { print $group_col, $seed_col }
  ' "$manifest"
}

manifest_missing_pairs() {
  manifest_pairs | while read -r group seed; do
    if [[ ! -e "$out/attempts/$stage/$group/$seed.tsv" && \
          ! -e "$out/attempts/$stage/$group/$seed.tsv.sha256" ]]; then
      printf '%s %s\n' "$group" "$seed"
    fi
  done
}

manifest_missing_recompute_pairs() {
  local subtree=$1
  manifest_pairs | while read -r group seed; do
    local primary="$out/$subtree/$stage/$group/$seed.tsv"
    emit_missing_pair_if_needed "$primary" "$group" "$seed"
  done
}

run_official_pairs() {
  local workers=$1
  export V3_OUT="$out" V3_STAGE="$stage" V3_R_ROOT="$r_root"
  export V3_JULIA_ROOT="$julia_root" V3_DRIVER="$driver"
  xargs -r -P "$workers" -n 2 sh -c '
    exec Rscript --vanilla "$V3_DRIVER" --mode=run-one \
      --output-root="$V3_OUT" --stage="$V3_STAGE" \
      --driver-root="$V3_R_ROOT" --r-root="$V3_R_ROOT" \
      --julia-root="$V3_JULIA_ROOT" --group="$1" --seed="$2"
  ' sh
}

run_base_r_pairs() {
  local workers=$1
  export V3_OUT="$out" V3_STAGE="$stage" V3_RECOMPUTER="$recomputer"
  xargs -r -P "$workers" -n 2 sh -c '
    exec Rscript --vanilla "$V3_RECOMPUTER" --mode=recompute-one \
      --output-root="$V3_OUT" --stage="$V3_STAGE" --group="$1" --seed="$2"
  ' sh
}

run_julia_pairs() {
  local workers=$1
  local group_flag
  if [[ "$stage" == d0f ]]; then group_flag=design; else group_flag=cell; fi
  export V3_OUT="$out" V3_STAGE="$stage" V3_JULIA_ROOT="$julia_root"
  export V3_JULIA_REPLAY="$julia_replay" V3_JULIA_BIN="$julia_bin"
  export V3_GROUP_FLAG="$group_flag"
  xargs -r -P "$workers" -n 2 sh -c '
    exec "$V3_JULIA_BIN" --project="$V3_JULIA_ROOT" --startup-file=no \
      "$V3_JULIA_REPLAY" --mode=replay --out-dir="$V3_OUT" \
      --stage="$V3_STAGE" --"$V3_GROUP_FLAG"="$1" --seed="$2"
  ' sh
}

external_batch_root() {
  local root
  root=${V3_BATCH_ROOT:-"$(dirname "$out")/.v07-recovery-v3-batches-$(basename "$out")"}
  [[ ! -L "$root" ]] || die "external batch root must not be a symlink: $root"
  mkdir -p "$root"
  [[ -d "$root" && ! -L "$root" ]] || die "external batch root is invalid: $root"
  (cd "$root" && pwd -P)
}

prepare_base_r_batch_plan() {
  local workers=$1
  local missing=$2
  local root plan batch_size
  root=$(external_batch_root)
  plan="$root/base-r-$stage.tsv"
  if [[ ! -e "$plan" && ! -e "$plan.sha256" && ! -L "$plan" && ! -L "$plan.sha256" ]]; then
    (( missing > 0 )) || die "cannot create a base-R batch plan with no missing rows"
    batch_size=$(( (missing + workers - 1) / workers ))
    Rscript --vanilla "$recomputer" --mode=write-batch-plan \
      --output-root="$out" --stage="$stage" --batch-plan="$plan" \
      --batch-size="$batch_size"
    Rscript --vanilla "$recomputer" --mode=validate-batch-plan \
      --output-root="$out" --stage="$stage" --batch-plan="$plan"
  elif [[ -f "$plan" && -f "$plan.sha256" && ! -L "$plan" && ! -L "$plan.sha256" ]]; then
    Rscript --vanilla "$recomputer" --mode=authenticate-batch-plan \
      --output-root="$out" --stage="$stage" --batch-plan="$plan"
  else
    die "external base-R batch plan is partial or nonregular: $plan"
  fi
  printf '%s\n' "$plan"
}

run_base_r_batches() {
  local workers=$1
  local plan=$2
  export V3_OUT="$out" V3_STAGE="$stage" V3_RECOMPUTER="$recomputer"
  export V3_BATCH_PLAN="$plan"
  awk -F '\t' '
    NR == 1 {
      for (i = 1; i <= NF; i++) if ($i == "batch_id") batch_col = i
      if (!batch_col) exit 65
      next
    }
    !seen[$batch_col]++ { print $batch_col }
  ' "$plan" | xargs -r -P "$workers" -n 1 sh -c '
    exec Rscript --vanilla "$V3_RECOMPUTER" --mode=recompute-batch \
      --output-root="$V3_OUT" --stage="$V3_STAGE" \
      --batch-plan="$V3_BATCH_PLAN" --batch-id="$1"
  ' sh
}

validate_julia_batch_inventory() {
  local dir=$1
  local count entries index expected
  [[ -d "$dir" && ! -L "$dir" ]] || die "external Julia batch directory is invalid: $dir"
  if find "$dir" -mindepth 1 -maxdepth 1 -type l -print -quit | grep -q .; then
    die "external Julia batch directory contains a symlink"
  fi
  count=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "$stage-batch-*-of-*.tsv" | wc -l | tr -d ' ')
  (( count >= 1 && count <= 96 )) || die "external Julia batch count is invalid"
  entries=$(find "$dir" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
  (( entries == 2 * count )) || die "external Julia batch inventory has missing or extra members"
  for ((index = 1; index <= count; index++)); do
    expected=$(printf '%s/%s-batch-%03d-of-%03d.tsv' "$dir" "$stage" "$index" "$count")
    [[ -f "$expected" && -f "$expected.sha256" && ! -L "$expected" && ! -L "$expected.sha256" ]] || \
      die "external Julia batch inventory is incomplete: $expected"
  done
}

prepare_julia_batch_dir() {
  local workers=$1
  local root dir
  root=$(external_batch_root)
  dir="$root/julia-$stage"
  if [[ ! -e "$dir" && ! -L "$dir" ]]; then
    mkdir "$dir"
    "$julia_bin" --project="$julia_root" --startup-file=no "$julia_replay" \
      --mode=write-batch-manifests --out-dir="$out" --stage="$stage" \
      --batch-dir="$dir" --batch-count="$workers" 1>&2
  fi
  validate_julia_batch_inventory "$dir"
  printf '%s\n' "$dir"
}

run_julia_batches() {
  local workers=$1
  local dir=$2
  local count index
  count=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "$stage-batch-*-of-*.tsv" | wc -l | tr -d ' ')
  export V3_OUT="$out" V3_STAGE="$stage" V3_JULIA_ROOT="$julia_root"
  export V3_JULIA_REPLAY="$julia_replay" V3_JULIA_BIN="$julia_bin"
  for ((index = 1; index <= count; index++)); do
    printf '%s/%s-batch-%03d-of-%03d.tsv\0' "$dir" "$stage" "$index" "$count"
  done | xargs -0 -r -P "$workers" -n 1 sh -c '
    exec "$V3_JULIA_BIN" --project="$V3_JULIA_ROOT" --startup-file=no \
      "$V3_JULIA_REPLAY" --mode=replay-batch --out-dir="$V3_OUT" \
      --stage="$V3_STAGE" --batch-manifest="$1" \
      --resume-complete-prefix=true
  ' sh
}

recommend_workers() {
  Rscript --vanilla - "$out" "$stage" <<'RSCRIPT'
args <- commandArgs(trailingOnly = TRUE)
root <- args[[1L]]
stage <- args[[2L]]
paths <- list.files(
  file.path(root, "attempts", stage), pattern = "[.]tsv$", recursive = TRUE,
  full.names = TRUE
)
paths <- paths[!grepl("[.]sha256$", paths)]
if (length(paths) < 16L) stop("fewer than 16 completed smoke attempts", call. = FALSE)
attempts <- lapply(paths, function(path) {
  x <- read.delim(path, sep = "\t", check.names = FALSE)
  if (!all(c("n", "peak_rss_mb") %in% names(x)) || nrow(x) != 1L) {
    stop("smoke attempt schema is incomplete", call. = FALSE)
  }
  x
})
manifest <- read.delim(
  file.path(root, paste0(stage, "_manifest.tsv")), sep = "\t",
  check.names = FALSE
)
observed_n <- unique(vapply(attempts, function(x) as.integer(x$n), integer(1L)))
if (!setequal(observed_n, unique(as.integer(manifest$n)))) {
  stop("smoke attempts do not cover every preregistered n", call. = FALSE)
}
rss <- vapply(attempts, function(x) as.numeric(x$peak_rss_mb), numeric(1L))
if (any(!is.finite(rss)) || any(rss <= 0)) {
  stop("smoke peak RSS is missing, nonfinite, or nonpositive", call. = FALSE)
}
environment <- read.delim(
  file.path(root, "environment_manifest.tsv"), sep = "\t",
  check.names = FALSE, stringsAsFactors = FALSE
)
preseal_cap <- suppressWarnings(as.integer(environment$value[environment$key == "max_workers"]))
if (length(preseal_cap) != 1L || is.na(preseal_cap) || preseal_cap < 1L || preseal_cap > 96L) {
  stop("presealed max_workers is invalid", call. = FALSE)
}
memory <- readLines("/proc/meminfo", warn = FALSE)
line <- grep("^MemAvailable:", memory, value = TRUE)
if (length(line) != 1L) stop("MemAvailable is unavailable", call. = FALSE)
available_mb <- as.numeric(gsub("[^0-9]", "", line)) / 1024
workers <- min(96L, preseal_cap, floor(0.7 * available_mb / max(rss)))
if (!is.finite(workers) || workers < 1L) {
  stop("smoke RSS cannot support one admitted worker", call. = FALSE)
}
cat(as.integer(workers), "\n", sep = "")
RSCRIPT
}

case "$mode" in
  prepare)
    require_predecessor_arity "$stage" prepare "$#"
    receipt_root=$1
    max_workers=$2
    require_workers "$max_workers"
    predecessor=()
    [[ "$stage" == d1 ]] && predecessor=(--d0f-adjudication-root="$3")
    exec Rscript --vanilla "$driver" --mode=prepare-stage \
      "${driver_common[@]}" --receipt-root="$receipt_root" \
      --max-workers="$max_workers" "${predecessor[@]}"
    ;;
  preseal)
    require_predecessor_arity "$stage" preseal "$#"
    predecessor=()
    [[ "$stage" == d1 ]] && predecessor=(--d0f-adjudication-root="$3")
    exec Rscript --vanilla "$driver" --mode=write-preseal \
      "${driver_common[@]}" --r-auto-route-commit="$1" \
      --julia-candidate-commit="$2" "${predecessor[@]}"
    ;;
  preflight)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec "$julia_bin" --project="$julia_root" --startup-file=no \
      "$julia_replay" --mode=preflight --out-dir="$out" --stage="$stage"
    ;;
  materialize-bootstrap)
    [[ "$stage" == d0f && $# -eq 0 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$driver" --mode=materialize-bootstrap \
      "${driver_common[@]}"
    ;;
  smoke-n-ladder)
    [[ $# -le 1 ]] || { usage >&2; exit 64; }
    workers=${1:-1}
    require_workers "$workers"
    require_preseal_worker_cap "$workers"
    validate_d0f_predecessor_once
    manifest_n_ladder | run_official_pairs "$workers"
    Rscript --vanilla "$driver" --mode=verify-phase "${driver_common[@]}"
    ;;
  smoke-16)
    [[ $# -le 1 ]] || { usage >&2; exit 64; }
    workers=${1:-16}
    require_workers "$workers"
    require_preseal_worker_cap "$workers"
    validate_d0f_predecessor_once
    smoke_rows=()
    while IFS= read -r row; do
      smoke_rows[${#smoke_rows[@]}]=$row
    done < <(manifest_missing_pairs)
    require_smoke_missing_count "${#smoke_rows[@]}"
    printf '%s\n' "${smoke_rows[@]:0:16}" | run_official_pairs "$workers"
    Rscript --vanilla "$driver" --mode=verify-phase "${driver_common[@]}"
    ;;
  verify-official)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$driver" --mode=verify-phase "${driver_common[@]}"
    ;;
  recommend-workers)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    recommend_workers
    ;;
  run-official)
    [[ $# -eq 1 ]] || { usage >&2; exit 64; }
    workers=$1
    require_workers "$workers"
    require_preseal_worker_cap "$workers"
    recommended=$(recommend_workers)
    (( workers <= recommended )) || die "workers=$workers exceeds smoke/RAM recommendation=$recommended"
    validate_d0f_predecessor_once
    manifest_pairs | run_official_pairs "$workers"
    Rscript --vanilla "$driver" --mode=verify-phase "${driver_common[@]}"
    ;;
  lock-corpus)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$driver" --mode=lock-corpus "${driver_common[@]}"
    ;;
  recompute-base-r)
    [[ $# -eq 1 ]] || { usage >&2; exit 64; }
    require_workers "$1"
    require_preseal_worker_cap "$1"
    recommended=$(recommend_workers)
    (( "$1" <= recommended )) || die "workers=$1 exceeds smoke/RAM recommendation=$recommended"
    validate_d0f_predecessor_once
    missing=$(manifest_missing_recompute_pairs base_r_recompute | wc -l | tr -d ' ')
    (( missing > 0 )) || exit 0
    batch_plan=$(prepare_base_r_batch_plan "$1" "$missing")
    run_base_r_batches "$1" "$batch_plan"
    ;;
  summarize-r)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$recomputer" --mode=summarize \
      --output-root="$out" --stage="$stage"
    ;;
  replay-julia)
    [[ $# -eq 1 ]] || { usage >&2; exit 64; }
    require_workers "$1"
    require_preseal_worker_cap "$1"
    recommended=$(recommend_workers)
    (( "$1" <= recommended )) || die "workers=$1 exceeds smoke/RAM recommendation=$recommended"
    validate_d0f_predecessor_once
    missing=$(manifest_missing_recompute_pairs julia_replay | wc -l | tr -d ' ')
    (( missing > 0 )) || exit 0
    batch_dir=$(prepare_julia_batch_dir "$1")
    run_julia_batches "$1" "$batch_dir"
    ;;
  verify-replay)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec "$julia_bin" --project="$julia_root" --startup-file=no "$julia_replay" \
      --mode=verify-replay --out-dir="$out" --stage="$stage"
    ;;
  summarize-julia)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec "$julia_bin" --project="$julia_root" --startup-file=no "$julia_replay" \
      --mode=summarize --out-dir="$out" --stage="$stage"
    ;;
  write-postrun-review)
    [[ $# -eq 3 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$recomputer" --mode=write-postrun-review \
      --output-root="$out" --stage="$stage" --reviewer="$1" \
      --verdict="$2" --reviewed-at-utc="$3"
    ;;
  adjudicate)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$recomputer" --mode=adjudicate \
      --output-root="$out" --stage="$stage"
    ;;
  validate-final)
    [[ $# -eq 0 ]] || { usage >&2; exit 64; }
    exec Rscript --vanilla "$recomputer" --mode=validate-final \
      --output-root="$out" --stage="$stage"
    ;;
  *)
    usage >&2
    exit 64
    ;;
esac
