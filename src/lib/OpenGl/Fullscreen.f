anew fullscreen.f  \ September 3rd, 2001 - 14:23

\ I could not get the right definition for the following structure.

struct{ \  devmode
    DWORD dmDeviceName
    WORD  dmSpecVersion
    WORD  dmDriverVersion
    WORD  dmSize
    WORD  dmDriverExtra
    DWORD dmFields
    WORD  dmOrientation
    WORD  dmPaperSize
    WORD  dmPaperLength
    WORD  dmPaperWidth
    WORD  dmScale
    WORD  dmCopies
    WORD  dmDefaultSource
    WORD  dmPrintQuality
    WORD  dmColor
    WORD  dmDuplex
    WORD  dmYResolution       \    148
    WORD  dmTTOption
    WORD  dmCollate           \    32
    DWORD dmFormName          \    28
    WORD  dmUnusedPadding
    DWORD dmBitsPerPel
    DWORD dmPelsWidth         \    1024   \ W98 max width of screen
    DWORD dmPelsHeight        \     768   \ W98 max height of screen
    DWORD dmDisplayFlags
    DWORD dmDisplayFrequency
    DWORD dmICMMethod
    DWORD dmICMIntent
    DWORD dmMediaType
    DWORD dmDitherType
    DWORD dmReserved1
    DWORD dmReserved2
    DWORD dmReserved3
    DWORD dmReserved4
    DWORD dmReserved5
    DWORD dmBpps                  \ new Bpps
    DWORD dmPanningWidth          \ new width
    DWORD dmPanningHeight         \ new height
    24 add-struct unknown
}struct devmode

sizeof devmode mkstruct: dvmd

: max-width-screen  ( - #pixels )   HORZRES ghdc call GetDeviceCaps  ;
: max-heigth-screen ( - #pixels )   VERTRES ghdc call GetDeviceCaps  ;

: fullscreen?  ( dvmd - flag )
  dup>r  dmPanningWidth  @ max-width-screen =
     r@  dmPanningHeight @ max-heigth-screen = and
     r>  dmBpps          @ ghdc max-bits-per-pixel  = and
 ;

: init-devmode-screen ( - dvmd )
    dvmd sizeof devmode  erase 1000 0
       do  dvmd i 0  call EnumDisplaySettings dup 0=
               if    leave
               else  dvmd fullscreen?
                        if    leave
                        else  drop
                        then
               then
       loop
 ;

: window-mode  ( - )
  0 0 call ChangeDisplaySettings DISP_CHANGE_SUCCESSFUL
  <> abort" Window mode failed"
 ;

: fullscreen-mode ( - ) \ using the current settings
   init-devmode-screen 0=
     if  no-painting window-mode
         true call ShowCursor drop
         true abort" Unsupported graphics mode."
     then
   DM_PELSWIDTH DM_PELSHEIGHT or DM_BITSPERPEL or dvmd dmFields !
   CDS_FULLSCREEN  dvmd call ChangeDisplaySettings
   DISP_CHANGE_SUCCESSFUL <>
     if  no-painting window-mode
         true call ShowCursor drop
         true abort" Fullscreen mode failed"
     then
  ;

:Object FullscreenOpenGLWindow    <Super Window

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
        int old_dc
        int old_hwnd
;Record

: default-window-classEx ( -- )   \ fill in the defaults for the window class
        12 cells                                                to cbSizeEx
        CS_HREDRAW  CS_VREDRAW or CS_OWNDC or                   to StyleEx
        TheWndProc                                      to wndProcEx
        0                                                       to clsExtraEx
        0                                                       to wndExtraEx
        appInst                                                 to hInstanceEx
        101 appinst                  Call LoadIcon              to hIconEx
        DefaultCursor: [ self ]      NULL Call LoadCursor       to hCursorEx
        0                                                       to hbrBackgroundEx
        NULL                                                    to MenuNameEx
        WindowClassName 1+                              to ClassNameEx
        0                                                       to hIconSmEx
        ;

: register-the-classEx    ( -- f )        \ register the class structure
       WndClassEx  Call RegisterClassEx   ;

: register-openGL-window  ( -- f )
       default-window-classEx register-the-classEx ;

: create-frame-windowEx  ( -- hwnd )
        0 0                                     \ adjust x,y relative to 0,0
        StartSize:     [ self ]                 \ width, height
        SetRect: WinRect
        ^base                                   \ creation parameters lpParam
        appInst                                 \ program instance *hInstance
        NULL LoadMenu: [ self ]                 \ menu hMenu
        ParentWindow:  [ self ]                 \ parent window handle ok hWndParent
        Height: WinRect                         \ adjusted height
        Width: WinRect                          \ adjusted  width
        StartPos:      [ self ] swap            \ y, x starting position
        WindowStyle:   [ self ]                 \ the window style dwStyle
        WindowTitle:   [ self ]         \ the window title lpWindowName
        WindowClassName 1+              \ class name pClassName
        WS_EX_APPWINDOW  WS_EX_TOPMOST or
        Call CreateWindowEx
        EraseRect: WinRect
       ;

:M ClassInit:    ( -- )   ClassInit: super    ;M

:M Start:        ( -- )
                 hWnd 0=
                 if     true to fl-fullscreen
                        ogl-hwnd to old_hwnd
                        ghdc     to old_dc
                        false call ShowCursor drop
                        fullscreen-mode
                        s" FullscreenOpenGLWindow" SetClassName: self
                        register-opengl-window drop
                        create-frame-windowEx  to hWnd
                 else   SetFocus: self
                 then
                 ;M

:M StartSize:     ( -- w h )
                  dvmd dmPanningWidth  @
                  dvmd dmPanningHeight @
                ;M

:M StartPos:      ( -- x y )    0 0       ;M

:M WindowStyle:   ( -- style )  WS_POPUP  ;M

:M WindowHasMenu: ( -- flag )   false     ;M

:M On_Paint:    ( - )     \ restore window when another window is moving over it
                SRCCOPY
                0 0                         \ y,x origin
                hdc-pixmap                  \ from a DIBSection
                Height                      \ source height
                Width                       \ source width
                0 0  ghdc                   \ to window
                call BitBlt drop            \ using a bit-block transfer
                ;M

:M On_Init:     ( -- )          \ things to do at the start of a window
                On_Init: super  \ do anything superclass needs
                ;M

:M WM_CREATE    ( hwnd msg -- res )
                2drop glout
                GetHandle: self to ogl-hwnd
                getDC: self to ghdc
                SW_SHOWNORMAL Show: self
                0 ;M

:M On_Size:     ( s -- )
                 SIZE_MINIMIZED <>
                      if    GetClientRect
                            to heightViewport to widthViewport
                     ( Height &InfoRect 3 cells+ ! Width &InfoRect
                           2 cells+ !) glout init-DIBsection painting
                      then
                  ;M

:M On_Done:  ( - )
              false to fl-fullscreen
              window-mode true call ShowCursor drop
              glout
              old_dc   to ghdc
              old_hwnd to ogl-hwnd
              On_Done: super
              &InfoRect ogl-hwnd
              GetClientRect
              to heightViewport to widthViewport
              init-DIBsection painting  \ in the previous window
              ;M

:M WM_KEYDOWN    ( key l -- res )
                 drop key-event
                 0
                 ;M

;Object

: start-FullscreenOpenGLWindow  ( -- )  Start: FullscreenOpenGLWindow ;
: end-FullscreenOpenGLWindow    ( -- )  Close: FullscreenOpenGLWindow ;

\s

