# check-log: 2026-09-24 post-#366 T5 CRAN hygiene (no upload)

Theme T5: Julia-free `--as-cran` readiness receipt.
Lane: `cursor/post366-t5-cran-hygiene` at
`~/local-scratch/lanes/hsquared-post366-t5`.
Base: `origin/main` at `c77fc05` (Merge #239).
Boundary: experimental **0.9.0** / `public_covered_count` **7**; no
version bump; no CRAN upload; no Registrator; avoids #237 FA /
genomic ordinary / #365 engine themes.

## Hygiene changes

- `cran-comments.md`: refreshed for experimental 0.9.0; documented
  frozen-artifact steps; recorded Julia-free local gate outcome.
- `.Rbuildignore`: added `^tools$` and `^\.gitattributes$` so maintainer
  scripts and git metadata stay out of the source tarball.
- `DESCRIPTION` Suggests: removed unused `pkgdown` (site build is
  maintainer-only; `_pkgdown.yml` remains Rbuildignored). Version left at
  `0.9.0`.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-post366-t5
unset NOT_CRAN HSQUARED_JULIA_TESTS HSQUARED_REQUIRE_BRIDGE
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1
R CMD build .
shasum -a 256 hsquared_0.9.0.tar.gz
tar -tzf hsquared_0.9.0.tar.gz | wc -l
R CMD check --as-cran --run-donttest hsquared_0.9.0.tar.gz
```

Artifact retained under
`~/local-scratch/hsquared-post366-t5-artifacts/` (`as-cran.log`,
`00check.log`, `inventory.txt`).

## Results

| Check | Outcome |
| --- | --- |
| `R CMD build .` | `hsquared_0.9.0.tar.gz` |
| SHA-256 | `220a0ba2f5764a358a54f69da5e0a18d9b63a22fe01a45a9474855deb81daeed` |
| Size | 913647 bytes |
| Inventory | 278 paths; forbidden-path scan **CLEAN** |
| `R CMD check --as-cran --run-donttest` | **Status: 1 NOTE** (0 errors, 0 warnings) |
| NOTE content | expected `New submission` only |
| Version / covered count | **0.9.0** / **7** unchanged |

## Provenance note

This is a readiness / hygiene receipt (CRAN-gate rung toward
`tarball-clean` on a clean source state). It is not submission-ready,
not uploaded, and not a claim that CRAN accepted the package. Re-freeze on
the exact release commit before any Gate-B upload decision.

## Prohibitions held

No CRAN submit, no Registrator, no version bump, no covered flip, no
engine/formula theme edits (#237 / FA / genomic ordinary / #365).
