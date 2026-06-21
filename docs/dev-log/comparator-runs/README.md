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

Run handoff packets:

- `2026-06-21-blupf90-multivariate-executable-handoff.md` gives the exact
  BLUPF90-family host requirements, file-generation command, run commands,
  result fields, proposed review bands, and reporting boundary for the next
  executable-backed multivariate comparator run. It is a protocol, not evidence.
- `2026-06-21-genomic-gblup-snpblup-target-handoff.md` records the HSquared.jl
  PR #140 (`008ea4d`) genomic GBLUP / SNP-BLUP target fixture shape, local
  comparator-tool availability, required external-run fields, and claim
  boundary. It is a protocol, not evidence.

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
