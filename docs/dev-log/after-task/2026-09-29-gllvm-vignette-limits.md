# GLLVM vignette limits

## 1. Goal

Make the user-facing GLLVM article state the current diagnostics and computation limits identified in Rose's candidate audit.

## 2. Implemented

The vignette now says that R reports combined convergence and outer iterations, while inner-mode convergence, gradient norm, stop reason, and backtracks are not exposed. It also says the route uses dense validation-scale computation and that sparse input does not establish sparse or large-scale fitting.

## 3a. Decisions and Rejected Alternatives

Document the existing boundary rather than widening the bridge payload. Do not change the experimental status, formula grammar, or automatic-rank follow-on.

## 4. Files Touched

- `vignettes/articles/genetic-gllvm.Rmd`
- This report.
- `docs/dev-log/check-log.d/2026-09-29-gllvm-vignette-limits.md`

Other dirty files in this worktree predate this documentation slice and were preserved.

## 5. Checks Run

- `Rscript --vanilla -e 'rmarkdown::render("vignettes/articles/genetic-gllvm.Rmd", output_file="/private/tmp/genetic-gllvm.html", quiet=TRUE)'`: exited successfully; generated HTML contains both boundary statements.
- `python3 /Users/z3437171/shinichi-brain/tools/slop_check.py /private/tmp/hsquared-fa-gllvm-20260927/vignettes/articles/genetic-gllvm.Rmd`: 0 findings across 340 words.
- `git diff --check -- vignettes/articles/genetic-gllvm.Rmd`: clean.
- The prior same-candidate R to Julia FA/GLLVM parity run passed 166 checks (FA 113, GLLVM 53); this documentation edit did not rerun model tests.
- Hosted CI was not checked.

## 6. Tests of the Tests

The article sets `eval = FALSE` globally. Rendering checks the R Markdown structure and verifies the resulting prose, but does not execute the example fit. No model behavior is claimed from this render.

## 7a. Issue Ledger

- Closed: visible article omitted the limited diagnostics returned by R.
- Closed: visible article omitted the dense validation-scale boundary.
- Open: bridge diagnostics could be expanded later with contract tests; doing so is outside this documentation slice.

## 8. Consistency Audit

The additions narrow interpretation. The article still describes one complete, balanced, three-trait, rank-two Poisson cell; it does not claim general recovery, calibration, an external same-objective comparison, automatic rank selection, response-scale heritability, or sparse-scale fitting. No capability status or covered count changed.

## 9. Coordination Notes

Rose completed a read-only audit of the current candidates and identified both omissions. The coordination board was left untouched because preflight found work on that path across 49 refs. The hub lease command printed `GRANTED` but also reported that it could not write its registry entry; the file-level preflight showed no missing-ref work on the article or new report paths.

## 9. What Did Not Go Smoothly

The first prose-check invocation used a relative path that the checker resolved under a different root. Re-running it with the exact absolute path passed. Lease persistence could not be confirmed because the shared registry directory denied the write.

## 10. Known Residuals

This documentation correction leaves diagnostics unchanged and provides no validation of large-scale computation. The Julia engine-review gates and FA/GLLVM validation programme remain open. The article render did not execute its model example.

## 11. Team Learning

Rose's read-only audit found the diagnostics and scale disclosures missing from the article. The relative-path prose-check invocation resolved under the wrong root; an absolute path worked. Next, correct stale FA evidence counts on an owned R documentation path and resolve the separate `initial` control/help mismatch with bridge review. Resume Julia roadmap and engine findings only on their candidate lineage. Keep A2, E1, and V3 open.

## 12. Cross-Product Coverage

The change documents the R surface for the existing Julia-owned GLLVM route. It does NOT cover a new estimator, bridge field, supported model cell, or automatic-rank behavior.
