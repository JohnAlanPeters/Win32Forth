\ $Id: HelpDexH.f,v 1.4 2011/11/18 11:06:43 georgeahubert Exp $

\ *! dexh-Helpdexh
\ *T Source documentation Extractor, HTML output
\ *Q Version 3
\ ** Primary contributor: Brad Eckert  brad1NO@SPAMtinyboot.com\n
\ ** Modified for use in Win32Forth by George Hubert and Dirk Busch\n
\ ** May 2008: modified for new Help + HTML4+CSS style sheets by Camille Doiteau

( *Q Abstract                                                                  )
( ** Dexh is a simple tool allowing to generate an html help page directly from)
( ** a source file, using its comments, slightly modified. It is inspired by   )
( ** MPE's DOCGEN. DexH can also be used to write articles about Forth         )
( ** featuring a mixture of documentation and source code. DexH is a standalone)
( ** program that processes a Forth source file.                               )

\ *S How to use dexh ?
\ *P Once the proper dexh commands are set in the comments of a source file, the
\ ** following command creates the html file from the source file : \n
\ ** \tDEX input_filename\d\n
\ ** or\n
\ ** \tDEXF\d (launches a file dialog to select the file to process)
\ *P The output file will be named input_filename\b.htm\d and will reside in the
\ ** same directory. You can move or rename it if needed.\n
\ *P With little effort, more sophisticated outputs can be obtained to suit your
\ ** needs (eg: several source files output to one html file) : check the file
\ ** Help\HelpCreateDexhDocs.f for an example.
\ *P The output is crude html code. Your html browser will use default settings
\ ** to display it. However, dexh invoques a CSS style sheet in the html header it
\ ** creates. Its name is "style.css". You can enhance the display by providing this
\ ** style sheet. You will find an example in help\html\style.css.

\ *S How to write comments that dexh will understand ?
\ *P Dexh uses "beginning-of-line commands" to describe how to display the comment
\ ** line and "in-line-commands" to add some more style.
\ *P The HelpDexh.f source itself contains many examples of use of theese commands.

\ *N "beginning-of-line commands"
\ *P Commands are embedded within comments. You can use either of the following
\ ** formats, starting at the first column. \n
\ ** \t( *? ... )  \d where *? is the command (followed by at least 1 space), or, simpler,\n
\ ** \t\\ *? ...\d \n
\ *P Available commands are :
\ *L
\ *| Command *? | Effect                                |
\ *| ** | continuation of P, E, G or B                  |
\ *| *T | Title (main title, at top of page)            |
\ *| *Q | "Quotation" or "Abstract" title (italics)     |
\ *| *S | Section         (title)                       |
\ *| *N | Sub-section     (sub-title)                   |
\ *| *A | Sub-Sub-section (sub-sub-title)               |
\ *| *P | Paragraph                                     |
\ *| *E | Paragraph which is a code example             |
\ *| *+ | Include folowing source code as text          |
\ *| *- | Turn off source code inclusion                |
\ *| *B | Bullet entry                                  |
\ *| *L | Table entries follow (**)                     |
\ *| *G | Glossary entry for the previous line          |
\ *| *R | raw LaTeX                                     |
\ *| *W | raw HTML                                      |

\ *P (**) Next lines must start with command *| and each table field
\ ** must be separated by | (vertical bar) and end in |
\ *P The commands *! *> *D and *Z (previously provided to handle filenames,
\ ** directories, etc) are no longer supported. They are harmless if
\ ** encoutered in a source. Theese command ids should not be re-used however.
\ ** The effect of command *A has been slightly modified to be only a level 4 title.


anew -DexH.f


\ *P Some files may use very long lines. Dexh handles lines to as long as 2000 chars.
\ ** You can allocate buffers for longer lines by changing the following line:
( *+ )
2000 CHARS CONSTANT max$
( *- )
CREATE inbuf    max$ 2 CELLS + ALLOT            \ current line
CREATE prevline max$ 2 CELLS + ALLOT            \ previous line
CREATE XPAD     max$ 2 CELLS + ALLOT            \ temporary

\ HTML needs some canned boilerplate. This is created by ,| since HTML
\ doesn't use | characters.
: (,$)  ( a len -- )  DUP C, 0 ?DO COUNT C, LOOP DROP ;
: ,|    ( <text> -- ) [CHAR] | WORD COUNT -TRAILING (,$) ;


CREATE DexHTMLheader
   ,| <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"                        |
   ,|     "http://www.w3.org/TR/html4/strict.dtd">                             |
   ,| <html>                                                                   |
   ,| <head>                                                                   |
   ,| <meta name="GENERATOR" content="DexH v03" />                             |
   ,| <title>                                                                  |
   0 C,
DexHTMLheader value HTMLheader

CREATE DexHTMLheaderA
   ,| </title>                                                                 |
   ,| <link rel="stylesheet" type="text/css" href="style.css">                 |
   ,| </head>                                                                  |
   ,| <body>                                                                   |
   0 C,
DexHTMLheaderA value HTMLheaderA

CREATE DexHTMLtrailer
   ,| </body></html>                                                           |
   0 C,
DexHTMLtrailer value HTMLtrailer


0 VALUE outfile                          \ The current output file
0 VALUE infile
0 VALUE echoing  0 value plain           \ Echo the code as output
0 VALUE mode
0 VALUE TableHead                        \ True for the first line of a table

( *P All output is via OUT and OUTLN, which can be sent to the screen for      )
( ** debugging purposes.                                                       )
( *+ )
0 VALUE testing                          \ screen is for testing
( *- )
: werr     ( n -- )      ABORT" Error writing file" ;
: out      ( a len -- )  testing IF TYPE    ELSE outfile WRITE-FILE werr THEN ;
: outln    ( a len -- )  testing IF TYPE CR ELSE outfile WRITE-LINE werr THEN ;
: boiler   ( addr -- )   BEGIN COUNT DUP WHILE 2DUP + >R outln R> REPEAT 2DROP ;

\ *N "in-line-commands"
\ *P Some characters (escaped by \) are provided that dexh will replace by html tags. For
\ ** instance the sequence \\tWORDS\\d will generate <code>WORDS</code>, and thus display
\ ** WORDS in a typewritter style like \tWORDS\d (Theese commands cannot be imbricated
\ ** however).
\ *P Examples:
\ *P "ax\\^2\\d + bx + w\\_0\\d = 0"   will display   "ax\^2\d + bx + w\_0\d = 0"\n
\ ** "Try \\bbold\d, \\iitalic \\dand \\ttypewriter.\\d"   will display   "Try \bbold\d, \iitalic \dand \ttypewriter\d."

\ *L
\ *| Command *? | Effect                          |
\ *| \\d        | Ends italic, superscript, etc.  |
\ *| \\i        | Italics                         |
\ *| \\b        | Bold                            |
\ *| \\t        | Typewriter                      |
\ *| \\^        | Superscript                     |
\ *| \\_        | Subscript                       |
\ *| \\n        | Line break                      |
\ *| \\r        | Horizontal rule                 |
\ *| \\p        | Page break                      |
\ *| \\\\       | \ character                     |

\ *P During htm file creation, some characters are automatically converted to html
\ ** sequences. They are < (&lt;) > (&gt;) " (&quot;) and © (&copy;)

VARIABLE bltally                                \ counts runs of blanks
VARIABLE thisfont                               \ current font attributes
VARIABLE escape                                 \ escape sequence in progress?
VARIABLE captive                                \ ESC sequence not allowed

: no-escape ( -- ) S" \" out  0 escape ! ;

: new-font  ( n -- ) \ switch to a new font
            thisfont @ SWAP thisfont !
            CASE
              [CHAR] i OF S" </i>"    out ENDOF
              [CHAR] b OF S" </b>"    out ENDOF
              [CHAR] t OF S" </code>" out ENDOF
              [CHAR] ^ OF S" </sup>"  out ENDOF
              [CHAR] _ OF S" </sub>"  out ENDOF
            ENDCASE ;

: outh      ( addr len -- ) \ HTMLized text output
	    999 bltally !
            BOUNDS
            ?DO
              i C@ escape @
              IF   CASE
                     [CHAR] \ OF               S" \"      out ENDOF
                     [CHAR] n OF               S" <br />" out ENDOF
                     [CHAR] r OF               s" <hr />" out ENDOF
                     [CHAR] i OF i C@ new-font S" <i>"    out ENDOF
                     [CHAR] b OF i C@ new-font S" <b>"    out ENDOF
                     [CHAR] t OF i C@ new-font S" <code>" out ENDOF
                     [CHAR] ^ OF i C@ new-font S" <sup>"  out ENDOF
                     [CHAR] _ OF i C@ new-font S" <sub>"  out ENDOF
                     [CHAR] d OF 0    new-font                ENDOF
                     no-escape I 1 out
                   ENDCASE 0 escape !
              ELSE CASE
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
              THEN
            LOOP
            escape @ IF no-escape THEN                   \ trailing \
            S" " outln ;

\ : lastchar ( a n -- a n c )
\    2DUP 1- CHARS + C@ ;

: line      ( -- a len )
            inbuf lcount 5 /STRING                       \ remove ( ** and ) or \ **
            inbuf cell+ c@ [CHAR] ( = IF lastchar [CHAR] ) = IF 1- THEN THEN
            -trailing ;

: _parse    ( $line char -- $line' $ )
            >R 2DUP R@ SKIP R> SCAN BL SCAN              \ parse out a substring
            2SWAP 2 PICK - ;

: table|    ( -- )                          \ add line to a table
            line
            begin [CHAR] | _parse BL skip 1- 0 max -trailing dup
		  if   TableHead
                       if   S" <th>" out outh S" </th>" outln
                       else S" <td>" out outh S" </td>" outln
                       then
                  else 2drop 2drop false to TableHead EXIT
                  then
            again ;

: end       ( -- ) \ insert end tags
            mode CASE
                   [CHAR] P OF s" </p>"       out ENDOF
                   [CHAR] E OF s" </pre>"     out ENDOF
                   [CHAR] B OF s" </li></ul>" out ENDOF
                   [CHAR] L OF s" </table>"   out ENDOF
                 ENDCASE
            BL to mode ;


: command   ( c -- )
   plain if s" </pre>" out 0 to plain then                  \ terminate plain text
   CASE
     [CHAR] * OF line outh ENDOF
     [CHAR] T OF end s" <h1>"    out line outh s" </h1>"        out ENDOF
     [CHAR] S OF end s" <h2>"    out line outh s" </h2>"        out ENDOF
     [CHAR] N OF end s" <h3>"    out line outh s" </h3>"        out ENDOF
     [CHAR] A OF end s" <h4>"    out line outh s" </h4><p>"     out [CHAR] P to mode ENDOF
     [CHAR] Q OF end s" <h3><i>" out line outh s" </i></h3><p>" out [CHAR] P to mode ENDOF
     [CHAR] P OF end s" <p>"     out line outh                      [CHAR] P to mode ENDOF
     [CHAR] E OF end s" <pre>"   out line outh                      [CHAR] E to mode ENDOF
     [CHAR] B OF mode [CHAR] B <>
                 if end s" <ul><li>" else s" </li><li>" then out
                 line outh                                          [CHAR] B to mode ENDOF
     [CHAR] G OF end s" <p><b><code>" out prevline lcount outh
                     s" </code></b><br>" out line outh              [CHAR] P to mode ENDOF
     [CHAR] W OF end line outln ENDOF
     [CHAR] + OF end s" <pre>"   out 1 to plain 1 to echoing ENDOF
     [CHAR] - OF end 0 to echoing ENDOF
     [CHAR] L OF end s" <table>" out 1 to TableHead                 [CHAR] L TO mode ENDOF
     [CHAR] | OF     S" <tr>"    out table| S" </tr>" outln ENDOF
   ENDCASE ;

: process-line ( -- )
            inbuf @ 3 >
            if   S" ( *" inbuf cell+ over compare 0=
                 S" \ *" inbuf cell+ over compare 0= or
                 inbuf @ 4 > if inbuf cell+ 4 + c@ bl = and then
            else 0
            then
            if   0 captive !
                 inbuf cell+ 3 chars + c@ command   \ command line
            else end echoing                        \ not a command line
                 if   plain 0=
                      if 1 to plain s" <pre>" out then
                      1 captive !
                      inbuf LCOUNT outh
                 then
            then
            inbuf prevline over @ cell+ move ;      \ save line as prevline
( *W <hr> )
( *S Glossary )

: ((dexh))  ( -- ) \ input and output files are opened and file-position set
            0 to testing                          \ output to file
            0 to echoing 0 to plain 0 to mode     \ reset modes
            0 escape !
            0 to TableHead                        \ init table header flag
            prevline max$ BLANK
            begin XPAD max$ infile read-line      \ read line
                  inbuf max$ BL FILL              \ convert tabs to spaces
                  abort" Error reading file"
                  >r >r 0 XPAD R> BOUNDS          \ idx . .
                  ?do  i c@ 9 =
                    if   3 RSHIFT 1+ 3 LSHIFT     \ tab
                    else i c@ over CHARS CELL+ inbuf + C!
                         1+ dup max$ =
                         if cr ." Input line too long" then
                    then
                  loop
                  r>                              \ len eof
                  while
                  inbuf ! process-line            \ process line
\ ??? should stop if \s encountered...
            repeat drop
            end
            HTMLtrailer boiler ;

CREATE $infile 250 allot         \ input source file name
CREATE $outfile 250 allot        \ output htm file name

: right$    ( addr cnt char -- addr' cnt' )
            \ Example: s" c:\dir\file.ext" ascii \ right$ gives "file.ext"
            \ Example: s" aaaa.ext" ascii \ right$ gives "aaaa.ext"
            >r swap over + over r> -scan ?dup
            if   rot swap - 1- swap 1+ swap
            else swap
            then ;

: (dexh)    ( -- ) \ filenames supposed set in $infile and $outfile
            $infile count r/o OPEN-FILE abort" Missing input file" to infile
            $outfile count w/o CREATE-FILE abort" Can't create file" to outfile
            HTMLheader  boiler
            $infile count [char] \ right$ out     \ title = source filename
            HTMLheaderA boiler
            ((dexh))
            outfile CLOSE-FILE drop
            infile CLOSE-FILE drop ;

: DEX       ( <sourcefilename> -- )
\ *G Build dexh doc from source "filename[.f]" : create doc file "filename.htm" in
\ ** same directory.
            BL parse 2dup lower                               \ handle filenames
            2dup $infile place $infile +null
            2dup [char] . right$ s" f" compare 0=
            if   2 -                                          \ remove ".f"
            else s" .f" $infile +place
            then
            $outfile place s" .htm" $outfile +place $outfile +null
            (dexh) ;

internal
in-application

FileOpenDialog DexFile  "Dex Forth File"  "Forth Files (*.f)|*.f|All Files (*.*)|*.*|"

in-system
external

: DEXF  ( -- )
\ *G Opens a file dialog to choose a source file and convert it to HTML. Output directory
\ ** is same as input directory. Output filename is same filename with .htm extension. The
\ ** source filename will be displayed in the title bar of Internet Explorer.
        conhndl start: DexFile count ?dup
        if   2dup $infile place $infile +null
             2 - $outfile place s" .htm" $outfile +place $outfile +null
             (dexh)
        else drop
        then ;

[defined] dexh [if]
\in-system-ok ' DEXF is dexh \ link into w32f console menu
[then]


cr .( DexH -- Document Extractor loaded )
cr
cr .( Usage: " DEX <filename> " to convert the file <filename> )
cr .( or     " DEXF " to choose a file and convert it. )

module

\ *W <hr>Document : Dexh-HelpDexH.htm -- 2006/11/08 -- win32forth team
\ *Z


\s
