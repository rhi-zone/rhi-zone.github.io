# ADR-0132: Persistent daemon owns connections; CLI is a thin Unix-socket client

- Status: Accepted
- Date: 2026-05-29

**Context.** The interconnect CLI must talk to platforms with slow/persistent handshakes (Slack Socket Mode, Discord gateway) and receive messages across multiple short-lived tool invocations. The question is whether each CLI call manages its own connection or whether a long-lived process owns them.

**Decision.** A persistent interconnect-daemon process owns long-lived room connections; the short-lived interconnect CLI talks to it over a Unix socket and completes in milliseconds. CLI commands fail immediately if the daemon is not running.

**Alternatives rejected.**
- *Each CLI call connects, authenticates, and tears down its own connection* — Expensive for platforms with slow handshakes (Slack Socket Mode, Discord gateway) and impossible for workflows that need to receive messages across multiple tool invocations.

**Consequences.** Connection lifecycle and per-room read cursors live in the daemon; CLI is stateless and fast but requires the daemon to be running. Enables hook-driven reactive agents (recv --nowait, watch). Couples CLI usability to daemon availability. Mined from: /home/me/git/rhizone/interconnect/docs/daemon.md (3), /home/me/git/rhizone/interconnect/docs/daemon.md (3).
