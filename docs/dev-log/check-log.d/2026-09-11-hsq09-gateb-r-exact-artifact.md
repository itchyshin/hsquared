# 0.9 Gate-B R exact-artifact candidate check

- Candidate branch: `codex/hsq09-gateb-r-artifact-20260911`.
- Source basis: exact clean commit `a1bd525e8594ccc346f43d7741eb37b1e7e112d2`.
- Frozen source artifact: `hsquared_0.9.0.tar.gz`, SHA-256
  `1934c4526279ba8a7e6f0e2cdb204d797a4a33e290028e2e1ed0f5dca745ed32`
  (886236 bytes). Its retained inventory contains no `.git`, `.unlazy`,
  `.Rhistory`, or `.RData` path.
- Candidate-local tests passed with `NOT_CRAN=false`; the live R-to-Julia parity
  cell separately passed with `NOT_CRAN=true` against the fresh Julia candidate
  branch.
- `pkgdown::check_pkgdown()`, `pkgdown::build_site()`, and
  `urlchecker::url_check()` passed; the retained log records `All URLs are
  correct`.
- `R CMD check --as-cran --run-donttest hsquared_0.9.0.tar.gz` completed with
  `Status: 1 NOTE`; the sole retained note is the expected new-submission
  feasibility note, not a package warning or error.
- Unlazy re-verification passed: nine of nine gates (`G0`–`G8`).
- The CRAN-gate negative controls passed. This is an artifact-preparation
  result only: no CRAN submission, registry action, PR update, push, tag,
  merge, or public release occurred.
