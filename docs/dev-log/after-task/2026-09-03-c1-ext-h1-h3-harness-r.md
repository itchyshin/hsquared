# After-task — C1-ext H1/H3 R PATH_ONLY twin (no flip)

Date: 2026-09-03. Lane: R public (`hsquared`). Branch:
`cursor/09-h1-h3-harness-r-20260903`. Type: evidence scaffolding / twin pointer.

```
PLATFORM: cursor | LANE: cursor/09-h1-h3-harness-r-20260903
OTHER LANES: Codex DRAFT #137 cite-only · R #158–#165 cite-only
  · Julia #294 cite (this is the twin) · Dropbox checkout FOREIGN
Active lenses: Ada · Shannon · Hopper · Fisher · Rose fence
Spawned subagents: none
Current lane: R C1-ext PATH_ONLY pointer
  (~/local-scratch/lanes/hsquared-09-h1-h3-20260903)
```

## Goal

Give Julia [#294](https://github.com/itchyshin/HSquared.jl/pull/294) an R
public-lane twin: smoke / PATH_ONLY C1-ext intervals prep aligned with the
design-39 H0 claim-level template. Do not run a 2000-rep confirm. Do not
ratify H0 Layer B. Do not rescue repeatability `t`. Do not flip covered.

## What landed

- `sim/phase1_interval_coverage_ext.R` — include-safe PATH_ONLY pointer.
  Same five campaigns as Julia #294. Writes `claim_eligible=false`.
  Rejects `screen` / `confirm` / `promote` (no R numeric harness).
- `tests/testthat/test-c1-ext-h1-h3-harness.R` — fast contract test
  (no Julia). Locks campaign names, characterization-only `t`, blocked
  `confint()` / `vcov()` / `profile()`, missing
  `genetic_correlation_interval()`, count 7 / experimental 0.7.0.
- Recovery-checkpoint pointer + this after-task + check-log.d.

## Public claim audit

Allowed: "R PATH_ONLY pointer exists; Julia #294 holds the numeric harness;
`confint()` still blocked; no R coverage bank."  
Blocked: coverage-calibrated intervals; `point`; covered flip; count 8;
repeatability rescue; H0 Layer B; genomic / FA / NG interval claims;
0.9.0 / 1.0 / CRAN.

## Checks this slice

See `docs/dev-log/check-log.d/2026-09-03-c1-ext-h1-h3-harness-r.md`.
Focused test: 36/36. Coordination board not edited (other 0.8 / G5 / H0
lanes hold shared docs). `docs/design/01-v0.1-contract.md` not touched
(#161 holds H0 Layer A).

## Tests of the tests

The contract test sources the helper and asserts the smoke TSV, not a
fitted interval. A green run cannot be read as coverage. `h1_t` stays
`characterization_only` even if a later Julia confirm looks pretty.

## Lease / collision

Dropbox checkout was FOREIGN (Codex #137). Work ran in a new worktree off
`origin/main` (`96318bf9`). Lease claimed new files only
(`LANE_ID=cursor:hsquared:09-h1-h3-r`).

## What did not go smoothly

`confint()` wording on `origin/main` is not the older "planned, not
implemented" string from the FOREIGN Dropbox branch. The test matches
main.

## Known limitations

A true numeric R twin is still not possible: no C1-ext driver, no
`genetic_correlation_interval()` generic, coverage is a Julia gate.
This PR closes the **missing pointer**, not the 0.9 honesty gates.

## Next

1. Julia Totoro 1-task smoke + `seff` after G0 (Julia lane).
2. Julia fir confirm under a new SHA. Then Fisher map. No silent `point`.
3. H0 Layer B remains unpaid (#161 is Layer A only).
4. Count stays 7 until a later Rose CLEAN + owner flip, not this PR.
