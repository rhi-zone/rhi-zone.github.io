# Finding Bugs in Existing Code

**See also:** [Deterministic Simulation Testing](/deterministic-simulation-testing) and [The Decision Stream](/decision-stream) (the first arc — antithesis → oracle → lever → Shannon → normalize → "collapse the valid-program space"), normalize's [`inferred-opinionation`](https://github.com/rhi-zone/normalize/blob/master/docs/design/inferred-opinionation.md) (the constructive-leverage destination), [Vision](/vision), [Ecosystem Design Principles](/decisions/throughlines).

This essay captures a distinct second thread of the same session: a concrete attempt to **increase automation for finding CVEs in critical *existing* software** — rsync as the target — with the emphasis on **logic/semantic** bugs, not just memory-safety ones. Where the first arc ends on a forward-looking lever (build code that is analyzable-by-construction), this thread walks the *backward* problem: a binary that already exists, that you cannot restructure, and that you want to find unknown bugs in.

It is recorded with explicit epistemic status per claim — **settled**, **open**, or **retracted** — because the session itself hardened a rule mid-thread: **a confidently-framed wrong guess is context poisoning — strictly negative value.** The thread contains several of the assistant's own over-reaches that were corrected by the user; those are recorded *as* retractions, not laundered into a clean conclusion. The thread was cut off before its central question resolved. It is recorded as open.

## The goal

**(settled)** Increase automation for finding CVEs in critical existing software. Concrete target: **rsync**. Emphasis: **logic/semantic** bugs, not only memory-safety.

The data backs the emphasis. rsync's January-2025 cluster of six CVEs is dominated by *logic*, not corruption:

- **CVE-2024-12086** — arbitrary file leak (the server can read client files outside the transfer set)
- **CVE-2024-12087** — path traversal via `--inc-recursive`
- **CVE-2024-12088** — `--safe-links` bypass
- **CVE-2024-12747** — symlink-race privilege escalation
- **CVE-2024-12084** — heap buffer overflow (memory)
- and a second memory class — an uninitialized-stack-contents leak

So ~4 of 6 are logic (two path-traversal variants, the safe-links bypass, the symlink race), 2 are memory. Vulnerable target is rsync **3.2.7** (Debian 12 / `nixos-23.05`); anything `< 3.4.0` is affected, 3.4.0 is the fix. Logic bugs are exactly the class the research's own honest ceiling says fuzzing-plus-sanitizers *miss*. Centering them is correct.

## The dynamic-linking harness, and the verify-gate

**(settled)** The opening question: is there "something like Antithesis, but as a harness via dynamic linking" — interposing on the dynamic-linker boundary (`LD_PRELOAD`) rather than a hypervisor or full emulator?

A verify-gate (a research subagent, not assertion-from-memory) returned a clear result: **no *unified* "Antithesis-via-dynamic-linking" exists.** What ships is a kit of scattered, per-concern parts:

- **Time / RNG:** `libfaketime` (preload-fakes `time`/`clock_gettime`); `preeny`'s `derand.so`.
- **Fault injection:** `libfiu` (named, probabilistic POSIX-libc fault points) — libc-surface only.
- **Deterministic threading:** DThreads, Kendo, CoreDet — all unmaintained 2009–2013 research prototypes.
- **Deterministic network sim:** **Shadow** is the serious one — `LD_PRELOAD` *plus* a seccomp filter to catch direct syscalls that bypass the PLT, with a simulated clock + seeded RNG + discrete-event network. Actively maintained, but distributed-systems-shaped.
- **Closest in spirit, but not preload:** **madsim / turmoil** (Rust) — strongest determinism of the lot, but via *compile-time* substitution (swap the crate, override symbols at link), so it only works for code written to its interfaces — language-locked.
- **Hermit** (the closest general thing) is ptrace-based, not link-seam, has no network/fault/oracle layer, and is in maintenance mode. **Antithesis** is closed. **"Openthesis"** is vaporware. The databases.systems series names this exact gap as unbuilt.

**(settled)** The `LD_PRELOAD` seam is a genuinely *cheaper, partial* determinism seam. It structurally **cannot** intercept: statically-linked binaries, direct `syscall` instructions, vDSO calls, or raw CPU instructions (`rdtsc`/`cpuid`/`rdrand`). That last is the hard floor — uninterceptable from userspace, the reason Antithesis built a hypervisor.

**(settled — the key reframe)** For **rsync-class *application* software, this hardware leak barely matters.** rsync's nondeterminism is sockets, clock, `getrandom`, scheduling — all library-mediated, all interceptable. The `rdtsc`/`rdrand`/vDSO leak sinks the seam for *kernels / crypto / timing* code, not for a file-sync protocol. So the cheap seam is viable *here* specifically.

## Law-shaped oracles

**(settled)** To find logic bugs *without enumerating attack vectors*, you want a small set of **law-shaped invariants** that any violation trips, whatever its class — Antithesis's `always`/`sometimes` model, but the assertions are security/correctness invariants. The laws identified:

- **Confinement** — no filesystem operation touches anything outside the designated root (after symlink resolution). One invariant covering the whole traversal / symlink / safe-links / leak family.
- **Faithfulness** — rsync is an *optimization* of a trivial operation (delta-transfer instead of full copy), and **the oracle for any optimization is its naïve counterpart**: after `rsync(src → dst)`, `dst` must byte-equal what a trivial full copy (`cp -a`) would produce. This is the differential/metamorphic pattern that found compiler bugs (Csmith `-O2` vs `-O0`) and DB bugs (SQLancer). It catches every failed / corrupt / partial / mistransferred file without enumerating failure modes.
- **Atomicity-under-fault** — under an injected failure, `dst` is faithful *or* cleanly unchanged (catches interrupted-transfer corruption).
- **No-leak / no-priv-escalation** — the peer gets only what it requested; no op yields a file owned/writable by the wrong principal.

**(retracted — flagged as context-poisoning)** The assistant initially framed one law (first confinement, then faithfulness) as the **"primary oracle"** and ranked them. The user rejected this directly: *"'primary oracle' as a term is context poisoning."* There is **no primary oracle.** The laws are **orthogonal predicates over disjoint bug classes, all asserted on every run** — they *compose* (AND them all); none trades against another; cost is additive and trivial. Choosing among things that stack is itself the error. What *is* real (not a hierarchy): how complete each law is (a per-law dial), and what the search injects (the explorer, separate from the oracles).

## The spike: GO (qualified) → retracted

**(settled — mechanism only)** A spike was built and committed at `~/git/pterror/rsync-confinement-shim-spike` (commit `a9e3e70`; the earlier `38fc91f` is the synthetic mechanism-validation step). A single generic confinement invariant — `realpath`-resolve each written path's parent through symlinks, assert it stays under `CONFINE_ROOT` — enforced by a ~230-line `LD_PRELOAD` shim (`confine.c`), caught a real rsync 3.2.7 out-of-root write at the first escaping access, with no rsync/CVE/symlink-specific logic, and no false positive on a clean in-root transfer.

**(settled — the real product is the interposition table)** The two engineering learnings, both "the concept was easy, the grounding is the work":

1. **The interposition surface is not the syscalls you'd name.** The obvious set (`open`/`openat`/`symlinkat`…) caught *nothing*: rsync writes via **`mkstemp`**, which glibc implements by calling `open` *inside* libc — never crossing the PLT — so preloading `open` is inert. The LFS `*64` variants (`open64`/`openat64`) are distinct symbols. The irreducible unit is *every path-creating libc symbol, enumerated from the target's real `nm -D` table*, not from intuition. **The complete, target-validated interposition table is the actual product**; the invariant is trivial.
2. **The ABI false-green trap.** A shim built against a different glibc than the target *silently fails to load* and looks exactly like a successful block — a harness that lies green, worse than none. Caught only by asking "why *didn't* it escape?" Any library here needs a self-check that the shim actually loaded.

**(retracted — the GO was premature; the catch was circular)** The user dismantled the GO on two grounds, and the assistant retracted:

- **Circularity:** the shim asserts "paths stay under root"; the CVE *is* a path-escaping-root bug; the violating input was hand-crafted. The oracle is the negation of the known property, fed the known violation. *"Of course it caught it."* This is **repro, not discovery.** It validated the *interception mechanism* (non-trivial, given the `mkstemp`/`*64` truth) — it did **not** validate that the approach *finds* bugs.
- **"Multi-day means something's missing."** The full CVE-2024-12087 wire attack needs a *patched malicious sender* emitting a crafted `--inc-recursive` file list — which the spike agent called "multi-day." The user read that estimate as a tell: the missing piece is the **drive** — the search that reaches states you *didn't* set up by hand. Without it, the only possible demo is the circular one.

Honest state after this: **mechanism de-risked; discovery entirely unproven.**

## Config-blindness (a correction that matters)

**(settled)** An *absolute* confinement oracle cannot tell a **bug** (escaped when it shouldn't have) from **permitted behavior** (followed an allowed symlink — `rsync --copy-links` does this on purpose; non-chrooted daemons escape the destination by design). It is **configuration-blind**. So a dumb fuzzer emitting `../` and symlinks trips the absolute oracle on nearly every run — and almost all of those trips are rsync correctly obeying its config. **Dense oracle-trips are false positives, not bugs.**

To make it a real bug oracle you need either:
- a **config-aware spec model** (re-implement rsync's intended confinement per flag/mode — real work, *is* the hard part), or
- **differential** (same tree+flags through two impls — rsync vs openrsync, or vulnerable 3.2.7 vs patched 3.4.0): a *disagreement* about what escapes is a bug, because both share the intended spec. This dodges config-modeling — the divergence *is* the oracle, spec-free.

**(open)** This casts doubt on the spike's own "catch": it showed rsync writing out-of-root, but never established that rsync was *supposed* to confine *in that configuration*. It may have caught rsync correctly following a symlink, mislabeled by the config-blind oracle. Checkable (what flags/mode it ran under), but **unestablished as reported.**

## The search critique (user-led)

The user drove a sequence of eliminations against dynamic search. Each is **settled**:

- **Fuzzing is a waste of compute.** Undirected sampling is *unbounded by construction* — nothing makes the next attempt differ from the last. (This is the "same thing, expecting different results" insanity — the literal definition the user invoked.)
- **Coverage-guided fuzzing is flawed because "new coverage" depends on *execution order*.** An input's "new coverage" is not a property of the input — it's a property of *(input, history that ran before it)*. AFL keeps `X` iff it hits a bitmap bucket not yet seen *globally*; if an earlier input incidentally hit `X`'s edges first, `X` is judged boring and **permanently discarded** — even though `X` is unchanged and the *state/combination* it reaches is novel. The fitness is **non-stationary and order-shaped**, not intrinsic. Run it twice with a different seed/order → different corpus → different bugs. (The user named this specifically as the sharper flaw, distinct from edge-vs-path.)
- **Edge coverage ≠ path coverage.** Edge coverage is tractable *because* it's lossy: once every edge is hit there's no signal left, but the bug-bearing path *conjunctions* (A taken **and** later B **and** a specific value) sit unexplored.
- **Path coverage = 2^branches = exponential = a search problem again.** "Just track paths" detonates into the exponential; choosing *which* path to drive toward is the original search problem in a hat. No free lunch.
- **Choosing a target is dumb.** Picking a target branch/state biases the search to failure modes you *already imagined* (known-unknowns) and goes blind to the rest — which is the enumeration the whole thread rejected, sneaking back in as "which target."

The three "X is dumb"s eliminate a *whole family*: random sampling (waste), coverage-guided (order-dependent fitness), chosen-target (biased enumeration) — i.e. **all of dynamic search**, every run-some-inputs-and-score-them method.

## The wall, and the retraction at the wall (recorded carefully)

**(settled — the wall)** Three routes, three theorems:
- dynamic search → waste / order-noise / enumeration-bias;
- full path/state enumeration → exponential;
- *complete* general static analysis of an arbitrary semantic property → **undecidable (Rice's theorem)**. (The user's *"if we manage it we'd be famous"* is the correct instinct — a proven floor, not a missing trick.)

**(retracted — the over-reach)** The assistant then leapt from "complete general static analysis is undecidable" to **"therefore finding is hopeless — give up on existing code and go constructive."** The user rejected it (*"wrong"*), then — after the assistant guessed *again* — *"WHY THE FUCK ARE YOU GUESSING IN THE FIRST PLACE."* The assistant retracted: **undecidable means *incomplete, not impossible*.** Incomplete deciders are the whole game (the decided-vs-don't-know region); abstract interpretation / bounded model checking / LLM-assisted analysis all live there, trading completeness for tractability. The eliminations removed the *dumb* ways to find — they did **not** eliminate finding. *"Give up and build new code instead"* was a flinch to doom, not anything the eliminations supported.

**(open — the unresolved question)** The genuinely-open question the thread was reaching toward and **never settled**: *is there a useful, incomplete, order-independent, non-enumerating finder for **logic** bugs in **existing** code?* It was cut off there. It is recorded as **open**, not resolved. (And: the user repeatedly signalled the answer was simpler/different than every theory the assistant manufactured — six straight "wrong"s — so even the *shape* of the intended answer is not captured here. The thread paused to fix the control surface, then to write this capture, before the point landed.)

## Test-adjacent-code leverage (ROI)

**(settled)** The question "what maximizes ROI/leverage on writing *test-adjacent code*?" produced a frame:

- **Leverage = write-once-catch-many.** Cost fixed, yield unbounded. An example test costs O(1), catches O(1); an invariant costs O(1) and catches every input, every regression, and classes you never named. Maximize `(bugs covered)/(lines written)` by never writing anything whose cost scales with the number of *cases*.
- **The machine is a *product*, not a sum:** `drive × observe × search × adjudicate × reproduce`. Highest *marginal* ROI is whichever factor is currently weakest. Build order sequences finite effort by marginal ROI: deterministic harness first → the two ≈free oracles → coverage feedback → fault injection → structure-aware generator → shrink/replay; reassess after each.
- **Buy vs compose vs irreducibly-yours:**
  - **Buy (mature, near-optimal — reinventing is waste):** *search* (AFL++/libFuzzer, proptest/Hypothesis/QuickCheck with built-in shrinking, libprotobuf-mutator); *reproduce* (shrinkers, `rr`, seed-replay); *universal oracles* (ASan/UBSan/MSan, crash/hang detection).
  - **Compose (the white space):** the **unified deterministic drive + control + observe + fault-inject + replay harness for an arbitrary dynamically-linked binary.** Every *part* ships, scattered and uncomposed; no unified library does "point at a binary → deterministic, drivable, fault-injectable, replayable, with an API to attach your invariants." This is "Antithesis-via-dynamic-linking, packaged" — buildable, not built.
  - **Irreducibly yours (cannot be a library — the whole point):** the **specific oracle/invariant.** No library writes `dst ≡ naïve-copy(src)` or `fs stays in root` for you. The harness's job is to make *writing and running* yours cheap.
- **Observability is the leverage ceiling.** You can only assert invariants over state the harness *exposes* — the "express ≈ extract" echo from the normalize thread. A line spent exposing more state raises the ceiling for *all* oracles at once. This factor is underfunded.

## Honest meta

- **(settled)** There is no cheap, general, *complete* finder for arbitrary existing code. The walls are **theorems** (Rice, no-free-lunch, the exponential), not engineering gaps.
- **(settled)** Existing rsync-class code caps at *partial* methods: fuzzing+sanitizers (memory class), differential where a second impl exists, manual audit, and *incomplete* static analysis — every one trading completeness for tractability, living in the don't-know region.
- **(contested / unresolved)** The "construct-analyzable" attractor (normalize collapsing the valid-program space; crescent making illegal states unrepresentable) is forward leverage that buys the *next* rsync, never *this* one — but this was entangled with the assistant's **give-up over-reach**, which was retracted. The **find-vs-construct tension was left unresolved.** Recorded as a live tension, not a decision: it is *not* settled that one should abandon find-on-existing-code in favor of construct-analyzable.

## Open questions / live frontier

- **Is there a useful, incomplete, order-independent, non-enumerating finder for logic bugs in existing code?** The thread's central question. Unsettled; cut off.
- **What order-independent progress signal could steer a search** — intrinsic reached-state (exponential) vs a chosen target (re-introduces enumeration bias) — *without* falling back into one of the three eliminated families? Open.
- **Did the spike catch a bug, or permitted behavior?** Checkable from the run's flags/mode; unestablished. The config-blindness correction makes this a real doubt, not a footnote.
- **Differential (rsync vs openrsync, or 3.2.7 vs 3.4.0) as the spec-free oracle:** identified as the way to dodge config-modeling; *not yet built or validated* for rsync. No public rsync fuzz harness / OSS-Fuzz entry exists, so even the "buy" tier is unbuilt here.
- **The drive half is entirely unproven.** The spike validated an oracle; a search that pushes the program *into* violating states was never built. For confinement specifically (dense triggers), a non-circular cheap drive was hypothesized — but see config-blindness: dense triggers are dense *false positives* under an absolute oracle.
- **Should this become a repo?** The recommendation oscillated (spike → scaffold; then GO retracted → don't scaffold yet). Unresolved. If it ever does, it is a **rhi-zone** substrate (a test harness, distinct from normalize and crescent), and the name is the user's to choose.

---

*Control-surface note, recorded because it is part of this thread:* mid-session, the repeated guess-after-correction failure prompted a hardening of the anti-guessing rule in `tooling/claude-hooks/post-history.sh` (commit `92a57c3`): **a confidently-framed wrong guess gets treated as established fact, downstream reasoning builds on it, and dislodging it costs multiple turns — so it is strictly negative value, worse than admitting uncertainty.** This capture applies that rule to itself: claims above are marked settled / open / retracted, and no resolution the thread did not reach has been manufactured.
