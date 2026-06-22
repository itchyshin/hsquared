# After-task report - Forced-p G exact-parity check + V4 honesty fixes

Date: 2026-06-22

Branch: `codex/gparity-and-v4-honesty` (stacked on PR F / `codex/genomic-external-comparator-run`)

Active lenses: Jason, Kirkpatrick, Fisher, Mrode, Rose

Spawned subagents: Rose (rose-systems-auditor) for the audit

Current lane: R (validation evidence + status honesty)

## 1. Goal

The two clean follow-ups requested before the Julia-lane handover:
1. Chase the **exact-parity G check** against AGHmatrix (the agreement-only
   genomic run left this open).
2. The two **V4 honesty fixes** Fisher flagged (R-lane, no binary).

## 2. Implemented

**Follow-up A — exact-parity G construction.** `AGHmatrix::Gmatrix` (2.1.4) has
**no supplied-frequency argument**, so the supplied-p `G` *values* cannot be
forced. Instead the study now verifies the construction **formula**: feeding the
engine's VanRaden formula AGHmatrix's *own* sample p reproduces
`AGHmatrix::Gmatrix` to **`max|Δ| = 0`** (machine-exact). Combined with the
earlier result (engine fixture `G` == base-R supplied-p formula to 4.4e-16), this
confirms the engine's VanRaden `G` construction matches AGHmatrix
**formula-for-formula**; the fixture-level 0.277 difference is *solely*
AGHmatrix's p-estimation, not an algorithm discrepancy. Updated
`data-raw/genomic-external-comparator-study.R`, the run report (table +
interpretation + claim boundary), and the validation-debt genomic row.

**Follow-up B — V4 honesty fixes** (capability-status row "multivariate Gaussian
animal model" + validation-debt "experimental multivariate REML estimator
bridge"):
- The full-unstructured `sommer` comparator is now stated as **a reproducible
  `data-raw` run, not a CI gate** — and that the **CI-gated `sommer` check is
  diagonal-residual only**. Previously this could read as a standing CI gate.
- "no detectable bias" is now qualified as **a low-power non-rejection rather than
  a proof of unbiasedness**, so the recovery leg is not over-read as "unbiased".

## 3a. Decisions and Rejected Alternatives

- **Formula-parity, not value-parity, for AGHmatrix.** Since `Gmatrix` cannot take
  supplied p, I validated the algorithm at matched p (exact) rather than hack a
  value match. This is the honest, achievable exact check; the supplied-p *value*
  match still needs a supplied-frequency-capable tool (left as the one open
  sliver).
- **Reword, not re-architect, for V4 fix 1.** Promoting the full-unstructured
  `sommer` comparator into a CI test (Fisher's alternative) adds a fragile
  sommer/API CI dependency; the wording fix achieves honesty without that risk.
  Noted in-suite promotion as an optional later slice.
- **No promotion.** Both follow-ups sharpen evidence/wording; genomic and V4
  rows stay `partial`.

## 4. Files Touched

- `data-raw/genomic-external-comparator-study.R` (formula-parity block; `.Rbuildignore`d)
- `docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-run.md`
- `docs/design/capability-status.md` (multivariate row — 2 honesty fixes)
- `docs/design/validation-debt-register.md` (genomic row — formula parity; multivariate row — 2 honesty fixes)
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-22-gparity-v4-honesty.md` (this file)

No `R/`, `tests/`, `man/`, NAMESPACE, or DESCRIPTION change.

## 5. Checks Run

- `Rscript --vanilla data-raw/genomic-external-comparator-study.R` →
  `max|base-R VanRaden(p_AGH) - AGHmatrix G| = 0` (plus the prior run's numbers
  unchanged).
- `pkgdown::check_pkgdown()` (result in check-log).
- after-task validator (result in check-log); `git diff --check`.

## 6. Tests of the Tests

The formula-parity result is falsifiable: if the engine's VanRaden formula and
AGHmatrix's differed (centering, denominator), `max|Δ|` would be non-zero, not 0.
It is `0`, so the algorithms are identical at matched p. The V4 fixes are wording
corrections checked by re-reading the two rows for any residual "unbiased" /
"CI gate" overstatement.

## 7a. Issue Ledger

Advances twin `HSquared.jl#49` (genomic comparator) and `#41` (V4 gate). No issue
state changed; no promotion.

## 8. Consistency Audit

- The exact-parity finding is stated consistently across the run report (table +
  interpretation + boundary) and the validation-debt genomic row.
- The two V4 rows (capability-status + validation-debt) now carry identical
  honesty qualifications (sommer data-raw-not-CI; low-power non-rejection).
- Confirmed both rows still say `partial`; no covered claim introduced.

## 9. What Did Not Go Smoothly

AGHmatrix's lack of a supplied-frequency argument meant the literal "forced
supplied-p" check was not possible; pivoted to the equivalent (and stronger,
because exact) formula-parity-at-matched-p check.

## 10. Known Residuals

- The one open sliver: a supplied-p `G` **value** match against an external tool
  (needs a supplied-frequency-capable / licensed tool). The construction
  **algorithm** is now exactly validated against AGHmatrix, so this is cosmetic.
- The full-unstructured `sommer` comparator could still be promoted from
  `data-raw` to a skip-guarded in-suite test (optional; wording now honest).
- Genomic + V4 stay `partial`; no promotion.

## 11. Team Learning

When an external builder won't accept your inputs (AGHmatrix re-estimates p),
validate the *algorithm* at the builder's own inputs (exact) instead of forcing a
value match — it's a cleaner, stronger statement. And keep status wording matched
to what is actually CI-gated vs reproducibly-recorded: "external comparator … to
8e-5" should say whether it is a standing check or a one-time data-raw run.
