# Testing Philosophy

A reference for what kinds of tests to write and why. Derived from patterns across the rhi ecosystem — ooxml, wick, rescribe, normalize, crescent.

## What makes a bad test

A test that **parrots behavior** encodes the specific output a specific implementation happened to produce. It passes when the implementation is wrong, fails when the implementation changes for good reasons, and gives you no signal about what property you care about.

```rust
// Bad: parrots the implementation
assert_eq!(add(2, 3), 5); // fine for math, but...
assert_eq!(serialize(doc), "<document><p>hello</p></document>"); // fragile, says nothing
```

The smell: if you wrote the test by running the code and copying the output, it's probably parroting.

## Invariant hierarchy

Ranked from strongest to most implementation-coupled:

### 1. Mathematical identities

Properties that hold by definition, independent of any implementation being correct. Ground truth.

```rust
// If any backend implements cross product wrong, this catches it
// regardless of what the "correct" answer is
assert_close(cross(a, b), -cross(b, a));
assert_close(dot(a, b), dot(b, a));
assert_close(length(a - b), distance(a, b));
```

Strongest because they don't require a reference implementation. If eval and Cranelift both compute the same wrong answer, a parity test passes — but an identity test will catch it.

### 2. Parity across independent implementations

If multiple independent implementations (different backends, different code paths, different languages) all agree, they're very likely correct. The test doesn't need to know the right answer.

```rust
// wick: eval, Lua, Cranelift must agree
let eval_result = eval_backend.run(&expr);
let lua_result = lua_backend.run(&expr);
let jit_result = cranelift_backend.run(&expr);
assert_close(eval_result, lua_result);
assert_close(eval_result, jit_result);

// crescent: pure Lua, FFI, system tiers must produce identical output
// (parity tests assert byte-for-byte equality across tiers)
```

Catches divergence without encoding the expected answer. Combine with identities for full coverage.

### 3. Roundtrip fidelity

Parse → emit → parse produces equivalent output. Catches silent data loss without specifying the exact serialized form.

```rust
// ooxml, rescribe: structural roundtrip
let original = parse(bytes);
let emitted = serialize(&original);
let roundtripped = parse(&emitted);
assert_structurally_equal(&original, &roundtripped);
```

Stronger than snapshot testing because it allows the serialized form to change (whitespace, attribute order, namespace prefixes) while asserting that meaning is preserved. Use `CompareOptions` or equivalent to specify what "equal" means.

**Semantic roundtrip** is stronger still — assert that specific *values* are preserved, not just structure:

```rust
assert_eq!(roundtripped.cell(0, 0).value, original.cell(0, 0).value);
assert_eq!(roundtripped.cell(0, 0).formula, original.cell(0, 0).formula);
```

### 4. Never panic

Any input, no matter how malformed, must produce an error — never a panic or undefined behavior. Fuzz testing is the right tool.

```rust
// fuzz target: the invariant is implicit — no panic
fuzz!(|data: &[u8]| {
    let _ = parse(data); // must not panic
});
```

For richer fuzz targets, generate *semantically valid* inputs and assert stronger invariants:

```rust
// wick: type-aware fuzzer generates well-typed expressions
// then asserts parity, not just "no panic"
fuzz!(|expr: WellTypedExpr| {
    assert_close(eval(&expr), lua_eval(&expr));
});
```

Type-aware generation (using `Arbitrary` impls that respect the type system) is more efficient than raw byte fuzzing — budget goes to semantic coverage, not parse errors.

### 5. Specific output

Only appropriate when the output is the invariant itself — canonicalization, normalization, a defined format. Otherwise, write a stronger test instead.

```rust
// OK: testing a defined canonical form
assert_eq!(normalize_whitespace("  hello   world  "), "hello world");

// OK: testing a spec-defined serialization rule
assert_eq!(serialize_bool(true), "1"); // OOXML requires "1", not "true"
```

## Edge cases

Edge cases are not a separate category — they're inputs that stress a specific invariant. For each invariant, ask: what inputs would break it?

- **Roundtrip**: empty documents, maximum nesting depth, unicode (emoji, ZWJ sequences, RTL, combining chars), null bytes, HTML entities
- **Mathematical identities**: zero vectors, orthogonal vectors, unit vectors, subnormal floats
- **Parity**: expressions that expose floating-point ordering differences between backends
- **Never panic**: truncated inputs, missing fields, invalid lengths, recursive structures

Document edge cases as named fixtures or corpus entries, not inline magic values.

## What's missing in the ecosystem

**Property-based testing** (proptest, quickcheck) is the systematic layer between fuzz and hand-written edge cases. Fuzzing covers "no panic" over random bytes; property tests cover "for all valid inputs, invariant X holds" with shrinking on failure.

Natural fits:
- ooxml/rescribe: "for any valid XML conforming to the schema, roundtrip preserves semantic content"
- wick: "for any well-typed expression, all backends agree" (currently fuzz-only, no shrinking)
- crescent: "for any type that satisfies an interface, tier-downgrade produces identical output"
- normalize: "for any source file, index rebuild is idempotent"

## When to write which kind of test

| Situation | Test type |
|-----------|-----------|
| Multiple implementations of the same thing | Parity |
| Transformation that should preserve meaning | Roundtrip (structural + semantic) |
| Mathematical or logical law | Identity |
| Parser, deserializer, or format reader | Never-panic fuzz |
| Canonicalization or normalization | Specific output |
| Large input space, properties should hold everywhere | Property-based |
| Known-bad inputs from bug reports | Regression (specific output, documented) |
