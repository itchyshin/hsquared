# Check log — 2026-09-07 validation-evidence route/evidence wording

- RED: added the source-tree documentation regression in
  `test-d41-experimental-honesty.R`; it rejected the stale `"fits by default"`
  covered definition and the blanket `"Partial rows are experimental:
  REML-only"` definition. Retained receipt:
  `/private/tmp/hsq-web-20260907-r-validation-evidence-red.log`.
- GREEN: `devtools::test(filter = "d41-experimental-honesty")` completed
  **65 pass, 0 fail, 0 warning, 0 skip**. Retained receipt:
  `/private/tmp/hsq-web-20260907-r-validation-evidence-green.log`.
- Render: `pkgdown::build_article("articles/validation-evidence",
  new_process = FALSE, quiet = TRUE)` rendered only
  `pkgdown-site/articles/validation-evidence.html`; the generated page contains
  the covered-route routing distinction and the local `model-status.html` link.
  Retained receipt:
  `/private/tmp/hsq-web-20260907-r-validation-evidence-render.log`.
- No status, count, numerical result, coverage, or route promotion changed.
