# After-task — single-step H⁻¹ construction bridge (2026-06-20 s5, ranked #3)

## Goal

Execute `docs/design/25`: surface the single-step H⁻¹ **construction** path
(`single_step(1 | id, pedigree = ped, markers = M)`) so users no longer precompute
`Hinv` — the engine builds it from the pedigree + genotyped-subset markers.

## Shipped

- **Parser** (`R/model-spec.R`): `hs_parse_single_step_construct()` — reuses
  `hs_validate_pedigree` + `hs_validate_genomic_markers`, computes the
  `genotyped_rows` alignment (§3: genotyped ids ⊆ pedigree ids; sorted
  pedigree-row positions; markers reordered to match), routes construction vs the
  supplied-`Hinv` path, and emits the "choose one" / "needs a pedigree" errors.
- **Payload** (`R/bridge-payload.R`): a `source = "construct"` branch carrying
  pedigree id/sire/dam, reordered markers, `genotyped_rows`, and the knobs.
- **Bridge** (`R/julia-bridge.R`): `hs_fit_julia_single_step_construct_payload()` —
  `normalize_pedigree → Ainv`, `additive_relationship → A`,
  `genomic_relationship_matrix → G`, `fit_single_step_reml(...; ids = hsq_ped.ids)`;
  asserts engine-order == R-order at fit time; reuses the genomic result normalizer.
- **Target/dispatch** (`R/hsquared.R`, `hs_validate_julia_target`,
  `hs_effect_targets`): `single_step_construct`.
- **Tests** (`tests/testthat/test-single-step-construct.R`): pure-R parser/alignment
  + error contracts; live reorder-invariance, id-labelled all-animal GEBVs,
  differs-from-pedigree-model, ridge rank-deficient-G.
- **Docs**: doc 25 → IMPLEMENTED (as-built, §6 corrected); capability-status
  planned(R) → partial(R); NEWS bullet; single_step() roxygen.

## Honesty

- Experimental, opt-in, REML-only, dense/validation-scale; mirrors twin `V2-SSHINV`
  (partial). Knobs not comparator-validated; promotion twin-gated.
- **v1 scope cut**: explicit `pedigree =` required (the `hs_data()` shorthand is
  deferred); `markers` without `pedigree` gives a directing error.
- The original spec §6.1 "reduction == animal model" keystone was **invalid** (the
  markers-built `G ≠ A₂₂`); replaced with independent guards (reorder invariance +
  differs-from-pedigree). Doc 25 §6 corrected to match.

## Verification

- **Adversarial verify** (Workflow `wf_7c349339-20f`, 5 lenses) caught 2 blockers:
  the missing `ids = hsq_ped.ids` (GEBVs labelled 1..n) and the circular keystone
  test. Both fixed; all should-fix/nits applied.
- Full `devtools::test_dir` (non-live) FAIL 0 / PASS 1112+; `air`; `document`;
  `check_pkgdown` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- **LIVE** (`test-single-step-construct.R`): reorder invariance to 1e-8, GEBVs
  id-labelled + cover all pedigree animals, cor(construct, pedigree) > 0.5 yet
  differ, ridge fits a rank-deficient G.

## Cross-lane

- No twin edit; targets her exported `single_step_inverse`/`fit_single_step_reml`/
  `additive_relationship`. Promotion past `partial` needs a BLUPF90/AGHmatrix
  single-step comparator (twin-gated).

## Next

1. LOCO / single-marker `gwas()` (#4).
2. The `hs_data()` pedigree shorthand for `single_step()` construction (deferred).
3. Large-pedigree sparse A (the dense `additive_relationship` is validation-scale).
