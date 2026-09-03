# 39 — H0 univariate interval-coverage claim-flip (bank the earned C1 tier; template for later coverage flips)

Date: 2026-07-11 · Lane: coordinator (R-repo `docs/design/` + the R claim
surfaces) · **Status: PROPOSAL — awaiting Rose pre-public audit + maintainer
ratification.**

> This is a **CLAIM CHANGE**, not a code or capability change. It flips *interval
> claim levels* on already-shipped surfaces to match the now-banked 2000-rep C1
> coverage evidence. It is **NOT** a `public_covered_count` move (count unchanged;
> live count is 7), it does **not** touch `validation_status()` covered rows
> (unchanged from live; do not reset to 4), and it does
> **not** change `DESCRIPTION`. Every wording change below is a proposal; none may
> land before Rose records a clean pre-public audit and the maintainer ratifies
> the amended Uncertainty Scope. **H0** is the label for this first interval-
> coverage claim-flip; §7 promotes it into the reusable template that every later
> coverage flip (multivariate, genomic, FA, non-Gaussian) inherits.

---

## 1. What this proposes (one paragraph)

The C1 univariate interval-coverage campaign pre-registered in
`docs/design/34-interval-recovery-pre-registration.md` has returned at the
**2000-rep confirm tier** (DRAC `fir` job 47925485), and its result is banked in
`docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md:17-38`.
Mapping that evidence through the pre-committed decision rule
(`docs/design/34-…md:71-135` §3–§4) licenses three tier assignments on the shipped
univariate animal-model interval surfaces:

1. **`h²` interval — `directional-conservative`** on all three legs
   (delta/Wald, profile, bootstrap): it over-covers (conservative), never
   under-covers. This **confirms and strengthens** the tier the earlier 500-rep
   evidence had only provisionally licensed, now at the 2000-rep tier and now
   including the bootstrap leg.
2. **`σ²a` profile interval — `directional-conservative`** (NEW positive claim):
   calibrated where measured (0.947 at h²=0.5, 0.956 at h²=0.7 — inside the band),
   claimed at the safer conservative tier.
3. **`σ²a` delta/Wald interval — `experimental-only`** (DEMOTION): it genuinely
   under-covers (0.897 at h²=0.5, below the 0.90 floor). It must not be presented
   as either a calibrated **or** a conservative interval on any user-facing
   surface; point estimate ± SE only, behind the experimental label.

**Honest distinction held throughout:** `directional-conservative` ≠
`coverage-calibrated-at-nominal`. No surface flips to the `point` tier. The
`point` threshold is maintainer-owned (`docs/dev-log/decisions.md:51-64`); even the
profile-σ²a leg, which sits inside the calibration band where measured, is claimed
only at `directional-conservative` here (see §4 and Open Question O1).

---

## 2. Evidence banked (C1, 2000-rep confirm)

Source: `docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md:17-38`
(DRAC `fir` job **47925485**, 2000 reps/cell, bootstrap arm ON). Pooled per doc-34
§12 (`Σcovered / Σinterval_success` across 20 tasks). Tiers adjudicated at the
**interpretable interior cells** — the `small` design (q=120), h² ∈ {0.3, 0.5, 0.7},
0.95 nominal level — under the §4 worst-interior-cell rule.

| Estimand | delta / Wald | profile | bootstrap |
| --- | --- | --- | --- |
| **h²** | directional-conservative | directional-conservative | directional-conservative |
| **σ²a** | **experimental-only** (0.897 at h²=0.5, under-covers) | directional-conservative (0.947 / 0.956 at h²=0.5 / 0.7) | directional-conservative |

Verified facts from the checkpoint (do not re-derive):

- **h² over-covers (conservative) across all three legs — never under-covers.**
- **The σ²a delta/Wald interval genuinely under-covers** (0.897 < 0.90 at h²=0.5),
  while **profile stays calibrated** (0.947 / 0.956 at h²=0.5 / 0.7). This measures,
  at 2000 reps, exactly why the shipped variance-component interval is profile-only
  (`docs/design/34-…md:220-221` §7).
- **Caveats retained as fences (§6):** the `tiny` design (q=36) is
  **NON-INTERPRETABLE** at this tier (bootstrap/profile shed intervals,
  Σinterval_success < 1800) → excluded from tier assignment; **h²=0.1 is a boundary
  cell** (characterization only, never promotes); the **0.90 nominal level is
  descriptive-only** (never run through the 0.95 band).
- **What it earns:** the shipped h² interval and the profile σ²a interval qualify
  for `directional-conservative` — an honest upgrade from the placeholder
  "experimental" wording the 0.1 honesty pass shipped. It touches the **Uncertainty
  Scope**, so it needs **maintainer ratification after a Rose audit**; it is **not
  a `public_covered_count` move**.

Precursor evidence (now superseded as the *governing* basis, retained as context):
the 500-rep delta/profile study (job 46853279) and the delta/t/profile/bootstrap
grid (job 47870067) — cited in the current Uncertainty Scope
(`docs/design/01-v0.1-contract.md:220`).

---

## 3. The three-claim-level policy mapping (explicit)

From the v0.1 Uncertainty Scope (`docs/design/01-v0.1-contract.md:217-221`) and the
governing rule (`docs/design/34-…md:40-49` §2, `:71-135` §3–§4). The contract prose
renders tier 3 as **experimental**; doc-34 uses **experimental-only** for the same
tier (`docs/design/34-…md:48-49`).

| Tier | Definition (doc-34 §2) | Decision rule (doc-34 §3–§4) | What flips here |
| --- | --- | --- | --- |
| **point** | interval presented as calibrated (nominal coverage supported by evidence) | measured `Ĉ ∈ 0.95 ± 2·MC-SE` across interior cells **and** the maintainer-owned ~2000-rep threshold is declared met | **Nothing.** No surface reaches `point` in this proposal. |
| **directional-conservative** | interval shown only as a *conservative / directional* statement; must not be presented as exactly calibrated; over-coverage never promotes to `point` | over-covers (`Ĉ > 0.95 + 2·MC-SE`) **or** mild under-cover (`Ĉ ∈ [0.90, 0.95−2·MC-SE)`) | **h²** interval (delta, profile, bootstrap); **σ²a profile** interval |
| **experimental-only** | no interval on any user-facing surface; point estimate only, behind an opt-in / experimental label | under-covers (`Ĉ < 0.90`) | **σ²a delta/Wald** interval (0.897 < 0.90) |

Aggregation (doc-34 §4): the published tier for a `(leg, estimand)` pair is the
**worst (lowest) tier across its interpretable interior cells**. Boundary cells
(h²=0.1) and non-interpretable cells (`tiny`, q=36) do not enter the minimum; they
generate caveats only.

---

## 4. Per-estimand-per-leg tier decisions (and the honest distinction)

**h² interval (all three legs) → `directional-conservative`.** Over-coverage is the
measured regime; the §4 completion states over-coverage is *never* `point` (not
calibrated) and *never* `experimental-only` (it is honest, not anti-conservative).
This is substantively the tier the shipped h² surface already carries
("conservative / not coverage-calibrated"); the change is an **evidence upgrade**
(500-rep provisional → 2000-rep confirm) that now also covers the bootstrap leg.

**σ²a profile interval → `directional-conservative`.** Measured **inside** the
calibration band at the interior cells reported (0.947, 0.956). Under §4 an in-band
cell is eligible for `point` *or* the safer `directional-conservative`. We propose
the **safer** tier, deliberately, because: (i) the `point` threshold is
maintainer-owned and not yet declared met (`decisions.md:51-64`); (ii) the full
interior grid to `point` (h²=0.3 and the larger designs converging in-band) is not
assembled — the checkpoint reports only h²=0.5/0.7 for profile; (iii) the standing
non-negotiable that `directional-conservative` ≠ `coverage-calibrated-at-nominal`.
Whether profile-σ²a is later promoted to `point` is **Open Question O1**, for the
maintainer.

**σ²a delta/Wald interval → `experimental-only`.** Measured 0.897 < 0.90 → the §4
`experimental-only` branch. This is materially anti-conservative: it must **not** be
labelled "conservative" (it is not) and must **not** be presented as calibrated. It
is the demotion that carries teeth — the one surface whose *rendering* may need to
change (see O2). The shipped variance-component interval already ships profile-only
at the engine level (doc-34 §7), so in R this is largely a **formalization**: the
delta-method SE is still shown for reference, but under a strengthened
under-coverage disclosure, not as an interval claim.

---

## 5. Exact wording changes to the claim surfaces

All edits are **proposals**. Ordering: the Uncertainty Scope (§5.1) is the primary
governing surface; every other surface (§5.2–§5.7) is downstream of it and must
agree with it. Land none before Rose + maintainer.

### 5.1 `docs/design/01-v0.1-contract.md` — Uncertainty Scope (PRIMARY; lines 219-223)

**Replace claim-level item 2** (current `:220`) with:

> 2. **directional-conservative** — the **2000-rep confirm** univariate coverage run
>    (HSquared.jl DRAC job **47925485**, pooled per doc-34 §12; banked in
>    `docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md`)
>    licenses a MEASURED, **target- and leg-specific** direction, not a
>    coverage-calibrated one, adjudicated at the interpretable interior cells
>    (`small` design q=120, h²∈{0.3,0.5,0.7}, 0.95 level; doc-34 §4 worst-cell). At
>    nominal 0.95: the **h²** interval is **conservative — it over-covers across all
>    three legs (delta, profile, bootstrap), never under-covers** →
>    `directional-conservative` for h². For the **variance component σ²a** the legs
>    split: the **profile** interval is **calibrated where measured** (0.947 / 0.956
>    at h²=0.5 / 0.7, inside the band) and is claimed at the safer
>    **`directional-conservative`** tier (not `point` — see the maintainer-owned
>    point threshold, `decisions.md`); the **delta/Wald** interval **under-covers**
>    (0.897 at h²=0.5, below the 0.90 floor) → **`experimental-only`**: it is shown
>    as a point estimate ± SE only, never as a calibrated or conservative interval.
>    The **tiny** design (q=36) is NON-INTERPRETABLE at this tier and sets no tier;
>    **h²=0.1 is a boundary cell** (characterization only); the **0.90 nominal
>    level is descriptive-only**. This supersedes the 500-rep provisional basis
>    (jobs 46853279 / 47870067), retained as precursor context. Repeatability (the
>    two-effect / multi-effect ratio interval) is NOT in this study's scope, so it
>    carries no directional claim.

**Replace the "Accordingly" paragraph** (current `:223`, first two sentences) with:

> Accordingly `summary()` labels the **h² SE/CI** "experimental; conservative / not
> coverage-calibrated; asymptotic REML" (unchanged in substance; now backed by the
> 2000-rep confirm), and labels the **variance-component (delta/Wald) SEs**
> "experimental; NOT coverage-calibrated — the σ²a delta/Wald interval **under-covers**
> (0.897 at nominal 0.95, 2000-rep confirm); asymptotic REML; point estimate ± SE
> shown for reference only, not a calibrated or conservative interval." `plot()` and
> `autoplot()` label the figures "not coverage-calibrated" (they mix targets/legs).

Note in the surrounding prose that `point` remains deferred and maintainer-owned.

### 5.2 `docs/design/capability-status.md` — `hsquared_fit` object/extractors row (line 39)

In the `Evidence` cell, **replace** the trailing clause describing the uncertainty
surfaces —

> … all clearly labelled experimental, REML-only, and not coverage-calibrated.

**with:**

> … all clearly labelled experimental and REML-only. Interval **claim levels** are
> now set by the 2000-rep C1 confirm (job 47925485; doc-34 §4; banked
> 2026-07-10-coverage-recovery-results.md): the **h² interval** is
> `directional-conservative` (over-covers across delta/profile/bootstrap, never
> under-covers) and the **σ²a profile** leg is `directional-conservative`
> (calibrated where measured), while the **σ²a delta/Wald** leg is
> `experimental-only` (under-covers, 0.897 at h²=0.5) — a point estimate ± SE only,
> not a calibrated or conservative interval. `directional-conservative` ≠
> coverage-calibrated-at-nominal; no leg reaches `point` (maintainer-owned). Not a
> `public_covered_count` move (unchanged; live count is 7).

### 5.3 `docs/design/06-public-claims-register.md` — add a dedicated interval-coverage row

The register currently has **no interval-specific row** (interval wording is only
implicit in the extractor row `:29`). Propose **inserting a new row** so README /
DESCRIPTION / issue / example wording is governed:

> | univariate animal-model interval coverage (claim levels) | directional-conservative (h² all legs; σ²a profile) / experimental-only (σ²a delta/Wald) | 2000-rep C1 confirm (HSquared.jl DRAC job 47925485; doc-34 §4; `docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md`): h² over-covers across delta/profile/bootstrap (never under-covers); σ²a profile calibrated where measured (0.947/0.956); σ²a delta/Wald under-covers (0.897) | Allowed: the h² interval and the σ²a **profile** interval may be described as **conservative / directional — not coverage-calibrated**; the σ²a **delta/Wald** SE is **experimental only, under-covers, not an interval claim**. FORBIDDEN: "calibrated coverage", "nominal coverage", "point-calibrated", or any `point`-tier phrasing for any leg; calling the σ²a delta/Wald leg "conservative". Not a covered claim; `public_covered_count` unchanged. |

### 5.4 `man/heritability_interval.Rd` (edit roxygen in `R/extractors.R:~1017-1020`)

The Rd is generated; edit the roxygen block. **Replace** the final details sentence
(currently `man/heritability_interval.Rd:35-39`):

> The interval leg is a REML-only, asymptotic (logit delta-method) approximation,
> not a coverage-calibrated interval, and is unreliable at small `n` …

**with:**

> The interval leg is a REML-only, asymptotic (logit delta-method or profile)
> approximation. The 2000-rep C1 coverage confirm (HSquared.jl DRAC job 47925485)
> places the h² interval at the **directional-conservative** claim level — it
> **over-covers** (conservative) at small `n` across the delta, profile, and
> bootstrap legs and never under-covers — which is **not** the same as
> coverage-calibrated at nominal; it is reported as a point estimate plus bounds,
> not a validated (coverage-calibrated) capability, and remains unreliable near the
> `h² → 0` boundary. The underlying estimators `V3-TWOEFFECT-REML` /
> `V3-NEFFECT-REML` are `covered`, but this **interval** is not.

(Then `devtools::document()` regenerates the `.Rd`; do not hand-edit the `.Rd`.)

### 5.5 `man/variance_component_standard_errors.Rd` (edit roxygen in `R/extractors.R`)

**Replace** the final details sentence (currently
`man/variance_component_standard_errors.Rd:33-36`):

> These mirror the engine row `V1-HERIT-CI` (`partial`): asymptotic, REML-only, and
> unreliable at small `n` or near a variance-component boundary … They are not
> coverage-calibrated and not a validated capability.

**with:**

> These mirror the engine row `V1-HERIT-CI` (`partial`): asymptotic, REML-only, and
> unreliable at small `n` or near a variance-component boundary (where the AI matrix
> is ill-conditioned and the fields are omitted). The 2000-rep C1 coverage confirm
> (HSquared.jl DRAC job 47925485) measured the **σ²a delta/Wald** interval implied
> by these SEs to **under-cover** (0.897 at nominal 0.95, h²=0.5), placing it at the
> **experimental-only** claim level: the SE is a point-estimate reference only, **not
> a calibrated and not a conservative interval**. (A profile σ²a interval is
> `directional-conservative` by the same run, but is not surfaced by this
> delta-method extractor.) Not coverage-calibrated, not a validated capability.

### 5.6 `R/fit-object.R` — `summary()`/`print()` labels and the header comment (lines 121-160)

**(a)** Update the header comment (`R/fit-object.R:123-128`) to cite the 2000-rep
confirm (job 47925485) as the governing evidence and to record the σ²a leg split
(h² conservative all legs; σ²a profile calibrated → directional-conservative; σ²a
delta/Wald under-covers → experimental-only), replacing the 500-rep-era
"delta_z ~0.92, approximately nominal" note, which the confirm supersedes (measured
0.897, under-covers).

**(b)** Change the variance-component SE label (`R/fit-object.R:154-156`) from:

> "  variance-component SEs (experimental; not coverage-calibrated; asymptotic REML):\n"

**to:**

> "  variance-component SEs (experimental; NOT coverage-calibrated — the sigma_a2 delta/Wald leg under-covers, ~0.897 at nominal 0.95; asymptotic REML; point estimate +/- SE for reference only, not a calibrated or conservative interval):\n"

The h² label (`:135`) may stay ("conservative / not coverage-calibrated" already
states the directional-conservative tier); optionally add "(2000-rep confirmed)".
Any label change ships with a snapshot-test update (`testthat` `print`/`summary`
snapshots) in the same slice.

### 5.7 `NEWS.md` — development-version bullet (after `NEWS.md:29`)

Add:

> * **Interval-coverage claim levels for the univariate animal model (2000-rep C1
>   confirm).** The pre-registered C1 coverage campaign
>   (`docs/design/34-interval-recovery-pre-registration.md`) returned at the
>   2000-rep confirm tier (HSquared.jl DRAC job 47925485). Mapped through the
>   pre-committed decision rule (doc-34 §4), the **h² interval** is now
>   **directional-conservative** across the delta, profile, and bootstrap legs (it
>   over-covers — conservative — and never under-covers), and the **σ²a profile**
>   interval is directional-conservative (calibrated where measured). The **σ²a
>   delta/Wald** interval is **experimental-only** — it under-covers (0.897 at
>   nominal 0.95) and is shown as a point estimate ± SE only, not as a calibrated or
>   conservative interval. `directional-conservative` is **not**
>   coverage-calibrated-at-nominal: no leg is promoted to the `point` tier, which
>   stays maintainer-owned. No capability is promoted — `public_covered_count` is
>   unchanged (this is an honesty/claim-level change, not a covered flip).

---

## 6. What does NOT flip (honesty fences)

- **No `point` tier.** No surface is promoted to `point`; the ~2000-rep in-band
  `point` threshold is maintainer-owned (`decisions.md:51-64`) and not declared met
  here, even for the in-band profile-σ²a leg (O1).
- **Not a `public_covered_count` move** (unchanged; live count is 7); **`validation_status()` covered
  rows unchanged** (unchanged from live; do not reset to 4); **`DESCRIPTION` unchanged**. Interval claim levels are
  an Uncertainty-Scope axis, orthogonal to the covered-count.
- **σ²a delta/Wald "conservative" is forbidden.** It under-covers; it may be called
  experimental and point-only, never conservative and never calibrated.
- **Out-of-scope intervals untouched.** Repeatability `t`, the two-effect /
  multi-effect variance-ratio intervals, and every multivariate interval were **not**
  in the C1 study (doc-34 §7, §10). They keep their current labels ("experimental;
  asymptotic REML", no directional claim). Repeatability separately stays
  experimental (its 2000-rep recovery confirm marginally failed, a banked negative —
  `2026-07-10-coverage-recovery-results.md:64-85`).
- **`tiny` (q=36) non-interpretable; h²=0.1 boundary; 0.90 nominal descriptive-only.**
  These generate caveats, never tiers.
- **No post-hoc relaxation.** The tiers are read off the pre-committed rule
  (doc-34 §3, §9) against already-observed data; this proposal only *transcribes*
  the result to the claim surfaces — it does not move a threshold or re-band.

---

## 7. The reusable template (every later coverage flip inherits this)

H0 is the worked instance; the procedure below is the template for the 0.6 → 1.0
coverage flips (multivariate, genomic, FA, non-Gaussian interval legs). A future
coverage claim-flip proposal is a *fill-in-the-blanks* of this list:

1. **Pre-register first.** The estimands, legs, cells, seeds, band, aggregation, and
   the interpretability floor are committed *before* any `sbatch` (doc-34, or a new
   dated superseding predeclaration on fresh seeds). No tier is read off data whose
   gate was not fixed in advance.
2. **Confirm tier only.** A tier assignment requires the **~2000-rep calibrated
   tier** for the governing leg × estimand (doc-34 §11). Screening/triage (48–50
   reps) can flag or schedule but never sets a tier.
3. **Map, don't negotiate.** Pool by **summing raw counts** (doc-34 §12), compute
   `Ĉ` and MC-SE on `interval_success`, and read the tier off the §4 table at the
   **worst interpretable interior cell**. Boundary and non-interpretable cells →
   caveats only.
4. **Hold the honest distinction.** `directional-conservative` (over-covers, or mild
   under-cover ≥ 0.90) ≠ `point` (in-band **and** maintainer threshold declared).
   Over-coverage never promotes to `point`; under-coverage (< 0.90) → `experimental-only`.
5. **Update the same six claim surfaces, in order:** (1) the Uncertainty Scope in
   `01-v0.1-contract.md` (primary), then (2) `capability-status.md`, (3)
   `06-public-claims-register.md`, (4) the relevant `man/*.Rd` (via roxygen), (5) the
   `summary()`/`print()`/`autoplot()` labels, (6) `NEWS.md`. Every downstream surface
   must agree with the Scope.
6. **Gate it.** Rose pre-public audit → maintainer ratification of the amended Scope.
   A `directional-conservative`/`experimental-only` interval flip is an
   Uncertainty-Scope change and is **not** a `public_covered_count` move.
7. **`point` is separate.** Promoting an interval to `point` (coverage-calibrated) is
   a distinct, maintainer-owned decision (and, if ever a 0.90-level claim is wanted,
   needs its own `0.90 ± 2·MC-SE` predeclaration — doc-34 §4).
8. **Interval coverage ≠ covered.** Interval-coverage calibration is the third 1.0
   axis (`decisions.md:135-141`), orthogonal to the covered/production axes. A
   coverage flip does not by itself move a capability to `covered`; a covered flip
   still needs its recovery gate + external same-estimand comparator under the
   Standard-Tier gate.

---

## 8. Gate checklist (Definition of Done for this claim-flip)

Per `AGENTS.md` DoD and the pre-public discipline:

- [ ] Rose pre-public audit records CLEAN (or blockers) on the six edited surfaces.
- [ ] Maintainer ratifies the amended Uncertainty Scope (`01-v0.1-contract.md`).
- [ ] Fisher confirms the estimand/leg tier mapping matches doc-34 §4 (inference lens).
- [ ] Boole confirms the label wording is consistent across all six surfaces
      (no surface states a stronger tier than the Scope).
- [ ] `devtools::document()` regenerates the two `.Rd` with zero unrelated delta.
- [ ] `devtools::test()` passes, including the updated `print`/`summary` snapshots.
- [ ] `devtools::check()` clean; commands + outcomes recorded in
      `docs/dev-log/check-log.md`; after-task report written; coordination board row added.
- [ ] Confirm `public_covered_count` (live **7**) and `validation_status()` covered rows are **unchanged** in the diff (do not reset either number to a historical 5 / 4).

---

## 9. Open questions (for the maintainer / named lenses)

- **O1 — Promote profile-σ²a to `point`?** The profile σ²a interval sits **inside**
  the calibration band where measured (0.947 / 0.956 at h²=0.5 / 0.7), which is
  §4-eligible for `point`. This proposal claims only `directional-conservative` (the
  safer tier). Promotion to `point` needs (a) the maintainer's ~2000-rep threshold
  declaration, and (b) the full interior grid — h²=0.3 and the larger designs — read
  in-band, which the checkpoint does not yet report for profile. Recommend: **hold at
  directional-conservative** now; revisit `point` when the interior grid is complete.
- **O2 — Does `experimental-only` for σ²a delta/Wald require *removing* the
  ±1.96·SE whisker rendering?** Doc-34 §2 defines `experimental-only` as "no interval
  on any user-facing surface; point estimate only." The current `plot()` / `autoplot()`
  draw ±1.96·SE whiskers and `summary()` prints the SE — an interval *rendering*, but
  already under a uniform experimental label. Two honest readings: (a) keep the SE
  under a strengthened under-coverage disclosure (this proposal's §5.6 default), or
  (b) drop the σ²a whisker/interval rendering, keeping only the point + SE number.
  This is a **Florence (figures) + Boole + maintainer** call. Recommend (a) as the
  minimal change, with (b) flagged as the stricter doc-34-literal option.
- **O3 — Surface a profile σ²a interval extractor in R?** The profile-σ²a
  `directional-conservative` tier is currently a design-doc/register claim about the
  *leg*; R surfaces only the delta-method SE, not a profile variance-component
  interval. Should a `variance_component_interval(method = "profile")` extractor be
  added so users can access the better-calibrated leg? Out of scope for this
  claim-flip; recommend as a follow-up slice (Emmy/Boole).
- **O4 — README / DESCRIPTION touch?** Confirm whether any current README or
  DESCRIPTION text makes an interval claim that §5.3's allowed-wording now governs
  (Jason/Grace scan); if none, this flip is docs + man + labels only.

---

## 10. Provenance

- Evidence: `docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md`
  (C1, job 47925485, §"C1 — univariate interval coverage", lines 17-38 + the
  maintainer-gated-items summary lines 91-96).
- Governing rule / decision rule / claim vocabulary:
  `docs/design/34-interval-recovery-pre-registration.md` (§2 vocab :40-49; §3 verbatim
  rule :71-95; §4 operationalization :97-151; §11 tiers :351-360; §12 pooling :364-388).
- Claim levels & maintainer-owned `point` threshold:
  `docs/dev-log/decisions.md:51-64` ("Three Claim Levels for Intervals and Coverage").
- Current claim surfaces edited: `docs/design/01-v0.1-contract.md:213-223`
  (Uncertainty Scope); `docs/design/capability-status.md:39`;
  `docs/design/06-public-claims-register.md` (new row);
  `man/heritability_interval.Rd:22-39` (roxygen `R/extractors.R:~1000-1020`);
  `man/variance_component_standard_errors.Rd:25-36` (roxygen `R/extractors.R`);
  `R/fit-object.R:121-160` (`summary()`/`print()` labels + comment); `NEWS.md:28-29`.
- Release/axes context: `docs/dev-log/decisions.md:106-147`
  ("Release Model", interval-coverage is the third 1.0 axis).

**Status on commit: PROPOSAL. No claim surface may be edited before Rose records a
clean pre-public audit and the maintainer ratifies the amended Uncertainty Scope.
Not a `public_covered_count` move.**