# After-task — R single-step planned-only → partial / experimental

**Date:** 2026-09-03
**Lane:** R (`hsquared`) — worktree `~/local-scratch/hsquared-ss-r-catchup`,
branch `cursor/08-ss-r-catchup-20260903` from `origin/main` `96318bf`.
**Active lenses:** Ada, Shannon, Rose, Boole, Henderson (perspectives).
**Spawned subagents:** none
**Current lane:** R docs/status honesty for single-step

**Fence held:** `public_covered_count` stays **7**. No covered flip. No
1.0 / CRAN. Engine-covered ≠ R-public. Darwin UNSIGNED. No ordinary-route
promotion.

---

## Task goal

Clear the false **planned-only** reading of single-step while Julia
[#295](https://github.com/itchyshin/HSquared.jl/pull/295) has AGHmatrix
H-matrix construction **AGREE** and an n=240 recovery **GATE PASS**.
Advance R honesty to **partial / experimental**. Do not claim a covered
flip and do not auto-route `single_step()` on the default path.

## Files changed

- `docs/design/capability-status.md` — construction row cites #295;
  GREML/SS notes say SS stays partial / experimental.
- `docs/design/06-public-claims-register.md` — new experimental
  single-step H⁻¹ construction claim row.
- `docs/design/validation-debt-register.md` — new `V2-SSHINV` twin debt
  row (partial; Darwin UNSIGNED).
- `R/formula-status.R` — construction / bundle behavior cites #295 and
  count 7; still opt-in.
- `tests/testthat/test-phase0-api.R` — pins #295 / count 7 / no
  default-route wording.
- `NEWS.md` — honesty bullet; count stays 7.

## Checks run and exact outcomes

- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api")'` — **FAIL 0 / WARN 0 / SKIP 0 / PASS 153**
- `devtools::document()` not required (no roxygen change).

## Public claim audit

Rose **CLEAN-WITH-LIMITATIONS** (status honesty only; not a flip audit).

- Single-step construction is **partial / experimental**, not covered.
- R still requires explicit `target = "single_step_construct"` (or
  supplied-`Hinv` `target = "single_step"`).
- No ordinary-route / default-path promotion.
- Count stays 7.
- Darwin remains UNSIGNED. Do not echo SIGN.
- `DESCRIPTION` / reader vignettes / `R/hsquared-package.R` left to
  #158 / #162 / #163 so this PR does not fight those files.

## Tests of the tests

The new `formula_status()` assertions fail if the construction row drops
the #295 cite, the count-7 fence, or the no-default-route sentence.

## Coordination notes

- Worked from `origin/main`, not #158 / #162 / #163.
- Did **not** edit `docs/dev-log/coordination-board.md` (many live
  lanes). Suggested board row:

  | 2026-09-03 | R 0.8 SS honesty catch-up | Ada/Shannon/Rose | `cursor/08-ss-r-catchup-20260903` | capability / claims / debt / `formula_status()` | **DRAFT PR.** SS no longer planned-only; cites Julia #295; stays partial. Count **7**. | Darwin UNSIGNED; no flip | Merge when CI green; do not flip |

## What did not go smoothly

Lane census was crowded. Shared files (`NEWS.md`, `formula-status.R`,
capability/claims/debt) also sit on #163 (FA). Hunks are SS-only so a
later merge should apply beside the FA rows.

## Known limitations

- No new live R↔engine numeric parity test in this slice.
- BLUPF90/preGSf90 and APY remain planned.
- Metafounder `H^Gamma` is unchanged.

## Next actions

1. Draft PR; merge when CI green.
2. Darwin SIGN remains owner ink. Then R↔engine element-wise parity +
   spawned Rose. No auto-flip.
