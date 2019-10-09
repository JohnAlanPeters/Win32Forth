anew  -PopupWindow.f

\ -----------------------------------------------------------------------------
\       Define the Popup bar for the mediatree in a new window
\ -----------------------------------------------------------------------------


: PlaySelectedFromTreeView ( -- )
    last-selected-rec n>record   dup to #playing  dup>r
    RecordDef File_name  r@ Cnt_File_name c@
    r@ incr-#played
    r> mark-played
    turnkey? not
        if    2dup cr type-space
        then
    PlayFileFromCatalog: Player4W
  ;

defer    ClosePopupWindow            ' noop is ClosePopupWindow

POPUPBAR PopupOnRecord
    POPUP " "
       MENUITEM  "Play file"         ClosePopupWindow PlaySelectedFromTreeView ;
       MENUITEM  "Request record"    ClosePopupWindow RequestRecord ;
ENDBAR

:Object    PopupWindow    <super  Window

int  focus

:M ClassInit:   ( -- )
                ClassInit: super
                PopupOnRecord SetPopupBar: Self
                true to Focus
                ;M

\ The popupmenu needs a rbuttondown to do it right
: StartPopup    ( -- )  0 WM_RBUTTONDOWN GetHandle: self Call PostMessage drop ;
: CleanupClose  ( h_m w_l - res )       2drop 0 close: Self     ;

:M WindowStyle:   ( -- style )          WS_POPUP                ;M
:M StartSize:     ( -- width height )   1 1                     ;M
:M StartPos:      ( -- x y )            mousex  mousey          ;M
:M WM_LBUTTONDOWN ( h m w l -- res )    CleanupClose            ;M
:M On_KillFocus:  ( h m w l -- res )    CleanupClose            ;M
:M On_Done:       ( h m w l -- res )    On_Done: super 0        ;M
:M Start:         ( mousex mousey -- )  to mousey to mousex   Start: super  ;M

:noname  ( - )   false to focus
                 hwnd  call DestroyWindow drop
       ; is ClosePopupWindow

:M On_Paint:    ( -- )
                focus   if   hwnd start: PopupOnRecord   StartPopup   then   ;M
;Object

\ mousex mousey  start: PopupWindow   \ Start needs mousex mousey

\s
