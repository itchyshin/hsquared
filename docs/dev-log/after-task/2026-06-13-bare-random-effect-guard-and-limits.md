# Reject bare `(... | group)` random effects + document model limits

Date: 2026-06-13 (autonomous overnight; user away till ~05:00)

Active lenses: Ada, Boole, Pat, Rose. Spawned subagents: none (small,
TDD-tested parser-hardening fix + a docs section; proportionate self-review).
Current lane: R (hsquared). No twin edits.

## Goal and context

Directly answers the user's first question this session ("can we put an
arbitrary number of random slopes and random effects … or some limits — it
will be good to know the limits") and fixes a silent-correctness bug found
while checking those limits.

## The bug

`y ~ animal(1 | id, pedigree = ped) + (1 | x)` was **accepted**: the bare
lme4-style `(1 | x)` term was not a recognized named effect, so it fell through
into the fixed-effect design, where `model.frame` evaluated `1 | x` as the
logical expression `1 | x` (always `TRUE`) and produced a garbage all-`TRUE`
fixed column `1 | xTRUE`. A user writing an ordinary random effect got silent
nonsense instead of an error — a violation of the User Interface Mantra ("error
messages should name the unsupported syntax and point to the closest
implemented or planned path").

## What changed

- `R/model-spec.R` — added `hs_is_bar_expr()` (a top-level `|` call, unwrapping
  parentheses; named wrappers like `animal(1 | id)` are function calls, not bar
  exprs, so they are unaffected) and `hs_stop_unsupported_random_effect()`. In
  `hs_build_model_spec`, any leftover term (not the primary, the second effect,
  or a planned marker) that is a bar expression is now rejected with a pointer
  to the named effects (`animal()`/`permanent()`/`common_env()`/
  `maternal_genetic()`) before it can be absorbed into the fixed design.
- `vignettes/articles/model-status.Rmd` — a new **"Current limits"** section:
  exactly one primary effect; at most one additional random effect (only with
  an `animal()` primary); random intercepts only (slopes and bare `(... |
  group)` rejected); univariate; Gaussian identity; REML-only on the fit path;
  fixed effects unrestricted. Each limit verified empirically against the parser.

## Tests

- `tests/testthat/test-formula-animal.R` — new test: `(1 | x)` and `(x | id)`
  bare terms both error with "Unsupported random-effect term". Watched fail
  first (the `(1 | x)` was silently accepted; `(x | id)` died with an unhelpful
  internal `eval` error), then pass. Named effects (`animal() + permanent()`)
  confirmed still parse (the guard only catches bare bars).

## Checks

- `air format`; `devtools::document()`; `pkg::`-grep clean (no new deps);
  `pkgdown::check_pkgdown()` clean; full `testthat` with juliaup + `NOT_CRAN` +
  sommer + enhancer — 0/0/0; `rcmdcheck(--as-cran)` 0/0/1 (benign).

## Boundary

A parser-honesty/UX fix and a documentation section; no fitting-capability
change. The named effects, v0.1 contract, and all opt-in models are unchanged.
