# After-task — 2026-09-20 merge of `asreml_test` into `main` (PR #234)

## 1. Goal

Merge the long-lived `asreml_test` branch (PR #234, opened 2026-09-16) into `main`
so the ASReml-vs-`hsquared` development comparison — the great tit animal-model
notebook, its two source CSVs, a small simulator, and a benchmark pedigree
generator — becomes part of the main line. Requested directly by the maintainer.

## 2. Implemented

Merged `origin/asreml_test` into `main` as merge commit `e29b0a7` (no fast-forward),
bringing in eight files under `dev-test/` and `docs/dev-log/`:

- `dev-test/great_tit_animal_model.qmd` — Quarto notebook fitting clutch size and
  laying date with `asreml`, then with `hsquared`, and tabulating runtime,
  variance components, and heritability side by side.
- `dev-test/great_tit_breeding_data.csv` (12,030 rows, 1965 onward) and
  `dev-test/great_tit_pedigree.csv` (111,637 rows) — the notebook's inputs.
- `dev-test/simulate-animal-data.R`, `dev-test/test.R` — simulator and benchmark
  pedigree generator.
- `docs/dev-log/check-log.md` — two 2026-07-24 entries, inserted in chronological
  position (before the 2026-07-13 entry), not appended.
- `docs/dev-log/after-task/2026-07-24-simple-animal-data-simulator.md` and
  `docs/dev-log/after-task/2026-07-24-development-benchmark-pedigree.md`.

Three resolutions were applied on top of the branch as pushed (see §3a):
`docs/dev-log/coordination-board.md` kept at `main`'s version, `.claude/settings.json`
kept tracked, and `^dev-test$` added to `.Rbuildignore`.

## 3a. Decisions and Rejected Alternatives

- **Kept `main`'s `coordination-board.md`, overriding the branch.** The branch's own
  merge commit `14536ec` has parents `9e2fec4` (board carrying 0 of the 2026-09-11
  rows) and `15770b6` (`main`, carrying all 21) and resolved to the branch side.
  Because that resolution is recorded as an intentional branch-side change, a plain
  `git merge` reproduced it **with no conflict**, deleting 21 rows spanning
  2026-09-02 to 2026-09-11. Verified by `git merge --no-commit` staging
  `M docs/dev-log/coordination-board.md`, then restored with `git checkout HEAD --`.
  Rejected: merging as-is and repairing the board afterwards — that would have put a
  21-row deletion into `main`'s history for any future `git log -p` reader to trip
  over, and the board is the recovery rule's own source of truth.
- **Kept `.claude/settings.json` tracked**, per the maintainer's explicit answer. The
  branch deleted it (70 lines of `PostToolUse` graft hook config). Rejected: letting
  the deletion land as the completion of `03cdf48 ignore settings jsons`. The
  `settings.json` ignore rule from `03cdf48` is deliberately left in place and is NOT
  resolved here — an ignore rule does not untrack an existing file, so the
  contradiction between the two is carried forward as a residual (§10), not silently
  fixed inside a data merge.
- **Added `^dev-test$` to `.Rbuildignore`.** Not requested; the branch did not include
  it. Without it the ~4 MB of CSVs, the `.qmd`, and two loose top-level `.R` scripts
  ship in the package tarball at version 0.9.0 with a `cran-comments.md` in the tree.
  `^dev-test$` was placed adjacent to the existing `^data-raw$` / `^sim$` entries,
  matching how the repo already fences development directories.
- **Merged the CSVs as-is**, per the maintainer's explicit answer to a question about
  redistribution rights for real long-term-study data with individual bird and
  nestbox identifiers on a public repository. Recorded as the maintainer's decision,
  not an inference; the files were already public on the PR branch before this merge.
- **Reverted `NAMESPACE` and `DESCRIPTION` churn produced by `devtools::document()`.**
  Local roxygen2 is 8.1.0; the repo pins `Config/roxygen2/version: 8.0.0` with
  `RoxygenNote: 7.3.2`. Running `document()` rewrites `importFrom(ggplot2, ...)` to
  multi-line form and rewrites the version pins. Rejected: committing it — the merge
  touches no `R/` file, so this is pre-existing toolchain drift on `main` and does not
  belong in a data merge. Filed as a residual (§10).
- **No `air format .`** — `air` is not installed on this host (`which air` empty),
  matching what the branch's own 2026-07-24 check-log entries already record. Not
  substituted with another formatter.

## 4. Files Touched

Merge `e29b0a7` against `ec5d684`:

- Added: `dev-test/great_tit_animal_model.qmd`, `dev-test/great_tit_breeding_data.csv`,
  `dev-test/great_tit_pedigree.csv`, `dev-test/simulate-animal-data.R`,
  `dev-test/test.R`,
  `docs/dev-log/after-task/2026-07-24-development-benchmark-pedigree.md`,
  `docs/dev-log/after-task/2026-07-24-simple-animal-data-simulator.md`.
- Modified: `.Rbuildignore` (one line), `docs/dev-log/check-log.md` (+34).
- Deliberately NOT in the merge: `docs/dev-log/coordination-board.md`,
  `.claude/settings.json`, `.gitignore` (the branch's duplicate `settings.json` line
  was dropped, leaving the file byte-identical to `main`).

`git diff --stat ec5d684 e29b0a7 -- R/ NAMESPACE man/ DESCRIPTION tests/ docs/design/`
is **empty**.

## 5. Checks Run

Host: macOS, `OPENBLAS_NUM_THREADS=1`. Julia bridge not exercised.

- `R CMD build --no-build-vignettes --no-manual .` — built `hsquared_0.9.0.tar.gz`,
  **885 KB**; `tar tzf | grep -c dev-test` returned **0**, confirming the
  `.Rbuildignore` fence. `man/figures` present (15 entries).
- `devtools::document()` — produced `NAMESPACE`/`DESCRIPTION` drift from a roxygen2
  version mismatch (8.1.0 installed vs 8.0.0 pinned); reverted, see §3a and §10.
- `devtools::test()` — `FAIL= 0  ERROR= 2  SKIP= 88  PASS= 2975`. Both errors are
  `test-multivariate.R:728` and `:819`, the `sommer` Suggests gate failing closed
  (`MV-1b`/`MV-1 requires Suggests package 'sommer' when NOT_CRAN=true`);
  `sommer` is NOT INSTALLED on this host.
- `pkgdown::check_pkgdown()` — **PASS** ("No problems found.").
- `devtools::check(args = c("--no-manual","--no-build-vignettes"))` with
  `_R_CHECK_FORCE_SUGGESTS_=false` — `errors= 2  warnings= 0  notes= 1`.
- **Baseline comparison (this session's own measurement, not a citation).** A detached
  worktree at the pre-merge commit `ec5d684` was created and the *identical* check
  command run there: `errors= 2  warnings= 0  notes= 0`, with error titles
  `checking tests ...` and `checking running R code from vignettes ...` and
  `any(grepl("animal-model-path.svg", r$errors))` **TRUE**. The same worktree run of
  `devtools::test(filter="multivariate")` gave `FAIL= 0  ERROR= 2  PASS= 119`.
  Conclusion: **both errors are identical pre-merge and post-merge**; the merge adds
  **zero** new check findings. The single NOTE difference is `.vscode`, an untracked
  local directory present in the working checkout and absent from the fresh worktree.
- CI on `main` after push: see §7a.

## 6. Tests of the Tests

The load-bearing claim here is negative — "the merge introduces no new check
findings" — and a negative claim from one run is weak. It was tested by constructing
the counterfactual rather than asserting it: a detached worktree at `ec5d684` (the
exact pre-merge commit, pinned beforehand as `refs/premerge/asreml-234`) was checked
with the byte-identical command, and the error count, error titles, and the
`animal-model-path.svg` substring were compared. The comparison discriminates: it
returned `notes= 0` against the merged tree's `notes= 1`, which is how the `.vscode`
NOTE was identified as a working-checkout artifact rather than a merge effect.

The `.Rbuildignore` fence was likewise verified by consequence, not by reading the
file: the tarball was built and its manifest grepped (`dev-test` count 0, size 885 KB).

## 7a. Issue Ledger

- **PR #234** (hsquared) — **MERGED** at `e29b0a7`, 2026-09-20T18:19:39Z, detected by
  GitHub from the pushed merge rather than through the web UI.
- **#138** (open) — "ASReml vs. HSquared comparison". This merge supplies development
  material toward it and does **not** close it: no comparator evidence is claimed and
  the issue's validation intent is unmet.
- **PR #235** (open, green, unreviewed) — `attr(fit, "bridge_errors")`, the R half of
  `HSquared.jl#351`. Directly related: `#351` was raised from a two-trait fit
  returning `SE = NA`, and `dev-test/great_tit_animal_model.qmd` is a two-trait
  (clutch size, laying date) fit that tabulates `SE` for both engines. Unaffected by
  this merge; left open.
- **`HSquared.jl#364` Ask 4** (open) — stale `:dense` extractor-default wording in
  `R/julia-bridge.R`. NOT addressed here; its fix rides on PR #235's commit `6dbfab7`
  and is still absent from `main`.

## 8. Consistency Audit

Every claim above was checked against a primary source, not carried forward from the
PR description (which was empty). `git log -1 --format='%H %P' 14536ec` gave the merge
parents and `git show <parent>:docs/dev-log/coordination-board.md | grep -c` gave the
row counts on each side, establishing the board regression mechanically rather than by
inference. `git merge-base --is-ancestor 15770b6 origin/asreml_test` confirmed the
branch had already absorbed that commit. `git ls-tree origin/main .claude/` confirmed
`main` still tracks `settings.json` despite `03cdf48`; `git show 03cdf48` confirmed
that commit touched `.gitignore` only. `git ls-files .vscode` (empty) confirmed the
NOTE's subject is untracked. Post-merge invariants were re-read from the working tree:
board rows `21`, `settings.json` `70` lines, `public_covered_count` **7** in
`docs/design/06-public-claims-register.md`, `Version: 0.9.0`. The ASReml claim
boundary was read from `docs/design/52-v07-exact-G-comparator-recipe.md:21`
("Forbidden as covered leg | ... **ASReml** (licence ABSENT)").

## 9. What Did Not Go Smoothly

- **The board regression was invisible to every ordinary signal.** PR #234 reported
  `MERGEABLE` / `mergeStateStatus: CLEAN`, CI was green, and `git merge` produced no
  conflict. Only a direct read of the three-dot diff showed 21 `-` rows, and only
  inspecting the merge commit's two parents explained why git considered the question
  already settled. A reviewer working from the GitHub UI would have had no cue.
- **I misreported the roxygen situation mid-task.** I grepped `DESCRIPTION` for the
  version pin *after* `devtools::document()` had already rewritten it, and stated the
  versions matched at 8.1.0. They do not: the repo pins 8.0.0 and the host has 8.1.0.
  The conclusion (drift is pre-existing, keep it out of this merge) was unaffected,
  but the stated reason was wrong for one step. Corrected on the spot from
  `git diff DESCRIPTION`.
- **A `grep -c` returning 0 exited non-zero** and broke an `&&` chain mid-command, so
  the tarball move did not run on the first attempt. The zero was the wanted result;
  the non-zero exit was not a failure of the check.

## 10. Known Residuals

- **`settings.json` ignore-vs-tracked contradiction.** `.gitignore` carries
  `settings.json` (from `03cdf48`) while `.claude/settings.json` remains tracked. Git
  honours the tracking, so behaviour is well-defined today, but the two express
  opposite intents and the next person to run `git rm --cached` will get a surprise.
  Not resolved here by explicit decision; needs its own slice.
- **Roxygen toolchain drift on `main`.** `devtools::document()` on this host now
  rewrites `NAMESPACE` and `DESCRIPTION` (8.1.0 vs the pinned 8.0.0). The 2026-09-15
  after-task recorded `document()` as producing an empty diff at `e28ba19c`, so this
  appeared between then and now, presumably from a local roxygen2 upgrade. Any next
  session running `document()` will see spurious churn until the pin or the toolchain
  is reconciled.
- **Two pre-existing local check errors** (`sommer` Suggests gate; the
  `animal-model-path.svg` vignette path under `--no-build-vignettes`). Both predate
  this merge and neither was investigated further here.
- **`.vscode` is untracked and not in `.Rbuildignore`**, so it produces a hidden-file
  NOTE in any local check run from this working checkout. It cannot reach CI.
- **The notebook is unexecuted in CI and unrunnable without a licensed ASReml.** No
  test, workflow, or check exercises `dev-test/`. It can rot silently.

## 11. Team Learning

- **A branch that already merged `main` once can still carry a silent revert of
  `main`.** The dangerous artifact is not a stale branch — it is a *merge commit on
  the branch* whose conflict resolution chose the branch side of a shared file. Git
  then treats the deletion as settled and will not raise it again at integration
  time. For any branch with a `Merge branch 'main'` commit in it, diff the shared
  coordinator-lane files (`coordination-board.md`, `check-log.md`, the design
  ledgers) against `main` explicitly before merging; `mergeStateStatus: CLEAN` says
  nothing about this class of loss.
- **Prove "my change caused nothing" with a worktree at the pinned pre-change
  commit, not with an argument.** The reasoning ("the merge touches no `R/` file, so
  it cannot affect tests") was sound and would have been accepted, but running the
  baseline cost about three minutes and converted it into a measurement — and it paid
  for itself by isolating the `.vscode` NOTE, which the argument alone would have
  left ambiguous.
- **Pin a rollback ref before starting an integration** (`git update-ref
  refs/premerge/<name> HEAD`). It costs nothing, survives the merge, and doubles as
  the exact commit the baseline comparison needs later.

## 12. Cross-Product Coverage

This slice is a development-material merge plus three integration resolutions. It
changes no package code and no claim surface, so most of the product is untouched by
construction; stated explicitly rather than left implied:

- **What the merged material covers:** a development-time, two-trait ASReml-vs-
  `hsquared` comparison on one real great tit dataset, plus two helper scripts. It
  **does NOT cover** validation: ASReml is licence-absent and explicitly *forbidden as
  a covered comparator leg* (`docs/design/52-v07-exact-G-comparator-recipe.md:21`), so
  nothing in `dev-test/` is admissible as covered-flip evidence, and issue #138 stays
  open. It **does NOT cover** any pre-declared recovery gate, MCSE bound, seed
  protocol, or runtime pre-registration; the notebook's runtime table is a development
  observation on one machine, not a benchmark.
- **What the checks cover:** that the merge adds no new `R CMD check` finding relative
  to `ec5d684`, that `dev-test/` stays out of the tarball, and that `pkgdown` is
  clean. They **do NOT cover** a CRAN-grade `--as-cran` run (`--no-manual
  --no-build-vignettes` were passed), a cross-OS matrix, the `sommer`-gated
  multivariate comparator tests (Suggests absent), the live Julia bridge (not
  exercised), or `air` formatting (not installed).
- **What the resolutions cover:** the board's 21 rows, `.claude/settings.json`, and
  the tarball fence. They **do NOT cover** the `settings.json` ignore-vs-tracked
  contradiction or the roxygen pin drift, both left as §10 residuals by explicit
  decision rather than oversight.
- **Release/status surface — out of scope, not silently skipped:** no `DESCRIPTION`
  version change (stays **0.9.0**), no tag, no CRAN action, no
  `docs/design/capability-status.md` or `validation-debt-register.md` row change,
  `public_covered_count` stays **7**, no `validation_status()` row added or flipped.
