# ADR-0205: Capability-based design: interfaces never acquire resources by path/name

- Status: Accepted
- Date: 2026-05-29

**Context.** Portals interfaces need to define how applications obtain resources (databases, files, sockets). The choice is between letting the trait itself acquire resources (e.g. open(path)) versus receiving pre-opened handles from the host.

**Decision.** Interfaces never acquire resources by path/name; they receive pre-opened handles from the host. Constructors live in backends, not interfaces. This is mandated as a core principle, not optional, and enforced via a checklist for new interfaces.

**Alternatives rejected.**
- *Interface acquires resource by path/name (e.g. a Database trait with fn open(path) or connect(url))* — Breaks the capability-based security model: the host cannot control what resources the application accesses, it is hard to inject mock capabilities for testing, and the same interface cannot work whether the resource is local, remote, or sandboxed.

**Consequences.** All new interfaces must pass a checklist (no open(path)/connect(url) in the trait; constructors in backends; trait operates on already-acquired capability; mockable without filesystem/network). Constructors are pushed into backend crates. Constrains every future portals interface. Mined from: /home/me/git/rhizone/portals/DESIGN.md (17), /home/me/git/rhizone/portals/DESIGN.md (13).
