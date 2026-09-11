## Submission summary

This is a **draft** first-CRAN comment file for hsquared version **0.9.0**
(experimental). It is prepared only for an independent frozen-artifact gate;
it is **not** a CRAN submission.  No tag, merge, registry action, or public
release has occurred. The exact tarball receipt is intentionally maintained in
the release-gate evidence outside this draft until the independent gate passes.

hsquared is the R-facing twin of the Julia engine HSquared.jl. It provides
formula syntax, validation, summaries, and extractors for quantitative-genetic
animal models. Default fitting requires a local Julia and HSquared.jl; CRAN
checks must not invoke live Julia setup. Use `hs_control(engine = "validate")`
to preview the model contract without fitting.

Package status for this candidate: **experimental**. Version is intentionally
`0.9.0`, not `1.0.0`. Report point estimates only for rows marked `covered` in
`validation_status()`; uncertainty intervals are experimental and not
coverage-calibrated. The 0.9.0 candidate retains a public covered count of 7;
its opt-in Poisson/log and Binomial/logit path has a narrow three-field engine
contract and makes no covered or coverage-calibrated claim.

## Frozen artifact gate

* a fresh `hsquared_0.9.0.tar.gz` is built only from a clean, isolated source
  candidate;
* its SHA-256, byte size, source commit, inventory, and direct `R CMD check
  --as-cran --run-donttest` output are retained as gate evidence;
* an earlier failed portable-manual artifact is retained as a failed attempt,
  rather than overwritten;
* HSquared.jl General registration is deferred and is not a precondition for
  this preparation gate.

## R CMD check results (local gate)

Local macOS normal package checks and the direct frozen-artifact `R CMD check
--as-cran` are run on the isolated candidate. Their exact receipt is part of
the independent gate; it is not a claim that CRAN has accepted the package.

```
Status: pending independent frozen-artifact gate
```

Expected first-submission NOTE when submitted:

```
New submission
```

## Test-suite design

* CRAN lane: formula, extractors, error paths, release identity, and contract
  tests that do **not** call `JuliaCall::julia_setup()`.
* Live Julia / recovery / comparator suites: repository CI and maintainer
  machines only (`NOT_CRAN=true` or `HSQUARED_JULIA_TESTS=true`).
* Defense in depth: `hs_skip_live_julia()` (see `tests/testthat/helper-julia-skip.R`)
  mirrors drmTMB's `drm_skip_live_julia()` so non-interactive CRAN checks never
  hang inside Julia setup.

## Downstream dependencies

There are no CRAN reverse dependencies because this is the package's first
submission.

## Twin citation

Cite the R+Julia twin as one data publication when the shared DOI (D-23) is
issued. Until then, `citation("hsquared")` returns the package Manual entry with
an explicit twin-DOI placeholder note.
