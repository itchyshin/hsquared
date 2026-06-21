# Marker-scan comparator / threshold tool availability

Date: 2026-06-21

## Purpose

Record the local tool state before attempting any external marker-scan
comparator or calibrated-threshold evidence for the experimental post-fit
`gwas()` path.

This is a blocker report, not comparator evidence.

## Scope

Target capability:

- post-fit `gwas(fit, markers)` marker scans and future calibrated
  genome-wide thresholds;
- R issue: `itchyshin/hsquared#23`;
- twin gates: `itchyshin/HSquared.jl#48` and coordination `#61`.

Existing R evidence before this report:

- mixed, single-marker, and LOCO `gwas()` bridge paths are live and
  experimental;
- `gwas_table(scan)` and `lod_scores(scan)` are thin views of existing
  `hs_gwas` results;
- HSquared.jl PR #142 supplied a row-aligned marker-scan payload fixture that
  R mirrors in a Julia-free normalizer test;
- HSquared.jl PR #134 supplied a fixed-marker-panel calibration smoke harness,
  and PR #143 added the Julia `V5-MARKER-THRESHOLD` status row.

Remaining evidence blockers:

- a realistic-LD or real-marker-panel calibration run;
- a same-result comparison against an accepted scan tool or independent
  implementation for at least one small fixture;
- negative-control and positive-control threshold checks;
- Fisher/Curie signoff on acceptance bands before any threshold claim.

## Local Executable Probe

Command:

```sh
for x in plink plink2 gemma gcta64 gcta bolt-lmm saige \
  step1_fitNULLGLMM.R step2_SPAtests.R; do
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
| `plink` | MISSING |
| `plink2` | MISSING |
| `gemma` | MISSING |
| `gcta64` | MISSING |
| `gcta` | MISSING |
| `bolt-lmm` | MISSING |
| `saige` | MISSING |
| `step1_fitNULLGLMM.R` | MISSING |
| `step2_SPAtests.R` | MISSING |

## Local R Package Probe

Command:

```sh
Rscript --vanilla -e 'pkgs <- c("GenABEL", "qvalue", "sommer", "rrBLUP", "GAPIT", "SNPRelate", "GWASTools", "SKAT", "BGLR", "AGHmatrix"); for (pkg in pkgs) { if (requireNamespace(pkg, quietly = TRUE)) cat(pkg, as.character(utils::packageVersion(pkg)), sep = "\t") else cat(pkg, "MISSING", sep = "\t"); cat("\n") }'
```

Result:

| Package | Local result |
| --- | --- |
| `GenABEL` | MISSING |
| `qvalue` | MISSING |
| `sommer` | 4.4.3 |
| `rrBLUP` | MISSING |
| `GAPIT` | MISSING |
| `SNPRelate` | MISSING |
| `GWASTools` | MISSING |
| `SKAT` | MISSING |
| `BGLR` | MISSING |
| `AGHmatrix` | MISSING |

`sommer` being installed is useful context but is not automatically a scan
comparator for the current threshold gate. A future `sommer`-derived scan route
would need to demonstrate the same background model, test statistic, marker
panel, p-value scale, and threshold estimand before counting as evidence.

## Verdict

This local machine cannot produce the needed marker-scan external-comparator or
calibrated-threshold evidence today.

R issue #23 and HSquared.jl #48 remain **open / partial**.

## Next Runnable Comparator Step

On a host with at least one accepted scan tool installed, run a small
same-result fixture comparison and record:

- tool name and version;
- exact fixture and marker map;
- background model and relationship correction;
- test statistic and p-value scale;
- threshold or calibration method, if any;
- negative-control and positive-control outcomes if claiming threshold
  calibration;
- differences from the `hs_gwas` table and acceptance verdict.

Use `docs/dev-log/comparator-runs/TEMPLATE.md` for the report. No public
threshold wording should change until the report is reviewed by Fisher, Curie,
and Rose.

## Claim Boundary

This records local availability only. It does not add PLINK, GenABEL, GEMMA,
GCTA, BOLT-LMM, SAIGE, sommer-derived, qvalue, or other external scan evidence.
It does not activate calibrated thresholds, formula-level `marker_scan()`,
fit-level/map-annotated QTL/GWAS/eQTL tables, or a covered-status promotion.
