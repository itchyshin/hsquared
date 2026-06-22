# Multivariate second-comparator runbook: ASReml-R, DMU, WOMBAT

Date: 2026-06-22

Reporter: Jason (landscape scout)

## Purpose

Provide one reproducible run protocol for obtaining the **second independent
same-estimand REML comparator** for the opt-in multivariate animal model
(`V4-MV-REML`, `target = "multivariate"`), using the three accepted REML tools
**not yet covered by an existing handoff**: ASReml-R, DMU, and WOMBAT.

The existing reproduced `sommer` full-unstructured-residual leg is the **first**
same-estimand REML comparator against the shared `phase4_multitrait_parity`
target. This runbook exists to obtain a **second, independent** one. The
BLUPF90-family path is already documented separately and is **not** repeated
here:

- `docs/dev-log/comparator-runs/2026-06-21-blupf90-multivariate-executable-handoff.md`
- `docs/dev-log/comparator-runs/2026-06-21-multivariate-tool-availability.md`

This file is a **run protocol, not comparator evidence**. No comparator run has
been executed for ASReml-R, DMU, or WOMBAT. Nothing here promotes any
`validation_status()` row, capability, or public claim.

## Capability gate

- R issue: `itchyshin/hsquared#10`
- Twin gates: `itchyshin/HSquared.jl#41` (multivariate recovery),
  `itchyshin/HSquared.jl#49` (full-R0 second comparator)
- Current status: `V4-MV-REML` remains **partial**.
- Existing same-estimand REML comparator: reproduced `sommer` full-unstructured
  comparator against `phase4_multitrait_parity` (the **first** leg).
- Required missing leg: a **second independent** same-estimand REML comparator
  beyond `sommer`. Any one of ASReml-R, DMU, or WOMBAT executed and reviewed can
  fill this slot. This runbook does **not** imply that second comparator exists.
- `MCMCglmm` Bayesian agreement and the Mrode Example 5.1 supplied-G0/R0
  BLUP/MME anchor do **not** count as a second same-estimand REML comparator.

## Required host and tools

This local host **lacks** all three tools (consistent with
`2026-06-21-multivariate-tool-availability.md`):

| Tool | Executable / package | Local result |
| --- | --- | --- |
| ASReml-R | `asreml` (licensed R package) | MISSING |
| DMU | `dmu1`, `dmuai` (and `dmu4`/`dmu5` driver) | MISSING |
| WOMBAT | `wombat` | MISSING |

A second comparator therefore **cannot** be produced on this machine today. The
run must happen on a host that has one of these tools licensed and installed.

Capture versions before any run and paste the output into the run report:

```sh
# DMU and WOMBAT executables
for x in dmu1 dmuai dmu4 dmu5 wombat; do
  if command -v "$x" >/dev/null 2>&1; then
    printf '%s\t%s\n' "$x" "$(command -v "$x")"
    "$x" 2>&1 | head -n 5 || true
  else
    printf '%s\tMISSING\n' "$x"
  fi
done
```

```r
# ASReml-R (licensed) version and license state
if (requireNamespace("asreml", quietly = TRUE)) {
  cat("asreml", as.character(utils::packageVersion("asreml")), "\n")
  library(asreml)            # prints the license expiry banner
} else {
  cat("asreml MISSING\n")
}
```

ASReml-R object slots and WOMBAT/DMU keywords differ by version; record the
exact version so a future maintainer can reproduce the parameterization mapping.

## Inputs

Use the committed shared multivariate fixture (do not regenerate the targets):

- `tests/testthat/fixtures/phase4_multitrait_parity/pedigree.csv`
- `tests/testthat/fixtures/phase4_multitrait_parity/phenotypes.csv`
- `tests/testthat/fixtures/phase4_multitrait_parity/expected_*.csv`

Fixture shape (verify before running):

- 20 animals (`pedigree.csv`, IDs `f1`..`f20`; unknown parents coded `0`).
- 80 phenotype records (`phenotypes.csv`), 4 records per animal.
- Columns: `record`, `animal`, `x`, `trait1`, `trait2`.
- One shared continuous fixed covariate `x` (there is **no** `sex` or `age`
  column; the `AGENTS.md` `sex + age` example does not apply to this fixture).
- Both traits observed on every record (no missing trait values).

Model to fit in every tool (must match the fixture target exactly):

- Response: `cbind(trait1, trait2)` (a 2-trait model).
- Fixed effects, per trait: intercept and `x` (trait-specific slopes and
  intercepts).
- Random effect: additive genetic `animal`, unstructured `2x2` genetic
  covariance `G0` on a numerator-relationship (`A`) basis built from the
  pedigree.
- Residual: unstructured `2x2` residual covariance `R0` at the record level.
- Estimator: **REML**.
- **No** permanent-environment term, **no** extra random effect, and **no**
  repeatability/repeated-records residual block. The fixture's per-trait
  heritability is the plain `diag(G0) / (diag(G0) + diag(R0))`; adding any extra
  variance component changes the residual partition and breaks the match.

### Per-tool input generation

ASReml-R: a generator already exists. **Do not rewrite it.**

```sh
# dry run (any machine) to inspect the prepared long-format data
Rscript inst/comparator-scripts/asreml/multivariate-animal.R
# real fit (licensed ASReml-R host only)
Rscript inst/comparator-scripts/asreml/multivariate-animal.R --run \
  --out=/tmp/hsquared-asreml-mv/fit.rds
```

That script reshapes the fixture to long format, builds `ainverse(ped)`, and
fits the candidate ASReml-R 4 model
(`fixed = value ~ trait + trait:x - 1`,
`random = ~ us(trait):vm(animal, ainv)`,
`residual = ~ idv(record):us(trait)`). Review the residual term locally before
trusting the output: `idv(record):us(trait)` carries an `idv` scale on top of an
`us(trait)` block, which can be over-parameterized unless the `idv` component is
fixed at 1. Confirm the fitted residual block reproduces `R0` (off-diagonal
included) before recording any verdict; if it does not, switch to a plain
per-record `us(trait)` residual and record the change.

DMU and WOMBAT: **no generator exists yet** in
`inst/comparator-scripts/`. Until one is added (a reasonable follow-up, mirroring
`blupf90/prepare-multivariate-animal.R`), build inputs by hand from the fixture
and record the exact files in the run report. The BLUPF90 prepare script is the
pattern to copy: integer ID recoding via `id_map <- setNames(seq_len(nrow(ped)),
ped$animal)`, unknown parents kept as `0`, and a wide-format data row per record.

DMU inputs (DMUAI via the `dmu4`/`dmu5` driver):

- A flat data file (e.g. `mv.dat`), one row per record, whitespace-delimited,
  with integer animal ID, a constant `1` for the intercept (or an explicit
  fixed-class column), the covariate `x`, and both traits, e.g. columns:
  `animal_int  x  trait1  trait2`. Record the exact column order.
- A pedigree file (e.g. `mv.ped`): `animal_int sire_int dam_int`, unknown
  parents `0`, same integer recoding as the data file.
- A driver file `mv.DIR` declaring: `$DATA` (integer and real column counts and
  the data file), `$VARIABLE` names, `$MODEL` with two traits, the absorbed/fixed
  effect `x` (regression) per trait, and the random `animal` effect with an
  additive-genetic structure read from the pedigree, and `$VAR_STR` selecting the
  additive relationship structure. Request REML (AI-REML) estimation. Record the
  full `.DIR` verbatim in the run report.

WOMBAT inputs:

- A flat data file (e.g. `mv.dat`), one row per record, with integer animal ID,
  `x`, and both traits (WOMBAT reads two trait columns for a 2-trait run).
- A pedigree file (e.g. `mv.ped`): `animal_int sire_int dam_int`, unknown
  parents `0`.
- A parameter file `mv.par` declaring: `ANALYSIS MUV` (multivariate),
  `PEDS mv.ped`, `DATA mv.dat` with the column list, `MODEL` with `TRAIT`,
  per-trait fixed covariable `COV x(1)` and the random `EFF animal NRM` (additive
  numerator-relationship), `RESIDUAL` as an unstructured `2x2`, and a `VAR`
  block giving starting `G0`/`R0`. Run REML (the default AI-REML), not Gibbs.
  Record the full `.par` verbatim.

## Run commands per tool

ASReml-R (licensed host):

```sh
mkdir -p /tmp/hsquared-asreml-mv
HSQUARED_REPO="$(git rev-parse --show-toplevel)" \
  Rscript inst/comparator-scripts/asreml/multivariate-animal.R --run \
  --out=/tmp/hsquared-asreml-mv/fit.rds
```

DMU (host with `dmu4`/`dmu5` + `dmu1`/`dmuai`):

```sh
cd /tmp/hsquared-dmu-mv
# driver name without the .DIR suffix, per local DMU convention
dmu5 -d mv            # or: DMU mv   (record the exact launcher used)
```

WOMBAT (host with `wombat`):

```sh
cd /tmp/hsquared-wombat-mv
wombat -v mv.par      # record exact flags; --redo / -c for restarts
```

If a tool expects a different launcher, file suffix, or working-directory
convention, record the **actual** command used, not the template.

## Exact result extraction

Each run report must extract, on the fixture's two-trait scale:

- converged yes/no/unclear; iteration count; final REML log-likelihood.
- genetic covariance `G0`: `G[1,1]`, `G[1,2]`, `G[2,2]`.
- residual covariance `R0`: `R[1,1]`, `R[1,2]`, `R[2,2]`.
- fixed effects per trait: intercept and `x` slope for trait1 and trait2.
- per-trait heritability: `h2 = diag(G0) / (diag(G0) + diag(R0))` for each trait
  (compute from the estimated `G0`/`R0`, do not read a tool-specific h2 unless
  its definition is confirmed identical).
- animal EBVs for both traits, **aligned to the original fixture animal IDs**
  (`f1`..`f20`), using the integer-to-`f*` map from input generation.
- boundary flags, singularity, non-positive-definite, or fixed-component
  warnings.
- the exact scale/parameterization mapping used (next section).

Where the tool writes machine-readable output, capture it verbatim:

- ASReml-R: `summary(fit)$varcomp`, `summary(fit)$coef.fixed`, and
  `summary(fit, coef = TRUE)` / `predict()` for EBVs; the `--out` RDS already
  serializes the fit and `sessionInfo()`.
- DMU: the `.lst`/`.PAROUT`/`SOL` solution files (fixed effects and animal
  solutions) and the residual/genetic (co)variance estimates from the listing.
- WOMBAT: `SumEstimates.out` (variance components), `FixSolutions.out`
  (fixed effects), and `RnSoln_*.dat` (random/animal solutions).

When possible, attach a sanitized companion CSV with columns `quantity`,
`target`, `estimate`, `difference`, `tolerance`, `verdict`. The repo's internal
ingester validates that table shape and the required core quantities (`G`, `R`,
per-trait h2). It is a review aid only and is **not** comparator evidence.

## Scale and parameterization mapping

Each tool parameterizes (co)variances differently. The mapping to the fixture
target must be **explicit and verified**, not assumed. The fixture target is a
direct `2x2` `G0` and `2x2` `R0` on the observed trait scale (see
`expected_genetic_covariance.csv` / `expected_residual_covariance.csv`), with
EBVs and fixed effects on the same scale.

| Tool | Native parameterization | Mapping to fixture `G0`/`R0` |
| --- | --- | --- |
| ASReml-R | `us(trait)` reports variances/covariances directly, but the `residual = idv(record):us(trait)` form multiplies the `us(trait)` block by the `idv` scale. EBVs come from `predict()`/`coef`, often on a centered fixed-effect basis. | If `idv` is estimated (not fixed at 1), the reported residual `us(trait)` block is `R0 / idv`; reconstruct `R0 = idv * us_block` (or refix `idv = 1`). Confirm `G0` is read directly from the `us(trait):vm(animal)` component. Confirm EBV/fixed-effect centering matches the fixture's intercept+`x` parameterization. |
| DMU | DMUAI estimates (co)variance **matrices** directly per random and residual term; output is usually the full `G0`/`R0` matrices in the listing. Some builds report correlations alongside covariances. | `G0`/`R0` should map one-to-one once trait order matches. Verify trait ordering (trait1 then trait2) and that the residual matrix is the per-record `R0`, not a derived phenotypic matrix. If only correlations + variances are printed, reconstruct covariances as `r * sqrt(v_i v_j)`. |
| WOMBAT | Estimates covariance components per `EFF` and the residual matrix directly; `SumEstimates.out` lists matrices and (often) correlations. WOMBAT may rescale data internally and report on the input scale. | Map the `animal NRM` covariance matrix to `G0` and the residual matrix to `R0`. Confirm WOMBAT did not standardize traits (if it did, back-transform to the input scale). Confirm `COV x(1)` slope sign/scale matches the fixture's `x` parameterization. |

For all three: confirm **trait order** (trait1, trait2), confirm the
**relationship basis** is the numerator-relationship `A` from the same pedigree
(not a genomic or identity basis), and confirm EBVs use the **same animal set
and ordering** before correlating against `expected_ebv.csv`.

## Comparison target

Compare against the committed Julia REML targets (same fixture):

- `expected_genetic_covariance.csv` — `G0` (`G[1,1]=0.6036`, `G[1,2]=0.1120`,
  `G[2,2]=0.2704`).
- `expected_residual_covariance.csv` — `R0` (`R[1,1]=0.2631`, `R[1,2]=3.08e-4`,
  `R[2,2]=0.0907`).
- `expected_beta.csv` — fixed effects (Intercept/`x` per trait).
- `expected_heritability.csv` — `h2` trait1 `=0.6964`, trait2 `=0.7489`.
- `expected_ebv.csv` — animal EBVs keyed by original ID (`f1`..`f20`).
- `expected_metadata.csv` — `loglik=-121.7048`, `converged=true`,
  `iterations=284`, `genetic_correlation_trait1_trait2=0.2771`,
  `residual_correlation_trait1_trait2=0.00199`.

These are Julia REML targets, not a published external standard. The log-
likelihood and iteration count are tool- and parameterization-specific and are
**not** part of the acceptance bands; report them for context only.

## Proposed acceptance bands

Initial proposed bands for review, not automatic promotion:

| Quantity | Proposed acceptance band |
| --- | --- |
| `G0` / `R0` covariance entries | absolute difference <= `1e-3` after confirmed scale mapping |
| fixed effects (Intercept, `x`, per trait) | absolute difference <= `1e-3` |
| per-trait EBV correlation | >= `0.999` |
| max absolute EBV difference per trait | <= `1e-2` after confirmed scale mapping |
| per-trait h2 | absolute difference <= `1e-3` (derived from matched `G0`/`R0`) |
| convergence | converged with no unreviewed boundary, singularity, or non-PD flag |

These bands match the BLUPF90 packet. If a tool's optimizer, convergence
criterion, or parameterization makes a band inappropriate (e.g. a looser default
convergence tolerance, or an unavoidable EBV centering difference), Fisher and
Curie must record an adjusted decision **before** any status claim changes.

## Report location

Copy a sanitized run report per tool to:

```text
docs/dev-log/comparator-runs/YYYY-MM-DD-asreml-multivariate-run.md
docs/dev-log/comparator-runs/YYYY-MM-DD-dmu-multivariate-run.md
docs/dev-log/comparator-runs/YYYY-MM-DD-wombat-multivariate-run.md
```

using `docs/dev-log/comparator-runs/TEMPLATE.md`. Each report must record tool
version, OS/host class, input checksums, exact command, full model/parameter
spec, convergence status, `G0`/`R0`/fixed/h2/EBV results on the matched scale,
the scale-mapping derivation, and a **Rose / Fisher / Curie** verdict.

Only **one** accepted, reviewed run is needed to fill the second-comparator slot;
additional tools strengthen the evidence but are not required.

Do not commit licensed or proprietary output if the ASReml/DMU/WOMBAT license or
local policy forbids redistribution. Commit enough version, command, summary, and
checksum provenance for a maintainer to reproduce the result instead.

## Claim boundary

Until an executed run report exists and is reviewed:

- this file is a run protocol, **not** comparator evidence;
- no ASReml-R, DMU, or WOMBAT comparator evidence is claimed;
- the existing reproduced `sommer` leg remains the **only** same-estimand REML
  comparator; **no second** same-estimand REML comparator is claimed;
- no `validation_status()` row, capability row, or public claim changes;
- `V4-MV-REML` stays **partial** until an executed run plus a Rose/Fisher/Curie
  verdict (with the twin gates `HSquared.jl#41`/`#49`) clear promotion.
