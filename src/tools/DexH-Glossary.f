\ DexH-Glossary.f
\ Creating a glossary for Win32Forth.

create OutputFile$ ," doc\w32f-glossary.csv"

\ ****************************************************************************
\ write output file
\ ****************************************************************************

[UNDEFINED] OutputFileHandle [if]
0 value OutputFileHandle
\ *G The handle of the output file for the glossary.
[then]

: output-close ( -- )
\ *G Close the output file for the glossary.
        OutputFileHandle ?dup
        if   close-file drop
             0 to OutputFileHandle
        then ;

: OutputFile  ( -- addr len )
\ *G Get name of output file for the glossary (including path).
        OutputFile$ count Prepend<home>\ ;

: output-open ( -- f )
\ *G Open the output file for the glossary.
\ ** If the file already exist the append mode for the file is set.
        output-close
        OutputFile r/w open-file swap to OutputFileHandle 0=
        if   OutputFileHandle file-append 0=
        else OutputFile r/w create-file swap to OutputFileHandle 0=
        then ;

: output-delete ( -- )
\ *G Delete the output file for the glossary.
        OutputFile delete-file drop ;

: output-write  ( addr len -- )
\ *G Write a string to the output-file.
        OutputFileHandle write-file drop ;

: output-char ( char -- )
\ *G Write a char to the output-file.
        here c! here 1 output-write ;

: (output-string) ( addr count -- )
\ *G Write a string to the output-file.
\ ** A " char will be written as "" into the file.
        bounds
        ?do  i c@ dup [char] " =
             if   dup output-char
             then output-char
        loop ;

: output-string ( addr count -- )
\ *G Write a string to the output-file.
\ ** The string will be quoated with " .
        [char] " output-char
        (output-string)
        [char] " output-char ;

: output-sep ( -- )
\ *G Write seperator to the output-file.
        [char] , output-char ;

: output-cr ( -- )
\ *G Write CR to the output-file.
        13 output-char
        10 output-char ;

: output-header ( -- )
\ *G Write the header line to the output-file.
        s" Name"    output-string output-sep
        s" Stack"   output-string output-sep
        s" Comment" output-string output-sep
        s" Type"    output-string output-sep
        s" Class"   output-string output-sep
        s" File"    output-string output-cr ;

: output-new    ( -- )
\ *G Create a new empty glossary file.
        output-delete
        output-open if
          output-header
          output-close
        then ;

\ ****************************************************************************
\ parse input file
\ ****************************************************************************

-1 constant #invalid-definition-type
#invalid-definition-type value definition-type

: allot-erase   ( n -- )
        here over allot swap erase ;

create $definition-name 1024 allot-erase
create $definition-type 1024 allot-erase
create $stack-comment   1024 allot-erase
create $comment         1024 allot-erase
create $class-name      1024 allot-erase

false value InClass?

: IsClass?              ( -- f )
        definition-type  8 = \ :class ?
        definition-type  9 = \ :object ?
        definition-type 14 = \ |class ?
        or or ;

: IsCloseingClass?      ( -- f )
        definition-type 10 = \ ;class ?
        definition-type 11 = \ ;object ?
        or ;

: set-class-name        ( -- )
        IsClass?
        if   $definition-name lcount $class-name lplace
        else IsCloseingClass?
             if   0 $class-name !
             then
        then ;

: +word ( a1 n1 -- a2 n2 a3 n3 )
        bl skip 2dup bl scan 2dup 2>r nip - 2r> 2swap ;

: set-definition-type   ( addr len n -- )
        to definition-type 2drop ;

: is-definition-type    ( a1 n1 -- )

        2dup s" :"            COMPARE 0= if  0 set-definition-type exit then
        2dup s" CODE"         COMPARE 0= if  1 set-definition-type exit then
        2dup s" CONSTANT"     COMPARE 0= if  2 set-definition-type exit then
        2dup s" DEFER"        COMPARE 0= if  3 set-definition-type exit then
        2dup s" CREATE"       COMPARE 0= if  4 set-definition-type exit then
        2dup s" VARIABLE"     COMPARE 0= if  5 set-definition-type exit then
        2dup s" VALUE"        COMPARE 0= if  6 set-definition-type exit then
        2dup s" :M"           COMPARE 0= if  7 set-definition-type exit then
        2dup s" :CLASS"       COMPARE 0= if  8 set-definition-type true  to InClass? exit then
        2dup s" :OBJECT"      COMPARE 0= if  9 set-definition-type true  to InClass? exit then
        2dup s" ;CLASS"       COMPARE 0= if 10 set-definition-type false to InClass? exit then
        2dup s" ;OBJECT"      COMPARE 0= if 11 set-definition-type false to InClass? exit then
        2dup s" FVARIABLE"    COMPARE 0= if 12 set-definition-type exit then
        2dup s" 2VARIABLE"    COMPARE 0= if 13 set-definition-type exit then
        2dup s" |CLASS"       COMPARE 0= if 14 set-definition-type true  to InClass? exit then
        2dup s" :NONAME"      COMPARE 0= if 15 set-definition-type exit then
        2dup s" |:"           COMPARE 0= if 16 set-definition-type exit then
        2dup s" FCONSTANT"    COMPARE 0= if 17 set-definition-type exit then
        2dup s" 2CONSTANT"    COMPARE 0= if 18 set-definition-type exit then
        2dup s" BYTES"        COMPARE 0= if 19 set-definition-type exit then
        2dup s" BYTE"         COMPARE 0= if 20 set-definition-type exit then
        2dup s" BITS"         COMPARE 0= if 21 set-definition-type exit then
        2dup s" SHORT"        COMPARE 0= if 22 set-definition-type exit then
        2dup s" INT"          COMPARE 0= if 23 set-definition-type exit then
        2dup s" DINT"         COMPARE 0= if 24 set-definition-type exit then
        2dup s" USER"         COMPARE 0= if 25 set-definition-type exit then
        2dup s" NEWUSER"      COMPARE 0= if 26 set-definition-type exit then
        2dup s" CFA-CODE"     COMPARE 0= if 27 set-definition-type exit then
        2dup s" CFA-FUNC"     COMPARE 0= if 28 set-definition-type exit then
        2dup s" HEADER"       COMPARE 0= if 29 set-definition-type exit then
        2dup s" ALIAS"        COMPARE 0= if 30 set-definition-type exit then
        2dup s" SYNONYM"      COMPARE 0= if 31 set-definition-type exit then
        2dup s" EQU"          COMPARE 0= if 32 set-definition-type exit then
\         2dup s" AS"           COMPARE 0= if 33 set-definition-type exit then
        2dup s" MACRO"        COMPARE 0= if 34 set-definition-type exit then
        2dup s" #DEFINE"      COMPARE 0= if 35 set-definition-type exit then
        2dup s" RECORD:"      COMPARE 0= if 36 set-definition-type exit then
        2dup s" ;RECORDSIZE:" COMPARE 0= if 37 set-definition-type exit then
        2dup s" MACRO:"       COMPARE 0= if 38 set-definition-type exit then
        2dup s" SUBR:"        COMPARE 0= if 39 set-definition-type exit then
\         2dup s" PROC"         COMPARE 0= if 40 set-definition-type exit then
        2dup s" EXTERN"       COMPARE 0= if 41 set-definition-type exit then
        2dup s" WINLIBRARY"   COMPARE 0= if 42 set-definition-type exit then

        2drop ;

: get-definition-type ( addr len -- )
\ Get the type of the definition.
\ Note: The string will be in uppercase letters after this.
        #invalid-definition-type to definition-type \ default: unkonwen

        2dup upper +word -trailing
        is-definition-type definition-type #invalid-definition-type =
        if   +word -trailing is-definition-type 2drop
        else 2drop
        then ;

create buf1$ 1024 allot
create buf2$ 1024 allot

: parse-stack-comment ( a1 n1 c1 c2 -- a2 n2 f )
                      { c1 c2 -- }
        0 $stack-comment !

        2dup c1 scan ?dup         \ a1 n1 a2 n2 f
        if   \ stack comment found
             2nip 2dup c2 scan 2dup 2>r nip - ?dup  \ a2 n2 a3 n3
             if   c1 skip bl skip -trailing $stack-comment lplace
             else drop
             then 2r> 1 /string
        else drop
        then $stack-comment lcount nip ;

: parse-line    ( addr len -- f )
\ Parse one line of the input file, and write
\ the name the stack comment, and to comment into the output file.

        \ the name and definition type
        +word buf1$ lplace
        +word buf2$ lplace

        buf1$ lcount $definition-type lplace $definition-type lcount
        get-definition-type definition-type #invalid-definition-type =
        if   buf2$ lcount $definition-type lplace $definition-type lcount
             get-definition-type definition-type #invalid-definition-type =
             if   2drop false exit \ exit on error
             else \ the name comes after the definition type (e.g. FCONSTANT)
                  +word $definition-name lplace
             then
        else buf2$ lcount $definition-name lplace
        then

        \ stack comment
        [char] ( [char] ) parse-stack-comment 0=
        if   [char] { [char] } parse-stack-comment drop
        then

        \ comment
        [char] \ scan ?dup
        if   [char] \ skip bl skip -trailing $comment lplace
        else drop 0 $comment !
        then

        \ write the strings into the output file
        $definition-name lcount output-string output-sep
        $stack-comment   lcount output-string output-sep
        $comment         lcount output-string output-sep

        true ;

: print-class-name ( -- )
\ Write the name of the current class into the output file.
        InClass? IsClass? 0= and
        if   $class-name lcount
        else s" "
        then output-string ;

: print-definition-type ( -- )
\ Write the definition type into the output file.
        definition-type
        case    0 of s" COLON"        endof
               15 of s" COLON hidden" endof \ :noname
               16 of s" COLON hidden" endof \ |:

                1 of s" CODE"         endof

                2 of s" CONSTANT"     endof
               17 of s" FCONSTANT"    endof
               18 of s" 2CONSTANT"    endof

                3 of s" DEFER"        endof
                4 of s" CREATE"       endof

                5 of s" VARIABLE"     endof
               12 of s" FVARIABLE"    endof
               13 of s" 2VARIABLE"    endof

                6 of s" VALUE"        endof

               14 of s" |CLASS"       endof
                8 of s" CLASS"        endof
                9 of s" OBJECT"       endof

               10 of s" ;CLASS"       endof
               11 of s" ;OBJECT"      endof

                7 of s" METHOD"       endof \ :m
               19 of s" BYTES ivar"   endof
               20 of s" BYTE ivar"    endof
               21 of s" BITS ivar"    endof
               22 of s" SHORT ivar"   endof
               23 of s" INT ivar"     endof
               24 of s" DINT ivar"    endof

               25 of s" USER"         endof
               26 of s" NEWUSER"      endof
               27 of s" CFA-CODE"     endof
               28 of s" CFA-FUNC"     endof
               29 of s" HEADER"       endof
               30 of s" ALIAS"        endof
               31 of s" SYNONYM"      endof
               32 of s" EQU"          endof
               33 of s" AS"           endof
               34 of s" MACRO"        endof
               35 of s" #DEFINE"      endof
               36 of s" RECORD:"      endof
               37 of s" ;RECORDSIZE:" endof
               38 of s" MACRO:"       endof
               39 of s" SUBR:"        endof
               40 of s" PROC"         endof
               41 of s" EXTERN"       endof
               42 of s" WINLIBRARY"   endof
        endcase
        output-string ;

: print-file-name  ( #anchor -- )
\ Write the name of input file with the anchor into the output file.
        [char] " output-char
        $infile lcount (output-string)
        [char] # output-char
        s>d (D.) (output-string)
        [char] " output-char ;

: process-word  ( #anchor addr len -- )
\ *G Process on line of the input file.
        ?dup
        if   parse-line
             if   set-class-name
                  print-definition-type output-sep ( #anchor )
                  print-class-name      output-sep ( #anchor )
                  print-file-name       output-cr  ( -- )
             else drop
             then
        else 2drop
        then ;
