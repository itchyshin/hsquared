# After-task — Next-big-4 slice 6 (#32): Mrode Example 3.2 sire anchor (2026-06-19)

## Task goal

Program-2 workstream #1 (validation depth): a second published external-canon anchor beyond
Example 3.1, extending coverage to a new model class, CI-runnable and Julia-free, pinned to
published constants with multi-source provenance (never fabricated).

## Active lenses / agents

- **Spawned subagent:** `mrode-validation-canon` — researched candidates and recommended GO on
  Example 3.2 (sire model) with provenance; NO-GO/defer on 4.1 / maternal / single-step (couldn't
  corroborate published solutions from ≥2 sources). Autonomous run (3h goal).
- Lenses: Curie/Fisher (test design), Rose (honesty).
- Lane: R.

## Files changed

- `R/validation-fixtures.R` — new `hs_mrode_example_3_2_sire_fixture()` (sire NRM on {1,3,4} via
  the same tabular recursion as 3.1; sigma_s2=5, sigma_e2=55, alpha=11; published p.48 solutions).
- `tests/testthat/test-mrode-sire-anchor.R` — pins the reference Henderson solver to the published
  sire solutions + both sex means + the male−female contrast (1e-6), plus a test-of-test.
- `NEWS.md` — dev bullet (#32).

## Provenance (multi-source, re-solved — the honesty bar)

Mrode (2014, 3rd ed.) Example 3.2 (p.48), sire model on the WWG data: published sex means
(male 4.33567107, female 3.38198579) and sire solutions (1: 0.02200220, 3: 0.01402640,
4: −0.04304180). Confirmed against the masuday BLUPF90 tutorial (p.48) and the austin-putz
chapter-3 reproduction (inputs + MME construction), and independently re-solved in pure base R to
~1e-7. Related sires (sire 4's sire = sire 1) — the unrelated-sire variant does NOT match,
confirming the parameterization.

## Checks

- `air format` clean; `devtools::test()` PASS (incl. the new anchor + the existing 3.1 anchor);
  `devtools::check(--no-manual)` 0/0/0 (see CI-evidence note). Internal fixture (no new export, no
  man page, no pkgdown change). Pure R, no Julia, no skip guards — runs on CI.

## Public claim audit (Rose lens, applied)

- The anchor pins PUBLISHED digits, not solver-generated numbers (closes the
  internally-consistent-but-wrong failure mode for a second model class). The sire model is framed
  as planned in hsquared; this validates the reference solver against the published sire-model
  canon, it does not promote a sire-model fitting capability. No fabricated numbers.
- The research lens returned NO-GO on the repeatability (4.1), maternal, and single-step (11.x)
  anchors — their published solutions could not be corroborated from ≥2 sources — so those are
  deferred, not pinned. Recorded honestly on #32.

## Known limitations / next actions

- Anchors the reference solver, not a production sire-model fit path (none exists). Repeatability /
  maternal / single-step published anchors remain open until a second citable reproduction is found.
- Remaining program-2 R-ownable work is thin: #34 (multivariate recovery harness — needs the live
  engine to run), #21 (PEV/reliability `:selinv` — needs a live probe). #3/#4 of the big 4 remain
  twin-gated.
