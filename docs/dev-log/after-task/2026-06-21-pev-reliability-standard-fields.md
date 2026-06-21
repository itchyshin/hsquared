# PEV/Reliability Standard-Field Status Reconciliation

Date: 2026-06-21

Active lenses: Ada, Shannon, Hopper, Henderson, Fisher, Rose, Grace.
Spawned subagents: none.
Current lane: R status/bridge.

## Goal

Reconcile the R-lane docs and status ledgers after the PEV/reliability bridge
behavior moved past the older "optional enrichment when available" wording.
This slice records status only; it does not change R behavior.

## Files Changed

- `NEWS.md`
- `docs/design/01-v0.1-contract.md`
- `docs/design/03-engine-contract.md`
- `docs/design/04-validation-canon.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/19-on-main-bridge-gap.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`

## Checks

- `air format .` - passed.
- `Rscript --vanilla -e 'devtools::test(filter = "julia-bridge|pev-reliability-anchor|phase0-api")'` -
  135 passed, 0 failed, 0 warnings, 8 skipped.
- `Rscript --vanilla -e 'devtools::test()'` - 1248 passed, 0 failed, 0
  warnings, 55 skipped.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
- `git diff --check` - clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
  Status OK, 0 errors, 0 warnings, 0 notes.

The skipped tests were optional-package legs and live Julia bridge legs under the
plain Rscript environment. This docs/status slice relies on the previously
recorded live evidence for the bridge behavior and does not regenerate new live
engine evidence.

## Public Claim Audit

Allowed wording:

- current univariate/default, sparse, and explicit AI-REML result-payload routes
  consume standard `prediction_error_variance` and `reliability` fields when
  present;
- current engines emit those fields via `:selinv`;
- direct dense extractor calls are only a backward-compatible fallback for older
  local engines whose payloads do not yet carry those fields;
- supplied-variance Henderson MME attaches dense validation-path PEV/reliability
  unconditionally.

Blocked wording:

- production sparse PEV/reliability is implemented;
- multivariate per-trait PEV/reliability is complete;
- comparator-validated reliability is available;
- #21/#43 are fully closed or covered.

## Tests Of The Tests

The focused test set included the bridge normalizer tests, the independent
PEV/reliability anchor, and `phase0-api` status-table checks. The full test run
confirmed that the status-only edits did not disturb package behavior.

## Coordination Notes

This is the R counterpart to the already-landed univariate/Henderson bridge
evidence. It keeps #21/#43 partial and names the remaining blockers explicitly:
multivariate per-trait PEV/reliability, production sparse reliability strategy,
and independent comparator validation.

## What Did Not Go Smoothly

The plain Rscript test environment does not activate the local Julia bridge, so
live bridge checks skipped. That is acceptable for this docs-only reconciliation,
but a future behavior-changing PEV/reliability slice should rerun the live bridge
environment explicitly.

## Known Limitations

- No code behavior changed.
- No new live Julia evidence was generated.
- No multivariate per-trait PEV/reliability payload is claimed.
- No production sparse reliability or external comparator evidence is claimed.

## Next Actions

1. Keep #21/#43 open until multivariate per-trait PEV/reliability and production
   sparse/comparator validation are available.
2. If the next R bridge slice changes behavior, run the live bridge environment
   explicitly rather than relying only on skip-guarded tests.
3. Continue clean-branch bridge work only after PR #39 and this status PR are
   reviewed or merged.
