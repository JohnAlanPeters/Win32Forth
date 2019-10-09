\ $Id: SudokuToolbar.f,v 1.3 2006/08/10 22:27:43 rodoakford Exp $
\ SudokuToolbar.f       Toolbar for Sudoku game
\                       September 2005  Rod Oakford

s" apps\Sudoku\res" "fpath+

Needs Toolbar.f
Needs SudokuMenu.f
cr .( Loading Sudoku Toolbar...)
\- ToolBarLayoutKey  Create ToolBarLayoutKey ," Software\Win32Forth\Sudoku\Options"


:ToolStrings SudokuTooltips

        ts," Make a new game"
        ts," Open game file"
        ts," Save game file"
        ts," Print game"
        ts," Select 1"
        ts," Select 2"
        ts," Select 3"
        ts," Select 4"
        ts," Select 5"
        ts," Select 6"
        ts," Select 7"
        ts," Select 8"
        ts," Select 9"
        ts," Select blank"
        ts," Undo last move"
        ts," Redo last move"
        ts," Make larger"
        ts," Make smaller"
        ts," Start/stop timer"
        ts," Text colour 1"
        ts," Text colour 2"
        ts," Text colour 3"
        ts," Text colour 4"
        ts," Options dialog"

;ToolStrings

:ToolBarTable SudokuTable
\ Bmp Ndx     ID             Initial Style    Initial State         Tooltip Ndx
\ The default state and style for all buttons are enabled and button style
\ You can modify as desired
                                                                    SeparatorButton,
  0        IDM_NEW           TBSTATE_ENABLED  TBSTYLE_BUTTON        0 ToolBarButton,
  1        IDM_OPEN          TBSTATE_ENABLED  TBSTYLE_BUTTON        1 ToolBarButton,
  2        IDM_SAVE          TBSTATE_ENABLED  TBSTYLE_BUTTON        2 ToolBarButton,
                                                                    SeparatorButton,
  3        IDM_PRINT         TBSTATE_ENABLED  TBSTYLE_BUTTON        3 ToolBarButton,
                                                                    SeparatorButton,
  4        IDM_SELECT_1      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    4 ToolBarButton,
  5        IDM_SELECT_2      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    5 ToolBarButton,
  6        IDM_SELECT_3      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    6 ToolBarButton,
  7        IDM_SELECT_4      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    7 ToolBarButton,
  8        IDM_SELECT_5      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    8 ToolBarButton,
  9        IDM_SELECT_6      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    9 ToolBarButton,
  10       IDM_SELECT_7      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    10 ToolBarButton,
  11       IDM_SELECT_8      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    11 ToolBarButton,
  12       IDM_SELECT_9      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    12 ToolBarButton,
  13       IDM_SELECT_BLANK  TBSTATE_ENABLED
                             TBSTATE_CHECKED or TBSTYLE_CHECKGROUP  13 ToolBarButton,
                                                                     SeparatorButton,
  14       IDM_BACKWARD      TBSTATE_ENABLED  TBSTYLE_BUTTON        14 ToolBarButton,
  15       IDM_FORWARD       TBSTATE_ENABLED  TBSTYLE_BUTTON        15 ToolBarButton,
                                                                     SeparatorButton,
  18       IDM_PAUSE       TBSTATE_ENABLED TBSTYLE_CHECK            18 ToolBarButton,
                                                                     SeparatorButton,
  19       IDM_COLOUR_1    TBSTATE_ENABLED
                           TBSTATE_CHECKED or TBSTYLE_CHECKGROUP    19 ToolBarButton,
  20       IDM_COLOUR_2    TBSTATE_ENABLED  TBSTYLE_CHECKGROUP      20 ToolBarButton,
  21       IDM_COLOUR_3    TBSTATE_ENABLED  TBSTYLE_CHECKGROUP      21 ToolBarButton,
  22       IDM_COLOUR_4    TBSTATE_ENABLED  TBSTYLE_CHECKGROUP      22 ToolBarButton,

ToolBarTableExtraButtons:

  16       IDM_PLUS        TBSTATE_ENABLED  TBSTYLE_BUTTON          16 ToolBarButton,
  17       IDM_MINUS       TBSTATE_ENABLED  TBSTYLE_BUTTON          17 ToolBarButton,
                                                                     SeparatorButton,
  23       IDM_OPTIONS     TBSTATE_ENABLED  TBSTYLE_BUTTON          23 ToolBarButton,

;ToolBarTable


0 value BitmapFileHeader
: BitmapInfo   BitmapFileHeader 14 + ;
: BitmapData   BitmapFileHeader dup 10 + @ + ;
: LoadBitmapFile ( a n -- )
        "path-file drop   \ added September 2005
        r/o open-file abort" Couldn't open the ToolBar bitmaps"  >r
        here dup to BitmapFileHeader        \ set the bmp address
        r@ file-size 2drop                  \ the bmp length
        dup allot                           \ allocate the space
        r@ read-file 2drop                  \ read the bmp file
        r> close-file drop                  \ close file
        ;

: MakeTransparent ( -- )   \ changes background color of bitmap to BTNFACE
        COLOR_BTNFACE Call GetSysColor   \ convert 0bgr to 0rgb
        dup 0xFF and 16 LShift  over 0xFF00 and +  swap 0xFF0000 and 16 RShift +
        BitmapInfo dup @ +               \ address of ColorTable
        BitmapData c@ 15 and             \ color index for first pixel
        4 *  +  ! 
        ;

s" Toolbar.bmp" LoadBitmapFile


:Object SudokuToolBar   <Super Win32Toolbar

int hBitmap

int pszValueNameDefault
:M SaveRestoreDefault: ( f -- )
        pszValueName swap
        pszValueNameDefault to pszValueName
        SaveRestore: self
        to pszValueName
        ;M

:M Start:   ( parent -- )
        SudokuTable         IsButtonTable: self
        SudokuTooltips      IsTooltips: self
        Start: super
    \ Create bitmap handle
        MakeTransparent       
        DIB_RGB_COLORS
        BitmapInfo
        BitmapData
        CBM_INIT
        BitmapInfo            \ info pointer
        GetDC: self dup>r
        call CreateDIBitmap to hBitmap
        r> ReleaseDC: self
        0 hBitmap 24 AddBitmaps: self drop
    \ Set-up registry key for customization data...
        ToolBarLayoutKey 1+            \ Registry sub-key
        z" ToolBarLayout"              \ value key name
        SetRegistryKey: self
        z" ToolBarLayoutDefault" to pszValueNameDefault
        True SaveRestoreDefault: self
        False SaveRestore: self
        ;M

:M WM_RBUTTONDOWN ( h m w l -- res )   \ right click for context menu sent to frame window
        swap rot GetHandle: Parent
        Call SendMessage drop 0
        ;M

:M WindowStyle:  ( -- style )
        WS_CHILD   \ not WS_VISIBLE - start hidden
        TBSTYLE_TOOLTIPS or
        TBSTYLE_TRANSPARENT or   \ less flicker for XP style
        CCS_ADJUSTABLE or
        WS_CLIPSIBLINGS or
        ;M

:M On_Done: ( -- ) 
        hbitmap
        if      hbitmap Call DeleteObject drop
                0 to hbitmap
        then    On_Done: super
        ;M

:M On_CustHelp: ( -- f )                        \ Request for customization help
        z" Reset: resets all buttons to their previous positions.\nButtons can also be rearranged or deleted by holding down the shift key while dragging."
        z" Customize Toolbar"
        MB_OK MessageBox: self drop
        true
        ;M

;Object


0 value ToolbarHeight

: ShowToolbar ( -- )   GetWindowRect: SudokuToolbar nip swap - nip to ToolbarHeight
        SW_SHOW show: SudokuToolbar  true check: hToolbar ;

: HideToolbar ( -- )   0 to ToolbarHeight
        SW_HIDE show: SudokuToolbar  false check: hToolbar ;

: CheckNumber ( n -- )   \ check nth number on toolbar, uncheck the rest
        IDM_SELECT_BLANK + true swap CheckButton: SudokuToolBar ;
