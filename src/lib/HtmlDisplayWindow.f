\ HtmlDisplayWindow.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Samstag, Dezember 04 2004 - dbu
\ Updated: Samstag, Dezember 04 2004 - dbu
\
\ Display HTML pages in a Window.

cr .( Loading HtmlDisplayWindow.f : Html Display Window...)

anew -HtmlDisplayWindow.f

needs HtmlControl.f
needs Bitmap.f
needs Toolbar.f
needs RebarControl.f

INTERNAL

\ --------------------------------------------------------------------------------
\ Toolbar for the HtmlDisplayWindow
\ --------------------------------------------------------------------------------

load-bitmap HtmlDisplayBitmaps "apps\sciedit\res\toolbar.bmp"

\ Define tool tips (texts that gives a short description of the buttons function)
\ These correspond to bitmap images in the loaded bitmap
:ToolStrings HtmlDisplayToolTips
        ts," Back"
        ts," Forward"
;ToolStrings

\ Define button strings ( text that can optionally be displayed on the button
:ToolStrings HtmlDisplayToolStrings
        ts," Back"
        ts," Forward"
;ToolStrings

\ Define all toolbar buttons in this application.

NextId constant IDM_HTML_BACK
NextId constant IDM_HTML_FORWARD

:ToolBarTable HtmlDisplayTable
\  Bitmap index id                 Initial state    Initial style      tool string index
  22            IDM_HTML_BACK      TBSTATE_ENABLED  TBSTYLE_BUTTON     0 ToolBarButton,
  23            IDM_HTML_FORWARD   TBSTATE_ENABLED  TBSTYLE_BUTTON     1 ToolBarButton,
;ToolBarTable

:Class HtmlDisplayToolbar     <super Win32ToolBar

int hbitmap
72 constant LargeButtonWidth     \ for buttons with text
48 constant LargeButtonHeight
24 constant SmallButtonWidth     \ a little bigger than Windows default
18 constant SmallButtonHeight
30 constant #buttons
int ButtonText?
int FlatToolBar?

:M ClassInit:   ( -- )
                ClassInit: super
                0 to hbitmap
                false to ButtonText?
                true to FlatToolBar?
                ;M

:M Start:       ( parent -- )
                HtmlDisplayTable         IsButtonTable: self
                HtmlDisplayToolTips         IsToolTips: self

                ButtonText?
                if      HtmlDisplayToolStrings
                else    NULL
                then    IsButtonStrings: self

                Start: super

                \ set button size
                ButtonText?
                if      LargeButtonWidth LargeButtonHeight
                else    SmallButtonWidth SmallButtonHeight
                then    word-join 0 TB_SETBUTTONSIZE SendMessage:Self drop

                \ set bitmap size
                16 18 word-join 0 TB_SETBITMAPSIZE SendMessage:Self drop

                HtmlDisplayBitmaps usebitmap   \ create bitmap handle
                map-transparent               \ use system colors for background
                GetDc: self dup>r CreateDIBitmap to hbitmap
                r> ReleaseDc: self
                hbitmap \ do we have a handle?
                if   0 hbitmap #buttons AddBitmaps: self drop
                then
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                [ TBSTYLE_TOOLTIPS TBSTYLE_WRAPABLE or CCS_ADJUSTABLE or nostack1
                CCS_NOPARENTALIGN or CCS_NORESIZE or ] LITERAL or
                FlatToolBar?
                if      TBSTYLE_FLAT  or
                then
                ;M

:M On_Done:     ( -- )
                hbitmap
                if      hbitmap Call DeleteObject drop
                        0 to hbitmap
                then    On_Done: super
                ;M

:M On_ToolBarChange: ( -- f )                   \ User has changed toolbar
                Autosize: self false
                ;M

;Class

\ --------------------------------------------------------------------------------
\ Rebar for the HtmlDisplayWindow
\ --------------------------------------------------------------------------------

:Class HtmlDisplayRebar          <super RebarControl

HtmlDisplayToolbar HtmlToolbar

: add-toolbar   ( -- )
                eraseband-info

\                 New> HtmlDisplayToolbar to HtmlToolbar
                999 SetID: HtmlToolbar
                self Start: HtmlToolbar

                \ Set-up registry key for toolbar customization data...
                s" SOFTWARE\" pad place
                PROGREG count pad +place
                s" Settings" pad +place
                pad +null pad count drop \ Registry sub-key
                z" ToolBar"
                SetRegistryKey: HtmlToolbar

                \ restore any settings
\                false SaveRestore: HtmlToolbar

                [ RBBIM_CHILD RBBIM_CHILDSIZE or RBBIM_STYLE or RBBIM_SIZE or ] LITERAL
                to bfmask
                GetHandle: HtmlToolbar to hwndchild
                0 to cxMinChild
                25 to cyMinChild
                25 to cyChild       \ band height
                200 to cyMaxChild   \ max band height
                1 to cyIntegral
                200 to cx           \ band width
                RBBS_GRIPPERALWAYS   \ RBBS_VARIABLEHEIGHT or
                RBBS_CHILDEDGE or
                to fstyle
                InsertBand: self ;

:M Start:       ( parent -- )
                Start: super
                hwnd
                if   add-toolbar
                then ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                [ WS_CLIPSIBLINGS WS_CLIPCHILDREN or CCS_NODIVIDER or RBS_VARHEIGHT or RBS_BANDBORDERs or WS_BORDER or RBS_AUTOSIZE or ] literal or
                ;M

:M Close:       ( -- )
                Close: HtmlToolbar
                Close: super ;M

:M Show:        ( f -- )
                if SW_SHOW else SW_HIDE then Show: super ;M

:M Handle_Notify: ( )
                HtmlToolbar
                if   Handle_Notify: HtmlToolbar
                then ;M

:M ClassInit:   ( -- )
                ClassInit: super
                ;M

;class

\ --------------------------------------------------------------------------------
\ HtmlDisplayWindow class
\ --------------------------------------------------------------------------------

EXTERNAL

:class HtmlDisplayWindow <super Window

HTMLControl      HtmlControl
HtmlDisplayRebar HtmlRebar
int              ShowToolbar?

:M On_Init:     ( -- )
                On_Init: super

                1001 SetId: HtmlControl
                self Start: HtmlControl

                1002 SetId: HtmlRebar
                self Start: HtmlRebar
                ;M

: AdjustWindowSize      { width height win -- }
                SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                win Call SetWindowPos drop ;

:M On_Size:     ( -- )
                winRect GetClientRect: self

                Left: winRect Top: winRect Right: winRect Bottom: winRect 2>r
                ShowToolbar? if drop Height: HtmlRebar 2 - then
                2r>
                ShowToolbar? if Height: HtmlRebar - 1+ then
                Move: HtmlControl

                ShowToolbar? if Width Height: HtmlRebar GetHandle: HtmlRebar AdjustWindowSize then
                ;M

:M SetURL:      ( zUrl -- )
                SetURL: HtmlControl ;M

:M GoBack:      ( -- )
                GoBack: HtmlControl ;M

:M GoForward:   ( -- )
                GoForward: HtmlControl ;M

:M GoHome:      ( -- )
                GoHome: HtmlControl ;M

:M GoSearch:    ( -- )
                GoSearch: HtmlControl ;M

:M Refresh:     ( -- )
                Refresh: HtmlControl ;M

:M Stop:        ( -- )
                Stop: HtmlControl ;M

:M WM_NOTIFY    ( h m w l -- res )
                HtmlRebar
                if   Handle_Notify: HtmlRebar
                then ;M

:M ClassInit:   ( -- )
                ClassInit: super
                true to ShowToolbar?
                ;M

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
                over LOWORD IDM_HTML_BACK    = if GoBack: self exitm then
                over LOWORD IDM_HTML_FORWARD = if GoForward: self exitm then
                OnWmCommand: Super
                ;M

;class

MODULE

