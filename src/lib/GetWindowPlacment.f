\ $Id: GetWindowPlacment.f,v 1.1 2004/12/21 00:19:10 alex_mcdonald Exp $
\    File: GetWindowPlacment.f
\  Author: Dirk Busch
\ Created: Samstag, Mai 29 2004 - 11:25 - dbu
\ Updated: Sonntag, Mai 30 2004 - 9:21 - dbu

ANEW -GetWindowPlacment.f

needs Struct.f

INTERNAL

EXTERNAL

struct{ \ POINT
        LONG x
        LONG y
}struct POINT

struct{ \ RECT
        LONG left
        LONG top
        LONG right
        LONG bottom
}struct RECT

struct{ \ WINDOWPLACEMENT
        UINT  length
        UINT  flags
        UINT  showCmd
        POINT ptMinPosition
        POINT ptMaxPosition
        RECT  rcNormalPosition
}struct WINDOWPLACEMENT

INTERNAL

sizeof WINDOWPLACEMENT mkstruct: wp

EXTERNAL

: GetWindowPlacment ( hWnd -- wp ) \ get window placement
        sizeof WINDOWPLACEMENT wp length !
        wp swap Call GetWindowPlacement ?win-error wp ;

MODULE

