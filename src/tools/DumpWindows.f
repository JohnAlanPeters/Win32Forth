\    File: DumpWindows.f
\  Author: Dirk Busch
\ Created: May 29th, 2003 - 11:37 - dbu
\ Updated: Samstag, Juli 22 2006 - 10:15 - dbu
\
\ This is an example of how to use a callback's in Win32Forth.
\ It dump's all Top-Level-Windows to the console.

anew -DumpWindows.f

INTERNAL

[UNDEFINED] zCount [if]
: zCount        ( a1 -- a2 len ) \ get length of zstring
    TRUE 2dup 0 scan nip - ;
[then]

: GetProcessId  { hWnd -- ProcessID }
\ *G Get ProcessId for given window.
        here hWnd call GetWindowThreadProcessId drop here @ ;

: GetThreadId   { hWnd -- ThreadID }
\ *G Get ThreadId for given window.
        0 hWnd call GetWindowThreadProcessId ;

2 CallBack: DumpWindowCallback { hWnd lParam \ buff$ -- int }
\ *G The callback function for EnumWindows().
\ *P CallBack: Need's the NUMBER OF PARAMETERS passed to the funtion by
\ **           Windows on TOS
\ **
\ ** CallBack: Creates TWO definitions!  The first has the name you specify,
\ **           and the second has the same name, prefixed with a '&' meaning
\ **           'address of' This second definition is the one which returns the
\ **           address of the callback, and must be passed to Windows.
        LMAXCOUNTED localalloc: buff$

        1 +TO FIRST-LINE?
        cr  FIRST-LINE? 3 u,.r space
        hWnd h.8 space
        hWnd GetProcessId h.8 space
        hWnd GetThreadId h.8 space

        LMAXCOUNTED buff$ hWnd
        call GetClassName 0<> if buff$ zcount type then cr 27 spaces

        LMAXCOUNTED buff$ hWnd
        call GetWindowText 0<> if buff$ zcount type else ." <no title>" then
        true ; \ default return value

: (.Windows)    ( -- )
\ *G Dump all Top-Level-Windows to the console.
        cr cr ." Top-Level-Windows:"
        cr ."   # hWnd     ProcId   ThreadId ClassName - WindowTitle"
        0 TO FIRST-LINE?
        0                     \ lParam is passed to the callback funtion by Windows
        &DumpWindowCallback   \ get address of the callback function
        Call EnumWindows drop \ and use it

        cr ." Total:" FIRST-LINE? 1 u,.r cr ;

' (.Windows) is .Windows

EXTERNAL

MODULE

.Windows
