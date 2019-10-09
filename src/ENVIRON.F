\ $Id: ENVIRON.F,v 1.8 2011/03/31 08:08:38 georgeahubert Exp $
\ ENVIRON.F             ENVIRONMENT? support    by Tom Zimmer

cr .( Loading ANS ENVIRONMENT...)

\ Implementation suggested by Andrew McKewan

only forth also definitions
1 #vocabulary environment

: environment?  ( a1 n1 -- false | ?? true )
                ['] environment vcfa>voc search-wordlist
                if      execute true
                else    false
                then    ;

environment definitions

         MAXCOUNTED  CONSTANT /COUNTED-STRING
               0x50  CONSTANT /HOLD
          MAXSTRING  CONSTANT /PAD
                  8  CONSTANT ADDRESS-UNIT-BITS
               TRUE  CONSTANT CORE
               TRUE  CONSTANT CORE-EXT
        -10 7 / -2 = CONSTANT FLOORED
               0xFF  CONSTANT MAX-CHAR
0x7FFFFFFF.FFFFFFFF 2CONSTANT MAX-D
         0x7FFFFFFF  CONSTANT MAX-N
         0xFFFFFFFF  CONSTANT MAX-U
0xFFFFFFFF.FFFFFFFF 2CONSTANT MAX-UD
              0x100  CONSTANT RETURN-STACK-CELLS
              0x100  CONSTANT STACK-CELLS
               TRUE  CONSTANT DOUBLE
               TRUE  CONSTANT DOUBLE-EXT
               TRUE  CONSTANT EXCEPTION
               TRUE  CONSTANT EXCEPTION-EXT
               TRUE  CONSTANT FACILITY
               TRUE  CONSTANT FACILITY-EXT
               TRUE  CONSTANT MEMORY-ALLOC
               TRUE  CONSTANT MEMORY-ALLOC-EXT
               TRUE  CONSTANT FILE
               TRUE  CONSTANT FILE-EXT
               TRUE  CONSTANT TOOLS
               TRUE  CONSTANT TOOLS-EXT
               TRUE  CONSTANT SEARCH-ORDER
               TRUE  CONSTANT SEARCH-ORDER-EXT
              #VOCS  CONSTANT WORDLISTS
               TRUE  CONSTANT STRING
               TRUE  CONSTANT STRING-EXT
           #-LOCALS  CONSTANT #LOCALS
               TRUE  CONSTANT LOCALS
               TRUE  CONSTANT LOCALS-EXT

LOADED? SRC\FLOAT.F [IF]
               TRUE  CONSTANT FLOATING
               TRUE  CONSTANT FLOATING-EXT
    FSTACK-ELEMENTS  CONSTANT FLOATING-STACK
               FBIG FCONSTANT MAX-FLOAT
[then]

\ Win32Forth specific queries
               TRUE  CONSTANT WIN32FORTH


\ Added Wednesday, September 27 2006 to support Forth 200x extensions. gah

                            : X:EXTENSION-QUERY ;
                            : X:DEFINED         ;
                            : X:REQUIRED        ;
                            : X:DEFERRED        ;
                            : X:PARSE-NAME      ;
                            : X:NUMBER-PREFIX   ;
LOADED? SRC\STRUCT200X.F    [IF]
                            : X:STRUCTURES      ;   [THEN]
\                            : X:EKEYS           ; \ Not sure

previous definitions


