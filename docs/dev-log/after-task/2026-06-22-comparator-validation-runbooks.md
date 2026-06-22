# After-task report - Comparator & validation runbooks (PR B)

Date: 2026-06-22

Branch: `codex/comparator-validation-runbooks` (stacked on PR A / `codex/structured-cov-ratification`)

Active lenses: Jason, Fisher, Henderson, Kirkpatrick, Mrode, Curie, Rose

Spawned subagents: jason-landscape-scout ×2 (MV + genomic runbooks),
fisher-inference-reviewer (marker-scan plan), henderson-animal-model-specialist
(metafounder plan); Rose (rose-systems-auditor) for the audit

Current lane: R / coordinator (docs/plans only)

## 1. Goal

Batch 2 of the 20-slice goal — slices 4, 6, 7, 19. Author the comparator and
validation runbooks/plans that define how the partial capabilities get external
evidence, without producing any evidence or promotion: the multivariate
second-comparator runbook (slice 4), the genomic external-comparator runbook
(slice 6), the marker-scan threshold calibration plan (slice 7), and the
metafounder Γ-estimation + external-validation plan (slice 19).

## 2. Implemented

Four new docs, each a protocol/plan with an explicit "not evidence" boundary:

- **Slice 4** `docs/dev-log/comparator-runs/2026-06-22-multivariate-second-comparator-runbook.md`
  — ASReml-R / DMU / WOMBAT runbook for the **second** same-estimand REML
  comparator (the BLUPF90 path stays the separate existing packet). Reuses the
  existing `inst/comparator-scripts/asreml/multivariate-animal.R`; specifies
  DMU `.DIR` and WOMBAT `.par` hand-built inputs; pins the `phase4_multitrait_parity`
  targets, a per-tool scale-mapping table, and acceptance bands.
- **Slice 6** `docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-runbook.md`
  — per-tool recipes (AGHmatrix G/Ginv; rrBLUP GBLUP + SNP-BLUP; BGLR;
  sommer; JWAS) against the `genomic_gblup_snpblup_target` fixture, with the
  load-bearing supplied-`p` VanRaden-1 scale (`k = 2.825`) and the
  Bayesian-vs-REML distinction.
- **Slice 7** `docs/dev-log/comparator-runs/2026-06-22-marker-scan-threshold-calibration-plan.md`
  — operationalizes the doc 28 gates: permutation (on the whitened scale),
  realistic-LD simulation (type-I + power), PLINK/GEMMA/GCTA alignment; activates
  no threshold; LOCO excluded from first activation on the scale-mismatch ground.
- **Slice 19** `docs/design/30-metafounder-gamma-estimation-plan.md`
  — Γ-estimation design (engine-owned; García-Baccino 2017 MoM / REML options)
  + external-validation route (Mrode Ch.11 anchor; AGHmatrix scoped to
  ordinary/`Γ=0` construction; BLUPF90 preGSf90/GAMMAF90 for estimated Γ).
- Indexed the three comparator-runs docs in
  `docs/dev-log/comparator-runs/README.md`; corrected a stale `sommer 4.4.3` →
  `4.4.5` in the marker-scan plan.

## 3a. Decisions and Rejected Alternatives

- **Parallel drafting via specialist subagents**, then integrate/review/bank
  myself. The four docs are independent and research-flavored, so fan-out was
  efficient; I read all four in full before banking.
- **Caught and corrected a would-be false comparator claim:** my brief to the
  metafounder agent suggested `AGHmatrix::Amatrix(metafounder=)` as a target, but
  Henderson flagged that the twin's own `validation_status.jl` records
  "AGHmatrix/nadiv do not implement metafounder Γ." The doc now scopes AGHmatrix
  to ordinary/`Γ=0` construction and marks `Amatrix(metafounder=)` as UNVERIFIED.
  This is exactly the kind of overclaim the subagent review caught.
- **Did not run comparators or write generators.** DMU/WOMBAT input generators
  are noted as a reasonable follow-up but not built (no host tools to test them).
- **Kept slice 19 as a design doc (30)** rather than a comparator-run, since it
  is a contract+route, not a run; cross-referenced from the comparator README.

## 4. Files Touched

- `docs/dev-log/comparator-runs/2026-06-22-multivariate-second-comparator-runbook.md` (new)
- `docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-runbook.md` (new)
- `docs/dev-log/comparator-runs/2026-06-22-marker-scan-threshold-calibration-plan.md` (new)
- `docs/design/30-metafounder-gamma-estimation-plan.md` (new)
- `docs/dev-log/comparator-runs/README.md` (index + nothing else)
- `docs/dev-log/check-log.md` (entry)
- `docs/dev-log/coordination-board.md` (row)
- `docs/dev-log/after-task/2026-06-22-comparator-validation-runbooks.md` (this file)

No `R/`, `tests/`, `man/`, NAMESPACE, DESCRIPTION, capability-status, or
validation-debt change (these are runbooks/plans; status rows move only on
executed evidence).

## 5. Checks Run

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` (result in check-log).
- after-task validator on this report (result in check-log).
- `git diff --check`.
- Read all four drafted docs in full for claim-boundary integrity before banking.

## 6. Tests of the Tests

No behavioral tests (docs/plans only). The integrity check is that every doc
states "protocol/plan, not evidence", records the local tool blocker, keeps the
relevant rows `partial`, and preserves the Bayesian-vs-REML distinction — each
verified on read, and re-verified by the Rose audit.

## 7a. Issue Ledger

Advances `hsquared#10` (MV comparator), `#9`/`#7` (genomic), `#23` (marker
scan), and the metafounder rows; twin `HSquared.jl#49`, `#48`, `#41`. No issue
state changed, no capability/validation/public-claim promotion.

## 8. Consistency Audit

- All four docs cross-checked against the existing comparator-runs docs and the
  capability/validation rows for consistent claim boundaries.
- Verified the metafounder doc does not contradict the twin `V1-METAFOUNDER`
  status (AGHmatrix metafounder caveat) and that Mrode numbers are "to be
  transcribed", not cited from memory.
- Verified the genomic runbook's fixture values and `k = 2.825` against the
  committed fixture description; verified the MV runbook's `expected_*.csv`
  values match the fixture.
- Corrected the one stale fact found (sommer version).

## 9. What Did Not Go Smoothly

The metafounder-comparator brief I gave the subagent contained a latent overclaim
(AGHmatrix metafounder Γ); caught in review and corrected in the doc. Two
subagents also flagged latent issues outside this batch's scope (a possibly
over-parameterized `idv(record):us(trait)` residual in the existing ASReml
script; a λ_GC-implies-calibration wording risk in `R/gwas.R`/autoplot) — left as
flagged follow-ups, not fixed here.

## 10. Known Residuals

- All four are protocols/plans; no comparator/calibration evidence is produced.
  Every leg that needs binaries (ASReml/DMU/WOMBAT, AGHmatrix/rrBLUP/BGLR,
  PLINK/GEMMA/GCTA, BLUPF90 preGSf90/GAMMAF90) is blocked locally → Codex /
  a capable host.
- Flagged-but-not-fixed: the ASReml-script residual term and the λ_GC wording in
  `R/gwas.R` (out of scope; R-code changes need live tests → Codex).
- DMU/WOMBAT input generators not written.

## 11. Team Learning

When delegating comparator-runbook drafting, the highest-risk failure is a
plausible-but-false "tool X validates capability Y" claim. The subagent review
caught one (AGHmatrix ≠ metafounder Γ) by checking the twin's own status ledger —
always cross-check a proposed comparator against the project's recorded
"what tool X does/doesn't do" before asserting it.
