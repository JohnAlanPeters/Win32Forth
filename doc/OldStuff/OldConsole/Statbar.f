\ $Id: Statbar.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $

\    File: Statbar.f
\  Author: Jeff Kelm
\ Created: 24-Sep-1998
\ Updated: August 17th, 2003 dbu
\ Classes to handle Statusbars (simple and multipart)

Comment:  Revision History (most recent first)
August 17th, 2003 dbu
 - Changed to use in WinEd 2.21.05 and later
19981231
 - Incorporated the new ChildWindow class.
19981216
 - Removed Redraw: SetStyle: GetStyle: methods, now handled in BasicWin.f
 - Changed SetSimple: to eliminate flag and created SetMulti: to make up for it
19981117
 - General cosmetic updates
 - redefined to use BaseWindow superclass and call BasicWin.f
 - eliminated SetParent: from Create: set by CreateStatusWindow now
Comment;


NEEDS BasicWin.f
CR  .( Loading Statusbar class for the Console window...)



\ Notes:
\ 1) SBARS_SIZEGRIP don't appear to work.  Always shows up with the size grip
\    box.



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ Simple Statusbar Class
\
:Class Console_Statusbar  <Super Console_ChildWindow

      INT BorderStyle \ style of border to use

   :M DefStyle: ( -- style)   \ default control style
      [ WS_VISIBLE WS_CHILD OR ] literal
      ;M

   :M DefClassName: ( -- ClassName)   \ default class name
      Z" msctls_statusbar32"
      ;M

   :M Create: ( hParent)   \ creates an empty statusbar in parent window
      Create: super
      0 TRUE SB_SIMPLE SendMessage: self DROP
      ;M

comment:
:Class Statusbar  <Super BaseWindow

      INT BorderStyle \ style of border to use

   :M DefStyle: ( -- style)   \ override if another style is needed
      WS_BORDER WS_VISIBLE OR   \ WS_CHILD is forced
      ;M
comment;

   :M RaisedBorder: ( -- )   \ text drawn below border (default)
      0 TO BorderStyle
      ;M

   :M NoBorder: ( -- )   \ text drawn at border level (no border)
      SBT_NOBORDERS TO BorderStyle
      ;M

   :M SunkenBorder: ( -- )   \ text drawn above border
      SBT_POPOUT TO BorderStyle
      ;M

   :M ClassInit: ( -- )   \ initialize class
      ClassInit: super
      RaisedBorder: self           \ default, text lower than border
      ;M

comment:
   :M Create: ( hParent)   \ creates an empty statusbar in parent window
      CreateNewID                  \ Statusbar ID
      SWAP
      NULL                         \ initial string to display
      DefStyle: self  WS_CHILD OR  \ style
      Call CreateStatusWindow  DUP PutHandle: self  ?WinError
      0 TRUE SB_SIMPLE SendMessage: self DROP
      ;M
comment;

   \ NULL MinHeight: self  appears to reset to the default height statusbar
   :M MinHeight: ( #pixels)   \ set minimum height of text region (not including borders)
      0 SWAP SB_SETMINHEIGHT SendMessage: self DROP
      ;M

   :M GetBorders: ( -- hWidth vWidth divWidth)   \ returns the border widths in pixels
      HERE 0 SB_GETBORDERS SendMessage: self ?WinError
      HERE DUP @  SWAP CELL+ DUP @  SWAP CELL+ @
      ;M

   :M Redraw: ( -- )   \ redraw the statusbar after changes (e.g., size)
      0 0 WM_SIZE SendMessage: self DROP
      ;M

\   :M SetStyle: ( style)   \ set style of statusbar "on the fly"
\      GWL_STYLE GetHandle: self Call SetWindowLong DROP
\      Redraw: self
\      ;M

\   :M GetStyle: ( -- style)   \ get current style of statusbar
\      GWL_STYLE GetHandle: self Call GetWindowLong
\      ;M

   :M SetText: ( szText)   \ sets simple status bar text
      255 BorderStyle OR SB_SETTEXT SendMessage: self ?WinError
      ;M

   :M Clear: ( -- )   \ clears text from status window
      Z" " SetText: self
      ;M

;Class



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ Multipart Statusbar Class
\
:Class Console_MultiStatusbar <Super Console_Statusbar

      INT nParts    \ number of parts in statusbar
      INT aWidths   \ address of widths table

   :M Create: ( hParent)
      Create: super
      0 FALSE SB_SIMPLE SendMessage: self DROP
      ;M

   :M SetParts: ( aWidths nParts)   \ width table address and count
      TO nParts
      TO aWidths
      aWidths nParts SB_SETPARTS SendMessage: self ?WinError
      ;M

   :M GetParts: ( -- aWidths nParts)   \ retrieve data structure info
      aWidths  nParts
      ;M

   :M SetSimple: ( flag)   \ sets status bar to show single-part
      0 TRUE SB_SIMPLE SendMessage: self DROP
      ;M

   :M SetMulti: ( flag)   \ sets status bar to show multiparts
      0 FALSE SB_SIMPLE SendMessage: self DROP
      ;M

   :M SetText: ( szText n)   \ set text in n'th part
      BorderStyle OR
\ was      SB_SETTEXT SendMessage: self DROP
( is)      SB_SETTEXT SendMessage: self ?WinError
      ;M

;Class

