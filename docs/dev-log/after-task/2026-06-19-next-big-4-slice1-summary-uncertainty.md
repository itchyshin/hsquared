# After-task — Next-big-4 launch + slice 1 (summary uncertainty display, 2026-06-19)

## Task goal

Open the second post-v0.1.0 program (the "next big 4", maintainer-confirmed: all four,
issues-first) and ship its first R-ownable slice — surface the experimental uncertainty fields
(heritability CI, variance-component + heritability SEs, repeatability CI) in
`summary()`/`print()`, leveraging the surfaces shipped in the ultracode WS2 wave.

## Active lenses / agents

- Lenses: Pat + Florence (applied-user readout), Fisher/Falconer (uncertainty framing), Rose
  (honesty), Ada/Shannon (program structure). No spawned subagents (bounded R-ownable slice).
- Lane: R.

## Files changed

- `R/fit-object.R` — `summary.hsquared_fit()` carries the four experimental uncertainty fields;
  `print.summary_hsquared_fit()` calls a new internal `hs_print_uncertainty()` that prints them
  when present, labelled experimental/asymptotic.
- `tests/testthat/test-summary-uncertainty.R` — new fixture tests (display present, omitted when
  absent, repeatability path).
- `NEWS.md` — dev-section bullet (#28).
- `docs/dev-log/2026-06-19-next-big-4-program.md` — the next-big-4 program plan.
- `docs/dev-log/issue-map.md` — next-big-4 section (#27–#34).
- `docs/dev-log/coordination-board.md` — program-2 launch + slice-1 row.
- GitHub: filed #27 (UX epic) + #28–#34 (next-big-4 backbone).

## Checks

- `air format` clean; `devtools::document()` (no new exports — `hs_print_uncertainty` internal);
  `devtools::test()` 831 pass / 0 fail / 0 warn / 27 skip; `pkgdown::check_pkgdown()` clean;
  `devtools::check(--no-manual)` 0/0/0 (+benign timestamp note). pkgdown deploys on push.

## Public claim audit (Rose)

- No capability promoted. The display only shows fields a fit already carries, every block is
  labelled "experimental; asymptotic REML", and absent fields print nothing (no implication of
  availability). Mirrors the partial rows V1-HERIT-CI / V3-REPEAT-REML.

## Tests of the tests

- The "omits when absent" test guards against the block printing for fits without the fields; the
  repeatability test checks the t-interval path (distinct from h²).

## Coordination notes

- Program 1 (post-v0.1.0) is finished; this opens program 2. Issues-first backbone filed
  (#27–#34) before execution, per the established pattern. #3/#4 of the big 4 are joint with the
  twin (cross-lane issues HSquared.jl#37/#41/#42).

## Known limitations / next actions

- Next R-ownable slices: #29 (gryphon end-to-end vignette), #30 (Florence figures), #31
  (sommer/pedigreemm benchmark), #32 (Mrode beyond 3.1), #33 (comparator policy), #34
  (multivariate recovery harness). #4 (FA) and the multivariate gate stay twin-led via issues.
