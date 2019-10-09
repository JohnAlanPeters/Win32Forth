Anew -ReformatStrings.f \ May 3rd, 2013 Needs at least Win32Forth version 6.14

\ *D doc\
\ *T ReformatStrings.f -- A utillity to show a long string in short lines.


  ((  Disable or delete this line to generate a glossary
      cr cr .( Generating Glossary )
needs help\HelpDexh.f  DEX ReformatStrings.f
      cr cr .( Glossary created. ) chdir
      dir *.htm  abort     ))


[UNDEFINED] +trailing  [if]
: +trailing  ( addr cnt char -- adr2 cnt2 ) ( 6.15 version)
\ *G Remove leading a character from a string.
    locals| char |
    dup 0>
        if    begin   over c@ char =
              while   1 /string
              repeat
        then
 ;
[then]

: GetCol  ( - col )
\ *G Return the x position of the cursor in a line.
 getxy drop
 ;

: rep-emit   ( char n -- )
\ *G Emit a character n times.
    0 max 0
      ?do    dup emit
      loop
    drop
 ;

: emit-till  ( Char TillPosition -- )
\ *G  Emit a character till the specifed position.
    GetCol -  rep-emit ;

: ListItem   ( adr cnt max-on-line - )
\ *G Shows a string on the same line when the specifed position
\ ** will not be reached. It also takes the width of the console in account.\n
\ ** Otherwise a new line is started and then the string is shown.
     GetCol 2 pick + 1+ swap cols min >
       if    cr
       then
    type
 ;

: -ScanForBl ( adrEnd Size -- adrBackwards cntTillEnd )
\ *G Scan backwards till a space has been found.\n
\ ** cntTillEnd will be 0 when no space could be found.
    bl -scan ;

: -ScanFor{;, { adrEnd Size -- adrBackwards cntTillEnd }
\ *G Scan backwards till a '{' or a ';' or a ',' or a space
\ ** has been found.\n
\ ** cntTillEnd will be 0 when the backwards scan fails
    adrEnd Size ascii { -scan dup 0=     ( Switch colorization on again } )
        if    2drop  adrEnd Size  ascii ; -scan dup 0>
                   if    1 dup d+
                   else  2drop  adrEnd Size  ascii , -scan dup 0>
                              if    1 dup d+
                              else  2drop  adrEnd Size -ScanForBl
                              then
                   then
     then
;

defer BackwardScan ( adrEnd Size -- adrBackwards cntTillEnd ) ' -ScanForBl is BackwardScan
defer NewLine      ( -- ) ' cr is NewLine

: ListWords { adrEnd Size --  }
\ *G Lists all words in the buffer.
   Begin adrEnd Size  bl scan dup
   while >r adrEnd Size r@ - cr type  r>  1 /string  to Size to adrEnd
   repeat
  2drop
 ;

: .LeftAligned$ ( adr cnt max-#chars-on-one-line -- )
\ *G Shows a long string divided over several lines.\n
\ ** Each line will not be longer than the max-#chars-on-one-line\n
\ ** and takes the width of the console in account.\n
\ ** The BackwardScan and NewLine can be changed.
    2 max cols min 0 locals| Reducing MaxChar |
    begin    2dup MaxChar min
             dup MaxChar >=
                 if    2dup + over BackwardScan nip dup 0=
                           if    drop
                           else  nip
                           then
                 then
             dup>r bl +trailing  r> over - over +
             to Reducing dup
     while   NewLine type  Reducing /string
     repeat  4drop
 ;

: ltype...: ( adr cnt max-#char-on-one-line -- )
\ *G Shows a long string divided in to several lines.\n
\ ** Each line will not be longer than the max-#chars-on-one-line\n
\ ** and takes the width of the console in account.\n
\ ** A number of dots and a ':' will be added to the last line till
\ ** the position of max-#char-on-one-line is reached.
    dup>r .LeftAligned$ ascii . r> emit-till ." :"
 ;

\s Example:

20 constant #chars/line

s" Maximum number of work-items that can be specified in " temp$ place
s" each dimension of the work-group to clEnqueueNDRangeKernel" temp$ +place

: testltype...:
    4 1
       do    cr temp$ count i #chars/line * ltype...: 512 .
       loop
 ;

testltype...: abort

\s

\ *G \bOutput example:\d
\ *+

Maximum number of
work-items that can
be specified in
each dimension of
the work-group to
clEnqueueNDRangeKer
nel.................:512

Maximum number of work-items that can be
specified in each dimension of the
work-group to clEnqueueNDRangeKernel....:512

Maximum number of work-items that can be specified in each
dimension of the work-group to clEnqueueNDRangeKernel.......:512
\ *-
\ *Z Jos
