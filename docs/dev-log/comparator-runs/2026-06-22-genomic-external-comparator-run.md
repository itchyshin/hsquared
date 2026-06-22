# Genomic external comparator run (EXECUTED)

Date: 2026-06-22 · Reporters: Jason / Fisher / Kirkpatrick lenses · Host: macOS
arm64, R 4.5.2.

This is an **executed external-comparator run** (not a runbook/protocol) against
the committed `genomic_gblup_snpblup_target` fixture, using CRAN packages that
were installed for this run. Generator (re-runnable):
`data-raw/genomic-external-comparator-study.R`. Protocol:
`docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-runbook.md`.

## Why this run exists

Earlier sessions recorded these comparators as "blocked / missing locally." That
was a conflation of **not installed** with **not available**: `AGHmatrix`,
`rrBLUP`, and `BGLR` are CRAN packages and installed cleanly
(`AGHmatrix 2.1.4`, `rrBLUP 4.6.3`, `BGLR 1.1.4`). So this genomic comparator is
not host-gated; it just needed running.

## Fixture

`tests/testthat/fixtures/genomic_gblup_snpblup_target/` — 4 individuals (g1–g4),
6 markers (0/1/2), `y = (10,12,11,9)`, supplied allele frequencies
`p = (.30,.45,.60,.40,.55,.35)`, supplied variances `sigma_g2 = 2`,
`sigma_e2 = 1` (ratio `lambda = 0.5`), VanRaden-1 with **supplied** frequencies
(`k = 2 * sum p(1-p) = 2.825`), `g_positive_definite = true`.

## Results

| Quantity | Tool | Result | Verdict |
| --- | --- | --- | --- |
| VanRaden-1 `G` (supplied p) | base-R re-derivation | max\|Δ\| `4.4e-16` | exact — independent re-derivation (not an external pkg) |
| `G⁻¹` (supplied p) | base-R re-derivation | max\|Δ\| `3.1e-15` | exact |
| VanRaden `G` | **AGHmatrix 2.1.4** | max\|Δ\| `0.277` | **different estimand** — AGHmatrix re-estimates p from the 4-sample; not a clean supplied-p comparator here |
| supplied-variance GBLUP intercept | base-R Henderson MME | `10.4334891878` vs `10.4334891878` | exact |
| supplied-variance GBLUP GEBVs | base-R Henderson MME | max\|Δ\| `4.4e-16` | exact |
| **GBLUP↔SNP-BLUP GEBV equivalence** | **rrBLUP 4.6.3** | max\|Δ\| `7.5e-6` | **equivalence confirmed externally** |
| GBLUP GEBV agreement | rrBLUP (REML var) | cor `0.99979` | agreement; gap explained by REML ratio |
| SNP-BLUP marker-effect agreement | rrBLUP (REML var) | cor `0.99817` | agreement |
| GBLUP GEBV agreement | **BGLR 1.1.4** (Bayesian) | cor `0.99943` | Bayesian agreement |
| rrBLUP REML variance ratio | rrBLUP | `Ve/Vu = 0.687` (vs supplied `0.5`) | explains the < 1.0 correlations |

## Interpretation (honest)

- **What is externally corroborated:** two independent CRAN packages (`rrBLUP`
  REML, `BGLR` Bayesian) reproduce the fixture's GBLUP GEBVs at correlation
  `> 0.999`, and `rrBLUP` independently confirms the **GBLUP↔SNP-BLUP GEBV
  equivalence** (the `V2-SNPBLUP` core claim) to `7.5e-6`. This is genuine
  external comparator evidence for the genomic GBLUP/SNP-BLUP estimands.
- **Why it is agreement, not exact parity:** no installed CRAN package fits the
  fixture's **supplied-variance** GBLUP — `rrBLUP`/`BGLR`/`sommer` all
  REML/Bayes-estimate the variance ratio (here `rrBLUP` finds `0.687` vs the
  fixture's supplied `0.5`). The `< 1.0` correlations are fully explained by that
  estimand difference, not by an engine error. The **exact** supplied-variance
  route is reproduced by an independent base-R Henderson MME (`4.4e-16`).
- **AGHmatrix finding (corrects the runbook):** `AGHmatrix::Gmatrix` re-estimates
  allele frequencies from the sample, so on this deliberately supplied-p, n=4
  fixture its `G` differs (`0.277`). It is therefore **not** a clean supplied-p
  `G` comparator here; the runbook's "AGHmatrix is the cleanest G comparator"
  expectation does not hold for a supplied-frequency fixture. A clean external
  `G` comparison would require forcing the supplied `p` (no direct argument in
  `Gmatrix` 2.1.4) or a fixture that uses sample frequencies.

## Claim boundary

- This is external comparator **evidence** for the genomic GBLUP / SNP-BLUP
  **estimands** (agreement-level, `> 0.999`; not exact parity, because of
  estimated-vs-supplied variances). It is a real run, not a protocol.
- It does **not** promote the genomic GREML / single-step / SNP-BLUP rows past
  `partial`: promotion is twin-gated, and production-sparse, APY, low-rank
  `m≫n`, and weighted/Bayesian-marker-prior support remain planned.
- The exact supplied-p `G`/`G⁻¹` and supplied-variance GBLUP are confirmed by
  independent base-R re-derivation, not by an external package; a clean external
  supplied-p `G` comparator (forced-`p` AGHmatrix, or ASReml/BLUPF90) remains
  open.
- `BGLR` is Bayesian/MCMC agreement, not same-estimand REML parity.
- No new R model-spec activation, no calibrated thresholds, no covered promotion.

Reviewer verdict: external rrBLUP/BGLR agreement accepted as corroborating
evidence for the genomic estimands (Fisher); G-construction comparator remains
open pending a forced-frequency or licensed-tool run (Kirkpatrick); rows stay
`partial`, no claim drift (Rose).
