\ $Id: INTERPIF.F,v 1.7 2013/11/06 21:56:29 georgeahubert Exp $

cr .( Loading interpretive [IF] ...)

( interpif.f )
( interpretive if control structure )
( Placed in the public domain on 8aug96, by Jim Schneider )
\ August 9th, 1996 - 10:38 tjz slight modifications for Win32Forth

\ *D doc
\ *! p-interpif W32F interpretive conditionals
\ *T Interpretive conditionals in Win32Forth

\ *P Win32Forth supports the ANSI interpretive conditionals from the tools extension wordset, with some
\ ** W32F specific extensions as well as an alternative set based on the 'C' style words
\ ** #if #else #then etc.


INTERNAL

-58 Constant THROW_INTERPRETCONDITIONAL
THROW_MSGS LINK, THROW_INTERPRETCONDITIONAL  , ," Unmatched Interpreted conditionals!!! "

: definite-word
                bl nextword 0= THROW_INTERPRETCONDITIONAL ?throw uppercase ;

: match-[str]   ( cstr addr len -- cstr fl )
                2 pick count str= ;

: match-[]      ( possibly match an [if] [then] [else] )
                ( if-count c-addr -- if-count' )
                s" [IF]"   match-[str] if drop 1+ else
                  s" [ELSE]" match-[str] if drop dup 1 <> and else
                    s" [THEN]" match-[str] if drop 1- else
                       s" [ENDIF]" match-[str] if drop 1- else
                drop then then then then ;

: match-[#]     ( possibly match an #if #then #else )
                ( if-count c-addr -- if-count' )
                s" #IF"   match-[str] if drop 1+ else
                  s" #ELSE" match-[str] if drop dup 1 <> and else
                    s" #THEN" match-[str] if drop 1- else
                       s" #ENDIF" match-[str] if drop 1- else
                drop then then then then ;

EXTERNAL

\ *S Glossary

: [else]        ( -- )           \ ANSI             TOOLS EXT
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( "<spaces>name" ... -- )
\ ** Skipping leading spaces, parse and discard space-delimited words from the parse area,
\ ** including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], until
\ ** the word [THEN] has been parsed and discarded. If the parse area becomes exhausted,
\ ** it is refilled as with REFILL. [ELSE] is an immediate word.
                1
                begin   ?dup
                while   definite-word
                        match-[]
                repeat  ; immediate

: [if]          ( flag -- )       \ ANSI            TOOLS EXT
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( flag | flag "<spaces>name" ... -- )
\ ** If flag is true, do nothing. Otherwise, skipping leading spaces, parse and discard
\ ** space-delimited words from the parse area, including nested occurrences of
\ ** [IF] ... [THEN], [IF] ... [ELSE] ... [THEN], [IF] ... [ENDIF] and
\ ** [IF] ... [ELSE] ... [ENDIF], until either the word [ELSE],
\ ** the word [THEN] or the word [ENDIF] has been parsed and discarded.
\ ** If the parse area becomes exhausted, it is refilled as with REFILL.
\ ** [IF] is an immediate word.
\ ** An ambiguous condition exists if [IF] is POSTPONEd.
\ ** If the end of the input buffer is reached and cannot be refilled before the terminating
\ ** [ELSE], [THEN] or [ENDIF] is parsed then error -58 is thrown.
                0= if postpone [else] then ; immediate

: [then]        ( -- )            \ ANSI            TOOLS EXT
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( -- )
\ ** Does nothing. [THEN] is an immediate word.
                ; immediate

: [endif]       ( -- )            \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( -- )
\ ** Does nothing. [ENDIF] is an immediate word.
                ; immediate

: #else         ( -- )            \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( "<spaces>name" ... -- )
\ ** Skipping leading spaces, parse and discard space-delimited words from the parse area,
\ ** including nested occurrences of #IF ... #THEN and #IF ... #ELSE ... #THEN, until
\ ** the word #THEN has been parsed and discarded. If the parse area becomes exhausted,
\ ** it is refilled as with REFILL. #ELSE is an immediate word.
                1
                begin   ?dup
                while   definite-word
                        match-[#]
                repeat  ; immediate

: #if           ( flag -- )       \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( flag | flag "<spaces>name" ... -- )
\ ** If flag is true, do nothing. Otherwise, skipping leading spaces, parse and discard
\ ** space-delimited words from the parse area, including nested occurrences of
\ ** #IF ... #THEN, #IF ... #ELSE ... #THEN, #IF ... #ENDIF and
\ ** #IF ... #ELSE ... #ENDIF, until either the word #ELSE,
\ ** the word #THEN or the word #ENDIF has been parsed and discarded.
\ ** If the parse area becomes exhausted, it is refilled as with REFILL.
\ ** #IF is an immediate word.
\ ** An ambiguous condition exists if #IF is POSTPONEd.
\ ** If the end of the input buffer is reached and cannot be refilled before the terminating
\ ** #ELSE, #THEN or #ENDIF is parsed then error -58 is thrown.
                0= if postpone #else then ; immediate

: #then         ( -- )            \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( -- )
\ ** Does nothing. #THEN is an immediate word.
                ; immediate

: #endif        ( -- )            \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( -- )
\ ** Does nothing. #ENDIF is an immediate word.
                ; immediate

\ header file support for conditional compilation

: #ifdef        ( "aword" -- )    \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( "aword" | "aword<spaces>name" ... -- )
\ ** If "aword" is found in the search order, do nothing. Otherwise, skipping
\ ** leading spaces, parse and discard
\ ** space-delimited words from the parse area, including nested occurrences of
\ ** #IF ... #THEN, #IF ... #ELSE ... #THEN, #IF ... #ENDIF and
\ ** #IF ... #ELSE ... #ENDIF, until either the word #ELSE,
\ ** the word #THEN or the word #ENDIF has been parsed and discarded.
\ ** If the parse area becomes exhausted, it is refilled as with REFILL.
\ ** #IF is an immediate word.
\ ** An ambiguous condition exists if #IF is POSTPONEd.
\ ** If the end of the input buffer is reached and cannot be refilled before the terminating
\ ** #ELSE, #THEN or #ENDIF is parsed then error -58 is thrown.
\ ** This word is designed to ignore object.ivar type words.
                defined nip postpone #if ; immediate

: #ifndef       ( "aword" -- )    \ W32F            TOOLS EXTRA
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: ( "aword" | "aword<spaces>name" ... -- )
\ ** If "aword" is not found in the search order, do nothing. Otherwise, skipping
\ ** leading spaces, parse and discard
\ ** space-delimited words from the parse area, including nested occurrences of
\ ** #IF ... #THEN, #IF ... #ELSE ... #THEN, #IF ... #ENDIF and
\ ** #IF ... #ELSE ... #ENDIF, until either the word #ELSE,
\ ** the word #THEN or the word #ENDIF has been parsed and discarded.
\ ** If the parse area becomes exhausted, it is refilled as with REFILL.
\ ** #IF is an immediate word.
\ ** An ambiguous condition exists if #IF is POSTPONEd.
\ ** If the end of the input buffer is reached and cannot be refilled before the terminating
\ ** #ELSE, #THEN or #ENDIF is parsed then error -58 is thrown.
\ ** This word is designed to ignore object.ivar type words.
                defined nip 0= postpone #if ; immediate

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Compiler assistance to detect words already define or undefined
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: [DEFINED]     ( "aword" -- f1 ) \ Forth200X            TOOLS EXT
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: Return true if "aword" is found in a search of the search order.
\ ** This word is designed to ignore object.ivar type words.
                DPR-WARNING? >R DPR-WARNING-OFF
                BL WORD UPPERCASE PARMFIND nip 0<>
                R> TO DPR-WARNING? ; IMMEDIATE

: [UNDEFINED]   ( "aword" -- f1 ) \ Forth200X            TOOLS EXT
\ *G Compilation: Perform the execution semantics given below. \n
\ ** Execution: Return false if "aword" is found in a search of the search order.
\ ** This word is designed to ignore object.ivar type words.
                postpone [DEFINED] 0= ; IMMEDIATE

MODULE

\ *Z

