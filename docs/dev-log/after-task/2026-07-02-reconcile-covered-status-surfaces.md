# After-task — reconcile covered-status surfaces (R twin, 2026-07-02)

Branch: `docs/2026-07-02-reconcile-covered-status-surfaces` (off `main` @ `7e848ee`).
Owner: Claude (R lane). Class: documentation-consistency reconciliation.

## What changed

Four opt-in models were already promoted to `covered (validation-scale)` by prior
**maintainer-signed G10 public-flip commits**, but those flips were propagated
unevenly across the status surfaces. This slice propagates them to the lagging
surfaces so every surface + the `model-status` pkgdown article agree on
covered-vs-experimental. It makes **no new coverage decision**.

The four already-covered models and their G10 flip commits:

- common-environment two-effect **leg** (`target = "two_effect"`, `common_env`) — `7538663`
- arbitrary-N independent `(1 | g)` multi-effect (`target = "multi_effect"`) — `9fe1458`
- random-regression k=2 (`target = "random_regression"`) — `9cb3481`
- direct–maternal correlated 2×2 G (`target = "direct_maternal"`) — `e3462d3` (the template; already propagated everywhere)

Corroborating pre-existing evidence (unchanged here): `validation_status()`
capability 8 is already `status = "covered"` with the "covered: common-env +
(1|g) iid / A2=I; experimental: maternal / A2=pedigree" split, asserted by
`tests/testthat/test-phase0-api.R`; `formula-status.R` behavior for RR and
direct–maternal already read covered.

Files (7):

- `R/formula-status.R` — `common_env` and `(1 | group)` `current_behavior`
  strings flipped experimental → "covered at validation scale" (ASCII-only).
- `docs/design/06-public-claims-register.md` — two-effect row status
  partial → covered with a common-env-covered / maternal-experimental split;
  new multi-effect + RR covered rows.
- `docs/design/capability-status.md` — two-effect row split (row 29); new
  multi-effect row; RR row (34) partial → covered.
- `vignettes/articles/model-status.Rmd` — the old "Opt-in and experimental"
  section split into **"Opt-in and covered at validation scale"** (common-env,
  multi-effect, RR, direct–maternal) and **"Opt-in and experimental"**
  (repeatability, maternal two-effect leg, genomic/GREML, single-step, SNP-BLUP,
  multivariate); cross-references in "Exists now", "Current limits", and "Not
  implemented yet" reconciled.
- `ROADMAP.md` — Phase 2 status text: common-env / multi-effect / RR covered;
  repeatability + maternal two-effect leg experimental.
- `NEWS.md` — dev-version RR entry flipped experimental → covered; new
  dev-version entry for the common-env + multi-effect covered promotions
  (prior-release "experimental" entries left as historical record).
- `docs/dev-log/coordination-board.md` — one coordination row.

## Scope / honesty fences (held)

- **No new coverage decision** — propagation of four G10-signed flips only.
- `validation_status()` unchanged: **21 rows**, capability 8 covered, covered-count 4.
- **Stay experimental / partial:** maternal two-effect leg (A2 = pedigree),
  repeatability, genomic/GREML, single-step, SNP-BLUP, multivariate,
  non-Gaussian, metafounder.
- Fences preserved: direct–maternal Willham **labelled triple** (never a bare
  scalar); RR `h²(t)` **curve** (scalar `heritability()` errors), k=2 only,
  homogeneous-residual / no-PE overstatement caveat, point-estimate only;
  two-/multi-effect animal-block = narrow-sense h², other blocks =
  variance-explained proportions (not heritabilities), intervals
  asymptotic / **not** coverage-calibrated; ALL opt-in, **not** the default
  `engine = "fit"`, dense/validation-scale, REML-only, not production.

## Checks

- `test_dir(filter = "phase0-api|formula-animal|engine-setup-and-honesty")` —
  pass (1 live-Julia test skipped on CRAN, expected).
- Article render dry check (`rmarkdown::render` to tempfile) — OK.
- `pkgdown::check_pkgdown()` — "No problems found."
- `rg '[^\x00-\x7F]' R/formula-status.R` — empty (ASCII-clean; the repeated
  R-CMD-check non-ASCII trap avoided).

## Rose audit

Real `rose-systems-auditor` on the branch diff → **PROMOTE-WITH-CHANGES**. All
seven files verified clean, consistent, fence-preserving, no new coverage claim;
the four G10 flips verified genuine (maintainer-authored). Single REQUIRED
finding: **exclude `AGENTS.md` and `CLAUDE.md`** (unrelated pre-existing local
second-brain wiring carrying a personal absolute path) from the commit — applied
(only the 7 reconciliation files + this report + the check-log entry are staged).

## Next actions / retained debt (unchanged by this slice)

- Debt inherited by the covered rows (not retired): 2nd independent same-estimand
  comparator on a different lineage for direct–maternal (`blupf90+` AIREMLF90
  2×2-G); broader-DGP / larger-scale recovery; calibrated intervals; the maternal
  two-effect leg's own recovery gate + comparator; k≥3 RR.
- Optional (Rose): the house-convention phrase "Covered at VALIDATION scale,
  experimental, opt-in" reads as internally tense; a future wording pass could use
  "Covered at validation scale (experimental tier)". Not required.
