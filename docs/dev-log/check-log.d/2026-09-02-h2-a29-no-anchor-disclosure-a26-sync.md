# 2026-09-02 — A29 follow-up: no-anchor disclosure + A26 discharge-language sync

**Arc:** A29 follow-up (agent-runnable prep after the Rose pre-flip **BLOCKED**
verdict, `~/local-scratch/h2-a29-rose-preflip-2026-09-02.md`).
**Lane:** R (`hsquared`) **and** Julia (`HSquared.jl`) — a shared-contract fact
changed, so both twins move together (Julia `AGENTS.md` rule 2).
**Worktrees:** `~/local-scratch/lanes/hsquared-h2-twin-20260901` (R) and
`~/local-scratch/lanes/HSquared.jl-h2-twin-20260901` (Julia).
**Branch (both):** `claude/lane-h2-twin-20260901`. **Neither pushed.**

## What closed

Two of the six agent-runnable items A29 §7 listed. **Neither is a flip.**

1. **A1 — gate item 2 no-anchor disclosure (was NOT MET, and was a *new*
   A29 blocker).** The multivariate claim surfaces cited Mrode Example 5.1 as
   their published anchor. That anchor is a **supplied-`G0`/`R0` multiple-trait
   BLUP/MME** target: it pins fixed effects and animal BLUPs *given known
   covariances*, so it does **not** anchor the **estimated** `G0`/`R0` that the
   0.6 flip would cover. Every surface described it accurately, but none carried
   the disclosure the Standard-Tier gate requires as the *alternative* to a
   pinned textbook number. The disclosure now says, in-surface, that **no
   published textbook anchor for estimated multivariate `G0`/`R0` exists** and
   that the estimated-covariance evidence is comparator- and recovery-based
   (`sommer` 4.4.5, `blupf90+` 2.60, cold-start recovery), never
   textbook-anchored. Precedent followed: `docs/design/43-genomic-greml-g0.md`
   §1, which does exactly this for the genomic pillar.

2. **A2 — A26 discharge language reconciled across both lanes.** A26's discharge
   had propagated to exactly one surface (the R debt register), which said a bare
   "now discharged"; five others still said parity was "owed", including live
   `validation_status()` on both twins and the published Julia Documenter page.
   All now carry one wording: **discharged locally, NOT CI-backed** — implemented
   and run at tip within pre-declared tolerances, but Tier-1 parity CI is not yet
   live (no workflow provisions Julia; `bridge-parity-tier1.stub.yaml` is
   `if: false`; the parity legs *skip* on a Julia-free runner, so a push yields a
   green check with them silently absent). Recorded as owner decision **DP-10**;
   explicitly **not** delivered by DP-1 (push).

   A **seventh** stale surface not on A29's list was found and fixed:
   `HSquared.jl/src/multivariate.jl` docstring.

3. **A3 (adjacent, same table cell) — stale segfault clause refreshed.** The R
   debt register still called the whole-suite blocker "a **pre-existing**
   JuliaCall 0.17.6 assign-then-eval segfault". `becfa5b` fixed it
   (`hs_y_matrix_for_julia()` converts `NA → NaN` before `julia_assign`).
   Measured at tip: `test-multivariate.R` runs live **95 pass / 0 fail / 0 skip**,
   no crash. The row now says so.

## Surfaces edited

**R lane (7 files + 1 regenerated):**

| File | Item |
|---|---|
| `R/validation-status.R` | A1 (evidence row) + A1/A2 (claim_boundary) — the live `validation_status()` output |
| `docs/design/capability-status.md` | A1 + A2 |
| `docs/design/validation-debt-register.md` | A1 + A2 + A3 |
| `docs/design/06-public-claims-register.md` | A1 + A2 |
| `vignettes/articles/multivariate.Rmd` | A1 + A2, plain-language, in the "Claim boundary" list and the intro |
| `vignettes/articles/model-status.Rmd` | A1 + A2 |
| `tools/write-capability-ledger-summary.R` | A1 + A2 |
| `vignettes/articles/includes/capability-ledger-summary.md` | **regenerated** from the tool (`Rscript tools/write-capability-ledger-summary.R`) |

**Julia lane (5 files + 1 regenerated):**

| File | Item |
|---|---|
| `src/validation_status.jl` | A1 + A2 on the `V4-MV-REML` claim boundary |
| `src/multivariate.jl` | A1 + A2 in the fitter docstring (7th surface, not on A29's list) |
| `docs/design/capability-status.md` | A1 + A2 |
| `docs/design/validation-debt-register.md` | A1 + A2 |
| `docs/design/06-public-claims-register.md` | A1 + A2 |
| `docs/src/validation-status.md` | **regenerated** (`julia --project=. tools/write_validation_status_page.jl`) — diff confined to the `V4-MV-REML` row + the regen timestamp |

## Commands and outcomes

| Command | Result |
|---|---|
| `air format .` (R lane) | reformatted 22 files outside this slice; **all reverted** — the two R files in this slice were already clean (no-drive-by-reformat rule) |
| `Rscript tools/write-capability-ledger-summary.R` | wrote the include (156 lines); diff is the multivariate scope cell only |
| `testthat::test_file("test-capability-ledger-summary.R")` | **20 pass / 0 fail** (was 19/1 before the include was regenerated — the in-sync assertion caught it, as designed) |
| `testthat::test_file("test-phase0-api.R")` | pass |
| `testthat::test_file("test-d41-experimental-honesty.R")` | pass |
| `testthat::test_file("test-multivariate-fence-contract.R")` | **16 pass / 0 fail** |
| `testthat::test_file("test-mrode-multivariate-anchor.R")` | **6 pass / 0 fail** |
| `devtools::test()` (full, no live bridge) | **FAIL 0 / WARN 0 / SKIP 72 / PASS 2384** |
| `test-multivariate-engine-parity.R`, live bridge at tip | **44 pass / 0 fail / 0 skip**, ~20 s wall (re-measured for the DP-10 cost table) |
| `devtools::document()` | no `man/` or `NAMESPACE` churn |
| `devtools::check(args = "--no-manual")` | **Status: OK — 0 errors / 0 warnings / 0 notes** |
| `pkgdown::check_pkgdown()` | **No problems found** |
| `julia --project=. tools/write_validation_status_page.jl` | wrote 56 rows; diff confined as above |
| `julia --project=. -e 'using Pkg; Pkg.test()'` | **tests passed** |
| Julia fences re-read live | `V4-MV-REML` = **covered** (unchanged), 13 covered rows / 56 total (unchanged) |
| R fences re-read live | multivariate = **partial**, **4** covered rows / 21 rows (all unchanged) |

Julia bridge configured via
`HSQUARED_JULIA_PROJECT=~/local-scratch/lanes/HSquared.jl-h2-twin-20260901`,
Julia 1.10.0. **No Totoro or DRAC compute routed.**

## Fence

- **No covered flip.** R multivariate stays **partial**; Julia `V4-MV-REML`
  stays **covered** and untouched in status.
- `public_covered_count` stays **5** on every surface.
- Darwin ink still **blank**; no G10; no MV-5 authorization.
- **No push** on either lane; no Registrator; no version bump; no CI enabled.
- Gate items 2 (disclosure) is now **MET**. Items 3 (Darwin), 8-CI (DP-10),
  and 9 (Definition of Done backfill) remain **unmet** — the flip stays illegal.
