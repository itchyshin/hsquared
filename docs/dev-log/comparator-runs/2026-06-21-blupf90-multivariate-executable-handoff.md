# BLUPF90 multivariate executable handoff packet

Date: 2026-06-21

## Purpose

Provide a reproducible handoff for the next same-estimand multivariate REML
comparator leg on a machine that has BLUPF90-family executables installed.

This packet is not comparator evidence. It is the run protocol for obtaining
comparator evidence.

## Capability Gate

- R issue: `itchyshin/hsquared#10`
- Julia gates: `itchyshin/HSquared.jl#41`, `itchyshin/HSquared.jl#49`
- Current status: `V4-MV-REML` remains partial.
- Required missing leg: a second independent same-estimand REML comparator
  beyond the reproduced full-unstructured-residual `sommer` comparator.

## Required Host

The run host must have at least:

- `renumf90`
- `airemlf90`

Helpful alternates or diagnostics:

- `blupf90`
- `remlf90`
- `gibbsf90`

Record exact executable paths and versions before running:

```sh
for x in renumf90 airemlf90 blupf90 remlf90 gibbsf90; do
  if command -v "$x" >/dev/null 2>&1; then
    printf '%s\t%s\n' "$x" "$(command -v "$x")"
    "$x" --version 2>&1 | head -n 5 || true
  else
    printf '%s\tMISSING\n' "$x"
  fi
done
```

## Inputs

Use the committed shared multivariate fixture:

- `tests/testthat/fixtures/phase4_multitrait_parity/pedigree.csv`
- `tests/testthat/fixtures/phase4_multitrait_parity/phenotypes.csv`
- `tests/testthat/fixtures/phase4_multitrait_parity/expected_*.csv`

Generate BLUPF90-family flat files from the R lane:

```sh
mkdir -p /tmp/hsquared-blupf90-mv
Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R \
  --write=/tmp/hsquared-blupf90-mv
```

Expected generated files:

- `multivariate-animal.dat`
- `multivariate-animal.ped`
- `multivariate-animal.renf90`
- `multivariate-animal.par`
- `README.txt`

The current Julia lane also has a hardened BLUPF90 preflight and skip-safe
runner from HSquared.jl PR #132 (`b657464`). If using the Julia packet instead,
record the exact HSquared.jl commit and command. Do not mix R-generated and
Julia-generated files in the same run report unless their byte-level contents
are compared and recorded.

## Run Commands

From the generated output directory:

```sh
cd /tmp/hsquared-blupf90-mv
renumf90 multivariate-animal.renf90
airemlf90 renf90.par
```

If the local BLUPF90-family distribution expects a different parameter-file
name after `renumf90`, record the actual file and command used.

## Extract Required Results

The run report must include:

- converged yes/no/unclear;
- iteration count;
- final REML log likelihood if reported;
- genetic covariance estimates: `G[1,1]`, `G[1,2]`, `G[2,2]`;
- residual covariance estimates: `R[1,1]`, `R[1,2]`, `R[2,2]`;
- fixed effects, including intercept and `x` effect for both traits;
- animal EBVs for both traits, aligned to the original fixture animal IDs;
- warnings, boundary flags, singularity, or non-positive-definite diagnostics;
- exact scale mapping between BLUPF90 output and the fixture target.

## Comparison Target

Compare against:

- `expected_genetic_covariance.csv`
- `expected_residual_covariance.csv`
- `expected_beta.csv`
- `expected_heritability.csv`
- `expected_ebv.csv`
- `expected_metadata.csv`

Use the original animal IDs from `pedigree.csv`; the generated BLUPF90 files
map IDs to integers. The report must include this mapping or enough output to
reconstruct it.

## Acceptance Bands

Initial proposed bands for review, not automatic promotion:

| Quantity | Proposed acceptance band |
| --- | --- |
| G/R covariance entries | absolute difference <= `1e-3` after confirmed scale mapping |
| fixed effects | absolute difference <= `1e-3` |
| EBV correlation per trait | >= `0.999` |
| max absolute EBV difference per trait | <= `1e-2` after confirmed scale mapping |
| convergence | converged with no unreviewed boundary or singularity warning |

If BLUPF90's parameterization or convergence criterion makes these bands
inappropriate, Fisher and Curie must record an adjusted decision before any
status claim changes.

## Report Location

Copy a sanitized run report to:

```text
docs/dev-log/comparator-runs/YYYY-MM-DD-blupf90-multivariate-run.md
```

Use:

```text
docs/dev-log/comparator-runs/TEMPLATE.md
```

Do not commit licensed/proprietary output if the BLUPF90 distribution or local
policy forbids redistribution. Instead, commit enough version, command, summary,
and checksum provenance for a maintainer to reproduce the result.

## Claim Boundary

Until the executable run report exists and is reviewed:

- no BLUPF90 comparator evidence is claimed;
- no second same-estimand REML comparator is claimed;
- no `validation_status()` row changes;
- no V4-MV-REML covered-status promotion is allowed.
