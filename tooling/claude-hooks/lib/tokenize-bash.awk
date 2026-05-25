# tokenize-bash.awk
# Reads a decoded (non-JSON-encoded) bash command on stdin.
# Walks char-by-char tracking single-quote / double-quote / backslash state.
# On segment boundaries (;, &&, ||, |, newline) outside quotes, emits a segment
# for allowlist checking.
#
# Allowed leading-token tuples (every non-empty segment must match one):
#   git commit ...
#   git push ...
#   git status ...
#   git log --oneline ...
#
# Prints "OK" if all segments pass, "DENY:<reason>" if any fail.

BEGIN {
    in_single = 0
    in_double = 0
    esc_next  = 0
    segment   = ""
    result    = "OK"
    RS        = ""     # slurp
    FS        = ""
}

function check_segment(seg,    tokens, n, t0, t1, t2) {
    # Strip leading/trailing whitespace
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", seg)
    if (seg == "") return "OK"

    n = split(seg, tokens, /[[:space:]]+/)
    t0 = (n >= 1) ? tokens[1] : ""
    t1 = (n >= 2) ? tokens[2] : ""
    t2 = (n >= 3) ? tokens[3] : ""

    if (t0 == "git") {
        if (t1 == "commit") return "OK"
        if (t1 == "push")   return "OK"
        if (t1 == "status") return "OK"
        if (t1 == "log" && t2 == "--oneline") return "OK"
        return "DENY:git subcommand not allowed: " t1
    }
    return "DENY:command not allowed: " t0
}

function flush_segment(    r) {
    if (result != "OK") return
    r = check_segment(segment)
    if (r != "OK") result = r
    segment = ""
}

{
    n = split($0, chars, "")
    for (i = 1; i <= n; i++) {
        c = chars[i]
        next_c = (i < n) ? chars[i+1] : ""

        if (esc_next) {
            segment = segment c
            esc_next = 0
            continue
        }

        if (in_single) {
            if (c == "'") {
                in_single = 0
            } else {
                segment = segment c
            }
            continue
        }

        if (in_double) {
            if (c == "\\") {
                esc_next = 1
                segment = segment c
            } else if (c == "\"") {
                in_double = 0
            } else {
                segment = segment c
            }
            continue
        }

        # Outside quotes
        if (c == "\\") {
            esc_next = 1
            segment = segment c
            continue
        }
        if (c == "'") {
            in_single = 1
            continue
        }
        if (c == "\"") {
            in_double = 1
            continue
        }
        if (c == ";") {
            flush_segment()
            continue
        }
        if (c == "|") {
            flush_segment()
            # Consume second '|' if present (||)
            if (next_c == "|") i++
            continue
        }
        if (c == "&" && next_c == "&") {
            flush_segment()
            i++
            continue
        }
        if (c == "\n") {
            flush_segment()
            continue
        }
        segment = segment c
    }
    flush_segment()
}

END {
    print result
}
