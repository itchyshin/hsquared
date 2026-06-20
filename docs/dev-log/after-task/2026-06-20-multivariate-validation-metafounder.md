# After-task — multivariate t=2 validation evidence + metafounder Gamma reservation (2026-06-20 s4)

## Goal

Resume the ultracode sweep (drive order Julia→bridge→docs/validation). Land the
twin's #1 cross-lane handoff (multivariate t=2 validation, #10/#49 ↔ twin
#47/#49) and answer the metafounder Q1–Q4 contract (#53) the twin is waiting on.

## Shipped

**Multivariate t=2 validation evidence** (two `.Rbuildignore`d studies + register reconcile):

- `data-raw/multivariate-recovery-study.R` — **bug-fixed** (the harness called
  `hsquared(..., engine_control=)` at top level with no
  `control = hs_control(engine = "julia", ...)` wrapper, so the default
  `engine="fit"` path rejected every fit and `error=function(e) NULL` silently
  dropped them — it reported 0/4 converged in 0.3 s). Added the wrapper + a
  first-error surfacer + a non-converged guard. **LIVE run (n_rep=100, cold start
  diag(2)):** 100/100 converged, **all 9 targets within bias ± 2·MCSE** (no
  detectable bias), EBV accuracy 0.790/0.742. Corroborates twin #78/#79 with
  tighter MCSE.
- `data-raw/multivariate-comparator-study.R` (new) — `sommer` 4.4.5 `mmer`
  **full-unstructured-residual** comparator vs the twin's serialized
  `phase4_multitrait_parity` target, A rebuilt independently via `nadiv` (not
  copied). Agreement: max|dG0|=7.5e-5, max|dR0|=7.6e-6, max|dβ|=1.8e-6,
  max|dh2|=6.8e-5, EBV cor=1.0, max|dEBV|=4.4e-5. Recovers the off-diagonal
  residual R0[2,1] the in-suite diagonal-residual `mmes` check cannot.
- `docs/design/capability-status.md` + `docs/design/validation-debt-register.md`
  multivariate rows reconciled with the new evidence (kept **partial**);
  `NEWS.md` validation-evidence bullet.

**Metafounder Gamma reservation** — `R/qg-effects.R`: `metafounder()` now declares
`Gamma = NULL` (+ @param), so the proposed `metafounder(1|id, pedigree=ped,
Gamma=Γ)` grammar isn't silently swallowed by `...`. Marker stays
planned-not-implemented. `man/qg_effect_markers.Rd` regenerated.

## Honesty

V4-MV-REML stays **partial** — this is the R-lane EVIDENCE half (recovery +
external comparator); promotion to covered is twin-gated. REML loglik is NOT
compared (different additive constants; offset 113.74 reported, not asserted).
The metafounder marker remains inert; only the arg is reserved. No public
capability promoted.

## Verification

- `air format`; `devtools::document()`; `rcmdcheck(--no-manual)` **0/0/0**;
  `pkgdown::check_pkgdown()` clean. Slice touches no live-bridge R code (package
  code byte-identical apart from the inert `Gamma` arg), so tests cannot regress.
- 4-lens adversarial-verify Workflow (`wf_8bad14cd-fba`): both comparator lenses
  **sound** (the correctness agent independently re-ran the study and reproduced
  every number, confirmed the 113.7 loglik offset, A parent-order symmetry, and
  the `mmes` unstructured-residual error). Metafounder lenses **minor_issues** —
  contract core sound; all should-fix items applied to the #61 post + the code.

## Cross-lane

- Posted the MV evidence (versions + tolerances) and the metafounder Q1–Q4
  contract to twin #61. Opening the R-side metafounder mirrored issue.

## Next

Single-step H⁻¹-construction bridge activation; CPU batched marker-scan
prototype; AI-REML convergence hardening. FA/low-rank, calibrated GWAS, GPU ext
wiring remain twin-gated.
