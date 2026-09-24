## Submission summary

This is the first-CRAN submission comment file for hsquared version **0.9.0**
(experimental). It is maintained ahead of any upload so the frozen-artifact
gate has current comment text. **No CRAN upload is performed from this file
alone.** Upload, confirmation, acceptance, and public CRAN availability are
separate states and are recorded only with one identified frozen artifact.

hsquared is the R-facing twin of the Julia engine HSquared.jl. It provides
formula syntax, validation, summaries, and extractors for quantitative-genetic
animal models. Default fitting requires a local Julia and HSquared.jl; CRAN
checks must not invoke live Julia setup. Use `hs_control(engine = "validate")`
to preview the model contract without fitting.

Package status: **experimental**. Version is intentionally `0.9.0`, not
`1.0.0`. Report point estimates only for rows marked `covered` in
`validation_status()`; uncertainty intervals are experimental and not
coverage-calibrated. The 0.9.0 release retains a public covered count of 7;
its opt-in Poisson/log and Binomial/logit path has a narrow three-field engine
contract and makes no covered or coverage-calibrated claim.

## Frozen-artifact steps (maintainer; no upload)

Bank a Julia-free readiness receipt before any submit decision:

1. Clean isolated worktree at the intended release commit
   (`git status --porcelain` empty).
2. Confirm `DESCRIPTION` Version `0.9.0` and public covered count **7**; do not
   bump version in a hygiene-only pass.
3. Confirm `.Rbuildignore` excludes maintainer trees (`docs/`, `tools/`,
   `data-raw/`, agent dirs, `cran-comments.md`, site sources).
4. Build: `R CMD build .` (or `devtools::build()`).
5. Record tarball path, byte size, `shasum -a 256`, and `tar -tzf` inventory;
   reject any forbidden path (`.git`, `.Rhistory`, `.RData`, `.unlazy`,
   agent dirs).
6. Julia-free check on that exact tarball:
   `env -u NOT_CRAN R CMD check --as-cran --run-donttest hsquared_0.9.0.tar.gz`
   (do not set `NOT_CRAN=true` or `HSQUARED_JULIA_TESTS=true`).
7. Retain the check log beside the SHA receipt; expected first-submission
   NOTE only when still unarchived. Do **not** treat this as CRAN acceptance.
8. Only after Gate-1 rights, independent Rose/Grace/Pat audit, and platform
   evidence may a maintainer upload; Registrator / twin Julia register steps
   remain separately gated.

## R CMD check results (local Julia-free gate)

Post-#366 Theme T5 banked a Julia-free readiness receipt on macOS (R 4.6.0,
aarch64-apple-darwin23). Full command log:
`docs/dev-log/check-log.d/2026-09-24-post366-t5-cran-hygiene.md`.

Hygiene tarball (predecessor evidence only; not a submission artifact):

* file `hsquared_0.9.0.tar.gz`
* SHA-256 `d5e40bfb44d7fe0e3048754a027af321160d29965ae871ef455b79adfa44d024`
* size 913650 bytes
* inventory 278 paths; forbidden-path scan clean

```
Status: 1 NOTE
```

0 errors, 0 warnings. The NOTE is the expected first-submission feasibility
note:

```
Maintainer: 'Shinichi Nakagawa <itchyshin@gmail.com>'

New submission
```

Re-freeze SHA / size / inventory on the exact release commit before any
upload; do not treat this hygiene receipt as CRAN acceptance.

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
