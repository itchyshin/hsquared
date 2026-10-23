# Check log: 2026-09-26 hsquared#237 R-lane cbind + permanent()

Branch: `cursor/237-mv-permanent-r`
Worktree: `~/local-scratch/lanes/hsquared-237-mv-permanent`
Base: `origin/main` @ `c36244b`

## Commands

```sh
cd ~/local-scratch/lanes/hsquared-237-mv-permanent
air format .
Rscript -e 'devtools::document()'
Rscript --vanilla -e 'devtools::test(filter = "multivariate-permanent-237|engine-julia-unsupported-parity|repeated-records-warning-352|hs-control-targets|julia-error-translation")'
Rscript --vanilla -e 'devtools::test(filter = "multivariate-fence-contract")'
```

Live opt-in (not CRAN lane):

```sh
PATH="$HOME/.juliaup/bin:$PATH" \
HSQUARED_JULIA_PROJECT="$HOME/local-scratch/lanes/HSquared.jl-237-mv-permanent" \
HSQUARED_JULIA_TESTS=true \
Rscript --vanilla -e 'devtools::test(filter = "multivariate-permanent-237")'
```

## Outcomes

- Focused 237 / parity / warning / control / error-translation / fence-contract:
  **FAIL 0 / WARN 0 / SKIP 3 / PASS 176**. Live #237 fit ran against
  `~/local-scratch/lanes/HSquared.jl-237-mv-permanent` (#398 @ `410f7efd`).
  Three skips are unrelated `test-julia-error-translation.R` live legs.
- Version **0.9.0**; `public_covered_count` **7**; no covered flip.
- NOT_CRAN was not set. No Julia twin edit. Julia #398 not merged from this lane.

## Notes

R consumes frozen `fit_multivariate_repeatability_reml`. Result target
`multivariate_repeatability_reml`; status experimental.
