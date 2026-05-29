# ADR-0118: Asymmetric sentiment evolution: comfort sentiments habituate, discomfort entrenches

- Status: Accepted
- Date: 2026-05-29

**Context.** Sentiments toward users/communities accumulate over time, and the design must decide whether positive and negative feelings decay at the same rate.

**Decision.** Comfort sentiments (warmth, satisfaction, curiosity, enthusiasm) habituate and decay faster (~11% per rest for warmth); discomfort sentiments (irritation, dread) entrench and fade slower (~7% per rest). Adding warmth only cross-reduces irritation by amount x 0.3, never replacing it.

**Alternatives rejected.**
- *Symmetric decay / a good interaction replaces or cancels a bad one* — a good interaction shouldn't erase a bad one; both must accumulate independently to produce ambivalence, which is honest

**Consequences.** Mixed feelings toward a target persist; positive and negative tracks coexist. All sentiment events and rest-processing rules must preserve the asymmetry and cross-reduction-not-replacement model. Mined from: /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (250), /home/me/git/pterror/fuwafuwa/docs/wiki/emotional-layer.md (217).
