\ $Id: EscapedStrings.f,v 1.3 2011/08/18 15:34:40 georgeahubert Exp $

\ RfD: Escaped Strings S\"
\ 19 July 2007, Stephen Pelc
\
\ 20070719 Modified ambiguous condition
\           Added ambiguous conditions to definition of S\"
\           Added test cases
\           Corrected Reference Implementation
\ 20070712 Redrafted non-normative portions.
\ 20060822 Updated solution section.
\ 20060821 First draft.
\
\
\ Rationale
\ =========
\
\
\ Problem
\ -------
\ The word S" 6.1.2165 is the primary word for generating strings.
\ In more complex applications, it suffers from several deficiencies:
\ 1) the S" string can only contain printable characters,
\ 2) the S" string cannot contain the '"' character,
\ 3) the S" string cannot be used with wide characters as discussed
\     in the Forth 200x internationalisation and XCHAR proposals.
\
\
\ Current practice
\ ----------------
\ At least SwiftForth, gForth and VFX Forth support S\" with very
\ similar operations. S\" behaves like S", but uses the '\' character
\ as an escape character for the entry of characters that cannot be
\ used with S".
\
\
\ This technique is widespread in languages other than Forth.
\
\
\ It has benefit in areas such as
\
\
\ 1) construction of multiline strings for display by operating
\     system services,
\ 2) construction of HTTP headers,
\ 3) generation of GSM modem and Telnet control strings.
\
\
\ The majority of current Forth systems contain code, either in the
\ kernel or in application code, that assumes char=byte=au. To avoid
\ breaking existing code, we have to live with this practice.
\
\
\ The following list describes what is currently available in the
\ surveyed Forth systems that support escaped strings.
\
\
\ \a      BEL (alert, ASCII 7)
\ \b      BS (backspace, ASCII 8)
\ \e      ESC (not in C99, ASCII 27)
\ \f      FF (form feed, ASCII 12)
\ \l      LF (ASCII 10)
\ \m      CR/LF pair (ASCII 13, 10) - for HTML etc.
\ \n      newline - CRLF for Windows/DOS, LF for Unices
\ \q      double-quote (ASCII 34)
\ \r      CR (ASCII 13)
\ \t      HT (tab, ASCII 9)
\ \v      VT (ASCII 11)
\ \z      NUL (ASCII 0)
\ \"      "
\ \[0-7]+ Octal numerical character value, finishes at the
\          first non-octal character
\ \x[0-9a-f]+  Hex numerical character value, finishes at the
\          first non-hex character
\ \\      backslash itself
\       before any other character represents that character
\
\
\ Considerations
\ --------------
\ We are trying to integrate several issues:
\
\
\ 1) no/least code breakage
\ 2) minimal standards changes
\ 3) variable width character sets
\ 4) small system functionality
\
\
\ Item 1) is about the common char=byte=au assumption.
\ Item 2) includes the use of COUNT to step through memory and the
\          impact of char in the file word sets.
\ Item 3) has to rationalise a fixed width serial/comms channel
\          with 1..4 byte characters, e.g. UTF-8
\ Item 4) should enable 16 bit systems to handle UTF-8 and UTF-32.
\
\
\ The basis of the current approach is to use the terminology of
\ primitive characters and extended characters. A primitive character
\ (called a pchar here) is a fixed-width unit handled by EMIT and
\ friends as well as C@, C! and friends. A pchar corresponds to the
\ current ANS definition of a character. Characters that may be
\ wider than a pchar are called "extended characters" or xchars.
\ The xchars are an integer multiple of pchars. An xchar consists
\ of one or more primitive characters and represents the encoding
\ for a "display unit". A string is represented by caddr/len
\ in terms of primitive characters.
\
\
\ The consequences of this are:
\
\
\ 1) No existing code is broken.
\ 2) Most systems have only one keyboard and only one screen/display
\     unit, but may have several additional comms channels. The
\     impact of a keyboard driver having to convert Chinese or Russian
\     characters into a (say) UTF-8 sequence is minimal compared to
\     handling the key stroke sequences. Similarly on display.
\ 3) Comms channels and files work as expected.
\ 4) 16-bit embedded systems can handle all character widths as they
\     are described as strings.
\ 5) No conflict arises with the XCHARs proposal.
\
\
\ Multiple encodings can be handled if they share a common primitive
\ character size - nearly all encodings are described in terms of
\ octets, e.g. TCP/IP, UTF-8, UTF-16, UTF-32, ...
\
\
\ Approach
\ --------
\ This proposal does not require systems to handle xchars, and does
\ not disenfranchise those that do.
\
\
\ S\" is used like S" but treats the '\' character specially. One
\ or more characters after the  '\' indicate what is substituted.
\ The following three of these cause parsing and readability
\ problems. As far as I know, requiring characters to come in
\ 8 bit units will not upset any systems. Systems with characters
\ less than 7 bits are non-compliant, and I know of no 7 bit CPUs.
\ All current systems use character units of 8 bits or more.
\
\
\ Of observed current practice, the following two are problematic.
\
\
\ \[0-7]+ Octal numerical character value, finishes at the
\          first non-octal character
\
\
\ \x[0-9a-f]+  Hex numerical character value, finishes at the
\          first non-hex character
\
\
\ Why do we need two representations, both of variable length?
\ This proposal selects the hexadecimal representation, requiring
\ two hex digits. A consequence of this is that xchars must be
\ represented as a sequence of pchars. Although initially seen as a
\ problem by some people, it avoids at least the following problems:
\
\
\ 1) Endian issues when transmitting an xchar, e.g. big-endian host
\     to little-endian comms channel
\
\
\ 2) Issues when an xchar is larger than a cell, e.g. UTF-32 on
\     a 16 bit system.
\
\
\ 3) Does not have problems in distinguishing the end of the
\     number from a following character such as '0' or 'A'.
\
\
\ At least one system (Gforth) already supports UTF-8 as its native
\ character set, and one system (JaxForth) used UTF-16. These systems
\ are not affected.
\
\
\       before any other character represents that character
\
\
\ This is an unnecessary general case, and so is not mandated. By
\ making it an ambiguous condition, we do not disenfranchise
\ existing implementations, and leave the way open for future
\ extensions.
\
\
\ Proposal
\ ========
\
\
\ 6.2.xxxx S\"
\ s-slash-quote CORE EXT
\
\
\ Interpretation:
\     Interpretation semantics for this word are undefined.
\
\
\ Compilation: ( "ccc<quote>" -- )
\     Parse ccc delimited by " (double-quote), using the translation
\     rules below. Append the run-time semantics given below to the
\     current definition.
\
\
\ Translation rules:
\     Characters are processed one at a time and appended to the
\     compiled string. If the character is a '\' character it is
\     processed by parsing and substituting one or more characters
\     as follows:
\
\
\     \a      BEL (alert, ASCII 7)
\     \b      BS (backspace, ASCII 8)
\     \e      ESC (not in C99, ASCII 27)
\     \f      FF (form feed, ASCII 12)
\     \l      LF (ASCII 10)
\     \m      CR/LF pair (ASCII 13, 10)
\     \n      implementation dependent newline, e.g. CR/LF, LF, or LF/CR.
\     \q      double-quote (ASCII 34)
\     \r      CR (ASCII 13)
\     \t      HT (tab, ASCII 9)
\     \v      VT (ASCII 11)
\     \z      NUL (ASCII 0)
\     \"      "
\     \xAB    A and B are Hexadecimal numerical characters. The resulting
\             character is the conversion of these two characters. An
\             ambiguous conditions exists if \x is not followed by two
\             hexadecimal characters.
\     \\      backslash itself
\     \       An ambiguous condition exists if a \ is placed before any
\             character, other than those defined in 6.2.xxx s\".
\
\
\ Run-time: ( -- c-addr u )
\     Return c-addr and u describing a string consisting of the translation
\     of the characters ccc. A program shall not alter the returned string.
\
\
\ See: 3.4.1 Parsing, 6.2.0855 C" , 11.6.1.2165 S" , A.6.1.2165 S"
\
\
\ Labelling
\ =========
\ Ambiguous conditions occur:
\    If \x is not followed by two hexadecimal characters.
\    If a \ is placed before any character, other than those defined
\    in 6.2.xxx s\".
\
\
\ Reference Implementation
\ ========================
\ Taken from the VFX Forth source tree and modified to remove most
\ implementation dependencies. Assumes the use of the # and $ numeric
\ prefixes to indicate decimal and hexadecimal respectively.
\
\
\ Another implementation (with some deviations) can be found at
\ http://b2.complang.tuwien.ac.at/cgi-bin/viewcvs.cgi/*checkout*/gforth...

\ Reference Implementation modified for Win32Forth by Dirk Busch

anew -EscapedStrings.f

INTERNAL

IN-SYSTEM

: $,            \ caddr len --
\ *G Lay the string into the dictionary at *\fo{HERE}, reserve
\ ** space for it and *\fo{ALIGN} the dictionary.
   dup >r
   here place
   r> 1 chars + allot

\ All string literals are stored as null terminated, counted strings.
\ The count doesn't include the null byte.
   0 c,

   align
;

: addchar       \ char string --
\ *G Add the character to the end of the counted string.
   tuck count + c!
   1 swap c+!
;

: append        \ c-addr u $dest --
\ *G Add the string described by C-ADDR U to the counted string at
\ ** $DEST. The strings must not overlap.
   >r
   tuck  r@ count +  swap cmove          \ add source to end
   r> c+!                                \ add length to count
;

: extract2H     \ caddr len -- caddr' len' u
\ *G Extract a two-digit hex number in the given base from the
\ ** start of the* string, returning the remaining string
\ ** and the converted number.
   base @ >r  hex
   0 0 2over drop 2 >number 2drop drop
   >r  2 /string r>
   r> base !
;

create EscapeTable      \ -- addr
\ *G Table of translations for \a..\z.
   7 c,         \ \a
   8 c,         \ \b
   char c c,    \ \c
   char d c,    \ \d
   27 c,       \ \e
   12 c,       \ \f
   char g c,    \ \g
   char h c,    \ \h
   char i c,    \ \i
   char j c,    \ \j
   char k c,    \ \k
   10 c,       \ \l
   char m c,    \ \m
   10 c,       \ \n (Unices only)
   char o c,    \ \o
   char p c,    \ \p
   char " c,    \ \q
   13 c,       \ \r
   char s c,    \ \s
   9 c,         \ \t
   char u c,    \ \u
   11 c,       \ \v
   char w c,    \ \w
   char x c,    \ \x
   char y c,    \ \y
   0 c,         \ \z

: addEscape     \ caddr len dest -- caddr' len'
\ *G Add an escape sequence to the counted string at dest,
\ ** returning the remaining string.
   over 0=                              \ zero length check
   if  drop  exit  endif
   >r                                        \ -- caddr len ; R: -- dest
   over c@ [char] x = if                        \ hex number?
     1 /string extract2H r> addchar  exit
   endif
   over c@ [char] m = if                        \ CR/LF pair?
     1 /string 13 r@ addchar  10 r> addchar  exit
   endif
   over c@ [char] n = if                        \ CR/LF pair?
     1 /string  crlf$ count r> append  exit
   endif
   over c@ [char] a [char] z 1+ within if
     over c@ [char] a - EscapeTable + c@  r> addchar
   else
     over c@ r> addchar
   endif
   1 /string
;

: parse\"  \ caddr len dest -- caddr' len'
\ *G Parses a string up to an unescaped '"', translating '\'
\ ** escapes to characters much as C does. The
\ ** translated string is a counted string at *\i{dest}
\ ** The supported escapes (case sensitive) are:
\ *D \a      BEL (alert)
\ *D \b      BS (backspace)
\ *D \e      ESC (not in C99)
\ *D \f      FF (form feed)
\ *D \l      LF (ASCII 10)
\ *D \m      CR/LF pair - for HTML etc.
\ *D \n      newline - CRLF for Windows/DOS, LF for Unices
\ *D \q      double-quote
\ *D \r      CR (ASCII 13)
\ *D \t      HT (tab)
\ *D \v      VT
\ *D \z      NUL (ASCII 0)
\ *D \"      "
\ *D \xAB    Two char Hex numerical character value
\ *D \\      backslash itself
\ *D \       before any other character represents that character
   dup >r  0 swap c!                 \ zero destination
   begin                                        \ -- caddr len ; R: -- dest
     dup
    while
     over c@ [char] " <>                     \ check for terminator
    while
     over c@ [char] \ = if              \ deal with escapes
       1 /string r@ addEscape
     else                               \ normal character
       over c@ r@ addchar  1 /string
     endif
   repeat then
   dup                                  \ step over terminating "
   if  1 /string  endif
   r> drop
;

: readEscaped   \ "string" -- caddr
\ *G Parses an escaped string from the input stream according to
\ ** the rules of *\fo{parse\"} above, returning the address
\ ** of the translated counted string in *\fo{PAD}.
   source >in @ /string tuck         \ -- len caddr len
   pad parse\" nip
    - >in +!
   pad
;

EXTERNAL

: S\"           \ "string" -- caddr u           \ 200X
\ *G As *\fo{S"}, but translates escaped characters using
\ ** *\fo{parse\"} above.
   readEscaped count  state @ if
     compile (s") $,
   then
; IMMEDIATE

\ For symetry with the other string literals in Win32Forth
\ by Dirk Busch

: C\"           \ "string" -- caddr             \ W32F
\ *G As *\fo{C"}, but translates escaped characters using
\ ** *\fo{parse\"} above.
   readEscaped   state @ if
     compile (c") count $,
   then
; IMMEDIATE

: .\"           \ "string" --                   \ W32F
\ *G As *\fo{."}, but translates escaped characters using
\ ** *\fo{parse\"} above.
   readEscaped count  state @ if
     compile (.") $,
   else type
   then
; IMMEDIATE

: Z\"           \ "string" -- addr              \ W32F
\ *G As *\fo{Z"}, but translates escaped characters using
\ ** *\fo{parse\"} above.
   readEscaped   state @ if
     compile (z") count $,
   else
     dup +null 1 chars +
   then
; IMMEDIATE

INTERNAL

: Z$,           \ comp: ( addr len -- )         \ W32F
\ *G Lay the null terminated string into the dictionary
\ ** at *\fo{HERE}, reserve space for it and *\fo{ALIGN}
\ ** the dictionary.
   here over allot swap cmove 0 c, align
;

EXTERNAL

: Z,\"          \ comp: ( -<string">- )         \ W32F
\ *G compile string delimited by " as uncounted
\ ** chars null-terminated chars at here
    readEscaped count Z$, ;

: +Z,\"         \ comp: ( -<string">- )         \ W32F
\ *G Adds the string delimited by " to the currently compiled string.
    -NULL, Z,\" ;

IN-PREVIOUS

MODULE

\s
\ Test Cases
\ ==========

HEX

: { ; immediate
: -> cr .s RESET-STACKS [char] } parse type ;

( The same tests as for S" )


{ : GC5 S\" XY" ; -> }
{ GC5 SWAP DROP -> 2 }
{ GC5 DROP DUP C@ SWAP CHAR+ C@ -> 58 59 }


( The following are inspired by the gForth test suite )


{ S\" " SWAP DROP -> 0 }


{ S\" \a" SWAP C@ -> 1 07 } \ BEL Bell
{ S\" \b" SWAP C@ -> 1 08 } \ BS  Backspace
{ S\" \e" SWAP C@ -> 1 1B } \ ESC Escape
{ S\" \f" SWAP C@ -> 1 0C } \ FF  Formfeed
{ S\" \l" SWAP C@ -> 1 0A } \ LF  Linefeed
{ S\" \q" SWAP C@ -> 1 22 } \ "   Double Quote
{ S\" \r" SWAP C@ -> 1 0D } \ CR  Carage Return
{ S\" \t" SWAP C@ -> 1 09 } \ TAB Horisontal Tab
{ S\" \v" SWAP C@ -> 1 0B } \ VT  Virtical Tab
{ S\" \z" SWAP C@ -> 1 00 } \ NUL No Character
{ S\" \"" SWAP C@ -> 1 22 } \ "   Double Quote
{ S\" \\" SWAP C@ -> 1 5C } \ \   Back Slash


{ S\" \n" 2DROP -> }                                \ System dependent
{ S\" \m" SWAP DUP C@ SWAP CHAR+ C@ -> 2 0D 0A }    \ CR\LF pair
{ S\" \x1Fa" SWAP DUP C@ SWAP CHAR+ C@ -> 2 1F 61 } \ Specified Char


{ S\" S\\\" \\a\"" EVALUATE SWAP C@ -> 1 7 }

decimal

