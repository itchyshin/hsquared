# C1-ext / H1+H3 R PATH_ONLY pointer (twin of Julia #294)

Date: 2026-09-03 · Lane: R public (`cursor/09-h1-h3-harness-r-20260903`) ·
Status: **POINTER + PATH_ONLY smoke.** No R coverage bank. Confirm **not
armed** (there is no R `sbatch`).

Cites R-repo `docs/design/34-interval-recovery-pre-registration.md` §2–§4,
§10 (C1-ext). Design-36 H1/H3 = interval-calibration campaigns, not the
Julia-backlog non-Gaussian family IDs. Design-39 H0 is the later
claim-level template this pointer prepares for; **H0 Layer B is unpaid**.

Julia operational child (numeric harness):
`HSquared.jl` `docs/dev-log/recovery-checkpoints/2026-09-03-c1-ext-h1-h3-ademp-predeclaration.md`
on [PR #294](https://github.com/itchyshin/HSquared.jl/pull/294) tip
`b0f645ee`.

```
PLATFORM: cursor | LANE: cursor/09-h1-h3-harness-r-20260903
OTHER LANES: Codex DRAFT #137 cite-only · R #158–#165 cite-only
  · Julia #294 cite (this is the twin) · Dropbox checkout FOREIGN
Active lenses: Ada · Shannon · Hopper · Fisher · Rose fence
Spawned subagents: none
Current lane: R C1-ext PATH_ONLY pointer (scratch worktree)
```

## Aim

Keep the R public lane honest while Julia #294 holds the C1-ext driver:

- Name the five campaigns (`h1_two`, `h1_multi`, `h1_t`, `h3_rg`, `h3_ram`).
- Map each estimand to the R extractor that exists today, or to **NONE**.
- Freeze `claim_eligible = false` and `GATE PATH_ONLY` on every smoke row.
- Leave `confint()` / `vcov()` / `profile()` hard-blocked.

No `covered` flip. No `public_covered_count` move (stays **7**). No `point`
promotion. A later H1/H3 claim level still needs Julia confirm + Fisher
doc-34 §4 map + Rose + G10. This file does not ratify H0 Layer B.

## Symbolic alignment (design-36 §2.2; per-estimand, no inheritance)

| Campaign | Estimand | Julia interval | R surface today | Role |
| --- | --- | --- | --- | --- |
| H1-two | `ratio1` | `two_effect_ratio_interval` | `heritability_interval()` (experimental) | covered-pillar bank |
| H1-two | `ratio2` | `two_effect_ratio_interval` | `common_env_proportion_interval()` / `maternal_proportion_interval()` (experimental) | covered-pillar bank |
| H1-multi | `ratio1` | `multi_effect_ratio_interval` | `heritability_interval()` on multi-effect fits (experimental) | covered-pillar bank |
| H1-multi | `ratio2` | `multi_effect_ratio_interval` | attached ratio2 when present (experimental) | covered-pillar bank |
| H1-t | `t` | `repeatability_interval` | `repeatability_interval()` (experimental) | **characterization only** |
| H3-rg | `r_g` | `genetic_correlation_interval` `:delta` | **no generic**; `genetic_correlation()` is point-only | covered-pillar bank (engine) |
| H3-ram | `r_am` | `direct_maternal_interval` | **no generic**; `genetic_correlation()` is point-only | covered-pillar bank (engine) |

`c²` does not inherit `h²`. `r_g` does not inherit G diagonals. Willham
`h²_T` does not inherit `r_am`. `t` does not inherit `σ²a`.

## Decision rule (verbatim from doc-34; frozen; not applied here)

```
measured coverage within 0.95 +/- 2*MC-SE   supports 'point' or 'directional-conservative'
[0.90, 0.94)                                 => 'directional-conservative' only
< 0.90                                       => 'experimental-only'
```

The R twin does **not** measure coverage. Over-coverage →
`directional-conservative`, **never** `point`. `h1_t` cannot become a
covered-pillar claim whatever Julia later measures.

## What a pass means

- R smoke pass = the pointer wrote a NEW TSV with `GATE PATH_ONLY` and
  `claim_eligible=false`, and the contract test still sees experimental
  extractors + blocked `confint()`.
- It is not coverage evidence. It does not license design-39 wording on
  H1/H3 estimands.

## Not armed

There is no R confirm array. Do not invent one. Julia
`sim/drac/phase1_interval_coverage_ext.sbatch` stays unarmed on #294.
This week (2026-09-01–09-07) DRAC is in maintenance; Totoro smoke only
on the Julia lane.

## H0 arc (design-39)

H0 Layer A (Uncertainty Scope cites C1 2000-rep confirm) is R #161, a
different file. This pointer does not touch `docs/design/01-v0.1-contract.md`.
H0 Layer B (Fisher Table 2 + Rose + ratify) remains unpaid. H1/H3 later
inherit H0's claim-level template **after** a Julia confirm bank exists.
