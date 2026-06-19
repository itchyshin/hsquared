# After-task — Next-big-4 slice 2 (#31): sommer + pedigreemm benchmark article (2026-06-19)

## Task goal

Program-2 workstream #1 (validation depth): a documented, reproducible benchmark article placing
the v0.1 Gaussian animal-model fit next to `sommer` and `pedigreemm` on the gryphon dataset,
within the maintainer-signed-off band — surfacing the *existing* comparator evidence with *real*
executed numbers, no fabrication.

## Active lenses / agents

- **Spawned subagents:** Curie (validation lens) — extracted the exact comparator evidence +
  honesty guards + recommended structure; Rose (systems auditor) — honesty audit of the article.
- Lenses applied: Pat/Fisher/Falconer (reader + estimand), Mrode (canon anchor).
- Lane: R / docs.

## Files changed

- `vignettes/articles/benchmark-comparators.Rmd` — new article.
- `_pkgdown.yml` — registered in the navbar + articles index.
- `vignettes/articles/validation-evidence.Rmd` — one-line cross-link to the benchmark.
- `NEWS.md` — dev-section bullet.

## Numbers (executed this session; reproducing code shown in the article)

- Gryphon `BWT ~ 1 + animal` (REML), `enhancer::DT_gryphon` / `A_gryphon`, Wilson et al. (2010):
  - Published: σ²a=3.3954, σ²e=3.8286, h²=0.470.
  - hsquared pure-R reference: σ²a=3.3953, σ²e=3.8287, h²=0.470 (converged).
  - `sommer::mmes()`: σ²a=3.3954, σ²e=3.8286, h²=0.470. All agree to ~4 dp.
- `pedigreemm` one-sided floor (replicated 12-animal × 3-record fixture): hsquared REML
  logLik = −52.2836 ≥ pedigreemm −52.3097 (hsquared reaches the better optimum by ~0.026).

## Checks

- `pkgdown::check_pkgdown()` clean (article registered); `pkgdown::build_article(...)` renders.
- Docs-only change (no `R/` code): prior `devtools::test()` 831/0/0/27 + `check(--no-manual)`
  0/0/0 hold. pkgdown auto-deploys on push.

## Public claim audit (Curie + Rose)

- Rose verdict: **CLEAN-WITH-NOTES**, 0 blockers. Applied the one correctness fix Rose caught:
  testthat `expect_equal(tolerance = 0.02)` is *relative*, not absolute — corrected the two spots
  that said "absolute 0.02" (the `h²`-vs-`sommer` check is the genuinely absolute bound).
- Honesty guards held: `pedigreemm` framed strictly as a **one-sided log-likelihood floor** ("at
  least as good as", on the replicated fixture — never "agrees with"); EBV r>0.999 presented as a
  signed-off **target**, not a demonstrated result; engine-vs-CI split stated (CI uses the pure-R
  reference; engine leg local-only); `sommer`/`pedigreemm` described as evidence behind the
  `covered` fit, not separately covered; no twin row-ids presented as R-side ids.

## What did not go smoothly

- A units slip ("absolute" vs "relative" tolerance) — caught by Rose and fixed. The error was
  conservative (relative 0.02 at h²=0.470 is tighter than absolute 0.02), so no claim weakened.

## Known limitations / next actions

- Benchmark uses the pure-R reference in CI; the production-engine recovery is local-only
  (skip-guarded), matching the pure-R reference to machine precision.
- Recovery is against a *published external estimate*, not known-truth simulation (that is the DGP
  study, cross-linked).
- Next program-2 R-ownable slices: #29 (gryphon end-to-end vignette), #30 (Florence figures), #32
  (Mrode beyond 3.1), #33 (comparator-policy doc). #3/#4 of the big 4 remain joint with the twin.
