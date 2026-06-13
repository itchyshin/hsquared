# Formula Grammar

Phase 0 records planned grammar only. The R package does not yet parse or fit
these model terms.

## V0.1 Planned Syntax

```r
y ~ fixed + animal(1 | id, pedigree = ped)
```

`animal()` means an additive genetic random effect whose relationship structure
comes from a pedigree. The Julia engine should use sparse Ainv rather than
constructing and inverting dense A.

## Later Relationship Terms

```r
genomic(1 | id, Ginv = Ginv)
single_step(1 | id, Hinv = Hinv)
maternal(1 | dam, pedigree = ped)
permanent(1 | id)
common_env(1 | litter)
relmat(1 | id, Kinv = custom_Kinv)
kernel(1 | id, precision = Q_custom)
```

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
