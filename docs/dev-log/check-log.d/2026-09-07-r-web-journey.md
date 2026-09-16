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

## Rendered repair follow-up

- A 147-route browser crawl found an invalid XML control character in
  `man/figures/g0-rg-teaching.svg`, a 1440px 404 navbar overflow, and a 320px
  reference-index long-name overflow. The SVG source was repaired and every
  tracked SVG passed `xmllint --noout`.
- The phone reference rule wraps only long code-form function names; display
  mathematics now scrolls inside its own phone-width reading column rather than
  widening either multivariate article.
- The initial local `pkgdown::build_site()` sandbox attempt failed on DNS/R Sass
  cache access; the authorized retry rendered the repaired asset. Its retained
  log is `/private/tmp/hsq-web-20260907-r-render-repair.log`. `pkgdown::init_site()`
  then refreshed `pkgdown-site/extra.css` (retained log:
  `/private/tmp/hsq-web-20260907-r-render-assets-repair.log`).
- A serial Playwright check routed the candidate local stylesheet instead of the
  production absolute `extra.css` referenced by pkgdown HTML. It passed all 16
  combinations of 404, reference index, G-matrix interpretation, and
  multivariate pages at 1440/1024/768/320 px: status 200, no bad images, no
  page errors, and no horizontal overflow. The earlier un-routed probe remains
  retained as evidence that localhost otherwise loads the live stylesheet.
- `git diff --check` passed after the repair.
