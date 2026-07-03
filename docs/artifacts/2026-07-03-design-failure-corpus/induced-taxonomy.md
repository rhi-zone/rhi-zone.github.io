# Induced Taxonomy of the Development-Event Ledger

Produced 2026-07-03 by blind induction over `ledger/events.jsonl` only — no project
theory documents were read (stage 5 of the pipeline).

Method: read all 425 records in the ledger, clustered them by recurring theme without
reference to any pre-registered category scheme, and named each cluster independently.
Counts are approximate — many records legitimately belong to more than one cluster;
counts reflect the cluster a record most centrally exemplifies.

## Patterns

### 1. Provisional Foundation Churn (~22 records)

A component gets built quickly under implicit shipping pressure, then within days-to-
months the same component is discovered to be architecturally wrong and is rewritten
from a different foundation — sometimes multiple times in sequence (one typechecker
went through four rewritten generations). The record set treats this as a named,
repeating cycle rather than isolated incidents.

- "custom engine built, then migrated to Nunjucks within days" — `docs/introspection/log/synthesis-jan28-mar2.md:50`
- "hand-rolled Pratt parser (~760 lines), then replaced with oxc_parser" — `docs/introspection/log/synthesis-jan28-mar2.md:51`
- "v1 (HM unification, Feb 27)" ... "v4 (set-theoretic foundation... May 19)" — `docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-DESIGN-CEILING.md:87`
- "layout system accumulated special cases... Systematic elimination over 56 turns" — `docs/introspection/log/synthesis-jan28-mar4.md:62`
- "re-open M1–M7 as drafts... resolve every global axis... then redraft" — `docs/introspection/log/daily/2026-06-11.md:49`

### 2. Grievance Codification (~26 records)

A correction the user issues in the moment is not treated as resolved once the
immediate output is fixed; it is converted into a standing rule appended to a
CLAUDE.md-style control file, on the explicit theory that "every correction means a
rule is missing." This is the dominant response shape to friction across the whole
corpus, not particular to one project.

- "\"Never invent numbers\" and \"always externalize decisions\" added" — `docs/introspection/log/synthesis-jan28-mar2.md:92`
- "the constraint is explicit: \"every correction means a rule is missing\"" — `docs/introspection/log/synthesis-jan28-mar2.md:68`
- "CLAUDE.md update: \"Never invoke tsc/tsgo directly...\"" — `docs/introspection/log/friction-analysis-2026-03-29.md:78`
- "a `.git/info/private-names` denylist... read by a committed `.githooks/pre-commit`" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:49`
- "Fix: slim the injection, make it project-relative... propagate to 45 repos" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:47`

### 3. Wrong-Answer Perseveration (~26 records)

An agent, once corrected on a technical point, proposes a *new* wrong answer rather
than reconsidering the premise — sometimes cycling through several variants of the
same mistake before landing on the right one, occasionally only after the user states
the answer outright. The record set explicitly names this "not generalizing from the
first rejection."

- "chain 'WRONG'/'also wrong'... six consecutive turns" — `docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-DESIGN-CEILING.md:15`
- "kept proposing fixes for a multi-return type system bug... Each fix was technically plausible but wrong at a deeper level" — `docs/introspection/log/friction-analysis-2026-03-29.md:41`
- "kept retrying the same wrong approach after the first rejection instead of stopping to think" — `docs/introspection/log/friction-analysis-2026-03-29.md:76`
- "the agent knew the correct answer by turn 34... but kept abandoning it for SHA-NI alternatives" — `docs/introspection/log/friction-analysis-2026-03-29.md:115`
- "a misnaming the agent had been overridden on five times" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:91`

### 4. Naming as Load-Bearing Ritual (~11 records)

Choosing a project or module name consumes disproportionate deliberate turns/time
(15–45+ minutes, 30+ turns), with multiple candidates explicitly rejected before one
resonates. Renames of existing names also occur and cascade across many files. Notably,
one record shows a naming decision being explicitly left *unresolved* rather than
forced, framed as house policy.

- "naming brainstorm after rejecting polymath and others... settled quickly once \"motif\" resonated" — `docs/introspection/log/synthesis-jan28-mar2.md:74`
- "~15 messages and 45 minutes on naming (freeview, osmose, wall, ledger, folio rejected)" — `docs/introspection/log/synthesis-jan28-mar2.md:75`
- "30+ turns in a single session dedicated to finding the right name" — `docs/introspection/log/synthesis-jan28-mar2.md:76`
- "dew-to-wick rename cascading across 9 crate directories" — `docs/introspection/log/synthesis-jan28-mar2.md:77`
- "`seelie` and `dew` weighed, none chosen, per house rules (refine the conceptual space, don't force the name)" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:101`

### 5. Telemetry Reflex (~60 records, the largest single event_type cluster)

An extremely dense, self-referential habit of quantifying the development process
itself — tokens, cache-hit ratios, dollar cost, session counts, turn counts — often at
a level of precision (single-token counts, per-turn breakdowns) that exceeds what would
be needed for simple cost awareness. This is less "noting a fact" than a standing
instrumentation practice applied to nearly every session.

- "Cache hit ratios are very high across the major sessions — private-recipient-b ~121:1... fractal ~119:1, github-io ~131:1" — `docs/introspection/log/daily/2026-06-11.md:81`
- "The single largest cache_read on any turn was 82M tokens on a subagent warmup message containing just the word \"Warmup.\"" — `docs/introspection/log/synthesis-jan28-mar2.md:247`
- "14.2B cache_read tokens, 1.1B cache_create tokens, 32.5M output tokens" — `docs/introspection/log/synthesis-jan28-mar2.md:241`
- "`ls` failed 1,068 out of 1,693 attempts (63%), burning an estimated 51.7M output tokens" — `docs/introspection/log/synthesis-jan28-mar2.md:249`
- "fuwafuwa had consumed ~$300 of a ~$305 window... to deliver 9 actual Discord messages out of ~831 sessions" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:32`

### 6. Silence Adjudication Disputes (~11 records, 3 of them flagged by the ledger's own QA as mislabeled)

Multiple records describe a project going quiet for days or weeks, and multiple
*other* records — sometimes about the very same gap — explicitly refuse to let that
silence be called "abandonment," insisting the record is "not determinable from the
session data alone" or "indistinguishable from baseline attention-cycling." This
tension is unusually visible: three of the ledger's five internally-rejected
records (its own verification layer overriding the assigned label) are exactly this
dispute — the extraction over-called silence as abandonment where the source text
withheld that judgment.

- "several scaffolded projects (Deskspace, Motif) have had no implementation work weeks after creation... not determinable from the session data alone" — `docs/introspection/log/synthesis-jan28-mar2.md:163` (label rejected in verification for the near-duplicate at `synthesis-jan28-mar4.md:195`)
- "After that session, reincarnate has had zero sessions in 20 days" — labeled abandonment, but rejected in verification: the source document's own adjudication called the gap "indistinguishable from baseline attention-cycling cadence" — `docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-MOMENTUM-LOSS.md:17`
- "The release does not ship in this window — this thread simply goes quiet... neither resolved nor explicitly abandoned" — labeled abandonment, rejected in verification for contradicting its own quoted text — `docs/introspection/log/synthesis-2026-05-10-2026-05-29.md:65`
- "existence (157 sessions, last session ended mid-feature with a \"pick one of the remaining\")" — `docs/introspection/investigations/2026-05-20-whats-wrong/registry/H-MOMENTUM-LOSS.md:27`
- "Hubris/legacy received no sessions. Dusklight/Marinada was silent... accumulating waiting time, not being actively retired" — `docs/introspection/log/synthesis-mar10-mar16.md:117`

### 7. Hypothesis Registry Self-Audit (~40 records across three files)

A distinct, formal sub-corpus (`registry/H-MOMENTUM-LOSS.md`, `H-DECOMPOSITION-
FAILURE.md`, `H-DESIGN-CEILING.md`) in which named hypotheses about ecosystem
dysfunction are stated, evidenced, then subjected to an internal "red-team" pass that
argues against them, and finally adjudicated — sometimes reversing the hypothesis to
"dead" or downgrading it to "weak." This is a self-auditing structure layered on top
of the raw development events, not itself a development event.

- "**Alive — partially confirmed.**" (initial verdict) → "**dead.** The red-team's three angles all land." — `H-MOMENTUM-LOSS.md:71` and `:95`
- "H-MOMENTUM-LOSS should be downgraded from... to \"Weak — insufficient evidence...\"" — `H-MOMENTUM-LOSS.md:89`
- "Deduplication check: 443 total tasks, 429 unique first-message prefixes (14 duplicates = 3.2%)... No postmortem. No user signals of breakdown." — `H-DECOMPOSITION-FAILURE.md:39`
- "Most typechecker work *did* ship: 8 phases of static typechecker landed" (Evidence Against section) — `H-DESIGN-CEILING.md:29`
- "The model caught its own over-counting under user challenge and retracted its rewrite recommendation." — `H-DESIGN-CEILING.md:89`

### 8. Empirical Turn (~10 records)

Recurring move where a stalled argument-driven debate is broken not by more argument
but by switching to direct measurement or a mechanized/formal check: building a
codebase graph instead of reasoning about coupling, running an oracle against real
LuaJIT instead of debating semantics, adopting a proof assistant instead of continuing
ad-hoc invariant enforcement.

- "stop reasoning about composition from first principles and *measure* it... a machine-readable codebase graph" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:64`
- "It revealed the real runaway was the projection surface (933 hand-written routes vs. 51 thin bindings)... not the slice-to-slice edge mesh... that had dominated discussion" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:64`
- "an oracle model (run on real LuaJIT, compare verdicts), then a decisive move to a proof assistant" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:79`
- "the session measured Haiku/Sonnet recall against an Opus ceiling via semantic-match scoring" — `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:124`
- "Binary bloat measured, not assumed" — `docs/introspection/log/synthesis-jan28-mar4.md:63`

### 9. Handoff/Continuity Debt (~15 records)

Work is deliberately split across sessions via "handoff" artifacts (plans, summaries),
which is treated as a load-bearing, mostly successful discipline — but the record set
also documents its failure mode: stale, copy-pasted handoff instructions that describe
an idealized workflow rather than the actual one, discovered only after sustained user
pushback.

- "picked up directly from a handoff: the previous session had co-designed... and left an approved design doc" — `docs/introspection/log/daily/2026-06-11.md:9`
- "handoff plans had been copy-pasted across ~30 sessions, introducing stale commands... because they came \"from a plan\" and therefore weren't questioned" — `docs/introspection/log/synthesis-mar10-mar16.md:45`
- "19% of sessions were interrupted on turn 0 — the plan-mode handoff pattern... This looks like overhead but isn't" — `docs/introspection/log/synthesis-jan28-mar2.md:245`
- "plan mode not ephemeral enough, \"next tasks\" potentially unreliable, decision to promote handoff to a skill" — `docs/introspection/log/synthesis-2026-04-01-2026-04-20.md:91`
- "The lesson: handoff plans need freshness checks, not just correctness checks." — `docs/introspection/log/synthesis-mar10-mar16.md:125`

## Event-type distribution

```
decision_made         108
other_notable          92
cost_note              78
correction_issued      49
completion_success     31
correction_repeated     24
decision_reversed       19
abandonment             14
revert                   5
oscillation              5
```

`decision_made` and `other_notable` together are over half the ledger — the corpus
leans descriptive/decisional rather than incident-driven; failure-flavored types
(`correction_repeated`, `revert`, `oscillation`) are a small minority (~8%) despite
supplying some of the most vivid quotes.

## Per-project concentration

`crescent` (84 records) and `reincarnate` (75) dominate the ledger by a wide margin,
followed by `normalize` (42), `fuwafuwa` (22), `existence` (21), `private-recipient-b`
(20), and the meta-project `github-io` itself (18). Pattern concentration is uneven:
Wrong-Answer Perseveration is almost entirely `crescent` + `reincarnate`;
Naming-as-Ritual is spread across small/early-stage projects (motif, deskspace,
tiltshift, wick, scribble) that otherwise barely appear elsewhere; Telemetry Reflex is
ecosystem-wide but the extreme per-token figures cluster in `fuwafuwa` (autonomous,
high session-count) and `reincarnate` (large source files, full-rewrite churn);
Substrate/governance-flavored records (private-name leak, hook scoping, skill
propagation) are exclusively `github-io`.

## Temporal arc

Records cluster into three visible phases. **Jan–Mar**: heavy Provisional Foundation
Churn, Naming Rituals, and Grievance Codification — the correction-to-rule feedback
loop is explicitly noted as compressing "from days... to minutes" over this window.
**Late Apr–May**: the ledger turns reflexive — the Hypothesis Registry Self-Audit
records appear only here, treating the ecosystem's own momentum/decomposition/design-
ceiling as objects of investigation, mostly adjudicating the more alarming hypotheses
down or dead. **Jun**: an Empirical Turn cluster and a burst of Substrate
Self-Governance records (private-name leak, global-vs-repo-local tooling fights, hook
slimming) — the corpus's attention visibly moves toward hardening its own control
surface and toward measurement-over-argument, alongside a cost crisis
(`fuwafuwa`'s $300 quota burn) that itself triggers a Grievance-Codification-style fix.

## Records that resist clustering

- A subagent warmup turn whose entire content was the word "Warmup" consumed 82M
  cache-read tokens — a technical curiosity about how agent-spawning inherits parent
  context, not part of any narrative pattern. `docs/introspection/log/synthesis-jan28-mar2.md:247`
- A recommendation to read fiction (Greg Egan, BLAME!, Chirault) alongside a proposed
  "probabilistic tasklist" — the one record touching literary taste rather than
  software process. `docs/introspection/log/synthesis-mar10-mar16.md:97`
- A brand-new project (unnamed "website") scaffolded via Google Apps Script + Sheets +
  Cloudflare Workers, explicitly noted as having no established register in the
  ecosystem yet. `docs/introspection/log/synthesis-2026-04-01-2026-04-20.md:99`
- An explicit data-loss disclosure about the ledger's own source material — session
  files for part of the covered period were deleted before backup, so a chunk of the
  history is admittedly reconstructed, not observed. `docs/introspection/log/synthesis-2026-04-01-2026-04-20.md:3`
- A disclosed methodology note that most of one month's daily logs were "backfilled in
  a single pass" after the fact, undercutting any reading of those logs as having
  steered decisions in real time. `docs/introspection/log/synthesis-2026-05-30-2026-06-23.md:138`

## Absent or rare patterns (evidence by absence)

- **No end-user/customer feedback.** Every correction, complaint, and course-change in
  the ledger comes from one developer talking to agents about the developer's own
  projects. There is no record of an external user, customer, or downstream consumer
  reacting to shipped software.
- **No security-incident or vulnerability-response cluster**, despite ~54 repos of
  active software development — the sole adjacent record is a defensive fork-hardening
  effort against a third-party regression, not an incident in the ecosystem's own code.
- **Almost no unqualified praise.** Positive/success records exist (`completion_success`,
  31 of them) but are nearly always paired with a caveat, a "but," or a quantified
  residual problem; simple unmixed approval is rare enough to stand out when it appears.
- **No deadline- or external-commitment-driven pressure.** Releases are repeatedly
  *deferred* voluntarily pending internal quality bars, never rushed against an
  outside date.
- **No budget-approval or financial-planning process** beyond ad-hoc reactions to a
  cost spike after the fact — cost appears only as forensic accounting, never as
  upfront planning or a hard pre-set limit (until the `fuwafuwa` circuit-breaker, which
  is itself framed as a post-hoc fix).
