# 44 — v0.7 genomic GREML public-activation contract

> **Status: FROZEN PRE-IMPLEMENTATION CONTRACT, 2026-07-12.** This document
> replaces the open design choices in `43-genomic-greml-g0.md` for the v0.7
> activation arc. It authorizes implementation and validation of one narrow R
> route to the already-covered Julia supplied-precision REML estimator. It does
> **not** itself activate the route, promote an R capability, change
> `public_covered_count`, or authorize a release. Repository code, executable
> evidence, and the gates below decide those later states.

## 1. Goal and claim boundary

The candidate public route is:

```r
hsquared(
  y ~ fixed + genomic(1 | id, markers = M),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

with this exact computation:

```text
R formula and validation
  -> sample-frequency VanRaden method 1 in HSquared.jl
  -> K_lambda = G + 0.01 I
  -> Q_lambda = inv(K_lambda)
  -> covered supplied-Q Gaussian REML estimator
  -> R fit carrying the construction scale and provenance
```

The sibling engine's `V2-GREML` row is already `covered` for the
**supplied-`Ginv` estimator only**: its evidence is a preregistered 48-seed
known-truth recovery gate plus one same-supplied-precision `blupf90+` 2.60
AI-REML comparison (`HSquared.jl/src/validation_status.jl`, `V2-GREML`;
`HSquared.jl/docs/design/capability-status.md`, “Genomic REML”). That evidence
does not validate marker construction, R routing, R result labelling, or a
production genotype pipeline. This arc must prove those missing links.

The candidate may claim only:

> For the frozen marker construction below, the R marker route constructs the
> same regularized genomic precision used by the supplied-precision route and
> fits a Gaussian single-genomic-effect REML model through the covered Julia
> supplied-precision estimator. The returned ratio is a genomic variance ratio
> on that declared relationship scale.

It must not claim:

- pedigree, founder-base, population, or universal narrow-sense heritability;
- that the genomic ratio is necessarily less than pedigree heritability;
- exact SNP-BLUP equivalence after ridge regularization;
- weighted, base-frequency, LD-adjusted, Bayesian, APY, sparse-production, or
  file-backed marker support;
- calibrated confidence intervals;
- production-scale performance; or
- an additional covered public capability or a higher
  `public_covered_count`.

## 2. Frozen statistical model

Let \(M\in[0,2]^{n_g\times m}\) be an individual-by-marker dosage matrix;
hard calls in \(\{0,1,2\}\) are a supported subset. Rows are genotyped
individuals and columns are biallelic markers. For marker
(j), calculate its allele frequency from the supplied sample:

\[
p_j = \frac{1}{2n_g}\sum_{i=1}^{n_g} M_{ij}.
\]

Define the centred marker matrix and the VanRaden method-1 denominator:

\[
W_{ij}=M_{ij}-2p_j,
\qquad
k=2\sum_{j=1}^{m}p_j(1-p_j).
\]

The genomic relationship, regularized relationship, and precision are:

\[
G=\frac{WW^{\mathsf T}}{k},
\qquad
K_\lambda=G+\lambda I,
\qquad
Q_\lambda=K_\lambda^{-1},
\qquad
\lambda=0.01.
\]

The fitted model is:

\[
y=X\beta+Zu+\varepsilon,
\qquad
u\sim N(0,\sigma_g^2 K_\lambda),
\qquad
\varepsilon\sim N(0,\sigma_e^2 I).
\]

The derived coefficient-scale variance-component ratio is:

\[
r_G=\frac{\sigma_g^2}{\sigma_g^2+\sigma_e^2}.
\]

The public component label is exactly `genomic_variance_ratio`; its human
description is **“genomic variance-component ratio on the declared
relationship scale.”** The relationship scale is `K_lambda`, with method
`vanraden1`, sample allele frequencies, and ridge `0.01`. Because `K_lambda`
is not constrained to have mean diagonal one and the ridge changes its
diagonal scale, \(r_G\) is not generally the fraction of average marginal
phenotypic variance. It is also not pedigree-, founder-base-, population-, or
universal narrow-sense heritability. The name `heritability()` may remain the
generic entry point for API continuity, but the returned object must carry the
component and scale labels and must never return a bare `h2` interpretation for
a genomic fit.

Ridge changes the covariance kernel. Therefore the unregularized identity
between particular GBLUP and SNP-BLUP parameterizations is not evidence for the
frozen (K_\lambda) model. Any future SNP-BLUP equivalence claim requires its
own algebra and evidence on the same regularized estimand.

## 3. Frozen formula and routing contract

### 3.1 Accepted public forms

```r
hsquared(
  y ~ fixed + genomic(1 | id, markers = M),
  data = dat,
  family = gaussian(),
  REML = TRUE
)

hsquared(
  y ~ fixed + genomic(1 | id, Ginv = Q),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

The default `control = hs_control(engine = "fit")` route must auto-select the
genomic GREML bridge only when all of the following hold:

1. the response is univariate `gaussian(identity)`;
2. `REML = TRUE`;
3. there is exactly one genomic random intercept;
4. there is no second, bare-i.i.d., multivariate, random-regression, or other
   random effect;
5. exactly one of `markers` and `Ginv` is supplied; and
6. record IDs and genomic rows pass the alignment contract below.

The explicit spelling

```r
control = hs_control(
  engine = "julia",
  engine_control = list(target = "genomic")
)
```

remains a backward-compatible alias to the same bridge. It must not select a
different estimator, construction, starting-value policy, or result shape.

Fixed effects supported by the ordinary univariate fixed-design parser remain
allowed. The genomic term is the only random effect.

### 3.2 Repeated records and ID alignment

Repeated phenotype records per individual are supported. This is not a
one-record-per-individual public restriction. Let `ids` be marker-row or
precision-row order. R constructs a record-to-individual incidence matrix
(Z), with each phenotype record mapped to exactly one matching `ids` entry.

Required alignment rules:

- every observed, nonmissing phenotype ID must occur exactly once in `ids`;
- genomic row IDs must be unique, nonmissing, and nonempty;
- marker rows or precision rows may include genotyped individuals with no
  phenotype record;
- repeated phenotype IDs produce repeated incidence rows and do not duplicate
  or reorder the genomic matrix;
- marker row order is the individual order used for (G,K_\lambda,Q_\lambda),
  breeding values, and the ID-order fingerprint;
- a supplied `Ginv` must have identical row and column names in identical
  order; and
- no positional matching is permitted when names are absent or disagree.

### 3.3 Rejected forms

All of these must error before Julia marshalling, naming the unsupported input
and, where useful, the accepted form:

- `REML = FALSE`;
- a non-Gaussian family or non-identity Gaussian link;
- a genomic slope or a non-bare grouping expression;
- more than one primary random-effect term;
- genomic plus any second or bare-i.i.d. random effect;
- a multivariate response;
- neither or both of `markers` and `Ginv`;
- user-facing `method`, `weights`, `allele_frequencies`, or `ridge` controls;
- missing, duplicated, empty, or unmatched IDs;
- a nonnumeric, empty, nonfinite, or out-of-range marker matrix;
- a marker panel whose realized sample-frequency denominator satisfies
  (k\le0); and
- an invalid supplied precision under Section 4.2.

`single_step()`, `snp_blup`, custom relationship terms, and marker scans remain
separate routes. This auto-route must not absorb them.

## 4. Input validation

### 4.1 Marker matrix

Before marshalling, `markers` must be a numeric matrix with:

- at least one row and one column;
- finite, nonmissing entries;
- every entry in the closed interval `[0, 2]`;
- unique, nonmissing, nonempty row names;
- optional column names that, when present, are unique, nonmissing, and
  nonempty; and
- (k>0) under the exact sample-frequency formula in Section 2.

Fractional dosages in `[0,2]` are accepted; the public contract is therefore a
dosage matrix, not hard calls only. Monomorphic columns may be present if the
panel still has (k>0); they contribute zero to (k). A wholly monomorphic
panel is rejected. This version does not impute missing dosages.

### 4.2 Supplied precision

Before marshalling, `Ginv` must be a nonempty numeric square matrix with:

- finite, nonmissing entries;
- unique, nonmissing, nonempty row and column names that are identical in the
  same order;
- symmetry within the package's documented numerical tolerance; and
- positive definiteness, established by a Cholesky factorization rather than
  by silently adding a ridge.

R must not alter, rescale, symmetrize, blend, or regularize supplied `Ginv`.
Its construction is unknown unless a later explicit provenance contract is
added.

## 5. Provenance and fingerprint contract

### 5.1 Marker route

The fitted object must retain this semantic provenance:

```text
relationship_source       = "markers"
relationship_method       = "vanraden1"
allele_frequency_source   = "sample"
ridge                     = 0.01
scale_denominator         = k
relationship_scale        = "K_lambda"
id_order_fingerprint      = <SHA-256>
marker_content_fingerprint= <SHA-256>
kernel_fingerprint        = <SHA-256 of K_lambda>
precision_fingerprint     = <SHA-256 of Q_lambda>
```

### 5.2 Supplied-precision route

The fitted object must retain:

```text
relationship_source       = "supplied_Ginv"
relationship_method       = NA
allele_frequency_source   = NA
ridge                     = NA
scale_denominator         = NA
relationship_scale        = "inverse_of_supplied_precision"
id_order_fingerprint      = <SHA-256>
marker_content_fingerprint= NA
kernel_fingerprint        = NA
precision_fingerprint     = <SHA-256 of supplied Q>
```

The current payload's unused `ridge = 0.01` on supplied `Ginv` is not valid
provenance and must be removed or set to unknown.

### 5.3 Canonical fingerprint definition

Fingerprints are **engine-generated SHA-256 provenance fingerprints over
canonical semantic inputs**, carried unchanged into R. They are not R object
serialization hashes, CSV-file hashes, Julia-memory-layout hashes, or proofs of
floating-point equality.

The Julia implementation owns one canonical encoder with these rules:

1. prepend a versioned ASCII domain tag, for example
   `HSquared-provenance-v1\0<kind>\0`;
2. encode strings as UTF-8 with an unsigned 64-bit little-endian byte length
   followed by their bytes;
3. encode dimensions as unsigned 64-bit little-endian integers;
4. encode numeric array entries as IEEE-754 `Float64` bit patterns in
   column-major semantic order, canonicalizing `-0.0` to `+0.0` and rejecting
   nonfinite values before hashing;
5. include row IDs and, for markers, a names-present flag followed by either
   marker names or positional column indices before numeric content;
6. distinguish `markers`, `K_lambda`, and `Q_lambda` with different `<kind>`
   tags; and
7. return lowercase 64-character hexadecimal SHA-256.

The encoder includes the element count before every ID/name vector and encodes
row-ID and column-ID vectors separately for square matrices, even when they are
equal. Integer dimensions, counts, and `Float64` bit patterns are written
explicitly little-endian (for example, using `htol`), never in host byte order.
The implementation gate includes one byte-level golden encoder fixture, one
independently known SHA-256 digest, and mutations of dimension, ID order,
marker order, `-0.0`, and one numeric value.

The ID-order fingerprint hashes only the ordered UTF-8 ID vector under its own
kind tag. The marker-content fingerprint hashes dimensions, ordered IDs,
ordered marker identities—supplied names when present, otherwise positional
column indices—and dosage entries. Kernel and precision fingerprints
hash dimensions, ordered IDs for both axes, and numeric entries.

Route equivalence remains **tolerance-based numeric equivalence**. Matching
fingerprints establish that the exact canonical engine values match; differing
fingerprints do not by themselves establish a scientific disagreement because
numerically equivalent independently computed values may differ by rounding.
Every gate therefore reports both fingerprints and maximum numeric difference.

Prior BLUPF90 evidence may be linked only on the comparator's own frozen
dataset. Regenerate that dataset from the committed generator with the recorded
Julia version, code commit, and seed; run the candidate marker construction and
supplied-precision route on those inputs; record marker and precision
fingerprints plus maximum numeric differences. Because the historical
comparator precision and its fingerprint were not committed, regeneration
alone does not prove that the regenerated bytes were the bytes read by the
historical BLUPF90 run. The exact-precision link therefore requires either a
contemporaneous tracked checksum/log matching the regenerated value or a new
BLUPF90 run using the regenerated, fingerprinted precision. Without either,
the prior run remains fixed-data, same-Q solver/optimum parity evidence for the
supplied-precision estimator generally; it is not frozen-\(K_\lambda\)
known-truth recovery or the exact-hash link for this activation arc.

## 6. Result contract

The ordinary fitted-object fields remain backward compatible. For a genomic
fit:

- `variance_components()` labels the components `genomic` and `residual`;
- genomic random effects remain labelled `genomic` and aligned to genomic IDs;
- fit diagnostics record the estimated genomic AI-REML source;
- the fit carries the Section 5 provenance; and
- `heritability(fit)` returns a data frame containing at least:

```text
term = "genomic"                    # retained for compatibility
component = "genomic_variance_ratio"
estimate = r_G
relationship_scale = "K_lambda"     # marker route
relationship_source = "markers"     # or "supplied_Ginv"
relationship_method = "vanraden1"   # NA for supplied Ginv
allele_frequency_source = "sample"  # NA for supplied Ginv
ridge = 0.01                         # NA for supplied Ginv
```

For supplied `Ginv`, `relationship_scale` is
`inverse_of_supplied_precision` and construction fields remain unknown. Print,
summary, vignette, and status wording must use “genomic variance-component
ratio on the declared relationship scale.” Public genomic
`heritability_interval()` and `heritability_standard_error()` accessors remain
unavailable until they carry the identical component and relationship-scale
provenance and receive a separate interval-calibration gate. Raw engine
uncertainty fields may remain internal; this arc does not validate intervals.

## 7. Verification gates

### G1 — pure-R grammar and validation

Tests must cover every accepted and rejected form in Sections 3–4 without
requiring Julia. Deliberate mutations of dosage range, missingness, row IDs,
marker names, (k), precision symmetry, and precision definiteness must make
the gate red.

### G2 — Julia construction fixture

For a deterministic marker fixture, serialize or report (M,p,W,k,G,K_\lambda,
Q_\lambda), ordered IDs, marker names, and all fingerprints. Recompute the
equations independently in base R without calling package helpers. Require:

- (p,W,k,G,K_\lambda,Q_\lambda): maximum absolute difference `<= 1e-10`;
- exact agreement of method, frequency-source, ridge, ID order, and dimensions;
- valid SHA-256 shapes and engine-to-R pass-through; and
- a failed mutation check when sample frequencies are replaced by `0.5`, ridge
  is omitted or doubled, marker/ID order changes, or the denominator changes.

### G3 — marker versus supplied-precision route identity

Freeze seed `20270701`, `n = 120`, `m = 600`, a two-column fixed design, repeated
phenotype records for a subset of individuals, and additional genotyped
individuals without phenotype records; use
(\sigma_g^2=\sigma_e^2=0.5), sample-frequency VanRaden1, and ridge `0.01`.
Fit once from markers and once from its exact (Q_\lambda). Require:

- construction agreement `<= 1e-10`;
- variance components, ratio, and fixed effect `<= 1e-8`;
- GEBV correlation `>= 0.99999999`;
- maximum absolute GEBV difference `<= 1e-8`; and
- matching engine precision fingerprints for the two routes.

### G4 — external-comparator chain

The mandatory construction comparator is the independent base-R calculation in
G2. An AGHmatrix construction is optional and counts only if configured to the
exact sample-frequency VanRaden1 scale.

The existing BLUPF90 estimator evidence is reusable only under Section 5.3's
regenerated-exact-Q fingerprint gate. If that gate fails, prepare and run a new
same-(Q_\lambda) comparison. Optional `sommer` or `rrBLUP` REML comparisons
must receive identical `y`, `X`, `Z`, (K_\lambda), fixed effects, parameter
scale, and convergence policy. Acceptance, where run, is:

- each variance component within 2% relative difference;
- genomic variance ratio within `0.02` absolute difference;
- fixed effects within `1e-6`; and
- GEBV correlation at least `0.999`.

Log-likelihood is gated only when additive constants and parameterization are
shown to align.

### G5 — preregistered recovery

Run nine cells:

| `n` | `m` | regime |
| ---: | ---: | --- |
| 120 | 600 | marker-rich relative to individuals |
| 300 | 150 | marker-limited |
| 300 | 1000 | marker-rich |

For each cell and seed, draw population minor-allele frequencies
`pi_j ~ Uniform(0.05, 0.5)` and independent hard-call genotypes
`M_ij ~ Binomial(2, pi_j)`. Remove realized monomorphic columns, then construct
the fitted kernel from realized sample frequencies
`p_hat_j = sum_i M_ij/(2n)`, not from `pi_j`. This recovery-only preprocessing
does not change the public input contract in Section 4.1, where monomorphic
columns may be supplied and contribute zero. If removal leaves no columns or
the retained panel has `k <= 0`, classify the seed as an input/convergence
failure and do not redraw it. Set `(sigma_g2, sigma_e2) = (r_G, 1-r_G)` for
`r_G in {0.2,0.5,0.8}`. “Total coefficient variance one” refers only to
`sigma_g2 + sigma_e2 = 1`, not average marginal phenotypic variance. Build the
exact `K_lambda = G(M,p_hat)+0.01I`, draw
`u ~ N(0,sigma_g2 K_lambda)` by its Cholesky factor, draw
`epsilon ~ N(0,sigma_e2 I)`, and fit the candidate marker route end to end.
One record per individual and an intercept-only fixed model are used. The
conclusion is exact-model recovery for this HWE/no-LD/sample-frequency/ridge
design, not robustness to LD, population structure, imputation, or base-
frequency misspecification.

Use 48 preregistered pilot seeds per cell for runtime, memory, convergence, and
precision planning only, excluding them from confirmatory bias. If pilot
convergence is below 95%, stop the cell. For target `theta`, estimate
`s_pilot,theta` from finite converged pilot estimates and calculate the one-sided
95% upper confidence bound:

\[
s_{U,\theta}=s_{pilot,\theta}
\sqrt{\frac{n_{pilot,conv}-1}{\chi^2_{0.05,n_{pilot,conv}-1}}}.
\]

Define the absolute margin `Delta_theta` as `0.05 * theta` for each variance
component and `0.02` for `r_G`. Calculate:

\[
N_{req,\theta}=\left\lceil
\left(\frac{1.96s_{U,\theta}}{\Delta_\theta/2}\right)^2
\right\rceil,
\]

use the largest target-specific requirement in the cell, with a minimum of 200.
If the requirement exceeds 2,000, stop with a precision blocker; do not truncate
to 2,000 and proceed.

For confirmation, every attempted seed remains in the convergence denominator.
A seed counts as converged for this gate only when the fit reports convergence
and all three target estimates are finite; otherwise it receives an explicit
failure class. Bias is convergence-conditional over those eligible rows and is
reported with `n_attempted`, `n_converged`, `n_bias_rows`, and all failure
classes; by definition `n_bias_rows = n_converged`, and failed/nonfinite
estimates are never imputed or replaced. For each target, compute
`b_bar = mean(theta_hat)-theta`, `SE_MC = sd(theta_hat)/sqrt(n_bias_rows)`, and
the two-sided 95% interval
`b_bar +/- t_(0.975,n_bias_rows-1) * SE_MC`. A target passes only when
`lower > -Delta_theta` and `upper < Delta_theta`. A cell passes only when all
three targets pass, observed convergence is at least 95%, and the Wilson 95%
lower bound is at least 90%. Pilot and confirmation seed manifests are
disjoint.

The campaign runs on Totoro or DRAC, never GitHub Actions. Raw per-seed output
stays local; the repository records preregistration, seed manifests, compact
summaries, failure classes, fingerprints, commands, and environment versions.

### G6 — independent recomputation and tests of tests

Recompute cell counts, bias, Monte Carlo intervals, convergence, and Wilson
bounds independently in the other language and require `<= 1e-10` arithmetic
agreement. Mutating one estimate, truth, seed, failure row, cell label, ridge,
fingerprint, ID order, or pilot/confirmation seed membership must make at least
one gate fail.

### G7 — audits and activation candidate

Fisher reviews the estimand/recovery decision, Darwin the quantitative-genetic
interpretation, Noether the scale, Hopper the bridge parity, Grace the
reproducibility boundary, and Rose the full claim-versus-evidence surface. Rose
must report `CLEAN`, or every requested change must be applied and re-audited.

Passing G1–G7 permits a separately reviewable, merge-ready activation/status
candidate. The R genomic row remains `partial`/experimental and
`public_covered_count = 5` unless a separate explicit maintainer G10 changes
it. Passing does not itself authorize a release or count flip.

## 8. Stopping rules

- Any unresolved scale or estimand disagreement stops implementation.
- Construction disagreement stops routing and recovery work until the first
  differing intermediate is localized.
- Marker and supplied-precision fit disagreement stops activation.
- Failure to regenerate and fingerprint the comparator precision blocks reuse
  of the prior BLUPF90 link, not the reusable implementation work.
- Pilot convergence below 95% stops the confirmatory campaign.
- Required confirmation above 2,000 records a precision blocker.
- Failure of any confirmatory cell withholds the broad default-route claim.
- Partial cell success may be reported only by exact cell; it cannot be
  rewritten as broad recovery.
- A Rose objection withholds activation until re-audited.
- A negative result lands reusable validation/provenance hardening, keeps the
  default route held, and records the exact blocker and next discriminating
  experiment.
- Without an explicit maintainer G10 decision, status and
  `public_covered_count` remain unchanged.

## 9. Live-repository basis and research provenance

The frozen contract was reconciled against live `hsquared` `main` on
2026-07-12:

- parsing and current validation: `R/model-spec.R`,
  `hs_parse_relinv_primary_call()`, `hs_validate_genomic_markers()`, and
  `hs_validate_genomic_ginv()`;
- payload: `R/bridge-payload.R`, `hs_build_relinv_bridge_payload()`;
- current opt-in/default dispatch: `R/hsquared.R`, `hsquared()`;
- live construction and fit: `R/julia-bridge.R`,
  `hs_fit_julia_genomic_payload()`;
- current unqualified result surface: `R/extractors.R`,
  `heritability.hsquared_fit()`;
- current tests: `tests/testthat/test-genomic.R`; and
- current public state: `docs/design/capability-status.md`,
  `docs/design/validation-debt-register.md`, and
  `vignettes/articles/genomic-prediction.Rmd`.

The live scout found that marker fitting already enters
`hs_fit_julia_genomic_payload()` through
`genomic_relationship_matrix()` then `genomic_relationship_inverse()`, the
payload hard-codes `ridge = 0.01`, supplied `Ginv` misleadingly carries that
unused ridge, the default route rejects genomic terms as opt-in, and genomic
`heritability()` currently returns only `term = "genomic"` plus an estimate.
Those are implementation gaps, not evidence that this contract is active.

NotebookLM queries over the curated HSquared and quantitative-genetics
notebooks informed the terminology and comparator cautions. They are
**research input, not authority**. Any auto-added or synthesized claim remains
`UNVERIFIED` until grounded in primary manuals, repository code, or executable
evidence. The live repositories and exact runs control every gate in this
document.
