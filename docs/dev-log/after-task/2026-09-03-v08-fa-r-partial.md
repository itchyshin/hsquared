# After-task — R FA planned → partial / experimental stubs

**Date:** 2026-09-03
**Lane:** R (`hsquared`) — worktree `~/local-scratch/hsquared-fa-partial`,
branch `cursor/08-fa-partial-20260903` from `origin/main` `96318bf`.
**Active lenses:** Ada, Shannon, Rose, Boole, Kirkpatrick (perspectives).
**Spawned subagents:** none
**Current lane:** R docs/status/formula stubs

**Fence held:** `public_covered_count` stays **7**. No covered flip. No
1.0 / CRAN. Engine-covered ≠ R-public.

---

## Task goal

Clear the Rose blocker **R twin FA still planned** while Julia draft
#292 has S4 Totoro `d4-k1` **8/10 PASS**. Advance R honesty to
**partial / experimental** surfaces. Do not claim R can fit FA.

## Files changed

- `docs/design/capability-status.md` — FA rows `planned` → `partial`
  (engine experimental; R reserved).
- `docs/design/06-public-claims-register.md` — same split.
- `docs/design/validation-debt-register.md` — FA debt row now cites #292
  S4; owed R bridge / comparator.
- `docs/design/02-formula-grammar.md` — `cov = fa()` reserved stub note.
- `R/formula-status.R` — `cov = fa()` syntax **reserved**; behavior
  cites #292 S4 and count 7.
- `R/model-spec.R` — `cov` error: reserved / not parsed; FA names the
  engine path, R does not fit it.
- `R/julia-bridge.R` — `genetic_structure = "factor_analytic"` still
  errors; wording is engine-experimental, R not activated.
- `R/hs_control.R`, `R/hsquared-package.R` + regenerated Rd.
- tests: `test-phase0-api.R`, `test-formula-animal.R`,
  `test-multivariate.R`, `test-package-help-honesty.R`.
- `NEWS.md` — honesty bullet; count stays 7.

## Checks run and exact outcomes

- `devtools::document()` — wrote `hs_control.Rd`, `hsquared-package.Rd`.
- Focused tests: `test-phase0-api.R` 155/0;
  `test-formula-animal.R` 96/0 (2 live-Julia skips);
  `test-multivariate.R` 73/0 (4 skips);
  `test-package-help-honesty.R` 11/0;
  `test-hs-control-targets.R` 26/0.

## Public claim audit

Rose **CLEAN-WITH-LIMITATIONS**.

- FA is **partial / experimental**, not covered.
- R still does not parse or fit `cov = fa()`.
- Bridge still rejects `genetic_structure = "factor_analytic"`.
- Count stays 7.
- `DESCRIPTION` still says "factor-analytic models remain planned"
  because lane `cursor:g5-stale-copy-20260903` holds that file (#162).
  Follow-up after that lease.

## Coordination notes

- Worked from `origin/main`, not #160. #160 is pointer-only and still
  says "FA stays planned".
- Did **not** edit `docs/dev-log/coordination-board.md` — #160 holds
  that lease. Suggested board row is in the check-log sibling.

## Next actions

1. Draft PR; merge when CI green.
2. After #162: align DESCRIPTION with this wording.
3. R bridge activation and any covered flip remain G10 / Rose CLEAN
   separate work. No auto-flip.
