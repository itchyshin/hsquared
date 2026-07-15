# After-task report — Retry-6 terminal route blocker and seed-free repair

## 1. Goal

Run Retry-6 D0F only after every admission gate was green, adjudicate fail
closed, and open D1 only after formal D0F `PASS/COMPLETE`.

## 2. Implemented

All three 576-row D0F routes completed. The first receipt writer exposed a
summary route-binding defect before writing any receipt, so the full root and
seed spaces were retired. D0F/D1 route threading, mutation tests, executable
seed retirement, status evidence, and a handover were added prospectively.

## 3a. Decisions and Rejected Alternatives

No repair-in-place, subset adjudication, pooled summary, manual receipt, D1,
or seed reuse was allowed. The synthetic repair cannot adjudicate Retry 6.

## 4. Files Touched

Route-aware preseal/recompute helpers and tests, recomputer sidecar, seed lock
and tests, doc 49, capability/coordination evidence, checkpoint, check log,
after-task report, and handover. The two H2-2 Retry-5 drafts remain unstaged and
untouched.

## 5. Checks Run

- Totoro official/base-R/Julia inventories: 576/576/576 complete.
- R recovery-v3 family: 822 pass, 0 fail, 0 warn, 0 skip.
- Seed-lock focused tests: 60/60 pass.
- Driver, adjudicator, admission, preseal, and seed-lock selftests: pass.
- Recomputer sidecar and `git diff --check`: pass.
- Exact-head CI and final package checks are recorded at closeout.

## 6. Tests of the Tests

D0F and D1 Julia rows fail under the ordinary default, pass only under
`julia_profile_replay`, and fail with an R driver commit. Seed mutations reject
all retired Retry-6 phenotype/bootstrap seeds and the tests require that no
proposed D0F stage exists.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| Julia route dropped during summary reconstruction | Fixed prospectively for D0F and D1; Retry 6 retired. |
| Retry-6 seeds remained labelled proposed | Entire phenotype/bootstrap spaces moved into the executable historical lock. |
| H2-2/task ownership ambiguity | H2-2 archived; this task is sole lane; durable memory note written. |
| Stale local selftest filename | Corrected to live filenames; product suite was already green. |
| Full-suite validation fixture lost its test-only helper | Added a defensive local helper load; the fixture already passed alone and no package behavior changed. |

## 8. Consistency Audit

Both D0F and D1 paths, seed registry, twin status surfaces, Totoro freeze/process
state, capability count, and handover were checked. Retired roots and the Julia
quarantined scaffold were not modified.

Memory receipt: `/ask-brain` was used for the lane-history question. `route.py`
found no repo LOAD-FIRST manifest, so repo files remained technical truth. The
Golden Set was not run because no memory-retrieval regression was diagnosed.

## 9. What Did Not Go Smoothly

The defect appeared after 1,728 valid evidence rows because admission retained
the route but a later helper silently defaulted it. One chained local check
used a stale driver filename after the initial route-only suite had passed. A
first full-suite rerun then correctly exposed stale prospective-seed assertions;
after those were made historical, the last validation fixture exposed a
test-helper order dependency and was hardened.

## 10. Known Residuals

Retry 6 has no formal adjudication. D1-D4, final Rose activation audit, G10,
merge, release, and activation remain outstanding. No successor contract or
seed allocation exists. Final exact-head CI is still required.

## 11. Team Learning

Thread route provenance through every summary layer, and retire a terminal
root's whole reserved seed spaces in executable code. Codex-created handover
tasks also need explicit naming and archival/ownership notice.

## 12. Cross-Product Coverage

This covers D0F/D1 summary route binding and Retry-6 seed retirement. It does NOT cover
Retry-6 adjudication, recovery, D1-D4 execution, default routing,
capability promotion, production genomic fitting, G10, merge, release, or a
`public_covered_count` change.
