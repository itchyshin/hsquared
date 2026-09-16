# 2026-09-07 — Documentation milestone / release boundary

## Decision

The paired website and named honesty-documentation work is complete as a
documentation/usability milestone. It is not a package release and does not
settle a next package number. The public state remains experimental **0.8.0**
with `public_covered_count` **7**.

No package number, version bump, tag, CRAN/General registration, release, or
capability promotion is authorized by this record. In particular, neither
**0.9** nor **0.10** is selected here.

## Scientific-plan boundary

The historical 0.9/1.0 roadmap in design documents 36 and 41 is retained as a
science plan, not marked fulfilled by the documentation milestone. H1/H3 remain
deferred and the G10 promotion hold remains. The Julia S5 tail-scale evidence is
recorded as a 2026-09-01 PASS at its frozen scope; this cleanup ran no new S5
execution and does not promote that estimator.

## Public evidence pinned for this decision

- R source head: [`4b7bfefa0ddb7003d4f3e8dc7bbb5b9bb83355c6`](https://github.com/itchyshin/hsquared/commit/4b7bfefa0ddb7003d4f3e8dc7bbb5b9bb83355c6); package CI [34153464768](https://github.com/itchyshin/hsquared/actions/runs/34153464768) and pkgdown CI [34153676260](https://github.com/itchyshin/hsquared/actions/runs/34153676260) succeeded. The public publication receipt is [R PR #198 comment 5574720136](https://github.com/itchyshin/hsquared/pull/198#issuecomment-5574720136).
- Julia source head: [`a1c2401e194dba4f2fdffd580ccbc061b1c0df5a`](https://github.com/itchyshin/HSquared.jl/commit/a1c2401e194dba4f2fdffd580ccbc061b1c0df5a); CI [34152604486](https://github.com/itchyshin/HSquared.jl/actions/runs/34152604486) and Documenter [34152548409](https://github.com/itchyshin/HSquared.jl/actions/runs/34152548409) succeeded. The public publication receipt is [Julia PR #319 comment 5574607296](https://github.com/itchyshin/HSquared.jl/pull/319#issuecomment-5574607296).

The linked sources establish the completed documentation milestone only. They
do not supply release authorization or a substitute for the deferred scientific
gates.
