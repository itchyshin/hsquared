# Arc 1 outer32 and outer33 seed-guard review

The guard must continue to distinguish a spent attempt from a fresh seed.
Neither historical case authorizes a new run or earns current-source gate
credit. Review source: Julia trial commit
`927b8f11bba481e6d5adb6e65e6a1469b5dcd0ed`.

## Outer32

The original retained receipt was recovered from Totoro and matches its
recorded SHA-256
`2a9e51019b10c1d72a3bbd642ec821a37abb40627f5b2f7f62d889edc1188cf4`.
It binds outer32 and seed `18043834289602542821` to v14 candidate
`a3e0066897e8fd8fab55d3b9e4e963c442cfe0ae03627457f0ca780be772b729`,
source lock `3463c8a621318e06bbf3c63b7561c538e7f27d17c54c033245b0dd9ae9407af9`,
and retained failed result
`d3b583924260082abe3794a833cc2717697286dc4a4087c9d4832e78b6626fd1`.
The attempt remains consumed once in the 270-attempt denominator, with no gate
credit and no selection-rate eligibility. The trial validator currently
refuses this collision; the outer33 receipts do not resolve it. The activated
admission hash in the receipt is `0087dd927dc40b993392d92a97a5cbb7e64b68b56fd2ee10e93e3617e477ac3a`. The copied run-admission file hashes to
`82f3c5e22d3ff781fedafaea35984487717cfb63fe65efd46cfb27db00a7e098`;
the receipt records the canonical JSON digest, while this is the raw-byte
digest. Canonicalizing the recovered file with sorted keys and compact
separators reproduces the receipt hash.

A narrowly scoped future correction should bind the exact key, seed, source,
admission, started record, receipt and result. It should reject altered or
missing evidence, mismatched admissions, duplicate executions and the seed
under any other key. This is a proposed contract, not an implemented change.

## Outer33

Seven historical files match their pinned hashes. A replay against the Julia
trial source yielded eight passes and one failure in the nine-test
manifest-amendment suite. The expected single outer33 seed-context occurrence
has become five tracked documentary mentions. The pinned check-log line
itself still matches. A separate one-occurrence positive fixture passes, and
altered or duplicated evidence is refused.

A possible future correction is to review and pin the exact path and line hash
of each allowed mention while retaining every existing receipt, source and key
check. Any new, moved, changed or duplicated occurrence must still fail. The
current scanner counts a repeated seed twice on one line as one line; a new
rule needs a multiplicity test. A negative test for the same seed under a
different key must start from a passing positive fixture, or it can pass
vacuously. Recognizing a spent key must never authorize another launch.

## Reproduction and evidence

`arc1-szymek-evidence-20261104-v8.zip` is a local private-review copy; its
SHA-256 is `63c951cb1b999eb21d57f3f0da96fbda9c340703f5091cbda357e9947f6ea229`.
It contains the outer32 and outer33 retained files, a portable no-fit replay,
and 1,000 of the 1,001 files in the historical audit. The historical whole
check log is the remaining audit-file gap. The original Arc 1 gate file and
original v10/v11 R maps also remain unavailable. The bundle has not been sent.

The replay records the suite's failing exit separately from the replay
process's successful receipt-writing exit. Inspect its JSON receipt; a written
receipt is not a passing suite. The bundle contains machine-specific paths in
historical originals, so use a private transfer after review. Redacting those
originals would change their hashes.
