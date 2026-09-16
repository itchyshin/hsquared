# check-log — 2026-09-01 h2-twin A10 BLUPF90 unavailability (F5)

**Arc:** A10 (B3)  
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`  
**Goal:** Close fog ticket F5 by documenting BLUPF90 executables unavailable on campaign laptop; scaffold wired.

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-h2-twin-20260901

# R BLUPF90 prep dry-run
Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R

# Executable probe (campaign laptop)
for x in renumf90 airemlf90 blupf90; do
  command -v "$x" || echo "$x MISSING"
done

# Scoped comparator-script tests
Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-comparator-scripts.R")'
```

## Results

| Check | Outcome |
|-------|---------|
| R dry-run | exit 0 — 80 data rows, 20 pedigree rows |
| `renumf90` | MISSING |
| `airemlf90` | MISSING |
| `blupf90` | MISSING |
| `test-comparator-scripts.R` | **PASS 46 / FAIL 0** (with `devtools::load_all()`) |
| Unavailability note | `docs/dev-log/comparator-runs/2026-09-01-blupf90-tool-unavailability.md` |

## Claim boundary

- Closes **F5** via document-unavailable-and-why path; does **not** install BLUPF90.
- Scaffold wired ≠ comparator evidence; `V4-MV-REML` remains **partial**.
- Next probe host: Totoro (separate approval before any run claim).
