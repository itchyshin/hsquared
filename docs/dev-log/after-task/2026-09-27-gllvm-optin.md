# Bounded Poisson genetic GLLVM R opt-in, candidate report

## 1. Goal

Make the three-trait, two-factor pure low-rank pedigree Poisson-log genetic GLLVM fit usable through explicit R expert controls.

## 2. Implemented

The R bridge validates complete balanced counts, one record per pedigree animal, known pedigree, and trait intercepts. It returns genetic covariance and correlations, fixed effects, trait-level conditional genetic modes on the log-rate scale, and diagnostics. The public article gives the exact call and omissions. `heritability()` and ordinary likelihood-based extractor claims are withheld for this cell.

## 3a. Decisions and Rejected Alternatives

The acceptance cell fixes `K = 2` to test the engine and bridge before automatic rank choice. Public breeding values are trait effects rather than latent factor scores. The non-Gaussian fit objective integrates fixed and genetic effects under a flat fixed-effect measure with a Laplace approximation; it is not labelled ordinary ML or REML.

## 4. Files Touched

R implementation: `R/hs_control.R`, `R/hsquared.R`, `R/model-spec.R`, `R/julia-bridge.R`, `R/extractors.R`, `R/validation-status.R`, `R/hsquared-package.R`. Tests: `tests/testthat/test-gllvm-optin.R` and shared bridge/extractor controls. Public documentation: `vignettes/articles/genetic-gllvm.Rmd`, `current-limits.Rmd`, `model-status.Rmd`, `fitting-models.Rmd`, `_pkgdown.yml`, `ROADMAP.md`, `docs/design/capability-status.md`, `validation-debt-register.md`, `06-public-claims-register.md`, `16-wide-response-syntax-plan.md`, `docs/dev-log/check-log.md`, and generated `man/*.Rd` files for changed exports. The capability-ledger generator and its committed include were updated together.

## 5. Checks Run

A live 12-animal same-input R–Julia fit passed 49 checks for G, correlations, fixed effects, trait conditional modes, and objective (`/tmp/gllvm-live-final.log`). Separate trait-order and pedigree-ID invariance checks passed 38 assertions; that run intentionally skipped its live Julia test, which the 49-check run supplies (`/tmp/gllvm-invariance.log`). The post-audit local `rcmdcheck` returned Status: OK (`/private/tmp/hsquared-fa-gllvm-rcmdcheck-20260927-postrose.log`). `pkgdown::check_pkgdown()` passed after the new article was indexed and after the claim wording correction. The generated capability summary sync test passed 29/29. CI remains pending.

## 6. Tests of the Tests

The R tests reject unsupported families, trait/rank structures, missing or duplicate records, pedigree-ID mismatch, and unrequested extractor claims. The live comparison calls the candidate Julia fitter on the same data, rather than comparing two R normalizations. The Julia deterministic T=3, K=2 fixture converged from default and three ordinary starts with objective spread below `1e-5`; this is a restart check, not population recovery.

## 7a. Issue Ledger

Fixed: R bridge was absent and Julia factor modes were incorrectly exposed as breeding values. Open: same-objective external comparator, non-Gaussian rank/recovery calibration, response-scale estimands, and automatic rank selection.

## 8. Consistency Audit

The article, site index/sidebar, model-status page, current-limits page, capability row, validation debt, and public claims register identify only the bounded partial cell. The generated ledger distinguishes a planned validation task from blanket fit unavailability. Rose's final audit is clean with limitations for the bounded claim and blocks broader covered or release wording.

## 9. What Did Not Go Smoothly

The first `pkgdown::check_pkgdown()` rejected the new article because `_pkgdown.yml` lacked an index entry. The source and generated capability summary initially implied all GLLVM fitting remained unavailable. Both were corrected, and the focused ledger test plus pkgdown check passed.

## 10. Known Residuals

This is a candidate arc receipt. No external same-objective pedigree comparator or interval calibration has passed. Final Julia checks after source-review repairs, CI, panel signoff, and broader GLLVM grammar remain open. No 0.11 release was made.

## 11. Team Learning

Memory receipt: `route.py hsquared`, brain D-293, and the sibling GLLVM design notes informed the boundary between fixed-rank acceptance and later auto rank. Golden Set: not run; this route's regressions cover malformed input and parity but no general memory regression campaign. A public latent model should report invariant trait effects, with factor scores kept internal.

## 12. Cross-Product Coverage

Covers: Poisson-log T=3, K=2 pure low-rank pedigree genetic covariance, complete balanced responses, trait intercepts, link-scale trait modes, and the stated R extractor set.

This route does NOT cover Bernoulli or mixed families, non-Gaussian uniqueness, missing or unbalanced records, response-scale heritability, raw loading inference, intervals, automatic rank selection, broad recovery, or a covered/release claim.
