\ $Id: CTYPE.F,v 1.2 2011/08/19 21:23:24 georgeahubert Exp $

( C-ish ctype macros, rendered in FORTH )
( Placed in the public domain on 8aug96, by Jim Schneider )

\ August 9th, 1996 - 10:35 tjz slight modifications for Win32Forth

INTERNAL

0x01 constant ctype_upper         ( upper case letters )
0x02 constant ctype_lower         ( lower case letters )
0x04 constant ctype_digit         ( digit characters )
0x08 constant ctype_ws            ( white space )
0x10 constant ctype_punct         ( punctuation characters )
0x20 constant ctype_hex           ( hexadecimal digits )
0x40 constant ctype_control       ( control characters )
0x80 constant ctype_graph         ( is printable [ie., "graphic"] )

create ctype_array
0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x048 c, ( 0x00-0x07 )
0x048 c, 0x048 c, 0x048 c, 0x048 c, 0x048 c, 0x048 c, 0x040 c, 0x040 c, ( 0x08-0x0f )
0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, ( 0x10-0x17 )
0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, 0x040 c, ( 0x18-0x1f )
0x088 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, ( 0x20-0x27 )
0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, ( 0x28-0x2f )
0x0a4 c, 0x0a4 c, 0x0a4 c, 0x0a4 c, 0x0a4 c, 0x0a4 c, 0x0a4 c, 0x0a4 c, ( 0x30-0x37 )
0x0a4 c, 0x0a4 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, ( 0x38-0x3f )
0x090 c, 0x0a1 c, 0x0a1 c, 0x0a1 c, 0x0a1 c, 0x0a1 c, 0x0a1 c, 0x081 c, ( 0x40-0x47 )
0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, ( 0x48-0x4f )
0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, 0x081 c, ( 0x50-0x57 )
0x081 c, 0x081 c, 0x081 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, ( 0x58-0x5f )
0x090 c, 0x0a2 c, 0x0a2 c, 0x0a2 c, 0x0a2 c, 0x0a2 c, 0x0a2 c, 0x082 c, ( 0x60-0x67 )
0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, ( 0x68-0x6f )
0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, 0x082 c, ( 0x70-0x77 )
0x082 c, 0x082 c, 0x082 c, 0x090 c, 0x090 c, 0x090 c, 0x090 c, 0x040 c, ( 0x78-0x7f )

: ctype@ ( n -- x )
        dup 0x7f > over 0< or if drop ctype_control else ctype_array + c@ then ;

EXTERNAL

: is-alpha ( n -- flag )
        ctype@ [ ctype_upper ctype_lower or ] literal and 0<> ;

: is-lower ( n -- flag )
        ctype@ ctype_lower and 0<> ;

: is-upper ( n -- flag )
        ctype@ ctype_upper and 0<> ;

: is-digit ( n -- flag )
        ctype@ ctype_digit and 0<> ;

: is-hex ( n -- flag )
        ctype@ ctype_hex and 0<> ;

: is-space ( n -- flag )
        ctype@ ctype_ws and 0<> ;

: is-forth-space ( n -- flag )
        ctype@ [ ctype_ws ctype_control or ] literal and 0<> ;

: is-punct ( n -- flag )
        ctype@ ctype_punct and 0<> ;

: is-alnum ( n -- flag )
        ctype@ [ ctype_upper ctype_lower ctype_digit or or ] literal and 0<> ;

: is-print ( n -- flag )
        ctype@ ctype_graph and 0<> ;

: is-graph ( n -- flag )
        ctype@ [ ctype_punct ctype_upper ctype_lower ctype_digit or or or ]
        literal and 0<> ;

: is-cntrl ( n -- flag )
        ctype@ ctype_control and 0<> ;

: tolower ( n -- n' )
        dup is-upper if [ char a char A - ] literal + then ;

: toupper ( n -- n' )
        dup is-lower if [ char A char a - ] literal + then ;

MODULE

