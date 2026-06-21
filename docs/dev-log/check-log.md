# Check Log

Append exact commands and outcomes here. Do not replace repository evidence
with private memory.

## 2026-06-21 GWAS threshold activation contract

- Scope: R design/claim contract only. Added
  `docs/design/28-gwas-threshold-activation-contract.md` and refreshed the
  next-50 slice board.
- The contract records the future activation surface, required calibrated-scan
  result fields, validation gates, comparator discipline, and R boundary before
  `gwas()` can expose genome-wide significance thresholds.
- Claim boundary: no code behavior changed. `gwas()` remains experimental and
  uncalibrated; Bonferroni/BH summaries remain deterministic summaries over
  the supplied marker panel; no permutation cutoff, realistic-LD calibration,
  external scan comparator, QTL/eQTL threshold, or covered-status promotion is
  claimed.
- Checks:
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `rg -n "no threshold is activated|gwas\\(\\) remains experimental and uncalibrated|required calibrated-result fields|Validation Gates|external scan comparator|covered-status promotion" docs/design/28-gwas-threshold-activation-contract.md docs/design/11-next-50-slices.md docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-gwas-threshold-activation-contract.md`
    confirms the contract/non-activation boundary.

## 2026-06-21 GWAS calibration metadata validator

- Scope: internal R validation scaffold only. Added strict validation for
  optional future `hs_gwas` calibration metadata and tests for missing fields,
  bad p-value thresholds, `method = "none"`, scan-method mismatch, and
  non-integer replicate counts.
- Claim boundary: current `gwas()` output remains unchanged because the live
  engine result carries no calibration payload. This does not activate R
  significance thresholds, does not add a permutation cutoff, does not add
  realistic-LD production calibration, does not add an external scan comparator,
  and does not promote marker scans beyond partial.
- Checks:
  - `air format R/gwas.R tests/testthat/test-gwas.R` clean.
  - `Rscript --vanilla -e 'devtools::test(filter = "gwas")'`: 43 pass /
    0 fail / 0 warn / 2 skip.
  - `Rscript --vanilla -e 'devtools::test()'`: 1314 pass / 0 fail /
    0 warn / 58 skip.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning", check_dir = tempfile("hsq-check-"))'`:
    0 errors / 0 warnings / 0 notes.
  - `rg -n "does not activate R significance thresholds|current `gwas\\(\\)` output remains unchanged|optional future `hs_gwas` calibration metadata|no calibration payload|marker scans beyond partial" R/gwas.R tests/testthat/test-gwas.R docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-gwas-calibration-metadata-validator.md`
    confirms the validator/non-activation boundary.

## 2026-06-21 BLUPF90 multivariate executable handoff

- Scope: R validation/comparator handoff documentation only. Added
  `docs/dev-log/comparator-runs/2026-06-21-blupf90-multivariate-executable-handoff.md`
  and linked it from `docs/dev-log/comparator-runs/README.md`.
- The packet records host requirements, exact file-generation command, BLUPF90
  run commands, required result fields, proposed review bands, and report
  location for an executable-backed second-comparator run.
- Claim boundary: this is a run protocol, not comparator evidence. No
  BLUPF90-family executable was run, no `validation_status()` row changed, and
  V4-MV-REML remains partial.
- Checks:
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `rg -n "not comparator evidence|not evidence|no BLUPF90|V4-MV-REML remains partial|renumf90|airemlf90|acceptance|same-estimand" docs/dev-log/comparator-runs/2026-06-21-blupf90-multivariate-executable-handoff.md docs/dev-log/comparator-runs/README.md docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-blupf90-executable-handoff.md`
    confirms the protocol/evidence boundary and executable requirements.

## 2026-06-21 Julia #132/#133 issue-map sync

- Scope: coordination docs only. Refreshed `docs/dev-log/issue-map.md` after
  Julia-lane sync reported:
  - HSquared.jl PR #132 merged at `b657464`, hardening the BLUPF90
    multivariate preflight packet and skip-safe opt-in runner for #49/#41;
  - HSquared.jl PR #133 merged at `4526481`, closing #38 and replacing stale
    AI-matrix validation wording.
- Live issue-list check:
  `gh issue list --repo itchyshin/HSquared.jl --state open --limit 80` still
  lists #49 and #41 as open validation/comparator gates, while #38 is absent.
- Claim boundary: no R code or capability status changed. PR #132 is preflight
  hardening only; no BLUPF90-family executable comparator evidence was run and
  V4-MV-REML remains partial.
- Checks:
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `rg -n "#132|#133|b657464|4526481|BLUPF90|V4-MV-REML remains partial|#49|#41|#38" docs/dev-log/issue-map.md docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-julia-132-133-issue-map-sync.md`
    confirms #132/#133 are recorded and #49/#41 remain open/partial.

## 2026-06-21 Julia #38 issue-map sync

- Scope: coordination docs only. Refreshed `docs/dev-log/issue-map.md` after
  Julia-lane sync reported HSquared.jl PR #133 merged at `4526481`, closing
  HSquared.jl issue #38 and replacing the stale `250-animal` /
  `ratio ~0.99` AI-matrix wording in the Julia engine contract with the
  committed finite-difference REML Hessian gate (`rtol = 0.12`).
- Live check:
  `gh issue view 38 --repo itchyshin/HSquared.jl --json number,title,state,closedAt,url,labels`
  returned `state = "CLOSED"`, `closedAt = "2026-06-21T18:12:50Z"`.
- Claim boundary: R code and public capability status are unchanged. Historical
  R dev-log notes may still mention the old wording as the problem statement;
  the live selected issue map now treats #38 as banked.
- Checks:
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `rg -n "\\| 38 \\||03-engine-contract reword|Recently banked.*#38|4526481|250-animal" docs/dev-log/issue-map.md docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-julia-38-issue-map-sync.md`
    confirms the live selected issue map no longer lists #38 as open; remaining
    `250-animal` hits are historical notes or the explicit historical caveat.

## 2026-06-21 structured diagonal claims reconciliation

- Scope: public-claim/status wording only. Reconciled the structured
  covariance claim boundary after the diagonal-G bridge had already landed:
  `engine_control$genetic_structure = "diagonal"` is experimental/partial,
  while `lowrank`, `factor_analytic`, `rank`, and long-format
  `cov = us()/diag()/lowrank()/fa()` grammar remain planned/fenced.
- Updated `R/hs_control.R` roxygen and
  `docs/design/06-public-claims-register.md`.
- Claim boundary: no parser or fitting behavior changed, no factor-analytic or
  low-rank bridge activated, no loading extractor activated, no validation row
  promoted.
- Checks:
  - `Rscript --vanilla -e 'devtools::document()'` regenerated
    `man/hs_control.Rd`.
  - `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|formula-animal|multivariate|diagonal-multivariate|covariance-structure-lrt")'`:
    269 pass / 0 fail / 0 warn / 4 skip.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - Rose overclaim grep over the structured-covariance claim surfaces confirms
    diagonal is framed as experimental/partial while `lowrank`,
    `factor_analytic`, `rank`, and long-format `cov = ...` grammar remain
    planned/fenced.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning", check_dir = tempfile("hsq-check-"))'`:
    0 errors / 0 warnings / 0 notes.

## 2026-06-21 H^Gamma result-surface evidence

- Scope: R bridge evidence only. Strengthened the skip-guarded live
  nonzero-`Gamma` single-step `H^Gamma` probe to assert the standard
  fitted-object surface from `fit_metafounder_single_step_reml()`:
  `fit_diagnostics()`, `prediction_error_variance()`, `reliability()`, and
  derived `accuracy()`.
- Updated status ledgers:
  `docs/design/capability-status.md` and
  `docs/design/validation-debt-register.md`.
- Claim boundary: this is result-surface/bridge-readiness evidence only. It
  does not estimate `Gamma`, does not expose `metafounder_effects()`, does not
  add BLUPF90/ASReml comparator evidence, does not make a production-scale
  claim, and does not promote any metafounder or `H^Gamma` row to covered.
- Checks:
  - `air format tests/testthat/test-single-step-construct.R` clean.
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "single-step-construct")'`:
    105 pass / 0 fail / 0 warn / 0 skip.
  - `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|single-step-construct|fit-object")'`:
    262 pass / 0 fail / 0 warn / 7 skip.
  - `Rscript --vanilla -e 'devtools::test()'`: 1290 pass / 0 fail /
    0 warn / 58 skip.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning", check_dir = tempfile("hsq-check-"))'`:
    0 errors / 0 warnings / 0 notes.

## 2026-06-21 issue-map #15 correction

- Scope: docs/dev-log coordination only. Corrected
  `docs/dev-log/issue-map.md` and the matching after-task report to move R
  issue #15 out of the active-open table and into the recently banked/closed
  note, matching live `gh issue list --repo itchyshin/hsquared --state open`.
- Claim boundary: no capability status changed, no `validation_status()` rows
  changed, and closed #15 does not imply a covered-status promotion.
- Checks:
  - `git diff --check` clean.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.

## 2026-06-21 multivariate comparator availability

- Scope: R validation/comparator coordination only. Probed local availability
  for the next same-estimand multivariate REML comparator beyond `sommer`.
- Executable probe:
  `renumf90`, `airemlf90`, `blupf90`, `remlf90`, `gibbsf90`, `asreml`,
  `dmuai`, `dmu1`, and `wombat` are all missing from `PATH`.
- R package probe:
  `sommer` 4.4.3 and `MCMCglmm` 2.36 are installed; `nadiv`, `pedigreemm`,
  `asreml`, `AGHmatrix`, `enhancer`, and `JWAS` are missing.
- Recorded blocker report:
  `docs/dev-log/comparator-runs/2026-06-21-multivariate-tool-availability.md`.
- Claim boundary: this is not comparator evidence and does not promote
  V4-MV-REML; the row remains partial until recovery-gate acceptance/broadening
  plus another independent same-estimand comparator beyond `sommer`.
- Checks: `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean;
  `git diff --check` clean; claim-boundary grep over the changed files confirms
  the slice is framed as a blocker report, not new comparator evidence.

## 2026-06-21 issue-map live refresh

- Scope: docs/dev-log coordination only. Refreshed
  `docs/dev-log/issue-map.md` against live open issue lists for `hsquared` and
  `HSquared.jl`, moved closed R issue rows (#11, #12, #13, #14, #16, #17, #18,
  #26) into a "recently banked" note, clarified `hsquared#23` as live but still
  partial, and made the Julia table a selected cross-lane anchor map rather than
  an exhaustive issue dump.
- Live commands:
  - `gh issue list --repo itchyshin/hsquared --state open --limit 80 --json number,title,labels,url`
  - `gh issue list --repo itchyshin/HSquared.jl --state open --limit 80 --json number,title,labels,url`
- Claim boundary: no capability status changed, no `validation_status()` rows
  changed, and no covered promotion is implied by closed issues.
- Checks:
  - `git diff --check` clean.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.

## 2026-06-21 formula_status single-step bundle shorthand row

- Scope: formula/status diagnostics only. Added a distinct parsed
  `formula_status()` row for
  `single_step(1 | id) with data = hs_data(..., pedigree = ped, genotypes = M)`
  so users can distinguish the `hs_data()` bundle shorthand from explicit
  `single_step(..., pedigree = ped, markers = M)` construction and supplied
  `Hinv` single-step forms.
- Claim boundary: no parser behavior or fitting behavior changed; this records
  existing opt-in single-step construction shorthand support. The path remains
  experimental, dense/validation-scale, and twin-gated for promotion.
- Checks:
  - `air format .` clean.
  - `Rscript --vanilla -e 'devtools::document()'` clean.
  - `Rscript --vanilla -e 'devtools::test(filter = "phase0-api")'`
    **103 pass / 0 fail / 0 warn / 0 skip**.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
    **0 errors / 0 warnings / 0 notes**. Expected INFO only: optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` unavailable.

## 2026-06-21 multivariate MCMCglmm Bayesian agreement probe

- Scope: recorded a reproducible, opt-in `MCMCglmm` Bayesian agreement probe for
  the shared `phase4_multitrait_parity` two-trait animal-model fixture. This is
  agreement evidence only, not a same-estimand REML comparator and not a
  `V4-MV-REML` covered promotion.
- Evidence script:
  - `Rscript --vanilla data-raw/multivariate-mcmcglmm-agreement-study.R`
  - Result: `MCMCglmm` 2.36; seed 20260621; `nitt = 50000`, `burnin = 10000`,
    `thin = 40`; posterior samples = 1000.
  - Serialized HSquared.jl target inside 95% HPD intervals for all 8 covariance
    elements, all 4 fixed effects, and both per-trait h2 values.
  - Posterior-mean agreement: `max|dG0| = 0.0385`, `max|dR0| = 0.00647`,
    `max|dbeta| = 0.00697`, `max|dh2| = 0.0253`; EBV correlations 0.9998 and
    0.9997; `max|dEBV| = 0.0458`; minimum effective sample sizes VCV 777.4 and
    Sol 867.4.
- Local comparator availability:
  - `Rscript --vanilla -e 'pkgs <- c("sommer", "MCMCglmm", "nadiv", "asreml", "pedigreemm", "enhancer", "AGHmatrix"); for (p in pkgs) cat(p, ": ", if (requireNamespace(p, quietly=TRUE)) as.character(packageVersion(p)) else "not installed", "\n", sep="")'`
  - Result: `sommer` 4.4.3 and `MCMCglmm` 2.36 installed; `nadiv`, `asreml`,
    `pedigreemm`, `enhancer`, and `AGHmatrix` not installed.
- Status/docs touched: `validation_status()`, capability status, validation
  canon, validation debt, public claims, issue map, comparator plan, NEWS, and
  multivariate/model-status/G-matrix articles now include the MCMCglmm leg while
  keeping the second same-estimand comparator blocker explicit.
- Checks:
  - `air format .` clean.
  - `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|comparator-scripts")'`
    **134 pass / 0 fail / 0 warn / 0 skip**.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
  - `git diff --check` clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
    **0 errors / 0 warnings / 0 notes**. Expected INFO only: optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` unavailable.

## 2026-06-21 metafounder result-surface provenance extractors

- Scope: R fitted-object result surface only. Added `gamma_matrix(fit)` and
  `metafounder_groups(fit)` for the experimental supplied-`Gamma`
  `metafounder()` and `H^Gamma` single-step bridge paths. These extractors
  return supplied input provenance (`Gamma` and ID-keyed group assignments),
  not estimated parameters or metafounder effects. Ordinary
  `variance_components()`, `heritability()`, `breeding_values()`, PEV,
  reliability, and diagnostics continue to use the existing result surface.
- Code/details:
  - exported `gamma_matrix()` and `metafounder_groups()`;
  - added mock-object tests for both extractors and missing-field errors;
  - added live bridge assertions for animal-only metafounder and H^Gamma
    single-step results;
  - extended the boundary diagnostic's primary-effect vocabulary to include the
    `metafounder` variance-component label;
  - updated NEWS and status ledgers to say provenance extractors are available
    while metafounder effect extractors, Gamma estimation, and external
    comparator evidence remain absent.
- Local checks:
  - `air format .` - passed.
  - `Rscript --vanilla -e 'devtools::document()'` - passed; regenerated
    `NAMESPACE`, `man/gamma_matrix.Rd`, and `man/metafounder_groups.Rd`.
  - `Rscript --vanilla -e 'devtools::test(filter = "fit-object|julia-bridge|single-step-construct|phase0-api")'`
    - 283 passed, 0 failed, 0 warnings, 16 skipped.
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "julia-bridge|single-step-construct")'`
    - 208 passed, 0 failed, 0 warnings, 0 skipped.
  - `Rscript --vanilla -e 'devtools::test()'` - 1272 passed, 0 failed, 0
    warnings, 58 skipped.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean after adding the
    new topics to `_pkgdown.yml`.
  - `git diff --check` - clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
    Status OK, 0 errors, 0 warnings, 0 notes. Missing optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` were INFO only in the
    built-package sandbox.
- Rose boundary: this is a result-shape/provenance slice. It does not add
  `metafounder_effects()`, does not estimate `Gamma`, does not add BLUPF90 or
  ASReml comparator evidence, and does not promote the metafounder rows beyond
  `partial`.

## 2026-06-21 animal-only supplied-Gamma metafounder bridge

- Scope: R bridge activation for animal-only supplied-`Gamma` metafounder
  `A^Gamma` only. `metafounder(1 | id, pedigree = ped, group = group,
  Gamma = Gamma)` now parses as a primary effect and fits through
  `engine_control = list(target = "metafounder", variance_components = ...)`
  by calling the Julia-owned supplied-variance `metafounder_animal_model()`
  path. No `Gamma` estimation, metafounder-specific extractor,
  BLUPF90-family comparator evidence, production-scale claim, or covered-status
  promotion is claimed.
- Bridge details:
  - added the animal-only metafounder parser/model-spec branch;
  - extended the bridge payload with `relationship_source = "metafounder"`,
    `group_of`, supplied dense `Gamma`, and `gamma_source = "supplied"`;
  - added `hs_fit_julia_metafounder_payload()` for supplied-variance JuliaCall
    execution and result normalization;
  - kept the existing `target = "metafounder_single_step"` H^Gamma REML bridge
    separate.
- Local checks:
  - `air format .` - passed.
  - `Rscript --vanilla -e 'devtools::document()'` - regenerated
    `man/hs_control.Rd` and `man/qg_effect_markers.Rd`.
  - `Rscript --vanilla -e 'devtools::test(filter = "formula-animal|phase0-api|bridge-payload|julia-bridge")'`
    - 229 passed, 0 failed, 0 warnings, 9 skipped.
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "julia-bridge")'`
    - 109 passed, 0 failed, 0 warnings, 0 skipped.
    - Evidence includes `Gamma = 0` reduction to ordinary Henderson MME
      supplied-variance output and nonzero-`Gamma` prediction sensitivity for
      the animal-only metafounder bridge.
  - `Rscript --vanilla -e 'devtools::test()'` - 1265 passed, 0 failed, 0
    warnings, 58 skipped. Skips were optional packages and live Julia bridge
    legs under the plain Rscript environment.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
  - `git diff --check` - clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
    Status OK, 0 errors, 0 warnings, 0 notes. Missing optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` were INFO only.
- Rose boundary: this is an experimental, opt-in, dense validation-scale bridge.
  Animal-only `metafounder()` is supplied-variance only; it does not estimate
  variance components or `Gamma`. The multivariate validation/comparator gate
  and BLUPF90-family second-comparator evidence remain separate.

## 2026-06-21 metafounder H^Gamma live bridge probe

- Scope: R bridge activation for supplied-`Gamma` single-step `H^Gamma` only.
  `target = "metafounder_single_step"` now calls the Julia-owned
  `fit_metafounder_single_step_reml()` path. Animal-only `metafounder()` remains
  a syntax reservation; no `Gamma` estimation, metafounder-specific extractor,
  BLUPF90 comparator evidence, production-scale claim, or covered-status
  promotion is claimed.
- Bridge details:
  - added `hs_fit_julia_metafounder_single_step_payload()`;
  - reused the existing single-step construction payload (`pedigree`, markers,
    `genotyped_rows`, `group_of`, supplied `Gamma`, and knobs);
  - explicitly reconstructs `Gamma` as a Julia matrix because JuliaCall collapses
    a 1x1 R matrix to a scalar.
- Local live check:
  - `air format .` - passed.
  - `Rscript --vanilla -e 'devtools::document()'` - regenerated
    `man/genomic_markers.Rd` and `man/hs_control.Rd`.
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "single-step-construct")'`
    - 92 passed, 0 failed, 0 warnings, 0 skipped.
    - Evidence includes `Gamma = 0` reduction to ordinary single-step
      construction and nonzero-`Gamma` prediction sensitivity with stable labels
      and dimensions.
  - `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|single-step-construct")'`
    - 159 passed, 0 failed, 0 warnings, 7 skipped.
  - `Rscript --vanilla -e 'devtools::test()'` - 1247 passed, 0 failed, 0
    warnings, 57 skipped. Skips were optional packages and live Julia bridge
    legs under the plain Rscript environment.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
  - `git diff --check` - clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
    Status OK, 0 errors, 0 warnings, 0 notes. Missing optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` were INFO only.

## 2026-06-21 PEV/reliability standard-field status reconciliation

- Scope: R-lane docs/status reconciliation only. No R behavior changed. Updated
  the v0.1 and engine contracts, active capability/validation/public ledgers,
  bridge-gap table, validation canon, issue map, coordination board, and NEWS so
  they match the current bridge behavior:
  - default/sparse/explicit AI-REML result-payload routes consume standard
    `prediction_error_variance` and `reliability` fields when present (current
    engines emit them via `:selinv`);
  - direct dense extractor calls remain only as a backward-compatible fallback
    for older local engines;
  - supplied-variance Henderson MME attaches dense validation-path PEV and
    reliability unconditionally;
  - #21/#43 remain `partial` for multivariate per-trait PEV/reliability,
    production sparse reliability, and comparator validation.
- Local checks:
  - `air format .` - passed.
  - `Rscript --vanilla -e 'devtools::test(filter = "julia-bridge|pev-reliability-anchor|phase0-api")'` -
    135 passed, 0 failed, 0 warnings, 8 skipped. The skipped tests were
    live-engine bridge legs under the plain Rscript environment.
  - `Rscript --vanilla -e 'devtools::test()'` - 1248 passed, 0 failed, 0
    warnings, 55 skipped. Skips were optional packages and live Julia bridge
    legs under the plain Rscript environment.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
  - `git diff --check` - clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
    Status OK, 0 errors, 0 warnings, 0 notes. Missing optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` were INFO only.
- Rose boundary: this records status, not capability promotion. No production
  sparse PEV/reliability, multivariate per-trait reliability, or independent
  comparator evidence is claimed.

## 2026-06-21 Multivariate validation/comparator gate clarification

- Scope: R-lane validation-status and coordination clarification after merging
  the two banking PRs (`hsquared` #35 and `HSquared.jl` #125). No capability
  promotion and no Julia files edited.
- Refreshed local `main`:
  - `git switch main && git pull --ff-only`
  - Result: fast-forwarded to merged A3/#93 commit `6098839`; two unrelated
    Codex handover files remained untracked and were not touched.
- Created branch:
  - `git switch -c codex/mv-validation-comparator-gate`
- Changed files:
  - `R/validation-status.R`
  - `tests/testthat/test-phase0-api.R`
  - `docs/design/04-validation-canon.md`
  - `docs/dev-log/issue-map.md`
- Local checks:
  - `air format .` - passed.
  - `Rscript --vanilla -e 'devtools::test(filter = "phase0-api")'` - 87
    passed, 0 failed, 0 warnings, 0 skipped.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
  - `git diff --check` - clean.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
    Status OK, 0 errors, 0 warnings, 0 notes. Missing optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` were reported as INFO only.
- Rose boundary: the multivariate row stays `partial`. The R lane records
  cold-start recovery and one reproduced full-unstructured `sommer` comparator
  leg; promotion remains twin-gated and still needs a broader/redeclared
  recovery gate, a published or Mrode-style multivariate target, and another
  independent same-estimand comparator.

## 2026-06-21 A3 fit-time plot-data payloads (#93)

- Scope: R bridge slice only. The Julia bridge now attaches available engine
  `*_plot_data` payloads at fit time for standard animal-model,
  multivariate, and random-regression fits. No `HSquared.jl` files were
  edited.
- Implementation surfaces:
  - `R/julia-bridge.R`
  - `R/autoplot.R`
  - `tests/testthat/test-plot-data-parity.R`
  - `tests/testthat/test-multivariate.R`
  - `tests/testthat/test-random-regression.R`
  - `tests/testthat/test-autoplot.R`
  - `NEWS.md`
  - `docs/design/24-plotting-standard.md`
  - `docs/design/capability-status.md`
- Live engine payload shape probe:
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" Rscript --vanilla -e '...'`
  - Result: passed. Observed standard variance-component and breeding-value
    plot-data payloads, multivariate genetic-correlation and PCA payloads, and
    random-regression genetic-variance, eigenfunction, and covariance-surface
    payload shapes from the sibling Julia project.
- Focused live bridge probes:
  - Standard fit probe confirmed attached `variance_components_plot_data` and
    `breeding_values_plot_data`; the R normalizer drops the dummy univariate
    `trait` column from the breeding-value payload.
  - Multivariate probe with the sibling Julia project printed
    `multivariate_plot_payload_probe_ok` after confirming attached
    `genetic_correlation_plot_data` and `genetic_pca_plot_data`.
  - Random-regression probe confirmed attached
    `rr_genetic_variance_plot_data`, `rr_eigenfunctions_plot_data`, and
    `rr_covariance_surface_plot_data`, with the bridge grid unstandardized
    back to the original covariate range `1` to `5`. `autoplot(..., n = 7)`
    recomputed on the requested custom grid rather than reusing the default
    25-point payload.
- Local checks:
  - `air format .` - passed.
  - `Rscript --vanilla -e 'devtools::test(filter = "autoplot")'` - 126
    passed, 0 failed, 0 warnings, 0 skipped.
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test_file("tests/testthat/test-plot-data-parity.R")'` - 35 passed, 0 failed, 0 warnings, 0 skipped.
  - `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test_file("tests/testthat/test-random-regression.R")'` - 93 passed, 0 failed, 0 warnings, 0 skipped.
  - `env -u HSQUARED_JULIA_PROJECT Rscript --vanilla -e 'devtools::test_file("tests/testthat/test-multivariate.R")'` - 61 passed, 0 failed, 0 warnings, 3 skipped.
  - Full live `test-multivariate.R` with `HSQUARED_JULIA_PROJECT` set
    segfaulted during JuliaCall setup after 40 pure R passes. This is recorded
    as a local JuliaCall verifier limitation; the targeted live multivariate
    probe above covered the new fit-time payload attachment path.
  - `Rscript --vanilla -e 'devtools::document()'` - passed; regenerated Rd
    files.
  - `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
  - `Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` - 1 ERROR because optional suggested packages `enhancer`, `nadiv`, and `pedigreemm` were not installed locally.
  - `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` - Status OK, 0 errors, 0 warnings, 0 notes.
- Comparator/tool availability check for the coordination closeout:
  - `Rscript --vanilla -e 'pkgs <- c("sommer", "MCMCglmm", "nadiv", "asreml", "pedigreemm", "enhancer"); ...'`
  - Result: `sommer` 4.4.3 and `MCMCglmm` 2.36 installed; `nadiv`,
    `asreml`, `pedigreemm`, and `enhancer` not installed.
  - `for x in blupf90 airemlf90 remlf90 renumf90 gibbsf90; do command -v "$x" || true; done`
  - Result: no BLUPF90-family executables found on `PATH`.
- Rose boundary: this slice attaches plotting payloads and preserves recompute
  fallbacks. It does not promote multivariate validation, external comparator
  status, PEV/reliability plotting, marker/non-Gaussian plotting, or structured
  covariance claims.

## 2026-06-21 Codex-team handover

- Rehydrated the R repo for a Codex-team handover:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -8`
  - `gh run list --limit 8`
- Result: R repo on `main`, aligned with `origin/main`; live head `bbf0939`
  (`Record #93-closeout CI evidence + session handoff-9`). Latest observed
  `pkgdown` run `27892465085` and Pages run `27892511303` were successful.
- Rehydrated the Julia sibling read-only:
  - `git status --short --branch`
  - `git log --oneline --decorate -8`
  - `gh run list --limit 8`
- Result: `HSquared.jl` on `main`, aligned with `origin/main`; live head
  `bf9decd` (`Session handover v14: complete START-HERE note for a fresh
  session (#123)`). Local sibling checkout has untracked
  `docs/dev-log/after-task/2026-06-21-codex-handover-v1.md`; it was not edited.
  Latest observed CI run `27902900856`, Documenter run `27902900840`, and Pages
  run `27902950360` were successful.
- Wrote the durable Codex-team handover:
  - `docs/dev-log/handover/2026-06-21-codex-team.md`
- No package tests were run because this was a coordinator documentation
  handover only.

## 2026-06-12

- Rehydrated R repo:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -5`
  - `gh run list --repo itchyshin/hsquared --limit 5`
- Result before Phase 0 R edits: clean `main`, tracking `origin/main`, latest
  R-CMD-check run green.
- Coordinated with Julia twin thread
  `019ebb88-ee69-7be2-850c-0e4840c34734`; instructed it to own only
  `HSquared.jl` and avoid R-repo writes.
- Verified Julia twin from live state after coordination:
  - `git status --short --branch` in `HSquared.jl`
  - `git log --oneline --decorate -5` in `HSquared.jl`
  - `gh repo view itchyshin/HSquared.jl --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
  - `gh run list --repo itchyshin/HSquared.jl --limit 5`
- Result: `HSquared.jl` is public at
  `https://github.com/itchyshin/HSquared.jl`, on clean `main`, latest commit
  `079dbf2`, latest GitHub Actions CI run passed.
- Local Phase 0 R commands:
  - `for d in .agents/skills/*; do python3 /Users/z3437171/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d" || exit 1; done`
  - `air format .`
  - `Rscript -e 'devtools::document(); devtools::test()'`
  - `Rscript -e 'devtools::check(error_on = "warning")'`
- Result: all local skill validations passed; formatting completed; R tests
  passed with `0 fails | 0 warnings | 12 pass`; R CMD check passed with
  `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - `rg -n "TODO|\[TODO|fits animal|fits fast|implemented model|ASReml-level" README.md DESCRIPTION AGENTS.md ROADMAP.md docs .agents R tests`
- Result: matches were intentional claim-audit text only; no public wording
  says fitting is implemented.
- Follow-up Rose sweep used a broader unsupported-claim pattern and softened
  unsupported performance phrasing from `fast sparse` to `sparse`.
- After the clean full package check, final edits were prose-only claim-audit
  changes in README/design docs and generated Rd text. A subsequent
  `Rscript --vanilla -e 'cat("R ok\n")'` startup probe became unresponsive and
  was interrupted; use the next GitHub Actions run as the post-push R runtime
  verification.
- `git diff --check`
- Result: clean after trimming one trailing blank line in the testthat
  snapshot.
- Committed and pushed R Phase 0 scaffold:
  - `git commit -m "Install Phase 0 operating system"`
  - `git push origin main`
- Result: commit `d956a25` pushed to `main`.
- Remote R CI:
  - `gh run watch 27452325194 --repo itchyshin/hsquared --exit-status`
- Result: R-CMD-check passed in GitHub Actions in 1m33s.
- Public visibility:
  - `gh repo edit itchyshin/hsquared --visibility public --accept-visibility-change-consequences`
  - `gh repo view itchyshin/hsquared --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
  - `gh repo view itchyshin/HSquared.jl --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
- Result: both `itchyshin/hsquared` and `itchyshin/HSquared.jl` are public on
  `main`.
- GitHub ledger:
  - Added shared labels and Phase 0-8 milestones to both repos.
  - Opened `hsquared` issues #1-#7.
  - Opened `HSquared.jl` issues #1-#7.
- Final evidence commit:
  - `git commit -m "Record Phase 0 R closeout evidence"`
  - `git push origin main`
  - `gh run watch 27452446531 --repo itchyshin/hsquared --exit-status`
- Result: final commit `2268ff4` is on `main`; R-CMD-check passed in GitHub
  Actions in 1m12s.

## 2026-06-13

- Rehydrated R repo:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -5`
  - `gh run list --limit 5`
- Result before Phase 1A R edits: on `main`, tracking `origin/main`;
  latest remote R-CMD-check runs were green.
- Coordinated with Julia twin thread
  `019ebb88-ee69-7be2-850c-0e4840c34734`.
- Result: Julia lane reported `HSquared.jl` commits for pedigree inverse
  utilities and the genomics/GPU/HPC roadmap, with CI and Documenter green.
- Local package commands:
  - `Rscript -e "devtools::document()"`
  - `git diff --check`
  - `Rscript -e "devtools::test()"`
  - `Rscript -e "pkgdown::build_site()"`
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - `Rscript -e "devtools::check()"`
- Result: documentation regenerated; whitespace check clean; testthat passed
  with `22 pass`; pkgdown site built locally into ignored `pkgdown-site/`;
  `pkgdown::check_pkgdown()` reported no problems; R CMD check passed with
  `0 errors | 0 warnings | 0 notes`.
- Formula/API checks:
  - `animal()` is now an exported inert formula marker.
  - `hs_build_model_spec()` parses the v0.1
    `animal(1 | id, pedigree = ped)` contract, validates pedigree/data IDs,
    builds fixed design matrices, and stops before fitting.
  - Tests cover accepted syntax, pedigree-column synonyms, unsupported
    trait/covariance syntax, missing pedigree IDs, and bridge-boundary
    wording.
- Documentation and public-site checks:
  - Added `_pkgdown.yml`, a pkgdown GitHub Actions workflow, and initial
    vignettes/articles for overview, model status, and the genomics/GPU
    roadmap.
  - Added `docs/design/07-genomics-qtl-gpu-plan.md` and a scout note for
    local packages, quantitative-genetic packages, and GPU backends.
- Rose wording sweep:
  - Public wording says parser/design-stage or planned where fitting,
    genomics, QTL/eQTL, GLLVM, GPU, and HPC features are not implemented.
  - No public wording claims fitted animal models, Julia bridge execution,
    GPU acceleration, or genomic/QTL support as implemented.
- Known check friction:
  - Early snapshot tests around Phase 0 bridge-boundary wording were replaced
    with direct `expect_error()` checks after snapshot update tooling created
    noisy EOF/diff prompts. The formula parser keeps focused snapshots for
    unsupported syntax.
- Remote GitHub Actions after push:
  - `gh run watch 27455226958 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m55s.
  - `gh run watch 27455226953 --repo itchyshin/hsquared --exit-status`
  - Result: initial pkgdown workflow failed while initializing `gh-pages`
    because the runner had no git author identity.
  - Fix: added a `Configure git identity` step to
    `.github/workflows/pkgdown.yaml`.
  - Follow-up run `27455290071` reached the deploy step, initialized
    `gh-pages`, and then failed while building reference pages because
    `library(hsquared)` could not find an installed package on the runner.
  - Fix: added an explicit `R CMD INSTALL .` step before deployment.
- Remote GitHub Actions after install-step fix:
  - `gh run watch 27455352894 --repo itchyshin/hsquared --exit-status`
  - Result: pkgdown passed in 1m19s and pushed `gh-pages`.
  - `gh run watch 27455352898 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m46s.
  - `gh api --method POST repos/itchyshin/hsquared/pages -f "source[branch]=gh-pages" -f "source[path]=/"`
  - Result: GitHub Pages enabled for
    `https://itchyshin.github.io/hsquared/`.
  - `gh run watch 27455403672 --repo itchyshin/hsquared --exit-status`
  - Result: Pages build and deployment passed.
  - `curl -L --max-time 20 -I https://itchyshin.github.io/hsquared/`
  - Result: live site returned `HTTP/2 200`.

## 2026-06-13 R bridge payload slice

- Rehydrated local state before edit:
  - `git status --short --branch`
  - Result: on `main`, tracking `origin/main`, with a clean worktree before
    the bridge-payload slice.
- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: documentation regenerated; `man/hsquared-package.Rd` updated with
    package URLs.
  - `Rscript -e "devtools::test()"`
  - Result after payload and test hardening: `49 pass`, `0 fail`.
  - `git diff --check`
  - Result after removing a trailing snapshot blank line and deleting brittle
    snapshots: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - First `Rscript -e "devtools::check()"`
  - Result: failed in tests because an ordinary error snapshot differed between
    interactive and built-package contexts.
  - Fix: replaced formula-error snapshots with direct `expect_error()`
    assertions and removed the obsolete `_snaps` fixture.
  - Final `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Bridge/API evidence:
  - Added internal `hs_build_bridge_payload()`.
  - Tests cover numeric `y`, dense fixed `X`, sparse animal-incidence `Z`,
    normalized parent-before-offspring pedigree order, parent index metadata,
    method/family payload fields, cycle rejection, and the current
    `HSquared.animal_model_spec()` stop-boundary wording.
- Rose wording sweep:
  - README, vignettes, and design docs say internal bridge payload only.
  - No public wording claims Julia execution, `Ainv` construction, or fitted
    animal models as implemented.
- Remote GitHub Actions after push:
  - `git push origin main`
  - Result: commit `c5c348e` pushed to `origin/main`.
  - `gh run watch 27455845170 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m24s.
  - `gh run watch 27455845181 --repo itchyshin/hsquared --exit-status`
  - Result: pkgdown passed in 1m20s and deployed the site.
  - `gh run watch 27455874827 --repo itchyshin/hsquared --exit-status`
  - Result: Pages build and deployment passed. GitHub emitted a
    non-blocking Node.js 20 deprecation annotation for Pages actions.
  - `curl -L --max-time 20 -I https://itchyshin.github.io/hsquared/`
  - Result: live site returned `HTTP/2 200`.
  - `gh issue comment 6 --repo itchyshin/hsquared --body ...`
  - Result: issue #6 updated with evidence at
    `https://github.com/itchyshin/hsquared/issues/6#issuecomment-4697408730`.

## 2026-06-13 R fitted object and extractor contract slice

- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: `NAMESPACE` regenerated and Rd topics written for
    `variance_components()`, `heritability()`, `breeding_values()`,
    `fixef()`, and `ranef()`.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `65 pass`, `0 fail`.
  - First `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: failed because five new extractor topics were missing from the
    reference index.
  - Fix: added an `Extractor contract` section to `_pkgdown.yml`.
  - Final `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - First `Rscript -e "devtools::check()"`
  - Result: `0 errors`, `0 warnings`, `1 note`; NOTE was an unqualified
    `logLik()` call inside `AIC.hsquared_fit()`.
  - Fix: changed `AIC.hsquared_fit()` to call `stats::logLik(object)`.
  - Final `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- API evidence:
  - Added internal `hs_new_fit()`.
  - Added extractor generics and `hsquared_fit` methods for variance
    components, heritability, breeding values, fixed effects, random effects,
    log-likelihood, AIC, prediction, and summary.
  - Tests use mocked result fields only; `hsquared()` still does not fit or
    return an `hsquared_fit` object.
- Rose wording sweep:
  - README, vignettes, and design docs describe this as an extractor contract
    over future/internal fit objects, not as fitted animal-model support.

## 2026-06-13 R data container slice

- GitHub issue setup:
  - `gh issue create --repo itchyshin/hsquared --title "R data container for phenotype/pedigree/genotype inputs" ...`
  - Result: created issue #8 for the `hs_data()` data-container lane.
- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: `NAMESPACE` regenerated and `man/hs_data.Rd` written.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `81 pass`, `0 fail`.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- API evidence:
  - Added `hs_data()` for phenotype, pedigree, genotype, marker, expression,
    annotation, and environment inputs.
  - Tests cover phenotype/pedigree ID checks, genotype and expression ID maps,
    genotyped-without-phenotype and phenotyped-without-genotype bookkeeping,
    default-row-name rejection, and unsupported component shapes.
- Rose wording sweep:
  - Public wording says lightweight data container and ID maps only.
  - No public wording claims file-backed genomics, streaming, QTL/eQTL scans,
    or model fitting.

## 2026-06-13 R live Julia bridge smoke slice

- Rehydrated state before closeout:
  - `git status --short --branch`
  - `gh run list --repo itchyshin/hsquared --limit 5`
  - `git status --short --branch` in sibling `HSquared.jl`
  - `gh run list --repo itchyshin/HSquared.jl --limit 5`
- Result:
  - `hsquared` was clean at `644c75e` before the bridge-smoke edit.
  - `HSquared.jl` was clean at `798cfb7` after the twin committed the
    `HSData` mirror; Julia CI, Documenter, and Pages had passed.
- Local implementation checks:
  - `Rscript -e "devtools::document()"`
  - Result: completed after loading `hsquared`.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `93 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge test activated the sibling project at
    `~/Dropbox/Github Local/HSquared.jl` and returned an internal
    `hsquared_fit`.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Bridge/API evidence:
  - Added internal `hs_fit_julia_payload()`.
  - The tiny smoke path checks for Julia, `JuliaCall`, and a sibling
    `HSquared.jl` project before running.
  - The bridge sends `y`, `X`, dense guarded `Z`, pedigree IDs/parents,
    method, and initial variance values into Julia.
  - Julia builds `Ainv` through `pedigree_inverse()`, calls
    `fit_animal_model()`, returns `result_payload()`, and R normalizes the
    result into the existing internal `hsquared_fit` contract.
  - Tests assert convergence, finite log-likelihood, variance components,
    breeding-value IDs, fixed-effect naming, heritability, and `logLik()`.
  - A dense-size guard refuses payloads above `max_dense_cells`.
- Cross-repo learning:
  - The first live smoke exposed a Julia-side type-order issue where
    `HSData` referenced `HSDataIDMap` before it was defined.
  - The sibling Julia lane fixed and committed that work in
    `798cfb7 Add HSData input container`; local Julia `Pkg.test()` and
    Documenter checks were verified from the R/coordinator lane.
- Rose wording sweep:
  - README, model status, engine contract, capability status, validation debt,
    and public claims register now say local internal bridge smoke only.
  - Public wording still says ordinary `hsquared()` calls do not fit models and
    production/user-facing bridge execution remains planned.

## 2026-06-13 R opt-in Julia engine slice

- Goal: make the live Julia bridge reachable through an explicit experimental
  user-facing control while keeping the default `hsquared()` call
  validation-only.
- Active lenses: Ada, Shannon, Hopper, Lovelace, Emmy, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Added `engine = c("validate", "julia")` to `hs_control()`.
  - Kept Julia-specific knobs in `engine_control`: currently `julia_project`,
    `initial`, and `max_dense_cells`.
  - Updated `hsquared()` so `control = hs_control(engine = "julia")` calls the
    experimental Julia bridge and returns an internal `hsquared_fit`.
  - Default `hs_control(engine = "validate")` still parses, validates, builds
    the bridge payload, and stops with an informative message.
  - Added validation for named `engine_control` and positive
    `max_dense_cells`.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `animal`, `hs_control`, `hsquared`, and package Rd
    topics.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `105 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live tests activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says experimental opt-in tiny local engine path.
  - Public wording does not claim general animal-model fitting, sparse
    production bridge execution, ASReml-level support, or large-data readiness.

## 2026-06-13 R PEV and reliability extractor contract

- Goal: mirror Julia's new dense experimental PEV/reliability extractor
  vocabulary on the R fitted-object side without claiming the live bridge
  payload returns those fields yet.
- Active lenses: Fisher, Pat, Emmy, Hopper, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `prediction_error_variance()` generic and
    `hsquared_fit` method.
  - Added exported `reliability()` generic and `hsquared_fit` method.
  - Added future-compatible bridge normalization for
    `raw$prediction_error_variance` and `raw$reliability` if Julia adds those
    fields to `result_payload()`.
  - Updated pkgdown extractor index.
  - Updated claim register, capability status, validation debt, engine
    contract, README, NEWS, and model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and extractor Rd topics.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `111 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge test still confirms reliability is absent from the current
    Julia payload.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says R extractor contract only.
  - Public wording does not claim current live bridge PEV/reliability,
    production sparse PEV/reliability, or comparator validation.

## 2026-06-13 R sparse Z bridge marshalling

- Goal: use the Julia twin's `sparse_csc_matrix()` helper so the opt-in R
  bridge sends sparse `Matrix::dgCMatrix` slots instead of densifying `Z`.
- Active lenses: Hopper, Lovelace, Karpinski, Grace, Rose.
- Spawned subagents: none.
- Julia handoff:
  - `HSquared.jl` commit `6b530e4 Add sparse CSC bridge marshalling`.
  - Julia CI, Documenter, and Pages were green before the R slice started.
- Implementation evidence:
  - Removed dense `Z` conversion from `hs_julia_assign_payload()`.
  - Added `hs_sparse_csc_slots()` to expose `nrow`, `ncol`, zero-based
    `colptr`, zero-based `rowval`, and numeric `nzval`.
  - Added `hs_julia_assign_sparse_csc()` to construct Julia
    `SparseMatrixCSC` objects through `HSquared.sparse_csc_matrix()`.
  - Removed `max_dense_cells` from the active engine-control surface.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `hs_control` Rd.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `116 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Remote checks:
  - Commit: `2a9ba37 Use sparse Z bridge marshalling`.
  - `gh run watch 27457225007 --exit-status`
  - Result: R-CMD-check passed in GitHub Actions.
  - `gh run watch 27457225023 --exit-status`
  - Result: pkgdown passed in GitHub Actions.
  - `gh run watch 27457267046 --exit-status`
  - Result: GitHub Pages build and deployment passed. The run emitted a
    GitHub-hosted Node.js 20 deprecation annotation for Pages actions.
- Rose wording sweep:
  - Public wording says sparse `Z` marshalling, not production sparse fitting.
  - Public wording does not claim large-data readiness, Mrode validation, or
    production bridge performance.

## 2026-06-13 Tiny Ainv validation fixture

- Goal: add the first tiny deterministic validation atom for issue #7 without
  claiming Mrode, ASReml, or production sparse fitting coverage.
- Active lenses: Curie, Fisher, Gauss, Jason, Rose, Grace.
- Spawned subagents: none.
- Scout evidence:
  - Read local `drmTMB` animal-relatedness and Julia-bridge tests.
  - Read local `gllvmTMB` sparse pedigree `Ainv` tests, validation register,
    cross-package validation article, and Gaussian REML pilot report.
  - Checked Henderson, Mrode, AGHmatrix, and nadiv public sources for the
    validation ladder.
  - Persisted lessons in
    `docs/dev-log/scout/2026-06-13-validation-fixtures.md`.
- Implementation evidence:
  - Added internal `hs_tiny_animal_validation_fixture()`.
  - Added tests that pin R payload ID ordering, parent indices, sparse `Z`,
    and live Julia `pedigree_inverse()` agreement for the three-animal
    fixture when a sibling `HSquared.jl` checkout is available.
  - Updated capability status, validation debt, public claims register,
    NEWS, and model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'validation-fixtures')"`
  - Result: passed with `8 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live fixture activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `124 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Remote checks:
  - Commit: `c161a7f Add tiny Ainv validation fixture`.
  - `gh run watch 27457494019 --exit-status`
  - Result: R-CMD-check passed in GitHub Actions.
  - `gh run watch 27457494023 --exit-status`
  - Result: pkgdown passed in GitHub Actions.
  - `gh run list --limit 8`
  - Result: GitHub Pages build and deployment `27457528612` passed.
- Rose wording sweep:
  - Public wording says tiny deterministic Ainv validation fixture.
  - Public wording does not claim Mrode validation, ASReml comparison,
    production sparse fitting, large-pedigree readiness, or genomic
    validation.

## 2026-06-13 Mrode9 pedigree Ainv comparator

- Goal: add the first optional Mrode-sourced pedigree `Ainv` comparator without
  claiming fitted Mrode animal-model validation.
- Active lenses: Curie, Fisher, Gauss, Jason, Rose, Grace.
- Spawned subagents: none.
- Source:
  - `nadiv::Mrode9`, documented by `nadiv` as a pedigree adapted from example
    9.1 of Mrode (2005).
- Implementation evidence:
  - Added optional `nadiv` Suggests entry.
  - Added internal `hs_mrode9_pedigree_validation_fixture()`.
  - Added tests that load `nadiv::Mrode9`, compute `nadiv::makeAinv()`, align
    names, and compare with Julia `HSquared.pedigree_inverse()` when both
    `nadiv` and the sibling Julia bridge are available.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'mrode-validation')"`
  - Result: passed with `8 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live comparator activated sibling `HSquared.jl`.
  - `air format . && Rscript -e "devtools::test()"`
  - Result: passed with `132 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated sibling `HSquared.jl`.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Remote checks:
  - Commit: `f0e71c7 Add Mrode9 Ainv comparator`.
  - `gh run watch 27457712229 --exit-status`
  - Result: R-CMD-check passed in GitHub Actions.
  - `gh run watch 27457712238 --exit-status`
  - Result: pkgdown passed in GitHub Actions.
  - `gh run list --limit 8`
  - Result: GitHub Pages build and deployment `27457742164` passed.
- Rose wording sweep:
  - Public wording says Mrode9 pedigree-Ainv comparator.
  - Public wording does not claim fitted Mrode animal-model validation,
    ASReml/BLUPF90/DMU/WOMBAT comparison, production sparse fitting, or
    large-pedigree readiness.

## 2026-06-13 Planned backend vocabulary controls

- Goal: align `hs_control()` with the CPU/GPU backend vocabulary in the
  genomics/QTL/GPU plan without claiming backend execution.
- Active lenses: Lovelace, Karpinski, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Expanded `backend` values to `auto`, `cpu`, `threads`, `cuda`, `amdgpu`,
    `metal`, and `oneapi`.
  - Expanded `accelerator` values to `auto`, `none`, `gpu`, `cuda`,
    `amdgpu`, `metal`, and `oneapi`.
  - Added control-validation tests.
  - Updated public claims, capability status, validation debt, NEWS, and the
    model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `man/hs_control.Rd`.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `27 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `143 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says planned backend/control vocabulary only.
  - Public wording does not claim CPU/GPU execution, Metal/CUDA/AMDGPU/oneAPI
    availability, backend benchmarking, or CPU/GPU numerical agreement.
- Remote checks:
  - Commit: `5feac1f Expand planned backend controls`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27457948686` passed in GitHub Actions.
  - Result: pkgdown `27457948693` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27457985141` passed.

## 2026-06-13 Backend status diagnostics

- Goal: add an honest R-side backend diagnostic surface that exposes planned
  backend vocabulary while marking backend execution unavailable.
- Active lenses: Lovelace, Karpinski, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `backend_info()`.
  - Added `print.hs_backend_info()`.
  - Added tests that check planned backend rows, requested-backend flags,
    `selectable = TRUE`, `execution_available = FALSE`, and `status =
    "planned"`.
  - Added `backend_info()` to the pkgdown reference index.
  - Updated NEWS, public claims, capability status, validation debt, and the
    model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and `man/backend_info.Rd`.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `35 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `151 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - First `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: failed because `_pkgdown.yml` was missing the new `backend_info`
    topic from the reference index.
  - Second `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says `backend_info()` reports planned backend vocabulary and
    unavailable execution status.
  - Public wording does not claim runtime backend probes, CPU/GPU execution,
    backend benchmarking, or CPU/GPU numerical agreement.
- Remote checks:
  - Commit: `498d41f Add backend status diagnostics`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458148965` passed in GitHub Actions.
  - Result: pkgdown `27458148970` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458179717` passed.

## 2026-06-13 Planned genomic and QTL formula markers

- Goal: reserve readable genomics/QTL formula vocabulary while rejecting it
  honestly until implementation exists.
- Active lenses: Boole, Jason, Lovelace, Rose, Pat.
- Spawned subagents: none.
- Scout input:
  - Read local sibling formula-marker patterns in `gllvmTMB` and `DRM.jl`.
  - Useful local lesson: reserve readable markers, but keep parser and engine
    support explicit so decorative formula terms do not imply computation.
- Implementation evidence:
  - Added inert `genomic()`, `single_step()`, `markers()`, `marker_scan()`,
    and `qtl_scan()` functions.
  - Added parser detection for those markers before model-frame construction.
  - Added planned-not-implemented errors for genomic, marker-scan, single-step,
    and QTL/eQTL terms.
  - Added tests and a pkgdown reference topic.
  - Updated NEWS, public claims, capability status, validation debt, and the
    model-status article.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and `man/genomic_markers.Rd`.
  - `Rscript -e "devtools::test(filter = 'formula-animal')"`
  - Result: passed with `17 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `158 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says inert planned markers and planned-not-implemented
    parser errors.
  - Public wording does not claim genomic prediction, marker scanning,
    QTL/eQTL analysis, single-step fitting, or marker-effect estimation.
- Remote checks:
  - Commit: `dc53584 Add planned genomic QTL markers`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458338370` passed in GitHub Actions.
  - Result: pkgdown `27458338374` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458374477` passed.

## 2026-06-13 Planned standard QG and inheritance formula markers

- Goal: reserve readable Phase 2+ formula vocabulary for permanent
  environment, common environment, parental effects, inheritance kernels, and
  custom relationship/precision terms while rejecting it honestly until
  implementation exists.
- Active lenses: Boole, Jason, Darwin, Emmy, Rose, Pat.
- Spawned subagents: none.
- Scout input:
  - Read local `gllvmTMB` animal keyword conventions.
  - Read local `drmTMB` structured-effect status patterns.
  - Read local `DRM.jl` parse-time `relmat()`/`animal()` marker pattern.
  - Read local `GLLVM.jl` structured precision and performance design notes.
  - Useful local lesson: formula vocabulary should be explicit and
    discoverable, but parser support must not imply fitted model support.
- Implementation evidence:
  - Added inert `permanent()`, `common_env()`, `maternal_genetic()`,
    `maternal_env()`, `paternal_genetic()`, `paternal_env()`,
    `cytoplasmic()`, `imprinting()`, `dominance()`, `epistasis()`,
    `relmat()`, and `precision()` functions.
  - Generalized parser planned-marker detection so those markers fail before
    model-frame construction.
  - Added planned-not-implemented parser tests and pkgdown reference topic.
  - Updated NEWS, README, formula grammar, public claims, capability status,
    validation debt, model-status article, and scout notes.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated documentation; `man/qg_effect_markers.Rd` exists.
  - `Rscript -e "devtools::test(filter = 'formula-animal')"`
  - Result: passed with `33 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `174 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says inert planned markers and planned-not-implemented
    parser errors.
  - Public wording does not claim permanent environment, common environment,
    maternal/paternal, dominance, epistasis, custom relationship/precision,
    cytoplasmic, or imprinting models are fitted.
- Remote checks:
  - Commit: `14e5781 Add planned quantitative genetics markers`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458665520` passed in GitHub Actions.
  - Result: pkgdown `27458665528` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458695360` passed.

## 2026-06-13 Formula grammar roadmap article

- Goal: make the pkgdown site easier for applied users by separating parsed
  v0.1 syntax from planned quantitative-genetic, inheritance-kernel, genomic,
  marker, multivariate, and factor-analytic syntax.
- Active lenses: Pat, Boole, Rose, Grace.
- Spawned subagents: none.
- Scout/style input:
  - Used `prose-style-review`: reader first, purpose before mechanics, and
    implemented/partial/planned separation.
  - Used `rose-pre-public-audit`: public claims must not imply fitted Phase 2+
    support.
- Implementation evidence:
  - Added `vignettes/articles/formula-grammar.Rmd`.
  - Added the article to the pkgdown navbar and article list.
  - Added a NEWS entry.
- Local checks:
  - `air format .`
  - Result: completed.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Replaced a too-broad "Works today" heading with "Parsed today".
  - Public wording says the article is a grammar map and that planned markers
    are syntax reservations only.
- Remote checks:
  - Commit: `92c1d12 Add formula grammar roadmap article`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27458831298` passed in GitHub Actions.
  - Result: pkgdown `27458831294` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27458861190` passed.

## 2026-06-13 Formula grammar status diagnostic

- Goal: give users a compact R-side status table for parsed, reserved, and
  planned grammar terms.
- Active lenses: Pat, Boole, Emmy, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `formula_status()`.
  - Added `print.hs_formula_status()`.
  - Added tests for non-empty rows, parsed/reserved/planned status, and print
    output.
  - Added pkgdown reference entry.
  - Updated README, NEWS, model-status article, formula grammar article,
    capability status, public claims, and validation debt.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: regenerated `NAMESPACE` and `man/formula_status.Rd`.
  - `Rscript -e "devtools::load_all(quiet = TRUE); print(formula_status())"`
  - Result: printed a 20-row `hs_formula_status` table.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `47 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `186 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says diagnostic/status table.
  - Public wording does not say `formula_status()` expands the parser or
    enables fitting.
- Remote checks:
  - Commit: `52d57dd Add formula grammar status diagnostic`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27459051476` passed in GitHub Actions.
  - Result: pkgdown `27459051483` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27459084347` passed.

## 2026-06-13 GPU/backend and algorithm scout

- Goal: record source-backed backend and algorithm leads for later
  `HSquared.jl` engine work.
- Active lenses: Jason, Gauss, Karpinski, Grace, Rose.
- Spawned subagents: none.
- Sources checked:
  - Official JuliaGPU documentation for CUDA.jl, AMDGPU.jl, Metal.jl,
    oneAPI.jl, and KernelAbstractions.jl.
  - Source pages for Takahashi selected inverse, sparse inverse subset, APY
    genomic relationship inverse, sparse AI-REML, and augmented AI-REML.
- Implementation evidence:
  - Added `docs/dev-log/scout/2026-06-13-gpu-algorithm-scout.md`.
- Local checks:
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - The scout says research direction only.
  - It does not claim backend execution, selected-inverse, APY, or AI-REML is
    implemented.
- Remote checks:
  - Commit: `6d6f1f1 Add GPU and algorithm scout`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27459211479` passed in GitHub Actions.
  - Result: pkgdown `27459211480` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27459245659` passed.

## 2026-06-13 Expanded genomics/QTL/GLLVM/GPU plan

- Goal: convert the maintainer's extended prompt into a durable 20-section
  technical and strategic plan for `hsquared` and `HSquared.jl`.
- Active lenses: Ada, Jason, Karpinski, Pat, Rose.
- Spawned subagents: none.
- Local sibling scout:
  - `find /Users/z3437171/Dropbox/Github\ Local -maxdepth 2 -type d ...`
  - Result: found local `drmTMB`, `gllvmTMB`, `DRM.jl`, `GLLVM.jl`, and many
    GLLVM branch/worktree folders; no `PMTMB` folder was found by name.
  - Read targeted local references:
    `DRM.jl/src/takahashi_selinv.jl`, `DRM.jl/src/DRM.jl`,
    `gllvmTMB/CLAUDE.md`, `GLLVM.jl/src/fit.jl`, and
    `GLLVM.jl/src/structured_schur.jl`.
- Implementation evidence:
  - Expanded `docs/design/07-genomics-qtl-gpu-plan.md` into the requested
    design plan covering architecture, grammar, data integration, genomics,
    QTL/eQTL, GLLVMs, CPU/GPU backends, HPC, validation, outputs, roadmap,
    risks, and the first minimal implementation.
  - Updated `vignettes/articles/genomics-gpu-roadmap.Rmd` with user-facing
    QTL/eQTL and multivariate/GLLVM roadmap examples.
  - Updated `docs/design/00-ecosystem-lessons.md` with concrete local lessons
    from `DRM.jl`, `GLLVM.jl`, and `gllvmTMB`.
- Local checks:
  - `git diff --check`
  - Result: clean.
  - `LC_ALL=C rg -n "[^\\x00-\\x7F]" docs/design/07-genomics-qtl-gpu-plan.md docs/design/00-ecosystem-lessons.md vignettes/articles/genomics-gpu-roadmap.Rmd docs/dev-log/after-task/2026-06-13-expanded-genomics-qtl-gpu-plan.md NEWS.md`
  - Result: no non-ASCII matches in edited files.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - The plan and pkgdown article call genomic, QTL/eQTL, GLLVM, GPU, and HPC
    examples planned targets only.
  - Public wording does not claim those workflows are implemented, benchmarked,
    or ASReml-level.
- Remote checks:
  - Commit: `f806a96 Expand genomics QTL GPU plan`.
  - `gh run list --limit 8`
  - Result: R-CMD-check `27459396773` passed in GitHub Actions.
  - Result: pkgdown `27459396771` passed in GitHub Actions.
  - Result: GitHub Pages build and deployment `27459433476` passed.

## 2026-06-13 Opt-in bridge PEV/reliability enrichment

- Goal: enrich the experimental local R-to-Julia bridge with dense
  validation-path prediction-error-variance and reliability fields when the
  sibling `HSquared.jl` checkout exposes exported extractors.
- Active lenses: Hopper, Lovelace, Fisher, Emmy, Rose, Grace.
- Spawned subagents: none.
- Bridge review:
  - Read `docs/design/01-v0.1-contract.md` and
    `docs/design/03-engine-contract.md`.
  - Inspected R bridge code and tests.
  - Inspected sibling `HSquared.jl` state on clean `main` at `5960af1`, where
    `prediction_error_variance(fit)` and `reliability(fit)` exist as dense
    validation-path functions but base `result_payload(fit)` remains stable.
- Implementation evidence:
  - Updated `hs_fit_julia_payload()` to merge optional
    `prediction_error_variance` and `reliability` fields into the R-side raw
    result by calling exported Julia dense validation extractors when they are
    defined.
  - Added a Julia-free normalizer test for optional PEV/reliability fields.
  - Updated live Julia bridge smoke tests to assert PEV/reliability IDs and
    finite values.
  - Updated README, model-status article, v0.1 and engine contracts,
    capability status, validation debt, claims register, NEWS, and
    coordination board.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'julia-bridge')"`
  - Result: passed with `34 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The test activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `195 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: clean.
  - `rg -n "PEV/reliability waiting|does not return them yet|not yet in live R bridge|PEV or reliability through the current live|waiting on Julia result-payload|current Julia bridge payload does not" README.md NEWS.md vignettes docs R tests`
  - Result: no stale wording matches.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says dense validation-path enrichment for tiny opt-in local
    bridge examples only.
  - Public wording does not claim production sparse PEV/reliability, Mrode
    fitted-output validation, or general animal-model fitting.

## 2026-06-13 Model specification preview helper

- Goal: add a user-facing `model_spec()` inspector for the parsed v0.1 animal
  model contract without widening fitting claims.
- Active lenses: Emmy, Hopper, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `model_spec()` and `"hs_model_spec"` / `"summary_hs_model_spec"`
    methods.
  - The inspector validates `animal(1 | id, pedigree = ped)`, builds the same
    internal bridge payload as `hsquared()`, and reports response, family,
    method, fixed columns, sparse `Z` dimensions, animal IDs, pedigree
    founders, and Julia targets.
  - Added tests for preview fields, compact summaries, no fitted result field,
    and planned-marker error reuse.
  - Updated README, model-status article, pkgdown reference index, capability
    status, claims register, coordination board, and NEWS.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `man/model_spec.Rd`.
  - `Rscript -e "devtools::test(filter = 'model-spec-inspect')"`
  - Result: passed with `24 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `219 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - First result: failed because `_pkgdown.yml` was missing the new
    `model_spec` topic.
  - Fix: added `model_spec` to the Start here reference index.
  - Second result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Public wording says `model_spec()` previews the parsed contract and does
    not fit a model.
  - Public wording does not claim general animal-model fitting.

## 2026-06-13 hs_data parser integration

- Goal: let the v0.1 R parser use an `hs_data()` bundle directly for the
  phenotype/pedigree path.
- Active lenses: Emmy, Pat, Hopper, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added internal `hs_model_data_context()` to unwrap `hs_data()` into
    `phenotypes` plus a formula environment containing named components such as
    `pedigree`, `genotypes`, `markers`, `expression`, `annotation`, and
    `environment`.
  - `model_spec()` and `hsquared()` can now parse
    `animal(1 | id, pedigree = pedigree)` when `data` is an `hs_data()` object
    with a pedigree component.
  - Updated tests, README, model-status article, v0.1 contract, status tables,
    claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`, `hsquared.Rd`, and `model_spec.Rd`.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `17 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test(filter = 'model-spec-inspect')"`
  - Result: passed with `29 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `225 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says `hs_data()` integration is for the v0.1
    phenotype/pedigree parser path.
  - Public wording does not claim file-backed storage, automatic genotype/omics
    model construction, or broader fitting support.

## 2026-06-13 hs_data ID-overlap summary

- Goal: make `summary(hs_data(...))` more useful for phenotype, pedigree,
  genotype, and expression ID checks.
- Active lenses: Emmy, Pat, Rose.
- Spawned subagents: none.
- Implementation evidence:
  - Added an `id_overlap` table to `summary.hs_data()`.
  - The table reports phenotype, pedigree, genotype, expression, and mismatch
    counts using the existing `id_map`.
  - Updated tests, README, model-status article, capability status, claims
    register, NEWS, and coordination board.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; no generated file changes.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `19 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `227 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording describes an ID diagnostic only.
  - Public wording does not claim modelling support from genotype or expression
    components.

## 2026-06-13 hs_data marker-map validation

- Goal: add conservative marker-map metadata validation to `hs_data()`.
- Active lenses: Emmy, Jason, Pat, Rose.
- Spawned subagents: none.
- Scout:
  - Read `quantgen-scout` and local package map.
  - Searched local `drmTMB`, `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` for marker
    and map vocabulary.
  - Recorded `docs/dev-log/scout/2026-06-13-marker-map-validation-scout.md`.
- Implementation evidence:
  - Added private `hs_validate_marker_map()`.
  - `hs_data(markers = ...)` now requires marker ID, chromosome, and position
    columns using common aliases.
  - Marker IDs must be non-missing and unique; chromosomes cannot be missing or
    empty; positions must be finite, numeric, and non-negative.
  - Stored normalized metadata in private `hs_marker_map_spec`.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `26 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `234 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says marker metadata validation only.
  - Public wording does not claim genotype parsing, PLINK/VCF ingestion, marker
    imputation, marker scans, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data genotype-marker alignment

- Goal: check that genotype marker columns match supplied marker-map IDs.
- Active lenses: Emmy, Jason, Pat, Rose.
- Spawned subagents: none.
- Scout:
  - Reused `docs/dev-log/scout/2026-06-13-marker-map-validation-scout.md` and
    updated it with the alignment rule.
- Implementation evidence:
  - Added private `hs_validate_genotype_marker_alignment()` and
    `hs_genotype_marker_ids()`.
  - When both `genotypes` and `markers` are supplied, genotype marker column
    names must match marker-map IDs exactly, allowing different order but no
    missing or extra markers.
  - Stored private `hs_genotype_marker_spec` with marker IDs and marker-map
    indices.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `34 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `242 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says genotype-marker alignment validation only.
  - Public wording does not claim genotype parsing, marker imputation, marker
    scans, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data marker-status summary

- Goal: expose marker-map and genotype-marker alignment diagnostics through
  `summary(hs_data(...))`.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `marker_status` to `summary.hs_data()`.
  - The table reports marker-map marker count, genotype marker-column count,
    aligned marker-column count, chromosome count, coordinate range, and
    alignment status.
  - `print.summary_hs_data()` prints marker status only when marker or genotype
    marker components are present.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `41 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `249 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says marker-status diagnostics only.
  - Public wording does not claim genotype parsing, marker imputation, marker
    scans, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 data_status diagnostic helper

- Goal: add a direct user-facing status helper for `hs_data()` diagnostics.
- Active lenses: Emmy, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added exported `data_status()` S3 generic.
  - Added `data_status.hs_data()` and `print.hs_data_status()`.
  - The helper reports component presence, ID-overlap diagnostics, and
    marker-status diagnostics using the existing `hs_data()` summary surfaces.
  - Added tests and pkgdown reference-index coverage.
  - Updated README, model-status article, capability status, validation debt,
    claims register, NEWS, and coordination board.
- Local checks:
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `data_status.Rd`.
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `46 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `254 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says `data_status()` is a diagnostic helper only.
  - Public wording does not claim fitting, genotype parsing, relationship
    matrix construction, marker scanning, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data pedigree-status diagnostics

- Goal: expose pedigree coverage and parent-link diagnostics through
  `summary(hs_data(...))` and `data_status()`.
- Active lenses: Emmy, Henderson, Pat, Rose, Grace.
- Spawned subagents: none.
- Scout:
  - Searched local `drmTMB`, `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` for
    relationship, parent, pedigree, and precision patterns.
  - Recorded `docs/dev-log/scout/2026-06-13-pedigree-status-scout.md`.
- Implementation evidence:
  - Added `pedigree_status` to `summary.hs_data()`.
  - Added pedigree-status printing to `print.summary_hs_data()` and
    `print.hs_data_status()`.
  - `data_status()` now includes pedigree diagnostics alongside ID and marker
    diagnostics.
  - Updated tests, README, model-status article, capability status, validation
    debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `hs_data.Rd` and `data_status.Rd`.
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: passed with `55 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `263 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - Result: `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - Public wording says pedigree diagnostics only.
  - Public wording does not claim pedigree inverse construction, Ainv support,
    animal-model fitting, genomic fitting, or QTL/eQTL fitting.

## 2026-06-13 hs_data pedigree shorthand for animal()

- Goal: let `animal(1 | id)` use the pedigree stored in
  `data = hs_data(..., pedigree = ped)`, while keeping explicit
  `animal(1 | id, pedigree = ped)` as the canonical portable contract.
- Active lenses: Ada, Shannon, Boole, Noether, Emmy, Hopper, Grace, Rose, Pat.
- Spawned subagents: none.
- Scout:
  - Checked local `gllvmTMB`, `DRM.jl`, and `GLLVM.jl` guidance for formula
    parity, one-engine data-shape conversion, R-Julia bridge ownership, and
    verify-before-claim discipline.
  - Recorded
    `docs/dev-log/scout/2026-06-13-hs-data-pedigree-shorthand-scout.md`.
- Implementation evidence:
  - `hs_build_model_spec()` now passes the original `hs_data()` context to the
    animal parser.
  - `animal(1 | id)` resolves to the bundle pedigree only when `data` is an
    `hs_data()` object with a pedigree component.
  - Plain data frames and `hs_data()` objects without a pedigree still error
    clearly and require an explicit pedigree source.
  - `model_spec()` summaries now record whether the pedigree came from the
    formula or the `hs_data()` bundle.
  - `formula_status()` reports the bundle shorthand as parsed today.
  - Updated tests, README, formula/status articles, capability status,
    validation debt, claims register, NEWS, and roxygen docs.
- Local checks:
  - `Rscript -e "devtools::test(filter = 'formula-animal|model-spec-inspect|phase0-api')"`
  - Result: passed with `122 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `animal.Rd`, `hsquared.Rd`, and `model_spec.Rd`.
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `276 pass`, `0 fail`, `0 warnings`, and `0 skips`.
    The live bridge activated the sibling `HSquared.jl` checkout.
  - `git diff --check`
  - Result: passed with no output.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n 'henderson_mme.*estimate|Henderson MME.*estimate|supplied-variance.*log-likelihood|log-likelihood.*supplied-variance|production sparse reliability.*implemented|general animal-model support|AI-REML is implemented|Mrode fitted-output validation is covered|ASReml parity|fast|faster|speedup' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says optional dense validation-path PEV/reliability for the
    supplied-variance Henderson MME bridge only.
  - Public wording does not claim variance-component estimation, log-likelihood
    support, AI-REML, Mrode fitted-output validation, ASReml parity, production
    sparse reliability, or speedup.
- Remote checks for commit `1489185`:
  - GitHub Actions R-CMD-check `27462976668`: passed in 1m29s.
  - GitHub Actions pkgdown `27462976666`: passed.
  - GitHub Pages build/deploy `27463009993`: passed.

## 2026-06-13 fitted/residual extractors for hsquared_fit

- Goal: add ordinary R `fitted()` and `residuals()` methods for
  `hsquared_fit` objects with normalized fitted-value predictions and response
  values.
- Active lenses: Emmy, Pat, Fisher, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `fitted.hsquared_fit()` over the normalized `predictions` result
    field.
  - Added `residuals.hsquared_fit()` using the stored response vector and
    fitted values.
  - Added guards for missing response values and response/fitted length
    mismatch.
  - Updated NEWS, README, model-status article, v0.1 contract, engine
    contract, capability status, validation debt, public claims, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `39 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `340 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note identified
    unqualified internal calls to `predict()` and `fitted()`.
  - Namespace fix: changed internal calls to `stats::predict()` and
    `stats::fitted()`.
  - `air format . && Rscript -e "devtools::test(filter = 'fit-object')" && Rscript -e "devtools::check()"`
  - Result: focused tests passed with `39 pass`, `0 fail`, `0 warnings`, and
    `0 skips`; `devtools::check()` returned `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n 'fitted\\(\\).*general|residuals\\(\\).*general|residuals.*fit model|fitted.*fit model|general animal-model support|production sparse|ASReml parity|speedup|fast|faster' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says fitted/residual extractor methods for `hsquared_fit`
    objects only.
  - Public wording does not claim general model fitting, production sparse
    fitting, ASReml parity, or speedup.
- Remote checks for commit `09f3135`:
  - GitHub Actions R-CMD-check `27463241417`: passed in 1m37s.
  - GitHub Actions pkgdown `27463241406`: passed.
  - GitHub Pages build/deploy `27463273446`: passed.

## 2026-06-13 EBV/BLUP aliases and accuracy extractor

- Goal: add applied-user extractor ergonomics for `hsquared_fit` objects:
  `EBV()`, `BLUP()`, and `accuracy()`.
- Active lenses: Emmy, Falconer, Fisher, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `EBV()` and `BLUP()` as S3 aliases for `breeding_values()`.
  - Added `accuracy()` as a derived square-root reliability extractor.
  - Added guardrails for malformed reliability payloads and values outside
    `[0, 1]`.
  - Updated NEWS, README, model-status article, v0.1 contract, engine
    contract, capability status, validation debt, public claims, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `48 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `349 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n 'accuracy\\(\\).*validated|accuracy\\(\\).*general|EBV\\(\\).*general|BLUP\\(\\).*general|production accuracy|production sparse|general animal-model support|ASReml parity|speedup|fast|faster' README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says alias and derived extractors for `hsquared_fit` objects
    only.
  - Public wording does not claim general model fitting, production accuracy,
    production sparse fitting, ASReml parity, or speedup.
- Remote checks for commit `046a8e6`:
  - GitHub Actions R-CMD-check `27463477466`: passed in 1m33s.
  - GitHub Actions pkgdown `27463477467`: passed in 1m49s.
  - GitHub Pages build/deploy `27463517699`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.
- Remote checks for evidence commit `66d4d36`:
  - GitHub Actions R-CMD-check `27463547679`: passed in 1m30s.
  - GitHub Actions pkgdown `27463547685`: passed in 1m36s.
  - GitHub Pages build/deploy `27463582542`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.
- Issue ledger:
  - Issue #5 updated:
    <https://github.com/itchyshin/hsquared/issues/5#issuecomment-4698196423>.

## 2026-06-13 hs_data environment-key diagnostics

- Goal: add `hs_data()` diagnostics for environment/covariate metadata keyed
  to phenotype records.
- Active lenses: Emmy, Darwin, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `environment_id` to `hs_data()`.
  - Added `hs_environment_spec` metadata for keyed environment tables.
  - Added `summary(hs_data(...))$environment_status`.
  - Added `data_status(...)$environment_status` and print support.
  - Added tests for keyed coverage, unkeyed environment tables, and invalid
    environment-key inputs.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `74 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `368 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "environment.*model|environment.*fit|multi-environment.*support|environment_id.*fit|environment_id.*model|genomic.*implemented|QTL.*implemented|eQTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports genomic|supports QTL|supports eQTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says environment-key diagnostics only.
  - Public wording does not claim environmental model terms,
    multi-environment animal models, automatic environment joins, genomic/QTL
    fitting, GLLVM support, GPU execution, ASReml parity, or speedup.
- Remote checks for commit `07c8145`:
  - GitHub Actions R-CMD-check `27463896935`: passed in 1m37s.
  - GitHub Actions pkgdown `27463896936`: passed in 1m34s.
  - GitHub Pages build/deploy `27463935270`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.
- Issue ledger:
  - Issue #8 updated:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698232188>.

## 2026-06-13 hs_data annotation-feature diagnostics

- Goal: add `hs_data()` diagnostics for expression feature columns keyed to
  annotation metadata rows.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `annotation_id` to `hs_data()`.
  - Added `hs_annotation_spec` metadata for keyed annotation tables.
  - Added `summary(hs_data(...))$annotation_status`.
  - Added `data_status(...)$annotation_status` and print support.
  - Added tests for keyed annotation coverage, unkeyed annotation tables, and
    invalid annotation-key inputs.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `94 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `388 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "annotation.*model|annotation.*fit|annotation_id.*fit|annotation_id.*model|eQTL.*implemented|omics.*implemented|expression.*model|expression.*fit|automatic.*annotation|genomic.*implemented|QTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports eQTL|supports omics|supports QTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, or prior scan/report records.
  - Public wording says annotation-feature diagnostics only.
  - Public wording does not claim eQTL fitting, omics models, automatic
    annotation joins, marker/QTL/GWAS fitting, GLLVM support, GPU execution,
    ASReml parity, or speedup.
- Remote checks for commit `cc62dd2`:
  - GitHub Actions R-CMD-check `27464161209`: passed.
  - GitHub Actions pkgdown `27464161179`: passed.
  - GitHub Pages build/deploy `27464191840`: passed.
- Issue ledger:
  - Updated issue #8:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698262135>.

## 2026-06-13 hs_data expression-status diagnostics

- Goal: add `hs_data()` diagnostics for expression matrix/data-frame shape and
  feature naming without adding eQTL or omics modelling.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `summary(hs_data(...))$expression_status`.
  - Added `data_status(...)$expression_status` and print support.
  - The status table reports expression rows, expression IDs, expression
    feature count, named feature count, unnamed feature count, duplicate named
    feature count, and component type.
  - Added tests for data-frame expression inputs, named matrix features with
    duplicate feature IDs, and unnamed expression matrix columns.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()"`
  - Result: documentation updated; wrote `hs_data.Rd` and `data_status.Rd`.
  - `air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: formatting completed, and focused tests passed with `101 pass`,
    `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `395 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "expression.*model|expression.*fit|expression_status.*fit|expression_status.*model|eQTL.*implemented|omics.*implemented|automatic.*expression|automatic.*annotation|genomic.*implemented|QTL.*implemented|GLLVM.*implemented|GPU.*implemented|supports eQTL|supports omics|supports QTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, prior scan/report records, or
    the intended new `without fitting eQTL or omics models` wording.
  - Public wording says expression-status diagnostics only.
  - Public wording does not claim eQTL fitting, omics models, automatic
    expression or annotation joins, marker/QTL/GWAS fitting, GLLVM support,
    GPU execution, ASReml parity, or speedup.
- Remote checks:
  - GitHub Actions R-CMD-check `27464519542`: passed for commit `c5e97d1`.
  - GitHub Actions pkgdown `27464519547`: passed for commit `c5e97d1`.
  - GitHub Pages build/deploy `27464558016`: passed after the pkgdown publish.
  - Pages emitted the upstream Node.js 20 action deprecation annotation from
    the Pages action stack; no package-code failure.
- Issue ledger:
  - Updated issue #8:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698297184>.

## 2026-06-13 hs_data genotype-status diagnostics

- Goal: add `hs_data()` diagnostics for genotype matrix/data-frame shape and
  marker-column naming without adding genomic, marker-scan, or QTL modelling.
- Active lenses: Emmy, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `summary(hs_data(...))$genotype_status`.
  - Added `data_status(...)$genotype_status` and print support.
  - The status table reports genotype rows, genotype IDs, marker-column count,
    named marker-column count, unnamed marker-column count, duplicate named
    marker-column count, missing genotype value count, and component type.
  - Fixed duplicate-name handling in genotype and expression feature helper
    paths by replacing `setdiff()` with order-preserving name filtering.
  - Added tests for matrix genotype inputs, data-frame genotype inputs,
    unnamed genotype matrix columns, duplicate genotype marker columns, and
    missing genotype values.
  - Updated README, model-status article, capability status, validation debt,
    public claims, NEWS, roxygen docs, and board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`
  - Result: documentation updated, formatting completed, and focused tests
    passed with `108 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `402 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note was
    `unable to verify current time` from timestamp verification.
  - `Rscript -e "devtools::check()"`
  - Rerun result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "genotype.*model|genotype.*fit|genotype_status.*fit|genotype_status.*model|genomic.*implemented|marker.*implemented|QTL.*implemented|eQTL.*implemented|omics.*implemented|automatic.*genotype|automatic.*marker|GLLVM.*implemented|GPU.*implemented|supports genomic|supports QTL|supports eQTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  - Result: hits were planned, blocked, negated, prior scan/report records, or
    the intended new `without fitting genomic, marker-scan, or QTL models`
    wording.
  - Public wording says genotype-status diagnostics only.
  - Public wording does not claim genomic fitting, genotype parsing, marker
    scanning, QTL/GWAS/eQTL fitting, automatic genotype/model construction,
    GLLVM support, GPU execution, ASReml parity, or speedup.
- Remote checks:
  - GitHub Actions R-CMD-check `27464791701`: passed for commit `fd0cbd9`.
  - GitHub Actions pkgdown `27464791712`: passed for commit `fd0cbd9`.
  - GitHub Pages build/deploy `27464830072`: passed after the pkgdown publish.
  - Pages emitted the upstream Node.js 20 action deprecation annotation from
    the Pages action stack; no package-code failure.
- Issue ledger:
  - Updated issue #8:
    <https://github.com/itchyshin/hsquared/issues/8#issuecomment-4698325286>.

## 2026-06-13 supplied-variance Henderson MME validation fixture

- Goal: add an internal supplied-variance Henderson mixed-model-equation
  validation atom for issue #7.
- Active lenses: Curie, Henderson, Fisher, Hopper, Rose, Grace.
- Spawned subagents: none.
- Scout:
  - Checked local `HSquared.jl/src/likelihood.jl` to confirm
    `henderson_mme()` is a supplied-variance solver, not a variance-component
    optimizer.
  - Checked local `GLLVM.jl/CLAUDE.md` for verify-before-claim discipline.
  - Recorded
    `docs/dev-log/scout/2026-06-13-henderson-mme-validation-scout.md`.
- Implementation evidence:
  - Added `hs_henderson_mme_validation_fixture()`.
  - Added `hs_solve_henderson_mme_reference()` as an independent R MME solve.
  - Added tests comparing fixed effects, EBVs, fitted values, and h2 against
    expected fixture values.
  - Added an optional live Julia test comparing the R fixture with
    `HSquared.henderson_mme()` when a sibling checkout is available.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'validation-fixtures')"`
  - Result: passed with `19 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live fixture activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `287 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::document()"`
  - Result: completed.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "general animal-model support|production sparse fitting is validated|Mrode validation is covered|ASReml comparison is covered|GPU execution is (available|implemented)|fits general animal|supports genomic|supports QTL|supports eQTL" README.md vignettes docs/design docs/dev-log NEWS.md`.
  - Result: hits were planned, blocked, or negated wording only.
  - Public wording says supplied-variance Henderson MME validation fixture only.
  - Public wording does not claim variance-component estimation, general
    fitting, Mrode fitted-output validation, AI-REML, or production sparse
    fitting.
- Remote checks for commit `ec2a9cc`:
  - GitHub Actions R-CMD-check `27461936435`: passed in 1m40s.
  - GitHub Actions pkgdown `27461936446`: passed in 1m36s.
  - GitHub Pages build/deploy `27461969071`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.

## 2026-06-13 validation_status evidence diagnostics

- Goal: add a user-facing validation evidence status helper for issue #7.
- Active lenses: Curie, Fisher, Pat, Rose, Grace.
- Spawned subagents: none.
- Skill used:
  - `validation-canon-review`: read current validation canon and validation
    debt register before editing.
- Implementation evidence:
  - Added exported `validation_status()`.
  - Added `print.hs_validation_status()`.
  - The helper reports current partial validation atoms and planned comparator
    lanes with claim-boundary wording.
  - Added tests, roxygen docs, pkgdown reference entry, README/model-status
    wording, capability status, validation debt, public claims, NEWS, and board
    updates.
- Local checks:
  - `air format .`
  - Result: completed.
  - `Rscript -e "devtools::test(filter = 'phase0-api')"`
  - Result: passed with `56 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `validation_status.Rd`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `295 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "validation_status\\(\\).*fit|validation_status\\(\\).*run|validation_status\\(\\).*covered|ASReml parity|GPU speedup|general animal-model fitting is implemented|production sparse fitting is validated" README.md R man tests vignettes docs/design docs/dev-log NEWS.md _pkgdown.yml`.
  - Result: hits were planned, blocked, or negated wording only.
  - Public wording says `validation_status()` is a diagnostic helper only.
  - Public wording does not claim checks are run, fitting is available,
    validation rows are covered, ASReml parity, GPU speedup, or production
    sparse fitting.
- Remote checks for commit `a52337a`:
  - GitHub Actions R-CMD-check `27462165978`: passed in 1m38s.
  - GitHub Actions pkgdown `27462165981`: passed in 1m42s.
  - GitHub Pages build/deploy `27462200373`: passed; Node.js 20 deprecation
    warning is from the Pages action stack, not this package code.

## 2026-06-13 marker/QTL/eQTL extractor contract

- Goal: reserve user-facing marker, QTL, GWAS, and eQTL output extractor names
  without implying model fitting support.
- Active lenses: Jason, Fisher, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `marker_effects()`, `marker_variance_explained()`, `qtl_table()`,
    `gwas_table()`, `eqtl_table()`, and `lod_scores()`.
  - Each extractor is an S3 generic.
  - `hsquared_fit` methods return matching future result payload fields.
  - Default methods error clearly that marker-scan, QTL, GWAS, and eQTL models
    are not fitted yet.
  - Added tests, roxygen docs, pkgdown reference entry, README/model-status
    wording, capability status, validation debt, public claims, NEWS, and board
    updates.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: passed with `32 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::document()"`
  - Result: completed; wrote `NAMESPACE` and `marker_extractors.Rd`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `306 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "qtl_table\\(\\).*fit|gwas_table\\(\\).*fit|eqtl_table\\(\\).*fit|marker_effects\\(\\).*fit|marker-scan.*implemented|GWAS.*implemented|eQTL.*implemented|QTL.*implemented|supports QTL|supports eQTL|supports genomic" README.md R man tests vignettes docs/design docs/dev-log NEWS.md _pkgdown.yml`.
  - Result: hits were planned, blocked, or negated wording only.
  - Public wording says output extractor vocabulary only.
  - Public wording does not claim marker scanning, QTL, GWAS, eQTL, genomic
    fitting, or generated result tables.
- Remote checks for commit `ab5d5dd`:
  - GitHub Actions R-CMD-check `27462369055`: passed in 1m51s.
  - GitHub Actions pkgdown `27462369052`: passed in 1m40s.
  - GitHub Pages build/deploy `27462402877`: passed.

## 2026-06-13 supplied-variance Henderson MME bridge target

- Goal: expose an explicit opt-in R-to-Julia bridge target for
  supplied-variance Henderson MME validation.
- Active lenses: Hopper, Lovelace, Henderson, Fisher, Rose, Grace.
- Spawned subagents: none.
- Skills used:
  - `bridge-contract-review`: kept the target under `engine_control` and mapped
    Julia result fields back to the R S3 object contract.
  - `engine-contract-review`: kept the payload within the v0.1 animal-model
    contract and avoided log-likelihood or optimizer claims.
- Implementation evidence:
  - Added `engine_control$target` validation for `"fit_animal_model"` and
    `"henderson_mme"`.
  - Added required `engine_control$variance_components` validation for
    `target = "henderson_mme"`.
  - Added `hs_fit_julia_henderson_mme_payload()`.
  - Added an R normalizer for the Julia `henderson_mme()` result shape.
  - `hsquared()` now dispatches to `henderson_mme()` only when explicitly
    requested through the experimental Julia engine.
  - Added live tests against the existing Henderson MME validation fixture.
  - Updated README, model-status article, v0.1 contract, engine contract,
    capability status, validation debt, public claims, NEWS, roxygen docs, and
    coordination board.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'julia-bridge|phase0-api')"`
  - Result: docs updated, formatting completed, focused tests passed with
    `111 pass`, `0 fail`, `0 warnings`, and `0 skips`; live Julia bridge
    activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `327 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note was
    `unable to verify current time` from timestamp verification.
  - `Rscript -e "devtools::check()"`
  - Rerun result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording sweep:
  - Overclaim scan:
    `rg -n "henderson_mme.*estimate|henderson_mme.*logLik|supplied-variance.*log-likelihood|general animal-model support|production sparse fitting|AI-REML|ASReml parity|fit.*Mrode|optimizer" README.md R man tests vignettes docs/design docs/dev-log NEWS.md`.
  - Result: hits were planned, blocked, negated, or the intended
    `optimizer_status = "not_run"` diagnostic.
  - Public wording says supplied-variance validation bridge target only.
  - Public wording does not claim variance-component estimation, log-likelihood
    support, AI-REML, Mrode fitted-output validation, ASReml parity, or
    production sparse fitting.
- Remote checks for commit `99d974a`:
  - GitHub Actions R-CMD-check `27462704120`: passed in 1m51s.
  - GitHub Actions pkgdown `27462704121`: passed.
  - GitHub Pages build/deploy `27462736392`: passed.

## 2026-06-13 fit diagnostics extractor

- Goal: add a conservative `fit_diagnostics()` extractor for `hsquared_fit`
  objects so users and developers can inspect engine, method, target,
  convergence, optimizer status, iterations, log-likelihood metadata, and
  dense-validation-path flags without refitting or implying production support.
- Active lenses: Emmy, Hopper, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Sibling scout:
  - Checked local `drmTMB`, `gllvmTMB`, `GLLVM.jl`, and `DRM.jl` fit-summary
    and post-fit patterns.
  - Recorded decision in
    `docs/dev-log/scout/2026-06-13-fit-diagnostics-sibling-scout.md`.
- Implementation evidence:
  - Added `fit_diagnostics()` generic, default method, `hsquared_fit` method,
    and `print.hs_fit_diagnostics()`.
  - Added scalar formatting for result diagnostics while preserving extra Julia
    payload diagnostics such as `gradient_norm`.
  - Added tests for the extractor, default error, and print method.
  - Updated README, NEWS, model-status article, public claims register,
    capability status, roxygen docs, and pkgdown reference index.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object|julia-bridge|phase0-api')"`
  - Result: docs updated, formatting completed, focused tests passed with
    `171 pass`, `0 fail`, `0 warnings`, and `0 skips`; live Julia bridge
    activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `408 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - First run result: `0 errors | 0 warnings | 1 note`; note was
    `unable to verify current time`.
  - `Rscript -e "devtools::check()"`
  - Rerun result: `0 errors | 0 warnings | 0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording boundary:
  - `fit_diagnostics()` is documented as an inspection helper over existing
    result payloads.
  - No public wording claims new model-fitting support, production sparse
    reliability, ASReml parity, or GPU/backend execution.
- Remote checks for commit `908288d`:
  - GitHub Actions R-CMD-check `27465212098`: passed in 1m30s.
  - GitHub Actions pkgdown `27465212092`: passed.
  - GitHub Pages build/deploy `27465247244`: passed.
  - Pages emitted the upstream Node 20 actions deprecation annotation for
    `actions/checkout@v4` and `actions/upload-artifact@v4`; package checks and
    deployment succeeded.

## 2026-06-13 coef/nobs S3 fit methods

- Goal: make `hsquared_fit` objects behave a little more like ordinary R fit
  objects by adding `coef()` as a fixed-effect alias and `nobs()` as an
  observation-count extractor.
- Active lenses: Emmy, Pat, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added `coef.hsquared_fit()` delegating to `fixef()`.
  - Added `nobs.hsquared_fit()` using `result$nobs` with a response-payload
    fallback.
  - Added tests for `coef()`, `nobs()`, fallback behavior, and missing
    observation metadata.
  - Added `importFrom(stats, nobs)` through roxygen after `R CMD check` caught
    the missing namespace generic during clean namespace loading.
  - Updated README, NEWS, model-status article, capability status, and public
    claims register.
- Local checks:
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`
  - Result: docs updated, formatting completed, focused tests passed with
    `58 pass`, `0 fail`, `0 warnings`, and `0 skips`.
  - `Rscript -e "devtools::test()" && Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()" && Rscript -e "devtools::check()"`
  - Result before import fix: full tests passed with `412 pass`; pkgdown had
    `No problems found`; `devtools::check()` failed with `3 warnings` and
    `2 notes` because `nobs` was not imported for namespace S3 registration.
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')" && Rscript -e "devtools::check()"`
  - Result after import fix: focused tests passed with `58 pass`; package check
    passed with `0 errors`, `0 warnings`, and `0 notes`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `git diff --check`
  - Result: clean.
- Rose wording boundary:
  - `coef()` and `nobs()` are S3 ergonomics over existing payload fields.
  - No public wording claims new fitting, variance-component estimation,
    production sparse PEV/reliability, or comparator parity.
- Remote checks for commit `64b6c89`:
  - GitHub Actions R-CMD-check `27465482460`: passed in 1m31s.
  - GitHub Actions pkgdown `27465482452`: passed.
  - GitHub Pages build/deploy `27465520405`: passed.
  - Pages emitted the upstream Node 20 actions deprecation annotation for
    `actions/checkout@v4` and `actions/upload-artifact@v4`; package checks and
    deployment succeeded.

## 2026-06-13 Henderson MME bridge PEV/reliability parity

- Goal: let the supplied-variance Henderson MME bridge target attach dense
  validation-path PEV and reliability when the sibling `HSquared.jl` checkout
  exposes applicable `prediction_error_variance()` and `reliability()` methods.
- Active lenses: Hopper, Lovelace, Henderson, Fisher, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added an `applicable()`-guarded JuliaCall enrichment step for
    `target = "henderson_mme"`.
  - Added optional `prediction_error_variance` and `reliability` normalization
    to `hs_normalize_julia_henderson_mme_result()`.
  - Added a mocked normalizer test and live bridge assertions for local
    `HSquared.jl` checkouts that expose the MME extractor methods.
  - Updated README, model-status article, v0.1 contract, engine contract,
    validation canon, capability status, validation debt, public claims, NEWS,
    and `validation_status()` wording.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'julia-bridge|phase0-api')"`
  - Result: passed with `117 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `333 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`

## 2026-06-13 sparse REML likelihood validation atom

- Goal: mirror the Julia lane's sparse REML identity evidence in the R repo by
  adding a tiny supplied-variance fixture that compares Julia dense REML,
  sparse REML, and ML hand-check targets through the existing R bridge setup.
- Active lenses: Curie, Gauss, Fisher, Hopper, Rose, Grace.
- Spawned subagents: none.
- Implementation evidence:
  - Added internal `hs_reml_likelihood_validation_fixture()`.
  - Added a pure R fixture test for payload IDs, all-founder parent indices,
    intercept-only `X`, identity `Z`, identity `Ainv`, beta target, and
    closed-form ML/REML log-likelihood values.
  - Added an optional live JuliaCall test that constructs the sibling
    `HSquared.jl` `animal_model_spec()`, calls `gaussian_loglik()` for ML and
    REML, calls `sparse_reml_loglik()`, and checks sparse REML equals dense
    REML at supplied variance components.
  - Updated `validation_status()`, README, NEWS, model-status article,
    capability status, validation debt register, and public claims register.
- Local checks:
  - `Rscript -e "devtools::test(filter = 'validation-fixtures|phase0-api')"`
  - Initial result: live Julia bridge executed, but two R-only expectations
    failed because they compared incidental matrix attributes and dimensions.
  - Fix: compare numeric values and matrix shape directly.
  - `Rscript -e "devtools::test(filter = 'validation-fixtures|phase0-api')"`
  - Result after fix: passed with `93 pass`, `0 fail`, `0 warnings`, and
    `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test()"`
  - Result: docs updated, formatting completed, full tests passed with
    `428 pass`, `0 fail`, `0 warnings`, and `0 skips`; live Julia bridge
    activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt and `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors`, `0 warnings`, and `0 notes`.
  - `git diff --check`
  - Result: clean.
- Rose wording boundary:
  - Allowed: tiny supplied-variance likelihood identity, dense-vs-sparse REML
    agreement, ML and REML hand-check targets.
  - Blocked: sparse optimizer, AI-REML, fitted Mrode output validation,
    production sparse fitting, general animal-model support, ASReml parity,
    GPU execution, or speedup.
- Remote checks for commit `49ce975`:
  - GitHub Actions R-CMD-check `27465915349`: passed in 1m38s.
  - GitHub Actions pkgdown `27465915342`: passed in 1m26s.
  - GitHub Pages build/deploy `27465944575`: passed.

## 2026-06-13 mission-control pkgdown article

- Goal: add an R-facing dashboard article matching the twin operating style
  without implying new modelling support.
- Active lenses: Ada, Shannon, Boole, Hopper, Emmy, Grace, Rose, Pat.
- Spawned subagents: none.
- Implementation evidence:
  - Added `vignettes/articles/mission-control.Rmd`.
  - Added the article to `_pkgdown.yml`.
  - Linked the dashboard from README and NEWS.
- Local checks:
  - `git diff --check`: clean.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
    articles rebuilt, including `articles/mission-control.html`; pkgdown
    reported `No problems found.`
  - Rendered article spot-check:
    `rg -n "Mission control|One R interface|&lt;article|<pre><code>&lt;article|Blocked Claims|Julia Engine Boundary" pkgdown-site/articles/mission-control.html`
    found the page title, menu link, dashboard content, and no escaped
    dashboard article block.
  - `Rscript -e "devtools::check()"`: passed with `0 errors`, `0 warnings`,
    and `0 notes`.
- Boundary:
  - Documentation dashboard only.
  - No new fitting, bridge, validation, backend, GPU, QTL/eQTL, GLLVM, or
    performance claim.
- Remote checks for commit `aca35df`:
  - GitHub Actions R-CMD-check `27466195166`: passed in 1m48s.
  - GitHub Actions pkgdown `27466195171`: passed in 1m54s.
  - GitHub Pages build/deploy `27466236586`: passed.
  - Pages emitted the upstream Node 20 actions deprecation annotation for
    `actions/checkout@v4` and `actions/upload-artifact@v4`; package checks and
    deployment succeeded.
- Live docs:
  - `https://itchyshin.github.io/hsquared/articles/mission-control.html`:
    HTTP 200 and contains the mission-control page title, Articles menu link,
    and blocked-claims dashboard section.
  - `https://itchyshin.github.io/HSquared.jl/dev/mission-control.html`:
    HTTP 200 and contains the Julia mission-control page title and
    blocked-claims dashboard section.

## 2026-06-13 Mrode-style supplied-variance fixture

- Goal: mirror the Julia twin's Mrode-style supplied-variance validation
  fixture on the R side without claiming general fitting, variance-component
  estimation, or ASReml parity.
- Active lenses: Ada, Shannon, Jason, Hopper, Lovelace, Curie, Fisher, Mrode,
  Rose, Grace.
- Spawned subagents: none.
- Scout evidence:
  - `HSquared.jl/test/runtests.jl` Phase 1 Mrode-style fixture.
  - `HSquared.jl/src/likelihood.jl` likelihood/MME boundaries.
  - `gllvmTMB/R/julia-bridge.R` R-to-Julia result-shape discipline.
  - `DRM.jl/src/comparison.jl` REML comparability guardrail.
- Implementation evidence:
  - Added internal `hs_mrode_supplied_variance_validation_fixture()`.
  - Added independent R reference helpers for MME PEV, reliability, and dense
    Gaussian ML/REML log-likelihood at supplied variance components.
  - Added pure R and optional live JuliaCall tests for Ainv, fixed effects,
    EBVs, fitted values, PEV, reliability, h2, ML logLik, and dense/sparse REML
    logLik.
  - Updated `validation_status()`, README, NEWS, model-status article,
    mission-control article, validation canon, capability status, validation
    debt register, and public claims register.
- Local checks:
  - `air format . && Rscript -e "devtools::test(filter = 'validation-fixtures|mrode-validation|phase0-api|julia-bridge')"`
  - Initial result: two failures from incidental row names inherited from named
    PEV/reliability vectors.
  - Fix: strip incidental names in the R reference helper.
  - Result after fix: passed with `192 pass`, `0 fail`, `0 warnings`, and
    `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "devtools::test()"`
  - Result: passed with `460 pass`, `0 fail`, `0 warnings`, and `0 skips`;
    live Julia bridge activated sibling `HSquared.jl`.
  - `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - Result: articles rebuilt, including `mission-control.html` and
    `model-status.html`; pkgdown reported `No problems found.`
  - `Rscript -e "devtools::check()"`
  - Result: `0 errors`, `0 warnings`, and `0 notes`.
  - `git diff --check`
  - Result: clean.
  - Rendered article spot-check:
    `rg -n "Mrode-style supplied-variance|estimated-variance Mrode|full Mrode" pkgdown-site/articles/model-status.html pkgdown-site/articles/mission-control.html`
  - Result: found the new model-status and mission-control wording plus the
    blocked estimated-variance Mrode claim.
  - Targeted Rose search:
    `rg -n "Mrode validation complete|animal-model fitting works|REML estimation works|ASReml parity is established|variance-component estimation is implemented|GPU execution is available|QTL/eQTL.*available" README.md NEWS.md docs/design vignettes || true`
  - Result: no matches.
- Rose wording boundary:
  - Allowed: Mrode-style supplied-variance validation fixture with pinned
    Ainv, fixed effects, EBVs, fitted values, PEV, reliability, h2, ML logLik,
    and dense/sparse REML logLik.
  - Blocked: general animal-model fitting, variance-component estimation,
    AI-REML, full Mrode fitted-output validation, ASReml parity, production
    sparse reliability, GPU execution, or speedup.
- Closeout verification (Claude, R lane), takeover of the sister-thread slice:
  - Independent pure-R re-derivation (pedigree -> A -> Ainv -> Henderson MME
    plus marginal-V ML/REML) reproduced every pinned value (Ainv, fixed
    effects, EBVs, fitted, PEV, reliability, h2, ML logLik, dense/sparse REML
    logLik) to machine precision: max abs diff approximately 1.8e-14;
    h2/ML/REML matched exactly.
  - `Rscript -e "rcmdcheck::rcmdcheck(args=c('--no-manual','--no-build-vignettes'))"`:
    `0 errors | 0 warnings | 0 notes`.
  - `air format --check .` and `git diff --check`: clean.
- Remote checks for commit `a437feb`:
  - GitHub Actions R-CMD-check `27467574922`: passed.
  - GitHub Actions pkgdown `27467574904`: passed.
  - GitHub Pages build/deploy `27467612204`: passed.

## 2026-06-13 Claude agent roster and readiness layer

- Goal: stand up the Claude-side operating layer for the R lane without forking
  the Codex instruction set: convert the 21 `.codex/agents/*.toml` review lenses
  to `.claude/agents/*.md`, add `CLAUDE.md` (imports `AGENTS.md`), and symlink
  the 11 `.agents/skills` into `.claude/skills`.
- Active lenses: Ada, Shannon, Grace, Rose. Spawned subagents: none (mechanical
  conversion done solo).
- Implementation evidence:
  - 21 `.claude/agents/*.md` generated from the TOML via tomllib; frontmatter
    `name` (kebab stem) + `description` preserved; `model_reasoning_effort=high`
    -> `model: opus` (11 opus / 10 inherit), else inherit; body =
    `developer_instructions`.
  - `CLAUDE.md` imports `@AGENTS.md` plus Claude-specific notes (lane boundary,
    rehydrate loop, lenses in `.claude/agents`, skills in `.claude/skills`,
    local-checks-over-CI, commit convention).
  - `.claude/skills/<name>` -> `../../.agents/skills/<name>` for all 11 skills
    (all resolve to a `SKILL.md`).
  - `.Rbuildignore` extended with `^\.claude$` and `^CLAUDE\.md$` so the new
    top-level files do not trigger an R CMD check note.
- Local checks:
  - `Rscript -e "rcmdcheck::rcmdcheck(args=c('--no-manual','--no-build-vignettes'))"`:
    `0 errors | 0 warnings | 0 notes` (confirms `.Rbuildignore` excludes the new
    files; no non-standard top-level files note).
  - `.claude/agents`: 21 files. `.claude/skills`: 11 resolving symlinks.
- Boundary: tooling/readiness only; no package code, R API, claims, or bridge
  contract changed. This is the R-lane twin of the Julia lane's agent roster
  (separate repo, no lane collision).
- Remote checks for commit `b43b682`:
  - GitHub Actions R-CMD-check `27467772941`: passed.
  - GitHub Actions pkgdown `27467772929`: passed.
  - GitHub Pages build/deploy `27467811302`: passed.

## 2026-06-13 Experimental sparse REML estimator bridge (B2)

- Goal: surface the twin's Julia-owned `HSquared.fit_sparse_reml()` REML-only
  sparse optimizer through a fenced, opt-in R bridge target
  `engine_control = list(target = "sparse_reml")`; default `hsquared()` still
  validates-and-stops.
- Active lenses: Jason, Hopper, Lovelace, Gauss, Fisher, Curie, Rose. Spawned
  subagents: B2 scout (Jason/Hopper/Curie) and B2 review (Hopper/Fisher/Rose) via
  Workflow.
- Reuse (license-clean): mirrored hsquared's own MIT `hs_fit_julia_payload()` /
  `henderson_mme` pattern and reused `hs_normalize_julia_result()`; adapted
  R-Julia bridge idioms (patterns only) from GPL-3 `gllvmTMB`/`drmTMB`
  `julia-bridge.R` — no GPL code copied into MIT hsquared.
- Implementation:
  - `hs_validate_julia_target()` now accepts `"sparse_reml"`.
  - new `hs_validate_iterations()` and `hs_fit_julia_sparse_reml_payload()`
    (builds a REML spec, calls `fit_sparse_reml(spec; initial, iterations)`,
    reuses the default normalizer, tags `spec$target = "sparse_reml"`).
  - dispatch branch in `hsquared.R`; `hs_control()` doc updated.
- Local checks:
  - `NOT_CRAN=true` `testthat::test_dir(filter = "julia-bridge")`: pass; the live
    sparse-REML test executed against the sibling `HSquared.jl`.
  - `devtools::test()` full: `473 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active.
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .` and `git diff --check`: clean.
- Multi-lens review (Workflow): Hopper (bridge parity), Fisher (claim/estimand),
  Rose (claim-vs-evidence) — all returned `clean`, no blocking/required findings.
- Boundary: experimental, opt-in, REML-only, Julia-owned estimator that R only
  surfaces; gated on the twin's green `validation_status()`; not the default, not
  variance-component estimation via the public R interface, not production sparse
  fitting, AI-REML, fitted-Mrode, or ASReml parity.
- Remote checks for commit `6add692` (+ `2dd436b`):
  - GitHub Actions R-CMD-check `27468442096`: passed.
  - GitHub Actions pkgdown `27468442094`: passed.
  - GitHub Pages build/deploy `27468475645`: passed.

## 2026-06-13 Estimated-vs-supplied variance provenance (B3)

- Goal: distinguish an estimated-variance fit from a supplied-variance fit. The
  sparse-REML path tags `variance_components = "estimated_sparse_reml"` (Henderson
  MME stays `"supplied"`); `fit_diagnostics()` surfaces `variance_components_source`.
  New `validation_status()` row "experimental sparse REML estimator (opt-in)"
  (Phase 1, partial); table now 13 rows.
- Active lenses: Emmy, Fisher, Rose, Pat. Spawned subagents: none.
- Local checks:
  - `devtools::test()` full: `476 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (provenance assertions ran).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Boundary: provenance labelling only; not an accuracy, recovery,
  production-fitting, or comparator claim.
- Remote checks for commit `503734e`:
  - GitHub Actions R-CMD-check `27468654232`: passed.
  - GitHub Actions pkgdown `27468654248`: passed.
  - GitHub Pages build/deploy `27468689299`: passed.

## 2026-06-13 Sparse REML estimate-recovery validation fixture (B4)

- Goal: first honest behavioural evidence for the opt-in sparse REML estimator
  without the comparator estimand trap — a start-independence check (same REML
  optimum from two different starts), not DGP/supplied-truth recovery.
- Active lenses: Curie, Gauss, Fisher, Mrode, Jason, Rose. Spawned subagents:
  none (B2 scout already covered sister comparator discipline).
- Local checks:
  - `devtools::test()` full: `481 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (two-start test ran).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Boundary: start-independence only; not DGP recovery, supplied-truth recovery,
  external-comparator parity, AI-REML, or production sparse fitting.
- Remote checks for commit `8a2009a`:
  - GitHub Actions R-CMD-check `27468842532`: passed.
  - GitHub Actions pkgdown `27468842514`: passed.
  - GitHub Pages build/deploy `27468886120`: passed.

## 2026-06-13 Sparse REML bridge contract memory (B5)

- Goal: record the sparse-REML bridge contract in `03-engine-contract.md`,
  closing the Phase B surfacing arc (B2 path -> B3 provenance -> B4
  estimate-recovery -> B5 contract memory).
- Active lenses: Shannon, Hopper, Lovelace, Rose, Pat. Spawned subagents: none.
- Local checks: `git diff --check` clean (documentation-only, coordinator lane).
- Boundary: documents the contract B2-B4 implement; no new capability or claim.
- Remote checks for commit `9e12821`:
  - GitHub Actions R-CMD-check `27468956169`: passed.
  - GitHub Actions pkgdown `27468956186`: passed.
  - GitHub Pages build/deploy `27468994647`: passed.

## 2026-06-13 Sparse-vs-dense REML optimizer agreement (B6, follow-on)

- Goal: cross-check the sparse REML optimizer against the dense REML optimizer
  on the same Mrode fixture (same estimand, different linear algebra).
- Active lenses: Curie, Gauss, Fisher, Hopper, Rose. Spawned subagents: none.
- Local checks:
  - `devtools::test()` full: `486 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (both optimizers ran and agreed).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Finding: sparse and dense REML optimizers reach the same REML optimum (matching
  logLik and variance estimates) on the Mrode fixture.
- Boundary: internal cross-check only; not an external comparator, DGP recovery,
  or production-fitting claim.
- Remote checks for commit `f84b959`:
  - GitHub Actions R-CMD-check `27469342270`: passed.
  - GitHub Actions pkgdown `27469342263`: passed.
  - GitHub Pages build/deploy `27469378298`: passed.

## 2026-06-13 Independent pure-R REML optimizer cross-check (B7, follow-on)

- Goal: a fully independent (non-Julia) check on the surfaced sparse REML
  estimator via a pure-R `optim()` over the dense REML objective (a clean
  external REML comparator is not installed; MCMCglmm is Bayesian, excluded).
- Active lenses: Curie, Gauss, Fisher, Rose. Spawned subagents: none.
- Local checks:
  - `devtools::test()` full: `490 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge active (pure-R optimum and Julia estimate agreed).
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .`: clean.
- Finding: Julia `fit_sparse_reml()` estimate matches an independent pure-R REML
  optimum on the Mrode fixture. The pure-R optimizer test runs on CI (no Julia).
- Boundary: independent same-estimand cross-check only; not an external
  comparator, DGP recovery, or production-fitting claim.
- Remote checks for commit `1d576c8`:
  - GitHub Actions R-CMD-check `27469532263`: passed.
  - GitHub Actions pkgdown `27469532270`: passed.
  - GitHub Pages build/deploy `27469579694`: passed.

## 2026-06-13 External REML comparator: pedigreemm (B9, follow-on)

- Goal: first external comparator — `pedigreemm` (lme4-based REML animal model)
  vs hsquared's REML solution on a deterministic replicated dataset.
- Active lenses: Jason, Fisher, Curie, Gauss, Rose. Spawned subagents: none.
- Finding: hsquared/the pure-R reference reach the true REML optimum (verified by
  multi-start + grid on the common verified objective); `pedigreemm` lands
  slightly worse and cannot fit the saturated Mrode fixture. Honest claim:
  hsquared is at least as good as `pedigreemm` by REML logLik (not a tight
  point-estimate match; not ASReml parity; not DGP recovery).
- Local checks:
  - `devtools::test()` full: `492 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia + pedigreemm.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: `0 errors`,
    `0 warnings`, `1 note` (benign new-submission/dev-version note).
- CI break + fix: first push `9b2af4e` FAILED R-CMD-check (`27470213036`) with
  `unstated dependencies in 'tests' ... WARNING: '::' import not declared from
  'lme4'` under `--as-cran` (workflow `error-on: "warning"`). My earlier local
  gate omitted `--as-cran` and missed it. Fix `dcef460`: declared `lme4` in
  Suggests; re-verified with `--as-cran` (0 warnings). LESSON: gate with
  `--as-cran` locally to match CI.
- Remote checks for commit `dcef460`:
  - GitHub Actions R-CMD-check `27470343823`: passed.
  - GitHub Actions pkgdown `27470343838`: passed.
  - GitHub Pages build/deploy `27470387166`: passed.

## 2026-06-13 User-docs honesty pass for the sparse REML path (B8)

- Goal: keep user-facing docs in sync with capability — surface the opt-in
  `target = "sparse_reml"` estimator path in the model-status article and refresh
  the vision "Current Status" (Pat/Rose lens).
- Active lenses: Pat, Rose, Grace. Spawned subagents: none.
- Local checks:
  - `pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()`:
    `model-status.html` rebuilt; "No problems found."
  - `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
  - `air format .` + `git diff --check`: clean.
- Boundary: docs match capability; no new claim; default still validates-and-stops.
- Remote checks for commit `1e89593`:
  - GitHub Actions R-CMD-check `27469723178`: passed.
  - GitHub Actions pkgdown `27469723172`: passed.
  - GitHub Pages build/deploy `27469763549`: passed.

## 2026-06-13 Opt-in AI-REML estimator bridge (target = "ai_reml")

- Goal: surface the twin's average-information REML estimator
  (`HSquared.fit_ai_reml`) through R behind the existing opt-in fence, mirroring
  `target = "sparse_reml"`. Default still validates-and-stops; no new public
  claim. Serves the standing performance directive (fastest REML/ML).
- Active lenses: Hopper, Lovelace, Gauss, Fisher, Curie, Rose. Spawned
  subagents: none.
- TDD: RED (target rejected; `hs_fit_julia_ai_reml_payload` absent) → GREEN
  (four minimal edits: bridge fn, target validator, dispatch, control docs).
- Local checks:
  - `devtools::test()` full with the live Julia bridge (juliaup on PATH,
    `NOT_CRAN=true`): 508 pass, 0 fail, 0 warnings, 0 skips; the AI-REML live
    tests ran and passed.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign new-submission/dev-version). The first `--as-cran`
    run caught a stale `validation_status()` row-count assertion (13 → 14), fixed
    before commit. Lesson reaffirmed: gate with `--as-cran` locally to match CI.
  - `air format .`: clean.
- Finding: AI-REML and the sparse NelderMead REML optimizer reach the same REML
  optimum on the Mrode fixture (logLik diff 1.3e-8, variance components 2.7e-4).
- Boundary: experimental opt-in path; estimator is Julia-owned and R surfaces
  it; gated on twin `validation_status()`; not default/production/ASReml/DGP.
- Remote checks for commit `eba8711`:
  - GitHub Actions R-CMD-check `27473026734`: passed.
  - GitHub Actions pkgdown `27473026735`: passed.
  - GitHub Pages build/deploy `27473061867`: passed.

## 2026-06-13 Honesty pass + v0.1 promotion predicate

- Goal (autonomous run, user away): finish the packages honestly. A 6-agent
  audit found the v0.1 fit gate genuinely closed and not openable autonomously;
  the safe high-value work was an honesty pass + binding the gate. Edits made,
  then a 4-agent adversarial review (`safe_to_commit: false`) returned three
  must-fixes + medium predicate-rigor gaps, all applied before commit.
- Active lenses: Rose, Pat, Fisher (review workflow); Ada/Shannon. Spawned
  subagents: yes — workflows `twin-finish-audit` (6) and `honesty-slice-verify`
  (4); also `gate-source-scout` (4) for the maintainer decision menu.
- Files: README.md, vignettes/articles/mission-control.Rmd,
  vignettes/articles/model-status.Rmd, docs/design/01-v0.1-contract.md
  (V0.1 Promotion Predicate + Uncertainty Scope).
- Local checks:
  - `pkgdown::build_articles(lazy = FALSE)` + `pkgdown::check_pkgdown()`:
    rebuilt; "No problems found."
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign new-submission/dev-version).
  - Docs-only; no R code changed.
- Twin-lane finding (verified, NOT fixed here — Julia lane owns it): the twin
  `V1-AI-REML` evidence string (`HSquared.jl/src/validation_status.jl:97`) cites
  a "250-animal simulation / observed-information ratio ~0.99" with no backing
  test (grep: `250` only in that string; real test is an 8-animal
  optimizer-agreement fixture). Must be fixed before any promotion cites that
  row. A GitHub issue on the twin repo was denied by the permission classifier;
  recorded on the coordination board + after-task report for the maintainer.
- Remote checks for commit `0565948`:
  - GitHub Actions R-CMD-check `27473795597`: passed.
  - GitHub Actions pkgdown `27473795603`: passed.
  - GitHub Pages build/deploy `27473836594`: passed.

## 2026-06-13 Gryphon external published-REML recovery atom

- Goal: first externally-anchored REML-recovery atom in the R lane —
  hsquared's pure-R REML reference recovers the published gryphon variance
  components/h2 (Wilson et al. 2010), optionally agreeing with sommer. Built
  under the standing finish-directive; mirrors the pedigreemm precedent.
- Active lenses: Curie, Fisher, Jason, Rose. Spawned subagents: none (built on
  scout `wo62dphp0` + local verification).
- Finding (triple agreement): published VA=3.3954/VE=3.8286/h2=0.470 ↔ sommer
  ↔ hsquared pure-R reference VA=3.3953/VE=3.8287/h2=0.4700 (~4 s).
- Files: `R/validation-fixtures.R` (`hs_gryphon_published_reml()`),
  `tests/testthat/test-validation-fixtures.R` (skip-guarded test),
  `DESCRIPTION` (Suggests: enhancer, sommer), `R/validation-status.R` +
  `test-phase0-api.R` (15 rows), capability-status + validation-debt registers.
- Local checks:
  - `devtools::test()` (NOT_CRAN): the gryphon test ran and passed.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign).
  - `air format .`: clean.
- Boundary: external-anchor cross-check of the R reference optimizer only; not
  the production fit path; does not satisfy the twin `V1-MRODE-FIT` gate;
  gryphon is teaching/simulated data. Autonomous-under-delegation; maintainer
  may re-point the anchor.
- Remote checks for commit `952075b`:
  - GitHub Actions R-CMD-check `27474821889`: passed (gryphon test ran on CI
    with sommer/enhancer installed).
  - GitHub Actions pkgdown `27474821893`: passed.
  - GitHub Pages build/deploy `27474859398`: passed.

## 2026-06-13 Known-truth DGP variance-component recovery study

- Goal: fill the v0.1 promotion-predicate item-3 gap (known-truth recovery, not
  optimizer reproducibility). ADEMP study (Morris 2019; Williams 2024):
  simulate a univariate Gaussian animal model with known VC over a clean
  pedigree, recover with the engine (ai_reml) + the pure-R reference.
- Active lenses: Curie, Fisher, Gauss, Rose. Spawned subagents: none (used the
  simulation-design skill).
- Result (n=420, 120 engine reps, 100% converged): bias s2a=-0.0000 (MCSE
  0.0090), s2e=+0.0057 (MCSE 0.0067), h2=-0.0049 (MCSE 0.0073) — 0 within
  bias +/- 2*MCSE for all three; EBV accuracy 0.737; engine matches the pure-R
  reference to machine precision (max |h2 diff| 0.0000 on shared reps).
- Files: `data-raw/dgp-recovery-study.R` (full study + ADEMP design, .Rbuildignore'd),
  `tests/testthat/helper-simulation.R`, skip-guarded pure-R regression test in
  `test-validation-fixtures.R`, `R/validation-status.R` (16 rows),
  capability-status + validation-debt registers, `test-phase0-api.R`.
- Local checks:
  - `devtools::test()` (NOT_CRAN): the pure-R regression test ran and passed.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
    0 warnings, 1 note (benign).
  - `air format .`: clean.
- Boundary: R-lane recovery evidence via the read-only bridge; does NOT flip the
  twin estimator gate row; single h2=0.4 setting; no boundary/interval/
  production-robustness or default-fit claim.
- Remote checks for commit `874bf07`:
  - GitHub Actions R-CMD-check `27475342941`: passed (DGP test ran on CI with nadiv).
  - GitHub Actions pkgdown `27475342963`: passed.
  - GitHub Pages build/deploy `27475387456`: passed.

## 2026-06-13 DGP generality grid + v0.1 identifiability statement

- Grid (`c15345c`): extended the recovery study with an h2 grid (0.1/0.2/0.4/0.6,
  100 engine reps/cell). Near-unbiased across the interior (0.2/0.4/0.6); the
  near-boundary cell (h2=0.1) shows mild upward bias, 94% convergence, and 5%
  boundary pinning (expected; informs predicate item 4). Updated the recovery
  atom evidence + `data-raw/dgp-recovery-study.R`. `rcmdcheck(--as-cran)`: 0/0/1.
  - Remote: R-CMD-check `27475621343`, Pages `27475670567`: passed.
- Identifiability (`564448a`): added the v0.1 estimable-quantities / identifiability
  statement to `01-v0.1-contract.md` (predicate item 4 docs half; textbook-grounded
  proposal). Docs only.
  - Remote: R-CMD-check `27475739750`, Pages `27475776217`: passed.

## 2026-06-13 Boundary/identifiability flag (predicate item 4 R-half)

- Goal: implement the R-side surfacing half of promotion-predicate item 4 -
  `fit_diagnostics()` + `summary()` flag a variance-component boundary so a
  boundary h2 is not read as ordinary. Engine boundary-stability stays twin work.
- Active lenses: Fisher, Emmy, Rose. Spawned subagents: none.
- Files: `R/extractors.R` (`hs_fit_boundary_flag()` + `at_boundary` row),
  `R/fit-object.R` (summary note), `test-fit-object.R` (metric set + detection
  test), `01-v0.1-contract.md` (predicate item 4), `capability-status.md`.
- Local checks: `devtools::test()` test-fit-object pass; `rcmdcheck(--as-cran)`
  0/0/1 (benign); `air format .` clean.
- Boundary: a diagnostic, not a fitting/default claim; capability stays partial.
- Remote checks for commit `c53f927`:
  - GitHub Actions R-CMD-check `27476005389`: passed.
  - GitHub Actions pkgdown: passed.
  - GitHub Pages build/deploy `27476045834`: passed.

## 2026-06-13 Fixed-effect DGP recovery (contract model)

- Goal: verify recovery holds for `y ~ x + animal(1|id, pedigree=ped)` (the v0.1
  contract structure with a fixed effect), exercising the multi-column X path.
- Result (100 reps, 100% converged): h2 near-unbiased (bias +0.0014, MCSE
  0.0081), EBV acc 0.74, fixed effect recovered (b_x 0.99 vs 1.0).
- `rcmdcheck(--as-cran)`: 0/0/1 (benign). `air format`: clean.
- Remote checks for commit `fdd8705`:
  - GitHub Actions R-CMD-check `27476335755`: passed.
  - GitHub Actions pkgdown `27476335754`: passed.
  - GitHub Pages build/deploy `27476377904`: passed.

## 2026-06-13 Maintainer v0.1 gate sign-off

- Recorded the maintainer sign-off (gryphon anchor + sommer comparator band +
  DGP thresholds) as binding targets in 01-v0.1-contract.md; tightened the
  gryphon comparator test to the signed-off band (VC ~1-2%, h2 ~0.01-0.02) +
  added an h2-agreement check; updated the gate handoff + board.
- Local checks: `air format` clean; live `test-validation-fixtures.R` (juliaup
  on PATH, NOT_CRAN) pass incl. the tightened gryphon band; `rcmdcheck(--as-cran)`
  0 errors, 0 warnings, 1 note (benign).
- Remote checks for commit `03bd62e`:
  - GitHub Actions R-CMD-check `27476877537`: passed.
  - GitHub Actions pkgdown: passed.
  - GitHub Pages build/deploy `27476923025`: passed.

## 2026-06-13 v0.1 default-fit flip (engine = "fit")

- Goal: flip the default `hsquared()` from validate-and-stop to a real REML fit
  of the v0.1 Gaussian animal model (`fit_ai_reml` through the bridge) and make
  every living public surface honest about it. Predicate SATISFIED + maintainer
  sign-off (2026-06-13); mirrors twin gates (V1-AI-REML covered, V1-MRODE-FIT /
  V1-COMPARATORS covered_external).
- Active lenses: Ada, Shannon, Boole, Fisher, Rose, Pat, Hopper. Spawned
  subagents: 5-agent adversarial honesty audit `wetqf4t9i` (3 lenses clean; 1
  confirmed blocker — `engine = "julia"`/`fit_animal_model` ran ML for
  `REML = FALSE` — fixed by an ML guard + regression test).
- ML is not implemented: `REML = FALSE` is rejected on every estimation path;
  the REML-only optimizers stamp `method = "REML"`. Promoted the default-fit,
  gryphon, and DGP validation_status rows to `covered`; corrected "exact" →
  signed-off band (machine precision reserved for engine-vs-pure-R).
- Files: `R/{hsquared,hs_control,julia-bridge,validation-status,formula-status,
  hsquared-package}.R`, `man/*`, `DESCRIPTION`, `README.md`, `vignettes/*`,
  `docs/design/{00-vision,01-v0.1-contract,06-public-claims-register,
  capability-status,validation-debt-register}.md`,
  `tests/testthat/{test-phase0-api,test-julia-bridge,test-bridge-payload,
  test-hs-data}.R`.
- Local checks: `air format .` clean; `devtools::document()`; full `testthat`
  suite with juliaup on PATH + `NOT_CRAN` + `sommer` + `enhancer` (live default
  fit, gryphon, DGP, sommer all run) — 0 failures, 0 warnings, 0 skipped;
  `rcmdcheck(--as-cran)` 0 errors, 0 warnings, 1 note (benign new-submission);
  both pkgdown articles render.
- Local commit `fd7975e` (flip) + `2437e09` (records), not yet pushed.
- Follow-on honesty sweep (separate commit): corrected the last stale
  "validates-and-stops" / "validation-only" claims in living surfaces that the
  flip should have touched — `ROADMAP.md` (Phase 1 status + frontier framing),
  `NEWS.md` (added the headline flip entry + fixed two now-false bullets),
  `docs/design/03-engine-contract.md`, and
  `vignettes/articles/formula-grammar.Rmd`. Repo-wide grep for stale pre-flip
  phrasing in living surfaces is clean; both edited articles render.
- Twin gate landed: `v01-gate-validation-status` (`100adbe`) fast-forwarded onto
  Julia `main` under maintainer authorization (`94e695b..100adbe`); `main` now
  reads V1-AI-REML covered, V1-MRODE-FIT / V1-COMPARATORS covered_external.
  Coordination issue `HSquared.jl#13` opened and closed. Then pushed the four R
  commits (`cd13551..b07bf58`).
- Remote checks for commit `b07bf58`:
  - GitHub Actions R-CMD-check `27482232390`: passed.
  - GitHub Actions pkgdown `27482232393`: passed.
  - GitHub Pages build/deploy `27482264882`: passed.

## 2026-06-13 Opt-in repeatability (permanent-environment) model (Phase 2)

- Goal: first Phase 2 increment (maintainer-authorised "build & ship opt-in"):
  surface the repeatability model behind an opt-in, experimental fence mirroring
  `sparse_reml`/`ai_reml`. Twin gate `V3-REPEAT-REML` is `partial`, so the R
  surface is honestly experimental — never covered/default/production.
- Active lenses: Ada, Hopper, Boole, Emmy, Curie, Rose, Falconer. Spawned
  subagents: scout `w0hj6t9xq` (cancelled by an interrupt; redone inline) +
  3-agent review `wckuklv5h` (0 blocking, all clean; one should-fix — untested
  `REML = FALSE` rejection — now covered).
- Parser accepts `animal(1 | id) + permanent(1 | id)` (PE effect shares the
  animal `Z`, A2 = I); new opt-in `target = "repeatability"` calls the twin's
  `fit_repeatability_reml`; surfaces 3 variance components + `repeatability()` +
  `permanent_effects()`. Default `engine = "fit"` rejects `permanent()`; REML
  only. `validation_status()` now 17 rows (repeatability `partial`).
- Files: `R/{model-spec,julia-bridge,hsquared,extractors,formula-status,
  validation-status,hs_control}.R`, `NAMESPACE`, `man/*`, `NEWS.md`, `ROADMAP.md`,
  `docs/design/{capability-status,06-public-claims-register}.md`,
  `tests/testthat/{test-repeatability,test-formula-animal,test-phase0-api}.R`.
- Local checks: `air format .`; `devtools::document()`; full `testthat` with
  juliaup + `NOT_CRAN` + sommer + enhancer (live repeatability fit ran) —
  0 failures, 0 warnings, 0 skipped; `rcmdcheck(--as-cran)` 0 errors, 0 warnings,
  1 note (benign).
- Local commit `f408fb2`. Remote checks for `f408fb2`: GitHub Actions
  R-CMD-check `27483238750` **passed**; pkgdown `27483238761` **failed** — the
  two new exports (`repeatability`, `permanent_effects`) were missing from the
  `_pkgdown.yml` reference index (the test suite and `--as-cran` do not catch
  pkgdown-config gaps). Lesson reaffirmed: run `pkgdown::check_pkgdown()` locally
  for slices that add exports.
- Fix (follow-up commit `5ef0c4f`): added both extractors to `_pkgdown.yml` and
  refreshed the stale section description ("…do not fit models yet");
  `pkgdown::check_pkgdown()` reports no problems locally.
- Remote checks for commit `5ef0c4f` (all green):
  - GitHub Actions R-CMD-check `27483306182`: passed.
  - GitHub Actions pkgdown `27483306179`: passed.
  - GitHub Pages build/deploy `27483339408`: passed.

## 2026-06-13 Opt-in common-environment (two-effect) model (Phase 2)

- Goal: second Phase 2 increment — surface the common-environment model (animal
  additive + IID environmental effect) behind an opt-in fence via the twin's
  `fit_two_effect_reml`. Twin gate `V3-TWOEFFECT-REML` is `partial`, so the R
  surface is honestly experimental.
- Active lenses: Ada, Hopper, Boole, Emmy, Curie, Rose, Darwin. Spawned
  subagents: review `wziz2f7mm` (hopper-bridge + rose-honesty, 0 blocking; one
  should-fix + one nit applied).
- Generalised the parser into a shared "second random effect" mechanism;
  `common_env(1 | group)` parsed as an IID environmental effect; new opt-in
  `target = "two_effect"` builds a second `Z2` + identity `Ainv2` and calls
  `fit_two_effect_reml`; surfaces 3 components + `common_env_effects()`.
  `validation_status()` now 18 rows. The v0.1 + repeatability paths are unchanged.
- Files: `R/{model-spec,bridge-payload,julia-bridge,hsquared,extractors,
  formula-status,validation-status,hs_control}.R`, `NAMESPACE`, `man/*`,
  `NEWS.md`, `ROADMAP.md`, `_pkgdown.yml`,
  `docs/design/{capability-status,06-public-claims-register}.md`,
  `tests/testthat/{test-common-env,test-repeatability,test-formula-animal,
  test-phase0-api}.R`.
- Local checks: `air format .`; `devtools::document()`; **`pkgdown::check_pkgdown()`
  clean** (run locally this time per the previous lesson); full `testthat` with
  juliaup + `NOT_CRAN` + sommer + enhancer (live two-effect fit ran) — 0 failures,
  0 warnings, 0 skipped; `rcmdcheck(--as-cran)` 0/0/1 (benign).
- Local commit `e7026a9`. Remote checks for `e7026a9`: pkgdown `27483756310`
  **passed** (local `check_pkgdown()` paid off); R-CMD-check `27483756304`
  **failed** — the defensive `methods::is()` I added (from the review should-fix)
  triggered ``'::' import not declared from: 'methods'``, and CI runs
  `error_on = "warning"`. Local `rcmdcheck(error_on = "never")` did not surface
  this warning (a local/CI R-version divergence). Lesson: avoid `pkg::` for
  undeclared packages; the codebase already uses base `inherits()` for the same
  dgCMatrix check.
- Fix (follow-up commit `9484cae`): replaced `methods::is()` with base
  `inherits()` (matching `R/julia-bridge.R` line ~630); no `methods::` usage
  remains.
- Remote checks for commit `9484cae` (all green):
  - GitHub Actions R-CMD-check `27483872069`: passed.
  - GitHub Actions pkgdown `27483872067`: passed.
  - GitHub Pages build/deploy `27483901956`: passed.

## 2026-06-13 Opt-in maternal-genetic two-effect model (Phase 2)

- Goal: third Phase 2 increment — surface the maternal-genetic model (direct
  additive + maternal genetic effect via the dam, both pedigree A) behind the
  opt-in `two_effect` fence, reusing the common-environment infrastructure. Twin
  gate `V3-TWOEFFECT-REML` is `partial`.
- Active lenses: Ada, Hopper, Henderson, Emmy, Curie, Rose, Falconer. Spawned
  subagents: review `wrgi3zo2o` (hopper-alignment + rose-honesty), 0 blocking,
  0 should-fix; the Z2/Ainv2 pedigree-alignment concern verified correct.
- `maternal_genetic(1 | dam)` parsed with `relationship = "pedigree"`; the
  two-effect bridge branches on relationship (pedigree → `Ainv2 = hsq_Ainv`,
  `ids2 = hsq_ped.ids`; identity → sparse identity). New `maternal_effects()`
  extractor. The two-effect validation row was broadened (still 18 rows).
- Files: `R/{model-spec,bridge-payload,julia-bridge,hsquared,extractors,
  formula-status,validation-status,hs_control}.R`, `NAMESPACE`, `man/*`,
  `NEWS.md`, `ROADMAP.md`, `_pkgdown.yml`,
  `docs/design/{capability-status,06-public-claims-register}.md`,
  `tests/testthat/{test-maternal,test-repeatability,test-formula-animal,
  test-phase0-api}.R`.
- Local checks: `air format`; `devtools::document()`; **`pkg::`-vs-Imports grep**
  (lesson applied) + **`check_pkgdown()` clean**; full `testthat` with juliaup +
  `NOT_CRAN` + sommer + enhancer (live maternal fit ran) — 0/0/0;
  `rcmdcheck(--as-cran)` 0/0/1 (benign).
- Local commit `803793d`. Remote checks for `803793d` (all green):
  - GitHub Actions R-CMD-check `27484321173`: passed.
  - GitHub Actions pkgdown `27484321186`: passed.

## 2026-06-13 Opt-in genomic GREML model (Phase 5)

- Goal: fourth opt-in slice — surface genomic variance-component estimation on a
  user-supplied genomic relationship inverse via `genomic(1 | id, Ginv = Ginv)`
  → `fit_ai_reml` on a Ginv-based spec. Twin gate `V2-GREML` is `partial`. A
  bridge probe confirmed the engine path before building.
- Active lenses: Ada, Hopper, Henderson, Kirkpatrick, Emmy, Curie, Rose. Spawned
  subagents: review `woigtw1b0` (hopper-parser-align + rose-honesty) — 1 blocking
  (`model_spec()` crash on genomic) + 1 should-fix, both fixed; Z/Ginv/ids
  alignment and the primary-effect generalisation verified correct.
- Generalised the parser's PRIMARY effect (animal XOR genomic); new opt-in
  `target = "genomic"`; `model_spec()` errors clearly on genomic.
  `validation_status()` now 19 rows. v0.1 + repeatability + two-effect unchanged.
- Files: `R/{model-spec,model-spec-inspect,bridge-payload,julia-bridge,hsquared,
  formula-status,validation-status,hs_control}.R`, `NAMESPACE`, `man/*`,
  `NEWS.md`, `ROADMAP.md`,
  `docs/design/{capability-status,06-public-claims-register}.md`,
  `tests/testthat/{test-genomic,test-model-spec-inspect,test-formula-animal,
  test-phase0-api}.R`.
- Local checks: `air format`; `devtools::document()`; **`pkg::`-grep clean** +
  **`check_pkgdown()` clean**; full `testthat` with juliaup + `NOT_CRAN` + sommer
  + enhancer (live GREML fit ran) — 0/0/0; `rcmdcheck(--as-cran)` 0/0/1 (benign).
  Lesson: `--as-cran` (installed-package tests) caught a model-spec test
  divergence that `test_dir(load_all)` did not — `--as-cran` is authoritative.
- Local commit `8930323`. Remote checks for `8930323` (all green):
  - GitHub Actions R-CMD-check `27484947202`: passed.
  - GitHub Actions pkgdown `27484947207`: passed.

## 2026-06-13 "Fitting models" vignette + opt-in single-step model (Phase 5)

- Vignette `vignettes/articles/fitting-models.Rmd` (commit `cada073`): a
  worked-examples capstone for every model hsquared fits (v0.1 default +
  repeatability, common-environment, maternal, genomic, single-step), with the
  formula/target/extractors per model; `check_pkgdown()` clean (added to navbar +
  index). Remote checks for `cada073` (green): R-CMD-check `27485056735`, pkgdown
  `27485056726`.
- Single-step model (commit `bbd527d`): `single_step(1 | id, Hinv = Hinv)` fits by
  REML on a user-supplied single-step relationship inverse, reusing the genomic
  `fit_ai_reml`-on-a-supplied-inverse path (the genomic parser was generalised to
  a shared supplied-relationship-inverse primary). Twin gate `V2-SSHINV` partial.
  Spawned subagents: one Explore review — clean (0 blocking; refactor verified
  non-regressive). The supplied-relationship validation_status row was broadened
  (still 19 rows).
- Local checks: `air format`; `devtools::document()`; `pkg::`-grep + `check_pkgdown()`
  clean; full `testthat` with juliaup + `NOT_CRAN` + sommer + enhancer (live
  single-step fit ran) — 0/0/0; `rcmdcheck(--as-cran)` 0/0/1 (benign).
- Remote checks for `bbd527d` (all green):
  - GitHub Actions R-CMD-check `27485346107`: passed.
  - GitHub Actions pkgdown `27485346095`: passed.

## 2026-06-13 Opt-in marker-based genomic (build Ginv from markers) + vignette honesty fix

- Marker-based genomic (commit `d03a987`): `genomic(1 | id, markers = M)` builds
  the genomic relationship from a raw marker matrix in the engine
  (`genomic_relationship_matrix`/`_inverse`, ridge 0.01, then `fit_ai_reml`),
  alongside the existing `genomic(1 | id, Ginv = Ginv)`. Verified read-only that
  both engine functions and the `V2-GRM`/`V2-GINV`/`V2-GREML` gates are on twin
  `origin/main` (`100adbe`), so the path works against the released engine.
- Vignette honesty fix (commit `30ea6fa`): the `model-status` vignette still
  listed `genomic()`/`single_step()`/`permanent()`/`common_env()`/
  `maternal_genetic()` as "error as not implemented" (stale since the earlier
  opt-in slices); added an "Opt-in and experimental" section and removed the
  false claims. Flagged by the rose honesty review of the marker slice.
- Spawned subagents: 2-agent review — `hopper-r-julia-translator`
  (`a05b5e7c716abe0a6`, regression/Z-G-alignment) and `rose-systems-auditor`
  (`af664757db1486c13`, honesty). Both 0 blockers; acted on hopper should-fix #1
  (argument-aware eval error), #3 (two non-live payload-wiring tests close the
  CI-runnable gap), and rose's in-slice ROADMAP nit + the vignette fix.
- Local checks: `air format`; `devtools::document()`; `pkg::`-grep clean (only
  declared `JuliaCall::`) + `check_pkgdown()` clean; full `testthat` with juliaup
  + `NOT_CRAN` + sommer + enhancer (live marker fit ran) — 0/0/0;
  `rcmdcheck(--as-cran)` 0/0/1 (benign new-submission NOTE).
- Remote checks for `30ea6fa` (all green):
  - GitHub Actions R-CMD-check `27485897859`: passed.
  - GitHub Actions pkgdown `27485897877`: passed.

## 2026-06-13 Opt-in SNP-BLUP marker-effect model (supplied-variance, Phase 5)

- SNP-BLUP (commit `27e30c2`): `genomic(1 | id, markers = M)` with
  `target = "snp_blup"` and supplied `variance_components = c(sigma_g2, sigma_e2)`
  surfaces `fit_snp_blup()` — per-marker effects (`marker_effects()`) +
  per-individual GEBVs at supplied variances (not estimation). Verified
  read-only that `fit_snp_blup`/`centered_markers` and the `V2-SNPBLUP` gate are
  on twin `origin/main` `100adbe`. A direct bridge probe confirmed the call,
  result shape, and the GBLUP↔SNP-BLUP equivalence (exact at ridge 0).
  `validation_status()` now 20 rows. `marker_effects()` (already wired) carved
  out of the reserved-placeholder set. v0.1 + all prior opt-in models unchanged.
- Spawned subagents: 2-agent review — `hopper-r-julia-translator`
  (`a105f3f97181ec007`) and `rose-systems-auditor` (`ad54a93ee199c04b7`). The
  bridge/engine logic reviewed CLEAN (per-record marker alignment
  permutation-free; per-individual GEBV internally consistent via shared
  `snp.p`; routing non-regressive; extractor wiring correct). Both caught the
  SAME blocker: a botched claims-register table edit that merged the SNP-BLUP
  row with the orphaned tail of the fitted-object/extractor row (deleting its
  leading cells); restored to +1 net row with the fitted-object row intact.
  Should-fix (stale "Reserved" marker_effects framing in model-status) + nit
  (extractor roxygen) also fixed.
- Local checks: `air format`; `devtools::document()`; `pkg::`-grep clean (only
  declared `JuliaCall::`) + `check_pkgdown()` clean; full `testthat` with juliaup
  + `NOT_CRAN` + sommer + enhancer (live SNP-BLUP fit ran) — 0/0/0;
  `rcmdcheck(--as-cran)` 0/0/1 (benign).
- Remote checks for `27e30c2` (all green):
  - GitHub Actions R-CMD-check `27486476591`: passed.
  - GitHub Actions pkgdown `27486476589`: passed.

## 2026-06-13 Multivariate readiness plan + bare-random-effect guard / limits doc

- Multivariate R-bridge readiness plan (commit `d510e8e`): docs-only. Recorded
  the Phase 3 surfacing design (`cbind()` grammar, `Y`-matrix payload, opt-in
  `target = "multivariate"` fence, genetic-correlation/G/per-trait-h2 extractors)
  against the twin's actual `fit_multivariate_reml` contract — verified read-only
  that it is on the twin branch `phase4-multivariate-reml` and NOT on Julia main
  (`100adbe`), so nothing is surfaceable yet. `docs/design/09-multivariate-plan.md`
  + ROADMAP Phase 3 pointer. No capability claim, no code, no twin edit.
- Bare-random-effect guard + limits doc (commit `df7bc42`): the parser silently
  absorbed a bare `(1 | x)` into the fixed design (model.frame evaluated `1 | x`
  as an all-TRUE logical column). Now `hs_is_bar_expr`/
  `hs_stop_unsupported_random_effect` reject any leftover top-level `|` term with
  a pointer to the named effects (TDD: watched the `(1 | x)`/`(x | id)` tests
  fail first). Named effects unaffected. Added a "Current limits" section to the
  model-status vignette answering the maintainer's limits question.
- Local checks (both): `air format`; `devtools::document()`; `pkg::`-grep clean
  (no new deps); `check_pkgdown()` clean; full `testthat` with juliaup +
  `NOT_CRAN` + sommer + enhancer — 0/0/0; `rcmdcheck(--as-cran)` 0/0/1 (benign).
- Remote checks for `df7bc42` (all green):
  - GitHub Actions R-CMD-check `27486712995`: passed.
  - GitHub Actions pkgdown `27486713006`: passed.
- Remote checks for `d510e8e` (docs-only) were superseded by `df7bc42`'s run on
  the same tree state; both pushed and green.

## 2026-06-13 Overnight honesty sweep (stale planned/inert claims for opt-in models)

- Audit (Workflow `wf_158f535d-1c2`, 26 agents): 6 parallel audit dimensions
  (claims-honesty, validation-evidence, cross-doc, vignette-accuracy,
  export-integrity, opt-in-wiring) → adversarial refutation of every candidate →
  16 confirmed defects (from 20). All one class: stale "planned/inert/not
  implemented" wording for now-opt-in models, in surfaces the per-slice reviews
  did not revisit. ZERO over-claims; critical dimensions CLEAN (opt-in wiring
  complete, multivariate not claimed anywhere, register well-formed, the 3
  covered rows correctly backed).
- Sweep (commit `7b3c3d9`, docs/strings only): README, DESCRIPTION,
  genomic-markers.R / qg-effects.R roxygen (man/*), capability-status.md,
  06-public-claims-register.md, and four vignettes carve the opt-in fitted models
  out of the "planned/inert" wording with the experimental/opt-in/not-default
  fence; fixed a real bug (formula_status advertised `maternal_genetic(1 | dam,
  pedigree = ped)`, which the parser rejects → `maternal_genetic(1 | dam)`);
  trimmed the "finite REML logLik" evidence over-statement from three
  validation_status rows; mission-control "16" rows → 20.
- Local checks: `air format`; `devtools::document()`; `pkg::`-grep clean (no new
  deps); `check_pkgdown()` clean; full `testthat` with juliaup + `NOT_CRAN` +
  sommer + enhancer — 0/0/0; `rcmdcheck(--as-cran)` 0/0/1 (benign).
- Remote checks for `7b3c3d9` (all green):
  - GitHub Actions R-CMD-check `27487099560`: passed.
  - GitHub Actions pkgdown `27487099551`: passed.

## 2026-06-14 R multivariate bridge slice (opt-in `target = "multivariate"`)

- Implemented the R-facing multivariate Gaussian animal-model slice after the
  Julia twin landed Phase 4 on `main` (`f9da6bb`): `cbind(trait1, trait2) ~
  animal(1 | id, pedigree = ped)` parses into an NA-preserving `Y` matrix,
  reuses the existing `X`/sparse-`Z`/pedigree payload, and routes through
  `engine = "julia", engine_control = list(target = "multivariate")` to
  `HSquared.fit_multivariate_reml()`. Added G/R covariance and correlation
  extractors, per-trait h2, cross-trait EBVs, named `initial = list(G0 = ...,
  R0 = ...)` validation, rank-deficient-X guard, and non-converged
  `logLik()`/`AIC()` fence. Status stays `partial`.
- Added `docs/design/11-next-50-slices.md` as the next-slice runway.
- Formatting: `air` was not available on PATH (`command -v air` returned
  empty).
- Documentation: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` — passed; generated `NAMESPACE`,
  `man/multivariate_extractors.Rd`, and updated control/fit docs.
- Focused tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "devtools::test(filter = 'multivariate')"` — passed, 0 failures / 0
    warnings / 2 live-Julia skips / 29 passes.
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "devtools::test(filter = 'multivariate|phase0-api|fit-object|julia-bridge')"` —
    passed, 0 failures / 0 warnings / 10 live-Julia skips / 196 passes.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  560 passes.
- Julia bridge note: forcing Julia onto PATH with
  `PATH="/Users/z3437171/.juliaup/bin:$PATH"` caused the local R/JuliaCall
  process to segfault (exit 139) before live bridge checks could complete. The
  ordinary package-test environment leaves Julia off PATH, so those live tests
  skip safely. A direct Julia smoke against `HSquared.jl` succeeded outside
  JuliaCall, returning the expected 2-trait covariance/EBV shapes; the short
  100-iteration smoke did not converge, which is acceptable for that shape-only
  probe.
- Pkgdown:
  - Plain `pkgdown::check_pkgdown()` failed because Pandoc was not on the shell
    PATH.
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Claim/housekeeping scans:
  - `rg -n "pkg::" R tests vignettes README.md DESCRIPTION NEWS.md docs/design`
    — no matches.
  - Stale multivariate-claim scan for branch-only / not-on-main / production
    overclaim wording — clean; remaining hits are intentional "not production"
    and structured/factor-analytic-planned caveats.
  - `git diff --check` — passed.
- Package check:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
    errors / 0 warnings / 0 notes.
- Remote checks for `835e8c2` (all green):
  - GitHub Actions R-CMD-check `27498306285`: passed.
  - GitHub Actions pkgdown `27498306288`: passed.
  - GitHub Pages build/deployment `27498349567`: passed.

## 2026-06-14 Structured multivariate grammar error ergonomics

- Implemented the next R-safe bite from `docs/design/11-next-50-slices.md`:
  `animal(trait | id, ...)` and `animal(..., cov = ...)` errors now point users
  to the live opt-in `cbind(trait1, trait2) ~ ... + animal(1 | id, pedigree =
  ped)` multivariate path and clearly label long-format/structured covariance
  grammar (`cov = us()`, `cov = fa(K = 2)`) as planned.
- Focused tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'formula-animal')"` — passed, 0 failures / 0
  warnings / 0 skips / 41 passes.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  561 passes.
- `git diff --check` — passed.

## 2026-06-14 Multivariate fitting article

- Added a dedicated pkgdown article for the opt-in multivariate Gaussian animal
  model: `vignettes/articles/multivariate.Rmd`. It documents the live `cbind()`
  response grammar, missing response cells, G/R covariance and correlation
  extractors, per-trait h2, cross-trait EBVs, named `initial = list(G0 = ...,
  R0 = ...)`, and the claim boundary around structured covariance syntax.
- Updated `vignettes/articles/fitting-models.Rmd` to include the multivariate
  fit in the model tour and to stop saying multivariate as a whole remains only
  on the roadmap; the roadmap boundary is now structured/factor-analytic
  covariance, non-Gaussian/GLLVM, unusual inheritance, and GPU execution.
- Updated `_pkgdown.yml` so the multivariate article appears in the Articles
  menu and Start here article index.
- Jason scout: checked local sister documentation patterns in `gllvmTMB`
  (`covariance-correlation.Rmd`, `animal-model.Rmd`) and `drmTMB`
  (`phylogenetic-spatial.Rmd`) for purpose-first examples, syntax/equation
  pairing, and explicit fitted-vs-planned boundaries.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Public-claim scan: `rg -n
  "Multivariate, factor-analytic|multivariate.*remain on the roadmap|ASReml-style production|t>=2|target = \"multivariate\"|cov = us|cov = fa"
  README.md DESCRIPTION ROADMAP.md docs vignettes R tests` — no stale
  "multivariate remains on the roadmap" wording; remaining hits are intentional
  opt-in/partial/planned-boundary language.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  561 passes.
- `git diff --check` — passed.
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.

## 2026-06-14 Manual comparator-script smoke coverage

- Added ordinary CI-safe smoke tests for the manual comparator scripts:
  - ASReml-R script dry-run prepares the shared Phase 4 fixture and reports
    160 long-format records, 2 traits, and 20 animals without requiring ASReml.
  - BLUPF90-family script dry-run prepares 80 data rows and 20 pedigree rows.
  - BLUPF90-family script write mode emits `.dat`, `.ped`, `.renf90`, `.par`,
    and README files into a temporary directory; the test checks row/column
    counts and verifies template placeholders are replaced.
- Hardened `inst/comparator-scripts/blupf90/prepare-multivariate-animal.R` so
  template lookup works from the source tree, the installed package layout, and
  the `.Rcheck` package-check layout.
- Initial focused run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'comparator-scripts')"` — failed because
  `system2(env = ...)` used a named vector and the repo path contains a space;
  fixed to pass an explicit quoted `HSQUARED_REPO=...` string.
- Second focused run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'comparator-scripts')"` — failed because the script
  path containing `Github Local` needed quoting; fixed by quoting script
  arguments.
- First package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — failed in
  `test-comparator-scripts.R` because the built-package `.Rcheck` layout stores
  comparator templates under `hsquared/comparator-scripts/`, not
  `inst/comparator-scripts/`; fixed by adding multi-layout template discovery.
- Final focused tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'comparator-scripts')"` — passed, 0 failures /
  0 warnings / 0 skips / 27 passes.
- Formatting: `command -v air` returned no `air` binary on PATH.
- `git diff --check` — passed.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  612 passes.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `02940a9` (all green):
  - GitHub Actions R-CMD-check `27502951970`: passed.
  - GitHub Actions pkgdown `27502951976`: passed.
  - GitHub Pages build/deployment `27502995270`: passed.
- Remote checks for `3ea321d` (all green):
  - GitHub Actions R-CMD-check `27502628759`: passed.
  - GitHub Actions pkgdown `27502628772`: passed.
  - GitHub Pages build/deployment `27502672768`: passed.
- Remote checks for `4d6d09d` (all green):
  - GitHub Actions R-CMD-check `27502737484`: passed.
  - GitHub Actions pkgdown `27502737487`: passed.
  - GitHub Pages build/deployment `27502782595`: passed.

## 2026-06-14 Factor-analytic G-matrix production design note

- Boole/Noether review: planned syntax remains
  `animal(trait | id, pedigree = ped, cov = diag() / lowrank(K) / fa(K))`;
  no parser change was made.
- Engine-contract review: future result fields should keep `genetic_covariance`
  and `genetic_correlation` primary; loadings, uniqueness, rotation method, and
  latent breeding values are deferred metadata until rotation and validation
  gates pass.
- Sources checked:
  - `docs/design/02-formula-grammar.md`.
  - `docs/design/01-v0.1-contract.md`.
  - `docs/design/13-sparse-multivariate-production-plan.md`.
  - `HSquared.jl/docs/dev-log/decisions/2026-06-14-loading-rotation-identifiability.md`.
  - `HSquared.jl/test/runtests.jl` structured covariance tests.
  - `GLLVM.jl/src/postfit.jl` rotation-aware extraction pattern.
  - `gllvmTMB/R/diagnose.R` rotation-identifiability advisory pattern.
  - Meyer/Hill multivariate AI-REML reduced-rank PDF.
- Added `docs/design/14-factor-analytic-production-plan.md`.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.

## 2026-06-14 Reserved factor/G-matrix extractor names

- Added reserved R extractor names:
  - `loadings()` for future factor-analytic G-matrix loadings.
  - `specific_variance()` for future uniqueness / specific variance.
  - `latent_breeding_values()` for future latent-axis EBVs.
  - `eigen_G()` for future G-matrix eigen summaries.
- These methods intentionally fail for `hsquared_fit` objects with
  planned/not-implemented messages that point users back to invariant
  `genetic_covariance()` and `genetic_correlation()` and warn that loading axes
  remain rotation-nonunique.
- `loadings.default()` falls back to `stats::loadings()` for non-`hsquared`
  objects so the familiar stats helper is not broken by the package generic.
- Documentation: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` — passed; regenerated `NAMESPACE` and added
  `man/factor_g_extractors.Rd`.
- Focused tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'fit-object')"` — passed, 0 failures / 0 warnings /
  0 skips / 81 passes.
- Formatting: `command -v air` returned no `air` binary on PATH.
- `git diff --check` — passed.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  628 passes.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- First package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — failed with 1
  warning because `man/factor_g_extractors.Rd` documented `effect` and `rotate`
  even though the public generic usage entries do not expose those method-only
  arguments.
- Roxygen fix: moved the `effect` / `rotate` explanation from `@param` tags into
  prose and reran `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` — passed; regenerated `man/factor_g_extractors.Rd`.
- Recheck after roxygen fix:
  - Focused tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "devtools::test(filter = 'fit-object')"` — passed, 0 failures / 0 warnings
    / 0 skips / 81 passes.
  - `git diff --check` — passed.
  - Pkgdown:
    `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "pkgdown::check_pkgdown()"` — passed, "No problems found."
  - Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips
    / 628 passes.
  - Package check:
    `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript -e
    "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
    errors / 0 warnings / 0 notes.

## 2026-06-14 Non-Gaussian family planned errors

- Updated the family validation error in `R/model-spec.R` so non-Gaussian
  families name the requested family/link and point users to the live
  `family = gaussian()` v0.1 path or `model_spec()` preview path.
- Added focused tests for `poisson(log)` and `binomial(logit)` planned errors.
- Formatting: `command -v air` returned no `air` binary on PATH.
- Focused tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'formula-animal')"` — passed, 0 failures /
  0 warnings / 0 skips / 43 passes.
- `git diff --check` — passed.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  614 passes.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `3d3935f` (all green):
  - GitHub Actions R-CMD-check `27501775236`: passed.
  - GitHub Actions pkgdown `27501775239`: passed.
  - GitHub Pages build/deployment `27501820927`: passed.

## 2026-06-14 Standard QG marker claim audit

- Rose audit command:
  `rg -n "fits|estimates|fast|ASReml-level|implemented|supports|Julia speed|production|validated|covered" README.md DESCRIPTION ROADMAP.md docs vignettes R man`
  found stale ledger wording for the standard quantitative-genetic marker row:
  `docs/design/06-public-claims-register.md`,
  `docs/design/capability-status.md`, and
  `docs/design/validation-debt-register.md` still described all permanent,
  common-environment, and maternal markers as planned-only.
- Confirmed `R/qg-effects.R` and `man/qg_effect_markers.Rd` already carve out
  the opt-in `permanent()`, `common_env()`, and `maternal_genetic()` paths.
- Updated the three ledger rows so:
  - `permanent()`, `common_env()`, and `maternal_genetic()` are opt-in
    experimental paths only;
  - paternal, maternal-environment, dominance, epistasis, custom-kernel,
    cytoplasmic, and imprinting syntax remains planned-only;
  - no row promotes those opt-in paths beyond `partial`.
- Remote checks for `08a7545` (all green):
  - GitHub Actions R-CMD-check `27501546666`: passed.
  - GitHub Actions pkgdown `27501546680`: passed.
  - GitHub Pages build/deployment `27501593161`: passed.
- `git diff --check` — passed.
- Row verification:
  `rg -n "Standard quantitative-genetic formula markers exist|Quantitative-genetic effect markers" docs/design/06-public-claims-register.md docs/design/capability-status.md docs/design/validation-debt-register.md`
  — passed; the three rows now carve out the opt-in paths and keep remaining
  markers planned-only.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `a75b099` (all green):
  - GitHub Actions R-CMD-check `27501031338`: passed.
  - GitHub Actions pkgdown `27501031343`: passed.
  - GitHub Pages build/deployment `27501072754`: passed.

## 2026-06-14 Manual comparator-run report template

- Added `docs/dev-log/comparator-runs/TEMPLATE.md` for future manual external
  comparator runs. The template captures purpose, claim boundary, tool/version,
  environment, input checksums, model/estimand match, covariance/h2/logLik
  result table, convergence diagnostics, file redistribution constraints, and
  Rose/Fisher/Curie verdicts.
- Updated `docs/dev-log/comparator-runs/README.md` to point contributors to the
  template.
- Remote checks for `e623006` (all green):
  - GitHub Actions R-CMD-check `27501369523`: passed.
  - GitHub Actions pkgdown `27501369525`: passed.
  - GitHub Pages build/deployment `27501417156`: passed. GitHub emitted a
    non-failing hosted-actions warning about Node.js 20 deprecation in Pages
    actions.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `5f84bbd` (all green):
  - GitHub Actions R-CMD-check `27500857518`: passed.
  - GitHub Actions pkgdown `27500857520`: passed.
  - GitHub Pages build/deployment `27500902705`: passed.

## 2026-06-14 Multivariate partial-comparator claim sweep

- Updated `docs/design/06-public-claims-register.md` so the experimental
  multivariate Gaussian animal-model row records shared R/Julia fixture parity
  and the optional `sommer` diagonal-residual comparator for G0, diag(R0), and
  diagonal-target h2.
- Updated `vignettes/articles/model-status.Rmd` to say full same-estimand
  external-comparator evidence remains planned, while the partial `sommer`
  diagonal-residual check exists.
- `git diff --check` — passed.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `d7fe473` (all green):
  - GitHub Actions R-CMD-check `27500692937`: passed.
  - GitHub Actions pkgdown `27500692932`: passed.
  - GitHub Pages build/deployment `27500735239`: passed.

## 2026-06-14 Multivariate validation issue ledger

- Created focused GitHub issue:
  `https://github.com/itchyshin/hsquared/issues/10`
  (`Multivariate validation: comparator and recovery gates`), labelled
  `validation`, `roadmap`, `r-package`, `julia-engine`, and `status:partial`.
- Cross-linked from validation canon issue #7:
  `https://github.com/itchyshin/hsquared/issues/7#issuecomment-4701935017`.
- Verification:
  - `/opt/homebrew/bin/gh issue view 10 --repo itchyshin/hsquared --json number,title,labels,url,state`
    showed issue #10 open with the expected labels.
  - `/opt/homebrew/bin/gh issue view 7 --repo itchyshin/hsquared --comments --json comments --jq '.comments[-1].url'`
    returned the #7 cross-link comment URL above.
- `git diff --check` — passed.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `9b9a11d` (all green):
  - GitHub Actions R-CMD-check `27500382900`: passed.
  - GitHub Actions pkgdown `27500382897`: passed.
  - GitHub Pages build/deployment `27500426971`: passed.

## 2026-06-14 ASReml/BLUPF90 manual comparator skeletons

- Added manual comparator skeletons:
  - `inst/comparator-scripts/README.md`;
  - `inst/comparator-scripts/asreml/multivariate-animal.R`;
  - `inst/comparator-scripts/blupf90/prepare-multivariate-animal.R`;
  - `inst/comparator-scripts/blupf90/multivariate-animal.renf90`;
  - `inst/comparator-scripts/blupf90/multivariate-animal.par`;
  - `docs/dev-log/comparator-runs/README.md`.
- ASReml dry-run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript inst/comparator-scripts/asreml/multivariate-animal.R --dry-run`
  — passed; prepared 160 long-format records, 2 traits, and 20 animals without
  requiring ASReml.
- BLUPF90 dry-run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R`
  — passed; prepared 80 data rows and 20 pedigree rows without writing files.
- BLUPF90 temp write smoke:
  `tmpdir=$(mktemp -d); /Library/Frameworks/R.framework/Resources/bin/Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R --write="$tmpdir"; find "$tmpdir" -maxdepth 1 -type f -print | sort; sed -n '1,80p' "$tmpdir/multivariate-animal.renf90"; rm -rf "$tmpdir"`
  — passed; wrote README, data, pedigree, `.renf90`, and `.par` files to a temp
  directory and substituted the data/pedigree filenames into the template.
- `git diff --check` — passed.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::test()"`
  — passed, 0 failures / 0 warnings / 27 live-Julia skips / 585 passes.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `c3e5a26` (all green):
  - GitHub Actions R-CMD-check `27500073218`: passed.
  - GitHub Actions pkgdown `27500073217`: passed.
  - GitHub Pages build/deployment `27500113544`: passed.

## 2026-06-14 Optional sommer comparator for multivariate fixture

- Added a skip-safe optional `sommer` comparator test to
  `tests/testthat/test-multivariate.R`.
- The test reads the shared Phase 4 fixture, builds `A` with `nadiv::makeA()`,
  reshapes the response to sommer's long format, and fits a diagonal-residual
  multivariate animal model:
  `value ~ trait + trait:x - 1`,
  `random = ~ vsm(usm(trait), ism(animal), Gu = A)`,
  `rcov = ~ vsm(dsm(trait), ism(units))`.
- Assertions:
  - `sommer` reports convergence.
  - G0 matches the serialized Julia target within `5e-4`.
  - `diag(R0)` matches the serialized Julia target within `5e-4`.
  - diagonal-target h2 matches within `5e-4`.
  - the sommer residual off-diagonal is exactly zero, making the partial
    comparator boundary explicit.
- Updated `validation_status()`, `capability-status.md`, and the validation debt
  register to state that the `sommer` comparator is partial/diagonal-residual
  only.
- Formatting: `command -v air || true` returned no `air` binary on PATH.
- First focused run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'multivariate|phase0-api')"` — failed because the
  new test incorrectly called `utils::reshape()`; fixed to `stats::reshape()`.
- Second focused run:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'multivariate|phase0-api')"` — passed, 0 failures /
  0 warnings / 2 live-Julia skips / 124 passes.
- Documentation:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` — passed; no generated Rd changes.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  585 passes.
- `git diff --check` — passed.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.

## 2026-06-14 Multivariate comparator scout and plan

- Added `docs/design/12-multivariate-comparator-plan.md` to define the
  multivariate comparator ladder and same-estimand rules.
- Added `docs/dev-log/scout/2026-06-14-multivariate-comparator-scout.md` with
  the local package/tool availability check and the `sommer` pilot result.
- Local availability:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript -e "pkgs <- c('asreml','sommer','MCMCglmm','nadiv','pedigreemm','AGHmatrix'); for (p in pkgs) cat(p, ': ', if (requireNamespace(p, quietly=TRUE)) as.character(utils::packageVersion(p)) else 'not installed', '\n', sep='')"`
    reported `sommer` 4.4.5, `MCMCglmm` 2.36, `nadiv` 2.18.0,
    `pedigreemm` 0.3.5; `asreml` and `AGHmatrix` were not installed.
  - `command -v asreml || true; command -v airemlf90 || true; command -v blupf90 || true; command -v renumf90 || true; command -v dmuai || true; command -v wombat || true`
    returned no comparator executables on `PATH`.
- Sommer pilot:
  - Reshaped the shared Phase 4 fixture into long format and sorted by `trait`.
  - Built `A` from the fixture pedigree with `nadiv::makeA()`.
  - `sommer::mmes(value ~ trait + trait:x - 1, random = ~ vsm(usm(trait), ism(animal), Gu = A), rcov = ~ vsm(dsm(trait), ism(units)))`
    fit successfully.
  - The `sommer` genetic covariance and residual variances matched the
    serialized Julia target within a tight deterministic smoke-test tolerance:
    `G0 = [[0.6036285, 0.1119503], [0.1119503, 0.2703534]]`,
    `diag(R0) = [0.2631124, 0.0906582]`.
  - `rcov = ~ vsm(usm(trait), ism(units))` failed locally with
    `Mat::operator(): index out of bounds`; the wide `cbind()` sommer pilot also
    failed under the installed 4.4.5 API. The first comparator slice is
    therefore partial/diagonal-residual only.
- `git diff --check` — passed.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `61a7ca3` (all green):
  - GitHub Actions R-CMD-check `27499481337`: passed.
  - GitHub Actions pkgdown `27499481332`: passed.
  - GitHub Pages build/deployment `27499523585`: passed.

## 2026-06-14 V4 issue ledger cleanup

- GitHub connector write attempt for issue #6 returned 403
  (`Resource not accessible by integration`), so issue writes used the
  authenticated `gh` CLI.
- Posted R bridge-ledger follow-up to `hsquared#6`:
  `https://github.com/itchyshin/hsquared/issues/6#issuecomment-4701824594`.
- Posted validation-canon follow-up to `hsquared#7`:
  `https://github.com/itchyshin/hsquared/issues/7#issuecomment-4701825084`.
- Posted extractor-contract follow-up to `hsquared#5`:
  `https://github.com/itchyshin/hsquared/issues/5#issuecomment-4701825670`.
- Relabelled `hsquared#7` from `status:planned` to `status:partial`.
- Verification:
  - `/opt/homebrew/bin/gh issue view 7 --repo itchyshin/hsquared --json number,title,labels,url`
    shows `status:partial` and no `status:planned`.
  - `/opt/homebrew/bin/gh issue view 6 --repo itchyshin/hsquared --comments --json comments --jq '.comments[-1].url'`
    returned the #6 comment URL above.
  - `/opt/homebrew/bin/gh issue view 7 --repo itchyshin/hsquared --comments --json comments --jq '.comments[-1].url'`
    returned the #7 comment URL above.
  - `/opt/homebrew/bin/gh issue view 5 --repo itchyshin/hsquared --comments --json comments --jq '.comments[-1].url'`
    returned the #5 comment URL above.
- Remote checks for `43d83aa` (all green):
  - GitHub Actions R-CMD-check `27498842644`: passed.
  - GitHub Actions pkgdown `27498842650`: passed.
  - GitHub Pages build/deployment `27498896347`: passed. GitHub emitted a
    non-failing hosted-actions warning about Node.js 20 deprecation in Pages
    actions.

## 2026-06-14 Multivariate extractor documentation examples

- Added non-running roxygen examples to the multivariate extractor topic
  (`genetic_covariance()`, `residual_covariance()`, `genetic_correlation()`,
  `residual_correlation()`). The examples show the opt-in `cbind()` multivariate
  fit, `fit_diagnostics()`, G/R covariance and correlation extraction, and
  per-trait `heritability()`.
- Formatting: `air` was not available on PATH (`command -v air` returned
  empty).
- Documentation: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` — passed; regenerated
  `man/multivariate_extractors.Rd`.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Focused tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'multivariate|fit-object')"` — passed, 0 failures /
  0 warnings / 2 live-Julia skips / 96 passes.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  561 passes.
- `git diff --check` — passed.
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes; examples checked OK.
- Remote checks for `21161a5` (all green):
  - GitHub Actions R-CMD-check `27499072097`: passed.
  - GitHub Actions pkgdown `27499072089`: passed.
  - GitHub Pages build/deployment `27499111169`: passed.

## 2026-06-14 Shared Phase 4 multivariate parity fixture in R tests

- Copied the deterministic two-trait Phase 4 parity fixture from the sibling
  `HSquared.jl` local checkout into
  `tests/testthat/fixtures/phase4_multitrait_parity/`. The fixture README
  explicitly states that it is not an external comparator and does not promote
  any validation row to covered status.
- Added an ordinary CI-safe R test that reads the fixture, normalizes the
  Julia-style pedigree unknown-parent `0` values to R missing parents, builds
  the `cbind(trait1, trait2) ~ x + animal(1 | animal, pedigree = ped)` model
  spec, checks `Y`/`X`/`Z`/ID payload alignment, and normalizes the serialized
  Julia REML target into an `hsquared_fit` for G/R covariance and correlation,
  per-trait h2, fixed-effect, EBV, nobs, logLik, df, and diagnostics checks.
- Formatting: `command -v air || true` returned no `air` binary on PATH.
- Focused tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'multivariate')"` — passed, 0 failures / 0
  warnings / 2 live-Julia skips / 48 passes.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  580 passes.
- `git diff --check` — passed.
- Pkgdown: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check: `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.

## 2026-06-14 Inference helper blockers

- Added explicit `hsquared_fit` methods for `confint()`, `vcov()`,
  `profile()`, and `anova()`. These methods intentionally error and state that
  validated confidence intervals, standard-error surfaces, profile likelihoods,
  and likelihood-ratio / ANOVA guidance are planned, not implemented.
- Documentation: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::document()"` — passed; regenerated `NAMESPACE` and added
  `man/inference_blocks.Rd`.
- Focused tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'fit-object')"` — passed, 0 failures / 0 warnings /
  0 skips / 71 passes.
- Formatting: `command -v air` returned no `air` binary on PATH.
- `git diff --check` — passed.
- Full tests: `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 27 live-Julia skips /
  618 passes.
- First pkgdown check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — failed because `_pkgdown.yml` did not yet index
  the new `inference_blocks` topic.
- Fixed the pkgdown reference index by adding `inference_blocks` to the
  extractor-contract section.
- Pkgdown recheck:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `5f3c6f1` (all green):
  - GitHub Actions R-CMD-check `27502155981`: passed.
  - GitHub Actions pkgdown `27502155965`: passed.
  - GitHub Pages build/deployment `27502205152`: passed.
- Remote checks for `3122d3c` (all green):
  - GitHub Actions R-CMD-check `27502457364`: passed.
  - GitHub Actions pkgdown `27502457363`: passed.
  - GitHub Pages build/deployment `27502500423`: passed.

## 2026-06-14 Sparse multivariate production design note

- Jason scout question: what should the production sparse multivariate path
  learn from local twin/sister packages before any R syntax or public claim is
  widened?
- Sources checked:
  - `.agents/skills/quantgen-scout/references/packages.md`.
  - `HSquared.jl/ROADMAP.md` Phase 4 / 4B status and current limitations.
  - `HSquared.jl/docs/design/00-ecosystem-lessons.md`.
  - `GLLVM.jl/src/fit_phylo.jl` Woodbury / sparse Cholesky pattern.
  - `DRM.jl/src/location_only.jl` sparse marginal likelihood, profiled fixed
    effects, and Takahashi-trace pattern.
  - PubMed page for Gilmour (2019), "Average information residual maximum
    likelihood in practice".
  - Meyer/Hill multivariate AI-REML reduced-rank PDF.
  - BLUPF90 large-scale REML tutorial page by Masuda.
- Added `docs/design/13-sparse-multivariate-production-plan.md` with target
  model equations, dense-vs-sparse boundaries, sparse MME ladder, structured
  `G0` constraints, matrix-free/iterative extension, R contract, diagnostics,
  validation gates, and CPU/GPU boundary.
- Updated `docs/design/05-roadmap.md` and `docs/design/11-next-50-slices.md`
  to link the design note and mark next-50 row 33 as done.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors
  / 0 warnings / 0 notes.

## 2026-06-14 G/R matrix aliases

- Added `G_matrix()` and `R_matrix()` as aliases over
  `genetic_covariance()` and `residual_covariance()` for `hsquared_fit`
  objects. These names improve applied multivariate ergonomics without adding a
  new result contract or any `P_matrix()` claim.
- Documentation:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::document()"` — passed; regenerated `NAMESPACE` and
  `man/multivariate_extractors.Rd`.
- Formatting:
  `command -v air` — no `air` binary on PATH.
- Focused tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test(filter = 'fit-object|multivariate')"` — passed, 0 failures /
  0 warnings / 3 skips / 135 passes.
- `git diff --check` — passed.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 32 skips / 608
  passes.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for `a4881ea` (all green):
  - GitHub Actions R-CMD-check `27503480493`: passed.
  - GitHub Actions pkgdown `27503480520`: passed.
  - GitHub Pages build/deployment `27503528014`: passed.

## 2026-06-14 G-matrix interpretation article

- Added `vignettes/articles/g-matrix-interpretation.Rmd`, a reader-facing
  article explaining how to interpret the current opt-in multivariate G/R
  matrices, genetic and residual correlations, per-trait h2, cross-trait EBVs,
  and current gates around `P_matrix()`, factor-analytic loadings,
  evolvability, and selection-response claims.
- Added `docs/dev-log/scout/2026-06-14-g-matrix-interpretation-scout.md` after
  checking local sister/twin docs and classical G-matrix anchors.
- Updated `_pkgdown.yml`, `NEWS.md`, and `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for `7e4cce3` (all green):
  - GitHub Actions R-CMD-check `27503967568`: passed.
  - GitHub Actions pkgdown `27503967586`: passed.
  - GitHub Pages build/deployment `27504011650`: passed.

## 2026-06-14 Genomic prediction article

- Added `vignettes/articles/genomic-prediction.Rmd`, a user-facing article that
  separates the current opt-in supplied-`Ginv` GREML, marker-built GREML,
  supplied-variance SNP-BLUP, and supplied-`Hinv` single-step paths from planned
  H construction, APY, marker scans, QTL/GWAS/eQTL, and production comparator
  work.
- Added `docs/dev-log/scout/2026-06-14-genomic-prediction-vignette-scout.md`
  after checking current tests/status docs and genomic prediction anchors.
- Updated `_pkgdown.yml`, `NEWS.md`, and `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for `381cf60` (all green):
  - GitHub Actions R-CMD-check `27504202880`: passed.
  - GitHub Actions pkgdown `27504202884`: passed.
  - GitHub Pages build/deployment `27504252638`: passed.

## 2026-06-14 QTL/GWAS/eQTL status article

- Added `vignettes/articles/qtl-gwas-eqtl-status.Rmd`, a user-facing status
  article that separates live SNP-BLUP `marker_effects()` output and data/status
  diagnostics from planned marker scans, QTL interval scans, GWAS/eQTL tables,
  scan plots, LOCO, and production-scale scan claims.
- Added `docs/dev-log/scout/2026-06-14-qtl-gwas-eqtl-status-scout.md` after
  checking current syntax/tests, local sister-package patterns, and QTL/GWAS/eQTL
  source anchors.
- Updated `_pkgdown.yml`, `NEWS.md`, and `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `2923042` (all green):
  - GitHub Actions R-CMD-check `27504500020`: passed.
  - GitHub Actions pkgdown `27504500023`: passed.
  - GitHub Pages build/deployment `27504554393`: passed.

## 2026-06-14 QTL extension boundary decision

- Added `docs/design/15-qtl-extension-boundary.md`, recording the boundary that
  core `hsquared` owns simple formula/status/result vocabulary while heavy
  QTL/GWAS/eQTL scan execution, file-backed scan infrastructure, plotting,
  fine-mapping, and accelerator/HPC scan kernels belong in optional future
  `hsquaredQTL` / `HSquaredQTL.jl` extensions unless a tiny core scan target is
  dependency-light and fully validated.
- Updated `docs/design/05-roadmap.md` and `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `1dfbaa0` (all green):
  - GitHub Actions R-CMD-check `27504816062`: passed.
  - GitHub Actions pkgdown `27504816046`: passed.
  - GitHub Pages build/deployment `27504863586`: passed.

## 2026-06-14 Inheritance systems roadmap article

- Added `vignettes/articles/inheritance-systems.Rmd`, a user-facing roadmap
  article that keeps the current v0.1 additive animal model and opt-in
  permanent/common/maternal-genetic stepping stones separate from planned
  selfing, clonal, haplodiploid, polyploid, cytoplasmic, imprinting,
  dominance, epistasis, and custom-kernel models.
- Added `docs/dev-log/scout/2026-06-14-inheritance-systems-roadmap-scout.md`
  after checking current R vocabulary, roadmap docs, local sister-package
  patterns, and `nadiv`/`AGHmatrix` literature anchors.
- Updated `_pkgdown.yml`, `NEWS.md`, and `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Formatting:
  `command -v air` — no `air` binary on PATH.
- Rose claim grep:
  `rg -n "supports selfing|polyploid model|dominance model|custom kernels work|cytoplasmic inheritance fit|imprinting support|fits selfing|fits clonal|fits haplodiploid|fits polyploid" vignettes/articles/inheritance-systems.Rmd docs/dev-log/scout/2026-06-14-inheritance-systems-roadmap-scout.md NEWS.md docs/design/11-next-50-slices.md`
  — only the scout note's explicit high-risk phrase list matched; the public
  article did not match these over-claim forms after the wording patch.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `984fbd3` (all green):
  - GitHub Actions R-CMD-check `27505026686`: passed.
  - GitHub Actions pkgdown `27505026688`: passed.
  - GitHub Pages build/deployment `27505072608`: passed.

## 2026-06-14 Wide-response matrix syntax plan

- Added `docs/design/16-wide-response-syntax-plan.md`, recording future
  `traits(...)` and long stacked-cell syntax for GLLVM, omics, and community
  response matrices while keeping the current `cbind(...)` path as the only live
  multivariate animal-model grammar.
- Added `docs/dev-log/scout/2026-06-14-wide-response-syntax-scout.md` after
  checking current hsquared grammar docs, `gllvmTMB`, `GLLVM.jl`, `DRM.jl` /
  `drmTMB`, and external `gllvm` sources.
- Updated `docs/design/05-roadmap.md`, `docs/design/07-genomics-qtl-gpu-plan.md`,
  and `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Rose claim grep:
  `rg -n "traits\\(\\.\\.\\.\\) fits|GLLVM support|omics model|ordination available|per-trait families supported|wide response matrices supported|supports GLLVM|fits GLLVM|implements GLLVM" docs/design/16-wide-response-syntax-plan.md docs/dev-log/scout/2026-06-14-wide-response-syntax-scout.md docs/design/05-roadmap.md docs/design/07-genomics-qtl-gpu-plan.md docs/design/11-next-50-slices.md`
  — only the scout note's explicit high-risk phrase list matched.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `c0a3563` (all green):
  - GitHub Actions R-CMD-check `27505365372`: passed.
  - GitHub Actions pkgdown `27505365382`: passed.
  - GitHub Pages build/deployment `27505414409`: passed.

## 2026-06-14 Trait ordering contract

- Added `docs/design/17-trait-ordering-contract.md`, recording the shared
  trait-order invariant across current `cbind(...)`, future `traits(...)`,
  future long data, Julia payloads, extractors, comparator scripts, and plots.
- Added `docs/dev-log/scout/2026-06-14-trait-ordering-contract-scout.md` after
  checking current R parser/payload code, multivariate tests, the multivariate
  plan, wide-response syntax plan, `gllvmTMB`, and `GLLVM.jl` orientation notes.
- Updated `docs/design/09-multivariate-plan.md`,
  `docs/design/16-wide-response-syntax-plan.md`, and
  `docs/design/11-next-50-slices.md`.
- `git diff --check` — passed.
- Rose claim grep:
  `rg -n "long data supported|traits\\(\\.\\.\\.\\) supported|trait_order implemented|wide-to-long equivalence tested|comparator validated trait order|supports trait_order|implemented trait_order" docs/design/17-trait-ordering-contract.md docs/dev-log/scout/2026-06-14-trait-ordering-contract-scout.md docs/design/09-multivariate-plan.md docs/design/16-wide-response-syntax-plan.md docs/design/11-next-50-slices.md`
  — only the scout note's explicit high-risk phrase list matched.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `24ceb9a` (all green):
  - GitHub Actions R-CMD-check `27505661085`: passed.
  - GitHub Actions pkgdown `27505661091`: passed.
  - GitHub Pages build/deployment `27505705113`: passed.

## 2026-06-14 Multivariate trait-name guard

- Added a parser guard so multivariate `cbind()` responses require unique,
  non-empty trait names before fitting.
- Added focused tests for duplicate `cbind()` names and unrecoverable blank
  trait names.
- Updated `NEWS.md` and `docs/design/17-trait-ordering-contract.md`.
- `git diff --check` — passed.
- Focused tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test(filter = 'multivariate')"` — passed, 0 failures / 0 warnings /
  3 skips / 52 passes.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test()"` — passed, 0 failures / 0 warnings / 32 skips / 610
  passes.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` — passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `bd53ebd` (all green):
  - GitHub Actions R-CMD-check `27505906421`: passed.
  - GitHub Actions pkgdown `27505906424`: passed.
  - GitHub Pages build/deployment `27505963691`: passed.

## 2026-06-14 Sky-blue pkgdown theme

- Updated `_pkgdown.yml` from the previous deep teal to a sky-blue pkgdown
  palette:
  - `primary: "#38a8df"`
  - `headings-color: "#173141"`
  - `link-color: "#126f9b"`
- `git diff --check` - passed.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Local site build:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::build_site(preview = FALSE, new_process = FALSE)"` - passed.
- Visual checks:
  - Desktop screenshot `/tmp/hsquared-skyblue-pkgdown.png`: navbar rendered as
    `rgb(56, 168, 223)`, body links as `rgb(18, 111, 155)`, white navbar text,
    dark search box unchanged.
  - Mobile screenshot `/tmp/hsquared-skyblue-mobile.png`: hamburger visible,
    no horizontal overflow (`bodyWidth = viewportWidth = 390`).
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `71c0766` (all green):
  - GitHub Actions R-CMD-check `27506205627`: passed.
  - GitHub Actions pkgdown `27506205628`: passed.
  - GitHub Pages build/deployment `27506257631`: passed.

## 2026-06-14 Structured covariance R-control contract

- Added `docs/design/18-structured-covariance-r-control.md`, defining the
  planned expert `engine_control$genetic_structure` bridge for future
  `diagonal`, `lowrank`, and `factor_analytic` multivariate genetic covariance
  without exposing live R formula grammar.
- Added `docs/dev-log/scout/2026-06-14-structured-covariance-r-control-scout.md`
  after checking local `hsquared`, `gllvmTMB`, `GLLVM.jl`, and `HSquared.jl`
  feature-branch patterns plus external sommer, ASReml-R, and gllvm
  documentation.
- Updated `ROADMAP.md`, `docs/design/05-roadmap.md`,
  `docs/design/09-multivariate-plan.md`,
  `docs/design/11-next-50-slices.md`, and
  `docs/design/14-factor-analytic-production-plan.md`.
- `git diff --check` - passed.
- Rose claim grep:
  `rg -n 'supports `cov|fits factor-analytic|diagonal multivariate model implemented|ASReml-style structured covariance|factor-analytic G matrices are implemented|structured covariance support' ...`
  - matched only the scout note's high-risk wording list and the after-task
    report line describing that grep.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
  errors / 0 warnings / 0 notes.
- Remote checks for previous commit `73f5738` (all green):
  - GitHub Actions R-CMD-check `27506408866`: passed.
  - GitHub Actions pkgdown `27506408863`: passed.
  - GitHub Pages build/deployment `27506468140`: passed.

Remote follow-up for committed slice `27bf20f`:

- `/opt/homebrew/bin/gh run list --limit 8` showed all current pushed checks
  green:
  - GitHub Actions R-CMD-check `27506805996`: passed.
  - GitHub Actions pkgdown `27506806005`: passed.
  - GitHub Pages build/deployment `27506853028`: passed.

## 2026-06-14 Structured covariance control guardrail

- Added a pre-marshalling guard for the reserved
  `engine_control$genetic_structure` field. The current R bridge accepts only
  `"unstructured"` on the opt-in multivariate target. `"diagonal"`, `"lowrank"`,
  and `"factor_analytic"` now error as planned instead of being silently ignored.
- Updated `R/hs_control.R`/`man/hs_control.Rd`, `NEWS.md`, and
  `docs/design/18-structured-covariance-r-control.md`.
- Formatting:
  `command -v air` - no `air` binary on PATH.
- `git diff --check` - passed.
- Focused tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test(filter = 'multivariate')"` - passed, 0 failures / 0 warnings /
  3 skips / 57 passes.
- Documentation:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::document()"` - passed; intended `hs_control.Rd` update kept and
  incidental package-level roxygen churn reverted.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 615
  passes.
- Rose claim grep:
  `rg -n 'supports genetic_structure|genetic_structure.*implemented|diagonal.*implemented|lowrank.*implemented|factor_analytic.*implemented|fits diagonal|fits factor|structured covariance.*implemented|structured covariance support' ...`
  - matched only the intended planned/not-implemented R error text and the
    prior check-log grep record.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
  errors / 0 warnings / 0 notes.

Remote follow-up for committed slice `774284f`:

- `/opt/homebrew/bin/gh run list --limit 5` showed all current pushed checks
  green:
  - GitHub Actions R-CMD-check `27507096865`: passed.
  - GitHub Actions pkgdown `27507096881`: passed.
  - GitHub Pages build/deployment `27507152621`: passed.

## 2026-06-14 Structured covariance rank guardrail

- Extended the structured covariance guard so the future `engine_control$rank`
  field errors on the current unstructured multivariate bridge instead of being
  silently ignored. This keeps future `lowrank` and `factor_analytic` controls
  fenced until the engine support and R bridge tests exist.
- Updated `R/hs_control.R`/`man/hs_control.Rd`, `NEWS.md`,
  `docs/design/18-structured-covariance-r-control.md`, and
  `docs/design/11-next-50-slices.md`.
- Formatting:
  `command -v air` - no `air` binary on PATH.
- `git diff --check` - passed.
- Focused tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test(filter = 'multivariate')"` - passed, 0 failures / 0 warnings /
  3 skips / 59 passes.
- Documentation:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::document()"` - passed; intended `hs_control.Rd` update kept and
  incidental package-level roxygen churn reverted.
- Full tests:
  `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 617
  passes.
- Rose claim grep:
  `rg -n 'rank.*implemented|supports rank|lowrank.*implemented|factor_analytic.*implemented|structured covariance.*implemented|rank.*silently ignored' ...`
  - matched only the intended "error rather than silently ignored" NEWS line,
    the planned/not-implemented R error text, and prior grep records.
- Pkgdown:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
  errors / 0 warnings / 0 notes.

## 2026-06-14 Sky-blue pkgdown theme refresh

- Rehydrated R repo:
  - `git status --short --branch` - clean `main` tracking `origin/main`
    before edits.
  - `git remote -v` - `origin` is `https://github.com/itchyshin/hsquared.git`.
  - `git log --oneline --decorate -5` - latest commit was `3e12fa1`.
  - `gh run list --limit 5` - unavailable on this shell (`gh: command not
    found`); live CSS was checked with `curl` instead.
- Live site CSS probe:
  - `curl -L --max-time 20 -s https://itchyshin.github.io/hsquared/` found
    `deps/bootstrap-5.3.8/bootstrap.min.css`.
  - The live Bootstrap CSS already contained `--bs-primary: #38A8DF` and
    `.navbar ... background:#38A8DF`, but Flatly still contributed the heavier
    Bootswatch palette and green/turquoise accents.
- Theme changes:
  - Removed `bootswatch: flatly` from `_pkgdown.yml`.
  - Set a cleaner sky palette in `_pkgdown.yml`: primary `#0ea5e9`, link
    `#0369a1`, link hover `#075985`, headings `#102a3b`, border `#dbeafe`.
  - Added `pkgdown/extra.css` so the navbar is explicitly sky-blue even when
    pkgdown emits `bg-light`.
  - Added `^pkgdown$` to `.Rbuildignore` so the site source directory is not
    bundled into the R package tarball.
- `git diff --check` - passed.
- Pkgdown build:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::build_site()"` - passed; output copied `pkgdown/extra.css` to
    `pkgdown-site/extra.css` and finished without problems.
- Generated-site CSS/HTML checks:
  - `rg -n "extra.css|#0ea5e9|navbar\\.bg-primary|bootswatch|flatly"
    pkgdown-site/index.html pkgdown-site/extra.css _pkgdown.yml` confirmed
    `extra.css` is linked from the built homepage and the sky colors are
    present.
  - Node/Playwright using system Chrome rendered the local built site. Final
    computed styles: desktop navbar background `rgb(14, 165, 233)`, navbar
    version text `rgba(255, 255, 255, 0.78)`, main link color
    `rgb(3, 105, 161)`, `extraCssLinked = true`; mobile navbar background
    `rgb(14, 165, 233)`, toggler filter `invert(1) grayscale(1) brightness(2)`,
    `extraCssLinked = true`.
- Pkgdown check:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  - First `devtools::check(document = FALSE, args = "--no-manual")` passed
    with one NOTE because top-level `pkgdown/` was not yet in `.Rbuildignore`.
  - After adding `^pkgdown$`, the rerun
    `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::check(document = FALSE, args = '--no-manual')"` passed, 0
    errors / 0 warnings / 0 notes.
- Remote follow-up for committed slice `6fa5548`:
  - `git push origin main` - pushed `3e12fa1..6fa5548`.
  - `/opt/homebrew/bin/gh run watch 27508145805 --exit-status` - R-CMD-check
    passed in 1m49s.
  - `/opt/homebrew/bin/gh run watch 27508145793 --exit-status` - pkgdown
    passed in 1m46s and deployed to `gh-pages`.
  - `/opt/homebrew/bin/gh run watch 27508191234 --exit-status` - Pages build
    and deployment passed.
  - `curl -L --max-time 20 -s https://itchyshin.github.io/hsquared/index.html`
    confirmed the live homepage links `extra.css`.
  - `curl -L --max-time 20 -s https://itchyshin.github.io/hsquared/extra.css`
    confirmed the deployed CSS contains `#0ea5e9`, `.nav-text.text-muted`, and
    `.navbar-toggler`.
  - Node/Playwright using system Chrome rendered the live site. Computed live
    styles: navbar background `rgb(14, 165, 233)`, version text
    `rgba(255, 255, 255, 0.78)`, and `extraCssLinked = true`.

## 2026-06-14 Structured covariance formula vocabulary

- Rehydrated R repo:
  - `git status --short --branch` - clean `main` tracking `origin/main`
    before edits.
  - `git remote -v` - `origin` is `https://github.com/itchyshin/hsquared.git`.
  - `git log --oneline --decorate -5` - latest commit was `cbf303e`.
  - `/opt/homebrew/bin/gh run list --limit 8` - latest R-CMD-check, pkgdown,
    and Pages runs were all green.
- Jason scout:
  - Read `.agents/skills/quantgen-scout/references/packages.md`.
  - Checked local `HSquared.jl` docs/tests/roadmap for `diag`, `lowrank`,
    `factor_analytic`, loadings, uniqueness, and structured covariance rows.
  - Checked local `gllvmTMB` latent-factor/loadings/covariance examples for
    invariant covariance-first interpretation.
  - Recorded persistent lessons in
    `docs/dev-log/scout/2026-06-14-structured-covariance-formula-vocabulary-scout.md`.
- Implementation:
  - `formula_status()` now has separate planned rows for
    `cov = us()`, `cov = diag()`, `cov = lowrank(K = 2)`, and
    `cov = fa(K = 2)`.
  - The planned `animal(..., cov = ...)` error now names all four covariance
    forms and points users back to the current opt-in `cbind()` multivariate
    path.
  - `docs/design/02-formula-grammar.md` and `docs/design/01-v0.1-contract.md`
    now distinguish the covered v0.1 default fit and opt-in experimental
    surfaces from planned structured covariance grammar.
  - Claims/capability/validation-debt rows now mention the structured
    covariance vocabulary without promoting support.
- Formatting:
  - `command -v air || true` - no `air` binary on PATH.
- Focused tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::test(filter = 'phase0-api|formula-animal')"` - passed, 0
    failures / 0 warnings / 0 skips / 119 passes.
- Full tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 620
    passes on the first run, then 622 passes after adding the
    `formula_status()` subset-print regression.
- Status-table smoke:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    'devtools::load_all(quiet = TRUE); s <- formula_status(); stopifnot(nrow(s) == 24L); ss <- s[s$category == "multivariate and factor analytic", c("term", "syntax_status", "fitting_status")]; print(ss)'`
    - passed and printed the parsed `cbind()` row plus planned `us`, `diag`,
    `lowrank`, and `fa` rows.
- `git diff --check` - passed.
- Pkgdown:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
    errors / 0 warnings / 0 notes.
- Rose claim check:
  - No new fitting or validation claim. This is formula-status, error-text, and
    design-memory work only; `cov = us()/diag()/lowrank()/fa()` remains planned
    long-format structured covariance grammar.

## 2026-06-14 Formula status print wording

- Follow-on polish after the structured covariance formula vocabulary slice:
  `print(formula_status())` now separates default fitting, opt-in experimental
  fitting, and planned/reserved grammar instead of saying "others parse-only".
- Focused tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::test(filter = 'phase0-api')"` - passed, 0 failures / 0 warnings /
    0 skips / 76 passes.
- Full tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 623
    passes.
- `git diff --check` - passed.
- Pkgdown:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
    errors / 0 warnings / 0 notes.
- Remote follow-up for previous committed slice `406e914`:
  - GitHub Actions R-CMD-check `27508736392`: passed in 1m54s.
  - GitHub Actions pkgdown `27508736390`: passed in 1m48s.
  - GitHub Pages build/deployment `27508781835`: passed.

## 2026-06-14 SNP-BLUP marker variance explained

- Rehydrated R repo:
  - `git status --short --branch` - `main` tracking `origin/main`, with
    the open SNP-BLUP marker-variance slice in the working tree.
  - `/opt/homebrew/bin/gh run list --limit 8` - latest remote R-CMD-check,
    pkgdown, and Pages runs were green for `93ff682`.
- Theme check prompted by maintainer screenshot:
  - `curl -L --max-time 20 -s https://itchyshin.github.io/hsquared/extra.css`
    confirmed the deployed CSS already pins the navbar to sky blue
    `#0ea5e9`.
  - No theme files were edited in this slice.
- Jason scout:
  - Checked local `HSquared.jl/src/genomic.jl`, where `centered_markers()`
    defines `W = M - 2p` and `fit_snp_blup()` fits marker effects at supplied
    variances.
  - Checked local `HSquared.jl/docs/src/genomic-models.md` and the twin
    SNP-BLUP after-task report for the supplied-variance boundary.
  - Checked VanRaden (2008), "Efficient Methods to Compute Genomic
    Predictions", DOI `10.3168/jds.2007-0980`, and Meuwissen, Hayes, and
    Goddard (2001), "Prediction of Total Genetic Value Using Genome-Wide Dense
    Marker Maps", DOI `10.1093/genetics/157.4.1819`.
  - Recorded persistent notes in
    `docs/dev-log/scout/2026-06-14-snp-blup-marker-variance-explained-scout.md`.
- Implementation:
  - The SNP-BLUP Julia bridge now requests the marker allele-frequency vector
    `p` from `HSquared.fit_snp_blup()`.
  - `hs_normalize_julia_snp_blup_result()` now stores
    `marker_allele_frequencies` and a `marker_variance_explained` result.
  - `marker_variance_explained()` now returns a live result for opt-in
    SNP-BLUP fits, with fallback derivation from the stored payload if needed.
  - The contribution is descriptive:
    `effect^2 * centered_marker_variance`, normalized across fitted markers.
    It is not a marker scan, p-value, LOD score, QTL result, or causal
    decomposition under linkage disequilibrium.
- Formatting:
  - `command -v air || true` - no `air` binary on PATH.
- Documentation:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::document()"` - passed; `man/marker_extractors.Rd` regenerated.
    Unrelated roxygen metadata churn was trimmed before closeout.
- Focused tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::test(filter = 'snp-blup|fit-object')"` - passed, 0 failures /
    0 warnings / 1 skip / 100 passes.
- Full tests:
  - `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 632
    passes.
- `git diff --check` - passed before closeout.
- Pkgdown:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
    errors / 0 warnings / 0 notes. The check reported INFO for optional
    suggested packages not available locally (`enhancer`, `nadiv`, and
    `pedigreemm`).
- Rose claim check:
  - Public wording now allows live `marker_effects()` and
    `marker_variance_explained()` only for opt-in supplied-variance SNP-BLUP.
  - QTL, GWAS, eQTL, marker scanning, p-values, LOD scores, fine mapping,
    causal marker-variance claims, and production genomic prediction remain
    planned or blocked unless future engine evidence exists.
- Remote follow-up for committed slice `27a7054`:
  - `git push origin main` - pushed `93ff682..27a7054`.
  - `/opt/homebrew/bin/gh run watch 27509522006 --exit-status` -
    R-CMD-check passed in 1m54s.
  - `/opt/homebrew/bin/gh run watch 27509522007 --exit-status` - pkgdown
    passed in 1m55s and deployed the site.
  - `/opt/homebrew/bin/gh run watch 27509571640 --exit-status` - Pages build
    and deployment passed. GitHub emitted the known non-failing Node.js 20
    deprecation annotation for Pages actions.

## 2026-06-14 light sky-blue pkgdown navbar

- Rehydrated R repo:
  - `git status --short --branch` - clean `main` tracking `origin/main`.
  - `git remote -v` - `origin` is `https://github.com/itchyshin/hsquared.git`.
  - `git log --oneline --decorate -5` - latest commit before this slice was
    `eec0e16` (`Record SNP-BLUP marker variance CI evidence`).
  - `gh run list --limit 5` - unavailable in this shell (`gh: command not
    found`), so remote CI was not live-refreshed before local edits.
- Live-site theme check before editing:
  - `curl -L --max-time 20 -s https://itchyshin.github.io/hsquared/extra.css`
    confirmed the deployed site already served a sky-blue navbar rule pinned
    to `#0ea5e9`.
- Theme update:
  - `_pkgdown.yml` primary/headings/body/border colours moved to a cleaner
    navy-on-sky palette.
  - `pkgdown/extra.css` changed the navbar from a saturated solid blue to a
    lighter sky gradient (`#e0f2fe` to `#bae6fd`) with dark navy nav text,
    a visible sky border, and a readable light search box.
- Whitespace check:
  - `git diff --check` - passed.
- Local site build:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::build_site()"` - passed and rebuilt `pkgdown-site/`.
- Visual smoke:
  - A system Chrome Playwright run against
    `file:///Users/z3437171/Dropbox/Github%20Local/hsquared/pkgdown-site/index.html`
    confirmed desktop and mobile navbar CSS:
    `linear-gradient(90deg, rgb(224, 242, 254) 0%, rgb(186, 230, 253) 100%)`
    with brand text `rgb(8, 47, 73)`.
  - Desktop and mobile screenshots were inspected, then removed from the
    working tree.
- Pkgdown:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "pkgdown::check_pkgdown()"` - passed, "No problems found."
- Package check:
  - `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
    /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
    "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0
    errors / 0 warnings / 0 notes. Optional suggested packages
    (`enhancer`, `nadiv`, `pedigreemm`) were not available locally.
- Rose claim check:
  - Visual/docs configuration only. No public capability wording, API, fitting,
    validation, or roadmap status was changed.
- Remote follow-up for committed slice `68101a3`:
  - `git push origin main` - pushed `eec0e16..68101a3`.
  - `/opt/homebrew/bin/gh run watch 27511733994 --exit-status` -
    R-CMD-check passed in 1m55s.
  - `/opt/homebrew/bin/gh run watch 27511734000 --exit-status` - pkgdown
    passed in 1m48s and deployed the site.
  - `/opt/homebrew/bin/gh run watch 27511780257 --exit-status` - Pages build
    and deployment passed. GitHub emitted the known non-failing Node.js 20
    deprecation annotation for Pages actions.
  - `curl -L --max-time 20 -s
    'https://itchyshin.github.io/hsquared/extra.css?theme-check=68101a3'`
    confirmed the live CSS now serves the light sky gradient and navy text.

## 2026-06-18 Retire static mission-control pkgdown article

- Context: a disposable live monitor now serves the mission-control board from
  gitignored `.mission-control/` (`python3 .mission-control/serve.py` on
  127.0.0.1:8781), so the static in-package pkgdown article was retired. The
  monitor is not a package surface.
- Edits:
  - `git rm vignettes/articles/mission-control.Rmd`.
  - `_pkgdown.yml` - removed the navbar menu entry and the articles-index entry.
  - `README.md` - removed the mission-control page paragraph.
  - `NEWS.md` - removed the unreleased "Added a pkgdown mission-control
    dashboard" bullet (the feature never shipped in a release).
  - `.gitignore` - added `.mission-control/`.
  - `.Rbuildignore` - added `^\.mission-control$`.
- Reference scan: `grep -rinE "mission.control"` across `*.Rmd/*.yml/*.md/*.R`
  (excluding the generated site, the monitor folder, and historical dev-log) -
  no remaining live references.
- Checks (RSTUDIO_PANDOC=.../aarch64, Rscript --vanilla):
  - `pkgdown::check_pkgdown()` - passed, "No problems found."
  - `pkgdown::build_site(preview = FALSE)` - built clean; rebuilt navbar has 0
    "Mission control" hits; no live page links to the removed article; stale
    orphan `pkgdown-site/articles/mission-control.html` removed locally.
  - `devtools::check(document = FALSE, args = "--no-manual")` - first run
    0 errors / 0 warnings / 1 NOTE (hidden-dir NOTE for `.mission-control`);
    after the `.Rbuildignore` fix, re-run 0 / 0 / 0.
- Not committed or pushed (awaiting maintainer go); remote CI not re-checked.

## 2026-06-18 R-safe finishing: suite green + release hygiene (WORDLIST, Language)

- Full test suite (`devtools::test_local`, silent reporter): 632 pass, 0 fail,
  0 warn, 32 skip-guarded (Julia bridge) across 18 files.
- Spelling: `spelling::spell_check_package()` reported 110 domain terms
  (technical vocabulary, not typos: NelderMead, PEV, VanRaden, sommer,
  polyploid, oneAPI, haplodiploid, etc.). `spelling::update_wordlist(vignettes =
  TRUE)` wrote `inst/WORDLIST` (110 terms); re-run spell_check 110 -> 0.
- DESCRIPTION: added `Language: en-US` (CRAN / spelling recommendation; was
  missing).
- `devtools::check(document = FALSE, args = "--no-manual")` after the additions:
  0 errors / 0 warnings / 0 notes.
- Context: the ultracode finish-readiness review (`wf_c6e56a2d-5bc`) ran its 8
  lens passes but synthesis stalled (~6 min silence, no punch-list output);
  proceeded hands-on with the above R-safe release-hygiene rather than block.
- Not committed or pushed (commit only when the maintainer asks).

## 2026-06-18 Engine-setup onboarding + review honesty fixes (5-lens parallel batch)

Implemented via a 5-lens parallel workflow (disjoint files); operator ran the
toolchain once after.

- Findings addressed (finish-readiness punch-list, docs/dev-log/2026-06-18-finish-readiness-punchlist.md):
  - #6/#24 engine-setup onboarding: README `### Engine setup`, vignettes/hsquared.Rmd
    `## Engine setup`, fitting-models.Rmd pointer; rewrote the install-failure stop()
    in R/hsquared.R to name `HSQUARED_JULIA_PROJECT`, `engine_control$julia_project`,
    `git clone https://github.com/itchyshin/HSquared.jl`, and the `engine = "validate"`
    fallback. Honest: HSquared.jl is a from-source Julia checkout.
  - #1 Julia fit-target honesty: the validate branch, bridge payload
    `julia_fit_target`, and `model_spec()` summary now all report `spec$bridge$target`
    (one source of truth) -> correct fit_multivariate_reml / fit_repeatability_reml /
    fit_two_effect_reml for opt-in models. Updated test-bridge-payload.R and
    test-model-spec-inspect.R, which pinned the old divergent strings.
  - #2 hs_stop_planned_marker(): no longer claims the parser accepts only animal(...)
    or lists genomic/single-step as unimplemented; points to formula_status();
    preserves the pinned "is planned, not implemented".
  - #4 hs_fit_boundary_flag(): detects a near-zero primary genetic/effect component
    by name (animal/genomic/single_step), so genomic and single-step fits surface
    at_boundary. New test-boundary-genomic.R.
- New tests: test-engine-setup-and-honesty.R (18 expectations), test-boundary-genomic.R.
- Checks (RSTUDIO_PANDOC + Rscript --vanilla): air format . clean; devtools::document()
  (RoxygenNote 7.3.2); devtools::test() 652 pass / 0 fail / 0 warn / 32 skip;
  pkgdown::check_pkgdown() "No problems found."; devtools::check(--no-manual)
  0 errors / 0 warnings / 0 notes (a transient 1-error from a stale pinned target
  string was fixed before this record).
- Follow-up noted: univariate default validate/preview reports
  "fit_animal_model(...)" (the spec$bridge$target descriptor) rather than the
  "fit_ai_reml" estimator name.
- Committed locally; push (CI evidence) deferred to a checkpoint per the
  local-checks-over-CI policy.

## 2026-06-18 Finishing wave 2: CI policy, claim-attribution honesty, negative controls

4-lens parallel workflow (wf_0edbc10e-468); operator verified + integrated.

- #10 CI policy: .github/workflows/R-CMD-check.yaml now triggers on `pull_request` +
  `workflow_dispatch` only (removed `push`), per the local-checks-over-CI policy;
  pkgdown.yaml keeps push-to-main (deploys docs) + workflow_dispatch. YAML validated.
- #5/#11 claim-attribution honesty: README.md + NEWS.md now clarify the engine-recovery
  results (gryphon, DGP) are validated locally via the R->Julia bridge, while public CI
  exercises the pure-R reference and skip-guards the live-engine tests. True claims kept;
  DESCRIPTION correctly left unchanged (no recovery claim there).
- #23 dead-code: REJECTED as a false positive — hs_fit_julia_payload() is the live
  default-fit dispatch (R/hsquared.R:387) plus 2 active tests; no change made.
- #21 negative control: new tests/testthat/test-negative-control.R (5 test-of-test
  blocks, ~26 assertions) proving the pure-R reference comparisons (Henderson, Mrode,
  gryphon band, REML band, DGP band) reject deliberately-wrong values.
- Checks: air format clean; devtools::document(); devtools::test() 678 pass / 0 fail /
  0 warn / 32 skip; pkgdown::check_pkgdown() clean; devtools::check(--no-manual) 0/0/0.
- Committed locally; push (CI evidence) deferred to a checkpoint.

## 2026-06-18 Finishing wave 3: engine-target docs + boundary-flag generalization

2-lens parallel workflow (wf_9e905c7a-fd6); operator verified + integrated.
- #12/#13: documented the engine_control$target menu in ?hs_control (R/hs_control.R):
  enumerates the 10 targets and clarifies engine="fit" uses the validated AI-REML
  estimator while engine="julia" with no target uses the dense fit_animal_model
  optimizer (results can differ at the optimizer level). Docs only; no behaviour change.
- #18: hs_fit_boundary_flag() (R/extractors.R) now flags at_boundary when ANY
  variance-component share <= tol (residual sigma_e2->0 / h2->1, or a near-zero second
  effect), subsuming the prior primary-component-only check; multivariate unchanged.
  3 new cases in test-boundary-genomic.R.
- Checks: air clean; devtools::document() (rewrote man/hs_control.Rd); devtools::test()
  681 pass / 0 fail / 0 warn / 32 skip; pkgdown::check_pkgdown() clean;
  devtools::check(--no-manual) 0/0/0.
- Committed locally; push deferred.

## 2026-06-18 Second-pass fix wave: ten findings (parser/multivariate/examples/docs/anchor)

6-lens parallel workflow (wf_017aac82-a65); operator verified + integrated.
- #1 nested-marker cryptic error: R/model-spec.R now names the offending term when an
  effect/marker is nested in an interaction/function term, instead of leaking base-R
  "invalid type (NULL)".
- #2 formula_status() gains a genomic(1 | id, markers = M) row (parsed / fitted opt-in
  genomic/SNP-BLUP); test-phase0-api.R pinned count 24 -> 25.
- #3/#4 multi-primary and multi-second-effect errors now name single_step() and
  maternal_genetic() respectively.
- #5 predict()/fitted()/residuals() give a clear multivariate-target message instead of
  the misleading "planned v0.1 contract"; new response_scale_methods man topic +
  _pkgdown.yml reference entry.
- #7 runnable Julia-free @examples for formula_status(), validation_status(),
  model_spec(), hs_data()/data_status() (executed by R CMD check).
- #8/#9/#11 hsquared-package landing page, README lead sentence, and the model-status
  article no longer under-state the shipped opt-in multivariate/genomic paths.
- #10 new tests/testthat/test-pev-reliability-anchor.R: independent hand-built MME
  PEV/reliability anchor + negative control (no Julia).
- #6 (loadings() shadowing stats::loadings) left as a flagged design call, not fixed.
- Checks: air clean; devtools::document() (new response_scale_methods.Rd, refreshed
  data_status/validation_status/hsquared-package Rd); devtools::test() 692 pass / 0 fail /
  0 warn / 32 skip; pkgdown::check_pkgdown() clean (after adding response_scale_methods to
  the reference index); devtools::check(--no-manual) 0/0/0.
- Committed locally; push deferred.

## 2026-06-18 Deep core fixes: 8 correctness/robustness findings (parser/pedigree/boundary)

2-lens parallel workflow (wf_f77503d3-1f1) on the deep-pass findings; operator verified.
- #1 single-level / zero-row factor fixed effect -> named error before model.matrix (was a
  base-R "contrasts can be applied only to factors with 2 or more levels" leak).
- #2 offset() -> clean unsupported-syntax error (was silently dropped from design + payload).
- #3 univariate response name uses hs_deparse(lhs) (log(y) labelled "log(y)", not "y").
- #4 cbind() derived/transformed columns rejected with a named message (was a confidently
  WRONG trait label from all.vars()).
- #5 bare "." in formula RHS -> clean unsupported-syntax error (was a base-R "'.' in formula
  and no 'data' argument" leak).
- #6 hs_topological_pedigree() rewritten from R recursion to an iterative Kahn / explicit-stack
  sort (byte-identical ordering verified over 200 random pedigrees; same cycle message); deep
  pedigrees no longer stack-overflow or get misreported as cycles.
- #7 negative variance reported as inadmissible (distinct from at/near-zero) via new
  at_boundary_class / at_boundary_condition; the at_boundary row stays TRUE/FALSE.
- #8 hs_fit_boundary_class() guards a non-list variance_components shape (no more
  "$ operator is invalid for atomic vectors" crash in summary()/fit_diagnostics()).
- New tests: tests/testthat/test-parser-robustness.R, tests/testthat/test-boundary-edge.R
  (operator fixed an over-strict expect_silent(print()) -> capture.output).
- Checks: air clean; devtools::document(); devtools::test() 734 pass / 0 fail / 0 warn /
  32 skip; pkgdown::check_pkgdown() clean; devtools::check(--no-manual) 0/0/0.
- Follow-up (docs, minor): formula_status()/man could note offset() and "." now error and
  multivariate cbind() requires bare columns.
- Committed locally; push deferred.

## 2026-06-18 Validation-backbone fixes (reference REML robustness + independent pedigree anchor)

2-lens parallel workflow (wf_8827ff98-4eb) on the validation cross-check findings. The
cross-check first confirmed the reference math is numerically CORRECT (independently
re-derived to machine precision); these fixes harden robustness + close a rigor gap.
- #3 hs_gaussian_loglik_reference() / hs_reml_estimate_reference() no longer propagate a raw
  chol() error at the h2->1 boundary: the loglik wraps the Cholesky in tryCatch (returns -Inf
  so Nelder-Mead retreats), and the optimizer returns convergence=99 on an inadmissible
  optimum instead of a spurious "converged" non-finite estimate. Well-conditioned behaviour is
  byte-identical (Mrode ML/REML loglik unchanged; gryphon + DGP recovery pass live).
- #1/#2 new tests/testthat/test-pedigree-mme-anchor.R: an INDEPENDENT hand-built lambda-form
  MME solve on the real 12-animal pedigree (with off-diagonal Ainv) anchors
  hs_solve_henderson_mme_reference fixed effects + EBVs (~1e-14), closing the circularity left
  by the diag(3)-only PEV anchor; includes a discriminating negative control.
- #4 data-raw/dgp-recovery-study.R header "Relative/absolute bias" -> "Absolute bias".
- New tests/testthat/test-reference-reml-boundary.R.
- Checks: air clean; devtools::document(); devtools::test() 753 pass / 0 fail / 0 warn /
  32 skip; pkgdown::check_pkgdown() clean; devtools::check(--no-manual) 0/0/0.
- Follow-up (maintainer): pin the PUBLISHED Mrode Example 3.1 EBVs against the physical
  textbook for an external-source canon gate (needs the book's digits).
- Committed locally; push deferred.

## 2026-06-18 Validation-evidence article (Curie/Fisher write, Rose honesty audit)

New `vignettes/articles/validation-evidence.Rmd`: the honest, single-source answer to "what
does `hsquared` mean by validated, and what is the actual evidence?" Written test-first — every
claim points at a named fixture/test/study; weakest-to-strongest ladder (gryphon anchor -> DGP
recovery -> external-package agreement -> supplied-variance Henderson/Mrode fixtures ->
independent hand-built MME anchors -> nadiv pedigree-inverse comparator -> negative controls),
the public-CI-vs-local split, and an explicit "Honest boundaries" section (REML-only, no
validated SE/CI, accuracy() is sqrt(reliability) not realised accuracy, opt-in models are
partial, no t>=2 multivariate recovery claim, no production/ASReml-parity claim).
- Registered in `_pkgdown.yml` (articles navbar + index). Rose adversarial honesty audit:
  clean, 0 findings (no claim exceeds `validation_status()`).
- Render-name fix: `build_article()` needs the registered name `articles/validation-evidence`
  (the `articles/` subdir is part of the pkgdown article name), not the bare slug.
- Checks: `pkgdown::check_pkgdown()` clean; `pkgdown::build_article("articles/validation-evidence")`
  renders cleanly (against a fresh local `devtools::install()` of hsquared). No R/ code change,
  so the prior green `devtools::test()` (753) and `devtools::check(--no-manual)` (0/0/0) hold.
- Committed locally; push deferred.

## 2026-06-18 Validation-evidence article: cross-doc audit + clarity pass (Rose + Pat)

Two parallel lenses on the just-committed article. Article numbers/test-names were first
independently fact-checked against source (gryphon 3.3954/3.8286/0.470; DGP n=420/120 reps/seed
20240613; h2 bias -0.0049/MCSE 0.0073; EBV grid 0.60/0.74/0.83; b_x 0.9896; closed-form REML
target `-0.5(2log2pi+3log2+log1.5+1)`; 5-animal Henderson + 12-animal Mrode fixtures; all 5
cited test files + 4 test descriptions exist) -> all confirmed correct.
- Rose cross-document audit (1 major + 1 should, both confirmed against source): the
  known-truth DGP recovery row in `docs/design/validation-debt-register.md` was marked
  `partial`, contradicting BOTH `validation_status()` (`R/validation-status.R` capability
  "known-truth DGP variance-component recovery (R reference)", status `rep("covered", 3L)`;
  pinned `covered` by `test-phase0-api.R`) AND `capability-status.md:34` (`covered`). The same
  row's Notes said "single h²=0.4 setting" while its own Evidence cell said "h² grid
  (0.2/0.4/0.6)". Fixed the register TOWARD the source of truth: `partial` -> `covered` and the
  stale note -> the grid description (aligned to capability-status.md wording). README,
  model-status.Rmd, DESCRIPTION, NEWS all confirmed consistent with the article.
- Pat cold applied-user read: applied 7 surgical clarity edits to the article (no claim
  change) — needs-Julia + status-column orientation in the intro; glosses for "predicate",
  "ADEMP", "boundary pinning", "lambda form"; an accurate "the three covered rows are X" line
  before the closing chunk; plainer large/inbred-pedigree caveat; a closing pointer to the
  Getting-started article for the fit workflow.
- Checks: `pkgdown::build_article("articles/validation-evidence")` re-renders cleanly;
  `pkgdown::check_pkgdown()` clean. Docs-only; no R/ code touched, so prior test 753 /
  check(--no-manual) 0/0/0 hold.
- Committed locally; push deferred.

## 2026-06-18 Article-set honesty sweep (Rose x3, clean) — release-readiness check

Extended the validation-evidence cross-doc audit to the three highest-drift-risk articles —
the ones describing opt-in/experimental and planned capabilities. Each lens checked the
article against the live source of truth (`validation_status()` in `R/validation-status.R`,
`docs/design/capability-status.md`, `R/formula-status.R`, and the actual extractor code).
- `vignettes/articles/genomic-prediction.Rmd` — CLEAN. Genomic GREML / marker-G / SNP-BLUP /
  single-step all framed experimental/opt-in/partial; every fit chunk uses
  `engine="julia", target=...` with `eval=FALSE`; QTL/GWAS/eQTL extractors correctly shown
  `# planned` (verified they error via `hs_fit_result()`); `marker_variance_explained` carries
  the no-QTL-signal disclaimer matching its roxygen.
- `vignettes/articles/multivariate.Rmd` — CLEAN. Experimental/opt-in/partial; explicit "no
  external comparator or committed t>=2 known-truth recovery"; `cov=us()/fa()` labelled
  "Planned, not fitted yet"; conservative (omits the optional sommer comparator rather than
  over-state it); closing handoff to `validation_status()`.
- `vignettes/articles/g-matrix-interpretation.Rmd` — CLEAN. Multivariate G/R reading partial;
  factor-analytic loadings/specific-variance/latent-BV/eigen-G correctly "roadmap" (verified
  `loadings()/specific_variance()/eigen_G()` abort via `hs_factor_g_extractor_planned()`);
  no phantom extractor advertised; `P_matrix()` correctly withheld; no runnable reserved-grammar
  example.
- Result: 0 findings across 3 independent adversarial lenses; no over- or under-claims. Three
  independent audits in a row (this + the validation-evidence cross-doc + the prior self-review)
  now return zero — the claim surface is consistent end-to-end. Audit-only; no files changed.

## 2026-06-18 Release-prep slice (maintainer-authorized): v0.1.0 + genetic_loadings + validate-returns-spec

Three maintainer-authorized items, implemented then run through a 5-lens adversarial review
workflow (wf_764021bf-9b8: Boole/Emmy/Curie/Grace/Rose, each finding independently verified;
7 raw -> 6 confirmed + 1 false positive). Confirmed findings folded in before commit.
- VERSION: DESCRIPTION 0.0.0.9000 -> 0.1.0; NEWS.md heading -> `# hsquared 0.1.0`; man/
  regenerated. v0.1 promotion predicate already SATISFIED (univariate Gaussian animal model,
  AI-REML, gryphon + DGP + sommer). No stale `0.0.0.9000` strings remain.
- RENAME (#6): reserved factor-analytic generic `loadings()` (shadowed `stats::loadings`) ->
  `genetic_loadings()`, aligning with the genetic_* extractor family and the design-doc proposal;
  `.default` now errors uniformly like its siblings. NAMESPACE clean (no stale `loadings`).
- VALIDATE-RETURNS-SPEC (#20): `hsquared(control = hs_control(engine = "validate"))` no longer
  stop()s; it messages ("Validated the v0.1 animal-model contract ... Julia fit target:
  HSquared.<target> ...") and returns invisible(spec). 4 validate tests updated error->message
  + spec assertions; roxygen (?hsquared @return, ?hs_control) updated.
- REVIEW FIXES folded in: (a) [3 lenses, should] the validate message no longer says "inspect it
  with model_spec()" (model_spec() is a constructor taking formula/data, not an inspector of the
  returned object) — reworded to "returned invisibly as a named list; assign it to inspect"; the
  @return now states it is the internal spec list, not the classed model_spec() object;
  (b) [Curie, minor] test-bridge-payload.R now binds + asserts the returned spec (parity with the
  other 3 validate tests). Did NOT return a classed hs_model_spec (both verifiers flagged that the
  naive upgrade breaks on genomic/single_step specs). [Grace, minor] noted process-only: pushing
  main runs the pkgdown deploy, not R-CMD-check — watch the deploy, don't claim CI-green-at-commit
  from R-CMD-check.
- Checks: air clean; devtools::document(); devtools::test() 784 pass / 0 fail / 0 warn / 27 skip
  (27 skip not 32 because Julia + sommer were available this run); pkgdown::check_pkgdown() clean;
  devtools::check(--no-manual) 0 errors / 0 warnings / 0 notes.
- Committed locally; push at the release checkpoint (will watch the pkgdown deploy run).

## 2026-06-18 Published Mrode Example 3.1 anchor (#5 / validation cross-check #1)

Closed the last external-canon validation gap: a CI-runnable, Julia-free fixture pinning the
package R reference Henderson MME solver against the PUBLISHED Mrode (2014, 3rd ed., p.39)
Example 3.1 EBVs. Mrode-canon research lens (background agent) first established, on evidence,
that the published digits are honestly pinnable: inputs + solutions confirmed against THREE
independent citable sources (masuday BLUPF90 tutorial citing Mrode 2014 p.39; austin-putz Mrode
chapter-3 R reproduction; Bioconductor GeneticsPed Mrode3.1) and independently re-solved (EBVs
reproduce to ~5e-9). NOT fabricated from memory.
- New `hs_mrode_example_3_1_fixture()` (R/validation-fixtures.R): 8-animal pedigree, 5 records
  (animals 4-8), sex fixed effect, sigma_a2=20/sigma_e2=40 (alpha=2). Ainv built by the tabular
  numerator-relationship method in pure base R (no nadiv) so the anchor is CI-runnable without
  Julia or optional packages. Published EBVs + the male-female sex contrast stored in `expected`.
- New `tests/testthat/test-mrode-published-anchor.R`: asserts the solver's EBVs equal the
  published digits to 1e-6 (empirically ~5e-9), the sex contrast (parameterization-free, from a
  male vs female record's fixed prediction) equals the published 0.95407223 (~9e-8), and a
  test-of-test rejects perturbed (+0.1) published EBVs.
- Cross-references updated: the stale NOTE in test-pedigree-mme-anchor.R (which declared the
  published pin out-of-scope / needs-the-book) now points at the new anchor; validation_status()
  evidence and validation-debt-register.md note the published anchor closes the
  self-generated-number gap. Status stays `partial` (supplied-variance BLUP, not VC estimation),
  so validation_status() row count is unchanged.
- Checks: air clean; devtools::test() 793 pass / 0 fail / 0 warn / 27 skip; pkgdown::check_pkgdown()
  clean; devtools::check(--no-manual) 0/0/0.
- Committed locally; push at the release checkpoint.

## 2026-06-18 Push + CI evidence (v0.1.0 release checkpoint)

Maintainer-authorized push of the full session (18 commits, `3666363..b0153aa`) to `origin/main`.
This is the v0.1.0 release checkpoint.
- `git push origin main` -> `3666363..b0153aa`.
- The push triggered ONLY the pkgdown deploy (NOT R-CMD-check) — confirming the CI-policy change
  (commit 7c54e28: R-CMD-check is now `pull_request` + `workflow_dispatch`; pkgdown deploys on
  push). Exactly as Grace's review predicted.
- `gh workflow run R-CMD-check.yaml --ref main` (workflow_dispatch) so the release commit carries
  an auditable green tick. `gh run watch 27803010380 --exit-status` -> success (1m50s).
- `gh run watch 27803006576 --exit-status` (pkgdown deploy, push) -> success (2m23s).
- `pages-build-deployment` 27803081687 -> success (23s).
- `curl -L https://itchyshin.github.io/hsquared/` -> HTTP 200 (v0.1.0 site live).
- All three workflows green at the release commit `b0153aa`.

## 2026-06-19 Cut the v0.1.0 git tag + GitHub release (maintainer-authorized)

Closed the one remaining R-lane action: the `v0.1.0` tag and GitHub release object did not exist
yet (version bumped, pushed, CI-green, but never tagged). Maintainer authorized "Tag + GitHub
release".
- Pre-state verified: `git tag -l` empty, `gh release list` empty.
- `git tag -a v0.1.0 -m "hsquared 0.1.0"` at HEAD `6d25c7d` (DESCRIPTION `Version: 0.1.0`; the two
  commits after the dispatched-green checkpoint `b0153aa` are docs-only — CI-evidence record + the
  handoff doc — so HEAD is the released state).
- `git push origin v0.1.0` -> `* [new tag] v0.1.0 -> v0.1.0`.
- `gh release create v0.1.0 --verify-tag --title "hsquared 0.1.0" --notes-file NEWS.md` (NEWS.md is
  a single `# hsquared 0.1.0` section, so it is the release body verbatim).
- Verified: `gh release view v0.1.0` -> tag=v0.1.0, name="hsquared 0.1.0", draft=false,
  prerelease=false, commit=main, published 2026-06-19T11:08:08Z; `gh release list` shows it as
  `Latest`. URL: https://github.com/itchyshin/hsquared/releases/tag/v0.1.0
- No package/code/docs change in this action (tag + release object only); prior test 793/0/0/27 +
  check(--no-manual) 0/0/0 from the release commit remain the standing evidence.

## 2026-06-19 (session 3 — autonomous gap-closing run)

- Rehydrated: `git status --short --branch`; `git log --oneline -8`;
  `gh run list --repo itchyshin/hsquared --limit 5` (pkgdown green);
  `gh issue list` both repos; `git -C ../HSquared.jl fetch origin && git -C ../HSquared.jl log
  origin/main --oneline -8`. Live finding: twin advanced to `ef5bda4`; the `:diagonal` multivariate
  bridge payload + `test/fixtures/structured_covariance_parity/` fixture landed (`ad6006d`, PR #63),
  making the #61 hand-off actionable. `which julia` → not found, so
  `hs_julia_bridge_available() == FALSE` (no live fit; engine legs skip-guarded).
- Five slices, each: `air format <files>` → `Rscript -e devtools::document()` (where roxygen/exports
  changed) → `Rscript -e devtools::load_all + testthat::test_file/test_dir` → commit → `git push`.
  - `d1c1002` diagonal multivariate fixture parity (#61): test 862/0/0.
  - `eee2275` Phase 2 grammar markers: `devtools::document()` regenerated NAMESPACE +
    `man/qg_effect_markers.Rd`; test 868/0/0.
  - `38cb0cb` gated family/marker error sharpens: test 870/0/0.
  - `cfdf4c1` doc/status reconcile (no code).
  - `34f8a29` review-barrier follow-ups (test tightening + marker masking note): test 876/0/0.
- Cumulative DoD checks (full state, run twice — after slice 4 and again after slice 5):
  - `Rscript -e 'pkgdown::check_pkgdown()'` → clean.
  - `RSTUDIO_PANDOC=... Rscript -e 'devtools::check(args="--no-manual", error_on="never")'`
    → **ERRORS=0 WARNINGS=0 NOTES=0** (the benign "installed roxygen2 8.0.0 doesn't match required
    7.3.2 → check() will not re-document" line only means `check()` skips re-docs; `document()` ran
    cleanly separately).
  - `Rscript -e 'devtools::test()'` full suite → **876 pass / 0 fail / 0 warn / 32 skip** (the
    skip count reflects live-engine legs guarded by `skip_if_not(hs_julia_bridge_available())` /
    `skip_on_cran()`; with no local Julia they skip).
- JSON: `python3 -c "json.load(open('.mission-control/status.json'))"` → valid (widget tally string
  updated to twin `ef5bda4` 25-partial/33; the gitignored widget is not committed).
- Two multi-agent workflows: map-and-design (6 scouts → Rose verify → Ada synthesis) and the
  review barrier (6 lenses → Ada+Rose audit, verdict CLEAN, Rose honesty-clean). Cross-lane comments
  posted via `gh issue comment` on `HSquared.jl#44` and `hsquared#23`.
- `git push origin main` for each slice; final HEAD `34f8a29`. R-CMD-check does not run on push
  (CI = pull_request + workflow_dispatch); pkgdown auto-deploys on push.

## 2026-06-19 (session 3 — LIVE ENGINE UNLOCKED + verified PEV bridge fix)

- **Julia was available all along — only off-PATH.** Found a `juliaup` install at
  `~/.juliaup/bin/julia` (julia 1.10.0 default; 1.12.6 available) + `~/.julia` +
  `/Applications/Julia-1.6.app`. The bridge goes LIVE in a dev (`load_all`) session with:
  `export PATH="$HOME/.juliaup/bin:$PATH"` and
  `export HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl"`
  (under `load_all`, `system.file()` resolves the default project to `hsquared/HSquared.jl`,
  the wrong path — the env var overrides it to the sibling). Set `NOT_CRAN=true` to run
  `skip_on_cran()` legs. Then `hs_julia_bridge_available()` → TRUE. **Future sessions: live
  verification of every engine-coupled slice is possible — do not assume skip-only.**
- Live verification (Julia 1.10 + HSquared.jl `origin/main`):
  - `testthat::test_file("tests/testthat/test-diagonal-multivariate.R")` → all pass incl. the
    live diagonal leg + LRT end-to-end (this session's #1 slice, previously skip-only). CLEAN.
  - `testthat::test_file("tests/testthat/test-julia-bridge.R")` → all pass against the real
    engine, incl. the reliability/PEV presence assertions (L87-90, L129).
  - `testthat::test_file("tests/testthat/test-multivariate.R")` → assertions pass, then a
    **JuliaCall/Rcpp segfault at teardown** (`Rcpp_precious_preserve`) — a known JuliaCall memory
    quirk under many `julia_eval` calls, NOT a model-logic failure. Run heavy live files one per
    process.
- **Verified PEV/reliability bridge fix shipped (`f38d7f4`, closes the univariate half of #21).**
  Confirmed live that `result_payload(::AnimalModelFit)` now carries the `:selinv`
  `prediction_error_variance` field (`hasproperty(...) == TRUE`); the bridge's unconditional
  `:dense` re-merge was clobbering it. Guarded the merge on
  `!hasproperty(hsq_result, :prediction_error_variance)` at all three `result_payload` routes.
  Post-fix live check: reliability/pev/accuracy finite, and `R PEV == result_payload(:selinv)
  PEV` → TRUE (merge correctly skipped, no redundant `:dense` factorization). Non-live suite
  `devtools::test()` → **876 / 0 / 0 / 32**. Pushed `f38d7f4`.

## 2026-06-19 (session 3 — full live bridge hardening + non-Gaussian bridge #44)

- **Full live bridge hardening** (each test file in its own process to dodge the JuliaCall/Rcpp
  teardown segfault; env: `PATH=$HOME/.juliaup/bin:...` + `HSQUARED_JULIA_PROJECT=../HSquared.jl`
  + `NOT_CRAN=true`). Every experimental bridge target passes against `HSquared.jl origin/main`:
  `julia-bridge` 94, `diagonal-multivariate` 26, `repeatability` 31, `common_env` 22, `maternal`
  13, `genomic` 39, `single_step` 16, `snp_blup` 25, `validation-fixtures` 104 (incl. the live
  `sommer` comparator), `mrode-validation` 8, `pev-reliability-anchor` 11 — **0 failures**.
  `test-multivariate.R` segfaults at teardown (its assertions pass; `test-diagonal-multivariate.R`
  covers the same engine path cleanly).
- **Non-Gaussian bridge (#44, `31f200c`)** — built the R bridge to the twin's `nongaussian_result_payload`
  (`29b66c5`). Commands: `devtools::document()` (regenerated `man/hsquared.Rd` + `man/hsquared-package.Rd`,
  NAMESPACE unchanged — bridge fns are internal); `air format`; non-live `devtools::test()` →
  **889 / 0 / 0 / 33**; **live** `test-nongaussian.R` (Poisson + Bernoulli fits) passes against the
  real engine; `pkgdown::check_pkgdown()` clean; `devtools::check(args="--no-manual")` → **0 / 0 / 0**
  (first pass raised a non-ASCII WARNING from an em-dash I put in an error string at
  `R/model-spec.R:545` → replaced with ASCII; comment em-dashes are tolerated).
- Rose audit: slice surfaces clean; fixed 4 stale "non-Gaussian remains planned" claims
  (`R/hsquared.R`, `R/hsquared-package.R`, `README.md`, old `#6` NEWS line) → re-checked clean.
- Pushed `31f200c`. Cross-lane: division-of-labour on twin #61, bridge-landed on twin #44.

## 2026-06-19 (session 3 — evolvability / G-geometry bridge #55)

- New `R/evolvability.R` (eigen_G/g_max/mean_evolvability/evolvability/respondability/
  conditional_evolvability/autonomy); flipped the reserved `eigen_G()`; updated 2 `test-fit-object.R`
  assertions; added `g_matrix_geometry` to `_pkgdown.yml`.
- `devtools::document()` (NAMESPACE + `man/g_matrix_geometry.Rd`); `air format`; non-live
  `devtools::test()` → **907 / 0 / 0 / 34**; **live** `test-evolvability.R` parity (R == engine
  `evolvability.jl` on a random PD G) passes; `pkgdown::check_pkgdown()` clean;
  `devtools::check(args="--no-manual")` → **0 / 0 / 0**. Pushed `35bf92f`; posted on twin #61.
- Ratified the FA rotation convention on twin #61 (the Julia thread was holding on R's ack).

## 2026-06-19 (session 3 — post-fit gwas() marker scan #45/#23)

- New `R/gwas.R` (`gwas(fit, markers)` + `hs_gwas` print); updated `hs_marker_extractor_default` + 5 `test-fit-object.R` marker assertions; added `gwas` to `_pkgdown.yml`.
- `devtools::document()`; `air format`; non-live `devtools::test()` → **917 / 0 / 0 / 35**; **live** `test-gwas.R` (fit + scan + element-wise engine parity + relatedness-vs-fixed-effect discriminator) passes; `pkgdown::check_pkgdown()` clean; `devtools::check(args="--no-manual")` → **0 / 0 / 0**. Pushed `23aab52`.
- First live fit attempt failed on pure-noise data (`fit_ai_reml could not keep variance components positive`); fixed the test to simulate pedigree-structured breeding values (additive variance identifiable). Rose audit CLEAN. Posted on twin #45 + R #23.

## 2026-06-20 (session 3 — fitted estimated-VC fixture #46/#49)

- Mirrored twin `test/fixtures/animal_model_fitted_target/` into `tests/testthat/fixtures/`; new `test-fitted-target-fixture.R` (julia-free internal consistency + a live estimated-VC reproduction).
- `air format`; non-live `devtools::test()` -> **922 / 0 / 0 / 36**; **live** test reproduces the serialized REML estimates (VC/beta/h2 to 1e-4, EBVs/reliabilities to 1e-3); `pkgdown::check_pkgdown()` clean; `devtools::check(args="--no-manual")` -> **0 / 0 / 0**. Pushed `7761055`; posted on twin #46.
- Note: corrected an inbreeding-naive `reliability == 1 - PEV/sigma_a2` check to the inbreeding-aware implied-A_ii identity (the fixture includes inbred animals).

## 2026-06-20 (session 3 — variance_along_gradient + full live hardening v2 + handoff)

- `variance_along_gradient()` completes the evolvability bridge (`95e598a`): hand-computed + live engine parity (both normalize modes). test 925/0/0/36; check(--no-manual) 0/0/0; check_pkgdown clean.
- **Full live hardening v2** against twin main `616339e` (one file/process to dodge the JuliaCall teardown segfault): every experimental bridge target passes — julia-bridge 94, diagonal-multivariate 26, nongaussian 22, evolvability 33, gwas 20, fitted-target 14, repeatability 31, genomic 39, single-step 16, snp-blup 25, validation-fixtures 104 (incl. live sommer) = **424 live assertions, 0 fail**.
- Wrote `docs/dev-log/after-task/2026-06-20-session-handoff-3.md` (START-HERE) + refreshed the mission-control widget (gitignored).

## 2026-06-20 (session 3 — public-article reconciliation)

- Updated 4 pkgdown articles to reflect the session's shipped capabilities (gwas, eigen_G/evolvability, non-Gaussian) with experimental/uncalibrated framing; QTL/eQTL/loadings/calibration stay reserved. `genomic-prediction`/`g-matrix-interpretation` (`c81f83c`), `model-status`/`qtl-gwas-eqtl-status` (`e64fd3d`).
- All four `rmarkdown::render()` cleanly (eval=FALSE); `pkgdown::check_pkgdown()` clean. Pushed.

## 2026-06-20 (session 3 — cross-lane engine-scaling prototypes #51/#58)

- **Lane: coordinator / cross-lane research. No R package code touched** (only
  `docs/dev-log/prototypes/` + dev-log). So the standard R checks (document/test/
  check/pkgdown) are not applicable to this slice; evidence is the runnable Julia
  prototypes + their recorded outputs. Engine: local Julia 1.10.0 (`~/.juliaup/bin/julia`).
- **Matrix-free genomic REML** (`prototypes/matrix-free-genomic-reml.jl`):
  - `~/.juliaup/bin/julia hsq_proto_reml_mf.jl` → exit 0.
  - `-2logL` matfree vs dense `abs_err = 2.27e-13`; analytic AI score == central
    finite-difference (all printed digits).
  - VC recovery (truth va=0.60 ve=1.00): n=2k vâ=0.599; n=8k vâ=0.581; n=30k vâ=0.609;
    n=80k vâ=0.575 (setup 2.80s + solve 5.02s, 6 it) — dense G=51.2 GB skipped.
  - SLQ logdet(K) rel-err 2.8e-3 (nv=24, L=30).
- **Metal GPU `W(W'B)`** (`prototypes/gpu-vapply-bench.jl`, `gpu-precision-check.jl`),
  Metal.jl in `/tmp/hsqgpu` project, `functional=true`:
  - speedups 3.36×(k=1) → 10.7×(k=32, n=200k); rel-err ~1e-6 for k≤8.
  - **Precision finding (verified vs Float64):** CPU-f32 stays 5.6e-7 for all k;
    Metal-f32 jumps to 3.0e-2 at k≥32 (reduced-precision wide-GEMM, k-triggered).
- **Symbolic-once `cholesky!`** (`prototypes/symbolic-once-cholesky.jl`):
  - `~/.juliaup/bin/julia hsq_symbolic_once.jl` → exit 0.
  - solve rel-err(reuse vs fresh) = **0.00** at q∈{5k,20k,50k,100k}; speedup
    1.43–2.55× (constant-factor, flat in q).
- **R-lane-verified by reading source:** `fit_ai_reml` (`likelihood.jl:378-381`)
  full-factors each iteration (symbolic-once opportunity) and lacks a `try/catch`
  around the factorization (uncaught PosDefException risk); `pedigree_inverse` is
  dense-capped at 10 000 rows (`pedigree.jl:106-109`).
- **Design pass `wms6xwbj4`** (9 agents, adversarial verify): plan + risk register
  saved verbatim to `prototypes/engine-scaling-plan.md`; independently reproduced
  the 2.3e-13 low-rank result.
- Cross-lane comments to the twin: HSquared.jl #51 `issuecomment-4757925615`
  (brief), #58 `issuecomment-4757928611` (pointer) + `issuecomment-4758004745`
  (engine improvements, attribution-separated).

## 2026-06-20 (session 3 — APY sparse genomic inverse, ultracode-verified)

- **Lane: coordinator / cross-lane research. No R package code touched.** Engine:
  local Julia 1.10.0. Jason scout -> equation-level APY spec
  (`docs/dev-log/scout/2026-06-20-apy-sparse-ginv-scout.md`).
- `~/.juliaup/bin/julia hsq_proto_apy.jl` -> exit 0 (after a 4-lens adversarial
  panel `wgztxoz8y` rebuild).
- (i) SHARP correctness (c<n, scattered core): ||G_APY^-1 - inv(Sigma)|| = 3.41e-15;
  ||G_APY^-1*Sigma - I|| = 5.6e-15; nn=1 vs (G+λI)^-1 = 4.3e-15; floor guard active
  (66 floored at ridge 1e-12); marker-built==dense-built = 2.9e-16.
- (ii) recovery: lowrank(d=250) EIG98 core=234 (12% n) fidelity 0.978 acc-vs-true 0.930
  nnz/dense 0.22 ; VanRaden EIG98 core=1173 (59% n) fidelity 0.9995 acc-vs-true 0.733
  nnz/dense 0.83 -> APY compresses only when genomic dim << n.
- (iv) rSVD core sizing == dense eig exactly (234==234, 1173==1173), G never formed.
- (v) scale build (G never formed; core from rSVD): n=10000 core381 nnz/dense 0.075
  0.43s ; n=40000 core571 0.028 3.22s ; n=100000 core761 0.015 11.72s.
- Adversarial panel verdict: no blockers; core math independently confirmed 2.7e-16;
  first draft's validation hardened (sharp c<n test, dual GRM, truth comparison,
  rSVD sizing, complexity label, single-step framing). Validation debt: real-marker
  recovery + BLUPF90 comparator.

## 2026-06-20 (session 3 — Julia engine unlocks: Meuwissen-Luo + symbolic-once PR seed)

- After a discovery workflow (`wi3omhdhz`) mapped the full remaining surface; user
  chose "Julia engine unlocks first". No R package code touched.
- **Meuwissen-Luo O(n) sparse inbreeding** (`prototypes/meuwissen-luo-inbreeding.jl`,
  stdlib-only): `~/.juliaup/bin/julia hsq_proto_ml_inbreeding.jl` -> exit 0.
  - max|F_ML - F_dense| = **0.00e+00** vs an independent dense tabular A at n=500/2000,
    1500-inbred (max F=0.5), and 2000 with 35% one-parent-known.
  - scale (dense numerator-relationship hard-throws > 10,000): n=20k 0.48s, 50k 1.53s,
    100k 3.48s, 250k 9.86s.
- **Symbolic-once fit_ai_reml PR seed** (`prototypes/symbolic-once-fit_ai_reml.patch.md`):
  diff + parity test for the cholesky!-reuse refactor (twin's lane to apply).

## 2026-06-20 (session 3 — random-regression bridge, LIVE-VERIFIED)

- Bridge activation of engine #54 (RR/reaction-norm). Implemented by the
  emmy-r-package-architect agent (mirroring the multivariate target); live
  verification + commit by the operator.
- Files: model-spec.R (rr() parser), bridge-payload.R, julia-bridge.R (target reg +
  `hs_fit_julia_random_regression_payload` + normalizer + R-side legendre helpers),
  hsquared.R (dispatch), extractors.R (5 new exported extractors), formula-status.R,
  NEWS.md, capability-status.md, _pkgdown.yml, test-random-regression.R (new).
- New extractors: `rr_covariance`, `random_coefficients`, `rr_genetic_variance(at=)`,
  `rr_heritability(at=)`, `rr_correlation(at=)`. Trajectories computed in R from K_g +
  the normalized-Legendre basis.
- Agent non-live checks: `air format` exit 0; `devtools::document()` OK;
  `devtools::test()` **996 pass / 0 fail / 33 skip**; `pkgdown::check_pkgdown()` clean;
  `devtools::check(--no-manual)` **0 / 0 / 0**.
- **LIVE (operator, PATH=~/.juliaup/bin, HSQUARED_JULIA_PROJECT=sibling):**
  - ad-hoc parity (`/tmp/rr_live_verify.R`): bridge vs direct
    `fit_random_regression_reml` on identical data → max|dK_g|, |d sigma_e2|,
    |d loglik|, max|d coef| all **0.00e+00**; h2(at 2/5/8)=0.927/0.922/0.915.
  - committed `test-random-regression.R` run live → **FAIL 0 | WARN 0 | SKIP 0 |
    PASS 57** (live fit + extractors against the real engine).
- Grammar `animal(rr(age, order=k) | id, pedigree=ped)` is PROVISIONAL (proposed to
  twin #61, awaiting ack); shipped experimental; homogeneous residual only,
  permanent-environment + heterogeneous residual still planned.

## 2026-06-20 (session 3 — doc reconciliation + handoff-4)

- Reconciled R-doc drift vs engine 2f62781 (Rose lens): LOCO, single-step H-inverse
  construction, and selinv-PEV reworded from false "planned" to "engine-shipped, R
  surfacing pending"; the 7/12-seed recovery gate paired with the twin #78/#79
  no-detectable-bias result; experimental fences kept. Engine exports verified:
  loco_mixed_model_marker_scan (genomic.jl:498), single_step_inverse /
  fit_single_step_reml (HSquared.jl:66/68, genomic.jl:2163).
- `devtools::document()` regenerated gwas.Rd + covariance_standard_errors.Rd;
  `devtools::test()` no failures (live tests skip without Julia);
  `pkgdown::check_pkgdown()` clean.
- Wrote docs/dev-log/after-task/2026-06-20-session-handoff-4.md (START-HERE;
  inherits the /goal, mission-control, the discovery-map plan, the live-bridge recipe).

## 2026-06-20 (session 4 — multivariate t=2 validation evidence + metafounder Gamma reservation)

- **Multivariate t=2 validation slice** (the twin's #1 cross-lane handoff #10/#49 ↔
  twin #47/#49; backlog #1). Two reproducible `.Rbuildignore`d studies + doc/register
  reconcile. Files: data-raw/multivariate-recovery-study.R (bug-fixed + RECORDED RESULT
  filled), data-raw/multivariate-comparator-study.R (new), docs/design/capability-status.md,
  docs/design/validation-debt-register.md, NEWS.md.
  - **Harness bug fixed:** the recovery study called `hsquared(..., engine_control=...)` at
    top level (no `control = hs_control(engine="julia", ...)` wrapper), so the default
    `engine="fit"` path rejected every fit and `error=function(e) NULL` silently dropped
    them (reported 0/4 converged in 0.3s). Added the wrapper + surfaced the first error.
  - **LIVE recovery (operator, PATH=~/.juliaup/bin, HSQUARED_JULIA_PROJECT=sibling,
    NOT_CRAN=true):** n_rep=100, **100/100 converged**, cold-start diag(2) (not truth),
    12.6s/rep. Every target within bias ± 2·MCSE (no detectable bias); EBV accuracy
    0.790/0.742. Corroborates twin #78/#79 with tighter MCSE (100 vs 12 reps).
  - **sommer comparator (no Julia):** sommer 4.4.5 `mmer` full-unstructured residual vs the
    twin `phase4_multitrait_parity` target, A rebuilt via nadiv (not copied):
    max|dG0|=7.5e-5, max|dR0|=7.6e-6, max|dβ|=1.8e-6, max|dh2|=6.8e-5, EBV cor=1.0,
    max|dEBV|=4.4e-5; loglik offset 113.74 (additive constant, not compared). Recovers the
    off-diag R0[2,1] the in-suite diagonal-residual `mmes` check can't (mmes errors on an
    unstructured residual here). V4-MV-REML kept **partial** (promotion twin-gated).
  - Adversarial verification: 4-lens Workflow (jason/rose/henderson/boole). Both comparator
    lenses **sound** (correctness agent re-ran and reproduced every number, confirmed the
    113.7 offset + A symmetry + mmes error); nits applied (loglik offset reporting, column
    order, claim-boundary). check 0/0/0, check_pkgdown clean.
- **Metafounder Gamma reservation** (grammar lens should-fix). R/qg-effects.R: added
  `Gamma = NULL` to the inert `metafounder()` marker signature + @param (so the proposed
  `metafounder(1|id, pedigree=ped, Gamma=Γ)` grammar isn't silently swallowed by `...`;
  marker stays planned-not-implemented). `devtools::document()` regenerated
  man/qg_effect_markers.Rd. check 0/0/0.
- Q1–Q4 metafounder contract + the MV evidence posted to twin #61
  (issuecomment-4758935657 + -4758935789). Pushed `ad6584f..a9c81d4`.
- **CI evidence:** pkgdown run `27876651312` **success** (2m26s) + pages build
  `27876713163` **success** on `main @ a9c81d4`. (R-CMD-check is workflow_dispatch
  + PR-only per repo CI policy; local rcmdcheck 0/0/0 is the push gate.)

## 2026-06-20 (session 4 — batched CPU marker-scan prototype)

- `docs/dev-log/prototypes/batched-marker-scan.jl` (new) + README §7. Exact
  drop-in speedup for the engine's post-fit scan (`_mixed_marker_scan_stats`,
  genomic.jl:627): one BLAS-3 `cholV \ W` vs the per-marker BLAS-2 loop.
- **LIVE (Julia 1.10, n=2000 p=3 m=20000):** max|d effects|=2.9e-16,
  max|d se|=5.6e-17, max|d chisq|=3.6e-14, max|d denom|=1.8e-12 (machine
  precision — BLAS reassociation) vs the per-marker loop that mirrors the engine
  line-for-line; **46.8×** (38.19s → 0.82s), EXACT not an approximation.
  Self-verifying (two independent code paths agree to 1e-16 across 20k markers).
- No R package code; no public claim. Twin's lane to apply (#48/#51).

## 2026-06-20 (session 4 — AI-REML convergence/robustness hardening prototype)

- `docs/dev-log/prototypes/ai-reml-hardening.jl` (new) + README §8. Faithful dense
  mirror of the engine AI-REML loop (`likelihood.jl:356-420`) demonstrating two
  gaps + a verified fix: (1) the unguarded `cholesky(Symmetric(lhs); check=true)`
  at `likelihood.jl:381` throws a cryptic `PosDefException` on a rank-deficient /
  collinear X; (2) σ²ₐ→0 step instability.
- **LIVE (Julia 1.10):** well-posed raw == guarded to **0.00e+00** (non-regressive);
  collinear X → raw `PosDefException` (cryptic) vs guarded clear error ("X is
  rank-deficient (rank 2 < 3 columns)…"); faithfulness over 20 seeds mean
  sa2=0.652 (truth 0.6) / se2=0.930 (truth 1.0), 20/20 converged.
- No R package code; no public claim. Twin's lane to apply (#58).

## 2026-06-20 (session 4 — ggplot2 visualization layer, maintainer-directed)

- Maintainer asked for brms/bayesplot-style result visualization (consistent with
  the drmTMB/gllvmTMB sisters). Decisions: ggplot2 engine; in-package `autoplot()`
  methods, modular for later extraction; all four figure families.
- `R/autoplot.R` (new): `autoplot.hsquared_fit(type=)` -> variance+h2 forest (95% CIs),
  EBV caterpillar (+-1.96 sqrt(PEV) bands, trait facets), rotation-invariant G
  correlation heatmap (NO raw loadings); `autoplot.hs_gwas()` -> Manhattan with the
  uncalibrated-significance banner; `hs_recovery_forest()` (bias +-2*MCSE);
  `theme_hsquared()`. ggplot2 + stats -> Imports; `_pkgdown.yml` Visualization group.
- **LIVE render** (operator, bridge recipe) of all 5 figures from REAL fits (univariate
  + multivariate + gwas via the live bridge; recovery from the real s4 numbers) ->
  `/tmp/hsq-figs/*.png`, visually QA'd (all correct + honest banners).
- air format; `devtools::document()` (reexports.Rd + 3 new man pages); `test-autoplot`
  **12/12 pass**; `rcmdcheck(--no-manual)` **0/0/0** (fixed one non-ASCII `h2` ->
  `²`); `pkgdown::check_pkgdown()` clean.
- Follow-up: `vignettes/articles/visualizing-models.Rmd` (new) — a "Visualizing an
  animal model" gallery that **renders** every `autoplot()` figure on the pkgdown
  site from small illustrative fit objects (`eval = TRUE`, ggplot2 only, no engine
  needed at build), with the real `autoplot()` calls shown. Added to `_pkgdown.yml`.
  `rmarkdown::render()` OK; `check_pkgdown()` clean.

## 2026-06-20 (session 4 — rr_eigenfunctions flip + twin #61 reconciliation cleanups)

- Acting on the twin's #61 cross-lane reconciliation (she re-baselined what's
  already flipped + what R can flip now). **R-owned flip:** `rr_eigenfunctions()`
  extractor (`R/extractors.R`) — the rotation-invariant eigen-decomposition of
  `K_g` as covariate functions (eigenvalues, variance_explained,
  sign-canonicalized eigen_coefficients, eigenfunctions `psi_j(t)`); computed in R
  via `hs_g_eigen` + `hs_legendre_design` (conventions already engine-verified).
- **LIVE parity (operator):** `rr_eigenfunctions` == `HSquared.rr_eigenfunctions`
  on a fixed K_g/grid AND on a live RR fit — eigenvalues 1.1e-16,
  variance_explained 1.1e-16, eigenfunctions 1.0e-15. Committed mock + skip-guarded
  live parity tests (`test-random-regression.R`).
- **Twin ratified the `rr()` grammar (#61):** dropped the PROVISIONAL/may-change
  caveat from NEWS + capability-status + the parser comment (now "ratified").
- **Honesty:** reconciled `docs/design/21-nongaussian-la-va-method.md` — the
  Laplace path now fits experimentally since `31f200c`; VA / method-control /
  binomial-with-trials / promotion past partial remain planned.
- Also posted decisions on #61 unblocking the twin: FA **invariants-only** (ship
  the eigenbasis payload), metafounder **option (a)** combined (m+n) inverse,
  freeze method wire-token `"laplace"`/`"variational"`, binomial-with-trials in
  near-term scope.
- air format; `devtools::document()`; `test-random-regression` 12 mock + live all
  pass; `rcmdcheck(--no-manual)` **0/0/0**; `check_pkgdown()` clean.

## 2026-06-20 (session 4 — R-authored plotting STANDARD + impl alignment)

- Maintainer: "R sets the plotting standard, then Julia mirrors it." Authored
  `docs/design/24-plotting-standard.md` (figure catalog incl. QQ/λGC/RR-surface;
  binding per-figure honest-status contract; `hsquared_meta` schema + mapping to
  the engine flags; two-column engine-field↔R-shape data contract incl. full
  `marker_manhattan_data`; explicit R↔Julia↔preparer naming map; theme; flexible
  v1). Builds on the twin's `13-plotting-layer.md` architecture.
- **Adversarial review** (4-lens Workflow: Florence/Pat/Rose/Hopper) — all
  `minor_gaps`, sound in intent/honesty/mirrorability; applied every should-fix
  (added QQ/λGC, genomic-coordinate Manhattan shape, per-figure §2 rows, low-h²
  flag, h² annotate-not-clamp, engine-field data contract, explicit naming map,
  parity test honestly marked PLANNED).
- **Impl alignment:** `R/autoplot.R` h² interval now surfaces RAW bounds +
  annotates a `[0,1]` crossing instead of silently clamping (matches §2 + the
  engine boundary-throw discipline). test-autoplot 18 pass; rcmdcheck 0/0/0.
- Posted the standard to the twin on #61 (R-set, flexible, asks: confirm the §6
  naming map; the live R↔engine parity test is the shared §5 drift mitigation).

## 2026-06-20 (session 5 — answered twin #93 plotting plot-data contract + §3 fix)

- Answered the twin's **8 structured questions on `HSquared.jl#93`** (plotting
  plot-data contract; the engine adapts its `*_plot_data` payloads to `autoplot.R`)
  and **settled the h² clamp divergence: RAW + annotate, no clamp** (engine ships
  raw `lo`/`hi`; R owns the `[0,1]` annotation). Reply
  `#93 issuecomment-4759668333`; pointer on `#61 issuecomment-4759670038`.
- Draft **adversarially verified** before posting (4-lens Workflow `wf_009f0a43-922`:
  Hopper/Florence/Rose/Pat). All `minor_gaps`; applied every should-fix + nit:
  Q1 panel-scoped rbind; Q2 pinned coordinate field names (`covariate`/`surface`;
  `covariate`/`eigenfunctions`/`axis`/`variance_explained` — `axis` not `rank`);
  Q3a read-only `method` field already exists (defer only the settable arg);
  Q3b/divergence scoped as a payload request; Q4 flat status fields + cite the §3
  BINDING rule honestly; Q7 added the rotation-arbitrary/span-ambiguity directional
  caveat (arrow biplot = new §1 figure); Q8 EBV field named `value` (not `ebv`) +
  `pev_scale` honest-status; TL;DR parity-net marked PLANNED.
- **Real fix surfaced by Florence:** `hs_autoplot_reaction_norm()` shipped without
  `rotation_status`, defaulting to `"not_applicable"` — a self-violation of the
  standard's §3 BINDING rule (`type ∈ {g_matrix,g_geometry,reaction_norm,rr_surface}`
  MUST be `"rotation_invariant"`). Fixed: `R/autoplot.R` now emits
  `rotation_status="rotation_invariant"` + `interval_status="descriptive"` for
  reaction_norm; added a `testthat` guard (`test-random-regression.R`).
- **Standard amended** (`docs/design/24-plotting-standard.md` §3/§4/§6) to encode
  the field decisions (flat engine status fields; pinned coordinate/EBV field names;
  `interval_status`/`interval_method`; `breeding_values_plot_data` in the naming map)
  — standard + #93 reply are one source of truth.
- Commands: `air format R/autoplot.R tests/testthat/test-random-regression.R` (clean);
  `devtools::document()` (no man-page diffs); `testthat::test_file` on test-autoplot
  (36 pass) + test-random-regression (60 pass, 1 on-CRAN skip);
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
  No live engine needed (reaction_norm fixture is a pure-R `hs_new_fit`).
- CI (commit `878638c`): pkgdown run `27880741356` **success**; pages deploy green.

## 2026-06-20 (session 5 — consume genetic_correlation_plot_data in autoplot + low-h² flag + live parity)

- Backlog #2 buildable subset (g-correlation set-C). `hs_autoplot_g_matrix()`:
  auto-detect the engine `genetic_correlation_plot_data` payload (recompute
  fallback via `genetic_correlation()`), add a **low-h² imprecision flag** on
  off-diagonal cells (plotting standard §2; heuristic, default `low_h2 = 0.1`,
  degrades gracefully on absent/NA/mismatched h²), and a `intToUtf8` dagger marker
  + subtitle. New live parity guard `test-plot-data-parity.R`
  (`genetic_correlation_plot_data` == `cov2cor(G)`; + a live-marshalled end-to-end
  consumer check). Standard §1/§7 + capability-status updated (new viz-layer row).
- **Adversarial verify (Workflow `wf_346a322f-608`: Hopper/Florence/Rose/Pat)
  caught a BLOCKER** the green checks missed: the `†`/`²`/`—`
  escapes were written with DOUBLED backslashes -> rendered as literal text
  (`0.30†`), and the first tests only grepped the ASCII word "imprecise" so
  they passed. Fixed with `intToUtf8(0x2020/0x00b2/0x2014)` (ASCII source, no
  escape ambiguity) + a glyph-asserting regression test (nchar 5, no `u2020`
  leak). Also applied: validate payload `rotation_invariant` (drop to recompute if
  FALSE); defensive `hs_as_square_matrix()` reshape; align fallback trait labels to
  the engine `trait_%d`; reworded the overclaiming mock comment (bridge does NOT
  attach the payload yet — recompute is the live path); 7 new edge-case tests
  (single-NA h², mismatched-length, low_h2 override, NULL-traits payload, recompute
  0.3 assertion, payload-vs-recompute Julia-free parity, non-rotation-invariant
  payload).
- **LIVE-VERIFIED** (bridge): `test-plot-data-parity.R` 7/7 — engine
  `genetic_correlations` == `cov2cor(G)` to 1e-12, h² exact, and JuliaCall returns
  the NamedTuple matrix field as a real R 3×3 matrix consumed end-to-end by
  `autoplot`. Rendered a flagged heatmap: subtitle + `0.30†` labels show real
  glyphs (nchar 5).
- Commands: `air format`; `devtools::document()` (regen `hsquared-autoplot.Rd` for
  the `@param ...` passthrough doc); `test-autoplot` all pass (incl. 13 g_matrix
  cases); `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- CI (commit `a9173dc`): pkgdown run `27883654950` **success**; pages deploy green.

## 2026-06-20 (session 5 — consume variance_components_plot_data Set-B forest)

- Twin landed `variance_components_plot_data` (PR #95) returning exactly the #93
  spec: `(term, estimate, lo, hi, panel, level, interval_method, interval_status,
  supplied)` with RAW unclamped `lo`/`hi`. `hs_autoplot_variance()` now auto-detects
  it (recompute fallback preserved in the else branch); the `[0,1]` boundary
  annotation is scoped to the h² panel only (a variance whisker crossing 0 is
  expected, not flagged). Live parity extended (`variance_components_plot_data`
  preparer on a real fit → marshalled → consumed; + NaN→NA bridge round-trip).
- **Adversarial verify (Workflow `wf_14b47306-325`: Curie/Rose/Hopper)** — no
  blockers (Hopper confirmed the field/shape contract matches the engine exactly).
  Applied the should-fix + nits: a negative-control test (variance whisker crossing
  is NOT flagged as an h² boundary), a recompute-branch boundary + CI-value test, a
  term+estimate-only points-only test, the live NaN→NA marshalling assertion, and
  clarifying comments (interval_status binary-by-contract; engine h² is logit-delta
  so the payload boundary path is a defensive guard).
- Caught + fixed a **test bug** the live run surfaced: the NaN assertion used a
  mixed `[NaN,1.0,NaN]` vector, so `all(is.na())` was correctly FALSE; rewrote to
  assert NaN→NA at positions 1/3 and finite passthrough at 2.
- New test helper `hs_sim_genedrop_phenotypes()` (gene-dropping; clean pedigree →
  interior VCs) so the live variance fit converges (toy 3-5 animal datasets pin
  σ²ₐ→0, confirming the AI-REML σ²ₐ→0 instability lead).
- Commands: `air format`; `devtools::document()` (no man change);
  `test-autoplot` all pass (incl. 11 variance cases); `pkgdown::check_pkgdown()`
  clean; `rcmdcheck(args="--no-manual")` **0/0/0**; LIVE `test-plot-data-parity`
  **16/16** (g-corr ×2 + variance forest + NaN round-trip).
- CI (commit `df54258`): pkgdown run `27884196127` **success**; pages deploy green.

## 2026-06-20 (session 5 — g_geometry eigenvalue scree figure)

- Built `autoplot(fit, "g_geometry")` — a rotation-invariant genetic-eigenstructure
  **scree** (eigenvalues = variance per genetic axis + % variance explained),
  realizing the "plot planned" g_geometry catalog row. Auto-detects the engine
  `genetic_pca_plot_data` payload (recompute via `eigen_G()` fallback). **Axis
  directions / loadings are never drawn** (rotation-arbitrary; span-ambiguous under
  repeated eigenvalues). Live parity case added.
- **Adversarial verify (Workflow `wf_bef66f21-dfb`: Florence/Curie)** caught a
  **BLOCKER**: the payload branch validated `rotation_invariant` but NOT
  `is_eigenstructure_not_loadings` (the §3-enforced flag whose purpose is to signal
  a loadings payload) → a loadings payload would be drawn as a scree. Fixed: added
  the guard so such a payload falls through to the PSD-gated recompute. Plus a
  should-fix: a non-PSD payload (negative eigenvalue) produced nonsense "116%"
  labels (recompute is PSD-gated, payload was not) → now suppresses the %
  labels + flags "non-positive-definite G" in the subtitle/meta. Added the
  matching tests + the coverage Curie asked for (loadings-flag fallback, non-PSD,
  ve/axis length-mismatch fallback, all-zero NA, payload-vs-recompute parity).
- Standard §1 catalog row updated (g_geometry: scree, built; axis directions never
  drawn); capability-status viz row updated.
- Commands: `air format`; `devtools::document()` (regen `hsquared-autoplot.Rd`);
  `test-autoplot` all pass (incl. 11 g_geometry cases); `pkgdown::check_pkgdown()`
  clean; `rcmdcheck(args="--no-manual")` **0/0/0**; LIVE `test-plot-data-parity`
  **21/21** (g_pca eigenvalues == eigen(G); marshalled scree consumed).
- CI (commit `70a8731`): pkgdown run `27884567967` **success**; pages deploy green.

## 2026-06-20 (session 5 — reaction_norm consumer + the #93 Q6 RR parity test)

- `hs_autoplot_reaction_norm()` now auto-detects the engine
  `rr_genetic_variance_plot_data` payload (covariate + genetic-variance +
  heritability trajectories) when the user has not asked for a custom grid; else
  recomputes via `rr_genetic_variance()`/`rr_heritability()`. **Rename-robust**:
  accepts either `value` (the #93-agreed field) or the current `genetic_variance`,
  so it works whether or not the twin's rename has landed — this removes the
  handoff's "hold the RR consumer until the rename" dependency.
- **Delivered the #93 Q6 RR parity test** (the twin asked both lanes to co-own it):
  a skip-guarded live `testthat` case asserting the engine
  `rr_genetic_variance_plot_data` `v_g(t)` == R `hs_rr_variance_values()` on a
  seeded `K_g` / standardized covariate grid.
- Commands: `air format`; `devtools::document()` (no man change);
  `test-autoplot` all pass (+2 RR payload tests), `test-random-regression`
  recompute path still green; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**; LIVE `test-plot-data-parity` **24/24**
  (g-corr ×2, g-pca, variance forest, NaN round-trip, RR parity).
- CI (commit `34074f3`): pkgdown run `27884896947` **success**; pages deploy green.

## 2026-06-20 (session 5 — closed #93 loop + single-step R-wiring build-spec)

- **Closed the #93 plot-data contract loop** with the twin (`issuecomment-4760095710`):
  R now consumes ALL FOUR landed `*_plot_data` preparers (genetic_correlation,
  variance_components, genetic_pca, rr_genetic_variance) with a live parity guard
  each (24/24), incl. the #93 Q6 RR parity she co-owns; the engine status flags are
  enforced R-side; the RR consumer is rename-robust. Asked her to confirm the §6
  naming map + the `value` rename on her schedule.
- **Single-step H⁻¹ construction R-wiring build-spec** (`docs/design/25-...md`) —
  turns the ranked #3 ("focused fresh-context build") into a mechanical execution:
  parser grammar (`single_step(1|id, pedigree=ped, markers=M)` vs supplied-Hinv),
  the **genotyped_rows alignment rule** (the crux: `rownames(M) ⊆ ped_ids`, sorted
  pedigree-row order, observed NOT required ⊆ markers), the payload contract, the
  exact engine command sequence, the live reduction test, and a risk register.
- **LIVE-confirmed the spec's command sequence** (engine, juliaup): a 5-animal
  pedigree, `additive_relationship(ped)`→A, `G=A[g,g]` all-genotyped,
  `fit_single_step_reml(y,X,Z,Ainv,A,G,g)` == `fit_ai_reml(animal_model_spec(...))`
  → **max|ΔVC| = 0.0**. Engine fn names verified callable + exported
  (`single_step_inverse`, `fit_single_step_reml`, `genomic_relationship_matrix`,
  `additive_relationship`). Docs-only slice; no R package code changed.
- CI (commit `1c96f86`): pkgdown run `27885106331` **success**; pages deploy green.

## 2026-06-20 (session 5 — gwas QQ figure + lambda_GC)

- Added `autoplot(scan, "qq")` (`autoplot.hs_gwas` now dispatches
  `type = c("manhattan", "qq")`; Manhattan extracted to a helper): observed vs
  expected `-log10(p)` with a `y = x` null reference and the genomic-inflation
  `lambda_GC = median(qchisq(1-p,1)) / qchisq(0.5,1)` as a subtitle diagnostic.
  Pure-R from the scan p-values (no engine). Realizes the standard's §1 QQ + λGC
  catalog rows; honest EXPERIMENTAL / not-genome-wide-calibrated caveat (gate #48).
- Tests: qq has a y=x abline, 20-point sorted-aligned expected/observed data,
  `type="qq"`/`uncalibrated` meta, `lambda_GC` in the subtitle; Manhattan stays the
  default. Standard §1 (QQ + λGC built) + capability-status viz row updated.
- Commands: `air format`; `devtools::document()` (regen `hsquared-autoplot.Rd`);
  `test-autoplot` all pass; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**. Rendered QQ: λGC label + caveat correct.
- CI (commit `ba0bb67`): pkgdown run `27885363770` **success**; pages deploy green.

## 2026-06-20 (session 5 — Rose session-close honesty audit + reconciliation)

- Ran a **Rose session-scope honesty audit** (spawned `rose-systems-auditor`) over
  the s5 surfaces (autoplot.R, capability-status, plotting standard, doc 25 spec,
  README, NEWS) cross-checked against the engine. **Verdict: CLEAN — no overclaims,
  no blockers.** All findings were *under*-claims (stale status text where the code
  now does more than the docs admitted) + one NEWS completeness gap.
- Reconciled (docs-only): capability-status + standard §0/§7 now state the live
  parity guard covers FOUR preparers (genetic_correlation, genetic_pca,
  rr_genetic_variance, variance_components), not "genetic_correlation only"; §3 lists
  `g_geometry` among the testthat-enforced rotation-invariant figures; NEWS now lists
  the g_geometry scree + the gwas QQ/λGC + the low-h² flag (were omitted).
- `pkgdown::check_pkgdown()` clean (renders NEWS/articles). Docs-only; no R code
  change, so the prior `rcmdcheck` 0/0/0 holds.
- CI (commit `be43091`): pkgdown run `27885576792` **success**; pages deploy green.

## 2026-06-20 (session 5 — rr_eigenfunctions figure)

- Added `autoplot(fit, "rr_eigenfunctions")` — the rotation-invariant eigenfunctions
  `psi_j(t)` of `K_g` as covariate functions (faceted by axis, labelled by % genetic
  variance). Auto-detects `rr_eigenfunctions_plot_data` (recompute via
  `rr_eigenfunctions()` fallback). Honest §2 caveat: signs arbitrary,
  span-ambiguous under repeated eigenvalues; `rotation_status="rotation_invariant"`
  (added to the §3 binding set). Realizes the standard's §1 reaction-norm
  eigenfunctions catalog row (R-proposes process, §7).
- Standard amended: §3 type enum + binding set (+`rr_eigenfunctions`), §1 catalog
  row, §6 naming map (`rr_eigenfunctions` → `rr_eigenfunctions_plot_data`).
- Tests: payload-consume (test-autoplot), recompute on the real RR fit
  (test-random-regression: values == `rr_eigenfunctions()$eigenfunctions`, meta
  rotation-invariant), + a live consume leg in test-plot-data-parity (marshalled
  m×k eigenfunctions matrix == engine).
- Commands: `air format`; `devtools::document()` (regen `hsquared-autoplot.Rd`);
  `test-autoplot` + `test-random-regression` all pass; `pkgdown::check_pkgdown()`
  clean; `rcmdcheck(args="--no-manual")` **0/0/0**; LIVE `test-plot-data-parity`
  **25/25**; rendered figure verified (axis facets + % variance labels).
- CI (commit `df7ef4a`): pkgdown run `27885829976` **success**; pages deploy green.

## 2026-06-20 (session 5 — rr_surface figure; plotting catalog complete)

- Added `autoplot(fit, "rr_surface")` — the genetic covariance surface
  `S(s,t) = phi(s)' K_g phi(t)` over the covariate grid as a heatmap, with
  `correlation = TRUE` for the genetic-correlation surface (unit diagonal).
  Auto-detects `rr_covariance_surface_plot_data` (recompute via the internal
  Legendre design + `rr_covariance()` fallback). Supplied-K_g descriptive,
  rotation-invariant (now the full §3 binding set is enforced in tests).
- **This completes the plotting standard's §1 figure catalog** — every cataloged
  figure is now built (variance, breeding_values, g_matrix+low-h², g_geometry,
  reaction_norm, rr_eigenfunctions, rr_surface, Manhattan, QQ+λGC, recovery_forest).
- Standard §1 (rr_surface built), §3 (full enforced set), §7 (rr_surface parity
  covered) updated.
- Tests: payload-consume (test-autoplot), recompute + correlation-option unit
  diagonal (test-random-regression), live marshalled-consume leg (test-plot-data-parity).
- Commands: `air format`; `devtools::document()`; `test-autoplot` +
  `test-random-regression` all pass; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**; LIVE `test-plot-data-parity` **26/26**.
- CI (commit `9edc726`): pkgdown run `27886025919` **success**; pages deploy green.

## 2026-06-20 (session 5 — visualizing-models article: complete the gallery)

- Completed the user-facing figure gallery `vignettes/articles/visualizing-models.Rmd`
  — it showed 5 of the now-10 figures. Added **g_geometry** scree, **QQ** (+λGC),
  **reaction_norm**, **rr_eigenfunctions**, **rr_surface** sections, each rendered
  from a small illustrative plain-`structure()` mock (no engine at build): added
  `genetic_covariance` to the multivariate mock + a plain random-regression mock
  (`coefficient_covariance` + `residual_variance` + `random_regression` metadata).
  Carries the honest-status caveats (low-h² flag note, rotation-invariant/no-loadings,
  signs-arbitrary, not-genome-wide-calibrated).
- `rmarkdown::render()` OK (all figures build); `pkgdown::check_pkgdown()` clean.
  Docs-only (article); no R package code changed.
- CI (commit `638ad15`, visualizing-models gallery): pkgdown run `27886549198` **success** (the article renders all 10 figures on the site).
- Follow-up: NEWS.md completeness — added `rr_eigenfunctions` + `rr_surface` to the visualization-layer bullet (they landed after the earlier NEWS edit).

## 2026-06-20 (session 5 — single-step H⁻¹ CONSTRUCTION bridge, ranked #3)

- Landed the ranked #3 capability: `single_step(1 | id, pedigree = ped, markers = M)`
  + `target = "single_step_construct"` builds `H⁻¹` engine-side (Ainv + dense A from
  the pedigree, G from the genotyped-subset markers; Aguilar et al. 2010) and fits
  by REML — no precomputed `Hinv` needed. Additive + isolated: new parser branch,
  payload branch, bridge fit fn, target; reuses `hs_validate_pedigree` + the genomic
  result normalizer. Engine fns `additive_relationship`/`single_step_inverse`/
  `fit_single_step_reml` confirmed exported; the bridge asserts engine-order ==
  R-order at fit time (the §8 alignment guard, fails loudly).
- **Adversarial verify (Workflow `wf_7c349339-20f`: Boole/Hopper/Henderson/Curie/Rose)
  caught 2 BLOCKERS** the green checks missed: (1) the fit call omitted
  `ids = hsq_ped.ids` → GEBVs labelled 1..n (fixed: pass ids + a live id-label
  assertion); (2) the keystone equivalence test was **circular** (both sides read
  the same parsed `ss`) → replaced with independent guards: the marker-row **reorder
  invariance** test (§6.3, the real alignment guard) + a **differs-from-pedigree-model**
  anchor + id/coverage + ridge rank-deficient-G; plus Boole's parser error contracts
  ("choose one" Hinv+construction; markers-without-pedigree directing error; grammar)
  and the hs_data-shorthand deferral (documented).
- Pure-R alignment tests (topological, non-contiguous, scrambled rows, ungenotyped
  accepted) all pass; **LIVE** `test-single-step-construct.R` all pass (reorder
  invariance, id-labelled GEBVs for all pedigree animals, differs-from-pedigree
  cor>0.5 + differ, ridge fits a rank-deficient G).
- `air`; `devtools::document()` (genomic_markers.Rd: new single_step args);
  full `devtools::test_dir` (non-live) FAIL 0 / PASS 1112+; `pkgdown::check_pkgdown()`
  clean; `rcmdcheck(args="--no-manual")` **0/0/0** (fixed one non-ASCII em-dash in a
  string literal). capability-status row flipped planned(R) → **partial (R)**;
  doc 25 marked IMPLEMENTED (as-built, §6 corrected — the markers-G path can't reduce
  to A₂₂, so reorder + differs-from-pedigree are the anchors); NEWS bullet added.
- CI (commit `80d27cf`, single-step construction): pkgdown run `27887761040` **success**; pages green. Posted to twin #61 (`issuecomment-4760353752`).

## 2026-06-20 (session 5 — gwas single-marker method option, part of #4)

- Added `gwas(fit, markers, method = c("mixed", "single"))`: `"single"` surfaces the
  Julia-owned `single_marker_scan()` (relatedness-UNcorrected OLS scan) as a naive
  contrast to the default relatedness-corrected `mixed_model_marker_scan()`.
  Isolated to `R/gwas.R` (method dispatch; same result shape so the normalizer is
  reused) + `R/autoplot.R` (the Manhattan/QQ note "relatedness-UNcorrected" when the
  `scan_method` attr is "single"). The hs_gwas result carries a `scan_method`
  attribute; `print()` is method-aware.
- LOCO (`loco_mixed_model_marker_scan`) is the remaining part of #4 — it needs a
  marker-group map + per-group relationship precisions (a bigger build); deferred.
- Tests: normalizer/print method attr (pure R); autoplot single-method note (pure R);
  **LIVE** `test-gwas.R` — `method="single"` matches the engine `single_marker_scan`
  p-values element-wise and differs from the mixed scan.
- `air`; `devtools::document()` (gwas.Rd: `method` arg); `test-gwas` + `test-autoplot`
  pass; live gwas all pass; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**. capability-status marker-scan row + NEWS
  gwas bullet updated.
- CI (commit `0b9756a`, gwas single-marker): pkgdown run `27888126645` **success**; pages green.

## 2026-06-20 (session 6 — LOCO marker-scan bridge, completes #4)

- Added `gwas(fit, markers, method = "loco", marker_groups = chrom)`: a
  leave-one-group-out scan surfacing `HSquared.loco_relationship_precisions()` +
  `HSquared.loco_mixed_model_marker_scan()`. Build-spec `docs/design/26` (IMPLEMENTED).
- **Live dimension probe first** (`/tmp/loco_probe.R`, on the bridge): resolved the
  handoff-8 open design question. The LOCO precision enters the `Ainv` slot
  (engine guards `size(Z,2)==size(precision,1)`), so precisions are built from
  **animal-level** markers → (n_animals × n_animals), while the scan tests
  **record-level** markers (`Z %*% markers`); a single supplied σ²a/σ²e is reused
  from the pedigree fit. Probe confirmed: precisions 80×80; chr1 markers match a
  single `mixed_model_marker_scan` with the chr1 precision to **max|diff| = 0.0**;
  LOCO differs from the whole-G scan.
- R wiring: `R/gwas.R` (method enum + `marker_groups`; `hs_gwas_marker_groups`
  validator: required-under-loco / rejected-otherwise / length / NA / empty /
  ≥2-distinct / `as.character` coercion; loco bridge branch; loco `print()` with the
  genomic-vs-pedigree scale-mismatch + uncalibrated caveat); `R/autoplot.R`
  (Manhattan/QQ LOCO note).
- Adversarial verify (Workflow, 5 lenses: Boole/Hopper/Fisher/Curie/Rose): Hopper
  CLEAN; others changes-needed, **no true blocker**. Fixed: (1) the stale
  `mixed`-branch `print()` line ("LOCO … not yet surfaced") → now points to
  `method = "single"`/`"loco"`; (2) **Curie's real gap** — the live tests used a
  square `Z` (one record per animal), so animal-level ≡ record-level markers and a
  markers/markers_rec swap passed undetected. Added a **non-square-Z** (repeated
  records, 110 records / 80 animals, interior σ²a=1.12) live test that (a) asserts
  the scan runs, (b) parity vs a direct engine LOCO scan from animal-level
  precisions + record-level scan markers, and (c) `expect_error` on the wrong path
  (record-level markers → precisions, which the engine size guard rejects);
  (3) test hardening — single-method branch coverage, dispatch-level loco guards,
  factor/integer coercion, symmetric chr2-precision match; (4) tightened the
  autoplot note test to the honesty half ("pedigree-estimated VCs"); (5) Fisher's
  honesty clause in the loco `print()` (effect/SE scale is not a calibrated
  genomic-VC quantity).
- `air`; `devtools::document()`; pure-R `test-gwas` **30/0/0/2** + `test-autoplot`
  **117/0/0/0**; **LIVE** `test-gwas.R` **59/0/0/0** (both the square and the
  non-square dimensional blocks, on the bridge with Julia on PATH);
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
  capability-status marker-scan row + NEWS gwas bullet updated (LOCO surfaced,
  live-verified element-wise); doc 26 → IMPLEMENTED.
- CI (commit `a448f79`, LOCO gwas): pkgdown run `27888780206` **success**; pages green.

## 2026-06-20 (session 6 — single_step(1 | id) hs_data bundle shorthand)

- Wired the deferred `hs_data()` bundle shorthand for single-step construction:
  when `data` is an `hs_data()` container with a pedigree and genotypes,
  `single_step(1 | id)` resolves both from the bundle (the `animal(1 | id)`
  precedent); explicit `pedigree =`/`markers =` override. `R/model-spec.R`:
  threaded `model_data` (incl. `id = data$id`) into `hs_parse_relinv_primary_call`
  + `hs_parse_single_step_construct`; routing gained a bundle branch (no Hinv AND
  bundle has both pedigree+genotypes); new `hs_single_step_bundle_markers()`
  coerces the genotypes component (matrix / data-frame with id col or rownames)
  into the numeric dosage matrix. Doc 25 §2/§6, NEWS, capability-status,
  `genomic-markers.R` roxygen updated (shorthand LANDED).
- Adversarial verify (Workflow, 6 lenses: Boole/Emmy/Hopper/Curie/Pat/Rose):
  all flagged ONE shared **blocker** — a shipped failing pure-R test (the reworded
  "needs a pedigree" error gained a backtick that broke a `fixed = TRUE` match;
  rcmdcheck reproduced it where my `as.data.frame(test_file)` summary had masked
  it). Fixed the message to keep the literal "needs a pedigree" AND the bundle
  pointer. Folded the majors: (B2) stale `?single_step` roxygen ("explicit
  `pedigree =` is required") → corrected; (M1/M2) bare `single_step(1 | id)` on
  plain data / a partial bundle now points at the construction on-ramps, not a
  Hinv-only message; (M3) added an end-to-end test of the new id-threading
  (data-frame genotypes under a non-default id) + directing-error tests.
- `air`; `devtools::document()`; pure-R `test-single-step-construct` **38/0/0/5**;
  **LIVE** `test-single-step-construct.R` **54/0/0/0** on the bridge (the bundle
  shorthand fits identically to the explicit call — VCs + GEBVs to 1e-8);
  full suite earlier 1167/0/0; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**. No new engine contract consumed (pure
  R sugar over the existing construct path), so no twin coordination needed.
- CI (commit `6adc24f`, bundle shorthand): pkgdown run `27889443212` **success**; pages green.

## 2026-06-20 (session 6 — variational (VA) non-Gaussian marginal R bridge)

- Surfaced the engine's **variational (VA) marginal** for the opt-in non-Gaussian
  (GLMM) animal model — answers the twin's "pending R-lane coordination" item
  (the `"laplace"`/`"va"` method-string). The engine's `fit_laplace_reml` already
  supports `marginal = :variational` (+ DRM-style `:LA`/`:VA`), validated
  engine-side (V6-LAPLACE/VA: VA ELBO a verified lower bound via Gauss–Hermite).
- `R/julia-bridge.R`: `hs_validate_marginal_method()` accepts
  `"laplace"`/`"variational"` (+ `"la"`/`"va"` aliases, case-insensitive),
  canonicalizes; the user-facing spec method is `"Variational-REML"` vs
  `"Laplace-REML"` from the engine-echoed result method; diagnostics carry
  `loglik_kind` (the VA value is the **ELBO**, a lower bound — so VA/Laplace
  `logLik`/`AIC` are not comparable). `R/hsquared.R` + `R/hs_control.R` roxygen
  (the `marginal` key + a `target = "nongaussian"` paragraph).
- Adversarial verify (Workflow, 5 lenses: Boole/Hopper/Fisher/Curie/Rose):
  Hopper + Curie **clean**; SHIP-after-FIX. Folded: 1 **blocker** (a stale
  `validation-debt-register` row claiming "variational planned" — the opposite of
  reality) + majors — the `marginal` key was undiscoverable in `?hs_control`
  (added key + nongaussian paragraph); the VA loglik/ELBO scale was un-flagged
  (added `loglik_kind`); and the Rose-principle sweep caught the same stale
  "Laplace-only/Laplace-REML" claim across `model-spec.R` error, `README.md`,
  `model-status.Rmd`, the package roxygen, `validation-status.R`, and a second
  validation-debt row — all reconciled.
- `air`; `devtools::document()`; pure-R `test-nongaussian` **18/0/0/2**; **LIVE**
  `test-nongaussian.R` **39/0/0/0** on the bridge (VA matches the engine VA fit to
  1e-6, VA ≠ Laplace so the knob is not a no-op, the `"va"` alias routes
  identically, print shows `Variational-REML`, `loglik_kind` is the ELBO);
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
  capability-status + NEWS updated. No engine edit (the engine pre-built the
  `MarginalMethod` R-name mapping).
- CI (commit `5f0e25f`, VA marginal): pkgdown run `27889972721` **success**; pages green.

## 2026-06-20 (session 6 — binomial cbind(successes,failures) counts: correctness fix)

- **Bug fixed (silently-wrong):** on the opt-in non-Gaussian path,
  `hsquared(cbind(succ, fail) ~ ..., family = binomial())` was mis-detected as a
  TWO-TRAIT multivariate Gaussian (family-blind `multivariate <- is.matrix(response)`),
  silently fitting successes/failures as two Gaussian traits. `cbind(s,f) ~ x` is
  the canonical R `glm` binomial-counts syntax, so it is user-reachable (verified
  via `hs_build_model_spec` with widened families). Found by the cross-lane
  opportunity scout (ranked A1, correctness-first).
- **Fix:** `hs_build_response_spec(lhs, response, family)` is now family-aware — a
  2-col `cbind` under `family = binomial(logit)` routes to the new
  `hs_build_binomial_counts_response()` (successes = col1, n_trials = succ+fail;
  validates non-negative integers, ≥1 trial, and **equal row totals** since the
  engine `BinomialResponse` holds one scalar `n_trials` — varying totals error,
  per-record trials deferred to a twin issue). `n_trials` flows
  spec→payload (`bridge-payload.R`)→`fit_laplace_reml(family=:binomial, n_trials=)`
  (`julia-bridge.R`); `hs_nongaussian_family_symbol(family, n_trials)` → "binomial"
  when n_trials>1, else "bernoulli".
- Adversarial verify (Workflow, 6 lenses: Boole/Hopper/Fisher/Curie/Pat/Rose):
  **code/bridge/tests CLEAN** (Boole/Hopper/Fisher/Curie). FIX-FIRST on 2 stale-doc
  blockers (validation-debt-register + doc 21 still said "binomial trial count
  planned") + 2 Pat majors (the family-rejection message + `formula_status()` cbind
  row both said "binary 0/1" only) — all reconciled; Rose-principle sweep confirmed
  no remaining stale "binomial binary-only/trial-count-planned" text.
- `air`; `devtools::document()`; pure-R `test-binomial-counts` **12/0/0/2**; **LIVE**
  `test-binomial-counts.R` **20/0/0/0** on the bridge (balanced counts fit matches a
  direct engine `fit_laplace_reml(family=:binomial, n_trials=)` to 1e-6;
  one-trial `cbind` reduces to the bernoulli fit; varying-totals error; gaussian
  `cbind` still multivariate); `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**. capability-status + NEWS + doc 21 +
  validation-debt-register + `formula_status()` updated. No engine edit.
- CI (commit `2322ba4`, binomial counts): pkgdown run `27891149133` **success**; pages green.

## 2026-06-20 (session 6 — REML-estimated SNP-BLUP, closes hsquared#13 build half)

- `genomic(1 | id, markers = M)` with `target = "snp_blup"` and **no supplied
  variances** now estimates σ²g/σ²e by REML (Julia-owned
  `HSquared.fit_snp_blup_reml`, exported on twin main `5de0e6a`); supplied
  variances still use the supplied-variance `fit_snp_blup` path (byte-identical).
  New `hs_fit_julia_snp_blup_reml_payload`; the shared normalizer gained
  `provenance`/`converged`/`loglik` params (provenance `estimated_snp_blup_reml`);
  dispatch routes on whether `variance_components` is NULL.
- Cross-lane opportunity scout ranked this A2 (#13's genuinely-new half;
  `fit_gblup_reml` is redundant with the existing GREML `fit_ai_reml`-on-Ginv path).
- Adversarial verify (Workflow, 5 lenses): Hopper **CLEAN** (bridge marshalling +
  VC scaling correct). FIX-FIRST on a **real behavioural bug** (B1) + stale
  honesty surfaces: (B1) the `REML = FALSE` exemption was unconditional for
  `snp_blup`, so an unsupplied (REML-estimating) snp_blup silently accepted
  `REML = FALSE` — now exempt only when variances are supplied; (B2) hs_control
  roxygen + (B3) `validation_status()` label/evidence still said
  "supplied-variance only / REML planned"; Fisher: the REML path left `df` unset
  so `AIC`/`BIC` returned NA → set `df = ncol(X) + 2`; Curie: added converged +
  AIC-finite + estimate≠(1,1)-default assertions. Rose-principle sweep reconciled
  the model-status, genomic-prediction, fitting-models, qtl-gwas vignettes +
  `validation-status.R` + the bridge comment.
- `air`; `devtools::document()` (hs_control.Rd regenerated); pure-R `test-snp-blup`
  **14/0** (routing test runs off-bridge); **LIVE** `test-snp-blup.R` **37/0/0/1**
  on the bridge (REML estimates interior σ²g/σ²e; converged; AIC finite; estimate
  ≠ default; parity vs a direct `fit_snp_blup_reml` to 1e-6; supplied path
  unchanged); `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")`
  **0/0/0**. capability-status + NEWS + validation-status + 4 vignettes updated.
  No engine edit.
- CI (commit `e279b26`, SNP-BLUP REML): pkgdown run `27891709713` **success**; pages green.

## 2026-06-20 (session 6 — Henderson MME PEV/reliability unconditional, #21/A4)

- The Henderson MME bridge (`target = "henderson_mme"`) now attaches PEV +
  reliability **unconditionally** (the engine's
  `prediction_error_variance/reliability(::HendersonMMEResult; method = :dense)`
  default to `:dense`, so the legacy `isdefined/applicable` probe is dropped). The
  default-fit path already emitted them unconditionally; this closes the Henderson
  half (small slice from the scout's A4 / issue #21).
- Test hardened: the live Henderson-MME-fixture test now asserts PEV + reliability
  are **present** + finite (not merely "if present"). A strict `[0,1]` reliability
  assertion was tried then dropped: on this fixture reliability ranges `[~0, 0.17]`
  and the apparent `< 0` is a floating-point `-0.0` (numerical zero), not a real
  out-of-bounds — no twin concern, the assertion was simply over-strong.
- `air`; `devtools::document()`; **LIVE** `test-julia-bridge.R` **96/0/0/0** on the
  bridge; `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")`
  **0/0/0**. Dense/validation-scale label unchanged (no capability promotion).
- CI (commit `c49614d`, Henderson PEV unconditional): pkgdown run `27892075172` **success**; pages green.

## 2026-06-20 (session 6 — validation depth: GBLUP <-> SNP-BLUP GEBV equivalence)

- Added a live cross-path validation atom (`test-snp-blup.R`): fitting the same
  markers as a genomic relationship (GREML, `target = "genomic"`) vs as marker
  effects (REML SNP-BLUP, `target = "snp_blup"`) — each REML-estimating its own
  variances — yields **equivalent** per-individual GEBVs (the textbook
  GBLUP<->SNP-BLUP equivalence; the twin V2-SNPBLUP pinned property). Probed:
  GEBV correlation **0.999998**, relative max-diff **~0.6%** (the small residual
  is the ridge the genomic path applies to G, not a discrepancy). Test asserts
  `cor > 0.999` and relative max-diff `< 0.02`.
- Test-only addition; **LIVE** `test-snp-blup.R` **40/0/0/1** on the bridge;
  `rcmdcheck(args="--no-manual")` **0/0/0**.

## 2026-06-20 (session 6 — consume breeding_values_plot_data: #93 loop closed R-side)

- The twin landed `breeding_values_plot_data` (#116) — the last #93 preparer.
  `autoplot("breeding_values")` now auto-detects an attached
  `breeding_values_plot_data` payload (rename-robust via the new
  `hs_breeding_values_from_payload`) and falls back to the
  `breeding_values()`+`prediction_error_variance()` recompute (the live path; the
  bridge does not attach payloads at fit time yet). **All 7 #93 preparers are now
  consumed with live parity** — the plot-data contract is closed R-side.
- Tests: pure-R consume + the helper rename-robustness/guards (`test-autoplot.R`);
  **LIVE** parity (`test-plot-data-parity.R`): the engine
  `breeding_values_plot_data(hsq_fit)` id/value/pev match the R recompute to 1e-8,
  `pev_scale == "validation"`, and a marshalled payload draws the same EBVs.
- `air`; `devtools::document()`; pure-R `test-autoplot` **126/0**; **LIVE**
  `test-plot-data-parity.R` **32/0/0/0** on the bridge; `pkgdown::check_pkgdown()`
  clean; `rcmdcheck(args="--no-manual")` **0/0/0**. doc 24 updated (all-seven
  preparers). No engine edit.
- CI (commit `f5e00b7`, breeding_values_plot_data consumer): pkgdown run `27892365616` **success**; pages green.

## 2026-06-21 (Mrode Example 5.1 multivariate published target)

- Added a CI-runnable pure-R Mrode Example 5.1 multiple-trait supplied-G0/R0
  BLUP/MME anchor: `hs_mrode_example_5_1_multitrait_fixture()`,
  `hs_solve_multivariate_henderson_mme_reference()`, and
  `test-mrode-multivariate-anchor.R`. The reference solve reproduces the
  published/reproduced fixed effects and animal BLUPs for pre-weaning and
  post-weaning gain at the supplied `G0 = [[20, 18], [18, 40]]` and
  `R0 = [[40, 11], [11, 30]]`.
- Reconciled `validation_status()`, `capability-status.md`,
  `validation-debt-register.md`, `04-validation-canon.md`,
  `12-multivariate-comparator-plan.md`, `11-next-50-slices.md`, and
  `issue-map.md`. Claim boundary stays explicit: this closes the
  published/Mrode-style supplied-covariance target gap only; V4-MV-REML remains
  `partial` and still needs recovery-gate acceptance or broadening plus another
  independent same-estimand comparator beyond `sommer`.
- Local tool availability refreshed: `sommer` 4.4.3 and `MCMCglmm` 2.36 are
  installed; `nadiv`, `pedigreemm`, `asreml`, `AGHmatrix`, `enhancer`, and
  `JWAS` are not installed; `asreml`, `airemlf90`, `blupf90`, `renumf90`,
  `dmuai`, and `wombat` are not on `PATH`.
- Checks: `air format .` clean; focused
  `devtools::test(filter = "mrode-multivariate-anchor|phase0-api")`
  **94/0/0/0**; full `devtools::test()` **1210 pass / 0 fail / 0 warn /
  55 skip**; `pkgdown::check_pkgdown()` clean; `git diff --check` clean;
  `_R_CHECK_FORCE_SUGGESTS_=false rcmdcheck::rcmdcheck(args = "--no-manual")`
  **0/0/0**.

## 2026-06-21 (metafounder + H^Gamma R contract/status)

- Cross-lane state before this slice: R PR #37 was squash-merged, refreshing R
  `main` to `6a1065e`; Julia PR #128 was squash-merged to HSquared.jl `main`
  at `758349d`. Julia PR #128 scope was the supplied-`Gamma`
  `metafounder_single_step_inverse`, `fit_metafounder_single_step`, and
  `fit_metafounder_single_step_reml` engine primitives only; no R payload or
  covered-status claim.
- Reconciled stale R status wording after the ordinary single-step construction
  merge: `validation_status()`, the genomic/model-status/fitting-model/QTL-GWAS
  articles, public claims, capability status, validation debt, issue map, and the
  bridge-gap ledger now distinguish supplied-`Hinv` single-step from constructed
  `Hinv` (`single_step(1 | id, pedigree = ped, markers = M)`,
  `target = "single_step_construct"`).
- Reserved the R-side metafounder syntax contract without fitting it:
  `metafounder()` now explicitly accepts inert `group =` alongside supplied
  `Gamma =`; `formula_status()` reports
  `metafounder(1 | id, pedigree = ped, group = group, Gamma = Gamma)` as
  reserved/planned, and adds the already-live constructed single-step row.
- Added `docs/design/27-metafounder-single-step-contract.md` as the R payload
  target for Candidate A: future `target = "metafounder"` and
  `target = "metafounder_single_step"` payloads, group/Gamma alignment,
  extractor questions, validation gates, and Rose-blocked wording.
- BLUPF90-family second-comparator evidence remains locally blocked: Julia
  successfully banked the starter-packet generator, but this machine lacks
  `renumf90`, `airemlf90`, `blupf90`, `remlf90`, and `gibbsf90` on PATH, so no
  BLUPF90 comparator run is claimed.
- Checks: `air format .` clean; `devtools::document()` regenerated
  `man/qg_effect_markers.Rd`; focused
  `devtools::test(filter = "phase0-api|formula-animal|single-step-construct")`
  **190 pass / 0 fail / 0 warn / 5 skip**; full `devtools::test()`
  **1220 pass / 0 fail / 0 warn / 55 skip**; `pkgdown::check_pkgdown()` clean;
  `git diff --check` clean; `_R_CHECK_FORCE_SUGGESTS_=false
  rcmdcheck::rcmdcheck(args = "--no-manual")` **0/0/0**.

## 2026-06-21 (metafounder H^Gamma parser/payload gate)

- Continued Candidate A from the Big 3 plan after R PR #38 merged:
  `single_step(1 | id, pedigree = ped, markers = M, group = mf_group,
  Gamma = Gamma)` now has a pure-R parser/model-spec/bridge-payload gate for
  supplied-`Gamma` single-step `H^Gamma`.
- Implementation boundary: the branch validates an ID-keyed `group` assignment
  against normalized pedigree IDs, requires non-missing labels for animals with
  unknown parents, validates finite symmetric positive-semidefinite supplied
  `Gamma`, reorders dimnamed `Gamma` to resolved first-appearance group labels,
  keeps marker rows aligned to `genotyped_rows`, and serializes
  `group_of`/`Gamma`/`gamma_labels` in the future `metafounder_single_step`
  payload.
- Fitting boundary: `engine_control$target = "metafounder_single_step"` is
  recognized but deliberately errors before Julia execution. The ordinary
  `target = "single_step_construct"` rejects the `group`/`Gamma` branch so the
  two single-step paths stay unambiguous.
- Docs/status boundary: NEWS, formula grammar, capability status, validation
  debt, public claims, issue map, bridge-gap doc, contract doc, and the genomic
  prediction article now say "payload gate done; live fit/extractor/comparator
  pending." No covered promotion, no `Gamma` estimation claim, and no BLUPF90
  evidence.
- BLUPF90-family executable probe: `renumf90`, `airemlf90`, `blupf90`,
  `remlf90`, and `gibbsf90` are all absent from PATH locally, so the real
  second-comparator run remains blocked here.
- Checks: `air format .` clean; `Rscript --vanilla -e 'devtools::document()'`
  regenerated `man/genomic_markers.Rd`; focused
  `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|single-step-construct|formula-animal")'`
  **218 pass / 0 fail / 0 warn / 5 skip**; full
  `Rscript --vanilla -e 'devtools::test()'` **1248 pass / 0 fail / 0 warn /
  55 skip**; `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean;
  `git diff --check` clean; `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla
  -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")'`
  **0 errors / 0 warnings / 0 notes**.

## 2026-06-21 (metafounder_effects reserved extractor)

- Added the exported, error-only `metafounder_effects()` generic and
  `hsquared_fit` method. The method deliberately errors until a future engine
  result returns explicit combined-system metafounder solutions; current
  metafounder and `H^Gamma` fits continue to expose only supplied provenance
  through `gamma_matrix()` and `metafounder_groups()`.
- Reconciled the metafounder contract, capability status, validation debt,
  public-claims register, NEWS, and pkgdown reference index so the public
  surface says "reserved/error-only" rather than implying a returned effect
  table.
- Checks: `air format .` clean; `Rscript --vanilla -e
  'devtools::document()'` regenerated `NAMESPACE` and
  `man/metafounder_effects.Rd`; focused `Rscript --vanilla -e
  'devtools::test(filter = "fit-object|phase0-api")'` **198 pass / 0 fail /
  0 warn / 0 skip**; `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean; `git diff --check` clean; full `Rscript --vanilla -e
  'devtools::test()'` **1290 pass / 0 fail / 0 warn / 58 skip**;
  `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e
  'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  **0 errors / 0 warnings / 0 notes**. Expected INFO only: optional suggested
  packages `enhancer`, `nadiv`, and `pedigreemm` unavailable.

## 2026-06-21 (BLUPF90 multivariate result-ingester scaffold)

- Added an internal, non-exported BLUPF90-family multivariate summary ingester:
  `hs_read_blupf90_multivariate_summary()` reads a sanitized CSV companion table
  with `quantity`, `target`, `estimate`, `difference`, `tolerance`, and
  `verdict`; `hs_validate_blupf90_multivariate_summary()` checks required core
  G/R covariance and per-trait h2 quantities plus non-pass verdicts.
- Updated the BLUPF90 executable handoff packet and comparator-runs README so a
  future executable-backed report can attach that CSV without requiring the R
  lane to parse raw BLUPF90 logs.
- Claim boundary: synthetic scaffold and review aid only. No `renumf90` or
  `airemlf90` run, no BLUPF90 comparator evidence, no `validation_status()`
  change, and no V4-MV-REML promotion.
- Checks: `air format .` clean; focused
  `Rscript --vanilla -e 'devtools::test(filter = "comparator-scripts")'`
  **46 pass / 0 fail / 0 warn / 0 skip**; full
  `Rscript --vanilla -e 'devtools::test()'`
  **1301 pass / 0 fail / 0 warn / 58 skip**;
  `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean;
  `git diff --check` clean; `_R_CHECK_FORCE_SUGGESTS_=false
  Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual",
  error_on = "never")'` **0 errors / 0 warnings / 0 notes**.

## 2026-06-21 (Julia PR #134 GWAS calibration sync)

- Julia-lane sync reported HSquared.jl PR #134 merged at `beca371`, with #48's
  opt-in threshold calibration harness now defaulting to a fixed-marker-panel
  type-I smoke. Live GitHub issue check shows HSquared.jl #48 is closed, while
  #45 and #61 remain open.
- Updated R wording to avoid the stale implication that an open #48 gate is the
  only blocker, while preserving the important public boundary: R `gwas()`
  p-values remain nominal/Bonferroni/BH and are not genome-wide calibrated.
  Julia's fixed-panel smoke does not activate an R significance threshold,
  provide a PLINK/GenABEL-style external comparator, provide realistic-LD
  production calibration, or promote the marker-scan row beyond partial.
- Checks: `air format .` clean; `Rscript --vanilla -e 'devtools::document()'`
  regenerated `man/gwas.Rd` and `man/hsquared-autoplot.Rd`; focused
  `Rscript --vanilla -e 'devtools::test(filter = "gwas|autoplot|phase0-api|fit-object")'`
  **354 pass / 0 fail / 0 warn / 2 skip**; full
  `Rscript --vanilla -e 'devtools::test()'`
  **1301 pass / 0 fail / 0 warn / 58 skip**;
  `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean;
  stale #48 wording audit clean; `git diff --check` clean;
  `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e
  'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  **0 errors / 0 warnings / 0 notes**.

## 2026-06-21 (Next-50 bank sync)

- Refreshed `docs/design/11-next-50-slices.md` after R PRs #55/#56 and Julia
  PR #134. The board now distinguishes banked BLUPF90 handoff/summary-ingester
  scaffolds from actual BLUPF90 comparator evidence, and distinguishes Julia's
  fixed-panel calibration smoke from any R `gwas()` threshold activation.
- Claim boundary: docs-only status sync. No `validation_status()` change, no
  capability-status promotion, no BLUPF90 evidence, no calibrated GWAS threshold,
  and no QTL/eQTL table activation.
- Checks: `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean;
  `git diff --check` clean; boundary grep over `docs/design/11-next-50-slices.md`
  and the after-task report confirms the BLUPF90 and GWAS updates are framed as
  no-evidence/no-threshold/no-promotion boundaries.

## 2026-06-21 (GWAS article calibration sync)

- Updated user-facing GWAS/QTL/genomic/visualization article prose after
  HSquared.jl PR #134 so users see the current split: Julia has a fixed-panel
  calibration smoke harness, but R `gwas()` still has no activated significance
  threshold.
- Claim boundary: no calibrated threshold, no permutation-backed cutoff, no
  realistic-LD production calibration, no external scan comparator, no QTL/eQTL
  table activation, and no covered-status language.
- Checks: `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean;
  `git diff --check` clean; boundary grep over the edited articles and
  after-task report confirms the fixed-panel-smoke/no-R-threshold wording.
