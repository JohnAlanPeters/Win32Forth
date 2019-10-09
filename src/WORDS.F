\ $Id: WORDS.F,v 1.8 2008/08/03 11:08:48 camilleforth Exp $

cr .( Loading WORDS...)

only forth also definitions

in-system

\ display words from one or two patterns

: horizontal-line ( -- )
                getcolrow drop getxy drop - 8 - 0max 8 /mod 0
                ?do     ." --------"
                loop    s" --------" drop swap type
                cr ;

INTERNAL        \ internal definitions start here

variable vocsave

create words-pocket MAXSTRING allot

: .voc-once     ( -- )
                vocsave @ ?dup
                if      cr ." ----------- " .NAME
                        horizontal-line
                        vocsave off
                then    ;

: match?        ( addr len -- f )
                2dup >r >r words-pocket count search nip nip
                pocket  c@
                if      r> r>    pocket count search nip nip and
                else    r> r> 2drop
                then       words-pocket c@ 0= or ;

0 value with-address?
true value with-tabs?

: (words)       { voc \ words-pad$ w#threads -- }
                MAXSTRING LocalAlloc: words-pad$
                voc dup voc#threads to w#threads
                dup voc>vcfa
                ?isclass not \ don't look through classes
        if      dup here 500 + w#threads cells move     \ copy vocabulary up
                voc>vcfa vocsave !
                begin   here 500 + w#threads largest dup
                while   dup l>name nfa-count 2dup "CLIP" words-pad$ place
                        words-pad$ uppercase count match?
                        if      .voc-once with-address?
                                if      2 pick link> dup here u>
                                        if      ." +"
                                        else    space
                                        then    ." 0x" h.8 ."  "
                                        30
                                else    20
                                then	-rot type
				with-tabs?
					if	dup #tab space ?cr
					else	drop cr
					then
                                1 +to words-cnt
                                start/stop
                                screendelay ms  \ slow down screen output
                        else    2drop
                        then
                        @ swap !
                repeat  2drop
        else    drop
        then    vocsave off ;

\ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
\ ++++++++++++ display windows constants containing adr,len ++++++++++++++
\ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

\ enum constants
\ int wcEnumWin32Constants(char* addr, int len, CALLBACKPROC* proc)
\ int callback(char* addr, int len, int value)

0 value constant-cnt
0 value constant-tot

3 CALLBACK: .WinConstantCount ( abs_adr len value -- f )
                3drop 1 +to constant-tot 1 ;

3 CALLBACK: .WinConstant ( abs_adr len value -- f )
                drop \ discard the constant's value
                2dup match?
                if   type 20 #tab space 20 ?cr
                     1 +to constant-cnt
                else 2drop
                then nuf? 0= ;

: count-constants ( -- n1 ) \ count the constants available to system
                constant-tot 0= \ only count if not counted...
                if   WinConlib load-dll 0=           \ Leave if wincon.dll
                     if 0 EXIT then                  \ isn't present
                     &.WinConstantCount 0 here CALL wcEnumWin32Constants DROP
                then constant-tot ;

EXTERNAL

: ORDER         ( -- ) \ display current vocabulary search order
                CR ." Context: " CONTEXT
                #VOCS 0
                DO      DUP @ ?DUP
                        IF      voc>vcfa .NAME 14 ?CR
                        THEN    CELL+
                LOOP    DROP
                CR ." Current: " CURRENT @  voc>vcfa .NAME    ;

: VOCS          ( -- ) \ display vocabularies
                cr ." Vocabularies    #Threads  #Words  #Average"
                cr VOC-LINK @
                BEGIN   DUP VLINK>VOC
                        dup voc>vcfa
                        ?isclass not \ don't look through classes
                        IF      dup voc>vcfa .NAME  18 #tab
                                dup voc#threads         dup>r 4 .r
                                        0 to words-cnt
                                        0 to header-cnt
                                    count-voc words-cnt dup   9 .r
                                                   10 * r> / 10 .r.1
                                cr
                        ELSE    DROP
                        THEN    @ DUP 0=
                UNTIL   DROP
                   ." -----------------------------------------"
                cr ." Total System Words: " count-words 11 .r
                cr ;

: .words        ( -- )
                count-words dup
                cr app-cnt  dup    6 u,.r - ."  Words in Application dictionary"
                cr                 6 u,.r   ."  Words in System dictionary"
                cr                 6 u,.r   ."  Words total in dictionaries"
                cr count-constants 6 u,.r   ."  Windows Constants available" ;

: CONSTANTS     ( -<optional_name>- )
                cr
                0 to constant-cnt
                WinConlib load-dll 0=               \ Leave if wincon.dll
                if ." WINCON.DLL missing" EXIT then \ isn't present

                cr ." ----------- Windows Constants "
                horizontal-line

                bl word uppercase count words-pocket place
                bl word uppercase drop
                &.WinConstant 0 here CALL wcEnumWin32Constants DROP

                cr horizontal-line
                cr ." Displayed " constant-cnt . ." of the "
                count-constants . ." Windows Constants in the system." ;

: with-address  ( -- )
                true to with-address? ;

INTERNAL

: _WORDS         ( -<optional_name>- ) \ WORDS partial-string will focus the list
                0 to words-cnt
                words-pocket off
                bl word uppercase c@
                if      pocket count words-pocket place
                        bl word uppercase drop
                        voc-link @
                        begin   dup vlink>voc ( #threads cells - )
                                ['] (words) catch
                                if      cr ." Interrupted!"
                                        drop TRUE       \ stop now
                                else    @ dup 0=
                                then
                        until   drop
                else    context @ ['] (words) catch
                        if      drop
                                cr ." Interrupted!"
                        then
                then    0 to with-address?
                base @ >r decimal

                cr horizontal-line
                ." Displayed " words-cnt . ." of the " count-words . ." words in the system."
                cr ." ** Use: WORDS <substring> to limit the list **"
                cr ." ** Use: CONSTANTS <substring> to display Windows Constants **"
                cr ." See also .loaded .deferred .file .fonts .free and more"
                r> base ! ;

EXTERNAL

: WORDS		( -<optional_name>- ) \ WORDS partial-string will focus the list
                true to with-tabs? _words ;

: on-allwords   { theCFA \ vocBuf -- }
                512 cells LocalAlloc: vocBuf
                voc-link @
                begin   dup vlink>voc
                        dup voc#threads >r
                        dup voc>vcfa @
                        dup   doClass =         \ don't look through classes
                        swap do|Class = or 0=   \ don't look through classes
                        if      vocBuf r@ cells move    \ copy vocabulary up
                                begin   vocBuf r@ largest dup
                                while   dup l>name theCFA execute
                                        @ swap !
                                repeat  2drop
                        else    drop
                        then    rdrop
                        @ dup 0=
                until   drop ;

in-application

MODULE          \ end of the module

