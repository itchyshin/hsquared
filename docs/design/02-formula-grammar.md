# Formula Grammar

The R package now parses and fits the narrow v0.1 animal-model syntax through
the `HSquared.jl` engine when local Julia, `JuliaCall`, and the sibling checkout
are available. It also builds a tested internal bridge payload for contract
preview and validation. Later grammar remains planned unless explicitly marked
as opt-in and experimental.

## V0.1 Parsed Syntax

```r
y ~ fixed + animal(1 | id, pedigree = ped)
```

With `data = hs_data(..., pedigree = ped)`, users may omit the repeated
pedigree argument:

```r
y ~ fixed + animal(1 | id)
```

`animal()` means an additive genetic random effect whose relationship structure
comes from a pedigree. The Julia engine should use sparse Ainv rather than
constructing and inverting dense A.

Current default-fit limits:

- exactly one `animal()` term;
- random-intercept syntax only: `1 | id`;
- `pedigree = ped` required for plain data frames;
- omitted `pedigree =` allowed only when `data` is an `hs_data()` bundle with a
  pedigree component;
- Gaussian identity-link response only;
- `cov =`, long-format trait syntax, marker scans, selfing, QTL, and
  non-Gaussian syntax aborts before marshalling;
- repeatability, two-effect, genomic, single-step, SNP-BLUP, and multivariate
  models are parsed only through opt-in experimental targets, not the default
  v0.1 fit path.

Current bridge-payload notes:

- `X` is built with base R model-matrix semantics.
- `Z` is a sparse animal-incidence matrix with one row per observation.
- pedigree IDs are normalized to parent-before-offspring order;
- the payload records parent indices for Julia-side sparse `Ainv`
  construction;
- the default fit path is the v0.1 univariate Gaussian animal model; genomic,
  repeatability, two-effect, SNP-BLUP, and multivariate paths are opt-in and
  experimental; non-Gaussian, QTL/GWAS/eQTL, structured covariance grammar, and
  unusual inheritance remain planned.

## Later Relationship Terms

```r
genomic(1 | id, Ginv = Ginv)
single_step(1 | id, Hinv = Hinv)
single_step(1 | id, pedigree = ped, markers = M)
single_step(1 | id, pedigree = ped, markers = M, group = group, Gamma = Gamma)
metafounder(1 | id, pedigree = ped, group = group, Gamma = Gamma)
permanent(1 | id)
common_env(1 | litter)
maternal_genetic(1 | dam, pedigree = ped)
maternal_env(1 | dam)
paternal_genetic(1 | sire, pedigree = ped)
paternal_env(1 | sire)
dominance(1 | id, pedigree = ped)
epistasis(1 | id, pedigree = ped)
cytoplasmic(1 | maternal_line)
imprinting(1 | id, pedigree = ped, parent = "maternal")
relmat(1 | id, K = custom_K)
precision(1 | id, Q = custom_Q)
```

Some later markers are now opt-in experimental (`genomic()`, the supplied-`Hinv`
and constructed-`Hinv` `single_step()` paths, `permanent()`, `common_env()`, and
`maternal_genetic()` in their gated targets). `single_step(..., group =, Gamma =)`
is parsed only as a contract-only supplied-`Gamma` `H^Gamma` payload gate; the
future `target = "metafounder_single_step"` fit is recognized but not wired.
`metafounder()` is reserved as a contract-only syntax for a supplied `Gamma`
matrix and animal-to-metafounder `group` labels; it still errors explicitly as
planned, not implemented. None of the later markers changes the default v0.1
animal-model fit path.

## Later Covariance Grammar

The preferred multivariate grammar separates random-effect design,
relationship source, and covariance among traits:

```r
animal(trait | id, pedigree = ped, cov = us())
animal(trait | id, pedigree = ped, cov = diag())
animal(trait | id, pedigree = ped, cov = lowrank(K = 2))
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

Definitions:

- `us()` is full unstructured covariance.
- `diag()` is trait-specific variances only.
- `lowrank(K)` is `Lambda Lambda'`.
- `fa(K)` is `Lambda Lambda' + Psi`.

Avoid naming the reduced-rank form `rr()` because that often suggests random
regression in quantitative genetics.
