# After-task — 2026-09-20 animal + permanent environment at scale, and K-effect standard errors

## 1. Goal

Close the two blockers the maintainer hit on real great tit data: `hsquared`
returned no standard errors, and it could not fit `animal` (A-structured) plus a
non-genetic individual effect for repeated records, so `V_A` absorbed `V_PE`
(ASReml's `0.595 + 0.525` came back as a single `1.110`). Filed as
`HSquared.jl#351` and `#352`. The owner assigned BOTH lanes for this arc, so R
and Julia changes land together.

## 2. Implemented

- **`cc9e040`** — merged PR #235: post-fit engine failures surface as one
  warning plus `attr(fit, "bridge_errors")` instead of a silent `NA`; also
  carries the `HSquared.jl#364` Ask-4 `:dense` → `:auto` documentation fix.
- **`fd10dca`** — `target = "repeatability"` gains `scale_method`. `"dense"`
  unchanged; `"auto"` expresses the same model as the K = 2 block problem and
  calls `fit_multi_effect(method = :auto)`, taking the sparse-exact AI-REML
  route with no dense ceiling. Multi-effect block floor 3 → 2. Dense refusal
  names `scale_method = "auto"`. Provenance reports the estimator that actually
  ran.
- **`5135a92e` (HSquared.jl)** — `multi_effect_variance_component_covariance`,
  `multi_effect_variance_component_standard_errors`,
  `multi_effect_ratio_standard_errors`, differentiating the sparse
  `sparse_multi_reml_loglik`.
- **`bb2e89e`** — R surfaces those as `variance_component_se` / `heritability_se`,
  with the permanent block's ratio carried as `permanent_proportion_se`.

## 3a. Decisions and Rejected Alternatives

- **Verified the capability before planning around it.** `target =
  "repeatability"` already existed; the maintainer's "one effect or at least
  three" was an accurate description of the *reachable* surface but not of the
  target list. A live fit confirmed the model was correct and the DENSE CEILING
  was the real blocker. Planning from the issue text alone would have produced a
  new-model slice instead of a routing slice.
- **Routed the sparse path through the existing `repeatability` target rather
  than opening `multi_effect` to `permanent()`.** My first attempt did the
  latter; the test failed because an earlier router already sends `permanent()`
  to `repeatability` and prints the closest working call. That router is better
  UX than what I was adding, so the change was reverted and the test rewritten
  to assert the routing. One model, one surface, with PE-specific labels and
  `repeatability()` / `permanent_effects()` intact.
- **Kept the block-floor lift anyway** (3 → 2). It is the other half of #352:
  `animal + one bare (1 | group)` was unreachable for no engine reason.
- **Did not forward `initial`/`iterations` to the sparse route, and warn instead
  of accepting them.** `fit_multi_effect` does not take them (`HSquared.jl#343`).
  Silently ignoring a start value someone tuned to rescue convergence is worse
  than refusing it.
- **Did not compute `repeatability_interval` on the sparse route.** The engine's
  interval refits DENSELY, so calling it would re-impose the very ceiling the
  route exists to escape.
- **Built the SEs on the sparse loglik, not the dense one.**
  `multi_effect_ratio_interval` already had the FD-Hessian machinery but
  differentiates `_multi_effect_dense` with an explicitly inverted `Ainv`;
  reusing it would have given standard errors that cannot be computed for the
  fits that now newly exist. Rejected as self-defeating.
- **Refused at the boundary up front** rather than letting
  `sparse_multi_reml_loglik` throw "all sigmas must be positive" from inside the
  difference quotient, which reads as a bug rather than a boundary.
- **Deferred pinning the two warning-emitting tests** (`test-multivariate.R:544`,
  `test-repeatability.R:259`) that PR #235's body raised. S2 changes whether
  those warnings fire, so pinning them in S0 would have meant writing an
  expectation and immediately rewriting it. The underlying property is already
  covered by the 56 forced-throw tests.
- **Reverted `devtools::document()` churn** to `NAMESPACE`/`DESCRIPTION`
  (roxygen 8.1.0 installed vs 8.0.0 pinned). Pre-existing drift, not this arc's.

## 4. Files Touched

R (`cc9e040`, `fd10dca`, `bb2e89e`): `R/julia-bridge.R`, `R/hsquared.R`,
`R/hs_control.R`, `R/conditions.R`, `R/extractors.R`, `man/`, `NEWS.md`,
`docs/design/capability-status.md`, `tests/testthat/test-repeatability-sparse-352.R`
(new), `tests/testthat/test-bridge-errors-351.R` (new, via #235),
`tests/testthat/test-julia-error-translation.R`.

Julia (`5135a92e`): `src/likelihood.jl`, `src/HSquared.jl`, `test/runtests.jl`,
`test/test_352_multi_effect_se.jl` (new).

## 5. Checks Run

- R `devtools::test()`: **FAIL=0 ERROR=2 SKIP=101 PASS=3005** (2975 pre-arc).
  Both errors are the pre-existing absent-`sommer` Suggests gate, verified
  identical against a pre-change worktree baseline.
- `pkgdown::check_pkgdown()` **PASS**; `devtools::check()` **2/0/1**, identical
  to the established baseline.
- New R test file **44/44** live against a local `HSquared.jl`; the #235 live
  bridge-error suite **56/56**.
- Julia full `Pkg.test()` **PASS**; new block **20/20**.
- Parity, scale, SE, and REML-constant measurements: see the 2026-09-20
  check-log entry.
- CI: R-CMD-check **SUCCESS** on all three R commits; pkgdown **SUCCESS**; Julia
  Documenter **SUCCESS**; Julia `CI` dispatched manually (it is
  `workflow_dispatch`-only and does not fire on push).

## 6. Tests of the Tests

- The **parity** test is the load-bearing one: two independent estimators on
  identical data must agree, which is the entire justification for calling the
  sparse route "the same model". It discriminates — it is the test that would
  fail if the K = 2 block construction mis-assigned `Z` or the identity block.
- The **SE** test cross-checks against a genuinely different code path
  (`_multi_effect_dense` with densified `Ainv`), not against a second call to
  the same function, so it can catch an error in the sparse loglik itself.
- The **above-the-ceiling** test asserts its own precondition
  (`expect_gt(nobs^2 + n^2, 1e6)`), so it cannot silently degrade into a
  below-the-ceiling test if the fixture sizes are later edited.
- My **first simulation was wrong** and the fit caught it: drawing breeding
  values i.i.d. rather than dropping them down the pedigree produced data with
  no A-structured variance, and the fit correctly put everything in the PE
  block. That near-miss is why `hs_sim_genedrop_bv()` is used and why the
  fixture helper carries a comment saying so.

## 7a. Issue Ledger

- **HSquared.jl#352** — addressed on both lanes; not closed here. Item 3 (warn
  when repeated records are fitted WITHOUT a `permanent()` term) is still open
  and is the next slice.
- **HSquared.jl#351** — R half merged (#235). The engine-side root cause on the
  real two-trait fit is NOT diagnosed yet; still open.
- **HSquared.jl#365** — filed this session (REML-constant offset), then
  corrected by me after reading the docstring that already documents the
  internal convention split.
- **HSquared.jl#364 Ask 4** — the R-lane `:dense` drift is now fixed on `main`.
- **HSquared.jl#343** — `initial`/`iterations` not forwarded on `:auto`; now
  user-visible as a warning rather than silence.
- **#138** (ASReml comparison) — untouched, still open.

## 8. Consistency Audit

Claims checked against primary sources: `K >= 1` read directly in
`fit_multi_effect_reml`, `fit_sparse_multi_effect_aireml` and
`fit_multi_effect`; the dense ceiling read at `src/likelihood.jl:3344`; the
single `variance_component_standard_errors` method confirmed by grep before
asserting that multi-effect fits had none; the REML-constant hypothesis verified
arithmetically rather than eyeballed. `public_covered_count` re-read as **7** and
`Version: 0.9.0` re-read after the final commit.

## 9. What Did Not Go Smoothly

- **My first `multi_effect` change was unreachable.** An earlier router already
  handled `permanent()`. The test caught it; the change was reverted rather than
  kept alongside.
- **An invalid simulation nearly became a false bug report.** See §6.
- **`sparse_multi_reml_loglik` returns a plain tuple, not a NamedTuple**, so the
  first SE implementation failed on `.loglik`. Caught immediately by running it.
- **I filed #365 before reading the relevant docstring**, which already
  documented the convention split. Corrected in-thread with the citation rather
  than leaving the maintainer to discover the overlap.
- **`scale_method` was rejected by the engine-control allowlist** on first live
  run — the allowlist working as designed; the key had to be registered.

## 10. Known Residuals

- The sparse route has **no repeatability-coefficient interval** (§3a).
- **`loglik` is not comparable across `scale_method`** (HSquared.jl#365).
- The SEs are **asymptotic and not coverage-calibrated**; no simulation study of
  their coverage was run.
- Repeatability stays **partial**: no external comparator, no recovery campaign.
- `HSquared.jl#352` item 3 (silent `V_PE` absorption warning) not yet done.
- The engine-side `#351` root cause is undiagnosed.
- Roxygen 8.1.0-vs-8.0.0 pin drift still makes `document()` churn.
- Julia CI does not run on push (`workflow_dispatch` only).

## 11. Team Learning

- **Check whether the capability already exists before designing it.** The
  reported symptom ("only 1 or ≥3 random effects") described the reachable
  surface accurately, and the honest conclusion — a target existed but was
  undiscoverable and dense-capped — changed the slice from "implement a model"
  to "route and scale an existing one". A live fit answered in minutes what
  issue archaeology would not have.
- **When a new code path duplicates an old one, diff the numbers, not just the
  shapes.** Variance components agreed to 1e-5 while log-likelihoods differed by
  688; a shape-only parity test would have passed and shipped a silently wrong
  AIC.
- **A failing test that reveals your change was unnecessary is a good outcome.**
  The `multi_effect` revert left the codebase with one surface instead of two.

## 12. Cross-Product Coverage

- **What this covers:** the Gaussian REML `animal + permanent(1 | id)` model on
  a pedigree relationship, via explicit `engine = "julia"`,
  `target = "repeatability"`, `scale_method = "auto"`; plus `animal + one bare
  (1 | group)` through `multi_effect`; plus asymptotic variance-component and
  ratio standard errors for any K-effect fit.
- It **does NOT cover**: the default `engine = "fit"` path, which is unchanged
  and still single-animal-effect; non-Gaussian families on this route; ML (REML
  only); correlated blocks (these are INDEPENDENT effects — the correlated
  direct–maternal model is a separate target); more than one PE term; or
  `permanent()` on any target other than `repeatability`.
- The standard errors **do NOT cover** coverage calibration, profile or
  bootstrap intervals on this route, or a boundary/flat optimum — where they
  refuse by design rather than returning a number.
- The parity evidence **does NOT cover** above-the-ceiling agreement: the dense
  route cannot run there, so no dense comparator exists at the scale that
  matters most. Agreement is established below the ceiling and extrapolated.
- **Release/status surface, explicitly out of scope:** no version bump (stays
  **0.9.0**), no tag, no CRAN action, `public_covered_count` stays **7**, no
  `validation_status()` row flipped, repeatability stays **partial** on both
  lanes. ASReml remains forbidden as a covered comparator leg and **#138**
  remains open.
