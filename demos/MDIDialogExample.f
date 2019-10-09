\ $Id: MDIDialogExample.f,v 1.3 2013/11/29 14:43:29 georgeahubert Exp $
\ G.Hubert Monday, July 26 2004 - 21:52
\ Example of an MDI application using the MDIDialogWindow Class
\ with the MDI Classes by Rod Oakford
\ Icon resource 100 and 101 needed in .exe
\ otherwise default windows icon used

anew -MDIDialogExample.f

Needs MDI
Needs MdiDialog.f

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

:M MinSize: ( -- width height )   106  0  ;M

:M WindowTitle: ( -- z" )   z" MDI Example"  ;M

:M On_Size: ( h m w -- )
        0 0 Width Height Move: MDIClient
        ;M

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
        Turnkeyed? IF  0 call PostQuitMessage drop  THEN
        On_Done: Super
        ;M

;Object

0 value check1

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MDIChild   <Super MDIDialogWindow
    256 bytes FileName

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

:M On_SetFocus: ( -- )              \ A child window can be selected by clicking on it,
                                    \ selecting it from the Window menu or using CTRL+F6
        ;M

:M On_Close: ( -- f )   \ True = close, False = cancel close
        GetHandle: self Destroy: Frame
        self dispose true
        ;M

  EditControl Edit_1     \ an edit window
StaticControl Text_1     \ a static text window
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button
 CheckControl Check_1    \ a check box
 RadioControl Radio_1    \ a radio button
 RadioControl Radio_2    \ another radio button

: CloseSample   ( -- )
                Close: [ self ] ;

:M On_Init:     ( -- )
                On_Init: super
                self               Start: Check_1
                4 25 60 20          Move: Check_1
                s" Hello"        SetText: Check_1

                self               Start: Radio_1
                80 25 80 20         Move: Radio_1
                s" Hello2"       SetText: Radio_1
                                GetStyle: Radio_1 \ get the default style
                [ WS_GROUP WS_TABSTOP OR ] literal  OR
                                SetStyle: Radio_1 \ Start a group

                self               Start: Radio_2
                80 45 120 20        Move: Radio_2
                s" Hello Again"  SetText: Radio_2

                self               Start: Text_1 \ start up static text
                                GetStyle: Text_1 \ get the default style
                [ WS_GROUP SS_CENTER OR WS_BORDER OR ] literal OR \ start a group and centre
                                SetStyle: Text_1 \ and border to style
                4  4 192 20         Move: Text_1 \ position the window
                s" Sample Text"  SetText: Text_1 \ set the window message

                self               Start: Edit_1
                3 72  60 25         Move: Edit_1
                s" 000,00"       SetText: Edit_1

                IDOK               SetID: Button_1
                self               Start: Button_1
                110 72 36 25        Move: Button_1
                s" OK"           SetText: Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                SetStyle: Button_1

                self               Start: Button_2
                150 72 45 25        Move: Button_2
                s" Beep"         SetText: Button_2
                ['] beep         SetFunc: Button_2
                ;M

:M On_Paint:    ( -- )          \ screen redraw procedure
                0 0 width height LTGRAY FillArea: dc
                ;M

:M ON_COMMAND:  ( hwnd msg wparam lparam -- res )
                over LOWORD ( ID )
                case
                IDOK            of hwnd destroy: frame self dispose         endof
                GetID: Check_1  of GetID: Check_1
                                   IsDlgButtonChecked: self to check1 beep  endof
                endcase 0
                ;M

:M ON_SETFOCUS: ( hwnd msg wparam lparam -- )
                SetFocus: Check_1
                On_SetFocus: Super
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
       Turnkeyed? IF  Begin key drop again  THEN
       ;

go
