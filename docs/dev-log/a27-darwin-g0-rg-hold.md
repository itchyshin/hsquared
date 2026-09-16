# A27 Darwin G₀ / r_g sheet — **SIGNED** (2026-09-02)

> **SIGNED.** Owner Darwin ink recorded. **Not** a covered flip.  
> `public_covered_count` stays **5**. R multivariate stays `partial`.  
> Source scratch: `~/local-scratch/h2-a27-darwin-sign-sheet.md` (inked 2026-09-02).  
> Echoed on `cursor/mv4-060-20260902` from owner authorization source phrase `chat "go ahead" (Shinichi, 2026-09-02)`.  
> Prior General+TagBot HOLD language is **superseded** (G0 ARMED; registration DEFERRED OK).

**0.6 gate — biology SIGN only.** Does **not** authorize G10 or `partial → covered`.

```
Active lenses: Darwin (SIGNED). Ada / Rose / Shannon as packet context.
Spawned subagents: none
Current lane: cursor/mv4-060-20260902 (R MV-4 WT) — A27 SIGN echo
```

---

## One-line action

**SIGNED as recommended.** Headline recovered quantity = **G₀ / r_g**. Items 1–7 SIGN.
Ranga citation pins KEEP AS DRAFTED. Teaching/field fences retained below.

---

## What A27 signs

Design-41 §3 criterion 5 (campaign R
`docs/design/41-lane-goal-to-1.0.md` @ `2516490`):

> Darwin sign-off on the biologically-meaningful recovered quantity
> (for correlated models, the covariance/correlation between effects).

Capability / canon (verified this pass on the campaign trees):

| Surface | What it says A27 is about | Status this pass |
|---|---|---|
| R `capability-status.md` multivariate row | R-public `cbind()` k=2 Gaussian animal model stays **`partial`**. Engine `V4-MV-REML` is already **covered**. Flip still needs Darwin A27 + Rose + owner G10. `public_covered_count` **5**. | Confirmed at R `2fc250c` |
| Julia `capability-status.md` `V4-MV-REML` | Engine estimates G₀ / R₀ and returns correlations + per-trait h². Covered at validation scale; does **not** confer the R flip. Count stays **5**. | Confirmed at Julia `7d4ca106` |
| Both `04-validation-canon.md` “Locked Derived-Estimand Identities” | `r_g = cov2cor(G0)`; `h²_k = diag(G0)/(diag(G0)+diag(R0))`. Falconer & Mackay / Lynch & Walsh pins. | Present on **both** lanes |

| Role | Quantity | Darwin job |
|---|---|---|
| **Primary (sign this)** | Genetic covariance **G₀** and genetic correlation **r_g = cov2cor(G₀)** | Correlated multitrait biology lives in the off-diagonals. A flip that only advertises two univariate h² values would mis-teach. |
| Secondary (allowed, not the headline) | Per-trait **h²_k = G₀[k,k] / (G₀[k,k] + R₀[k,k])** | Identity-tested (MV-3). Useful descriptors, not the Darwin headline for a correlated model. |
| Components (Fisher/Curie, not Darwin headline) | Unique G₀ / R₀ elements | External-comparator gated (`sommer`, `blupf90+`). Darwin does not re-score those numbers. |
| **Out of A27 / out of 0.6** | Interval claims on r_g / h²; **k ≥ 3**; `genetic_structure = "diagonal"`; field-empirical genetic correlations | Point-estimate k=2 only. Intervals stay experimental / uncalibrated (criterion 7). |

You are **not** signing code correctness, comparator digits, A26 plumbing,
a covered flip, G10, field-empirical validity, or Block 1.

---


## Evidence already on `origin/main` (cite for one-shot SIGN)

**Measured 2026-09-02 via `gh` against `itchyshin/hsquared` + `itchyshin/HSquared.jl` `main`.**
Tips this poll: R `28a0e7ec9` · Julia `5747df1acf`. Use these paths/SHAs/test names so Darwin need not hunt campaign trees. Campaign SHAs in the older table below remain historical; **prefer origin citations for ink**.

| Role for G₀ / r_g | Path | Last-touch on `main` | Test / checkpoint name |
|---|---|---|---|
| Criterion text (Darwin signs covariance/correlation) | R `docs/design/41-lane-goal-to-1.0.md` §3 item 5 | `251649026` | design-41 §3.5 |
| Locked identities `r_g = cov2cor(G0)`; per-trait h² | R `docs/design/04-validation-canon.md`; Julia mirror | R `529a5a2b7` · J `7ab28d3644` | “Locked Derived-Estimand Identities” |
| MV-3 identity + genuine off-diagonals | R `tests/testthat/test-multivariate.R` | `672368c8d` | `test_that("R consumes the shared Phase 4 multivariate parity fixture", …)` (MV-3 block ~L649–663: `r_g == cov2cor(G0)`, `h2_k == G0[k,k]/(G0[k,k]+R0[k,k])`) |
| Teaching fixture (known-truth G₀/R₀) | R `tests/testthat/fixtures/phase4_multitrait_parity/`; Julia `test/fixtures/phase4_multitrait_parity/` | Julia fixture dir `6746c4b4b5` | shared `phase4_multitrait_parity` |
| R cold-start recovery (G₀/R₀/r_g + h²) | R `data-raw/multivariate-recovery-study.R` | `94e94d3f2` | 100-rep t=2 study |
| Engine predeclared 48-seed gate | Julia `docs/dev-log/recovery-checkpoints/2026-06-22-mv-reml-predeclared-48seed.md` | `24ee2d9cb5` | MV-REML 48-seed PASS |
| Full-sib / 3-trait confirmatory | Julia `.../2026-06-30-mv-fullsib-48seed.md`, `.../2026-06-30-mv-3trait-48seed.md` | `71d2da14be` / `b14defd210` | both PASS |
| C8 broader-DGP scope edge | Julia `.../2026-07-12-coverage-recovery-evidence-reconciliation.md`; R `.../2026-07-10-coverage-recovery-results.md`; driver `sim/phase4_v5_mv_recovery_reseed.jl` | J `d0b159459e` · R `b90d4c345` · driver `8d782e0d2a` | DRAC `47925486`; 14/16; fails only pre-registered extreme r_g × 1-record |
| Component comparators (not Darwin headline) | Julia sommer / blupf90+ checkpoints; R in-suite sommer tests | `b84749dff8` / `553826273c` | R: `optional sommer comparator matches the Phase 4 FULL-UNSTRUCTURED target` |
| Mrode 5.1 teaching (supplied-cov, not estimated-VC) | R `tests/testthat/test-mrode-multivariate-anchor.R` | `6a1065eb0` | `the multivariate Henderson MME solver reproduces Mrode Example 5.1 solutions` |
| A26 plumbing (same quantity through bridge) | R `tests/testthat/test-multivariate-engine-parity.R` | `6332e35ea` | `Tier B1/B2: the bridge reproduces the serialized k=2 target element-wise` |
| Capability surfaces (still partial R / covered engine) | R + Julia `docs/design/capability-status.md` | R `2fc250cc3` · J `5f1a742ea9` | R multivariate row `partial`; engine `V4-MV-REML` covered; **count 5** |

**Historical note:** the origin evidence table above was assembled before ink. Whole-sheet is now **SIGNED** (see below).

---

## Evidence pointers (read, not re-run)

Measured 2026-09-02 from the campaign worktrees. Do not re-run C8, A26,
or MV-5.

| Lane | Worktree | Branch | HEAD this pass |
|---|---|---|---|
| R | `~/local-scratch/lanes/hsquared-h2-twin-20260901` | `claude/lane-h2-twin-20260901` | `2fc250c` (local-only ahead of origin branch) |
| Julia | `~/local-scratch/lanes/HSquared.jl-h2-twin-20260901` | `claude/lane-h2-twin-20260901` | `7d4ca106` (LOOP stamp; local-only) |

### What Darwin is signing exists

| Leg | What it shows for biology | Pointer (campaign tree) | Last-touch SHA |
|---|---|---|---|
| Design-41 criterion 5 | Recovered quantity for correlated models = covariance / correlation | R `docs/design/41-lane-goal-to-1.0.md` §3 item 5 | `2516490` |
| Locked identities | `r_g == cov2cor(G0)`; h²_k identity + Falconer/Lynch pins | R `docs/design/04-validation-canon.md` § “Locked Derived-Estimand Identities”; Julia mirror of the same section | R `529a5a2` / Julia present at tip |
| MV-3 identity test | Extractors equal those identities on the serialized k=2 fixture; off-diagonals genuine (not 0/1) | R `tests/testthat/test-multivariate.R` (~587–663) | `672368c` |
| Promotion fixture | Shared k=2 teaching / known-truth target (`phase4_multitrait_parity`) | R `tests/testthat/fixtures/phase4_multitrait_parity/`; Julia `test/fixtures/phase4_multitrait_parity/` | Julia `6746c4b4` |
| R cold-start recovery | 100/100 conv; all 9 targets (G₀/R₀/r_g + both h²) inside bias ± 2·MCSE | R `data-raw/multivariate-recovery-study.R` | `94e94d3` |
| Engine 48-seed gate | Pre-declared cold-start; all six \|bias\| ≤ 2·MCSE (the engine covered rest) | Julia `docs/dev-log/recovery-checkpoints/2026-06-22-mv-reml-predeclared-48seed.md` | `24ee2d9c` |
| Full-sib + 3-trait | Confirmatory (easier full-sib) and 12-parameter 3-trait; both PASS | Julia `.../2026-06-30-mv-fullsib-48seed.md`, `.../2026-06-30-mv-3trait-48seed.md` | `71d2da14` / `b14defd2` |
| C8 broader-DGP | 16×500; **14/16** pass; fails only pre-registered single-record × r_g ≥ 0.90; `base_inside` clean | DRAC job `47925486`; driver Julia `sim/phase4_v5_mv_recovery_reseed.jl`; Julia `.../2026-07-12-coverage-recovery-evidence-reconciliation.md`; R `.../2026-07-10-coverage-recovery-results.md` | `8d782e0d` / `d0b15945` / `b90d4c3` |
| Comparators (components) | Same-estimand REML agree on G₀/R₀ at **one** fixture, point-estimate (`sommer` 4.4.5, `blupf90+` 2.60) | Julia `.../2026-06-21-multivariate-sommer-comparator.md`, `.../2026-06-29-v4-blupf90-comparator.md`; R in-suite MV-1 | `b84749df` / `55382627` |
| Mrode Ex. 5.1 | Supplied-covariance BLUP/MME teaching anchor — **not** estimated-VC. No-anchor disclosure now on the R multivariate row | R `tests/testthat/test-mrode-multivariate-anchor.R`; R `capability-status.md` multivariate row | `6a1065e` / `2fc250c` |
| A26 plumbing | Element-wise R↔engine parity on the same fixture (G₀, R₀, r_g, r_e, h², β, EBV, logLik); local, **not CI-backed** | R `tests/testthat/test-multivariate-engine-parity.R`; receipt `~/local-scratch/h2-a26-receipt.md` | test `6332e35` |

Inventory (do not re-derive): `~/local-scratch/h2-060-evidence-inventory.md`.

### Teaching vs field fences

| Surface | Label Darwin requires | Fail if… |
|---|---|---|
| `phase4_multitrait_parity` / recovery studies | Teaching / simulated known-truth | Called “field validated” or “real-population genetic correlations” |
| Mrode Example 5.1 | Published teaching supplied-covariance BLUP | Implied as estimated-VC REML textbook pin |
| C8 / W1 | Recovery characterization + scope edge | Sold as uniform field recovery at extreme r_g × one record |
| User docs (when a later flip happens) | Covered **point-estimate** k=2 genetic covariance / correlation | Interval maturity, k≥3, or diagonal promoted silently |

---

## SIGN / HOLD / REJECT — tick one box per row

Tick **exactly one** of SIGN / HOLD / REJECT per item.
(`DECLINE` = REJECT synonym.) Owner ink below mirrors the scratch sign sheet.

| # | Item | Proposed answer | SIGN | HOLD | REJECT |
|---|---|---|---|---|---|
| 1 | Headline recovered quantity = **G₀ / r_g**, not univariate h² alone? | **YES.** Matches design-41 §3.5 and A13 item 5 (framing only). | [x] | [ ] | [ ] |
| 2 | Per-trait h² allowed as secondary identity-derived descriptors? | **YES, fenced.** Never the sole public claim for a correlated flip. | [x] | [ ] | [ ] |
| 3 | C8 2/16 fails (extreme r_g × 1 record) = scope edge, not Darwin veto? | **YES.** Pre-registered; adding records restores recovery even at r_g = 0.95. | [x] | [ ] | [ ] |
| 4 | A26 parity sufficient biological plumbing for “same quantity through the bridge”? | **YES as plumbing.** Still needs this ink + Rose re-audit + owner G10. Not CI-backed (DP-10). | [x] | [ ] | [ ] |
| 5 | Teaching / sim vs field fences above? | **HARD YES.** Same spirit as A13 items 4/8. | [x] | [ ] | [ ] |
| 6 | Criterion-3 locked citations (Falconer ch. 19 + Lynch & Walsh ch. 21 for r_g; Falconer ch. 8/10 + Lynch & Walsh ch. 4/7 for per-trait h²) acceptable? | **YES — already in both canons.** Confirm or annotate chapter pins from the *same* editions. | [x] | [ ] | [ ] |
| 7 | Mrode 5.1 no-anchor disclosure (estimated G₀/R₀ has no textbook pin)? | **ACCEPT.** Darwin is not asked to invent a Mrode estimated-VC number. | [x] | [ ] | [ ] |

**Whole-sheet choice (one tick):**

- [x] **SIGN as recommended** — G0 ARMED; biology ready (owner ink)
- [ ] **HOLD** — only if you annotate a remaining biology fence
- [ ] **REJECT** — 0.6 biology ink withheld; say why

**SIGN status this pass:** **SIGNED.** Owner: Shinichi (Darwin). Date: 2026-09-02. Source: chat "go ahead" (Shinichi, 2026-09-02).

**Prior HOLD (superseded):** Wait-pass HOLD was procedural (General+TagBot / registration before 0.6).
Owner deferred registration, armed G0 via parity CLOSE → 0.6 sequence, and authorized recommended
Wave A ticks via chat “go ahead” (2026-09-02). A29 Rose tip re-audit remains **after** this ink
(not Darwin’s job; still no covered flip).

**Annotations / conditions:**

Owner authorized recommended SIGN (items 1–7 + whole-sheet). Ranga citation pins KEEP AS DRAFTED.
Teaching / sim vs field fences above remain hard requirements on any later claim surface.

---

## Sign-off gate — recorded

1. **G0 ARMED** for 0.6 evidence/ink — **YES** (parity CLOSE; reg DEFERRED OK).
2. Items 1–7 **SIGNED**.
3. Name and date recorded below (echo of owner scratch ink).
4. Check-log stub records this SIGN; **not** a covered flip; count **5**.
5. Later: Rose A29 → owner G10 only with full §3. **Do not flip `public_covered_count`.**

**Signed (Darwin / Shinichi):** Shinichi (Darwin)  **Date:** 2026-09-02  
**Source:** chat "go ahead" (Shinichi, 2026-09-02)

---

## NON-goals (this packet)

1. **No covered flip.** `public_covered_count` stays **5**. R multivariate
   stays `partial`. Engine `V4-MV-REML` stays `covered`.
2. **No interval calibration.** Multivariate SEs and Fisher-z r_g
   intervals stay experimental / uncalibrated. That is 0.9, not 0.6.
3. **No k ≥ 3 covered. No `diagonal` covered.**
4. **No A13 ink, no G10 ink, no version bump, no push, no merge.**
5. **No MV-4 code.** Routing already merged (PR #132). Do not “start MV-4.”
6. **No Totoro / DRAC run** from this sheet. C8 is already banked. MV-5
   is an A25 disposition, not Darwin.
7. **No claiming General registration or CRAN** from this sheet; reg stays DEFERRED.

---

## What this packet does and does not do

| Does | Does not |
|---|---|
| Record Darwin SIGN on G₀ / r_g as the 0.6 biology headline | Flip R multivariate `partial → covered` |
| Keep teaching/field fences and Mrode no-anchor disclosure | Authorize G10 or change `public_covered_count` |
| Keep A13 and A27 as separate inks | Let A13 item 5 stand in for this sheet |
| Leave count at **5** | Calibrate intervals / promote k≥3 / diagonal |

**Next (not this sheet):** DP-10 C honesty apply · A25 SUPERSEDE · Rose A29 tip · owner G10 only with full §3.
Registration / General / TagBot remain DEFERRED and are **not** SIGN gates.

**Fence:** SIGN recorded · no capability flip · no covered flip · no G10 ink · `public_covered_count` **5**.
