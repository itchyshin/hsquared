## Resubmission response

Thank you for reviewing hsquared 0.9.0. This revision addresses the comments
from Konstanze Lauseker received on 8 October 2026.

### Examples

The three extractor help pages no longer use if(FALSE) or examplesIf FALSE.
They now use small, explicitly labelled synthetic result objects to illustrate
result extraction without Julia or a model-fitting step. All three examples
run during the ordinary package check, without donttest or dontrun wrappers.

### Package scope

We have removed development-roadmap language from DESCRIPTION. This submission
provides the implemented R interface for Gaussian pedigree animal-model fitting
and result extraction. Future extensions are outside that stated scope.
We retain experimental labels in the user documentation because validation is
model-specific and uncertainty intervals are not coverage-calibrated. The
article 'Can I fit and report this?' documents the restrictions and reporting
permissions. We do not claim that future or partial routes are fully developed.

## R CMD check results

Pending verification on the revised source tarball. This file is not yet an
upload-ready attachment. Predecessor check results are not evidence for this
revision.

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

* Version **0.9.0** is an **experimental** release (lifecycle badge, README, startup message). Public
  covered capability count is **7**; many formula terms remain planned or experimental-only.
* Uncertainty intervals and several opt-in routes are **not** coverage-calibrated; users are directed
  to the pkgdown article “Can I fit and report this?”.

## Authors and consent

* Maintainer and corresponding author: Shinichi Nakagawa `<itchyshin@gmail.com>`.
* Co-authors Yefeng Yang and Szymon Drobniak are listed with ORCIDs in `DESCRIPTION`, `inst/CITATION`,
  `CITATION.cff`, and README. `CITATION.cff` is retained for GitHub citation but excluded from the R source
  tarball; `inst/CITATION` is the package citation record. **Maintainer confirms co-author consent for CRAN `aut` and `cph` roles**
  (record kept outside the tarball).

## Method references

* DESCRIPTION cites Gilmour et al. (1995) <doi:10.2307/2533274> for univariate AI-REML.
  There is no single published methods paper for the full `hsquared` / `HSquared.jl` system. Validation
  follows textbook animal-model examples (e.g. Mrode) and package-documented recovery studies; see
  vignettes under `articles/` and `NEWS.md` for 0.9.0 scope.

## Downstream dependencies

* None known at first submission.
