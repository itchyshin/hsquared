# 45 — Bridge production fences (DRAFT / UNRATIFIED)

**Status:** DRAFT scratch honesty for Path FULL 0.9 closeout prep.  
**Pins:** version **0.8.0** · `public_covered_count` **7** · 0.9 **NOT authorized**.  
**Does not:** promote any bridge row to covered · authorize production claims · flip FA/SS.

Scratch receipt: `~/local-scratch/h2-09-finish-BRIDGE-PRODUCTION-FENCES-DRAFT.md`.

## Production vs validation-scale

**Validation-scale live bridge** means skip-guarded JuliaCall tests, dense paths, and
explicit opt-in targets — not sparse production fitting, not ASReml-scale multivariate
production, and not default CI without a sibling `HSquared.jl` checkout.

Infrastructure rows (**R-to-Julia bridge payload**, **opt-in experimental Julia engine**)
stay **partial** through 0.9 even when individual targets are covered.

## Target tiers (R `hs_validate_julia_target`)

| Tier | Examples | 0.9 public language |
| --- | --- | --- |
| Default live | v0.1 animal (`fit_ai_reml`), genomic GREML auto-route, `cbind()` multivariate | covered at validation-scale |
| Opt-in covered | `direct_maternal`, `multi_effect`, `two_effect` (common env), `random_regression` | covered at validation-scale, opt-in, dense |
| Opt-in partial | `single_step*`, `snp_blup`, `sparse_reml`, `repeatability`, `henderson_mme`, `nongaussian`, `relmat`/`precision` | partial / experimental |
| Blocked | `genetic_structure = "factor_analytic"` / `"lowrank"`, `cov = fa()` grammar | planned |
| PATH_ONLY | C1-ext interval smoke (`sim/phase1_interval_coverage_ext.R`) | not a fit bridge; `claim_eligible = false` |

## payload_v2

Block-structured **`parse_payload_v2` → `fit_payload_v2` → `result_payload_v2`**
is live for **`direct_maternal`** and **`multi_effect`** only. Other targets use the
legacy payload builders. Universal payload_v2 is **planned**, not 0.9.

## FA / SS fences (Gate 5)

- **FA:** R bridge **rejects** `"factor_analytic"` and `"lowrank"` at
  `hs_validate_genetic_structure_control()`. Engine FA is engine-covered only;
  rotation-invariant functionals only (doc 29).
- **SS:** Live opt-in via `target = "single_step"` / `"single_step_construct"` /
  `"metafounder_single_step"`. No default-route promotion. Engine `V2-SSHINV`
  engine-covered ≠ R-public partial.

## Hopper gate (before authorize 0.9.0)

Verify target parity, payload_v2 scope, FA rotation fence, SS engine≠R-public
discipline, genomic default vs held ordinary route, result-shape fixtures, and
PATH_ONLY isolation. Full checklist in scratch draft above.

## Cross-links

- Gap table history: [19-on-main-bridge-gap.md](19-on-main-bridge-gap.md)
- SS construction: [25-single-step-construction-bridge.md](25-single-step-construction-bridge.md)
- FA rotation: [29-structured-covariance-eigenbasis-bridge-contract.md](29-structured-covariance-eigenbasis-bridge-contract.md)
- Twin matrix: HSquared.jl [12-bridge-compatibility.md](https://github.com/itchyshin/HSquared.jl/blob/main/docs/design/12-bridge-compatibility.md)
