# 2026-09-02 — 0.7 G5: R↔engine genomic promotion parity — RESULTS

**Arc:** 0.7 GREML gap-clear G5.  
**Predeclaration:** `2026-09-02-07-greml-promotion-parity-predeclaration.md`.  
**Not a covered flip.** Count stays **6**.

## Evidence recorded (banked on tip; tols not widened)

| Source | Outcome |
|---|---|
| R `test-genomic.R` marker ≡ exact supplied-Q [live] | Committed gate with `tolerance = 1e-8` on VC / ratio / fixef / EBV; fingerprint exact. Present on `origin/main` (merged activation + S0). |
| R activation fixture [live] | Both public routes match frozen fixture construction. |
| Julia `test_genomic_greml_s0_identity.jl` | Marker vs supplied-Q identity on tip (RNG-free; CI-green on #284). |
| Engine V2-GREML | Supplied-`Ginv` estimator already **covered**; marker route maps onto it. |

## Re-measure this gap-clear (optional local)

When Julia is on PATH against a local twin checkout:

```r
Sys.setenv(NOT_CRAN = "true")
devtools::load_all(".")
testthat::test_file("tests/testthat/test-genomic.R")
testthat::test_file("tests/testthat/test-genomic-greml-s0-identity.R")
```

```sh
julia --project=. -e 'using Pkg; Pkg.test("HSquared"; test_args=`test_genomic_greml_s0_identity`)'
```

If a local re-measure is not run in this session, the **committed** live gates
above remain the evidence of record (same as citing A26 results after merge).

## CI caveat (DP-10 posture)

Julia-free `R-CMD-check` green ≠ parity legs executed. Stub Tier-1 CI stays
off.

## Fence

G5 recorded for Rose §3 #8. Flip still needs full §3 + Rose CLEAN + #7.
