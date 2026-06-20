# START HERE — session handoff 4 (2026-06-20, ultracode engine+bridge sweep)

Resume rule: **live repo state wins over this doc.** Run the `hsquared-rehydrate`
skill (or `git status --short --branch`, `git diff`, then read the coordination
board + latest `check-log` entry + this file). Then continue.

## Inherit these (carry forward)

- **Goal (active `/goal`):** "look at the broader plan and try to finish the
  package(s) — look at the widget (mission control too)." Keep driving the package
  toward completion across all three lanes; keep the mission-control widget current.
- **Mission control widget:** gitignored; regenerate/refresh it as the session
  progresses (prior sessions refreshed it after each wave). It visualizes the
  lane board + capability status + twin coordination.
- **The plan (this session's discovery map):** a full deduped backlog of the
  remaining surface lives in the discovery workflow output (run id `wi3omhdhz`);
  the recommended-next slices and what's done/left are summarized in
  "Remaining backlog" below. Re-run a discovery sweep if the twin has moved.
- **User directive in force:** "ultracode all Julia stuff left and also the
  R-Julia bridge … keep communicating with your Julia twin." Drive order chosen:
  **Julia unlocks → bridge → docs/validation.** Use Workflows for substantive work
  (ultracode is on); adversarially verify prototypes before delivering.

## The key unlock (do not lose this)

**Live bridge verification recipe.** Julia is off-PATH at `~/.juliaup/bin/julia`
(1.10). To run the R bridge live against the engine:

```sh
PATH="$HOME/.juliaup/bin:$PATH" \
HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" \
NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-<x>.R")'
```

`hs_julia_bridge_available()` gates on `Sys.which("julia")`, so the PATH export is
mandatory. Standalone Julia prototypes run directly: `~/.juliaup/bin/julia file.jl`.
JuliaCall can segfault on teardown — run each live check in one process; a nonzero
exit *after* the result prints is the teardown, not a failure.

## What landed this session (all committed to `main` + pushed; all delivered to the twin)

Twin `HSquared.jl` is at HEAD `2f62781` (#81); #54 RR, #77-79 MV-REML, #81 selinv-PEV.

| Commit | What | Twin |
| --- | --- | --- |
| `bcac54a`,`1be1cd6` | Matrix-free **low-rank genomic AI-REML** (n=80k REML ~8s, exact to 2.3e-13), **Metal GPU** `W(W'B)` (k≥32 precision landmine verified), **symbolic-once cholesky**, design-pass plan + risk register | #51 brief, #58 plan |
| `d71b807` | **APY sparse genomic inverse** (first open-Julia; adversarially verified; sharp c<n test 3.4e-15; honest "compresses only when genomic dim ≪ n") | #51 |
| `9801d07` | **Meuwissen-Luo O(n) sparse inbreeding** (the >10k-pedigree A⁻¹ unlock; bit-exact, n=250k in 10s) + **symbolic-once `fit_ai_reml` PR seed** (diff+test) | #51, #58 |
| `355f445` | **Random-regression (reaction-norm) bridge** — `animal(rr(age, order=2)|id, pedigree=ped)`, 5 extractors, **live-verified == engine to 0.00e+00**, 57 live assertions pass | #61 grammar proposal |
| (this handoff's commit) | **Doc reconciliation** — corrected false "planned" claims (LOCO/single-step/selinv-PEV are engine-shipped, R-surfacing-pending), 7/12-seed + no-detectable-bias nuance | — |

All prototypes + the staged engineering plan + scout notes are in
`docs/dev-log/prototypes/` (README has every result table) and
`docs/dev-log/scout/`.

## Twin coordination — OPEN threads (check for replies first)

- **#61** — proposed the `rr()` grammar (`animal(rr(age, order=k)|id)`; `order` =
  #coefficients; provisional). Bridge is built + live-verified. **Awaiting her ack**;
  if she wants different surface syntax, only `hs_parse_rr_lhs` changes.
- **#51** — asked **who carries the pedigree-A⁻¹ scaling** (the Meuwissen-Luo patch
  into `pedigree.jl` is her lane to apply). APY + M-L + matrix-free briefs all there.
- **#58** — symbolic-once `fit_ai_reml` PR seed + the PosDefException-guard companion
  item (her lane to apply).

## Remaining backlog (from discovery map `wi3omhdhz`; ranked, unblocked first)

1. **MV (t=2) known-truth recovery study** — `data-raw/multivariate-recovery-study.R:42`
   still says `RECORDED RESULT: PENDING`. Run the ADEMP harness via the live bridge
   (recipe above), fill the block (truth vs mean(hat), bias ± 2·MCSE per G0/R0 element,
   rg, per-trait h², EBV accuracy, convergence), commit. Pairs with an SE-coverage leg.
   **Unblocked, high value.** (This was next when the session paused.)
2. **More bridge-activation** of landed engine surfaces (no R door yet): single-step
   **H⁻¹ construction** (`single_step_inverse`/`fit_single_step_reml`), unconditional
   **selinv-PEV** unpack, **binomial-with-trials** + variational marginal, the
   engine-built G/Ginv inspector. Mirror an existing target; live-verify.
3. **More Julia prototypes** (R-lane-assigned by the scaling plan): the **CPU batched
   marker-scan reference** (gates all GPU work; the design pass measured ~30× on CPU
   alone — verify), **AI-REML convergence hardening**.
4. **Twin-blocked** (do NOT start): FA/low-rank covariance (#42), metafounders/UPG,
   correlated direct-maternal, production sparse fitting, calibrated GWAS thresholds,
   GPU ext/ wiring.

## Definition-of-done discipline (followed all session)

Per-slice: implement/prototype → adversarially verify (Workflow) → live-verify if
engine-coupled → `air format` + `devtools::document/test/check` + `pkgdown::check_pkgdown`
→ record exact commands in `check-log.md` → board row → after-task → Rose audit →
commit (plain imperative subject, **no Co-Authored-By**) → push → post to twin.
Honesty gate: engine-shipped ≠ R-surfaced; separate R-lane-verified from design-pass
leads; no public capability claim without live evidence + the experimental fence.
