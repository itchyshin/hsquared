# Sparse REML Likelihood Validation Atom

Date: 2026-06-13

Active lenses: Curie, Gauss, Fisher, Hopper, Rose, Grace.

Spawned subagents: none.

## Scope

Add a small R-side validation atom that exercises the sibling `HSquared.jl`
dense and sparse supplied-variance Gaussian likelihood evaluators through the
existing JuliaCall bridge setup.

This is not a sparse optimizer, AI-REML implementation, fitted Mrode validation,
or general animal-model fitting claim.

## Implementation

Added:

- internal `hs_reml_likelihood_validation_fixture()`;
- pure R payload and closed-form target checks;
- optional live Julia test comparing:
  - `HSquared.gaussian_loglik(...; method = :REML)`;
  - `HSquared.sparse_reml_loglik()`;
  - `HSquared.gaussian_loglik(...; method = :ML)`;
- `validation_status()` row for `sparse REML likelihood identity`;
- README, NEWS, model-status article, capability status, validation debt, and
  public claims register wording.

The fixture uses three all-founder animals, `sigma_a2 = 1`, `sigma_e2 = 1`,
intercept-only fixed effects, identity `Z`, and identity `Ainv`. It pins:

- beta = 2;
- ML log-likelihood hand check;
- REML log-likelihood hand check;
- dense REML equals sparse REML at supplied variance components.

## Validation

Local checks:

- `Rscript -e "devtools::test(filter = 'validation-fixtures|phase0-api')"`
  - initial run: live Julia bridge executed, but two R-only expectations failed
    due to incidental matrix attributes and dimension comparison.
  - after value-comparison fix: `93 pass`, `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test()"`
  - `428 pass`, `0 fail`, `0 warnings`, `0 skips`;
  - live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`
  - articles rebuilt;
  - `No problems found.`
- `Rscript -e "devtools::check()"`
  - `0 errors`, `0 warnings`, `0 notes`.
- `git diff --check`
  - clean.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- tiny supplied-variance likelihood identity;
- dense REML and sparse REML agreement;
- ML and REML hand-check targets.

Blocked wording:

- sparse REML optimizer exists;
- AI-REML exists;
- fitted Mrode output validation is covered;
- general animal-model fitting is implemented;
- production sparse fitting is validated;
- ASReml parity, GPU execution, or speedup exists.

## Handoff

Issue #7 should be updated after push. The Julia twin should be told that the R
lane now mirrors its sparse REML identity status with a three-founder bridge
fixture, and that no new Julia engine API is requested by this slice.
