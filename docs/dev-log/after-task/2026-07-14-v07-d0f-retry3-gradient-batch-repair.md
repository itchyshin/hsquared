# After-task report — v0.7 D0F retry-3 gradient and batch repair

## 1. Goal

Retire the unadjudicable retry-3 root honestly and prepare a fresh, disjoint
retry-4 whose successful R fits expose a finite solver diagnostic and whose
independent R and Julia replay stages can resume safely without rescanning the
entire 576-row corpus once per seed.

## 2. Implemented

The R bridge now carries the boundary AI score norm into
`diagnostics$gradient_norm`. The official driver treats a missing or nonfinite
value on a successful fit as an infrastructure contract error before publishing
an attempt or packet, and post-run admission checks the same invariant.

Retry-3 phenotype and bootstrap seeds are retired. Retry-4 uses disjoint bases
`2036000000` and `2037000000`. Base-R recomputation and Julia replay now use
external, hash-bound, deterministic batch plans; authenticate the complete
corpus once per batch; reauthenticate every row's attempt and five packet files;
precheck every target; accept only a complete resumable prefix; and preserve
create-once evidence outputs.

## 3a. Decisions and Rejected Alternatives

Retry-3 was not salvaged because its preseal binds attempts with
`gradient_norm=NA` and zero Julia replay rows. Editing those attempts, relaxing
the Julia validator, or treating provisional base-R summaries as recovery would
break the preregistered three-route chain. Per-seed full-corpus rescans were
also rejected because they caused avoidable operational exposure without
strengthening the scientific contract.

## 4. Files Touched

The Julia bridge adapter, recovery driver, preseal validator, seed lock,
base-R recomputer, launcher, doc 49, their focused tests, tool sidecars, and
this report. The Julia twin owns its replay batching implementation and the
durable retry-3 blocker checkpoint.

## 5. Checks Run

Focused driver, preseal, launcher, recomputer, tooling, seed-lock, and
downstream-contract tests pass. The complete R test suite has no failures from
this slice; the documented source-runner helper residual passes in isolation.
The authoritative built-package `R CMD check --no-manual` is `Status: OK`,
including package tests and rebuilt vignettes. Live R-to-Julia genomic tests,
exact sidecars, shell syntax, launcher selftest, and diff checks pass. The Julia
twin replay selftests, full `Pkg.test()`, Documenter build, and preamble cap pass.

## 6. Tests of the Tests

The gates turn red for missing, `NA`, `NaN`, infinite, or vector-valued AI
score norms; a retired or duplicated seed; a batch with duplicate, unknown,
reversed, or incomplete membership; a plan inside the evidence root; a mutated
locked input; a partial output pair; a non-prefix resume; a scientifically
changed completed replay; and a child-process failure.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| Retry-3 successful attempts stored `gradient_norm=NA` | Surface the exact boundary AI score norm and fail before publication if it is not one finite scalar. |
| Retry-3 had no Julia replay rows | Preserve it as an infrastructure-blocked, unadjudicated root. |
| Retry-3 seeds had been observed | Retire all 576 phenotype and three bootstrap-index seeds. |
| Independent replay rescanned 3,457 locked files for every seed | Authenticate once per bounded batch and retain the corpus digest map. |
| Interrupted batches needed safe restart | Admit only complete prefixes and freshly revalidate their deterministic scientific fields. |
| External scheduling state could contaminate evidence | Keep create-once batch plans outside the evidence root and bind them to root, stage, manifest, preseal, and corpus hashes. |

## 8. Consistency Audit

The sweep covered both twins, the retry-3 Totoro root and process state, seed
spaces, bridge result shape, driver failure semantics, preseal admission,
sidecars, batch membership, resume behaviour, shell propagation, doc 49,
capability wording, and the held activation boundary. Repository and executable
evidence remained authoritative. No retrieval gap required a Golden Set run.

## 9. What Did Not Go Smoothly

Retry-3 completed all official and base-R rows before the missing diagnostic
blocked the first Julia replay. During this repair, the first Julia selftest was
invoked without the preregistered one-thread BLAS environment and failed as
designed; it passed after the environment was pinned. A source-tree R suite run
also observed a sidecar while that sidecar was being updated; the affected file
passed immediately in isolation and the clean built-package check passed.

## 10. Known Residuals

Exact repair commits, five fresh preseal reviews, clean Totoro deployment,
retry-4 preseal/preflight, official D0F execution, three-route adjudication, D1,
conditional D2-D4, final Rose review, and G10 remain outstanding. The held
default route is not activated.

## 11. Team Learning

Diagnostics used by evidence gates are part of the public bridge contract even
when they are not user-facing. Batch optimization is admissible only when it
preserves exact corpus authentication, row-level reauthentication, deterministic
membership, and create-once outputs.

## 12. Cross-Product Coverage

This slice repairs the Gaussian-REML genomic recovery harness and its exact
R-to-Julia diagnostic/replay contract. It does NOT cover recovery, default-route
activation, ML or non-Gaussian genomic models, additional random effects,
alternative relationship constructions or ridge values, production scale,
capability promotion, or a change to `public_covered_count` from 5.
