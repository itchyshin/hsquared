# Planned Genomic And QTL Formula Markers

Date: 2026-06-13

Active lenses: Boole, Jason, Lovelace, Rose, Pat.

Spawned subagents: none.

## Scope

Reserve readable user-facing formula vocabulary for planned genomic,
single-step, marker-effect, marker-scan, and QTL/eQTL workflows without
claiming any of those models are implemented.

## Scout Notes

Local sibling lesson from `gllvmTMB` and `DRM.jl`: formula markers are useful
when they are honest parser tokens. They become risky when they look decorative
but are silently ignored or treated as ordinary fixed effects. This slice
therefore adds inert marker functions and parser errors together.

## Implementation

Added inert markers:

- `genomic()`;
- `single_step()`;
- `markers()`;
- `marker_scan()`;
- `qtl_scan()`.

Updated the parser so these markers fail before model-frame construction with
planned-not-implemented wording. This prevents undefined marker objects from
being evaluated and prevents planned genomics/QTL terms from being mistaken for
implemented model components.

Updated:

- tests;
- roxygen documentation and `NAMESPACE`;
- pkgdown reference index;
- NEWS;
- public claims register;
- capability status;
- validation debt;
- model-status article.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated `NAMESPACE` and
  `man/genomic_markers.Rd`.
- `Rscript -e "devtools::test(filter = 'formula-animal')"`: `17 pass`,
  `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `158 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- the markers reserve planned formula vocabulary;
- the parser rejects these terms as planned, not implemented.

Blocked wording:

- genomic prediction works;
- marker scans, QTL scans, or eQTL scans run;
- single-step or GBLUP fitting is implemented;
- marker effects are estimated.

## Tests Of The Tests

The tests check both sides of the guardrail:

- marker functions return invisibly when called as syntax helpers;
- the parser fails with planned-not-implemented errors before evaluating marker
  objects.

## Next Work

1. Create a Julia-side model-spec vocabulary for these planned markers.
2. Add an R model-spec object for genomic relationship inputs after the Julia
   contract exists.
3. Keep QTL/eQTL scans as roadmap syntax until genotype storage and validation
   are real.
