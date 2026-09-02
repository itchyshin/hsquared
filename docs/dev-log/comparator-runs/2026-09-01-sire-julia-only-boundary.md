# `sire_model_fitted_target` — Documented Julia-Only Boundary

Date: 2026-09-01

## Purpose

Record, explicitly and in both lanes, that the `sire_model_fitted_target`
comparator fixture exists **only in the Julia lane** and has **no R mirror**.

This closes H² twin Block 1 barrier condition **B3 C2** in its
*boundary-note-committed* form: the one unmirrored comparator target is now a
**documented** Julia-only boundary rather than a silent gap in a 7-target
harness that otherwise reports full cross-lane byte parity.

**It does not decide whether the mirror should eventually be built.** That is
owner ask **#sire-mirror**, and it is open — see "The Open Decision" below. This
note asserts the *current* boundary and makes it auditable; it is not a
permanence claim.

This note is **boundary evidence, not comparator evidence.** It promotes nothing.
`V1-SIRE-FIT` stays **partial**, and `public_covered_count` stays **5**.

## Scope

| | |
| --- | --- |
| Target id | `sire_model_fitted_target` |
| Julia issue | `itchyshin/HSquared.jl#16` |
| Ledger row | `V1-SIRE-FIT` — **partial**, "fitted sire-model native target (Mrode Ch.4)" |
| Estimand | sire model (record→sire incidence, sires-only `Ainv`) with REML-estimated sire variance |

## What Exists, Per Lane

**Julia lane — the fixture and a self-consistency pin.**

`HSquared.jl/test/fixtures/sire_model_fitted_target/` holds nine committed
files: `README.md`, `generate.jl`, `pedigree.csv`, `phenotypes.csv`, and the
five `expected_*.csv` targets (variance components, `beta`, EBV, reliability,
metadata). The unified harness (`comparator/run_targets.jl`) validates their
integrity and digests them like every other target.

**R lane — nothing mirrored, and one thing that is easy to mistake for a mirror.**

- `tests/fixtures/comparator_targets.toml` carries the target with
  `r_mirror = false` and an empty `r_fixture_path`, and
  `tests/fixtures/comparator_fixture_shas.csv` freezes **no** bytes for it.
- `tests/testthat/test-mrode-sire-anchor.R` exists and is **not** this mirror.
  It is a **supplied-variance** published anchor (Mrode Example 3.2): variance
  components are given, not estimated. It cannot corroborate a target whose
  whole point is a REML-**estimated** sire variance.

## Why the Harness Calls It a `gap`, and Why That Stays

`adapter_sire_model_fitted_target` in `comparator/run_targets.jl` reports
`status = "gap"` when the R mirror is absent, deliberately: for this one target
an absent mirror is a tracked item rather than a neutral observation. This note
does **not** soften that verdict to `validated`.

That distinction matters. Documenting a boundary and discharging a debt are
different acts, and a harness that reported `validated` here would be asserting
cross-lane agreement that has never been measured. `julia
comparator/run_targets.jl --strict` therefore still exits non-zero, and should.
What changes is only that the gap now resolves to a written boundary instead of
to nothing.

## The Open Decision (owner ask #sire-mirror)

Two acceptable outcomes, and this note picks neither:

1. **Mirror it.** Copy the serialized fixture into the R lane, freeze its bytes
   in `comparator_fixture_shas.csv`, flip `r_mirror = true`, and let the
   existing cross-lane byte-parity check cover it as it covers the other six.
2. **Make the boundary permanent.** Declare the sire target Julia-engine-only by
   design — there is no parsed public R sire-model formula path, so there is
   nothing on the R side for a mirrored fixture to exercise beyond byte
   equality — and record it as a standing boundary rather than debt.

Argument for (2), recorded so the decision is not re-derived from scratch: the
mirror's only current value is byte equality, because the R lane has no sire
route to fit the mirrored data with. Argument for (1): every *other* target is
mirrored, so the asymmetry is itself a maintenance cost, and a mirror is cheap
insurance if an R sire route is ever built.

**No R fixtures were invented for this note.** Fabricating a mirror to make a
harness count look tidy is precisely the failure this boundary is written to
avoid.

## What Remains Open (unchanged by this note)

- Owner ask **#sire-mirror** — the mirror-vs-permanent-boundary decision above.
- The **same-estimand REML sire-model comparator** — an R-lane `nadiv` /
  `pedigreemm` fit of the *same* serialized data, or a published estimated-VC
  sire-model target with versions and tolerances. Still the substantive debt on
  `V1-SIRE-FIT`, and untouched by either outcome above.
- The engine `heritability()` accessor is documented as **mislabelled for
  sire-model specs**; the fixture stores the corrected
  `h2 = 4 sigma_s2 / (sigma_s2 + sigma_e2)`.
- No parsed public R sire-model formula path exists.
- `V1-SIRE-FIT` status remains **partial**.
