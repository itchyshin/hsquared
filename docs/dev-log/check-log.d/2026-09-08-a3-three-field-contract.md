# Check log — 2026-09-08 A3 three-field contract (R)

| Check | Outcome | Boundary retained |
| --- | --- | --- |
| Focused A3 R-to-Julia bridge test | PASS | live transport only, not calibration |
| Full R test suite | PASS | documented external/live skips retained |
| Ordinary isolated `R CMD check --no-manual` | Status: OK | live Julia intentionally skipped |
| Maintainer live-Julia check | exit 0, 0 errors/0 warnings; retained temp NOTE | no suppression of environmental evidence |
| Rose audit and Unlazy | PASS; 8/8 A3 gates | no promotion/release |

No source-bundle ledger or `LOOP` note remains after the `.Rbuildignore` fix.
