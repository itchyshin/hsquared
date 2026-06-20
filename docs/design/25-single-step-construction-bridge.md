# Single-step H⁻¹ construction bridge — R-wiring build-spec

Status: **build-spec (planned)**, 2026-06-20 (R lane / Ada, Hopper, Henderson,
Kirkpatrick). The engine contract is **proven**; this spec defines the remaining
**R wiring** so it is a mechanical fresh-context build, not a design problem.

## 0. Why

Today R surfaces single-step only with a **user-supplied** `Hinv`
(`single_step(1 | id, Hinv = Hinv)`, `target = "single_step"`). The engine ships
the **construction** — `H⁻¹ = A⁻¹ + scatter(τ·Gʷ⁻¹ − ω·A₂₂⁻¹)` over the genotyped
rows (Aguilar et al. 2010; Christensen & Lund 2009) — but R does not yet build it
from a pedigree + markers. This spec wires that path so an applied user writes the
model they have in mind:

```r
hsquared(
  y ~ fixed + single_step(1 | id, pedigree = ped, markers = M),
  data = dat,
  control = hs_control(engine = "julia",
                       engine_control = list(target = "single_step_construct"))
)
```

## 1. Engine contract (PROVEN — do not re-derive)

`HSquared.jl/src/genomic.jl`:

- `single_step_inverse(Ainv, A, G, genotyped_rows; tau=1, omega=1, blend_weight=0, ridge=0)` → `H⁻¹`.
- `fit_single_step_reml(y, X, Z, Ainv, A, G, genotyped_rows; tau, omega, blend_weight, ridge, initial, target=:ai_reml, ids)` → `AnimalModelFit`.

Inputs R must provide / have the engine build:

| Symbol | What | Engine builder |
| --- | --- | --- |
| `Ainv` | sparse pedigree inverse `A⁻¹` | `pedigree_inverse(normalize_pedigree(id, sire, dam))` |
| `A` | **dense** numerator relationship `A` | `additive_relationship(ped)` (exported; bounded `max_relationship_cache`, validation-scale; `A[i,i]=1+F_i`) |
| `G` | genomic relationship among the **genotyped** rows, in **sorted pedigree-row order** | `genomic_relationship_matrix(M_sorted)` |
| `genotyped_rows` | 1-based pedigree-row indices of the genotyped animals (sorted) | built R-side (see §3) |

**Key reductions (the live tests):** when `G = A[g, g]` (the dense `A₂₂` block,
NOT `(A⁻¹)[g,g]`) and **all** animals are genotyped, `H⁻¹` reduces exactly to `A⁻¹`
and the fit reproduces `fit_ai_reml(Ainv)` (engine tests `runtests.jl:3553`,
probe == `0.00e+00`). A singular raw `G` needs `blend_weight`/`ridge` (engine
`runtests.jl:3566/3572`).

**Live-confirmed (2026-06-20, this command sequence from a 5-animal pedigree):**
`additive_relationship(ped)` → dense `A`, `G = A[g,g]` all-genotyped,
`fit_single_step_reml(y, X, Z, Ainv, A, G, g)` vs
`fit_ai_reml(animal_model_spec(y, X, Z, Ainv))` → **`max|ΔVC| = 0.0`**. The exact
names/signature above are verified callable; the build is wiring, not discovery.

## 2. Parser grammar (Boole)

Generalize `single_step()` (`R/genomic-markers.R`) and the model-spec parser
(`R/model-spec.R`, `hs_is_single_step_primary_call`) so `single_step()` accepts a
**construction** branch in addition to the supplied-inverse branch:

- `single_step(1 | id, Hinv = Hinv)` — **supplied** (unchanged; `target="single_step"`).
- `single_step(1 | id, pedigree = ped, markers = M)` — **construction**
  (`target="single_step_construct"`).
- Optional knobs (parsed, passed through): `tau`, `omega`, `blend_weight`, `ridge`
  (defaults `1, 1, 0, 0`); keep them **out of the common path** (Users-are-gold) —
  document but do not require.
- Error contract: supplying BOTH `Hinv` and (`pedigree`+`markers`) → a clear
  "choose one" error. `markers` without `pedigree` (and no `hs_data` pedigree) →
  point at the pedigree requirement. Reuse the `hs_data()` pedigree shorthand
  (`animal(1|id)` precedent) so `single_step(1|id, markers=M)` can find a bundled
  pedigree.

## 3. genotyped_rows alignment (THE CRUX — Henderson/Hopper)

This is the one part with real edge-case density; pin it precisely:

1. `ped` defines the full animal ordering; `normalize_pedigree` returns the sorted
   pedigree ids (parents-before-offspring). Let `ped_ids` be that order.
2. `rownames(M)` are the **genotyped** animals; require `rownames(M) ⊆ ped_ids`
   (every genotyped animal must be in the pedigree). Error naming the offending ids
   otherwise.
3. **Do NOT require `observed ⊆ markers`** — ungenotyped *phenotyped* animals are
   the entire point of single-step. The observed (`y`) animals map to pedigree rows
   via `Z` (the record incidence), independently of who is genotyped.
4. `genotyped_rows = sort(match(rownames(M), ped_ids))` (1-based; sorted ascending
   to match the engine's `g` convention).
5. **Reorder `M`** so its rows are in `genotyped_rows` (i.e. pedigree-row) order
   before `genomic_relationship_matrix`, so `G`'s rows/cols align with
   `genotyped_rows`. (`M_sorted = M[order(match(rownames(M), ped_ids)), ]`.)
6. Validate: `length(genotyped_rows) == nrow(G) == ncol(G)`; no duplicate rows;
   all finite.

## 4. Payload contract (Hopper)

New `target = "single_step_construct"` payload (`R/bridge-payload.R`):

```
y, X, Z            # as the animal model (Z maps records -> pedigree rows)
id, sire, dam      # for normalize_pedigree -> Ainv, numerator_relationship -> A
markers            # M_sorted (genotyped rows, in pedigree-row order)
genotyped_rows     # 1-based, sorted
knobs = list(tau, omega, blend_weight, ridge)
initial            # (sigma_a2, sigma_e2) starts
metadata$relationship_source = "single_step_construct"
```

## 5. Bridge command (Hopper) — `R/julia-bridge.R`, new branch

```julia
hsq_ped   = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);
hsq_Ainv  = HSquared.pedigree_inverse(hsq_ped);
hsq_A     = HSquared.additive_relationship(hsq_ped);           # dense A, validation-scale
hsq_G     = HSquared.genomic_relationship_matrix(hsq_markers); # genotyped, pedigree-row order
hsq_fit   = HSquared.fit_single_step_reml(
  hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_A, hsq_G, hsq_genotyped_rows;
  tau=hsq_tau, omega=hsq_omega, blend_weight=hsq_bw, ridge=hsq_ridge,
  initial=(sigma_a2=hsq_a0, sigma_e2=hsq_e0));
hsq_result = HSquared.result_payload(hsq_fit);
```

Result normalizer + extractors: **reuse** the existing genomic/single_step path
(VC/h²/GEBVs, `estimated_single_step_construct_ai_reml` provenance). No new
extractors needed.

## 6. Live tests (Curie/Mrode) — `tests/testthat/test-single-step-construct.R`

1. **Reduction (the keystone):** all-genotyped pedigree, `markers` chosen so
   `G == A₂₂` is not required — instead pass the all-genotyped construction and
   assert the fit's VC/h²/EBVs **== the plain `animal()` `fit_ai_reml`** fit on the
   same data (the engine guarantees `G=A₂₂ ⇒ H⁻¹=A⁻¹`; the R-level test drives it
   through the public API). Tolerance machine-precision.
2. **Partial-genotyped sanity:** a pedigree where only a subset is genotyped +
   some phenotyped animals are ungenotyped; assert the fit converges, VC positive,
   h² ∈ (0,1), GEBVs for ALL pedigree animals (genotyped + not).
3. **Alignment guards:** `rownames(M) ⊄ ped_ids` errors naming the ids;
   shuffled `M` rows give the **same** fit (reorder correctness).
4. **Knobs:** `blend_weight`/`ridge` make a singular raw `G` fit (no PD error).
5. All skip-guarded on `hs_julia_bridge_available()`; one process per file.

## 7. Honesty / status

Experimental, opt-in, REML-only, dense/validation-scale; mirrors the twin
`V2-SSHINV` (partial). The construction `τ/ω/blend/ridge` knobs are **not**
comparator-validated. Promotion past `partial` is twin-gated (BLUPF90/AGHmatrix
single-step comparator). `capability-status.md` row "genomic/single-step
construction beyond supplied inverses" flips from `planned (R)` to `partial (R)`
only when this lands + the reduction test is green.

## 8. Risk register

- **genotyped_rows order** (§3) — the single highest-risk item; the shuffled-`M`
  test (§6.3) is the guard.
- **dense `A`** — `numerator_relationship` is bounded-cache (validation-scale);
  large pedigrees are a twin-side sparse follow-up, not this slice.
- **observed ⊄ markers** — must NOT be required (§3.3); a test asserts an
  ungenotyped phenotyped animal still gets a GEBV.
- **parser ambiguity** — supplied vs construction branch must be unambiguous
  (§2 error contract).
