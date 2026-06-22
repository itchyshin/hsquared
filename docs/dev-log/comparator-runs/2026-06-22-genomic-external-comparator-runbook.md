# Genomic GBLUP / SNP-BLUP external-comparator runbook

Date: 2026-06-22

Reporter: Jason (landscape scout)

Related R issues: `itchyshin/hsquared#7`, `itchyshin/hsquared#9`

Related twin gate: `itchyshin/HSquared.jl#49`
(genomic `V2-GREML`, single-step `V2-SSHINV`, SNP-BLUP `V2-SNPBLUP`)

Related fixture: `tests/testthat/fixtures/genomic_gblup_snpblup_target/`
(Julia source HSquared.jl PR #140, `008ea4d`)

> **This is a protocol, not comparator evidence.** No external genomic
> comparator run has been executed. Nothing here promotes a capability,
> activates new syntax, or changes a public claim. The genomic GREML /
> single-step and SNP-BLUP / RR-BLUP rows stay `partial`.

## Purpose

Give a reproducible recipe for obtaining **external, same-estimand comparator
evidence** for the opt-in genomic targets (`target = "genomic"`,
`target = "snp_blup"`, and the supplied-variance GBLUP/SNP-BLUP route checked
by the committed fixture). The intended external tools are:

- `AGHmatrix` — VanRaden genomic relationship `G` and its inverse `G⁻¹`;
- `rrBLUP` — GBLUP (`mixed.solve` with a `K = G` kinship) and RR-BLUP /
  SNP-BLUP marker effects (`mixed.solve` with `Z = markers`, or `A.mat` for
  `G`);
- `BGLR` — Bayesian GBLUP (`model = "RKHS"`, `K = G`) and Bayesian ridge /
  SNP-BLUP marker effects (`model = "BRR"`), **agreement-only** (see the JWAS
  note);
- `sommer` — GBLUP via `mmer` with a supplied `vsr(id, Gu = G)`;
- `JWAS` (optional) — Bayesian GBLUP / SNP-BLUP, **MCMC agreement-only**, not
  same-estimand REML parity.

The companion document
`2026-06-21-genomic-gblup-snpblup-target-handoff.md` records the **target
fixture** shape, the required-report fields, and the claim boundary. This
runbook does **not** restate that handoff; it adds the per-tool *how-to-run*
recipes, the scale/standardization translation each tool needs, and proposed
acceptance bands. Read the handoff first.

## Capability gate

| Lane | Item | Status |
| --- | --- | --- |
| Twin (Julia) | `HSquared.jl#49` genomic `V2-GREML` | partial |
| Twin (Julia) | `HSquared.jl#49` single-step `V2-SSHINV` | partial |
| Twin (Julia) | `HSquared.jl#49` SNP-BLUP `V2-SNPBLUP` (GBLUP↔SNP-BLUP GEBV equivalence) | partial |
| R | `genomic GREML / single-step models` | partial |
| R | `SNP-BLUP / RR-BLUP marker effects` | partial |

The committed R fixture mirror recomputes the supplied-frequency VanRaden `G`,
`G⁻¹`, the supplied-variance GBLUP MME solution, and the SNP-BLUP
marker-effect-to-GEBV route agreement **inside R** (an internal/target route
check). That is **not** external comparator evidence: an independent same-scale
package must reproduce the same estimand on the same inputs before any row
moves. The fixture's own README and the handoff both state this explicitly;
this runbook does not weaken that boundary.

## Required tools + version capture

Run the probe and paste the table into the eventual comparator report. Versions
recorded on this host (`2026-06-22`):

```sh
Rscript --vanilla -e 'pkgs <- c("AGHmatrix","rrBLUP","BGLR","sommer","nadiv"); for (p in pkgs) { v <- tryCatch(as.character(utils::packageVersion(p)), error=function(e) "MISSING"); cat(sprintf("%-10s %s\n", p, v)) }'
# JWAS is Julia; probe in Julia:
#   julia --project=. -e 'using Pkg; haskey(Pkg.project().dependencies, "JWAS") ? println("JWAS present") : println("JWAS MISSING")'
```

| Package | Local result (2026-06-22 host) | Role |
| --- | --- | --- |
| `AGHmatrix` | **MISSING** | VanRaden `G` / `G⁻¹` |
| `rrBLUP` | **MISSING** | GBLUP + RR-BLUP/SNP-BLUP |
| `BGLR` | **MISSING** | Bayesian GBLUP / RR (agreement-only) |
| `sommer` | **4.4.5** | GBLUP (`mmer`, `Gu = G`) |
| `JWAS` (Julia) | **MISSING** | Bayesian GBLUP / SNP-BLUP (agreement-only) |
| `nadiv` | 2.18.0 | pedigree `A`-only; **not** a genomic `G` comparator |

Host: R 4.5.2, `aarch64-apple-darwin20`.

> **Blocker.** Of the genomic-specific comparators, only `sommer` (4.4.5) is
> installed; `AGHmatrix`, `rrBLUP`, `BGLR`, and `JWAS` are **absent**. A
> `sommer`-only leg is *one* same-estimand REML route, not the independent
> cross-check the gate needs, and `sommer` does not expose marker effects, so it
> cannot validate the SNP-BLUP marker-effect → GEBV leg on its own. The
> SNP-BLUP and `G`/`G⁻¹` legs of this runbook **cannot be executed on this host
> today**. This is the genomic analogue of the
> `2026-06-21-marker-scan-tool-availability.md` and
> `2026-06-21-multivariate-tool-availability.md` blockers. The note that
> `sommer` was `4.4.3` in the 2026-06-21 handoff is now stale on this host
> (`4.4.5`); record the version observed at run time.

To unblock, install on a comparator host:

```r
install.packages(c("AGHmatrix", "rrBLUP", "BGLR"))   # CRAN
```

```julia
import Pkg; Pkg.add("JWAS")   # optional, agreement-only
```

## Inputs (the genomic target fixture)

All recipes read the committed fixture. Use either the R-lane mirror
(`tests/testthat/fixtures/genomic_gblup_snpblup_target/`) or the Julia source
(`HSquared.jl/test/fixtures/genomic_gblup_snpblup_target/`); they are byte
copies. Record the exact path and these checksums (MD5, R-lane mirror) in the
report:

| File | MD5 |
| --- | --- |
| `phenotypes.csv` | `508217493fb687428a6f3c04d9de59ae` |
| `markers.csv` | `2e711ae5577a8d0861c1182586c1ccf9` |
| `allele_frequencies.csv` | `842b44f1f605c12c829e7efa949094de` |
| `expected_genomic_relationship.csv` | `3094e8e6fd65e917d7420070f33ebe47` |
| `expected_genomic_precision.csv` | `4eef747510169fd432e36425d4370b27` |
| `expected_beta.csv` | `a6d33748c16e6946552ac8fc34e7acea` |
| `expected_gebv.csv` | `cc3683eb331b295e7362fd638ef17a61` |
| `expected_marker_effects.csv` | `364af53c9f794ea299c837febf84221a` |
| `expected_metadata.csv` | `07bd018ea62af39647a156c23907d017` |

```sh
md5 tests/testthat/fixtures/genomic_gblup_snpblup_target/*.csv   # macOS
# md5sum on Linux
```

Fixture contents (the exact inputs each tool needs):

- **IDs / order:** individuals `g1`–`g4` (row-aligned across `phenotypes.csv`
  and `markers.csv`); markers `m1`–`m6`.
- **Response `y`:** `c(g1=10, g2=12, g3=11, g4=9)`.
- **Fixed effects `X`:** intercept only (`X = matrix(1, 4, 1)`).
- **Marker matrix `M`** (4 × 6, dosage coded **0/1/2**, rows = individuals):

  ```text
        m1 m2 m3 m4 m5 m6
  g1     0  1  2  1  0  2
  g2     2  1  0  1  2  0
  g3     1  0  1  2  1  1
  g4     0  2  1  0  2  1
  ```

- **Supplied allele frequencies `p`** (do **not** re-estimate from this tiny
  sample; the fixture deliberately uses these so `G` is positive definite and
  no ridge is needed):
  `p = c(m1=0.30, m2=0.45, m3=0.60, m4=0.40, m5=0.55, m6=0.35)`.
- **Supplied variance components:** `sigma_g2 = 2`, `sigma_e2 = 1`
  (so the GBLUP MME ratio is `lambda = sigma_e2 / sigma_g2 = 0.5`).
- **VanRaden scaling constant:** `k = 2 * sum(p * (1 - p)) = 2.825`
  (recorded as `k = 2.825` in `expected_metadata.csv`).
- **Targets to compare against:** `expected_genomic_relationship.csv` (`G`),
  `expected_genomic_precision.csv` (`G⁻¹`), `expected_beta.csv`
  (intercept `10.433489187842572`), `expected_gebv.csv`
  (`gblup` and `snp_blup` GEBV columns), `expected_marker_effects.csv`
  (`m1`–`m6` SNP-BLUP effects). `expected_metadata.csv` records the
  GBLUP↔SNP-BLUP route agreement (`max_abs_gebv_diff = 1.11e-15`).

### Scale / standardization notes (read before running any recipe)

This is the load-bearing translation step. The fixture's `G` follows **VanRaden
(2008) method 1** with **supplied** frequencies:

- centre markers by `2p`: `W = M - 2 * 1_n p'` (with `M` coded 0/1/2);
- scale by a **single** denominator `k = 2 * sum_j p_j (1 - p_j)`;
- `G = W W' / k`. For this fixture `k = 2.825`.

Pitfalls that will silently break a "comparison":

1. **Frequency source.** `AGHmatrix::Gmatrix` and `rrBLUP::A.mat`
   **re-estimate** `p` from the supplied genotypes by default. On 4 individuals
   that gives different `p`, hence a different `G`. You must force the **fixture
   `p = c(0.30, 0.45, 0.60, 0.40, 0.55, 0.35)`** (e.g. `AGHmatrix`
   `ploidy.correction`/explicit-frequency handling, or centre by `2p` yourself
   and pass the pre-centred matrix). If a tool cannot accept supplied `p`,
   record that and treat its `G` as a *different estimand* (off-fixture-scale),
   not a parity failure.
2. **Denominator convention.** Some implementations divide by
   `sum 2 p (1 - p)` (= `k`), others normalise per-marker or use
   `M - 1` centering for `{-1,0,1}` coding. Confirm the tool reproduces
   `k = 2.825` (or rescale and document the constant). A constant rescale of
   `G` rescales `sigma_g2`; GEBVs are invariant only if `sigma_g2` is rescaled
   to match.
3. **Coding.** The fixture is **0/1/2**. `rrBLUP` documents `{-1,0,1}`. Convert
   consistently (`M_{-1,0,1} = M_{0,1,2} - 1`) and keep the centering
   consistent with the coding.
4. **Ridge / regularization.** The fixture `G` is positive definite, so use
   **no** ridge. If a tool adds a default nugget to `G` before inverting,
   disable it or record the exact value.

## Per-tool run recipes

Each recipe is a *protocol*. Treat the code as the intended command, not as
something already executed. After running, fill
`docs/dev-log/comparator-runs/TEMPLATE.md`.

### Shared setup

```r
dir <- "tests/testthat/fixtures/genomic_gblup_snpblup_target"
phen <- read.csv(file.path(dir, "phenotypes.csv"))
M    <- as.matrix(read.csv(file.path(dir, "markers.csv"), row.names = 1))   # 4 x 6, 0/1/2
p    <- read.csv(file.path(dir, "allele_frequencies.csv"))$frequency        # length 6
y    <- phen$y; names(y) <- phen$id
X    <- matrix(1, nrow = length(y), ncol = 1)
sigma_g2 <- 2; sigma_e2 <- 1; lambda <- sigma_e2 / sigma_g2                  # 0.5
G_target    <- as.matrix(read.csv(file.path(dir, "expected_genomic_relationship.csv"), row.names = 1))
Ginv_target <- as.matrix(read.csv(file.path(dir, "expected_genomic_precision.csv"),   row.names = 1))
gebv_target <- read.csv(file.path(dir, "expected_gebv.csv"))                 # cols: id, gblup, snp_blup
me_target   <- read.csv(file.path(dir, "expected_marker_effects.csv"))       # cols: marker, effect
beta_target <- read.csv(file.path(dir, "expected_beta.csv"))$value           # 10.4334891878...

# Reference VanRaden-1 G with SUPPLIED p (what every tool must reproduce):
W  <- sweep(M, 2, 2 * p, FUN = "-")        # centre by 2p
k  <- 2 * sum(p * (1 - p))                  # 2.825
G_ref <- (W %*% t(W)) / k
stopifnot(max(abs(G_ref - G_target)) < 1e-8)   # sanity: fixture math reproduces in base R
```

### 1. `AGHmatrix` — `G` and `G⁻¹`

```r
library(AGHmatrix)
# VanRaden G. AGHmatrix re-estimates allele freqs by default; to match the
# fixture you must drive it to the SUPPLIED p (or pass pre-centred markers and
# rescale). Record exactly which path was used.
G_agh <- Gmatrix(SNPmatrix = M, method = "VanRaden", ploidy = 2)
Ginv_agh <- solve(G_agh)
cat("max|G - target|   :", max(abs(G_agh   - G_target)),    "\n")
cat("max|Ginv - target|:", max(abs(Ginv_agh - Ginv_target)), "\n")
```

Compare elementwise against `expected_genomic_relationship.csv` and
`expected_genomic_precision.csv`. If `Gmatrix` cannot consume supplied `p`,
report `G_agh` as off-fixture-scale and additionally check `G_ref` (the
supplied-`p` base-R route) for documentation. `AGHmatrix` is the cleanest `G`
/ `G⁻¹` comparator; it does **not** fit GBLUP itself.

### 2. `rrBLUP` — GBLUP GEBV + RR-BLUP / SNP-BLUP marker effects

```r
library(rrBLUP)
# (a) GBLUP via kinship route. mixed.solve estimates the variance ratio by REML,
#     so this is an ESTIMATED-variance check, not the fixture's SUPPLIED-variance
#     estimand. Treat GEBV correlation/sign, not exact GEBV equality, as primary
#     unless you fix the ratio. K must be the SAME G (supplied-p VanRaden).
fit_gblup <- mixed.solve(y = y, K = G_target, X = X)   # u = GEBVs, beta = intercept
gebv_rr   <- fit_gblup$u

# (b) RR-BLUP / SNP-BLUP marker effects via the marker route.
#     Z must be centred markers on the SAME convention as G (W = M - 2p).
fit_rr    <- mixed.solve(y = y, Z = W, X = X)           # u = marker effects
me_rr     <- fit_rr$u
gebv_from_me <- as.numeric(W %*% me_rr)                 # marker effects -> GEBV

cat("cor(GEBV, target gblup):", cor(gebv_rr, gebv_target$gblup), "\n")
cat("max|GEBV(from markers) - GEBV(kinship)|:",
    max(abs(gebv_from_me - gebv_rr)), "\n")
```

Notes: `mixed.solve` estimates `sigma_g2`/`sigma_e2` by REML; to test the
fixture's **supplied-variance** estimand exactly, either (i) report the
estimated ratio alongside the GEBV correlation, or (ii) prefer `sommer`/manual
MME with the ratio fixed at `lambda = 0.5`. `rrBLUP::A.mat(M_{-1,0,1})` is an
alternative `G` route (re-estimates `p`; document the scale).

### 3. `BGLR` — Bayesian GBLUP (`RKHS`) and Bayesian ridge / SNP-BLUP (`BRR`)

```r
library(BGLR)
nIter <- 12000; burnIn <- 2000   # record seeds + chain length
# (a) GBLUP-analogue: RKHS with K = G.
ETA_gblup <- list(list(K = G_target, model = "RKHS"))
fm_gblup  <- BGLR(y = y, ETA = ETA_gblup, nIter = nIter, burnIn = burnIn, verbose = FALSE)
gebv_bglr <- fm_gblup$ETA[[1]]$u
# (b) SNP-BLUP-analogue: Bayesian ridge regression on centred markers.
ETA_brr   <- list(list(X = W, model = "BRR"))
fm_brr    <- BGLR(y = y, ETA = ETA_brr, nIter = nIter, burnIn = burnIn, verbose = FALSE)
me_bglr   <- fm_brr$ETA[[1]]$b
cat("cor(posterior-mean GEBV, target gblup):", cor(gebv_bglr, gebv_target$gblup), "\n")
```

> **Agreement-only.** `BGLR` is Bayesian/MCMC: priors and posterior means do
> **not** reproduce a fixed supplied-variance REML/MME point estimand. Report
> posterior means inside a posterior credible/HPD interval and GEBV
> correlations, not exact-tolerance parity. This mirrors the `MCMCglmm`
> distinction used for the multivariate row.

### 4. `sommer` — GBLUP via `mmer` (the one locally available leg)

```r
library(sommer)
dat <- data.frame(id = factor(phen$id, levels = phen$id), y = y)
# Supply the SAME G as a covariance; sommer estimates sigma_g2/sigma_e2 by REML.
fit_s <- mmer(y ~ 1, random = ~ vsr(id, Gu = G_target), rcov = ~ units, data = dat)
gebv_s <- as.numeric(fit_s$U[[1]]$y)      # check name/order in fit_s$U
cat("cor(GEBV, target gblup):", cor(gebv_s, gebv_target$gblup), "\n")
cat("sommer sigma_g2/sigma_e2:", unlist(fit_s$sigma), "\n")
```

> `sommer` is the **only** genomic-relevant comparator installed (4.4.5). It
> estimates variances by REML (it does not fix them to `sigma_g2=2`,
> `sigma_e2=1`), and it does **not** expose marker effects, so on its own it can
> check the GBLUP GEBV leg (correlation + variance-ratio context) but **not**
> the `G`/`G⁻¹` construction or the SNP-BLUP marker-effect leg. Document the
> estimated variances; if they differ from the supplied values, the GEBV
> comparison is a same-estimand-*shape* agreement, not supplied-variance parity.

### 5. `JWAS` (optional, Julia) — Bayesian agreement-only

```julia
using JWAS, CSV, DataFrames
# Build genotypes/phenotypes from the same fixture CSVs; run a GBLUP or
# BayesC/BRR analysis. Record n_iter, burn-in, seed, priors.
```

> **Agreement-only, not same-estimand parity.** `JWAS` is Bayesian/MCMC. Use it
> only as a posterior-agreement cross-check (GEBV correlation, posterior means
> inside credible intervals), exactly as `MCMCglmm` is used for the multivariate
> row. A `JWAS` run does **not** satisfy a same-estimand REML parity
> requirement and does not promote any row.

## What to compare

Record every quantity in the `TEMPLATE.md` results table, aligned to the
fixture IDs/marker labels:

| Quantity | Target file | Comparison | Notes |
| --- | --- | --- | --- |
| `G` elementwise (4×4) | `expected_genomic_relationship.csv` | max\|Δ\| | requires supplied-`p` VanRaden-1 scale (`k = 2.825`) |
| `G⁻¹` elementwise (4×4) | `expected_genomic_precision.csv` | max\|Δ\| | only if the tool exposes/forms `G⁻¹` |
| intercept `beta` | `expected_beta.csv` | \|Δ\| | `10.433489187842572`; only meaningful if variances fixed |
| GBLUP GEBV (`g1`–`g4`) | `expected_gebv.csv` (`gblup`) | corr **and** max\|Δ\| | exact Δ only under fixed supplied variances |
| SNP-BLUP marker effects (`m1`–`m6`) | `expected_marker_effects.csv` | corr **and** max\|Δ\| | only tools exposing marker effects (rrBLUP, BGLR, JWAS) |
| marker effects → GEBV equivalence | `expected_gebv.csv` (`snp_blup`) | max\|GEBV(markers) − GEBV(kinship)\| | the `V2-SNPBLUP` equivalence (fixture: `1.11e-15`) |
| variance components | `expected_metadata.csv` (`sigma_g2`, `sigma_e2`) | report estimates | REML tools estimate, not fix; flag the estimand mismatch |
| convergence / warnings | — | record | boundary, singularity, non-PD nugget, MCMC diagnostics |

Primary equivalence target for the SNP-BLUP gate: **GBLUP (kinship route) and
SNP-BLUP (marker route) produce the same GEBVs** when fed the same `G`/markers
and the same variances — the fixture pins this at `1.11e-15`. Reproduce that
equivalence *within the comparator* (route-internal check) and *against the
fixture* (target check).

## Proposed acceptance bands

These extend the handoff's review bands; they are **proposals for Fisher /
Kirkpatrick / Curie**, not automatic promotion gates.

| Quantity | Proposed band | Conditions |
| --- | --- | --- |
| `G` elementwise | max\|Δ\| ≤ `1e-10` | exact algebra, supplied-`p` VanRaden-1, `k = 2.825` confirmed |
| `G⁻¹` elementwise | max\|Δ\| ≤ `1e-8` | well-conditioned 4×4; tighten if the tool reports the inverse directly |
| GBLUP GEBV (variances fixed) | max\|Δ\| ≤ `1e-6` | only when `sigma_g2`/`sigma_e2` fixed and scale mapped |
| GBLUP GEBV (REML-estimated variances) | corr ≥ `0.999` | rrBLUP/sommer estimate variances; report estimates + correlation |
| SNP-BLUP marker effects | max\|Δ\| ≤ `1e-6` | variances fixed and exposed (rrBLUP fixed-ratio route) |
| marker → kinship GEBV equivalence | max\|Δ\| ≤ `1e-8` | route-internal; fixture itself reaches `~1e-15` |
| Bayesian (BGLR/JWAS) GEBV | target inside 95% credible/HPD; corr ≥ `0.99` | agreement-only, never exact parity |
| convergence | no unreviewed warning / boundary / singularity / non-PD nugget | all REML legs; MCMC: report ESS / R-hat |

If a comparator estimates rather than fixes variance components, Fisher and
Curie must record a separate estimand decision (supplied-variance MME vs.
REML-estimated) **before** any status change — the same rule the handoff
applies.

## Report location + Rose / Fisher / Kirkpatrick verdict

- Write each executed run as a dated report from `TEMPLATE.md` under
  `docs/dev-log/comparator-runs/` (one per tool, or one combined report with a
  per-tool section), e.g.
  `docs/dev-log/comparator-runs/2026-MM-DD-genomic-aghmatrix-rrblup-comparator.md`.
- Attach the sanitized companion table (`quantity, target, estimate,
  difference, tolerance, verdict`) per the directory README convention.
- Record exact commands + outcomes in `docs/dev-log/check-log.md` if any R
  checks are run.
- Required sign-off before any status change:
  - **Rose** — confirms no claim drift; rows stay `partial` until evidence is
    accepted; the fixture is not mislabelled as external evidence.
  - **Fisher** — confirms the estimand match (supplied-variance vs. REML),
    intervals/identifiability, and the supplied-`p` scale before accepting GEBV
    parity.
  - **Kirkpatrick** — confirms the `G` construction (VanRaden-1, centering by
    `2p`, denominator `k`) and that any rescale is documented and
    GEBV-invariant.
- (Curie remains the simulation/test reviewer for the route-equivalence and
  recovery tests if the run is wired into the suite.)

## Claim boundary

This runbook is a **protocol, not comparator evidence**. As of `2026-06-22`:

- **No external genomic comparator run has been executed.**
- The only genomic-relevant comparator installed on this host is `sommer`
  (4.4.5); `AGHmatrix`, `rrBLUP`, `BGLR`, and `JWAS` are **absent** — a recorded
  blocker. The `G`/`G⁻¹` and SNP-BLUP marker-effect legs cannot run here today.
- The committed fixture
  (`tests/testthat/fixtures/genomic_gblup_snpblup_target/`) is a
  **target / internal-route check** (R recomputes VanRaden `G`/`G⁻¹`, the
  supplied-variance GBLUP MME solution, and the SNP-BLUP marker-effect → GEBV
  route). It is **not** external comparator evidence and must not be presented
  as such.
- `BGLR` and `JWAS` are **Bayesian/MCMC agreement** checks, **not**
  same-estimand REML parity (the `MCMCglmm` distinction).
- This document does **not** add APY / low-rank `m ≫ n` / weighted-marker /
  Bayesian-marker-prior claims, does **not** activate new R genomic syntax, and
  does **not** promote any capability, validation, or public claim. The genomic
  GREML / single-step and SNP-BLUP / RR-BLUP rows remain `partial`.
