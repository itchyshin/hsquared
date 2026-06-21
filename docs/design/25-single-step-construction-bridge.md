# Single-step H⁻¹ construction bridge — R-wiring build-spec

Status: **IMPLEMENTED**, 2026-06-20 (R lane / Ada, Hopper, Henderson,
Kirkpatrick; adversarially reviewed by Boole/Hopper/Henderson/Curie/Rose). The
engine contract is **proven**; the R wiring (parser + payload + bridge + target)
has landed with pure-R alignment tests and live guards (§6). This doc is kept as
the as-built contract.

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
- Error contract (as built): supplying BOTH `Hinv` and (`pedigree`+`markers`) →
  a clear "choose one" error; `markers` without `pedigree` → a directing error
  pointing at the `pedigree =` requirement.
- **`hs_data()` bundle shorthand (LANDED, s6):** when `data` is an `hs_data()`
  container carrying both a pedigree and genotypes, `single_step(1 | id)` resolves
  both from the bundle (the `animal(1 | id)` precedent), so neither argument is
  required. Explicit `pedigree =`/`markers =` still win when supplied (they
  override the bundle, and may be mixed with bundle resolution of the other).
  The genotypes component is coerced to the numeric dosage matrix the construction
  path expects by `hs_single_step_bundle_markers()` (matrix → as-is; data frame →
  the bundle's `id` column or explicit row names provide the genotyped ids).

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

## 6. Live tests (Curie/Mrode) — `tests/testthat/test-single-step-construct.R` (LANDED)

NB the construct path builds `G` from **markers** (`genomic_relationship_matrix`),
so `G = A₂₂` is *not* reachable through it — the original "reduction == `animal()`"
keystone idea is **invalid** (markers give a VanRaden `G ≠ A₂₂`). The keystone is
instead the pair of *independent* guards below.

1. **Reorder guard (THE alignment guard, §6.3):** fitting with the marker rows in
   two different orders (same genotypes) gives an **identical** fit. A missing or
   wrong reorder would place `G` at the wrong `H⁻¹` rows and change the fit; this
   is the only test that catches a `genotyped_rows`/marker-permutation bug
   independently (a self-referential construct-vs-rebuilt-Hinv check cannot — both
   sides share the same alignment).
2. **Differs-from-pedigree anchor:** the construct GEBVs **track** the plain
   `animal()` pedigree-model GEBVs (correlation > 0.5, same signal) but **differ**
   from them (the genomic information is genuinely used) — an independent estimand,
   not a hand-rebuild of the same construction.
3. **Labels + coverage:** GEBVs are labelled by the real pedigree ids (not
   positional integers) and cover ALL pedigree animals; a specific ungenotyped
   phenotyped animal gets a finite GEBV (the §3.3 property).
4. **Singular-G / ridge (§6.4):** more genotyped animals than markers → a positive
   `ridge` makes `H⁻¹` PD and the fit succeed.
5. **Parser (no Julia):** topological + non-contiguous + scrambled-row alignment;
   `rownames(M) ⊄ ped_ids` / missing-markers / `markers`-without-`pedigree` /
   both-`Hinv`-and-construction error contracts.

All live tests skip-guarded on `hs_julia_bridge_available()`; one process per file.
The bridge also asserts engine-order == R-order at fit time (so the genotyped_rows
alignment fails loudly, not silently, if the two topological sorts ever diverge).

## 7. Honesty / status

**LANDED 2026-06-20** (R lane). Experimental, opt-in, REML-only,
dense/validation-scale; mirrors the twin `V2-SSHINV` (partial). The construction
`τ/ω/blend/ridge` knobs are **not** comparator-validated. Promotion past `partial`
is twin-gated (BLUPF90/AGHmatrix single-step comparator). `capability-status.md`
row "genomic/single-step construction beyond supplied inverses" is now `partial
(R)` (the reorder + differs-from-pedigree guards are green live). The `hs_data()`
bundle shorthand (`single_step(1 | id)` resolving pedigree + genotypes from the
container) **landed s6** (§2), live-verified to fit identically to the explicit
call; `markers` without a `pedigree` (and no bundle) emits a directing error.

## 8. Risk register

- **genotyped_rows order** (§3) — the single highest-risk item; the shuffled-`M`
  test (§6.3) is the guard.
- **dense `A`** — `numerator_relationship` is bounded-cache (validation-scale);
  large pedigrees are a twin-side sparse follow-up, not this slice.
- **observed ⊄ markers** — must NOT be required (§3.3); a test asserts an
  ungenotyped phenotyped animal still gets a GEBV.
- **parser ambiguity** — supplied vs construction branch must be unambiguous
  (§2 error contract).
