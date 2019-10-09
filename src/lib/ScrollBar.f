\ $Id: ScrollBar.f,v 1.4 2013/03/15 00:23:07 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -ScrollBar.f

WinLibrary COMCTL32.DLL

cr .( Loading ScrollBar Class...)

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="ScrollBar"></a>
\ *S ScrollBar class
\ ------------------------------------------------------------------------
|Class ScrollBar	<Super Control
\ *G Scrollbar control
\ ** Note: this is an internal class. Don't use it directly.

Record: ScrollInfo
    INT cbSize
    INT fMask
    int  nMin
    int  nMax
    INT nPage
    int  nPos
    int  nTrackPos
;RecordSize: sizeof(ScrollInfo)

:M ClassInit:   ( -- )
\ *G Initialise the class.
                ClassInit: super
                0 to style
                sizeof(ScrollInfo) to cbSize
                0 to nMin
                100 to nMax
                25 to nPage
                0 to npos
                ;M

: SetScrollInfo ( -- n )
                1 ScrollInfo SB_CTL hwnd Call SetScrollInfo ;

: GetScrollInfo ( -- n )
                ScrollInfo SB_CTL hwnd Call GetScrollInfo ;

:M SetRange:    ( min max -- )
                to nMax to nMin SIF_RANGE to fMask
                SetScrollInfo to npos ;M

:M GetRange:    ( -- min val )
                SIF_RANGE to fmask
                GetScrollInfo drop
                nmin nmax ;M

:M SetPosition: ( n -- prev )
                to npos SIF_POS to fmask
                SetScrollInfo to npos ;M

:M GetPosition: ( -- n )
                SIF_POS to fmask
                GetScrollInfo drop npos ;M

:M SetPage:     ( page -- )
                to npage SIF_PAGE to fmask
                SetScrollInfo drop ;M

:M GetPage:     ( -- page )
                SIF_PAGE to fmask
                GetScrollInfo drop npage ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                to parent z" SCROLLBAR" create-control ;M

:M SetFont:     ( hndl -- )
\ *G Set the font in the control.
\ ** Note that this is a dummy method in this class.
                drop ;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class

\ ------------------------------------------------------------------------
\ *W <a name="HorizScroll"></a>
\ *S HorizScroll class
\ ------------------------------------------------------------------------
:Class HorizScroll      <Super ScrollBar
\ *G Scrollbar control (vorizontal).

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: SBS_HORZ.
                WindowStyle: super SBS_HORZ or ;M

;Class
\ *G End of HorizScroll class

\ ------------------------------------------------------------------------
\ *W <a name="VertScroll"></a>
\ *S VertScroll class
\ ------------------------------------------------------------------------
:Class VertScroll	<Super ScrollBar
\ *G Scrollbar control (vertical).

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: SBS_VERT.
                WindowStyle: super SBS_VERT or ;M

;Class
\ *G End of VertScroll class

\ ------------------------------------------------------------------------
\ *W <a name="SizeBox"></a>
\ *S SizeBox class
\ ------------------------------------------------------------------------
:Class SizeBox 		<Super ScrollBar
\ *G Size box control.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: SBS_SIZEGRIP.
                WindowStyle: super SBS_SIZEGRIP or ;M

;Class
\ *G End of SizeBox class

MODULE

\ *Z
