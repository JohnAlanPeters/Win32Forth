\ $Id: PVToolbar.f,v 1.2 2006/08/10 22:51:46 rodoakford Exp $

\ PVToolBar.f           Toolbar for Picture Viewer by Rod Oakford
\                       June 2006

s" apps\PictureViewer" "fpath+
s" apps\PictureViewer\res" "fpath+

Needs ToolBar
Needs PVMenu
s" ListBox.f" "path-file [IF] 2drop Needs ExControls [ELSE] "Fload [THEN]
\ Needs ListBox
Needs PV.h

cr .( Loading PVToolBar)

\- ActiveChild   0 value ActiveChild
\- PictureAdjustment  0 value PictureAdjustment
\- NewWindow  0 value NewWindow
\- ToolBarLayoutKey  Create ToolBarLayoutKey ," Software\Win32Forth\PictureViewer\Options"

Create ScaleComboValues
1 w, 2 w, 3 w, 4 w, 5 w, 10 w, 20 w, 30 w, 40 w, 50 w, 75 w, 100 w, 150 w, 200 w, 400 w, 800 w, 
Create DefaultValues
1 w, 2 w, 3 w, 4 w, 5 w, 10 w, 20 w, 30 w, 40 w, 50 w, 75 w, 100 w, 150 w, 200 w, 400 w, 800 w, 

Font ComboFont
-14 Height: ComboFont
s" MS Sans Serif" SetFaceName: ComboFont

: (U.R) ( n w -- a n )
\        pad 8 erase  pad 3 blank
        pad 8 blank
        >r (.) r@ swap - pad + r@ move pad r> ;

: ScaleNumber ( a n -- n )   bl skip  number? 2drop ;


:Object ScaleCombo   <Super ComboBox

:M GetDroppedState: ( -- flag )   0 0 CB_GETDROPPEDSTATE hwnd call SendMessage ;M

:M GetNumber: ( -- n )   GetText: self  ScaleNumber ;M

:M SetNumber: ( n -- )   3 (U.R) SetText: self ;M

:M RestoreValues: ( -- )
        Clear: self
        16 0 DO
            ScaleComboValues i 2* + w@ ?dup IF  3 (U.R) asciiz  AddStringTo: self  THEN
        LOOP ;M

:M SaveValues: ( -- )
        ScaleComboValues 32 erase
        GetCount: self 0 DO
            i GetStringAt: self  ScaleNumber  ScaleComboValues i 2* + w!
        LOOP ;M

: WmKeyDown ( h m w l obj -- res )   \ to insert or delete items when list is open
        2 pick VK_DELETE = GetDroppedState: parent and
        IF
            drop  GetCurrent: parent  dup DeleteString: parent
            SetSelection: parent  GetSelectedString:  parent  SetText: parent  FALSE
        THEN
        2 pick VK_INSERT = GetDroppedState: parent and
        IF
            GetText: [ ] 2dup  ScaleNumber 3 (U.R) asciiz  dup dup FindExact: parent -1 = IF
            AddStringTo: parent FindExact: parent SetSelection: parent
            SetText: parent ELSE  4drop  THEN
            FALSE
        THEN ;

: WmChar ( h m w l obj -- res )
        2 pick VK_RETURN =
        IF
            GetText: [ ]  ScaleNumber  IDM_SCALE DoCommand
\            ActiveChild IF  SetFocus: ActiveChild  THEN
            FALSE
        THEN
        ;

:M StartSize: ( -- w h )   44 200 ;M

:M WindowStyle: ( -- style )
        WindowStyle: super
        WS_VISIBLE invert and   \ start hidden
        CBS_SORT or
        WS_CLIPCHILDREN or
        ;M

:M Start:   ( Parent -- )
        Start: Super
        Create: ComboFont
        Handle: ComboFont SetFont: self
        RestoreValues: self
        100 SetNumber: self
        ['] WmChar SetWmChar: ComboEdit
        ES_NUMBER +style: ComboEdit
        ['] WmKeyDown SetWmKeyDown: ComboEdit
        ;M

;Object


:ToolStrings PVTooltips

        ts," Open"
        ts," Print picture"
        ts," No adjustment of picture"
        ts," Centre picture in window"
        ts," Centre picture and stretch"
        ts," Stretch picture to fit in window"
        ts," Size window to aspect ratio of picture"
        ts," Rotate 90 degrees anticlockwise"
        ts," Rotate 90 degrees clockwise"
        ts," Rotate 180 degrees"
        ts," Flip horizontally"
        ts," Flip vertically"
        ts," Increase size"
        ts," ScaleCombo"
        ts," Decrease size"
        ts," Previous slide"
        ts," Next slide"
        ts," Start/stop slide show"
        ts," Options dialog"

;ToolStrings


:ToolBarTable PVTable
\ Bmp Ndx     ID                    Initial Style    Initial State         Tooltip Ndx
\ The default state and style for all buttons are enabled and button style
\ You can modify as desired
                                                                           SeparatorButton,
  0        IDM_OPEN                 TBSTATE_ENABLED  TBSTYLE_BUTTON        0 ToolBarButton,
                                                                           SeparatorButton,
  1        IDM_PRINT                0                TBSTYLE_BUTTON        1 ToolBarButton,
                                                                           SeparatorButton,
  2        IDM_NO_ADJUST            TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    2 ToolBarButton,
  3        IDM_CENTRE_IN_WINDOW     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    3 ToolBarButton,
  4        IDM_CENTRE_AND_STRETCH   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    4 ToolBarButton,
  5        IDM_STRETCH_TO_WINDOW    TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    5 ToolBarButton,
  6        IDM_FIXED_ASPECT_RATIO   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP    6 ToolBarButton,
                                                                           SeparatorButton,
  7        IDM_ROTATE_90            0                TBSTYLE_BUTTON        7 ToolBarButton,
  8        IDM_ROTATE_-90           0                TBSTYLE_BUTTON        8 ToolBarButton,
  9        IDM_ROTATE_180           0                TBSTYLE_BUTTON        9 ToolBarButton,
  10       IDM_FLIP_HORIZONTAL      0                TBSTYLE_BUTTON       10 ToolBarButton,
  11       IDM_FLIP_VERTICAL        0                TBSTYLE_BUTTON       11 ToolBarButton,
                                                                           SeparatorButton,
  12       IDM_ZOOM_IN              0                TBSTYLE_BUTTON       12 ToolBarButton,
  13       IDM_SCALE                0                TBSTYLE_BUTTON       13 ToolBarButton,
                                                                           SeparatorButton,
                                                                           SeparatorButton,
                                                                           SeparatorButton,
  14       IDM_ZOOM_OUT             0                TBSTYLE_BUTTON       14 ToolBarButton,
                                                                           SeparatorButton,
  15       IDM_PREVIOUS_SLIDE       0                TBSTYLE_BUTTON       15 ToolBarButton,
  16       IDM_NEXT_SLIDE           0                TBSTYLE_BUTTON       16 ToolBarButton,
  17       IDM_SLIDE_SHOW           0                TBSTYLE_CHECK        17 ToolBarButton,

ToolBarTableExtraButtons:

  18       IDM_OPTIONS              TBSTATE_ENABLED  TBSTYLE_BUTTON       18 ToolBarButton,

;ToolBarTable


:Object PVToolBar   <Super Win32Toolbar

int pszValueNameDefault
:M SaveRestoreDefault: ( f -- )
        pszValueName swap
        pszValueNameDefault to pszValueName
        SaveRestore: self
        to pszValueName
        ;M

:M MoveCombo: ( -- )   \ move ScaleCombo over button, hide if not there
        IDM_SCALE ValidID: self
        IF
            IDM_SCALE CommandToIndex: self  GetButtonRect: self 3drop
            1 47 200  Move: ScaleCombo
            SW_SHOW
        ELSE
            SW_HIDE 
        THEN
        Show: ScaleCombo ;M

:M CheckPictureAdjustment: ( n -- )   \ check correct PictureAdjustment button on toolbar, uncheck the rest
        PictureAdjustment IDM_NO_ADJUST + true swap CheckButton: self ;M

:M EnableButtons: ( f -- )
        dup Enable: hClose
        dup Enable: hSaveAs
        dup Enable: hPrint
        dup IDM_PRINT EnableButton: self         
        dup IDM_ROTATE_90 EnableButton: self         
        dup IDM_ROTATE_-90 EnableButton: self         
        dup IDM_ROTATE_180 EnableButton: self         
        dup IDM_FLIP_HORIZONTAL EnableButton: self         
        dup IDM_FLIP_VERTICAL EnableButton: self         
        dup IDM_ZOOM_IN EnableButton: self         
        dup IDM_ZOOM_OUT EnableButton: self         
        dup IDM_PREVIOUS_SLIDE EnableButton: self         
        dup IDM_NEXT_SLIDE EnableButton: self         
        IDM_SLIDE_SHOW EnableButton: self         
        ;M

:M Start: ( parent -- )
        PVTable         IsButtonTable: self
        PVTooltips      IsTooltips: self
        Start: super
        Self Start: ScaleCombo
        AppInst IDI_TOOLBAR_BMP 19 AddBitmaps: self drop
    \ Set-up registry key for customization data...
        ToolBarLayoutKey 1+            \ Registry sub-key
        z" ToolBarLayout"              \ value key name
        SetRegistryKey: self
        z" ToolBarLayoutDefault" to pszValueNameDefault
        True SaveRestoreDefault: self
        False SaveRestore: self
        MoveCombo: self
        ;M

:M WindowStyle: ( -- style )
        WS_CHILD   \ not WS_VISIBLE - start hidden, not flat
        TBSTYLE_TOOLTIPS or
        CCS_ADJUSTABLE or
        TBSTYLE_TRANSPARENT or
        WS_CLIPCHILDREN or
        WS_CLIPSIBLINGS or
        ;M

:M WM_RBUTTONDOWN ( h m w l -- res )   \ right click for context menu sent to frame window
        swap rot HandleOfParent
        Call SendMessage drop 0
        ;M

:M On_ToolBarChange: ( -- f )                   \ User has changed toolbar
        MoveCombo: self
        ActiveChild EnableButtons: self
        false
        ;M

:M On_Reset: ( -- f )                           \ User resets toolbar
        false SaveRestore: self
        CheckPictureAdjustment: self
        ActiveChild EnableButtons: self
        MoveCombo: self
        true
        ;M

:M On_CustHelp: ( -- f )                        \ Request for customization help
        z" Reset: resets all buttons to their previous positions.\nButtons can also be rearranged or deleted by holding down the shift key while dragging."
        z" Customize Toolbar"
        MB_OK MessageBox: self drop
        true
        ;M

;Object


0 value ToolbarHeight

: ShowToolbar ( -- )   GetWindowRect: PVToolbar nip swap - nip to ToolbarHeight
        SW_SHOW show: PVToolbar  true check: hToolbar ;

: HideToolbar ( -- )   0 to ToolbarHeight
        SW_HIDE show: PVToolbar  false check: hToolbar ;

: CheckToolbarAndMenu ( -- )  
        false false false false false
        sp@ PictureAdjustment 0max 4 min cells+ true swap !
        check: hNoAdjust
        check: hCentre
        check: hStretch
        check: hFit
        check: hAspect
        CheckPictureAdjustment: PVToolbar
        NewWindow check: hNewWindow        
        ;
