# Test coverage collection and Codecov upload

**Slice:** first Codecov coding pass (hsquared R lane only)  
**Approval:** Shinichi approved Codecov rollout; this file records the
pipeline, not a coverage percentage.

This is **code-coverage infrastructure** (covr + Codecov). It is not a
scientific `validation_status()` coverage claim, not interval calibration,
and not a `public_covered_count` move.

## What runs

| Workflow | Role | Shards | Uploads to Codecov? |
| --- | --- | --- | --- |
| `R-CMD-check.yaml` | package check (ubuntu + windows) | two OS jobs, unchanged | **no** |
| `test-coverage.yaml` | `covr::package_coverage()` then one OIDC upload | ubuntu only | **yes, once** (`flags: ubuntu-covr`) |
| `pkgdown.yaml` | site build/deploy | n/a | no |
| `bridge-parity-tier1.yaml` | optional live Julia, dispatch only | n/a | no |

Do **not** add covr to the R-CMD-check OS matrix. Both OS jobs run the same
Julia-absent testthat suite; uploading twice would double-count.

The coverage job does **not** provision Julia. Live bridge tests skip, the
same way they skip on default R-CMD-check. Coverage numbers, when they
exist, describe that Julia-absent suite.

Auth is documented Codecov OIDC (`use_oidc: true`) with job-scoped
`contents: read` and `id-token: write`. No `CODECOV_TOKEN`, and
`GITHUB_TOKEN` / `GH_TOKEN` is not used as a Codecov token.

## Evidence stages (do not collapse)

Config on a branch is not functioning coverage. Keep these five claims
separate:

| Stage | What would prove it | This first pass |
| --- | --- | --- |
| 1. Local checks / local covr | `devtools::test()` / `covr::package_coverage()` on this host | **NOT_VERIFIED** — no R runtime here |
| 2. CI coverage finish | GitHub Actions `test-coverage` job produced `cobertura.xml` and a covr percent in the log / step summary | **NOT_VERIFIED** until that job completes |
| 3. Upload executed | Codecov action log shows a successful OIDC upload (`fail_ci_if_error: true`) | **NOT_VERIFIED** until that step succeeds |
| 4. Accepted commit report | Codecov commit URL for this SHA shows an accepted report | **NOT_VERIFIED** until Codecov accepts it |
| 5. Main dashboard coverage | https://app.codecov.io/gh/itchyshin/hsquared (or the GitHub Codecov app) shows `main` | **NOT_VERIFIED**; needs an authorized merge to `main` plus a successful `push` run of `test-coverage.yaml` on `main` |

Stage 5 is why the workflow listens to `push` on `main` as well as
`pull_request`. GitHub Actions will run the PR workflow from this branch
without merging. The **main dashboard** will not exist until someone with
merge authority lands the workflow on `main` and that `push` job uploads.
This lane does not merge.

## Architecture notes

- PR comments from Codecov, if the GitHub App is installed, can appear on
  this PR after a successful upload. That is stage 4-ish, still not stage 5.
- If OIDC upload fails, treat that as an actual uploader failure before
  asking the owner for a Codecov GitHub App grant or a repository token.
  Do not mint or extract tokens; do not put `GH_TOKEN` in the Codecov
  `token:` input.
- Coverage status checks are **informational** (`codecov.yml`). This pass
  does not fail PRs on an unknown baseline percentage.
- README Codecov badge is deferred until stage 4 exists. A badge is not
  evidence.

## Local covr (when R is available)

```r
# Julia-absent, same suite the CI job measures
cov <- covr::package_coverage()
print(cov)
covr::report(cov)
```

Do not treat a local percent as a Codecov dashboard number.
