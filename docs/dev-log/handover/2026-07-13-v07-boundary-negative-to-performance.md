# Handover — R twin v0.7 boundary negative endpoint

## Goal

Keep the explicit genomic R route synchronized while the Julia lane localizes
performance. Do not add default routing or launch R-formula recovery until a
newly preregistered Julia candidate passes a fresh untouched holdout.

## Start Here

1. `docs/dev-log/after-task/2026-07-13-v07-genomic-boundary-holdout.md`
2. `docs/design/capability-status.md` genomic row.
3. `docs/design/validation-debt-register.md` genomic activation row.
4. Julia recovery checkpoint
   `../HSquared.jl/docs/dev-log/recovery-checkpoints/2026-07-13-v07-genomic-boundary-holdout.md`.
5. R PR #136 and Julia PR #273.

## Frozen State

- Branch: `codex/2026-07-12-v07-optimizer-localization`.
- Frozen bridge/oracle: `68e2bd06be0bcc85e9a832e3c0c327bcdc53d3a1`.
- Negative-endpoint evidence: `73b50dc`.
- The explicit experimental route and independent base-R oracle are green.
- Result: 240/240 classifications matched; 30 wins, 0 losses; overall gate
  failed because one Julia candidate/default p95 ratio was 5.99x above a 3x cap.
- The 240 seeds are spent; nine-cell recovery and default activation did not run.
- `public_covered_count` remains 5.

## R Lane Next Action

No R implementation is owed during Julia performance discovery. Once a new
Julia candidate is frozen, rebind the exact Julia commit, rerun the focused
zero-skip genomic live suite and independent oracle, review any payload/runtime
metadata delta, and only then participate in the fresh cross-twin holdout.

## Hard Guards

- Never silently auto-route genomic models through the ordinary default engine.
- Never reuse the opened 240 holdout seeds for a revised candidate.
- Never relabel the genomic relationship-scale ratio as pedigree/population
  heritability.
- No nine-cell recovery, count/status promotion, G10, or release before a new
  conjunctive holdout passes.

## Verification

- Full engine-free suite: 0 failures, 0 warnings, 68 expected skips.
- Commit-pinned live genomic R-Julia suite: 265 pass, 0 fail/warn/skip.
- Focused independent-oracle test: green.
- pkgdown: clean.
- `R CMD check --no-manual`: 0 errors / 0 warnings / 0 notes.
- Fisher/Darwin and Rose audits: `CLEAN`.
- PR #136 CI: green.

## Landing State

This arc is committed, pushed, and in PR #136. The landing gate also reports
older unrelated local branches with commits on no remote. They were not touched
or interpreted here and are **CARRIED-OVER / ownership unknown**:

```text
codex/a3-fit-time-plot-data
codex/genomic-target-fixture-mirror
codex/hsdata-live-marshalling
codex/innovation-issues-24-25-sync
codex/issue-10-body-sync
codex/issue-22-body-sync
codex/issue-23-body-sync
codex/issue-23-scan-sync
codex/issue-5-6-body-sync
codex/issue-5-extractor-sync
codex/issue-6-bridge-parent-sync
codex/issue-7-body-sync
codex/issue-9-roadmap-sync
codex/issue-map-close-19
codex/issue-map-close-2
codex/issue-map-close-20
codex/issue-map-close-21
codex/issue-map-close-8
codex/julia-138-mrode-sync
codex/julia-139-mrode31-sync
codex/julia-140-genomic-target-sync
codex/julia-141-pev-map-sync
codex/julia-147-validation-sync
codex/julia-148-extractor-mirror-sync
codex/julia-149-parent-ledger-sync
codex/julia-150-innovation-gate-sync
codex/julia-151-blupf90-packet-sync
codex/marker-scan-payload-fixture
codex/marker-scan-tool-availability
codex/metafounder-animal-supplied-bridge
codex/metafounder-hgamma-payload-gate (2 commits)
codex/metafounder-single-step-contract
codex/mi-miss-control-contract
codex/mv-published-target-scout
codex/pev-reliability-standard-fields
codex/public-claims-gwas-reconcile
codex/status-ledger-sync-144-143
codex/structured-diagonal-doc-reconcile
docs/2026-07-09-claude-handover (2 commits)
```

All unannotated branches above had one unpushed commit at the gate. Resume only
through a separate ownership/reconciliation audit; do not delete them as part
of this genomic arc.
