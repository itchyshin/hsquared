# Issue map — live backlog index (both repos)

The single index of the GitHub backlog across `hsquared` (R lane) and `HSquared.jl`
(twin engine). Refreshed 2026-06-21 from live `gh issue list` output. Each issue maps to a
phase, lane, status, and — for R — the closest `capability-status.md` / `validation_status()`
row. **Live `gh issue list` + `validation_status()` win over this table**; refresh it when the
backlog changes.

Honesty rule: an issue's `status:` label must not exceed what `validation_status()` supports.
Only `V1-AI-REML`, `V1-AINV-MRODE9`, `V1-MRODE-FIT`, `V1-COMPARATORS` are `covered`.

## hsquared (R lane) — open

| # | Title | Phase | Type | Status | Capability / validation anchor |
| --- | --- | --- | --- | --- | --- |
| 5 | R fitted object & extractor contract | 1 | r-package | partial | extractor contract; children #11/#12/#21/#22/#23 |
| 6 | R-to-Julia bridge payload design | 1 | bridge | partial | **bridge epic**; children #11–#15, #21–#23 |
| 7 | Validation canon | 1 | validation | partial | mirrors HSquared.jl#7/#41 |
| 9 | Roadmap: genomics/QTL/GLLVM/GPU | 5–8 | roadmap | planned | innovation children #17/#18/#19/#20 |
| 10 | Multivariate validation: comparator & recovery gates | 3 | validation | partial | V4-MULTIVARIATE/V4-MV-REML (partial); R evidence legs now include cold-start recovery, full-unstructured `sommer`, Mrode Example 5.1 supplied-G0/R0 BLUP/MME, and a Bayesian `MCMCglmm` agreement probe; twin #41/#49 still own promotion gates |
| 22 | Bridge: activate structured mv covariance | 4 | bridge | partial · **diagonal shipped** | **`:diagonal` subset SHIPPED** (guardrail relaxed + `genetic_structure` threaded + `covariance_structure_lrt`, built to twin contract #61 and the Julia `structured_covariance_parity` fixture). HSquared.jl PR #144 (`023c675`) synced the twin docs/status split: diagonal/unstructured bridge payload is banked, while `lowrank`/`fa` stay **blocked** on loading exposure, R activation, comparator/calibration gates, and the rotation convention (twin #42/#37/#61). |
| 23 | Bridge: post-fit `gwas()`/marker-scan wrapper | 5 | bridge | partial | Mixed, single-marker, and LOCO scan bridges are live and experimental; `gwas_table(scan)` and `lod_scores(scan)` now expose thin views of an already-computed `hs_gwas` object. Julia PR #142 (`f9fbbb1`) closed #45 by exporting a stable row-aligned `marker_scan_result_payload()` and serialized fixture, now mirrored by an R Julia-free payload-normalization test. Julia PR #134 banked a fixed-panel calibration smoke harness, PR #135 reopened #48 as the active calibration/evidence gate, and PR #143 (`07a3c63`) synced the Julia `V5-MARKER-THRESHOLD` status row while keeping #48 open. Local R scan-tool availability is blocked (`2026-06-21-marker-scan-tool-availability.md`: no PLINK/GEMMA/GCTA/SAIGE executables; no GenABEL/qvalue/rrBLUP/BGLR/AGHmatrix packages; `sommer` only). R significance thresholds remain inactive. Future gates are permutation/realistic-LD threshold activation, external comparator/calibration evidence, formula-level scan grammar, and map-annotated QTL/eQTL result tables (active twin #48/#61, with #45 closed). |
| 24 | Innovation: augmented AI-REML single-solve (Strandén 2024) | 8 | innovation/perf | planned | engine-led; twin #58; scout note |
| 25 | Innovation: SQUAREM EM accelerator (engine utility) | — | innovation/perf | planned | engine-led; twin #58; from `GLLVM.jl/em_squarem.jl` |
| — | Bridge contract: metafounder `A^Gamma` + single-step `H^Gamma` | 2/5 | bridge/contract | partial | Candidate A Big 3 slice; `metafounder(..., group =, Gamma =)` now validates the supplied-`Gamma` animal-only payload and fits the experimental supplied-variance `target = "metafounder"` path; `single_step(..., group =, Gamma =)` validates the supplied-`Gamma` `H^Gamma` payload and fits the experimental live `target = "metafounder_single_step"` path. `gamma_matrix()` and `metafounder_groups()` expose supplied provenance; `metafounder_effects()` is reserved/error-only. No returned metafounder-specific effects, `Gamma` estimation, BLUPF90-family comparator evidence, or covered promotion yet |

Recently banked / no longer open in the R issue list: #2, #8, #11, #12, #13,
#14, #15, #16, #17, #18, #19, #20, #21, and #26. Shipped features remain
partial/experimental where the capability ledgers say so; a closed issue does
not imply covered validation.

## HSquared.jl (twin engine) — selected open anchors

This table is a selected cross-lane map, not an exhaustive issue dump. The live
`gh issue list --repo itchyshin/HSquared.jl` output remains authoritative for
the full innovation backlog (#48, #50-#58, #61, and bridge/validation anchors).

| # | Title | Phase | Status | R mirror |
| --- | --- | --- | --- | --- |
| 48 | Validation: calibrated genome-wide significance thresholds | 5 | open · partial | R #23; PR #134 banked fixed-panel smoke, PR #135 reopened #48 as the active evidence gate, and PR #143 (`07a3c63`) synced the Julia validation-status/source-doc row; R #59/#60 banked the activation contract and inert metadata validator, but no R threshold is active |
| 61 | Joint critical path / cross-lane coordination | — | open · cross-lane | Holds ratified bridge conventions that feed R #22/#23/metafounder/RR follow-ups |
| 58 | Engine perf ideas (augmented AI-REML / SQUAREM / Woodbury) | 8 | planned · cross-lane | hsquared#24/#25/#17 |
| 53 | Innovation: metafounders / unknown-parent groups for ssGBLUP | 2/5 | planned / partial primitives | R contract row; supplied-`Gamma` bridge exists, no estimation or comparator claim |
| 49 | Validation: external comparator target fixtures | — | partial · cross-lane | hsquared#10/#7 promotion gate; Julia PR #132 hardened the BLUPF90 packet preflight and skip-safe runner; Julia PR #140 (`008ea4d`) added a genomic GBLUP/SNP-BLUP target fixture; Julia PR #145 (`b0d14ba`) added a machine-readable comparator target manifest for current fixture handoffs. No BLUPF90 executable, genomic external-comparator evidence, or new comparator parity exists yet |
| 46 | Validation: fitted Mrode/textbook target evidence | 1/3 | partial · open | Julia PR #138 (`945bd2a`) synced the R Mrode Example 5.1 supplied-covariance BLUP/MME anchor and `MCMCglmm` Bayesian agreement probe into the Julia V4 ledger; Julia PR #139 (`934a91e`) added a native Mrode (2014) Example 3.1 supplied-variance anchor at `sigma_a2 = 20`, `sigma_e2 = 40`, pinning published EBVs for animals 1-8 and the invariant male-minus-female sex contrast. #46 remains open for fitted estimated-VC/textbook target work; neither sync promotes V4-MV-REML or adds comparator parity |
| 5 | Gaussian animal model REML/ML engine | 1 | partial | — (epic) |
| 6 | Engine result object and diagnostics | 1 | partial | hsquared#6 |
| 7 | Julia-side validation canon | 1 | partial | hsquared#7/#10 |
| 8 | HSData input container and bridge parity | 1 | partial | hsquared#8 |
| 37 | [from R] PR #17 calibration: em_fa.jl warm-start; merge? | 4 | partial · cross-lane | hsquared#17/#22 |
| 41 | [from R] Validation gates R needs (partial→covered) | — | partial · cross-lane | hsquared#10/#7 |
| 42 | Bridge activation: structured mv covariance (FA/low-rank) | 4 | partial · cross-lane | hsquared#22; PR #144 (`023c675`) synced the twin status split between banked diagonal/unstructured bridge payload and still-blocked lowrank/fa loading exposure |
| 44 | Bridge activation: non-Gaussian LA/VA + MarginalMethod | 6 | partial · cross-lane | hsquared#18 |

## Cross-lane mirror map

| Topic | R (hsquared) | Twin (HSquared.jl) | Gate |
| --- | --- | --- | --- |
| Structured/FA G | #22 (+ #17 method) | #42 (+ #37 calibration) | twin diagonal/unstructured bridge payload+fixture is banked and mirrored by R diagonal controls/LRT; HSquared.jl PR #144 (`023c675`) keeps #42 open for lowrank/fa loading exposure, R formula/control activation, comparator/calibration gates, and the rotation convention; PR #17 closed, FA core already on main |
| PEV/reliability | #21 closed | #43 closed | Paired standard-field ledger is banked: R #21 closed by hsquared PR #73 (`adc2e63`), and Julia #43 closed by HSquared.jl PR #141 (`7466b2d`). Current fitted `AnimalModelFit` result payloads carry standard `prediction_error_variance` and `reliability` `(ids, values)` fields via `:selinv`, while supplied-variance Henderson MME may still use extractor enrichment. Remaining broader gates are multivariate per-trait fields, production sparse reliability strategy, and comparator validation; no covered-status promotion |
| Non-Gaussian LA/VA | #18 | #44 (+ #40) | twin `MarginalMethod` refactor + PR |
| Marker scans | #23 | #45 closed + #48 (+ PR #134 smoke, PR #135 reopen, PR #143 status row) | Phase 5 scan payload fixture banked by Julia PR #142 and mirrored by R payload-normalization parity; R now has thin `gwas_table(scan)` / `lod_scores(scan)` views for existing `hs_gwas` results; local scan-comparator tools are unavailable on this host; fixed-panel threshold smoke and Julia validation-status hygiene are banked and #48 remains the active evidence gate, but no R significance threshold activation, formula-level scan grammar, map-annotated table workflow, or production calibration claim |
| Metafounder / `H^Gamma` | — (contract row) | #53/#61 family | R model-spec + payload + live bridge branch for animal-only supplied-variance `A^Gamma` and single-step `H^Gamma`; supplied `Gamma`, provenance extractors, reserved/error-only `metafounder_effects()`, no estimation; BLUPF90-family comparator executable currently unavailable locally |
| Validation gates | #10, #7 | #41, #49, #7 | broader/redeclared recovery gate + second independent same-estimand comparator; Mrode-style target and `MCMCglmm` Bayesian agreement evidence are recorded but do not clear REML comparator parity; Julia PR #132 banked BLUPF90 preflight/runner hardening only; Julia PR #140 banked a genomic target fixture for future external comparator consumption; Julia PR #145 banked a fixture index/manifest only, not comparator evidence |
| HSData marshalling | #8 | #8 | skip-guarded live bridge marshalling now checks phenotype/pedigree/genotype data-frame components into `HSquared.HSData`; no file-backed storage, relationship construction, or fitting claim |

Recently banked / no longer open in the selected Julia anchor list: #38
(`docs/design/03-engine-contract.md` AI-matrix claim hygiene, merged in
HSquared.jl PR #133 at `4526481`), #93 (plotting plot-data contract, closed by
HSquared.jl PR #136 at `ff1fbab` after R PR #35/A3 attached available fit-time
plot-data payloads), #47 (multivariate covariance SE/LRT ledger, closed by
HSquared.jl PR #137 at `ad7848c` for already-landed work), #43
(PEV/reliability standard-field ledger, closed by HSquared.jl PR #141 at
`7466b2d` after paired R #21/PR #73 closeout), and #45 (marker-scan result
payload fixture, closed by HSquared.jl PR #142 at `f9fbbb1`; R mirrors the
serialized payload fixture for Julia-free normalization parity). Historical
R-lane notes may still mention the old `250-animal` wording, #93 as an open
cleanup item, #47 as an active ledger row, #43 as open, or #45 as an active
payload gate; the live selected issue map now treats those as banked.

Recent Julia-side coordination checkpoints that keep current gates honest:

- HSquared.jl PR #132 (`b657464`) hardened the BLUPF90 multivariate preflight
  packet and skip-safe opt-in runner for #49/#41. It did not run
  `renumf90`/`airemlf90`/BLUPF90-family executables and does not count as
  second-comparator evidence.
- HSquared.jl PR #133 (`4526481`) cleaned the stale AI-matrix validation claim
  and closed #38. R current public capability rows already avoid the old claim.
- HSquared.jl PR #134 (`beca371`) hardened the opt-in fixed-marker-panel
  threshold calibration smoke harness. HSquared.jl PR #135 (`a815097`) then
  reopened #48 as the active calibration/evidence gate. Neither PR activates R
  `gwas()` significance thresholds, adds a PLINK/GenABEL-style external
  comparator, provides realistic-LD production calibration, or promotes the R
  marker-scan row beyond partial.
- HSquared.jl PR #142 (`f9fbbb1`) closed #45 by exporting a stable
  `marker_scan_result_payload(scan)` row-aligned bridge payload and serialized
  marker-scan parity fixture. R mirrors that fixture for Julia-free
  normalization parity, but no threshold, map-table, formula-scan, sparse
  production, comparator, or promotion claim follows from it.
- HSquared.jl PR #143 (`07a3c63`) synced the Julia `V5-MARKER-THRESHOLD`
  validation-status/source-doc row and retargeted Julia issue #48 while keeping
  #48 open. It did not run new threshold calibration, add realistic-LD or
  external-comparator evidence, wire threshold columns into public marker-scan
  outputs, or activate R significance wording.
- HSquared.jl PR #144 (`023c675`) synced the Julia structured-covariance status
  split for #42: rotation-free `:diagonal` / `:unstructured` bridge payload
  evidence is banked, while `lowrank`/`fa` loading exposure, R activation,
  comparator/calibration evidence, and any validation-row promotion remain open.
- HSquared.jl PR #136 (`ff1fbab`) closed #93 after reconciling the plotting
  plot-data contract with the R A3/PR #35 fit-time payload attachment.
- HSquared.jl PR #137 (`ad7848c`) closed #47 as an issue-ledger closeout for
  already-landed multivariate covariance SE/LRT work. It does not add a new
  structured-fit covariance SE claim or promote multivariate coverage.
- HSquared.jl PR #138 (`945bd2a`) synced the R-lane Mrode Example 5.1
  supplied-covariance BLUP/MME anchor (`hsquared` `6a1065e`) and `MCMCglmm`
  Bayesian agreement probe (`hsquared` `dbf97a7`) into the Julia V4 ledger.
  V4-MV-REML remains partial: only the `sommer` leg is same-estimand REML
  parity, #46 remains open for fitted textbook-target work, and #49 still
  needs a second independent same-estimand comparator.
- HSquared.jl PR #139 (`934a91e`) added a Julia-native Mrode (2014) Example
  3.1 published animal-model anchor at supplied variance components
  (`sigma_a2 = 20`, `sigma_e2 = 40`). It pins published EBVs for animals 1-8
  and the male-minus-female sex contrast, with a perturbation test-of-test.
  It is still supplied-variance textbook evidence only: no estimated variance
  components, no same-estimand REML comparator parity, no sire-model
  implementation, and no covered promotion.
- HSquared.jl PR #140 (`008ea4d`) added a Julia-native genomic GBLUP/SNP-BLUP
  target fixture under `test/fixtures/genomic_gblup_snpblup_target/`. The
  fixture serializes phenotypes, marker dosages, supplied allele frequencies,
  VanRaden method-1 `G`, `Ginv`, beta, GEBVs, marker effects, metadata, and a
  no-RNG generator. It is target availability only: no AGHmatrix, rrBLUP,
  sommer, JWAS, BGLR, BLUPF90, or other external comparator evidence; no R
  genomic model-spec activation; and no covered promotion.
- HSquared.jl PR #145 (`b0d14ba`) added `test/fixtures/comparator_targets.toml`
  as a machine-readable fixture/comparator handoff index. It records current
  fixture IDs, issue/status rows, required files, evidence classes, required
  comparators, and claim boundaries. It is an index only: no external comparator
  run, no R genomic/threshold/structured-covariance activation, and no
  validation/public-claim promotion.

## Historical WS2 work order — Step 0 DONE (see `docs/design/19-on-main-bridge-gap.md`)

Historical Step 0 (#15) result from 2026-06-19: `HSquared.jl origin/main`
(`4e8ffde`) was at **Phases 1–6** — PR #36 had landed Phase 4B + Phase 5, and
Phase 6 non-Gaussian functions were present. This is retained as the WS2
decision record; the selected issue table above and live `gh` output are the
current backlog snapshot.

- #21: closed on 2026-06-21 after the R standard-field surface was banked
  (univariate/default PEV/reliability payload consumption and Henderson dense
  reliability). Multivariate per-trait, production sparse reliability, and
  comparator validation remain cross-lane/twin-gated and do not imply a covered
  promotion. Julia issue #43 is also closed after HSquared.jl PR #141
  (`7466b2d`) recorded the standard `AnimalModelFit` payload contract.
- #22: the diagonal structured-covariance subset is banked; low-rank and FA
  remain twin/rotation-convention gated.
- #23: mixed, single-marker, and LOCO marker scans are banked; Julia has a
  stable marker-scan result payload fixture (PR #142) plus a fixed-panel
  calibration smoke, and #48 is open as the active evidence gate, but R
  threshold activation, production calibration, external comparator evidence,
  and map-annotated QTL/eQTL tables remain gated.
- #18/#44: Laplace/VA marginal dispatch and binomial counts are banked; further
  family breadth remains validation-gated.

## Next big 4 (program 2) — see `docs/dev-log/2026-06-19-next-big-4-program.md`

| # | Big item | Issue(s) | Lane |
| --- | --- | --- | --- |
| 1 | Validation depth (v0.1 unimpeachable) | #7 epic + ✅#31 (sommer/pedigreemm benchmark), ✅#33 (comparator-policy doc), ✅#32 (Mrode 3.2 sire anchor) — **all done** | R-ownable |
| 2 | Applied-user experience + figures | #27 epic + ✅#28 (summary CI/SEs), ✅#30 (plot.hsquared_fit), ✅#29 (gryphon worked vignette) — **all done** | R-ownable |
| 3 | Multivariate → covered | #10 + ✅#26 (covariance SEs) + ✅#34 (t≥2 recovery harness) + R full-unstructured `sommer` REML evidence + Mrode Example 5.1 supplied-covariance target + `MCMCglmm` Bayesian agreement — **R evidence recorded, not coverage**; promotion still needs broader/redeclared recovery gate and a second independent same-estimand comparator via HSquared.jl#41/#49 | R evidence + twin gate |
| 4 | Factor-analytic unblock | #22 mirror; twin HSquared.jl#37 (calibration) + #42 (payload) | twin-led, R-prepared |

See `docs/dev-log/coordination-board.md` and the program plan for the full workstream design.
