# 2026-09-02 — A28 (part 1): capability id alias, not rename

Arc **A28** (Boole freeze-closure audit), the residual left open by A24. Lane: R.
Worktree `~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`. **Not pushed.**

## Problem

MV-4 made a `cbind()` Gaussian response with an `animal()` term auto-route to the
multivariate REML fitter on the default path. The `validation_status()` capability
id `"experimental multivariate REML estimator (opt-in)"` still said "(opt-in)".

## Citation footprint — measured before deciding

`rg` over both lane worktrees for the exact string. Seven sites in the R lane,
**zero in `HSquared.jl`** (the Julia lane keys its rows `V4-MV-REML` etc., so no
twin coupling).

| Path:line | Class | Safe to rewrite? |
|---|---|---|
| `R/validation-status.R:53` | the id itself | it *is* the id |
| `tools/write-capability-ledger-summary.R:146` | live join key | yes, edits together |
| `tests/testthat/test-phase0-api.R:243,310` | live tests | yes, edits together |
| `docs/dev-log/comparator-runs/2026-06-21-multivariate-tool-availability.md:17` | **dated evidence** | **no** |
| `docs/dev-log/comparator-runs/2026-09-01-blupf90-tool-unavailability.md:19` | **dated evidence** | **no** |
| `docs/dev-log/check-log.d/2026-09-01-h2-a24-mv4-claim-surface-honesty.md:94` | **dated check-log** | **no** |

One near-miss that is **not** this string and did not change:
`docs/design/validation-debt-register.md` row `experimental multivariate REML
estimator bridge` (ends "bridge", no "(opt-in)"), cited by
`after-task/2026-06-22-gparity-v4-honesty.md:35`.

## Decision — ALIAS

Three dated records cite the id verbatim, so it stays. Recorded in
`docs/dev-log/decisions.md`, "2026-09-02: Capability Ids Are Historical; Labels
Carry Current Wording", with the three rejected alternatives.

`validation_status()` gains a `capability_label` column; `capability` remains the
stable lookup id. Reader surfaces print the label. The override table
`hs_validation_status_label_overrides()` has exactly one entry today.

**Precedent, not invention:** `tools/write-capability-ledger-summary.R` already
splits id (`key`) from display (`title`). Regenerating the include after this
change produced **no diff**, confirming the reader card never showed the raw id.

## Second defect found and fixed

The multivariate `claim_boundary` contradicted itself in one field: A24 added
"auto-routes to this fitter on the DEFAULT path (MV-4)" while leaving "it is not
the public default" later in the same string. Replaced with "default routing did
not promote it". Test pin updated.

## Also corrected

- `docs/design/validation-debt-register.md` — multivariate row notes led with
  "Experimental opt-in path only"; now states the default route explicitly and
  that routing is reachability, not promotion.
- `vignettes/articles/validation-evidence.Rmd` — the covered-rows table prints
  `capability_label`. Cosmetically identical today (no covered row is aliased);
  changed so it cannot drift.

## Commands and outcomes

| Command | Result |
|---|---|
| `devtools::document()` | OK (`man/validation_status.Rd` regenerated) |
| `Rscript tools/write-capability-ledger-summary.R` | wrote 156 lines, **no diff** |
| `devtools::test()` | **FAIL 0 / WARN 0 / SKIP 70 / PASS 2348** (was 2336; +12 from two new blocks) |
| `devtools::check(document = FALSE, args = "--no-manual")` | **Status: OK — 0 errors, 0 warnings, 0 notes** (3m 7s) |
| `air format R/validation-status.R tests/testthat/test-phase0-api.R` | no changes |

New tests in `test-phase0-api.R`:

1. `capability_label` present, character, complete, non-empty; every override key
   names a live capability id (so a rename cannot silently strand an alias);
   unaliased rows have label identical to id.
2. The historical `(opt-in)` id still resolves to exactly one `partial` row; its
   label drops "opt-in" and gains "default route"; the printed table shows the
   label.

## Claim boundary

Vocabulary and display only. **No status changed. No `partial → covered` flip.
`public_covered_count` stays 5.** No push, no CI verification, no G10, no version
bump, no compute run.

## A28 residual — still open

This closed only the key-honesty item. The rest of the A28 charter is untouched:
recording doc-38 §H.3's gate decision as discharged by MV-1, and **verifying that
the `k >= 3` experimental fence and the `diagonal`-stays-experimental fence are
enforced on every surface, not merely documented.**
