# After-task report — v0.7 genomic recovery-v2 precision blocker

## 1. Goal

Run the preregistered raw-marker genomic GREML recovery pilot through the live
R-to-Julia route, launch confirmation only if every frozen gate passed, and
package either an activation candidate or a scientifically honest negative
endpoint.

## 2. Implemented

- Ran 432 fresh Totoro pilot fits through the ordinary R formula route; every
  attempt succeeded and converged.
- Produced create-once driver-R, independent base-R, and independent Julia
  summaries plus immutable manifests, packets, hashes, and corpus locks.
- Enforced the preregistered 2,000-replicate ceiling: five cells exceeded it,
  so no confirmation manifest was created.
- Localized and repaired a fail-closed adjudicator representation defect:
  logical `FALSE` was serialized as `false` and then compared lexically.
- Retired offsets 7101:7148, reserved 7201:7248 for any future separately
  admitted design, and synchronized public/status/validation prose without a
  capability or count promotion.

## 3a. Decisions and Rejected Alternatives

- Recorded the three-summary diagnostic `PRECISION_BLOCKER` and stopped the
  campaign; did not truncate required denominators, drop five difficult cells,
  relax margins, or launch partial confirmation.
- Preserved the immutable offset-7101 root byte-for-byte; did not monkey-patch
  the sealed process or mint a post-hoc adjudication receipt with unbound code.
- Did not rerun another 432 pilot fits solely to manufacture a receipt. The
  independent summaries already show that the frozen stopping rule bars
  confirmation; the next experiment must change the design for a declared
  scientific reason, not merely spend new seeds.
- Kept the route partial/held and `public_covered_count = 5`.

## 4. Files Touched

- `NEWS.md`
- `R/hsquared.R` and generated `man/hsquared.Rd`
- `docs/design/02-formula-grammar.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/48-v07-genomic-recovery-v2.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `tests/testthat/test-v07-genomic-recovery-v2.R`
- `tools/v07_genomic_recovery_v2.R`
- `tools/v07_genomic_recovery_v2_recompute.R`
- `vignettes/hsquared.Rmd`
- `vignettes/articles/formula-grammar.Rmd`
- `vignettes/articles/genomic-prediction.Rmd`
- `vignettes/articles/genomics-gpu-roadmap.Rmd`
- `vignettes/articles/model-status.Rmd`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- this report and the matching recovery checkpoint.

The Julia twin changes its recomputer, ROADMAP, genomic docs, capability and
validation ledgers, check log, coordination board, and matching closeout files.

## 5. Checks Run

- Totoro: 432/432 attempt files are `success` and `converged = true`.
- Three persisted summaries: same `PRECISION_BLOCKER`; base R is byte-identical
  to driver R; Julia maximum absolute numeric difference is `3.33e-16` and no
  numeric field exceeds `1e-10`.
- Focused recovery-v2 tests: 134 pass, 0 fail, 0 warn, 0 skip.
- Full `devtools::test()`: 0 failures and 0 warnings; ordinary optional/live
  dependency skips remain expected.
- Forced non-lazy pkgdown build: green; rendered stale-phrase scan is clean.
- `_R_CHECK_FORCE_SUGGESTS_=false` `R CMD check --no-manual`: 0 errors,
  0 warnings, 0 notes.
- Julia twin: recovery recomputer self-test green; full `Pkg.test()` green;
  Documenter/Vitepress build green with pre-existing docstring/npm warnings.
- `git diff --check`: green in both repositories before closeout.

## 6. Tests of the Tests

- Logical in-memory to TSV to character round-trip now stays green.
- A valid `false` to `true` inversion goes red.
- Invalid and missing Boolean tokens go red.
- Retired 7101 offsets fail both driver and independent base-R manifest gates;
  Julia's recomputer self-test rejects retired pilot membership.
- Existing gates still reject changed estimates, truths, seeds, cell labels,
  ridge, hashes, ID order, dropped failures, duplicate seeds, and tier overlap.
- The real negative control fired: the old adjudicator withheld the receipt and
  therefore prevented confirmation.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| CRAN JuliaCall segfault on Totoro Ubuntu 24 | Bound the exact upstream fixed source commit, installed tree, manifest, and bundled libunwind before root creation. |
| `target_pass` logical serialization mismatch | Fixed in both R comparators; round-trip and mutation tested. |
| Old offset-7101 root lacks an adjudication receipt | Preserved as unadjudicated diagnostic output; no post-hoc mutation. |
| Five pilot cells require more than 2,000 confirmation replicates | Campaign-wide precision blocker; no confirmation. |
| Public/status prose said the pilot had not run | Swept and corrected across both twins and rendered R pages. |

## 8. Consistency Audit

The neighbour sweep covered NEWS, public claims, capability status, validation
debt, ROADMAP, both reader-facing genomic articles, the package introduction,
the Julia genomic manual, recomputer contracts, generated pkgdown pages, and
Mission Control status. Every surface now distinguishes successful execution
from accepted recovery evidence and states that no receipt or confirmation
exists.

Memory receipt: the repo LOAD-FIRST manifest, ultra-plan/ask-brain research,
validation-harness, after-task audit, R-public/Julia-engine boundary, D-50 local
compute rule, and Rose negative-space discipline shaped the work. The first
absolute-path router invocation missed; routing by repo name returned the
correct manifest and was applied.

## 9. What Did Not Go Smoothly

Totoro/DRAC connectivity briefly dropped and recovered. Totoro's CRAN
`JuliaCall 0.17.6` initially segfaulted through system `libunwind`, requiring an
exact upstream source pin. After the full pilot, a case-sensitive Boolean
round-trip defect stopped adjudication even though the persisted summaries
agreed. The first pkgdown build reused stale cached pages; a forced non-lazy
rebuild corrected the rendered surface. `air format --check .` also reports a
large pre-existing formatting backlog, including several frozen campaign tools;
it was recorded rather than bulk-rewriting unrelated or hash-bound files.

## 10. Known Residuals

- The immutable offset-7101 pilot has no accepted adjudication receipt and cannot support
  confirmation or activation.
- A future recovery design must address the estimator variance/precision burden
  before using offsets 7201:7248; simply widening the compute cap is not an
  evidence-based fix.
- The studied DGP is independent HWE/no-LD and says nothing about LD,
  population structure, imputation, base-frequency misspecification, real
  panels, or production-scale data.
- The pinned JuliaCall repair is an exact upstream source commit, not the CRAN
  package bytes used in ordinary installations.
- Rose/G10, merge of default routing, release, and production claims remain
  open/held.

## 11. Team Learning

Serialization boundaries are scientific infrastructure: a Boolean must be
tested after an actual write/read round trip, not only in memory. A successful
pilot is not necessarily progress toward confirmation; its most valuable result
can be a preregistered precision stop that prevents a much larger uninformative
campaign.

Golden Set: not run because retrieval/routing code did not change. The in-scope
recurring failures were exercised directly through exact checkout/hash gates,
create-once files, retired seeds, independent recomputation, and deliberate
summary mutations.

## 12. Cross-Product Coverage

- Formula route covers the narrow Gaussian-REML, one-genomic-intercept marker
  path on the frozen VanRaden1/sample-frequency/ridge-0.01 scale; it does NOT
  cover ML, non-Gaussian families, slopes, multiple random effects, alternate
  frequencies/weights/ridges, or general genomic pipelines.
- Pilot execution covers 432 fresh Totoro fits across the nine frozen cells; it
  does NOT cover accepted recovery, confirmation, broad activation, LD,
  population structure, imputation, real panels, or production scale.
- Comparator evidence covers independent marker construction, exact
  marker-versus-supplied-Q identity, and the existing same-Q `blupf90+` link;
  it does NOT cover exact ridge-regularized SNP-BLUP equivalence or a second
  independent REML solver across the new recovery cells.
- Tooling covers local Totoro execution with exact source/environment binding;
  it does NOT cover GitHub Actions simulations/artifacts or a general portable
  JuliaCall installation contract.
- Status remains partial/held; this work does NOT cover capability promotion,
  `public_covered_count` change, G10, merge, release, or automatic publication.
