\ $Id: PictureViewer.f,v 1.10 2013/12/17 19:25:21 georgeahubert Exp $

\ PictureViewer.f       An MDI application using FreeImage.dll to view picture files
\                       Version 6.2  July 2006  Rod Oakford

anew -PictureViewer.f

cr .( Loading PictureViewer)

s" apps\PictureViewer"     "fpath+
s" apps\PictureViewer\res" "fpath+

Create Version$ ," Picture Viewer version 6.2"
200 to IDCounter   \ to keep Toolbar button IDs the same as v5.2.2
: Sysgen ;   \ define for turnkey


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Constants and values for this application
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Create CommandLine LMAXSTRING allot
True value SingleInstance
0 value hLib   \ for FreeImage.dll
0 value ScreenWidth
0 value ScreenHeight
0 value StopExit
False value FullScreen
0 value MainWindow
Rectangle FrameWindowRect
HALFTONE value StretchBltMode
-1 constant FIF_UNKNOWN
Create CurrentFile 256 allot
Create PreviousFile 256 allot
0 value ActiveChild
0 value FileCount
0 value Sizing
0 value Maximizing
0 value Restoring
0 value Tiling
0 value PictureRedrawn
0 value AdjustWhileSizing
0 value Loading
0 value WindowState
0 value PictureAdjustment
0 value FlatToolbar?
False value ContinueSlide
False value SlideShowRunning
True value Continue
800 value CurrentPictureWidth
600 value CurrentPictureHeight
True value PrintAspect
True value PrintCentre
False value PrintEnlarge
4000 value PrintWidth   \ in 1000th of inch
3000 value PrintHeight
0 value Time
0 value NumberRecentFiles
Create JPEG ( SaveFlag ) 0x200 ,   ( LoadFlag ) 0 , ( FIF_JPEG )  2 ,  ( .Ext ) z," .jpg"  0 c,
Create TIFF ( SaveFlag ) 0x4000 ,  ( LoadFlag ) 0 , ( FIF_TIFF ) 18 ,  ( .Ext ) z," .tif"  0 c,
Create BMP  ( SaveFlag ) 0 ,       ( LoadFlag ) 0 , ( FIF_BMP )   0 ,  ( .Ext ) z," .bmp"  0 c,
0 value LoadFlag
true value Preload
0 value PreloadedDIB
0 value hChildWindow
0 value FileType
0 value NewWindow
Create ToolBarLayoutKey 256 allot
0 value CXEDGE
0 value CYEDGE
0 value CXSIZEFRAME
0 value CYSIZEFRAME
0 value CYCAPTION
0 value CYMENU
: GetSystemMetrics ( -- )
        SM_CXEDGE       call GetSystemMetrics to CXEDGE
        SM_CYEDGE       call GetSystemMetrics to CYEDGE
        SM_CXSIZEFRAME  call GetSystemMetrics to CXSIZEFRAME
        SM_CYSIZEFRAME  call GetSystemMetrics to CYSIZEFRAME
        SM_CYCAPTION    call GetSystemMetrics to CYCAPTION
        SM_CYMENU       call GetSystemMetrics to CYMENU ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Files needed
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WinLibrary COMDLG32.DLL
WinLibrary COMCTL32.DLL
WinLibrary msvfw32.dll
Needs MDI
Needs RecentFiles
Needs PVMenu
Needs PVDialogs
Needs RegistrySupport
Needs PVStatusBar
Needs PVToolbar
Needs RotateBits
Needs PVPrinting
Needs AcceleratorTables


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Loading, Preloading and Unloading files
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WinLibrary FreeImage.dll
0 value CurrentDIB
0 value CurrentPicture
Create PreloadedFile 256 allot

: NextFileToLoad ( -- FileName$/0 if found )   Forwards IF  GNextFile  ELSE  GPrevFile  THEN
        dup FileFound: MainWindow  IF  drop 0  THEN ;

: LoadPicture ( File$ -- dib )   \ load File$, return dib
        count   \ cr ." LoadPicture "  2dup type
        asciiz  to CurrentPicture
        0 to CurrentDIB   \ default: no bitmap loaded
        LoadFlag CurrentPicture Call _FreeImage_GetFileType@8
        dup FIF_UNKNOWN =
        IF         \ on some filetype's FreeImage_GetFileType fails, so
                   \ try to get the filetype from the filename
            drop CurrentPicture Call _FreeImage_GetFIFFromFilename@4
        THEN
        dup to FileType
        dup FIF_UNKNOWN <>
        IF         \ open file
            0 CurrentPicture rot Call _FreeImage_Load@12 to CurrentDIB
        ELSE  drop
        THEN
        CurrentDIB
        ;

: UnloadPicture ( dib -- )   Call _FreeImage_Unload@4 drop ;

: PreloadPicture ( -- )   0 to PreloadedDIB  Preload
        IF
            NextFileToLoad ?dup   \ returns 0 if already open
            IF
                dup count PreloadedFile place
                LoadPicture to PreloadedDIB
            THEN
        THEN  UpdateFlags: ActiveChild ;

: DeletePreloaded ( -- )   \ unload preloaded picture
        PreloadedDIB ?dup IF  UnloadPicture  false to PreloadedDIB  THEN ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define the Accelerator Table
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AcceleratorTable PVAccelerators


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Registry sets and words to save/restore recent files and remove all keys
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

PROGREG-SET-BASE-PATH   \ to put registry entries under current version of Win32Forth (e.g. Win32Forth 6.11.09)
Create RegPath$ max-path allot
ProgReg count RegPath$ place  s" PictureViewer"  RegPath$ +place
RegPath$ count                                                   RegistrySet PictureViewer
RegPath$ count pad place s" \Window" pad +place pad count        RegistrySet WindowSettings
RegPath$ count pad place s" \Options" pad +place pad count       RegistrySet Options
RegPath$ count pad place s" \Recent Files" pad +place pad count  RegistrySet RecentFilesList

((   \ to put registry entries under Win32Forth
s" Win32Forth\PictureViewer"                RegistrySet PictureViewer
s" Win32Forth\PictureViewer\Window"         RegistrySet WindowSettings
s" Win32Forth\PictureViewer\Options"        RegistrySet Options
s" Win32Forth\PictureViewer\Recent Files"   RegistrySet RecentFilesList
))

s" Software\" ToolBarLayoutKey place Options ProgReg count ToolBarLayoutKey +place

: SaveRecentFiles ( -- )
        RecentFilesList  s" File1"
        10 1 DO
                2dup + 1- i 48 + swap c! 2dup
                i GetRecentFile: RecentFiles count
                2swap REG_SZ SetRegistryValue
        LOOP 2drop ;

: RestoreRecentFiles ( -- )
        RecentFilesList  s" File1"
        9 0 DO
                2dup + 1- 57 i - swap c!  2dup
                REG_SZ GetRegistryValue  over 1- c! 1-  Insert: RecentFiles
        LOOP 2drop ;

: RemoveRegKeys ( -- )
        WindowSettings SaveSettings DeleteKey
        Options SaveSettings DeleteKey
        SaveRecentFiles DeleteKey
        PictureViewer  s" " s" " REG_SZ SetRegistryValue  DeleteKey ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Opening files from the command line
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 0 2value Arg
0 0 2value Arg-pos
Variable Arg/   \ contains only the last option on the command line e.g. /B

: NextArg ( a1 n1 -- a2 n2 )               \ strip off spaces and quotes
        bl skip  dup>r  Ascii " skip  dup r> =
        IF
            2dup bl scan
        ELSE
            bl skip  Ascii " skip  2dup Ascii " scan
        THEN
        2dup 2to Arg-pos
        nip -  2dup 2to Arg  -trailing
        ;

: Arg-1 ( -- a1 n1 )   CommandLine lcount NextArg ;

: Arg-next ( -- a n )                      \ next argument skipping any options /B etc.
       BEGIN
           Arg-pos NextArg
           over c@  Ascii / =
       WHILE
           3 min Arg/ place
       REPEAT ;

: OpenCommandLine ( -- )                   \ open all files on the command line
        Arg-1  BEGIN  dup WHILE  pad place  0 to PreloadedDIB  pad IDM_OPEN_FILE DoCommand  Arg-next
        REPEAT  2drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define application window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Frame   <Super MDIFrameWindow

Record: BMIH
    int     biSize
    int     biWidth
    int     biHeight
    short   biPlanes
    short   biBitCount
    int     biCompression
    int     biSizeImage
    int     biXPelsPerMeter
    int     biYPelsPerMeter
    int     biClrUsed
    int     biClrImportant
;RecordSize: sizeof(BMIH)

:M Classinit: ( -- )
        ClassInit: super
        s" PictureViewer" SetClassName: self
        PVMenu to CurrentMenu
        self to MainWindow
        ;M

:M WindowMenuNo: ( -- n )   3 ;M   \ the Window menu where the child window titles will be placed

:M Start: ( -- )   \ create a new window object
        hWnd 0=
        IF
            register-frame-window drop
            create-frame-window to hWnd
            WindowState SIZE_MAXIMIZED = IF  SW_SHOWMAXIMIZED  ELSE  SW_SHOW  THEN
            Show: self   \ allow to start maximized when WindowState is SIZE_MAXIMIZED
            Update: self
        ELSE  SetFocus: self
        THEN
        ;M

:M ExWindowStyle: ( -- exstyle )
        WS_EX_ACCEPTFILES
        ;M

2 CallBack: FindFile ( hChild Filename$ -- f )
        >r to hChildWindow
        temp$  MAXCOUNTED over hChildWindow Call GetWindowText
        r> count "to-pathend" caps-compare  IF  0 to hChildWindow  THEN
        hChildWindow 0=   \ FALSE if found to stop enumeration of child windows
        ;

:M FileFound: ( Filename$ -- hChildWindow )   \ returns handle of child window or 0 if not found
        0 to hChildWindow
        &FindFile MDIClient: self call EnumChildWindows drop
        hChildWindow
        ;M

:M WM_DROPFILES { hndl message wParam lParam -- res }
        DeletePreloaded
        True to Continue
        SetForegroundWindow: self
        0 0 -1 wParam Call DragQueryFile
        0 ?DO
            MAXCOUNTED temp$ 1+  i wParam Call DragQueryFile temp$ c!
            temp$ IDM_OPEN_FILE DoCommand
            Continue 0= IF  leave  THEN
        LOOP
        wParam Call DragFinish
        PreloadPicture
        ;M

Record: COPYDATASTRUCT
    int dwData
    int cbData
    int lpData
;Record

:M WM_COPYDATA ( h m w l -- res )
        dup cell+ 2@ CommandLine lplace
        WindowState SIZE_MINIMIZED = IF  SW_RESTORE Show: self  THEN
        hWnd Call SetActiveWindow drop
        Arg-1 IF  OpenCommandLine  THEN  drop
        true ;M

:M CopyData: ( hWindow -- )   >r
        CommandLine lcount to cbData to lpData
        COPYDATASTRUCT hWnd WM_COPYDATA r> send-window
        ;M

:M MinSize: ( -- width height )   ( 280 ) 160 0  ;M

:M WindowTitle: ( -- z" )   z" Picture Viewer"  ;M

:M WM_NOTIFY ( hwnd msg wparam lparam -- res )   Handle_Notify: PVToolbar  ;M

:M DisableRedraw: ( -- )
        false SetRedraw: self   \ disable drawing in MDIClient window
        ;M

:M EnableRedraw: ( -- )
        true SetRedraw: self   \ enable drawing in MDIClient window and redraw
        RDW_FRAME RDW_INVALIDATE or 0 0 GetHandle: ActiveChild call RedrawWindow drop
        ;M

:M On_Size: ( h m w -- h m w )
        dup to WindowState   \ get new WindowState, don't save size of maximised or minimised window
        Redraw: PVStatusBar
        Autosize: PVToolbar
        PictureRedrawn not   \ if not done in WM_WINDOWPOSCHANGING
        IF
            0  ToolbarHeight  Width  Height ToolbarHeight - StatusBarHeight -
            Move: MDIClient
        THEN
        False to Maximizing
        False to Restoring ;M

:M WM_WINDOWPOSCHANGING ( h m w l -- res )
        Windowstate SIZE_MINIMIZED =  Maximizing or Restoring or
        GetActive: self  drop and  dup to PictureRedrawn
        IF
            dup 16 + @  CXSIZEFRAME 2* -  >r  dup 20 + @  CYSIZEFRAME 2* - CYCAPTION - CYMENU -  >r
            0  ToolbarHeight  2r> ToolbarHeight - StatusBarHeight -
            2dup CYEDGE 2 * - swap CXEDGE 2 * - swap SetSize: ActiveChild
            AdjustPicture: ActiveChild
            Move: MDIClient  PauseForMessages
        THEN ;M

:M DefaultIcon: ( -- hIcon )   \ set the icon for the frame window
        100 appinst Call LoadIcon
        ;M

:M WndClassStyle: ( -- style )   CS_DBLCLKS ;M   \ for newer versions of Win32Forth

:M On_Init: ( -- )
        On_Init: super
        COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hWnd Call SetClassLong drop
\        CS_DBLCLKS GCL_STYLE hWnd Call SetClassLong drop   \ needed for older versions of Win32Forth

        self start: PVToolbar
        ToolbarPopup SetPopupBar: self
        FlatToolbar? 0= to FlatToolbar? IDM_FLAT DoCommand
        CheckToolbarAndMenu
        ToolbarHeight IF  ShowToolbar  THEN
        self start: PVStatusBar
        StatusBarHeight IF  ShowStatusBar  THEN
        NumberRecentFiles SetNumber: RecentFiles
        RestoreRecentFiles

        -1 call _FreeImage_Initialise@4 drop   \ initialise FreeImage.dll
        sizeof(BMIH)  BMIH over erase  to biSize
        Get-dc   \ each child window will need a DC with a bitmap large enough to cover the screen
        HORZRES GetHandle: dc Call GetDeviceCaps dup to ScreenWidth to biWidth
        VERTRES GetHandle: dc Call GetDeviceCaps dup to ScreenHeight to biHeight
        BITSPIXEL	GetHandle: dc Call GetDeviceCaps to biBitCount
        PLANES GetHandle: dc Call GetDeviceCaps	to biPlanes
        Release-dc
        ;M

:M OnWmCommand:  ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        over GetID: ScaleCombo CBN_SELCHANGE word-join =     \ Command from ScaleCombo
        IF  GetSelectedString: ScaleCombo ScaleNumber IDM_SCALE DoCommand ( SetFocus: self ) THEN

        over LOWORD ( command ID ) dup IsCommand?
        IF  DoCommand                         \ intercept Toolbar and accelerator commands
        ELSE  drop  OnWmCommand: Super        \ intercept Menu commands
        THEN
        ;M

:M WM_CLOSE ( h m w l -- res )   \ close all child windows
        False to StopExit
        CloseAll: self
        NotCancelled  StopExit 0= and   \ if we don't cancel the close
        IF
            WM_CLOSE WM: super          \ then just terminate the program
        ELSE
            1                           \ else abort program termination
        THEN
        ;M

:M On_Done: ( -- )   \ save registry settings and tidy up
        WindowState SIZE_RESTORED = IF  WindowSettings SaveSettings  THEN
        SaveValues: ScaleCombo
        Options SaveSettings
        PictureViewer SaveSettings
        SaveRecentFiles
        Call _FreeImage_DeInitialise@0 drop   \ close FreeImage.dll
        hLib Call FreeLibrary drop
        PVAccelerators DisableAccelerators   \ free the accelerator table
        Close: PVToolbar
        MenuHandle: ToolbarPopup call DestroyMenu drop
        MenuHandle: ChildPopup call DestroyMenu drop
        Turnkeyed? IF  0 call PostQuitMessage drop  THEN
        On_Done: Super
        ;M

:M WM_APPCOMMAND ( h m w l -- res )   \ mouse X buttons for Win2K/XP
        dup hiword 3 and
        Case
            1 of  false 0 Next: self  endof   \ activate next child
            2 of  true  0 Next: self  endof   \ activate previous child
        EndCase
        true ;M

:M WM_SYSCOMMAND ( h m w l -- res )   \ determine whether Frame is being Maximized or Restored
        over 0xFFF0 and  dup SC_MAXIMIZE =
        GetActive: self  drop and
        IF  true to Maximizing  THEN
        SC_RESTORE = GetActive: self  drop and
        IF  true to Restoring  THEN
        DefFrameProc ;M

:M WM_EXITSIZEMOVE ( h m w l -- res )   \ resize picture only after window sizing finishes
        GetActive: self drop  Sizing and
        IF  AdjustPicture: ActiveChild  THEN
        False to Sizing
        0 ;M

:M WM_TIMER ( hwnd msg wparam lparam -- res )   PauseForMessages
        Loading IF  true to ContinueSlide  ELSE  IDM_NEXT_SLIDE DoCommand  THEN
        0 ;M

:M Next: ( f hWnd -- )   DeletePreloaded  WM_MDINEXT SendMDIMessageDrop ;M   \ redefined to DeletePreloaded also

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MDIChild   <Super MDIChildWindow

    int ChildWindowState
    int ChildMaximizing
    int ChildRestoring
    int ChildRedrawn
    256 bytes FileName
    64  bytes FileTitle
    int dib
    int hdd
    int PictureDC
    int PictureBitmap
    int PictureHeight
    int PictureWidth
    int lpBmi
    int lpvBits
    int BitsPerPixel
    int Palette
    int WidthInBytes
    int PictureX
    int PictureY
    int ScaledHeight
    int ScaledWidth
    int AskBeforeClosing

: ScaleX ( -- % )   ScaledWidth  100 *  PictureWidth  2/ +  PictureWidth  / ;
: ScaleY ( -- % )   ScaledHeight 100 *  PictureHeight 2/ +  PictureHeight / ;

:M Marked: ( -- f )   AskBeforeClosing ;M

:M ToggleMark: ( f -- )   AskBeforeClosing 0= to AskBeforeClosing ;M

:M WM_GETMINMAXINFO ( h m w l -- f )
        dup  9 cells+  15 swap +!   \ allow max height to be more than screen height
        DefMDIChildProc
        ;M

:M FileName: ( -- a )   filename ;M

:M UpdateFlags: ( Mflag Pflag -- )
        AskBeforeClosing PreloadedDIB  UpdateFlags ;M

:M UpdateStatusBar: ( -- )
        PictureWidth PictureHeight ScaleX dup SetNumber: ScaleCombo
        PictureAdjustment
        Case
            1  OF  s"  Centred in window"  ENDOF
            2  OF  s"  Centred and stretched to window"  ENDOF
            3  OF  s"  Stretched to fit in window"  ENDOF
            4  OF  WindowState SIZE_MAXIMIZED =  FullScreen or  Maximizing or  Restoring or
                   IF  s"  Window cannot be adjusted to correct aspect ratio"
                   ELSE  s"  Window has correct aspect ratio"
                   THEN  ENDOF
            s"  No adjustment"  rot ( default )
        EndCase
        UpdateStatusBar
        ;M

:M WindowTitle: ( -- z" )
        CurrentFile count "to-pathend" FileTitle place
        FileTitle +null  FileTitle 1+
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: super
        GetActive: Frame  0= or  IF  WS_MAXIMIZE or  THEN   \ start new child maximised unless
        ;M                                                  \ the active child is not maximised
((
 0 constant FIF_BMP                         \ icon-bmp.ico
 1 constant FIF_ICO
 2 constant FIF_JPEG                        \ icon-jpg.ico
 3 constant FIF_JNG
 4 constant FIF_KOALA
 5 constant FIF_LBM
 5 constant FIF_IFF \ same as FIF_LBM       \ icon-iff.ico
 6 constant FIF_MNG
 7 constant FIF_PBM
 8 constant FIF_PBMRAW
 9 constant FIF_PCD                         \ icon-pcd.ico
10 constant FIF_PCX                         \ icon-pcx.ico
11 constant FIF_PGM
12 constant FIF_PGMRAW
13 constant FIF_PNG                         \ icon-png.ico
14 constant FIF_PPM
15 constant FIF_PPMRAW
16 constant FIF_RAS
17 constant FIF_TARGA                       \ icon-tga.ico
18 constant FIF_TIFF                        \ icon-tif.ico
19 constant FIF_WBMP
20 constant FIF_PSD                         \ icon-psd.ico
))
:M DefaultIcon: ( -- hIcon )   \ set the icon for the child window
        FileType
        Case
            0  of  IDI_BMP   endof
            2  of  IDI_JPG   endof
            5  of  IDI_IFF   endof
            9  of  IDI_PCD   endof
            10 of  IDI_PCX   endof
            13 of  IDI_PNG   endof
            17 of  IDI_TGA   endof
            18 of  IDI_TIFF  endof
            20 of  IDI_PSD   endof
            ( default ) swap 101
        EndCase
        AppInst Call LoadIcon
        ;M

:M PictureParameters: ( -- )
        dib call _FreeImage_GetHeight@4      to PictureHeight
        dib call _FreeImage_GetWidth@4       to PictureWidth
        dib call _FreeImage_GetInfo@4        to lpBmi
        dib call _FreeImage_GetBits@4        to lpvBits
        dib call _FreeImage_GetBPP@4         to BitsPerPixel
        dib call _FreeImage_GetPalette@4     to Palette
        ;M

false value NoExtension
:M Save: ( -- )   \ save the picture as a jpeg, tiff or bmp
        FileNames 1+ zcount ".ext-only"  dup 2 < to NoExtension
        2dup s" .jpg" Caps-Compare
        IF  2dup s" .tif" Caps-Compare
            IF  s" .bmp" Caps-Compare
                IF  nFilterIndex @  ELSE  3  THEN
            ELSE  2drop 2  THEN
        ELSE  2drop 1  THEN
        Case
            1  of JPEG  EndOf
            2  of TIFF  EndOf
                  BMP ( default ) swap
        EndCase
        dup>r
        NoExtension
        IF
            dup 3 cells+   \ get extension for JPEG, TIFF or BMP
            FileNames 1+ zcount "minus-ext" +  5 move
        THEN
        FileNames 1+ zcount FileNames c! drop
        @  FileNames 1+   dib  r> 2 cells+ @  Call _FreeImage_Save@16  0=
        IF  FileNames SavePictureError  FileNames 1+  Call DeleteFile drop  THEN
        ;M

:M Draw: ( -- )   \ draw picture scaled
\        dib IF
            0 0 ScreenWidth ScreenHeight GRAY FillArea: PictureDC
            Call DrawDibOpen to hdd
            4  ( DDF_SAME_HDC )
            PictureHeight                    \ nSrcHeight
            PictureWidth                     \ nSrcWidth
            0                                \ y-coord of source upper-left corner
            0                                \ x-coord of source upper-left corner
            lpvBits                          \ *lpBits
            lpBmi                            \ *lpBitsInfo
            ScaledHeight                     \ destination height
            ScaledWidth                      \ destination width
            PictureY                         \ y-coord of destination upper-left corner
            PictureX                         \ x-coord of destination upper-left corner
            GetHandle: PictureDC             \ hdc
            hdd call DrawDibDraw drop
            hdd call DrawDibClose drop
\        THEN
        ;M

:M Print: ( w h x y -- )   2>r 2>r       \ print the picture
        SRCCOPY                          \ raster operation code
        DIB_RGB_COLORS	                 \ usage options
        lpBmi                            \ *lpBitsInfo
        lpvBits                          \ *lpBits
        PictureHeight                    \ nSrcHeight
        PictureWidth                     \ nSrcWidth
        0                                \ y-coord of source upper-left corner
        0                                \ x-coord of source upper-left corner
        r>                               \ ScaledHeight in pixels
        r>                               \ ScaledWidth in pixels
        r>                               \ OriginY
        r>                               \ OriginX
        GetHandle: ThePrinter            \ hdc
        Call StretchDIBits drop
        ;M

:M On_Paint: ( -- )   \ copy from memory DC for quicker repainting when uncovered
        SaveDC: dc
        SRCCOPY 0 0 GetHandle: PictureDC
        width height \ 10 +
        0 0  BitBlt: dc
        RestoreDC: dc
        ;M

:M CentreInWindow: ( -- )   \ Centre in window keeping size the same
        Width ScaledWidth -  2/  to PictureX
        Height ScaledHeight - 2/ to PictureY
        ;M

:M CentreAndStretch: ( -- )   \ Centre and stretch to fit window maintaining aspect ratio
        Height PictureWidth *  Width PictureHeight *  >
        IF
            width to ScaledWidth
            PictureHeight ScaledWidth *  PictureWidth  2/ +  PictureWidth  / to ScaledHeight
            0 to PictureX
            Height ScaledHeight - 2/ to PictureY
        ELSE
            Height to ScaledHeight
            PictureWidth ScaledHeight *  PictureHeight 2/ +  PictureHeight / to ScaledWidth
            0 to PictureY
            Width ScaledWidth -  2/  to PictureX
        THEN
        ;M

Rectangle WindowRect

: AdjustWindowRect ( l t r b h -- l t r b )
        >r  swap 2swap swap   \ save handle on return stack and reverse client-rectangle
        sp@            \ address of client-rectangle
        GWL_EXSTYLE r@ Call GetWindowLong  swap   \ extended style
        GWL_STYLE r@ Call GetWindowLong           \ window style
        dup WS_CHILD and IF  r>drop 0  ELSE  r> Call GetMenu  THEN  swap   \ menu-present flag
        rot Call AdjustWindowRectEx ?win-error
        swap 2swap swap ;   \ reverse client-rectangle back

:M SizeWindowToPicture: ( -- )   \ window sized so its client area is ScaledWidth by ScaledHeight
        ChildWindowState SIZE_MAXIMIZED =
        IF
        GetWindowRect: frame 2drop   \ origin X, origin Y
        0 0 ScaledWidth ScaledHeight
        MDIClient: frame AdjustWindowRect   \ adjust to get window rectangle of MDIClient
        GetHandle: frame AdjustWindowRect   \ adjust to get window rectangle of frame
        ( l t r b )  >r  rot - swap                   \ adjusted width
        r> swap - StatusBarHeight + ToolBarHeight +   \ adjusted height
        over 288 < IF  SM_CYMENU Call GetSystemMetrics +  THEN    \ adjust for 2 lines of menu
        Move: Frame
        THEN
        ChildWindowState SIZE_RESTORED =
        IF
            WindowRect  dup
            hWnd Call GetWindowRect drop
            MDIClient: Frame Call ScreenToClient drop
            WindowRect.Left WindowRect.Top   \ origin X, origin Y
            0 0 ScaledWidth ScaledHeight
            GetHandle: self AdjustWindowRect   \ adjust to get window rectangle of child
            ( l t r b )  >r  rot - swap r> swap -   \ adjusted width, height
            Move: self
        THEN
        PictureWidth PictureHeight ScaleX
        s"  Window has correct aspect ratio"
        UpdateStatusBar
        ;M

:M FitInWindow: ( -- )   \ Stretch to fill window allowing aspect ratio to change
        Height to ScaledHeight
        Width to ScaledWidth
        0 to PictureX  0 to PictureY
        ;M

:M FixedAspectRatio: ( -- )   \ Resize window to have aspect ratio of picture
        ScaledHeight ScaledWidth            \ save dimensions of picture
        Width to ScaledWidth
        Width PictureHeight PictureWidth */ to ScaledHeight
        SizeWindowToPicture: self
        to ScaledWidth to ScaledHeight      \ restore dimensions of picture
        ;M

:M GetMDIClientRect: ( -- w h )
        WindowRect   MDIClient: Frame  Call GetClientRect drop
        Right: WindowRect Bottom: WindowRect
        ;M

: Adjustment ( -- )
        PictureAdjustment
        Case
\            0  OF  0 to PictureX  0 to PictureY  ENDOF
            1  OF  CentreInWindow: self  ENDOF
            2  OF  CentreAndStretch: self  ENDOF
            3  OF  FitInWindow: self  ENDOF
            4  OF  WindowState SIZE_MAXIMIZED =  FullScreen or  Maximizing or  Restoring or
                   IF  CentreAndStretch: self
                   ELSE  FixedAspectRatio: self  FitInWindow: self
                   THEN  ENDOF
        EndCase
        ;

:M AdjustPicture: ( -- )
        Adjustment
        Draw: self
        Paint: self
        UpdateStatusBar: self
        ;M

:M FullScreen: ( -- )   true to maximizing
        FrameWindowRect  GetHandle: frame call GetWindowRect drop   \ save position and size
        0 0 ScreenWidth ScreenHeight        \ client rectangle required for full screen
        MDIClient: frame AdjustWindowRect   \ adjust to get window rectangle of MDIClient
        GetHandle: frame AdjustWindowRect   \ adjust to get window rectangle of frame
        ( l t r b )
        >r >r  ToolBarHeight -              \ adjusted origin X and origin Y
        over r> swap -                      \ adjusted width
        over r> swap - StatusBarHeight +    \ adjusted height
        Move: frame  \ move frame so that its MDIClient client area fills the screen
        ;M

:M RestoreFromFullScreen: ( -- )   true to restoring
        Left: FrameWindowRect Top: FrameWindowRect
        over Right: FrameWindowRect swap -  over Bottom: FrameWindowRect swap -
        move: frame   \ restore position and size of frame window
        ;M

int RotatedBits

:M RotatePlus90: ( -- )
        PictureWidth 4 mod  PictureHeight 4 mod  or  BitsPerPixel 24 <>  or
        IF     \ use FreeImage call, nearly 5 times slower
            1079410688 0 ( 90 s>f fs>ds ) dib call _FreeImage_RotateClassic@12 dup
            IF  dup to dib  call _FreeImage_GetBits@4 to lpvBits  True  THEN
        ELSE   \ use faster code in RotateBits.f for 24 BPP
            PictureHeight PictureWidth 3 * * malloc to RotatedBits   \ allocate memory
            lpvBits  RotatedBits   PictureHeight  PictureWidth
            RotatePlus90   \ assembler code in RotateBits.f
            RotatedBits release   \ release memory
            True
        THEN
        IF
            lpBmi  4 + @ lpBmi  8 + @ lpBmi  4 + !  lpBmi  8 + !
            PictureHeight PictureWidth to PictureHeight to PictureWidth
            ScaledHeight ScaledWidth to ScaledHeight to ScaledWidth
            Draw: self
            Paint: self
            AdjustPicture: self
        ELSE
            Filename RotatePlusError
        THEN ;M

:M RotateMinus90: ( -- )
        PictureWidth 4 mod  PictureHeight 4 mod  or  BitsPerPixel 24 <>  or
        IF     \ use FreeImage call, nearly 5 times slower
            -1068072960 0 ( -90 s>f fs>ds ) dib call _FreeImage_RotateClassic@12 dup
            IF  dup to dib  call _FreeImage_GetBits@4 to lpvBits  True  THEN
        ELSE   \ use faster code in RotateBits.f for 24 BPP
            PictureHeight PictureWidth 3 * * malloc to RotatedBits   \ allocate memory
            lpvBits  RotatedBits   PictureHeight  PictureWidth
            RotateMinus90   \ assembler code in RotateBits.f
            RotatedBits release   \ release memory
            True
        THEN
        IF
            lpBmi  4 + @ lpBmi  8 + @ lpBmi  4 + !  lpBmi  8 + !
            PictureHeight PictureWidth to PictureHeight to PictureWidth
            ScaledHeight ScaledWidth to ScaledHeight to ScaledWidth
            Draw: self
            Paint: self
            AdjustPicture: self
        ELSE
            Filename RotateMinusError
        THEN ;M

:M FlipHorizontal: ( -- )
        dib Call _FreeImage_FlipHorizontal@4 drop
        Draw: self
        Paint: self
        ;M

:M FlipVertical: ( -- )
        dib Call _FreeImage_FlipVertical@4 drop
        Draw: self
        Paint: self
        ;M

:M Rotate180: ( -- )
        dib Call _FreeImage_FlipHorizontal@4 drop
        dib Call _FreeImage_FlipVertical@4 drop
        Draw: self
        Paint: self
        ;M

:M ScrollPicture: ( x y -- )   FullScreen   \ only scroll when not full screen mode
        IF  2drop
        ELSE
            2dup  +to PictureY  +to PictureX
            Draw: self  Scroll: self  Update: self
        THEN ;M

:M ScrollUp: ( -- )      0 -1  ScrollPicture: self ;M
:M ScrollDown: ( -- )    0  1  ScrollPicture: self ;M
:M ScrollLeft: ( -- )   -1  0  ScrollPicture: self ;M
:M ScrollRight: ( -- )   1  0  ScrollPicture: self ;M

: InPicture ( -- f )   MouseX PictureX dup ScaledWidth + between
        MouseY PictureY dup ScaledHeight + between and ;
:M ChangeCursor: ( n i -- )   Call LoadCursor ?dup
        IF  dup GCL_HCURSOR GetHandle: self Call SetClassLong drop  Call SetCursor drop  THEN ;M
int Scrolling
int MX
int MY

: OnClick ( -- )   InPicture dup FullScreen not and to Scrolling
        IF  MouseX to MX  MouseY to MY  FullScreen IF  151  ELSE  149  THEN  appinst ChangeCursor: self
        THEN ;
: OnTrack ( -- )   Scrolling IF  MouseX MX -  MouseY MY - ScrollPicture: self  OnClick  THEN ;
: OnUnclick ( -- )   Scrolling
        IF  FullScreen IF  151 appinst  ELSE  IDC_ARROW 0 THEN   ChangeCursor: self  THEN ;

:M Plus: ( -- )   \ increase size by 33%
        ScaledHeight 133 100 */ to ScaledHeight
        ScaledWidth  133 100 */ to ScaledWidth
        PictureAdjustment IF  CentreInWindow: self  THEN
        Draw: self
        Paint: self
        PictureWidth PictureHeight ScaleX dup SetNumber: ScaleCombo
        s"  Zoomed in"  UpdateStatusBar
        ;M

:M Minus: ( -- )   \ decrease size by 33%
        ScaledHeight 100 133 */ to ScaledHeight
        ScaledWidth  100 133 */ to ScaledWidth
        PictureAdjustment IF  CentreInWindow: self  THEN
        Draw: self
        Paint: self
        PictureWidth PictureHeight ScaleX dup SetNumber: ScaleCombo
        s"  Zoomed out"  UpdateStatusBar
        ;M

:M Scale: ( % -- )   dup
        PictureHeight 100 */ to ScaledHeight
        PictureWidth  100 */ to ScaledWidth
        PictureAdjustment IF  CentreInWindow: self  THEN
        Draw: self
        Paint: self
        PictureWidth PictureHeight ScaleX dup SetNumber: ScaleCombo
        s"  Scale changed "  UpdateStatusBar
        ;M

:M Replace: ( dib Filename$ -- )
        count "to-pathend" SetText: self
        dib UnloadPicture
        to dib
        PictureParameters: self
        GetNumber: ScaleCombo dup
        PictureHeight 100 */ to ScaledHeight
        PictureWidth  100 */ to ScaledWidth
        AdjustPicture: self
        ;M

:M TimeToLoad: ( -- )
        PictureWidth PictureHeight ScaleX
        s"  Loaded in " pad place
        ms@ start-time -  0 <# # # # ascii . hold # #> pad +place
        s"  seconds" pad +place  pad count UpdateStatusBar
        ;M

:M Start: ( parent -- )
        Timer-reset
        PreLoadedDIB
        IF
            PreloadedDIB to dib  0 to PreloadedDIB
            PreloadedFile count CurrentFile place
        ELSE
            CurrentFile LoadPicture to dib
        THEN
            CurrentFile count Filename place
        dib
        IF
            1 +to FileCount
            false to AskBeforeClosing
            s" MDIChild" pad place  FileType (.) pad +place   \ need to register different window classes
            pad count SetClassName: self                      \ to get different icons for each file type

            New> WinDC to PictureDC
            0 Call CreateCompatibleDC PutHandle: PictureDC
            0 0 0  DIB_RGB_COLORS  Frame.BMIH  0
            Call CreateDIBSection  dup to PictureBitmap
            SelectObject: PictureDC  DeleteObject: PictureDC

            PictureParameters: self
            GetNumber: ScaleCombo dup
            PictureHeight 100 */ to ScaledHeight
            PictureWidth  100 */ to ScaledWidth
            Adjustment

            StretchBltMode GetHandle: PictureDC call SetStretchBltMode ?win-error
            Draw: self
            GetActive: Frame  0= or  IF  SIZE_MAXIMIZED  ELSE  SIZE_RESTORED  THEN  to ChildWindowState
            False to maximizing  false to restoring

            DisableRedraw: frame   \ disable drawing till child window is ready to be drawn
            Start: super
            0 GCL_HBRBACKGROUND hWnd Call SetClassLong drop   \ stop white flicker on draw:
            CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop   \ double click to toggle fullscreen
            EnableRedraw: frame   \ enable drawing so child window is drawn in one go

            True EnableButtons: PVToolbar
            ChildPopup SetPopupBar: self
            ['] OnClick SetClickFunc: self
            ['] OnTrack SetTrackFunc: self
            ['] OnUnClick SetUnClickFunc: self
        ELSE  drop  PreviousFile count CurrentFile place   Filename LoadPictureError  self dispose
        THEN ;M

:M On_Command:  ( hwnd msg wparam lparam -- hwnd msg wparam lparam f )
        OnWmCommand: Super   \ so child window will handle commands from context menu
        False ;M

:M On_SetFocus: ( -- )              \ A child window can be selected by clicking on it,
        self to ActiveChild         \ selecting it from the Window menu or using CTRL+F6
        AdjustPicture: self
        ;M

:M WM_RBUTTONDOWN                   \ activate child on right click and bring up context menu
        hWnd Activate: frame
        WM_RBUTTONDOWN WM: super
        ;M

:M WM_CHILDACTIVATE ( h m w l -- f )   \ update statusbar when child is activated
        Filename count CurrentFile place
        self to ActiveChild
        PictureWidth to CurrentPictureWidth  PictureHeight to CurrentPictureHeight
        UpdateStatusBar: self
        UpdateFlags: self
        DefMDIChildProc ;M

:M On_Size: ( h m w l -- h m w l )   \ height . width .
        over to ChildWindowState
        True to Sizing
        AdjustWhileSizing ChildMaximizing or ChildRestoring or Tiling or
        ChildRedrawn not and
        IF  AdjustPicture: self  False to Sizing  THEN
        False to ChildMaximizing
        False to ChildRestoring
        ;M

:M WM_WINDOWPOSCHANGING ( h m w l -- res )
        ChildWindowState SIZE_MINIMIZED =  ChildMaximizing or ChildRestoring or Tiling or
        dup to ChildRedrawn
        IF
            dup 16 + @  CXSIZEFRAME 2* -  over 20 + @  CYCAPTION - CYSIZEFRAME 2* -
            SetSize: self
            AdjustPicture: self
        THEN
        0 ;M

: CloseWindow ( -- )
        -1 +to FileCount
        FileName Insert: RecentFiles   \ save filename in recent files list
        GetHandle: self Destroy: Frame   \ close child window now so we can safely dispose of it
        dib UnloadPicture  0 to dib   \ unload current picture
        DeletePreloaded   \ unload preloaded picture
        GetHandle: PictureDC Call DeleteDC ?win-error
        PictureBitmap DeleteObject: PictureDC
        PictureDC dispose
        FileCount 0= IF  0 to ActiveChild  Clear: PVStatusBar  false EnableButtons: PVToolbar  THEN
        self dispose
        ;

:M On_Close: ( -- f )   \ True = close, False = cancel close
        AskBeforeClosing
        IF
            CloseMessage
            Case
                IDCANCEL  Of        false FALSE  to NotCancelled  Endof
                IDYES     Of         true  TRUE  to NotCancelled  Endof
                ( otherwise IDNO )  false  TRUE  to NotCancelled  True to StopExit  swap
            EndCase
        ELSE  true  TRUE  to NotCancelled
        THEN
        IF  CloseWindow  THEN
        false ;M   \ child window closed earlier

:M On_SysCommand: ( h m w l -- f )   \ determine whether Child is being Maximized or Restored
        over 0xFFF0 and
        dup SC_MAXIMIZE = IF  true to ChildMaximizing  THEN
        SC_RESTORE = IF  true to ChildRestoring  THEN
        False ;M

:M WM_EXITSIZEMOVE ( h m w l -- res )   \ resize picture only after window sizing finishes
        GetActive: Frame drop 0=  Sizing and  AdjustWhileSizing not and
        IF  AdjustPicture: self  THEN
        False to Sizing
        0 ;M

:M WM_LBUTTONDBLCLK ( h m w l - res )
        IDM_FULL_SCREEN DoCommand
        0 ;M

;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Set Menu and Toolbar commands
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Close ( -- )   ActiveChild IF  GetHandle: ActiveChild CloseChild: Frame  THEN ;   IDM_CLOSE SetCommand

: AdjustPicture ( n -- )
        to PictureAdjustment
        CheckToolbarAndMenu
        ActiveChild IF  AdjustPicture: ActiveChild  THEN
        ;

: NoAdjustmentButton ( -- )   0 AdjustPicture ;                                 IDM_NO_ADJUST SetCommand

: CentreInWindowButton ( -- )   1 AdjustPicture ;                        IDM_CENTRE_IN_WINDOW SetCommand

: CentreAndStretchButton ( -- )   2 AdjustPicture ;                    IDM_CENTRE_AND_STRETCH SetCommand

: StretchToWindowButton ( -- )   3 AdjustPicture ;                      IDM_STRETCH_TO_WINDOW SetCommand

: FixedAspectRatioButton ( -- )   4 AdjustPicture ;                    IDM_FIXED_ASPECT_RATIO SetCommand

: ExitApp ( -- )   Close: frame ;                                                    IDM_EXIT SetCommand

: Tile ( -- )   True to tiling  0 Tile: Frame  False to Tiling ;                     IDM_TILE SetCommand

: Arrange ( -- )   Arrange: Frame ;                                               IDM_ARRANGE SetCommand

: Cascade ( -- )   True to tiling  Cascade: Frame ( 500 ms ) False to Tiling ;              IDM_CASCADE SetCommand

: CloseAll ( -- )   CloseAll: Frame ;                                           IDM_CLOSE_ALL SetCommand

: OpenFile ( File$ -- )   dup count file-status nip 0=
        IF
            True to loading
            SlideShowRunning 0= to ContinueSlide
            CurrentFile count PreviousFile place   \ save PreviousFile in case of LoadPictureError
            count CurrentFile place  CurrentFile FileFound: Frame
            IF
                hChildWindow Activate: frame
            ELSE
                Timer-reset
                ActiveChild 0=  NewWindow or  ActiveChild IF  Marked: ActiveChild or  THEN
                IF
                    New> MDIChild to ActiveChild
                    MDIClientWindow: Frame Start: ActiveChild
                ELSE
                    FileName: ActiveChild Insert: RecentFiles
                    PreLoadedDIB
                    IF  PreloadedDIB PreloadedFile  0 to PreloadedDIB  PreloadedFile count CurrentFile place
                    ELSE  CurrentFile LoadPicture CurrentFile
                    THEN  Replace: ActiveChild  UpdateFlags: ActiveChild  CurrentFile count Filename: ActiveChild place
                THEN
                TimeToLoad: ActiveChild
            THEN
            BEGIN PauseForMessages ContinueSlide UNTIL
            False to loading
        ELSE LoadPictureError
        THEN ;          IDM_OPEN_FILE SetCommand

: OpenRecentFile ( File$ -- )   DeletePreloaded  OpenFile  PreloadPicture ;   IDM_OPEN_RECENT_FILE SetCommand

: Open ( -- )   GetHandle: Frame OpenDialog
        IF
            DeletePreloaded  AllPictureFiles?
            IF  OpenDirectory CurrentFile count Filenames place filenames +null
            ELSE  OpenFiles
            THEN  PreloadPicture
        THEN ;                                                                    IDM_OPEN SetCommand

: OpenDir ( -- )
        s" All Picture Files" Filenames place Filenames +null  Open ;   IDM_OPEN_DIRECTORY SetCommand

: SaveAs ( -- )   ActiveChild 0= ?exit
        GetHandle: Frame SaveDialog
        IF  Save: ActiveChild  SaveDirectory
        THEN ;                               IDM_SAVE_AS SetCommand

: About ( -- )   Frame start: AboutBox drop ;                                       IDM_ABOUT SetCommand

: Uninstall ( -- )   UninstallMessage  IDYES = IF  RemoveRegKeys  bye  THEN ;   IDM_UNINSTALL SetCommand

: Restore ( -- )   Options RestoreSettings  CheckToolbarAndMenu ;                 IDM_RESTORE SetCommand

warning @ warning off

: Save ( -- )   Options SaveSettings ;                                               IDM_SAVE SetCommand

warning !

: Default ( -- )   Options DefaultSettings  RestoreValues: ScaleCombo
                100 SetNumber: ScaleCombo  CheckToolbarAndMenu ;                  IDM_DEFAULT SetCommand

: Rotate90 ( -- )   ActiveChild IF  RotatePlus90: ActiveChild  THEN ;           IDM_ROTATE_90 SetCommand

: Rotate-90 ( -- )   ActiveChild IF  RotateMinus90: ActiveChild  THEN ;        IDM_ROTATE_-90 SetCommand

: Rotate180 ( -- )   ActiveChild IF  Rotate180: ActiveChild  THEN ;            IDM_ROTATE_180 SetCommand

: FlipH ( -- )   ActiveChild IF  FlipHorizontal: ActiveChild  THEN ;      IDM_FLIP_HORIZONTAL SetCommand

: FlipV ( -- )   ActiveChild IF  FlipVertical: ActiveChild  THEN ;          IDM_FLIP_VERTICAL SetCommand

: ZoomIn ( -- )   ActiveChild IF  Plus: ActiveChild  THEN ;                       IDM_ZOOM_IN SetCommand

: ZoomOut ( -- )   ActiveChild IF  Minus: ActiveChild  THEN ;                    IDM_ZOOM_OUT SetCommand

: Scale ( % -- )    ActiveChild IF  Scale: ActiveChild  ELSE  drop  THEN ;          IDM_SCALE SetCommand

: ScrollUp ( -- )   ActiveChild IF  ScrollUp: ActiveChild  THEN ;               IDM_SCROLL_UP SetCommand
: ScrollDown ( -- )   ActiveChild IF  ScrollDown: ActiveChild  THEN ;         IDM_SCROLL_DOWN SetCommand
: ScrollLeft ( -- )   ActiveChild IF  ScrollLeft: ActiveChild  THEN ;         IDM_SCROLL_LEFT SetCommand
: ScrollRight ( -- )   ActiveChild IF  ScrollRight: ActiveChild  THEN ;      IDM_SCROLL_RIGHT SetCommand

: OptionsDial ( -- )   Frame Start: OptionsDialog
        IF  NumberRecentFiles SetNumber: RecentFiles  THEN ;                      IDM_OPTIONS SetCommand

: ToggleNewWindow ( -- )
        NewWindow 0= dup  to NewWindow  check: hNewWindow ;             IDM_TOGGLE_NEW_WINDOW SetCommand

: ToggleToolbar ( -- )
        ToolbarHeight IF  HideToolbar  ELSE  ShowToolbar  THEN
        On_Size: Frame
        ActiveChild IF  AdjustPicture: ActiveChild  THEN ;                 IDM_TOGGLE_TOOLBAR SetCommand

: ToggleStatusBar ( -- )
        StatusBarHeight IF  HideStatusBar  ELSE  ShowStatusBar  THEN
        On_Size: Frame
        ActiveChild IF  AdjustPicture: ActiveChild  THEN ;               IDM_TOGGLE_StatusBar SetCommand

: SaveToolbar   true SaveRestore: PVToolbar ;                                IDM_SAVE_TOOLBAR SetCommand

: RestoreToolbar   false SaveRestore: PVToolbar  MoveCombo: PVToolbar
        CheckPictureAdjustment: PVToolbar  ActiveChild EnableButtons: PVToolbar ;   IDM_RESTORE_TOOLBAR SetCommand

: DefaultToolbar   false SaveRestoreDefault: PVToolbar  MoveCombo: PVToolbar
        CheckPictureAdjustment: PVToolbar  ActiveChild EnableButtons: PVToolbar ;   IDM_DEFAULT_TOOLBAR SetCommand

: ToggleFlatToolbar ( -- )   FlatToolbar?
        IF
            false check: hFlat false to FlatToolbar?
            TBSTYLE_FLAT -Style: PVToolbar
        ELSE
            true check: hFlat true to FlatToolbar?
            TBSTYLE_FLAT +Style: PVToolbar
        THEN  paint: PVToolbar ;                                     IDM_FLAT SetCommand

: SlideShow ( -- )   SlideShowRunning invert dup to SlideShowRunning
        IF  0 time 1 GetHandle: frame Call SetTimer drop
            FileCount 1 = IF  OpenCurrentDirectory  THEN
        ELSE  1 GetHandle: frame Call KillTimer drop  false to continue  true to ContinueSlide PauseForMessages   \ kill OpenCurrentDirectory
        THEN ;                                                                 IDM_SLIDE_SHOW SetCommand

: NextSlide ( -- )   ActiveChild IF  true GetHandle: ActiveChild  Next: frame  THEN ;            IDM_NEXT_SLIDE SetCommand

: PreviousSlide ( -- )   ActiveChild IF  false GetHandle: ActiveChild  Next: frame  THEN ;   IDM_PREVIOUS_SLIDE SetCommand

: Escape ( -- )   ActiveChild 0= ?exit  False to continue
        FullScreen IF  False to FullScreen  RestoreFromFullScreen: ActiveChild  IDC_ARROW 0 ChangeCursor: ActiveChild  THEN
        ;                                                                      IDM_ESCAPE SetCommand

: ToggleFullScreen ( -- )   ActiveChild 0= ?exit  FullScreen
        IF
            False to FullScreen  RestoreFromFullScreen: ActiveChild  IDC_ARROW 0 ChangeCursor: ActiveChild
        ELSE
            True to FullScreen  FullScreen: ActiveChild  151 appinst ChangeCursor: ActiveChild
        THEN ;                                                                 IDM_FULL_SCREEN SetCommand

: KeyHelp ( -- )   Frame start: KeyHelpDialog  drop ;                                    IDM_HELP SetCommand

: OpenNext ( -- )   CurrentFile c@ 0= ?exit  PreloadedDIB Forwards and  True to Forwards
        IF  PreloadedFile                  \ open preloaded file if available
        ELSE  DeletePreloaded  GNextFile   \ delete preloaded file if direction changes
        THEN  IDM_OPEN_FILE DoCommand  PreloadPicture ;   IDM_OPEN_NEXT SetCommand

: OpenPrev ( -- )   CurrentFile c@ 0= ?exit  PreloadedDIB Forwards 0= and  False to Forwards
        IF  PreloadedFile                   \ open preloaded file if available
        ELSE  DeletePreloaded  GPrevFile    \ delete preloaded file if direction changes
        THEN  IDM_OPEN_FILE DoCommand  PreloadPicture ;   IDM_OPEN_PREV SetCommand

: ToggleMark ( -- )   ActiveChild 0= ?exit  ToggleMark: ActiveChild Updateflags: ActiveChild ;   IDM_TOGGLE_MARK SetCommand


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Registry settings
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WindowSettings entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
&Of: Frame.Width ( 4 )     514              REG_DWORD     RegEntry  "WindowWidth"
&Of: Frame.Height          434              REG_DWORD     RegEntry  "WindowHeight"
&Of: Frame.OriginX         135              REG_DWORD     RegEntry  "WindowLeft"
&Of: Frame.OriginY         66               REG_DWORD     RegEntry  "WindowTop"
EndEntries

Options entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
' ToolbarHeight 4 + ( 4 )  28               REG_DWORD     RegEntry  "ToolbarHeight"
' StatusBarHeight 4 +      22               REG_DWORD     RegEntry  "StatusBarHeight"
' FlatToolbar? 4 +         False            REG_DWORD     RegEntry  "Flat Toolbar"
' PictureAdjustment 4 +    2                REG_DWORD     RegEntry  "PictureAdjustment"
' NumberRecentFiles 4 +    9                REG_DWORD     RegEntry  "Files"
' Time 4 +                 2000             REG_DWORD     RegEntry  "Time"
' Preload 4 +              True             REG_DWORD     RegEntry  "Preload"
' NewWindow 4 +            True             REG_DWORD     RegEntry  "New window"
' SingleInstance 4 +       True             REG_DWORD     RegEntry  "SingleInstance"
ScaleComboValues 32        DefaultValues 32 REG_BINARY    RegEntry  "ScaleComboValues"
Directory 256              0 0              REG_SZ        RegEntry  "Current directory"
rtMargin                   100              REG_DWORD     RegEntry  "MarginLeft"
rtMargin 4 +               100              REG_DWORD     RegEntry  "MarginTop"
rtMargin 8 +               100              REG_DWORD     RegEntry  "MarginRight"
rtMargin 12 +              100              REG_DWORD     RegEntry  "MarginBottom"
rtMinMargin                100              REG_DWORD     RegEntry  "MinMarginLeft"
rtMinMargin 4 +            100              REG_DWORD     RegEntry  "MinMarginTop"
rtMinMargin 8 +            100              REG_DWORD     RegEntry  "MinMarginRight"
rtMinMargin 12 +           100              REG_DWORD     RegEntry  "MinMarginBottom"
' WindowState 4 +          SIZE_RESTORED    REG_DWORD     RegEntry  "Window State"
JPEG                       0x200            REG_DWORD     RegEntry  "Jpeg save flag"
TIFF                       0x4000           REG_DWORD     RegEntry  "Tiff save flag"
BMP                        0                REG_DWORD     RegEntry  "Bmp save flag"
EndEntries

PictureViewer entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
Version$         20        0 0              REG_SZ        RegEntry  "" ( default )
EndEntries


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Handle MDI Accelerators: ALT+ - (minus), CTRL+ F4, CTRL+ F6
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DoMDIMsg ( pMsg f  -- pMsg f )
        dup MDIClient: Frame 0<> and
        IF
            drop dup MDIClient: Frame Call TranslateMDISysAccel 0=
        THEN
        ;
msg-chain chain-add DoMDIMsg


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\	Accelerator Table Entries
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

PVAccelerators table
\   Flags               Key Code      Command ID
\ File Menu
    FCONTROL            'O'           IDM_OPEN                AccelEntry
    FCONTROL            'D'           IDM_OPEN_DIRECTORY      AccelEntry
    FCONTROL            'W'           IDM_CLOSE               AccelEntry
    FCONTROL FSHIFT or  'W'           IDM_CLOSE_ALL           AccelEntry
    FCONTROL FSHIFT or  'S'           IDM_SAVE_AS             AccelEntry
    FCONTROL            'P'           IDM_PRINT               AccelEntry
    FCONTROL FSHIFT or  'P'           IDM_PAGE_SETUP          AccelEntry

\ Options Menu
    FCONTROL            'N'           IDM_NO_ADJUST           AccelEntry
    FCONTROL            'C'           IDM_CENTRE_IN_WINDOW    AccelEntry
    FCONTROL            'S'           IDM_CENTRE_AND_STRETCH  AccelEntry
    FCONTROL            'F'           IDM_STRETCH_TO_WINDOW   AccelEntry
    FCONTROL            'R'           IDM_FIXED_ASPECT_RATIO  AccelEntry
    0                   'R'           IDM_ROTATE_-90          AccelEntry
    FSHIFT              'R'           IDM_ROTATE_90           AccelEntry

\ Toolbar
    0                   VK_ADD        IDM_ZOOM_IN             AccelEntry
    0                   VK_SUBTRACT   IDM_ZOOM_OUT            AccelEntry
    0                   32            IDM_OPEN_NEXT           AccelEntry
    0                   'N'           IDM_NEXT_SLIDE          AccelEntry
    0                   k_backspace   IDM_OPEN_PREV           AccelEntry
    0                   'B'           IDM_PREVIOUS_SLIDE      AccelEntry
    0                   'M'           IDM_TOGGLE_MARK         AccelEntry

\ Arrow Keys
    0                   VK_UP         IDM_SCROLL_UP           AccelEntry
    0                   VK_DOWN       IDM_SCROLL_DOWN         AccelEntry
    0                   VK_LEFT       IDM_SCROLL_LEFT         AccelEntry
    0                   VK_RIGHT      IDM_SCROLL_RIGHT        AccelEntry

\ Misc
   0                    VK_ESCAPE     IDM_ESCAPE              AccelEntry
   FALT                 VK_RETURN     IDM_FULL_SCREEN         AccelEntry
   0                    VK_F1         IDM_HELP                AccelEntry

Frame HandlesThem


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       The word to start the application
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Main ( -- )
        Options RestoreSettings
        cmdline CommandLine lplace
        Turnkeyed? SingleInstance and
        IF
            z" PictureViewer" find-window ?dup
            IF  dup Call SetForegroundWindow drop  CopyData: Frame  bye  THEN
        THEN
        GetSystemMetrics
        zeromenu: PVMenu
        z" FreeImage.dll"  Call LoadLibrary ?dup
        IF  to hLib  ELSE  FreeImageError  bye  THEN
        WindowSettings RestoreSettings
        Directory c@ 0= IF  &prognam count "path-only" Directory place Directory +null  THEN
        start: Frame
        False EnableButtons: PVToolbar
        DefaultPrinter
        11692 8267 ptPaperSize 2!   \ default A4 if no printer installed
        Paper-size or
        IF  Paper-size 1000 254 */ swap 1000 254 */ ptPaperSize 2!  THEN
        GetHandle: Frame hOwner !
        SetOutputMessage   \ Error messages from FreeImage
        Turnkeyed? IF  PVAccelerators EnableAccelerators  OpenCommandLine THEN
        ;

[defined] sysgen [IF]
          &forthdir count &appdir place   \ make turnkey in Win32Forth folder
          ' Main turnkey PictureViewer
          Needs PVResources
        Require Checksum.f
        s" PictureViewer.exe" prepend<home>\ (AddCheckSum)
          1 pause-seconds  bye
     [ELSE]  Main
     [THEN]

