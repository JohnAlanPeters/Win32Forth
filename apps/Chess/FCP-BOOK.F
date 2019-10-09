\ Opening book for FCP 1.1

MARKER fcp-book

initBook

\ ruy lopez
line: e2e4 e7e5 g1f3 b8c6 f1b5 a7a6 b5a4 g8f6 e1g1 f8e7 f1e1 b7b5 a4b3 e8g8 c2c3 d7d6 ;
line: e2e4 e7e5 g1f3 b8c6 f1b5 f7f5? d2d3 f5e4 d3e4 g8f6 d1e2 ;
\ two knights
line: e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 f3g5 d7d5 e4d5 c6a5 ;
\ four knights June 15th, 2004 Jos
line: e2e4 e7e5    g1f3 b8c6    b1c3 g8f6    d2d3 f8b4 ;
\ trap
line: e2e4 e7e5 g1f3 f7f6? f3e5 f6e5 d1h5 e8e7 h5e5 e7f7 f1c4 d7d5 c4d5 f7g6 h2h4 ;
\ bishop's opening
line: e2e4 e7e5 f1c4? b8c6 b1c3 f8c5 d2d3 g8f6 f2f4 d7d6 g1f3 c8g4 ;
\ sicilian
line: e2e4 c7c5? g1f3 d7d6 d2d4 c5d4 f3d4 ;
line: e2e4 c7c5 g1f3 b8c6 d2d4 c5d4 f3d4 ;
line: e2e4 c7c5 b1c3 b8c6 g2g3 g7g6 f1g2 f8g7 ;
\ nimzo
line: e2e4 b8c6? d2d4 d7d5 ;
line: e2e4 b8c6 d2d4 e7e6 ;
\ french
line: e2e4 e7e6? d2d4 d7d5 b1c3 g8f6 e4e5 f6d7 g1f3 c7c5 ;
line: e2e4 e7e6 d2d4 d7d5 b1c3 f8b4 e4e5 c7c5 ;
line: e2e4 d7d5? e4e5 c7c5 ;
line: e2e4 d7d5 e4e5 e7e6 g1f3 c7c5 ;
\ caro kann
line: e2e4 c7c6? d2d4 d7d5 e4d5 c6d5 c2c4 ;
\ QGA
line: d2d4? d7d5 c2c4 d5c4 b1c3 e7e5 e2e3 e5d4 e3d4 g8f6 f1c4 f8b4 g1f3 e8g8 ;
line: d2d4 d7d5 c2c4 d5c4 e2e3 b7b5 a2a4 c7c6 a4b5 c6b5 ;
\ QP
line: d2d4 d7d5 g1f3 g8f6 c1g5 e7e6 e2e3 c7c5 ;
\ Blackmar-Diemer Gambit (avoid)
line: d2d4 d7d5 e2e4? c7c6 ;
line: d2d4 d7d5 b1c3 g8f6 g1f3 ;
line: d2d4 d7d5 b1c3 g8f6 e2e4? c7c6 ;

[UNDEFINED] WINBOARD-ENGINE [IF]
here bookRoot @ -  cr . .( bytes used for book)
[THEN]

