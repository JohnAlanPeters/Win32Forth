\ $Id: CommandWindow.f,v 1.34 2014/08/17 15:32:05 rodoakford Exp $

\ CommandWindow - a child window class to accept and edit text on a command line by Rod Oakford
\
\ Features:
\
\ Action when enter is pressed is deferred
\ Font changeable
\ Key buffer
\ Command history
\ Cut, copy and paste


defer HandleKeys      ' drop is HandleKeys      \ define to handle keys e.g. 'O' +k_control
defer HandleKeyDown   ' drop is HandleKeyDown   \ define to handle virtual keys e.g. VK_F12
defer LogKeyStrokes   ' noop is LogKeyStrokes   \ used in KeySave.f defined as menukey-more


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Command Window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class CommandWindow  <Super Child-Window

int action   \ what to do when enter is pressed on the command line
:M SetAction: ( xt -- )   to action ;M

int CommandFont
int hFont
int mDC   \ WinDC mDC   \ used for font calculations

int X
int Y
:M SetXY: ( X Y -- )   to Y to X ;M
:M GetXY: ( -- X Y )   X Y ;M
int XYA

int text   \ pointer to text buffer
int MaxText   \ size of text buffer allocated
int lines    \ number of rows of text
int TextZero   \ address of terminating zero
int FirstRow   \ index of first row partially visible
int FirstRowAddress   \ address of text for first row

: LastRowAddress ( -- a )   TextZero dup text -  10 -scan  drop 1 10 skip drop ;
: RowAddress ( row -- a )   \ address of text at beginning of row
        dup lines 1- >=
        IF  drop LastRowAddress
        ELSE  Text TextZero over -  rot 0 ?DO  13 scan 1 /string 10 skip  LOOP  drop
        THEN ;
: XYAddress ( -- a )   Y RowAddress X + ;   \ address of text at current X Y
: RowString ( row -- a n )   RowAddress  TextZero over -  2dup 13 scan nip - ;   \ without the cr
: RowLength ( row -- n )   RowString nip ;
: RowEndAddress ( row - a )   RowString + ;   \ address immediately after text at end of row (contains cr or null)

: LastRow ( -- row )   lines 1- ;
: LastCol ( -- col )   LastRow RowLength ;

:M LastColRow: ( -- col row )   LastCol LastRow ;M

Rectangle CaretPos    \ caret position to bottom right used to update part of window
Rectangle UpdateRect  \ l , t , r , b

4 bytes TabWidth
16 bytes Prompt
:M SetPrompt: ( z$ -- )   prompt 16 erase prompt 15 move ;M

int Editing
:M SetEditing: ( f -- )   to editing ;M
int #chars   \ number of characters on command line
int CommandStart   \ column after prompt
int CommandLine   \ address of text after prompt
: CommandEnd ( -- X )   CommandStart #chars + ;   \ column at end of command line
: CommandString ( -- a n )   CommandLine #chars ;

int MaxChars   \ maximum number of characters accepted on the command line
:M SetMaxChars: ( n -- )   to MaxChars ;M

int KeysOn
:M KeysOff: ( -- )   false to KeysOn ;M
:M KeysOn: ( -- )   true to KeysOn ;M

int Abort?     \ flag set when esc pressed

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Type ahead Key Buffer \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    1024 bytes KeyBuffer
    int head

:M EmptyKeyBuffer: ( -- )   0 to head ;M

:M KeyBufferEmpty: ( -- f )   head 0= ;M

:M PutKey: ( n -- )   \ as long as key buffer is not full
        head 255 =
        IF  drop  beep
        ELSE  KeyBuffer head 4 * + !  head 1+ to head
        THEN ;M

:M GetKey: ( -- n )   \ returns 0 if KeyBuffer is empty
        KeyBufferEmpty: self
        IF  0
        ELSE  KeyBuffer @  KeyBuffer dup 4 + swap 1020 move  head 1- to head
        THEN ;M

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Selecting Text \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int SelStartCol
int SelStartRow
int SelEndCol
int SelEndRow
int SelEndColNew
int SelEndRowNew
int increasing
int SelStartX
int SelStartY
int SelEndX
int SelEndY

int SelectedAddress         \ highlighted string
int SelectedLength
int SelectionRemainingAddress
int SelectionRemainingLength

256 bytes SelectedLine

: NextSelectedLine ( -- a n )   \ use 1 /string in case n = 0
        SelectionRemainingAddress  SelectionRemainingLength
        2dup  13 scan 1 /string
        2dup 10 skip to SelectionRemainingLength to SelectionRemainingAddress
        nip - SelectedLine place  SelectedLine count
        2dup + 1-  dup c@ 13 = IF  32 swap c!  ELSE  drop  THEN
        ;

: FirstSelectedLine ( -- a n )
        SelectedAddress to SelectionRemainingAddress
        SelectedLength to SelectionRemainingLength
        NextSelectedLine ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Command History \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int MaxHistory
1024 bytes CommandHistory   \ count , 0 , z$ , z$ , ...  0
int Command
: InitHistory ( -- )   CommandHistory to Command ;
:M ClearHistory: ( -- )   CommandHistory off  InitHistory ;M

: AddCommand ( a n -- )  \ pad place pad +null pad count   \ need null terminated string
        2dup CommandHistory 2 + zcount str=                              \ same as previous command
        IF  2drop
        ELSE
        >r CommandHistory dup count  MaxHistory 5 - r@ - min             \ don't move past end of buffer
        over 1 + r@ +  swap 2 + 0max  move                               \ move previous strings along
\        2 +  r@ 1+ MaxHistory 3 - min  move                              \ move in new string at start
        2 +  r@ MaxHistory 4 - min  2dup + 0 swap c!  move               \ move in new string at start
        CommandHistory c@ r> 1+ + MaxHistory 2 - min CommandHistory c!   \ limit count to MaxHistory 2-
        0 CommandHistory MaxHistory 2 - + w!                             \ add 2 zeros at end
        THEN ;
                                                           \ truncating last string
: PrevCommand ( -- a n )
         Command 2 -
         BEGIN  dup c@  over CommandHistory >= and  WHILE  1-  REPEAT  1+   \ scan backwards for 0
         dup CommandHistory max to Command
         dup CommandHistory = IF  0  ELSE  zcount  THEN ;                \ first string is dummy

: NextCommand ( -- a n )
         Command zcount
         2dup + 1+ zcount
         dup IF  over to Command  2swap  THEN
         2drop ;

: ExecuteCommand ( -- )   CommandString dup IF  2dup AddCommand  THEN  action execute ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Scrollbars \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Rectangle ScrollRange   \ ( HMin VMin HMax VMax ) set from DT_CALCRECT DrawText
Rectangle ScrollPage    \ ( 0 0 HPage VPage ) set from GetClientRect
Rectangle ScrollPos     \ ( -HPos -VPos 0 0 ) used by DT_NOCLIP DrawText
Rectangle ScrollPosRel  \ ( -HPos -VPos 0 0 ) ScrollPos for first row to be drawn
int ScrollRangeHMax
int HorzLine
int VertLine
int HorzPage
int VertPage

Record: LPWinScrollInfo
    int cbSize
    int fMask
    int nMin
    int nMax
    int nPage
    int nPos
    int nTrackPos
;RecordSize: sizeof(LPWinScrollInfo)

Record: tm
    int tmHeight
    int tmAscent
    int tmDescent
    int tmInternalLeading
    int tmExternalLeading
    int tmAveCharWidth
    int tmMaxCharWidth
    int tmWeight
    byte tmItalic
    byte tmUnderlined
    byte tmStruckOut
    byte tmFirstChar
    byte tmLastChar
    byte tmDefaultChar
    byte tmBreakChar
    byte tmPitchAndFamily
    byte tmCharSet
    int tmOverhang
    int tmDigitizedAspectX
    int tmDigitizedAspectY
;Record

Record: DRAWTEXTPARAMS
    int dtSize
    int iTabLength
    int iLeftMargin
    int iRightMargin
    int uiLengthDrawn
;RecordSize: sizeof(DRAWTEXTPARAMS)

    int iTopMargin
    int iBottomMargin

:M SetTabLength: ( n -- )   to iTabLength ;M

:M SetLeftMargin: ( n -- )   to iLeftMargin ;M

:M SetRightMargin: ( n -- )   to iRightMargin ;M

:M SetTopMargin: ( n -- )   to iTopMargin ;M

:M SetBottomMargin: ( n -- )   to iBottomMargin ;M

\ :M VisibleCols: ( -- cols )   width iLeftMargin - iRightMargin -  HorzLine / ;M

:M VisibleCols: ( -- cols )   \ number of columns visible if vertical scrollbar were present
        GetWindowRect: self drop nip swap -
        SM_CXVSCROLL call GetSystemMetrics -
        iLeftMargin - iRightMargin -  HorzLine /
        ;M

:M VisibleRows: ( -- rows )   height  ScrollPos.Top negate VertLine mod -  VertLine / ;M

:M VisibleColRow: ( -- cols rows )
        VisibleCols: self
        VisibleRows: self
        ;M

:M FirstPartialRow: ( -- n )   ScrollPos.Top negate VertLine / ;M   \ number of first row partially visible

:M FirstVisibleRow: ( -- n )   ScrollPos.Top negate VertLine + 1- VertLine / ;M   \ number of first row completely visible

:M LastVisibleRow: ( -- n )   FirstVisibleRow: self  VisibleRows: self + ;M   \ number of last row  completely visible

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Managing the Scrollbars \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ScrollAdjust ( x y -- x y )
        >r  iLeftMargin + ScrollPos.left +
        r>  ScrollPos.top + ;

:M UpdateVScroll: ( -- )
        Top: ScrollPos negate to nPos
        Top: ScrollRange to nMin
        Bottom: ScrollRange to nMax
        Bottom: ScrollPage 1+ to nPage
        nPage nMax > IF  0 ScrollPos 4 + !  0 nPos Scroll: self  THEN
        Top: ScrollPos negate  TRUE  LPWinScrollInfo  SB_VERT
        hWnd  Call SetScrollInfo  negate ScrollPos 4 + !
        Top: ScrollPos + ?dup IF  0 swap Scroll: self  THEN
        ;M

:M UpdateHScroll: ( -- )
        Left: ScrollPos negate to nPos
        Left: ScrollRange  to nMin
        Right: ScrollRange  to nMax
        Right: ScrollPage 1+ to nPage
        nPage nMax > IF  0 ScrollPos !  nPos 0 Scroll: self  THEN
        Left: ScrollPos negate  TRUE  LPWinScrollInfo  SB_HORZ
        hWnd  Call SetScrollInfo  negate ScrollPos !
        Left: ScrollPos + ?dup IF  0 Scroll: self  THEN
        ;M

: UpdateRectangle ( l t r b f -- )   >r  SetRect: UpdateRect  r> UpdateRect InvalidateRect: self ;

: UpdateScrollPosRel ( -- )   ScrollPos ScrollPosRel 16 move  FirstRow   Vertline * ScrollPosRel 4 + +! ;

: UpdateFirstRow ( -- )   FirstPartialRow: self to FirstRow  FirstRow RowAddress to FirstRowAddress ;

: VScroll ( n -- )
        Bottom: ScrollPage Bottom: ScrollRange <= and  ?dup
        IF
            Top: ScrollPos negate min  Bottom: ScrollPage
            Bottom: ScrollRange - Top: ScrollPos -  max
            dup  ScrollPos 4 + +!  0 over Scroll: self
            dup 0> IF  >r  0 0 width r> true UpdateRectangle  ELSE  drop  THEN
            UpdateVScroll: self
            UpdateFirstRow
            UpdateScrollPosRel
        THEN
        ;

:M WM_VSCROLL ( h m w l -- res )   over word-split swap
        CASE
            SB_BOTTOM        OF      Bottom: ScrollRange negate    ENDOF
            SB_TOP           OF      Bottom: ScrollRange           ENDOF
            SB_LINEDOWN      OF      VertLine negate               ENDOF
            SB_LINEUP        OF      VertLine                      ENDOF
\            SB_PAGEDOWN      OF      VertPage negate               ENDOF
\            SB_PAGEUP        OF      VertPage                      ENDOF
            SB_PAGEDOWN      OF      VisibleRows: self VertLine * negate  ENDOF
            SB_PAGEUP        OF      VisibleRows: self VertLine *         ENDOF
            SB_THUMBTRACK    OF      dup negate  Top: ScrollPos negate $FFFF and negate -  ENDOF
            ( default case)	       0 swap
        ENDCASE
        VScroll
        0
        ;M

: HScroll ( n -- )
        Right: ScrollPage Right: ScrollRange <= and  ?dup
        IF
            Left: ScrollPos negate min  Right: ScrollPage
            Right: ScrollRange - Left: ScrollPos -  max
            dup  ScrollPos +!  0 Scroll: self
            UpdateHScroll: self
            UpdateScrollPosRel
        THEN
        ;

:M WM_HSCROLL ( h m w l -- res )   over word-split swap
        CASE
            SB_BOTTOM        OF      Right: ScrollRange negate     ENDOF
            SB_TOP           OF      Right: ScrollRange            ENDOF
            SB_LINERIGHT     OF      HorzLine negate               ENDOF
            SB_LINELEFT      OF      HorzLine                      ENDOF
\            SB_PAGERIGHT     OF      HorzPage negate               ENDOF
\            SB_PAGELEFT      OF      HorzPage                      ENDOF
            SB_PAGERIGHT     OF      VisibleCols: self HorzLine * negate  ENDOF
            SB_PAGELEFT      OF      VisibleCols: self HorzLine *         ENDOF
            SB_THUMBTRACK    OF      dup negate  Left: ScrollPos - ENDOF
            ( default case)	       0 swap
        ENDCASE
        HScroll
        0
        ;M

:M WM_MOUSEWHEEL ( h m w l -- res )   over word-split 32768 and
        \ get the Key flags (loword of wParam) and the WHEEL_DELTA (hiword of wParam)
        \ A positive value indicates that the wheel was rotated forward, away
        \ from the user; a negative value indicates that the wheel was rotated
        \ backward, toward the user.
        IF
            Case
                0                       of  SB_LINEDOWN   WM_VSCROLL  Endof
                MK_SHIFT                of  SB_LINERIGHT  WM_HSCROLL  Endof
                MK_CONTROL              of  SB_PAGEDOWN   WM_VSCROLL  Endof
                MK_SHIFT MK_CONTROL or  of  SB_PAGERIGHT  WM_HSCROLL  Endof
                ( default case) 0 0 rot
            EndCase
        ELSE
            Case
                0                       of  SB_LINEUP     WM_VSCROLL  Endof
                MK_SHIFT                of  SB_LINELEFT   WM_HSCROLL  Endof
                MK_CONTROL              of  SB_PAGEUP     WM_VSCROLL  Endof
                MK_SHIFT MK_CONTROL or  of  SB_PAGELEFT   WM_HSCROLL  Endof
                ( default case) 0 0 rot
            EndCase
        THEN
        0 -rot ?dup IF  hWnd send-window  ELSE  3drop  THEN
        0 ;M

:M HHome: ( -- )   Right:  ScrollRange HScroll ;M
:M HEnd:  ( -- )   Right:  ScrollRange negate HScroll ;M
:M VHome: ( -- )   Bottom: ScrollRange VScroll ;M
:M VEnd:  ( -- )   Bottom: ScrollRange negate VScroll ;M

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Setting and drawing the caret \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int CaretWidth
int CaretHeight

:M CharWH: ( -- w h )   HorzLine VertLine ;M

:M HideCaret: ( -- )   hWnd call HideCaret drop ;M

:M ShowCaret: ( -- )   hWnd call ShowCaret drop ;M

:M CreateCaret: ( -- )
        CaretHeight CaretWidth 0 hWnd call CreateCaret drop
        CaretPos.top CaretPos.left call SetCaretPos drop
        ShowCaret: self
        true to cursor-on?
        ;M

:M DestroyCaret: ( -- )   HideCaret: self  call DestroyCaret drop  false to cursor-on? ;M

:M SetCaret: ( w h -- )
        to CaretHeight  to CaretWidth
        DestroyCaret: self
        CreateCaret: self
        ;M

:M BigCursor: ( -- )   CharWH: self SetCaret: self ;M

:M SmallCursor: ( -- )   1 VertLine SetCaret: self ;M

:M On_SetFocus: ( h m w l -- )   CreateCaret: self  true to have-focus? ;M

:M On_KillFocus: ( h m w l -- )   DestroyCaret: self  false to have-focus? ;M

: ColRow>xy ( col row -- x y )   \ needs dc
        dup>r RowAddress
        TabWidth 1 2swap
        GetHandle: mdc call GetTabbedTextExtent
        loword  r> VertLine *
        ;

: SetCaretPosition ( X Y -- )   \ needs dc, also sets an update rectangle to end of line
        over to X  ColRow>xy ScrollAdjust
        dup VertLine +  width swap  SetRect: CaretPos
        cursor-on? IF  CaretPos.top CaretPos.left call SetCaretPos drop  THEN
        ;

: SetSelectionStart ( X Y -- )   \ needs dc
        2dup ColRow>xy to SelEndY to SelEndX
        dup to SelStartRow to SelEndRow
        dup to SelStartCol to SelEndCol
        ;

: SCP ( -- )   \ SetCommandPosition
        X Y SetSelectionStart
        X Y SetCaretPosition
        ;

:M UpdatePoint: (  -- )   0 0 1 1 false UpdateRectangle Update: self ;M   \ force a paint

: UpdateRange ( SelStartCol SelStartRow SelEndCol SelEndRow f -- )
        >r 2>r
        ColRow>XY ScrollAdjust  2r> ColRow>XY VertLine + ScrollAdjust  r> UpdateRectangle
        ;

:M UpdateLine: ( Y -- )   \ and redraw background, used in CR to erase after crlf to edge of window
        0 swap VertLine * ScrollPos.top + width over VertLine + true UpdateRectangle
        ;M

:M AutoHScroll: ( -- )   \ scroll caret into view horizontally
        PauseForMessages
        iLeftMargin CaretPos @ - 0 max
        width iRightMargin - CaretPos @ - 0 min  + HScroll
        UpdateHScroll: self
        SCP
        ;M

:M AutoVScroll: ( -- )   \ scroll caret into view vertically
        PauseForMessages
        0 CaretPos cell+ @ - 0 max
        height VertLine - CaretPos cell+ @ - 0 min  + VScroll
        UpdateVScroll: self
        SCP
        ;M

:M AutoScroll: ( -- )   \ scroll caret into view
        WindowState: parent SIZE_MINIMIZED = IF  exitm  THEN
\        UpdatePoint: self   \ force a paint to update text size
\        PauseForMessages
        iLeftMargin CaretPos @ - 0 max
        width iRightMargin - CaretPos @ - 0 min  + HScroll
        0 CaretPos cell+ @ - 0 max
        height VertLine - CaretPos cell+ @ - 0 min  + VScroll
        UpdateHScroll: self
        UpdateVScroll: self
\        SCP
        ;M

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Drawing the Text \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int ForegroundColour
int BackgroundColour
:M SetForeground: ( color_object -- )   to ForegroundColour ;M
:M SetBackground: ( color_object -- )
       dup to BackgroundColour
       Brush: [ ]  GCL_HBRBACKGROUND hWnd Call SetClassLong drop
       paint: self
       ;M

:M On_Paint: ( -- )   \ all window refreshing is done by On_Paint:
                      \ the size of the text is now calculated in UpdateScrollRange:
                      \ text metrics are calculated just once in SetFont:

        hFont SetFont: dc
        ForegroundColour SetTextColor: dc
        BackgroundColour SetBkColor: dc

\ Draw the null terminated text
        DRAWTEXTPARAMS  DT_NOCLIP DT_EXPANDTABS or DT_TABSTOP or DT_NOPREFIX or
\        ScrollPos  -1 Text  GetHandle: dc  call DrawTextEx  drop
\        ScrollPos  TextZero Text - Text  GetHandle: dc  call DrawTextEx  drop
        ScrollPosRel TextZero FirstRowAddress -  FirstRowAddress GetHandle: dc  call DrawTextEx  drop

\ Draw highlighted text if any
        SelectedLength
        IF
            BackgroundColour SetBkColor: dc
            ForegroundColour SetBkColor: dc
            iLeftMargin scrollpos.left +  TabWidth  1
            FirstSelectedLine swap
            SelStartX SelStartY ScrollAdjust swap
            GetHandle: dc call TabbedTextOut drop

            0 SelStartX SelStartY nip ScrollAdjust   \ adjusted point at start of row
            BEGIN  SelectionRemainingLength          \ while some chars left
            WHILE
                 VertLine +  2dup 2>r
                 iLeftMargin scrollpos.left +  TabWidth  1
                 NextSelectedLine swap
                 2r> swap
                 GetHandle: dc call TabbedTextOut drop
            REPEAT
            2drop
        THEN
        ;M

:M UpdateScrollRange: ( -- )   \ Calculate the size of the text and update ScrollRange
                               \ using all the lines of text and updating number of lines
        DRAWTEXTPARAMS  DT_CALCRECT DT_EXPANDTABS or DT_TABSTOP or DT_NOPREFIX or
\        ScrollRange  -1 Text GetHandle: mdc  call DrawTextEx  VertLine / to lines
        ScrollRange  TextZero Text - Text  GetHandle: mdc  call DrawTextEx  VertLine / to lines
        ScrollRange 8 + @ to ScrollRangeHMax
        ;M

:M Redraw: ( -- )
        Paint: self
        UpdateScrollRange: self
        UpdateVScroll: self
        UpdateHScroll: self
        ;M

:M SetFont: ( font -- )
        delete: CommandFont  to CommandFont  create: CommandFont
        Handle: CommandFont to hFont
        hFont SetFont: mdc
        tm GetTextMetrics: mdc
        tmAveCharWidth  dup to HorzLine  20 * to HorzPage
        tmHeight tmExternalLeading +  dup to VertLine  7 * to VertPage
        iTabLength HorzLine * TabWidth !
        Redraw: self
        PauseForMessages  BigCursor: self
        ;M

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Text Operations \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int CC
int PC
int nm
: GetTabbedCharsFromPoint ( x a n -- n )  to nm  0 to PC
        swap >r
        1
        BEGIN   2dup  swap  TabWidth 1 2swap  GetHandle: mdc call GetTabbedTextExtent
            loword  dup to CC  r@ <= over nm < and
        WHILE 1+ CC to PC
        REPEAT nip
        r>  PC CC + 2 / < IF  1-  THEN ;

: GetColRow ( X Y -- col row )   \ needs dc
        ScrollRange.bottom min scrollpos.top - VertLine / lines 1- min  0max  >r
        ScrollRange.right  iRightMargin - ( HorzLine + )   min scrollpos.left - iLeftMargin -
        r@ RowAddress r@ RowLength GetTabbedCharsFromPoint
        r@ RowLength min  r>  ;

: UpdateLines { StartX StartY EndX EndY -- }
        StartX 0max to StartX
        EndX 0max to EndX

        StartX StartY EndX EndY d>   \ make sure EndY >= StartY
        IF  StartX StartY EndX EndY to StartY to StartX to EndY to EndX  THEN

        StartY EndY < dup
        IF
            StartX width min  StartY  width     \ more than one line
        ELSE
            StartX  StartY  EndX    \ one line only
        THEN
        VertLine +to StartY   \ ** bug fixed, was doing last middle line twice
        StartY  true UpdateRectangle

        BEGIN  StartY EndY <
        WHILE
            0 StartY width  VertLine +to StartY  StartY   \ whole lines
            true UpdateRectangle
        REPEAT

        IF
            0 EndY EndX EndY Vertline +   \ last line only if more than one line
            true UpdateRectangle
        THEN
        ;

:M Select: ( col row -- )   \ select text from SelStart to SelEnd - col row
        SelEndCol SelEndRow         \ previous SelEnd col row
        2swap to SelEndRow to SelEndCol
        SelEndCol SelEndRow d= not   \ end position changed
        IF
            SelStartCol SelStartRow SelEndCol SelEndRow
            4dup d> IF  2swap  THEN
            2over ColRow>XY to SelStartY to SelStartX
            RowAddress + >r  RowAddress + r>  over -  to SelectedLength  to SelectedAddress
            SelEndX SelEndY ScrollAdjust   \ previous end point
            SelEndCol SelEndRow ColRow>XY  to SelEndY to SelEndX
            SelEndX SelEndY ScrollAdjust   \ new end point
            UpdateLines
        THEN
        ;M

: OnCommandLine ( col row -- f )
        Y =  swap CommandStart CommandEnd between  and
        ;

: StartBeforeCommandLine ( -- f )   SelStartCol SelStartRow CommandStart Y d< ;
: StartAfterCommandLine ( -- f )   SelStartCol SelStartRow CommandEnd Y d> ;
: BeforeCommandLine ( col row -- f )   CommandStart 1+ Y d< ;
: AfterCommandLine ( col row -- f )    CommandEnd 1- Y  d> ;
: SameRowAsCommandLine ( -- f )   SelStartRow Y = ;

: On_Track ( h m -- h m )
        KeysOn not ?exit
        MouseX MouseY GetColRow
        2dup BeforeCommandLine StartBeforeCommandLine and >r
        2dup AfterCommandLine  StartAfterCommandLine  and >r
        2dup OnCommandLine  Editing and  2r> or or
        IF  Select: self  ELSE  2drop  THEN
       ( winpause ) ;

:M Deselect: ( -- )
        SelectedLength
        IF
            0 to SelectedLength
            SelStartCol SelStartRow ColRow>XY  ScrollAdjust
            SelEndCol SelEndRow ColRow>XY  ScrollAdjust
            UpdateLines
            SelStartCol to SelEndCol SelStartRow to SelEndRow
        THEN ;M

: SetStart ( x y -- )   \ used in On_Click and SelectAll:
        GetColRow  2dup SetSelectionStart
        over swap  OnCommandLine
        IF  Y SetCaretPosition  true
        ELSE  drop  false
        THEN  to Editing
        ;

: On_Click ( h m w -- h m w )
        KeysOn not ?exit
        MK_SHIFT and
        IF  On_Track
        ELSE
            hWnd Call SetCapture drop
            Deselect: self
            MouseX MouseY SetStart
        THEN
        ;

: On_Unclick ( h m w -- h m w )
        KeysOn not ?exit
        Call ReleaseCapture drop ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Changing text in the text buffer \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:M ReplaceText: { a n a1 n1 -- }   \ replace a1 n1 with string a n
        a1 n1 +  a1 n +  TextZero a1 - n1 -  1+     move
        n n1 - +to TextZero
        n  0 ?DO  a i + c@
        dup 0= IF  drop 32  THEN  a1 i + c! LOOP   \ replace 0 with space
        ;M

\ :M DeleteText: ( a1 n1 -- )   ptrNull 0 2swap ReplaceText: self ;M

:M DeleteText: { a1 n1 -- }   \ remove a1 n1
\        n1 0max to n1
        a1 n1 +  ( TextZero min )  a1  TextZero a1 - n1 - ( 0max ) 1+  move
        n1 negate +to TextZero
        ;M

\ :M InsertText: ( a n a1 -- )   0 ReplaceText: self ;M

:M InsertText: { a n a1 -- }
        a1  a1 n +  TextZero a1 - 1+  move
        n +to TextZero
        a  a1  n  move
        ;M

:M InsertTextAtEnd: ( a n -- )   TextZero InsertText: self ;M

:M DeleteTextOnCommandLine: ( a1 n1 -- )   \ and replace with spaces
        dup>r DeleteText: self
        SPCS r@  CommandLine #chars + r> -  InsertText: self
        ;M

:M DeleteTextAndRedraw: ( a n -- )   \ DeleteText and update
        DeleteText: self
        Deselect:  self
        Redraw: self
        XYAddress to XYA
        ;M

:M DeleteTextFromStart: ( n -- )   \ n chars increased to make whole rows, Y adjusted
\        text +  Text zcount
        text +  Text TextZero over -
        BEGIN  Y 1- 0max to Y  13 scan 1 /string 10 skip  over 3 pick > over 0= or UNTIL
        drop text - nip
        Text swap DeleteTextAndRedraw: self ;M

: CheckTextBuffer ( n -- )
\        dup  text zcount nip + 256 + MaxText >
        dup  TextZero text - + 256 + MaxText >
        IF  DeleteTextFromStart: self  ELSE  drop  THEN ;

: ScrollRangeChanged? ( -- )
        X Y ColRow>xy bottom: ScrollRange >
        swap right: ScrollRange > or
        ;

:M OverwriteLineAtXY: ( a n -- )
        dup>r
        XYA  over 2dup 13 scan nip - >r  over 2dup 0 scan nip -  r> min  r@ min  ReplaceText: self
        X Y  r@ +to XYA  r> +to X   X Y  false UpdateRange
        X Y ColRow>xy drop right: ScrollRange max ScrollRange 8 + !
        ;M

:M DeleteLine: ( -- )   \ delete current row
        XYA TextZero over -
        2dup 13 scan 13 skip 10 skip nip - DeleteText: self
\        2dup 13 scan 13 skip 10 skip nip - dup>r  DeleteText: self
\        0 Y r> 1+ Y true UpdateRange   \ no need to update here
        ;M

:M CR: ( -- )
        crlf$ count XYA InsertText: self
        Y UpdateLine: self
        2 +to XYA
        Y lines = IF  1 +to lines  THEN
        0 to X  1 +to Y
        DeleteLine: self   \ no need to update this
\        1 +to lines
\        ScrollRange 12 + @ VertLine + ScrollRange 12 + !
        VertLine ScrollRange 12 + +!
        scp
        AutoScroll: self
        ;M

:M ?CR: ( n -- )   X +  VisibleCols: self  > IF  CR: self  THEN ;M

int wrap
:M wrap: ( n -- )   to wrap ;M   \ false: no wrapping, true: wrap after last visible column, positve value: wrap after this column

: AdjustCount ( n -- n )   wrap IF  wrap 0< IF  VisibleCols: self  ELSE  wrap  THEN  X - min 0 max  THEN ;

:M OverwriteTextAtXY: ( a n -- )   \ one line at a time
        dup CheckTextBuffer
        BEGIN  10 skip  dup>r  2dup 2dup 13 scan nip -  AdjustCount
            dup>r  OverwriteLineAtXY: self  r@ 2r> -   \ chars inserted, chars remaining
        WHILE  CR: self  /string  13 skip
        REPEAT  3drop
        SCP
        ;M

:M InsertTextAtXY: ( a n -- )   \ insert text and update to end of row
                                \ ************ special one for command line
        dup>r  XYAddress  0  ReplaceText: self
        X  Y  r> +to X  Y RowLength Y  false UpdateRange
        ScrollRangeChanged? IF  UpdateScrollRange: self  THEN
        ;M

:M GoToXY: ( X Y -- )   \ add extra lines and lengthen lines with spaces if necessary
        to Y to X
        Y LastRow - 0max 0 ?DO  crlf$ count InsertTextAtEnd: self  LOOP
        Y RowString 2>r
        X r@ >
        IF  SPCS X r@ -  2r> +  InsertText: self  ELSE  2r> 2drop  THEN
        UpdateScrollRange: self
        SCP
        XYAddress to XYA
        ;M

:M cls: ( -- )
        0 text c!
        0 to X  0 to Y  1 to lines
        0 to CommandStart  0 to #chars
        text to XYA  text to TextZero
        text to FirstRowAddress
        0 to FirstRow
        UpdateScrollPosRel
        0 0 0 VertLine SetRect: ScrollRange
\        EraseRect: ScrollRange
        Redraw: self
        ;M

:M InsertTextOnCommandLine: ( z$ -- )   \ at XY, limit to MaxChars in total after insert
        Deselect: self                  \ don't change text after command line
        HideCaret: self
        zcount MaxChars #chars -  2dup > IF  beep  THEN  min  dup>r
        dup +to #chars  InsertTextAtXY: self
        CommandString +   Y RowLength  CommandEnd - r> min  DeleteText: self
        SCP
        true to editing
        ShowCaret: self
        AutoScroll: self
        ;M

:M emit: ( c -- )   sp@  InsertTextOnCommandLine: self  drop ;M

:M BackSpace:  ( -- )
        x y or if
          x if y x 1- swap gotoxy: self
            else y 1- dup rowlength swap gotoxy: self
            then then
        ;M

: On_DblClick  ( h m w -- h m w )   \ insert double-clicked word in commandline, click within half a character either side of the word
        KeysOn not  ?shift or  ?exit
        SelStartCol SelStartRow OnCommandLine ?exit
        SelStartCol  SelStartRow RowAddress +         \ ( -- address of character clicked )
        dup 1-  SelStartCol  32 -scan  drop  1+       \ search backwards for space or beginning of line ( -- address of first char of word )
        over dup TextZero swap -  13 scan  drop       \ search forwards for cr
        rot dup TextZero swap -  32 scan  drop  min   \ search forwards for space ( -- address of last char of word +1 )
        over -                                        \ ( -- a n )
        ?dup                                          \ don't insert a space only
        IF
            pad place  32 pad count + !               \ replace possible cr with a space and add a null
            pad 1+ InsertTextOnCommandLine: self
        ELSE  drop
        THEN ;

:M DeleteCommand: ( -- )
        Deselect: self
        #chars
        IF
            CommandLine #chars DeleteTextOnCommandLine: self
            CommandStart to X
            X Y  X #chars + Y true UpdateRange
            0 to #chars
            SCP
            true to editing
            AutoScroll: self
        THEN
        ;M

:M DeleteSelectedTextOnCommandLine: ( -- )
        SelectedAddress Selectedlength DeleteTextOnCommandLine: self
        SelStartCol SelEndCol min to X    \ Update: self
        X Y  X #chars + Y true UpdateRange
        SelectedLength negate +to #chars
        Deselect: self
        SCP
        true to editing
        ;M
int cn
((
:M DeleteSelectedText: ( -- )   \ adjust X if necessary
        SelectedLength
        IF
            StartBeforeCommandLine
            IF
                SelectedAddress  SelectedLength + Y RowAddress - 0max to cn
                Y lines
                SelectedAddress  SelectedLength cn - DeleteTextAndRedraw: self
                lines -  - 0max to Y  cn if 1 +to Y then
                SPCS cn Y RowAddress cn ReplaceText: self
                Y UpdateLine: self
                CommandStart Y RowAddress + to CommandLine
                scp
            ELSE
                StartAfterCommandLine
                IF  SelectedAddress  SelectedLength DeleteTextAndRedraw: self
                ELSE  DeleteSelectedTextOnCommandLine: self
                THEN
            THEN
        THEN
        ;M
))
int cnn
:M DeleteSelectedText: ( -- )   \ adjust X if necessary
        SelectedLength
        IF
            StartBeforeCommandLine
            IF
                SelectedAddress  SelectedLength + Y RowAddress - dup to cnn 0max to cn
                Y lines
                SelectedAddress SelectedLength cn - ( cnn 0= if 2 - then ) DeleteTextAndRedraw: self
                cnn 0= if  crlf$ count SelectedAddress InsertText: self 1 +to lines THEN
                lines -  - 0max to Y
                SPCS cn Y RowAddress cn ReplaceText: self
                Y UpdateLine: self
                CommandStart Y RowAddress + to CommandLine
                SCP
            ELSE
                StartAfterCommandLine
                IF  SelectedAddress  SelectedLength DeleteTextAndRedraw: self
                ELSE  DeleteSelectedTextOnCommandLine: self
                THEN
            THEN
        THEN
        ;M

:M DeleteBackward: ( -- )
        SelectedLength  SelStartCol SelStartRow OnCommandLine  and
        IF  DeleteSelectedTextOnCommandLine: self
        ELSE
            Deselect: self
            X CommandStart >
            IF
                -1 +to X
                XYAddress 1 DeleteTextOnCommandLine: self
                X Y  X #chars + Y true UpdateRange
                -1 +to #chars
                SCP
                true to editing
                AutoScroll: self
            ELSE  beep
            THEN
        THEN ;M

:M DeleteForward: ( -- )
        SelectedLength
        IF  DeleteSelectedText: self   \ anywhere
        ELSE
            Deselect: self
            X CommandEnd <
            IF
                XYAddress 1 DeleteTextOnCommandLine: self
                X Y  X #chars + Y true UpdateRange
                -1 +to #chars
                SCP
                true to editing
                AutoScroll: self
            ELSE  beep
            THEN
        THEN ;M

:M Prompt: ( -- )
        UpdateScrollRange: self
        true to editing
        prompt zcount OverwriteTextAtXY: self
        X to CommandStart
        XYA to CommandLine
        0 to #chars
        SPCS MaxChars Y RowLength X - min OverwriteTextAtXY: self   \ blank up to MaxChar
        CommandStart to X
        SCP
        AutoScroll: self
        ShowCaret: self
        ShowCaret: self   \ does no harm but prevents loss of caret with lengthy text in buffer
        InitHistory
        KeysOn: self   \ KeysOn only during prompt
        ;M

:M EndPrompt: ( -- )
        HideCaret: self
        Deselect: self
        CommandEnd to X   \ correct X if caret is not at end of command line
        XYAddress to XYA
        false to editing
        KeysOff: self   \ KeysOff when not editing commandline
        ExecuteCommand
\        -1 to CommandStart
        0 to #chars
        ;M

int ClipboardHandle
int ClipboardAddress
int ClipboardCount

: OpenClipboard ( -- )
        CF_TEXT call IsClipboardFormatAvailable
        IF
            hWnd call OpenClipboard drop
            CF_TEXT call GetClipboardData dup to ClipboardHandle
            call GlobalLock zcount to ClipboardCount to ClipboardAddress
        THEN
        ;

: CloseClipboard ( -- )
        ClipboardHandle call GlobalUnlock drop
        call CloseClipboard drop
        0 to ClipboardHandle
        ;

:M EmptyClipboard: ( -- )   hWnd call OpenClipboard drop  call EmptyClipboard drop  call CloseClipboard drop ;M

:M Paste: ( -- )   \ paste (and execute) all text in the clipboard to the commandline
        ClipboardHandle 0= IF  OpenClipboard  ClipboardHandle 0= IF  beep  exitm  THEN  THEN
        ClipboardAddress ClipboardCount 2dup 2dup 13 scan nip dup>r - dup>r                   \ next line without CRLF
        pad place  pad +null  pad 1+ InsertTextOnCommandLine: self  r> r>                     \ chars inserted, chars remaining
        IF
            /string  13 skip 10 skip  to ClipboardCount to ClipboardAddress                   \ lines remaining
            EndPrompt: self
            ClipboardCount
            IF  'V' +k_control PutKey: self                                                   \ repeat Paste:
            ELSE  CloseClipboard
            THEN
        ELSE
            3drop
            0 to ClipboardCount
            CloseClipboard
        THEN
        true to editing
        ;M

:M PasteFirstLine: ( -- )   \ paste only the first line (less CR) to the commandline
        CF_TEXT call IsClipboardFormatAvailable
        IF
            hWnd call OpenClipboard drop
            CF_TEXT call GetClipboardData
            dup call GlobalLock zcount
            2dup 13 scan nip -  pad place  pad +null
            pad 1+ InsertTextOnCommandLine: self
            call GlobalUnlock drop
            call CloseClipboard drop
            true to editing
        THEN
        ;M

:M Copy: ( -- )
        SelectedLength
        IF
            hWnd call OpenClipboard drop
            call EmptyClipboard drop
            SelectedLength 1+ GMEM_DDESHARE call GlobalAlloc
            dup Call GlobalLock  dup SelectedLength 1+ erase
            SelectedAddress over SelectedLength move
            CF_TEXT call SetClipboardData drop
            call GlobalUnlock drop
            call CloseClipboard drop
        THEN
        ;M

:M Cut: ( -- )
        Copy: self
        DeleteSelectedText: self
        ;M

: MoveCaret ( x -- )
        to X
        HideCaret: self
        SCP
        true to editing
        ShowCaret: self
        AutoHScroll: self
        ;

: MoveCaretAndDeselect ( x -- )
        Deselect: self
        false CaretPos InvalidateRect: self   \ or to end of command line or one char
        MoveCaret
        ;

: ?MoveCaretAndDeselect ( x f -- )   IF  MoveCaretAndDeselect  ELSE  beep drop  THEN ;

:M CaretLeft: ( -- )   X 1-  X CommandStart >  ?MoveCaretAndDeselect ;M   \ move caret one character to left, deselects any text

:M CaretRight: ( -- )   X 1+  X CommandEnd <  ?MoveCaretAndDeselect ;M   \ move caret one character to right, deselects any text

:M Home: ( -- )   CommandStart  X CommandStart >  ?MoveCaretAndDeselect ;M   \ move caret to beginning of line, deselects any text

:M End: ( -- )   CommandEnd  X CommandEnd <  ?MoveCaretAndDeselect ;M   \ move caret to end of line, deselects any text

\ :M CtrlHome: ( -- )  ;M   \ ( not defined, will scroll parent window horzontally )

\ :M CtrlEnd: ( -- )   ;M   \ ( not defined, will scroll parent window horzontally )

: BeepEditEnd ( -- f )   SelEndCol SelEndRow  CommandEnd Y  d= ;   \ editing at end of command line
: BeepEditStart ( -- f )   SelEndCol SelEndRow  CommandStart Y  d= ;   \ editing at start of command line

: BeepEndCommandLine ( -- f )   SelEndCol SelEndRow  CommandEnd Y  d=  increasing not and ;   \ reached end of command line
: BeepStartCommandLine ( -- f )   SelEndCol SelEndRow  CommandStart Y  d=  increasing and ;   \ reached start of command line

: BeepLineUp ( -- f )   SelEndCol 0=  increasing and ;   \ start of any line, increasing
: BeepLineDown ( -- f )   SelEndCol 0=  increasing not and ;   \ start of any line, decreasing
  
: BeepStartText ( -- f )   SelEndCol SelEndRow d0= ;   \ reached start of text
: BeepEndText ( -- f )   SelEndCol SelEndRow RowLength =  SelEndRow LastRow =  and ;   \ reached end of text

:M ShiftHome: ( -- )   \ decrease the selection to beginning of line
        Editing
        IF  BeepEditStart IF  beep exitm  THEN  CommandStart Y  2dup SetCaretPosition
        ELSE
            BeepEndCommandLine  BeepLineDown  or IF  beep exitm  THEN
            StartAfterCommandLine SameRowAsCommandLine and
            IF  CommandEnd Y  ELSE  0 SelStartRow  THEN
            false to increasing
        THEN
        Select: self ;M

:M ShiftEnd: ( -- )   \ increase the selection to end of line
        Editing
        IF  BeepEditEnd IF  beep exitm  THEN  CommandEnd Y  2dup SetCaretPosition
        ELSE
            BeepStartCommandLine  BeepLineUp  BeepEndText  or or IF  beep exitm  THEN
            StartBeforeCommandLine SameRowAsCommandLine and
            IF  CommandStart Y
            ELSE  SelStartRow LastRow =  IF  LastColRow: self  ELSE  0 SelStartRow 1+  THEN
            THEN
            true to increasing
        THEN
        Select: self ;M

:M CtrlShiftHome: ( -- )   \ decrease the selection to beginning of text
        Editing
        IF  BeepEditStart IF  beep exitm  THEN  CommandStart Y  2dup SetCaretPosition
        ELSE
            BeepEndCommandLine  BeepStartText  or IF  beep exitm  THEN
            StartAfterCommandLine
            IF  CommandEnd Y  ELSE  0 0  THEN
            false to increasing
        THEN
        Select: self ;M

:M CtrlShiftEnd: ( -- )   \ increase the selection to end of text
        Editing
        IF  BeepEditEnd IF  beep exitm  THEN  CommandEnd Y  2dup SetCaretPosition
        ELSE
            BeepStartCommandLine  BeepEndText  or IF  beep exitm  THEN
            StartBeforeCommandLine
            IF  CommandStart Y  ELSE  LastColRow: self  THEN
            true to increasing
        THEN
        Select: self ;M

:M ShiftUp: ( -- )   \ decrease the selection by one line
        Editing
        IF  BeepEditStart IF  beep exitm  THEN  CommandStart Y  2dup SetCaretPosition
        ELSE
            BeepEndCommandLine  BeepStartText  or IF  beep exitm  THEN
            SelStartCol SelEndRow 1- 0max RowLength min  SelEndRow 1-
            dup 0< IF  2drop 0 0  THEN
            StartAfterCommandLine SelEndRow 1- 0max Y = and
            IF  swap  CommandEnd max  swap  THEN
            StartAfterCommandLine SelEndRow Y = and IF  2drop CommandEnd Y  THEN
            false to increasing
        THEN
        Select: self ;M
 
:M ShiftDown: ( -- )   \ increase the selection by one line
        Editing
        IF  BeepEditEnd IF  beep exitm  THEN  CommandEnd Y  2dup SetCaretPosition
        ELSE
            BeepStartCommandLine  BeepEndText  or IF  beep exitm  THEN
            SelStartCol SelEndRow 1+ RowLength min  SelEndRow 1+
            2dup LastColRow: self d> IF  2drop  LastColRow: self  THEN
            StartBeforeCommandLine SelEndRow 1+ lines 1- min Y = and
            IF  swap  CommandStart min  swap  THEN
            StartBeforeCommandLine SelEndRow Y = and IF  2drop CommandStart Y  THEN
            true to increasing
        THEN
        Select: self ;M

:M CtrlRight: ( -- )   \ move the caret to the beginning of the next word
        XYAddress  dup CommandEnd X -  32 scan  32 skip  drop  swap -
        X +  X CommandEnd <  ?MoveCaretAndDeselect
        ;M

:M CtrlLeft: ( -- )   \ move the caret to the beginning of the previous word
        XYAddress 1-   dup X CommandStart -  32 -skip  32 -scan  drop -
        X swap -  X CommandStart >  ?MoveCaretAndDeselect
        ;M

:M CtrlShiftLeft: ( -- )   \ decrease the selection to the beginning of the previous word
        Editing
        IF
            BeepEditStart IF  beep exitm  THEN
            Y RowAddress SelEndCol + 1-  dup SelEndCol CommandStart -  32 -skip  32 -scan  drop swap -
            SelEndCol + to SelEndColNew  SelEndRow to SelEndRowNew
            SelEndColNew SelEndRowNew SetCaretPosition
        ELSE
            BeepStartText  BeepEndCommandLine  or IF  beep exitm  THEN
            SelEndCol
            IF  SelEndCol  SelEndRow
            ELSE  SelEndRow 1- RowLength  SelEndRow 1-
            THEN  to SelEndRowNew  to SelEndColNew
            SelEndRowNew RowAddress SelEndColNew + 1-  dup SelEndColNew  32 -skip  32 -scan  drop swap -
            +to SelEndColNew

            SelEndRow Y =  SelEndColNew CommandStart CommandEnd within and  SelEndCol ( 0= not ) and
            SelEndRow Y =  SelEndColNew CommandEnd <  and  SelEndCol CommandEnd >  and  or
            SelEndRow Y 1+ =  SelEndCol 0=  and  or
            IF  CommandEnd SelEndColNew max to SelEndColNew  THEN
            false to increasing
        THEN
        SelEndColNew SelEndRowNew Select: self
        ;M

:M CtrlShiftRight: ( -- )   \ increase the selection to the beginning of the next word
        Editing
        IF
            BeepEditEnd IF  beep exitm  THEN
            Y RowAddress SelEndCol +  dup CommandEnd SelEndCol -  32 scan  32 skip  drop  swap -
            SelEndCol + to SelEndColNew  SelEndRow to SelEndRowNew
            SelEndColNew SelEndRowNew SetCaretPosition
        ELSE
            BeepEndText  BeepStartCommandLine  or IF  beep exitm  THEN
            SelEndRow RowAddress SelEndCol +  dup SelEndRow Rowlength SelEndCol -  32 scan  32 skip  drop  swap -   \ next word          
            SelEndCol + to SelEndColNew  SelEndRow to SelEndRowNew

            SelEndRow Y =
            SelEndCol CommandStart <  SelEndColNew CommandStart >  and
            SelEndCol CommandEnd >  SelEndColNew CommandEnd <  and  or  and
            IF  SelEndColNew CommandStart min to SelEndColNew  THEN

            SelEndColNew SelEndRow RowLength >=  SelEndRow LastRow <> and IF  0 to SelEndColNew  1 +to SelEndRowNew  THEN
            true to increasing
        THEN
        SelEndColNew SelEndRowNew Select: self
        ;M

:M ShiftLeft: ( -- )   \ decrease the selection by one character  
        Editing
        IF  BeepEditStart IF  beep exitm  THEN  SelEndCol 1- SelEndRow  2dup SetCaretPosition
        ELSE
            BeepStartText  BeepEndCommandLine  or IF  beep exitm  THEN
            SelEndCol
            IF    SelEndCol 1- SelEndRow
            ELSE  SelEndRow 1- dup RowLength swap
            THEN  false to increasing
        THEN
        Select: self
        ;M

:M ShiftRight: ( -- )   \ increase the selection by one character
        Editing
        IF  BeepEditEnd IF  beep exitm  THEN  SelEndCol 1+ SelEndRow  2dup SetCaretPosition
        ELSE
            BeepStartCommandLine  BeepEndText  or IF  beep exitm  THEN
            SelEndCol SelEndRow RowLength <
            IF    SelEndCol 1+ SelEndRow
            ELSE  0 SelEndRow 1+
            THEN  true to increasing
        THEN
        Select: self
        ;M

:M SelectAll: ( -- )   \ up till the command line
        CommandStart Y   \ lines 1-
        2dup SelEndCol SelEndRow d=
        SelStartRow SelStartCol d0= and
        IF  2drop   \ if all is selected already
        ELSE  Deselect: self  0 0 ScrollAdjust SetStart  Select: self
        THEN ;M

:M HandleChar: ( c -- )
        Case
            7   of  beep endof
            8   of  DeleteBackward: self  endof
            9   of  9 emit: self  endof
            13  of  EndPrompt: self  endof
            22  of  Paste: self  endof
            1   of  SelectAll: self  endof
            3   of  Copy: self  endof
            24  of  Cut: self  endof
            27  of  DeleteCommand: self  InitHistory  endof
            127 of  DeleteForward: self  endof
            ( default )  dup dup 32 256 within IF  emit: self  ELSE  HandleKeys  THEN
        EndCase
        ;M

:M WM_CHAR ( h m w l -- res )
        over   \ if CTRL and Shift pressed add in shift bits
        VK_CONTROL call GetKeyState 32768 and IF  VK_SHIFT call GetKeyState 32768 and IF  0x80000 or  THEN  THEN
        LogKeyStrokes   \ deferred, ' menukey-more is LogKeyStrokes for KeySave
        KeysOn
        IF   HandleChar: self
        ELSE  dup 27 = IF  true to Abort?  THEN  PutKey: self
        THEN
        \ drop false to Abort?
        0 ;M

:M HandleKeyDown: ( n -- )
        CASE
            VK_HOME    of  0 0  ?shift IF  ?control IF  CtrlShiftHome: self  ELSE  ShiftHome: self  THEN  ELSE  ?control IF  2drop SB_TOP WM_HSCROLL     ELSE  Home: self  THEN THEN  endof
            VK_END     of  0 0  ?shift IF  ?control IF  CtrlShiftEnd: self   ELSE  ShiftEnd: self   THEN  ELSE  ?control IF  2drop SB_BOTTOM WM_HSCROLL  ELSE  End: self   THEN THEN  endof
            VK_INSERT  of  0 0 endof
            VK_DELETE  of  DeleteForward: self 0 0  endof
            VK_PRIOR   of  ?shift IF  SB_TOP  ELSE  SB_PAGEUP  THEN  WM_VSCROLL  endof
            VK_NEXT    of  ?shift IF  SB_BOTTOM  ELSE  SB_PAGEDOWN  THEN  WM_VSCROLL  endof
            VK_LEFT    of  ?Shift IF  ?control IF CtrlShiftLeft: self ELSE ShiftLeft: self THEN  ELSE  ?control IF CtrlLeft: self ELSE CaretLeft: self THEN  THEN  0 0  endof
            VK_RIGHT   of  ?Shift IF  ?control IF CtrlShiftRight: self ELSE ShiftRight: self THEN  ELSE  ?control IF CtrlRight: self ELSE CaretRight: self THEN  THEN  0 0  endof
            VK_UP      of  ?Shift IF  ShiftUp: self     ELSE  NextCommand 2dup CommandString compare IF  DeleteCommand: self  asciiz InsertTextOnCommandLine: self  ELSE  2drop beep  THEN  THEN  0 0  endof
            VK_DOWN    of  ?Shift IF  ShiftDown: self   ELSE  PrevCommand dup IF  DeleteCommand: self  asciiz InsertTextOnCommandLine: self  ELSE  NextCommand 4drop beep  THEN  THEN  0 0  endof
            ( default case) dup 0 rot
        ENDCASE
        ?dup IF  0 -rot hWnd send-window  ELSE  HandleKeyDown  THEN
        ;M

:M WM_KEYDOWN ( h m w l -- res ) \ 4
        drop  KeysOn IF  dup  HandleKeyDown: self  THEN
        Case   \ these are the codes specified in keyboard.cpp
            VK_F1      of  0x10001  endof
            VK_F2      of  0x10002  endof
            VK_F3      of  0x10003  endof
            VK_F4      of  0x10004  endof
            VK_F5      of  0x10005  endof
            VK_F6      of  0x10006  endof
            VK_F7      of  0x10007  endof
            VK_F8      of  0x10008  endof
            VK_F9      of  0x10009  endof
            VK_F10     of  0x10010  endof
            VK_F11     of  0x10011  endof
            VK_F12     of  0x10012  endof
            VK_HOME    of  0x20000  endof
            VK_END     of  0x20001  endof
            VK_INSERT  of  0x20002  endof
            VK_DELETE  of  0x20003  endof
            VK_LEFT    of  0x20004  endof
            VK_RIGHT   of  0x20005  endof
            VK_UP      of  0x20006  endof
            VK_DOWN    of  0x20007  endof
            VK_SCROLL  of  0x20008  endof
            VK_PAUSE   of  0x20009  endof
            VK_PRIOR   of  0x20010  endof
            VK_NEXT    of  0x20011  endof
            ( default )    0 swap
        EndCase
        dup
        IF  VK_CONTROL call GetKeyState 32768 and IF  0x40000 or  THEN
            VK_SHIFT   call GetKeyState 32768 and IF  0x80000 or  THEN
        THEN
        dup IF  LogKeyStrokes  KeysOn
                   IF   HandleKeys
                   ELSE drop
                   THEN
            ELSE drop
            THEN
        0 ;M

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Standard window methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:M ClassInit: ( -- )
        ClassInit: super
        sizeof(LPWinScrollInfo) to cbSize
        SIF_ALL to fMask
        sizeof(DRAWTEXTPARAMS) to dtSize
        8 to iTabLength
        1024 to MaxHistory
        $100000 to MaxText   \ max size of text buffer 1 MB
        0 to head
        -1 to wrap
        1 to CaretWidth
        13 to CaretHeight
        8 to HorzLine
        13 to VertLine
        0 to FirstRow
        0 to ScrollRangeHMax
        Black to ForegroundColour
        White to BackgroundColour
        ['] On_Click     SetClickFunc:    self
        ['] On_Unclick   SetUnClickFunc:  self
        ['] On_Track     SetTrackFunc:    self
        ['] On_DblClick  SetDblClickFunc: self
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: super
        WS_CLIPSIBLINGS or
        WS_HSCROLL or
        WS_VSCROLL or
        ;M

:M On_Size: ( h m w - h m w )
        WindowState: parent SIZE_MINIMIZED = IF  exitm  THEN
        ScrollPage GetClientRect: self
        UpdateVScroll: self
        UpdateHScroll: self
        UpdateFirstRow
        UpdateScrollPosRel
        ;M

:M On_Init: ( -- )
        new> WinDC to mDC
        UnLinkGdiObject
        0 Call CreateCompatibleDC PutHandle: mDC
        MaxText malloc to text
        cls: self
        new> font to CommandFont
        UnLinkGdiObject
        10 Height: CommandFont
        fw_bold ( FW_HEAVY ) Weight: CommandFont          \ Optional
        s" Courier" SetFaceName: CommandFont
\        s" Terminal" SetFaceName: CommandFont \ Optional choice
        CommandFont SetFont: self   \ this creates a caret in BigCursor: self
        DestroyCaret: self   \ no caret until command window gets the focus
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop
        WHITE_BRUSH Call GetStockObject GCL_HBRBACKGROUND hWnd Call SetClassLong drop
        ;M

:M On_Done: ( -- )
        GetHandle: mdc call DeleteDC drop
        mDC dispose
        delete: CommandFont
        CommandFont dispose
        Text release
        ;M

;Class
