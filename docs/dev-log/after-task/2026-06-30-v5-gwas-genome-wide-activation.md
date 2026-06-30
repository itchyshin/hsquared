# After-task — V5 genome-wide calibration activated in `gwas()` (R twin, 2026-06-30)

Under the maintainer's authorization to do the cross-lane R `gwas()` activation (the v0.5 QTL gating leg). The
R half of the genome-wide-significance leg is now ACTIVATED and verified live. **NOTHING promoted to covered**
— the maintainer chose "land activation, hold flip": the scoped covered G10 is a deliberate later step.

## What changed

- `R/gwas.R`: `gwas(fit, markers, method = "single", genome_wide = TRUE, n_permutations =, seed =)` adds a
  `genome_wide_p` column via the Julia-owned `HSquared.genome_wide_marker_scan()` (HSquared.jl #208) — the
  exact per-dataset add-one permutation rule (null rebuilt per analysis; significant when `genome_wide_p <=
  0.05`). The generic + method signatures gained `genome_wide`/`n_permutations`/`seed`.
- Calibration-metadata contract EXTENDED (maintainer-chosen): `empirical_type1` may be `NA` for
  `calibration_method = "permutation_addone"` (validity by construction + externally validated), with a
  REQUIRED `validation_reference` naming the HSquared.jl REBUILD gate; other methods still require numeric
  `empirical_type1 ∈ [0,1]`.
- Wording UNHELD + SCOPED: the "NOT genome-wide calibrated" caveat now applies only to the nominal
  `p_value`/`bonferroni_p`/`bh_qvalue` columns (docstring, `print()`, NEWS); the `genome_wide_p` column is
  calibrated.
- SCOPE enforced in code: `genome_wide = TRUE` requires `method = "single"` (fixed-effect / intercept-only —
  the validated calibration); mixed/loco genome-wide null is rejected.
- Tests: pure-R validator (NA + `validation_reference`; missing-reference rejection; non-permutation method
  still needs numeric `empirical_type1`) + method-guard (mixed/loco rejection) + a skip-guarded LIVE bridge
  test (element-wise parity vs a direct `genome_wide_marker_scan` engine call).
- Status: `docs/design/capability-status.md` + `docs/design/validation-debt-register.md` note the activation as
  experimental/partial, fixed-effect-scoped, covered promotion twin-gated.

## Checks

- LIVE bridge (JuliaCall, local): `gwas(genome_wide = TRUE)` reproduces a direct
  `HSquared.genome_wide_marker_scan()` call element-wise (the planted causal marker is genome-wide significant).
- `devtools::test()` (CI-equivalent, live skipped): **0 fail, 1431 pass, 62 skip**.
- `R CMD check`: **0 errors, 0 warnings, 0 notes**.
- Real `rose-systems-auditor` audit → **PROMOTE** (engine call is the real validated rule not a fabrication;
  contract extension fenced with a required honestly-cited reference; scope enforced; wording scoped not
  inflated; tests real; nothing promoted on either lane). One cosmetic roxygen list-item glitch in `gwas.Rd`
  flagged + fixed.

## Honest status / held covered flip (ready for G10)

- `gwas()` genome-wide calibration is **experimental/partial** on both twins. The Julia `V5-MARKER-THRESHOLD`
  row is `partial`; this R activation does NOT flip it.
- The v0.5 evidence chain is now COMPLETE for a SCOPED covered claim: calibration (validation #203/#204 +
  production REBUILD gate #207, the exact rule type-I-controlled) + external comparator (PLINK #205) + the R
  `gwas(genome_wide = TRUE)` activation (this slice). The **scoped covered claim** would be: genome-wide
  significance via the exact per-dataset add-one permutation rule, FIXED-EFFECT / intercept-only, the tested
  LD designs; FENCED OUT: the mixed-model genome-wide null, broader-LD/covariate-adjusted calibration, the
  documented reuse-shortcut caveat.
- **The covered flip is HELD** (maintainer's choice) — a deliberate coordinated cross-twin G10 (Julia
  `validation_status()` V5 `partial → covered` scoped + R surfaces + a final Rose) for a later session.

## Next actions

1. (Maintainer G10, when ready) the coordinated scoped V5 covered flip across both twins.
2. (Optional) a Julia-free pure-R `genome_wide_scan_parity` fixture mirror for CI-without-Julia normalization
   parity (the live test already covers end-to-end within a Julia version).
3. (Future) mixed-model genome-wide null calibration; broader-LD/covariate-adjusted (Freedman–Lane) designs.
