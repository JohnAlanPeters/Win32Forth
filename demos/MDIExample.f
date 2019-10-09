\ MDIExample.f        Example of an MDI application using EditControls by Rod Oakford
\                     Icon resource 100 and 101 needed in .exe
\                     otherwise default windows icon used

anew -MDIExample.f

INTERNAL
EXTERNAL

\- Turnkeyed?   : Turnkeyed? ( -- f )   sys-free 0= ;   \ for compatability with v5.2
[UNDEFINED] Messagebox [IF]
: MessageBox  ( szText szTitle style hOwnerWindow -- result )
        >r  -rot swap r>
        Call MessageBox ;   [THEN]

\ *D doc\classes\
\ *> mdi
\ *S Example (demos\MdiExample.f)
\ *+

Needs MDI

0 value CurrentWindow
0 value ActiveChild
Create CurrentFile 256 allot


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Messages and Dialogs
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ?SaveMessage ( -- n )   \ IDYES, IDNO or IDCANCEL
        s" Do you want to save " pad place
        CurrentFile count "to-pathend" pad +place
        s"  ?" pad +place  pad +NULL
        pad 1+ z" MDI Example"
        [ MB_ICONEXCLAMATION  MB_YESNOCANCEL or ] literal
        NULL MessageBox ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Simple TextBox to place on child windows
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class TextBox   <Super Control

:M Start: ( Parent -- )
        to Parent
        z" EDIT" Create-Control
        ;M

:M WindowStyle: ( -- style )
        [ WS_VISIBLE WS_CHILD or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ] literal
        ;M

;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Define application menu
\
\ The frame window of an MDI application should include
\ a menu bar with a Window menu. The Window menu should
\ include command items that arrange the child windows
\ within the client window or that close all child windows.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: NewID ( <name> -- )
        defined
        IF  drop
        ELSE NextID swap count ['] constant execute-parsing
        THEN ;

IdCounter constant StartId

NewID IDM_NEW
NewID IDM_CLOSE
NewID IDM_EXIT
NewID IDM_TILE
NewID IDM_ARRANGE
NewID IDM_CASCADE
NewID IDM_CLOSE_ALL
NewID IDM_OPEN_FILE

IdCounter constant EndId

Create MenuTable EndId StartId - 4 * allot
: DoMenu ( ID -- )   StartId - 4 * MenuTable + @ ?dup IF execute THEN ;
: SetMenu ( ID -- )  last @ name>  swap StartId - 4 * MenuTable + ! ;

MENUBAR MDIMenu
    POPUP "&File"
        MENUITEM     "&New...   \tCtrl+N"     IDM_NEW               DoMenu ;
        MENUITEM     "C&lose"                 IDM_CLOSE             DoMenu ;
\     9 RECENTFILES   RecentFiles             IDM_OPEN_FILE         DoMenu ;
        MENUSEPARATOR
        MENUITEM     "E&xit  \tAlt-F4"        IDM_EXIT              DoMenu ;
    POPUP "&Window"
        MENUITEM     "&Tile"                  IDM_TILE              DoMenu ;
        MENUITEM     "&Arrange"               IDM_ARRANGE           DoMenu ;
        MENUITEM     "Ca&scade"               IDM_CASCADE           DoMenu ;
        MENUITEM     "&Close all"             IDM_CLOSE_ALL         DoMenu ;
ENDBAR


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define application window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Frame   <Super MDIFrameWindow

:M Classinit: ( -- )
        ClassInit: super
        MDIMenu to CurrentMenu
        ;M

:M WindowMenuNo: ( -- n )   1 ;M   \ the Window menu where the child window titles will be placed

:M WindowStyle: ( -- style )
        WindowStyle: SUPER
        WS_CLIPCHILDREN or
        ;M

:M ExWindowStyle: ( -- exstyle )
        WS_EX_ACCEPTFILES
        ;M

:M WM_DROPFILES { hndl message wParam lParam \ drop$ -- res }
        SetForegroundWindow: self
        MAXSTRING LocalAlloc: drop$
        0 0 -1 wParam Call DragQueryFile
        0 DO
            MAXCOUNTED drop$ 1+ i wParam Call DragQueryFile drop$ c!
            drop$ IDM_OPEN_FILE DoMenu
        LOOP
        wParam Call DragFinish
        ;M

:M MinSize: ( -- width height )   106  0  ;M

:M WindowTitle: ( -- z" )   z" MDI Example"  ;M

:M On_Size: ( h m w -- )
        0 0 Width Height Move: MDIClient
        ;M
(( This is equivalent to  :M WM_SIZE  ( h m w l -- f )   DefFrameProc ;M
   but if space for a Toolbar or StatusBar is needed MDIClient needs to be smaller ))

:M On_Init: ( -- )
        On_Init: super
        100 appinst Call LoadIcon   \ Win32For.ico
        GCL_HICON hWnd Call SetClassLong drop
        ;M

:M OnWmCommand:  ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        OnWmCommand: Super
        over LOWORD ( Menu ID )  dup StartId EndId within   \ intercept Menu commands
        IF  DoMenu  ELSE  drop  THEN
        ;M

:M WM_CLOSE ( h m w l -- res )
        CloseAll: self
        NotCancelled                    \ if we don't cancel the close
        IF
            WM_CLOSE WM: super          \ then just terminate the program
        ELSE
            1                           \ else abort program termination
        THEN
        ;M

:M On_Done: ( -- )
        Turnkeyed? IF  bye THEN
        On_Done: Super
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MDIChild   <Super MDIChildWindow
    int EditWindow
    256 bytes FileName
    int Modified

:M WindowTitle: ( -- z" )
        CurrentFile count FileName place
        FileName +null  FileName 1+
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: super
        WS_CLIPCHILDREN or
        GetActive: Frame  0= or  IF  WS_MAXIMIZE or  THEN   \ start new child maximised unless
        ;M                                                  \ the active child is not maximised

:M DefaultIcon: ( -- hIcon )
        101 appInst Call LoadIcon   \ App_icon.ico
        ;M

:M Start: ( parent -- )
        New> TextBox to EditWindow
        Start: super
        self start: EditWindow
        0 0 Width Height Move: EditWindow
        SetFocus: EditWindow
        True to Modified
        ;M

:M On_SetFocus: ( -- )              \ A child window can be selected by clicking on it,
        SetFocus: EditWindow        \ selecting it from the Window menu or using CTRL+F6
        EditWindow to CurrentWindow
        self to ActiveChild
        FileName count CurrentFile place CurrentFile +null
        ;M

:M On_Size: ( h m w l -- h m w l )
        0 0 Width Height Move: EditWindow   \ make TextBox fit child window
        ;M

:M On_Close: ( -- f )   \ True = close, False = cancel close
        Modified
        IF
            ?SaveMessage
            Case
                IDCANCEL  Of                 FALSE  Endof
                IDYES     Of                  TRUE  Endof
                ( otherwise IDNO )            TRUE  swap
            EndCase
        ELSE  TRUE
        THEN
        dup  dup to NotCancelled
        IF                                   \ if we don't cancel the close
            GetHandle: self Destroy: Frame   \ close child window first
            EditWindow dispose               \ so we can safely dispose
            self dispose                     \ of both the EditControl
        THEN                                 \ and the child window
        ;M

;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Activate Menu
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value New#
: New ( -- )   1 +to New#  s" File " currentfile place
        New# (.) currentfile +place
        New> MDIChild to ActiveChild
        MDIClientWindow: Frame Start: ActiveChild ;             IDM_NEW SetMenu
: Close ( -- )   GetHandle: ActiveChild CloseChild: Frame ;   IDM_CLOSE SetMenu
: ExitApp ( -- )   bye ;                                       IDM_EXIT SetMenu
: Tile ( -- )   0 Tile: Frame ;                                IDM_TILE SetMenu
: Arrange ( -- )   Arrange: Frame ;                         IDM_ARRANGE SetMenu
: Cascade ( -- )   Cascade: Frame ;                         IDM_CASCADE SetMenu
: CloseAll ( -- )   CloseAll: Frame ;                     IDM_CLOSE_ALL SetMenu
: OpenFile ( File$ -- )   count currentfile place
        New> MDIChild to ActiveChild
        ( File opening stuff )
        MDIClientWindow: Frame Start: ActiveChild ;       IDM_OPEN_FILE SetMenu

\ ********** many menu items not implemented here **********


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Handle MDI Accelerators: ALT+ - (minus), CTRL+ F4, CTRL+ F6
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DoMDIMsg ( pMsg f  -- pMsg f )
        dup MDIClient: Frame 0<> and
        IF
            drop dup MDIClient: Frame Call TranslateMDISysAccel 0=
        THEN
        ;
msg-chain chain-add DoMDIMsg


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       The word to start the application
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: go   ( -- )
       zeromenu: mdimenu
       start: Frame
       0 to New#
       New
       Cascade
       ;

\ *-
\ *Z

MODULE

cr .( Save MDIExample.exe [Y/N]: )  key  dup emit  dup 121 = swap 89 = or  nostack
    [IF]  ' go turnkey MDIExample.exe
    Needs Resources.f
    s" WIN32FOR.ICO" s" MDIExample.exe" AddAppIcon
    1 pause-seconds  bye
    [ELSE]  go
    [THEN]
\s
