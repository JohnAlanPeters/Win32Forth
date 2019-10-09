\ Automatic character encoding tables

\ ---------------------------------------------------
\     (c) Copyright 2001  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

\ This is an ANS Forth program using the CORE wordset


: char_table:   ( #chars "table_name" -- )
    CREATE   HERE  OVER  CHARS  ALLOT   SWAP  0 FILL
    DOES>  ( char -- code[c])
           CHARS +   C@  ;

: install      (  adr char.n char.1 -- )   \ fast fill
    SWAP 1+ SWAP   DO  2DUP  I  CHARS +  C!  LOOP  2DROP ;
\ end automatic conversion tables
