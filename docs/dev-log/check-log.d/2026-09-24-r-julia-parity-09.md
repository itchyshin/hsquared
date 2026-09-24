# 2026-09-24: R↔Julia engine=julia parity-09 (experimental 0.9.0)

- Worktree: `~/local-scratch/lanes/hsquared-r-julia-parity-09`
  branch `cursor/r-julia-parity-09-inventory`
- Commits: S2 `4ed37d4` · S3 `c392a5a` · S4 `44d5410` (+ S5 closeout this entry)
- Julia twin pointer: `~/local-scratch/lanes/HSquared.jl-r-julia-parity-09`
  `b68e8dd8` on `docs/design/12-bridge-compatibility.md`
- Version **0.9.0**; `public_covered_count` **7**; no covered flip; no push/merge

## Commands and outcomes

```sh
# Unsupported parity (S2)
Rscript -e 'devtools::load_all(".", quiet=TRUE);
  testthat::test_file("tests/testthat/test-engine-julia-unsupported-parity.R")'
# → [ FAIL 0 | WARN 0 | SKIP 0 | PASS 28 ]

# REACHABLE smoke (S3), Julia twin present
NOT_CRAN=true HSQUARED_JULIA_TESTS=true \
HSQUARED_JULIA_PACKAGE_PATH="$HOME/local-scratch/lanes/HSquared.jl-r-julia-parity-09" \
Rscript -e 'devtools::load_all(".", quiet=TRUE);
  testthat::test_file("tests/testthat/test-engine-julia-parity-smoke.R")'
# → [ FAIL 0 | WARN 2 | SKIP 3 | PASS 16 ]
#    skips: single_step_construct, metafounder, metafounder_single_step
#    warnings: known MV SE bridge_errors + repeated-records honesty (not fails)

# Unlazy
node ~/shinichi-brain/skills/unlazy/scripts/gate-check.mjs --root . \
  --cwd /Users/z3437171/local-scratch/lanes/hsquared-r-julia-parity-09 \
  --approve --reverify .unlazy/r-julia-parity-09/gates/leaf-S4.md
# → ALL MET (exit 0)
```

Boundary: inventory + honesty + skip-guarded smoke only. Dirty Dropbox trees
untouched. Codex #202 / #322 untouched. No CRAN / tag / promotion.
