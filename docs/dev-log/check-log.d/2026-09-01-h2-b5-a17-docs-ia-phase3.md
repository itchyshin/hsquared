# check-log — 2026-09-01 h2-b5 A17 docs IA (phase 3)

**Arc:** A17 phases A(4)/B/D — README D-41 callout, capability-ledger generator, full limits page, function map, reference-index split
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Plan:** `~/local-scratch/h2-a17-docs-ia-plan.md` §4a, §4b, §4c, §5 (I2), §2 reference split
**Goal:** Make the reader-facing claim surface generated from `validation_status()` instead of hand-written, and make the first README example runnable without Julia.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901

Rscript tools/write-capability-ledger-summary.R
air format tools/write-capability-ledger-summary.R \
  tests/testthat/test-capability-ledger-summary.R \
  tests/testthat/test-d41-experimental-honesty.R
Rscript -e 'pkgdown::check_pkgdown()'
Rscript -e 'devtools::load_all("."); testthat::test_local(filter = "capability-ledger-summary|d41")'
Rscript -e 'rmarkdown::render("vignettes/articles/current-limits.Rmd", output_dir = tempdir())'
Rscript -e 'rmarkdown::render("vignettes/articles/function-map-cheatsheet.Rmd", output_dir = tempdir())'
Rscript -e 'devtools::test(reporter = "progress")'
```

## Results

| Check | Outcome |
|-------|---------|
| `Rscript tools/write-capability-ledger-summary.R` | **PASS** — wrote `vignettes/articles/includes/capability-ledger-summary.md` (157 lines) |
| `air format` (3 touched files) | **PASS** — no diff |
| `pkgdown::check_pkgdown()` | **PASS** — no problems found |
| scoped tests (`capability-ledger-summary`, `d41`) | **PASS** — 20 + 15 assertions |
| render `current-limits.Rmd` | **PASS** — 32,739 bytes; generated include present, 7 route cards |
| render `function-map-cheatsheet.Rmd` | **PASS** — 18,261 bytes |
| `devtools::test()` (full suite) | **PASS** — `FAIL 0 \| WARN 0 \| SKIP 70 \| PASS 2322` (all 70 skips are live-Julia or optional-dependency guards) |

`devtools::check()` was **not** run in this slice — no `R/` or `man/` change was
made, so `document()` was also unnecessary. The R-lane rule to run `check()`
applies to code changes; this slice is docs, config, one `tools/` script, and
tests. Flagged rather than silently skipped.

## What changed

- **`tools/write-capability-ledger-summary.R` (NEW).** Generates
  `vignettes/articles/includes/capability-ledger-summary.md` from
  `validation_status()`. Route wording is keyed to exact `capability` strings and
  a declared expected `status`; generation **aborts** if a key vanishes or its
  status changes. The drift guard is the point — reader permissions cannot outlive
  the evidence row they were written against.
- **`vignettes/articles/current-limits.Rmd`.** Stub → full page: status vocabulary
  table (`covered`/`partial`/`experimental`/`planned`, never a bare "supported"),
  Julia-requirement table, the generated route cards, and a "before you report"
  checklist.
- **`vignettes/articles/function-map-cheatsheet.Rmd`.** Stub → full five-step map
  (Specify → Preview → Fit → Check → Extract), all examples `eval = FALSE`,
  uncertainty section stating no interval permission exists.
- **`README.md`.** D-41 channel 4: lifecycle badge, R-CMD-check badge, and a
  `> [!WARNING]` callout. I2 fix: first example is
  `hs_control(engine = "validate")` with no Julia; the fitting example is a
  clearly separate section headed "requires the Julia engine". Prose wall reduced;
  detail routed to the docs pages.
- **`_pkgdown.yml`.** 38-item extractor wall split into six task/status groups
  (Core / Uncertainty (experimental) / Repeatability and independent extra effects
  / Direct–maternal and random regression / Multivariate and G matrices / Genomic
  and marker outputs); `plot.hsquared_fit` moved to Visualization. All 38 topics
  retained exactly once — `check_pkgdown()` confirms.
- **Tests.** `test-capability-ledger-summary.R` (NEW, 8 tests): every route key
  resolves to exactly one `validation_status()` row; declared status matches live
  status; a missing key aborts; a demoted key aborts; no route claims an interval
  permission; generated text contains the honesty markers and none of the banned
  phrases; the committed include is byte-identical to a fresh generation.
  `test-d41-experimental-honesty.R` extended with the README channel-4 test,
  including an ordering assertion that the validate-first section precedes the
  fitting section.

## Claim boundary

- **No capability status changed.** No `experimental → covered` flip; no row added
  to or removed from `validation_status()`. `public_covered_count` untouched.
- **No `R/` code changed**, so no export, no `NAMESPACE`, no `man/` regeneration.
- The generated include is a **restatement** of `validation_status()`, not new
  evidence. Every scope sentence in the route table was written from the existing
  `claim_boundary` text of the row it is keyed to.
- **Known ledger gap surfaced, not fixed:** `docs/design/capability-status.md`
  records random-regression k = 2 and direct–maternal 2×2 G as covered at
  validation scale, but `validation_status()` carries no separate row for either.
  The generator therefore emits no card for them, and `current-limits.Rmd` says so
  explicitly in a hand-written section with their scope and fences. Adding those
  rows to the exported table is a public-claim-surface change and is left to the
  owner.
- **Known merge-conflict surface:** `origin/codex/2026-07-13-v07-performance-localization`
  carries five commits that edit the same README paragraphs (narrowing the genomic
  GREML claim to a held, branch-only route candidate). Their narrowing was **not**
  copied into this branch — on `main` the genomic row is still `partial`/opt-in,
  which is what this README says. Textual conflict on merge is expected; ownership
  is the owner's call (D-87/D-88).
- README badges are self-updating (shields.io lifecycle, GitHub Actions
  R-CMD-check), so neither asserts a status this branch cannot back.
- Not done in this slice: `inst/CITATION`, `cran-comments.md`,
  `hs_skip_live_julia()`, pkgdown CI build/deploy split, `man/*.Rd` `\examples{}`
  additions, and the Julia Documenter mirror (A18).
