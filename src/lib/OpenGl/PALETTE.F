anew palette.f   \ April 27th, 2002 - 15:35 for Win32Forth
needs struct.f

struct{ \ tagLOGPALETTE
    WORD palVersion
    WORD palNumEntries
\   PALETTEENTRY palPalEntry[n] first: sizeof LOGPALETTE-HEADER +
 }struct tagLOGPALETTE \ sizeof LOGPALETTE-HEADER

: logpalette:  \ compiletime:  ( <name> - )
   create 0x0300 w, 256  dup w, 4 * allot
   does>  ;     \ runtime:     ( - PALETTEENTRY )

\ Index   Red  Green  Blue   Colour
\ -----------------------------------
: start-color-table ( - 30-starting-colors)

(  9 )   166    202   240   \ pastel blue
(  8 )   192    220   192   \ pastel green
(  7 )   192    192   192   \ light grey
(  6 )     0    128   128   \ dark cyan
(  5 )   128      0   128   \ dark magenta (lavender)
(  4 )     0      0   128   \ dark blue
(  3 )   128    128     0   \ brown (dark yellow/pea green)
(  2 )     0    128     0   \ dark green
(  1 )   128      0     0   \ dark red
(  0 )     0      0     0   \ black
 ;

: end-color-table ( - 30-colors-end )
( 255 )   255    255   255   \ white
( 254 )     0    255   255   \ cyan
( 253 )   255      0   255   \ magenta
( 252 )     0      0   255   \ bright blue
( 251 )   255    255     0   \ yellow
( 250 )     0    255     0   \ bright green
( 249 )   255      0     0   \ bright red
( 248 )   128    128   128   \ dark grey
( 247 )   160    160   164   \ medium grey
( 246 )   255    251   240   \ soft white
  ;

: add-system-colors ( flag adr-bmiColors #colors - )
   LOCALS| #colors bmiColors flag |
    start-color-table 10 sizeof RGBQUAD * 0
      do      i  bmiColors rgbBlue       + c!
              i  bmiColors rgbGreen      + c!
              i  bmiColors rgbRed        + c!
         flag i  bmiColors rgbReserved   + c!
     4 +loop
    end-color-table #colors sizeof RGBQUAD * dup 10 sizeof RGBQUAD * -
      do      i  bmiColors rgbBlue       + c!
              i  bmiColors rgbGreen      + c!
              i  bmiColors rgbRed        + c!
         flag i  bmiColors rgbReserved   + c!
     4 +loop
 ;
0e fvalue _fred
0e fvalue _fgreen
0 value  _blue
0 value  _flag

255e 1 3 lshift 1 - s>f f/ fconstant 3bits-shift
255  1 2 lshift 1 -      / constant  2bits-shift

: 332palette ( adr-color-table flag - )
   swap 0 to _blue 0e fto _fred  0e fto _fgreen
    4 0 do
      8 0 do
        8 0 do
\               _fred fround f>s . _fgreen fround f>s . _blue .
                _fred   fround f>s over rgbRed      c!
                _fgreen fround f>s over rgbGreen    c!
                _blue              over rgbBlue     c!
                                   2dup rgbReserved c! sizeof RGBQUAD  +
                _fred   3bits-shift f+ fto _fred
            loop  0e fto _fred
                  _fgreen 3bits-shift f+ fto _fgreen
          loop  0e fto _fgreen
                2bits-shift +to _blue
        loop  2drop
  ;

\ use:
\ logpalette: logpalette1
\ logpalette1 sizeof LOGPALETTE-HEADER + 0 332palette
\ 0 logpalette1 sizeof LOGPALETTE-HEADER + 256 add-system-colors

: activate-palette ( hpalette hdc - )
     >r false  swap r@ call SelectPalette 0= abort" SelectPalette failed"
     r> call RealizePalette GDI_ERROR = abort" RealizePalette failed"
   ;

32 value _limit-bpps

: max-bits-per-pixel  ( hdc - bpps )
    BITSPIXEL swap call GetDeviceCaps  _limit-bpps min ;

create &InfoRect  4 cells allot    ( - &InfoRect )
&InfoRect 4 cells erase
&InfoRect constant window_x
&InfoRect 1 cells+ constant window_y
&InfoRect 2 cells+ constant width
&InfoRect 3 cells+ constant height

\s


