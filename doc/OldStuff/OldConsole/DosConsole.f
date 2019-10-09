\ DOSConsole.f      Basic DOS Console for kernel


anew -DOSConsole.f


\ ------------------------------------------------------------------------------
\ basic DOS console for kernel       -        d_ prefix stands for "DOS"
\ ------------------------------------------------------------------------------

0 PROC AllocConsole              \ kernel's console (APIs from KERNEL32.DLL)
2 PROC SetConsoleMode
1 PROC GetStdHandle
5 PROC WriteConsoleA
4 PROC PeekConsoleInputA
0 PROC FreeConsole
2 Proc GetNumberOfConsoleInputEvents
4 Proc ReadConsoleInputA

0 VALUE INH    0 to INH         \ console input handle
0 VALUE OUTH   0 to OUTH        \ console output handle
CREATE INP_REC  10 cells ALLOT  \ input_record for PeekConsoleInput
VARIABLE DOSCHAR -1 DOSCHAR !   \ current char buffer


: d_INIT-CONSOLE ( -- flg ) \ init kernel's DOS console, ff if already inited
                OUTH if 0 exit then
                Call AllocConsole drop          \ alloc the character mode cons.
                STD_OUTPUT_HANDLE
                Call GetStdHandle to OUTH       \ get output handle
                STD_INPUT_HANDLE
                Call GetStdHandle to INH        \ get input handle
                0                               \ mode: char/char ; no echo
                INH
                Call SetConsoleMode drop
                -1 ;                            \ true flag : ok

: d_UNINIT-CONSOLE ( -- ) \ free the character-mode console
                INH 0<>
                if   Call FreeConsole drop
                     0 to INH 0 to OUTH
                then ;

: d_TYPE        ( addr cnt -- ) \ type a string
                0                               \ reserved : null
                0 >r RP@                        \ pointer to addr # chars read
                2swap swap                      \ count and addr
                OUTH                            \ handle of console output
                Call WriteConsoleA drop
                r>drop ;

: d_EMIT        ( char -- ) \ emit a character
                SP@ 1 d_TYPE drop ;

: d_CR          ( -- ) \ emit a carriage return
                13 d_EMIT 10 d_EMIT ;

: d_EKEY	( -- u ) \ get extended char
		0 >r RP@
                2
                INP_REC
                INH
                Call ReadConsoleInputA drop
                r>drop
                INP_REC w@ KEY_EVENT <> if FALSE exit then
                [ INP_REC 14 + ] LITERAL w@                  \ AsciiChar
                [ INP_REC 12 + ] LITERAL w@  16 lshift or    \ wVirtualScanCode
                [ INP_REC 04 + ] LITERAL c@  24 lshift or ;  \ bKeyDown

: d_EKEY>CHAR   ( u -- u false | char true ) \ is char ?
		dup 0xFF000000 AND 0=  if FALSE    exit then
		dup 0x000000FF AND dup if nip TRUE exit then
		drop FALSE ;

: d_KEY? 	( -- flag ) \ is a char (ie key pressed) available ?
                DOSCHAR @ 0 > IF TRUE exit then
                begin 0 >r RP@
                      INH
                      Call GetNumberOfConsoleInputEvents drop
                      r>
                      while                          \ loop while events present
                      d_EKEY d_EKEY>CHAR             \ exit if event is a valid char
                      if DOSCHAR ! TRUE exit then
		      drop
                repeat FALSE ;

: d_KEY 	( -- char ) \ get key from keyboard
		DOSCHAR @ 0>
		if DOSCHAR @ -1 DOSCHAR ! exit then
		begin d_EKEY d_EKEY>CHAR
                      0= while
		      drop
		repeat ;

: d_ACCEPT      ( c-addr nbmax -- nbread ) \ accept a string
                >r 0                                 \ current char count
                begin
                  d_KEY dup 13 <> while
                  dup 8 =
                  if   drop dup 0>
                       if   1- 8 d_EMIT BL d_EMIT 8 d_EMIT
                       else 7 d_EMIT
                       then
                  else over r@ < over 32 >= and
                       if   dup d_EMIT 2 pick 2 pick + c! 1+
                       else drop 7 d_EMIT
                       then
                  then
                repeat
                drop swap r> 2drop ;


\ ------------------------------------------------------------------------------
\ tests
\ ------------------------------------------------------------------------------

: test          begin key? if key cr dup . dup emit 27 = else 0 then until ;


: K_NOOP0 2DROP 0 ;
: K_NOOP1 0 ;
: K_NOOP2 0 0 ;

: DosConsole    ( -- ) \ switch to DOS console functions
			['] NOOP         IS INIT-CONSOLE-REG  \ no
                ['] d_Init-Console       IS INIT-CONSOLE
                        ['] NOOP         IS INIT-SCREEN
                ['] d_KEY                IS KEY         \ init defered
                ['] d_KEY?               IS KEY?
                ['] d_ACCEPT             IS ACCEPT
                        ['] DROP         IS PUSHKEY
                        ['] 2DROP        IS "PUSHKEYS
                        ['] FALSE        IS SHIFTMASK
                        ['] NOOP         IS CLS
                ['] d_EMIT               IS EMIT
                ['] d_TYPE               IS TYPE
                ['] d_CR                 IS CR
                        ['] DROP         IS ?CR
                        ['] NOOP         IS CONSOLE     \ no  ( NewConsole )
                        ['] 2DROP        IS GOTOXY
                        ['] K_NOOP2      IS GETXY
                        ['] K_NOOP2      IS GETCOLROW
                        ['] K_NOOP1      IS SIZESTATE   \ no  ( ConsoleWindow.WindowState )
                        ['] 4DROP        IS MARKCONSOLE \ no  ( 2swap swap GoToXY:cmd swap Select: cmd )
                        ['] NOOP         IS CURSORINVIEW   \ no  ( does nothing ??? AutoScroll: cmd )
                        ['] 2DROP        IS FGBG!          \ using foreground/background color_objects
                        ['] DROP         IS FG@
                        ['] DROP         IS BG@
                        ['] K_NOOP2      IS CHARWH      \ ( cmd.HorzLine cmd.VertLine )
                        ['] 2DROP        IS SETCHARWH   \ no ( change the font )
                        ['] 2DROP        IS SETCOLROW   \ no ( resize ConsoleWindow )
                        ['] DROP         IS SET-CURSOR  \ no  big-cursor, norm-cursor ???
                        ['] K_NOOP1      IS GET-CURSOR  \ no
                        ['] DROP         IS SETROWOFF   \ no
                        ['] K_NOOP1      IS GETROWOFF   \ no
                        ['] K_NOOP2      IS GETMAXCOLROW   \ max console size - see wrapper???
                        ['] 2DROP        IS SETMAXCOLROW   \ check wrapper???
                        ['] FALSE        IS &THE-SCREEN   \ #print-screen in dc.f will not work
                        ['] FALSE        IS conHndl
                        ['] NOOP         IS copy-console
                        ['] NOOP         IS cut-console
                        ['] NOOP         IS mark-all
                        ['] NOOP         IS paste-load
		;

: NewConsole 	( -- ) \ switch to new console functions
                    ['] NOOP        IS INIT-CONSOLE-REG  \ no
                ['] c_Init-Console  IS INIT-CONSOLE
                ['] c_INIT-SCREEN   IS INIT-SCREEN
                ['] c_key           IS KEY
                ['] c_key?          IS KEY?
                ['] c_accept        IS ACCEPT
                ['] c_pushkey       IS PUSHKEY
                ['] c_"pushkeys     IS "PUSHKEYS
                ['] X_SHIFTMASK     IS SHIFTMASK
                ['] c_cls           IS CLS
                ['] c_emit          IS EMIT
                ['] c_type          IS TYPE
                ['] c_cr            IS CR
                ['] c_?cr           IS ?CR
                    ['] NOOP        IS CONSOLE     \ no  ( NewConsole )
                ['] c_gotoxy        IS GOTOXY
                ['] c_getxy         IS GETXY
                ['] c_getcolrow     IS GETCOLROW
                    ['] K_NOOP1     IS SIZESTATE   \ no  ( ConsoleWindow.WindowState )
                    ['] 4DROP       IS MARKCONSOLE \ no  ( 2swap swap GoToXY:cmd swap Select: cmd )
                    ['] NOOP        IS CURSORINVIEW   \ no  ( does nothing ??? AutoScroll: cmd )
                ['] c_FGBG!         IS FGBG!          \ using foreground/background color_objects
                ['] c_FG@           IS FG@
                ['] c_BG@           IS BG@
                ['] c_CharWH        IS CHARWH      \ ( cmd.HorzLine cmd.VertLine )
                    ['] 2DROP       IS SETCHARWH   \ no ( change the font )
                    ['] 2DROP       IS SETCOLROW   \ no ( resize ConsoleWindow )
                    ['] DROP        IS SET-CURSOR  \ no  big-cursor, norm-cursor ???
                    ['] K_NOOP1     IS GET-CURSOR  \ no
                    ['] DROP        IS SETROWOFF   \ no
                    ['] K_NOOP1     IS GETROWOFF   \ no
                    ['] K_NOOP2     IS GETMAXCOLROW   \ max console size - see wrapper???
                    ['] 2DROP       IS SETMAXCOLROW   \ check wrapper???
                ['] c_&TheScreen    IS &THE-SCREEN   \ #print-screen in dc.f will not work
                ['] NewConHndl      IS conHndl
                ['] c_copy-console  IS copy-console
                ['] c_cut-console   IS cut-console
                ['] c_mark-all      IS mark-all
                ['] c_paste-load    IS paste-load
                ;

: new>dos       ( -- ) \ activate DOS Console
                \ kill newconsole ???
                DosConsole
                init-console drop
                ;

: dos>new       ( -- ) \ activate new console
                d_uninit-console
                NewConsole
                init-screen
                SetFocus: ConsoleWindow
                ;
\s
\ ------------------------------------------------------------------------------


((
\ Old versions

1 PROC FlushConsoleInputBuffer
5 PROC ReadConsoleA

: d_KEY         ( -- key ) \ get key from keyboard
                0                               \ reserved : null
                0 >r RP@                        \ pointer to addr # chars read
                1                               \ # chars to read
                0 >r RP@                        \ pointer to buffer for char
                INH                           \ handle of console input
                Call ReadConsoleA drop
                r> r>drop ;

: d_KEY?       ( -- flag ) \ is a char available ?
                \ NOTE : due to auto scroll, CR is a special char. When used
                \        in START/STOP, you should use any key except CR to
                \        stop scrolling and only CR to start again.
                0 >R RP@                        \ pointer to addr # recs read
                1                               \ # record to read
                INP_REC 7 cells erase
                INP_REC                         \ pointer to input record
                INH                           \ handle of console input
                Call PeekConsoleInputA drop
                INP_REC w@ KEY_EVENT =          \ char available if key_event
                r> 0<> AND                      \ and at least 1 record read
                if   INP_REC 14 + w@ 13 =       \ if key is auto CR / SCROLL
                     if   FALSE                 \ ff and drop it
                          INH Call FlushConsoleInputBuffer drop
                     else TRUE
                     then
                else FALSE
                then ;

: BCKSPC        ( n -- ) \ emit n backspaces
                dup if 1- 8 EMIT BL EMIT 8 EMIT then ;

: d_ACCEPT      ( c-addr nbmax -- nbread ) \ accept a string
                \ NOTE: ACCEPT automatically returns, without typing CR,
                \       when nbmax # chars is reached. This is not a
                \       problem if nbmax is choosen large enough.
                >r 0
                begin
                  dup r@ < while
                  d_KEY dup 255 u>      \ for hyphens
                  if   drop
                  else dup 27 =
                       if   drop ( n BCKSPC) begin BCKSPC dup 0= until
                       else dup 8 =
                            if   drop BCKSPC
                            else dup 13 =
                                 if drop swap r> 2drop EXIT then
                                 BL MAX dup d_EMIT 2 pick 2 pick + C! CHAR+
                  then then then
                repeat
                swap r> 2drop ;
))

