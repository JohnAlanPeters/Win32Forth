\ $Id: CHILDWND.F,v 1.12 2011/07/21 18:26:20 georgeahubert Exp $

\ *D doc\classes\
\ *! Childwnd
\ *T Child-Window -- Base class for all child windows
\ *S Glossary

cr .( Loading Child Window...)

only forth also definitions

needs window.f

:CLASS Child-Window     <Super Window
\ *G Child-Window is the base class for all child windows.
\ *P The windows has a parent, which is the object address,
\ ** not the window handle. This allows the child to send
\ ** messages to its parent.

int id          \ id for this child window

\ int Parent    \ object address of the parent window
                \ Note: this ivar was moved into the window class some time ago.
                \ Altough it's not realy needed in the window class I (dbu) left
                \ it there in order not to break too much code  (Sonntag, Juni 04 2006 dbu).

:M ClassInit:   ( -- )
\ *G Initialise the class.
                ClassInit: super
                0 to id
                ;M

:M SetParent:   ( parent -- )
\ *G Set the object address of the parent window.
                to Parent ;M

:M GetParent:   ( -- parent )
\ *G Get the object address of the parent window.
                Parent ;M

:M SetID:       ( n -- )
\ *G Set the ID for this child window.
                to id  ;M

:M GetID:       ( -- n )
\ *G Get the ID for this child window.
                id  ;M

\ To change the minimum window size, override the MinSize: method.

\ :M MinSize:   ( -- width height )   0  0 ;M      \ override to change
\ :M StartSize: ( -- width height )   0  0 ;M      \ override to change
\ :M StartPos:  ( -- left  top )      0  0 ;M      \ override to change


\ -------------------- Create Child Window --------------------

\ The child window class has the following properties:
\       Private device context (OWNDC)
\       Black background
\       No icon

: register-child-window  ( -- f )
\ Register the window class for this child window.
        WndClassStyle: [ self ]                 to Style
        TheWndProc                              to WndProc
        0                                       to ClsExtra
        4                                       to WndExtra
        appInst                                 to hInstance
        NULL                                    to hIcon
        IDC_ARROW NULL Call LoadCursor          to hCursor
        NULL                                    to hbrBackground
        NULL                                    to MenuName

        \ Set the window class name for this child window. Every window
        \ will become it's own class name and it's own window class.
        default-class-name WindowClassName 1+   to ClassName

        register-the-class ;

: GetParentWindow       ( -- hWnd )
\ Get the parent window handle for this child window.
\ If this window has no parent the window of the console is used as the parent.
\ If no console is pressent the parent handle will be NULL.
        Parent if GetHandle: parent else conhndl then

        \ make shure that we have a valid window handle
        \ and tell the super class about it.
        dup call IsWindow 0= if drop NULL then
        dup SetParentWindow: super ;

: create-child-window   ( -- hWnd )
\ Create this child window.
        ^base                           \ creation parameters
        appInst                         \ program instance
        id                              \ child id
        GetParentWindow                 \ parent window handle
        StartSize:     [ self ] swap    \ height, width
        StartPos:      [ self ] swap    \ y, x starting position
        WindowStyle:   [ self ]         \ the window style
        WindowTitle:   [ self ]         \ the window title
        WindowClassName 1+              \ class name
        ExWindowStyle: [ self ]         \ extended window style
        Call CreateWindowEx ;

:M WindowStyle: ( -- style )
\ *G User windows should override the WindowStyle: method to
\ ** set the window style. Default is WS_CHILD and WS_VISIBLE.
                [ WS_CHILD WS_VISIBLE or ] literal ;M

:M WindowTitle: ( -- Zstring )
\ *G User windows should override the WindowTitle: method to
\ ** set the window caption. Default is "".
                z"  " ;M        \ we don't want a name, pass NULL

:M Start:       ( Parent -- )
\ *G Create this child window. Parent is the object address of the
\ ** parent window.
                to Parent
                register-child-window drop
                create-child-window dup to hWnd
                if   SW_SHOWNORMAL Show: self
                then ;M

:M AutoSize:    ( -- )
\ *G Size the window to fit into the client area of the parent window.
                winRect GetClientRect: Parent
                0 0 Right: winRect Bottom: winRect   \ x,y,h,w
                Move: self
                ;M

;Class
\ *G End of Child-Window class

\ *Z

