# After-task report - Genomic external comparator run + V4 gate review

Date: 2026-06-22

Branch: `codex/genomic-external-comparator-run` (stacked on PR E / `codex/nongaussian-per-record-trials-r`)

Active lenses: Jason, Fisher, Kirkpatrick, Mrode, Curie, Rose

Spawned subagents: Fisher (fisher-inference-reviewer) for the V4 gate review;
Rose (rose-systems-auditor) for the audit

Current lane: R (validation evidence + review)

## 1. Goal

Two tasks the user asked for after correcting my "comparator host is a
meta-blocker" overstatement:
1. Install the CRAN comparator packages and **actually run** the genomic
   comparator against the `genomic_gblup_snpblup_target` fixture (real external
   evidence, not a runbook).
2. Draft the V4-MV-REML promotion-gate re-examination via a Fisher/Mrode lens.

## 2. Implemented

**Task 1 (executed comparator run).** Installed `AGHmatrix 2.1.4`, `rrBLUP 4.6.3`,
`BGLR 1.1.4` from CRAN (they were never blocked — just not installed). Wrote and
ran `data-raw/genomic-external-comparator-study.R`. Results
(`docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-run.md`):
- engine VanRaden `G`/`G⁻¹` (supplied-p) reproduced by independent base-R to
  4.4e-16 / 3.1e-15; supplied-variance GBLUP reproduced by independent base-R
  Henderson MME (intercept exact, GEBV 4.4e-16);
- **rrBLUP** independently confirms the GBLUP↔SNP-BLUP GEBV equivalence to
  7.5e-6; rrBLUP GEBV agreement 0.99979, marker-effect 0.99817;
- **BGLR** (Bayesian) GEBV agreement 0.99943;
- the < 1.0 correlations are fully explained by rrBLUP/BGLR REML/Bayes-estimating
  the variance ratio (rrBLUP 0.687) vs the fixture's supplied 0.5;
- **AGHmatrix** re-estimates allele frequencies, so on this supplied-p n=4
  fixture its `G` differs (0.277) — not a clean supplied-p comparator (a finding
  that corrects my own runbook's AGHmatrix expectation).
Updated the genomic rows in `capability-status.md` (SNP-BLUP) and
`validation-debt-register.md` (genomic target fixture) and the comparator-runs
README to record this executed evidence honestly — agreement-level, rows stay
`partial`.

**Task 2 (V4 gate review).** `docs/design/33-v4-multivariate-promotion-gate-review.md`
captures the Fisher/Mrode/Curie verdict: do not promote yet, but the
"two same-estimand REML comparators" gate is over-strict because there is **no
free CRAN multivariate-animal-model REML package besides `sommer`** — so it
hard-couples a covered claim to a licensed binary. Recommends making the second
REML comparator and the recovery-gate acceptance **substitutable** (twin-owned
change), names the compute-only recovery-broadening as the highest-leverage
no-binary action, and flags two honesty fixes (the full-unstructured `sommer`
leg is data-raw not CI; recovery is a low-power non-rejection).

## 3a. Decisions and Rejected Alternatives

- **Reported agreement, not parity.** No CRAN package fits the fixture's
  supplied-variance GBLUP (all REML/Bayes-estimate variances), so the honest
  external claim is > 0.999 agreement with the gap explained, plus exact
  reproduction by an independent base-R MME — not "exact external parity."
- **Did not force AGHmatrix to the supplied p.** `Gmatrix` 2.1.4 has no direct
  supplied-frequency argument; rather than hack a match, I recorded that AGHmatrix
  is not a clean comparator for a supplied-p fixture and left a forced-p / licensed
  G comparator as open. This corrects the runbook honestly.
- **No promotion.** Real external evidence strengthens the genomic partial but
  promotion is twin-gated and production-sparse/APY/low-rank remain planned.
- **V4: review, not gate change.** The gate is twin-owned; I produced a
  recommendation for Ada/Shannon + the twin rather than editing the twin.

## 4. Files Touched

- `data-raw/genomic-external-comparator-study.R` (new; `.Rbuildignore`d)
- `docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-run.md` (new)
- `docs/design/33-v4-multivariate-promotion-gate-review.md` (new)
- `docs/design/capability-status.md` (SNP-BLUP row), `docs/design/validation-debt-register.md` (genomic target row)
- `docs/dev-log/comparator-runs/README.md` (index)
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-22-genomic-comparator-and-v4-gate.md` (this file)

No `R/`, `tests/`, `man/`, NAMESPACE, or DESCRIPTION change (the study is a
`data-raw` script, outside the package build).

## 5. Checks Run

- `install.packages(c("AGHmatrix","rrBLUP","BGLR"))` → installed
  (2.1.4 / 4.6.3 / 1.1.4).
- `Rscript --vanilla data-raw/genomic-external-comparator-study.R` → the results
  above (real run).
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` (result in check-log).
- after-task validator on this report (result in check-log).
- `git diff --check`; confirmed `data-raw/` is `.Rbuildignore`d (no build impact).

## 6. Tests of the Tests

The run is self-checking: the base-R reference must reproduce the fixture
(4.4e-16) for the comparison to be trustworthy, and it does; the rrBLUP
GBLUP↔SNP-BLUP equivalence (7.5e-6) is the V2-SNPBLUP claim reproduced in an
independent package; the variance-ratio readout (0.687 vs 0.5) is the falsifiable
explanation for why agreement is 0.999 not 1.000 — if the gap were an engine
error rather than an estimand difference, the ratio would not account for it.

## 7a. Issue Ledger

Advances twin `HSquared.jl#49` (external comparator evidence) and `#41` (the V4
gate). No issue state changed, no promotion.

## 8. Consistency Audit

- The new evidence is recorded identically across the run report, capability-status,
  validation-debt, and the comparator README (agreement-level, rows partial,
  AGHmatrix caveat).
- Confirmed the genomic rows still say `partial`; no covered claim introduced.
- The V4 note's claims (no free CRAN MV-REML package besides sommer; data-raw
  vs CI sommer leg) were Fisher-verified against the repo files.

## 9. What Did Not Go Smoothly

AGHmatrix did not behave as the runbook assumed (it re-estimates p), so the
cleanest planned `G` comparator was not clean for a supplied-p fixture. Turned
into an honest finding rather than a forced match.

## 10. Known Residuals

- Genomic external evidence is **agreement-level** (> 0.999), not exact parity;
  an exact external supplied-variance/forced-p comparison (forced-p AGHmatrix, or
  ASReml/BLUPF90) remains open.
- The V4 gate change (make the 2nd-comparator and recovery-gate substitutable) is
  twin-owned; the two honesty fixes (full-unstructured sommer into CI; recovery
  wording) are open R-lane follow-ups.
- No capability promoted; genomic + V4 stay `partial`.

## 11. Team Learning

"Missing on this machine" is not "blocked" — CRAN comparators are an
`install.packages()` away, and running them produced real evidence that planning
alone could not (including the AGHmatrix-estimates-p finding that corrected a
runbook). Reserve "host-gated" for genuinely licensed/registration binaries
(ASReml/BLUPF90/DMU/WOMBAT) — and even there, re-examine whether the gate truly
needs them (V4) before treating them as blockers.
