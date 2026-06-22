# After-task report - Activation plans (PR C)

Date: 2026-06-22

Branch: `codex/activation-plans` (stacked on PR B / `codex/comparator-validation-runbooks`)

Active lenses: Boole, Hopper, Kirkpatrick, Falconer, Fisher, Curie, Rose

Spawned subagents: boole-formula-reviewer (non-Gaussian plan),
kirkpatrick-gmatrix-specialist (RR roadmap). Rose used as a documented
review-lens (not spawned) for this plans-only batch.

Current lane: R / coordinator (design plans only)

## 1. Goal

Batch 3 of the 20-slice goal — slices 3, 8, 20. Author the R-activation plans:
the non-Gaussian per-record varying-trial activation plan (slice 3), and the
random-regression R roadmap (slices 8 + 20, merged because an opt-in `rr()`
surface already ships — the remaining R-facing work is the *next increments*).
Plans only; no activation, no promotion.

## 2. Implemented

- **Slice 3** `docs/design/31-nongaussian-per-record-trials-activation-plan.md`
  — concrete activation design for unbalanced `cbind(successes, failures)`:
  the equal-totals guard at `R/model-spec.R:437-446` becomes a per-record
  `n_trials` vector build; payload carry is already shape-agnostic
  (`R/bridge-payload.R:98`); the family-symbol mapper must become vector-safe
  (`R/julia-bridge.R:443` `n_trials > 1L` would silently mis-classify a vector
  as Bernoulli — documented as a gated requirement); marshalling
  (`R/julia-bridge.R:543-544`) scalar→vector; 7 pure-R tests + 1 skip-guarded
  live round-trip (Codex). All file:line refs verified by grep.
- **Slices 8+20** `docs/design/32-random-regression-r-roadmap.md`
  — anchors on the existing shipping `rr()` surface, then plans 5 gated
  increments in correctness order: (1) permanent-environment term (so
  `rr_heritability()` stops overstating `h²(t)`), (2) heterogeneous residual,
  (3) curve-valued EBV PEV/reliability, (4) multivariate RR / second random
  effect, (5) grammar promotion + spline bases. Each with lane ownership
  (engine=Codex vs R-glue=Claude) and gate. Verified `permanent()` is an inert
  planned marker in the twin, so the PE increment is genuinely new.

## 3a. Decisions and Rejected Alternatives

- **Merged slices 8 and 20 into one RR roadmap.** rr() already ships as an opt-in
  experimental target (capability row 33), so "plan the R rr() spec" (slice 8) and
  "RR later: PE/curve-PEV/heterogeneous residual" (slice 20) are the same
  next-increments roadmap; one coherent doc beats two overlapping ones.
- **Rose as review-lens, not a spawned subagent.** These are plans with no
  evidence/comparator claims; the only load-bearing assertions are doc 31's
  file:line references, which I verified directly by grep. PRs A/B (contract +
  comparator claims) got independent Rose spawns; this lower-risk plans batch gets
  a documented lens. (PR D will get a spawn — it edits the board.)
- **Did not write any R code.** Both docs are plans; activation is gated on live
  round-trips (Codex). Drafting the R changes now without live verification would
  risk the silent-Bernoulli landmine doc 31 itself flags.

## 4. Files Touched

- `docs/design/31-nongaussian-per-record-trials-activation-plan.md` (new)
- `docs/design/32-random-regression-r-roadmap.md` (new)
- `docs/dev-log/check-log.md` (entry)
- `docs/dev-log/coordination-board.md` (row)
- `docs/dev-log/after-task/2026-06-22-activation-plans.md` (this file)

No `R/`, `tests/`, `man/`, NAMESPACE, DESCRIPTION, capability-status, or
validation-debt change.

## 5. Checks Run

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` (result in check-log).
- after-task validator on this report (result in check-log).
- `git diff --check`.
- grep verification of doc 31's file:line refs (`model-spec.R:437`,
  `julia-bridge.R:443`, `bridge-payload.R:98`) — all confirmed accurate.

## 6. Tests of the Tests

No behavioral tests (plans only). The integrity check is that doc 31's cited
guard/landmine locations are real (grep-verified) and that both docs keep the
relevant rows `partial` with explicit "not activated"/"promotes nothing"
boundaries — verified on read.

## 7a. Issue Ledger

Advances the non-Gaussian gap (twin `HSquared.jl#44`) and the RR roadmap (twin
`HSquared.jl#54`). No issue state changed, no promotion.

## 8. Consistency Audit (Rose review-lens)

- **Claim boundary (PASS):** both docs state PLAN ONLY / promotes nothing; the
  non-Gaussian doc keeps the equal-totals guard "stands today" and the
  fixture≠activation distinction in three places; the RR doc keeps the `h²(t)`
  overstatement caveat and lists PE/residual/curve-PEV as "do not work yet".
- **Factual refs (PASS):** doc 31's `model-spec.R:437-446`, `julia-bridge.R:443`,
  `bridge-payload.R:98` all grep-verified; the silent-Bernoulli landmine is real
  (`if (!is.null(n_trials) && n_trials > 1L)` on a vector uses element 1 only).
- **Twin consistency (PASS):** RR doc verified `permanent()` is an inert planned
  marker (no RR+PE engine path today); both docs route engine work to Codex and
  do not request twin edits from this repo.
- **No promotion / scope (PASS):** `git status` shows only the 5 docs/dev-log
  files; no R/code/capability/validation change.

## 9. What Did Not Go Smoothly

A PR-number nuance surfaced: per-record engine support is twin PR #118 (engine
capability) vs PR #152 (the fixture serialization). Doc 31 references the engine
*capability* (`BinomialResponse` per-record `n_trials`) and the fixture
provenance precisely rather than over-pinning a single PR number — accurate and
avoids a wrong citation.

## 10. Known Residuals

- Both are plans; nothing activated. Non-Gaussian activation and every RR
  increment are gated on engine support + live round-trips (Codex) and, for RR
  recovery/comparator claims, evidence that does not exist.
- The silent-Bernoulli family-symbol landmine (`R/julia-bridge.R:443`) is a real
  latent correctness issue; it is documented as a gated activation requirement,
  not fixed here (fixing needs the activation slice + live tests → Codex).

## 11. Team Learning

Before "planning" a feature, check whether it already partially ships: rr() was
already an opt-in experimental surface, so the useful slice was the *next
increments* roadmap, not a from-scratch spec. And when a plan cites code
locations, grep-verify them — a plan that misdirects the implementer to the wrong
line is worse than a vague one.
