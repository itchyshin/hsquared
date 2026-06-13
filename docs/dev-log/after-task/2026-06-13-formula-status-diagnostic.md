# Formula Grammar Status Diagnostic

Date: 2026-06-13

Active lenses: Pat, Boole, Emmy, Rose, Grace.

Spawned subagents: none.

## Scope

Add a small user-facing diagnostic that reports which formula terms are parsed
today, reserved as inert markers, or still roadmap-only.

## Implementation

Added:

- `formula_status()`;
- `print.hs_formula_status()`;
- tests for row count, parsed/reserved/planned status, and print output;
- pkgdown reference entry;
- README, NEWS, model-status, formula-grammar, claim, capability, and
  validation-debt wording.

The returned object is a data frame with:

- `term`;
- `category`;
- `phase`;
- `syntax_status`;
- `fitting_status`;
- `current_behavior`.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated `NAMESPACE` and
  `man/formula_status.Rd`.
- `Rscript -e "devtools::load_all(quiet = TRUE); print(formula_status())"`:
  printed a 20-row `hs_formula_status` table.
- `Rscript -e "devtools::test(filter = 'phase0-api')"`: `47 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `186 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

Remote checks:

- Pending first push for this slice.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- `formula_status()` reports grammar status;
- the table distinguishes parsed, reserved, and planned syntax.

Blocked wording:

- `formula_status()` parses user formulas;
- `formula_status()` fits or enables any planned model;
- reserved syntax is engine-ready.

## Next Work

1. Mirror this status table in Julia Documenter once HSquared.jl has a matching
   model-spec vocabulary table.
2. Add `formula_status(term = ...)` only if users need filtering later.
3. Update this table whenever the parser graduates any reserved term into an
   implemented contract.
