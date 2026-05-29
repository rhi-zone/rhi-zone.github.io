# ADR-0053: Tools self-describe config via a single `--schema` convention

- Status: Accepted
- Date: 2026-05-29

**Context.** myenv must know where each tool's config lives, in what format, and how to validate it. The design had to decide whether myenv holds per-tool integration knowledge centrally or whether tools advertise it themselves.

**Decision.** Tools integrate via exactly one convention: `<tool> --schema` returns JSON with config_path, format (toml/json/yaml), and a JSON Schema. myenv fetches this at generate time to validate and write each tool's config. No other integration is needed.

**Alternatives rejected.**
- *myenv maintains centralized per-tool integration knowledge (paths, formats, validation rules)* — The design reduces tool integration to 'one convention' so that 'That's it. Tools read their own config files normally. No special runtime behavior needed.' — centralizing per-tool knowledge in myenv would couple myenv to every tool and was rejected in favor of tools self-describing.

**Consequences.** Any new tool becomes myenv-compatible by adding a --schema response, with no change to myenv. myenv depends on tools being invocable to fetch their schema at generate time. Format support is limited to toml/json/yaml. Mined from: /home/me/git/rhizone/myenv/docs/tool-integration.md (7), /home/me/git/rhizone/myenv/docs/tool-integration.md (11), /home/me/git/rhizone/myenv/docs/design.md (66).
