# Explorations

**See also:** [Interaction graph](/interaction-graph) (more developed lens), [Why software is hard](/why-software-is-hard), [Affordance opacity](/affordance-opacity), [Prior art](/prior-art) (things that got it right)

Diagnostic lenses and hypotheses that haven't been fully developed. Any of these could graduate to their own page if they prove useful.

---

## Objects, not documents

Notes apps are paper skeuomorphism on the most interactive medium ever created.

Paper affordances: static, linear, you write it, it sits there, you have to remember it exists, organization is manual.

What computers can do: execute, respond, connect, trigger, compute views on the fly, come to you instead of waiting.

Notes apps: "What if paper, but on a $2000 machine?"

**The reframe:** Documents are passive. Objects are active. A stopwatch has state and behavior. A timer triggers at a time. A calendar event comes to you. These aren't "notes" - they're things that *live*.

- Things that live > things that sit
- Comes to you > you go to it
- Active > passive

The right question isn't "how do I organize my notes?" It's "why am I taking notes at all when I have a computer?"

**Corollary:** If your work IS the dopamine reward, you don't need elaborate capture systems. The "I don't use notes apps" thing might not be a personal failure - it might be that you escaped the productivity theater that compensates for attention-hostile environments.

---

## Bridge problems

Why don't good things exist? Most missing tools are **bridge problems** - they require crossing between specializations, and specialists rarely cross.

Example: A composable derive macro system for Rust needs proc macro expertise (notoriously hard), deep understanding of HTTP/WebSocket/gRPC/CLI conventions, API design taste, AND the vision that it should exist. Four disciplines, one person (or a team that actually communicates).

The Venn diagram of "can build it" and "will build it" and "has time to build it" is nearly empty.

**Plus incentives:**
- Open source maintainers burn out
- Companies optimize for features, not polish
- Academia rewards novelty, not accessibility
- "Quality of life" improvements don't get funded

LLMs change the equation somewhat - you don't need to *be* a proc macro expert if you can collaborate with one. But motivation is still the bottleneck: who sees that it should exist, cares enough to start, and follows through past the prototype?

---

## Incumbents aren't competent

The uncomfortable truth: incumbents often won by showing up first, not by being good.

So the bar is actually low - but it *looks* high because:
- Incumbents seem authoritative (they're everywhere)
- Newcomers assume they need to be better to compete
- In reality, "finished and marketed" beats "better but obscure"

**The real filter is:**
1. Showing up
2. Finishing
3. Telling people

Most projects fail at step 2 or 3, not step 1. The competition isn't as scary as it looks - they're just further along the "actually shipped it" axis.

**The graveyard of incomplete implementations:** Many libraries exist for any given problem. How many are complete? How many authors are competent? How many gain traction? Failure modes stack: started but abandoned, complete but wrong, correct but obscure, found but untrusted.

---

## The two tracks

Programming bifurcated:

| Professional | Creative |
|--------------|----------|
| NextJS, k8s, 47 deps | Pico-8, Scratch, Love2D |
| "Work" | "Play" |
| Bootcamps, career content | Game jams, personal projects |
| Complexity as assumed | Constraints as guardrails |

Both exist. The creative track is alive: [PICO-8](https://www.lexaloffle.com/pico-8.php), PuzzleScript, Scratch, p5.js, [Shadertoy](https://www.shadertoy.com/), Sonic Pi, [TidalCycles/Strudel](https://strudel.cc/). See [prior art](/prior-art#creative-constraints) for more.

**The problem: they share the same name.**

Search "programming" → Primeagen, Low Level Learning, career content. The namespace is polluted. Creative track exists but is buried under SEO for bootcamps and career advice.

**We had a word for creative programming:** *Hacker.* MIT hacker culture, tinkering with computers for fun, clever solutions, joy of building. Then it got stolen - media made it mean "criminal," security industry made it mean "penetration testing," bootcamps made it mean "growth hacker" and "hackathon."

1980: "I'm a hacker" = I make things with computers for fun.
2026: "I'm a hacker" = I break into systems / I do 24-hour startup sprints.

We lost the word. And with it, the framing.

---

## State, not architecture

The insight that keeps getting rediscovered: it's not about the architecture. It's about the state.

- Where does state live?
- What can mutate it?
- What depends on it?
- What cascades from an update?

Architecture can be clean. State can be spaghetti. At scale, state spaghetti wins.

**Why every generation reinvents state management:** Redux → MobX → Zustand → Jotai → Signals → Server Components. All trying to make the state graph visible and manageable.

**You CAN lint state statically.** Systems that do it:
- Rust borrow checker (ownership graph is explicit)
- Elm (no side effects, forced MVU)
- Effect systems (track what can happen where)
- State machines / XState (explicit states + transitions)
- Signals (reactive graph is explicit)
- Linear types (state can't be aliased)

The question isn't "can we?" It's **"why isn't this the default?"**

---

## 8-item forcing function

Radial menus are optimal (Fitts's Law + muscle memory), but "they don't scale past 8 items."

Reframe: the 8-item limit isn't a bug, it's a **forcing function**.

- Curate by context (what's actually relevant HERE?)
- Nest if needed (radial → sub-radial)
- Reconsider the feature set (do you need 50 actions?)

Linear menus "scale" to 50 items by making all 50 equally hard to find. That's not scaling, that's hiding the problem.

Radial's limit is honest. "You get 8. Choose wisely." Linear menus let you pretend you're not making choices while actually making everything worse.

---

## Dopamine arbitrage

Hypothesis: "notes don't work for me" isn't always ADHD or neurodivergence. Sometimes it's having found an environment where your brain works well.

The attention economy is designed to exploit dopamine - infinite scroll, notifications, engagement metrics. Most people are stuck in that environment.

Programming is an escape hatch. Hyperfocus is a feature, not a bug. The reward loops align with deep work instead of fighting it.

"Falling out of the attention economy into Visual Studio."

Maybe the question isn't "is my brain different" but "did I accidentally optimize my environment while others are stuck in environments designed to exploit them?"
