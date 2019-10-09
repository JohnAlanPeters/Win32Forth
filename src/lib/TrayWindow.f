\ $Id: TrayWindow.f,v 1.7 2014/04/16 17:57:06 georgeahubert Exp $
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, April 24 2005 - dbu
\ Updated: Sonntag, Januar 15 2006 - dbu
\
\ *D doc\classes\
\ *! TrayWindow
\ *T TrayWindow class
\ *P Windows that are created with this class will hide themself
\ ** in the windows traybar when they are minimized, rather than on the task bar.

cr .( Loading TrayWindow class...)

Require Window.f

anew -TrayWindow.f

internal

2 proc Shell_NotifyIconA as Shell_NotifyIcon

external

\ *W <a name="TrayWindow"></a>
\ *S Glossary
:class TrayWindow <super window
\ *G TrayWindow class

Record: &NOTIFYICONDATA
        int   nid_cbSize
        int   nid_hWnd
        int   nid_uID
        int   nid_uFlags
        int   nid_uCallbackMessage
        int   nid_hIcon
     64 bytes nid_szTip
;RecordSize: sizeof(NOTIFYICONDATA)

:M GetTooltip:  ( -- addr len )
\ *G Get the tooltip text for the traybar icon. Default is to print the title of the window
\        s" Tooltip text" ;M
        WindowTitle: [self] zcount ;M

:M GetID:       ( -- uID )
        1 ;M

:M GetFlags:    ( -- uFlags )
        [ NIF_ICON NIF_MESSAGE NIF_TIP or or ] literal ;M

WM_APP 1+ constant WM_CALLBACK_MESSAGE

: ShellNotifyIcon      ( n -- )
        &NOTIFYICONDATA swap call Shell_NotifyIcon drop ;

:M AddIcon:     ( -- )
\ *G Add our icon to the traybar
        NIM_ADD ShellNotifyIcon ;M

:M DeleteIcon:  ( -- )
\ *G Remove our icon from the traybar
        NIM_DELETE ShellNotifyIcon ;M

:M On_Init:     ( -- )
        On_Init: super

        sizeof(NOTIFYICONDATA) to nid_cbSize
        GetHandle: self        to nid_hWnd
        GetID: [ self ]        to nid_uID
        GetFlags: [ self ]     to nid_uFlags
        WM_CALLBACK_MESSAGE    to nid_uCallbackMessage
        DefaultIcon: [ self ]  to nid_hIcon
        GetTooltip: [ self ]   nid_szTip swap 64 min cmove
        ;M

:M On_Done:     ( -- )
        DeleteIcon: self
        On_Done: super ;M

:M ShowWindow:  ( -- )
\ *G Show the window and remove the icon from the traybar.
        IsVisible?: self 0=
        if   DeleteIcon: self
             SW_RESTORE Show: self Update: self
        then ;M

:M HideWindow:  ( -- )
\ *G Hide the window and add the icon to the traybar.
        IsVisible?: self
        if   SW_HIDE Show: self Update: self
             AddIcon: self
        then ;M

:M WM_SIZE      ( hWnd uMsg wParam lParam -- res )
\ *G Handle the WM_SIZE message. If the window is minimized
\ ** it will be hidden and the icon will be added to the traybar.
        over SIZE_MINIMIZED =
        if   HideWindow: [ self ]
        then WM_SIZE WM: super
        ;M

:M WM_SYSCOMMAND ( hWnd uMsg wParam lParam -- res )
\ *G Handle the WM_SYSCOMMAND message. If the window is minimized
\ ** it will be hidden and the icon will be added to the traybar.
        over SC_MINIMIZE =
        if   HideWindow: [ self ] 0
        else hWnd WM_SYSCOMMAND 2swap DefWindowProc: self
        then ;M

: TrackPopup    ( -- )
\ Open the popup menu of the window.
        CurrentPopup
        if   get-mouse-xy
             GetHandle: self Track: CurrentPopup
        then ;

:M On_IconNotify:       ( hWnd uMsg wParam lParam -- res )
\ *G Handle the messages from the traybar icon.
\ *P The default handler removes the icon for the traybar and shows the window,
\ ** when the user click's with the left mouse button on the tray icon.
\ *P If the right mouse button is used the popup menu of the window is shown.
\ ** Use the \b SetPopupBar: \d method to assign a popup menu to the window.
        case    WM_LBUTTONUP of ShowWindow: [ self ] endof
                WM_RBUTTONUP of TrackPopup           endof
        endcase 0 ;M

:M WM_CALLBACK_MESSAGE  ( hWnd uMsg wParam lParam -- res )
        On_IconNotify: [ self ] ;M

;class
\ *G End of TrayWindow class

module

\s

\ ----------------------------------------------------------------------------
\ *S Example
\ -----------------------------------------------------------------------------

\ *+

\ Create a tray window
:object TestWindow <super TrayWindow

:M GetTooltip:  ( -- addr len )
        s" TrayWindow Test" ;M

;object

           Start: TestWindow \ open the window
SW_MINIMIZE Show: TestWindow \ minimize it to hide it in the TrayBar
\ *-
\ *Z
