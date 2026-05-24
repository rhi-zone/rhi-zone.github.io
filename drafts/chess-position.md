# chess-position

Reconstruction from two screenshots of a chess-variant video game.
Board orientation: white at bottom (king on rank 1), black at top (king on rank 8). Standard a-h × 1-8 coords.

## Position before (chess2.png)

White (bright pieces, 13):
- King f1
- Rook e1
- Queen c2 (pink flower accent)
- Knights e5, g6
- Bishops g3, h3
- Pawns c3, e2, e3, f5, f6, h2

Black (gray pieces with dark outlines, 10):
- King d8
- Rooks c8, f7
- Queen c6
- Bishop b5
- Pawns a3, b4, b7, g7, h5

No white rook other than e1 is visible. Black has no knights or bishops other than the b5 bishop.

## Position after white queen's second move (chess.png)

The white queen has moved c2 → e4 (up 2, right 2). She is highlighted with the "!!" just-played effect and pink glow. The black king is highlighted on e8 (just forced there by the rook check), and the black queen is highlighted on c6 as the looming threat.

c6 → e4 is a clean diagonal (c6, d5, e4), so the black queen now sees the white queen.

chess.png is a cropped/zoomed portrait view of the center-upper board. All visible pieces are consistent with the chess2 layout minus the rook's and queen's moves.

## Move sequence

1. **White R e1 → d1, check.** The rook slides from e1 to d1, putting the black king on d8 in check along the d-file. The king has no interposing piece and must move.
2. **Black K d8 → e8** (forced; the only legal escape from the d-file check).
3. **White Q c2 → e4** (up 2, right 2 — the diagonal offer). This is the position captured in chess.png: queen glowing on e4, black queen highlighted as the threat, black king highlighted on e8 where it just fled.
4. **Black Q c6 × e4** (captures the white queen along the c6-e4 diagonal). She killed her lover and stepped directly into the trap.
5. **White lower knight e5 → d6** — the quintuple fork. The knight lands on d6 with the king on e8 rather than d8.
6. Black must respond to the knight fork. White picks off forked pieces one by one. Each time the knight steps off the d-file to capture a forked piece, it uncovers the rook on d1, giving a discovered check on the king along the d-file. The king must move, the knight returns or continues capturing, and the cycle repeats.
7. The second white knight (g6) covers the king's flight squares, tightening the net during this oscillation.

## The fork verified

Knight lands on **d6** (reached from e5; one knight-move). From d6 a standard chess knight attacks these 8 squares:

| Square | Contents |
|--------|----------|
| b5 | **black bishop** |
| b7 | black pawn |
| c4 | empty |
| c8 | **black rook** |
| e4 | **black queen** (just captured the white queen there) |
| e8 | **black king** (forced here by the rook check on move 1) |
| f5 | white pawn (own) |
| f7 | **black rook** |

With the king on e8 the fork hits **bishop (b5), rook (c8), queen (e4), king (e8), rook (f7)** — five black pieces of major value, confirming the quintuple fork including the king. The b7 pawn is also under attack but is not what makes this a quintuple; the five that matter are the four black majors plus the king.

## Discovered check mechanic

The white rook stays on d1 after move 3. The knight on d6 blocks the d-file, so while the knight sits on d6 it shields the king on e8 from rook check along that file. The moment the knight steps off d6 to capture one of the forked pieces, the d-file opens and the rook on d1 gives discovered check on the king. This forces the king to move, buys white another tempo, and the knight can come back or continue capturing. The king oscillates between knight-fork pressure and d-file discovered checks until all forked pieces are taken.

## Capture order and defensive detail

After the knight lands on d6, the forked pieces are taken in this order (clockwise around d6's knight ring):

1. **f7 rook** — captured first
2. **e4 queen** — black queen captured second
3. **b5 bishop** — black bishop captured third
4. **c8 rook** — by this point the black king has been forced back to d8

The black king **cannot capture the white knight** at any of its landing squares: the white bishops cover those squares throughout, so the knight is defended at every stop. The king is forced to oscillate between e8 and d8 but never gets to take the knight.

The oscillation mechanic: when the knight sits on d6 (on the d-file), it blocks the rook's line of sight and the king can rest on d8. The moment the knight steps off d6 to capture, the d-file opens and the rook on d1 delivers a discovered check — the king must move. The second white knight (g6) blocks flight squares to the king's right, so the king bounces back and forth until all forked pieces are gone. The king is on d8 specifically when c8 is captured.

## Ambiguities and guesses

- **Lower knight square: e5 vs f5.** Two zoom passes disagreed; settled on e5 by column alignment with the dark bishop on b5 and queen on c6, and because the d6 fork landing then sits cleanly one knight-move away. If the knight is actually on f5, the fork square would be different (f5 → d6 is also one knight-move, so d6 still works).
- **f6 vs g5 white pawn.** Row 6 clearly has a white pawn next to the g6 knight; I placed it at f6. The right-side pawn cluster on row 5 (white pawn + dark pawn) I placed as f5+h5 with g5 empty, but it could be g5+h5 with f5 empty. This shifts the lower knight by one file if I'm wrong about the knight column too.
- **Rook source square.** The rook reaching d1 on move 1 is presumed to start from e1 (the only white rook visible in chess2.png). The e1 → d1 slide is a single rank-1 move that immediately puts the king in check. If the rook was actually elsewhere, the landing square on the d-file may differ, but the mechanic is the same: a white rook on the d-file forces the king off d8 before the knight forks.
- **Piece counts.** This variant has more pieces per side than classical chess (13 white, 10 black). Doubled bishops on g3/h3 and a doubled e-file pawn structure (e2+e3) are unusual but the rendering is unambiguous.
