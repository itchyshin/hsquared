# 49 — v0.7 genomic GREML recovery-v3 identification ladder

> 🎯 **GOAL**
>
> ```text
> Codex must determine, with immutable old-data replay and fresh Totoro evidence,
> whether the held v0.7 raw-marker genomic GREML route can separate genomic from
> residual variance at an evidence-supported validation scale. The headline is
> kernel identifiability: preserve the frozen VanRaden1/sample-frequency/ridge-
> 0.01 estimator and all recovery margins, first test whether projected-kernel
> information explains the recovery-v2 precision blocker, then run a staged
> n-by-m/n ladder with fresh seeds. In parallel, independently recompute every
> admitted summary in R and Julia. Defer any public spectral cutoff, estimator
> change, default-route merge, capability promotion, count change, or release.
> Smoke on Totoro, run at no more than 96 single-threaded workers, keep raw output
> local, make every gate fail under deliberate mutations, and close with the
> full Fisher, Darwin, Noether, Hopper, Grace, and Rose audit. A clear negative
> result is valid evidence; it is never
> rewritten as activation.
> ```

Status: **D0 COMPLETE; TWO D0F CORPORA LOCKED BUT UNADJUDICATED; THIRD
PROSPECTIVE D0F RETRY PREPARED BUT NOT PRESEALED; NO NEW PHENOTYPE AND NO D1 OR
D2 SEED CONSUMED.** The first D0F run completed 576
official R attempts,
but the exact presealed Julia replay tool stopped deterministically before
writing any replay row. That root is a hash-locked, retired
replay-infrastructure blocker, not D0F scientific evidence. The first retry
received the required hash-bound plan receipts, committed tooling, new stage
preseal, and new canonical root before its first phenotype was generated. All
576 official fits and all 576 base-R recomputations completed, but the exact
Julia replay tool then failed before writing any replay row because a Git root
returned as `SubString` promoted a `Cmd` argument vector to
`Vector{AbstractString}`. That second root is also retired as a
replay-infrastructure blocker. The third retry does not reopen, rewrite, pool,
or admit either blocked D0F corpus or the retired recovery-v2 offsets.

No D0F retry is adjudicated and therefore none can admit D1. The
downstream D2-D4 evidence protocol in this document was prospectively amended
on 2026-07-14, before any D2 seed was consumed, to require terminal ordered D2
history, dedicated numerical validators, one-to-three selected D3 triplets,
exactly three original D4 triplets, and acyclic official-attempt versus
post-lock recomputation schemas.

## 1. Why recovery-v3 exists

Recovery-v2 completed 432/432 converged end-to-end fits but correctly stopped at
`PRECISION_BLOCKER`: five of nine cells required more than the frozen 2,000
confirmation replicates, with a maximum requirement of 16,325. Six pilot cell
means also lay outside at least one frozen equivalence margin, although no
48-seed Monte Carlo interval lay wholly beyond its margin. The formal v2 result
therefore proves insufficient confirmation precision, not persistent estimator
bias.

Independent numerical review found no candidate implementation defect:

- the held ordinary-form marker and supplied-precision candidates use the same exact
  \(K_\lambda\);
- the AI and exact profile ratios agree to at most \(9.28\times10^{-8}\);
- the fitted objective and independently evaluated profile objective agree to
  at most \(1.30\times10^{-14}\) per observation for interior fits; and
- the scientific and numerical outputs differ only by the declared endpoint
  representation.

The remaining mechanism is statistical identification. Marker columns are
centred, so the intercept removes the exact ridge-only eigenmode. On the
remaining subspace, genomic and residual variances are distinguishable only
through dispersion in the eigenvalues of \(K_\lambda\). In a preliminary
three-packet-per-regime read-only check, residual-spectrum eigenvalue CV was
approximately 0.47 for
\((n,m)=(120,600)\), 0.57 for \((300,1000)\), and 1.47 for \((300,150)\).
The corresponding information-predicted standard errors closely matched the
observed pilot standard deviations. This is strong diagnostic evidence for weak
identification when the realised kernel approaches a scalar covariance, but it
is not fresh recovery evidence and does not select a public scope.

Recovery-v3 asks the next discriminating question without changing the
estimator: **how do sample size and marker-to-individual ratio jointly determine
the information available to separate \(\sigma_g^2K_\lambda\) from
\(\sigma_e^2I\)?**

## 2. Frozen boundaries

Recovery-v3 preserves all of the following:

- candidate route: ordinary-form `hsquared()` auto-dispatch through R
  validation and the live R-to-Julia bridge on an exact unmerged R commit;
- construction: unweighted VanRaden1 using realised sample allele frequencies;
- kernel: \(K_\lambda=G+0.01I\);
- model: Gaussian, REML, one genomic random intercept, one observation per ID,
  intercept-only fixed model;
- estimands: \(\sigma_g^2\), \(\sigma_e^2\), and
  \(r_G=\sigma_g^2/(\sigma_g^2+\sigma_e^2)\);
- margins: 5% relative for each variance component and 0.02 absolute for
  \(r_G\);
- successful endpoint fits remain in every denominator and summary;
- every attempted seed remains in the convergence denominator;
- pilot estimates never enter confirmatory bias summaries;
- raw outputs stay local on Totoro or DRAC, never GitHub Actions; and
- `public_covered_count` remains 5 without a separate maintainer G10 decision.

Recovery-v3 does **not** introduce a penalty, prior, bias correction,
unconstrained estimator, endpoint deletion, ratio-of-means target, altered
ridge, post-hoc margin, or relaxed convergence rule. Any such change defines a
new estimator or estimand and requires a new symbolic contract, comparator, and
recovery programme.

Executing the public-looking formula on the held branch proves candidate route
behaviour. It does not prove availability on `main`, activation, or release.

The original doc-44 G5 broad gate remains frozen. Recovery-v3 evidence cannot
make a failed original cell disappear. Exact-cell evidence discovered here
cannot silently replace the current broad grammar or its nine cells.

## 3. ADEMP design

This design follows Morris, White, and Crowther's ADEMP framework
(doi:10.1002/sim.8086) and the Williams et al. transparent-reporting checklist
(doi:10.1111/2041-210X.14415).

### A — Aims

Primary aim:

- determine whether conditional expected projected-kernel information is
  associated with the sampling variation and boundary mass of the frozen GREML
  estimator across sample size and marker-to-individual ratio.

Secondary aims:

- identify, without changing margins, the smallest tested \(n\) at each tested
  marker ratio for which a fresh three-ratio recovery confirmation is
  statistically feasible within 2,000 replicates per cell;
- estimate phenotype sampling variation conditional on preregistered fixed
  kernels separately from variation across the preregistered D0 panels,
  treated as draws from the frozen HWE/no-LD mechanism; and
- quantify runtime and peak RSS before any confirmation manifest is created.

This study does not aim to prove robustness to LD, population structure,
imputation, allele-frequency misspecification, related sampling, multiple
records, additional fixed effects, or production-scale panels.

### D — Data-generating mechanism

For individual \(i=1,\ldots,n\) and marker \(j=1,\ldots,m\), independently
draw

\[
\pi_j\sim\operatorname{Uniform}(0.05,0.5),\qquad
M_{ij}\sim\operatorname{Binomial}(2,\pi_j).
\]

Remove realised monomorphic columns without redrawing. The design factor
`marker_ratio = m/n` is the nominal pre-removal ratio. Every packet separately
records `retained_m` and `retained_marker_ratio = retained_m/n`; monomorphic
removal never silently redefines the design factor. Every retained column is
polymorphic and `1 <= retained_m <= m`; violation blocks packet admission. From the retained panel,
construct

\[
\hat p_j=\frac{1}{2n}\sum_i M_{ij},\quad
W_{ij}=M_{ij}-2\hat p_j,\quad
k=2\sum_j\hat p_j(1-\hat p_j),
\]

\[
G=WW^\top/k,\qquad K_\lambda=G+0.01I.
\]

Then draw

\[
u\sim N(0,\sigma_g^2K_\lambda),\qquad
\varepsilon\sim N(0,\sigma_e^2I),\qquad y=u+\varepsilon,
\]

where \((\sigma_g^2,\sigma_e^2)=(r_G,1-r_G)\). The random-number generator,
draw order, monomorphic-column handling, fit route, endpoint resolution, and
fingerprints are identical to recovery-v2 except for the new cell and seed
manifests.

#### Stage D0 — immutable spectral replay

Before generating v3 data, read all 432 members of the exact offset-7101 pilot
manifest without fitting or rewriting them. The replay binds and verifies:

```text
pilot_manifest.tsv      1264e87eeea10bf8dd9d6197a0f2ef865a2cd541e085bde22a655730ef894f61
pilot_corpus_lock.tsv   04f128168747aecab4847848de4498ebfb6efdf4aafb742d2e6f828e0d15c084
campaign_seal.tsv       4a921c039426faa400648752ec59bd3f049939098ec4f42b6faafc9e845b324c
```

There is no `valid packet` subset: a missing, additional, corrupt, duplicated,
or mismatched member stops the replay.

For each packet, independently reconstruct marker-built \(K_\lambda\), set
\(Q=K_\lambda^{-1}\), and reconstruct the actual profile input

\[
K_{profile}=\operatorname{sym}(Q^{-1}).
\]

The two kernels must agree elementwise to `1e-10`. Define the deterministic
\(n\times(n-1)\) Helmert contrast matrix \(C\) by, for column
\(j=1,\ldots,n-1\),

> **Prospective D0 provenance amendment (2026-07-13, before the first official
> D0 receipt and before any fresh v3 phenotype).** The packet contains markers,
> not a serialized `K`/`Q` pair. Exact raw-Float64 K/Q fingerprint reproduction
> across independently evaluated R and Julia arithmetic is therefore not a D0
> gate: last-bit reduction and BLAS order can change the byte hash without a
> scientific difference. The frozen three-link rule is instead: (1) base R and
> Julia must reproduce the marker and ID fingerprints exactly; (2) Julia must
> independently reconstruct `K` and `Q` and match the packet's recorded K/Q
> fingerprints exactly; and (3) base R must independently reconstruct `K` and
> `Q`, satisfy `QK`, `K` versus `sym(Q^-1)`, every eigenvalue, and every summary
> comparison at the frozen `1e-10` tolerance. Base R writes its native K/Q raw
> fingerprints to a separate create-once descriptive table. The adjudicator
> must verify that table's sidecar, exact schema, 432 unique packet keys, and
> exact marker/ID consistency; its K/Q hashes are provenance diagnostics, not a
> cross-language equality gate. This replaces the inherited doc-47 raw-K/Q-hash
> rule only for D0 packets that do not serialize K/Q; it changes no numerical,
> recovery, or activation threshold.

The same native-hash rule applies prospectively to D0F and D1. Their official
packet and attempt `kernel_hash` and `precision_hash` fields are Julia-native
construction fingerprints: Julia must reproduce them exactly. Base R must
reproduce `marker_hash` and `id_hash` exactly, independently reconstruct

\[
p,\;W,\;k,\;G,\;K_\lambda,\;Q_\lambda,
\]

and pass the frozen `1e-10` inverse, kernel-replay, spectral, attempt, and
summary comparisons. Each base-R recomputation row additionally records
`base_r_kernel_hash` and `base_r_precision_hash` as descriptive provenance.
Those native hashes must be valid and sidecar-bound but need not equal the
Julia-native hashes: last-bit differences from otherwise valid R/Julia linear
algebra are admitted only when every numerical gate remains within `1e-10`.
Marker or ID hash differences remain fatal. This amendment was frozen before
the first official D0F/D1 seed was consumed.

\[
C_{ij}=\begin{cases}
1/\sqrt{j(j+1)}, & i\le j,\\
-j/\sqrt{j(j+1)}, & i=j+1,\\
0, & i>j+1.
\end{cases}
\]

Thus \(C^\top C=I\) and \(C^\top\mathbf1=0\). Compute the sorted eigenvalues
\(\lambda_i\) of

\[
K_\perp=\operatorname{sym}(C^\top K_{profile}C).
\]

Deleting one ridge eigenvalue is mathematically equivalent but is not the
implementation, because the ridge eigenvalue can have multiplicity. Require all
\(n-1\) eigenvalues to be finite and strictly positive. Define population CV

\[
CV_\lambda=\frac{\sqrt{(n-1)^{-1}\sum_i(\lambda_i-\bar\lambda)^2}}
{\bar\lambda}
\]

and effective rank

\[
r_{eff}=\frac{(\sum_i\lambda_i)^2}{\sum_i\lambda_i^2},
\]

and, for \(r\in\{0.2,0.5,0.8\}\), the expected efficient Fisher information
conditional on realised \(K\), after eliminating total scale
\(t=\sigma_g^2+\sigma_e^2\),

\[
d_i(r)=\frac{\lambda_i-1}{r\lambda_i+1-r},\qquad
I_{r\mid t}=\frac12\left\{\sum_i d_i(r)^2-
\frac{[\sum_i d_i(r)]^2}{n-1}\right\},
\qquad SE_{info}(r)=I_{r\mid t}^{-1/2}.
\]

Set `SE_info = Inf` when information is numerically zero. This is a first-order
conditional asymptotic SE, not observed likelihood curvature or an exact
finite-sample SE. For each cell, report the primary mechanism statistic

\[
C_c=\frac{SD(\hat r_c)}
{\sqrt{48^{-1}\sum_{j=1}^{48}SE_{info,j}^2}}.
\]

A deterministic paired bootstrap uses 10,000 index rows generated once in base
R with the sealed RNG and seed `2030000000 + cell_index`; the index matrix is a
create-once input consumed by both recomputers. Its percentile 2.5% and 97.5%
quantiles accompany \(C_c\). Also report Spearman correlation between
`SE_info` and absolute ratio error, plus the first-order Normal boundary
diagnostics

\[
p_L(K)=\Phi\{-r/SE_{info}(K)\},\qquad
p_U(K)=1-\Phi\{(1-r)/SE_{info}(K)\},
\]

averaged across all 48 kernels and compared with observed lower/upper boundary
proportions and their binomial MCSEs. These are descriptive Normal diagnostics,
not exact boundary laws and not selection gates. D0 proceeds whenever R and
Julia reproduce every eigenvalue and summary to `1e-10`; only corpus or
recomputation disagreement stops D1. The marker-limited information result is
conditional on ridge 0.01, including its residual-subspace point mass at the
ridge floor, and does not generalise to another ridge or an unregularised
kernel.

Every D0F/D1 stage preseal must verify and bind the finalized D0 replay receipt,
not merely copy an unchecked digest:

```text
d0_output_root = /home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0-official-cdb33dc-4c5e54de
d0_adjudication_receipt_sha256 = 190b6546fab8caeec24683c4f7bee8063ada671c220852c9372e5db194b2886a
d0_diagnostics_relative_path = r/d0_packet_diagnostics_base_r.tsv
d0_diagnostics_sha256 = 7c1cbc165df90e844bd4fdc7fc6ffb6dcbb8343c0d5ca9e7a588e4ca6d48c370
```

The receipt primary and SHA-256 sidecar must both verify at that canonical
plain path before either stage can be presealed. D0F fixed-panel selection may
consume only the exact diagnostics relative path and hash above; callers cannot
select another pair inside the D0 root.

#### Stage D0F — fixed-kernel phenotype replication

The original official root
`/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0f-official-0a9d882-1a538212`
is permanently **UNADJUDICATED — REPLAY_INFRASTRUCTURE_BLOCKER**. It binds
preseal `2498301ca09949c584e74aa7bed0d468cd49cee893b1d6ded42d4785e30e1a32`,
official corpus lock
`dee0bb91f40bf0e9183ff6ccd8525b3ba97271edae8819413f90d57fa94bb963`,
R summary `3f09b47037e8cfccb090efb2ea76bfa0825e1f01aed8ebacabd8b17731c577c2`,
and Julia replay commit
`1a538212e258ca8e355ecd07420351a5097e3111` / tool SHA-256
`c8b4d2ceb4c01f807efa610002763fc1f5416c35a666427975a7f7972a3b0826`.
The replay produced zero rows, so no D0F adjudication receipt can be minted.
Neither its 576 phenotype estimates nor any repaired post-hoc replay may enter
the retry summary. The filesystem remains writable; admission relies on the
recorded exact hashes, and the root is logically frozen and never reused.

The first retry root
`/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0f-retry-r2-2cb5308-f7ff838`
is permanently **UNADJUDICATED — REPLAY_INFRASTRUCTURE_BLOCKER**. It binds
preseal `e55e68ef8734219572bf22cf51932b78c3efd38d2e04cb9eb83323ef80f98fa5`,
official corpus lock
`3191ba42c5061dc3693f930c81433682ff44a74f78bc27a6561c8292789ebc3f`,
base-R summary
`ea624296b249e37334c384c5a349037a5e91acd8f5c02b14615e2b35a25f6a6b`,
and Julia replay commit
`f7ff83855c4b4d14aad39516f37b7c1b5994b7ae` / tool SHA-256
`8aac6c50775fcb0f5ebcd15235b2d2979bc2ac50a7b7006165342f8208d9d7de`.
The exact failure was `MethodError: no method matching
Cmd(::Vector{AbstractString})` in `_git_blob_sha256`; replay produced zero
rows. The base-R summary is diagnostic infrastructure output only and cannot
be adjudicated or used to tune the third retry.

The only admitted continuation is a prospective third D0F retry: unchanged
fixed panels, 24-by-8 allocation, estimand, model, ridge, summaries, tolerances,
and stopping rules; a repaired replay tool with an exact `SubString`-root
regression and live Julia 1.10 preflight; five new exact reviewer receipts; a
new root and preseal; and 576 new phenotypes from the disjoint seed space below.
There is no pooling, paired reuse, seed replacement, threshold change, or
selection based on either blocked corpus or summary.

After the new preseal is written and before any smoke or official phenotype is
generated, the deployed Julia 1.10 tool must pass:

```sh
tools/run-v07-genomic-recovery-v3.sh preflight \
  <new-d0f-root> d0f <deployed-r-root> <deployed-julia-root>
```

This zero-seed preflight validates the exact preseal tree and executes the
Julia-side commit, Git-blob, sidecar, ancestry, clean-tree, and unchanged-engine
checks. It creates no output and consumes no official random number or seed.

This mandatory mechanism-only arm uses the 24 smallest manifest seeds from
each of the three original \(r_G=0.5\) v2 cells: `(120,600)`, `(300,150)`, and
`(300,1000)`. Their marker, kernel, precision, and ID hashes are written to a
create-once fixed-panel manifest and verified against the D0 corpus before any
phenotype draw. For each of the 72 fixed kernels, generate eight independent
fresh phenotypes at \(r_G=0.5\), giving 576 fits. Marker panels are never redrawn in
this arm.

For panel \(k\) and phenotype replicate \(j\), store \(\hat r_{kj}\). Within
each of the three designs report

\[
\bar r_k=8^{-1}\sum_j \hat r_{kj},\qquad
s_k^2=7^{-1}\sum_j(\hat r_{kj}-\bar r_k)^2,
\]

\[
\bar{\bar r}=24^{-1}\sum_k\bar r_k,\qquad
\operatorname{Var}_k(\bar r_k)=
23^{-1}\sum_k(\bar r_k-\bar{\bar r})^2,
\]

\[
V_{within}=24^{-1}\sum_k s_k^2,\qquad
V_{between}=\operatorname{Var}_k(\bar r_k)-V_{within}/8,
\]

without truncating a negative finite-sample \(V_{between}\). A deterministic
10,000-replicate two-level bootstrap per design resamples panels and then
phenotypes within panel, using a presealed index manifest, and reports percentile
intervals. Base R generates each design's indices with
`RNGkind("Mersenne-Twister", "Inversion", "Rejection")` and seed
`2035000000 + design_index`. The create-once manifest is normalized to one row
per bootstrap panel slot: `design_id`, `design_index`, `bootstrap_rep`,
`panel_slot`, `panel_rank`, followed by `phenotype_01` through
`phenotype_08`. It therefore contains exactly `3 * 10000 * 24 = 720000` rows.
Both recomputers consume the same primary and SHA-256 sidecar. D0F estimates
remain diagnostic and never enter D1/D2 sizing, D3/D4 recovery, or a capability
claim. Its exact successful adjudication receipt is nevertheless a mandatory
sequencing checkpoint: D1 cannot be prepared or presealed until fresh D0F is
fully recomputed, reviewed, and adjudicated `PASS` with decision `COMPLETE`.

The 24-by-8 allocation preserves the 576-fit budget while increasing the
between-panel degrees of freedom from 7 to 23 per design. It retains
`24 * (8 - 1) = 168` within-panel residual degrees of freedom per design,
compared with 184 under the rejected 8-by-24 allocation. Ten thousand
bootstrap replicates stabilize deterministic Monte Carlo quantiles but do not
create additional panel information. If any of the 576 fits is unsuccessful,
all attempted seeds remain in the denominator, the variance decomposition and
bootstrap intervals are recorded as unavailable, `d0f_status` is
`D0F_FIT_BLOCKER`, and `fit_blocker` is true; successful subsets are never
analysed as though complete. A complete 576-fit corpus records
`d0f_status = COMPLETE` and `fit_blocker = false`. These fields occur immediately after
`convergence_rate` in the ordered D0F summary schema.
Both \(u\) and \(\varepsilon\) are redrawn independently for every phenotype
replicate while \(K_\lambda\) remains fixed within panel. R and Julia report
Hyndman--Fan type-7 2.5% and 97.5% percentile quantiles. For each design they
also report `MCSE_mean_ratio = sd_k(bar_r_k) / sqrt(24)` and cluster-level
boundary-proportion MCSEs `sd_k(p_k) / sqrt(24)`, where \(p_k\) is the panel's
eight-replicate lower- or upper-boundary proportion.

The ordered D0F summary schema is:

```text
stage design_id design_index n m n_panels phenotypes_per_panel
n_expected n_attempted n_converged n_interior n_interior_rescued
n_boundary_lower n_boundary_upper n_unresolved n_error failure_classes
convergence_rate d0f_status fit_blocker bootstrap_sha256
variance_within variance_within_bootstrap_lower variance_within_bootstrap_upper
variance_between variance_between_bootstrap_lower variance_between_bootstrap_upper
mean_ratio mcse_mean_ratio empirical_sd_ratio
boundary_lower_proportion boundary_upper_proportion
mcse_boundary_lower mcse_boundary_upper
median_runtime_seconds p95_runtime_seconds median_peak_rss_mb p95_peak_rss_mb
```

All three design rows carry the corpus-wide D0F status. Under
`D0F_FIT_BLOCKER`, decomposition, bootstrap, mean-ratio, and boundary-proportion
fields are `NA`, while the complete attempt, classification, runtime, and RSS
fields remain populated.

Before official D0F, Julia must generate and read the deterministic canonical
base-R three-row summary fixture from the exact presealed R tool bytes. Both
implementations compare every ordered D0F summary field, using exact equality
for categorical, Boolean, and integer fields and `1e-10` for numeric fields.
The raw fixture SHA-256 is descriptive rather than an admission gate: R 4.5 and
4.6 can serialize last-bit quantile differences while every typed comparison
remains far inside `1e-10`. Mutating any field beyond its typed rule, changing
the schema, or changing the presealed R tool bytes must make the parity gate
red. This cross-version amendment was frozen before any official D0F/D1 seed.

#### Stage D1 — fresh interior ladder

**Fresh-D0F checkpoint.** Before D1 preparation, the launcher and R driver must
receive the canonical fresh-D0F root. They verify its
`stage_adjudication_receipt.tsv` primary and sidecar, exact ordered
`v07-genomic-recovery-v3-adjudication-1` schema, `stage = d0f`,
`verdict = PASS`, `stage_decision = COMPLETE`, parity maxima no larger than
`1e-10`, provenance digests, and canonical post-run review paths. The D1 root
and D0F root must be distinct and nonnested. D1's preseal binds both the
canonical D0F root and receipt SHA-256. The retired blocked D0F root named above
is explicitly forbidden, and a missing, partial, unhashed, failed, incomplete,
unadjudicated, noncanonical, nested, or mismatched receipt stops before D1
manifest preparation. The receipt pair is not sufficient by itself: the
operational independent R adjudicator must reconstruct the expected receipt
from the exact D0F preseal, corpus, attempts, packets, independent
recomputations, Julia replays, summaries, and five post-run reviews, and the
whole final tree must validate. Immediately before every D1 launcher fan-out
this full validation runs as a centralized early-stop preflight, and every
worker revalidates the exact final tree before consuming its seed. This is
intentionally I/O-heavy but leaves no caller-spoofable attestation shortcut;
runtime must be measured at smoke scale before production concurrency is set.
No D0F estimate enters the D1 analysis.

Use \(r_G=0.5\), 48 fresh pilot seeds per cell, and the full factorial design:

| factor | levels |
| --- | --- |
| \(n\) | 120, 300, 600, 1200 |
| \(m/n\) | 0.5, 10/3, 5 |
| \(m\) | `round(n * ratio)`, fixed in the manifest |
| \(r_G\) | 0.5 |

The twelve exact `(n, m)` pairs are `(120,60)`, `(120,400)`, `(120,600)`,
`(300,150)`, `(300,1000)`, `(300,1500)`, `(600,300)`, `(600,2000)`,
`(600,3000)`, `(1200,600)`, `(1200,4000)`, and `(1200,6000)`.

Each fit additionally records projected-spectrum CV, effective rank,
`SE_info(0.2)`, `SE_info(0.5)`, `SE_info(0.8)`, boundary status, fitted total
variance, runtime, and peak RSS. D1 contains 576 attempted fits.

For each of the 12 D1 cells, both recomputers report RMS `SE_info(0.5)`,
empirical ratio SD over the identical finite-success subset, their ratio
\(C_c\), predicted lower/upper Normal boundary probabilities averaged over all
admitted packets, and observed boundary proportions. Their across-cell
association is descriptive; it is neither an admission gate nor a hypothesis
test.

In the ordered D1 summary schema, immediately after
`empirical_sd_over_rms_se_info` (the reported \(C_c\)), add
`predicted_boundary_lower`, `predicted_boundary_upper`,
`observed_boundary_lower`, `observed_boundary_upper`,
`mcse_boundary_lower`, and `mcse_boundary_upper`, before the existing spectral
mean fields.

#### Stage D2 — fresh edge pilots

For each marker ratio, order all D1-eligible \(n\) values ascending. D2 tests
each eligible \(n\), in that order, with one immutable 48-seed batch at
\(r_G\in\{0.2,0.8\}\), stopping at the first \(n\) whose two edge cells both
meet every pilot admission rule or after \(n=1200\). A D1-ineligible \(n\) is
skipped and can never become selected. A failed D2 candidate stays failed; it
is never rerun, pooled, rescued, or replaced by data from a neighbour.

Independently of ladder selection, D2 also runs both fresh edge pilots for each
of the three original doc-44 `(n,m)` designs whose D1 \(r_G=0.5\) cell is
eligible. A cell already present in the ascending traversal is run once and
shared by exact hash; it never receives a second batch. This mandatory broad
lane ensures that D1/D2 either supply all nine original fresh pilots or record
exactly why the broad lane cannot proceed.

A mandatory original-cell broad batch may exist before the ascending ladder
reaches that cell, but it cannot influence selection until every earlier
eligible candidate has been adjudicated. It is run once and shared by exact
hash.

Each D2 batch occupies a separate immutable presealed root. The authenticated
history is ordered: D1 is `sequence_index = 0`, followed by
`d2_batch_001`, `d2_batch_002`, and so on. Each next D2 manifest is derived
from the canonical D1 summary plus every earlier D2 batch in that exact order.
An omitted, duplicated, reordered, forked, caller-selected, or nonterminal
history is inadmissible. D3 and D4 can be prepared only from the terminal D2
history, meaning that the state machine admits no further D2 batch. There is no
snapshot or early-history exception.

A D2 adjudication receipt with `verdict = PASS` says that the evidence tree is
valid and independently reproducible; it does not say that every cell is
eligible. Authenticated cell statuses remain `ELIGIBLE`,
`PRECISION_BLOCKER`, `FUTILITY_STOP`, or
`STOP_LOW_PILOT_CONVERGENCE`. `RECOMPUTATION_BLOCKER` is not an authenticated
pilot outcome: it prevents a PASS receipt and therefore cannot enter the
ordered predecessor history.

#### Stage D3 — selected exact-triplet confirmation

A marker ratio reaches D3 only when the same selected \(n\) is eligible at all
three \(r_G\) values. D3 admits **one to three** complete selected triplets,
depending only on the authenticated terminal D2 history, and confirms each
admitted triplet's three cells with fresh seeds and
the existing target-specific sizing rule, minimum 200 and maximum 2,000 per
cell. For \(r_G=0.5\), sizing comes only from that exact cell's D1 batch; for
each edge, it comes only from that exact cell's unique D2 batch. D0, D0F,
failed candidates, neighbours, and other pilot batches are never pooled or
chosen according to a smaller `N_req`. D1 and D2 estimates are excluded from
confirmation. A ratio that never reaches D3 is an explicit negative result.

A D3 pass supports only its exact tested `(n,m,r_G)` triplet. It does not prove
monotonicity, `n >= n_min`, intermediate marker ratios, a spectral threshold,
or general auto-routing. Any narrower public contract proposed after D3 must
first amend doc 44 with an enforceable prospective admission rule and then
receive independent confirmation on still-fresh seeds.

#### Stage D4 — original nine-cell broad confirmation

D4 is separately presealed from D3 and is the only v3 stage that can discharge
doc-44 G5. It binds authenticated D1 and terminal D2 broad-lane evidence only:
D3 is neither a predecessor nor a sizing source. Its manifest can exist only if
D1 and the mandatory D2 broad lane
produce eligible fresh pilots for all nine original cells. It then confirms all
nine exact doc-44 cells with independent fresh seeds and the unchanged
target-specific 200-to-2,000 sizing rule. The interior size comes only from D1
and each edge size only from its unique D2 batch. All nine confirmations must
pass together. If any original pilot is ineligible or any D4 cell fails, broad
activation remains withheld.

D3 and D4 use distinct roots, preseals, manifests, and disjoint seed ranges.
For D3, `campaign_pass` and `D3_PASS` refer only to the one-to-three triplets
actually admitted; partial admission never implies support for an untested
marker ratio. D4 always contains exactly the three original complete triplets,
and `D4_PASS` requires all nine original cells to pass together.

### E — Estimands and targets

| target | truth | fitted output |
| --- | --- | --- |
| genomic variance | \(\sigma_g^2=r_G\) | profile-resolved ratio times fitted total variance |
| residual variance | \(\sigma_e^2=1-r_G\) | one minus profile ratio, times fitted total variance |
| genomic variance ratio | \(r_G\) | exact profile-resolved ratio |
| total coefficient variance | 1 | \(\hat\sigma_g^2+\hat\sigma_e^2\), diagnostic only |
| projected-kernel information | exact from realised \(K_\lambda\) | \(I_r\), diagnostic only |

The total variance and spectral quantities cannot substitute for any of the
three activation estimands.

### M — Methods

The only fitted estimator is the held ordinary-form candidate on an exact
unmerged R commit: constrained Gaussian REML with exact one-dimensional profile
resolution. No competing
estimator is introduced. The independent base-R and Julia implementations are
recomputers of construction, information, and performance summaries, not
alternative fitted methods. Existing same-fixture BLUPF90 evidence remains the
external point-estimate comparator. New campaign kernels necessarily have new
precision hashes; that does not trigger a rerun. BLUPF90 is rerun only if the
frozen comparator fixture or estimator contract changes.

### P — Performance measures

For target \(\theta\), with finite converged estimates in one cell:

\[
\operatorname{bias}(\hat\theta)=\bar{\hat\theta}-\theta,\qquad
MCSE_{bias}=s_{\hat\theta}/\sqrt{n_{bias}},
\]

\[
RMSE=\sqrt{n_{bias}^{-1}\sum(\hat\theta-\theta)^2}.
\]

The three conjunctive primary activation endpoints are bias equivalence for
\(\sigma_g^2\), \(\sigma_e^2\), and \(r_G\). The primary mechanism endpoint is
\(C_c\), diagnostic only. Secondary endpoints are convergence/Wilson interval,
boundary proportions, total-variance bias, RMSE, runtime, RSS, spectral CV, and
effective rank.

For nonzero RMSE, report

\[
MCSE_{RMSE}=\frac{sd\{(\hat\theta-\theta)^2\}}
{2\,RMSE\sqrt{n_{bias}}};
\]

when RMSE is exactly zero, report `MCSE_RMSE = 0` only if every squared error is
exactly zero, otherwise `NA` with a failure flag. Report the Student-t 95%
Monte Carlo interval for mean bias, convergence and
its Wilson 95% interval, resolved lower/upper boundary proportions and binomial
MCSEs, empirical SD, median and 95th percentile runtime/RSS, and the ratio of
empirical SD to RMS `SE_info`. Runtime/RSS percentiles are descriptive; any
bootstrap interval is explicitly labelled deterministic percentile bootstrap.
No failed or endpoint fit is deleted.

For D1 and D2 boundary summaries, all 48 attempts remain in the denominator:

\[
\hat p_L=n_L/48,\qquad \hat p_U=n_U/48,\qquad
MCSE(\hat p)=\sqrt{\hat p(1-\hat p)/48}.
\]

Unresolved and error attempts remain in that denominator and are reported in
their own failure classes.

The D1 summary contract is identical in the independent R and Julia
recomputers. For each target, `required_n_raw` is the integer ceiling of the
preregistered precision calculation. `required_n` is the largest of the three
target-specific ceilings, clamped to at least 200, and is repeated on all three
target rows for that cell. Evidence admission precedes cell classification:
any corpus, route, fingerprint, invariant, or cross-language mismatch produces
the stage-level status `RECOMPUTATION_BLOCKER` and no scientific cell status is
minted. For an admitted corpus, cell status uses this precedence:

```text
STOP_LOW_PILOT_CONVERGENCE  fewer than 46 of 48 successful finite fits
PRECISION_BLOCKER           required_n exceeds 2000
FUTILITY_STOP               any target interval lies wholly beyond its margin
ELIGIBLE                    every preceding condition is false
```

Each cell also retains separate Boolean reason fields for low convergence,
nonfinite summary inputs, precision blocking, and futility; the primary status
does not erase secondary reasons. Nonfinite summary inputs after at least 46
successful finite fits are an invariant failure and therefore a stage-level
`RECOMPUTATION_BLOCKER`, not an ordinary low-convergence result.
The ordered D1 summary schema places `low_convergence`, `summary_nonfinite`,
`precision_blocked`, and `futility_stopped` immediately after `required_n`,
before the existing target- and cell-decision fields.

Resolved boundary counts include successful fits only. `n_unresolved` counts
unsuccessful `boundary_unresolved` attempts, and `n_error` counts every other
unsuccessful attempt; these counts plus the resolved counts must equal all 48
attempts. Persisted scientific runtime and RSS summaries use all official R
attempts; Julia direct-replay runtime/RSS are route diagnostics and never
replace official performance fields. Spectral means use all
admitted packets. RMS `SE_info` and the empirical ratio standard deviation use
the same finite-success subset. `failure_classes` is a lexically sorted,
all-attempt `class=count` representation, including `none=48` when appropriate.
Any R/Julia disagreement in these fields is a recomputation blocker, regardless
of the otherwise implied cell status.

### Downstream ordered schemas (prospective amendment)

The downstream manifest has these exact ordered columns:

```text
stage cell_id cell_index seed_offset seed n m marker_ratio
marker_ratio_code truth_sigma_g2 truth_sigma_e2 truth_ratio ridge
```

The official-attempt schema is the manifest schema followed by
`retained_m`, the marker/ID/kernel/precision hashes, and the frozen result
columns through `preseal_sha256`. It contains neither `manifest_sha256` nor
`corpus_lock_sha256`.

The post-lock base-R row has exactly the official columns followed by:

```text
manifest_sha256 corpus_lock_sha256 source_r_attempt_sha256
source_r_max_abs_difference r_recomputer_commit r_recomputer_sha256
```

The post-lock Julia replay row has exactly the official columns followed by:

```text
manifest_sha256 corpus_lock_sha256 source_r_attempt_sha256
source_r_max_abs_difference julia_replay_commit julia_replay_sha256
```

`source_r_attempt_sha256` is the digest of that seed's exact official row.
`source_r_max_abs_difference` is the row-wise maximum over the shared
scientific parity projection and must be finite, nonnegative, and no larger
than `1e-10`. Base R retains the official result `route` and performance fields
because it independently reconstructs construction and summaries without
refitting. Julia uses `route = julia_profile_replay`, its replay-tool commit,
and its own runtime/RSS. The shared scientific parity projection is every
official column except `route`, `driver_commit`, `runtime_seconds`,
`peak_rss_mb`, `r_implementation_commit`, and
`julia_implementation_commit`. Those deliberately route-specific fields are
validated against their own preseal bindings, never compared as scientific
parity fields.

The D2 summary is exactly the ordered D1 summary schema. The D3/D4 confirmation
summary is:

```text
stage cell_id cell_index n m marker_ratio truth_ratio
n_expected n_attempted n_converged n_bias_rows n_interior
n_interior_rescued n_boundary_lower n_boundary_upper n_unresolved n_error
convergence_rate wilson_lower wilson_upper target truth mean_estimate bias
mcse bias_ci_lower bias_ci_upper margin rmse mcse_rmse empirical_sd
summary_nonfinite target_bias_pass cell_convergence_pass cell_wilson_pass
target_pass cell_pass cell_status median_runtime_seconds p95_runtime_seconds
median_peak_rss_mb p95_peak_rss_mb rms_se_info
empirical_sd_over_rms_se_info observed_boundary_lower observed_boundary_upper
mcse_boundary_lower mcse_boundary_upper mean_spectral_cv mean_effective_rank
triplet_id triplet_pass campaign_pass stage_decision failure_classes
```

The predecessor lock is ordered as:

```text
stage sequence_index role source_stage source_batch source_root
adjudication_receipt_sha256 preseal_sha256 manifest_sha256
corpus_lock_sha256 r_summary_sha256 julia_summary_sha256
r_validator_sha256 julia_validator_sha256
```

The pilot-decision lock is ordered as:

```text
stage sequence_index source_stage source_batch selection_role cell_id
eligible required_n required_n_source_target source_summary_sha256
```

For D3 and D4, any nonfinite admitted summary yields
`RECOMPUTATION_BLOCKER`. Otherwise the stage decision is `D3_PASS` or
`D3_FAIL`, and `D4_PASS` or `D4_FAIL`, respectively.
`campaign_pass` covers exactly the complete triplets admitted to that stage;
D4's admitted set is always the original three.

For every D2-D4 cell, `n_attempted = n_expected`, `n_bias_rows = n_converged`,
the four resolved counts sum to `n_converged`, and resolved + unresolved +
error equals `n_expected`. Both Wilson limits, the convergence rate, both
observed boundary proportions, and both boundary MCSEs are recomputed from
those counts. `failure_classes` is lexically ordered, totals exactly
`n_expected`, and has `none = n_converged`. Any violation is a recomputation
blocker. A D2 cell with nonfinite summary inputs despite at least 46 successful
finite fits has `cell_status = RECOMPUTATION_BLOCKER`, is never eligible,
cannot produce a pilot-decision lock, and cannot appear in an admitted
predecessor history. With fewer than 46 successful fits, expected undefined
dispersion inputs remain an ordinary `STOP_LOW_PILOT_CONVERGENCE` result and do
not stop other cells from advancing. The same blocker status is used for any
nonfinite D3/D4 cell; its stage decision is `RECOMPUTATION_BLOCKER`.

An unsuccessful attempt has `status = fit_error`, `converged = false`, and a
non-`none` `error_class`. Scientific and numerical components, total variance,
iterations, objective, and gradient are canonical `NA`. An ordinary fit error
also has canonical `NA` boundary status/reason/epsilon/profile/derivatives. A
`boundary_unresolved` error instead carries its nonempty reason and exact
boundary epsilon; profile log likelihood and both endpoint derivatives are
either all finite or all `NA`, never partial. Independent replay compares these
unresolved evidence fields exactly within the frozen numerical tolerance; a
matching failure label alone is insufficient. Runtime/RSS and admitted
construction/spectral fields remain finite for every attempted packet.

## 4. Fresh seed contract and immutable outputs

Before choosing any v3 seed, generate and commit
`historical_seed_lock.tsv`, covering every prior manifest and every reserved
formula range in docs 44, 47, and 48. The verifier expands all ranges and proves
zero intersection with every proposed D0F/D1/D2/D3/D4 seed and uniqueness
within v3. The new recovery stages use

```text
seed = 2028000000 + 10000 * cell_index + seed_offset
```

with a canonical cell table committed before presealing. Offsets are:

`docs/design/v07_genomic_recovery_v3_cell_table.tsv` is the sole source of
cell IDs and indices for the state machine, seed-space verifier, manifest
writer, and both recomputers. Every consumer verifies its exact schema, row
order, content, and SHA-256 sidecar. Independently regenerated cell IDs are not
admitted. `marker_ratio_code` and exact `(n,m)` are identity fields; decimal
`marker_ratio` is descriptive and compared at `1e-12`.

- D1 pilot: `101:148`;
- D2 edge pilot for `n=120`: `1001:1048`;
- D2 edge pilot for `n=300`: `1101:1148`;
- D2 edge pilot for `n=600`: `1201:1248`;
- D2 edge pilot for `n=1200`: `1301:1348`;
- D3 selected-triplet confirmation: prefixes of `2001:4000`; and
- D4 original-cell confirmation: prefixes of `5001:7000`.

The cell index includes `n`, `m`, and `r_G`, so no seed is shared across cells
or stages. The blocked D0F run consumed and permanently retired the exact 576
phenotype seeds
`2029000000 + 100000 * design_index + 1000 * panel_rank + phenotype_rank`, with
`design_index = 1:3`, `panel_rank = 1:24`, and `phenotype_rank = 1:8`. The
source-safe verifier expands that true 3-by-24-by-8 grid as `D0F_RETIRED` and
adds it to the spent historical space; the prior erroneous 3-by-8-by-24 audit
expansion is not the record of seeds actually consumed. The blocked first
retry's 576 seeds use the same rank formula with base `2032000000`; the verifier
adds them to the retired space as `D0F_RETRY1_RETIRED`. The third prospective
retry uses base `2034000000` and is labelled `D0F_RETRY` in the seed-space
audit. The operational manifest stage remains `d0f` so the unchanged
scientific schema is reused. All values remain below R's 32-bit integer maximum.
All exact historical and retired seeds are excluded. Numeric offsets may recur
only under a new base after the verifier proves exact zero intersection. No
failed or blocked seed is replaced. Mutations introducing a retired-D0F seed,
the previously detected collision `2027142001`, or a duplicate must make the
historical-lock verifier red.

D0F bootstrap-index seeds are not phenotype seeds and are never fitted. The
original blocked run's three seeds `2031000000 + design_index` and the blocked
first retry's three seeds `2033000000 + design_index` are nevertheless spent
and retired because they generated observed bootstrap manifests. The third
retry uses `2035000000 + design_index`, one per design. All three sets must be
unique and in range; the current retry set must be disjoint from every
historical, retired D0F, blocked D0F retry, D1, D2, D3, and D4 data-generating
seed.

Every stage uses this acyclic create-once evidence chain:

1. Write and verify the design copy, committed 36-cell table,
   historical-seed lock, stage manifest, environment manifest, reviewer
   receipts, and the D0F fixed-panel/bootstrap manifests when applicable. Then
   write `stage_preseal.tsv` last. The preseal binds those existing primaries
   and sidecars, exact implementation commits/tool hashes, both route names,
   packet/truth schema versions, the canonical stage root, and the exact D0
   receipt. D1 additionally binds the canonical successful fresh-D0F root and
   adjudication-receipt SHA-256. It contains no future D1 corpus or result hash.
2. Generate official attempts and packets only after the preseal is accepted.
   Every attempt binds `preseal_sha256`. Before generation, the stage root may
   contain only the enumerated preseal inputs and their sidecars; attempts,
   packets, recomputations, summaries, corpus locks, and adjudication receipts
   must be absent.
3. After the exact manifest denominator is complete, write
   `stage_corpus_lock.tsv`. It binds the preseal, manifest, every official
   attempt, and every packet primary. Exact-tree validation rejects additional,
   missing, partial, nested, symlinked, empty-directory, or special-file
   members.
4. Independent base-R and Julia recomputations bind both `preseal_sha256` and
   `corpus_lock_sha256`. Only after their exact output trees and summaries agree
   may the formal adjudicator write `stage_adjudication_receipt.tsv`, which
   binds the official corpus, both recomputation corpora, summaries, stage
   decision, and post-run review verdicts.

No file may bind the hash of a future file that transitively contains its own
hash. In particular, a preseal never contains `corpus_lock_sha256`; this avoids
the impossible cycle preseal -> attempt -> corpus lock -> preseal contents.
Every primary has a SHA-256 sidecar. Both independent recomputers must reproduce
construction, spectral diagnostics, counts, performance measures, sizing, and
stage decisions to `1e-10` before the next manifest can exist.

The canonical stage-root primaries are `doc49.md`, `cell_table.tsv`,
`historical_seed_lock.tsv`, `<stage>_manifest.tsv`, and
`environment_manifest.tsv`; D0F additionally has
`d0f_fixed_panel_manifest.tsv` and `d0f_bootstrap_indices.tsv`. The only
preseal receipt directory is `receipts/`, containing exactly `fisher.tsv`,
`noether.tsv`, `hopper.tsv`, `grace.tsv`, and `rose.tsv`. Every primary has an
adjacent `.sha256` sidecar. The final preseal primary is `stage_preseal.tsv`.
Tools are verified at explicit canonical deployed paths outside the stage root.
No aliases or alternate filenames are admitted.

Every downstream D2/D3/D4 root additionally contains the canonical primaries
`predecessor_lock.tsv` and `pilot_decision_lock.tsv`, each with its adjacent
sidecar. A downstream preseal binds both lock hashes; the exact terminal history
head and batch sequence; the downstream-contract hash and commit; the official
driver, independent R validator, and Julia validator hashes and commits; the
manifest, environment, cell table, historical seed lock, candidate commits,
routes, relationship scale, ridge, and boundary controls. It contains no
future corpus, recomputation, summary, or receipt hash.

The dedicated downstream numerical validators are, for every D2, D3, and D4
root:

```text
tools/v07_genomic_recovery_v3_downstream_recompute.R
  --mode=validate-final --output-root=<root> --stage=d2|d3|d4

HSquared.jl/sim/phase2_v07_genomic_recovery_v3_downstream_replay.jl
  --mode=validate-final --output-root=<root> --stage=d2|d3|d4
```

Each validator has a SHA-256 sidecar, is bound by the preseal and final receipt,
and must actually be executed with the exact `--mode=validate-final` CLI before
a D2 root can be read as predecessor evidence. Verifying the validator file's
sidecar without executing it is insufficient. Each operational validator reads
the root's authenticated `cell_table.tsv`, verifies its sidecar and preseal
hash, and derives cell identity from those bytes; it may independently
regenerate a table only as a comparison that must agree exactly. Each validator
reconstructs the complete final tree from immutable primaries. The
synthetic confirmation mirror is not an operational validator. The ordered
downstream receipt binds both locks, preseal, manifest, official corpus,
base-R and Julia inventories and summaries, validator hashes and commits,
attempt and summary parity maxima, the six post-run review receipts, and the
stage decision.

The downstream preseal schema identifier is
`v07-genomic-recovery-v3-downstream-preseal-1`. Its ordered keys are:

```text
schema_version
stage
doc49_sha256
cell_table_sha256
historical_seed_lock_sha256
manifest_sha256
environment_manifest_sha256
predecessor_lock_sha256
pilot_decision_lock_sha256
history_state
history_batch_count
current_sequence_index
fisher_receipt_sha256
noether_receipt_sha256
hopper_receipt_sha256
grace_receipt_sha256
rose_receipt_sha256
downstream_contract_commit
downstream_contract_sha256
r_driver_commit
r_recomputer_commit
julia_replay_commit
r_auto_route_commit
julia_candidate_commit
r_driver_sha256
r_recomputer_sha256
julia_replay_sha256
output_root
official_route
replay_route
packet_schema_version
truth_schema_version
relationship_source
relationship_method
allele_frequency_source
relationship_scale
ridge
boundary_epsilon
boundary_kkt_tolerance
output_subtrees_absent_before_preseal
```

`history_state` is `ordered_prefix` for the next D2 batch and `terminal`
for D3/D4. If the predecessor lock contains D1 at sequence zero plus `k`
completed D2 batches at exactly `1:k`, then `history_batch_count = k` and a new
D2 preseal has `current_sequence_index = k + 1`. D3/D4 require terminal history
and `current_sequence_index = NA`. The downstream adjudication-receipt schema identifier is
`v07-genomic-recovery-v3-downstream-adjudication-1`. Its ordered columns are:

```text
schema_version stage verdict stage_decision preseal_sha256
predecessor_lock_sha256 pilot_decision_lock_sha256 manifest_sha256
corpus_lock_sha256 base_r_inventory_sha256 julia_inventory_sha256
r_summary_sha256 julia_summary_sha256 r_validator_sha256
julia_validator_sha256 r_driver_commit r_recomputer_commit julia_replay_commit
attempt_max_abs_difference summary_max_abs_difference
fisher_review_sha256 darwin_review_sha256 noether_review_sha256
hopper_review_sha256 grace_review_sha256 rose_review_sha256
```

Each **prospective plan-review** receipt has exactly these ordered columns:

```text
reviewer verdict doc49_sha256 r_driver_commit r_recomputer_commit
julia_replay_commit r_auto_route_commit julia_candidate_commit
```

Each **post-run evidence-review** receipt uses schema identifier
`v07-genomic-recovery-v3-downstream-postrun-review-1` and has exactly:

```text
schema_version stage reviewer verdict stage_decision preseal_sha256
predecessor_lock_sha256 pilot_decision_lock_sha256 manifest_sha256
corpus_lock_sha256 base_r_inventory_sha256 julia_inventory_sha256
r_summary_sha256 julia_summary_sha256 r_driver_commit
r_recomputer_commit julia_replay_commit reviewed_at_utc
```

The prospective set is Fisher, Noether, Hopper, Grace, and Rose. The post-run
set is Fisher, Darwin, Noether, Hopper, Grace, and Rose; every verdict must be
`CLEAN`, and every evidence field must equal the final adjudication receipt.
The two schemas are not interchangeable.

Thus a plan receipt cannot review only the harness while leaving either fitted
candidate implementation unbound. The R auto-route commit must be an ancestor
of the deployed R driver/recomputer commit, and the Julia candidate commit must
be an ancestor of the deployed Julia replay commit. Each deployed tool's bytes
must equal its exact Git blob at the declared commit and its sidecar; existence
of a commit object alone is insufficient. All declared R tool commits must
equal the deployed R `HEAD`, and the Julia replay commit must equal the deployed
Julia `HEAD`. The R implementation surfaces (`R/`, `DESCRIPTION`, `NAMESPACE`)
and Julia implementation surfaces (`src/`, `ext/`, `Project.toml`,
`Manifest.toml`) must be unchanged between the fitted candidate and deployed
tool commits. Both deployed repositories must have empty
`git status --porcelain` output when a preseal is minted.

Environment admission compares the manifest with live state: normalized
hostname, R and Julia versions, R RNG/normal/sample kinds, process thread
variables, Julia's live BLAS and Julia thread counts, and the worker cap. A
synthetic manifest containing merely plausible strings is not evidence. Every
required primary must be a nonempty regular file before its sidecar can pass.
The exact D0 root and receipt hash printed above are constants; callers cannot
substitute another canonical root/hash pair.

The frozen schema identifiers are:

```text
preseal  v07-genomic-recovery-v3-stage-preseal-2
packet   v07-genomic-recovery-v3-packet-1
truth    v07-genomic-recovery-v3-truth-1
```

For D0F and D1, `stage_preseal.tsv` contains exactly these keys in this order:

```text
schema_version
stage
doc49_sha256
cell_table_sha256
manifest_sha256
environment_manifest_sha256
d0_output_root
d0_adjudication_receipt_sha256
d0_diagnostics_sha256
d0f_adjudication_root
d0f_adjudication_receipt_sha256
historical_seed_lock_sha256
d0f_fixed_panel_manifest_sha256
d0f_bootstrap_indices_sha256
fisher_receipt_sha256
noether_receipt_sha256
hopper_receipt_sha256
grace_receipt_sha256
rose_receipt_sha256
r_driver_commit
r_recomputer_commit
julia_replay_commit
r_auto_route_commit
julia_candidate_commit
r_driver_sha256
r_recomputer_sha256
julia_replay_sha256
d0_recomputer_sha256
output_root
official_route
replay_route
packet_schema_version
truth_schema_version
relationship_source
relationship_method
allele_frequency_source
relationship_scale
ridge
boundary_epsilon
boundary_kkt_tolerance
output_subtrees_absent_before_preseal
```

For D0F and D1, the tool keys are language-specific and unambiguous.
`r_driver_sha256` binds
`tools/v07_genomic_recovery_v3.R`; `r_recomputer_sha256` binds the operational
independent `tools/v07_genomic_recovery_v3_recompute.R` (not the pure preseal
helper); `julia_replay_sha256` binds
`sim/phase2_v07_genomic_recovery_v3_stage_replay.jl`; and the single
`d0_recomputer_sha256` key binds the R
`tools/v07_genomic_recovery_v3_d0_recompute.R`. The Julia spectral helper is
loaded from, and therefore fixed by, the exact clean `julia_replay_commit`; it
does not reuse the R D0-tool key.

D2-D4 do not reuse those D0F/D1 validator keys. They use the dedicated
downstream preseal and the two downstream numerical validators frozen above.

D0F records `NA` for the two D1-only adjudication bindings. D1 records `NA` for
the two D0F-only manifest hashes and must record a non-`NA` canonical fresh-D0F
root and receipt digest. The official and replay routes are respectively
`ordinary_auto_genomic` and `julia_profile_replay`.
Every Julia replay row binds and verifies the actual source R attempt,
manifest, preseal, corpus lock, replay driver, and replay commit using the
ordered fields `source_r_attempt_sha256`, `source_r_max_abs_difference`,
`replay_julia_commit`, `replay_driver_sha256`, `manifest_sha256`,
`preseal_sha256`, and `corpus_lock_sha256`.
The common `driver_commit` result field is route-specific: official
`ordinary_auto_genomic` attempts carry `r_driver_commit`, while
`julia_profile_replay` rows carry `julia_replay_commit`. Admission must reject
either route carrying the other route's driver commit.

The post-run tree is also canonical. Official rows live at
`attempts/<stage>/<group>/<seed>.tsv`; packets live at
`packets/<stage>/<group>/<seed>/`, with `<group>` equal to `design_id` for D0F
and `cell_id` otherwise. The official corpus lock is the root-level
`stage_corpus_lock.tsv`. Base-R verification rows live at
`base_r_recompute/<stage>/<group>/<seed>.tsv`; Julia direct-replay rows live at
`julia_replay/<stage>/<group>/<seed>.tsv`. Their root-level summaries are
`<stage>_summary_r.tsv` and `<stage>_summary_julia.tsv`. The final root-level
`stage_adjudication_receipt.tsv` binds the preseal, official corpus lock, exact
inventories of both recomputation subtrees, both summaries, and the stage
decision. Every TSV has an adjacent `.sha256` sidecar. Phase-specific exact-tree
validation rejects any alternate name, extra file, directory, symlink, FIFO,
socket, device, or empty directory. The corpus lock binds only immutable
official attempts and packets; recomputation outputs are created afterwards
and are bound by the adjudication receipt, preserving the acyclic dependency.

## 5. Admission, selection, and stopping rules

For each pilot cell and target, retain the recovery-v2 one-sided 95% upper SD
bound

\[
s_U=s\sqrt{(n_{conv}-1)/\chi^2_{0.05,n_{conv}-1}}
\]

and sizing rule

\[
N_{req}=\left\lceil
\left\{1.96s_U/(\Delta/2)\right\}^2
\right\rceil.
\]

A D1 or D2 cell is eligible only when:

1. at least 46 of 48 attempted fits converge with all targets finite;
2. the largest target-specific `N_req` is at most 2,000;
3. no target's pilot 95% Monte Carlo bias interval lies wholly outside its
   frozen equivalence interval; and
4. all construction, route, KKT, fingerprint, corpus, and three-way
   recomputation gates pass.

Condition 3 is a futility stop, not a pilot success claim. An overlapping pilot
interval does not prove recovery and cannot replace D3.

D1 eligibility is deterministic. D2 traverses only D1-eligible values in
ascending order and selects the first whose two unique edge batches also meet
all four conditions. No alternative cell may be substituted after observing
results.

D3 uses the unchanged confirmation gates from recovery-v2:

- the entire Student-t 95% Monte Carlo interval for each mean bias lies strictly
  inside its frozen margin;
- observed convergence is at least 95%;
- the Wilson 95% lower bound for convergence is at least 90%; and
- every attempted seed remains in the denominator.

Any failed target fails its cell. Any failed cell fails its selected exact-cell
triplet. Partial success is reported by exact `(n,m,r_G)` cell only. Only D4
can satisfy doc-44's original broad G5 gate.

Mandatory stops:

- a D0 replay disagreement stops before v3 presealing;
- a one-fit or 16-worker smoke with empty, nonfinite, malformed, or mismatched
  output stops scale-up;
- pilot convergence below 46/48 stops that cell;
- `N_req > 2000` stops that cell without truncation;
- a pilot bias interval wholly beyond a margin stops that cell as futile;
- a runtime/RSS smoke that cannot stay within 96 workers and 70% of available
  Totoro RAM triggers right-sizing or DRAC submission, never a local overcommit;
- no public or status wording changes before independent D4 recomputation and
  the full doc-44 Fisher, Darwin, Noether, Hopper, Grace, and Rose audits; and
- no default-route merge or capability/count change without explicit G10.

## 6. Tests of the tests

Before a v3 preseal is admitted, deliberate mutations must make at least one gate
red for each of:

- an eigenvalue, spectral CV, effective rank, or `SE_info`;
- an estimate, truth, fitted total variance, or boundary status;
- `n`, `m`, marker ratio, cell index, cell label, seed, or stage membership;
- ridge, relationship method/scale, marker hash, kernel hash, precision hash,
  or ID order;
- a retained failure, duplicated seed, missing attempt, extra packet, corrupted
  checksum, or pilot/confirmation overlap;
- D1 eligibility, ascending D2 traversal, one-batch-per-cell mapping, D3 pilot
  source mapping, and D4 original-cell admission;
- a missing, duplicated, reordered, forked, or stale D2 history head;
- a changed `sequence_index`, `selection_role`, or
  `required_n_source_target`;
- a caller-selected validator, forged lock row with a fresh sidecar, or the
  synthetic mirror substituted for an operational validator;
- a D3 manifest with zero, more than three, or an incomplete selected triplet,
  and a D4 manifest that binds any D3 artifact or lacks an original triplet;
- `corpus_lock_sha256` inserted into an official-attempt row;
- logical TSV values and both valid Boolean inversions; and
- one changed summary value in each of the driver-R, independent base-R, and
  Julia recomputations.

The verifier must first be shown green on a synthetic valid fixture and then
red under every mutation.

## 7. Compute sequence

1. Run D0 locally and independently in R and Julia; commit only the compact
   replay summary and hashes. Run and adjudicate fresh D0F separately as
   mechanism evidence. Do not prepare D1 unless the exact D0F receipt is
   `PASS`/`COMPLETE`.
2. On Totoro, bind that successful D0F root and receipt into D1 preparation and
   preseal, verify the deployed commits and environment, then run one D1 fit
   at each `n` with `OPENBLAS_NUM_THREADS=1` and one Julia thread.
3. Run a 16-worker smoke and inspect the first completed attempt plus packet.
4. Set production workers to
   `min(96, floor(0.7 * available_RAM / smoke_peak_RSS))`.
5. Run D1, corpus-lock and independently adjudicate it, then mint D2 only from its
   receipt.
6. Do not prepare D2 until this amended doc hash, renewed plan-review receipts,
   both dedicated numerical validators, their synthetic mutation suites, and
   exact D1 final-tree validation are green. Then run and adjudicate each
   deterministic D2 batch; mint D3 only for selected
   exact triplets, and D4 only if all original pilots are eligible.
7. Run any admitted D3 and D4 stages, independently recompute them in both
   languages, mutation-test the adjudicator, and request the applicable audits.

No heavy campaign runs on GitHub Actions. Raw attempts and packets stay in a
new immutable Totoro output root. Only the preregistration, manifests, compact
summaries, hashes, failure classifications, exact commands, and environment
manifest may be committed.

Commit `120d04d` and the Julia canonical confirmation mirror are pure
schema/logic evidence: neither is a fit, recovery, or campaign result. D2 is
sizing and selection evidence only. D3 supports only its admitted exact
triplets. D4 pass discharges only doc-44 G5; G6-G7 audits and explicit G10
remain mandatory, and `public_covered_count` remains unchanged.

## 8. Decision table

| evidence | decision |
| --- | --- |
| D0 diagnostic fit is weak or surprising | report it; do not change or stop D1 |
| fresh D0F has no exact `PASS`/`COMPLETE` receipt | stop before D1 prepare/preseal; never substitute the blocked root |
| D0 R and Julia disagree | stop and localise the first differing eigenvalue or formula |
| no D1 cell eligible for a marker ratio | record that ratio unsupported; no D2/D3 |
| D2 edge fails at one eligible \(n\) | keep it failed; continue ascending through larger D1-eligible values, one immutable batch each |
| no D2 candidate passes | record that marker ratio unsupported |
| D3 cell fails | no confirmed exact triplet for that marker ratio |
| one or more D3 triplets pass | report exact supported cells; original broad G5 remains open |
| any original pilot is ineligible | D4 cannot exist; broad activation remains withheld |
| all nine D4 cells pass | proceed to G6–G7 broad-activation audits |
| a narrower public contract is proposed | prospectively amend doc 44, define an enforceable admission rule, repeat the full Fisher/Darwin/Noether/Hopper/Grace/Rose review, and use fresh confirmation seeds |
| G1–G7 pass but no G10 | keep activation/status candidate unmerged and count unchanged |

## 9. Williams et al. 11-item self-audit

| # | Item | Status | Where addressed |
| ---: | --- | --- | --- |
| 1 | Aims | complete | Section 3, A |
| 2 | DGP + `n_sim` justified | complete | Sections 3D, 4, and 5 |
| 3 | Estimand / target | complete | Sections 2 and 3E |
| 4 | Methods literature cited | complete | Section 3 introduction and 3M |
| 5 | Performance measures with formulas | complete | Section 3P |
| 6 | Software / packages / versions | pending preseal | Section 4 requires an environment-bound preseal |
| 7 | Code for DGP available | pending implementation | v3 driver required before admission |
| 8 | Code for performance measures | pending implementation | independent R and Julia recomputers required |
| 9 | Worked-example case study | complete for held route identity, not public availability or robustness | doc 44 G2–G4 fixture chain |
| 10 | Full performance table | pending evidence | D0–D4 summaries |
| 11 | MCSE reported alongside | frozen | Section 3P and every v3 summary schema |

## 10. Research and review provenance

The redesign was informed by Morris et al. and Williams et al., a scoped
NotebookLM notebook (`a45fcd26-9f0f-486b-a3da-ae72a278efe1`), immutable
recovery-v2 packets, and live-source inspection. NotebookLM was used only for
research triage. One generated suggestion treated `n << m` as automatically
favouring recovery; the exact projected-kernel information and live pilot show
that this inference is not valid for the present two-component HWE/no-LD
design. Repository equations, executable replay, and primary methods sources
control the contract.

Plan-review roles:

- Fisher/Curie: ADEMP design, sizing, futility, and equivalence logic;
- Gauss/Noether: profile information, spectral quantities, and numerical
  interpretation;
- Hopper: exact held bridge commit and end-to-end route parity;
- Grace: immutable evidence, environment, and local/CI boundary;
- Rose: original-scope preservation and claim-versus-evidence audit; and
- Darwin: quantitative-genetic interpretation before any activation conclusion.

No reviewer receipt is valid until it binds the committed doc-49 hash and the
exact R and Julia implementation commits. Pre-seal admission requires Fisher,
Noether, Hopper, Grace, and Rose. A mechanism-only closeout may stop there. Any
public/default-route conclusion requires the complete doc-44
Fisher/Darwin/Noether/Hopper/Grace/Rose audit after D4.
