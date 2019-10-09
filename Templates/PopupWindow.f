anew  -PopupWindow.f

\ Needed in a listview or treeview when you would like to have a popup menu.
\ The popup window could be activated when there is a right click on an item.

defer    ClosePopupWindow            ' noop is ClosePopupWindow

POPUPBAR PopupOnItem     \   Define the Popup bar for a window here.
    POPUP " "
       MENUITEM  "Some action (Not yet defined)"  ClosePopupWindow  noop ;
ENDBAR

:Object    PopupWindow    <super  Window

: StartPopup    ( -- )  0 WM_RBUTTONDOWN GetHandle: self Call PostMessage drop ;
:noname         ( - )                   Close: Self   ;  is ClosePopupWindow
: CleanupClose  ( h_m w_l - res )       2drop ClosePopupWindow  ;

:M ClassInit:     ( -- )   ClassInit: super   PopupOnItem SetPopupBar: Self ;M
:M WindowStyle:   ( -- style )          WS_POPUP                ;M
:M ExWindowStyle: ( -- extended_style ) WS_EX_TOOLWINDOW        ;M
:M StartSize:     ( -- width height )   1 1                     ;M
:M StartPos:      ( -- x y )            mousex  mousey          ;M
:M WM_LBUTTONDOWN ( h m w l -- res )    CleanupClose            ;M
:M On_KillFocus:  ( h m w l -- res )    CleanupClose            ;M
:M On_Done:       ( h m w l -- res )    On_Done: super 0        ;M
:M SetParent:     ( HwndParent -- )     to parent               ;M
:M On_Paint:      ( -- )   hwnd start: PopupOnItem   StartPopup ;M

:M Start:         ( mousex mousey HwndParent -- )
        SetParent: Self
        to mousey to mousex
        Start: super
        ;M


;Object

\  screen-size >r 2/ r> 2/ 0 Start: PopupWindow      \ to show how it looks

(( Use from an other window:

: StartPopupWindow ( -- )
           hWnd get-mouse-xy
           GetWindowRect: Self 2drop
           rot + >r + r>  Hwnd Start: PopupWindow
          ;  ))

\s
