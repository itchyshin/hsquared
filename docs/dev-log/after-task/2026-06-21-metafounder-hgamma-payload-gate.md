# After-task — metafounder H^Gamma parser/payload gate (2026-06-21)

## 1. Goal

Finish the next safe R-lane step after the metafounder/H^Gamma contract PR:
build a narrow parser/model-spec/bridge-payload gate for supplied-`Gamma`
single-step `H^Gamma`, while keeping the live fit, extractors, comparator
evidence, and covered support explicitly out of scope.

## 2. Implemented

- Extended `single_step(1 | id, pedigree = ped, markers = M)` with optional
  paired `group =` and `Gamma =` arguments for the contract-only
  `metafounder_single_step` payload branch.
- Validated `group` as an ID-keyed vector or data frame, aligned it to normalized
  pedigree order, and required non-missing labels for animals with unknown
  parent slots.
- Validated supplied `Gamma` as finite, square, symmetric, positive
  semidefinite, and dimensionally matched to the resolved metafounder group
  labels; dimnamed matrices are reordered to first-appearance label order.
- Serialized `group_of`, `Gamma`, `gamma_labels`, and
  `relationship_source = "metafounder_single_step"` in the internal bridge
  payload.
- Made `target = "metafounder_single_step"` a recognized target that stops with
  an honest "contract-only payload gate" error before live Julia execution.
- Updated NEWS, formula status, capability/debt/public-claims ledgers,
  bridge-gap/contract docs, issue map, coordination board, check-log, roxygen
  output, and the genomic prediction article.

## 3a. Decisions and Rejected Alternatives

- Chose a payload-only branch rather than a live JuliaCall fit branch. The Julia
  twin has `fit_metafounder_single_step_reml()`, but the R bridge still needs
  live `Gamma = 0` reduction and nonzero-`Gamma` sensitivity probes before it
  can safely claim a fitted path.
- Kept animal-only `metafounder()` inert. This slice is the single-step
  `H^Gamma` payload gate only; explicit metafounder effects/extractors remain
  a separate result-shape question.
- Kept `Gamma` supplied, never estimated. Any Gamma-estimation syntax or control
  would be a different statistical capability.
- Kept ordinary `target = "single_step_construct"` separate. If `group` and
  `Gamma` are supplied, the ordinary target errors rather than silently falling
  through.

## 4. Files Touched

- `NEWS.md`
- `R/bridge-payload.R`
- `R/formula-status.R`
- `R/genomic-markers.R`
- `R/hsquared.R`
- `R/julia-bridge.R`
- `R/model-spec.R`
- `docs/design/02-formula-grammar.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/19-on-main-bridge-gap.md`
- `docs/design/27-metafounder-single-step-contract.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/issue-map.md`
- `man/genomic_markers.Rd`
- `tests/testthat/test-phase0-api.R`
- `tests/testthat/test-single-step-construct.R`
- `vignettes/articles/genomic-prediction.Rmd`
- `docs/dev-log/after-task/2026-06-21-metafounder-hgamma-payload-gate.md`

## 5. Checks Run

- `air format .` — clean.
- `Rscript --vanilla -e 'devtools::document()'` — regenerated
  `man/genomic_markers.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter = "single-step|phase0-api")'`
  — 170 pass, 0 fail, 0 warn, 6 skip.
- `Rscript --vanilla -e 'devtools::test()'` — 1248 pass, 0 fail, 0 warn,
  55 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` — clean.
- `git diff --check` — clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  — 0 errors, 0 warnings, 0 notes.

## 6. Tests of the Tests

- The first focused run caught a real routing gap: the new
  `metafounder_single_step` target was accepted by target validation but not
  included in `hs_effect_targets("single_step")`. Adding it made the new
  target-fence test pass.
- The payload test would fail if marker rows were not reordered to
  `genotyped_rows`, if `Gamma` dimnames were not reordered to label order, or if
  `group_of` were not aligned to normalized pedigree IDs.
- The malformed-input tests exercise missing paired `group`/`Gamma`, missing
  pedigree IDs, missing unknown-parent labels, nonsquare `Gamma`, mismatched
  dimnames, and non-PSD `Gamma`.
- The target-fence tests confirm that `metafounder_single_step` does not fit yet
  and that ordinary `single_step_construct` rejects the H^Gamma branch.

## 7a. Issue Ledger

- Metafounder / `H^Gamma` contract row: advanced from contract-only syntax to
  partial R payload gate.
- No issue was closed as covered. The remaining fit/extractor/comparator work is
  still open.
- BLUPF90-family comparator evidence remains blocked locally because
  `renumf90`, `airemlf90`, `blupf90`, `remlf90`, and `gibbsf90` are absent from
  PATH.

## 8. Consistency Audit

- Searched the stale claim surface for `metafounder`, `H^Gamma`,
  `metafounder_single_step`, `single_step_construct`, `Gamma = Gamma`,
  `payload gate`, and old "no R model-spec branch / no bridge payload" wording.
- Checked the Julia twin primitive contract in `src/pedigree.jl`,
  `src/genomic.jl`, and `test/runtests.jl`: the R alignment mirrors the engine's
  first-appearance group-label order and unknown-parent-label requirement.
- Swept NEWS, formula grammar, capability status, validation debt, public claims,
  issue map, bridge-gap doc, contract doc, and the genomic prediction article so
  they all say the same thing: payload gate exists; live fit and validation do not.
- Confirmed the two unrelated untracked handover files were not touched.

## 9. What Did Not Go Smoothly

The target recognition initially had a split-brain bug: `hs_validate_julia_target()`
knew about `metafounder_single_step`, but effect-target routing did not. The new
target-fence test found it quickly, and `hs_effect_targets("single_step")` now
includes the contract-only target.

## 10. Known Residuals

- No live R-to-Julia metafounder/H^Gamma fit branch yet.
- No `metafounder_effects()` or `gamma_matrix()` extractor.
- No live `Gamma = 0` reduction probe through the R bridge.
- No live nonzero-`Gamma` sensitivity probe through the R bridge.
- No BLUPF90-family or other independent external comparator evidence for
  metafounder single-step.
- `Gamma` remains supplied by the user and is not estimated.

## 11. Team Learning

This was the right size for the next 5-hour sprint: after banking the contract
PR, the productive move was a payload gate with hard fences, not a premature fit
claim. The next branch can be similarly narrow: wire the live call and prove
`Gamma = 0` reduction plus nonzero-`Gamma` sensitivity before adding extractors
or capability language.
