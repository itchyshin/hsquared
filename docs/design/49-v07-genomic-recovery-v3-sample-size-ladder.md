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

Status: **PREREGISTRATION DRAFT — NO V3 SEED IS ADMITTED.** This document must
receive hash-bound pre-seal plan receipts from Fisher, Noether, Grace, and Rose,
plus Hopper for the exact held bridge commit, be committed, and be bound into a
new campaign seal before any recovery-v3 phenotype is generated. It does not
reopen, rewrite, or admit the retired recovery-v2 offsets.

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
  kernels separately from variation across newly drawn marker panels; and
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

Remove realised monomorphic columns without redrawing. From the retained panel,
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

#### Stage D0F — fixed-kernel phenotype replication

This mandatory mechanism-only arm uses the eight smallest manifest seeds from
each of the three original \(r_G=0.5\) v2 cells: `(120,600)`, `(300,150)`, and
`(300,1000)`. Their marker, kernel, precision, and ID hashes are written to a
create-once fixed-panel manifest and verified against the D0 corpus before any
phenotype draw. For each of the 24 fixed kernels, generate 24 independent fresh
phenotypes at \(r_G=0.5\), giving 576 fits. Marker panels are never redrawn in
this arm.

For panel \(k\) and phenotype replicate \(j\), store \(\hat r_{kj}\). Within
each of the three designs report

\[
V_{within}=8^{-1}\sum_k s_k^2,\qquad
V_{between}=\operatorname{Var}_k(\bar r_k)-V_{within}/24,
\]

without truncating a negative finite-sample \(V_{between}\). A deterministic
two-level bootstrap resamples panels and then phenotypes within panel, using a
sealed index manifest, and reports percentile intervals. D0F is diagnostic and
never enters D1/D2 sizing, D3/D4 recovery, or a capability claim.

#### Stage D1 — fresh interior ladder

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

#### Stage D3 — selected exact-triplet confirmation

A marker ratio reaches D3 only when the same selected \(n\) is eligible at all
three \(r_G\) values. D3 confirms exactly those three cells with fresh seeds and
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

D4 is separately sealed from D3 and is the only v3 stage that can discharge
doc-44 G5. Its manifest can exist only if D1 and the mandatory D2 broad lane
produce eligible fresh pilots for all nine original cells. It then confirms all
nine exact doc-44 cells with independent fresh seeds and the unchanged
target-specific 200-to-2,000 sizing rule. The interior size comes only from D1
and each edge size only from its unique D2 batch. All nine confirmations must
pass together. If any original pilot is ineligible or any D4 cell fails, broad
activation remains withheld.

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

## 4. Fresh seed contract and immutable outputs

Before choosing any v3 seed, generate and commit
`historical_seed_lock.tsv`, covering every prior manifest and every reserved
formula range in docs 44, 47, and 48. The verifier expands all ranges and proves
zero intersection with every proposed D0F/D1/D2/D3/D4 seed and uniqueness
within v3. The new recovery stages use

```text
seed = 2028000000 + 10000 * cell_index + seed_offset
```

with a canonical cell table committed before sealing. Offsets are:

- D1 pilot: `101:148`;
- D2 edge pilot for `n=120`: `1001:1048`;
- D2 edge pilot for `n=300`: `1101:1148`;
- D2 edge pilot for `n=600`: `1201:1248`;
- D2 edge pilot for `n=1200`: `1301:1348`;
- D3 selected-triplet confirmation: prefixes of `2001:4000`; and
- D4 original-cell confirmation: prefixes of `5001:7000`.

The cell index includes `n`, `m`, and `r_G`, so no seed is shared across cells
or stages. D0F phenotype seeds use the disjoint formula
`2029000000 + 100000 * design_index + 1000 * panel_rank + phenotype_rank`, with
`panel_rank = 1:8` and `phenotype_rank = 1:24`. All values remain below R's
32-bit integer maximum. All exact historical seeds are excluded. Numeric
offsets may recur only under the new base after `historical_seed_lock.tsv`
proves zero exact-seed intersection. No failed seed is replaced. A synthetic
collision mutation and the previously detected collision `2027142001` must make
the historical-lock verifier red.

The v3 seal, manifests, attempts, packet locks, corpus locks, summaries, and
adjudication receipts inherit recovery-v2's create-once and fail-closed rules.
Every primary has a SHA-256 sidecar. Both independent recomputers must reproduce
construction, spectral diagnostics, counts, performance measures, sizing, and
stage decisions to `1e-10` before the next manifest can exist.

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

- a D0 replay disagreement stops before v3 sealing;
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

Before a v3 seal is admitted, deliberate mutations must make at least one gate
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
- logical TSV values and both valid Boolean inversions; and
- one changed summary value in each of the driver-R, independent base-R, and
  Julia recomputations.

The verifier must first be shown green on a synthetic valid fixture and then
red under every mutation.

## 7. Compute sequence

1. Run D0 locally and independently in R and Julia; commit only the compact
   replay summary and hashes. Run and adjudicate D0F separately as mechanism
   evidence.
2. On Totoro, verify the deployed commits and environment, then run one D1 fit
   at each `n` with `OPENBLAS_NUM_THREADS=1` and one Julia thread.
3. Run a 16-worker smoke and inspect the first completed attempt plus packet.
4. Set production workers to
   `min(96, floor(0.7 * available_RAM / smoke_peak_RSS))`.
5. Run D1, seal and independently adjudicate it, then mint D2 only from its
   receipt.
6. Run and adjudicate each deterministic D2 batch; mint D3 only for selected
   exact triplets, and D4 only if all original pilots are eligible.
7. Run any admitted D3 and D4 stages, independently recompute them in both
   languages, mutation-test the adjudicator, and request the applicable audits.

No heavy campaign runs on GitHub Actions. Raw attempts and packets stay in a
new immutable Totoro output root. Only the preregistration, manifests, compact
summaries, hashes, failure classifications, exact commands, and environment
manifest may be committed.

## 8. Decision table

| evidence | decision |
| --- | --- |
| D0 diagnostic fit is weak or surprising | report it; do not change or stop D1 |
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
| 6 | Software / packages / versions | pending seal | Section 4 requires an environment-bound seal |
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
