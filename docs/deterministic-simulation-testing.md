# Deterministic Simulation Testing

**See also:** [The Decision Stream](/decision-stream) (the second half of this arc — Shannon → decision-stream → crescent), [Vision](/vision), [Explorations](/explorations), [Prior Art](/prior-art), [Ecosystem Design Principles](/decisions/throughlines)

What if you could run a distributed system through every interesting failure scenario — network partition, disk corruption, clock skew, process crash — in a controlled, reproducible, fully deterministic environment, without touching the production binary? And when you found a bug, rewind to exactly the moment it occurred, branch the universe, and try a different schedule?

That's the Antithesis pitch. This is an attempt to understand it, generalize it, and figure out what's actually buildable outside a well-funded startup.

## What Antithesis is

[Antithesis](https://antithesis.com/product/how_antithesis_works/) is a commercial testing platform built on a [deterministic hypervisor](https://antithesis.com/blog/deterministic_hypervisor/) — a fork of FreeBSD's bhyve that forces every nondeterministic event (time reads, interrupts, memory ordering) through a controlled chokepoint. Guest software runs inside this hypervisor with no awareness of it; the test author uploads a container, writes no test harness, and Antithesis's autonomous explorer runs coverage-guided search over the space of all possible interleavings and fault scenarios.

The assertions are [declarative](https://antithesis.com/docs/properties_assertions/assertions/): `always` (this must hold in every execution), `sometimes` (this must be reached at least once), `reachable`. When an assertion fires, Antithesis can [time-travel](https://antithesis.com/blog/multiverse_debugging/) — snapshot the hypervisor state, fork it into divergent futures, replay the exact sequence that triggered the bug. There's no "heisenbugs that disappear in the replay" problem because the replay *is* deterministic.

OSS has fragments of this: [rr](https://rr-project.org/) (record-replay for a single process, no fork into multiverse), CRIU (process snapshot, can't enforce scheduling), [Hermit](https://github.com/facebookexperimental/hermit) (deterministic Linux sandbox, in maintenance mode), [QEMU TCG icount mode](https://www.qemu.org/docs/master/devel/tcg-icount.html) (instruction-counted execution, linear replay only), [Coyote](https://microsoft.github.io/coyote/overview/how/) (.NET-only, IL-level scheduler interception), [shuttle](https://github.com/awslabs/shuttle) (Rust async scheduler, PCT algorithm). The primitive that makes Antithesis special — snapshot the whole system, fork into divergent futures, run them in parallel — is unbuilt in open source.

## The arc

Here's how the idea evolved, in the order it did, because the order is the interesting part.

**First pass: build a determinism engine.** Antithesis's value is the deterministic hypervisor, so build one. But immediately: hardware-assisted virtualization (VMX/SVM) gets you fast guest execution, not determinism. Real silicon exposes a partial free seam — you can trap VM exits, intercept `RDTSC`, but you can't control what order two physical cores actually commit memory writes. Antithesis's solution was a [PMU-based instruction counter](https://antithesis.com/blog/deterministic_hypervisor/) and one physical core per Determinator guest. Getting that instruction counter reliable to 1-in-a-trillion miscounts is a war against hardware errata, microcode quirks, and thermal effects. That's a company, not a project.

**Second pass: software emulation.** If hardware determinism is hard, software emulation is trivially deterministic — you *are* the CPU, you mint every value including time and scheduling, and snapshot/fork is just process fork. [QEMU's TCG](https://www.qemu.org/docs/master/devel/tcg-icount.html) already does record-replay in this mode (mature, production-tested). You could run a RISC-V target under software emulation and own every nondeterministic bit. The emulation penalty is around 10×, but throughput comes from running many universes in parallel, not from making each universe fast. A JIT (like TCG itself) keeps the determinism while recovering some speed.

**Third pass: why bhyve?** Antithesis chose bhyve for a reason that doesn't transfer. They needed throughput for paying customers running large, unmodified production systems — databases, microservices stacks, things that would take 10 minutes to boot under software emulation. The hardware-assisted path gets them within 2× of native for this class of workload. For a personal tool running purpose-built test targets, that rationale inverts. bhyve is hardware-only (no software emulation path), which is the one option that makes determinism hard. The rationale that led Antithesis to bhyve pushes a solo project in the opposite direction.

**Fourth pass: transparently wide.** The real idea is not "one substrate" but "Antithesis at every level that currently has nothing." Unit tests are already somewhat controllable. Integration tests are chaotic. Distributed systems tests are nearly impossible to reproduce. The ambition became: a single engine projected across backends — in-process scheduler interception, WebAssembly rewrite, software emulator, hardware hypervisor — so any codebase at any level could plug in.

**Fifth pass: "Coyote for everything."** [Coyote](https://microsoft.github.io/coyote/concepts/non-determinism/) does something specific that illuminates the whole problem: it auto-rewrites .NET IL to intercept every concurrent operation, then takes over the scheduler. No manual instrumentation. No test harness changes. You run `coyote test your.dll` and it explores the concurrency space automatically. The "magic" is that .NET IL is a *managed seam* — a known, universal intermediate representation that Coyote can pattern-match against. Native code has no equivalent seam; Antithesis needed the hypervisor to manufacture one from scratch. WebAssembly is the candidate universal IL: any language that targets wasm can have its concurrency operations auto-rewritten. "Coyote for everything" and "Antithesis at every level" converge on the same answer.

**Sixth pass: the two-primitive factoring.** By this point there are two distinguishable things:

- P1: Deterministic simulation. Reproducibility, replay, snapshot, fork, multiverse, assertions.
- P2: Transparent / instrumentation-optional simulation. The seam that lets you intercept without modifying the system under test.

They're not the same thing. P1 without P2 is FoundationDB's approach: [co-design the system to run inside a simulation framework](https://apple.github.io/foundationdb/testing.html). P2 without P1 is... something strange. The idea was to treat them as orthogonal axes and aim for the quadrant that has both.

## Adversarial pressure-test, round one

This is where the model got stress-tested. Here is what broke.

**The grid is a diagonal.** P1 (determinism depth) and P2 (invisibility) are not independent axes — they're causally coupled. A managed runtime (JVM, .NET, BEAM, wasm) hands you a control seam for free and gives you language-level determinism for free. Native code without any seam gives you neither. To get *both* deep determinism and full transparency for unmodified native code, you need software emulation or a hardware hypervisor. The "prize cell" (deep + invisible + language-agnostic + open) is precisely the *expensive* cell. You can have cheap or you can have complete; claiming both is the thing that breaks.

**P2 doesn't stand alone.** Control seams (as opposed to observation seams like eBPF, DTrace, Wireshark) always imply a consuming purpose. An observation seam lets you watch. A control seam lets you intervene. Intervention is only meaningful with an objective. P1 is the objective; P2 is the mechanism for reaching the system without refactoring it. P2 is the leash, not the dog. Proposing P2 as a standalone product fails immediately: "a seam with no purpose" is not a thing.

**"One engine projected across seams" leaks.** The kernel/controller split matters more than initially acknowledged. Some things are genuinely level-agnostic: the seed-to-run contract, exact replay from a seed prefix, bisection and shrinking, multiverse bookkeeping (the seed corpus, assertion-fired bitmap, coverage scalar). These belong in a shared kernel. But other things are forced per-level and cannot be abstracted: the granularity of decision points (logical async event vs instruction-count continuum), the exploration strategy (DPOR requires a happens-before relation that doesn't exist at machine level and degrades to blind fuzzing without it), assertion transport, and the economics of snapshotting. The metaphor is not "one engine with swappable backends" — it's "one kernel with per-level controllers that speak a common language."

**Invisible seams and rich assertions are in tension.** Antithesis's `always`/`sometimes`/`reachable` [assertions](https://antithesis.com/docs/best_practices/sometimes_assertions) require linking the Antithesis SDK into the system under test. That's instrumentation. Full transparency (zero changes to the binary) means you get coverage as a signal but no domain-specific assertions. The "invisible" story has a hard ceiling.

What survived: the emulator path is genuinely reachable (costs speed, not years); the kernel+controllers factoring is a healthier design than "one projected engine"; the wasm rewrite as universal seam is real.

## The seam-cost clarification

Before round two, a sharper accounting. Real silicon exposes a *partial* free seam: you can trap VM exits, intercept time reads, observe interrupt delivery. But it does not give you instruction-exact timing, does not give you multicore commit ordering, and does not give you scheduling control. Antithesis manufactured the rest via PMU, gave up SMP anyway (one physical core per guest universe), and still needed a company to make that reliable.

A complete, invisible seam is free in exactly two places:

- A managed runtime: the seam is free, but you're language-locked.
- Software emulation: the seam is free, but you pay ~10× in speed.

Real silicon: fast, but completing the seam costs a company.

Call these three currencies: language-generality, ~10× speed, or a company. A complete invisible seam costs exactly one of them.

## Adversarial pressure-test, round two

The three-currencies model survived for about ten minutes.

**It's a false trichotomy.** The real fourth currency is *completeness of determinism*. Nobody actually ships complete. [Polar Signals literally titled their post "(Mostly) Deterministic Simulation Testing in Go"](https://www.polarsignals.com/blog/posts/2024/05/28/mostly-dst-in-go) — "mostly" is load-bearing. Real tools pay partial amounts of multiple currencies simultaneously: Coyote is language-locked AND incomplete (it misses FFI, native dependencies, system calls). rr is hardware-locked AND incomplete AND linear (no fork into multiverse). The right framing is a tunable dial from "full nondeterminism, no overhead" to "complete determinism, high cost," and most useful tools live somewhere in the middle.

**"~10× and free" understates the emulation cost.** Deterministic SMP emulation forces all guest cores onto a single host thread — [QEMU's icount mode is explicitly incompatible with multi-threaded TCG](https://www.qemu.org/docs/master/devel/multi-thread-tcg.html). So it's not ~10× per universe; it's ~10×N where N is the number of guest cores. And it hits the same SMP wall Antithesis hit: both the emulator and Antithesis's Determinator converge on "one real thread of execution, guest OS scheduling decides interleaving." Multiverse parallelism rescues across-universe throughput (you can run 100 universes on 100 cores), but within-universe guest-SMP speed is gone. Worse: serialized single-thread execution gives you sequential consistency semantics, which structurally cannot expose weak-memory bugs (TSO violations, out-of-order store forwarding, etc.). That's not a tunable limitation — it's the geometry.

**Full determinism may be a purity trap.** This is the one that stung. Determinism does two separable jobs: *exploration* (finding bugs by exhausting the interesting part of a search space) and *reproduction* (re-running the exact execution that found the bug). Neither actually requires a determinized world. [Jepsen](https://jepsen.io) has found the decade's most consequential distributed systems bugs — including [MongoDB dropping writes under network partition](https://jepsen.io/analyses/mongodb-3-4-0-rc3) — with zero determinism: it just injects network faults and checks invariants. rr buys reproduction off-the-shelf for a single process, with no determinized guest OS, just record-and-replay of system calls. The bug-per-engineer-year comparison favors the cheap primitive. Full determinism pays off mainly when you co-design a stateful core explicitly for it (FoundationDB does this: the simulation is in the architecture), not when retrofitted onto existing systems "for everything." The original claim — "build Antithesis at every level" — may be over-ambitious in exactly the way that makes it useless.

## Software emulation, honestly

Since the emulator path keeps appearing as the "accessible solo option," it deserves an honest accounting.

Determinism in software emulation is free in the sense that an ordinary deterministic program minting values is deterministic. You're not fighting physics. Snapshot/fork is just process fork. This is genuinely different from hardware-assisted, where you're overriding physics with instrumentation and hoping the hardware doesn't lie.

The catch is architectural faithfulness versus microarchitectural fidelity. A software emulator correctly implements the ISA semantics — loads and stores behave as specified. But it serializes execution through a single thread, which imposes sequential consistency. Real hardware with multiple cores implements a weaker memory model (x86 is TSO; ARM is much weaker). Programs with data races can behave differently under sequential consistency than under the hardware's actual memory ordering. "Free determinism" means "replaced reality's nondeterminism with a chosen, modeled, replayable version" — and the chosen model may not match the nondeterminism that matters.

This isn't a reason to abandon emulation. It's a reason to be clear about what class of bugs you're targeting. Logical concurrency bugs (two threads accessing shared state in a bad order under any memory model) are in scope. Weak-memory concurrency bugs (a bug that only manifests under TSO relaxed ordering but not SC) are not. That's still a large and important class.

## What survives (humbled but sharper)

The grand "complete deterministic seam at every level, invisibly, for everything" is over-ambitious and partly a purity trap. Here's what remains as valuable and actually buildable:

**A tunable explorer plus cheap reproduction.** Something in the spirit of Jepsen generalized and made reusable — controllable fault injection, schedule perturbation, invariant checking — combined with off-the-shelf reproduction (rr for single-process traces, seed logging for higher-level systems). Deep determinism added per-target only where it demonstrably earns it.

**A level-agnostic kernel plus per-level controllers.** The kernel handles: seed-to-run contract, exact replay from seed prefix, prefix bisection and shrinking, multiverse bookkeeping (seed corpus, assertion bitmap, coverage scalar). Per-level controllers handle: decision-point granularity, exploration strategy, assertion transport, fork economics. A plugin design, not a monolith.

**WebAssembly rewrite as the universal transparency seam.** Any language that compiles to wasm gets transparent interception. This is the realistic path to "Coyote for everything" without mandating a specific managed runtime.

**Software emulation as the deep-determinism option.** ~10×N penalty, sequential consistency, no weak-memory bugs. Reachable for personal use on purpose-built targets.

## Open tensions

These are the unresolved questions the exploration ended on. They're listed as questions, not answers, because that's what they are.

**How partial is partial enough?** The "tunable dial" framing is satisfying conceptually, but where on the dial do you get the best bug-per-cost ratio for a given bug class? Concurrency bugs? Distributed protocol violations? Memory safety? The answer probably differs by class in ways that aren't obvious without empirical data.

**Are exploration and reproduction actually separable as tools?** The argument is that they do different jobs and can be separate. But in practice, Antithesis's multiverse debugging works because exploration and reproduction are tightly integrated — the same substrate that finds the bug is the one that replays it. Separation might mean duplication of effort or a seam that leaks. This is an empirical question.

**Can weak-memory bugs ever be in scope without abandoning determinism?** Software emulation can model a weaker memory order, but then you're no longer deterministic (you're sampling from the space of possible interleavings under the weak model). Hardware with TSO simulation exists (qemu -cpu max with TSO flags) but adds complexity. Is this actually needed for the bug classes that matter?

**Which bug classes justify deep determinism?** FoundationDB's answer is: the ones where you co-designed for it from the start. But for existing systems, is there a class of bug where the setup cost pays off? Long-running timing-dependent distributed consensus bugs might be the answer. But that's a hypothesis.

**Does P2 (the transparency seam) ever stand alone?** The argument that P2 is the leash and P1 is the dog was convincing. But wasm as a universal IL might enable other uses of the seam beyond testing — profiling, tracing, security instrumentation — that don't require the full P1 machinery. This is either a generalization of the tool or scope creep; it's not clear which.

**Which currency do you choose to spend?** The diagonal has a fourth axis now (completeness-of-determinism), and the currencies are language-generality, speed, company-scale effort, and completeness. Most real tools spend partial amounts of multiple currencies. For a solo project in this space, the pragmatic answer is probably: spend completeness (accept "mostly"), spend some speed (accept ~5×), and get language-generality + zero company-scale effort. Whether the result is useful is unknown.

## The live frontier

These questions emerged from the most recent round of thinking and are still actively unresolved.

**What problem does Antithesis actually solve, stated at problem level rather than mechanism level?** "Deterministic hypervisor" is a mechanism. The problem might be: "distributed system bugs that are impossible to reproduce in a reasonable time budget with conventional testing." Or: "the oracle problem in autonomous testing — how do you know a bug is a bug when you didn't specify what 'correct' means?" The mechanism answers are clear; the problem statement is blurry.

**Why does FOSS lack an obvious equivalent?** The open-source survey at [databases.systems](https://databases.systems/posts/open-source-antithesis-p1) found fragments but no equivalent. This isn't obviously a missing algorithm — the algorithms (PCT, DPOR, coverage-guided fuzzing) are all published. The gap is integration, oracle, and UX: Antithesis wraps a complete workflow from "upload a container" to "here is a minimized bug report with a replay." Each OSS fragment requires the user to assemble the workflow, write the oracle, and interpret the output. That's an integration moat, not an algorithmic one.

**How do you find bugs when you don't know where to look?** The oracle problem in autonomous testing: universal oracles (crash = bug, memory safety violation = bug, assertion = bug) catch a defined class. Specified oracles (linearizability, sequential consistency, this invariant) catch more but require domain knowledge. Differential testing (run the same input against two implementations and check they agree) is a partial oracle that requires a reference but no explicit spec. Which oracle strategy is most cost-effective for which class of system?

**Is the cheapest frontier the managed and declarative runtimes?** React/virtual DOM, Redux, CLI tools and TUI frameworks, the BEAM (Erlang/Elixir) with its process model, the JVM — all of these hand you a control seam for free. You can intercept every "interesting" event (state update, message send, I/O call) at the framework level with zero changes to the user's code. This might be "Antithesis for the frontend" — a domain where the seam is already there, the cost is low, and nobody has built the explorer. Is this a more tractable first target than native system software?

**Is a cheaper build matrix a pillar or a tangent?** Combinatorial/pairwise testing (cover all interesting pairs of feature flags / configuration options), software emulation as one node in the matrix, and differential testing as the oracle — assembled into a single build pipeline. Is this a component of a deterministic simulation substrate, or a separate (cheaper) tool that catches most of the same bugs with a fraction of the infrastructure? This question doesn't have an answer yet.

These questions are the live edge of the exploration. None of them are rhetorical. Any of them could be the next thing worth building, the next thing that collapses to a known prior art, or the thing that reframes the whole inquiry again.

## Sources

- Antithesis deterministic hypervisor: https://antithesis.com/blog/deterministic_hypervisor/
- Antithesis multiverse debugging: https://antithesis.com/blog/multiverse_debugging/
- Antithesis: how it works: https://antithesis.com/product/how_antithesis_works/
- Antithesis assertions: https://antithesis.com/docs/properties_assertions/assertions/
- Antithesis sometimes assertions: https://antithesis.com/docs/best_practices/sometimes_assertions
- QEMU record/replay: https://www.qemu.org/docs/master/system/replay.html
- QEMU TCG icount: https://www.qemu.org/docs/master/devel/tcg-icount.html
- QEMU multi-threaded TCG: https://www.qemu.org/docs/master/devel/multi-thread-tcg.html
- Polar Signals "(Mostly) Deterministic Simulation Testing in Go": https://www.polarsignals.com/blog/posts/2024/05/28/mostly-dst-in-go
- Jepsen MongoDB analysis: https://jepsen.io/analyses/mongodb-3-4-0-rc3
- Jepsen: https://jepsen.io
- FoundationDB testing: https://apple.github.io/foundationdb/testing.html
- rr project: https://rr-project.org/
- Coyote non-determinism: https://microsoft.github.io/coyote/concepts/non-determinism/
- Coyote how it works: https://microsoft.github.io/coyote/overview/how/
- Open-source Antithesis survey: https://databases.systems/posts/open-source-antithesis-p1
- shuttle (PCT): https://github.com/awslabs/shuttle
