# ADR-0171: LLM as oracle, not as the agent driving the loop

- Status: Accepted
- Date: 2026-05-29

**Context.** In a multi-agent LLM simulator, the LLM could either drive agent behavior directly (agentic) or be consulted as a generation oracle by deterministic agents.

**Decision.** Agents are profile-driven state machines that consult an LLM only for action/reaction generation. The LLM is an oracle; it does not drive the simulation loop.

**Alternatives rejected.**
- *LLM-driven agents where the model itself drives the loop* — Following the paper, agents are profile-driven state machines; the LLM does not drive the loop (it is consulted as an oracle for generation only).

**Consequences.** The loop is deterministic state-machine control with LLM calls behind an oracle trait (RigOracle); behavior is reproducible/mockable (mock-scripted backend). Agentic-LLM control flow is foreclosed by this design. Mined from: /home/me/git/pterror/matrix-gen/CLAUDE.md (20).
