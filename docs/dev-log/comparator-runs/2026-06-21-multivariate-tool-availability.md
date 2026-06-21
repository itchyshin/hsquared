# Multivariate Comparator Tool Availability

Date: 2026-06-21

## Purpose

Record the local comparator-tool state before attempting the next
same-estimand multivariate REML comparator leg for the opt-in
`target = "multivariate"` bridge.

This is a blocker report, not comparator evidence.

## Scope

Target capability:

- `experimental multivariate REML estimator (opt-in)`
- R issue: `itchyshin/hsquared#10`
- Twin gates: `itchyshin/HSquared.jl#41` and `itchyshin/HSquared.jl#49`

Existing R evidence before this report:

- 100-replicate cold-start known-truth recovery study.
- Full-unstructured-residual `sommer` same-estimand REML comparator against the
  shared `phase4_multitrait_parity` target.
- Published Mrode Example 5.1 supplied-G0/R0 BLUP/MME anchor.
- `MCMCglmm` Bayesian agreement probe.

The remaining comparator blocker is another independent same-estimand REML
comparator beyond `sommer`.

## Local Executable Probe

Command:

```sh
for x in renumf90 airemlf90 blupf90 remlf90 gibbsf90 asreml dmuai dmu1 wombat; do
  if command -v "$x" >/dev/null 2>&1; then
    printf '%s\t%s\n' "$x" "$(command -v "$x")"
  else
    printf '%s\tMISSING\n' "$x"
  fi
done
```

Result:

| Tool | Local result |
| --- | --- |
| `renumf90` | MISSING |
| `airemlf90` | MISSING |
| `blupf90` | MISSING |
| `remlf90` | MISSING |
| `gibbsf90` | MISSING |
| `asreml` | MISSING |
| `dmuai` | MISSING |
| `dmu1` | MISSING |
| `wombat` | MISSING |

## Local R Package Probe

Command:

```sh
Rscript --vanilla -e 'pkgs <- c("sommer", "MCMCglmm", "nadiv", "pedigreemm", "asreml", "AGHmatrix", "enhancer", "JWAS"); for (pkg in pkgs) { if (requireNamespace(pkg, quietly = TRUE)) cat(pkg, as.character(utils::packageVersion(pkg)), sep = "\t") else cat(pkg, "MISSING", sep = "\t"); cat("\n") }'
```

Result:

| Package | Local result |
| --- | --- |
| `sommer` | 4.4.3 |
| `MCMCglmm` | 2.36 |
| `nadiv` | MISSING |
| `pedigreemm` | MISSING |
| `asreml` | MISSING |
| `AGHmatrix` | MISSING |
| `enhancer` | MISSING |
| `JWAS` | MISSING |

## Verdict

The local machine can rerun existing `sommer` and `MCMCglmm` evidence, but it
cannot produce the needed second independent same-estimand REML comparator
today.

The V4-MV-REML status remains **partial**.

## Next Runnable Comparator Step

On a host with BLUPF90-family tools installed:

```sh
mkdir -p /tmp/hsquared-blupf90-mv
Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R \
  --write=/tmp/hsquared-blupf90-mv
cd /tmp/hsquared-blupf90-mv
renumf90 multivariate-animal.renf90
airemlf90 renf90.par
```

Then copy a sanitized report into `docs/dev-log/comparator-runs/` using
`TEMPLATE.md`. Include tool version, command, convergence status, covariance
estimates, fixed effects, EBV agreement, scale mapping, and a Rose/Fisher/Curie
verdict before any validation-status promotion is considered.

On a host with licensed ASReml-R:

```sh
Rscript inst/comparator-scripts/asreml/multivariate-animal.R --run
```

Record the same provenance and reviewer verdict before making any claim.
