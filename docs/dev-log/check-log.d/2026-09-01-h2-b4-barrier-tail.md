# H2 B4 barrier tail — conditions C1–C4 — 2026-09-01

Scope: closing the four barrier conditions from the Hopper B4 review packet
(`~/local-scratch/h2-b4-barrier-packet.md`) on `claude/lane-h2-twin-20260901`
(scratch worktree). Edits only to files already carried by the three B4 commits
`7193e9a` (A14), `07399a9` (A15), `3dbf486` (A16). No dispatch changes, no new
arcs, no A12 comparator-manifest files.

Lens: Hopper (R↔Julia translator), with Boole / Emmy / Fisher / Rose applied as
review perspectives, not spawned subagents.

## C1 — S2 tolerance replaced with a measured bound

`tests/testthat/test-engine-julia-smoke.R:80` asserted
`max(abs(default_vc - dense_vc)) < 0.5` on a fixture whose total phenotypic
variance is 1.17. Measured the actual delta live (numbers and command in the
A15 shard, `2026-09-01-h2-b4-a15-engine-julia-smoke.md`) and replaced the bound
with a relative VC bound plus h2 and logLik bounds:

- max relative VC delta measured 9.925e-04 → assert `< 5e-3`
- h2 delta measured 5.241e-05 → assert `< 1e-3`
- logLik delta measured 1.299e-08 → assert `< 1e-5`

`tolerance_rule` in `bridge-parity-smoke-status.tsv` changed from the
self-referential `vc_finite_delta_documented` to
`vc_rel_lt_5e-3_h2_lt_1e-3_loglik_lt_1e-5`.

## C2 — non-identity assertion removed

Dropped `expect_false(isTRUE(all.equal(default_vc, dense_vc, tolerance = 1e-8)))`.
It required the two optimizers to *disagree*, so a future sharpening of dense
REML would have turned the test red for a good reason — the same failure class
the Julia twin fixed as a class on 2026-08-04. The "different estimator" intent
is unchanged but now carried where it belongs: structurally, by the surviving
`dense_validation_path` and `target != ai_reml` diagnostics assertions, and in
prose by the `engine_julia_dense_boundary` claim text.

## C3 — `bridge-boundary.tsv` status vocabulary collision

The bare `status` column was undocumented and shared the word `covered` with
`bridge_status`, so `gryphon_live_vignette` read `smoke_status = no_smoke`,
`bridge_status = experimental`, `status = covered`. Renamed to
`boundary_doc_status` with a disjoint vocabulary (`documented` / `partial` /
`planned`), so the column cannot be misread as coverage. All three status
columns are now documented in `docs/dev-log/dashboard/README.md`.

Two new drift guards in `tools/validate-bridge-dashboard.py`:

- `boundary_doc_status` must be one of the three doc values (rejects `covered`)
- `bridge_status = covered` is rejected on a `no_smoke` row

Negative controls run (both fired, tree restored clean afterwards):

```sh
# boundary_doc_status = covered on gryphon row
python3 tools/validate-bridge-dashboard.py
# -> bridge_dashboard_validation_failed
#    gryphon_live_vignette: invalid boundary_doc_status 'covered'   exit 1

# bridge_status = covered on the no_smoke gryphon row
python3 tools/validate-bridge-dashboard.py
# -> bridge_dashboard_validation_failed
#    gryphon_live_vignette: bridge_status covered requires a smoke,
#    but smoke_status is no_smoke                                   exit 1
```

## C4 — after-task reports

One combined report for the three B4 slices:
`docs/dev-log/after-task/2026-09-01-h2-b4-bridge-phase1-after-task.md`.
The campaign-wide after-task gap the packet flagged (A10, A12, B5-A17 also
missing) is **not** closed by this entry and is carried forward.

## Checks run

```sh
python3 tools/validate-bridge-dashboard.py
```

Outcome: **PASS** — `bridge_dashboard_ok schema_rows=10 parity_smoke_rows=11 boundary_rows=10`, exit 0

```r
devtools::test(filter = "engine-julia-smoke")
devtools::test(filter = "bridge-dashboard-contracts")
devtools::test(filter = "bridge-ci-tier0-contracts")
```

| Command | Outcome |
|---------|---------|
| `engine-julia-smoke` (live, `HSQUARED_JULIA_PROJECT` set) | **PASS** — 24 assertions, 0 failures, both S2 and S3 executed live |
| `bridge-dashboard-contracts` | **PASS** — 34 assertions, 0 failures (29 before, +5 from the new vocabulary-disjointness test) |
| `bridge-ci-tier0-contracts` | **PASS** — 20 assertions, 0 failures |

Live smoke command:

```sh
OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 NOT_CRAN=true \
  HSQUARED_JULIA_PROJECT="$HOME/local-scratch/lanes/HSquared.jl-h2-twin-20260901" \
  Rscript -e 'devtools::load_all(quiet=TRUE); devtools::test(filter="engine-julia-smoke", reporter="summary")'
```

## Files touched

- `tests/testthat/test-engine-julia-smoke.R` (C1, C2)
- `tests/testthat/test-bridge-dashboard-contracts.R` (C3 column names + new test)
- `tools/validate-bridge-dashboard.py` (C3 field, enum, two drift guards)
- `docs/dev-log/dashboard/bridge-boundary.tsv` (C3 rename + claim text)
- `docs/dev-log/dashboard/bridge-parity-smoke-status.tsv` (C1 tolerance_rule)
- `docs/dev-log/dashboard/README.md` (C3 status-column documentation)
- `docs/dev-log/check-log.d/2026-09-01-h2-b4-a15-engine-julia-smoke.md` (measured delta)
- `docs/dev-log/after-task/2026-09-01-h2-b4-bridge-phase1-after-task.md` (C4)

## Claim boundary

No `public_covered_count` change. No new fitted capability. CI still never
exercises a live bridge — Tier 0 is fixture-first and Tier 1 remains a disabled
stub, so the measured S2 delta above is maintainer-local evidence, reproducible
only where Julia and a resolvable `HSquared.jl` checkout are present. The
payload-v2 schema stays FREEZE-READY, not RATIFIED, so every dashboard row
remains a seed row.

## Not in scope (carried forward)

- Tier 1 optional Julia CI job enablement (plan Phase 3.2)
- Default `ai_reml` → `fit_payload_v2` fast path (plan Phase 4.1, G3)
- `two_effect` migration to `fit_payload_v2` (plan Phase 4.2, G6)
- README I2 drift on `engine="fit"` vs `engine="julia"` defaults (plan Phase 5.1, G4)
- Campaign-wide after-task backfill for A10, A12, B5-A17
