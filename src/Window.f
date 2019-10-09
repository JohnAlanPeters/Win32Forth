\ $Id: Window.f,v 1.35 2013/12/17 19:25:22 georgeahubert Exp $

\ *D doc\classes\
\ *! Window
\ *T Window -- Class for window objects.
\ *S Glossary

require generic.f

cr .( Loading Window Class...)

\ Window class

only forth also definitions

in-application

0 value DefaultMenuBar \ Global default menubar
0 value ClassNameID

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Global windows procedure error, used here and in CONTROL.F
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value errCFA
 create errString MAXSTRING ALLOT

: WndProcError  ( error_value cfa -- 0 )
                to errCFA
                ?win-error-enabled
                IF      CASE    -2 OF   msg @ count     errString  place
                                        s"  \n  at: "   errString +place
                                        BASE @ >R  HEX
                                        errCFA (.)      errString +place
                                        r> BASE !
                                        errString count ErrorBox
                                   ENDOF
                        ENDCASE
                ELSE    drop
                THEN    0 ;

\ ------------------------------------------------------------

synonym WndRect  wrect

:CLASS Window         <SUPER Generic-Window
\ *G Base class for window objects.

      int CurrentPopup          \ current right mouse popup menu
      int CurrentMenu           \ current menubar
      int Width                 \ current width of client area
      int Height                \ current height of client area
      int OriginX
      int OriginY
      int cursor-on?
      int have-focus?
      int click-func
      int unclick-func
      int dbl-click-func
      int track-func
      int tracking?
      int clicking?
MAXSTRING bytes WindowClassName
      int Parent        \ object address of the parent window
                        \ Note: this ivar was moved here form the child-window class some
                        \ time ago. Altough it's not realy needed in the window class I
                        \ left it here in order not to break too much code (Sonntag, Juni 04 2006 dbu).
      int hWndParent    \ handle of the parent window (added Sonntag, Juni 04 2006 dbu)

:M ClassInit:   ( -- )
\ *G Initialise the class.
                ClassInit: super
                  0 to OriginX
                  0 to OriginY
                  0 to cursor-on?
                  0 to have-focus?
                  0 to tracking?
                  0 to clicking?
                  0 to CurrentPopup
                  0 to CurrentMenu
                  0 to Parent           \ added Sonntag, Juni 04 2006 dbu
                  0 to hWndParent       \ added Sonntag, Juni 04 2006 dbu
                640 to Width
                480 to Height
                ['] noop to click-func
                ['] noop to unclick-func
                ['] noop to dbl-click-func
                ['] noop to track-func
                WindowClassName MAXSTRING erase \ clear the class name
                ;M

\ -----------------------------------------------------------------
\ *N Window sizing
\ -----------------------------------------------------------------

:M GetSize:     ( --width height )
\ *G Get the size (width and height) of the window.
                Width Height ;M

:M Width:       ( -- width )
\ *G Get the width of the window.
                Width ;M

:M Height:      ( -- height )
\ *G Get the height of the window.
                Height ;M

:M SetSize:     ( width height -- )
\ *G Set the size of the window. \n
\ ** Note: The window itself will not be resized.
                to Height to Width ;M

:M On_Size:     ( hndl msg wParam -- )
\ *G User windows should override the On_Size: method. When this method is
\ ** called, the variables Width and Height will have already been set. \n
\ ** Default does nothing
                ;M

: set-size      ( lParam -- )
                word-split to Height  to Width ;

:M WM_SIZE      ( hndl msg wParam lParam -- res )
                set-size On_Size: [ self ] 0 ;M

:M WM_MOVE      ( hwnd msg wParam lParam -- res )
                EraseRect: WinRect                      \ make a new rectangle
                WinRect
                hWnd Call GetWindowRect                 \ adjust the window
                if   Left: WinRect  to OriginX
                     Top:  WinRect  to OriginY
                then EraseRect: WinRect
                0 ;M

:M MinSize:     ( -- width height )
\ *G To change the minimum window size, override the MinSize: method. Default is 10 by 10.
                10 10 ;M

:M MaxSize:     ( -- width height )
\ *G To change the maximum window size, override the MaxSize: method. Default is 8192 by 8192.
                8192 8192 ;M

:M StartSize:   ( -- width height )
\ *G To change the size of the window when it's created, override the StartSize: method
\ ** or call the SetSize: method before you create the window.
                Width Height ;M

:M SetOrigin:   ( x y -- )
\ *G To set the upper left corner of the window when it's created
\ ** call the SetOrigin: method before you create the window.
                screen-size 100 - rot min 0max to OriginY
                            100 -     min 0max to OriginX
                ;M

:M StartPos:    ( -- left top )
\ *G User windows should override the StartPos: method to set
\ ** the upper left corner of the window when it's created.
                OriginX OriginY ;M

: GETINFO ( SelId -- height width )
        >r
        ExWindowStyle: [ self ]
        WindowHasMenu: [ self ]                 \ have menu flag?
        WindowStyle:   [ self ]                 \ the window style
        0 0                                     \ adjust x,y relative to zero zero
        r> self find-method execute
        SetRect: WinRect
        WinRect                              \ make a new rectangle
        Call AdjustWindowRectEx ?win-error   \ adjust the window
        Height: WinRect                      \ adjusted height
        Width:  WinRect                      \ adjusted  width
        ;

:M WM_GETMINMAXINFO ( hwnd msg wparam lparam -- res )
        [ also hashed ]
        >r [ MinSize: ] literal
        GetInfo
        r@ 6 cells+ 2!
        [ MaxSize: ] literal
        GetInfo
        r> 8 cells+ 2! 0
        [ previous ]
        ;M

\ -----------------------------------------------------------------
\ -------------------- Window Class Procedure ---------------------
\ -----------------------------------------------------------------
\
\ The window will store its object address at offset zero in the Win32
\ window structure.  We will need to allocate 4 bytes of extra storage
\ when we register the window.  When the window is created Win32 will
\ initialize this memory to zero.  Until this data is filled in, we pass
\ all messages to DefWindowProc.  When we call CreateWindow, we pass the
\ base address of the object in the creation parameters field.  This is
\ the first DWORD of the CREATEPARMS structure passed in the lParam of the
\ WM_CREATE message.  When we see this message, we retrieve the object
\ address and store it in the extra window memory.  After this, we can
\ just retrieve it and know the address of the object.
\
\ We then search the object's class for the given message selector.  If
\ it is found we execute the method, otherwise we just call
\ DefWindowProc.
: (WndProc)   ( hwnd msg wparam lparam -- res )
        GWL_USERDATA 4 pick Call GetWindowLong  ( object address )
        ?dup 0=
        if
                2 pick WM_CREATE <>
                if
                        DefaultWindowProc exit
                then

                dup  @   \ window object pointer from
                         \ first cell of CREATEPARMS

                4 pick ( obj hwnd )
                2dup GWL_USERDATA swap Call SetWindowLong drop \ save pointer
                over !          \ set hWnd parameter of window struc

        then

        3 pick ( msg ) over obj>class MFA ((findm))
        if
                dup>r catch
                ?dup
                if      r@ WndProcError
                then    rdrop
        else    \ -- a1                                 \ the object address
                DefWindowProc: [ ( a1 -- ) ]            \ gets used here
        then    ;

4 callback TheWndProc (wndproc)

\ -----------------------------------------------------------------
\ *N Window creation
\ -----------------------------------------------------------------

Record: WndClass
        int Style
        int WndProc
        int ClsExtra
        int WndExtra
        int hInstance
        int hIcon
        int hCursor
        int hbrBackground
        int MenuName
        int ClassName
;Record

: default-class-name   ( -- )
\ The a default window class name for this window. Every window
\ will become it's own class name and it's own window class.
\ Note: If the window class name is set with SetClassName: before
\ the Start: method is called no default class name will be set.
                WindowClassName c@ 0=
                if   (classnamelock)
                     s" w32fWindow-" WindowClassName place
                     ClassNameID (.) WindowClassName +place
                     WindowClassName +null
                     1 +to ClassNameID
                     (classnameunlock)
                then
\ cr ." The WindowClassName is: " WindowClassName count type
                ;
: default-window-class ( -- )
\ Fill in the defaults for the window class.
                default-class-name
                WndClassStyle: [ self ]                            to Style
                TheWndProc                                         to wndProc
                0                                                  to clsExtra
                4                                                  to wndExtra
                appInst                                            to hInstance
                DefaultIcon:   [ self ]                            to hIcon
                DefaultCursor: [ self ] NULL Call LoadCursor       to hCursor
                WHITE_BRUSH                  Call GetStockObject   to hbrBackground
                NULL                                               to MenuName
                WindowClassName 1+                                 to ClassName ;

: register-the-class   ( -- f )
\ Register the window class.
                WndClass Call RegisterClass ;

: register-frame-window  ( -- f )
\ Init the window class and register it.
                default-window-class
                register-the-class ;

: create-frame-window   ( -- hwnd )
                \ calc window rect
                0 0                                     \ adjust x,y relative to 0,0
                StartSize:     [ self ]                 \ width, height
                2dup to Height to Width                 \ Save Height Width
                SetRect: WinRect

                ExWindowStyle: [ self ]                 \ extended window style
                WindowHasMenu: [ self ]                 \ have menu flag?
                WindowStyle:   [ self ]                 \ window style
                WinRect                                 \ make a new rectangle
                call AdjustWindowRectEx ?win-error      \ adjust the window

                \ create the window
                ^base                                   \ creation parameters
                appInst                                 \ program instance
                NULL LoadMenu: [ self ]                 \ menu
                ParentWindow:  [ self ]                 \ parent window handle
                Height: WinRect                         \ adjusted height
                Width:  WinRect                         \ adjusted width
                StartPos:      [ self ] swap            \ y, x starting position
                WindowStyle:   [ self ]                 \ the window style
                WindowTitle:   [ self ]                 \ the window title
                WindowClassName 1+                      \ class name
                ExWindowStyle: [ self ]                 \ extended window style
                Call CreateWindowEx

                EraseRect: WinRect
                ;

:M SetClassLong: ( long offset -- )
\ *G The SetClassLong method replaces the specified 32-bit (long) value at the
\ ** specified offset into the extra class memory or the WNDCLASS structure for
\ ** the class to which the window belongs.
                hWnd Call SetClassLong drop ;M

:M GetClassLong: ( offset -- long )
\ *G The GetClassLong function retrieves the specified 32-bit (long) value from
\ ** the WNDCLASS structure associated with the window.
                hWnd Call GetClassLong ;M

:M WndClassStyle:       ( -- style )
\ *G User windows should override the WndClassStyle: method to
\ ** set the style member of the the WNDCLASS structure associated with the window.
\ ** Default style is CS_DBLCLKS, CS_HREDRAW and CS_VREDRAW.
\ *P To prevent flicker on sizing of the window your method should return CS_DBLCLKS
\ ** only.
                [ CS_DBLCLKS CS_HREDRAW CS_VREDRAW or or ] literal ;M

:M Start:       ( -- )
\ *G Create the window.
\ *P Before the window is created a default window class name for this window will
\ ** be set. Every window will become it's own class name and it's own window class.
\ ** Note: If the window class name is set with SetClassName: before the Start: method
\ ** is called no default class name will be set.

\ The default window class is appropriate for frame windows. Child
\ windows will define their own window class. \n
\ The default window class has the following properties: \n
\ Style: CS_DBLCLKS, CS_HREDRAW and CS_VREDRAW \n
\ White background \n
\ Application icon

                hWnd 0=
                if   register-frame-window drop
                     create-frame-window dup to hWnd
                     if   SW_SHOWNORMAL Show: self
                          Update: self
                     then
                else SetFocus: self
                then ;M

\ *P On_Init: and On_Done were moved to Generic-Window.

\ *E Your On_Init: and On_Done: methods should look like this:
\ **
\ **      :M On_Init:  ( -- )
\ **              On_Init: super
\ **              ... other initialization ...
\ **              ;M
\ **
\ **      :M On_Done:  ( -- )
\ **              ... other cleanup ...
\ **              On_Done: super
\ **              ;M
\ **
\ **
\ ** The main application window will need the following methods, which cause the
\ ** program to terminate when the user closes the main application window.
\ ** Don't uncomment these out here, copy them into your application window
\ ** Object or Class, and then uncomment them out.
\ **
\ ** :M WM_CLOSE  ( h m w l -- res )
\ **              bye
\ **              0 ;M
\ **
\ ** :M On_Done:  ( h m w l -- res )
\ **              0 call PostQuitMessage drop     \ terminate application
\ **              On_Done: super                  \ cleanup the super class
\ **              0 ;M
\ **
\ ** For multi-tasking applications the main window of each task should define
\ ** the following method, to quit the message loop and exit the task.
\ **
\ ** :M On_Done:  ( h m w l -- res )
\ **              0 call PostQuitMessage drop     \ terminate application
\ **              On_Done: super                  \ cleanup the super class
\ **              0 ;M

:M WM_CLOSE     ( hwnd msg wparam lparam -- res )
                Close: [ self ] ;M

:M WM_DESTROY   ( hwnd msg wparam lparam -- res )
                On_Done: [ self ]
                DefWindowProc: [ self ]
                0 to hWnd
                ;M

:M SetClassName: ( addr len -- )
\ *G Set the window class name.
                WindowClassName place WindowClassName +NULL ;M

:M GetClassName: ( -- addr len )
\ *G Get the window class name.
                WindowClassName count ;M

:M SetParentWindow: ( hWndParent -- )
\ *G Set handle of the owner window (0 if no parent).
                to hWndParent ;M

:M GetParentWindow: ( -- hWndParent )
\ *G Get the handle of the owner window (0 if no parent).
                hWndParent ;M

:M SetParent:   ( hWndParent -- )
\ *G Set handle of the owner window (0 if no parent).
\ *P NOTE: This method is deprecated. Use SetParentWindow: instead.
                to hWndParent ;M DEPRECATED

:M ParentWindow: ( -- hWndParent )
\ *G Get the handle of the owner window (0 if no parent).
\ *P NOTE: This method is deprecated. Use GetParentWindow: instead.
                hWndParent ;M DEPRECATED

:M DefaultCursor: ( -- cursor-id )
\ *G User windows should override the DefaultCursor: method to
\ ** set the default cursor for window. Default is IDC_ARROW.
                IDC_ARROW ;M

:M DefaultIcon: ( -- hIcon )
\ *G User windows should override the WindowStyle: method to
\ ** set the default icon handle for window. Default is the W32F icon.
                101 appInst Call LoadIcon \ dup 0=
\                if  drop 100 z" w32fConsole.dll" Call GetModuleHandle Call LoadIcon
                ( then ) ;M

:M WindowStyle: ( -- style )
\ *G User windows should override the WindowStyle: method to
\ ** set the window style. Default is WS_OVERLAPPEDWINDOW.
                WS_OVERLAPPEDWINDOW ;M

:M ExWindowStyle: ( -- extended_style )
\ *G User windows should override the ExWindowStyle: method to
\ ** set the extended window style. Default is NULL.
                0 ;M

:M WindowTitle: ( -- Zstring )
\ *G User windows should override the WindowTitle: method to
\ ** set the window caption. Default is "Window".
                z" Window" ;M

\ -----------------------------------------------------------------
\ *N Painting
\ -----------------------------------------------------------------

WinDC dc
\ *G The window's device context. \n
\ ** It will be valid only when handling the WM_PAINT message
\ ** (see On_Paint: method)

Record: &ps
\ *G The PAINTSTRUCT for Begin- and EndPaint \n
\ ** It will be valid only when handling the WM_PAINT message
\ ** (see On_Paint: method)
      int ps_hdc
      int ps_fErase
      int ps_left
      int ps_top
      int ps_right
      int ps_bottom
      int ps_fRestore
      int ps_fIncUpdate
      32 bytes rgbReserved
;RecordSize: sizeof(PAINTSTRUCT)

:M On_EraseBackground: ( hwnd msg wparam lparam -- res )
\ *G User windows should override the On_EraseBackground: method to handle
\ ** WM_ERASEBKGND messages. \n
\ ** Default does nothing.
                DefWindowProc: [ self ] ;M

:M WM_ERASEBKGND ( hwnd msg wparam lparam -- res )
                On_EraseBackground: [ self ] ;M

:M On_Paint:    ( -- )
\ *G User windows should override the On_Paint: method to handle WM_PAINT messages. \n
\ ** Before this method is called BeginPaint will be called so that the PAINTSTRUCT
\ ** (&PS ivar) and the window device context (DC ivar) are initialized. \n
\ ** Check ps_fErase in your method to see if the background of the window should
\ ** be drawn and use ps_left, ps_top, ps_right and ps_bottom to see which part of
\ ** the window should be painted. \n
\ ** Default does nothing.
                ;M

:M WM_PAINT     ( hwnd msg wparam lparam -- res )
                \ Check if the window has an update region.
                \ If not don't call On_Paint:
                0 0 hWnd call GetUpdateRect
                if   &ps BeginPaint: self PutHandle: dc
                     On_Paint: [ self ]
                     &ps EndPaint: self 0 PutHandle: dc
                then 0 ;M

\ -----------------------------------------------------------------
\ *N Menu support
\ -----------------------------------------------------------------

:M LoadMenu:    ( parent -- menuhandle )
                drop                            \ window has no parent
                WindowHasMenu: [ self ]         \ have menu flag?
                -if     drop CurrentMenu 0=
                        if      DefaultMenuBar to CurrentMenu
                        then
                        MenuHandle: CurrentMenu ?dup 0=
                        if   self LoadMenu: CurrentMenu
                        MenuHandle: CurrentMenu
                        then
                then
                ;M

:M SetMenuBar:  ( menubar -- )
                to CurrentMenu
                self Start: CurrentMenu
                ;M

:M SetPopupBar: ( menubar -- )
                to CurrentPopup
                self Start: CurrentPopup
                ;M

:M WindowHasMenu: ( -- flag )
\ *G Flag is true if the window has a menu. Override this method if your window has a
\ ** menu. Default is false.
                 FALSE ;M

\ -----------------------------------------------------------------
\ *N Cursor (caret) support
\ -----------------------------------------------------------------

int c-width
int c-height
int c-x
int c-y

:M MoveCursor:  ( gx gy -- )
\ *G Move the caret.
                1+              \ correct for single pixel start offset
                have-focus?
                 cursor-on? and
                hWnd 0<>    and
                if      hWnd call HideCaret   ?win-error
                        2dup to c-y to c-x
                        swap call SetCaretPos ?win-error
                        hWnd call ShowCaret   ?win-error
                else    to c-y to c-x
                then    ;M

:M MakeCursor:  ( gx gy width height -- )
\ *G Create the caret.
                have-focus? cursor-on? 0= and
                if      2dup to c-height to c-width
                        swap 0
                        hWnd call CreateCaret ?win-error
                        2dup to c-y to c-x
                        swap call SetCaretPos ?win-error
                        hWnd call ShowCaret   ?win-error
                        TRUE to cursor-on?
                else    4drop
                then
                ;M

:M DestroyCursor: ( -- )
\ *G Destroy the caret.
                have-focus? cursor-on? and
                hWnd 0<>               and
                if      hWnd call HideCaret    drop
                             call DestroyCaret drop
                        FALSE to cursor-on?
                then
                ;M

:M ShowCursor:  ( -- )
\ *G Show the caret.
                cursor-on? 0=
                if      c-x c-y c-width c-height MakeCursor: self
                then
                ;M

:M HideCursor:  ( -- )
\ *G Hide the caret.
                cursor-on?
                if      DestroyCursor: self
                        FALSE to cursor-on?
                then
                ;M

:M On_SetFocus: ( h m w l -- )
\ *G Override the method to handle the WM_SETFOCUS message. \n
\ ** Example: When cursor is used, you will need something like the following
\ ** to control the position of the cursor in the window:
\ *E            cursor-col char-width  *
\ **            cursor-row char-height *
\ **            char-width char-height MakeCursor: self
                true to have-focus? ;M

:M WM_SETFOCUS  ( h m w l -- )
                On_SetFocus: [ self ] 0 ;M

:M On_KillFocus: ( h m w l -- )
\ *G Override the method to handle the WM_KILLFOCUS message. \n
\ ** Example: Use only when you are displaying a cursor in the window:
\ *E            DestroyCursor: self
                false to have-focus? ;M

:M WM_KILLFOCUS ( h m w l -- res )
                On_KillFocus: [ self ]
                0 ;M

\ *N Keyboard and mouse handling

:M PushKey:     ( c1 -- )
\ *G override to process keys yourself.
                pushkey ;M

: vga-skey      ( c1 -- )
\ push a special key with control or shift bits
                VK_CONTROL Call GetKeyState 0x8000 and
                if control_mask or then
                VK_SHIFT   Call GetKeyState 0x8000 and
                if shift_mask or then
                PushKey: [ self ] ;

: shift-pushkey ( c1 -- )
\ push a special key with shift bits
                dup 32 <                        \ if less than 32
                VK_SHIFT Call GetKeyState 0x8000 and and
                                                \ and shift was pressed
                if shift_mask or then  PushKey: [ self ] ;

:M WM_CHAR      ( h m w l -- res )
\ normal & control chars
                over shift-pushkey 0 ;M

\ :M WM_SYSCHAR   ( h m w l -- res )              \ alt chars come here
\                 over alt_mask or shift-pushkey  \ flag as an Alt-key
\                 DefWindowProc: [ self ]
\                 0 ;M

:M WM_SYSKEYDOWN   ( h m w l -- res )
                over VK_F10 =                \ if its an F10,
                if   K_F10 vga-skey          \ then push key value
                     0                       \ and signal we handled it
                else DefWindowProc: [ self ]
                then ;M

:M WM_KEYDOWN   ( h m w l -- res )
        drop
        case    VK_F1      of  K_F1     vga-skey  endof
                VK_F2      of  K_F2     vga-skey  endof
                VK_F3      of  K_F3     vga-skey  endof
                VK_F4      of  K_F4     vga-skey  endof
                VK_F5      of  K_F5     vga-skey  endof
                VK_F6      of  K_F6     vga-skey  endof
                VK_F7      of  K_F7     vga-skey  endof
                VK_F8      of  K_F8     vga-skey  endof
                VK_F9      of  K_F9     vga-skey  endof
                VK_F11     of  K_F11    vga-skey  endof
                VK_F12     of  K_F12    vga-skey  endof
                VK_HOME    of  K_HOME   vga-skey  endof
                VK_END     of  K_END    vga-skey  endof
                VK_INSERT  of  K_INSERT vga-skey  endof
                VK_DELETE  of  K_DELETE vga-skey  endof
                VK_LEFT    of  K_LEFT   vga-skey  endof
                VK_RIGHT   of  K_RIGHT  vga-skey  endof
                VK_UP      of  K_UP     vga-skey  endof
                VK_DOWN    of  K_DOWN   vga-skey  endof
                VK_SCROLL  of  K_SCROLL vga-skey  endof
                VK_PAUSE   of  K_PAUSE  vga-skey  endof
                VK_PRIOR   of  K_PGUP   vga-skey  endof
                VK_NEXT    of  K_PGDN   vga-skey  endof
        endcase
		0 ;M

: set-mousexy   ( l -- )
                word-split
                dup 0x8000 and if 0xFFFF0000 or then 0max to mousey
                dup 0x8000 and if 0xFFFF0000 or then 0max to mousex
                ;

: null-check    ( a1 -- a1 )
                ?win-error-enabled 0=
                if      dup 0=
                        if      drop ['] noop   \ convert null to NOOP
                                exit            \ and exit
                        then
                then
                dup 0= s" Attempt to execute a NULL function" ?TerminateBox
                ;

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
                dup  0=
                if   over LOWORD
                     CurrentMenu  if dup DoMenu: CurrentMenu then
                     CurrentPopup if dup DoMenu: CurrentPopup then
                     drop
                then ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
                OnWmCommand: [ self ]
                0 ;M

:M WM_RBUTTONDOWN ( h m w l -- res )
                set-mousexy
                CurrentPopup
                if      rot >r
                        mousex mousey r> Track: CurrentPopup
                then
                0 ;M

:M WM_LBUTTONDOWN ( h m w l -- res )
                set-mousexy
                clicking? 0=
                if      TRUE to clicking?
                        click-func null-check execute
                then
                0 ;M

:M WM_LBUTTONDBLCLK ( h m w l -- res )
                set-mousexy
                dbl-click-func null-check execute
                0 ;M

:M WM_LBUTTONUP ( h m w l -- res )
                set-mousexy
                clicking?
                if      unclick-func null-check CATCH
                        FALSE to clicking?
                        THROW
                then
                0 ;M

:M WM_MOUSEMOVE ( h m w l -- res )
                set-mousexy
                MK_LBUTTON   and        \ left mouse button is down
                tracking? 0= and        \ and we aren't already tracking
                if      TRUE to tracking?
                        track-func null-check CATCH
                        FALSE to tracking?      \ must reset tracking flag
                        THROW
                then
                0 ;M

:M SetClickFunc: ( cfa -- )
                to click-func
                ;M

:M SetDblClickFunc: ( cfa -- )
                to dbl-click-func
                ;M

:M SetTrackFunc: ( cfa -- )
                to track-func
                ;M

:M SetUnClickFunc: ( cfa -- )
                to unclick-func
                ;M

\ -----------------------------------------------------------------
\ *N Message handling
\ -----------------------------------------------------------------

\ [cdo] removed WM_WIN32FORTH message handling (replaced by WM_COPYDATA)
\       also removed Dexh comments which would continue to appear in doc
\ :M Win32Forth:  ( h m w l -- )
\ If you define an application specific window class or window object
\ that redefines the method Win32Forth: to perform its own function
\ rather than just doing a beep, then your window will be able to handle
\ interprocess messages.
\                 forth-msg-chain do-chain ;M
\
\ :M DefWindowProc: ( h m w l -- res )
\ Call the DefaultWindowProc for the window.
\                 2 pick WM_WIN32FORTH =
\                 if   Win32Forth: [ self ]
\                 else DefaultWindowProc
\                 then ;M

:M DefWindowProc: ( h m w l -- res )
\ *G Call the DefaultWindowProc for the window.
                DefaultWindowProc
                ;M

\ -----------------------------------------------------------------
\ *N everything else...
\ -----------------------------------------------------------------

: GetDeskTopSize ( -- w h )
\ Retrieves the size (width and height) of the work area on the primary
\ display monitor. The work area is the portion of the screen not obscured
\ by the system taskbar or by application desktop toolbars. \n
\ Width and height are expressed in virtual screen coordinates.
                0 pad 0 spi_getworkarea Call SystemParametersInfo DROP
                pad 8 + 2@ swap ;

: GetPositionParent ( -- x y wb hb )
                hWndParent dup 0>
                if   pad 16 erase
                     pad swap Call GetWindowRect  ?win-error
                     pad 2@ swap pad 8 + 2@ swap
                else drop 0 0 GetDeskTopSize  \ take the desktop when there is no parent.
                then ;

: MidPoint ( x y w h - mx my )
\ Calculate the middle point of the given rectangle
                rot  + 2/  -rot  + 2/  swap  ;

: CenterAroundMidpoint { mx my w h -- xl yl } \ w32f
                GetDeskTopSize 40 -
                my h 2/  - 0 max
                swap h - min
                mx w 2/  - 0 max
                rot w - min
                swap ;

:M CenterWindow: ( -- x y )
\ *G Calculate the position of the window to center it in the middle of it's parent window.
\ ** When the windows has no parent it will be placed in the middle of the primary display
\ ** monitor.
                GetPositionParent
                MidPoint
                GetSize: self
                CenterAroundMidpoint
                ;M

\ I (dbu) think the methods should be in the base class, but...

\ the rectangle winrect was moved to after the ints width are height since their offsets
\ are hard-coded in the file lib\RegistrySupport.f (gah). The same applies to parent.

:M Enable:      ( f1 -- )
\ *G Enable or disable the window.
                hWnd Call EnableWindow drop ;M

:M SetTitle:    { adr len \ temp$ -- }
\ *G Set the window title.
                MAXSTRING LocalAlloc: temp$
                adr len "CLIP" temp$ place
                               temp$ +NULL
                               temp$ 1+
                hWnd call SetWindowText ?win-error \ change the window title
                ;M

\ -------------------- Get/Release DC --------------------

: get-dc      ( -- )    GetDC: self  PutHandle: dc ;

: release-dc  ( -- )    GetHandle: dc  ReleaseDC: self ;


\ -------------------- Font Selection --------------------

: system-fixed-font  ( -- )
        SYSTEM_FIXED_FONT SelectStockObject: dc drop ;

: small-font  ( -- )
        ANSI_FIXED_FONT SelectStockObject: dc drop ;

;CLASS
\ *G End of window class.

\ *S Helper words outside the class

: find-window   ( z"a1 -- hWnd ) \ w32f
\ *G Find a window.
                0 swap Call FindWindow ;

: send-window   ( lParam wParam Message_ID hWnd -- ) \ w32f
\ *G Send a message to a window.
                Call SendNotifyMessage drop ;

: LoadIconFile  ( adr len -- hIcon ) \ w32f
\ *G Load an icon from an icon file.
        asciiz >r LR_LOADFROMFILE 0 0 IMAGE_ICON r>
        NULL call LoadImage ;

\ *Z
