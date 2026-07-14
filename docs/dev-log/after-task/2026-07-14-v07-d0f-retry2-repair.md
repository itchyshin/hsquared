# After-task report — v0.7 D0F retry-2 blocker and prospective retry-3 repair

## 1. Goal

Preserve the second failed D0F evidence root without post-hoc replay, repair
the Julia command-construction defect prospectively, retire every consumed seed,
and freeze the downstream D2-D4 contract before any D1 or D2 seed is opened.

## 2. Implemented

The exact retry-2 root, preseal, corpus lock, base-R summary, replay commit, and
zero-row replay outcome are recorded as an unadjudicated infrastructure
blocker. The Julia replay tool now constructs concrete `String` command vectors
and tests the exact `SubString` Git-root case. The retry-2 phenotype/bootstrap
spaces are retired; retry 3 uses bases `2034000000` and `2035000000`.

The downstream R contract now freezes distinct official, base-R, and Julia
schemas; exact scientific projections; ordered D2 history; terminal D3/D4
history; count and Wilson identities; exact tree/receipt/reviewer bindings;
canonical file/sidecar paths; Git blob, HEAD, ancestry, clean-tree, and
unchanged-implementation checks; and low-convergence precedence.

## 3a. Decisions and Rejected Alternatives

Post-hoc replay of retry 2, seed reuse, pooling either blocked corpus, threshold
changes, and treating a replay-tool exception as estimator evidence were
rejected. D1 remains barred until a fresh D0F root is independently recomputed,
replayed, reviewed, and adjudicated `PASS`/`COMPLETE`.

## 4. Files Touched

Doc 49; the downstream-contract tool, sidecar, and direct tests; seed-lock and
preseal tests; the seed-lock helper; the Julia stage-replay tool and sidecar;
and the repo-visible checkpoint, check log, coordination, and phase pointers.
The untracked Julia downstream-replay file remains an incomplete scaffold and
is not part of this repair or any evidence claim.

## 5. Checks Run

- R downstream selftest: PASS.
- Seed-lock selftest: PASS, 39,751 historical/retired and 92,304 possible v3
  seeds.
- Focused R tooling: 52/52 PASS.
- Focused R preseal: 218/218 PASS.
- Focused R downstream contract: 156/156 PASS.
- Julia stage-replay selftest: PASS.
- Full Julia `Pkg.test()`: PASS.
- Built-package `R CMD check --no-manual`: 0 errors, 0 warnings, 0 notes.
- `air format` applied to the edited R scripts/tests; all focused checks rerun.
- R and Julia SHA-256 sidecars: exact.
- Both `git diff --check` gates: PASS.
- Fisher, Grace, and Noether final independent reviews: `CLEAN` after the
  deployed-HEAD and unchanged-implementation hardening pass.

## 6. Tests of the Tests

Mutations turn red for `SubString` command construction, retired-seed overlap,
bootstrap overlap, malformed sidecar filename/bytes, file and root symlinks,
changed Git blobs, stale deployed HEAD, changed fitted implementation surfaces,
wrong reviewer identity, stale driver commit, broken count identities, forged
Wilson/boundary fields, duplicated seeds, and nonterminal or skipped history.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| Retry-2 Julia replay failed before row 1 | Retire the whole root and seed spaces; fix prospectively. |
| `Cmd(::Vector{AbstractString})` escaped selftest | Force `String[...]`, return concrete `String`, and test a `SubString` root. |
| Low-success cells became corruption blockers | `<46/48` now stops for low convergence; invariant-nonfinite applies only after the convergence gate. |
| Review files could substitute identities | Fixed filename, reviewer, receipt, and driver commit must all agree. |
| Matching live hash did not prove committed provenance | Require exact blob, deployed HEAD, ancestry, clean tree, and unchanged fitted surfaces. |
| Downstream route schemas were conflated | Separate official/base-R/Julia schemas and compare only the frozen scientific projection. |

## 8. Consistency Audit

The sweep covered both twins, Totoro process/output state, both blocked D0F
roots, all phenotype and bootstrap spaces, D1/D2 consumption, route/scale
provenance, public-count wording, the carried downstream scaffold, and adjacent
receipt/history/file-system bypasses.

## 9. What Did Not Go Smoothly

Retry 2 completed all 576 official fits and all 576 base-R recomputations before
the Julia preflight exposed a command-vector type defect. The first downstream
amendment also required three review/fix cycles: route provenance, scientific
low-convergence precedence, reviewer identity, canonical paths, and deployed
Git state each exposed a neighbouring fail-open condition.

## 10. Known Residuals

Retry 3 is not yet committed, presealed, or run. The dedicated operational R
downstream recomputer and Julia downstream replay remain to be completed. D1,
D2, D3, D4, final adjudication, Rose audit, and G10 remain outstanding.

## 11. Team Learning

Preflight code is experimental machinery. Synthetic tests must reproduce live
runtime types, and provenance must bind not only bytes and commit objects but
the deployed HEAD and unchanged fitted implementation surfaces.

## 12. Cross-Product Coverage

This slice repairs evidence machinery only. It does NOT cover recovery,
default R routing activation, capability promotion,
`public_covered_count = 5`, release either package, or authorize G10.
