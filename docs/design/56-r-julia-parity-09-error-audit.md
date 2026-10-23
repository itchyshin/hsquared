# Parity-09 error-string audit (experimental 0.9.0)

Companion to `docs/design/55-r-julia-engine-julia-parity-09.md`.
No new fitter targets. Version stays **0.9.0**. `public_covered_count` stays **7**.

Pinned tips: R `ebe18ff` / Julia `d1eb566b` (`origin/main` at inventory).

## SILENT-GAP closures

| ID | Gap | Abort name / site | Closest-path tip | Test |
| --- | --- | --- | --- | --- |
| SG1 | `cbind` + `permanent` tip incomplete | `hs_abort_unsupported_syntax` in `R/model-spec.R` (MV second-effect branch) | univariate `target="repeatability"` **or** `cbind` without `permanent` | `tests/testthat/test-engine-julia-unsupported-parity.R` |
| SG2 | `target="matrix_free"` / aliases bare allowlist | `hs_abort_unsupported_syntax` in `hs_validate_julia_target()` (`R/julia-bridge.R`) | engine-only D2; siblings `ai_reml`/`sparse_reml` or `multi_effect`/`repeatability` + `scale_method="auto"` | same |
| SG3 | Marker misroutes / FA / lowrank / RR+PE / NG outside A3 | existing `hs_abort_unsupported_syntax` + family fence | documented live paths per design-55 HONEST-ERROR table | same + existing FA/MV fence tests |

## HONEST-ERROR spot-check (already tip-complete; no code change)

| Surface | Abort | Tip present? |
| --- | --- | --- |
| FA / lowrank `genetic_structure` | `hs_validate_genetic_structure_control` | yes (D1) |
| Ordinary single-step default | default-path abort | yes → opt-in `target="single_step"` |
| Unknown non-matfree target | allowlist abort | yes |
| NG families outside poisson/binomial logit | `hs_nongaussian_family_symbol` | yes → A3 |

## Boole note (S2 G4)

No FA / matfree / MV+PE fitter targets added to `hs_validate_julia_target()` allowlist.
D1–D3 defaults held.
