#!/usr/bin/env bun
// Private-name hash guard.
//
// Compares SHA-256 hashes of normalized substrings of the given text/files
// against tooling/private-name-hashes.txt (committed hashes, no plaintext).
// Unlike the plaintext .git/info/private-names grep in .githooks/pre-commit,
// this works even on machines/clones that never had that local-only file,
// and can be run against DRAFT content before it's ever written to disk.
//
// Usage:
//   tooling/check-private-name-hashes.js <file> [<file> ...]
//   tooling/check-private-name-hashes.js -              # read stdin
//   echo "some draft text" | tooling/check-private-name-hashes.js -
//
// Exit 0: clean. Exit 1: one or more likely matches found (printed to stderr).
// Exit 2: setup problem (missing hash list, bad args).
//
// How matching works (see private-name-hashes.txt for why):
//   1. Split input into lines, then into whitespace-delimited tokens (this
//      keeps hyphens/underscores/plus signs etc. INSIDE a token, since
//      compounds like "acme-widgets" or "acme+corp" are exactly the
//      kind of thing we need to catch).
//   2. For each token, strip everything but [a-z0-9] and lowercase it.
//   3. Slide a window of every length from MIN_LEN to MAX_LEN across that
//      cleaned token and hash each substring. This is what catches "acme"
//      buried inside "acmecorp" (from "acme+corp") even though the two
//      words got glued together by stripping the "+".
//   4. Any hash that lands in the committed hash set is flagged, and the
//      original token + line number are reported so a human/agent can see
//      what to fix.
//
// Known limitation (same class as the "thoth" leak this can't catch): this
// only catches the literal protected string appearing somewhere in the
// text. A paraphrase, description, or codename that never spells out the
// real name will not be flagged. Hashing strengthens the literal-name layer
// only; it is not a substitute for reading the content.

import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const MIN_LEN = 5; // shortest protected name, normalized ("acme1")
const MAX_LEN = 20; // generous ceiling above the longest protected name

const HERE = dirname(fileURLToPath(import.meta.url));
const HASH_LIST_PATH = join(HERE, "private-name-hashes.txt");

function loadHashSet(path) {
  let raw;
  try {
    raw = readFileSync(path, "utf8");
  } catch (err) {
    console.error(`check-private-name-hashes: can't read hash list at ${path}: ${err.message}`);
    process.exit(2);
  }
  const set = new Set();
  for (const line of raw.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const hash = trimmed.split(/\s+/)[0].toLowerCase();
    if (!/^[0-9a-f]{64}$/.test(hash)) continue;
    set.add(hash);
  }
  return set;
}

function sha256(text) {
  return createHash("sha256").update(text, "utf8").digest("hex");
}

function normalizeToken(tok) {
  return tok.toLowerCase().replace(/[^a-z0-9]/g, "");
}

// Returns [{ raw, matchedSubstring }] for a single token.
function checkToken(rawTok, hashSet) {
  const clean = normalizeToken(rawTok);
  const len = clean.length;
  if (len < MIN_LEN) return [];
  const hits = [];
  const hi = Math.min(MAX_LEN, len);
  for (let wlen = MIN_LEN; wlen <= hi; wlen++) {
    for (let start = 0; start + wlen <= len; start++) {
      const sub = clean.slice(start, start + wlen);
      if (hashSet.has(sha256(sub))) {
        hits.push(sub);
      }
    }
  }
  return hits;
}

function checkText(text, hashSet) {
  const findings = []; // { line, raw, matches: [substrings] }
  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const tokens = lines[i].split(/\s+/).filter(Boolean);
    for (const tok of tokens) {
      const hits = checkToken(tok, hashSet);
      if (hits.length > 0) {
        findings.push({ line: i + 1, raw: tok, matches: [...new Set(hits)] });
      }
    }
  }
  return findings;
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.error("usage: check-private-name-hashes.js <file> [<file> ...] | -");
    process.exit(2);
  }

  const hashSet = loadHashSet(HASH_LIST_PATH);
  let anyFindings = false;

  for (const arg of args) {
    let label, text;
    if (arg === "-") {
      label = "<stdin>";
      text = readFileSync(0, "utf8");
    } else {
      label = arg;
      try {
        text = readFileSync(arg, "utf8");
      } catch (err) {
        console.error(`check-private-name-hashes: can't read ${arg}: ${err.message}`);
        process.exit(2);
      }
    }
    const findings = checkText(text, hashSet);
    if (findings.length > 0) {
      anyFindings = true;
      for (const f of findings) {
        console.error(
          `BLOCKED: ${label}:${f.line}: token "${f.raw}" matches a protected-name hash (normalized substring: "${f.matches.join('", "')}")`,
        );
      }
    }
  }

  if (anyFindings) {
    console.error(
      "\nOne or more protected names detected by hash match. Remove/redact before proceeding.",
    );
    process.exit(1);
  }
  process.exit(0);
}

main();
