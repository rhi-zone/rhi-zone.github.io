# ADR-0107: Fixed, non-extensible primitive set; native behavior via capabilities not new ops

- Status: Accepted
- Date: 2026-05-29

**Context.** Plugins need to provide native behavior beyond what Marinada's core can express. The language could let plugins register new ops, or it could keep a closed core and route native behavior through another mechanism.

**Decision.** The compiler knows a fixed, complete primitive set that is the entire language core and is not extensible. Plugins that need native behavior expose it through capabilities (call.method), not by registering new ops. lib:std is just an ordinary module with no special-casing.

**Alternatives rejected.**
- *Let plugins register new ops to extend the language core* — Explicitly rejected — a closed primitive set keeps the language core fixed and complete; native plugin behavior is routed through capabilities instead

**Consequences.** The language core stays stable and analyzable. Standard functions like map/filter/reduce are ordinary Marinada letrec expressions the optimizer sees through, not privileged builtins. Plugin authors cannot grow the language; they grant capabilities. Mined from: /home/me/git/rhizone/dusklight/docs/marinada.md (318).
