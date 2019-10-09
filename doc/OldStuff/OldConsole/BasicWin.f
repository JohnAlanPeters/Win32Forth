\ $Id: BasicWin.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $

\    File: BasicWin.f
\  Author: Jeff Kelm
\ Created: 17-Nov-1998
\ Updated: August 17th, 2003 dbu
\ Defines some basic window classes

Comment:  Revision History (most recent first)
August 17th, 2003 dbu
 - Changed to use in WinEd 2.21.05 and later
19990519
 - Modify to use 'stack frames' instead of HERE for temp
   storage.  Items marked ( fix) have not yet been properly
   handled.
19990422
 - Removed the changes on 990412, didn't work.  Added more to
   text in PutHandle: for debugging
19990412
 - Add equivalent to InitCommonControls to ChildWindow, Create:
   to try to correct a problem with turnkeying under Win95
   reported by Martin.Bitter@t-online.de (Martin Bitter).
19990315
 - Changed GetClientSize: to give ( x y) stack arguments
   (had incorrectly given (y x) stack).
19990218
 - GetStyleEx: changed to GetExStyle: in +/-ExStyle:
19990128
 - Rename StyleEx to ExStyle in several places.
 - Change logic of -Style/StyleEx: so that it doesn't set a flag
   if it wasn't already set (was XOR, now INVERT AND).
 - Extended styles can be NULL which gives errors in
   Get/SetStyleEx: and +/-StyleEx: from Get/SetWindowLong: which
   test returned results with ?WinError.
19981231
 - Incorporated the new ChildWindow class.
19981216
 - Change stack ordering to ( x y) for Get/SetPosition:
   and Get/SetSize:
 - replaced  GetHandle: self  with  hWnd
19981208
 - Added Get/SetText: methods
19981207
 - Added SetFocus: method
19981204
 - Added -Style: and -StyleEx: methods
19981202
 - Added +Style: and +StyleEx: methods
 - Rename GetWindowSize: to GetSize: for consistency
19981120
 - Changed ?WinError to DROP in Enable: & Disable: methods
19981117
 - separated these from WinBase.f where they had been defined.
 - General cosmetic updates
 - Added some validity checking to PutHandle: and Destroy:
 - Added methods to BaseWindow (SetID: GetStyle: SetStyle:
   GetStyleEx: GetWindowProc: SetWindowProc: Enable: Disable:
   IsVisible:)
 - Removed BaseChildWindow and incorporate functionality into
   BaseWindow.
 - Renamed BaseChildWindow to ChildWindow
           MoveTo: to SetPosition:
           Resize: to SetSize:
           GetWindowPos: to GetPosition:
 - Remove GetClientRect: (GetClientSize: provides same
   functionality)
Comment;



NEEDS WinBase.f
CR  .( Loading Base Window classes...)



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ A basic window class with some primative methods
\
:Class Console_BaseWindow  <Super Object

   INT hWnd   \ the window handle

   :M GetHandle: ( -- hWnd)   \ return the window handle
      hWnd
      ;M

   :M PutHandle: ( hWnd)   \ set the window handle
      DUP  Call IsWindow  0= ABORT" Nonexistent window handle"
      TO hWnd
      ;M

   :M SendMessage: ( lparam wparam msg -- result)
      hWnd  Call SendMessage
      ;M

   :M Show: ( -- )   \ show the window
      SW_SHOW  hWnd  Call ShowWindow DROP
      ;M

   :M Hide: ( -- )   \ hide the window
      SW_HIDE  hWnd  Call ShowWindow DROP
      ;M

   :M GetWindowLong: ( offset -- n)   \ get window memory
                                      \ contents at offset
      hWnd  Call GetWindowLong
      ( GetWindowLong could return NULL, so don't ?WinError)
      ;M

   :M SetWindowLong: ( n offset)   \ set window memory contents
                                   \ at offset
      hWnd  Call SetWindowLong  DROP
      ( SetWindowLong could return NULL, so don't ?WinError)
      ;M

   :M GetWindowRect: ( -- b r t l)   \ get window bounding rect
\ was      HERE hWnd  Call GetWindowRect  ?WinError
\ was      HERE 3 CELLS + @  HERE 2 CELLS + @  HERE CELL+ @  HERE @
      4 sFrame  \ save space on stack for RECT
      hWnd Call GetWindowRect ?WinError  ( b r t l)
      ;M

   :M GetClientSize: ( -- cx cy)   \ returns size of client area
\ was      HERE hWnd  Call GetClientRect ?WinError
\ was      HERE 2 CELLS + @  HERE @ -
\ was      HERE 3 CELLS + @  HERE CELL+ @ -
      4 sFrame   \ save space on stack for RECT
      hWnd Call GetClientRect ?WinError  ( b r t l)
      SWAP >R  -  SWAP R> -
      ;M

   :M GetSize: ( -- cx cy)   \ returns size of window rectangle
\ was      HERE hWnd  Call GetWindowRect ?WinError
\ was      HERE 2 CELLS + @  HERE @ -
\ was      HERE 3 CELLS + @  HERE CELL+ @ -
      GetWindowRect: self  ( b r t l)
      SWAP >R  -  SWAP R> -
      ;M

   :M SetSize: ( cx cy)   \ set size of window rectangle
\ was      SWAP 2>R  SWP_NOOWNERZORDER SWP_NOMOVE OR
( is)      SWAP 2>R  [ SWP_NOZORDER SWP_NOMOVE OR ] literal
      2R> 0 0 NULL  hWnd Call SetWindowPos ?WinError
      ;M

   :M GetPosition: ( -- x y)   \ return upper-left corner
\ was      HERE hWnd  Call GetWindowRect ?WinError
\ was      HERE 2@ SWAP
      GetWindowRect: self  2NIP  SWAP
      ;M

   :M SetPosition: ( x y)  \ set position of upper-left corner
\ was      SWAP 2>R  SWP_NOOWNERZORDER SWP_NOSIZE OR
( is)      SWAP 2>R  [ SWP_NOZORDER SWP_NOSIZE OR ] literal
      0 0 2R> NULL  hWnd Call SetWindowPos ?WinError
      ;M

   :M Destroy: ( -- )   \ destroy the window
      hWnd Call DestroyWindow  DUP
      IF  0 TO hWnd  THEN  ?WinError
      ;M

   :M GetID: ( -- id)   \ retrieve window identifier
      GWL_ID GetWindowLong: self
      ;M

   :M SetID: ( id)   \ set the window identifier
      GWL_ID SetWindowLong: self
      ;M

   :M GetStyle: ( -- style)   \ retrieve basic window style
      GWL_STYLE GetWindowLong: self
      ;M

   :M SetStyle: ( style)   \ set the basic window style
      GWL_STYLE SetWindowLong: self
      ;M

   :M +Style: ( style)   \ add to the basic window style
      GetStyle: self OR  SetStyle: self
      ;M

   :M -Style: ( style)   \ remove from the basic window style
      INVERT  GetStyle: self AND  SetStyle: self
      ;M

   :M GetExStyle: ( -- exStyle)   \ retrieve extended styles
      GWL_EXSTYLE GetWindowLong: self
      ;M

   :M SetExStyle: ( exStyle)   \ set the extended window style
      GWL_EXSTYLE SetWindowLong: self
      ;M

   :M +ExStyle: ( exStyle)   \ add to the extended window style
      GetExStyle: self OR  SetExStyle: self
      ;M

   :M -ExStyle: ( exStyle)   \ add to the extended window style
      INVERT  GetExStyle: self AND  SetExStyle: self
      ;M

   :M GetParent: ( -- hParent)   \ handle of parent window
      hWnd Call GetParent
      ;M

   :M SetParent: ( hWnd)   \ change the parent window
      hWnd Call SetParent  ?WinError
      ;M

   :M Enable: ( -- )   \ enables mouse and keyboard input to
                       \ the window or control
      TRUE hWnd Call EnableWindow  DROP
      ;M

   :M Disable: ( -- )   \ disables mouse and keyboard input to
                        \ the window or control
      FALSE hWnd Call EnableWindow  DROP
      ;M

   :M SetFocus: ( -- )   \ set keyboard focus to this window
      hWnd Call SetFocus  DROP
      ;M

   :M IsVisible: ( -- f)   \ ff=window not visible
      hWnd Call IsWindowVisible
      ;M

   :M SetText: ( szText)   \ send text to window/control
      hWnd Call SetWindowText  ?WinError
      ;M

   :M GetText: ( -- a n)   \ get window/control text
( fix)      MAXSTRING HERE hWnd Call GetWindowText  DUP ?WinError
      HERE SWAP
      ;M

;Class



:Class Console_ChildWindow  <Super Console_BaseWindow

   :M DefStyle: ( -- style)   \ default control style
      [ WS_VISIBLE WS_CHILD OR ] literal
      ;M

   :M DefExStyle: ( -- exStyle)   \ default extended style
      NULL
      ;M

   :M DefClassName: ( -- ClassName)   \ default class name
      Z" STATIC"
      ;M

   :M DefSize: ( -- cx cy)   \ default window size
      CW_USEDEFAULT CW_USEDEFAULT
      ;M

   :M DefPosition: ( -- x y)   \ default window position
      CW_USEDEFAULT CW_USEDEFAULT
      ;M

   :M Create: ( hParent -- )   \ create a child of parent window
      >R
      NULL                              \ creation parameters
      AppInst                           \ instance handle
      CreateNewID                       \ menu handle/control ID
      R>                                \ parent window
      DefSize: [ self ]  SWAP           \ window size ( h w)
      DefPosition: [ self ]  SWAP       \ window pos ( y x )
      DefStyle: [ self ]                \ window style
      NULL                              \ window title
      DefClassName: [ self ]            \ class name
      DefExStyle: [ self ]              \ extended window style
      Call CreateWindowEx  DUP TO hWnd  ?WinError
      ;M

;Class
