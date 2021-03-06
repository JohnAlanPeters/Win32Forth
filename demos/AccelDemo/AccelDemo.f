\ AccelDemo.f June 7th, 2003 - 14:01 dbu
\ based on WINDEMO.F  March 24th, 1999 - 21:37
\ changed for Win32Forth 6.07.07 September 6th, 2003 - 17:29 dbu
\ changed for Win32Forth 6.09.12 Samstag, September 11 2004 dbu

\
\ Search for "dbu" to see what's needed for Accelerator-Table-Support
\ in your own application.

only forth also definitions

require accel.f \ dbu

defer Init-Accelerator-Table ' noop is Init-Accelerator-Table \ dbu

1280 value screen-mwidth
1024 value screen-mheight
400 to screen-width
300 to screen-height


\ ---------------------------------------------------------------
\       Define the BIT-WINDOW global drawing functions
\ ---------------------------------------------------------------

Windc demo-dc

  2 value bit-originx
  2 value bit-originy
  0 value VGA-X                 \ VGA x coordinate in pixels
  0 value VGA-Y                 \ VGA y coordinate in pixels
  0 value LINE-VALUE
  0 value walking?
  0 value line-count
  0 value save-count
  0 value do-printing?

-1 value prev-x
-1 value prev-y

: moveto        ( x y -- )
                0max screen-height 4 - min swap 0max screen-width 4 - min swap
                bit-originy + swap bit-originx +  swap
                over prev-x = over prev-y = and
                IF      2drop
                ELSE    2dup to prev-y
                             to prev-x
                        2dup PrinterMoveTo: ThePrinter
                                    MoveTo: demo-dc
                THEN    ;

: lineto        ( x y -- )
                0max screen-height 4 - min swap 0max screen-width 4 - min swap
                bit-originy + swap bit-originx +  swap
                over prev-x = over prev-y = and
                IF      2drop
                ELSE    2dup to prev-y
                             to prev-x
                        2dup PrinterLineTo: ThePrinter
                                    LineTo: demo-dc
                then
                1 +to line-count ;

: line          ( x1 y1 x2 y2 -- )
                2swap moveto lineto ;

: line-color    ( color_object -- )
                ?ColorCheck
                dup to line-value
                dup
                case    black   of white        endof
                        white   of black        endof
                        yellow  of blue         endof
                                   dup
                endcase PrinterLineColor: ThePrinter
                               LineColor: demo-dc ;


\ ---------------------------------------------------------------
\       Define the BIT-WINDOW window class
\ ---------------------------------------------------------------

:Class bit-window  <super child-window

int vga-bitmap

:M On_Paint:    ( -- )
                SRCCOPY 0 0 GetHandle: demo-dc GetSize: self 0 0 BitBlt: dc
                ;M

:M WM_CREATE    ( hwnd msg wparam lparam -- res )
                get-dc
                0 call CreateCompatibleDC PutHandle: demo-dc
                screen-mwidth screen-mheight CreateCompatibleBitmap: dc
                to vga-bitmap
                vga-bitmap             SelectObject: demo-dc drop
                OEM_FIXED_FONT    SelectStockObject: demo-dc drop
                WHITE_PEN         SelectStockObject: demo-dc drop
                BLACK                    SetBkColor: demo-dc
                WHITE                  SetTextColor: demo-dc
                0 0 screen-mwidth screen-mheight BLACK FillArea: demo-dc
                release-dc
                0 ;M

:M On_Done:     ( -- )
                vga-bitmap call DeleteObject drop
                0 to vga-bitmap
                On_Done: super
                ;M

:M WM_MOUSEMOVE ( h m w l -- res )
                set-mousexy
                MK_LBUTTON and
                IF      track-func null-check execute
                then
                0 ;M

;Class


\ ---------------------------------------------------------------
\       Define the FILL-WINDOW window class
\ ---------------------------------------------------------------

Windc fill-dc

:Class fill-window  <super child-window

int fill-bitmap

:M On_Paint:    ( -- )
                On_Paint: super
                SRCCOPY 0 0 GetHandle: fill-dc GetSize: self 0 0 BitBlt: dc
                ;M

:M WM_CREATE
                get-dc
                0 call CreateCompatibleDC       PutHandle: fill-dc
                150 screen-mheight CreateCompatibleBitmap: dc to fill-bitmap
                fill-bitmap                  SelectObject: fill-dc drop
                0 0 150 screen-mheight    DKGRAY FillArea: fill-dc
                release-dc
                0 ;M

:M On_Done:     ( -- )
                fill-bitmap call DeleteObject drop
                0 to fill-bitmap
                On_Done: super
                ;M

;Class


\ ---------------------------------------------------------------
\ Menu and push button support
\ changed to use the Accelerator Table - dbu
\ ---------------------------------------------------------------

LRButtonBar Demo-LR-Buttons
ENDBAR

VButtonBar Demo-V-buttons
     AddButton  " Run Demo "            4728 Handle-Key-Table  ;
        ButtonInfo"  Run the Demo Program (ALT+R)"
     AddButton  " Run Walk "            4729 Handle-Key-Table  ;
        ButtonInfo"  Run the Line Walk Program (ALT+W)"
     AddButton  " Clear Window "        4730 Handle-Key-Table  ;
        ButtonInfo"  Clear the Demo Window (ALT+C)"
     AddButton  " Stop "                4731 Handle-Key-Table  ;
        ButtonInfo"  Stop Plotting (ALT+S)"
ENDBAR

100 SetButtonWidth: Demo-V-buttons      \ adjust the button width

ToolBar Demo-Tool-Bar "ACCELDEMO.BMP"
        03 HSpace
     1 PictureButton                    4711 Handle-Key-Table  ; \ open
        ButtonInfo"  Open "
     3 PictureButton                    4723 Handle-Key-Table  ;
        ButtonInfo"  Print Plot "
     3 PictureButton                    4724 Handle-Key-Table  ;
        ButtonInfo"  Print BitMap "
        8 HSpace
     6 PictureButton                    4722 Handle-Key-Table  ; \ cut
        ButtonInfo"  Cut Window "
     7 PictureButton                    4719 Handle-Key-Table  ; \ copy
        ButtonInfo"  Copy Window Normal "
     8 PictureButton                    4721 Handle-Key-Table  ; \ paste
        ButtonInfo"  Paste "
        8 HSpace
     9 PictureButton                    4728 Handle-Key-Table ; \ run
        ButtonInfo"  Run the Demo Program (ALT+R)"
    10 PictureButton                    4730 Handle-Key-Table ; \ clear
        ButtonInfo"  Clear the Demo Window (ALT+C)"
        8 HSpace
     5 PictureButton                    4727 Handle-Key-Table ;
        ButtonInfo"  About AcceleratorDemo "
        8 HSpace
ENDBAR

POPUPBAR Demo-Popup-bar

    POPUP " "
        MENUITEM        "Open File..."  4711 Handle-Key-Table  ;
        MENUSEPARATOR
        MENUITEM        "Print File..." 4723 Handle-Key-Table  ;
        MENUSEPARATOR
        MENUITEM        "Exit"          bye                     ;
ENDBAR

MENUBAR Demo-Menu-bar

    POPUP "&File"
        MENUITEM     "&Open File...  \tCtrl+O"             4711 Handle-Key-Table ;
         SUBMENU      "&Save Bitmap As"
           MENUITEM     "  1 Bits / 2 Colors\t1"           4712 Handle-Key-Table ;
           MENUITEM     "  4 Bits / 16 Colors\t2"          4713 Handle-Key-Table ;
           MENUITEM     "  8 Bits / 256 Colors\t3"         4714 Handle-Key-Table ;
           MENUITEM     " 16 Bits / 65536 Colors\tCtrl+S"  4715 Handle-Key-Table ;
           MENUITEM     " 24 Bits / 16 Million Colors\t5"  4716 Handle-Key-Table ;
           MENUITEM     " 32 Bits / 4 Billion Colors\t6"   4717 Handle-Key-Table ;
         ENDSUBMENU
        MENUSEPARATOR
        MENUITEM     "Page Setup...\tShift+Ctrl+P"     4725 Handle-Key-Table ;
        MENUITEM     "&Print Plot...\tCtrl+P"          4723 Handle-Key-Table ;
        MENUITEM     "&Print BMP...\tCtrl+Q"           4724 Handle-Key-Table ;
        MENUSEPARATOR
        MENUITEM     "E&xit\tAlt-F4"  bye ;

    POPUP "&Edit"
false   MENUMESSAGE     "Cut"
        SUBMENU         "&Copy"
             MENUITEM   "Plot Window &Normal\tCtrl+C"          4719 Handle-Key-Table ;
             MENUITEM   "Plot Window &Inverted\tShift+Ctrl+C"  4720 Handle-Key-Table ;
             ENDSUBMENU
        MENUITEM        "Paste\tCtrl+V"                        4721 Handle-Key-Table ;

    POPUP "&Display"
        MENUITEM        "Run Demo     \tALT+R" 4728 Handle-Key-Table  ;
        MENUITEM        "Run Line Walk\tALT+W" 4729 Handle-Key-Table  ;
        MENUITEM        "Erase Window \tALT+C" 4730 Handle-Key-Table  ;
        MENUITEM        "Stop Plotting\tALT+S" 4731 Handle-Key-Table  ;

    POPUP "&Help"
        MENUITEM        "About AcceleratorDemo\tF1"  4727 Handle-Key-Table ;
ENDBAR


\ ---------------------------------------------------------------
\       Define the DEMOW window class
\ ---------------------------------------------------------------
:Object DEMOW  <super window

 bit-window vga-bit-window
fill-window button-fill-window
  Rectangle DemoRect

 2 constant bitorigx
 2 constant bitorigy

:M Classinit:   ( -- )          \ static initialization goes here, IF needed
                ClassInit: super
                ;M

:M On_Init:     ( -- )          \ initialize the class
                On_Init: super                  \ first init super class
                1    SetId: button-fill-window  \ then the child window
                self Start: button-fill-window  \ then startup child window
                2    SetId: vga-bit-window      \ then the child window
                self Start: vga-bit-window      \ then startup child window
                3    SetId: Demo-V-Buttons      \ then the next child window
                self Start: Demo-V-Buttons      \ then startup child window
                4    SetId: Demo-Tool-Bar       \ then the next child window
                self Start: Demo-Tool-Bar       \ then startup child window
                5    SetId: Demo-LR-Buttons     \ then the next child window
                self Start: Demo-LR-Buttons     \ then startup child window
                Demo-menu-bar  SetMenuBar:  self
                Demo-popup-Bar SetPopupBar: vga-bit-window

                \ Init the Accelerator-Key-Table
                \ May 17th, 2003 - 19:58 dbu
                Init-Accelerator-Table

                ;M

:M On_Done:     ( h m w l -- res )

                \ destroy the Windows Accelerator Table
                \ May 17th, 2003 - 19:58 dbu
                Destroy-Accelerator-Table

                0 call PostQuitMessage drop
                On_Done: super
                0 ;M

:M WM_CLOSE     ( h m w l -- res )
                WM_CLOSE WM: Super
                bye
                0 ;M

:M Refresh:     ( -- )
                Paint: vga-bit-window
                ;M

:M StartSize:   ( -- width height )     \ starting window size
                bitorigx 2* screen-width +
                StartSize: Demo-V-Buttons drop 2 - +
                bitorigy 2* screen-height +
                StartSize: Demo-Tool-Bar nip + 1+
                ;M

:M MinSize:     ( -- width height )     \ minimum window size
                bitorigx 2* 100 + StartSize: Demo-V-Buttons drop 2 - +
                                  StartSize: Demo-Tool-Bar drop 1+ max
                bitorigy 2*       StartSize: Demo-V-Buttons nip  4 - +
                                  StartSize: Demo-Tool-Bar nip + 1+
                ;M

:M MaxSize:     ( -- width height )     \ maximum window size
                bitorigx 2* screen-mwidth +
                StartSize: Demo-V-Buttons drop 2 - +
                bitorigy 2* screen-mheight +
                ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" DEMO Window"
                ;M

:M On_Paint:    ( -- )
                LTGRAY_BRUSH Call GetStockObject
                0 0
                StartSize: self drop width max
                StartSize: Demo-Tool-Bar nip SetRect: DemoRect
                DemoRect GetHandle: dc call FillRect ?win-error
                EraseRect: DemoRect
                On_Paint: super
                WHITE                                LineColor: dc \ white color
                0 0                                     MoveTo: dc \ horiz
                StartSize: self drop width max 0        LineTo: dc \ line
                0 0                                     MoveTo: dc \ vertical
                StartSize: Demo-Tool-Bar nip 0 swap     LineTo: dc \ line
                StartSize: Demo-Tool-Bar swap 1+ swap   MoveTo: dc \ vertical
                StartSize: Demo-Tool-Bar drop 1+ 0      LineTo: dc \ line
                BLACK                                LineColor: dc
                0 StartSize: Demo-Tool-Bar nip dup>r    MoveTo: dc
                  StartSize: self drop width max r>     LineTo: dc

                  StartSize: Demo-Tool-Bar over 0       MoveTo: dc
                                                        LineTo: dc
                ;M

\ the l parameter has already been removed by WINDOW.F, and put
\ into Height and Width
:M On_Size:     ( h m w -- )                  \ handle resize message
                Width  StartSize: Demo-V-Buttons >r - 2 + r>
                Height StartSize: Demo-LR-Buttons bitorigy 2 - 0max +
                swap 4 - >r dup>r - over -
                r> 4 >          \ if there are buttons in the bar
                IF      2 -     \ then leave two more pixels of room
                                \ else we'll already have two pixels of room
                ELSE    r>drop StartSize: Demo-V-Buttons drop 4 - 0max >r
                THEN    r> swap
                        StartSize: Demo-Tool-Bar nip 1+ >r
                        2swap r@ + 2swap r> -
                        Move: button-fill-window

                bitorigx bitorigy StartSize: Demo-Tool-Bar nip + 1+
                Width  StartSize: Demo-V-Buttons drop - 2 -   dup to screen-width
                Height 4 - StartSize: Demo-Tool-Bar nip - 1- dup to screen-height
                Move: vga-bit-window
                  Width  StartSize: Demo-V-Buttons  drop - bitorigy 2 - 0max
                         StartSize: Demo-Tool-Bar   nip + 1+
                         StartSize: Demo-V-Buttons  Move: Demo-V-Buttons
                  Width  StartSize: Demo-LR-Buttons drop -
                  Height StartSize: Demo-LR-Buttons nip  - bitorigy 2 - 0max -
                         StartSize: Demo-LR-Buttons Move: Demo-LR-Buttons
                0 0      StartSize: Demo-Tool-Bar   Move: Demo-Tool-Bar
                ;M

:M SetVButtonBar: { buttonbar -- }
                buttonbar Demo-V-Buttons <>
                IF      Close: Demo-V-Buttons
                        buttonbar to Demo-V-Buttons
                        self  Start: Demo-V-Buttons
                        On_Size: self
                then
                ;M

:M SetLRButtonBar: { buttonbar -- }
                buttonbar Demo-LR-Buttons <>
                IF      Close: Demo-LR-Buttons
                        buttonbar to Demo-LR-Buttons
                        self  Start: Demo-LR-Buttons
                        On_Size: self
                then
                ;M

\ Mouse support connections from the applications window to the bitmapped
\ window that will actually receive the mouse clicks
:M SetClickFunc: ( cfa -- )
                SetClickFunc: vga-bit-window
                ;M

:M SetUnClickFunc: ( cfa -- )
                SetUnClickFunc: vga-bit-window
                ;M

:M SetDblClickFunc: ( cfa -- )
                SetDblClickFunc: vga-bit-window
                ;M

:M SetTrackFunc: ( cfa -- )
                SetTrackFunc: vga-bit-window
                ;M

\ All SC_xxxx command types always have the high nibble set to 0xF
:M WM_SYSCOMMAND ( hwnd msg wparam lparam -- res )
                over 0xF000 and 0xF000 <>
                IF      over LOWORD
                        DoMenu: CurrentMenu
                        0
                ELSE    DefWindowProc: [ self ]
                THEN    ;M

\ added for Windows Accelerator Table support
\ Samstag, September 11 2004 dbu
:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
                dup 0=
                if over hiword 1 = ACCEL-PTR @ and \ is accelerator key and table exists?
                  if
                    over LOWORD ACCEL-KEY drop \ handle the key
                  else
                    over LOWORD
                    CurrentMenu
                    if dup DoMenu: CurrentMenu then
                    CurrentPopup
                    if dup DoMenu: CurrentPopup then
                  then drop
                then    ;M

;Object

: uninit-demo   ( -- )
                DestroyWindow: DEMOW ;

unload-chain chain-add-before uninit-demo


\ ---------------------------------------------------------------
\ Demo about dialog, copied from the Forth About Dialog
\ ---------------------------------------------------------------

create about-demo-msg

         z," AcceleratorDemo, Public Domain, September 6th, 2003\n"
        +z," Version 1.1 - Written by Dirk Busch\n"
        +z," Mostly stolen from: WinDemo\n"
        +z," Written by Tom Zimmer"
        -null, here 0 c, align about-demo-msg - constant about-demo-len

:Object AboutWinDemo  <SUPER dialog

IDD_ABOUT_FORTH forthdlg find-dialog-id constant template

:M On_Init:     ( hWnd-focus -- f )
                about-demo-msg about-demo-len IDD_ABOUT_TEXT  SetDlgItemText: self
                1 ;M

:M Start:       ( -- f )
                Addr: DEMOW template run-dialog
                ;M

:M On_Command:  ( hCtrl code ID -- )
                case
                IDCANCEL of     end-dialog    endof
                                false swap ( default result )
                endcase ;M

;Object

: about-demo ( -- )
                start: AboutWinDemo ;


\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

: "demo-message ( a1 n1 -- )
                message-off
                dup
                IF      StartPos: DEMOW StartPos: msg-window
                        rot + >r + r> message-origin
                        MessageText: msg-window
                              Start: msg-window
                ELSE    2drop
                THEN    ;

: demo-message-off ( -- )
                message-off
                StartPos: DEMOW StartPos: msg-window
                rot - 0max >r swap - 0max r> message-origin ;


\ ---------------------------------------------------------------
\ clippboard support
\ ---------------------------------------------------------------

\ copy VGA-DC bitmap, f1=true=inverted
: copy-demo-bitmap   { flag \ hbm hdcMem -- }
                GetHandle: DEMOW call OpenClipboard 0=
        IF      s" Can't Open Clipboard\n\n...press a key to continue"
                "demo-message
                key drop demo-message-off
                EXIT
        THEN    flag
                SCREEN-HEIGHT
                SCREEN-WIDTH
                GetHandle: demo-dc
                call CreateCompatibleBitmap to hbm

                GetHandle: demo-dc
                call CreateCompatibleDC to hdcMem

                hbm hdcMem call SelectObject drop
                flag
                IF      NOTSRCCOPY
                ELSE    SRCCOPY
                THEN
                0 0                                     \ y,x origin
                GetHandle: demo-dc                      \ from the screen
                SCREEN-HEIGHT                           \ source height
                SCREEN-WIDTH                            \ source width
                0 0 hdcMem                              \ to new bitmap
                call BitBlt ?win-error                  \ invert the bitmap

                call EmptyClipboard ?win-error  \ clear out the clipboard
                hbm CF_BITMAP call SetClipboardData ?win-error
                call CloseClipboard ?win-error

                hdcMem call DeleteDC ?win-error
                ;

: paste-demo-bitmap   { flag \ hbm hdcMem -- }
                GetHandle: DEMOW call OpenClipboard 0=
        IF      s" Can't Open Clipboard\n\n...press a key to continue"
                "demo-message
                2000 ms demo-message-off
                EXIT
        then

                SCREEN-WIDTH
                SCREEN-HEIGHT
                CreateCompatibleBitMap: demo-dc to hbm

                GetHandle: demo-dc

                call CreateCompatibleDC to hdcMem

                CF_BITMAP call GetClipboardData dup to hbm ?win-error

                hbm hdcMem call SelectObject drop

                flag

                IF     NOTSRCCOPY
                ELSE   SRCCOPY
                THEN
                0 0                       \ y,x origin
                hdcMem                    \ from memory dc
                SCREEN-HEIGHT             \ source height
                SCREEN-WIDTH              \ source width
                0 0                       \ y,x dest
                GetHandle: demo-dc        \ to screen

                call BitBlt ?win-error          \ invert the bitmap

                call CloseClipboard ?win-error

                hdcMem call DeleteDC ?win-error
                ;


\ ---------------------------------------------------------------
\ Open image file support
\ ---------------------------------------------------------------

FileOpenDialog ViewBitmap "Open Bitmap File" "Bitmap Files (*.BMP)|*.BMP|*.DIB|All Files (*.*)|*.*|"
FileSaveDialog SaveBitmap "Save Bitmap File" "Bitmap Files (*.BMP)|*.BMP|*.DIB|All Files (*.*)|*.*|"

: open-demo-bitmap     { \ open$ hbm hdcMem --  }
                max-path LocalAlloc: open$
                GetHandle: DEMOW Start: ViewBitmap dup c@ \ -- a1 n1
                IF      count open$ place
                        LR_LOADFROMFILE
                        LR_CREATEDIBSECTION or
                        NULL
                        NULL
                        IMAGE_BITMAP
                        open$ dup +NULL 1+
                        NULL
                        Call LoadImage to hbm
                        GetHandle: demo-dc
                        Call CreateCompatibleDC to hdcMem
                        hbm hdcMem Call SelectObject  drop

                        SRCCOPY                                   \
                        0 0                                       \ y,x origin
                        hdcMem                                    \ from memory dc
                        SCREEN-HEIGHT                             \ height of dest rect
                        SCREEN-WIDTH                              \ width of dest rect
                        0 0                                       \ y,x dest
                        GetHandle: demo-dc                        \ to screen

                        Call BitBlt ?win-error                    \

                        hdcMem Call DeleteDC ?win-error

                        Refresh: DEMOW \ dbu
                ELSE    DROP
                THEN
                 ;


\ ---------------------------------------------------------------
\ Save File support
\ ---------------------------------------------------------------

        4 constant sizeof(RGBQUAD)
       14 constant sizeof(BitmapFileHeader)
       40 constant sizeof(BitmapInfoHeader)

        0 constant biSize
        4 constant biWidth
        8 constant biHeight
       12 constant biPlanes
       14 constant biBitCount
       16 constant biCompression
       20 constant biSizeImage
       24 constant biXPelsPerMeter
       28 constant biYPelsPerMeter
       32 constant biClrUsed
       36 constant biClrImportant

: show-BITMAPINFOHEADER { pbmih \ bmih$ -- }
        max-path localalloc: bmih$
        s" BITMAPINFOHEADER"                   bmih$  place
        s" \nbiSize : "                        bmih$ +place
       pbmih biSize + @           0 <# #s #>   bmih$ +place
        s" \nbiWidth : "                       bmih$ +place
       pbmih biWidth + @          0 <# #s #>   bmih$ +place
        s" \nbiHeight : "                      bmih$ +place
       pbmih biHeight + @         0 <# #s #>   bmih$ +place
        s" \nbiPlanes : "                      bmih$ +place
       pbmih biPlanes + w@        0 <# #s #>   bmih$ +place
        s" \nbiBitCount : "                    bmih$ +place
       pbmih biBitcount + w@      0 <# #s #>   bmih$ +place
        s" \nbiCompression : "                 bmih$ +place
       pbmih biCompression + @    0 <# #s #>   bmih$ +place
        s" \nbiSizeImage : "                   bmih$ +place
       pbmih biSizeImage + @      0 <# #s #>   bmih$ +place
        s" \nbiXPelsPerMeter : "               bmih$ +place
       pbmih biXPelsPerMeter + @  0 <# #s #>   bmih$ +place
        s" \nbiYPelsPerMeter : "               bmih$ +place
       pbmih biYPelsPerMeter + @  0 <# #s #>   bmih$ +place
        s" \nbiClrUsed : "                     bmih$ +place
       pbmih biClrUsed + @        0 <# #s #>   bmih$ +place
        s" \nbiClrImportant :"                 bmih$ +place
       pbmih biClrImportant + @   0 <# #s #>   bmih$ +place
       bmih$ count "message key drop message-off
        ;

: save-demo-bitmap { nBits \  pbmi lpBits hbm  hdcMem hfile nrgbquad BitmapFileHeader save$  -- }
        14 LocalAlloc: BitmapFileHeader
        max-path    LocalAlloc: save$
        s" Save Bitmap File: "  save$ place
        nBits (.)               save$ +place
        s"  Bit"                save$ +place
        save$ count SetTitle: SaveBitmap
        GetHandle: DEMOW Start: SaveBitmap dup c@

     IF count save$ place

        sizeof(BitmapInfoHeader)  sizeof(RGBQUAD) 256 * + malloc to pbmi
        pbmi sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + erase   \ (1) DON'T DELETE THIS LINE
                                                                      \

        sizeof(BitmapInfoHeader)                   pbmi biSize            +   !
        SCREEN-WIDTH                               pbmi biWidth           +   !
        SCREEN-HEIGHT                              pbmi biHeight          +   !
        1                                          pbmi biPlanes          +  w!
        nBits                                      pbmi biBitCount        +  w!

        nBits
         CASE
          1 OF BI_RGB    2 to nrgbquad    ENDOF
          4 OF BI_RLE4  16 to nrgbquad    ENDOF \ Could also be BI_RGB for
          8 OF BI_RLE8 256 to nrgbquad    ENDOF \ uncompressed format
         16 OF BI_RGB    0 to nrgbquad    ENDOF
         24 OF BI_RGB    0 to nrgbquad    ENDOF
         32 OF BI_RGB    0 to nrgbquad    ENDOF
         ENDCASE                                   pbmi biCompression     +   !

      \  0    pbmi biSizeImage       +   !       NOT NEEDED           (1)
      \  0    pbmi biXPelsPerMeter   +   !       SINCE
      \  0    pbmi biYPelsPerMeter   +   !       pbmi IS ERASED
      \  0    pbmi biClrUsed         +   !       ABOVE
      \  0    pbmi biClrImportant    +   !

        SCREEN-HEIGHT
        SCREEN-WIDTH
        GetHandle: demo-dc
        Call CreateCompatibleBitmap to hbm

        GetHandle: demo-dc
        Call CreateCompatibleDC to hdcMem
        hbm hdcMem Call SelectObject drop

        SRCCOPY                                   \
        0 0                                       \ y,x origin
        GetHandle: demo-dc                        \ from screen dc
        SCREEN-HEIGHT                             \ height of dest rect
        SCREEN-WIDTH                              \ width of dest rect
        0 0                                       \ y,x dest
        hdcMem                                    \ to memory dc
        Call BitBlt ?win-error                    \

        DIB_RGB_COLORS
        pbmi
        NULL
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 1st GetDIBits"

\        pbmi show-bitmapinfoheader

        pbmi biSizeImage + @ malloc to lpBits
        lpBits pbmi biSizeImage + @ erase

        DIB_RGB_COLORS
        pbmi
        lpBits
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 2nd GetDIBits"

\        pbmi show-bitmapinfoheader

        save$
        count
        GENERIC_READ GENERIC_WRITE or
        create-file abort" CreateFile"
        to hfile

        0x4d42 BitmapFileHeader     w!                        \ hdr.bfType

        sizeof(BitmapFileHeader)
        sizeof(BitmapInfoHeader) +
        nrgbquad sizeof(RGBQUAD) * +
        pbmi biSizeImage + @     +
               BitmapFileHeader 2 +  !                        \ hdr.bfSize

        0      BitmapFileHeader 6 + w!                        \ hdr.bfReserved1
        0      BitmapFileHeader 8 + w!                        \ hdr.bfReserved2

        sizeof(BitmapFileHeader)
        sizeof(BitmapInfoHeader) +
        nrgbquad sizeof(RGBQUAD) * +
               BitmapFileHeader 10 + !                        \ hdr.bfOffBits

        BitmapFileHeader
        sizeof(BitmapFileHeader)
        hfile write-file  drop

        pbmi
        sizeof(BitmapInfoHeader)
        nrgbquad sizeof(RGBQUAD) * +
        hfile write-file drop

        lpBits
        pbmi biSizeImage + @
        hfile write-file drop

        hfile close-file drop

        hdcMem call DeleteDC ?win-error
        hbm call DeleteObject ?win-error

        lpBits release
        pbmi release
     ELSE drop
     THEN
        ;


\ ---------------------------------------------------------------
\               Actual application section for DEMO
\ ---------------------------------------------------------------

0 value SEED1-SAVE
0 value SEED2-SAVE
0 value SEED3-SAVE

1 value dinc
0 value -hdots
0 value -vdots

ColorObject TheNextColor

: next-color    ( -- )
                BLACK line-color        \ make sure that TheNextColor object
                                        \ is not selected into the DC
                256 random 1+           \ before trying to create a new color
                256 random 1+
                256 random 1+ rgb
                NewColor: TheNextColor
                          TheNextColor line-color ;

: erase-demo    ( -- )
                0 0 screen-width screen-height WHITE PrinterFillArea: ThePrinter
                0 0 screen-width screen-height BLACK        FillArea: demo-dc
                Refresh: DEMOW
                seed1 to seed1-save     \ save this seed set in case we
                seed2 to seed2-save     \ want to print it
                seed3 to seed3-save
                0 to line-count ;

: run-demo      ( -- )
                FALSE TO walking?
                next-color
                screen-height 1- to -vdots
                screen-width  1- to -hdots
                BEGIN   -hdots random -vdots random -hdots random -vdots random
                        -vdots 0
                        DO      I + swap i - 2swap
                                I - swap i + 2swap
                                2over 2over line
                                15 random 2 <
                                IF      next-color
                                THEN
                                I 31 and 0=
                                IF      Refresh: DEMOW
                                        WINPAUSE
                                THEN
                        LOOP    2drop   2drop
                        key?
                        do-printing?
                        IF      line-count save-count >= OR
                        THEN
                UNTIL
                do-printing? 0=
                IF      line-count to save-count
                THEN    ;


\ ---------------------------------------------------------------
\               Actual application section for LINEWALK
\ ---------------------------------------------------------------

0 value x1 0 value y1 0 value x2 0 value y2

: bounce_xy1    ( x2 y2 x1 y1 -- x2 y2 x1 y1 )
                swap    dup -hdots >= IF -1 TO x1  0 TO x2 next-color THEN
                        dup 1 <       IF  1 TO x1  0 TO x2 next-color THEN
                swap    dup -vdots >= IF -1 TO y1  0 TO y2 next-color THEN
                        dup 1 <       IF  1 TO y1  0 TO y2 next-color THEN ;

: bounce_xy2    ( x1 y1 x2 y2 -- x1 y1 x2 y2 )
                swap    dup -hdots >= IF -1 TO x2  0 TO x1 next-color THEN
                        dup 1 <       IF  1 TO x2  0 TO x1 next-color THEN
                swap    dup -vdots >= IF -1 TO y2  0 TO y1 next-color THEN
                        dup 1 <       IF  1 TO y2  0 TO y1 next-color THEN ;

200 value line_max
400 value lines_max
0 value line_limit

: limit_xy      ( x2 y2 x1 y1 -- x2 y2 x1 y1 )
                2swap over >r 2swap over r> - dup abs line_limit >
                IF      dup 0<
                        IF      1 TO x1 -1 TO x2
                        ELSE    1 TO x2 -1 TO x1
                        THEN    y1 0= y2 0= or
                        IF 2 RANDOM 2 RANDOM - TO y1 then
                        next-color
                THEN    drop
                2swap dup>r   2swap dup  r> - dup abs line_limit >
                IF      dup 0<
                        IF      1 TO y1 -1 TO y2
                        ELSE    1 TO y2 -1 TO y1
                        THEN    x1 0= x2 0= or
                        IF 2 RANDOM 2 RANDOM - TO x1 then
                        next-color
                THEN    drop ;

0 value cnt-down
3 value cnt-down-max

: draw-a-line   ( x y x y -- )
                cnt-down 0=
                IF      line
                        cnt-down-max TO cnt-down
                ELSE    -1 +to cnt-down
                        2drop 2drop
                THEN    ;

: draw_1line    ( x y x y -- x y x y )
                line_max RANDOM 10 max TO line_limit
                2 RANDOM 2 RANDOM - TO x1 2 RANDOM 2 RANDOM - TO y1
                2 RANDOM 2 RANDOM - TO x2 2 RANDOM 2 RANDOM - TO y2
                lines_max RANDOM 1+ 0
                DO      4dup draw-a-line
                        limit_xy
                        swap x1 + swap y1 + bounce_xy1 2swap
                        swap x2 + swap y2 + bounce_xy2 2swap
                        i 1+ RANDOM 15 and 0=
                        IF      next-color
                        THEN
                        key? ?leave
                LOOP    next-color ;

: line-walk     ( -- )
                TRUE TO walking?
                next-color
                screen-height 1- to -vdots
                screen-width  1- to -hdots
                -hdots 2/ -vdots 2/ 2dup
                BEGIN   10 0
                        DO      draw_1line
                                Refresh: DEMOW
                                WINPAUSE
                        LOOP
                         500 RANDOM TO line_max
                        5000 RANDOM TO lines_max
                           3 RANDOM TO cnt-down-max
                        key?
                        do-printing?
                        IF      line-count save-count >= OR
                        THEN
                UNTIL   2drop
                do-printing? 0=
                IF      line-count to save-count
                THEN    ;


\ ---------------------------------------------------------------
\               Printing support
\ ---------------------------------------------------------------

: print-demo    ( -- )
                TRUE to do-printing?
                seed1-save to seed1     \ print same as displayed
                seed2-save to seed2
                seed3-save to seed3
                200 TO line_max
                400 TO lines_max
                0 TO line_limit
                0 TO cnt-down
                3 TO cnt-down-max
                single-page
                start-scaled
                IF      erase-demo
                        S" Printing DEMO..." "demo-message
                        walking?
                        IF      line-walk
                        ELSE    run-demo
                        THEN
                        print-scaled
                        demo-message-off
                THEN
                FALSE to do-printing? ;

: print-demo-bmp { nBits \  pbmi lpBits hbm  hdcMem    -- }
             Open: ThePrinter
        GetHandle: ThePrinter 0= ?EXIT
            Start: ThePrinter

             sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + malloc to pbmi
        pbmi sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + erase   \ (1) DON'T DELETE THIS LINE
                                                                      \

        sizeof(BitmapInfoHeader)                   pbmi biSize            + !
        SCREEN-WIDTH                               pbmi biWidth           + !
        SCREEN-HEIGHT                              pbmi biHeight          + !
        1                                          pbmi biPlanes          + w!
        nBits                                      pbmi biBitCount        + w!

        BI_RGB                                     pbmi biCompression     + !

      \  0    pbmi biSizeImage       +   !       NOT NEEDED           (1)
      \  0    pbmi biXPelsPerMeter   +   !       SINCE
      \  0    pbmi biYPelsPerMeter   +   !       pbmi IS ERASED
      \  0    pbmi biClrUsed         +   !       ABOVE
      \  0    pbmi biClrImportant    +   !

        SCREEN-HEIGHT
        SCREEN-WIDTH
        GetHandle: demo-dc
        Call CreateCompatibleBitmap to hbm

        GetHandle: demo-dc
        Call CreateCompatibleDC to hdcMem
        hbm hdcMem Call SelectObject drop

        SRCCOPY                                   \
        0 0                                       \ y,x origin
        GetHandle: demo-dc                        \ from screen dc
        SCREEN-HEIGHT                             \ height of dest rect
        SCREEN-WIDTH                              \ width of dest rect
        0 0                                       \ y,x dest
        hdcMem                                    \ to memory dc
        Call BitBlt ?win-error                    \

        DIB_RGB_COLORS
        pbmi
        NULL
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 1st GetDIBits"

       \ pbmi show-bitmapinfoheader

        pbmi biSizeImage + @ malloc to lpBits
        lpBits pbmi biSizeImage + @ erase

        DIB_RGB_COLORS
        pbmi
        lpBits
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 2nd GetDIBits"

      \  pbmi show-bitmapinfoheader

        SRCCOPY
        DIB_RGB_COLORS
        pbmi
        lpBits

        SCREEN-HEIGHT
        SCREEN-WIDTH
        0
        0
        Height: ThePrinter
        Width: ThePrinter
        0
        0
        GetHandle: ThePrinter
        Call StretchDIBits GDI_ERROR = ABORT" StretchDIBits"
          End: ThePrinter
        Close: ThePrinter
        hdcMem call DeleteDC ?win-error
        hbm call DeleteObject ?win-error

        lpBits release
        pbmi release
        ;

: setup-printer
        GetHandle: DEMOW Setup: ThePrinter ;


\ ---------------------------------------------------------------
\ Windows Accelerator Table - support
\ May 17th, 2003 - 19:59 dbu
\ ---------------------------------------------------------------

: save-bitmap-1          ( -- ) 1 save-demo-bitmap ;
: save-bitmap-4          ( -- ) 4 save-demo-bitmap ;
: save-bitmap-8          ( -- ) 8 save-demo-bitmap ;
: save-bitmap-16         ( -- ) 16 save-demo-bitmap ;
: save-bitmap-24         ( -- ) 24 save-demo-bitmap ;
: save-bitmap-32         ( -- ) 32 save-demo-bitmap ;

: handle-control-c       ( -- ) false copy-demo-bitmap ;
: handle-control-shift-c ( -- ) true copy-demo-bitmap ;
: handle-control-x       ( -- ) false copy-demo-bitmap k_esc pushkey ;

: handle-control-p       ( -- ) 16 print-demo ;
: handle-control-q       ( -- ) 16 print-demo-bmp ;
: handle-control-shift-p ( -- ) setup-printer ;

: stop-demo              ( -- ) k_esc +k_control pushkey ;

ACCELTABLE Accelerator-Key-Table \ create the Accelerator-Key-Table
        FCONTROL            'O'    4711  ' open-demo-bitmap        ACCELENTRY
        0                   '1'    4712  ' save-bitmap-1           ACCELENTRY
        0                   '2'    4713  ' save-bitmap-4           ACCELENTRY
        0                   '3'    4714  ' save-bitmap-8           ACCELENTRY
        0                   '4'    4715  ' save-bitmap-16          ACCELENTRY
        FCONTROL            'S'    4716  ' save-bitmap-16          ACCELENTRY
        0                   '5'    4717  ' save-bitmap-24          ACCELENTRY
        0                   '6'    4718  ' save-bitmap-32          ACCELENTRY

        FCONTROL            'C'    4719  ' handle-control-c        ACCELENTRY
        FCONTROL FSHIFT OR  'C'    4720  ' handle-control-shift-c  ACCELENTRY
        FCONTROL            'V'    4721  ' paste-demo-bitmap       ACCELENTRY
        FCONTROL            'X'    4722  ' handle-control-x        ACCELENTRY

        FCONTROL            'P'    4723  ' handle-control-p        ACCELENTRY
        FCONTROL            'Q'    4724  ' handle-control-q        ACCELENTRY
        FCONTROL FSHIFT OR  'P'    4725  ' handle-control-shift-p  ACCELENTRY

        0                   VK_F1  4727  ' about-demo              ACCELENTRY

        FALT                'R'    4728  ' run-demo                ACCELENTRY
        FALT                'W'    4729  ' line-walk               ACCELENTRY
        FALT                'C'    4730  ' erase-demo              ACCELENTRY
        FALT                'S'    4731  ' stop-demo               ACCELENTRY
ACCELEND \ mark the end of table

: (Init-Accelerator-Table) ( -- )
        \ create the table
        Accelerator-Key-Table Create-Accelerator-Table

        \ and our WM_COMMAND handler
        ACCEL-HNDL 0<> if ['] Handle-Key-Table is ACCEL-KEY then

;

' (Init-Accelerator-Table) is Init-Accelerator-Table

\ ---------------------------------------------------------------
\ Top Level program starts here
\ ---------------------------------------------------------------

: AccelDemo     ( -- )
                Start: DEMOW
                StartPos: DEMOW 50 + swap 50 + swap message-origin
                blue line-color
                RANDOM-INIT             \ initialize random number generator

                erase-demo
                begin   Refresh: DEMOW
                        key drop  \ handle keyboard interpretation
                                  \ this is needed because key contains the
                                  \ main window message loop !!!
                again
;

AccelDemo

\ Note : normally we should restore previous state by removing DoAccelMsg
\        from the msg-chain but this is not needed because the AccelDemo
\        directly exit Forth when closed


\ The keyboard is used, so it needs a hidden console in the program.

ConsoleHiddenBoot ' AccelDemo SAVE AccelDemo.exe

\s
