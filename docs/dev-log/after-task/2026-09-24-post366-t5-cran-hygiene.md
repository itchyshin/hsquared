# After-task: post-#366 T5 CRAN hygiene (no upload)

## 1. Goal

Bank a Julia-free `--as-cran` readiness receipt for experimental hsquared
0.9.0 on a clean worktree from `origin/main`, without uploading to CRAN and
without bumping version or `public_covered_count`.

## 2. Implemented

- Refreshed `cran-comments.md` for experimental 0.9.0 and documented the
  frozen-artifact steps maintainers must run before any upload.
- Tightened `.Rbuildignore` (`tools/`, `.gitattributes`).
- DESCRIPTION Suggests hygiene: dropped unused `pkgdown`.
- Ran `R CMD build` + Julia-free `R CMD check --as-cran --run-donttest` and
  recorded SHA-256, size, inventory, and check status.

## 3a. Decisions and Rejected Alternatives

Rejected uploading or cutting a release from this hygiene pass. Rejected
rewriting the long DESCRIPTION prose (out of T5 OWNS; Suggests-only).
Rejected merging conflicting release candidate #202 as part of overnight T5.

## 4. Files Touched

- `cran-comments.md`
- `.Rbuildignore`
- `DESCRIPTION` (Suggests only; Version stays 0.9.0)
- `docs/dev-log/check-log.md`
- `docs/dev-log/check-log.d/2026-09-24-post366-t5-cran-hygiene.md`
- `docs/dev-log/after-task/2026-09-24-post366-t5-cran-hygiene.md`

## 5. Checks Run

- `R CMD build .` → `hsquared_0.9.0.tar.gz` (913650 bytes)
- SHA-256 `d5e40bfb44d7fe0e3048754a027af321160d29965ae871ef455b79adfa44d024`
- Forbidden-path inventory scan: CLEAN (278 paths)
- `env` without `NOT_CRAN` / `HSQUARED_JULIA_TESTS`:
  `R CMD check --as-cran --run-donttest` → **1 NOTE** (`New submission` only)

## 7a. Issue Ledger

- No new package WARNING/NOTE blockers beyond the expected new-submission
  NOTE.
- CRAN submit / Registrator / Gate-B independent audit remain maintainer ASK.

## 8. Consistency Audit

Version **0.9.0**; public covered count **7**. No capability, formula, or
engine claim change. No upload.

## 6. Tests of the Tests

Julia-free lane relies on `hs_skip_live_julia()`; the CRAN-shaped check
completed without live Julia setup. Artifact identity uses macOS
`shasum -a 256`.

## 9. What Did Not Go Smoothly

Sandbox denied copying `.cursor` during `R CMD build` until the command ran
outside the sandbox; `.Rbuildignore` already excluded `.cursor`, but the
sandbox blocked the intermediate copy.

## 10. Known Residuals

This receipt is local macOS only. Platform-clean (win-builder / R-hub /
fresh CI on the frozen SHA), rights Gate-1, and Rose/Grace/Pat on the
immutable upload candidate remain unproven. Not submission-ready.

## 11. Team Learning

Hygiene and upload are different rungs. Bank `--as-cran` on an identified
tarball before any submit discussion; keep `pkgdown` out of Suggests when the
package never loads it.

## 12. Cross-Product Coverage

Covers source-tarball hygiene and Julia-free local `--as-cran`. Does not
cover live Julia, recovery campaigns, covered flips, or CRAN infrastructure.

## Next actions

Draft PR → merge-when-green. Append T5 to
`~/local-scratch/hsquared-post366-overnight-handoff.md`. Maintainer ASK remains
for any CRAN upload.
