# Claude Code Hook Schema

Empirical findings for `UserPromptSubmit` hooks. Verified in practice; annotated where behavior may shift across Claude Code versions.

## Input schema

Claude Code writes a JSON object to the hook's stdin on every `UserPromptSubmit` event. Captured from real payloads.

### Fields

| Field | Type | Notes |
|-------|------|-------|
| `session_id` | string (UUID) | Identifies the current session. Stable across turns in the same session. |
| `transcript_path` | string (absolute path) | Path to the `.jsonl` file storing the full session transcript. |
| `cwd` | string (absolute path) | Working directory of the Claude Code process at hook fire time. |
| `permission_mode` | string | Observed value: `"acceptEdits"`. May reflect the active permission level. |
| `hook_event_name` | string | Always `"UserPromptSubmit"` for this hook type. |
| `prompt` | string | The raw user prompt text, including any injected `<task-notification>` XML if the turn is a task callback. |

All six fields were present in every real payload. The first captured entry (`{"test":"sample"}`) was a bare test write and does not represent a real event payload.

### Concrete example (sanitized)

```json
{
  "session_id": "00000000-0000-0000-0000-000000000000",
  "transcript_path": "<REDACTED>",
  "cwd": "/home/me/git/rhizone/github-io",
  "permission_mode": "acceptEdits",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "<REDACTED>"
}
```

### Notes

- `prompt` carries the literal text the user submitted, including task-notification XML injected by the harness for background agent callbacks — the hook fires on those too.
- `transcript_path` encodes the project path in the filename (e.g. `-home-me-git-rhizone-github-io/<session_id>.jsonl`).
- No optional fields observed across the captured sample set; all six appear required.

## Output formats

Hooks write to stdout. Two forms are accepted:

**Plain text** — bare string is injected as additional context. Simplest.

```bash
echo "Reminder: don't act on what you haven't verified."
```

**JSON** — use when combining `additionalContext` with other fields (e.g. `sessionTitle`):

```json
{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "..."}}
```

Top-level `additionalContext` is also accepted per docs, but the nested form is preferred when other fields are present.

## Where output lands (empirical)

Output is wrapped in `<system-reminder>` tags:

```
<system-reminder>UserPromptSubmit hook success: ...</system-reminder>
```

Position: just before the user's prompt in the incoming turn. Not literally end-of-context, but recent enough to act on.

Multiple hook entries in the same array all fire; each gets its own `<system-reminder>` wrapper. These coexist with harness-generated reminders (e.g. EnterPlanMode, TaskCreate).

## Exit codes

| Code | Behavior |
|------|----------|
| `0` | Success. stdout injected as additional context (JSON or plain). |
| `2` | Blocking error. Prompt rejected; stderr shown to user. |
| other non-zero | Non-blocking warning. First line of stderr surfaced. |

## Durability

Per docs, injected `additionalContext` is saved in the session transcript and replayed on `/resume`. Each new turn fires the hook fresh regardless — content is dynamic per turn if needed.

Transcript replay has not been empirically verified here.

## Minimal working example

```bash
#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null  # discard prompt input
echo "Reminder: don't act on what you haven't verified."
```

## Multiple hooks

`hooks.UserPromptSubmit` is an array of entries, each with their own `hooks` sub-array. All fire per turn:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/post-history.sh" }
        ]
      }
    ]
  }
}
```

## Conventions

- Scripts live in `tooling/claude-hooks/<name>.sh` in this repo.
- Per-repo wiring: `.claude/settings.json`.
- Global wiring: `~/.claude/settings.json`.

## Caveats

- Positional ordering relative to other `<system-reminder>` blocks is not strictly documented. Observed behavior may shift across Claude Code versions.
- Transcript replay durability (on `/resume`) has not been empirically verified.
