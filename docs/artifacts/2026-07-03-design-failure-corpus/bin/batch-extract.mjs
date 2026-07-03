#!/usr/bin/env bun
// batch-extract.mjs — off-meter corpus extraction sweep via the Anthropic Message
// Batches API at Haiku batch rates. Runs under bun or node (ESM, no bun-only APIs).
//
// Modes:
//   (no flag)  --dry-run   Default. Lists candidate docs + estimated tokens/cost. No network.
//   --submit               Requires ANTHROPIC_API_KEY. Submits one batch request per doc.
//   --collect              Polls the batch, streams results, appends verified-pending
//                          records to ledger/candidate-records.jsonl (checkpointed).
//
// Selection: docs from ledger/index.jsonl with marker_count > 0 whose path has no
// records yet in ledger/events.jsonl (skip already-mined docs).
//
// Miners receive ONLY schema.md (read fresh off disk on every run) plus their own
// document text — never hypotheses.md, never any hypothesis content. This mirrors the
// containment rule in README.md: extraction must stay blind.

import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";
import crypto from "node:crypto";

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------

function repoRoot() {
  const here = path.dirname(new URL(import.meta.url).pathname);
  return execSync("git rev-parse --show-toplevel", { cwd: here, encoding: "utf8" }).trim();
}

const REPO_ROOT = repoRoot();
const ARTIFACT_DIR = path.join(REPO_ROOT, "docs/artifacts/2026-07-03-design-failure-corpus");
const LEDGER_DIR = path.join(ARTIFACT_DIR, "ledger");
const INDEX_PATH = path.join(LEDGER_DIR, "index.jsonl");
const EVENTS_PATH = path.join(LEDGER_DIR, "events.jsonl");
const CANDIDATE_PATH = path.join(LEDGER_DIR, "candidate-records.jsonl");
const BATCH_STATE_PATH = path.join(LEDGER_DIR, "batch-state.json");
const SCHEMA_PATH = path.join(ARTIFACT_DIR, "schema.md");

// ---------------------------------------------------------------------------
// Constants — model, pricing, estimation heuristics
// ---------------------------------------------------------------------------

const MODEL = "claude-haiku-4-5";
const MAX_TOKENS = 8192;

// Batch API is 50% of Haiku list price ($1/$5 per MTok -> $0.50/$2.50 batch).
const BATCH_INPUT_RATE_PER_TOKEN = 0.5 / 1_000_000;
const BATCH_OUTPUT_RATE_PER_TOKEN = 2.5 / 1_000_000;

const BYTES_PER_TOKEN = 3.5;
// Fixed overhead for the extraction instructions + schema.md text + JSON-schema
// output_config that rides on every request, independent of doc size. Measured
// against the current schema.md + instruction text (~1.6KB) plus JSON-schema
// serialization overhead; kept as a named constant so it's easy to re-tune.
const PROMPT_OVERHEAD_TOKENS = 900;
const OUTPUT_TO_INPUT_RATIO = 0.4;

// ---------------------------------------------------------------------------
// JSONL helpers
// ---------------------------------------------------------------------------

function readJsonl(p) {
  if (!fs.existsSync(p)) return [];
  return fs
    .readFileSync(p, "utf8")
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean)
    .map((l) => JSON.parse(l));
}

function appendJsonl(p, obj) {
  fs.appendFileSync(p, JSON.stringify(obj) + "\n");
}

// ---------------------------------------------------------------------------
// Doc selection
// ---------------------------------------------------------------------------

function selectUnminedDocs() {
  const index = readJsonl(INDEX_PATH);
  const events = readJsonl(EVENTS_PATH);
  const minedPaths = new Set(events.map((e) => e.source_path).filter(Boolean));
  return index.filter((d) => d.marker_count > 0 && !minedPaths.has(d.path));
}

function docBytes(doc) {
  const abs = path.join(REPO_ROOT, doc.path);
  try {
    return fs.statSync(abs).size;
  } catch {
    return 0;
  }
}

function estimateDoc(doc) {
  const bytes = docBytes(doc);
  const inputTokens = Math.ceil(bytes / BYTES_PER_TOKEN) + PROMPT_OVERHEAD_TOKENS;
  const outputTokens = Math.ceil(inputTokens * OUTPUT_TO_INPUT_RATIO);
  return { bytes, inputTokens, outputTokens };
}

// ---------------------------------------------------------------------------
// Prompt construction — blind extraction, schema.md mirrored verbatim
// ---------------------------------------------------------------------------

function lineNumberedText(text) {
  return text
    .split("\n")
    .map((line, i) => `${i + 1}\t${line}`)
    .join("\n");
}

function extractionInstructions() {
  return [
    "You are performing BLIND event extraction for a design-failure evidence corpus.",
    "",
    "Your job is descriptive-only: read the document below and emit event records",
    "for anything matching the neutral event_type vocabulary in the schema that",
    "follows. You are not told, and must not guess at, any hypothesis, theory, or",
    "pattern this corpus might be used to support. Do not interpret, editorialize,",
    "summarize intent, or draw conclusions. Extract only what is verbatim stated.",
    "",
    "Rules:",
    "- Every record's `quote` field must be an exact verbatim substring of the",
    "  document text below (copy it character-for-character; do not paraphrase,",
    "  and do not splice ellipses in a way that changes meaning).",
    "- `source.lines` must be the [start, end] line numbers (from the numbered",
    "  text below) that the quote came from.",
    "- Use only the `event_type` values enumerated in the schema. If an event",
    "  does not clearly fit one of them, use `other_notable`.",
    "- Emit one record per distinct event. Do not merge unrelated events into",
    "  one record, and do not emit a record for content that is not a",
    "  descriptive event (skip prose that is not reporting something that",
    "  happened).",
    "- If the document contains no qualifying events, return an empty `records`",
    "  array. Do not fabricate events to have something to report.",
    "- `id` must be a stable string unique within your output (e.g. a slug of",
    "  the doc path plus a sequence number).",
    "- `notes` is for extractor context only (e.g. surrounding disambiguation) —",
    "  still descriptive, never a conclusion.",
    "",
    "The full event record schema and the neutral event_type vocabulary follow",
    "verbatim. Mirror it exactly — do not invent fields or event types it does",
    "not define.",
  ].join("\n");
}

function buildUserMessage(doc, docText) {
  const schemaText = fs.readFileSync(SCHEMA_PATH, "utf8");
  const numbered = lineNumberedText(docText);
  return [
    extractionInstructions(),
    "",
    "--- SCHEMA (schema.md, verbatim) ---",
    schemaText,
    "--- END SCHEMA ---",
    "",
    `DOCUMENT PATH: ${doc.path}`,
    "",
    "--- DOCUMENT TEXT (line-numbered) ---",
    numbered,
    "--- END DOCUMENT TEXT ---",
  ].join("\n");
}

const RECORD_JSON_SCHEMA = {
  type: "object",
  properties: {
    records: {
      type: "array",
      items: {
        type: "object",
        properties: {
          id: { type: "string" },
          event_type: {
            type: "string",
            enum: [
              "decision_made",
              "decision_reversed",
              "correction_issued",
              "correction_repeated",
              "revert",
              "oscillation",
              "abandonment",
              "completion_success",
              "cost_note",
              "other_notable",
            ],
          },
          quote: { type: "string" },
          source: {
            type: "object",
            properties: {
              path: { type: "string" },
              lines: { type: "array", items: { type: "integer" } },
            },
            required: ["path", "lines"],
            additionalProperties: false,
          },
          session_id: { anyOf: [{ type: "string" }, { type: "null" }] },
          date: { type: "string" },
          project: { type: "string" },
          notes: { type: "string" },
        },
        required: ["id", "event_type", "quote", "source", "date", "project", "notes"],
        additionalProperties: false,
      },
    },
  },
  required: ["records"],
  additionalProperties: false,
};

// ---------------------------------------------------------------------------
// Dry run
// ---------------------------------------------------------------------------

function runDryRun() {
  const docs = selectUnminedDocs();
  if (docs.length === 0) {
    console.log("No candidate docs: every marker_count>0 doc already has events, or index is empty.");
    return;
  }

  let totalInput = 0;
  let totalOutput = 0;
  console.log(`Candidate docs (marker_count > 0, not yet mined): ${docs.length}\n`);
  for (const doc of docs) {
    const { bytes, inputTokens, outputTokens } = estimateDoc(doc);
    totalInput += inputTokens;
    totalOutput += outputTokens;
    console.log(
      `  ${doc.path}  (${bytes}B, markers=${doc.marker_count})  ~in=${inputTokens} ~out=${outputTokens}`,
    );
  }

  const cost = totalInput * BATCH_INPUT_RATE_PER_TOKEN + totalOutput * BATCH_OUTPUT_RATE_PER_TOKEN;

  console.log("");
  console.log(`Estimated total input tokens:  ${totalInput.toLocaleString()}`);
  console.log(`Estimated total output tokens: ${totalOutput.toLocaleString()}`);
  console.log(
    `Estimated cost @ Haiku batch rates ($0.50/$2.50 per MTok): $${cost.toFixed(4)}`,
  );
  console.log("");
  console.log("This is a dry run — no network calls were made. Use --submit to run the batch.");
}

// ---------------------------------------------------------------------------
// API access — SDK if importable, else raw fetch
// ---------------------------------------------------------------------------

function requireApiKey() {
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) {
    console.error("ANTHROPIC_API_KEY is required for --submit / --collect.");
    process.exit(1);
  }
  return key;
}

async function loadSdkClient() {
  try {
    const mod = await import("@anthropic-ai/sdk");
    const Anthropic = mod.default ?? mod.Anthropic;
    return new Anthropic();
  } catch {
    return null;
  }
}

async function fetchJson(url, apiKey, init = {}) {
  const res = await fetch(url, {
    ...init,
    headers: {
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
      ...(init.headers ?? {}),
    },
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status} ${res.statusText}: ${body}`);
  }
  return res.json();
}

// Deterministic, API-safe custom_id (Batches custom_id is restricted to
// [a-zA-Z0-9_-]{1,64}) derived from the doc path. The path itself is stored
// in batch-state.json's idMap so --collect can recover it.
function customIdFor(docPath) {
  return "d-" + crypto.createHash("sha256").update(docPath).digest("hex").slice(0, 40);
}

// ---------------------------------------------------------------------------
// Submit
// ---------------------------------------------------------------------------

async function runSubmit() {
  const apiKey = requireApiKey();
  const docs = selectUnminedDocs();
  if (docs.length === 0) {
    console.log("No candidate docs to submit.");
    return;
  }

  const idMap = {};
  const requests = docs.map((doc) => {
    const abs = path.join(REPO_ROOT, doc.path);
    const docText = fs.readFileSync(abs, "utf8");
    const customId = customIdFor(doc.path);
    idMap[customId] = doc.path;
    return {
      custom_id: customId,
      params: {
        model: MODEL,
        max_tokens: MAX_TOKENS,
        output_config: {
          format: { type: "json_schema", schema: RECORD_JSON_SCHEMA },
        },
        messages: [{ role: "user", content: buildUserMessage(doc, docText) }],
      },
    };
  });

  console.log(`Submitting batch of ${requests.length} requests (model=${MODEL})...`);

  const sdk = await loadSdkClient();
  let batch;
  if (sdk) {
    batch = await sdk.messages.batches.create({ requests });
  } else {
    batch = await fetchJson("https://api.anthropic.com/v1/messages/batches", apiKey, {
      method: "POST",
      body: JSON.stringify({ requests }),
    });
  }

  const state = {
    batchId: batch.id,
    model: MODEL,
    submittedAt: new Date().toISOString(),
    docCount: requests.length,
    idMap,
  };
  fs.mkdirSync(LEDGER_DIR, { recursive: true });
  fs.writeFileSync(BATCH_STATE_PATH, JSON.stringify(state, null, 2) + "\n");

  console.log(`Batch submitted: ${batch.id}`);
  console.log(`Saved batch state to ${path.relative(REPO_ROOT, BATCH_STATE_PATH)}`);
}

// ---------------------------------------------------------------------------
// Collect
// ---------------------------------------------------------------------------

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function retrieveBatch(sdk, apiKey, batchId) {
  if (sdk) return sdk.messages.batches.retrieve(batchId);
  return fetchJson(`https://api.anthropic.com/v1/messages/batches/${batchId}`, apiKey);
}

// Async generator over batch results, keyed by custom_id, regardless of arrival
// order. Uses the SDK's async iterator when available; otherwise streams the
// results endpoint (JSONL) line-by-line via fetch so large result sets don't
// have to be buffered in full before processing starts.
async function* iterateResults(sdk, apiKey, batchId) {
  if (sdk) {
    for await (const result of await sdk.messages.batches.results(batchId)) {
      yield result;
    }
    return;
  }

  const res = await fetch(`https://api.anthropic.com/v1/messages/batches/${batchId}/results`, {
    headers: { "x-api-key": apiKey, "anthropic-version": "2023-06-01" },
  });
  if (!res.ok || !res.body) {
    const body = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status} fetching results: ${body}`);
  }

  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });
    let idx;
    while ((idx = buffer.indexOf("\n")) >= 0) {
      const line = buffer.slice(0, idx).trim();
      buffer = buffer.slice(idx + 1);
      if (line) yield JSON.parse(line);
    }
  }
  buffer += decoder.decode();
  const tail = buffer.trim();
  if (tail) yield JSON.parse(tail);
}

async function runCollect() {
  const apiKey = requireApiKey();
  if (!fs.existsSync(BATCH_STATE_PATH)) {
    console.error(`No batch state at ${BATCH_STATE_PATH} — run --submit first.`);
    process.exit(1);
  }
  const state = JSON.parse(fs.readFileSync(BATCH_STATE_PATH, "utf8"));
  const sdk = await loadSdkClient();

  console.log(`Polling batch ${state.batchId}...`);
  let batch = await retrieveBatch(sdk, apiKey, state.batchId);
  while (batch.processing_status !== "ended") {
    console.log(`  status=${batch.processing_status} — waiting 30s`);
    await sleep(30_000);
    batch = await retrieveBatch(sdk, apiKey, state.batchId);
  }
  console.log("Batch ended. Streaming results...");

  fs.mkdirSync(LEDGER_DIR, { recursive: true });

  let succeeded = 0;
  let failed = 0;
  let recordCount = 0;

  for await (const result of iterateResults(sdk, apiKey, state.batchId)) {
    const docPath = state.idMap[result.custom_id] ?? result.custom_id;
    const resultType = result.result?.type;

    if (resultType === "succeeded") {
      const message = result.result.message;
      const textBlock = (message.content ?? []).find((b) => b.type === "text");
      let parsed;
      try {
        parsed = textBlock ? JSON.parse(textBlock.text) : null;
      } catch (err) {
        appendJsonl(CANDIDATE_PATH, {
          source_path: docPath,
          custom_id: result.custom_id,
          failure: "parse_error",
          error: String(err),
        });
        failed++;
        continue;
      }

      const records = parsed?.records ?? [];
      for (const rec of records) {
        appendJsonl(CANDIDATE_PATH, {
          ...rec,
          source_path: docPath,
          extraction: { model: MODEL, run: "batch-1" },
          verification: { status: "unverified" },
        });
        recordCount++;
      }
      succeeded++;
    } else {
      // errored / canceled / expired — record explicitly, never silently skip.
      appendJsonl(CANDIDATE_PATH, {
        source_path: docPath,
        custom_id: result.custom_id,
        failure: resultType ?? "unknown",
        error: result.result?.error ?? null,
      });
      failed++;
    }
  }

  console.log(`Done. succeeded=${succeeded} failed=${failed} records_appended=${recordCount}`);
  console.log(`Appended to ${path.relative(REPO_ROOT, CANDIDATE_PATH)}`);
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

async function main() {
  const args = process.argv.slice(2);
  if (args.includes("--submit")) {
    await runSubmit();
  } else if (args.includes("--collect")) {
    await runCollect();
  } else {
    // --dry-run is the default; accept it explicitly too.
    runDryRun();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
