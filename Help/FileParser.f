\ $Id: FileParser.f,v 1.2 2011/11/18 01:32:27 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008


\ -----------------------------------------------------------------------------
\ Words to parse strings in a file
\ -----------------------------------------------------------------------------


anew -FileParser.f


\ primitives
\ ----------

8000 Constant MaxGetBuffer             \ max multiline string we can extract from file
Create GetBuffer MaxGetBuffer allot    \ buffer for extracted string
0 Value GetPointer                     \ pointer to end of extracted string
0 Value GetBufferFull                  \ pointer to end of string buffer

2000 Constant MaxLine                  \ room for lenghty lines
Create PCurrentLine MaxLine 1+ allot   \ current line : uppercased and cleaned
Create POriginalLine MaxLine 1+ allot  \ current line : original
0 Value ParsePointer                   \ current parsing position in line
0 Value ParseOldPointer                \ current parsing position in line
0 Value ParseEndLine                   \ pointer past end of current line

0 value ParseFileId                    \ fileid of file to parse
0 Value #ParseLine                     \ file line # currently parsed
0 Value #ParseFrom                     \ parse from line # ...
0 Value #ParseTo                       \ ... to line #

0 Value SkipComment?                   \ true if we want to skip Forth-like comments
0 Value CommentType                    \ type of comment actually skipped
0 Value NoComment?                     \ true if there was no comment to skip
0 Value EndOnEmptyLine?                \ if true parsing will stop at next empty line
0 Value EndOfParse                     \ true as soon as end of parse is reached
                                       \ (can be true eof, reached #ParseTo, or
                                       \ encountered \S and SkipComment is on)
create currentword 255 allot           \ current parsed word : original
create wordupper 255 allot             \ current parsed word : uppercased



: Get1Line      ( -- )  \ get exactly one line from file (maybe empty)
                \ if end of file is reached, EndOfParse value is set to -1
                0 to EndOfParse
                #ParseLine #ParseTo >=                      \ reached ParseTo ?
                if true to EndOfParse exit then             \ yes: pseudo end of file
                PCurrentLine MaxLine ParseFileId read-line  \ read line
                abort" Read error while parsing file"
                0= if drop -1 to EndOfParse exit then       \ true end of file
                dup 0= EndOnEmptyLine? and                  \ if stop on empty line
                if drop true to EndOfParse exit then
                >r                                          \ line count
                PCurrentLine r@                             \ replace tabs with BLs
                begin  0x09 scan dup
                while  over bl swap c!
                repeat 2drop
                PCurrentLine POriginalLine r@ cmove         \ copy original line
                BL PCurrentline r@ + c!                     \ replace 0D by BL
                PCurrentLine r@ upper                       \ uppercase line
                1 +to #ParseLine                            \ update linecount
                PCurrentLine r>
                over to ParsePointer                        \ reset line pointers
                +    to ParseEndLine ;


\ Before invoquing the file parser, you should :
\ - execute ParseInit (needs a fileid as input)
\ - set true or false to the value SkipComment? (default=true)
\ - set true or false to EndOnEmptyLine? (default=false) \ ??? not yet implemented
\ - if needed, use ParseFrom to set line# of beginning of parsing (default=1)
\ - if needed, use ParseTo to set line# of end of parsing (default=2147483647)
\
\ While parsing, you can get current line# with GetParseLine
\
\ After parsing is finished you should close the file whose id is in ParseFileId


: ParseInit     ( FileId -- ) \ fileid of an already opened file to parse
                0          to #ParseFrom
                2147483647 to #ParseTo
                0          to #ParseLine
                to ParseFileId                          \ save file id
                0. ParseFileId reposition-file          \ go to beginning of file
                abort" Reposition error in parsed file"
                Get1Line                                \ read first line
                GetBuffer MaxGetBuffer 1- +             \ (which init EndOfParse)
                to GetBufferFull                        \ init extracted string buffer
                false to EndOnEmptyLine?
                true to SkipComment? ;

: ParseFrom     ( #line -- ) \ set #line where parse will start
                0. ParseFileId reposition-file   \ reset file position to bof
                abort" Reposition error while parsing file"
                to #ParseFrom
                0 to #ParseLine                  \ set file pointer to line from
                begin  #ParseLine #ParseFrom <
                while  Get1Line                  \ end of file is not an error
                repeat ;

: ParseTo       ( #line -- ) \ set #line where parse will stop
                to #ParseTo ;

: GetParseLine  ( -- line# ) \ get current file line number
                #ParseLine ;

: GetParseLineLength ( -- len ) \ get current buffered line length
                ParseEndLine PCurrentLine - ;


\ parsing primitives and words
\ ----------------------------

: (append)      ( from to -- ) \ append from-to-to of line buffer to get buffer
                over - >r                             \ count
                GetPointer r@ 1+ + GetBufferFull >
                abort" extracted string buffer full"  \ check buffer full
                Bl GetPointer c!                      \ append a blank
                1 +to GetPointer
                PCurrentLine -                        \ append string
                POriginalLine +                       \ from original line
                GetPointer                            \ append string
                r@ cmove
                r> +to GetPointer ;                   \ set new pointer
                \ ??? if count = -1 : string buffer overflowed : see file-positions instead

: GetStringEOL  ( -- addr cnt ) \
                GetBuffer to GetPointer               \ init extracted string
                ParsePointer ParseEndLine (append)    \ put eol into GetBuffer
                GetBuffer GetPointer over -           \ give extracted string
                BL skip
                Get1Line ;                            \ set new values

: GetString     ( addr cnt -- addr' cnt' ) \ search the string delimiter addr cnt and
                \ give the string between the last parsing position and just before the
                \ delimiter. Then the parsing position is just after the delimiter string.
                \ The result is same as original in file (not uppercased)
                \ cnt' = 0 means EndOfParse has been reached without match
                \ Note: Search also in comments, whatever SkipComment? is,  so that
                \       we can find ends of comments
                \ Note: If wanting to extract "text" from s" text" or similar, we can
                \       assume that, since we are starting from s", we won't have
                \       comments until "
                2dup upper \ ??? BL skip ??? not -trailing
                GetBuffer to GetPointer                       \ init extracted string
                begin ParsePointer ParseEndLine over - 1+     \ search for delimiter in
                      BL skip                                 \ remaining line
                      2over
                      search
                      if   ParsePointer 2 pick (append)       \ found: append to GetBuffer
                           drop + to ParsePointer drop        \ update line pointer
                           GetBuffer GetPointer over -        \ exit with extracted string
                           BL skip
                           exit
                      else ParsePointer ParseEndLine (append) \ not found: append eol
                           2drop
                      then
                      Get1Line
                      EndOfParse                              \ retry until end of parse
                until
                drop 0 ;                                      \ never found

: SkipString    ( addr cnt -- flag ) \ skip until just after the delimiter addr cnt
                \ Flag=0 : not found & endofparse
                GetString nip 0<> ;

\ Note: we could define SearchString, similar to GetString but not filling the
\       GetBuffer. This would allow to search any string anywhere without the risk
\       of buffer overflow. If defined, SkipString should use SearchString instead
\       of GetString. However SearchString would also search comments. It is safer
\       to make a loop on GetWord


: SkipComment   ( -- ) \ skip Forth-like comments, handles :
                \ comments to end of file: \S
                \ comments to eol: \ // -- <A
                \ multiline comments: () (()) comment:comment; /**/ (**) DOCENDDOC
                0 to CommentType
                -1 to NoComment?
                wordupper count s" \S" compare 0=
                if   true to EndOfParse
                else wordupper count s" \"  compare 0=
                     wordupper count s" //" compare 0= or
                     wordupper count s" --" compare 0= or
                     wordupper count s" <A" compare 0= or
                     if   Get1Line 0 to NoComment?
                     else wordupper count s" (" compare 0=
                          if   1 to CommentType 0 to NoComment?
                          else wordupper count s" ((" compare 0=
                               if   2 to CommentType 0 to NoComment?
                               else wordupper count s" COMMENT:" compare 0=
                                   if   3 to CommentType 0 to NoComment?
                                    else wordupper count s" /*" compare 0=
                                         if   4 to CommentType 0 to NoComment?
                                         else wordupper count s" (*" compare 0=
                                              if   5 to CommentType 0 to NoComment?
                                              else wordupper count s" DOC" compare 0=
                                                   if   6 to CommentType 0 to NoComment?
                then then then then then then then then
                CommentType 0<>
                if   \ we are in a multiline comment
                     CommentType
                     Case
                       1 of s" )"        endof
                       2 of s" ))"       endof
                       3 of s" COMMENT;" endof
                       4 of s" */"       endof
                       5 of s" *)"       endof
                       6 of s" ENDDOC"   endof
                     EndCase
                     GetString 2drop
                     0 to CommentType
                then ;

: GetWord       ( -- addr cnt ) \ parse next word from current parsing position,
                \ update parsing position just after word.
                \ cnt = 0 means EndOfParse has been reached
                \ Note: the result is same as original in file (not uppercased).
                \ Note: words are delimited by BL, tab, eol or eof
                \       (a word is assumed not to overlap on next line)
                begin
                  \ feed until beginning of next word if any
                  begin ParsePointer ParseEndLine over - \ current remaining line as addr cnt
                        dup 0>                           \ if not eol
                        if    bl skip                    \ skip heading bls
                              over to ParsePointer
                        then
                        nip 0 <=                         \ reached eol anyway ?
                        EndOfParse not and               \ and not end of parse
                        while
                        Get1Line                         \ try a new line
                  repeat
                  EndOfParse if ParsePointer 0 exit then \ end of parse ==> failed

                  \ here we are sure that we have at least one word in current line
                  ParsePointer to ParseOldPointer
                  ParsePointer ParseEndLine over -       \ parse it
                  bl scan drop to ParsePointer
                  ParseOldPointer ParsePointer over -
                  -trailing
                  2dup wordupper place                   \ save uppercased one
                  swap PCurrentLine -                    \ save original one
                  PoriginalLine + swap
                  currentword place

                  SkipComment?
                  if   SkipComment
                  else currentword count exit            \ don't skip comment ==> found
                  then

                  \ here we come back from SkipComment
                  NoComment?
                  if currentword count exit then         \ no comments ==> found
                  EndOfParse
                  if ParsePointer 0 exit then            \ end of parse ==> failed
                again ;      \ was a comment & not eop, check for any other comment


: SearchWord    ( addr count -- flag ) \ Search next word given by addr cnt.
                \ flag = 0 means not found and EndOfParse has been reached
                \ If SkipComment? is on, Forth-like comments are skipped
                \ Note: words are delimited by BL or eol or eof
                \       (a word is assumed not to overlap on next line)
                2dup upper -trailing BL skip
                begin  GetWord
                       nip 0= if 2drop 0 exit then    \ end of parse ==> failed
                       2dup wordupper count
                       compare 0=                     \ use uppercased version
                       if 2drop -1 exit then          \ same ==> found
                again ;



\ -----------------------------------------------------------------------------
\ Tests and demos : uncomment one of them and fload
\ -----------------------------------------------------------------------------


\ Test & demo : primary tests "by hand"   (not a demo, don't use)
\ -------------------------------------
((
\ s" toto tvn| tyt|y| synonym hhh ggg ( comment )" PCurrentLine swap cmove ( lenght 44)
s" toto tvn| tyt|y| ( comment hhh ) synonym hhh" PCurrentLine swap cmove
: show ( --) cr Pcurrentline 45 type ;
show
ParseInit2     (ParseInit2 and Get1Line2 must be written without file read)
))


\ Test & demo : Extract all line and multiline comments of a file
\ ---------------------------------------------------------------

\ Note: we can also extract dexh-like comments, this would make possible to
\ start a dexh comment elsewhere than at the beginning of a line
((
create parsefile 200 allot

: GetComments   ( -- )
                s" gdiPen.f" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                false to SkipComment?                  \ don't skip comments
                begin GetWord ?dup
                      while
                      2dup s" (" compare 0=            \ multiline ( ... )
                      if s" )" GetString cr type then
                      s" \" compare 0=                 \ to eol
                      if GetStringEol cr type then
                repeat drop
                ParseFileId close-file drop ;
))

\ Test & demo : Extract all  ( ... )  { ... }  \ ... comments for a word
\ ----------------------------------------------------------------------

\ Extract all types of comments from a given word and until the first non comment word.
\ In this example, the line number where the word is defined is used too.
((
create parsefile 200 allot

: GetLineComments ( addr cnt #line -- )
                s" fileparser.f" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                false to SkipComment?                      \ don't skip comments
                ParseFrom                                  \ point to line to explore
                SearchWord 0=
                abort" check word and line number"
                begin GetWord ?dup
                      while
                      2dup s" \" compare 0=
                      if   GetStringEol cr ." \ " type
                      else 2dup s" (" compare 0=
                           if   s" )" GetString cr ." ( " type ." ) "
                           else 2dup s" {" compare 0=
                                if   s" }" GetString cr ." { " type ." } "
                                else 2drop ParseFileId close-file drop exit
                      then then then
                      2drop
                repeat drop
                ParseFileId close-file drop ;

s" Get1Line" 45 GetLineComments     \ check line before running
s" SearchWord" 257 GetLineComments  \ check line before running
))

\ Test & demo : Getting text in s" text" quoted string
\ ----------------------------------------------------
((
create parsefile 200 allot
create squote 2 c, ascii S c, ascii " c,
create quote  2 c, ascii " c, bl c,

: GetQuote      ( -- )
                s" FileParser.f" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                true to SkipComment?
                begin GetWord ?dup
                      while
                      2dup upper
                      squote count compare 0=
                      if quote count GetString cr type then
                repeat drop
                ParseFileId close-file drop ;
))

\ Test & demo : Getting all synonyms in a file
\ --------------------------------------------

\ Notice that we set SkipComments to false because in this file we encounter
\ some DEFINITIONS of comments, eg ": ( ...", so we don't want the "(" to be
\ interpreted as a comment. This is a flaw in the precise case of comment.f
\ We could, in SkipComment, check if previous word is ":" but it is not worth it
((
create parsefile 200 allot

: Synonyms      ( -- )
                s" comment.f" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                false to SkipComment?
                begin s" Synonym" SearchWord
                      while
                      GetWord cr ." Word " type
                      GetWord    ."  is synonym of " type
                                 ."  at line " #ParseLine .
                repeat
                ParseFileId close-file drop ;
))

\ Test & demo : Search if method Classinit: belongs to class GDIPen
\ -----------------------------------------------------------------
((
create parsefile 200 allot
0 Value InClass?

: IsMethod      ( -- )
                s" GDIPen.f" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                true to SkipComment?
                false to InClass?
                begin GetWord ?dup
                      while
                      2dup upper
                      2dup s" :CLASS"  compare 0= >r       \ scan for GDIPen on
                      2dup s" :OBJECT" compare 0= r> or >r
                      2dup s" |CLASS"  compare 0= r> or
                      if   GetWord
                           2dup upper
                           s" GDIPEN"  compare 0=
                           if true to InClass?
                      then then

                      2dup s" ;CLASS"  compare 0= >r       \ check if GDIPen off
                      2dup s" ;OBJECT" compare 0= r> or
                      InClass? and
                      if false to InClass? then

                      s" CLASSINIT:"   compare 0=           \ method match ?
                      InClass? and
                      if cr ." GDIPen's Classinit: = line " #ParseLine . exit then
                repeat drop
                ParseFileId close-file drop ;
))

\ Test & demo : Search all methods and ivars of class GDIPen
\ ----------------------------------------------------------
((
create parsefile 200 allot
0 Value InClass?

: MethodIvar    ( -- )
                s" GDIPen.f" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                true to SkipComment?
                false to InClass?
                begin GetWord ?dup
                      while
                      2dup upper
                      2dup s" :CLASS"  compare 0= >r       \ scan for GDIPen on
                      2dup s" :OBJECT" compare 0= r> or >r
                      2dup s" |CLASS"  compare 0= r> or
                      if   GetWord
                           2dup upper
                           s" GDIPEN"  compare 0=
                           if true to InClass?
                      then then

                      2dup s" ;CLASS"  compare 0= >r       \ check if GDIPen off
                      2dup s" ;OBJECT" compare 0= r> or
                      InClass? and
                      if false to InClass? then

                      InClass?                             \ get methods & ivars
                      if   2dup s" :M"    compare 0=
                           if GetWord cr ." Method:        " type then
                           2dup s" BYTES" compare 0=
                           if GetWord cr ." Bytes Ivar: " type then
                           2dup s" BYTE"  compare 0=
                           if GetWord cr ." Byte Ivar:  " type then
                           2dup s" BITS"  compare 0=
                           if GetWord cr ." Bits Ivar:  " type then
                           2dup s" SHORT" compare 0=
                           if GetWord cr ." Short Ivar: " type then
                           2dup s" INT"   compare 0=
                           if GetWord cr ." Int Ivar:   " type then
                           2dup s" DINT"  compare 0=
                           if GetWord cr ." DInt Ivar:  " type then
                      then
                      2drop
                repeat drop
                ParseFileId close-file drop ;
))

\ Test & demo : reading a TV-structure-text-file
\ ----------------------------------------------

\ Lines in such a file have the following format :
\             2   tvn|   name|    tvd| data|  \ comment
\ Comments and empty lines are allowed, "|" are allowed in name and data
\ provided that they are not followed by a blank
((
create parsefile 200 allot
create buf1 200 allot
create buf2 200 allot
create buf3 200 allot

: testTV        ( -- )
                s" hdb\test.tv" parsefile place parsefile +null
                parsefile count r/w open-file
                drop ParseInit
                true to SkipComment?
                begin GetWord ?dup
                      while
                      2dup upper
                      buf1 place
                      s" TVN|" SearchWord if s" | " GetString buf2 place then
                      s" TVD|" SearchWord if s" | " GetString buf3 place then
                      cr ." TVdepth: " buf1 count evaluate .
                         ."  TVname: " buf2 count type
                         ."  TVdata: " buf3 count type
                repeat drop
                ParseFileId close-file drop ;
))


\s

