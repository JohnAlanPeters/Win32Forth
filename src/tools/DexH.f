\ $Id: DexH.f,v 1.10 2011/11/09 21:57:47 georgeahubert Exp $

( *! dexh DexH                                                                 )
( *T DexH -- Document Extractor, HTML output                                   )
\ *Q Version 3
\ ** Primary contributors: Brad Eckert  brad1NO@SPAMtinyboot.com
\ ** Modified for use in Win32Forth by George Hubert and Dirk Busch
( *Q Abstract                                                                  )
( ** DexH is a simple literate programming tool inspired by MPE's DOCGEN. DexH )
( ** can also be used to write articles about Forth featuring a mixture of     )
( ** documentation and source code. DexH is a standalone program that processes)
( ** a Forth source file. The following command does the conversion: \n        )
( ** \bDEX input_filename\d                                                    )
( *S Commands                                                                  )
( *P Commands are embedded within comments. You can use the following formats, )
( ** with either starting at the first column.                                 )
\ *B ( ?? ... ) where ?? is the command, or
\ *B \ ?? ...
( *P You can append HTML to created files by DEXing any number of source files )
( ** but you should use a *Z command to complete the HTML.                     )
( *L |c||l|                                                                    )
( *| Command | Effect                                   |                      )
( *| ** | continuation of G, E or P                     |                      )
( *| *D | Select a new output folder                    |                      ) \ dbu
( *| *! | create and select a new output file           |                      )
( *| *> | select an existing file to add text to        |                      )
( *| *T | Title                                         |                      )
( *| *Q | Quotation or abstract                         |                      )
( *| *S | Section                                       |                      )
( *| *N | Sub-section                                   |                      )
( *| *P | Paragraph                                     |                      )
( *| *E | Paragraph which is a code example             |                      )
( *| *B | Bullet entry                                  |                      )
( *| *G | Glossary entry for the previous line          |                      )
( *| *R | raw LaTeX                                     |                      )
( *| *W | raw HTML                                      |                      )
( *| *Z | End output                                    |                      )
( *| *+ | Include source code as document text          |                      )
( *| *- | Turn off source code inclusion                |                      )

anew -DexH.f
internal

\ Set to true when a separate glossary.txt should be created
\ Still work in progress... (dbu)
1 value create-glossary-file?

( *P DexH is ANS Forth except for the need for BOUNDS, SCAN, SKIP and LCOUNT.  )
( ** They are commonly used words but redefined here for completeness.         )
( *+ )
\ : BOUNDS OVER + SWAP ;
\ : SCAN            ( addr len char -- addr' len' )
\    >R BEGIN DUP WHILE OVER C@ R@ <>
\    WHILE 1 /STRING REPEAT THEN R> DROP ;
\ : SKIP            ( addr len char -- addr' len' )
\    >R BEGIN DUP WHILE OVER C@ R@ =
\    WHILE 1 /STRING REPEAT THEN R> DROP ;
\ : LCOUNT          ( addr -- addr' len ) DUP CELL+ SWAP @ ;
( *P Some files use very long lines, which is desirable for long sections of   )
( ** documentation. You can allocate buffers for lines longer than 2000 chars  )
( ** by changing the following line:                                           )
2000 CHARS CONSTANT max$
( *- )
CREATE inbuf    max$ 2 CELLS + ALLOT            \ current line
CREATE prevline max$ 2 CELLS + ALLOT            \ previous line
CREATE XPAD     max$ 2 CELLS + ALLOT            \ temporary
( *+ )
( *P HTML needs some canned boilerplate. This is created by ,| since HTML      )
( ** doesn't use | characters.                                                 )
: (,$)  ( a len -- )  DUP C, 0 ?DO COUNT C, LOOP DROP ;
: ,|    ( <text> -- ) [CHAR] | WORD COUNT -TRAILING (,$) ;

external

CREATE DexHTMLheader
   ,| <?xml version="1.0"?>                                                    |
   ,| <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"                 |
   ,|     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">                 |
   ,| <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">      |
   ,| <head>                                                                   |
   ,| <meta http-equiv="Content-Type" content="text/xml; charset=iso-8859-1" />|
   ,| <meta name="GENERATOR" content="DexH v03" />                             |
   ,| <style type="text/css">                                                  |
   ,| </style>                                                                 |
   ,| <title>                                                                  |
   0 C,
( *- )

DexHTMLheader value HTMLheader

CREATE DexHTMLheaderA
   ,| </title>                                                                 |
   ,| </head>                                                                  |
   ,| <body>                                                                   |
   0 C,

DexHTMLheaderA value HTMLheaderA

CREATE DexHTMLtrailer
   ,| <hr />                                                                   |
   ,| </body></html>                                                           |
   0 C,

DexHTMLtrailer value HTMLtrailer

internal

0 VALUE outfile                                 \ The current output file
0 VALUE infile
0 VALUE echoing  0 value plain                  \ Echo the code as output
0 VALUE mode
0 VALUE gl-outfile                              \ The glossary current output file

( *P All output is via OUT and OUTLN, which can be sent to the screen for      )
( ** debugging purposes.                                                       )
( *+ )
0 VALUE testing                                 \ screen is for testing
: werr     ( n -- )      ABORT" Error writing file" ;
: out      ( a len -- )  testing IF TYPE    ELSE outfile WRITE-FILE werr THEN ;
: outln    ( a len -- )  testing IF TYPE CR ELSE outfile WRITE-LINE werr THEN ;
( *- )
: boiler   ( addr -- )   BEGIN COUNT DUP WHILE 2DUP + >R outln R> REPEAT 2DROP ;
: tag|     ( <name><str> -- ) CREATE ,| DOES> COUNT out ( ln ) ;

tag| +t <table border="1">              |       \ table
tag| -t </table>                        |
tag| +b <ul><li>                        |       \ bullets
tag| -b </li></ul>                      |
tag| ~b </li><li>                       |
tag| +e <pre>                           |       \ code paragraph
tag| -e </pre>                          |
tag| +p <p>                             |       \ paragraph
tag| -p </p>                            |
tag| +g <pre><b>                        |       \ preformatted bold glossary
tag| -g </b></pre>                      |
tag| hr <hr />                          |       \ rule
tag| +h1 <h1>                           |       \ title
tag| -h1 </h1>                          |
tag| +h2 <h2>                           |       \ section
tag| -h2 </h2>                          |
tag| +h3 <h3>                           |       \ sub-section
tag| -h3 </h3>                          |
tag| +qu <h3><i>                        |       \ quotation or abstract
tag| -qu </i></h3>                      |
tag| +au <h4><i>                        |       \ Author
tag| -au </i></h4>                      |

tag| -a </a>
tag| +n <a name="                       |
tag| -n ">                              |
tag| +href <a href="                    |
tag| -href ">                           |

( *P Some characters are replaced by special strings so they can't be          )
( ** interpreted as tags. Also, runs of blanks need special treatment.         )
( ** Some escape sequences are supported:                                      )
( *L |c||l|                                                                    )
( *| \bseq\d | \bEscape command \d                      |                      )
( *| \\i  | Italics                                     |                      )
( *| \\b  | Bold                                        |                      )
( *| \\t  | Typewriter                                  |                      )
\ *| \\^  | Superscript (i.e. ax\\^2\\d+bx+c=0)         |
\ *| \\_  | Subscript                                   |
\ *| \\d  | Default font (ends italic, superscript, etc.) |
( *| \\n  | Line break                                  |                      )
( *| \\r  | Horizontal rule                             |                      )
( *| \\p  | Page break                                  |                      )
( *| \\\\ | \                                           |                      )

\ *P Sample usage:
\ ** "ax\\^2\\d + bx + w\\_0\\d = 0" displays ax\^2\d + bx + w\_0\d = 0
\ *P "Try \\bbold, \\iitalic \\dand \\ttypewriter.\\d" displays
\ ** "Try \bbold, \iitalic \dand \ttypewriter\d."

VARIABLE bltally                                \ counts runs of blanks
VARIABLE thisfont                               \ current font attributes
VARIABLE escape                                 \ escape sequence in progress?
VARIABLE captive                                \ ESC sequence not allowed

: no-escape ( -- ) S" \" out  0 escape ! ;

( *+ )
: new-font  ( n -- )                            \ switch to a new font
   thisfont @ SWAP thisfont !
   CASE [CHAR] i OF S" </i>" out                ENDOF
        [CHAR] b OF S" </b>" out                ENDOF
        [CHAR] t OF S" </code>" out             ENDOF
        [CHAR] ^ OF S" </sup>" out              ENDOF
        [CHAR] _ OF S" </sub>" out              ENDOF
   ENDCASE ;

: outh    ( addr len -- )                       \ HTMLized text output
   999 bltally !
   BOUNDS ?DO I C@ escape @ IF
     CASE
        [CHAR] \ OF S" \"         out           ENDOF
        [CHAR] n OF S" <br />"    out           ENDOF
        [CHAR] r OF hr                          ENDOF
        [CHAR] i OF I C@ new-font S" <i>" out       ENDOF
        [CHAR] b OF I C@ new-font S" <b>" out       ENDOF
        [CHAR] t OF I C@ new-font S" <code>" out    ENDOF
        [CHAR] ^ OF I C@ new-font S" <sup>" out     ENDOF
        [CHAR] _ OF I C@ new-font S" <sub>" out     ENDOF
        [CHAR] d OF 0    new-font                   ENDOF
        no-escape I 1 out
     ENDCASE 0 escape !
   ELSE
     CASE
        [CHAR] \ OF captive @
              IF no-escape ELSE 1 escape ! THEN ENDOF
        [CHAR] & OF S" &amp;"     out           ENDOF
        [CHAR] < OF S" &lt;"      out           ENDOF
        [CHAR] > OF S" &gt;"      out           ENDOF
        [CHAR] " OF S" &quot;"    out           ENDOF
        [CHAR] © OF S" &copy;"    out           ENDOF
        BL       OF bltally @ IF S" &nbsp;" ELSE S"  " THEN out
                 1 bltally +!                   ENDOF
        I 1 out  0 bltally !
       ENDCASE
   THEN LOOP
   escape @ IF no-escape THEN                   \ trailing \
   S" " outln ;
( *- )

: outt  ( a n -- ) out ;                        \ output as title string

\ : lastchar ( a n -- a n c )
\    2DUP 1- CHARS + C@ ;

: line     ( -- a len )
   inbuf LCOUNT 5 /STRING                       \ remove ( ** and ) or \ **
   inbuf CELL+ C@ [CHAR] ( = IF lastchar [CHAR] ) = IF 1- THEN THEN
   -TRAILING ;

: _parse ( $line char -- $line' $ )
   >R 2DUP R@ SKIP R> SCAN BL SCAN              \ parse out a substring
   2SWAP 2 PICK - ;

: closeout      ( -- )
   outfile ?DUP IF CLOSE-FILE DROP THEN
   0 TO outfile ;

: end           ( -- )                          \ insert end tags
   mode CASE
     [CHAR] P OF -p ENDOF
     [CHAR] E OF -e ENDOF
     [CHAR] B OF -b ENDOF
     [CHAR] L OF -t ENDOF
   ENDCASE BL TO mode ;

CREATE $infile     max$ 2 CELLS + ALLOT        \ file name
0 value #gl-anchor

: switchfolder  ( -- ) \ Set new output folder
        end closeout line
        BL _parse             \ get folder
\in-system-ok Prepend<home>\ "chdir \ set current directory
        2drop ;

: switchfile    ( -- $other $name io ) \ Set new output file
   end closeout line
   BL _parse                  \ get filename (minus extension)
   >R XPAD R@ MOVE
   S" .htm" XPAD R@ CHARS + SWAP MOVE           \ add file extension
   xpad R@ 4 CHARS + $infile lplace \ save file name
   0 to #gl-anchor \ reset anchor
   XPAD R> 4 CHARS +  w/o ;

: pgraph        ( -- ) +p line outh [CHAR] P TO mode ;
: egraph        ( -- ) +e line outh [CHAR] E TO mode ;
: iscommand?    ( $ -- ) inbuf CELL+ 3 COMPARE 0= ;

\ *P The fields in a table are separated by | (vertical bar) and end in |.

: table|        ( -- )                          \ add line to a table
   line
   BEGIN [CHAR] | _parse BL SKIP 1- 0 MAX -TRAILING DUP
      IF   S" <td>" out outh S" </td>" outln
      ELSE 2DROP 2DROP EXIT
      THEN
   AGAIN ;

fload tools/DexH-Glossary.f

: gl-open       ( -- )
\ *G Open glossary File.
        create-glossary-file?
        if   output-open drop
        then ;

: gl-close      ( -- )
\ *G Close glossary File.
        create-glossary-file?
        if   output-close
        then ;

: gl-anchor      ( -- )
\ *G Write anchor number.
         #gl-anchor s>d (D.) out ;

CREATE $line max$ 2 CELLS + ALLOT            \ previous line

: gl-get-type   ( addr len - f )
        $line lplace
        $line lcount get-definition-type
        definition-type #invalid-definition-type <>
        ;

: gl-entry      ( addr len -- )
\ cr 2dup type
        2dup gl-get-type
        if   IsCloseingClass? 0=
             if $line lplace #gl-anchor $line lcount process-word
             else 2drop
             then
        else 2drop cr ." Line: " $line lcount type ."  skipped"
        then ;

: gl-create-entry ( -- )
\ *G Create a glossary entry
\ cr ." gl-create-entry: " prevline LCOUNT type
        +n gl-anchor -n
        prevline LCOUNT outh -a

        create-glossary-file?
        if   prevline LCOUNT gl-entry
             1 +to #gl-anchor
        then ;

: command       ( c -- )
   plain IF -e 0 TO plain THEN                  \ terminate plain text
   CASE
     [CHAR] * OF line outh                                      ENDOF
     [CHAR] ! OF switchfile create-file abort" Can't create file"
       TO outfile                               \ create and select a new file
       HTMLheader  boiler  outt                 \ add title
       HTMLheaderA boiler                                       ENDOF
     [CHAR] > OF switchfile open-file abort" Can't open file"
       TO outfile 2DROP
       outfile FILE-SIZE DROP  outfile REPOSITION-FILE DROP     ENDOF
     [CHAR] T OF end hr +h1 line outh -h1 hr                    ENDOF
     [CHAR] S OF end +h2 line outh -h2                          ENDOF
     [CHAR] N OF end +h3 line outh -h3                          ENDOF
     [CHAR] A OF end +au line outh -au  +p [CHAR] P TO mode     ENDOF
     [CHAR] Q OF end +qu line outh -qu  +p [CHAR] P TO mode     ENDOF
     [CHAR] P OF end pgraph                                     ENDOF
     [CHAR] E OF end egraph                                     ENDOF
     [CHAR] B OF mode [CHAR] B <> IF end +b ELSE ~b THEN
            line outh [CHAR] B TO mode                          ENDOF
     [CHAR] G OF end +g gl-create-entry -g pgraph               ENDOF
     [CHAR] W OF end line outln                                 ENDOF
     [CHAR] + OF end +e 1 TO plain 1 TO echoing                 ENDOF
     [CHAR] - OF end 0 TO echoing                               ENDOF
     [CHAR] L OF end +t [CHAR] L TO mode                        ENDOF
     [CHAR] | OF S" <tr>" out table| S" </tr>" outln            ENDOF
     [CHAR] Z OF end HTMLtrailer boiler                         ENDOF
     [CHAR] D OF switchfolder                                   ENDOF \ dbu
   ENDCASE ;

: process-line  ( -- )                          \ process INBUF
   inbuf @ 3 >
   if   S" ( *" inbuf cell+ over compare 0=
        S" \ *" inbuf cell+ over compare 0= or
        inbuf @ 4 > if inbuf cell+ 4 + c@ bl = and then
   else 0
   then
(( old version
   S" ( *" iscommand?
   S" \ *" iscommand? OR inbuf @  3 > AND
))
   IF   0 captive !
        inbuf 3 CHARS + CELL+ C@ command        \ a command
   ELSE end echoing                             \ not a command
     IF plain 0= IF 1 TO plain +e THEN
        1 captive !
        inbuf LCOUNT outh
     THEN
   THEN inbuf prevline OVER @ CELL+ MOVE ;      \ save the old line
( *W <hr /> )
( *S Glossary )

external

: (dex)         ( addr len -- )
( *G Convert a file or files to HTML. Output filenames are included in the     )
( ** source file.                                                              )
   2dup cr ." Processing file: " type
   0 TO testing                                 \ output to file
   0 TO echoing 0 TO plain 0 TO mode            \ reset modes
   0 escape !
   R/O OPEN-FILE ABORT" Missing input file" TO infile
   gl-open
   prevline max$ BLANK
   BEGIN inbuf max$ BL FILL                     \ convert tabs to spaces
      XPAD max$ infile READ-LINE ABORT" Error reading file"
      >R >R 0 XPAD R> BOUNDS                    ( idx . . )
      ?DO  I C@ 9 = IF 3 RSHIFT 1+ 3 LSHIFT     \ tab
          ELSE I C@ OVER CHARS CELL+ inbuf + C!
             1+ DUP max$ = IF CR ." Input line too long" THEN
          THEN
       LOOP R>                                  ( len eof )
   WHILE  inbuf ! process-line
   REPEAT  DROP
   closeout infile CLOSE-FILE DROP              \ close files
   gl-close ;

: DEX           ( <filename> -- )
( *G Convert a file or files to HTML. Output filenames are included in the     )
( ** source file.                                                              )
   /PARSE-S$ count (dex) ;

: q  ( <string> -- )
( *G Test a single line of text, outputting to the screen.                     )
   1 TO testing -1 PARSE  inbuf OVER !
   inbuf CELL+ SWAP MOVE  process-line ;

\ *W <hr /><p>This file generated by <a href="dexh.F">DexH</a></p>
\ *Z

module

\ also hidden
\ debug gl-create-entry
\ dex c:\test.f
