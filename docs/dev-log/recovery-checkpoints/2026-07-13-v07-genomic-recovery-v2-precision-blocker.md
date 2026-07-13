# v0.7 genomic recovery-v2 pilot — precision blocker

**Outcome:** negative endpoint. The offset-7101 pilot completed, but it cannot
authorize confirmation or public activation.

## Frozen execution

- Totoro output root:
  `/home/snakagaw/hsq_work/v07-genomic-recovery-v2-offset7101`
- R execution/tooling commit:
  `0e4fa11cbb70b2f820c5015e11bf995d10c66c04`
- Julia execution/tooling commit:
  `c92663a47c8f5ce93cc984522614e4169717706c`
- campaign seal SHA-256:
  `4a921c039426faa400648752ec59bd3f049939098ec4f42b6faafc9e845b324c`
- pilot manifest SHA-256:
  `1264e87eeea10bf8dd9d6197a0f2ef865a2cd541e085bde22a655730ef894f61`
- pilot corpus lock SHA-256:
  `04f128168747aecab4847848de4498ebfb6efdf4aafb742d2e6f828e0d15c084`

The manifest contains 432 rows. All 432 attempt records are `success`, all 432
are `converged = true`, and all remain in the denominator.

## Pilot sizing result

| cell | converged / attempted | required confirmation N | pilot status |
| --- | ---: | ---: | --- |
| `n120_m600_r020` | 48 / 48 | 16,325 | `PRECISION_BLOCKER` |
| `n120_m600_r050` | 48 / 48 | 3,699 | `PRECISION_BLOCKER` |
| `n120_m600_r080` | 48 / 48 | 8,565 | `PRECISION_BLOCKER` |
| `n300_m150_r020` | 48 / 48 | 1,553 | `CONFIRMATION_ELIGIBLE` |
| `n300_m150_r050` | 48 / 48 | 335 | `CONFIRMATION_ELIGIBLE` |
| `n300_m150_r080` | 48 / 48 | 229 | `CONFIRMATION_ELIGIBLE` |
| `n300_m1000_r020` | 48 / 48 | 3,807 | `PRECISION_BLOCKER` |
| `n300_m1000_r050` | 48 / 48 | 911 | `CONFIRMATION_ELIGIBLE` |
| `n300_m1000_r080` | 48 / 48 | 2,021 | `PRECISION_BLOCKER` |

Five cells exceed the frozen 2,000-replicate ceiling. The preregistered rule is
campaign-wide, so partial eligibility cannot launch confirmation.

## Three-way recomputation and adjudication defect

- driver-R summary SHA-256:
  `f238846152921b2381428193c16f1cade80e2845c82a6ad9472d09e763ff65d0`
- independent base-R summary SHA-256:
  `f238846152921b2381428193c16f1cade80e2845c82a6ad9472d09e763ff65d0`
- independent Julia summary SHA-256:
  `a5be6a66e3d93ce66d8f9613f52fc4c0cf539b6cea18c600b57601adabf76acd`

Base R is byte-identical to the driver summary. Julia differs only in numeric
text formatting: its maximum absolute numeric difference from the driver is
`3.3306690738754696e-16`, with zero fields outside the frozen `1e-10`
tolerance. All three persisted summaries contain the same categorical result:
`PRECISION_BLOCKER` and `target_pass = false`.

The sealed adjudicator stopped before comparing all three persisted summaries.
It compared the in-memory pilot logical `FALSE` with its own lower-case TSV
spelling `false` as lexical strings. This is a representation defect, not a
statistical disagreement. Because the root binds the old driver commit and file
hashes, it was not monkey-patched and no post-hoc receipt was written.

## Decision boundary

- `pilot_adjudication_receipt.tsv` does not exist.
- `confirm_manifest.tsv` does not exist.
- offsets 7101:7148 are retired and will not be reused.
- the comparator now normalizes the single logical field and mutation-tests
  round-trip, inversion, invalid-token, missing-token, and retired-offset cases.
- offsets 7201:7248 are reserved only for a separately admitted future design;
  this arc does not launch them merely to manufacture a receipt.
- the ordinary genomic R route remains held and partial;
  `public_covered_count` remains 5.

This checkpoint is diagnostic evidence for the negative endpoint. It is not an
accepted recovery result, a capability promotion, G10, a release, or production
genomic validation.

## Exact commands

The sealed Totoro campaign used these canonical paths and launcher stages:

```sh
ROOT=/home/snakagaw/hsq_work/v07-genomic-recovery-v2-offset7101
DRIVER=/home/snakagaw/hsq_work/hsquared-v07-recovery-v2-driver
RUNTIME=/home/snakagaw/hsq_work/hsquared-v07-recovery-v2-runtime
JULIA=/home/snakagaw/hsq_work/HSquared-v07-recovery-v2
LAUNCHER="$DRIVER/tools/run-v07-genomic-recovery-v2.sh"

"$LAUNCHER" pilot-manifest "$ROOT" "$DRIVER" "$RUNTIME" "$JULIA"
"$LAUNCHER" run-tier "$ROOT" "$DRIVER" "$RUNTIME" "$JULIA" pilot 16
"$LAUNCHER" summarize "$ROOT" "$DRIVER" "$RUNTIME" "$JULIA" pilot
"$LAUNCHER" recompute-base-r "$ROOT" "$DRIVER" "$RUNTIME" "$JULIA" pilot
"$LAUNCHER" recompute-julia "$ROOT" "$DRIVER" "$RUNTIME" "$JULIA" pilot
"$LAUNCHER" adjudicate "$ROOT" "$DRIVER" "$RUNTIME" "$JULIA" pilot
```

The final command failed closed before writing
`pilot_adjudication_receipt.tsv`; therefore `confirmation-manifest` and
`run-tier ... confirm` were not run. Successor-tooling verification used:

```sh
Rscript -e 'testthat::test_file("tests/testthat/test-v07-genomic-recovery-v2.R", reporter = "progress")'
Rscript -e 'devtools::test(reporter = "summary")'
Rscript -e 'devtools::document()'
Rscript -e 'pkgdown::build_site(new_process = FALSE, lazy = FALSE)'
_R_CHECK_FORCE_SUGGESTS_=false Rscript -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'
git diff --check
```
