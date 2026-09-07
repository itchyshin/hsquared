# Check log — 2026-09-07 R web journey

- `devtools::test(filter = "capability-ledger-summary|d41-experimental-honesty|hsquared-help-frontdoor")`:
  **101 pass, 0 fail, 0 warning, 0 skip**.
- Generator/include identity check: passed; the committed reader cards exactly
  match `tools/write-capability-ledger-summary.R`.
- `git diff --check`: passed.
- Default R fit (existing tiny Mrode fixture; candidate Julia checkout):
  `HSquared.jl` `ai_reml`, converged, `h2 = 0.9522734`, `at_boundary = FALSE`.
  First sandbox attempt was blocked by Julia manifest-cache permissions; the
  authorized elevated retry completed in 22.4 seconds.
- Workflow-faithful local `pkgdown::build_site()` with operational root markdown
  temporarily hidden: rendered candidate at `/private/tmp/hsq-web-20260907-r/pkgdown-site`.
  Static audit receipt `/private/tmp/hsq-web-20260907-r-link-audit-final.json`:
  0 missing targets, fragments, out-of-prefix references, and image-alt failures.
