# Backend Status Diagnostics

Date: 2026-06-13

Active lenses: Lovelace, Karpinski, Grace, Rose, Pat.

Spawned subagents: none.

## Scope

Add a public R-side diagnostic so users and developers can inspect the planned
backend vocabulary without mistaking vocabulary for execution support.

## Implementation

Added `backend_info()`:

- returns one row each for `cpu`, `threads`, `cuda`, `amdgpu`, `metal`, and
  `oneapi`;
- records whether a backend is requested by `hs_control()`;
- marks every backend `selectable = TRUE`;
- marks every backend `execution_available = FALSE`;
- labels every backend `status = "planned"`.

Updated:

- tests;
- roxygen documentation and `NAMESPACE`;
- pkgdown reference index;
- NEWS;
- public claims register;
- capability status;
- validation debt;
- model-status article.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated `NAMESPACE` and
  `man/backend_info.Rd`.
- `Rscript -e "devtools::test(filter = 'phase0-api')"`: `35 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `151 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- First `Rscript -e "pkgdown::check_pkgdown()"`: failed because
  `_pkgdown.yml` was missing the new `backend_info` topic.
- Second `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- `backend_info()` reports planned backend status;
- backend names are selectable in `hs_control()`;
- backend execution is unavailable in this R diagnostic.

Blocked wording:

- CPU/GPU backend dispatch works;
- runtime GPU availability is probed;
- backend benchmarking exists;
- CPU/GPU numerical agreement has been tested.

## Tests Of The Tests

The test intentionally asserts `execution_available = FALSE` for all backend
rows. A future implementation must change this test before claiming an
execution-ready backend.

## Next Work

1. Add Julia-side typed backend controls in the twin lane.
2. Add runtime availability probes only after Julia exposes an honest backend
   capability API.
3. Add `backend()` and `device_info()` extractors once real fitted objects carry
   backend metadata.
