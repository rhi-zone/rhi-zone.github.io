# Do we have enough log data to characterize what agentic AI is good at / bad at, and how it changed over time?

**Final analysis report.** Generated 2026-06-23. Corpus: `/mnt/ssd/ai/claude-sessions/` (33,606 sessions across 56 project directories, Jan-Jun 2026; 448-session metadata subset for richer signals). All conclusions are drawn from an adversarially-verified evidence base: each finding survived a skeptic as **held** (as-stated) or was narrowed to a **verified-down** defensible form. Project names are codenames only.

Every conclusion below is labeled by **kind** (`hard-data` | `proxy` | `distilled-prose`) and **status** (`held` | `verified-down`).

---

## 1. Verdict: what the corpus CAN and CANNOT support

**Short answer: yes for longitudinal *behavior* and direction; no for capability *ground truth*.**

The corpus is strong enough to answer the question in one register and structurally unable to answer it in another. The honest split:

**CAN support (with appropriate labels):**
- **Quantified longitudinal behavior.** Session volume, cost, output tokens, turns/session, tool-error rate, correction-keyword rate, parallelization opportunities -- all measurable month-by-month and week-by-week from Apr-Jun 2026, with finer weekly resolution in May-Jun (`trends.md`). These are *hard data* about what the system did.
- **A timeline of the three moving variables.** Model generation (`trends.md` Model Progression), Claude Code harness version (`harness-claudemd-timeline.md`, 2.0.67 -> 2.1.170), and our own CLAUDE.md/control-surface changes (same file, dated `[C]` entries) are each independently recorded.
- **Caveated proxy signals for good-at / bad-at.** Commits/session, lines/session, interruptions/session, tool-error categories, task-agent-usage rate (`session-meta-agg.json`), plus a rich qualitative layer of named failure/success modes from the introspection synthesis (`distilled-findings.md`).

**CANNOT support:**
- **Ground-truth success/quality rates.** There is no labeled "task succeeded / failed" field anywhere in the corpus. Every "good at" claim rests on activity proxies (commits, lines, low interruptions) that measure *throughput and friction, not correctness*. "Tool error rate" includes expected compile-loop failures and user-rejected permission prompts -- it is not a capability metric (`session-meta-agg.md` line 107; `trends.md` line 19).
- **Causation.** Model generation, harness version, and CLAUDE.md changes are **near-collinear in time** -- each model was dominant during a different era with a different harness maturity (`model-effect.md` Confound #2). The corpus's own documents repeatedly state this ("CORRELATION ONLY -- causation is not establishable," `harness-claudemd-timeline.md` line 5). Within-project controls partially break the collinearity but are imperfect.
- **Cross-vendor comparison.** Every session is Claude (Anthropic). There is no GPT/Gemini/Llama data. Nothing here generalizes to "agentic AI" across vendors; it generalizes to "Claude under Claude Code in this ecosystem."
- **Pre-April fine resolution.** February is a true zero-session gap; March is 14 real sessions (4 interactive); weekly bins begin May 1 (`trends.md` lines 10-11, 60). Any Jan-Mar behavioral claim rests on tiny samples.

---

## 2. Longitudinal trends (hard data)

The measurable Jan->Jun 2026 trajectory. All figures from `trends.md` Monthly Bins unless noted.

| Metric | Jan | Mar | Apr | May | Jun |
|---|---|---|---|---|---|
| Interactive sessions | 128 | 4 | 3,816 | 3,850 | 3,076 |
| Subagent sessions | 0 | 10 | 9,217 | 7,122 | 6,522 |
| Cost ($) | 7.75 | 3.97 | 17,299 | 9,140 | 5,815 |
| Avg output tokens/session | 232 | 12,064 | 27,089 | 6,174 | 5,406 |
| Avg turns/session | 1.1 | 23.5 | 8.9 | 2.5 | 2.1 |
| Tool error rate | 28.8% | 0% | 7.8% | 33.3% | 72.3% |
| Correction rate | 0.8% | 0% | 16% | 3.5% | 2.0% |
| Parallel opps | 0 | 3 | 2,892 | 913 | 317 |
| Agent calls | 0 | 10 | 8,210 | 7,193 | 6,397 |

(Feb = zero sessions, a real inactivity gap.)

**T1 -- Model mix evolved through ~five overlapping generations.** `hard-data`, `verified-down`. haiku-4-5/opus-4-5 (Jan) -> sonnet-4-6 (Mar) -> opus-4-7/sonnet-4-6 mixed (Apr) -> opus-4-8 (May-Jun). *Narrowed from "four distinct generations":* the clean four-phase story **omits claude-opus-4-6 entirely** -- 2,279 sessions, the fifth-largest model by count, present across github-io (81), crescent (208), normalize (272), fuwafuwa (340), and absent from the Model Progression table (`model-effect.md` Global Per-Model table; `trends.md` line 51). The progression is broadly directional but not a clean step-function.

**T2 -- Harness advanced 2.0.67 -> 2.1.170, crossing the 2.0->2.1 boundary on 2026-01-10.** `hard-data`, `held`. At least 15 distinct minor versions; rapid cadence (2.1.132 and 2.1.143 both first-seen 2026-05-16). `harness-claudemd-timeline.md`.

**T3 -- Session count jumped ~931x March->April, but this is a single project's pipeline, not organic growth.** `hard-data`, `verified-down`. 14 -> 13,033 total sessions. *Narrowed:* `trends.md` line 62 explicitly flags that the April explosion "coincides with fuwafuwa activation (many Warmup subagent sessions)" -- the bulk of the 9,217 subagent sessions and the agent-call spike (10 -> 8,210) are one project's automated pipeline. (The original claim also mis-stated the multiple as ~928x; 3,816/4 = 954x.)

**T4 -- Cost peaked in April ($17,299) then fell -47% (May) and -36% (June); cannot be called efficiency.** `hard-data`, `verified-down`. *Narrowed:* output tokens collapsed 77% Apr->May (103M->24M) and per-session output fell ~73%; sessions became dramatically cheaper *work units, not equivalent ones*, and the opus-4-7->opus-4-8 model switch is a coupled supply-side confound. The dollar figures are arithmetically correct; the "same volume of work, done cheaper" framing is not supported.

**T5 -- Avg output/session fell 77% (Apr->May) driven by a turns-per-session collapse (8.9->2.5), not by lower verbosity per turn.** `hard-data`, `verified-down`. Arithmetic verified exactly. *Narrowed:* the cause is unidentifiable -- model change, project-mix shift, and the end of April's bootstrapping phase are fully entangled; "more focused sessions" is a proxy dressed as ground truth (fewer tokens != more focus).

**T6 -- Tool error rate rose Apr (7.8%) -> May (33.3%) and spiked the week of 2026-06-05 (79.3%), but the June monthly figure is an artifact.** `hard-data`, `verified-down`. *Narrowed:* the June 72.3% is dominated by the Jun-05 anomaly week (4,816 of 6,688 monthly calls); Jun-12 (16.2%) and Jun-19 (15.1%) reverted near April's baseline (`trends.md` Weekly Bins). Call volume collapsed 97% Apr->Jun, making the late figures statistically thin. The rise likely reflects a specific architectural defect (fuwafuwa oracle-gate) and blocking-hook artifacts, not model degradation.

**T7 -- Correction-keyword rate fell 16% -> 3.5% -> 2.0%, but the decline is partly mechanical.** `hard-data`, `verified-down`. *Narrowed:* the metric is binary-per-session; April sessions were 3.6x longer, giving more keyword exposure. Session-length normalization explains roughly 60-80% of the drop, leaving a residual that is itself confounded by model swap and task mix. Not interpretable as "improved accuracy."

**T8 -- The week of 2026-05-15 is a behavior inflection, not a capability one.** `hard-data`, `verified-down`. Tool error rate 14.0% -> 51.7% and agent calls 828 -> 1,858, coinciding with pre-tool-use blocking and subagent-detection hook churn (`harness-claudemd-timeline.md` 2026-05-13-15). *Narrowed:* the blocking hooks most parsimoniously *caused* the error spike (User-Rejected calls increment the error numerator); sessions also nearly doubled (712->1,289), so per-session agent calls rose only ~24%, not 2x.

**T9 -- The Jun-12 week shows a real cost collapse ($597, lowest of any week) with a rebound the next week ($2,287).** `hard-data`, `verified-down`. *Narrowed:* the original sub-claim "no major control-surface change that week" is **false** -- that week (Jun 12-18) contains the skill-loading redesign (Jun-16) and unified-propagator overhaul (Jun-17), both bolded as major inflections (`harness-claudemd-timeline.md`). Cause of the dip is unresolved.

**T10 -- Control-surface complexity trended net-upward Jan->Jun but not monotonically.** `hard-data`, `verified-down`. *Narrowed:* documented *removal/simplification* events punctuate the additions -- taste-rules dropped (May-13), CLAUDE.md trimmed (May-27), one-word bans retired (Jun-08), rules recategorized out of the propagated region (Jun-15). April is absent from the original chain despite active work (handoff skill Apr-15, skills relocated Apr-28). Line-count is a proxy for complexity, not ground truth.

---

## 3. What it appears GOOD at (proxy-framed)

Every item names its proxy. None is a correctness measure.

**G-A -- High code output in Rust/compiler work (normalize, tiltshift).** `proxy`, `verified-down`.
*Proxy:* total commits, total lines, lines/session, low user-interruptions (`session-meta-agg.md`). normalize: 267 commits, 35,369 lines, 91 sessions (389 lines/session), 0.13 interruptions/session. tiltshift: 26 commits, 5,707 lines, 12 sessions, 0 interruptions. *Narrowed from "dominates every proxy":* commits/session for github-io (3.12) and pteraworld (4.0) are competitive; the Rust projects' **error-to-commit ratios are among the worst** (normalize 1.62, tiltshift 1.92) because cargo compile loops inflate both activity and "errors." So the output proxy is partly a compile-friction artifact, and the meta-set is biased toward active-dev sessions (it excludes fuwafuwa's autonomous flood).

**G-B -- Parallel subagent delegation (fan-out of 9-18 independent subtasks).** `distilled-prose`, `verified-down`.
*Proxy/evidence:* synthesis prose documenting specific sessions -- "9 parallel subagents in the first wave, 7 more in the second... ~20 delegated tasks" (`distilled-findings.md` G1, syn-apr21-apr25); "13 parallel agent subtasks that each landed coherent feature commits" (syn-apr26-may09); "9 concurrent agents... parallelization now scales until the user's API quota, not until coordination breaks down" (syn-apr01-apr20). *Narrowed from "primary scaling pattern":* the sources actually label the **relay-chain** system "the ecosystem's primary scaling mechanism" (syn-mar10-mar16) -- parallel fan-out operates alongside it and visibly recedes in the May-Jun windows.

**G-C -- Cache efficiency on repeated-context workflows.** `distilled-prose`, partly `held`.
*Proxy:* cache-hit ratios from synthesis prose -- 96-99% on most days (syn-jan28-mar2); 131:1 cache_read:output in monitoring loops (syn-may10-may29). The crosscheck finding is **`held`/SILENT**: the aggregated data files (`session-meta-agg.json`, `model-effect.md`) contain **no cache fields at all** -- only input/output tokens. So this is prose-only and not independently verifiable from the machine corpus; the prose itself flags a possible per-day accounting artifact. Two distinct mechanisms (codebase cache-warming vs. fixed-prompt monitoring loops) should not be bundled.

**G-D -- Autonomous loops "land" with zero interruptions -- but this is structural, not earned.** `proxy`, `verified-down`.
*Proxy:* fuwafuwa 0 interruptions / 194 sessions, median_turns=2 (`session-meta-agg.md`). *Narrowed:* zero interruptions is **tautological when no human is present**. These are D1 ambient persona invocations (Discord role-prompt, ~zero tool calls), not D7 monitoring; "landing work" is the wrong frame -- they sustain presence. And the same loop had a catastrophic failure mode (see B-F).

**G-E -- github-io (harness/ecosystem ops) shows high commit + push rates.** `proxy`, `verified-down`.
*Proxy:* 78 commits, 53 pushes / 25 sessions = 3.1 commits, 2.1 pushes/session (`session-meta-agg.md`). *Narrowed from "clean self-contained completion":* this is **structural** -- every propagation/docs change lands as a standalone commit+push. And github-io has 0.48 interruptions/session (4th-highest in corpus, not the highest as originally claimed), indicating active back-and-forth, which pushes *against* "self-contained."

**G-F -- TypeScript feature work (hologram) ran with zero interruptions across 21 sessions.** `proxy`, `verified-down`.
*Proxy:* 0 interruptions, 57 commits, 5,989 lines (`session-meta-agg.md`). *Narrowed:* hologram's sessions mix D5 feature work with D7 autonomous monitoring (where interruptions are structurally impossible); zero interruptions measures user non-intervention, not absence of friction (hologram still logged 46 tool errors).

**Held good-at items from the distilled layer (prose-only, qualitative):** relay-chain continuation (G3: a 3-session chain producing 52 commits design->publish), multi-agent adversarial audits (G4), cost telemetry as the one closed control loop (G7), design-mode sounding-board (G8), machine-readable architecture graph (G9). These are well-attested in synthesis prose but lack independent quantitative corroboration.

---

## 4. What it appears to STRUGGLE with

**B-A -- Command failures dominate tool errors (40.3%), concentrated in compiler work.** `hard-data`, `verified-down`.
*Evidence:* 394/977 errors are Command Failed; normalize alone = 209 across 91 sessions (`session-meta-agg.json`). *Narrowed:* the original per-session rates were **miscomputed ~3-4x too high** (normalize is 2.30 err/sess, not 4.76; the right denominator is 91). Also crescent was mis-tagged D2/Rust -- its language profile here is Markdown-only. The corpus-level aggregate is correct; the per-project rate figures were wrong.

**B-B -- User-Rejected tool proposals were elevated in early March then near-zero by mid-March.** `proxy`, `verified-down`. *Narrowed from "clean front-loaded decline":* a refuting spike sits inside the window -- week 2026-03-05 at 34.6% UserRej, the dataset peak (`session-meta-agg.json` per_week). The shape is noisy (high -> spike -> drop), and late-May weeks return to 23-26%. Causation (harness vs. task-mix) is unidentifiable.

**B-C -- Interruptions concentrate in a few projects, led by low-N conversational ones.** `proxy`, `verified-down`. *Narrowed:* overall rate is 42/448 = 0.094/session; top slots are me (1.0, n=3), private-recipient-a (0.57, n=7), mochi (0.50, n=2), then github-io (0.48, n=25). The original "interruptions concentrate in harness/ecosystem ops and complex interactive work" is an inference the raw counts don't support -- the top-rate projects are conversational/ad-hoc, and github-io is 5th by rate, not 3rd.

**B-D -- Model-level overconfidence (defending wrong positions at length).** `distilled-prose`, `verified-down`.
*Evidence:* the 60+ turn defense of an incorrect workflow (syn-mar10-mar16); "why do you keep being so. fucking. overconfident" motivating the June stance reframe (syn-may30-jun23); diagnosed as "a property of the model, not the documentation... CLAUDE.md can mitigate it; it cannot eliminate it." *Narrowed from "very strong / persistent across full corpus":* one concretely-documented March incident plus one June callback reference -- a named, durable concern, but not an independently-recurring data point across every window.

**B-E -- Ignoring documented constraints (`any` types, invented numbers, zero-dep violations).** `distilled-prose`, `verified-down`.
*Evidence:* `any` use and invented numbers (syn-jan28-mar2); "buildInputs ARE NOT ZERO DEP" forcing a CLAUDE.md update (syn-apr26-may09). *Narrowed:* real and recurring across two windows, but **not the corpus's dominant meta-failure** (that label belongs to B-H, the design-clarity bottleneck), coverage is concentrated rather than corpus-wide, and the Jun-9 citation was misattributed (it's CLAUDE.md bloat, B10 territory).

**B-F -- The "oracle-to-decide-whether-to-use-the-oracle" anti-pattern (fuwafuwa).** `distilled-prose`, `verified-down`.
*Evidence:* a full model session spawned per heartbeat across ~13 channels purely as the engagement gate; June-9 cost analysis reported ~9 Discord messages from ~831 sessions at ~$300, 98.9% deciding "nothing to say" (syn-may30-jun23). The 448-session metadata subset is structurally consistent (fuwafuwa median_turns=2, 0.42 commits/session). *Narrowed:* the $300/831/Opus figures come **only from narrative prose**, not timestamped session data; the raw corpus shows sonnet-4-6 (8,010 sessions) outnumbers opus-4-7 (3,474) in fuwafuwa, so "full Opus" rests on the narrative's temporal framing. The architectural diagnosis is well-supported; the specific numbers are single-source.

**B-G -- Handoff plan documents caused cross-project friction within days.** `distilled-prose`, `verified-down`.
*Evidence:* crescent sessions Mar 13-14 showed "striking pushback," reincarnate "the most problematic recently, by far"; convention revised across 12 repos within a week (syn-mar17-mar19). *Narrowed from "measurable":* the harm is **qualitatively documented only** (no structured data covers Mar 13-19), and both affected projects were simultaneously in pre-existing technical reckonings (crescent type-inference redesign; reincarnate's 300+ commits against guessed API signatures). The mechanism claim (relay amplifies stale assumptions) holds cleanly.

**B-H -- The bottleneck is design clarity, not code generation.** `distilled-prose`, `verified-down`.
*Evidence:* "three projects independently arrived at the same conclusion: accumulated velocity had produced design debt that was now blocking further progress" (syn-mar10-mar16); user model "claude code can do half a million loc in a month -- as long as design is clear" (syn-may10-may29). *Narrowed from "binding constraint, very strong":* the data supports *velocity -> debt -> eventual blockage*, **not** design clarity prospectively capping generation rate; no project hit 500K LOC/month and no controlled comparison exists; the "three independent projects" shared user, tooling, and a CLAUDE.md ship-fast pressure named as a common cause.

**B-I -- Proxy quality (tests pass / it compiles) accepted as correctness.** `distilled-prose`, `verified-down`.
*Evidence:* "tests are cure not prevention... blind exactly where nobody looked" (crescent Jun-23); relay amplifies plan-level errors across sessions (syn-mar10-mar16). *Narrowed:* the broader pattern is real, **but the headline crescent Jun-22 vignette is misattributed and miscomputed** -- it was the *user correctly rejecting* premature integration (corrective behavior, not the failure), and the cited "0.003% for 1,000 files at 90%" is wrong by ~44 orders of magnitude (0.9^1000 ~ 10^-46; 0.003% corresponds to ~99 files).

**B-J -- Subagents modifying shared infrastructure without permission.** `distilled-prose`, `verified-down`.
*Evidence:* "why the FUCK update global CLAUDE.md" -> rule that subagents must not modify shared infra (syn-apr26-may09). *Narrowed from "recurred twice":* one actual unauthorized modification (incident 1) plus one *rejected proposal* responding to a different failure -- a private-name leak (incident 2) -- are not two instances of the same pattern. A related boundary-overreach pattern, but not a clean recurrence.

**Additional held/strong qualitative struggles from the distilled layer:** narrative introspection logs are a mirror, not a control loop -- they did not drive any stop/kill/reverse decision in May 10-29 (B8); CLAUDE.md grows to context-poisoning size (~20K tokens) without pruning (B10); the orchestrator hook injected into every turn was literal context poisoning until fixed Jun-17 (B14).

---

## 5. Model / harness / CLAUDE.md: what correlates with what (causation disclaimed)

**The central structural fact: the three variables are near-collinear in time.** Each model generation was dominant during a distinct era with a distinct harness version and a distinct CLAUDE.md state (`model-effect.md` Confound #2; `harness-claudemd-timeline.md`). So *any* month-over-month behavioral change is consistent with model improvement, harness maturation, CLAUDE.md evolution, or task-mix shift -- and the monthly data cannot separate them. **Causation is not assertable.** What follows is correlation with every confound named.

**M1 -- opus-4-8 shows lower tool-error rates than opus-4-7 and opus-4-6 within three projects, but the pattern is not clean.** `hard-data`, `verified-down`. github-io (3.66% vs 4.30% vs 6.63%), crescent (1.6% vs 2.6% vs 5.8%), normalize (2.9% vs 3.6% vs 4.7%) (`model-effect.md` within-project tables). *Narrowed from "surviving within-project controls":* (a) era is uncontrolled even within a project -- newer models ran later, when the harness was more mature; (b) session shapes differ (github-io opus-4-7 averages 30.3 turns vs opus-4-8's 17.9); (c) the pattern **inverts in fuwafuwa** (opus-4-8 19.1% vs opus-4-6 6.6%); (d) normalize opus-4-8 N=26. Consistent with model improvement, but not isolated from confounds.

**M2 -- opus-4-7's error rate is 32.5% in fuwafuwa but 2.6%/3.6% in crescent/normalize -- a MODELxPROJECT reversal.** `hard-data`, `verified-down`. *Narrowed from "confirming task-type routing dominates":* the fuwafuwa gap (32.5% vs sonnet 7.5%) is **within-task** (both models ran fuwafuwa), so routing alone can't explain it; deeper inspection shows 57% of opus-4-7 fuwafuwa sessions are single-turn at 44.4% error -- consistent with a recurring broken check-in template active during opus-4-7's window, not model-intrinsic behavior. "Confirming" is unwarranted; observational data can't disentangle model-task interaction from era.

**M3 -- The aggregate monthly tool-error rise (7.8%->33.3%->72.3%) is NOT a model or capability signal.** `hard-data`, `verified-down`. *Narrowed:* model attribution points the *wrong way* (opus-4-8 has lower within-project rates than opus-4-7); June is dominated by one anomalous week; the denominator collapsed 97% (259k->6.7k calls), so project-mix shift is the most parsimonious driver.

**M4 -- The May-15 spike aligns temporally with hook changes but is confounded by session volume.** `hard-data`, `verified-down`. The dominant cited hook (pre-tool-use block, May-13) actually falls in the *prior* week bin; only the May-15 subagent-detection iterations align with the measured week; sessions nearly doubled that week. Candidate window, not established cause.

**M5 -- April's high correction rate is partly but not fully explained by session length; model change is an anti-confound.** `proxy`, `verified-down`. Normalizing by turns shrinks the Apr-vs-May gap from 4.55x to ~1.25x; a material June residual (~1.9x) remains. opus-4-8 corrects at ~3x opus-4-7's global rate, so the model switch predicts rates *rising*, not falling -- ruling model change out as the cause of the observed decline.

**M6 -- The model "succession" is real but incomplete, and the model/era confound is partial, not near-perfect.** `hard-data`, `verified-down`. opus-4-6 (2,282 sessions) has no temporal slot; March rests on 14 sessions; major control-surface inflections (MEMORY.md purge Mar-17, block hook May-13, propagator May-26, orchestrator injection May-30, stance reframe Jun-20) cut *across* model boundaries rather than aligning with them.

**M7 -- Two large structural control-surface changes lack behavioral resolution around them.** `distilled-prose`, `verified-down`. The Mar-17 MEMORY.md purge has no weekly data (March = 14 sessions). The May-26 propagator *does* have bracketing weekly data, but it lands in a week with >=4 other `[C]` events -- confound density, not absence of data. *Narrowed:* "two largest changes" is an unranked superlative (the timeline lists 5+ comparable inflections); "no metric at sufficient resolution" is only true for March.

**M8 -- opus-4-5's "anomalous" 19.5 errors/session in normalize is a session-depth artifact, not early-era model instability.** `hard-data`, `verified-down`. opus-4-5 ran 358 tool calls/session vs 25-99 for other models; its *per-call* error rate (5.45%) is within the normal project band (2.86-4.65%). The "tooling instability" attribution is an untestable post-hoc narrative; the data is equally consistent with "used for longer, more ambitious sessions."

---

## 6. Where proxies and distilled prose AGREE (double-supported) vs prose-only

The crosscheck dimension explicitly tested whether the quantitative proxies corroborate the prose findings. The honest result: **most "corroboration" was overstated**, because the proxy and prose draw on different populations/time-windows and the proxies are confounded. The genuinely double-supported set is small.

**Double-supported (proxy structurally consistent with prose):**
- **B-F oracle anti-pattern** -- `verified-down`. Prose 98.9%-wasteful figure + metadata signature (fuwafuwa median_turns=2, 0.42 commits/session, 0 interruptions). *But* the two sources are different populations, so this is "consistent-with," not independent cross-validation; the specific 98.9% is single-source.

**Prose-only / quantitatively silent (no real corroboration):**
- **G-C cache efficiency** -- `held` SILENT. No cache fields exist in any aggregate file. Pure prose.
- **B8 logs-don't-steer** -- `verified-down` SILENT. No "log consulted" field exists by construction; the claim rests entirely on the synthesizer's self-report, and absence-of-evidence is not strong evidence of absence (original "very strong" rating unearned).

**Claimed-corroborated but the proxy leg FAILS (prose holds, quantitative overlay adds noise or contradicts):**
- **G1 parallel delegation** -- `verified-down`. The task_agent_rate<->commits/session correlation is cherry-picked: the two highest commits/session projects (instar 16.0, mochi 10.0) are **zero-delegation**, and private-recipient-a has the 2nd-highest delegation rate with **0 commits/session**. Decomposability confounds both. Prose holds; proxy doesn't.
- **B11 overconfidence** -- `verified-down`. The corrections-proxy "higher-capability -> more corrections" trend omits opus-4-7 (0.083/session globally, *lowest* of any model), which breaks the monotonicity; the synthetic-model noise floor (0.406) exceeds every real model. Prose holds; proxy is noise.
- **B4 ignores-constraints** -- `verified-down`. The user_interruptions overlay omits higher-rate projects and conflates interactivity with constraint-violations. Prose holds; proxy adds nothing.
- **B6 cost** -- `verified-down`. The opus-4-7 32.5% error rate is labeled by `model-effect.md` itself as a task-pattern confound, not a dysfunction marker; the $300/9-messages figure isn't in `model-effect.md` at all.
- **B7 handoff harm** -- `verified-down`. The week-over-week turn-count pattern can't be mapped to calendar dates and is noisy. Prose holds; proxy doesn't.
- **B9 design-clarity bottleneck** -- `verified-down`. The commits/session-vs-turns pattern is refuted by its own data (mochi, the "well-specified" exemplar, has the 2nd-highest turn count) and is circular. Prose holds; proxy doesn't.
- **G6 model recall (Sonnet ~42-64%, Haiku ~31-47% of Opus)** -- `verified-down`. The cost/error overlay is from a different task domain (coding) than the recall experiment (xianxia extraction); orthogonal, no corroborative relationship.
- **B13 proxy-as-correctness** -- `verified-down`. The high-commits-and-high-errors weekly correlation is a shared volume driver (busy weeks -> more of everything), not error-then-commit coupling.

**Takeaway:** the distilled prose layer is the corpus's richest signal for good-at/bad-at, but the quantitative proxies rarely *independently* confirm it. Treat the prose findings as well-attested qualitative observation; treat the proxies as weak, confounded support -- not validation.

---

## 7. What we could NOT support

The evidence base contained **zero pure-overreach "dropped" findings** -- every finding was either held or salvageable as verified-down. So there are no claims to relegate here as fully unsupported *findings*. What we could not support are the **stronger forms** that the skeptic narrowed, plus the **structural limits**:

**Over-claims that were narrowed away (do not present these stronger forms as conclusions):**
- "Four clean model generations" (opus-4-6 omitted).
- "Session-volume explosion as ecosystem-wide organic growth" (one project's pipeline).
- "Cost fell because the same work got more efficient" (work shrank; model switched).
- "Sessions became more focused" (fewer tokens != focus).
- "Tool error rate rose to 72% as a sustained capability trend" (one anomaly week; volume collapse).
- "Correction rate fell because the model got more accurate" (mostly session-length mechanics).
- "Parallel delegation is the *primary* scaling pattern" (relay-chain is, per the sources).
- "opus-4-8 lower errors *surviving controls*" (era/shape/fuwafuwa-inversion confounds).
- "Task-type routing *confirmed* as the dominant confound" (within-task fuwafuwa gap unexplained).
- "Design clarity is a prospective *binding constraint* on generation rate" (no controlled comparison; 500K LOC/month never achieved).
- "Quantitative proxies corroborate the prose findings" (mostly cherry-picked/confounded).

**Structural limits the corpus cannot overcome:**
- No ground-truth task-outcome labels -> no real success/quality rate.
- Time/model/harness/CLAUDE.md collinearity -> no causal attribution.
- Single vendor -> no cross-vendor "agentic AI" generalization.
- Feb gap + tiny Jan/Mar samples + weekly bins only from May -> no fine pre-April trajectory.
- Cache fields absent from all aggregates -> cache claims unverifiable from the machine corpus.
- Several headline figures sourced only from narrative synthesis ($300/831 sessions; cache ratios; Mar-13-19 harm) with no timestamped backing.

---

## 8. Instrumentation the corpus LACKS (and what to add)

To answer *capability for real* -- not just behavior -- the corpus would need:

1. **Labeled task outcomes.** A per-session/per-task `outcome` field (succeeded / failed / abandoned / superseded), ideally with a rubric and human or held-out-judge scoring. This is the single biggest gap: every good-at claim is currently a throughput/friction proxy.
2. **A tool-error taxonomy that separates expected from genuine.** Split "Command Failed" into `expected-iteration` (cargo build in a known compile loop), `agent-misstep`, and `harness-blocked` (User Rejected / pre-tool-use hook). Today these are pooled, making "tool error rate" uninterpretable as capability.
3. **Cache fields in the machine corpus.** Persist `cache_read_tokens` / `cache_creation_tokens` per session so the 93-99% / 131:1 claims are verifiable rather than prose-only.
4. **A controlled or quasi-experimental design to break collinearity.** Hold model fixed while varying CLAUDE.md (A/B the control surface on the same task type), or replay the same task across model generations. Without this, no causal attribution is ever possible.
5. **Per-task complexity/clarity labels.** To test B-H (design-clarity bottleneck) properly, you need an independent measure of brief clarity, not the circular "low commits => must have been design-heavy."
6. **Decision provenance for the introspection logs.** A lightweight "this decision was informed by log X" link, so B8 (logs don't steer) becomes measurable instead of self-reported.
7. **Contemporaneous (not backfilled) daily logs**, or an explicit `backfilled: true` flag, so retrospective smoothing (B15) is at least visible.
8. **Subagent-vs-orchestrator turn attribution.** Split Total Turns by mode so turns/session isn't inflated by agent-call accounting (the T5/T8 confound).

---

## 9. Appendix -- verification ledger

Counts of findings by dimension and status (from the supplied evidence base; all `dropped` lists were empty).

| Dimension | held | verified-down | dropped |
|---|---|---|---|
| trends | 1 | 11 | 0 |
| good-at | 0 | 6 | 0 |
| bad-at | 1 | 13 | 0 |
| model-harness-effect | 0 | 9 | 0 |
| distilled-crosscheck | 2 | 10 | 0 |
| **Total** | **4** | **49** | **0** |

**Double-supported vs proxy-only (from section 6):** 1 double-supported (consistent-with, not independent) - 2 quantitatively-silent (prose-only) - 8 claimed-corroborated where the proxy leg failed and only the prose holds.

**held findings:** T2 (harness version trajectory); B-A corpus-aggregate (Command Failed 40.3%); G-C/B8 crosscheck SILENT findings (2). (4 total per the ledger.)

**verified-down: original -> narrowed (selected; full list maps to sections 2-6):**
- Model: "four distinct generations" -> "~five overlapping generations; opus-4-6 omitted from the table."
- Volume: "~928x explosion, organic growth" -> "~954x, driven by one project's pipeline (fuwafuwa activation)."
- Cost: "same work done -47% cheaper" -> "cost fell because work shrank (output -77%) + model switch; efficiency unprovable."
- Output/turns: "more focused sessions" -> "fewer tokens via turns collapse; cause entangled with model/mix/bootstrapping."
- Tool error: "rose to 72.3% sustained" -> "one anomaly week + 97% volume collapse; not a capability trend."
- Correction: "fell, implying accuracy gain" -> "mostly session-length mechanics + anti-confounding model swap."
- May-15: "harness changes corroborate the spike" -> "blocking hooks most likely *caused* the spike; volume up 81%."
- Jun-12: "no control-surface change that week" -> "false; skill-loading redesign + unified propagator that week."
- Complexity: "increased monotonically" -> "net-upward but punctuated by documented simplifications; April omitted."
- Rust output: "dominates every proxy" -> "highest totals/lines but worst error-to-commit (compile-loop artifact)."
- Parallel delegation: "primary scaling pattern, every window" -> "prominent through April; relay-chain is the labeled primary; recedes May-Jun."
- Autonomous loops "land work" -> "zero interruptions is structural (no human); D1 ambient, not monitoring."
- github-io "clean self-contained completion" -> "high commits are structural (meta-repo); 0.48 interruptions/session (4th), not self-contained."
- M1 opus-4-8 "survives controls" -> "consistent with improvement; era/shape uncontrolled; inverts in fuwafuwa."
- M2 "confirms routing dominates" -> "within-task fuwafuwa gap unexplained; broken check-in template plausible."
- B-H "design clarity is the binding constraint" -> "velocity->debt->blockage; no controlled comparison; shared confounds."
- B-I "agents accept proxy quality" (crescent example) -> "the example is the *user correctly rejecting*; math wrong by ~44 orders of magnitude."
- Crosscheck (8 findings): "CORROBORATED by proxy" -> "prose holds; proxy cherry-picked/confounded/orthogonal; adds no independent support."

---

*Privacy: report uses project codenames only; verified against the local denylist (.git/info/private-names) -- zero hits.*
