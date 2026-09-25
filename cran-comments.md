## R CMD check results

0 errors | 0 warnings | 3 notes

* Local Julia-free check on the frozen tarball (macOS, R 4.6.0):
  `env -u NOT_CRAN -u HSQUARED_JULIA_TESTS R CMD check --as-cran --no-manual hsquared_0.9.0.tar.gz`
* **NOTE — CRAN incoming:** first submission for this package name at version 0.9.0.
* **NOTE — `CITATION.cff`:** shipped at the repository root for GitHub/software citation
  (CodeMeta/CFF). It is not an R `inst/CITATION` bibliographic file; there is no competing
  `inst/CITATION` entry for the same work.

## Test environment

* Default `R CMD check` and CRAN incoming run **without** Julia or `HSQUARED_JULIA_TESTS`.
  Engine-backed tests are skipped when Julia is unavailable; the check log reports skips, not failures.
* Optional suggested packages (`enhancer`, `nadiv`, `pedigreemm`, `sommer`, …) may be absent on CRAN
  builders; examples and tests guard or skip accordingly.

## External software (not on CRAN)

* **Default fitting** requires a local Julia installation, the suggested package `JuliaCall`, and a
  checkout of the sibling engine **HSquared.jl** (not in the Julia General registry). README and
  vignettes state this explicitly; `engine = "validate"` exercises the R-side contract without fitting.
* We did **not** add `SystemRequirements: Julia` because the package installs and checks cleanly
  without Julia; only the default fit path needs it.

## Experimental release labelling

* Version **0.9.0** is an **experimental** release (lifecycle badge, README, DESCRIPTION). Public
  covered capability count is **7**; many formula terms remain planned or experimental-only.
* Uncertainty intervals and several opt-in routes are **not** coverage-calibrated; users are directed
  to the pkgdown article “Can I fit and report this?”.

## Authors and consent

* Maintainer and corresponding author: Shinichi Nakagawa `<itchyshin@gmail.com>`.
* Co-authors Yefeng Yang and Szymon Drobniak are listed with ORCIDs in `DESCRIPTION`, `inst/CITATION`,
  `CITATION.cff`, and README. **Maintainer confirms co-author consent for CRAN `aut` and `cph` roles**
  (record kept outside the tarball).

## Method references

* There is no single published methods paper for the full `hsquared` / `HSquared.jl` system. Validation
  follows textbook animal-model examples (e.g. Mrode) and package-documented recovery studies; see
  vignettes under `articles/` and `NEWS.md` for 0.9.0 scope.

## Downstream dependencies

* None known at first submission.
