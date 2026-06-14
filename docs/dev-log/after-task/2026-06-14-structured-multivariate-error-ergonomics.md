# Structured multivariate grammar error ergonomics

Date: 2026-06-14

## Task goal

Keep the multivariate user interface easy after the new `cbind()` bridge landed:
when users try future long-format or structured covariance grammar inside
`animal()`, point them to the current working path instead of only saying "not
implemented."

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Boole, Pat, Rose.

Spawned agents: none.

Current lane: R.

## Files created or changed

- `R/model-spec.R`: added dedicated error helpers for non-intercept
  `animal()` syntax and `cov = ...`.
- `tests/testthat/test-formula-animal.R`: updated parser tests to require the
  `cbind()` guidance and future `animal(trait | id, cov = ...)` fence.
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`: evidence
  and lane update.

## Checks run and exact outcomes

- `devtools::test(filter = 'formula-animal')`: 0 failures / 0 warnings / 0
  skips / 41 passes.
- `devtools::test()`: 0 failures / 0 warnings / 27 live-Julia skips / 561
  passes.
- `git diff --check`: passed.

## Public claim audit

No capability changed. The slice improves user-facing errors while preserving
the claim boundary:

- Current multivariate support: opt-in `cbind()` response + `target =
  "multivariate"`.
- Planned structured grammar: `animal(trait | id, cov = us())`, `cov = fa(K =
  2)`, and random slopes.

Rose verdict: clean.

## Tests of the tests

The updated tests would fail if the parser returned the old generic
random-intercept-only message, or if `cov = ...` stopped being fenced as planned.

## Coordination notes

This is the R-lane counterpart to the twin's next structured-covariance work:
Julia can explore structured covariance recovery, while R keeps users pointed to
the one multivariate grammar that is actually live.

## What did not go smoothly

No blocker.

## Known limitations

This does not implement long-format multivariate grammar or any structured
covariance model.

## Next actions

Let the Julia lane work its structured covariance recovery harness. The next
R-safe slice is a short multivariate fitting vignette or shared deterministic
fixture consumption after the twin writes the fixture.
