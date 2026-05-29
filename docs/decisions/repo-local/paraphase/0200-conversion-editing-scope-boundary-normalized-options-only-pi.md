# ADR-0200: Conversion-vs-editing scope boundary: normalized options only, no pixel/creative ops

- Status: Accepted
- Date: 2026-05-29

**Context.** As paraphase adds resize/crop/watermark, there is risk of scope creep into a general asset editor (reimplementing Photoshop). A clear boundary was needed.

**Decision.** Paraphase handles only transformations expressible as normalized options or property constraints; the test is 'can an agent express the operation without looking at the specific content?'. Pixel-level coordinates, region selection, color grading, compositing, and filters/effects are explicitly out of scope; placement uses semantic presets (corners/center) and gravity, never coordinates.

**Alternatives rejected.**
- *Allow pixel-precise / creative operations (crop_x/crop_y, watermark_x/y, saturation, filters)* — They require creative judgment, content understanding, or tool-specific expertise that an agent cannot express as a content-blind target constraint; users wanting these use ImageMagick/ffmpeg directly

**Consequences.** Clear, agent-friendly boundary prevents feature creep; all operations are normalized one-vocabulary constraints. Cost: 'obvious' features like arbitrary crop and filters are excluded; full editing requires external tools. Bar for future additions: 'would an agent reasonably request this as a target constraint?' Mined from: /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (612), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (614).
