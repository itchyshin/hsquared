# Issue map — live backlog index (both repos)

The single index of the GitHub backlog across `hsquared` (R lane) and `HSquared.jl`
(twin engine). Built 2026-06-19 (WS1 of the post-v0.1.0 program plan). Each issue maps to a
phase, lane, status, and — for R — the closest `capability-status.md` / `validation_status()`
row. **Live `gh issue list` + `validation_status()` win over this table**; refresh it when the
backlog changes.

Honesty rule: an issue's `status:` label must not exceed what `validation_status()` supports.
Only `V1-AI-REML`, `V1-AINV-MRODE9`, `V1-MRODE-FIT`, `V1-COMPARATORS` are `covered`.

## hsquared (R lane) — open

| # | Title | Phase | Type | Status | Capability / validation anchor |
| --- | --- | --- | --- | --- | --- |
| 2 | Define v0.1 R-Julia contract | 1 | bridge/coordinator | covered | v0.1 contract shipped (univariate Gaussian only); Phase 2+ contracts open separate issues, not under this covered label |
| 5 | R fitted object & extractor contract | 1 | r-package | partial | extractor contract; children #11/#12/#21/#22/#23 |
| 6 | R-to-Julia bridge payload design | 1 | bridge | partial | **bridge epic**; children #11–#15, #21–#23 |
| 7 | Validation canon | 1 | validation | partial | mirrors HSquared.jl#7/#41 |
| 8 | R data container: live HSData marshalling parity | 1 | r-package | partial | base `hs_data()` done; mirrors HSquared.jl#8 |
| 9 | Roadmap: genomics/QTL/GLLVM/GPU | 5–8 | roadmap | planned | innovation children #17/#18/#19/#20 |
| 10 | Multivariate validation: comparator & recovery gates | 3 | validation | partial | V4-MULTIVARIATE/V4-MV-REML (partial); twin #41 |
| 11 | Bridge: surface `heritability_interval` (experimental CI) | 1 | bridge | partial · **DONE** | V1-HERIT-CI (partial); shipped `56f8fb5` (experimental extractor) |
| 12 | Bridge: surface `repeatability_interval` | 2 | bridge | partial | V3-REPEAT-REML (partial) — **WS2** |
| 13 | Bridge: REML genomic variants — if on main | 2 | bridge | partial | V2-GREML (partial) — **WS2, Step-0 gated** |
| 14 | Bridge: verify `single_step` routing | 2 | bridge | partial · **DONE (no bug)** | V2-SSHINV; verified correct — supplied-Hinv ssGBLUP via `fit_ai_reml`, not SNP-BLUP |
| 15 | Audit: on-main engine fns vs R surfaces (gap table) | 1 | bridge | partial | **WS2 Step 0** |
| 16 | Docs: verify `eigen_G` wording lives in R repo | 4 | claim-audit | planned | reserved extractor; twin #38 |
| 17 | Innovation: FA-G EM initializer note | 4 | innovation | planned | from `GLLVM.jl/em_fa.jl`; twin #37/#42 |
| 18 | Innovation: Phase 6 LA + VA `method=` note | 6 | innovation | planned | from DRM.jl/GLLVM.jl; twin #40/#44 |
| 19 | Innovation: `mi()`/`miss_control()` grammar | 8 | innovation | planned | `08-missing-data-plan.md`; drmTMB/gllvmTMB |
| 20 | Infra: recurring innovation scout (weekly) | — | innovation/infra | planned | WS3 cadence |
| 21 | Bridge: PEV/reliability as standard fields | 1 | bridge | partial | **WS2 lowest-delta**; twin #43 |
| 22 | Bridge: activate structured mv covariance (FA/low-rank) | 4 | bridge | partial · **blocked** | twin #42; FA core already on `origin/main` (V4-FA partial), gated on twin bridge payload+fixture + failing calibration (PR #17 closed) |
| 23 | Bridge: post-fit `gwas()`/scan wrapper | 5 | bridge | partial · **blocked** | twin #45; Phase 5 engine landed (PR #36) — now gated on post-fit scan payload + thresholds |
| 24 | Innovation: augmented AI-REML single-solve (Strandén 2024) | 8 | innovation/perf | planned | engine-led; twin #58; scout note |
| 25 | Innovation: SQUAREM EM accelerator (engine utility) | — | innovation/perf | planned | engine-led; twin #58; from `GLLVM.jl/em_squarem.jl` |

## HSquared.jl (twin engine) — open

| # | Title | Phase | Status | R mirror |
| --- | --- | --- | --- | --- |
| 5 | Gaussian animal model REML/ML engine | 1 | partial | — (epic) |
| 6 | Engine result object and diagnostics | 1 | partial | hsquared#6 |
| 7 | Julia-side validation canon | 1 | partial | hsquared#7/#10 |
| 8 | HSData input container and bridge parity | 1 | partial | hsquared#8 |
| 37 | [from R] PR #17 calibration: em_fa.jl warm-start; merge? | 4 | partial · cross-lane | hsquared#17/#22 |
| 38 | [from R] reword "250-animal ratio ~0.99" in 03-engine-contract | 1 | cross-lane | hsquared#16 |
| ~~39~~ | [from R] Phase 5 stack merge — **CLOSED** (landed via PR #36) | 5 | done | residual → #45 / hsquared#23 |
| ~~40~~ | [from R] Phase 6 branch — **CLOSED** (fns on main) | 6 | done | residual → #44 / hsquared#18 |
| 41 | [from R] Validation gates R needs (partial→covered) | — | partial · cross-lane | hsquared#10/#7 |
| 42 | Bridge activation: structured mv covariance (FA/low-rank) | 4 | partial · cross-lane | hsquared#22 |
| 43 | Bridge activation: PEV/reliability standard fields | 1 | partial · cross-lane | hsquared#21 |
| 44 | Bridge activation: non-Gaussian LA/VA + MarginalMethod | 6 | partial · cross-lane | hsquared#18 |
| 45 | Bridge activation: post-fit marker scans (GWAS/QTL/eQTL) | 5 | partial · cross-lane | hsquared#23 |
| 58 | [from R] Engine perf ideas (augmented AI-REML / SQUAREM / Woodbury) | 8 | planned · cross-lane | hsquared#24/#25/#17 |

## Cross-lane mirror map

| Topic | R (hsquared) | Twin (HSquared.jl) | Gate |
| --- | --- | --- | --- |
| Structured/FA G | #22 (+ #17 method) | #42 (+ #37 calibration) | twin bridge payload+fixture (#42) + V4-FA calibration; PR #17 closed, FA core already on main |
| PEV/reliability | #21 | #43 | twin payload promotion (lowest-delta) |
| Non-Gaussian LA/VA | #18 | #44 (+ #40) | twin `MarginalMethod` refactor + PR |
| Marker scans | #23 | #45 (+ #39) | Phase 5 stack on main + thresholds |
| 03-engine-contract reword | #16 (R-side eigen_G) | #38 | twin doc edit |
| Validation gates | #10, #7 | #41, #7 | twin recovery/comparator tests |
| HSData marshalling | #8 | #8 | live bridge marshalling |

## WS2 work order — Step 0 DONE (see `docs/design/19-on-main-bridge-gap.md`)

Step 0 (#15) result: `HSquared.jl origin/main` (`4e8ffde`) is at **Phases 1–6** — PR #36 landed
Phase 4B + Phase 5, and Phase 6 non-Gaussian functions are present. **Every WS2 candidate
function is on `origin/main` and exported.** Honesty unchanged (7 covered/external rows; all new
rows `partial`) → R surfaces stay experimental/partial.

- **Class A — R-buildable now** (R calls the exported fn on the returned fit; no twin change):
  #21 (PEV/reliability via `:selinv`, lowest-delta) → #11 (heritability_interval) →
  #12 (repeatability_interval) → #14 (single_step routing) → #13 (REML genomic variants).
- **Class B — gated on a twin result-payload / refactor:** #22 (structured covariance — twin
  exposes loadings/uniqueness in the multivariate payload #42 + V4-FA calibration), #23 (post-fit
  marker scans — twin scan payload #45 + thresholds), #18 (non-Gaussian LA/VA — twin
  `MarginalMethod` refactor #44).

See `docs/dev-log/coordination-board.md` and the program plan for the full workstream design.
