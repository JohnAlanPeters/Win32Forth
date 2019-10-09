needs opengl.f     \ Basic OpenGL binding to Win32Forth. April 26th, 2013 by Jos v.d.Ven


menubar Nomenu
 popup " No menu. "
endbar


 WS_EX_APPWINDOW WS_EX_WINDOWEDGE or value ExStyle
 CS_HREDRAW  CS_VREDRAW or CS_OWNDC or CS_BYTEALIGNCLIENT or value CsStyle
 WS_CLIPSIBLINGS WS_CLIPCHILDREN or WS_OVERLAPPEDWINDOW or WS_VISIBLE or value WindowStyle

0 value hrgn
0 value OneTime

:Object OpenGLWindow    <Super Window
int SecondPaint


Rectangle clientRect
Record: WndClassEx
        int cbSizeEx
        int StyleEx
        int WndProcEx
        int ClsExtraEx
        int WndExtraEx
        int hInstanceEx
        int hIconEx
        int hCursorEx
        int hbrBackgroundEx
        int MenuNameEx
        int ClassNameEx
        int hIconSmEx
;Record

: default-window-classEx ( -- )   \ fill in the defaults for the window class
        12 cells                                                to cbSizeEx
        CsStyle                                                 to StyleEx
        TheWndProc                                              to wndProcEx
        0                                                       to clsExtraEx
        0                                                       to wndExtraEx
        appInst                                                 to hInstanceEx
        101 appinst                  Call LoadIcon              to hIconEx
        DefaultCursor: [ self ] NULL Call LoadCursor            to hCursorEx
        0                                                       to hbrBackgroundEx
        NULL                                                    to MenuNameEx
        WindowClassName 1+                                      to ClassNameEx
        0                                                       to hIconSmEx
  ;

\ register the class structure
: register-the-classEx    ( -- f ) WndClassEx  Call RegisterClassEx ;
: register-openGL-window  ( -- f ) default-window-classEx register-the-classEx ;

: create-frame-windowEx  ( -- hwnd )
        0 0                                     \ adjust x,y relative to 0,0
        StartSize:     [ self ]                 \ width, height
        SetRect: WinRect
        ExStyle                                 \ extended style
        WindowHasMenu: [ self ]                 \ have menu flag?
        WindowStyle:   [ self ]                 \ the window style
        AddrOf: WinRect                         \ make a new rectangle
        call AdjustWindowRectEx ?win-error      \ adjust the window
        ^base                                   \ creation parameters lpParam
        appInst                                 \ program instance *hInstance
        NULL LoadMenu: [ self ]                 \ menu hMenu
        ParentWindow:  [ self ]                 \ parent window handle ok hWndParent
        Bottom: WinRect  Top: WinRect -         \ adjusted height
         Right: WinRect Left: WinRect -         \ adjusted  width
        StartPos:      [ self ] swap            \ y, x starting position
        WindowStyle:   [ self ]                 \ the window style dwStyle
        WindowTitle:   [ self ]                 \ the window title lpWindowName
        WindowClassName 1+                      \ class name pClassName
        ExStyle
        Call CreateWindowEx
        EraseRect: WinRect
        0.00001e StartTimer: RefreshTimer       \ Prevent a deadlock
       ;

:M Start:      ( -- )
                hWnd 0=
                if      true to FirstTime
                        s" OpenGL" SetClassName: self
                        register-opengl-window drop
                        create-frame-windowEx to hWnd
                else    SetFocus: self
                then
                ;M

:M ClassInit:     ( -- )            ClassInit: super     ;M
:M StartSize:     ( -- w h )        630 470              ;M
:M StartPos:      ( -- x y )        CenterWindow: Self nip width 2/ swap  ;M
:M WindowTitle:   ( -- Zstring )    z" OpenGl in Win32Forth"  ;M
:M WindowHasMenu: ( -- flag )       TRUE                 ;M
:M WindowStyle:   ( -- style )      WindowStyle          ;M
:M On_Init:       ( -- )            On_Init: super       ;M
:M WM_KEYDOWN     ( key l -- res )  drop key-event 0     ;M
:M MinSize:       ( -- width height )    200 100         ;M

:M WM_CREATE    ( hwnd msg -- res )
                2drop
                set-ogl-events
                GetHandle:   self to ogl-hwnd
\                Nomenu  SetMenuBar: self             \ Optional
\                ogl-hwnd call GetMenu to NOmenu-hmnu
                getDC: self to ghdc
                Openglmenu  SetMenuBar: self
                SW_SHOWNORMAL Show: self
                ogl-hwnd call UpdateWindow drop
                ogl-hwnd call GetMenu to menu-hmnu
                addr: self to oglwin-base
                ogl-hwnd SetParent: AskIntWindow
                oglwin-base s" None" 20  ['] drop ForAskedInteger \ Should not be needed
                close: AskIntWindow                     \ just to get the right position
                start-ogl-threads
                \ HALFTONE ghdc call SetStretchBltMode ?win-error
                 COLORONCOLOR ghdc call SetStretchBltMode ?win-error \ Faster when StretchBlt is used
                0 ;M

:M On_Size:     { size -- }
                 size SIZE_MINIMIZED <> SecondPaint and
                     if  static-scene
                              if    InitOpenGL painting
                              else  true to resizing?
                              then
                     else true to SecondPaint
                     then
                  ;M

:M On_Done:     ( - )  reset-all-events  glout  On_Done: super   bye  ;M

;Object


: start-opengl-window  ( -- )
   Start: OpenGLWindow
 ;

: end-opengl    ( -- )  Close: OpenGLWindow bye ;

: _start/end-fullscreen
   fl-fullscreen dup not to fl-fullscreen
     if     end-FullscreenOpenGLWindow
            50 ms  false to request-to-stop
           \ Restart-painting-by-Timer: OpenGLWindow
     else   start-FullscreenOpenGLWindow
     then
 ;


 ' _start/end-fullscreen is start/end-fullscreen
 ' noop  is painting ( scene)

: (FocusOpenGLWindow
   SetFocus: OpenGLWindow
 ;

defer FocusOpenGLWindow

' (FocusOpenGLWindow is FocusOpenGLWindow

\s
