# 2026-09-02 — Pat P1: warn on non-converged heritability / print

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied user tester). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

The advertised four-animal *fit* returns `converged = FALSE` and
`heritability()` ≈ 0 with no warning. Students treat that as h² = 0.
`heritability()` and `print.hsquared_fit` must warn; the golden-path
docs must not present n = 4 as a trustworthy numeric demo.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format R/fit-object.R R/extractors.R tests/testthat/test-fit-object.R` | clean |
| `devtools::document()` | regenerated `man/heritability.Rd` only |
| `devtools::test(filter = "^fit-object$")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 120** |
| `devtools::test(filter = "nongaussian$\\|heritability-interval$\\|summary-uncertainty$\\|common-env$")` | **FAIL 0 / WARN 0 / SKIP 3** (live Julia) **/ PASS 132** |

`devtools::check()` not run: extractor warning + docs fence only.

## Claim boundary

- No capability-status or `validation_status()` edit.
- No larger demo dataset invented.
- Validate chunks stay `eval = TRUE` (Getting started `golden-validate`).
- Engine-fit chunks stay `eval = FALSE` and are marked syntax-only /
  may-not-converge.
- Julia README not edited: it does not copy the four-animal fit lie
  (its `heritability(fit)` is a low-level `fit_variance_components`
  extractor, not the R hello-world). Sibling d32e was not present;
  after-task shard skipped (sibling lease on `docs/dev-log/after-task/`).

## Test of the tests

Mock `hsquared_fit` with `converged = FALSE`, animal VC at 1e-16, and
h² = 9.48e-17 (the live-walk number). Asserts the warning text, that
`heritability()` still returns the engine number, that `print()` says
`not reportable` and does not peek `9.48`, and that a converged
interior fit stays silent.
