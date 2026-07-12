# 35 — API Stability Contract (0.5.0)

> **STATUS: PROPOSAL — awaiting maintainer ratification.** This scopes what the
> first CRAN/registry release (`0.5.0`) promises to keep stable versus what stays
> behind the experimental fence. It implements the "first-release contract"
> delta from the 2026-07-11 release-strategy panel and the release-model decision
> (`docs/dev-log/decisions.md`, "2026-07-11: Release Model"). Nothing here is
> binding until the maintainer accepts it.

## Purpose

`0.5.0` ships under a prominent **experimental** label (hub D-41). "On CRAN" must
never read as "validated end-to-end." An explicit stability contract lets an
applied user tell, at a glance, which surface they can build on and which may
change without a deprecation cycle. The machine-readable sources of truth are the
per-function **`lifecycle` badges** (already applied across the namespace) plus
`validation_status()` and `formula_status()`; this document is the narrative that
those signals encode.

## The stability tiers

### STABLE — committed for the `0.x` line (changes go through a deprecation cycle)

Scoped **only** to the covered core — the five recovery-gated Gaussian models,
each backed by a pre-declared 48-seed bias/MCSE recovery gate PASS and ≥1 external
same-estimand REML comparator that AGREES:

- The default `hsquared(y ~ fixed + animal(1 | id, pedigree = ped), ...)` call —
  its formula grammar for the univariate Gaussian animal model, and the
  `family = gaussian()` / `REML = TRUE` defaults.
- The four covered opt-in targets and their **frozen** auto-routing grammar and
  argument names (frozen by Boole as a precondition of each covered flip, per the
  Standard-Tier Covered-Flip Gate): common-environment `two_effect`, arbitrary-N
  `multi_effect`, `random_regression` k=2, and `direct_maternal` 2×2 G.
- The standard extractors **as applied to covered fits**: the point estimates
  from `heritability()` (including the direct–maternal Willham labelled triple),
  `variance_components()`, `breeding_values()` / `ranef()`, `fixef()`, and
  `genetic_correlation()`; and the core S3 methods (`print`, `summary`, `coef`,
  `nobs`).
- The honesty accessors themselves: `validation_status()`, `formula_status()`,
  `fit_diagnostics()` — their presence and columns, not their row *contents*
  (which grow as capability accrues).

Stability here is a promise about **names, argument spellings, and the shape of
returned point estimates** for covered fits — not about numerical values, which
may improve as the engine hardens.

### EXPERIMENTAL — no stability promise (may change or be removed without deprecation)

Everything carrying a `lifecycle::badge("experimental")` badge, including:

- The whole opt-in `engine = "julia"` surface **beyond** the four covered targets:
  genomic / single-step / SNP-BLUP / metafounder / multivariate / non-Gaussian /
  factor-analytic fits. All are `partial` in `validation_status()`.
- **All uncertainty outputs** — `heritability_interval()`,
  `variance_component_standard_errors()`, `repeatability_interval()`, and every
  interval/SE. They are asymptotic delta-method, **not coverage-calibrated**,
  REML-only, and unreliable at small `n` or near a boundary. No coverage claim
  exists for any model.
- The `cov = us()/diag()/lowrank()/fa()` structured-covariance grammar (surfaced
  diagnostically only; not a fitting contract).
- The reserved formula-marker verbs (`epistasis`, `imprinting`, `cytoplasmic`,
  `qtl_scan`, `marker_scan`, `dominance`, `relmat`, `precision`, …). These stay
  **exported and badged** so that using them in a formula raises the helpful
  `hsquared_unsupported_syntax` error naming the unsupported syntax — but their
  signatures carry no stability promise.
- The backend vocabulary (`cpu`/`threads`/`cuda`/`amdgpu`/`metal`/`oneapi`) —
  selectable metadata, not execution-ready.

## Scope fences that hold across the whole `0.x` line

- Dense, `n ≤ ~1000`, REML-only (ML is not implemented anywhere).
- Point estimates on covered fits are recovery-gated and externally
  cross-checked; **intervals are not coverage-calibrated**.
- Fitting requires the opt-in Julia engine; the R package is installable and its
  non-fitting surface (parsing, validation, status accessors, summaries) runs
  engine-free.

## Relationship to `1.0`

The `0.x` line makes **no** commitment to a stable *whole* API — only to the
covered-core surface above. The committed-stable **full** public API is a `1.0`
maturity gate (`docs/dev-log/decisions.md`, "2026-07-11: Release Model"), reached
only when every pillar is covered + production + interval-coverage-calibrated and
the maintainer declares maturity. Until then, the experimental fence is the
contract.

## Owed before `0.5.0` tag (maintainer / release pass)

- Surface this contract (once ratified) from the pkgdown landing page and a
  short "stability" section in the README, alongside the existing
  `model-status` / `validation-evidence` articles.
- Confirm the `lifecycle` badges partition matches this document exactly (every
  non-covered export badged experimental; the covered-core extractors not
  mislabelled).
