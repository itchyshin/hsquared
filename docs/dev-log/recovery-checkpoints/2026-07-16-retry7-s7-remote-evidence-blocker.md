# Retry-7 S7 remote-evidence blocker — 2026-07-16

## Completed operational evidence

Fresh sibling Totoro clones at
`/home/snakagaw/hsq_work/retry7-s7-bounded-8739531-97681439` were checked out
at R `873953104cfc1d9d738201038c99207ccc2d618b` and Julia
`976814393043d3a4af5ce343d8ac4b05c43eac41`, both clean.

- The clean-deployment control passed.
- An isolated dirty sibling clone rejected before materialization with
  `deployed implementation worktree is dirty`.
- The synthetic-only lifecycle completed: D0F `COMPLETE` receipt
  `a2b94371bce0c3f69fa117440a2518949528c639010fefd097ccc269b01288ff` and
  D1 `ELIGIBLE=12` receipt
  `1783597362edc4906290d375563aef4af947fe89fe723b0e38c3e864d39af028`.
  Each stage wrote five clean post-run reviews, recognized an identical receipt
  retry, and passed final validation. The completed log SHA-256 is
  `984a2ebde8b46c6f72382a5546139ca02be56f5d6bae21244206604234e8ad87`.

This remains synthetic architecture evidence only. It used no official seed,
fit, preseal, or adjudication.

## Why S7 is not cleared

1. A remote-evidence reviewer exceeded its remote-only brief with a local
   status preflight that surfaced protected Retry-5 filenames. No protected
   contents or edits occurred, but the review chain is reset; see
   `docs/dev-log/reviews/2026-07-16-retry7-protected-state-read-incident-3.tsv`.
2. The retained lifecycle log proves successful worker outcomes but does not
   persist the `timeout` executable, 900-second setting, or wrapper arguments.
   The live process was observed with those arguments, but that observation is
   not a durable replayable artifact. Grace therefore returned BLOCKED.

## Required recovery

Before another remote S7 clearance attempt, add a create-once synthetic run
receipt that records the bounded-worker configuration and deployed heads, then
rerun exact local gates/CI as required by the changed source head. Commission a
fresh strictly remote-only evidence review afterward. Do not open official
preseal or any official RNG while this blocker stands.
