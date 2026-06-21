# After-task — metafounder H^Gamma parser/payload gate (2026-06-21)

## Task Goal

Execute the first Big 3 continuation from clean R-lane scope: move Candidate A
from a documented contract to a narrow, honest R parser/payload gate for supplied
`Gamma` single-step `H^Gamma`, without claiming live fitting or comparator
coverage.

## Active Lenses And Agents

Active lenses: Ada, Shannon, Boole, Noether, Hopper, Lovelace, Curie, Fisher,
Jason, Rose, Grace.

Spawned subagents: none.

Current lane: R bridge/payload, coordinated with the Julia twin state already on
HSquared.jl main from PR #128.

## Files Changed

- `R/model-spec.R`: `single_step(..., group =, Gamma =)` now parses to a
  `metafounder_construct` source, validates group/Gamma shape and alignment, and
  records `relationship = "metafounder_single_step"`.
- `R/bridge-payload.R`: the single-step construction payload now carries
  `group_of`, `Gamma`, `gamma_labels`, `relationship_source =
  "metafounder_single_step"`, and `metadata$gamma_source = "supplied"` for the
  metafounder branch.
- `R/hsquared.R`, `R/julia-bridge.R`: `target = "metafounder_single_step"` is
  recognized, fenced to the matching formula branch, and stopped before fitting
  with explicit contract-only wording.
- `R/formula-status.R`, `R/genomic-markers.R`, `man/genomic_markers.Rd`, and
  tests: status, help, parser payload, guard, and target-fence tests now cover
  the payload gate.
- `NEWS.md`, `vignettes/articles/genomic-prediction.Rmd`, `docs/design/*`, and
  `docs/dev-log/issue-map.md`: public and internal wording now says partial
  payload gate, not implemented fit.
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`, and this
  report: recorded commands, outcomes, blockers, and next action.

## Checks Run

- `air format .` — clean.
- `Rscript --vanilla -e 'devtools::document()'` — regenerated
  `man/genomic_markers.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|single-step-construct|formula-animal")'`
  — 218 pass, 0 fail, 0 warn, 5 skip.
- `Rscript --vanilla -e 'devtools::test()'` — 1248 pass, 0 fail, 0 warn, 55 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` — clean.
- `git diff --check` — clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")'`
  — 0 errors, 0 warnings, 0 notes.
- `command -v` probe for `renumf90`, `airemlf90`, `blupf90`, `remlf90`, and
  `gibbsf90` — all missing locally.

## Public Claim Audit

Clean. This slice claims only:

- R validates and serializes a contract-only supplied-`Gamma` single-step
  `H^Gamma` payload.
- `target = "metafounder_single_step"` is recognized but not fit-wired.
- `Gamma` is supplied by the user, not estimated.

It does not claim:

- R fits metafounder or `H^Gamma` models.
- Any metafounder extractor exists.
- BLUPF90-family comparator evidence exists.
- Metafounder or multivariate support moves to covered.

## Tests Of The Tests

The new `test-single-step-construct.R` cases fail if `group_of` is not reordered
to normalized pedigree order, if named `Gamma` is not reordered to resolved
metafounder labels, if malformed group/Gamma inputs are accepted, or if
`target = "metafounder_single_step"` silently proceeds to a fit. The
`formula_status()` regression now fails if the payload-gate row disappears or
stops being labelled as not fit-available.

## Coordination Notes

Julia main already contains the supplied-`Gamma` engine primitives from PR #128.
This R slice consumes that as a contract target only; it does not call the Julia
functions yet. The second-comparator lane remains blocked locally because the
BLUPF90-family executables are not on PATH. The untracked Codex handover files in
`docs/dev-log/after-task/` and `docs/dev-log/handover/` were preserved and left
unstaged.

## What Did Not Go Smoothly

This continuation started from an in-progress local diff that already contained
the core parser and tests. I treated those edits as live workspace state, audited
them, tightened the public/documentation surfaces, and avoided expanding scope
into a live Julia fit.

## Known Limitations

- The animal-only `metafounder()` term is still inert.
- `target = "metafounder_single_step"` stops before fitting.
- No live `Gamma = 0` reduction or nonzero-`Gamma` sensitivity probe exists on
  the R bridge yet.
- No `metafounder_effects()` or `gamma_matrix()` extractor exists.
- The BLUPF90-family second-comparator run remains locally blocked by missing
  executables.

## Next Actions

1. Bank this narrow R PR.
2. Big 2: unblock or reroute second-comparator evidence. If BLUPF90-family tools
   become available, run the banked starter packet; otherwise keep the blocker
   explicit and choose another independent same-estimand comparator.
3. Big 3: from clean main, either live-wire the `metafounder_single_step` bridge
   with `Gamma = 0` and nonzero-`Gamma` probes, or take the lower-risk bridge
   cleanup slice for standard PEV/reliability payload fields.
