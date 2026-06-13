# v0.1 Gate Handoff (turnkey)

Date: 2026-06-13. A consolidated, decision-ready snapshot of the v0.1
default-fit gate after an autonomous R-lane run (15 CI-green commits). The
binding rules are in `docs/design/01-v0.1-contract.md` (V0.1 Promotion
Predicate); per-slice detail is in `docs/dev-log/after-task/2026-06-13-*.md`.

The default `hsquared()` fit stays validate-and-stop until the predicate holds.
The R lane has taken every item as far as it can; what remains is twin-engine
work and maintainer sign-offs.

## Predicate status (each item: R-side done · remaining · owner)

| Item | R-side evidence in hand | Remaining to mark covered | Owner |
| --- | --- | --- | --- |
| 1 · `V1-MRODE-FIT` (published estimated-REML target) | Gryphon pure-R recovery atom: published ↔ sommer ↔ hsquared REML agree to 4 dp (`test-validation-fixtures.R`). | Fit the published target through the **engine** and flip the twin row. NB: the raw gryphon pedigree is pathological (ancestral loops; even `nadiv::prepPed` fails) — the engine path must use `A_gryphon` **directly** (supplied-`Ainv` spec), not pedigree→Ainv. | Twin + maintainer (anchor sign-off) |
| 2 · `V1-COMPARATORS` (external agreement) | sommer agreement on the gryphon anchor (committed). | Record an agreement check on **estimated** VC/h²/EBVs within a declared band; flip the twin row. The existing pedigreemm logLik check is a one-sided floor only. | Twin + maintainer (comparator + band) |
| 3 · estimator known-truth recovery | DGP study: engine near-unbiased (0 within bias ± 2·MCSE, 120 reps, 100% conv), EBV acc 0.74, engine == pure-R to machine precision; generality grid h²=0.2/0.4/0.6 (`data-raw/dgp-recovery-study.R`). | Flip the twin estimator row (`V1-SPARSE-REML-OPT`/`V1-AI-REML`) to covered-with-recovery, citing this. | Twin + maintainer (thresholds) |
| 4 · boundary/identifiability | **Surfacing done**: `fit_diagnostics()` + `summary()` `at_boundary` flag; identifiability statement in the contract. | **Engine-stability**: the optimizer returning a boundary-consistent, finite result as h²→0/1 (extend the twin's `sigma_a2 = 0` fixture). | Twin |

Also blocking, separate from the four items:

- **Twin integrity bug** (verified): `HSquared.jl/src/validation_status.jl:97`
  `V1-AI-REML` evidence cites a "250-animal observed-information check" with **no
  backing test** (only an 8-animal optimizer-agreement fixture exists). Fix or
  downgrade the string before any promotion cites that row. Rose blocks
  promotion until resolved.

## The two parties

**Maintainer — three sign-offs** (all backed by committed, verified evidence;
the autonomous run did not pick them):

1. Anchor for `V1-MRODE-FIT` — recommended: gryphon (data in CRAN `enhancer`;
   confirm Wilson 2010 headline numbers).
2. Comparator + agreement band for `V1-COMPARATORS` — recommended: sommer,
   clean-convergence gated; VC ~1–2 %, h² ~0.01–0.02, EBV r > 0.999.
3. DGP-recovery pass thresholds (replicates, bias ± MCSE cap, EBV-accuracy
   floor).

**Twin thread (`HSquared.jl`)** — currently on Phase-2 genomics, not the gate:

- Build `V1-MRODE-FIT` (engine fits the published target via supplied `A_gryphon`)
  and `V1-COMPARATORS` (estimated-output agreement), flip those rows.
- Flip an estimator row to covered-with-recovery citing the R-lane DGP study.
- Boundary-stable optimization at h²→0/1.
- Fix the `V1-AI-REML` evidence string.

## Then: the default flip (R lane, one mechanical slice)

When the twin rows read covered/covered_external and the maintainer signs off:
change the default engine for the v0.1 contract from `validate` to a real fit,
flip `capability-status.md` rows 16/30 and the predicate-named rows together
(Rose blocks any single-document promotion), add integration tests, honesty
pass, CI, Rose audit. The predicate forbids doing this earlier.
