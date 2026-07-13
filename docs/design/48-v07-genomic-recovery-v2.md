# 48 — v0.7 genomic GREML recovery-v2 preregistration amendment

> **Status: FROZEN BEFORE ANY OFFSET-7001 DATA GENERATION.** This amendment
> operationalizes G5–G6 of `44-v07-genomic-public-activation.md` after the
> optimized boundary candidate passed its fresh offset-6001 holdout. It does
> not activate the default route, promote a capability, change
> `public_covered_count`, or authorize a release.

## 1. Admitted implementation and predecessor evidence

The campaign is admitted only when a create-once seal binds all of these exact
inputs:

| item | frozen identity |
| --- | --- |
| Julia selected implementation | `fc9d39df650b20aa09d769d9f9528eed1b606f1e` |
| Julia execution/tooling commit | `8f0f4ec2a001004f65740b2057e08c80250a2d91` |
| Julia holdout driver/execution | `fe5987c2dc5002d3b41910a0356554a8f4d7e359` |
| held R ordinary-auto-route candidate | `1082d84f4269d4f79fdc248558ec56b8f710b8d2` |
| R boundary-oracle implementation | `05ba8aed1c19a7971eeaaf3199fd1afe7d899561` |
| durable Julia holdout PASS checkpoint | `6e31575777d12263702ae1f6b28c315ade3f6705` |
| checkpoint document SHA-256 | `51307db4cc977125e21bb764bbdf8a021a2b8a5c38584dd98da26d4029ecfb3f` |
| checkpoint check-log SHA-256 | `3a25ff9423aecd158e0361ff34016f38b810c0fb530d65a0d2c02dbce24c6e83` |
| standalone base-R recomputer SHA-256 | `d07ca5012ab28e4b5b10b1649e995bd4627b03407896890ba163e96335d8ce3a` |
| Julia recomputer SHA-256 | `a61d2c70846cda0f85431429a385ca222c94afff6c81812d20bff71bb2721935` |
| boundary-v2 candidate seal SHA-256 | `e82e023957514621083df6ea7424cc2d14159aa43e9b567122a6edf944cfb724` |
| `holdout_gate.tsv` SHA-256 | `5d60afc5df62706444149544d5c4aa2d0e1a684d213d594a44a1e7eea622d5c1` |
| `holdout_timing.tsv` SHA-256 | `098b02ae95083f793de5605c85dbba6db2126cbf1daf4c5d53891969afe8c097` |
| summary-files lock SHA-256 | `4f895bbaab54dd15781ac031de8e3053d1e02eabedbec7ae19da97dca6ee873a` |

That holdout attempted 240 fresh fits, returned 40 scientific wins and zero
losses, had a 95% Clopper–Pearson lower bound of `0.9278424754944854`, returned
no invalid, unresolved, or unchanged-component errors, and passed every one of
the five frozen timing cells. Those seeds are spent. Recovery-v2 must not read,
reuse, or reinterpret them.

The driver checkout, R execution checkout, and Julia execution checkout must be
three distinct, non-nested, clean real paths. The two R checkouts are pinned to
one passed full execution/tooling commit; the Julia checkout is pinned to a
separately passed full execution/tooling commit. The seal records both commits
and proves that the R `R/` tree is byte-identical to the selected auto-route
commit above and the Julia `src/` tree is byte-identical to the selected Julia
implementation above. Thus new campaign tools may exist without silently
changing either fitted candidate. The driver commit, this document's SHA-256,
both campaign scripts' SHA-256 values, platform versions, thread settings, and
the predecessor-evidence hashes are recorded in the seal. Any mismatch stops
before a manifest or dataset is created.

Because an R tool cannot embed its own future commit without a circular hash,
the exact two execution commits are admitted by a separate create-once
execution-admission receipt after Fisher, Grace, and Rose each return `CLEAN`.
The campaign seal binds that receipt's canonical path and SHA-256 and every
later driver/recomputer invocation rechecks it. Operator-supplied clean
descendants without this exact reviewed receipt are not admissible.

Before the seal can exist, both independent recomputers must already exist and
be hash-bound: the base-R recomputer in the exact R checkout and the Julia
recomputer in the exact Julia checkout. Their source schemas must cover the
attempted denominator, upper-SD sizing, bias interval, Wilson interval, and
stopping status. Recovery does not open offset 7001 while either recomputer is
missing or incompatible.

After each tier, the campaign driver, standalone base-R recomputer, and Julia
recomputer write separate create-once summaries. Adjudication requires exact
categorical/integer agreement and numeric agreement within `1e-10` across all
three. A confirmation manifest cannot exist before pilot adjudication passes;
the final campaign verdict likewise requires confirmatory adjudication.

## 2. Exact end-to-end route

Every fit is one fresh R process and must call the public formula route:

```r
hsquared::hsquared(
  y ~ genomic(1 | id, markers = M),
  data = dat,
  family = stats::gaussian(),
  REML = TRUE
)
```

This is the ordinary public formula with no explicit engine or target control.
The held auto-route candidate injects the exact Julia project through the
process environment. The campaign tests default dispatch, public R grammar,
validation, bridge, exact selected Julia project, and the returned R object. It
is not a Julia-native or explicit-target recovery shortcut. The candidate
remains held and unmerged while the campaign runs.

The launcher may use independent OS processes, for example `xargs -P`, but
must never put `mclapply()` around JuliaCall. It sets Julia, OpenBLAS, OMP, and
vecLib threads to one. This frozen environment is Totoro-only and never GitHub
Actions. A DRAC run requires a new seal and preregistration amendment.

## 3. Frozen ADEMP design and seed space

The nine cells and estimands are unchanged from doc 44:

| `n` | `m` | regime | `r_G` |
| ---: | ---: | --- | --- |
| 120 | 600 | marker-rich relative to individuals | 0.2, 0.5, 0.8 |
| 300 | 150 | marker-limited | 0.2, 0.5, 0.8 |
| 300 | 1000 | marker-rich | 0.2, 0.5, 0.8 |

Cells are indexed in that table order with `r_G` varying fastest. Their seed
base is `2027120000 + 10000 * cell_index`.

- pilot offsets are exactly `7001:7048` in each cell;
- confirmation offsets are prefixes of `8001:10000`, sized independently by
  the pilot rule below;
- historical offsets `1:48`, confirmation `1001:3000`, holdout `5001:5048`,
  and fresh boundary holdout `6001:6048` are excluded;
- pilot and confirmation are disjoint and no failed seed is replaced.

For every seed, base R independently draws
`pi_j ~ Uniform(0.05, 0.5)` and hard calls
`M_ij ~ Binomial(2, pi_j)`, after explicitly setting
`RNGkind("Mersenne-Twister", "Inversion", "Rejection")`. The draw order is
population frequencies, marker calls, the standard-normal genomic vector, and
the residual vector. Realized monomorphic columns are removed without
redrawing. It then uses realized sample frequencies to construct

```text
p_j = colSums(M) / (2n)
W   = sweep(M, 2, 2p, "-")
k   = 2 sum(p(1-p))
G   = tcrossprod(W) / k
K   = G + 0.01 I
```

and draws `u ~ N(0, sigma_g2 K)` using `t(chol(K))`,
`epsilon ~ N(0, sigma_e2 I)`, and `y = u + epsilon`, with
`sigma_g2 = r_G`, `sigma_e2 = 1-r_G`. There is one record per individual and
an intercept-only fixed design. No-LD HWE is a studied design, not a robustness
claim.

## 4. Immutable manifests, attempts, and outputs

The seal, manifests, per-seed attempts, and summaries are create-once. The
output root must be absent until every host, checkout, version, thread,
recomputer, and predecessor-evidence check passes. A writer
creates bytes in a same-directory temporary file and claims the final name by
an exclusive hard link. It never overwrites or renames over an existing path.
Every primary file has a SHA-256 sidecar. Missing, additional, duplicated,
corrupt, or orphan primary/sidecar files make the gate red.

The manifest is the attempted denominator. A per-seed fit catches ordinary R,
bridge, construction, and Julia errors and still writes one immutable row with
an explicit failure class. A killed process leaves a missing manifest member;
summary is then forbidden rather than silently shrinking the denominator.
If failure occurs before a reconstructable packet exists, the attempt row is
retained but the missing packet makes corpus sealing and summary impossible;
that failure therefore cannot contribute to a recovery claim.
Candidate fit estimates, convergence, optimizer/boundary fields, runtime,
peak RSS, relationship method/scale, ridge, scale denominator, and marker,
ID-order, kernel, and precision fingerprints are retained. All paths and rows
are rechecked against the seal and manifest before fitting and before summary.

The scientific recovery values use the boundary-profile ratio and the fitted
numerical total variance. Define
`fitted_total_variance = numerical_sigma_g2 + numerical_sigma_e2`, then
`sigma_g2 = profile_ratio * fitted_total_variance`,
`sigma_e2 = (1-profile_ratio) * fitted_total_variance`, and
`ratio = profile_ratio`. This is deliberately a **profile-resolved ratio ×
fitted numerical total**, not an independently recovered profile total. The
numerical MME variance components and numerical ratio are recorded separately.
The exact successful status set is
`boundary_lower`, `boundary_upper`, `interior`, and `interior_rescued`.
Resolved endpoints are successful, remain in both the convergence and bias
denominators, and use scientific ratios exactly 0 or 1; they are never dropped
or replaced by epsilon-shifted numerical components.

Raw files stay local. Only manifests, compact summaries, hashes, failure
classifications, commands, and environment evidence may be committed later.
The three compact summaries are named `{tier}_summary_driver_r.tsv`,
`{tier}_summary_base_r.tsv`, and `{tier}_summary_julia.tsv`. Their schema and
arithmetic must agree to `1e-10` before confirmation. Each records the full
status breakdown (`interior`, `interior_rescued`, both boundaries, unresolved,
other error, and resolved-valid counts) and a deterministic whole-campaign
status in addition to per-cell decisions.

Before any summary is written, `{tier}_corpus_lock.tsv` binds the manifest,
every attempt primary, and every packet primary by output-relative path and
SHA-256. The driver, base-R recomputer, and Julia recomputer each verify that
same corpus. Three-way adjudication recomputes the driver summary from current
bytes and then writes `{tier}_adjudication_receipt.tsv`, binding the campaign
seal, corpus-lock hash, all three summary hashes, both recomputer hashes, and
campaign status. Confirmation can be admitted only from a currently valid
pilot receipt. Verification is an explicit exact stage machine: `sealed`,
`pilot_manifest`, `pilot_complete`, `confirm_manifest`, or `confirm_complete`;
a seal-only tree cannot pass a later stage.

## 5. Pilot sizing and frozen stopping rules

Pilot estimates never enter confirmatory bias. If any cell has fewer than 46
successful fits out of 48, the whole campaign stops before any confirmation
manifest exists. For each target, compute the one-sided 95% upper
SD bound from the finite converged pilot estimates:

\[
s_U=s\sqrt{(n_{conv}-1)/\chi^2_{0.05,n_{conv}-1}}.
\]

This is a frozen **Normal-theory planning bound**, not a distribution-free 95%
guarantee. Boundary mass can violate the Normal sampling assumption; the risk
is an underpowered negative confirmation, not permission to relax the final
equivalence gate.

Margins are `0.05 * theta` for each variance component and `0.02` for the
genomic ratio. The required confirmation denominator is

\[
N_{req}=\left\lceil(\Phi^{-1}(0.975)s_U/(\Delta/2))^2\right\rceil,
\]

using the largest target-specific value and a minimum of 200. If any cell
requires more than 2,000, the whole campaign stops with a precision blocker; it
is not truncated and no partial confirmation launches. Otherwise each cell
uses exactly offsets `8001:(8000 + N_req)`.

For confirmation, `n_attempted` is the manifest denominator and convergence
requires a reported converged fit plus all three finite estimates. Bias is
convergence-conditional and `n_bias_rows = n_converged`. For each target the
entire Student-t 95% Monte Carlo interval for mean bias must lie strictly
inside its margin. A cell additionally requires observed convergence at least
95% and the Wilson 95% lower bound at least 90%. One failed cell withholds the
broad claim; partial success is reported only by exact cell.

## 6. Tests of the tests and decision boundary

Before launch, tests must show red gates after mutating each of: an estimate, a
truth, a seed, a retained failure, a cell label, ridge, a provenance hash, ID
order, pilot/confirmation membership, or attempt status. They also exercise
two writers contending for one create-once path, missing/additional outputs,
checksum corruption, and orphan primary/sidecar files.

Passing recovery-v2 requires three-way driver/base-R/Julia recomputation and
adjudication, then permits the remaining doc-44 audits. It does not itself
activate the default route. Until the full chain and explicit maintainer G10
decision, the genomic row remains partial, the default route remains held, and
`public_covered_count` remains 5.
