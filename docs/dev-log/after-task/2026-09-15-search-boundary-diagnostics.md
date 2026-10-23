# After-task — 2026-09-15 search_boundary diagnostics records (#230 / PR #232)

## 1. Goal

Write repo-visible records (check-log entry + this after-task report) for `hsquared`
PR #232, already merged (`e28ba19c`), which closes #230: `fit_diagnostics()` gains
`search_boundary`/`search_boundary_condition` rows for non-Gaussian fits, distinct
from the existing `at_boundary`/`at_boundary_condition` pair. This is a records-only
task: no code, test, or NEWS change is made in this session.

## 2. Implemented

Documented, in `docs/dev-log/check-log.md` (2026-09-15 entry, appended at the end)
and this report, the R-side change already on `main` at merge commit `e28ba19c`
(two commits: `fba0d8e1` the implementation, `8d9b2a4` the pre-merge Rose touch-up):

- `R/extractors.R` — `fit_diagnostics.hsquared_fit()` gains `search_boundary`
  (`hs_fit_search_boundary_flag()`, line 1745) and `search_boundary_condition`
  (`hs_fit_search_boundary_condition_label()`, line 1759), gated on
  `object$result$boundary`; both names added to `already_reported` (line 1610).
  Roxygen documents the `at_boundary` (estimates) vs `search_boundary` (optimizer
  state) distinction.
- `R/hs_control.R` / `man/hs_control.Rd` — the `boundary` paragraph now points at
  the new rows instead of saying they don't exist yet.
- `R/julia-bridge.R` — `hs_abort_boundary_refused()`'s message text mirrors the
  same `restart_check` two-start-fence wording added to the condition string
  (Rose O-1), so the two user-facing surfaces no longer disagree.
- `NEWS.md` — one bullet under the existing development-version header, corrected
  (O-2) to state the `"interior"` `FALSE` reading explicitly.
- Tests — `tests/testthat/test-fit-object.R` (hand-built non-Gaussian-shaped fit,
  both `boundary` values; hand-built Gaussian fit asserting no row at all) and
  `tests/testthat/test-nongaussian-three-field-v09.R` (live fixture fit asserting
  `search_boundary == "FALSE"`); both files' `"interior"` assertions tightened
  (O-3) to drop an `NA` escape hatch.
- `man/fit_diagnostics.Rd`, `man/hs_control.Rd` regenerated via `devtools::document()`.

Also recorded: the Rose audit (`rose-r8.md`) verdict APPROVE (merge when green),
its five confirmed claims and one non-blocking gap, the proof that `man/` was
regenerated (49 `.Rd` files byte-identical in a scratch roxygenise), the three
optional items and that all three were applied pre-merge on commit `8d9b2a4`, and
the twin context (`HSquared.jl` PR #348 merged the same day; open `HSquared.jl`
issues #344, #345, #340).

## 3a. Decisions and Rejected Alternatives

- **Cited the orchestrator's full live-suite number rather than re-running the
  full suite in this records session**, consistent with the 2026-09-15
  non-Gaussian-boundary-initial after-task's own precedent for PR #229. The
  full-suite count (`FAIL= 0 ERROR= 0 SKIP= 3 PASS= 3669`, PR #232 head before the
  O-1..O-3 touch-up commit) is attributed to the orchestrator's own measurement,
  not claimed as this session's own run. Rejected: re-running the full live suite
  myself — a multi-minute reproduction of a number already reported by another
  role adds runtime without adding a different kind of evidence.
- **The filtered live rerun was run fresh, twice, in this session** — once with
  `reporter = "summary"` for the dot-progress "gold medal" confirmation, once with
  `reporter = "silent"` capturing the returned results object to get an exact
  numeric tally (`FAIL= 0  PASS= 263`). This is this session's own measurement,
  not a citation, and it happens to match the number carried forward in the task
  brief for PR #232's own post-touch-up filtered rerun — reported as agreement
  between two independent measurements, not substituted for one.
- **No code, test, or NEWS change made in this session**, per the task's explicit
  "docs only" framing.
- **The `devtools::check()` NOTE from the first run is reported honestly, not
  silently dropped, even after it was fixed.** The task brief's own check command
  was run verbatim and returned `notes= 1` on the first pass; investigating it
  (rather than assuming it was one of the file's known-benign recurring notes)
  found it was this session's own stray artifact, not a PR defect. Fixed and
  re-run clean (`0/0/0`); both the cause and the fix are recorded in §9 rather
  than only reporting the final clean number, since a records report that hides
  its own near-miss is less useful to the next agent than one that names it.

## 4. Files Touched

- `docs/dev-log/check-log.md` — one entry appended at the end (2026-09-15,
  `search_boundary`/`search_boundary_condition`).
- `docs/dev-log/after-task/2026-09-15-search-boundary-diagnostics.md` — this report.

No R, test, NEWS, or `DESCRIPTION` file touched by this session.

## 5. Checks Run

- `Rscript -e 'devtools::document()'` then `git status --porcelain` — clean;
  **empty** diff (no drift between committed `man/`/`NAMESPACE` and a fresh
  regeneration on this branch head, `e28ba19c`).
- `Rscript -e 'r <- devtools::check(".", document = FALSE, quiet = TRUE, error_on =
  "never"); cat(...)'` (`OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4`, run via the
  harness's own background facility, no bare `&`, no sleep chain) — first run
  returned **errors= 0  warnings= 0  notes= 1** (`checking for hidden files and
  directories ... NOTE / Found the following hidden files and directories:
  .check_log.txt`); this was a stray, untracked, zero-byte artifact left in the
  worktree root by this session's own first (aborted) background-check attempt,
  not a defect in the PR — removed (`rm .check_log.txt`, confirmed untracked by
  `git status --porcelain` before deletion) and the check re-run clean:
  **errors= 0  warnings= 0  notes= 0**.
- Live filtered run (`HSQUARED_JULIA_TESTS=true HSQUARED_JULIA_PROJECT=<local
  HSquared.jl checkout, `origin/main` `a0a0059a`> NOT_CRAN=true
  OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4 Rscript -e 'devtools::test(filter =
  "fit-object|nongaussian-three-field-v09", reporter = "summary")'`) — both files
  fully green, "Your tests deserve a gold medal", exit code 0. A second run with
  `reporter = "silent"`, tallying the returned results object directly, gave
  **FAIL= 0  PASS= 263** — this session's own measurement.
- FULL LIVE SUITE (orchestrator-reported, PR #232 head before the O-1..O-3
  touch-up commit): `FAIL= 0  ERROR= 0  SKIP= 3  PASS= 3669`. Not re-run by this
  session; cited as the orchestrator's own measurement (see §3a).
- CI (`gh run list -R itchyshin/hsquared --branch main -L 4`): R-CMD-check on the
  PR #232 merge commit (`e28ba19c`) — SUCCESS (6m12s); pkgdown on the PR #232
  merge — SUCCESS; R-CMD-check and pkgdown on the prior (#229 records) merge
  commit — both SUCCESS.
- `Rscript <brain>/tools/check-after-task.R
  docs/dev-log/after-task/2026-09-15-search-boundary-diagnostics.md` — see §6.

## 6. Tests of the Tests

Not applicable in the usual sense (no code changed this session). The one check
applicable to a records-only task is the after-task validator itself
(`check-after-task.R`), which fails closed: it requires all twelve section headers
verbatim and requires the literal phrase "does NOT cover" to actually appear in
§12's body. This report was written with §12's negative-space bullets already in
place, and the validator was run once against the finished file (see §5) — this is
evidence the finished report satisfies the gate, not evidence the gate
discriminates against a broken draft.

## 7a. Issue Ledger

- **#230** (hsquared) — CLOSED by PR #232.
- **HSquared.jl#344** (open) — `laplace_reml_interval` does not consume
  `NonGaussianFit.boundary`. Not this repo's to fix.
- **HSquared.jl#345** (open) — R bridge consumes only `converged`, not `boundary`;
  its title predates #229's `hs_ng09_boundary()` addition and reads as stale
  relative to the current R bridge, but it was not re-litigated or closed from
  this session — closing an issue on another repo based on a records-only R-side
  audit is out of scope here.
- **HSquared.jl#340** (open) — `fit_multivariate_reml` optimizer parameter count
  does not remove FA/low-rank rotational indeterminacy. Unrelated thread, listed
  for twin-context completeness only.
- **`search_boundary = TRUE` on a genuine engine fit** (Rose NOT-COVERED, no issue
  filed) — untested and untestable through the public API by design, since the
  bridge refuses such a fit before an `hsquared_fit` object exists. Recorded as a
  residual (§10), not filed separately, per Rose's own framing.

## 8. Consistency Audit

Cross-checked every factual claim against primary sources rather than carrying
forward summaries: `gh pr view 232` (title, body, mergedAt, mergeCommit, two
commits) for the merge SHA and commit list; `gh issue view 230` for the closed
issue's exact wording; direct reads of `R/extractors.R` (lines 1595-1622, 1745,
1759), `R/julia-bridge.R` (lines 815-835), `R/hs_control.R`, and `NEWS.md` to
confirm the implementation and all three optional items were in fact applied on
commit `8d9b2a4` (not merely claimed in `rose-r8.md`); `git diff --stat
882b45f..e28ba19c` confirms the 8-file footprint (7 files at Rose's audit time,
plus `R/julia-bridge.R` added by the touch-up commit). `gh pr view 348 -R
itchyshin/HSquared.jl` and `gh issue view 344/345/340 -R itchyshin/HSquared.jl`
confirm the twin-context state (merged same day; three issues open, exact
titles). `gh run list -R itchyshin/hsquared --branch main -L 4` confirms CI state
at write time. `docs/design/capability-status.md` grepped for
`public_covered_count` and diffed 882b45f..e28ba19c against
`capability-status.md`/`validation-debt-register.md` — empty diff, count stays 7.

## 9. What Did Not Go Smoothly

- **Self-inflicted NOTE, found and fixed.** The first background attempt at
  `devtools::check()` in this session used a manual `nohup ... > .check_log.txt 2>&1
  & disown` pattern before the harness's own `run_in_background` semantics were
  re-confirmed. That command was killed (`pkill`) per the task's explicit
  instruction to never use a bare `&`, and the check was re-run through the
  harness's native backgrounding instead — but the zero-byte `.check_log.txt` it
  had already created in the worktree root was left behind, untracked. The next
  `devtools::check()` run (the task brief's own command, run exactly as
  specified) consequently returned `errors= 0  warnings= 0  notes= 1`, not the
  0/0/0 pattern the two most recent prior after-task entries in this same file
  recorded for their own runs. Rather than assume the note was one of the file's
  known-benign recurring notes (hidden top-level dirs, new-submission,
  roxygen2-version mismatch) and move on, it was re-run capturing `print(r$notes)`
  directly, which named the file: `checking for hidden files and directories ...
  NOTE / Found the following hidden files and directories: .check_log.txt`.
  Confirmed untracked (`git status --porcelain`), removed, and `devtools::check()`
  re-run a third time: clean `errors= 0  warnings= 0  notes= 0`. Net effect: zero
  defect in the PR, one self-caused false signal, caught and corrected before
  being recorded as a PR property.

## 10. Known Residuals

- `search_boundary = TRUE` on a genuine (non-hand-built) engine fit remains
  untested through the public API by design — the bridge's `hs_ng09_boundary()`
  refuses such a fit before an `hsquared_fit` object can exist. The `TRUE` branch
  of `search_boundary`/`search_boundary_condition` is covered only by a
  hand-built `result` list in `test-fit-object.R`.
- The `at_boundary`/`search_boundary` naming distinction is documented in roxygen
  and `?hs_control` but not enforced by any test that would catch the two
  concepts being confused in a future PR — same residual class the 2026-09-15
  non-Gaussian-boundary-initial report flagged for the underlying `boundary`
  field itself.
- `HSquared.jl#345`'s title reads as stale relative to the current R bridge (see
  §7a) but was left open, not corrected or closed, from this records-only R-side
  session.

## 11. Team Learning

- **A background `Rscript` command's stray stdout/log redirect, if aborted
  mid-write, leaves an artifact `devtools::check()` will flag as a hidden file
  in the very next run.** The general lesson from this file's prior entries was
  "never use a bare `&`, use the harness's `run_in_background`"; the specific
  addendum this session adds is: if a manual background attempt is aborted
  before switching to the correct mechanism, clean up whatever redirect target
  it already created (`ls -la` the worktree root, or `git status --porcelain`
  after the real check) before trusting the next check's result — an untracked
  leftover from your own tooling mistake can masquerade as a PR defect.
- **A records session should re-run the brief's own check commands verbatim and
  report what they actually say, even when a prior entry in the same file
  reported a cleaner result for a nearby commit** — the temptation, given
  consecutive 0/0/0 entries immediately above this one in `check-log.md`, is to
  assume the same command produces the same shape of output on the next commit.
  It did not, on the first pass (1 NOTE) — a records task exists to record and
  then run down reality, not to extrapolate the previous entry's pattern
  forward or assume the brief's implied "clean" outcome.
- **A number handed to a records session that happens to match a value already
  circulating (rose-r8.md, the PR body's own "Test / check numbers" section)
  should still be independently re-measured, not merely copied**, when the task's
  own instructions call for a live run — here the filtered rerun's `PASS= 263`
  was measured fresh in this session and only afterward compared against the
  brief's own cited figure, rather than the reverse.

## 12. Cross-Product Coverage

This slice is two additive `fit_diagnostics()` rows (`search_boundary`,
`search_boundary_condition`), gated on a single pre-existing result field
(`result$boundary`) that only the non-Gaussian bridge route writes — not a
cross-cutting flag that changes other targets' behaviour. Stated for
completeness against this campaign's own §12 precedent (2026-09-13,
2026-09-15 entries):

- **The new diagnostics rows cover:** any fit whose `result` list carries a
  `boundary` field — today, exactly the non-Gaussian three-field v0.9 bridge
  route (`poisson`, `bernoulli`, `binomial` conditional targets, all
  single-variance Brent in `HSquared.jl`). This does NOT cover: any Gaussian
  route (`engine = "fit"`, animal-model/genomic/single-step/direct-maternal/
  relmat/precision/multi-effect/multivariate) — none of these write
  `result$boundary`, so the `NULL` gate drops both rows entirely, by design, not
  by oversight; the `gamma`, `nbinom`, `ordered_probit (K>=3)` and `:gaussian`
  non-Gaussian families that HSquared.jl fits via the ±8-log-unit joint rail
  rather than the single-variance Brent path — the R bridge does not admit these
  as engine families today (`R/julia-bridge.R:875,950` fence on `poisson`,
  `bernoulli`, `binomial` only), so this is a latent scope note, not a current
  gap; and a real (non-hand-built) `TRUE` value, which the public API cannot
  produce on a returned fit (§10).
- **The condition-text correction (mirroring `restart_check` into both the
  condition string and `hs_abort_boundary_refused()`) covers:** the two
  user-facing surfaces that describe `result$boundary`'s meaning to a reader. It
  does **NOT cover**: `HSquared.jl`'s own `ArgumentError` message at
  `src/nongaussian.jl:907-909`, which the 2026-09-15 non-Gaussian-boundary-initial
  entry already recorded as carrying the same imprecision on the engine side
  (tracked as `HSquared.jl#347`, open, not this repo's to fix) — this PR narrows
  but does not close that specific twin-repo gap, since the R-side backstop
  message it corrects is presently unreachable in the wired route (the Julia
  payload builder refuses first).
- **Release/version/status-ledger surface — explicitly out of scope, not
  silently skipped:** no `DESCRIPTION` version bump, no tag, no CRAN submission,
  no `docs/design/capability-status.md` or `validation-debt-register.md` row
  change, `public_covered_count` stays **7**. This records session's own checks
  (`devtools::check()`, the filtered live test) cover only what PR #232 already
  shipped; they do **NOT** cover a CRAN-submission-grade `--as-cran` check, a
  cross-OS CI matrix run, or any evidence toward a future
  `experimental -> covered` status flip for the non-Gaussian target. Also does
  **NOT cover**: the vignettes that mention `at_boundary`
  (`vignettes/articles/model-status.Rmd`, `vignettes/articles/function-map-cheatsheet.Rmd`)
  — both were deliberately left alone by the PR's own author, and Rose agreed in
  the audit (rose-r8.md §6), since neither enumerates diagnostics rows and
  `search_boundary` only exists on the experimental non-Gaussian route those
  vignettes do not walk; and `restart_estimate`, which the 2026-09-15
  non-Gaussian-boundary-initial report already recorded as reaching the wire but
  not the R result object (O-3 on PR #229) — still not surfaced, unchanged by
  this PR.
