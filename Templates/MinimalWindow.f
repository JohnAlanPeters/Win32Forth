Anew -MinimalWindow.f   \ With a start of a menubar

Needs Resources.f

false value turnkey?

:Object MinimalWindow   <Super Window

:M On_Init:             ( -- )                    On_Init: super        ;M
:M ClassInit:           ( -- )                  ClassInit: super        ;M
:M WindowStyle:         ( -- style )   WindowStyle: Super  WS_CLIPCHILDREN or ;M
:M ParentWindow:        ( -- hwndParent | 0=NoParent )    parent        ;M
:M SetParent:           ( hwndparent -- )       to parent               ;M
:M WindowHasMenu:       ( -- f )                true                    ;M
:M WindowTitle:         ( -- ztitle )           z" Minimal window"      ;M
:M StartSize:           ( -- width height )     screen-size >r 2/ r> 2/ ;M
:M StartPos:            ( -- x y )              CenterWindow: Self      ;M
:M Close:               ( -- )                  Close: super            ;M

:M On_Done:             ( -- )
                        On_Done: super 0
                        bye
                ;M

:M msgBox: ( z$menu z$text - ) swap MB_OK   MessageBox: Self drop       ;M

;Object

MENUBAR ApplicationBar
    POPUP "File"
        MENUITEM        "Exit"          Close: MinimalWindow    ;
    POPUP "Help"
        MENUITEM        "Info"
                        z" Info"
                        z" A template for a \nminimal window."
                        msgBox: MinimalWindow                   ;
ENDBAR

: Minimal
   start: MinimalWindow
   ApplicationBar SetMenuBar: MinimalWindow ;

turnkey? [if]
        ' Minimal turnkey MinimalWindow.exe
        s" WIN32FOR.ICO" s" MinimalWindow.exe"  AddAppIcon
        1 pause-seconds bye
[else]  Minimal
[then]

\s
