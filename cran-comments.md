## Submission summary

This is the first-CRAN submission comment file for hsquared version **0.9.0**
(experimental). The submission is made only from the frozen artifact identified
in the release-gate evidence. Upload, confirmation, acceptance, and public
CRAN availability are separate states and are recorded with that artifact.

hsquared is the R-facing twin of the Julia engine HSquared.jl. It provides
formula syntax, validation, summaries, and extractors for quantitative-genetic
animal models. Default fitting requires a local Julia and HSquared.jl; CRAN
checks must not invoke live Julia setup. Use `hs_control(engine = "validate")`
to preview the model contract without fitting.

Package status: **experimental**. Version is intentionally
`0.9.0`, not `1.0.0`. Report point estimates only for rows marked `covered` in
`validation_status()`; uncertainty intervals are experimental and not
coverage-calibrated. The 0.9.0 release retains a public covered count of 7;
its opt-in Poisson/log and Binomial/logit path has a narrow three-field engine
contract and makes no covered or coverage-calibrated claim.

## Frozen artifact gate

* a fresh `hsquared_0.9.0.tar.gz` is built only from a clean, isolated release
  commit;
* its SHA-256, byte size, source commit, inventory, and direct `R CMD check
  --as-cran --run-donttest` output are retained as gate evidence;
* an earlier failed portable-manual artifact is retained as a failed attempt,
  rather than overwritten;
* HSquared.jl publication is separately recorded and is not evidence for any
  additional R capability.

## R CMD check results (local gate)

Local macOS normal package checks and the direct frozen-artifact `R CMD check
--as-cran` are run on the isolated release commit. Their exact receipt is part
the independent gate; it is not a claim that CRAN has accepted the package.

```
Status: see the immutable release-gate receipt for the submitted artifact
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
