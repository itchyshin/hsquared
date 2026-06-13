# Validation Canon

Validation is a first-class product surface. A public capability needs evidence
before it is advertised as working.

## Validation Hierarchy

1. Tiny deterministic hand checks.
2. Pedigree and Ainv known examples.
3. Simple Mrode-style examples.
4. ASReml comparison when available.
5. BLUPF90, DMU, or WOMBAT comparison where reproducible.
6. XSim simulation truth for later genomic and selection examples.

## Metrics

Record:

- Ainv construction time;
- model matrix construction time;
- ML/REML optimization time;
- total time;
- peak memory;
- number of records;
- number of animals;
- number of fixed-effect levels;
- number of traits;
- number of nonzero entries.

## Comparator Discipline

Do not compare different estimands. Before calling a difference an engine bug,
confirm the DGP, fitted model, estimator, scale, and missing-data handling.

## Current Validation Atoms

- Tiny deterministic Henderson-style three-animal `Ainv` fixture: checks R
  payload ordering, sparse `Z`, and live Julia `pedigree_inverse()` agreement
  when a sibling `HSquared.jl` checkout is available.
- Optional Mrode9/nadiv pedigree `Ainv` comparator: checks Julia
  `pedigree_inverse()` against `nadiv::makeAinv()` for the Mrode9 pedigree when
  optional dependencies are available.
- Supplied-variance Henderson MME fixture: checks an independent R solve
  against Julia `henderson_mme()` for fixed effects, EBVs, fitted values, h2,
  and optional dense validation-path PEV/reliability when the sibling Julia
  checkout exposes those extractors. This does not estimate variance
  components.
