# After-task report - Non-Gaussian per-record varying-trial R activation (R side)

Date: 2026-06-22

Branch: `codex/nongaussian-per-record-trials-r` (stacked on PR D / `codex/board-hygiene-coordination`)

Active lenses: Boole, Hopper, Fisher, Curie, Darwin, Rose

Spawned subagents: Rose (rose-systems-auditor) for the audit

Current lane: R (code + tests + status)

## 1. Goal

Slice 18 of the 20-slice plan, done in **R only** (the user reassigned execution
after Codex went offline; the live Julia round-trip and the Julia-engine slices
13/15/16/17 and binary-blocked slice 14 remain out of scope). Implement the
R-side of per-record varying-trial Binomial activation per the plan
(`docs/design/31-...`): parse and carry varying `cbind(successes, failures)` row
totals as a per-record vector, classify the family vector-safely, and verify with
pure-R tests. Do **not** claim end-to-end activation — the live varying-trial
engine round-trip stays the gate.

## 2. Implemented

R code:
- `R/model-spec.R` (`hs_build_binomial_counts_response`): replaced the
  equal-totals rejection guard with a per-record integer vector build
  (`n_trials <- as.integer(totals)`); kept all prior validation (numeric,
  finite/no-NA, non-negative integers, `>= 1` trial). A constant vector is the
  common-trial special case; an all-ones vector is the Bernoulli reduction.
- `R/julia-bridge.R` (`hs_nongaussian_family_symbol`): made the rule
  **vector-safe** — `any(n_trials > 1L)` (was scalar `n_trials > 1L`), so a vector
  whose first element is 1 (e.g. `c(1, 4, 5)`) is still Binomial, not silently
  Bernoulli (the landmine doc 31 flagged at `julia-bridge.R:443`).
- `R/julia-bridge.R` (marshalling): when every record shares one trial count, pass
  the **scalar** `Int(hsq_n_trials)` — the existing **live-verified** common-trial
  path, unchanged; only a genuinely varying vector is passed as
  `Vector{Int}(hsq_n_trials)`.
- `R/bridge-payload.R`: comment now says the carried `n_trials` is a per-record
  vector (the carry itself was already shape-agnostic).

Tests (`tests/testthat/test-binomial-counts.R`):
- Inverted the former "varying row totals errors" test → now asserts an unbalanced
  `cbind` builds `n_trials == c(3L,3L,4L,3L)` (order-preserving, not collapsed).
- Updated the balanced test to expect the constant vector `rep(3L, 4)`.
- Added vector-safe family-symbol cases (`c(1,4,5)` → binomial; `c(1,1,1)` →
  bernoulli).
- Added a skip-guarded **live** varying-trial round-trip test (skips without
  Julia) for when the engine is available.

Status docs (honest, no over-claim): `capability-status.md` (fit-entry row),
`validation-debt-register.md` (non-Gaussian bridge row), and
`docs/design/21-nongaussian-la-va-method.md` now say the R bridge **parses and
carries** per-record varying totals (pure-R tested), the equal-totals case stays
the **live-verified** common-trial path, and the **live varying-trial engine
round-trip is the remaining verification gate**. Non-Gaussian stays `partial`,
latent-scale, no heritability.

## 3a. Decisions and Rejected Alternatives

- **Scalar marshalling preserved for equal totals.** Rather than always sending a
  vector (which would replace the previously live-verified balanced path with an
  unverified one), the marshalling sends a scalar when all totals are equal and a
  vector only when they vary. This keeps the verified common-trial behaviour
  byte-identical and isolates the unverified change to the genuinely-new case.
- **No end-to-end activation claim.** The R lane cannot run JuliaCall here
  (`julia` not on PATH → `hs_julia_bridge_available()` is FALSE → live tests
  skip), so the varying-trial fit is not live-verified. Status wording claims only
  the R-side parsing/payload/classification (what pure-R tests prove); the live
  round-trip is the gate. This is the honest version of what the closed PR #101
  over-claimed.
- **Did not reuse PR #101's code.** Implemented fresh from the plan (doc 31) and
  verified with my own test run, rather than trusting the rogue branch.

## 4. Files Touched

- `R/model-spec.R`, `R/julia-bridge.R`, `R/bridge-payload.R`
- `tests/testthat/test-binomial-counts.R`
- `docs/design/capability-status.md`, `docs/design/validation-debt-register.md`,
  `docs/design/21-nongaussian-la-va-method.md`
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-22-nongaussian-per-record-trials-r.md` (this)

No NAMESPACE/man change (the changed functions are internal; `document()` clean).

## 5. Checks Run

- `air format` on the changed R/test files — applied.
- `devtools::test(filter = "binomial-counts")` → **17 pass / 0 fail / 3 skip**
  (the 3 live tests skip — Julia not on PATH).
- `devtools::test()` (full suite) → **1419 pass / 0 fail / 0 warn / 60 skip** —
  no regression from the scalar→vector change.
- `devtools::document()` → no man/NAMESPACE drift.
- `pkgdown::check_pkgdown()` → "No problems found".
- `_R_CHECK_FORCE_SUGGESTS_=false rcmdcheck(--no-manual --no-build-vignettes,
  error_on = "warning")` → **status 0** (no errors/warnings).

## 6. Tests of the Tests

The inverted test is the key guard: it would fail if the parser still rejected
varying totals (the old behaviour) or collapsed them (`unique`). The vector-safe
family-symbol test (`c(1,4,5)` → binomial) directly exercises the silent-Bernoulli
landmine — it fails against the old scalar `n_trials > 1L`. The balanced test
pins the constant-vector shape so a later refactor can't silently re-collapse it.
The full-suite run confirms no other test depended on the old scalar shape.

## 7a. Issue Ledger

Advances twin `HSquared.jl#44` (non-Gaussian per-record trials). No issue state
changed. No promotion — non-Gaussian stays `partial`.

## 8. Consistency Audit

- Swept the suite for scalar-`n_trials` assumptions: the only dependents were the
  two updated tests; the full suite (1419) is green.
- Confirmed the marshalling change does not alter the balanced/common-trial path
  (scalar `Int` preserved) — the existing live balanced + Bernoulli-reduction
  tests are unchanged and still skip-guarded.
- Confirmed status docs claim only pure-R-verified behaviour; "live varying-trial
  round-trip" is consistently named as the open gate across all three surfaces.

## 9. What Did Not Go Smoothly

The only non-R dependency — the live engine round-trip — cannot run in this lane
(`julia` not on the R session PATH). Handled by keeping the claim to the pure-R
surface and leaving the live test skip-guarded.

## 10. Known Residuals

- The varying-trial **marshalling** (`Vector{Int}` keyword) and the end-to-end
  fit are **not live-verified** (no Julia here). The skip-guarded live test is the
  verification; running it (Codex / a Julia host) is the gate before any
  varying-trial fit is claimed. Until then non-Gaussian stays `partial`.
- Slices 13/14/15/16/17 remain out of scope (engine code / comparator binaries)
  per the Codex hand-off.

## 11. Team Learning

When a feature's only unverifiable piece is the engine boundary, implement and
fully test the R-side, and design the boundary so the previously-verified path is
preserved byte-for-byte (scalar for equal totals) — then the unverified surface is
just the genuinely-new case, and the honest claim is exactly what the pure-R tests
prove. Don't let status wording outrun the test that backs it (cf. closed PR #101).
