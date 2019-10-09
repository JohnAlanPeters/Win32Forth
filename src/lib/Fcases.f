\ fcases.f              Case extensions

cr .( Loading fcases.f : CASE and IF extensions )

\ Theese are various CASE and IF extensions from different authors


anew -fcases.f

INTERNAL
EXTERNAL


\ ------------------------------------------------------------------------------
\ default case
\ ------------------------------------------------------------------------------
\ by Jeff Kelm - 27-Aug-1998
\ DefaultOf is defined in src\utils


\ ------------------------------------------------------------------------------
\ range case
\ ------------------------------------------------------------------------------

INTERNAL

: _RangeOf      ( n1 n2 n3 -- n1 ff | tf )
                2 pick -rot between
                dup if nip then ;

EXTERNAL
IN-SYSTEM

: RangeOf       ( n1 n2 n3 -- n1 )      \ extension to CASE for a range
                \ use: 2  case 1 5 RangeOf do_if_2_is_>=1_and<=5 endof
\in-system-ok   ?comp POSTPONE _RangeOf POSTPONE ?branch >mark 4 ; immediate

IN-APPLICATION


\ ------------------------------------------------------------------------------
\ enum case and if
\ ------------------------------------------------------------------------------
\ By Ezra Boyce

INTERNAL

0 value savedSP

: (|if)         ( n n1...nn -- n f )
                savedSP 0= abort" missing | in conditional"
                savedSP sp@ - cell /  1- >r              \ calc number of items
                sp@ r> savedSP @ lscan nip >r   \ save flag
                savedSP sp! 0 to savedSP                \ restore original sp
                r> ;

: (|of)         ( n n1...nn -- n f | f )
                (|if) dup
                if      nip     \ for case_of_endof structures discard n
                then    ;

EXTERNAL

: |             ( n -- n )
                sp@ to savedSP ;

IN-SYSTEM

: |if           ( n n1..nn -- f ) \ allow IF to check for a value in a list
                \ use:  5 | 1 2 3 4 8 9 5 |if do_if_five_is_in_list then
                \ Beware: not reentrant
\in-system-ok  ?comp POSTPONE (|if) POSTPONE nip POSTPONE ?branch >mark 2 ; IMMEDIATE

: |of           ( n n1..nn -- f ) \ allow OF to check for a value in a list
                \ use:  5 | 1 2 3 4 8 9 5 |of do_if_five_is_in_list endof
                \ Beware: not reentrant
\in-system-ok   ?comp POSTPONE (|of) POSTPONE ?branch >mark 4 ; IMMEDIATE

IN-APPLICATION


\ ------------------------------------------------------------------------------
\ strings case
\ ------------------------------------------------------------------------------
\ by Bozhil Makaveev - March 16 1997
\ <bozhil@pacbell.net> - bozhil@iname.com
\ Home phone and fax: (818) 348-2653 - Work phone: (818) 883-5211 ext. 280.
\ These are some lines that I always add to my programs, so feel free to
\ use them, and if you like them - add to win32for files.

INTERNAL

: ("of)         ( counted-source a1 c1 -- counted-source ff | tf )
                2>r dup count 2r> compare 0= -if nip then ;

: ("of-begin)   ( counted-source a1 c1 -- counted-source ff | tf )
                2 pick count drop over compare 0= -if nip then ;

: ("of-contain) ( counted-source a1 c1 -- counted-source ff | tf )
                2>r dup count 2r> search nip nip -if nip then ;

EXTERNAL
IN-SYSTEM

: "of           ( n1 n2 n3 -- n1 ) \ extension to CASE for a string
                \ compares two strings for exact match
                \ The parameter before CASE is a counted string given by its count address
                \ use: s" this" "of do_if_case_parameter_is_exactly_"this" endof
\in-system-ok   ?comp POSTPONE ("of) POSTPONE ?branch >mark 4 ; immediate

: "of-begin   ( n1 n2 n3 -- n1 ) \ extension to CASE for a string
                \ compares two strings at their beginning.
                \ The parameter before CASE is a counted string given by its count address
                \ use: s" this" "of do_if_case_parameter_begins_with_"this" endof
\in-system-ok   ?comp POSTPONE ("of-begin) POSTPONE ?branch >mark 4 ; immediate

: "of-contain   ( n1 n2 n3 -- n1 )      \ extension to CASE for a string
                \ checks for tokens presence in the source string
                \ The parameter before CASE is a counted string given by its count address
                \ use: s" this" "of do_if_case_parameter_contains_"this" endof
\in-system-ok   ?comp POSTPONE ("of-contain) POSTPONE ?branch >mark 4 ; immediate

IN-APPLICATION

MODULE



\S      **********  Some test code ***********

: testcase      ( n -- )
		case
                          1 Of ." of : n=1 "               Endof
                   2 4 RangeOf ." RangeOf : 2<=n<=4 "      Endof
                   | 5 6 8 |Of ." |Of : n = 5 or 6 or 8 "  Endof
                     DefaultOf ." DefaultOf : n=neither "  Endof
                endcase ;

cr .( 0 testcase --> ) 0 testcase
cr .( 1 testcase --> ) 1 testcase
cr .( 2 testcase --> ) 2 testcase
cr .( 3 testcase --> ) 3 testcase
cr .( 4 testcase --> ) 4 testcase
cr .( 5 testcase --> ) 5 testcase
cr .( 6 testcase --> ) 6 testcase
cr .( 7 testcase --> ) 7 testcase
cr .( 8 testcase --> ) 8 testcase

: test_"of ( -- )
                bl word
                case
                        s" string1" "of ." string 1 matched" endof
                        s" string2" "of ." string 2 matched" endof
                        s" string3" "of ." string 3 matched" endof
                endcase ;
cr .( " string2" "of --> ) test_"of string2


: test_"of-begin ( -- )
                bl word
                case
                        s" string1" "of-begin ." string 1 matched" endof
                        s" string2" "of-begin ." string 2 matched" endof
                        s" string3" "of-begin ." string 3 matched" endof
                endcase ;
cr .( " string2yyy" "of-begin --> ) test_"of-begin string2yyy


: test_"of-contain ( -- )
                bl word
                case
                        s" string1" "of-contain ." string 1 matched" endof
                        s" string2" "of-contain ." string 2 matched" endof
                        s" string3" "of-contain ." string 3 matched" endof
                endcase ;
cr  .( " xxxstring2yyy" "of-contain --> ) test_"of-contain xxxstring2yyy"

