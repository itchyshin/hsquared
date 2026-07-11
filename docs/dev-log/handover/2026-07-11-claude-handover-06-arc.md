# Handover — 2026-07-11 (PM): the 0.5/1.0 planning arc + the 0.6 multivariate slice

**From** Claude (Opus 4.8), long session · **to** Claude/next session ·
`hsquared` R lane + `HSquared.jl` twin. Everything below is committed + pushed on
two open PRs (nothing mid-flight, working tree clean).

## What shipped today (all on open PRs vs `main`)

**PR #131 — planning/design layer** (`docs/2026-07-11-release-model-decoupling`):
- **Release model decision** (`decisions.md`, `ROADMAP.md`): first registration =
  **0.5.0 not 1.0** (brain D-40/D-42/D-41/D-23), releases **decoupled from
  phases**, **1.0 = maturity (covered+production+interval-calibrated+stable
  API+maintainer declaration), 1.0 ≠ "Phase 6 done."**
- `docs/design/35` API-stability contract · `36` Phase-3→6 execution plan · `41`
  lane goal charter (with the **autonomy boundary**) · `37` **NG-1 non-Gaussian
  heritability-scale estimand contract — NG-2 SIGNED OFF** (ratify-with-fixes 3–1,
  math clean; logit `primary=latent`; §8 wording punch-list pending) · `38` MV-4
  grammar freeze **RATIFIED** · `39` H0 coverage-flip proposal · `40` MV-5
  pre-declaration · `42` FA calibration diagnosis · `43` genomic-GREML G0 design.

**PR #132 — 0.6 multivariate slice** (`feat/2026-07-11-mv4-cbind-autoroute`):
- **MV-4** cbind() multivariate auto-routes on the default path (no covered flip).
- **MV-1** in-suite full-unstructured `sommer` comparator (off-diagonal R0) — CI-gated.
- **MV-2** verified + cited the executed `blupf90+` 2.60 2nd same-estimand REML leg
  (discharged) — ledger rows refreshed.
- **MV-3** derived-estimand identity gate (`r_g`, `h²`) + locked citation (doc 04).
- **MV-5** broadened-recovery driver committed (t=3, 2 truth points, full-sib 456,
  pre-declared, pre-run). Full `test()` 0-fail throughout.

(The 0.2.0 honesty baseline #125/#127/#128/#129/#130 already merged to `main`
earlier today; that arc is done.)

## CARRIED OVER — resume here (in priority order)

1. **MV-5 parallelization (a)** — add `parallel::mclapply` (≤96 cores) to the seed
   loop in `data-raw/multivariate-recovery-broadened-study.R` so the 1000-fit
   confirm tier is tractable (serial ≈11 hr). NOT done.
2. **MV-5 simulation-check review (b)** — run the `simulation-check` skill / ADEMP
   review of the two truth points + full-sib design before the confirm tier. NOT done.
3. **MV-5 run** — live Julia campaign on **Totoro** (screen 48 → confirm 500).
   **Codex or the user runs it — NEVER concurrently with Claude** (see the new
   memory rule: Claude/Codex are sequential hand-off, not parallel). Recipe is in
   the previous chat turn + doc 40. Paste results back → Claude scores the gate +
   writes the recovery-checkpoint.
4. **FA discriminating test** — the turnkey Julia script (`scratchpad/
   fa_discriminating_test.jl`, also in chat) is handed to the user to run in
   `HSquared.jl`; verdict classifies Heywood-boundary vs optimizer vs sampling.
   Do NOT launch a Totoro FA warm-start campaign until it runs (doc 42).
5. **NG-1 §8 wording punch-list** (doc 37) — mechanical labelling edits; then the
   Boole extractor-grammar freeze + maintainer nod.
6. **0.6 flip** — after MV-5 passes: Darwin biology sign-off + Rose + your G10.
7. **Maintainer-gated**: merge PRs #131/#132; the 0.5 release decisions
   (twin #267/#268 parity, stale-`v0.1.0`-tag, SystemRequirements, cran-comments,
   Julia-registers-first).

## New durable rule (recorded to the brain)

**Claude and Codex are never run at the same time — sequential hand-off only.**
Claude prepares live-toolchain work turnkey and hands it off; it does not propose
delegating to Codex as a *concurrent* step. (Corrected by Shinichi this session.)

## Resume command

```sh
cd "/Users/z3437171/Dropbox/Github Local/hsquared"   # skill: hsquared-rehydrate
gh pr view 131; gh pr view 132   # today's two open PRs
# read: docs/design/36 (execution plan), 41 (lane goal), 40 (MV-5 pre-decl)
```
