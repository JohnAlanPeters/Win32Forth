\ $Id: StatusBar.f,v 1.7 2015/12/30 11:37:40 jos_ven Exp $

\ StatusBar.f
\ Statusbar control separated from ExControls

\ *D doc\classes\
\ *> Controls
\ *T ExControls -- More (enhanced) classes for standard windows controls.

defined  -statusbar.f nip [if] \s [then]  anew -StatusBar.f

cr .( Loading StatusBar Class...)

anew -StatusBar.f

WinLibrary COMCTL32.DLL

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="Statusbar"></a>
\ *S Statusbar class
\ ------------------------------------------------------------------------
:Class Statusbar	<Super Control
\ *G Status bar control
\ *P A status bar is a horizontal window at the bottom of a parent window in
\ ** which an application can display various kinds of status information.
\ *P This status bar control has only one part to display information.

INT BorderStyle \ style of border to use

:M Start:       ( Parent -- )
\ *G Create the control.
                to parent Z" msctls_statusbar32" create-control
                0 TRUE SB_SIMPLE SendMessage:SelfDrop
                ;M

:M RaisedBorder: ( -- )
\ *G The text is drawn with a border to appear lower than the plane of the
\ ** window (default).
		0 TO BorderStyle ;M

:M NoBorder: 	( -- )
\ *G The text is drawn without borders.
		SBT_NOBORDERS TO BorderStyle ;M

:M SunkenBorder: ( -- )
\ *G The text is drawn with a border to appear higher than the plane of the window.
		SBT_POPOUT TO BorderStyle ;M

:M ClassInit:   ( -- )
\ *G Initialise the class.
		ClassInit: super
		RaisedBorder: self ;M

:M MinHeight: 	( #pixels -- )
\ *G Sets the minimum height of the status window's drawing area.
\ *P The minimum height is the sum of #pixels and twice the width, in pixels,
\ ** of the vertical border of the status window.
\ *P An application must use the Redraw: method to redraw the window.
		0 SWAP SB_SETMINHEIGHT SendMessage:SelfDrop ;M

:M GetBorders: 	( -- hWidth vWidth divWidth )
\ *G Retrieves the current widths of the horizontal and vertical borders of
\ ** the status window.
\ *P \i hWidth \d is the width of the horizontal border.
\ *P \i vWidth \d is the width of the vertical border.
\ *P \i divWidth \d is the width of the border between rectangles.

\ TODO: Don't use HERE here !!!
		12 cells localalloc dup>r 0 SB_GETBORDERS SendMessage:Self ?Win-Error
		r> DUP @  SWAP CELL+ DUP @  SWAP CELL+ @
		;M

:M Redraw: 	( -- )
\ *G Redraw the statusbar after changes (e.g. size).
		0 0 WM_SIZE SendMessage:SelfDrop ;M

:M SetText: 	( szText -- )
\ *G Sets the text in the status window.
\ *P Use \i RaisedBorder: \d, \i NoBorder: \d or \i SunkenBorder: \d to set
\ ** the the style how the text is drawn.
		255 BorderStyle OR SB_SETTEXTA SendMessage:Self ?Win-error ;M

:M Clear: 	( -- )
\ *G clears text in the status window.
		Z" " SetText: self ;M

:M Setfont:     ( handle -- )
\ *G Set the font in the control.
                1 swap WM_SETFONT SendMessage:SelfDrop ;M

:M Height:      ( -- height )
\ Get the height of the status window.
                GetWindowRect: self
                nip swap - nip ;M
;Class
\ *G End of Statusbar class

\ ------------------------------------------------------------------------
\ *W <a name="MultiStatusbar"></a>
\ *S MultiStatusbar class
\ ------------------------------------------------------------------------
:Class MultiStatusbar	<Super Statusbar
\ *G Status bar control
\ *P A status bar is a horizontal window at the bottom of a parent window in
\ ** which an application can display various kinds of status information.
\ *P This status bar control can have multiple parts to display information.

INT nParts    \ number of parts in statusbar
INT aWidths   \ address of widths table

:M Start:       ( Parent -- )
\ *G Create the control.
                Start: super
                0 FALSE SB_SIMPLE SendMessage:SelfDrop
                ;M

:M SetParts: 	( aWidths nParts -- )
\ *G Sets the number of parts in the status window and the coordinate of the right
\ ** edge of each part.
\ *P \i nParts \d Number of parts to set (cannot be greater than 256).
\ *P \i aWidths \d is a pointer to an integer array. The number of elements is
\ ** specified in nParts. Each element specifies the position, in client coordinates,
\ ** of the right edge of the corresponding part. If an element is -1, the right edge
\ ** of the corresponding part extends to the border of the window.
\ *P Note: \i aWidths \d must be valid until SetParts: is used again!
                TO nParts
		TO aWidths
		aWidths nParts SB_SETPARTS SendMessage:Self ?Win-error
		;M

:M GetParts: 	( -- aWidths nParts )
\ *G Gets the number of parts in the status window and the coordinate of the right
\ ** edge of each part.
		aWidths nParts ;M

:M SetSimple: 	( -- )
\ *G Reset the status bar to show only one part.
		0 TRUE SB_SIMPLE SendMessage:SelfDrop ;M

:M SetMulti:	( -- )
\ *G Set the status bar to show all parts set with \i SetParts: \d before.
		0 FALSE SB_SIMPLE SendMessage:SelfDrop ;M

:M SetText: 	( szText n -- )
\ *G Sets the text in the \i n'th \d part of status window.
\ *P Use \i RaisedBorder: \d, \i NoBorder: \d or \i SunkenBorder: \d to set
\ ** the the style how the text is drawn.
		BorderStyle OR SB_SETTEXTA SendMessage:Self ?Win-Error ;M

;Class
\ *G End of MultiStatusbar class

MODULE

\ *Z

