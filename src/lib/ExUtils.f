\ ExUtils.f           Extra utilities
\ Common routines needed by all modules

#ifndef ?exitm
macro ?exitm " if exitm then"
#then


\ String building routines
1024 128 * constant buffermax
buffermax cell+ Pointer BufferAddress

[undefined] tabsize [if]
8 value tabsize
[then]

0 value #chars  \ current number of characters on line
0 value #lines  \ number lines written
: +chars        ( n -- )
                +to #chars ;

: initbuffer    ( -- )
                bufferaddress off
                0 to #chars
                0 to #lines ;

: bufferfull?   ( size -- f )
                bufferaddress @ + buffermax > ;

: append        { addr cnt -- }
                cnt 0= ?exit
                cnt bufferfull? abort" Buffer full!"
                addr bufferaddress lcount + cnt move
                cnt bufferaddress +!
                cnt +chars ;

: cappend       ( char -- )
                1 bufferfull? abort" Buffer full!"
                bufferaddress c+lplace
                1 +chars ;

: intappend     ( n -- )    \ append an integer value
                cell bufferfull? abort" Buffer full!"
                bufferaddress lcount + !
                cell dup bufferaddress +!
                +chars ;

: "append       ( -- )
                [char] " cappend ;

: s"append      ( -- )
                [char] s cappend "append bl cappend ;

: z"append      ( -- )
                [char] z cappend "append bl cappend ;

: #append       ( n -- )
                (.) append bl cappend ;

: +crlf         ( -- )
                0x0D cappend 0x0A cappend
                0 to #chars    \ reset for start of line
                1 +to #lines ;

: append&crlf   ( addr cnt -- )
                append +crlf ;

\ Sonntag, Mai 30 2004 - 10:40 dbu
: relpath&append&crlf  ( addr cnt -- )
                &forthdir count MakePathRelativeTo count
                append&crlf ;

: +spaces       ( n -- )
                0max spcs swap append ;

: +tabs         ( n -- )
                tabsize * 0max +spaces ;

: append.l      ( addr cnt n -- ) \ justify to n length
                >r dup>r append r> r> swap - dup 0>
                if      +spaces
                else    drop
                then    ;

: thebuffer     ( -- addr cnt )
                bufferaddress lcount ;

: readline-memory { addr cnt \ str2 cnt2 -- addr2 cnt2 str2 cnt2 }
\ parse CRLF delimited strings in memory
\ addr2 cnt2 = line read minus crlf, str2 cnt2 = remaining buffer and count
                addr cnt 0x0D scan to cnt2 to str2
                cnt2 0>
                if      cnt cnt2 - to cnt
                        str2 cnt2 1 /string
                        dup
                        if      over c@ 0x0A =      \ line feed present?
                                if      1 /string   \ if so remove it
                                then
                        then    to cnt2 to str2
                then    addr cnt str2 cnt2 ;

: (fload-buffer)  { s1 c1 \ curstr curlen lcnt -- f }  \ compile a memory file
\ We need to save the string because if interpreting a line and a value is
\ left on the stack, e.g from "if", the system hangs somewhat
		0 to lcnt
                begin       c1
                while       1 +to lcnt
			    s1 c1 readline-memory to c1 to s1
                            2dup to curlen to curstr
                            ['] evaluate catch ?dup
                            if		nip nip new$ >r
					s" Compile error!\n" r@ place
					s" Error#: " r@ +place (.) r@ +place
					s" \nLine# " r@ +place
					lcnt (.) r@ +place
					s" : " r@ +place
					curstr curlen r@ +place
					s" \nSee W32F-Errors.htm for error descriptions" r@ +place
					true dup r> count ?MessageBox
					exit
			     then
		repeat      false ;

\ : (fload-buffer)  { s1 c1 -- }  \ compile a memory file
\ We need to save the string because if interpreting a line and a value is
\ left on the stack, e.g from "if", the system hangs somewhat
\                 begin       c1
\                 while       s1 c1 readline-memory to c1 to s1
\                             evaluate
\                 repeat      ;


: fload-buffer  ( addr cnt --  )
                TheBuffer (fload-buffer) drop ;

\ : ExecuteFile   { addr cnt hndl \ temp$ -- } \ open file using default application
\                 LMAXSTRING LocalAlloc: temp$
\                 s" file:\\" temp$ lplace
\                 addr cnt temp$ +lplace
\                 temp$ +lnull
\                 temp$ lcount hndl "Web-Link ;

: ExecuteFile   { addr cnt hndl \ temp$ -- } \ open file using default application
                max-path LocalAlloc: temp$
                addr cnt "path-only" temp$ place
                temp$ +NULL
                SW_SHOWNORMAL		                        \ nShowCmd
                temp$ 1+              \ default directory
                Null                        \ parameters
                addr cnt asciiz       \ file name to execute
                z" open"              \ operation to perform
                hndl                        \ parent
                Call ShellExecute 32 <=     \ error?
                s" Failed to execute file!" ?MessageBox ;

: more?         ( -- f )
                >in @ bl word swap >in ! c@ ;

: prognam>pad   ( -- )
                &prognam count "path-only" pad place pad ?+\ ;

: copy-clipboard  { str cnt \ hnd memptr -- }
                NULL Call OpenClipboard 0=  ?exit
                Call EmptyClipboard     0=  ?exit
                cnt 1+ GHND Call GlobalAlloc to hnd       \ allocate memory
                hnd Call GlobalLock to memptr          \ for data
                memptr 0= ?exit
                str memptr cnt move                   \ move the data
                hnd CF_TEXT Call SetClipboardData drop \ transfer to clipboard
                hnd Call GlobalUnlock drop
                Call CloseClipboard drop ;

((
: NoConsoleTitle     ( -- ) \ set console title text
\ Some apps use the console window text to identify W32F, as such other Forth apps
\ with hidden consoles are incorrectly identified
                    z" " conhndl Call SetWindowText drop ;
))

: >str		( n -- addr cnt ) \ converts n to counted string, return unique buffer
		(.) new$ dup>r place
		r@ +NULL
		r> count ;

\s
