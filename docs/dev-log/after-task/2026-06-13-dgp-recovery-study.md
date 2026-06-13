# Known-truth DGP variance-component recovery study

Date: 2026-06-13

Active lenses: Curie (simulation/ADEMP), Fisher (inference), Gauss (numerics),
Rose (claims). Spawned subagents: none for this slice (used the `simulation-design`
skill for the ADEMP structure).

Current lane: R (hsquared). Read-only against the live twin via the bridge; no
twin edits.

## Goal

The 6-agent audit's central finding was that all existing estimator evidence is
*optimizer reproducibility* (start-independence, dense-vs-sparse-vs-pure-R
agreement) — none of it is *known-truth recovery*. The v0.1 promotion predicate
(item 3) requires a replicated DGP study showing near-unbiased recovery of the
generating variance components plus EBV accuracy. This slice fills that gap from
the R lane, using a clean simulated pedigree (which sidesteps the gryphon raw
pedigree's data pathologies). Built under the standing finish-directive.

## Design (ADEMP; Morris/White/Crowther 2019; Williams et al. 2024)

- **Aims** — does the estimator recover known σ²ₐ/σ²ₑ/h² and produce EBVs that
  track true breeding values? Engine (`ai_reml`, via the read-only bridge) +
  pure-R reference cross-check.
- **DGP** — clean sexed generational pedigree (n=420; no selfing/cycles);
  `u = √σ²ₐ · Uᵀz` with `A = UᵀU`; `e ~ N(0, σ²ₑ I)`; `y = μ + u + e`, μ=5;
  total variance 1, h²=0.4. 120 engine reps / 40 pure-R reps; master seed
  20240613.
- **Estimands** — true σ²ₐ=0.4, σ²ₑ=0.6, h²=0.4, per-rep true u.
- **Methods** — `HSquared.fit_ai_reml` via the opt-in bridge;
  `hs_reml_estimate_reference` (independent pure-R).
- **Performance** — bias with MCSE; mean cor(EBV, true u); convergence rate.

## Result

| component | truth | engine mean | bias | MCSE |
| --- | --- | --- | --- | --- |
| σ²ₐ | 0.400 | 0.4000 | −0.0000 | 0.0090 |
| σ²ₑ | 0.600 | 0.6057 | +0.0057 | 0.0067 |
| h² | 0.400 | 0.3951 | −0.0049 | 0.0073 |

- 0 lies within bias ± 2·MCSE for all three components → statistically
  near-unbiased.
- EBV accuracy (mean cor with true u): 0.737. Convergence: 120/120.
- Engine vs pure-R reference: max |h² diff| = 0.0000 on shared reps (the two
  independent implementations agree to machine precision).

This is statistical-correctness (recovery) evidence — distinct from the
optimizer-reproducibility checks already in the suite.

## Files

- `data-raw/dgp-recovery-study.R` — reproducible full study + ADEMP design +
  recorded results (`.Rbuildignore`'d).
- `tests/testthat/helper-simulation.R` — `hs_sim_pedigree()`,
  `hs_sim_animal_phenotypes()`, `hs_sim_blup_ebv()` (test-only).
- `tests/testthat/test-validation-fixtures.R` — skip-guarded pure-R regression
  test (deterministic small-N, n=200, 25 reps, ~3 s) asserting near-unbiased
  recovery + EBV-accuracy floor + full convergence.
- `R/validation-status.R` (16 rows), `docs/design/capability-status.md`,
  `docs/design/validation-debt-register.md` — recorded the atom.

## Verification

- `devtools::test()` (NOT_CRAN): the pure-R regression test ran and passed.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
  0 warnings, 1 note (benign).
- `air format .`: clean. Full 120-rep engine study run locally (results above).

## Boundary (Rose)

R-lane recovery evidence produced via the read-only bridge. It does NOT flip the
twin-owned estimator gate row (`V1-SPARSE-REML-OPT` / `V1-AI-REML`) — the twin
records that, citing this evidence. Single h²=0.4 setting; no boundary
(h²→0/1), interval/SE, or production-robustness claim; not the default fit. The
predicate's boundary/identifiability item (item 4) remains open engine work.
Thresholds in the regression test are conservative proposals; the maintainer may
widen the design (more h² settings, larger replicate count, MCSE targets).

## What this advances

Predicate item 3 (known-truth recovery) now has concrete R-lane evidence for the
estimator. Remaining for the v0.1 default-fit gate: the twin's `V1-MRODE-FIT` +
`V1-COMPARATORS` rows (twin is on Phase 2), the boundary/identifiability engine
item, the maintainer's tolerance/threshold sign-off, and production robustness.
