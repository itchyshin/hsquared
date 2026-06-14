# Inheritance systems roadmap

This article shows how `hsquared` is expected to grow beyond the
ordinary diploid additive animal model.

The core design rule is simple:

``` text
inheritance system -> relationship matrix K or precision matrix Q
model term         -> design matrix Z
engine target      -> variance component and BLUP/EBV calculation
```

That rule keeps animal breeding, plant breeding, evolutionary ecology,
and genomic work on one modelling ladder. It also keeps the public API
from turning into a bag of special cases.

## What works today

The default fit is the v0.1 additive animal model:

``` r

fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = pheno,
  family = gaussian(),
  REML = TRUE
)
```

The following standard extensions fit only through opt-in experimental
engine targets:

``` r

# permanent environment / repeatability
y ~ animal(1 | id, pedigree = ped) + permanent(1 | id)

# IID common environment
y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter)

# independent direct additive + maternal genetic effect
y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam)
```

Those are not unusual-inheritance models. They are useful stepping
stones: extra random effects, pedigree-linked second effects, and clear
extractor boundaries.

## Planned named effects

Some future effects already have reserved formula markers:

``` r

y ~ animal(1 | id, pedigree = ped) +
  maternal_env(1 | dam)

y ~ animal(1 | id, pedigree = ped) +
  paternal_genetic(1 | sire, pedigree = ped) +
  paternal_env(1 | sire)

y ~ animal(1 | id, pedigree = ped) +
  cytoplasmic(1 | maternal_line)

y ~ animal(1 | id, pedigree = ped) +
  imprinting(1 | id, pedigree = ped, parent = "maternal")

y ~ animal(1 | id, pedigree = ped) +
  dominance(1 | id, pedigree = ped) +
  epistasis(1 | id, pedigree = ped)

y ~ relmat(1 | id, K = K_custom)
y ~ precision(1 | id, Q = Q_custom)
```

These examples do not fit yet. Today the parser rejects them as planned,
not implemented.

## Planned inheritance systems

Other systems are roadmap examples rather than exported syntax:

``` r

# planned future shapes, not implemented
animal(1 | id, pedigree = ped, inheritance = selfing(rate = s))
animal(1 | id, pedigree = ped, inheritance = clonal())
animal(1 | id, pedigree = ped, inheritance = haplodiploid())
animal(1 | id, pedigree = ped, inheritance = polyploid(ploidy = 4))
animal(1 | id, pedigree = ped, inheritance = cytoplasmic())
```

These names are useful design placeholders, but the package does not
currently export `selfing()`, `clonal()`, `haplodiploid()`,
`polyploid()`, or an `inheritance =` grammar for
[`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md).

## Why kernels first

Most inheritance systems become mixed-model terms only after the
relationship or precision structure is clear.

| System | Kernel question | Public risk if rushed |
|----|----|----|
| selfing / partial selfing | How does inbreeding change additive covariance through the pedigree? | A standard diploid A matrix can give the wrong expectation. |
| clonal / asexual | Which records share genotypes, ramets, environments, or clone lines? | Clone identity can be confounded with common environment. |
| haplodiploid | How do sex-specific inheritance and relatedness enter A or Q? | Parent-offspring and sib covariances are not the ordinary diploid ones. |
| polyploid | What ploidy, double reduction, and dosage assumptions define relatedness? | Diploid shortcuts can misstate plant-breeding relationships. |
| cytoplasmic | What is the maternal-line transmission structure? | It can be mistaken for maternal environment. |
| imprinting | Which parent-of-origin effect is modelled? | Maternal and paternal allele-origin effects can be conflated. |
| dominance / epistasis | Which non-additive relationship matrix is used? | Additive h2 can be over-interpreted as total genetic variance. |
| custom K / Q | Who constructed the matrix, and on what scale? | Scale, ordering, and positive-definiteness mistakes become silent model errors. |

The engine should prefer sparse precision matrices when possible. If a
system cannot supply a well-defined `K` or `Q`, the formula should stay
planned.

## Validation gates

An inheritance system should not move beyond `planned` until all of
these are true:

- mathematical definition of the estimand and relationship/precision
  matrix;
- tiny deterministic pedigree or genotype example;
- ID ordering and missing-parent behaviour pinned by tests;
- positive-definite or positive-semidefinite checks where relevant;
- comparator check against an established package or a published worked
  example when one exists;
- recovery simulation for the variance component and predicted effects;
- extractor and summary wording that separates additive, non-additive,
  maternal, paternal, cytoplasmic, and environmental interpretations.

For dominance and epistasis, `nadiv` is a natural comparison target. For
diploid/autopolyploid A/G/H relationship construction, `AGHmatrix` is a
natural comparison target. For breeding-program simulations, `XSim.jl`
is a natural future partner.

## User-facing rule

The common path should stay easy:

``` r

y ~ fixed + animal(1 | id, pedigree = ped)
```

Specialist inheritance should be explicit:

``` r

# planned
y ~ fixed +
  animal(1 | id, pedigree = ped) +
  cytoplasmic(1 | maternal_line)
```

The user should never need to guess whether “maternal” means maternal
genetic, maternal environmental, cytoplasmic, parent-of-origin, or dam
identity. Names should stay longer until the biology is unambiguous.

## Background anchors

Useful software anchors include
[nadiv](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/j.2041-210X.2012.00213.x)
for non-additive genetic relatedness matrices and
[AGHmatrix](https://pubmed.ncbi.nlm.nih.gov/37471595/) for diploid and
autopolyploid A/G/H relationship construction. The package-level roadmap
also tracks custom relationship and precision matrices because many
plant, animal, and ecological designs will arrive as a known kernel
before they arrive as a named inheritance helper.

For now, these sources motivate the roadmap. They are not evidence of
current support for selfing, clonal, haplodiploid, polyploid,
cytoplasmic, imprinting, dominance, epistasis, or custom-kernel models.

See also:

- [Formula grammar
  roadmap](https://itchyshin.github.io/hsquared/articles/formula-grammar.md)
- [Fitting
  models](https://itchyshin.github.io/hsquared/articles/fitting-models.md)
- [Model
  status](https://itchyshin.github.io/hsquared/articles/model-status.md)
