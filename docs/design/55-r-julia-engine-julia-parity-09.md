# R↔Julia `engine = "julia"` parity matrix (experimental 0.9.0)

Status: **inventory for parity-09**. No covered flip. Version stays **0.9.0**.
`public_covered_count` stays **7**.

Pinned twin tips (clean worktrees from `origin/main`, 2026-09-24):

| Twin | Branch / worktree | `origin/main` SHA |
| --- | --- | --- |
| `hsquared` (R) | `cursor/r-julia-parity-09-inventory` @ `~/local-scratch/lanes/hsquared-r-julia-parity-09` | `ebe18ff092341c9a6a1b729eb593476c941be053` |
| `HSquared.jl` | `cursor/r-julia-parity-09-inventory` @ `~/local-scratch/lanes/HSquared.jl-r-julia-parity-09` | `d1eb566bb4946564eaf7873db2da2ccad80815b9` |

Owner defaults for this arc (decide tickets D1–D3):

| ID | Default held |
| --- | --- |
| D1 | Factor-analytic / lowrank stay **named planned errors** on the R bridge (Julia V4-FA engine-covered is not R-public). |
| D2 | Matrix-free REML (`fit_matrix_free_reml` / V1-MATFREE-REML) stays **engine-only**; R must not grow a matfree `target`. Related large-scale path is `multi_effect` / `repeatability` with `scale_method = "auto"` (experimental, not a new target). |
| D3 | `cbind(...)` + `permanent()` is **honest-error quality** only (issue #237); full MV+PE fit is DEFER. |

Class vocabulary:

- **REACHABLE** — R `hsquared(..., control = hs_control(engine = "julia", …))` with the documented target/formula returns a finite fit (or the documented boundary contract).
- **HONEST-ERROR** — Julia can fit (or has an engine surface), but R rejects with `hs_abort_unsupported_syntax` / planned-not-implemented naming the closest live path.
- **SILENT-GAP** — wrong-target misroute, silent NA, half-fit, or an abort that does not name the unsupported syntax / closest live path. Must be closed in S2 (or explicitly filed as DEFER with an honest abort).

Julia pointer twin: `HSquared.jl` `docs/design/12-bridge-compatibility.md` (parity-09 section).

---

## REACHABLE — R `engine = "julia"` bridge targets

Allowlist source: `R/julia-bridge.R` `hs_validate_julia_target()` on R `ebe18ff`.

| Target | Julia fitter / route | Documented R formula / control | Capability note |
| --- | --- | --- | --- |
| `ai_reml` | `fit_ai_reml` / `fit_animal_model` | `y ~ … + animal(1 \| id, pedigree=)` | covered (v0.1); also default `engine="fit"` |
| `sparse_reml` | `fit_sparse_reml` | same animal formula; opt-in | partial / experimental |
| `henderson_mme` | `henderson_mme` (supplied VCs) | animal + supplied `initial` VCs | partial |
| `fit_animal_model` | `fit_animal_model` dispatcher | animal; dense path | alias / smoke surface |
| `repeatability` | `fit_repeatability_reml` (+ sparse/`scale_method="auto"`) | `animal + permanent(1 \| id)` | partial |
| `two_effect` | `fit_two_effect_reml` | `animal + common_env` / maternal (two-effect) | common_env covered; maternal experimental |
| `direct_maternal` | `fit_direct_maternal_reml` | `animal + maternal_genetic` (correlated) | covered (validation-scale) |
| `multi_effect` | `fit_multi_effect_reml` (+ `scale_method="auto"` → matfree MC) | `animal + (1\|g)+…` | covered (validation-scale dense); auto matfree experimental |
| `genomic` | `fit_gblup_reml` | `genomic(…)` + explicit `target="genomic"` | covered (validation-scale; opt-in) |
| `snp_blup` | `fit_snp_blup` / `fit_snp_blup_reml` | genomic markers; opt-in target | partial |
| `single_step` | `fit_single_step_reml` | `single_step(…)` opt-in | partial; ordinary default held |
| `single_step_construct` | construct + AI-REML path | construct control | partial |
| `metafounder` | metafounder animal / MME | metafounder primary | partial |
| `metafounder_single_step` | `fit_metafounder_single_step_reml` | Γ / group | partial |
| `relmat` | supplied relationship K | `relmat(…)` | partial |
| `precision` | supplied precision Q | `precision(…)` | partial |
| `multivariate` | `fit_multivariate_reml` (`:unstructured` / `:diagonal`) | `cbind(t1,t2) ~ … + animal(…)` | covered (validation-scale, t=2 US) |
| `random_regression` | `fit_random_regression_reml` | `animal(rr(…) \| id)` k=2 | covered (validation-scale) |
| `nongaussian` | `fit_laplace_reml` | `poisson(log)` / `binomial(logit)` narrow A3 | partial / experimental |

Smoke coverage for these targets is S3 (`tests/testthat/test-engine-julia-parity-smoke.R`).

---

## HONEST-ERROR — Julia-fittable or engine-present, R named reject

| Surface | Julia note | R reject today | Closest live path (tip) |
| --- | --- | --- | --- |
| `genetic_structure="factor_analytic"` / FA | V4-FA **engine-covered** (`fit_multivariate_reml`; loadings blocked from payload) | `hs_validate_genetic_structure_control` abort (D1) | `genetic_structure="unstructured"` or `"diagonal"` on `target="multivariate"` |
| `genetic_structure="lowrank"` | engine FA/lowrank structures | named planned abort (D1) | same unstructured/diagonal |
| `cov = fa` / `cov = lowrank(K=…)` formula | planned grammar | formula / phase0 unsupported tests | unstructured MV or univariate animal |
| Ordinary no-control `single_step()` default | V2-SSHINV engine-covered | default-path abort → opt-in Julia target | `hs_control(engine="julia", target="single_step")` |
| Direct `target="matrix_free"` / `"matrix_free_reml"` | `fit_matrix_free_reml` (V1-MATFREE-REML) engine-only (D2) | unknown-target allowlist abort | engine Julia call, or large-scale `multi_effect`/`repeatability` with `scale_method="auto"` |
| `fit_gllvm_laplace_reml` / genetic GLLVM | Phase 6 experimental; not R-wired | no R target / planned | `target="nongaussian"` narrow A3 or `multivariate` unstructured |
| GPU genomic (`backend=:cuda`, `gpu_fit_gblup`) | acceleration stubs / ext | not R-surfaced | CPU `target="genomic"` |
| Sire-model fitted fixture (V1-SIRE-FIT) | engine fixture; no public formula | no `sire()` formula | animal model with record→id Z |
| Broader NG (probit, ordered, gamma, beta-binomial, …) | engine families exist | `hs_nongaussian_family_symbol` / A3 fence | `poisson(log)` / `binomial(logit)` A3 only |
| RR + second effect | engine multi-effect possible | model-spec planned abort | univariate RR **or** univariate second-effect |
| Multivariate genomic / SS / iid extras | engine pieces exist | MV path supports animal-only | univariate genomic/SS **or** plain `cbind`+animal |
| `cbind(...)` + `permanent()` (#237) | engine multi-effect PE possible | model-spec MV reject (D3) | univariate `target="repeatability"` **or** `cbind` without `permanent()` |

---

## SILENT-GAP — must close in S2 (S1 inventory)

Inventory against R `ebe18ff` / Julia `d1eb566b` (S1 only; do not treat as closed here):

| ID | Gap | Expected close in S2 |
| --- | --- | --- |
| SG1 | `cbind` + `permanent` abort names MV animal-only shape but does **not** tip closest live PE path (`target="repeatability"`) or MV without `permanent` | Strengthen abort text + test (D3 honest-error quality) |
| SG2 | Unknown `target="matrix_free"` / `"matrix_free_reml"` only lists the allowlist; does not name D2 engine-only policy or `scale_method="auto"` sibling | Dedicated abort + test |
| SG3 | Confirm no misroute when combining markers that should abort (RR+PE, FA/lowrank, NG outside A3) | Tests asserting `hsquared_unsupported_syntax` + tip substrings |

Open SILENT-GAP count at S1 handoff: **3** (SG1–SG3).

---

## Explicitly out of fit-reachability scope

- Extractor asymmetry (**hsquared #236**) — DEFER unless smoke fails.
- Covered flips, CRAN, Julia General, public speed claims — forbidden this arc.
- Dirty Dropbox checkouts (`hsquared` July branch; `HSquared.jl` three-scale-naming) — never edited.

---

## Hopper + Boole read (S1)

- Hopper: bridge target allowlist ↔ Julia `fit_*` inventory above; payload fences for FA loadings unchanged.
- Boole: grammar rejects for FA/lowrank/cbind+PE/RR+second stay `hs_abort_unsupported_syntax`; no new fitter targets added for FA/matfree/MV+PE.
