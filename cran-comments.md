## Submission summary

This is a **draft** first-CRAN comment file for hsquared version **0.5.0**
(experimental). It is prepared for the A20 local gate and is **not** a live
submission. Tarball SHA, win-builder, and R-hub results below remain
placeholders until the release pass after HSquared.jl is in General (Julia
registers first).

hsquared is the R-facing twin of the Julia engine HSquared.jl. It provides
formula syntax, validation, summaries, and extractors for quantitative-genetic
animal models. Default fitting requires a local Julia and HSquared.jl; CRAN
checks must not invoke live Julia setup. Use `hs_control(engine = "validate")`
to preview the model contract without fitting.

Package status at first CRAN: **experimental** (D-41). Version is intentionally
`0.5.0`, not `1.0.0`. Report point estimates only for rows marked `covered` in
`validation_status()`; uncertainty intervals are experimental and not
coverage-calibrated.

## Artifact (fill at release pass)

* tarball `hsquared_0.5.0.tar.gz`;
* SHA-256 `TBD`;
* size TBD;
* built from clean twin-aligned commit `TBD` (after Julia General acceptance).

## R CMD check results (local gate — update at release)

Local macOS `devtools::check()` / `R CMD check --as-cran` on the campaign branch
(worktree tip recorded in `docs/dev-log/check-log.d/`):

```
Status: see check-log shard for A20
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
