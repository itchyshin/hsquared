```text
GOAL
Codex alone will close or explicitly stop the Retry-7 S7 bounded-recovery gate:
the headline is a clean, observable D0F-to-D1 synthetic lifecycle on Totoro,
preceded by exact source-head checks and a dirty-deployment rejection control.
Run independent local R and Julia checks plus narrow review receipts in
parallel where their inputs permit. Defer all official phenotype/bootstrap RNG,
preseal, D1-D4, default activation, G10, release, and public-count changes.
Discipline: no remote full lifecycle before exact CI and clean/dirty deployment
smokes; accept S7 only with an independently reviewed, fully bounded result;
use Totoro for the synthetic remote control and write a durable closeout or
blocker record.
```

# Retry-7 S7 bounded-recovery ultra-plan

## Context and prior-work sweep

The former S7 Totoro rehearsal was interrupted after D1 post-run receipts while
it was still progressing. It did not demonstrate a worker deadlock and did not
reach D1 adjudication. The protected Retry-5 state and the retired/incomplete
run remain untouched. Retry-7 official bases `2042000000` and `2043000000` are
reserved and unspent.

The recovery source head is R commit `873953104cfc1d9d738201038c99207ccc2d618b`
and Julia source remains `976814393043d3a4af5ce343d8ac4b05c43eac41`. The new R
exact-head CI is [green](https://github.com/itchyshin/hsquared/actions/runs/29532840660).

External research: none. This is an operational-contract repair grounded in
the existing repository evidence, not a scientific-design or comparator claim.

## Slice plan

| Slice | Member | Model / effort / dispatch | Time | Input → output | Dependency |
| --- | --- | --- | --- | --- | --- |
| S1 bounded worker + clean-root guard | Ada / R lane | Terra-high / native-inherited | complete | lifecycle tool + launcher → timeout, self-test, deployment-check | none |
| S2 exact R gate | Ada / R lane | Terra-high / native-inherited | complete | S1 → full tests, build, forced-Suggests check | S1 |
| S3 exact Julia gate | Ada / Julia verifier | Terra-high / native-inherited | complete | unchanged Julia head → package/docs/preamble checks | S1 |
| S4 recovery plan review | Rose + Grace lenses | Sol-high / native-inherited; adversarial gate justified by irreversible compute admission | pending | S1-S3 + CI → narrow CLEAN/BLOCKED review record | S2, S3, CI |
| S5 Totoro deployment smoke and lifecycle | Ada / live-toolchain | Sol-high / native-inherited; remote process and evidence gate | pending | clean and intentionally dirty sibling deployments → rejection control; then bounded D0F-to-D1 result | S4 |
| S6 conditional preseal and chronology | Sol verifier | Sol-high / native-inherited; release-grade chronology judgment | fenced | S5 PASS → preseal/chronology verdict | S5 only |
| S7 closeout | Rose | Terra-high / native-inherited | pending | all receipts → check-log/after-task or blocker/handoff | S5/S6 outcome |

S2 and S3 are independent local checks; S4 follows their exact-head CI.
S5 is strictly sequential after S4. S6 is fenced until S5 passes. Fan-out is
limited to two review lenses because all remaining work touches a single
operational evidence chain. The current Codex runtime exposes native inherited
dispatch only; the table records that limitation rather than claiming a mixed
tier dispatch.

## Plan review and verification

Rose reviews claim boundaries and whether the remote result would actually
clear S7. Grace reviews timeout/process and clean-deployment semantics. The
remote run must first prove: (1) a clean sibling deployment passes;
(2) a deliberately dirtied disposable sibling deployment rejects before any
synthetic materialization; and (3) the bounded full lifecycle completes with
both D0F and D1 adjudication receipts. Any timeout, unexpected nonzero exit,
or incomplete receipt is a blocker—not a reason to open official RNG.

## Estimate and closure

Expected wall time: one Codex session plus remote lifecycle runtime; one review
batch and one remote batch. On PASS, write a closeout and only then consider
the separately gated Sol preseal/chronology work. On BLOCKED, preserve the
fresh workspace and write a recovery checkpoint with the exact failed action,
without retrying or widening scope.
