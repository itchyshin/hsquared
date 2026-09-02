# 2026-09-02 — Pat UX item 4: next-call errors + cbind warn-once

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (formula / error wording). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

When a user writes a natural second-effect formula on the default path
(`+ common_env(...)`, `+ permanent(...)`, `+ maternal_genetic(...)`,
`animal(rr(...))`), the error pastes the closest working `hsquared()` call
with the named `target =`. Default-path `cbind()` still fits (MV-4) but
warns once that the route is experimental / partial.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/conditions.R` `R/hsquared.R` | clean |
| `devtools::test(filter = "common-env$\\|maternal$\\|repeatability$\\|random-regression$\\|multivariate$")` | FAIL 0; live-Julia skips only |
| `devtools::test(filter = "genomic$\\|single-step$\\|relmat-precision\\|phase0-api\\|direct-maternal")` | FAIL 0; other default-path "experimental and opt-in" aborts unchanged |
| `devtools::test(reporter = "summary")` | FAIL 0; 73 pre-existing live-Julia / comparator skips |

`devtools::document()` not run: no exported roxygen change.
`devtools::check()` not run: wording + warn-once only.

## Claim boundary

- `common_env()` / `two_effect` still covered at validation scale, opt-in.
- `permanent()` / `repeatability` still experimental.
- `maternal_genetic()` still names both `two_effect` (experimental) and
  `direct_maternal` (covered Willham triple, not a scalar h2).
- `rr(...)` / `random_regression` still covered at k = 2 only.
- `cbind()` still routes on the default path and stays `partial`.
- No README rewrite (sibling lease). No capability-status / validation_status
  row edits.

## Test of the tests

Message-content assertions pin `Closest working call`, the named `target =`,
and the user's formula / `data =` name. Genomic / relmat / single-step
default-path tests still match the older "experimental and opt-in" abort.
