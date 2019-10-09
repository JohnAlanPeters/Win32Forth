\ $Id: Console2.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $
\    File: Console2.f
\  Author: Dirk Busch
\ Created: November 9th, 2003 - 10:32 dbu
\ Updated: November 9th, 2003 - 10:32 dbu
\
\ more Win32Forth Terminal I/O (Moved here from Primutil.f )
\ It couldn't be moved into Console.f because 'mouse-chain' must be defined
\ before this.

cr .( Loading... Console I/O Part 2)

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       new definition of key to support minimal mouse down events
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value mousex
0 value mousey
0 value mouseflags

(( MOUSEFLAGS info:

        3               both  buttons, currently assigned to abort

        1               left  button
        9 control       left  button
       13 control shift left  mouse button
        5         shift left  mouse button

        2               right button
       14 control shift right mouse button
       10 control       right mouse button
        6         shift right mouse button

))

  defer do-mabort

0 value mkstlin         \ hold the status of the current marked console text
0 value mkstcol
0 value mkedlin
0 value mkedcol
0 value mkorlin
0 value mkorcol

: mark-start    ( -- )          \ set a new start of marked console text
                mousex charWH >r /             to mkstcol
                mousey        r> / getrowoff + to mkstlin
                mousex charWH >r /             to mkedcol
                mousey        r> / getrowoff + to mkedlin
                mkstlin to mkorlin
                mkstcol to mkorcol
                mkstlin mkstcol mkedlin mkedcol markconsole ;

: mark-end      { \ lin col -- } \ set a new end of marked console text
                mousex charWH >r /             to col
                mousey        r> / getrowoff + to lin
                lin mkorlin =                   \ same line but earlier in line
                col mkorcol <= and
                lin mkorlin <  or               \ or on an earlier line
                if      lin to mkstlin
                        col to mkstcol
                        mkorlin to mkedlin
                        mkorcol to mkedcol
                else    lin to mkedlin
                        col to mkedcol
                        mkorlin to mkstlin
                        mkorcol to mkstcol
                then
                mkstlin mkstcol mkedlin mkedcol markconsole ;

: mark_all      ( -- )          \ makr all console text
                0 to mkstlin
                0 to mkstcol
                0 to mkedcol
                getxy nip getrowoff + 1+ to mkedlin
                mkstlin mkstcol mkedlin mkedcol markconsole ;

: mark-none     ( -- )          \ clear the marking of any console text
                0 to mkstlin
                0 to mkstcol
                0 to mkedcol
                0 to mkedlin
                mkstlin mkstcol mkedlin mkedcol markconsole ;

: marked?       ( -- f1 )       \ return TRUE if any text is marked
                mkstlin mkedlin <>
                mkstcol mkedcol <> or ;

: _do-mabort    ( -- )
                cr ." Aborted by Mouse!"
                abort ;

' _do-mabort is do-mabort

: ?mouse_abort  ( -- )          \ abort if both mouse buttons are down
                mouseflags 3 and 3 =
                if      do-mabort
                then    ;

new-chain mouse-chain  \ chain of things to do on mouse down
mouse-chain chain-add ?mouse_abort

defer auto_key  ' noop is auto_key      \ default to nothing
defer auto_key? ' noop is auto_key?     \ default to nothing

: _mouse-click  ( -- )
                mouse-chain do-chain ;

defer mouse-click       ' _mouse-click  is mouse-click

: process-mouse ( ekey -- )
        dup down_mask and       \ if mouse is DOWN
        IF      dup>r
                mouse_mask -1 xor and
                down_mask  -1 xor and to mouseflags
                x_key?
                IF      x_key word-split
                        to mousey               \ set y
                        to mousex               \ set x
                                                \ is mouse UP and DOWN
                        mouseflags 3 and 1 =    \ left mouse button
                        IF      r@ up_mask and  \ both masks is a mousemove
                                ?shift or
                                IF      mark-end
                                ELSE    mark-start
                                THEN
                        THEN
                        mouseflags 3 and 2 =    \ right mouse button
                        IF      mouse-click
                        THEN
                THEN    r>drop
        ELSE    dup up_mask and  \ is mouse UP
                IF      mouse_mask -1 xor and
                        up_mask    -1 xor and to mouseflags
                        x_key?
                        IF      x_key word-split
                                to mousey       \ set y
                                to mousex       \ set x
                                mkstlin mkstcol
                                mkedlin mkedcol d= \ pos NOT changed?
                                IF      mouse-click
                                ELSE    mark-end
                                THEN
                        THEN
                ELSE    mouse_mask -1 xor and to mouseflags
                        x_key?
                        IF      x_key word-split
                                to mousey       \ set y
                                to mousex       \ set x
                                mouse-click
                        THEN
                THEN
        THEN    ;

: _mkey         ( -- c1 ) \ get a key from the keyboard, and handle mouse clicks
        auto_key
        BEGIN   x_key
                dup  mouse_mask and             \ mouse operation
                IF      process-mouse
                        false
                THEN    ?dup
        UNTIL ;

: _mkey?        ( -- c1 ) \ check for key from keyboard, and handle mouse clicks
                x_key?
                dup mouse_mask and
                if      x_key drop            \ discard waiting key
                        process-mouse
                        false
                then    auto_key? ;

: ?mabort       ( -- )      \ give mouse a chance to recognize button press
                WINPAUSE ;

: _mcls         ( -- )
                x_cls
                mark-none ;

: _memit        ( c1 -- )               \ allow mouse to abort EMIT
                ?mabort x_emit ;

: _mtype        ( a1 n1 -- )            \ allow mouse to abort TYPE
                ?mabort "CLIP" x_type ;

: _mcol         ( n1 -- )
                x_col ;

: _m?cr         ( n1 -- )
                x_?cr ;

: _mcrtab       ( -- )
                x_crtab ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

action-of accept value defaultAccept

: _basic-forth-io  ( -- )               \ reset to Forth IO words

                unhide-console
                sizestate 1 =           \ if window is SIZE_MINIMIZED
                IF normal-console THEN

                ['] _mkey       is key
                ['] _mkey?      is key?
                defaultAccept   is accept

                ['] _memit      is emit
                ['] _mtype      is type
                ['] _mcrtab     is cr
                ['] _m?cr       is ?cr
                ['] _mcls       is cls
                ['] x_cls       is page
                ['] x_gotoxy    is gotoxy
                ['] x_getxy     is getxy
                ['] x_getcolrow is getcolrow
                ['] _mcol       is col

                focus-console
                tabing-off
                ;

defer basic-forth-io ' _basic-forth-io is basic-forth-io
forth-io-chain chain-add basic-forth-io

: forth-io      ( -- )
                forth-io-chain do-chain ;

forth-io        \ set the default I/O words

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       mouse typing
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: mxy>cxy       ( x y -- cx cy ) \ convert from mouse xy to character xy
                charwh rot 2>r / 2r> swap / ;

: char@screen   ( x y -- c1 )
                getmaxcolrow drop * + &the-screen + c@ ;

: word@mouse"   ( -- a1 n1 )
                &the-screen
                mousex mousey mxy>cxy getrowoff + getmaxcolrow drop * +
                2dup + c@ bl <>
        if      0 over
                ?do     over i + c@ bl =
                        if      drop i leave    \ found blank, leave loop
                        then
             -1 +loop                           \ a1=screen, n1=offset to blank
                getmaxcolrow * swap /string     \ -- a1,n1 of remaining screen
                bl skip                         \ remove leading blanks
                2dup bl scan nip -              \ return addr and length
        else    + 0
        then    ;

: word@mouse>keyboard ( -- )            \ send word at mouse to keyboard
                mouseflags double_mask and 0= ?exit \ double clicked mouse
                word@mouse" ?dup
                if      "pushkeys
                        bl pushkey    \ push a space
                else    drop
                then    ;

MOUSE-CHAIN CHAIN-ADD WORD@MOUSE>KEYBOARD

: line@mouse"   ( -- a1 n1 )
                &the-screen
                mousex mousey mxy>cxy getrowoff + swap >r   \ save x for later
                getmaxcolrow drop swap * + r>   \ -- a1,n1 the line upto mouse
                -trailing ;                     \ remove trailing blanks

: line@mouse>keyboard ( -- )            \ send the line at mouse to keyboard
                mouseflags 0xFF and 0x09 <> ?exit \ ctrl-left mouse button down
                                                  \ along with the control key
                line@mouse" ?dup
                if      "pushkeys
                        0x0D pushkey    \ automatically press Enter
                else    drop
                then    ;

MOUSE-CHAIN CHAIN-ADD LINE@MOUSE>KEYBOARD


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ allow the user to set the current display FONT
\ doesn't work so it's deprecated
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ WINLIBRARY GDI32.DLL
\ 1 proc GetDC
\ 2 proc ReleaseDC
\ 1 proc GetStockObject
\ 2 proc SelectObject
: set-font      ( font_value -- )
\                 conHndl call GetDC >r     \ get and save the Device Control #
\                 call GetStockObject       \ return the object information
\                 r@ call SelectObject drop \ selects the object
\                 r> conHndl call ReleaseDC drop
                ; DEPRECATED

\ : _>bold        ( -- )
\                 OEM_FIXED_FONT set-font ;
\
\ : _>norm        ( -- )
\                 ANSI_FIXED_FONT set-font ;
\
\ ' _>bold is >bold
\ ' _>norm is >norm

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ allow the user to hide the cursor
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ Note: The Line Editor (in Lineedit.f) is using set-cursor which
\ turn's on the cursor every time it's called. So a call to hide-cursor doesn't
\ show any effect at all.
1 proc HideCaret
: hide-cursor   ( -- )
                conHndl call HideCaret drop ;

synonym cursor-off hide-cursor

1 proc ShowCaret
: show-cursor   ( -- )
                conHndl call ShowCaret drop ;

synonym cursor-on show-cursor


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: minimize-console ( -- )
                SW_SHOWMINIMIZED conhndl call ShowWindow drop ;

\ Make console the foreground window. Ignore error which will occur if we are
\ running under Windows95 and we are already the foreground window.
0 proc GetActiveWindow
1 proc SetActiveWindow
1 proc SetForegroundWindow
2 proc GetWindowThreadProcessId
3 proc AttachThreadInput

: (SetWindow) { hWnd proc \ hActiveThreadID hLocalThreadID -- }
                call GetActiveWindow dup hWnd =
                -if  hWnd proc execute
                else swap call GetWindowThreadProcessId to hActiveThreadID
                     0 hWnd call GetWindowThreadProcessId to hLocalThreadID
                     1 hLocalThreadID hActiveThreadID Call AttachThreadInput
                     hWnd proc execute
                     0 hLocalThreadID hActiveThreadID Call AttachThreadInput
                then 3drop ;

: (SetForegroundWindow) ( hwnd -- )     \ w32f
\ *G The SetForegroundWindow function puts the thread that created the specified window
\ ** into the foreground and activates the window. Keyboard input is directed to the window,
\ ** and various visual cues are changed for the user. The system assigns a slightly higher
\ ** priority to the thread that created the foreground window than it does to other threads. \n
\ ** The foreground window is the window at the top of the Z order. It is the window that the
\ ** user is working with. In a preemptive multitasking environment, you should generally let the
\ ** user control which window is the foreground window. }n
\ ** Windows 98, Windows 2000: The system restricts which processes can set the foreground window.
\ ** A process can set the foreground window only if one of the following conditions is true: \n
\ ** The process is the foreground process. \n
\ ** The process was started by the foreground process. \n
\ ** The process received the last input event. \n
\ ** There is no foreground process. \n
\ ** The foreground process is being debugged. \n
\ ** The foreground is not locked (see LockSetForegroundWindow). \n
\ ** The foreground lock time-out has expired (see SPI_GETFOREGROUNDLOCKTIMEOUT in SystemParametersInfo). \n
\ ** Windows 2000: No menus are active. \n
\ ** With this change, an application cannot force a window to the foreground while the user is
\ ** working with another window. Instead, SetForegroundWindow will activate the window (see SetActiveWindow)
\ ** and call the FlashWindowEx function to notify the user. For more information, see Foreground and
\ ** Background Windows. \n
\ ** A process that can set the foreground window can enable another process to set the foreground window by
\ ** calling the AllowSetForegroundWindow function. The process specified by dwProcessId loses the ability to
\ ** set the foreground window the next time the user generates input, unless the input is directed at that
\ ** process, or the next time a process calls AllowSetForegroundWindow, unless that process is specified. \n
\ ** The foreground process can disable calls to SetForegroundWindow by calling the LockSetForegroundWindow function.
                ['] SetForegroundWindow (SetWindow) ;

: (SetActiveWindow) ( hWnd -- )
\ *G The SetActiveWindow function activates a window. The window must be attached to the calling thread's message queue. \n
\ ** The SetActiveWindow function activates a window, but not if the application is in the background. The window will be
\ ** brought into the foreground (top of Z order) if its application is in the foreground when the system activates the window. \n
\ ** If the window identified by the hWnd parameter was created by the calling thread, the active window status of the calling
\ ** thread is set to hWnd. Otherwise, the active window status of the calling thread is set to NULL. \n
\ ** By using the AttachThreadInput function, a thread can attach its input processing to another thread.
\ ** This allows a thread to call SetActiveWindow to activate a window attached to another thread's message queue.
                ['] SetActiveWindow (SetWindow) ;

: _foreground-console   ( -- )
                conhndl (SetForegroundWindow) ;

: _activate-console   ( -- )
                conhndl (SetActiveWindow) ;

defer foreground-console ( -- )
' _foreground-console is foreground-console

defer activate-console ( -- )
' _activate-console is activate-console


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       fill in some deferred words default functions
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

' x_gotoxy    is-default gotoxy
' x_getxy     is-default getxy
' x_getcolrow is-default getcolrow

