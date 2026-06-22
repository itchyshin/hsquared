# After-task report — non-Gaussian per-record varying-trial Binomial activation (#44 gate 1)

Date: 2026-06-22

Branch: `claude/nongaussian-per-record-trials` (isolated worktree, branched from
`main` `d4ec85d`; **not committed, not pushed, not merged**)

Active lenses: Boole (formula), Hopper (bridge), Gauss/Curie (numerics/tests),
Fisher (inference honesty), Rose (claim-vs-evidence)

Spawned subagents: none

Current lane: R (`hsquared`), worked in an isolated git worktree so the
concurrently-active R-twin session's checkout (`codex/claude-cross-lane-handover`)
was untouched.

## 1. Goal

Activate the remaining narrow R-side gate of HSquared.jl #44: let the
`binomial(logit)` + `cbind(successes, failures)` non-Gaussian route accept
**per-record varying** trial totals (the engine already had
`BinomialVectorResponse`). Implemented + live-verified; status stays `partial`.

## 2. Implemented

- `R/model-spec.R::hs_build_binomial_counts_response`: removed the equal-totals
  guard; `n_trials` is now stored as the per-record integer vector `totals`
  (length n). Existing integer / non-negative / `total >= 1` checks retained.
- `R/julia-bridge.R::hs_nongaussian_family_symbol`: generalized the scalar
  `n_trials > 1L` test to `max(n_trials) > 1L` (vector-safe; all-ones → Bernoulli).
- `R/julia-bridge.R::hs_fit_julia_nongaussian_payload`: marshals the per-record
  integer vector (`n_trials = hsq_n_trials`, no longer `Int(...)`-scalarized) so
  the engine resolves it to `BinomialVectorResponse`; added a
  `length(n_trials) == length(y)` guard ahead of the engine `_check_counts`.
- `R/bridge-payload.R`: comment update (n_trials now a per-record vector).
- Living-doc honesty updates: `R/formula-status.R` (diagnostic row),
  `docs/design/capability-status.md`, `docs/design/validation-debt-register.md`,
  `docs/design/21-nongaussian-la-va-method.md` (new activation note) — all keep
  `partial` and name gate 2 (validation/comparator/calibration) as remaining.

## 3a. Decisions and Rejected Alternatives

- **Encoding = always per-record vector** (Shinichi's call): one bridge code path;
  the equal-totals case is a repeated-value vector. Rejected the
  scalar-when-constant fast path (more branching).
- **Same `cbind()` syntax, no new argument** (Shinichi's call): matches the
  `glm()`/`lme4` idiom; rejected a `trials=`/`weights=` argument.
- **All-ones `cbind` still reduces to Bernoulli** (`max(n_trials) > 1` rule):
  preserves the documented reduction + its live test; honest family label.
- **Engine untouched**: `BinomialVectorResponse` + `_fam_record` already exist
  (`HSquared.jl src/nongaussian.jl:59-97`). This is R-side activation only.
- **Did not edit `docs/design/19-on-main-bridge-gap.md` or `docs/dev-log/`
  ledgers**: those describe `main` / are append-only history actively owned by the
  R-twin session; editing them in the branch would falsely imply main already has
  the change. They are merge-time reconciliation items (see §10).

## 4. Files Touched

- `R/model-spec.R`
- `R/julia-bridge.R`
- `R/bridge-payload.R`
- `R/formula-status.R`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/design/21-nongaussian-la-va-method.md`
- `tests/testthat/test-binomial-counts.R`
- `docs/dev-log/after-task/2026-06-22-nongaussian-per-record-trials.md` (this file)

Diff vs `main`: 8 files, +135 / −53 (excluding this report).

## 5. Checks Run

Toolchain: `julia 1.10.0` (juliaup, wired via `PATH=$HOME/.juliaup/bin:$PATH`),
`HSQUARED_JULIA_PROJECT=/Users/z3437171/Dropbox/Github Local/HSquared.jl`
(instantiated; `using HSquared` loads OK). R `devtools`/`rcmdcheck`/`air` present;
`JuliaCall`/`MCMCglmm`/`sommer`/`pedigreemm`/`nadiv` installed.

- Baseline (pristine worktree, julia off): `binomial`+`nongaussian` →
  `PASS 76, SKIP 4`.
- RED (tests changed, source unchanged): `binomial` → `FAIL 3` for the expected
  reasons (scalar n_trials; equal-totals guard; vector in scalar `> 1L`).
- GREEN (source changed): `binomial` → `PASS 18, SKIP 3`.
- Full Julia-free suite: `PASS 1446, FAIL 0, WARN 0, SKIP 55`.
- LIVE `binomial-counts` (julia on): `PASS 32, FAIL 0, SKIP 0` (15.2s) — the new
  varying-trial leg matches a direct `fit_laplace_reml(...; family = :binomial,
  n_trials = hsq_n_trials)` to `tol = 1e-6`, `fit$result$n_trials` echoes the
  per-record vector, and all-ones reduces to the Bernoulli fit.
- LIVE `nongaussian` (julia on): `PASS 85, FAIL 0, SKIP 0` (12.1s) — no regression.
- `air format` (changed R files): clean.
- `rcmdcheck(args = c("--no-manual","--as-cran"))` (julia off): 0 errors,
  0 warnings, 2 NOTES (dev-version `0.1.0.9000`; `.git` hidden-file — a worktree
  artifact, absent from a real build tarball).

## 6. Tests of the Tests

- Watched RED before writing source (TDD): each failure was the missing feature,
  not a typo. The previously-passing "varying row totals errors clearly" test was
  inverted to assert success — proving the guard was the only blocker.
- Live parity asserts R == direct engine on an independently varying `n_trials`
  panel (not a constant), so a silent scalarization would fail it.
- Symbol-mapper test covers scalar 1/5, vector with a >1 total, and all-ones.

## 7a. Issue Ledger

- HSquared.jl #44 gate 1 (per-record varying-trial R activation): **implemented +
  live-verified on this branch**; NOT yet reflected in any issue (no GitHub post —
  needs Shinichi's OK). Gate 2 (binomial information-gradient recovery, external
  MCMCglmm agreement comparator, interval calibration) remains open.
- No capability promoted; non-Gaussian stays `partial` (`V6-LAPLACE`/`VA`).

## 8. Consistency Audit

- `grep -rn n_trials R/ tests/` sweep confirmed the change set is complete; the
  result-side normalizer + parity fixture were already vector-safe (unchanged).
- Stale-claim sweep fixed the living-capability surfaces; main-snapshot /
  append-only ledgers deliberately deferred to merge (§10).
- Coordination check before work: the R-twin's only new commit (`22659ae`) was
  `docs/dev-log/` housekeeping — no collision on `R/`, `tests/`, or `docs/design/`.

## 9. What Did Not Go Smoothly

- Codex was unavailable, so live execution was done by Claude (toolchain present),
  a deliberate, Shinichi-approved deviation from the usual Codex-runs-live split.
- `julia` was off the non-interactive `PATH` (juliaup); wired via `PATH` +
  `HSQUARED_JULIA_PROJECT` so the bridge's `Sys.which("julia")` resolves it.

## 10. Known Residuals

- **Committed + pushed; PR opened against `main`** (no merge yet), per Shinichi's
  finalize choice. CI (R-CMD-check / pkgdown) runs on the PR.
- **Merge-time ledger reconciliation** (not done here, to avoid touching
  R-twin-owned / on-main-snapshot files): `docs/design/19-on-main-bridge-gap.md`
  (V6 row), `docs/dev-log/issue-map.md`, a new `docs/dev-log/check-log.md` entry,
  a new `docs/dev-log/coordination-board.md` entry, and the HSquared.jl #44
  gate-1 checkbox + cross-lane note (all need Shinichi's OK for any GitHub post).
- **Gate 2 not started** (validation/comparator/calibration depth).
- Did not run the full live suite (55 legs) or a full live `rcmdcheck`; the change
  is isolated to the binomial non-Gaussian path, which was live-verified directly,
  and the full Julia-free suite is green.

## 11. Team Learning

When two routing answers conflict (Claude implements vs. a separate session owns
the repo), an isolated `git worktree` on a fresh branch reconciles both: real
implementation + live verification with zero disruption to the other session's
working tree. Branch from a stable base disjoint from the other session's edits so
the eventual merge is conflict-free.
