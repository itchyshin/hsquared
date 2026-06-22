# Metafounder Γ Estimation and External-Validation Plan (R-lane PLAN)

Status: **PLAN ONLY, 2026-06-22 (R lane / Henderson, with Noether, Gauss, Fisher,
Jason, Mrode, Hopper, Rose as review lenses).** This document is a *design plan*
for two still-open metafounder gaps. It is **not** an implementation, **not** a
capability/validation/public-claim promotion, and **not** comparator evidence.
Nothing here changes the current `partial` status of the metafounder / `H^Γ`
surface. The two gaps:

1. **Γ ESTIMATION.** The metafounder relationship covariance `Γ` is *supplied*
   by the user today and is **never estimated** by `hsquared` or `HSquared.jl`.
2. **External validation.** There is **no external comparator evidence** for the
   supplied-Γ `A^Γ` / single-step `H^Γ` paths. This plan defines the validation
   route (anchor + comparator) without producing any of it.

Most of the computational work below is the **Julia twin's** (`HSquared.jl`,
Codex lane): Γ estimation and `H^Γ` are engine concerns. This R-lane document
defines only the *contract* the R package would expose and the *validation
route* the project would follow. It does **not** propose an R implementation.

This plan builds on `docs/design/27-metafounder-single-step-contract.md` (the
live supplied-Γ bridge contract) and does not restate its payload/extractor
detail except where Γ estimation or external validation would change it.

## Purpose

Define, as a gated plan, two things the metafounder surface needs before it can
move beyond `partial`:

- a **Γ-estimation design**: which estimator(s), which inputs/outputs, and which
  lane owns the computation (the Julia engine), so that `Γ` can eventually be an
  *estimated* quantity rather than a supplied input; and
- an **external-validation target**: a textbook *anchor* (Mrode 2014 Ch.11
  metafounder worked example) for the supplied-Γ construction, plus a software
  *comparator* (`AGHmatrix` and/or a BLUPF90-family Γ tool) with an explicit,
  honest statement of what each one can and cannot validate.

The deliverable is a contract + route, so that when the engine lane implements Γ
estimation and a comparator run is executed, the R lane already knows the
extractor names, the activation criteria for `metafounder_effects()`, the
status-row edits, and the promotion gates — and so that none of those are done
prematurely.

## Background

### Metafounders and unknown-parent groups

Classical pedigree relationship matrices assume base (founder) animals are
unrelated and non-inbred. When a pedigree pools individuals from genetically
distinct or partially diverged base populations (breeds, lines, generations,
historical strata), that assumption biases the relationship matrix and the
resulting BLUP/EBV and variance-component estimates. Two devices address this:

- **Unknown-parent groups (UPG):** missing parents are assigned to fixed-effect
  groups; the genetic-group model (Quaas/Westell-style) adds group columns to
  the MME but treats groups as fixed levels, not as a covariance structure.
- **Metafounders (MF):** Legarra et al. (2015) replace unknown parents with a
  small set of *related, pseudo-individual* ancestors whose mutual relationships
  are encoded in an `m × m` covariance matrix `Γ` on the relationship scale.
  `Γ` makes base-population relatedness and divergence explicit and is
  compatible with single-step genomic evaluation: replacing the classical
  pedigree relationship `A` with the metafounder-augmented `A^Γ` inside the
  single-step construction yields `H^Γ`.

MF and UPG are **distinct** and must stay distinct in the API:
`unknown_parent_group()` remains a separate planned syntax reservation and is
**not** an alias for `metafounder()` (see contract 27 §2).

### Why supplied-Γ is insufficient

`Γ` is itself a set of parameters. Supplying it requires the user to already
know base-population relatedness, which is exactly what most analyses do not
have. The methodological literature treats `Γ` as a quantity to be *estimated*
from genomic data:

- **Legarra et al. (2015)** introduce metafounders and `Γ`, and note `Γ` relates
  to base-population allele frequencies / `Fst`-like divergence among groups.
- **Garcia-Baccino et al. (2017)** give practical **`Γ`-estimation** methods from
  genomic marker data — including a method-of-moments estimator that regresses
  the genomic relationship matrix `G` onto the pedigree relationship among the
  base/genotyped animals to recover the metafounder (co)ancestries, and related
  generalized-least-squares / summary-statistic variants. This is the canonical
  reference for the estimation gap this plan targets.

Because the supplied-Γ path cannot be used by an analyst who lacks a `Γ`, and
because an arbitrary or mis-specified `Γ` silently biases EBV and variance
components, **supplied-Γ alone cannot be promoted past `partial`**. Γ
estimation closes the usability gap; external validation closes the
correctness-evidence gap.

## Current state (the boundary this plan must not cross)

From contract 27, `docs/design/capability-status.md` (metafounder row), and
`docs/design/validation-debt-register.md` (metafounder row):

- **Supplied-Γ animal model.** `metafounder(1 | id, pedigree = ped,
  group = group, Gamma = Gamma)` fits an experimental, opt-in,
  **supplied-variance** (`sigma_a2`/`sigma_e2` required) animal-only `A^Γ`
  bridge at **dense/validation scale**, via the Julia-owned
  `metafounder_animal_model()`. It is **not** REML estimation.
- **Supplied-Γ single-step `H^Γ`.** `single_step(1 | id, pedigree = ped,
  markers = M, group = group, Gamma = Gamma)` fits an experimental, opt-in,
  **REML-only** `H^Γ` bridge at dense/validation scale via the Julia-owned
  `fit_metafounder_single_step_reml()`.
- **Provenance-only extractors.** `gamma_matrix(fit)` returns the *supplied* `Γ`;
  `metafounder_groups(fit)` returns the *supplied* group assignments. Neither is
  an estimator. `metafounder_effects(fit)` is **reserved/error-only** and returns
  no values.
- **No Γ estimation anywhere.** The Julia twin's own `validation_status.jl`
  (`V1-METAFOUNDER`) states plainly: *"Γ ESTIMATION not implemented (separate
  Fst/base-allele-frequency problem)."*
- **No external comparator evidence.** The same status note records the external
  comparator (Legarra 2015 / García-Baccino 2017; opt-in BLUPF90 preGSf90 /
  GAMMAF90) as **NOT run**, and the single-step row (`V2`) lists Mrode Ch.11
  H/H⁻¹ numbers and an `AGHmatrix::Hmatrix` / BLUPF90 comparator as still
  outstanding.

This plan changes none of the above. It is the route to changing them later.

## Γ-estimation design (engine-owned)

**Lane ownership.** Γ estimation is **Julia-engine (Codex) work.** It consumes
genomic marker data and pedigree relationships and produces an `m × m` matrix —
this is sparse/dense linear algebra and estimation, not R-facing glue. The R
lane's only role is to (a) accept the resulting estimated `Γ` through the bridge,
(b) carry provenance (`gamma_source = "estimated"` vs `"supplied"`), and (c)
expose extractors and status wording. **No R implementation of Γ estimation is
proposed here.**

### Method options (for the engine lane to choose and validate)

- **Option A — method of moments from genomic G on the base/UPG groups
  (García-Baccino et al. 2017).** Recover `Γ` by relating the genomic
  relationship matrix `G` of genotyped animals to the metafounder structure
  implied by their group membership — i.e. solve for the metafounder
  (co)ancestries that make the pedigree-implied base relationships consistent
  with observed `G`. Cheap, closed-form-ish, the field-standard default, and the
  natural first target. Sensitive to marker QC, allele-frequency reference, and
  the genotyped-animal/group mapping.
- **Option B — REML / likelihood-based estimation of `Γ`.** Treat the entries of
  `Γ` (or a low-dimensional parameterization of it) as covariance parameters and
  estimate them jointly with `σ_a²`/`σ_e²` by REML. More principled and
  uncertainty-aware, but markedly heavier, with identifiability and
  positive-(semi)definiteness constraints on `Γ` that the optimizer must respect.
  A later target, not the first.

Both options are **proposals for the engine lane**; neither is endorsed as
correct here. Selection, derivation, and validation belong to Noether/Gauss/
Fisher on the Julia side, anchored by Mrode/García-Baccino.

### Inputs / outputs (contract the bridge must carry)

- **Inputs:** genotyped-animal marker matrix `M` (or a genomic relationship
  matrix `G`), the `id → metafounder-group` assignment (`group_of`, aligned to
  normalized pedigree IDs), the pedigree, an allele-frequency / centering
  reference policy, and marker-QC parameters.
- **Outputs:** an estimated symmetric `m × m` `Γ` on the relationship scale;
  provenance metadata (`gamma_source = "estimated"`, method tag, reference
  policy); and, for Option B, an estimate of the sampling uncertainty of `Γ`.
- **Constraints:** estimated `Γ` must be symmetric and pass the same
  finiteness / symmetry / PSD (or PD where the inverse path needs it) guards the
  supplied path already enforces (contract 27 §2; twin `_validate_gamma`).

### What the R lane carries (no R estimation)

The bridge payload (contract 27 §3) already transports `Gamma` and
`metadata$gamma_source`. The only planned change is to allow
`gamma_source = "estimated"` and an accompanying method/reference tag once the
engine returns an estimated `Γ`. The R parser would gain a *gated* path that
requests engine-side Γ estimation instead of requiring a user-supplied `Gamma`;
the exact formula/control surface for that request is deferred to a Boole
formula-contract slice and is **not** specified here.

## External validation target

Two complementary legs, each with an explicit scope of what it can validate.

### Leg 1 — Mrode (2014) Ch.11 metafounder worked example (anchor)

Use the metafounder worked example in Mrode (2014), *Linear Models for the
Prediction of Animal Breeding Values* (3rd ed.), Ch.11, as a **textbook anchor**
for the **supplied-Γ construction and BLUP**, in the same spirit as the existing
Mrode pedigree-`A`/`A⁻¹` canon (`docs/design/04-validation-canon.md`). The
example fixes a small pedigree, a group structure, and a `Γ`, and reports the
resulting `A^Γ` (and/or `A^Γ⁻¹`) and breeding values.

What to compare, **elementwise**, against the engine on the *supplied-Γ* path
(this is an anchor for construction, not for Γ *estimation*):

- `A^Γ` entries (and `A^Γ⁻¹` entries) for the published pedigree + `Γ`;
- the combined `[metafounders; animals]` Henderson inverse if the text gives it;
- BLUP/EBV solutions, with metafounders treated per the text;
- the `Γ = 0` reduction to the ordinary Mrode `A` / `A⁻¹` / EBV canon (already
  pinned in the engine; restate as the elementwise tie to the classical anchor).

Tolerances and exact published-number transcription follow the
`validation-canon` discipline: **no numbers typed from memory**; the published
table is transcribed into a fixture with a citation, and the engine output is
matched elementwise to it.

### Leg 2 — software comparator (construction, with a scope caveat)

A software comparator for the *construction* side. **Important scope limit:** the
Julia twin's own `validation_status.jl` (`V1-METAFOUNDER`) records that
**"AGHmatrix/nadiv do not implement metafounder Γ."** Therefore:

- **`AGHmatrix` as an `A` / `H` construction comparator (in scope).**
  `AGHmatrix::Amatrix()` (pedigree `A`) and `AGHmatrix::Hmatrix()`
  (single-step `H`) can validate the **ordinary** relationship/single-step
  construction and the **`Γ = 0` reduction** of `A^Γ`/`H^Γ` — i.e. confirm that
  with no metafounder structure the engine matches an independent, widely used R
  implementation, elementwise.
- **`AGHmatrix::Amatrix(..., metafounder = ...)` as a *metafounder-Γ* comparator
  (UNVERIFIED — do not assume).** The prompt suggests an
  `Amatrix(metafounder=)` argument. Whether current `AGHmatrix` exposes a
  metafounder-`Γ` construction (and whether it matches the Legarra `A^Γ`
  definition the engine uses) is **not confirmed** and is contradicted by the
  twin's status note. This must be **verified against the installed
  `AGHmatrix` version's documentation before being treated as a metafounder
  comparator.** If it exists and matches the definition, it becomes the
  preferred metafounder-Γ construction comparator; if not, the metafounder-Γ
  construction has **no R-package comparator** and Leg 1 (Mrode) plus a
  BLUPF90-family Γ tool (preGSf90 / GAMMAF90) carry the metafounder-specific
  evidence.
- **BLUPF90-family (preGSf90 / GAMMAF90) for Γ estimation (in scope, blocked
  locally).** For the Γ-*estimation* gap specifically, the natural external
  comparator is the BLUPF90 metafounder/`Γ` tooling (preGSf90 / GAMMAF90), per
  the twin status note. This is the only identified external comparator for
  *estimated* `Γ` and is **locally blocked** (see Required tools).

**Elementwise comparison targets** (whichever comparator is in scope):
`A` / `A^Γ` entries, `A⁻¹` / `A^Γ⁻¹` entries, single-step `H` / `H^Γ` entries
(and their inverses), on a matched ID/group order and matched centering /
allele-frequency reference, recorded on the
`docs/dev-log/comparator-runs/TEMPLATE.md` surface.

## R-lane contract changes needed (PLANNED, gated)

All of the following are **planned and gated** — none are to be implemented by
this document.

- **Estimated-Γ provenance.** Allow `metadata$gamma_source = "estimated"` (plus a
  method/reference tag) in the bridge payload (contract 27 §3) and have
  `gamma_matrix(fit)` / `metafounder_groups(fit)` report whether `Γ`/groups were
  **supplied** or **estimated**. These remain provenance reporters; they become
  estimators **only** when the engine returns an estimated `Γ`, and even then
  `gamma_matrix()` reports the value, not an inference object.
- **`metafounder_effects()` activation criteria.** Keep `metafounder_effects()`
  reserved/error-only until **all** hold: (1) the engine returns *explicit
  combined-system metafounder solutions* (the metafounder levels of the
  augmented MME), not merely animal EBVs from `inv(A^Γ)`; (2) the result shape
  for those solutions is pinned in the engine contract; and (3) at least Leg 1
  (Mrode anchor) passes for the configuration that produces them. Until then it
  errors with a message naming the unsupported extractor and the supported
  provenance extractors.
- **Estimated-Γ extractor (new, gated).** When Γ estimation lands, add a
  provenance/diagnostic extractor for the *estimated* `Γ` and (Option B only) its
  uncertainty — name to be set in the activation slice (candidate:
  `gamma_matrix(fit)` continues to return the matrix and gains a
  `source`/`method` attribute, rather than introducing a parallel extractor).
  Not added here.
- **Status-row updates (only after evidence).** The metafounder rows in
  `capability-status.md` and `validation-debt-register.md` would gain an
  estimated-Γ sub-entry and/or a comparator-evidence note **only after** the
  corresponding gate below is met. No row is edited by this plan.

## Validation gates for promotion

The metafounder / `H^Γ` surface stays **`partial`** until the relevant gate is
met. Gates are independent: construction evidence does not promote estimation,
and vice versa.

1. **Supplied-Γ construction anchored.** Leg 1 (Mrode Ch.11) passes elementwise
   for `A^Γ` / `A^Γ⁻¹` / EBV on the supplied-Γ path, with a cited transcribed
   fixture. Promotes only the *supplied-Γ construction* claim.
2. **Supplied-Γ construction comparator.** An in-scope software comparator
   (Leg 2) agrees elementwise — at minimum the ordinary / `Γ = 0` reduction via
   `AGHmatrix`, and the metafounder-Γ construction via whichever comparator is
   confirmed in scope. Recorded via the comparator-run template with Rose /
   Fisher / Curie verdicts.
3. **Γ estimation validated.** An estimated `Γ` from the chosen engine method
   (Option A first) matches a BLUPF90-family Γ tool (or the published
   García-Baccino numbers) within a stated tolerance, on a shared fixture.
   Promotes the *Γ-estimation* claim only.
4. **`metafounder_effects()` activation.** The three activation criteria above
   all hold; only then does the extractor return values.

No gate is met today.

## Required tools and blocker

- **Host class.** Local Mac host. Both external comparators required for
  metafounder-specific evidence are **unavailable locally**:
  - **BLUPF90-family executables are ABSENT** from PATH (confirmed
    2026-06-22): `renumf90`, `airemlf90`, `blupf90`, `remlf90`, `gibbsf90`
    all absent. The metafounder/Γ tools (preGSf90 / GAMMAF90) are part of this
    family and are therefore also unavailable. This blocks Gate 2's
    metafounder-Γ leg and Gate 3 entirely on this host.
  - **`AGHmatrix` R package is ABSENT** locally (confirmed 2026-06-22:
    `requireNamespace("AGHmatrix")` is FALSE). This blocks the `AGHmatrix`
    construction comparator (Gate 2's ordinary / `Γ = 0` leg) until installed,
    and the `Amatrix(metafounder=)` capability cannot even be *verified* without
    it.
- **Action.** Record these as a blocker report under
  `docs/dev-log/comparator-runs/` (mirroring the existing
  `2026-06-21-marker-scan-tool-availability.md` and
  `2026-06-21-multivariate-tool-availability.md` blocker reports) before any
  comparator gate is attempted. A blocker report is **not** evidence.

## Claim boundary

- **Plan only.** This document plans Γ estimation and external validation; it
  implements neither and validates nothing.
- **`Γ` is SUPPLIED today, not estimated.** No estimated `Γ` exists in either
  lane.
- **No `metafounder_effects()` values.** The extractor stays reserved/error-only.
- **No external comparator evidence exists** for `A^Γ` / `H^Γ` (supplied or
  estimated). No Mrode Ch.11 metafounder numbers and no software-comparator
  numbers have been produced.
- **Engine-owned.** Γ estimation and `H^Γ` are Julia-engine (Codex) work; this
  is the R-lane contract + validation route, not an R implementation.
- **Comparator caveat.** `AGHmatrix`/`nadiv` are **not** known to implement
  metafounder `Γ` (twin `V1-METAFOUNDER` status); any use of
  `AGHmatrix::Amatrix(metafounder=)` as a metafounder comparator is unverified
  and must be checked against the installed version before it is trusted.
- **No promotion.** No capability, validation-debt, or public-claim status
  changes. The metafounder / `H^Γ` surface remains `partial`.

## References

- Legarra, A., Christensen, O. F., Vitezica, Z. G., Aguilar, I., & Misztal, I.
  (2015). Ancestral relationships using metafounders. *Genetics*, 200(2),
  455–468.
- Garcia-Baccino, C. A., Legarra, A., Christensen, O. F., Misztal, I., Pocrnic,
  I., Vitezica, Z. G., & Cantet, R. J. C. (2017). Metafounders are related to
  Fst fixation indices and reduce bias in single-step genomic evaluations.
  *Genetics Selection Evolution*, 49, 34. (Γ estimation.)
- Mrode, R. A. (2014). *Linear Models for the Prediction of Animal Breeding
  Values* (3rd ed.). CABI. Ch.11 (metafounder worked example; validation
  anchor — exact numbers to be transcribed, not cited from memory).
