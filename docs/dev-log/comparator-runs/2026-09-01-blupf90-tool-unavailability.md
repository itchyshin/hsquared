# BLUPF90 Multivariate Comparator — Tool Unavailability

Date: 2026-09-01

## Purpose

Record that BLUPF90-family executables are **not available on campaign laptop
hardware** as of 2026-09-01, while the **input scaffold is wired and validated**.
This closes fog ticket **F5** for the H² twin Block 1 arc **A10** when paired with
the A11 unified comparator harness (7/7 accounted, 0 silent skips).

This note is **blocker evidence, not comparator evidence**. It does not promote
`V4-MV-REML` or any validation-status row.

## Scope

Target capability:

- `experimental multivariate REML estimator (opt-in)`
- R issue: `itchyshin/hsquared#10`
- Twin gates: `itchyshin/HSquared.jl#41` and `itchyshin/HSquared.jl#49`
- Primary fixture: `phase4_multitrait_parity`

## Scaffold Status (Wired)

The following artifacts are committed and were smoke-checked on 2026-09-01:

| Lane | Artifact | Role |
| --- | --- | --- |
| R | `inst/comparator-scripts/blupf90/prepare-multivariate-animal.R` | Dry-run + `--write=` flat-file generator |
| R | `inst/comparator-scripts/blupf90/multivariate-animal.{renf90,par}` | RENUMF90/AIREMLF90 templates |
| R | `R/comparator-results.R` | `hs_read_blupf90_multivariate_summary()` / `hs_validate_blupf90_multivariate_summary()` |
| R | `tests/testthat/test-comparator-scripts.R` | Dry-run + write-mode + ingester tests |
| Julia | `comparator/prepare_blupf90_multitrait.jl` | Packet generator + executable probe |
| Julia | `comparator/run_blupf90_multitrait.jl` | Skip-safe runner (`HSQUARED_RUN_BLUPF90=true` to execute) |
| Docs | `docs/dev-log/comparator-runs/2026-06-21-blupf90-multivariate-executable-handoff.md` | Run protocol |

Scaffold wired ≠ comparator run. No BLUPF90 estimates have been recorded against
`phase4_multitrait_parity`.

## Local Smoke (2026-09-01)

```sh
# R dry-run — exit 0
Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R
# → data rows: 80, pedigree rows: 20, dry-run only

# Julia skip-safe runner — exit 0
julia comparator/run_blupf90_multitrait.jl
# → packet generated + validated; [skip] no external executable run
```

## Executable Probe

### 2026-06-21 (prior)

Documented in `docs/dev-log/comparator-runs/2026-06-21-multivariate-tool-availability.md`:
`renumf90`, `airemlf90`, `blupf90`, `remlf90`, `gibbsf90` — all **MISSING** on the
then-local host. ASReml-R, DMU, WOMBAT also missing.

### 2026-09-01 (campaign laptop, H² twin worktree)

Command:

```sh
for x in renumf90 airemlf90 blupf90; do
  command -v "$x" || echo "$x MISSING"
done
```

| Tool | Result |
| --- | --- |
| `renumf90` | MISSING |
| `airemlf90` | MISSING |
| `blupf90` | MISSING |

## Verdict

BLUPF90 is **not obtainable on campaign laptop hardware** today. The acceptable
campaign outcome for F5 is **document unavailable-and-why** (this note), not a failed
wire attempt.

The **next probe host** is Totoro (Phase 1 of the A11 Totoro plan). If Totoro has
`renumf90` + `airemlf90`, run the tiny `phase4_multitrait_parity` smoke only;
record output under `docs/dev-log/comparator-runs/` using `TEMPLATE.md` before any
parity language.

## What Remains Open

- Second independent same-estimand REML comparator for `V4-MV-REML` (sommer leg exists).
- Rose/Fisher/Curie review of any future BLUPF90 run report.
- Alignment via `animal_id_map.csv` and tolerance declaration against fixture targets.
- `V4-MV-REML` status remains **partial**.
