# Check log — v0.7 genomic recovery-v3 operational R harness

Date: 2026-07-13

## Scope

Operationalize the frozen D0F/D1 generator, independent base-R recomputation,
adjudication, and Totoro/DRAC launcher without consuming any official seed.

## Source hashes before commit

- doc 49: `9bf45e555230e6ae423067dfbe703dfcdf69dee9dbd82b5f43f13896b1b51b90`
- pure preseal helper: `d24e53f667db47b27e1185db01869bada3c804c775f66e1850987794dfbc7e8c`
- official R driver: `8ef9a5a1b2a71a4b49933d7acfaf2cc18177e59b070ac541cfffc4743b410ee0`
- independent base-R recomputer: `a71a92e6abc69cdb851644ef12c71b0d567d20a76edd5ede2f4226ef763534f9`
- frozen D0 base-R recomputer: `3e1892f336d218782d9b0b1e0ef449329adf33d59298e5c0b3f25be64839dc01`
- process launcher: `e87b425adfa48d493a8f4d314ec8966c30c5ec0622a41837e5480b14dff97de1`
- Julia replay tool: `c8b4d2ceb4c01f807efa610002763fc1f5416c35a666427975a7f7972a3b0826`

## Checks

- Official R driver selftest: PASS, synthetic only.
- Independent base-R recomputer/adjudicator selftest: PASS.
- Pure preseal selftest: PASS.
- Julia replay selftest: PASS, synthetic only.
- Launcher Bash syntax and executable guard selftest: PASS on Bash 3.2.57.
- Direct official R, base-R recomputation, and Julia replay compute guards:
  Totoro/live numeric-SLURM admitted; CI/GitHub/login-node mutations rejected.
- Focused driver tests: PASS, 67 expectations at the final Hopper audit.
- Focused launcher tests: PASS, 49 expectations at the final Grace audit.
- Focused preseal and recomputer files: PASS with no failure, warning, skip, or
  extracted `_problems`; the recomputer includes D0F and synthetic final-tree
  positive paths plus the native-hash regression.
- Full R `devtools::test(reporter = "check")`: exit 0, no `_problems`.
- Full Julia `Pkg.test()`: PASS.
- `git diff --check`: PASS in both twins.
- Clean Totoro selftest initially stopped on raw D0F fixture SHA drift between
  R 4.5.3 and 4.6.0. Direct diff showed only last-bit quantile/SD formatting;
  the frozen exact/`1e-10` typed comparison remained green. The redundant raw
  generated-fixture hash gate was removed prospectively; exact R tool hashes
  remain presealed.

## Tests of the tests

- Public-fit provenance mutation: red.
- Marker, ID, ridge, scale, panel, source, phenotype-seed, attempt, and summary
  mutations: red.
- Extra/missing/partial/symlink/FIFO/nonregular/empty tree members: red.
- Totoro/DRAC admission accepts Totoro and numeric-job allocations; GitHub
  Actions, generic CI, and DRAC login nodes: red.
- Worker cap 9 versus preseal cap 8: red.
- Fifteen-row smoke denominator: red before launch.
- Complete resumable pair: skipped; missing pair: emitted; orphan/symlink/
  nonregular pair: red.
- Failing xargs child: launcher exits nonzero.
- Last-bit-perturbed K/Q hashes differ while K/Q numeric deltas remain within
  `1e-10`; marker/ID identity remains exact.
- Synthetic adjudication writes once, validates the exact final tree, and
  rejects overwrite or receipt drift.

## Independent verdicts

- Hopper driver/bridge audit: CLEAN.
- Grace launcher/reproducibility audit: CLEAN after two repair rounds.
- Fisher contract review: remaining positive D0F/finalization tests applied.
- Noether numerical/preseal audit: CLEAN after the native-hash repair.
- Rose final pre-seed audit: CLEAN after direct-entry guards and stale Julia
  final-adjudicator wording were repaired.

## Boundary

No official D0F/D1 phenotype, fit, packet, replay, summary, adjudication,
recovery evidence, activation, capability move, count change, release, or
GitHub Actions campaign was produced. `public_covered_count` remains 5.
