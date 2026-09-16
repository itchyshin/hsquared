# Check log — 2026-09-07 release-record cleanup (R)

- Scope: paired documentation records only. No R source, public API, version,
  capability-status cell, test fixture, fit, release, tag, or deployment was
  changed or run.
- `git diff --check`: **PASS**.
- Manual source reconciliation: **PASS**. The current R target validator,
  validation-status documentation, and Julia compatibility matrix agree that
  `payload_v2` is limited on the R side to `direct_maternal` and `multi_effect`;
  FA/low-rank stays blocked and single-step stays opt-in partial.
- Public evidence pins recorded in the paired decision: R head
  `4b7bfefa0ddb7003d4f3e8dc7bbb5b9bb83355c6` with CI runs 34153464768 and
  34153676260; Julia head `a1c2401e194dba4f2fdffd580ccbc061b1c0df5a` with CI
  runs 34152604486 and 34152548409. These are cited as prior public evidence,
  not rerun by this cleanup.
- Result: experimental **0.8.0** / public count **7** remain unchanged.
