\ MDI.f   Multiple Document Interface by Rod Oakford
\         adapted from MDI.f by Michael Hillerström to work in Win32Forth v5.2

\ *D doc\classes\
\ *! mdi
\ *T Multiple Document Interface (MDI) classes

\ *P MDI.f contains classes that form the basis for writing MDI aplications
\ ** (like MS Word and MS Excel).  Each document in an MDI application is displayed
\ ** in a separate child window within the client area of the application's main window.

\ History:
\ July 3rd, 2004  added MDIClient: method to obtain handle of MDIClient window
\ to fix problem in v6.09.07 with DoMDIMsg when MDIClient is 0
\ ( 0 @ returns 0 in v5.2 but in v6.09.07 causes an exception )
\
\ Monday, September 26 2005 removed parent from MDIChildWindow class since it's now
\ defined in Window class

cr .( Loading Multiple Document Interface classes...)

True value NotCancelled   \ set to False in child's WM_CLOSE to cancel during CloseAll

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="MDIClientWindow"></a>
\ *S MDI client control class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MDIClientWindow   <super Control
\ *G MDI client control class. This control is used by the MDIFrameWindow class.
\ ** You shouldn't create instances of this class within your application.

Record: ClientCreateStruct
    int hWindowMenu
    int IdFirstChild
;Record

:M Start: ( hWindowMenu Parent -- )
\ *G Start the control.
        to Parent
        to hWindowMenu
        6300 to IdFirstChild
        z" MDICLIENT" Create-Control
        ;M

:M WindowStyle:   ( -- style )
        WindowStyle: super
        [ WS_HSCROLL WS_VSCROLL or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ] literal or
        ;M

:M ExWindowStyle:   ( -- exstyle )
        WS_EX_CLIENTEDGE ;M

:M CreateStruct: ( -- CreateStrucPointer )
\ *G Get the address of CLIENTCREATESTRUCT structure. It contains information about
\ ** the menu and first multiple document interface (MDI) child window of an MDI
\ ** client window. An application passes a pointer to this structure as the
\ ** lpvParam parameter of the CreateWindow function when creating an MDI client window.
        ClientCreateStruct ;M

;Class
\ *G End of MDIClientWindow class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="MDIFrameWindow"></a>
\ *S MDI Frame window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MDIFrameWindow   <super Window
\ *G All MDI child windows are displayed within the client area of this
\ ** window.

\ int MDIClient
MDIClientWindow MDIClient

:M MDIClientWindow: ( -- MDICLient window )
        MDIClient ;M

:M MDIClient: ( -- handle of MDICLient window )
        GetHandle: MDIClient ;M

:M Classinit: ( -- )
        ClassInit: super
        s" ForthMDIFrame" SetClassName: self
        ;M

:M WindowMenuNo: ( -- n )
\ *G Override this method to set the menu number in whitch all
\ ** child windows should be displayed.
        1 ;M

:M On_Init: ( -- )
        WindowMenuNo: [ self ]
        NULL LoadMenu: self
        Call GetSubMenu
        self start: MDIClient
        ;M

:M WindowHasMenu: ( -- f )
        TRUE ;M

:M WindowStyle: ( -- style )
        WindowStyle: super WS_CLIPCHILDREN or ;M

:M WindowTitle: ( -- z" )
\ *G Get the title text for the frame window.
        z" MDI Frame Window" ;M

: DefFrameProc ( h m w l -- f )
        4reverse MDIClient: self swap Call DefFrameProc ;

\ remove if MDIClient window does not fill entire
\ client area, use On_Size instead to Move: MDIClient
\ :M WM_SIZE  ( h m w l -- f )
\         DefFrameProc ;M

:M WM_MENUCHAR   ( h m w l -- f )
        DefFrameProc ;M

:M WM_SETFOCUS   ( h m w l -- f )
        DefFrameProc ;M

:M WM_NCACTIVATE ( h m w l -- f )
        DefFrameProc ;M

:M WM_COMMAND    ( h m w l -- f )
       WM_COMMAND WM: super ?dup 0=
       IF  DefFrameProc  THEN
       ;M

: SendMDIMessage     ( l w message -- result )
        MDIClient: self Call SendMessage ;

: SendMDIMessageDrop ( lParam wParam message -- )
        SendMDIMessage drop ;

:M SetRedraw:   ( f -- )
\ *G Set the redraw state of the window.
\ *P \i f \d Specifies the redraw state. If this parameter is TRUE, the
\ ** content can be redrawn after a change. If this parameter is FALSE,
\ ** the content cannot be redrawn after a change.
        0 swap WM_SETREDRAW SendMDIMessageDrop ;M

:M Tile:        ( f -- )
\ *G Arrange all child windows in a tile format.
\ *P \i f \d can be one of the following values optionally combined with
\ ** MDITILE_SKIPDISABLED to prevent disabled MDI child windows from being
\ ** tiled.
\ *L
\ *| MDITILE_HORIZONTAL | Tiles windows horizontally. |
\ *| MDITILE_VERTICAL | Tiles windows vertically. |
        0 swap WM_MDITILE SendMDIMessageDrop ;M

:M Arrange:     ( -- )
\ *G Arrange all minimized child windows. It does not affect child
\ ** windows that are not minimized.
        0 0 WM_MDIICONARRANGE SendMDIMessageDrop ;M

:M Cascade:     ( -- )
\ *G Arrange all child windows in a cascade format.
        0 0 WM_MDICASCADE SendMDIMessageDrop ;M

:M RefreshMenu: ( -- )
\ *G Refresh the window menu of the MDI frame window.
        0 0 WM_MDIREFRESHMENU SendMDIMessageDrop hWnd Call DrawMenuBar drop ;M

:M MDISetMenu:  ( hmenuWindow hmenuFrame -- )
\ *G Replace the entire menu of an MDI frame window, replace the window menu
\ *P of the frame window, or both.
        WM_MDISETMENU SendMDIMessageDrop hWnd Call DrawMenuBar drop ;M

:M DrawMenuBar: ( -- )
\ *G Redraws the menu bar of the window. If the menu bar changes after the system
\ ** has created the window, this function must be called to draw the changed menu bar.
        hWnd Call DrawMenuBar drop ;M

:M Restore:     ( hWnd -- )
\ *G Restore an MDI child window from maximized or minimized size.
        0 swap WM_MDIRESTORE SendMDIMessageDrop ;M

:M Maximize:    ( hWnd -- )
\ *G M maximize an MDI child window. The system resizes the child window to make its
\ ** client area fill the client window. The system places the child window's window
\ ** menu icon in the rightmost position of the frame window's menu bar, and places
\ ** the child window's restore icon in the leftmost position. The system also appends
\ ** the title bar text of the child window to that of the frame window.
        0 swap WM_MDIMAXIMIZE SendMDIMessageDrop ;M

:M GetActive:   ( -- Maximized handle )
\ *G Retrieve the handle to the active MDI child window.
        0 sp@ 0 WM_MDIGETACTIVE SendMDIMessage ;M

:M Activate:    ( hWnd -- )
\ *G Activate a MDI child window.
        0 swap WM_MDIACTIVATE SendMDIMessageDrop ;M

:M Next:        ( f hWnd -- )
\ *G Activate the next or previous child window.
        WM_MDINEXT SendMDIMessageDrop ;M

:M Destroy:     ( hWnd -- )
\ *G Destroy an MDI child window.
        0 swap WM_MDIDESTROY SendMDIMessageDrop ;M

:M CloseChild:  ( hWnd -- )
\ *G Close an MDI child window.
        >r 0 0 WM_CLOSE r> Call SendMessage drop ;M

:M EnumChildWindows: ( lparam pCallBack -- f )
\ *G Enumerate the MDI child windows
        MDIClient: self Call EnumChildWindows
        ;M

2 CallBack: CloseAllChildren { hChild lparam -- f }
        hChild Call GetParent MDIClient: self =
        IF
            hChild Call IsIconic IF  hChild Restore: self  THEN
            hChild Activate: self
            hChild CloseChild: self
        THEN
        NotCancelled
        ;

:M CloseAll:    ( -- )
\ *G Close all MDI child windows.
        0 &CloseAllChildren EnumChildWindows: self drop
        ;M

int hChild
:M GetFirstChild: ( -- hWndChild )
\ *G Get handle of the first child window
        GW_CHILD MDIClient: self call GetWindow dup to hChild ;M

:M GetNextChild: ( -- hWndChild )
\ *G Get handle of the next child window.       \n
\ ** NOTE: you must call GetFirstChild: first.
        GW_HWNDNEXT hChild call GetWindow dup to hChild ;M

:M SendMessageToAllChildren: { wParam lParam msg -- }
\ *G Send a message to all child windows
        GetFirstChild: self ?dup
        if   begin >r lParam wParam msg r> call SendMessage drop
                   GetNextChild: self dup 0=
             until drop
        then ;M

:M PostMessageToAllChildren: { wParam lParam msg -- }
\ *G Post a message to all child windows
        GetFirstChild: self ?dup
        if   begin >r lParam wParam msg r> call PostMessage drop
                   GetNextChild: self dup 0=
             until drop
        then ;M

;Class
\ *G End of MDIFrameWindow class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="MDIChildWindow"></a>
\ *S MDI Child window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MDIChildWindow   <super child-window
\ *G This is the base class for all windows that should be displayed
\ ** within the client area of a MDIFrameWindow.

:M Classinit: ( -- )
        ClassInit: super
        s" ForthMDIChild" SetClassName: self
        ;M

: DefMDIChildProc ( h m w l -- res )   4reverse Call DefMDIChildProc ;

: (MDIChildProc) ( hwnd msg wparam lparam -- res )
        [ also classes ]
        GWL_USERDATA 4 pick Call GetWindowLong ?dup 0= ( object address )
        IF
            2 pick WM_CREATE <> IF  DefMDIChildProc exit  THEN
            dup @       \ window object pointer from
            8 cells+ @  \ 8'th cell of CREATEPARMS (=object addr)
            4 pick      ( obj hwnd )
            2dup GWL_USERDATA swap Call SetWindowLong drop \ save pointer
            over !          \ set hWnd parameter of window struc
        THEN
        3 pick ( msg ) over obj>class MFA ((findm))
        IF
            dup>r catch
            ?dup IF  r@ WndProcError  THEN
            r>drop
        ELSE
            drop DefMDIChildProc
        THEN
        [ previous ] ;

4 callback MDIChildProc (MDIChildProc)

: MDI-child-class ( -- )   \ fill in the defaults for the window class
        0                                                to Style
        MDIChildProc                                     to wndProc
        0                                                to clsExtra
        4                                                to wndExtra
        appInst                                          to hInstance
        DefaultIcon: [ self ]                            to hIcon
        DefaultCursor: [ self ] NULL Call LoadCursor     to hCursor
        WHITE_BRUSH                  Call GetStockObject to hbrBackground
        NULL                                             to MenuName
        WindowClassName 1+                               to ClassName
        ;

\ :M DefaultIcon: ( -- hIcon )
\ *G Return the handle of the Icon whitch should be displayed in the upper
\ ** left corner of the MDi child window.
\        101 appInst Call LoadIcon ;M

:M ExWindowStyle: ( -- exstyle)
        WS_EX_MDICHILD ;M

:M ParentWindow: ( -- hParent )
\ *G Teturn the handle of parent, 0 = no parent
        Gethandle: Parent ;M

:M Start: ( Parent -- )
\ *G Create a new MDI child window object
        to Parent
        MDI-child-class
        Register-the-class drop
        Create-frame-window to hWnd
        SW_SHOW Show: self
        ;M

:M WindowTitle: ( -- z" )
\ *G Get the title text for the MDI child window.
        z" MDI Child Window" ;M

:M WindowHasMenu: ( -- f )
        FALSE ;M

:M StartPos: ( -- x y )
        CW_USEDEFAULT dup ;M

:M StartSize: ( -- w h )
        CW_USEDEFAULT dup ;M

:M On_QueryEnd: ( -- f )
\ *G This method is called when the user chooses to end the session or when an
\ ** application calls the ExitWindows function. If any application returns zero,
\ ** the session is not ended.
\ *P The default method returns TRUE, so that the session will be ended.
        TRUE ;M

:M WM_QUERYENDSESSION ( h m w l -- f )
        On_QueryEnd: [ self ]
        dup IF drop DefMDIChildProc  THEN
        ;M

:M On_Close: ( -- f )
\ *G This method is called when the user chooses to close the MDI child window.
\ ** If it returns FALSE the window will not be closed.
\ *P Override the method to check if the document within the child window
\ ** need's to be saved.
\ *P The default method returns TRUE, so that the window will be closed.
        TRUE ;M

:M WM_CLOSE ( h m w l -- f )
        On_Close: [ self ]
        dup IF  drop DefMDIChildProc  THEN
        ;M

\ ------------------------------------------------------------------------------
\ NOTE:  If you need to handle one of the following messages:
\ =====
\               WM_CHILDACTIVATE, WM_GETMINMAXINFO, WM_MENUCHAR,
\               WM_MOVE, WM_SETFOCUS, and WM_SIZE
\
\       then you MUST pass the message to DefMDIChildProc too!
\
\       Do not override WM_SYSCOMMAND or WM_COMMAND; use On_WmCommand: and
\       On_SysCommand: instead.
\
\       Failing to this, will cause in very weird results and malfunction!

:M On_ChildActivate: ( -- )
\ *G Handle the WM_CHILDACTIVATE message. This message is sent to a child window
\ ** when the user clicks the window's title bar or when the window is activated,
\ ** moved, or sized.
        ;M

:M WM_CHILDACTIVATE ( h m w l -- f )
        On_ChildActivate: [ self ]
        DefMDIChildProc ;M

:M On_GetMinMaxInfo: ( pMinMaxInfo -- pMinMaxInfo )
\ *G Handle the WM_GETMINMAXINFO message. This message is sent to a window when the size
\ ** or position of the window is about to change. An application can use this message
\ ** to override the window's default maximized size and position, or its default minimum
\ ** or maximum tracking size.
\ *P \i pMinMaxInfo \d Pointer to a MINMAXINFO structure that contains the default maximized
\ ** position and dimensions, and the default minimum and maximum tracking sizes. An application
\ ** can override the defaults by setting the members of this structure.
        ;M

:M WM_GETMINMAXINFO ( h m w l -- f )
        On_GetMinMaxInfo: [ self ]
        DefMDIChildProc ;M

:M On_MenuChar: ( w l -- w l )
\ *G Handle the WM_MENUCHAR message. This message is sent when a menu is active and the user
\ ** presses a key that does not correspond to any mnemonic or accelerator key. This message
\ ** is sent to the window that owns the menu.
        ;M

:M WM_MENUCHAR ( h m w l -- f )
        On_MenuChar: [ self ]
        DefMDIChildProc ;M

:M On_Move: ( l -- l )
\ *G Handle the WM_MOVE message. This message is sent after a window has been moved.
        ;M

:M WM_MOVE ( h m w l -- f )
        On_Move: [ self ]
        DefMDIChildProc
        ;M

:M WM_SETFOCUS  ( h m w l -- f )
        On_SetFocus: [ self ]
        DefMDIChildProc
        ;M

:M WM_SIZE ( h m w l -- f )
        dup set-size
        On_Size: [ self ]
        DefMDIChildProc
        ;M

:M On_SysCommand: ( h m w l -- h m w l f )
\ *G Handle the WM_SYSCOMMAND message. A window receives this message when the user chooses
\ ** a command from the window menu or when the user chooses the maximize button, minimize
\ ** button, restore button, or close button.
        FALSE ;M

:M WM_SYSCOMMAND ( h m w l -- f )
        On_SysCommand: [ self ]
        ?dup 0= IF  DefMDIChildProc  THEN
        ;M

:M On_Command: ( h m w l -- h m w l f )
\ *G Handle the WM_COMMAND message. This message is sent when the user selects a command item
\ ** from a menu, when a control sends a notification message to its parent window, or when an
\ ** accelerator keystroke is translated.
        FALSE ;M

:M WM_COMMAND ( h m w l -- f )
       On_Command: [ self ]
       ?dup 0= IF  DefMDIChildProc  THEN
       ;M

;Class
\ *G End of MDIChildWindow class

\ *Z

\s
\ Example
\ ( need to have WM_SIZE call DefFrameProc in MDIFrameWindow for this example )

MDIFrameWindow Frame
Start: Frame

0 value Child

New> MDIChildWindow to Child  MDICLientWindow: Frame Start: Child
s" Child 1" SetText: Child

New> MDIChildWindow to Child  MDICLientWindow: Frame Start: Child
s" Child 2" SetText: Child

New> MDIChildWindow to Child  MDICLientWindow: Frame Start: Child
s" Child 3" SetText: Child

\ MDITILE_HORIZONTAL Tile: Frame
\ MDITILE_VERTICAL Tile: Frame
\ Cascade: Frame
\ GetHandle: Child Maximize: Frame
\ GetActive: Frame Restore: Frame drop


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Handle MDI Accelerators: ALT+ - (minus), CTRL+ F4, CTRL+ F6
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DoMDIMsg ( pMsg f  -- pMsg f )
        dup MDIClient: Frame 0<> and
        IF   drop dup MDIClient: Frame Call TranslateMDISysAccel 0=
        THEN ;

msg-chain chain-add DoMDIMsg
