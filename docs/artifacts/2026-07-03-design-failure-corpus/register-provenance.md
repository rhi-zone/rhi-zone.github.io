# Register provenance: the "So, plainly" tic family
Status line: evidence artifact, 2026-07-04. Investigated in response to owner-reported response-quality failures (two specimens: dramatized self-congratulatory analysis; serial frame-guessing under rejection).

## Sweep 1 — instruction-echo hypothesis (REFUTED in direction)
Hypothesis: agent outputs echo CLAUDE.md disposition wording (installed dc9f670 2026-06-30, e445d13 2026-07-03).
Method: all assistant-role text blocks from ~/.claude/projects/ transcripts for this repo (11,884 blocks), plus docs/introspection/ and the pilot ledger; grep for fingerprint phrases; before/after split on wording-install date.
Findings: "So, plainly" and "wearing N hats" constructions PREDATE the wording by a month (earliest 2026-05-31 and 2026-05-31 resp.); most other pre-cutoff hits came from the two sessions that were drafting the disposition text itself (assistant-proposed wording captured pre-commit); "checked honestly" has zero occurrences outside the owner's pasted specimen and the session analyzing it.
Conclusion: contamination ran model → control surface: the model's native register entered CLAUDE.md via model-assisted drafting, not the reverse.

## Sweep 2 — model-version hypothesis (SUPPORTED)
Hypothesis (owner's): the tic family arrived with the opus-4-8 model (released 2026-05-28), i.e. it is weights-level, plausibly an RLHF-honesty artifact.
Method: all ~/.claude/projects/*/*.jsonl across all projects; 167,816 assistant text blocks, 100% carrying message.model; per-model and per-month counts of tic-family phrases, rates per 1000 blocks.
Findings table (transcribe exactly):
| model | blocks | honesty-marker hits | rate/1000 | tic-signature hits (so_plainly + plainly_colon + for_the_record) |
|---|---|---|---|---|
| sonnet-4-5 | 666 | 2 | 3.0 | 0 |
| opus-4-5 | 25,609 | 10 | 0.39 | 0 |
| opus-4-6 | 42,827 | 20 | 0.47 | 0 |
| sonnet-4-6 | 68,912 | 80 | 1.16 | 0 (2 generic "plainly" adverb uses) |
| opus-4-7 | 9,827 | 31 | 3.16 | 0 (1 quoted-text near-hit) |
| opus-4-8 | 14,925 | 158 | 10.59 | 68 (43% of hits) |
| fable-5 | 289 | 39 | 134.9 (CONTAMINATED, see caveats) | present incl. new "checked honestly" |
Key facts: zero genuine sentence-initial "So, plainly:" before 2026-05-28 in ~138k pre-boundary blocks; first true instance 2026-05-30 on opus-4-8; hits cluster across four unrelated repos (github-io + three other ecosystem repos), ruling out repo-local instructions; opus-4-7 vs opus-4-8 contrast (9,827 vs 14,925 blocks, 0 vs 12 so_plainly) is the powered comparison.
Caveats (transcribe faithfully): fable-5 sample is 289 blocks and includes the very session conducting this investigation, which quoted the specimen phrases repeatedly — the sweep cannot distinguish the model's own prose from quoted evidence, so the fable-5 rate is inflated by measurement contamination; its earliest tic hits (2026-06-11) do predate that session. Role attribution within transcripts cannot distinguish subagent from orchestrator turns. Phrase-family counts are small (68 hits opus-4-8).

## Corroborating specimen from draft authoring
Three persona drafts commissioned 2026-07-03 with an explicit banned-phrase list including "wearing N hats": two of three independently coined near-variants inside their own anti-tic clauses ("the same move wearing opposite clothes"; "the same move wearing the opposite coat"). Consistent with weights-level register that survives explicit prohibition in the prompt.

## Combined timeline
2026-05-28 opus-4-8 ships → 2026-05-30 first tic instance → June: tics establish across repos → 2026-06-30/07-02 disposition wording drafted with model assistance, absorbing the register into CLAUDE.md → 2026-07-03 owner reports response quality failures; investigation.
