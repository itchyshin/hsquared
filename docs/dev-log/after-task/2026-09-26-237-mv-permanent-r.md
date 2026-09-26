# After-task: hsquared#237 R-lane cbind + permanent() (2026-09-26)

Active lenses: Ada, Shannon, Boole, Curie, Rose (perspectives; no spawned subagents)
Current lane: R

## Goal

Make repeated-measures multivariate fittable on the default `cbind()` route with
`permanent(1 | id)` so Va and Vpe can be identified. Stay experimental 0.9.0.
`public_covered_count` stays 7. No covered flip. Consume the frozen Julia API
on HSquared.jl#398; do not redesign the engine.

## Implemented

- Parser accepts `cbind(...) ~ ... + animal(...) + permanent(1 | id)` on the
  default route. Other multivariate second effects stay named planned rejects.
- Default `engine = "fit"` and `engine = "julia"` with no target auto-select
  `multivariate_repeatability`. Explicit `target = "multivariate"` + PE upgrades
  to that target. R never calls `fit_multivariate_reml` on this formula.
- Bridge `hs_fit_julia_multivariate_repeatability_payload()` calls
  `HSquared.fit_multivariate_repeatability_reml(Y, X, Z, Ainv)` and normalizes
  `animal` / `permanent` / `residual` blocks. Result diagnostics target is
  `multivariate_repeatability_reml`; status is experimental.
- Animal-only cbind repeated-records warning names the live `permanent()` lever.
- Honesty: formula-status, capability-status, validation-debt, design-57, NEWS.
  Version stays 0.9.0. Count stays 7.

## Checks

- `air format .` ran.
- `devtools::document()` wrote `man/hs_control.Rd`. NAMESPACE roxygen 8.0.0
  churn was reverted (pin is 8.1.0).
- Focused
  `devtools::test(filter = "multivariate-permanent-237|engine-julia-unsupported-parity|repeated-records-warning-352|hs-control-targets|julia-error-translation|multivariate-fence-contract")`:
  FAIL 0 / WARN 0 / SKIP 3 / PASS 176. Live #237 fit passed against Julia #398.
- NOT_CRAN was not set.

## Public claim audit

Experimental / partial only. No covered flip. No version bump. The covered
animal-only cbind row is unchanged. Univariate repeatability stays partial.

## Tests of the tests

Pure-R parser, payload, validate, and refusal tests run without Julia. The live
fit test skip-guards on `hs_skip_live_julia()` plus
`isdefined(HSquared, :fit_multivariate_repeatability_reml)`. Old SG1
named-reject expectation was inverted to a parse assertion.

## Coordination

Worktree `~/local-scratch/lanes/hsquared-237-mv-permanent` from `origin/main`.
Dropbox dirty trees untouched. Codex CRAN files untouched. Julia engine sources
not edited. Frozen API is HSquared.jl#398 @ `410f7efd`. Do not merge that PR
from this lane.

## Known limitations

No recovery of G0 and P0. No comparator. No covered path. Live bridge needs
Julia on PATH and a checkout that exports the fitter (sibling WT
`~/local-scratch/lanes/HSquared.jl-237-mv-permanent`).

## Next actions

1. Owner may merge Julia #398 separately; not from this R lane.
2. Rose: confirm experimental (partial) while recovery and a comparator are
   still missing.
3. Do not flip covered. Do not Registrator. Do not CRAN upload.
