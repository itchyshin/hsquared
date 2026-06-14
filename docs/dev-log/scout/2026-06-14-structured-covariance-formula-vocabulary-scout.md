# Structured Covariance Formula Vocabulary Scout

Date: 2026-06-14

## Question

Should the R grammar/status surface name all planned structured covariance
forms now, or only the currently most-visible `us()` / `fa(K)` examples?

## Sources Checked

- Local `HSquared.jl` docs, tests, and roadmap for Phase 4B structured genetic
  covariance.
- Local `gllvmTMB` vignettes and tests around latent loadings, uniqueness, and
  covariance extraction.
- Current `hsquared` formula grammar, model-status, and structured covariance
  design notes.

## Lessons

- The Julia twin already uses the vocabulary `diag`, `lowrank`, and `fa` for
  structured multivariate genetic covariance and exposes engine-side metadata
  around structure, rank, loadings, and uniqueness.
- `gllvmTMB` reinforces the interpretation rule: invariant covariance matrices
  are the first user surface; loadings and latent axes need sign/rotation
  conventions before they become scientific claims.
- The R package should therefore show the complete planned vocabulary in
  `formula_status()` and errors, but keep it non-executable until the R bridge,
  validation, and result metadata are ready.

## hsquared Action

- Add separate planned `formula_status()` rows for `cov = us()`,
  `cov = diag()`, `cov = lowrank(K = 2)`, and `cov = fa(K = 2)`.
- Keep `animal(trait | id, cov = ...)` rejected with a pointer to the current
  opt-in `cbind()` multivariate path.
- Do not add exported covariance helper functions yet; that would make the
  planned grammar look more live than it is.

## Claim Risk

Public wording must not say that structured covariance formula grammar is
implemented. Acceptable wording: "planned", "reserved", "future grammar", and
"current path is opt-in `cbind()` with unstructured G0/R0".
