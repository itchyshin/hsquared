# check-log — 2026-09-02 h2 A21 C6 + r_am identity (A21 GAP)

**Arc:** A21 after-push tidy — **C6** (two `m2` denominators + `h2_direct` pin)
and the **GAP** (`r_am` identity test). C4 fixture repair is the minimum needed
so the identity assertion can hold.
**Lane:** R — `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Panel:** `~/local-scratch/h2-a21-estimand-claim-panel-2026-09-02.md` §1.3, §1.4, §1.5, §6
**Lenses:** Fisher / Noether / Falconer (perspectives; no spawned subagents)
**Not pushed.**

**No covered flip. No `validation_status()` row added. `public_covered_count`
stays 5.** Live `validation_status()` after the change: **21 rows / 4 covered /
10 partial / 7 planned** — unchanged. `R/validation-status.R` and
`docs/design/04-validation-canon.md` were not edited (G-AG-5 owner-gated; sibling
owns the canon file — C5 landed there as `529a5a2`). Claims register skipped
(A4 optional-skip while register-busy).

## What was wrong

1. **C6 / §1.4.** The same formula `animal(1 | id) + maternal_genetic(1 | dam)`
   reaches two routes whose `m2` uses different denominators:
   - `target = "two_effect"` → `maternal_proportion()` uses
     `σ²_a + σ²_m + σ²_e` (no covariance; experimental)
   - `target = "direct_maternal"` → `m2_maternal` uses
     `σ_P = σ²_ad + σ²_am + σ_dm + σ²_e` (covered)
   Neither fence named the other definition.
2. **C6 / §1.5.** `direct_heritability()` reads `result$heritability`;
   `heritability()` recomputes `h2_direct` from components. No test pinned
   agreement.
3. **GAP / §1.3.** `r_am = σ_dm / sqrt(σ²_ad · σ²_am)` is implemented in the
   engine and passed through by R, but **no identity test** existed. The mock
   set `r_am = -0.4` beside components that imply **−0.4714**, so an identity
   assertion on today's fixture would have failed.

## What changed

| File | Change |
|---|---|
| `docs/design/capability-status.md` | One sentence on the two-effect maternal fence and one on the direct–maternal Willham fence, each naming the other `m2` denominator. Status words and `public_covered_count` untouched. |
| `tests/testthat/test-direct-maternal.R` | Default `make_dm_fit()` derives `r_am` from components; plumbing tests still pass `r_am = -0.4` as a free knob. New identity + `h2_direct` pin + fence-prose guard. Live parity test (skip-guarded) also asserts the identity when both variances are positive. |

## Commands and results

```
devtools::test(filter = "direct-maternal", reporter = "check")
  FAIL 0 | WARN 0 | SKIP 1 | PASS 67
  skip: live Julia project not found (pre-existing; same skip as before)

pkgload::load_all(); validation_status()
  rows=21 covered=4 partial=10 planned=7
```

The live identity assertion is in the skip-guarded parity test; it did not run
in this environment. The mock identity and `h2_direct` pin did run and passed.

## Tests of the tests

Replacing `(no covariance)` in the two-effect fence with a dummy token turned
the prose guard **red** (`grepl("no covariance")` FALSE) and named the
two-effect fence. Restored immediately. The guard is not vacuous.

## Claim boundary

- No estimand, status word, or `public_covered_count` moved.
- No `validation_status()` row added (G-AG-5).
- No edit to `04-validation-canon.md` (C5 sibling).
- No edit to `06-public-claims-register.md` (A4 skipped).
- No Dropbox / v07 edit. No merge. No push.
- Julia-lane `r_am` identity remains owed (C4 said both lanes; this slice is
  R-only).
