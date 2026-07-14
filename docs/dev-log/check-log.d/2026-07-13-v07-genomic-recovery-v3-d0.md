# v0.7 Genomic Recovery-v3 D0 Spectral Replay

## Outcome

`D0_REPLAY_PASS` for the preregistered corpus and cross-language replay gate.
The \(C_c\) mechanism statistic is non-selection diagnostic evidence only. This
result does not admit fresh D0F or D1 phenotypes, prove recovery, activate the
default R route, change a capability row, or change
`public_covered_count = 5`.

No fresh v3 phenotype or recovery seed was generated. The replay read only the
retired immutable recovery-v2 offset-7101 corpus.

## Exact execution state

- R repository commit: `cdb33dc83017e9c4384aced032a0c3ee96235f72`
- Julia repository commit: `4c5e54de3870986f6799613302689df246b7df3e`
- Committed design doc 49 SHA-256:
  `0fb7a934f1385bfd62a6a4d572e035bacc19e7eed0382e8ec7b16a6faf1c8d2b`
- R D0 tool SHA-256:
  `3e1892f336d218782d9b0b1e0ef449329adf33d59298e5c0b3f25be64839dc01`
- Julia D0 tool SHA-256:
  `7b3b706cf374a020296fdb8ce3b97915698e5c2ddab4f6b9f9867f3c0c44ecdb`
- Totoro output root:
  `/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0-official-cdb33dc-4c5e54de`
- Immutable input root:
  `/home/snakagaw/hsq_work/v07-genomic-recovery-v2-offset7101`
- Input pilot manifest:
  `1264e87eeea10bf8dd9d6197a0f2ef865a2cd541e085bde22a655730ef894f61`
- Input corpus lock:
  `04f128168747aecab4847848de4498ebfb6efdf4aafb742d2e6f828e0d15c084`
- Input campaign seal:
  `4a921c039426faa400648752ec59bd3f049939098ec4f42b6faafc9e845b324c`
- Create-once bootstrap indices:
  `83473fdf56241b165830899c5534c37e621adf673dec7ed5479d7119f4f130a0`

The exact detached worktrees were clean before execution. BLAS threads were
pinned to one. The run used Totoro, never GitHub Actions.

## Cross-language adjudication

Both recomputers admitted all 432 exact packets and produced 103,248 projected
kernel eigenvalues. The formal base-R adjudicator verified the bootstrap
primary/sidecar/hash, the native-R fingerprint artifact, every output sidecar,
schemas, row order, character fields, and all numeric fields at the frozen
absolute tolerance `1e-10`.

```text
independent R-Julia D0 comparison: PASS
eigenvalues max_abs = 3.4638958368304884e-13
packet diagnostics max_abs = 2.6147972675971687e-12
cell summaries max_abs = 4.2632564145606011e-14
```

The exact marker and ID fingerprints agree across R, Julia, and the immutable
attempt records. Julia independently reconstructed K/Q and reproduced the
recorded raw Float64 K/Q fingerprints exactly. Base R independently
reconstructed K/Q and wrote its native raw fingerprints; those descriptive
hashes can differ at the last bit across toolchains. The scientific gates are
the exact marker/ID chain plus the frozen QK, K-versus-sym(Q^-1), eigenvalue,
and summary tolerances, as prospectively frozen in design doc 49 before this
official receipt.

## Mechanism summary

| cell | C_c | bootstrap 95% interval | mean spectral CV | mean effective rank |
| --- | ---: | ---: | ---: | ---: |
| n120_m600_r020 | 0.9281 | [0.7415, 1.0851] | 0.4665 | 97.73 |
| n120_m600_r050 | 0.9370 | [0.7564, 1.0874] | 0.4652 | 97.83 |
| n120_m600_r080 | 0.8044 | [0.6194, 0.9528] | 0.4651 | 97.84 |
| n300_m150_r020 | 1.0770 | [0.8346, 1.2845] | 1.4734 | 94.30 |
| n300_m150_r050 | 1.0402 | [0.8485, 1.1944] | 1.4720 | 94.43 |
| n300_m150_r080 | 1.1522 | [0.9156, 1.3478] | 1.4725 | 94.38 |
| n300_m1000_r020 | 0.8636 | [0.7108, 0.9819] | 0.5708 | 225.51 |
| n300_m1000_r050 | 0.9078 | [0.7430, 1.0456] | 0.5709 | 225.51 |
| n300_m1000_r080 | 0.8677 | [0.7067, 1.0016] | 0.5704 | 225.60 |

At the cell-summary level, the conditional projected-kernel information scale
was close to the observed ratio dispersion (`C_c = 0.80` to `1.15`; seven of
nine bootstrap intervals include one). Within-cell Spearman associations
between `SE_info` and absolute ratio error were weak and mixed (`-0.181` to
`0.344`), and the Normal boundary calculations remain descriptive. D0
therefore supports projected-kernel information as a plausible quantitative
explanation of dispersion at these nine old-pilot cells; it does not establish
a per-kernel monotone relationship, a causal mechanism, recovery, or a public
spectral rule.

## Output hashes

- base-R eigenvalues:
  `668b9e3e3117f961556badcbfff18067866fa860c8d5baf1db1764aff417b172`
- base-R packet diagnostics:
  `7c1cbc165df90e844bd4fdc7fc6ffb6dcbb8343c0d5ca9e7a588e4ca6d48c370`
- base-R native fingerprints:
  `f62d58558d6a04fc2f4636b0781ba8325b8aab9da87be0b0f4a7da0fbde01c62`
- base-R cell summary:
  `b7e1a6dfaa88d5ca1ee34ec89892c755b1e8006b3ae0b44950671922beb2f6ea`
- Julia eigenvalues:
  `ee677f997d28e9d3d0ac5740eaa53d9818dd74b19f14f433824efc2959eadd71`
- Julia packet diagnostics:
  `f945762c15dabe0a3c1030b83e9900549502d21b8e52f2b2346d2842a6f698ab`
- Julia cell summary:
  `f881c8e3878798586f1a024894f2c390ec1440e1bb4d2ca0fb30fd94fa975827`

## Tests and reviews

- recovery-v3 seed-lock selftest: PASS (`38,593` historical and `92,304`
  possible v3 exact seeds; zero intersection)
- independent base-R D0 selftest: PASS
- recovery-v3 state-machine selftest: PASS
- focused R tooling suite: 39/39 PASS
- Julia D0 selftest: PASS
- exact-head Julia package-check CI (`Pkg.test()` on Julia 1 and 1.10): PASS;
  D0 compute itself ran only on Totoro
- both repositories: `git diff --check` PASS
- full local R `devtools::test()`: 2,087 PASS, 68 skipped, and one expected
  fail-closed v2 selected-tree check because the current R tree adds only later
  status prose to the old frozen v2 implementation commit; the new recovery-v3
  tests are green

The following D0-only verdicts bind design-doc hash
`0fb7a934f1385bfd62a6a4d572e035bacc19e7eed0382e8ec7b16a6faf1c8d2b`, R
commit `cdb33dc83017e9c4384aced032a0c3ee96235f72`, and Julia commit
`4c5e54de3870986f6799613302689df246b7df3e`.

- Fisher statistical result review: CLEAN; independently verified the packet
  denominator, projected-eigenvalue count, efficient-information Schur
  complement, paired bootstrap, and diagnostic-only interpretation
- Noether mathematical review: CLEAN
- Hopper cross-twin parity review: CLEAN
- Grace reproducibility/admission review: CLEAN for this D0-only rerun
- Rose D0 claim-versus-evidence final re-audit: CLEAN after the wording and
  provenance corrections and the hash-bound Fisher receipt

Deliberate mutations made the seed collision, duplicate seed, partial/out-of-
order/post-stop D2 batch, malformed numeric comparison, changed bootstrap,
symlinked path component, non-regular file, unexpected directory, create-once
rewrite, checksum, fingerprint, eigenvalue, projection, information, and
bootstrap-index gates turn red.

## Commands

The exact commands used the detached worktrees and paths recorded above:

```sh
Rscript tools/v07_genomic_recovery_v3_d0_recompute.R \
  --mode=bootstrap --out-dir="$OUT/bootstrap"

OPENBLAS_NUM_THREADS=1 Rscript \
  tools/v07_genomic_recovery_v3_d0_recompute.R \
  --mode=recompute --input-root="$V2" --out-dir="$OUT/r" \
  --bootstrap="$OUT/bootstrap/d0_bootstrap_indices.tsv" \
  --bootstrap-sha256=83473fdf56241b165830899c5534c37e621adf673dec7ed5479d7119f4f130a0

OPENBLAS_NUM_THREADS=1 julia \
  sim/phase2_v07_genomic_recovery_v3_spectral_replay.jl \
  --mode=replay --corpus-root="$V2" --output-dir="$OUT/julia" \
  --bootstrap-indices="$OUT/bootstrap/d0_bootstrap_indices.tsv" \
  --bootstrap-sha256=83473fdf56241b165830899c5534c37e621adf673dec7ed5479d7119f4f130a0

Rscript tools/v07_genomic_recovery_v3_d0_recompute.R \
  --mode=compare --r-dir="$OUT/r" --julia-dir="$OUT/julia" \
  --bootstrap="$OUT/bootstrap/d0_bootstrap_indices.tsv" \
  --bootstrap-sha256=83473fdf56241b165830899c5534c37e621adf673dec7ed5479d7119f4f130a0
```

## Next gate

Implement and independently review D0F and the fresh D1 harness. No fresh
phenotype is admitted until their exact commits, environment, manifests,
mutation controls, and pre-seal receipts are clean.
