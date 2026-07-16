# Jevons Paradox and Substrates

## The question

Efficiency gains in AI inference are supposed to be good news: cheaper tokens, more
capability per watt. The Jevons paradox says otherwise. When a resource becomes more
efficient to use, usage grows to more than offset the efficiency gain, and total
consumption climbs. Coal-fired steam engines got more efficient in the 19th century and
coal consumption went *up*, not down, because cheaper power unlocked uses that weren't
economical before.

Applied to AI, the framing looks bleak. More efficient models make inference cheaper.
Cheaper inference means more usage. And AI usage is not obviously bounded the way
industrial coal demand was — an agent that can spawn subagents multiplies a single human
request into an arbitrarily large tree of model calls, each one consuming compute, each
one capable of spawning further subagents if the subtask still looks too big to do in one
shot. Demand-side, there's no natural ceiling in sight.

Supply-side fixes don't rescue this either. You could try to outrun demand with energy —
more power plants, more data centers, more efficient chips — but if usage growth is
genuinely unbounded (or even just grows faster than energy buildout can), no finite supply
catches up. Chasing an unbounded demand curve with a bounded supply curve is a race you
lose by construction, regardless of how fast supply grows.

So the standard framing offers two levers, demand and supply, and both look stuck. Is
there a third lever — one that doesn't require capping demand or racing supply?

## The expansion factor

Look at what actually happens when an agent handles a task it can't do in one shot: it
decomposes the task and spawns subagents for the pieces. Each subagent, in turn, either
completes its slice directly (the base case) or decomposes further. The total compute
spent on a single user request is a function of how deep and how wide that recursion tree
gets before every leaf hits a base case.

That recursion has a hidden variable: what determines the base case. A subagent stops
decomposing and does the work directly when the task in front of it is *small enough* —
and "small enough" is not a property of the request, it's a property of the substrate the
agent is working with. If accomplishing a goal requires touching twelve files, restating
the same fact in six different syntaxes, and hand-writing boilerplate at every layer, the
task looks big and the agent decomposes it. If the substrate already absorbs that
ceremony and the actual task collapses to "state this one fact," the agent does it
directly — no decomposition, no subagent, no additional compute.

This reframes the problem. The expansion factor — the ratio between "what was asked" and
"what actually gets executed" — is not fixed. It's a function of substrate complexity, and
substrate complexity is something engineers control. A better substrate produces an
earlier base case, a shallower recursion tree, and less total compute *per request*,
independent of how many requests arrive and independent of how efficient the underlying
model is. This is a lever distinct from demand management and distinct from supply
buildout: it attacks the multiplier sitting between the two.

That's a claim worth being skeptical of. The rest of this essay is an attempt to find out
whether it holds up, starting from a concrete question: why is production software as
large as it is in the first place?

## Why apps are so big: a case study

To get a feel for the size of the multiplier, it helps to look at one real, large,
unremarkable production codebase rather than reasoning about "ceremony" in the abstract.
The case study here is a production SaaS for a tutoring business — ordinary
line-of-business software: scheduling, payments, messaging, reporting. Nothing exotic
about the domain.

The codebase is roughly 626,000 lines. For scale, that's larger than the entirety of
[Bun](https://bun.sh), a JavaScript runtime with a native HTTP server, bundler,
transpiler, package manager, and test runner — Bun is on the order of a million lines
across a much broader problem (implementing a language runtime), which makes 626k lines
for a scheduling-and-payments app worth pausing on.

Breaking it down:

- **297,000 lines** live in 97 backend packages. Of that, an estimate of the code that is
  actual business logic — the part that encodes a decision specific to this domain, not
  infrastructure plumbing — comes out to roughly **10,000–15,000 lines**. The other
  280,000-plus lines are validation, wiring, persistence boilerplate, and other
  ceremony the substrate does not absorb.
- Individual use cases average an estimated **70–87% ceremony**: parse and validate
  input, fetch the relevant records, perform the actual check, write an audit record,
  publish a domain event, construct the response shape. A representative example —
  cancelling a lesson — is, at its business-logic core, about five lines: check the
  current status, if it's cancellable set it to cancelled. Getting that five-line decision
  to actually run in this codebase costs on the order of **160 lines** once you count the
  route handler, the input schema, the fetch, the permission check, the audit write, the
  event publish, and the response serialization spread across the stack.
- **229,000 lines** live in the UI layer. The codebase does have a "projector"
  abstraction — a pattern that derives a page's rendering from a declarative description
  instead of hand-writing the DOM construction and event wiring — and where it's used, it
  cuts page size by roughly 80%. But it's only applied to part of the UI; the rest is
  hand-written pages of conventional size. The gap between the projected pages and the
  hand-written ones is itself evidence for the thesis: the same result is achievable at a
  fraction of the code, when the abstraction actually gets used.

These are estimates from inspecting one codebase, not a controlled measurement across a
corpus — the exact percentages would move if someone else drew the business-logic
boundary differently. But the qualitative picture is hard to avoid: the overwhelming
majority of this application's size is not encoding anything specific to tutoring
businesses. It's ceremony. Which raises the actual question: why does the ceremony exist
at all? Code doesn't have to physically outweigh the information it carries — so why does
it?

## Why code carries more than its marginal entropy

The five-line "cancel a lesson" decision costs 160 lines because that decision doesn't
live in one place. It gets restated at every boundary the request crosses, and each
boundary speaks a different language: SQL for the schema, TypeScript types for the
application layer, a validation schema (Zod or similar) for the input boundary, an HTTP
route binding for the transport layer, DOM/component code for the UI. None of these
languages share a common representation of "what a lesson's status can be," so the fact
has to be re-encoded, by hand, once per language.

Concretely: the statement "`Lesson.status` is an enum of `scheduled | in_progress |
completed | cancelled`" is not one line of code in a codebase like this. It's the SQL
column definition (with a `CHECK` constraint or a Postgres enum type), the TypeScript
union type, the Zod (or equivalent) validation schema, the OpenAPI/GraphQL schema
fragment if one exists, the form component's set of allowed options, and the switch
statement that renders a badge per status — six to eight separate restatements of the
same fact, each in a syntax the others don't understand, each requiring separate
maintenance when the fact changes.

Part of what drives this is that most languages force more specificity than the actual
content warrants. A validation schema has to spell out every field even when the honest
answer is "same shape as the database row, minus two fields." A TypeScript type has to be
declared even when it is fully computable from the schema that already exists one layer
down. The language doesn't let you say "same as usual, except X" — it makes you restate
the whole thing, X included, from scratch. That gap between what's actually new
information (X) and what you're forced to write (the whole restated fact) is exactly the
ceremony measured above.

So the excess bulk isn't randomness or bad engineering — it's a structural consequence of
crossing representation boundaries that don't share a substrate. Every boundary is a place
a fact gets restated, and the number of restatements, not the amount of actual logic, is
what makes the codebase big.

## The approximation error framing

The case study above suggests a three-way split that applies to any codebase, not just
this one:

1. **Substrate** — whatever you build on top of: the language, the framework, the
   libraries, your own internal abstractions. The substrate is an approximation of what
   any given application needs; it ships with defaults and conventions that cover the
   common case.
2. **Approximation error, i.e. correction terms** — the business logic. The delta between
   what the substrate gives you by default and what you actually want. "Cancel a lesson
   only while it's `scheduled` or `in_progress`" is a correction term: it's the five lines
   the case study measured as the decision's actual content. This delta *is* the marginal
   entropy of the application — the information that couldn't have been known without this
   specific domain — and it's the only code that should, in principle, need writing.
3. **Encoding overhead** — ceremony. Not part of the substrate (it's not a default the
   substrate provides), and not part of the correction (it encodes no domain decision). It's
   the toll charged for expressing the correction in a system that doesn't accept
   corrections cleanly — the other 155 of the 160 lines. It carries no information: two
   codebases with identical business logic but different amounts of encoding overhead
   contain the same *facts*, just restated a different number of times.

The useful move here is that "substrate" isn't a special category of software — it's just
*whatever's below you*. Your language is a substrate for your framework. Your framework is
a substrate for your application. Your own internal abstraction layer is a substrate for
the feature code sitting on top of it. The three-way split applies recursively at every
layer: at each boundary, the code written there is either a correction term (something
that makes *this* layer do what's needed that the layer below didn't already default to)
or encoding overhead (ceremony the layer below forces on anything built above it, whether
or not that thing has anything new to say). Improving any one layer — giving it better
defaults, letting it accept a correction more directly — reduces overhead for every layer
stacked on top of it, which is why "substrate" recurs as the unit of leverage throughout
this essay rather than "framework" or "library" specifically.

This is also where the framing reconnects to the Jevons question this essay opened with.
AI Jevons runs on the encoding overhead, not on the business logic. When an agent
decomposes a task into subagents because the task "looks big," what's making it look big is
almost never the correction term itself — five lines to gate a status transition doesn't
need decomposing. It's the encoding overhead: the route handler, the schema restatement,
the audit write, the six syntaxes the same enum has to be spelled out in. The expansion
factor described earlier — the ratio between what was asked and what actually gets
executed — *is*, in this vocabulary, the ratio of encoding overhead to correction terms.
Reducing encoding overhead at any layer of the stack shrinks the recursion tree above it,
which is the mechanism, stated plainly, behind the substrate lever this essay is arguing
for.

Two things this framing does not resolve, left open deliberately: it doesn't say how to
tell, mechanically, which lines in a given file are correction and which are overhead
(that's exactly the undecidable-in-general problem the measurement section below runs
into), and it doesn't say how much encoding overhead is *irreducible* — some minimum
ceremony may be the unavoidable cost of crossing any boundary at all, in which case the
lever has a floor rather than a path to zero.

## Prior art, and why it hasn't worked

This is not a new observation, and there's a long history of attempts to fix it, worth
taking seriously before proposing another one.

**Domain-specific languages.** [Wasp](https://wasp.sh) is the most direct prior attempt
at exactly this problem: a DSL for describing a full-stack web app (routes, data models,
auth, jobs) that compiles down to a React/Node/Prisma app, eliminating the boilerplate at
the boundaries by generating it from one declarative source. According to the project's
own public retrospective, after roughly five years and $5M raised, the team concluded that
"the language was never the moat" — the actual value was never the DSL syntax itself, it
was the fact that the compiler had whole-app understanding at compile time and could
therefore generate every boundary consistently from one source of truth. They
subsequently pivoted away from a custom DSL toward plain TypeScript declarations that
provide the same compile-time whole-app comprehension without asking developers to learn
a new syntax or leave the TypeScript ecosystem.

That pivot is itself evidence for a specific failure mode of DSLs: they are rigid. A DSL
can express the common cases cleanly, but the moment a use case needs something the DSL
designer didn't anticipate, the only way out is to drop out of the abstraction entirely —
back to hand-written glue, bypassing the very thing that was eliminating ceremony. The DSL
approach ends up degrading gracefully in principle and ungracefully in practice, because
"drop into raw code" is a cliff, not a slope.

**Everything else.** ORMs promised to eliminate the SQL-to-application boundary; they
introduced their own query-building DSL and impedance-mismatch problems instead of
removing one. Frameworks promised convention over configuration; the configuration moved
into framework-specific magic that's arguably harder to reason about than the boilerplate
it replaced. Code generators promised to write the restated boundaries for you; they
turned the ceremony into generated files that still exist, still need to be regenerated on
change, and still show up in the LOC count an agent has to reason about. Low-code
platforms promised to eliminate code entirely; the complexity resurfaced as configuration
trees and escape-hatch scripting once requirements got specific.

The pattern across all four: the ceremony doesn't disappear, it *relocates*. Something
still has to hold "what this data looks like" and re-derive every representation from it,
and every one of these approaches either doesn't actually centralize that fact (ORMs,
frameworks) or centralizes it in a form too rigid to survive contact with a real
application's edge cases (DSLs, low-code).

## The substrate approach

The corrective, going by both Wasp's own retrospective and the pattern above, is not
another DSL and not a macro system that expands a compact syntax into the same
boilerplate at build time. It's **composition with sensible defaults**: state each fact
once, in a form expressive enough to cover edge cases without dropping out of the
abstraction, and derive every other representation — SQL schema, validation, types,
transport bindings, UI — from that one statement. The defaults handle the common case with
no additional code; overriding a default for an edge case is a local, incremental change,
not an escape hatch that throws away everything else the abstraction was providing.

Three existing projects attack different pieces of this, from different ends:

- **fractal** treats APIs as plain data: an endpoint is a `Node`
  (a small tree combining a reflection descriptor with a handler), and multiple
  interpreters walk the same tree to produce an HTTP server, an OpenAPI document, a typed
  client, a CLI, or an MCP server — one definition, many projections, instead of one
  definition per projection. It's getting a types-projection layer next, which would
  extend "state once, derive everywhere" to cover the TypeScript-type restatement
  specifically.
- **[rainbow](/projects/rainbow)** attacks the UI-state boundary with optics (lenses and
  prisms as first-class, composable values with laws). Instead of hand-writing
  synchronization code every time UI state needs to track application state, the
  relationship is declared once as an optic and reactivity propagates automatically. A
  TodoMVC implementation on this model runs to roughly 65 lines — a useful data point on
  what "the boundary doesn't need restating" looks like at small scale, though it's a toy
  benchmark, not evidence about an application anywhere near 626k lines.
- **[crescent](/projects/crescent)** takes the vendoring-first route: a zero-dependency
  Lua ecosystem aiming to cover the entire surface area of software an application might
  need — HTTP, storage, DNS, and so on — as libraries you vendor in and own outright,
  rather than boilerplate you write per-project. The organizing principle stated in the
  project itself is "make the computer small": for any given app, the actual surface it
  needs is bounded, and the more of that surface a substrate already covers, the less
  remains to be generated per application.

None of the three is a finished answer to the case study above — fractal doesn't yet have
the types layer, rainbow's optics model hasn't been proven at anything like 229k-line UI
scale, and crescent's coverage of "the entire surface of software" is necessarily always
partial. And there's a piece the three don't cover yet at all: **persistence ceremony** —
the case-study codebase's hand-written data-access layer runs to something on the order of
147 individual query methods, each restating a shape the schema already knows. That gap is
open.

## Measuring it: normalize-semantic-facts

Everything above is qualitative — "this looks like ceremony," "this looks restated." An
open tooling question sits underneath the whole investigation: how do you actually
*measure* how much of a codebase is restatement of an existing fact versus genuinely new
information?

A fully general answer is undecidable in the strict sense — deciding whether two pieces of
code encode "the same fact" in general is equivalent to deciding semantic equivalence,
which is not computable in general. But a narrower, three-state classification looks
tractable: label each candidate fact as **authoritative** (this is the one place the fact
is genuinely defined), **derived** (this is mechanically computable from an authoritative
fact elsewhere and could in principle be generated), or **uncertain** (not enough
structural signal to tell). Refusing to force a binary call on the hard cases is what
makes the classification tractable — the uncertain bucket absorbs the undecidable
instances instead of requiring a wrong answer for them.

**Structural facts** — an entity has a field of a given type, an enum's set of allowed
values, a function's signature — are mechanically extractable via a tool like
[tree-sitter](https://tree-sitter.github.io/) parsing across languages, and comparing
extracted structural facts across files is enough to catch a large share of the
restatement measured in the case study above (the `Lesson.status` enum showing up
six-to-eight times, for instance, is exactly a structural fact restated across syntaxes).

**Behavioral facts** — "a lesson can only be cancelled while its status is `scheduled` or
`in_progress`," a business rule rather than a type shape — are much harder to extract
mechanically and mostly belong in the uncertain bucket for now. That's a real limitation:
a meaningful share of the case study's ceremony is behavioral-rule restatement (the same
guard condition re-checked at the API layer, the service layer, and sometimes the UI), and
a structural-facts-only measurement would undercount it.

The proposal on the table is a **normalize-semantic-facts** crate: extract semantic facts
from source code, normalize them into one common representation regardless of source
language, and identify when the same normalized fact appears more than once across a
codebase — producing a per-fact restatement count (this specific fact appears N times)
rather than a single global "percentage ceremony" number, since a global average would
flatten exactly the kind of variation the case study surfaced (70–87% ceremony per use
case, but the number moves a lot use-case to use-case).

This is a different tool from the existing **normalize-facts** crate in the
[normalize](/projects/normalize) codebase, which extracts *syntactic* facts — symbols,
imports, call sites — for code-intelligence purposes (navigation, refactoring, dependency
analysis). normalize-semantic-facts would sit a level up: not "where is this symbol used"
but "where is this fact about the domain restated." Nothing beyond the design sketch
exists yet — this is the open next step, not a shipped tool.

## The thesis

Putting the pieces together: the AI Jevons paradox looks unsolvable when the only visible
levers are demand (which recursive subagent spawning makes look unbounded) and supply
(which no buildout can outrun an unbounded demand curve). But the expansion factor between
"what a user asked for" and "what actually gets executed" isn't fixed by demand or supply
— it's set by how much ceremony the substrate forces the agent to generate before it hits
a task small enough to do directly. A substrate that absorbs more of that ceremony
compresses the recursion tree: fewer subagents get spawned per request, less total compute
gets spent, less energy gets drawn, independent of how many requests arrive.

crescent's stated goal — covering the entire surface area of software as vendorable,
already-solved pieces — is a direct bet on this lever. If most of what a typical
application needs is already covered by the substrate, then building "yet another
tutoring-scheduling app" collapses toward pure glue: the actual 10–15k lines of business
logic the case study found underneath its 626k lines, with the rest of the surface already
solved and just composed in. An agent working against a substrate like that hits its base
case almost immediately, because there's very little left that counts as "too complex to
do in one shot."

That's the shape of the bet, not a demonstrated result. The case study is one codebase,
inspected by hand, not a corpus-wide measurement; the "70–87% ceremony" and "160 lines for
a 5-line decision" figures are estimates from that one inspection and would need
normalize-semantic-facts (or something like it) actually built and run at scale to become
more than a plausible-sounding number. fractal, rainbow, and crescent each address a piece
of the boundary-restatement problem but none has been measured end-to-end against a
codebase anywhere near 626k lines, and the persistence-ceremony gap has no answer yet at
all. What can be said with more confidence is the shape of the argument: if ceremony really
is what's driving the expansion factor, then building substrates that eliminate ceremony —
genuinely eliminate it, not relocate it the way ORMs and frameworks and DSLs have — is a
lever on AI's energy consumption that doesn't require betting against demand growth or
racing to outbuild it. Whether that lever is big enough to matter at the scale the Jevons
framing worries about is, honestly, still an open question.
