# Check Log

Append exact commands and outcomes here. Do not replace repository evidence
with private memory.

## 2026-06-12

- Rehydrated R repo:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -5`
  - `gh run list --repo itchyshin/hsquared --limit 5`
- Result before Phase 0 R edits: clean `main`, tracking `origin/main`, latest
  R-CMD-check run green.
- Coordinated with Julia twin thread
  `019ebb88-ee69-7be2-850c-0e4840c34734`; instructed it to own only
  `HSquared.jl` and avoid R-repo writes.
- Verified Julia twin from live state after coordination:
  - `git status --short --branch` in `HSquared.jl`
  - `git log --oneline --decorate -5` in `HSquared.jl`
  - `gh repo view itchyshin/HSquared.jl --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
  - `gh run list --repo itchyshin/HSquared.jl --limit 5`
- Result: `HSquared.jl` is public at
  `https://github.com/itchyshin/HSquared.jl`, on clean `main`, latest commit
  `079dbf2`, latest GitHub Actions CI run passed.
- Local Phase 0 R commands:
  - `for d in .agents/skills/*; do python3 /Users/z3437171/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d" || exit 1; done`
  - `air format .`
  - `Rscript -e 'devtools::document(); devtools::test()'`
  - `Rscript -e 'devtools::check(error_on = "warning")'`
- Result: all local skill validations passed; formatting completed; R tests
  passed with `0 fails | 0 warnings | 12 pass`; R CMD check passed with
  `0 errors | 0 warnings | 0 notes`.
- Rose wording sweep:
  - `rg -n "TODO|\[TODO|fits animal|fits fast|implemented model|ASReml-level" README.md DESCRIPTION AGENTS.md ROADMAP.md docs .agents R tests`
- Result: matches were intentional claim-audit text only; no public wording
  says fitting is implemented.
- Follow-up Rose sweep used a broader unsupported-claim pattern and softened
  unsupported performance phrasing from `fast sparse` to `sparse`.
- After the clean full package check, final edits were prose-only claim-audit
  changes in README/design docs and generated Rd text. A subsequent
  `Rscript --vanilla -e 'cat("R ok\n")'` startup probe became unresponsive and
  was interrupted; use the next GitHub Actions run as the post-push R runtime
  verification.
- `git diff --check`
- Result: clean after trimming one trailing blank line in the testthat
  snapshot.
- Committed and pushed R Phase 0 scaffold:
  - `git commit -m "Install Phase 0 operating system"`
  - `git push origin main`
- Result: commit `d956a25` pushed to `main`.
- Remote R CI:
  - `gh run watch 27452325194 --repo itchyshin/hsquared --exit-status`
- Result: R-CMD-check passed in GitHub Actions in 1m33s.
- Public visibility:
  - `gh repo edit itchyshin/hsquared --visibility public --accept-visibility-change-consequences`
  - `gh repo view itchyshin/hsquared --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
  - `gh repo view itchyshin/HSquared.jl --json nameWithOwner,visibility,isPrivate,url,defaultBranchRef`
- Result: both `itchyshin/hsquared` and `itchyshin/HSquared.jl` are public on
  `main`.
- GitHub ledger:
  - Added shared labels and Phase 0-8 milestones to both repos.
  - Opened `hsquared` issues #1-#7.
  - Opened `HSquared.jl` issues #1-#7.
- Final evidence commit:
  - `git commit -m "Record Phase 0 R closeout evidence"`
  - `git push origin main`
  - `gh run watch 27452446531 --repo itchyshin/hsquared --exit-status`
- Result: final commit `2268ff4` is on `main`; R-CMD-check passed in GitHub
  Actions in 1m12s.

## 2026-06-13

- Rehydrated R repo:
  - `git status --short --branch`
  - `git remote -v`
  - `git log --oneline --decorate -5`
  - `gh run list --limit 5`
- Result before Phase 1A R edits: on `main`, tracking `origin/main`;
  latest remote R-CMD-check runs were green.
- Coordinated with Julia twin thread
  `019ebb88-ee69-7be2-850c-0e4840c34734`.
- Result: Julia lane reported `HSquared.jl` commits for pedigree inverse
  utilities and the genomics/GPU/HPC roadmap, with CI and Documenter green.
- Local package commands:
  - `Rscript -e "devtools::document()"`
  - `git diff --check`
  - `Rscript -e "devtools::test()"`
  - `Rscript -e "pkgdown::build_site()"`
  - `Rscript -e "pkgdown::check_pkgdown()"`
  - `Rscript -e "devtools::check()"`
- Result: documentation regenerated; whitespace check clean; testthat passed
  with `22 pass`; pkgdown site built locally into ignored `pkgdown-site/`;
  `pkgdown::check_pkgdown()` reported no problems; R CMD check passed with
  `0 errors | 0 warnings | 0 notes`.
- Formula/API checks:
  - `animal()` is now an exported inert formula marker.
  - `hs_build_model_spec()` parses the v0.1
    `animal(1 | id, pedigree = ped)` contract, validates pedigree/data IDs,
    builds fixed design matrices, and stops before fitting.
  - Tests cover accepted syntax, pedigree-column synonyms, unsupported
    trait/covariance syntax, missing pedigree IDs, and bridge-boundary
    wording.
- Documentation and public-site checks:
  - Added `_pkgdown.yml`, a pkgdown GitHub Actions workflow, and initial
    vignettes/articles for overview, model status, and the genomics/GPU
    roadmap.
  - Added `docs/design/07-genomics-qtl-gpu-plan.md` and a scout note for
    local packages, quantitative-genetic packages, and GPU backends.
- Rose wording sweep:
  - Public wording says parser/design-stage or planned where fitting,
    genomics, QTL/eQTL, GLLVM, GPU, and HPC features are not implemented.
  - No public wording claims fitted animal models, Julia bridge execution,
    GPU acceleration, or genomic/QTL support as implemented.
- Known check friction:
  - Early snapshot tests around Phase 0 bridge-boundary wording were replaced
    with direct `expect_error()` checks after snapshot update tooling created
    noisy EOF/diff prompts. The formula parser keeps focused snapshots for
    unsupported syntax.
- Remote GitHub Actions after push:
  - `gh run watch 27455226958 --repo itchyshin/hsquared --exit-status`
  - Result: R-CMD-check passed in 1m55s.
  - `gh run watch 27455226953 --repo itchyshin/hsquared --exit-status`
  - Result: initial pkgdown workflow failed while initializing `gh-pages`
    because the runner had no git author identity.
  - Fix: added a `Configure git identity` step to
    `.github/workflows/pkgdown.yaml`.
