#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run-v07-genomic-recovery-v2.sh admission RECEIPT DRIVER_COMMIT JULIA_EXECUTION_COMMIT REVIEWED_AT_UTC
  run-v07-genomic-recovery-v2.sh seal OUT DRIVER_ROOT R_ROOT JULIA_ROOT DRIVER_COMMIT JULIA_EXECUTION_COMMIT ADMISSION_RECEIPT
  run-v07-genomic-recovery-v2.sh pilot-manifest OUT DRIVER_ROOT R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v2.sh run-tier OUT DRIVER_ROOT R_ROOT JULIA_ROOT pilot|confirm [WORKERS]
  run-v07-genomic-recovery-v2.sh summarize OUT DRIVER_ROOT R_ROOT JULIA_ROOT pilot|confirm
  run-v07-genomic-recovery-v2.sh recompute-base-r OUT DRIVER_ROOT R_ROOT JULIA_ROOT pilot|confirm
  run-v07-genomic-recovery-v2.sh recompute-julia OUT DRIVER_ROOT R_ROOT JULIA_ROOT pilot|confirm
  run-v07-genomic-recovery-v2.sh adjudicate OUT DRIVER_ROOT R_ROOT JULIA_ROOT pilot|confirm
  run-v07-genomic-recovery-v2.sh confirmation-manifest OUT DRIVER_ROOT R_ROOT JULIA_ROOT
  run-v07-genomic-recovery-v2.sh verify OUT DRIVER_ROOT R_ROOT JULIA_ROOT sealed|pilot_manifest|pilot_complete|confirm_manifest|confirm_complete

This frozen campaign runs one R process per seed on Totoro only, never CI.
Any DRAC execution requires a new environment seal and preregistration amendment.
EOF
}

[[ $# -ge 1 ]] || { usage >&2; exit 64; }
mode=$1
if [[ "$mode" == admission ]]; then
  [[ $# -eq 5 ]] || { usage >&2; exit 64; }
  tool="$(cd "$(dirname "$0")" && pwd)/v07_genomic_recovery_v2.R"
  exec Rscript "$tool" --mode=admission --path="$2" --driver-commit="$3" \
    --julia-execution-commit="$4" --reviewed-at-utc="$5"
fi
[[ $# -ge 5 ]] || { usage >&2; exit 64; }
out=$2
driver_root=$3
r_root=$4
julia_root=$5
tool="$driver_root/tools/v07_genomic_recovery_v2.R"

[[ -f "$tool" ]] || { echo "missing driver tool: $tool" >&2; exit 66; }
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export JULIA_NUM_THREADS=1

common=(--out-dir="$out" --driver-root="$driver_root" --r-root="$r_root" --julia-root="$julia_root")

case "$mode" in
  seal)
    [[ $# -eq 8 ]] || { usage >&2; exit 64; }
    exec Rscript "$tool" --mode=seal "${common[@]}" --driver-commit="$6" \
      --julia-execution-commit="$7" --admission-receipt="$8"
    ;;
  pilot-manifest)
    [[ $# -eq 5 ]] || { usage >&2; exit 64; }
    exec Rscript "$tool" --mode=pilot-manifest "${common[@]}"
    ;;
  confirmation-manifest)
    [[ $# -eq 5 ]] || { usage >&2; exit 64; }
    exec Rscript "$tool" --mode=confirmation-manifest "${common[@]}"
    ;;
  summarize)
    [[ $# -eq 6 ]] || { usage >&2; exit 64; }
    exec Rscript "$tool" --mode=summarize "${common[@]}" --tier="$6"
    ;;
  recompute-base-r)
    [[ $# -eq 6 ]] || { usage >&2; exit 64; }
    exec Rscript "$r_root/tools/v07_genomic_recovery_v2_recompute.R" \
      --mode=recompute --out-dir="$out" --tier="$6"
    ;;
  recompute-julia)
    [[ $# -eq 6 ]] || { usage >&2; exit 64; }
    exec julia --project="$julia_root" \
      "$julia_root/sim/phase2_v07_genomic_recovery_v2_recompute.jl" \
      --mode=recompute --out-dir="$out" --tier="$6"
    ;;
  adjudicate)
    [[ $# -eq 6 ]] || { usage >&2; exit 64; }
    exec Rscript "$tool" --mode=adjudicate "${common[@]}" --tier="$6"
    ;;
  verify)
    [[ $# -eq 6 ]] || { usage >&2; exit 64; }
    exec Rscript "$tool" --mode=verify "${common[@]}" --stage="$6"
    ;;
  run-tier)
    [[ $# -ge 6 && $# -le 7 ]] || { usage >&2; exit 64; }
    tier=$6
    workers=${7:-16}
    [[ "$tier" == pilot || "$tier" == confirm ]] || { echo "tier must be pilot or confirm" >&2; exit 64; }
    [[ "$workers" =~ ^[1-9][0-9]*$ ]] && (( workers <= 96 )) || { echo "workers must be 1..96" >&2; exit 64; }
    manifest="$out/${tier}_manifest.tsv"
    [[ -f "$manifest" && -f "$manifest.sha256" ]] || { echo "sealed manifest missing: $manifest" >&2; exit 66; }
    # The first five fields are tier, cell_id, cell_index, seed_offset, seed.
    export V07_TOOL="$tool" V07_OUT="$out" V07_DRIVER_ROOT="$driver_root"
    export V07_R_ROOT="$r_root" V07_JULIA_ROOT="$julia_root" V07_TIER="$tier"
    tail -n +2 "$manifest" | cut -f2,5 | \
      xargs -P "$workers" -n 2 sh -c '
        cell=$1; seed=$2
        exec Rscript "$V07_TOOL" --mode=run-one \
          --out-dir="$V07_OUT" --driver-root="$V07_DRIVER_ROOT" \
          --r-root="$V07_R_ROOT" --julia-root="$V07_JULIA_ROOT" \
          --tier="$V07_TIER" --cell-id="$cell" --seed="$seed"
      ' sh
    ;;
  *)
    usage >&2
    exit 64
    ;;
esac
