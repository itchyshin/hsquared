# 43 — Genomic GREML G0: estimand, grammar freeze, comparator plan (0.7)

> **Status: PROPOSAL, 2026-07-11.** The G0 start-now design for the 0.7 genomic
> GREML covered flip (`docs/design/36-phase3-6-execution-plan.md`). Pins the
> genomic-scale estimand, a Boole-freeze-ready dispatch grammar, and the
> same-estimand comparator plan; flags three consistency defects to fix before the
> flip. All covered-flip / grammar-freeze / compute-go steps stay maintainer-gated
> (`docs/design/41-lane-goal-to-1.0.md` §5).

## 1. The estimand (and why genomic-h² ≠ pedigree-h²)

`h²_g = σ²_g / (σ²_g + σ²_e)` on the **VanRaden `G = WW'/k`** scale
(`k = 2·Σ p(1−p)`; `HSquared.jl/src/genomic.jl:8-11,35,43-117`). This is
**genomic/SNP heritability relative to `G`'s allele-frequency base — NOT pedigree
narrow-sense h²**. It differs on three axes, each of which must be disclosed:

1. **Base population** — `G` is centred by `2p` and scaled by `k` (a
   sample/allele-frequency base), vs `A`'s founder base (VanRaden 2008;
   Legarra 2016).
2. **SNP-capture** — `h²_g ≤ h²_pedigree` (markers capture only LD-tagged
   additive variance; Yang et al. 2010).
3. **Implementation scale** — the ridge/conditional-on-`Ginv` construction gives
   `diag(inv(Ginv)) ≠ 1` (`validation_status.jl:151`), so `σ²_g` is
   conditional-on-`Ginv`, not a founder-base additive variance.

No clean Mrode/textbook genomic-h² anchor exists → the flip carries the **explicit
no-anchor disclosure** (Standard-Tier gate item 2), never an implied pedigree
anchor.

## 2. Dispatch grammar (Boole-freeze-ready)

A `genomic()` primary with a supplied `Ginv` **or** `markers = M` — univariate
Gaussian REML, no second/iid effect — auto-routes to the genomic GREML target on
the default `fit` path:
- `markers = M` → GREML/GBLUP (engine builds `G`), **not** SNP-BLUP;
- `single_step(...)` stays opt-in (0.8), not auto-routed here;
- frozen argument names + the `family = gaussian()`, REML-only, single-effect
  precondition are the Boole-freeze surface (mirror the `docs/design/38` format).

## 3. Comparator plan (same-estimand, not agreement)

| Tool | Role | Same-estimand? | Availability |
|---|---|---|---|
| **sommer 4.4.5** `mmer(..., vsr(Gu=G))` | **PRIMARY** component leg | yes — REML on the *supplied engine `G`* | installed |
| **rrBLUP 4.6.3** `mixed.solve(K=G)` | SECONDARY (independent EMMA optimiser) | yes — same estimand | CRAN (reinstall) |
| **GCTA** `--reml --grm` | confirmatory h²+SE | yes (after GRM reconciliation) | host-gated (binary, not installed) |
| BGLR | — | **no** (Bayesian) | agreement-only — label, never parity |
| AGHmatrix | G construction only | n/a | excluded from the VC gate |

**Critical trap (must not be reused):** the 2026-06-22 run tested a
**supplied-variance** fixture, so it logged rrBLUP/BGLR at *agreement* level only
(`docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-run.md`).
The flip needs a **NEW run against a REML-estimated-variance target**, each tool
fed the engine's **exact `G`** (one scale), where sommer + rrBLUP earn *parity*,
not agreement. Recovery gate: 48-seed bias/MCSE screen → 2000-rep confirm
(Totoro → DRAC), mirroring `V2-GREML` (`validation_status.jl:151-152,219-223`).
Acceptance band (maintainer/Fisher to ratify): σ²_g/σ²_e within ~1–2% relative,
h² within ~0.01–0.02 absolute (mirror the pedigree gryphon band,
`docs/design/23-comparator-policy.md:44-49`).

## 4. Three consistency defects to fix BEFORE the flip

- **N1 — one variance, two names.** The single genomic additive variance is
  `σ²_a` in the GBLUP payload but `σ²_g` in SNP-BLUP, related by
  `σ²_g = σ²_a·k` (`genomic.jl:385-397`). Pin as a within-package **identity
  test** (gate item: derived estimand identity) and unify the surfaced label.
- **N2 — honesty defect (mislabel).** `heritability()` currently labels the
  genomic ratio as pedigree **narrow-sense direct h²** with no conditional-base
  disclosure (`R/extractors.R:31-53` has no genomic branch vs
  `validation_status.jl:151`). A genomic fit must return a **genomic-scale-labelled**
  h² with the §1 disclosure — never a bare pedigree h². (Same "scale label travels
  with the number" principle as NG-1.)
- **N3 — silent estimand knob.** The `markers` auto-route injects a default
  `ridge = 0.01` (`R/model-spec.R:251`), unsurfaced and unfrozen — an
  estimand-affecting parameter. **Freeze it as part of the estimand and disclose
  it**; decide whether `G=` (Ginv-only) is rejected or engine-inversion documented.

## 5. Open questions (maintainer / named-lens)

1. Freeze `ridge = 0.01` in the estimand + disclose; `G=` handling (Boole+maintainer).
2. Is sample-`p` the frozen default (disclose h²_g is then relative to sample
   allele frequencies), and is a base-`p` `allele_frequencies` argument exposed at
   0.7 or deferred? (Fisher+Boole)
3. Freeze `method = :vanraden1`; is `method` user-exposed? Bears on GCTA GRM
   reconciliation (Fisher+Jason).
4. Provision a GCTA (+ BLUPF90 preGSf90) host now for the confirmatory h²_SNP leg,
   or defer past 0.7 with sommer+BLUPF90 sufficient for a two-sided flip? (Maintainer)
5. Confirm the no-anchor disclosure for gate item 2 (no genomic textbook anchor).

## 6. Provenance

VanRaden 2008 (J. Dairy Sci. 91:4414); Legarra 2016 (Theor. Popul. Biol.
107:26); Legarra-Aguilar-Misztal 2009; Powell-Visscher-Goddard 2010; Yang et al.
2010/2011 (GCTA). Engine: `genomic.jl:8-11,119-136,385-397`,
`validation_status.jl:151`. R: `model-spec.R:237-259`, `genomic-markers.R:43-45`,
`extractors.R:31-53`, `hsquared.R:508-534`.
