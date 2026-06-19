# After-task — Next-big-4 slice 5 (#29): gryphon end-to-end worked vignette (2026-06-19)

## Task goal

Program-2 workstream #2 (UX): a worked, real-dataset walkthrough of one univariate animal model
end to end — fit, heritability with the experimental CI/SE, breeding values + accuracy, and the new
diagnostic `plot()` — showcasing the full extractor surface in one place.

## Files changed

- `vignettes/articles/gryphon-worked-example.Rmd` — new article (all chunks `eval = FALSE`).
- `_pkgdown.yml` — registered in navbar + articles index.
- `NEWS.md` — dev bullet (#29).

## Honesty (self-audited, Rose lens)

- No fabricated numbers: only the **published/validated** point estimates (σ²a=3.3954,
  σ²e=3.8286, h²=0.470) are quoted; CI/SE are shown as extractor **calls**, never invented values.
- Explicit caveats up front: the fit needs a local engine (chunks not executed at build); gryphon
  uses a **supplied** relationship matrix (raw pedigree pathological), with a pointer to the
  ordinary `animal(1 | id, pedigree = ped)` path; the CI/SE surfaces are experimental (V1-HERIT-CI,
  partial). Cross-links to Fitting models + the benchmark + validation-evidence.
- Complements rather than duplicates: distinct from the broad fitting-models tour and the
  comparator-focused benchmark — this one is the extractor + plot + biological-interpretation
  end-to-end on a real dataset.

## Checks

- `pkgdown::check_pkgdown()` clean; `pkgdown::build_article(...)` renders. Docs-only (no `R/`
  change) so prior `devtools::test()` 840/0/0/27 + `check(--no-manual)` 0/0/0 hold. pkgdown
  deploys on push.

## Next actions

- Remaining program-2 R-ownable: #32 (Mrode beyond 3.1 — needs published-constant provenance,
  do with research rigor); #34 multivariate recovery harness (needs live engine to run recovery);
  #21 PEV/reliability `:selinv` (needs a live probe). #3/#4 of the big 4 remain twin-gated.
