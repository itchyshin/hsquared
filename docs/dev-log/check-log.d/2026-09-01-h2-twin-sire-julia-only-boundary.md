# check-log — 2026-09-01 h2-twin `sire_model_fitted_target` documented Julia-only boundary

**Arc:** B3 barrier condition **C2**, in its *boundary-note-committed* form
**Lane:** `claude/lane-h2-twin-20260901` @ `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Trigger:** `~/local-scratch/h2-b3-barrier-packet.md` §4 C2; Rose scrub B3 C2 residue
**Launch receipt:** `~/local-scratch/h2-overnight-pass3-launch-receipt.md`

## The gap

`sire_model_fitted_target` is the one comparator target of seven with no R mirror.
The A11 harness reports **6 agree / 0 drift / 1 not mirrored**, and the "1" had no
written explanation anywhere — a silent gap in a harness whose whole selling point
is 0 silent skips.

## What was measured first

| Lane | Finding |
|---|---|
| Julia | `test/fixtures/sire_model_fitted_target/` holds 9 committed files (README, `generate.jl`, `pedigree.csv`, `phenotypes.csv`, 5 `expected_*.csv`); harness validates and digests them |
| R | `tests/fixtures/comparator_targets.toml` carries `r_mirror = false`, empty `r_fixture_path`; `comparator_fixture_shas.csv` freezes **no** bytes for it |
| R | `tests/testthat/test-mrode-sire-anchor.R` exists and is **NOT** this mirror — it is a *supplied-variance* Mrode Example 3.2 anchor, so it cannot corroborate a target defined by a REML-*estimated* sire variance |
| Ledger | `V1-SIRE-FIT` is **partial**; no parsed public R sire-model formula path exists |

That third row is the one worth having measured: a reader scanning file names would
reasonably conclude the R lane already covers the sire model.

## What changed

| File | Change |
|---|---|
| `docs/dev-log/comparator-runs/2026-09-01-sire-julia-only-boundary.md` | **new** — the boundary note: what exists per lane, why the harness still says `gap`, the two acceptable outcomes with the argument for each, what stays open |
| `tests/fixtures/comparator_targets.toml` | `sire_model_fitted_target` boundary: "no R fixture mirror **yet**" → documented Julia-only boundary + note path + the "documented is not discharged" caveat + the anchor-is-not-a-mirror warning |

Julia-lane counterparts (same slice, other worktree): `comparator/README.md` gains a
"The one Julia-only target" subsection; `comparator/run_targets.jl` emits a
`boundary_note` field pointing at the note; `test/fixtures/comparator_targets.toml`
gets the matching boundary text.

## What was deliberately NOT done

- **The owner decision is not made.** Ask `#sire-mirror` — mirror the fixture, or
  make the Julia-only boundary permanent — is left open, with the argument for each
  side written down so it need not be re-derived. C2 offered "mirror+freeze **or**
  Julia-only boundary note committed"; this is the latter, and it deliberately does
  not foreclose the former.
- **No R fixtures were invented.** Fabricating a mirror to tidy a harness count is
  the exact failure the boundary is written to prevent.
- **The `gap` verdict was NOT softened to `validated`.** `--strict` still exits
  non-zero. Documenting a boundary and discharging a debt are different acts, and a
  harness reporting `validated` here would assert cross-lane agreement nobody has
  measured.
- **B3 is not marked done.** C1 (Darwin's A13 sign-off) is still open regardless, so
  B3 stays **partial**.

## Commands and outcomes

```sh
julia --project=. comparator/run_targets.jl   # exit 0; 7 targets; 6 agree / 0 drift / 1 not mirrored
                                              # sire_model_fitted_target: gap (as intended),
                                              # boundary_note now present in manifest.json
Rscript -e 'testthat::test_local(filter = "comparator")'   # see outcome below
```

Contract-test compatibility checked before editing: the R manifest test asserts
`expect_match(target$boundary, "no|not")` for every target and
`expect_identical(sire$r_mirror, FALSE)`. The new wording keeps both true, and
`r_mirror` was not touched.

## Still open

- Owner ask `#sire-mirror` (the decision above).
- The **same-estimand REML sire-model comparator** — an R-lane `nadiv`/`pedigreemm`
  fit of the same serialized data, or a published estimated-VC sire target with
  versions and tolerances. This is the substantive debt and neither outcome above
  touches it.
- `heritability()` documented as mislabelled for sire specs.
- `V1-SIRE-FIT` stays **partial**; `public_covered_count` stays **5**.
