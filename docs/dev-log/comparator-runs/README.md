# Comparator Runs

Manual external-comparator outputs belong here only after they are actually run.

Required provenance:

- tool name and version;
- operating system and host class;
- fixture checksum or data-generation script;
- exact command;
- parameter file or model formula;
- convergence status;
- covariance estimates on the matched scale;
- reviewer verdict from Rose, Fisher, and Curie.

Do not commit licensed/proprietary output if the license forbids redistribution.

Use `TEMPLATE.md` for the first pass of each ASReml-R, BLUPF90/AIREMLF90,
DMU, WOMBAT, sommer, JWAS, or other external-comparator run. The template is a
review surface, not evidence by itself.

Current blocker reports:

- `2026-06-21-multivariate-tool-availability.md` records that this local host
  lacks ASReml/BLUPF90-family/DMU/WOMBAT executables and R packages needed for a
  second independent same-estimand multivariate REML comparator beyond the
  existing `sommer` leg.
- `2026-06-21-marker-scan-tool-availability.md` records that this local host
  lacks PLINK/GEMMA/GCTA/SAIGE-style scan executables and GenABEL/qvalue/
  rrBLUP/BGLR/AGHmatrix-style R packages needed for marker-scan comparator or
  calibrated-threshold evidence. It is a blocker report, not evidence.

Run handoff packets:

- `2026-06-21-blupf90-multivariate-executable-handoff.md` gives the exact
  BLUPF90-family host requirements, file-generation command, run commands,
  result fields, proposed review bands, and reporting boundary for the next
  executable-backed multivariate comparator run. It is a protocol, not evidence.
- `2026-06-21-genomic-gblup-snpblup-target-handoff.md` records the HSquared.jl
  PR #140 (`008ea4d`) genomic GBLUP / SNP-BLUP target fixture shape, local
  comparator-tool availability, required external-run fields, and claim
  boundary. The R test suite now mirrors the fixture and checks its internal
  VanRaden/GBLUP/SNP-BLUP algebra; it is still a target/protocol, not external
  comparator evidence.
- `2026-06-22-multivariate-second-comparator-runbook.md` is the run protocol for
  the **second** independent same-estimand REML comparator for `V4-MV-REML`
  using ASReml-R / DMU / WOMBAT (the BLUPF90 path is the separate packet above).
  All three tools are absent locally; protocol, not evidence.
- `2026-06-22-genomic-external-comparator-runbook.md` is the per-tool run recipe
  (AGHmatrix / rrBLUP / BGLR / sommer / JWAS) for external same-estimand genomic
  GBLUP / SNP-BLUP comparison against the `genomic_gblup_snpblup_target` fixture.
  BGLR/JWAS are Bayesian agreement, not REML parity. Now **executed** — see below.
- `2026-06-22-genomic-external-comparator-run.md` is the **executed** run
  (generator `data-raw/genomic-external-comparator-study.R`): `AGHmatrix`/`rrBLUP`/
  `BGLR` were installed from CRAN and run. rrBLUP independently confirms the
  GBLUP↔SNP-BLUP GEBV equivalence (7.5e-6) and rrBLUP/BGLR GEBVs agree with the
  fixture at > 0.999 (agreement-level — REML/Bayes vs supplied variances; AGHmatrix
  re-estimates p so it is not a clean supplied-p `G` comparator on n=4). Real
  evidence, not a protocol; genomic rows stay partial.
- `2026-06-22-marker-scan-threshold-calibration-plan.md` operationalizes the
  doc 28 GWAS threshold-activation gates (permutation, realistic-LD simulation,
  PLINK/GEMMA/GCTA alignment). Thresholds remain INACTIVE; plan, not evidence.
  (The metafounder Γ-estimation / external-validation plan is a design note,
  `docs/design/30-metafounder-gamma-estimation-plan.md`.)

For BLUPF90-family multivariate runs, attach a sanitized companion CSV when
possible with these columns:

- `quantity`
- `target`
- `estimate`
- `difference`
- `tolerance`
- `verdict`

The internal R ingester validates that table shape and the required core
quantities (`G`, `R`, and per-trait h2), but it is a review aid only. It does not
parse raw BLUPF90 logs and does not turn a protocol into comparator evidence.
