\ $Id: Sudoku.f,v 1.11 2013/12/17 19:25:21 georgeahubert Exp $
\ Sudoku.f              Application to play and solve Sudoku puzzles.
\                       September 2005  Rod Oakford

cr .( Loading Sudoku...)

anew -Sudoku.f

Create SudokuVersion ," 1.4"
s" apps\Sudoku"     "fpath+
s" apps\Sudoku\res" "fpath+
: Sysgen ;   \ define for turnkey
Create ToolBarLayoutKey 256 allot

WinLibrary Winmm.dll
needs AcceleratorTables.f
needs RegistrySupport.f
needs SudokuMenu.f
needs SudokuStatusBar.f
needs SudokuToolbar.f
needs SudokuDialogs.f

0 value Printing
0 0 2value Papersize
0 value LeftMargin
0 value RightMargin
0 value TopMargin
0 value BottomMargin
0 value Resolution
0 value ScreenWidth
0 value ScreenHeight
0 value Maximizing
0 value Restoring
0 value NumberRecentFiles
0 value ShowNumber
0 value ShowWhileSizing
0 value Sizing
0 value BitCount
0 value ColourPlanes
0 value hBitmap
0 value CurrentCursor
0 value Error
0 value ShowSolution
0 value VisibleWarning
0 value AudibleWarning
0 value ShowElimination
0 value EditMode
: PlayError ( -- )   AudibleWarning
        IF  MB_ICONEXCLAMATION call MessageBeep drop  THEN ;
: PlayApplause ( -- )   ShowSolution ?exit
        SND_ASYNC SND_RESOURCE or
        AppInst
        153 call PlaySound drop ;
0 value FlatToolbar?
0 value WindowState
Create CurrentFile 256 allot
Create PreviousFile 256 allot
Create Directory 256 allot
0 value Modified
Windc mdc
60 value size
0 value x
0 value y
: position ( -- n )   x y 9 * + ;
: xy ( -- )   9 /mod to y to x ;
: Increase ( n -- )   position + 81 mod  9 /mod to y to x ;
: IncreaseX ( -- )   1  increase ;
: IncreaseY ( -- )   9  increase ;
: DecreaseX ( -- )   80 increase ;
: DecreaseY ( -- )   72 increase ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Font for digits \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Font SudokuFont
-40 value FontHeight
FontHeight Height: SudokuFont
0 Width: SudokuFont
700 Weight: SudokuFont
: ChangeFontSize ( n -- )   dup to FontHeight  Height: SudokuFont  Create: SudokuFont ;
: SetFontSize ( -- )   size 6 8 */ negate ChangeFontSize ;   \ set font size to a fixed fraction of cell size
: FactorFontSize ( ratio n1:n2 -- oldFontHeight )
        SudokuFont.lfHeight dup>r  swap */
        ChangeFontSize  r>
        ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Default colours for digits and background \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

1 value CurrentTextColour
0   0   0   rgb  new-color FixedColor
128 128 128 rgb  new-color TextColor1
0   240 240 rgb  new-color TextColor2
240 0   240 rgb  new-color TextColor3
240 240 0   rgb  new-color TextColor4
255 50  50  rgb  new-color WarningColor
255 255 255 rgb  new-color VariableBackgroundColor
220 240 230 rgb  new-color FixedBackgroundColor
20  20  230 rgb  new-color HighLightColor
255 255 220 rgb  new-color MarginColor
255 220 220 rgb  new-color EliminationColor


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Sudoku grid \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Create Numbers   \ solution, starting position, current position, colours
 z," 457293186198564732623781549249615873381927654765438921936872415572146398814359267"
+z," 400090080000500700623000040049000073000000000700000920030002415002006000010050007"
+z," 000000000000000000000000000000000000000000000000000000000000000000000000000000000"
+z," 000000000000000000000000000000000000000000000000000000000000000000000000000000000"
: SetColours ( -- )   81 0 DO  Numbers 81 + i + c@  '0' = IF  1  ELSE  0  THEN  Numbers 243 + i + c!  LOOP ;
Create TempNumbers 81 allot
: Start>Solution   numbers 81 + numbers 81 move ;
: Current>Solution   numbers 162 + numbers 81 move ;
: Solution>Current   numbers numbers 162 + 81 move ;
: Current>Temp   numbers 162 + TempNumbers 81 move ;
: Temp>Current   TempNumbers numbers 162 + 81 move ;
: Solution>Temp   numbers TempNumbers 81 move ;
: Temp>Solution   TempNumbers numbers 81 move ;
Create Eliminations 9 81 * allot
: ns   cr Numbers 81 type ;
: no   cr Numbers 81 + 81 type ;
: nc   cr Numbers 162 + 81 type ;
\ : cc   cr Numbers 243 + 81 type ;

Create Moves 512 allot   \ MoveNumber, redos, (n,p)...
: LastMove ( -- a )   Moves dup c@ 2* + ;
: GetLastMove ( -- n )   LastMove w@  256 /mod  9 /mod  to y to x ;
: SetLastMove ( x y n -- )   -rot  9 * +  256 * +  LastMove w! ;
: NumberFixed ( -- n )   0  81 0 DO  Numbers 81 + i + c@  49 58 within IF  1+  THEN  LOOP ;
: ShowMoves ( -- )   EditMode  moves c@ 0= or
        IF    s" Given numbers: " pad place  NumberFixed
        ELSE  s" Moves: " pad place  Moves c@
        THEN  (.) pad +place  pad 1  UpdatePart: SudokuStatusBar ;
: StoreMove ( x y n -- )   Moves cincr  SetLastMove  ShowMoves ;
: NoRedo ( -- )   0 Moves 1+ c! ;
: ZeroMoves ( -- )   0 Moves w!  ShowMoves ;

: Solved? ( -- )   numbers 162 + 81 48 scan nip 0=   \ no blanks?
        IF  IDM_CHECK_ALL DoCommand  error 0= ShowSolution 0= and IF  IDM_STOP DoCommand  THEN  THEN ;
: CellAddress ( x y -- a )   9 * + Numbers + ;
: GetNumber ( x y - n )   CellAddress 162 + c@ ;
: GetNumberP ( p -- n )   Numbers 162 + + c@ ;
: SetNumberP ( n p -- )   Numbers 162 + + c! ;
: SetNumber { n x y \ g - }   \ ShowSolution ?exit
        x y GetNumber  dup to g  n <>
        IF  n x y CellAddress 162 + c!  EditMode IF  n x y CellAddress 81 + c! THEN  x y g StoreMove  THEN ;
: GetColour ( x y -- c )   CellAddress 243 + c@ ;
: SetColour ( x y c -- )   -rot CellAddress 243 + c! ;
: WarningText ( x y )   true to error  VisibleWarning
        IF  2dup GetColour 128 or SetColour  c" Error in position" 1 UpdatePart: SudokuStatusBar
        ELSE  2drop
        THEN ;   \ warning colour
: RemoveWarningText ( x y )   2dup GetColour 127 and SetColour ;   \ normal text colour
: RemoveWarnings ( -- )   9 0 DO  9 0 DO  i j  RemoveWarningText  LOOP  LOOP ;

true value RemoveWarning
: Check ( -- )
        False to error
        x y GetNumber  dup '0' <>    \ current number in cell
        IF
            9 0 DO
                i y GetNumber  over =   \ row
                IF  x i <> IF  i y WarningText  x y WarningText  THEN
                ELSE  RemoveWarning IF  i y RemoveWarningText  THEN
                THEN
            LOOP
            9 0 DO
                x i GetNumber  over =   \ column
                IF  y i <> IF  x i WarningText  x y WarningText  THEN
                ELSE  RemoveWarning IF  x i RemoveWarningText  THEN
                THEN
            LOOP
            y 3 / 3 * 3 bounds DO
                x 3 / 3 * 3 bounds DO
                    i j GetNumber  over =   \ box
                    IF  i x =  j y =  and not IF  i j WarningText  x y WarningText  THEN
                    ELSE  RemoveWarning IF  i j RemoveWarningText  THEN
                    THEN
                LOOP
            LOOP
            Error IF  PlayError  THEN
        THEN
        drop ;

: NextSpace ( -- )   BEGIN  IncreaseX  x y GetNumber '0' =  x 0 = y 0 = and  or UNTIL ;
: PutNumber ( n -- )   \ Put number at current location in current text colour
        ShowSolution IF  drop  exit  THEN
        dup '0' = IF  RemoveWarnings  THEN
        EditMode
        IF
            dup '0' =
            IF    x y CurrentTextColour SetColour  x y SetNumber
            ELSE  x y 0 SetColour  x y SetNumber  true to Modified  0 to error  check  Error 0= IF  NextSpace  THEN
            THEN
        ELSE  x y GetColour ( 127 and )
            IF  x y CurrentTextColour SetColour  x y SetNumber  true to Modified  ELSE  drop  THEN
        THEN ;

: BlankWrongNumber ( -- )   Error VisibleWarning and IF  '0' PutNumber  THEN ;

: BlankAll ( -- )   Numbers 243 '0' fill  Numbers 243 + 81 1 fill ;   \ to make new game
: ClearAll ( -- )   81 0 DO  Numbers 81 + i + c@  dup  Numbers 162 + i + c!   \ to restart game
                       '0' = IF  1  ELSE  0  THEN  Numbers 243 + i + c!
                    LOOP ;

: SetEliminations ( -- )
        Eliminations 729 erase
        81 0 DO
            i Numbers 162 + + c@  dup 49 58 within
            IF
                49 - 81 * Eliminations +
                dup i 9 / 9 * + 9 bounds  DO  i cincr  LOOP   \ row
                dup i 9 mod + 81 bounds  DO  i cincr  9 +LOOP   \ column
                i 3 / 3 * dup 9 / 3 mod 9 * -  + 3 bounds  DO  i 27 bounds DO  i cincr  9 +LOOP  LOOP   \ box
            ELSE  drop
            THEN
        LOOP ;

: Eliminated? ( n p - f )  swap 49 - 81 * + Eliminations + c@ ;
: RemoveEliminations ( -- )   9 0 DO  9 0 DO  i j 2dup GetColour 64 invert and SetColour  LOOP  LOOP ;

: Eliminate ( -- )   \ shade background of blank squares where current number not possible
        RemoveEliminations
        SetEliminations
        CurrentCursor
        IF
        9 0 DO  9 0 DO
                 CurrentCursor 48 +  i j 9 * +  Eliminated?  i j GetNumber 48 = and
                 IF  i j 2dup GetColour 64 or  SetColour  THEN
        LOOP  LOOP
        THEN
        ;

: SolutionNeeded? ( -- f )   numbers 81 48 scan nip ;   \ false if full solution is present


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Brute force solver \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Try ( n p -- f )
        2dup Eliminated? IF  2drop false  exit  THEN
        >r 0   \ position saved on return stack, number and flag kept on stack
        r@ 9 / 9 *  numbers + 9  3 pick scan  nip or  dup IF  r> 3drop false exit  THEN   \ check row, exit on error
        r@ 9 mod  numbers +  81 bounds DO  over i c@ =  or  9 +LOOP   dup IF  r> 3drop false exit  THEN   \ check column
        r> 3 / 3 * dup 9 / 3 mod 9 * -  numbers +  3 bounds DO  i 27 bounds DO  over i c@ =  or  9 +LOOP  LOOP   \ check box
        nip 0= ;
0 value Counter
0 value FindNumber
10001 value MaxToFind
: Solve ( -- f )
    numbers 81 48 scan nip   \ any more spaces?
    IF
        81 0 DO        \ check all 81 numbers for '0'
            i numbers + c@ 48 =
            IF              \ space found
                58 49 DO
                    i j try       \ try fitting numbers in...
                    IF
                        i j numbers + c!   \ set number
                        recurse
                        IF
                            FindNumber  counter MaxToFind < and
                            IF  1 +to counter  48 j numbers + c!  \ ns
                            ELSE  unloop unloop true exit
                            THEN
                        ELSE  48 j numbers + c!    \ remove number
                        THEN
                    THEN
                LOOP
                false leave   \ none of 1-9 fit, false trail....
            THEN
        LOOP
    ELSE  true   \ no more spaces
    THEN ;

: tt ( -- )   SetEliminations current>solution time-reset solve .elapsed drop ;   \ test time taken to solve
: ct ( -- )   true to FindNumber  0 to counter SetEliminations current>solution
        time-reset solve cr .elapsed drop cr counter . false to FindNumber ;   \ find all solutions


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Timer routines \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value time
0 value TimerID

: ShowTime ( a n -- )
        pad place
        time 1000 /  0  \ 60 /mod
        <#  #  6 base !  #  10 base !  ':' hold  #s  #> pad +place
        s"  m:s" pad +place
        pad 0 UpdatePart: SudokuStatusBar
        ;
: TimeTaken ( -- )   s" Time taken to complete puzzle "  ShowTime ;
: TimeElapsed ( -- )   s" Time elapsed "  ShowTime ;
4 CallBack: TimerProc ( dwTime TimerID Msg hWnd -- 0 )   ms@ start-time - to time  TimeElapsed  4drop 0 ;
: SetTimer ( -- )   &TimerProc 1000 0 0 Call SetTimer to TimerID ;
: KillTimer ( -- )   TimerID 0 Call KillTimer drop ;
: StartTimer ( -- )   timer-reset  KillTimer  SetTimer  0 to time  TimeElapsed ;
: ResumeTimer ( -- )   ms@ time - to start-time  KillTimer  SetTimer ;
: PauseTimer ( -- )   ms@ start-time - to time  KillTimer ;
: StopTimer ( -- )   ms@ start-time - to time  KillTimer  TimeTaken ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ File handling \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

FileOpenDialog OpenDialog "" "Sudoku Files (*.sku)|*.sku|All Files (*.*)|*.*|"
FileSaveDialog SaveDialog "" "Sudoku Files (*.sku)|*.sku|All Files (*.*)|*.*|"

: ReadErrorMessage ( Filename$ -- )
        s" Unable to open " pad place  count pad +place  pad count asciiz
        z" Open File"  MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;

: WriteErrorMessage ( Filename$ -- )
        s" Unable to save " pad place  count pad +place  pad count asciiz
        z" Save File"  MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;

0 value FileHandle
0 value SaveFlag

: .sku ( Filename$ -- Filename$ )   dup count ".ext-only" nip 0= IF  dup s" .sku" rot +place  THEN ;
\ adds default .sku extension if none, will overwrite if file already exists

: OpenFile ( Filename$ -- f )   dup dup c@   \ true on success
        IF  count r/o open-file
            IF   drop  ReadErrorMessage  false      \ file does not exist
            ELSE  to FileHandle
                  CurrentFile Insert: RecentFiles
                  count CurrentFile place
                  CurrentFile count "path-only" Directory place
                  Numbers 324 FileHandle read-file 2drop
                  Moves 512 FileHandle read-file 2drop
                  true
            THEN  FileHandle close-file drop
        ELSE  2drop  false
        THEN ;

: SaveFile ( Filename$ -- )   dup dup c@
        IF  count r/w create-file
            IF   drop  WriteErrorMessage  false to SaveFlag      \ file does not exist
            ELSE  to FileHandle
                  count CurrentFile place
                  CurrentFile count "path-only" Directory place
                  Numbers 324 FileHandle write-file drop
                  Moves 512 FileHandle write-file Modified and to Modified
                  true to SaveFlag
            THEN  FileHandle close-file drop
        ELSE  2drop  false to SaveFlag
        THEN ;

: ?SaveMessage ( -- n )   \ IDYES, IDNO or IDCANCEL
        s" Do you want to save " pad place
        CurrentFile count ?dup
        IF  "to-pathend"
        ELSE  drop s" Untitled"
        THEN  pad +place
        s"  ?" pad +place  pad +NULL
        pad 1+ z" Sudoku"
        [ MB_ICONEXCLAMATION  MB_YESNOCANCEL or ] literal
        NULL MessageBox ;

: SaveIfModified ( -- f )   \ true if not cancelled or not modified
        True
        Modified
        IF
            ?SaveMessage
            Case
                IDCANCEL  Of          drop false  Endof
                IDYES     Of  IDM_SAVE DoCommand  drop SaveFlag Endof
                ( otherwise IDNO )  false to Modified
            EndCase
        THEN
        ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Define the Accelerator Table \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AcceleratorTable SudokuAccelerators


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Registry sets and words to save/restore recent files and remove all keys
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

PROGREG-SET-BASE-PATH   \ to put registry entries under current version of Win32Forth (e.g. Win32Forth 6.11.09)
Create RegPath$ max-path allot
ProgReg count RegPath$ place  s" Sudoku"  RegPath$ +place
RegPath$ count                                                   RegistrySet Sudoku
RegPath$ count pad place s" \Window" pad +place pad count        RegistrySet WindowSettings
RegPath$ count pad place s" \Options" pad +place pad count       RegistrySet Options
RegPath$ count pad place s" \Recent Files" pad +place pad count  RegistrySet RecentFilesList

((   \ to put registry entries under Win32Forth
s" Win32Forth\Sudoku"                RegistrySet Sudoku
s" Win32Forth\Sudoku\Window"         RegistrySet WindowSettings
s" Win32Forth\Sudoku\Options"        RegistrySet Options
s" Win32Forth\Sudoku\Recent Files"   RegistrySet RecentFilesList
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
        WindowSettings DeleteKey
        Options DeleteKey
        RecentFilesList DeleteKey
        Sudoku DeleteKey ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Main window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Frame   <Super Window

:M ChooseFont: ( -- )
        hWnd Choose: SudokuFont
        IF   SetFontSize redraw: [ self ]
        THEN ;M

:M ChooseColor: { ColorObject -- }
        Choose: ColorObject
        if   redraw: [ self ]
        then ;M

:M Classinit:   ( -- )
        ClassInit: super   \ init super class
        SudokuMenu to CurrentMenu
        ;M

:M WindowHasMenu: ( -- f )   true ;M

:M DefaultIcon: ( -- hIcon )   \ return the default icon handle for window
        101 appInst Call LoadIcon
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: SUPER
        WS_CLIPCHILDREN or
        ;M

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

:M MinSize: ( -- width height )   143  0  ;M

:M WindowTitle: ( -- z" )   z" Sudoku - Play or solve Sudoku puzzles" ;M

:M SetCaption: ( -- )
        s" Sudoku - [" pad place
        CurrentFile dup c@
        IF  count  "to-pathend"
        ELSE  s" new game"
        THEN  pad +place  s" ]" pad +place
        pad count SetText: self ;M

:M ExWindowStyle: ( -- exstyle )
        WS_EX_ACCEPTFILES
        ;M

:M WM_DROPFILES { hndl message wParam lParam -- res }
        SetForegroundWindow: self
        MAXCOUNTED temp$ 1+ 0 wParam Call DragQueryFile temp$ c!
        temp$ IDM_OPEN_FILE DoCommand
        wParam Call DragFinish
        ;M

:M WndClassStyle: ( -- style )   CS_DBLCLKS ;M   \ for newer versions of Win32Forth

:M On_Init: ( -- )
        On_Init: SUPER
\        CS_DBLCLKS GCL_STYLE hWnd Call SetClassLong drop   \ needed for older versions of Win32Forth
        101 appinst Call LoadIcon GCL_HICON hWnd Call SetClassLong drop
        0 GCL_HBRBACKGROUND hWnd Call SetClassLong drop
        0 Call CreateCompatibleDC PutHandle: mdc
        HORZRES GetHandle: mdc Call GetDeviceCaps to ScreenWidth
        VERTRES GetHandle: mdc Call GetDeviceCaps to ScreenHeight
        BITSPIXEL	GetHandle: dc Call GetDeviceCaps to BitCount
        PLANES GetHandle: dc Call GetDeviceCaps	to ColourPlanes

        0
        BITSPIXEL GetHandle: mdc Call GetDeviceCaps
        PLANES GetHandle: mdc Call GetDeviceCaps
        ScreenHeight ScreenWidth \ height width \ 600 800
        Call CreateBitmap to hBitmap
        hBitmap SelectObject: mdc drop

        self start: SudokuStatusBar
        StatusBarHeight IF  ShowStatusBar  THEN
        self start: SudokuToolbar
        ToolbarPopup SetPopupBar: self
        FlatToolbar? 0= to FlatToolbar? IDM_FLAT DoCommand
        ToolbarHeight IF  ShowToolbar  THEN
        ;M

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        over LOWORD ( command ID ) dup
        IsCommand? IF  DoCommand    \ intercept Toolbar and accelerator commands
        ELSE  drop OnWmCommand: Super    \ intercept Menu commands
        THEN
        ;M

:M WM_NOTIFY ( hwnd msg wparam lparam -- res )   Handle_Notify: SudokuToolbar ;M

:M On_Done: ( -- )
        WindowState SIZE_RESTORED = IF  WindowSettings SaveSettings  THEN
        Options SaveSettings
        Sudoku SaveSettings
        SaveRecentFiles
        ZeroMenu: CurrentMenu
        SudokuAccelerators DisableAccelerators   \ free the accelerator table
        KillTimer
        GetHandle: mdc call DeleteDC drop
        hBitmap DeleteObject: mdc
        Close: SudokuToolbar
        MenuHandle: ToolbarPopup call DestroyMenu drop
        Turnkeyed? IF  0 Call PostQuitMessage  THEN
        On_Done: super
        ;M

: DrawRectangle { l t w h \ r b -- }
        l w + to r
        t h + to b
        l t moveto: mdc
        r t lineto: mdc
        r b lineto: mdc
        l b lineto: mdc
        l t lineto: mdc
        ;

: Draw9 { l t -- }
        l 2 +  t 2 +  size 3 * 2 - dup  DrawRectangle   \ extra line on inside
        t 1+  size 3 *  bounds DO
            l 1+  size 3 *  bounds DO  i j size size DrawRectangle  size +LOOP
        size +LOOP ;

: Draw81 ( -- )
        Black LineColor: mdc
        LeftMargin  TopMargin  size 9 * 2 + dup  DrawRectangle   \ extra line on outside
        TopMargin size 9 * bounds DO
            LeftMargin size 9 * bounds DO  i j Draw9  size 3 * +LOOP
        size 3 * +LOOP
        ;

:M HighLight: { x y -- }
        Printing IF  exitm  THEN
        HighLightColor LineColor: mdc
        size x * 4 +  LeftMargin +
        size y * 4 +  TopMargin +
        size 6 - dup  DrawRectangle
        size 30 < IF  exitm  THEN
        size x * 5 +  LeftMargin +
        size y * 5 +  TopMargin +
        size 8 - dup  DrawRectangle
        size 40 < IF  exitm  THEN
        size x * 6 +  LeftMargin +
        size y * 6 +  TopMargin +
        size 10 - dup DrawRectangle
        size 60 < IF  exitm  THEN
        size x * 7 +  LeftMargin +
        size y * 7 +  TopMargin +
        size 12 - dup DrawRectangle
        ;M

:M FillSquare: { Color x y -- }
        size x *  1 + 1+ LeftMargin +
        size y *  1 + 1+ TopMargin +
        2dup size 1 -  size 1 - d+
        Color FillArea: mdc
        ;M

:M PlaceText: ( -- )
        9 0 DO
              9 0 DO
                      i j GetColour
                      dup dup 63 and
                      IF  64 and IF  EliminationColor  ELSE  VariableBackgroundColor  THEN
                      ELSE  drop FixedBackgroundColor
                      THEN  i j FillSquare: self

                      dup 128 and
                      IF  WarningColor
                      ELSE
                          63 and   \ ignore elimination
                          Case
                              0  of  FixedColor  Endof
                              1  of  TextColor1  EndOf
                              2  of  TextColor2  EndOf
                              4  of  TextColor3  EndOf
                              8  of  TextColor4  EndOf
                          ( default )  TextColor1 swap
                          Endcase
                      THEN  SetTextColor: mdc

                      size i *  1 +  LeftMargin +
                      size j *  1 +  TopMargin +
                      2dup  size 1+ size 1+ D+  SetRect: winRect
                      i j CellAddress 162 + c@ dup '0' = IF  drop 32  THEN  pad c!
                      pad 1 winRect DT_CENTER DT_VCENTER or DT_SINGLELINE or DT_NOCLIP or DrawText: mdc
              LOOP
        LOOP
        ;M

:M PrepareDC: ( -- )
        Handle: SudokuFont SetFont: mdc
        Transparent SetBkMode: mdc
        Printing not IF  0 0 ScreenWidth ScreenHeight MarginColor FillArea: mdc  THEN
        PlaceText: self
        x y HighLight: self
        Draw81
        ;M

:M On_Paint: ( -- )
        SRCCOPY 0 0 GetHandle: mdc
        Width Height StatusBarHeight - ToolbarHeight -
        0 ToolbarHeight BitBlt: dc
        ;M

:M Redraw: ( -- )
        PrepareDC: self
        0 ToolbarHeight Width Height StatusBarHeight - SetRect: winRect
        0 winRect InvalidateRect: self ;M

:M WM_CLOSE ( h m w l -- res )
        SaveIfModified
        IF
            CurrentFile Insert: RecentFiles
            WM_CLOSE WM: Super   \ close window
        ELSE  0                  \ abandon the close
        THEN
        ;M

: InSquares ( -- f )
        hWnd get-mouse-xy
        ToolbarHeight TopMargin +  Height BottomMargin - StatusBarHeight -  within
        swap  0 LeftMargin + width RightMargin - within  and
        ;

: SetCursor ( -- f )   \ true if new cursor is set
        CurrentCursor 142 + AppInst call LoadCursor dup ShowNumber and
        IF  call SetCursor drop  true  ELSE  drop false  THEN ;

:M SelectCursor: ( n -- )
        to CurrentCursor
        ShowElimination IF  eliminate redraw: self  THEN
        InSquares IF  SetCursor drop  THEN
        ;M

: IncreaseCursor ( -- )   InSquares
        IF  CurrentCursor 1 + 10 mod dup CheckNumber  SelectCursor: self  THEN ;
: DecreaseCursor ( -- )   InSquares
        IF  CurrentCursor 9 + 10 mod dup CheckNumber  SelectCursor: self  THEN ;

:M WM_MOUSEWHEEL ( h m w l -- res )   over word-split 32768 and
\ get the Key flags (loword of wParam) and the WHEEL_DELTA (hiword of wParam)
\ A positive value indicates that the wheel was rotated forward, away
\ from the user; a negative value indicates that the wheel was rotated
\ backward, toward the user.
        IF
            Case
                0           of  DecreaseCursor                          Endof
                MK_SHIFT    of  IDM_DOWN DoCommand                      Endof
                MK_CONTROL  of  IDM_RIGHT DoCommand                     Endof
            EndCase
        ELSE
            Case
                0           of  IncreaseCursor                          Endof
                MK_SHIFT    of  IDM_UP DoCommand                        Endof
                MK_CONTROL  of  IDM_LEFT DoCommand                      Endof
            EndCase
        THEN
        0 ;M

:M WM_SETCURSOR ( h m w l -- res )
        InSquares
        IF  SetCursor  0= IF  arrow-cursor  THEN  0
        ELSE  DefWindowProc: self
        THEN
        ;M

: get-xy ( n -- )   word-split
        2 - 1+  TopMargin - ToolbarHeight -  size /  0 max 8 min  to y
        2 - 1+  LeftMargin - size /  0 max 8 min  to x
        ;

:M WM_LBUTTONDOWN ( h m w l - res )
        BlankWrongNumber
        InSquares
        IF
            dup get-xy
            RemoveWarnings check Redraw: self
            x y GetColour dup 0 = over 128 = or
            IF  EditMode not IF  x y GetNumber 48 - dup SelectCursor: self  CheckNumber  THEN   \ pick up number if fixed
            ELSE  CurrentCursor 48 + dup  49 58 within
                IF  PutNumber check redraw: self Solved? NoRedo  ShowElimination IF  eliminate redraw: self  THEN  ELSE  drop  THEN
            THEN
        THEN
        0 ;M

:M WM_RBUTTONDOWN ( h m w l - res )
        BlankWrongNumber
        InSquares
        IF
            dup get-xy
            RemoveWarnings \ check Redraw: self
            x y GetColour dup 0 = over 128 = or
            IF  EditMode not IF  0 to CurrentCursor  0 CheckNumber  THEN  THEN  \ blank cursor if fixed
            '0' PutNumber check Redraw: self NoRedo
            ShowElimination IF  eliminate redraw: self  THEN
        THEN
        dup word-split nip  0 ToolbarHeight within
        IF  WM_RBUTTONDOWN WM: super   \ display context menu
        ELSE  0
        THEN ;M

: LeftM ( -- n )   rtMargin @ Resolution 1000 */ ;
: TopM ( -- n )   rtMargin 4 + @ Resolution 1000 */ ;
: RightM ( -- n )   rtMargin 8 + @ Resolution 1000 */ ;
: BottomM ( -- n )   rtMargin  12 + @ Resolution 1000 */ ;

:M Autosize: ( -- )   \ adjust window size to fit the game with a given size
        GetWindowRect: self 2drop
        size 9 * 11 +  LeftM + RightM +  size 9 * 11 + TopM + BottomM + 38 + ToolbarHeight + StatusBarHeight + move: self
        ;M

:M Resize: ( -- )   \ resize the game depending on margins and set font size
        width LeftM - RightM - 3 - 9 /
        height TopM - BottomM - StatusBarHeight - ToolbarHeight - 3 - 9 /  min
        1 max to size   \ largest size that will fit
        SetFontSize
        width LeftM - RightM - size 9 * - 3 - 2 /  dup LeftM + to LeftMargin  RightM + to RightMargin
        height TopM - BottomM - StatusBarHeight - ToolbarHeight - size 9 * - 3 - 2 /  dup TopM + to TopMargin  BottomM + to BottomMargin
        redraw: self
        0 CheckSize
        ;M

:M On_Size: ( h m w -- h m w )
        dup to WindowState
        Autosize: SudokuToolbar
        Redraw: SudokuStatusBar
        Maximizing  Restoring or  sizing not or  ShowWhileSizing or
        IF
            Resize: self
            False to Maximizing
            False to Restoring
        THEN
        ;M

:M WM_ENTERSIZEMOVE ( h m w l -- res)
        true to sizing
        0 ;M

:M WM_EXITSIZEMOVE ( h m w l -- res )   \ resize game only after window sizing finishes
        false to sizing
        Resize: self
        0 ;M

:M WM_SYSCOMMAND ( h m w l -- res )   \ determine whether Frame is being Maximized or Restored
        over 0xFFF0 and dup
        SC_MAXIMIZE = to Maximizing
        SC_RESTORE = to Restoring
        DefaultWindowProc ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Printing \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Needs SudokuPrinting.f


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Set commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ File Menu
: InitGame ( -- )   0 to x 0 to y  Redraw: Frame  IDM_PAUSE false CheckButton: SudokuToolbar
        ( ZeroMoves  IDM_ESCAPE DoCommand  ) false to EditMode  false check: hEdit  ShowMoves StartTimer
        ;
: ?Restart ( -- )
        SetCaption: Frame
        numbers 162 + 81 48 scan nip   \ blank squares?
        IF  InitGame
        ELSE
            z" This game is completed, do you want to restart it?"
            s" Sudoku - " pad place  CurrentFile count "to-pathend" pad +place  pad count asciiz
            MB_ICONEXCLAMATION MB_YESNO or  NULL  MessageBox
            IDYES = IF  IDM_RESTART DoCommand  ELSE  InitGame  THEN
        THEN ;

: New ( -- )   SaveIfModified  0= ?exit  0 to x 0 to y BlankAll Redraw: Frame
        CurrentFile Insert: RecentFiles
        CurrentFile off  SetCaption: Frame
        IDM_PAUSE false CheckButton: SudokuToolbar  ZeroMoves  StartTimer KillTimer
        false to EditMode IDM_TOGGLE_EDIT DoCommand ;   IDM_NEW SetCommand
: ?OpenFile ( FileName$ f -- )
        IF  OpenFile IF  ?Restart  THEN
        ELSE  drop
        THEN ;
: Open ( -- )   SaveIfModified  0= ?exit
        CurrentFile count OpenDialog place
        Frame @ Start: OpenDialog  dup c@ ?OpenFile ;   IDM_OPEN SetCommand
: SaveAs ( -- )
        CurrentFile count  2dup SaveDialog place  PreviousFile place
        Frame @ Start: SaveDialog dup c@
        IF  .sku SaveFile SaveFlag IF  SetCaption: Frame  PreviousFile Insert: RecentFiles  ELSE  drop  THEN
        ELSE  drop  false to SaveFlag
        THEN ;    IDM_SAVE_AS SetCommand
warning @ warning off
: Save ( -- )
        CurrentFile c@  IF  CurrentFile SaveFile  ELSE  SaveAs  THEN ;   IDM_SAVE SetCommand
warning !
: ImportGame ( -- )   SaveIfModified  0= ?exit
        Frame start: ImportDialog
        IF
            Solution ?dup IF  Numbers 81 move  THEN   \ if a full solution just add to current file
            Start ?dup IF  Numbers 81 + 81 move  CurrentFile Insert: RecentFiles  CurrentFile off  ClearAll  SetCaption: Frame  InitGame  true to Modified  THEN
        THEN ;   IDM_IMPORT SetCommand
: OpenRecentFile ( FileName$ -- )   SaveIfModified  ?OpenFile ;   IDM_OPEN_FILE SetCommand
: DoExit ( -- )   0 0 WM_CLOSE GetHandle: Frame send-window ;   IDM_EXIT SetCommand

\ View Menu
: Size1 ( -- )   SW_RESTORE show: Frame  30 to size  autosize: Frame  1 CheckSize ;   IDM_SIZE_1 SetCommand
: Size2 ( -- )   SW_RESTORE show: Frame  40 to size  autosize: Frame  2 CheckSize ;   IDM_SIZE_2 SetCommand
: Size3 ( -- )   SW_RESTORE show: Frame  60 to size  autosize: Frame  3 CheckSize ;   IDM_SIZE_3 SetCommand
: Size4 ( -- )   SW_RESTORE show: Frame  75 to size  autosize: Frame  4 CheckSize ;   IDM_SIZE_4 SetCommand
: CursorNumber ( -- )   ShowNumber 0= dup to ShowNumber Check: hCursor ;   IDM_CURSOR_NUMBER SetCommand
: ShowSizing ( -- )   ShowWhileSizing 0= dup to ShowWhileSizing Check: hSizing ;   IDM_SHOW_SIZING SetCommand
: ToggleStatusBar ( -- )
        StatusBarHeight IF  HideStatusBar  ELSE  ShowStatusBar  THEN
        Resize: Frame ;   IDM_TOGGLE_STATUSBAR SetCommand
: ToggleToolbar ( -- )
        ToolbarHeight IF  HideToolbar  ELSE  ShowToolbar  THEN
        Resize: Frame ;   IDM_TOGGLE_TOOLBAR SetCommand
: OnFont ( -- )   ChooseFont: Frame ;   IDM_FONT SetCommand

: TextColour1 ( -- )    TextColor1 ChooseColor: frame ;    IDM_TEXT_COLOUR_1 SetCommand
: TextColour2 ( -- )    TextColor2 ChooseColor: frame ;    IDM_TEXT_COLOUR_2 SetCommand
: TextColour3 ( -- )    TextColor3 ChooseColor: frame ;    IDM_TEXT_COLOUR_3 SetCommand
: TextColour4 ( -- )    TextColor4 ChooseColor: frame ;    IDM_TEXT_COLOUR_4 SetCommand
: FixedColour ( -- )    FixedColor ChooseColor: frame ;    IDM_FIXED_COLOUR SetCommand
: WarningColour ( -- )          WarningColor ChooseColor: frame ;    IDM_WARNING_COLOUR SetCommand
: VariableBackgroundColour ( -- )   VariableBackgroundColor ChooseColor: frame ;   IDM_VARIABLE_BACKGROUND_COLOUR SetCommand
: FixedBackgroundColour ( -- )  FixedBackgroundColor ChooseColor: frame ;    IDM_FIXED_BACKGROUND_COLOUR SetCommand
: HighLightColour ( -- )        HighLightColor ChooseColor: frame ;    IDM_HIGHLIGHT_COLOUR SetCommand
: MarginColour ( -- )           MarginColor ChooseColor: frame ;    IDM_MARGIN_COLOUR SetCommand
: EliminationColour ( -- )      EliminationColor ChooseColor: frame ;    IDM_ELIMINATION_COLOUR SetCommand

\ Game Menu
: StartEdit ( -- )
        ShowSolution IF  IDM_SOLUTION DoCommand  THEN
        SaveIfModified  0= ?exit
        ClearAll  IDM_CHECK_ALL DoCommand  ShowElimination IF eliminate THEN  Redraw: Frame
        true to EditMode  true check: hEdit
        PauseTimer   \ StartTimer KillTimer
        c" Edit mode (escape to finish) " 0 UpdatePart: SudokuStatusBar
        0 Moves w!  ShowMoves ;   IDM_START_EDIT SetCommand
: FinishEdit ( -- )
        false to EditMode  false check: hEdit  c" Play mode " 0 UpdatePart: SudokuStatusBar
        ClearAll  InitGame  ZeroMoves
        ShowElimination IF eliminate THEN  Redraw: frame
        ;
: Escape ( -- )
        ShowSolution
        IF  IDM_SOLUTION DoCommand
        ELSE  EditMode IF  FinishEdit  THEN
        THEN ;   IDM_ESCAPE SetCommand
: ToggleEdit ( -- )   EditMode IF  FinishEdit  ELSE  StartEdit  THEN ;   IDM_TOGGLE_EDIT SetCommand
: UndoMove ( -- )
          Moves c@
          IF
              GetLastMove
              Moves cdecr
              PutNumber  check  redraw: frame
              Moves cdecr
              Moves 1+ cincr   \ increase number of redos possible
              ShowMoves
          THEN ;   IDM_BACKWARD SetCommand
: RedoMove ( -- )
          Moves 1+ c@
          IF
              Moves cincr
              GetLastMove
              Moves cdecr
              PutNumber  check  redraw: frame
              Moves 1+ cdecr   \ decrease number of redos possible
              ShowMoves
          THEN ;   IDM_FORWARD SetCommand
: Restart ( -- )   SaveIfModified  0= ?exit
       ClearAll  ShowElimination IF eliminate THEN  InitGame  ZeroMoves ;   IDM_RESTART SetCommand
: CheckAll ( -- )
       0 to error
       VisibleWarning  AudibleWarning
       true to VisibleWarning  true to AudibleWarning
       false to RemoveWarning
       x y
       9 0 DO  9 0 DO  i to x  j to y  Check  LOOP  LOOP
       to y to x  Redraw: frame
       true to RemoveWarning
       to AudibleWarning  to VisibleWarning
       error IF  c" Error in current position"  1  UpdatePart: SudokuStatusBar  false  THEN
       ;   IDM_CHECK_ALL SetCommand
: SolveCurrentPosition ( -- f )   \ true on success
        CheckAll error 0=
        IF
            Current>solution
            SetEliminations
            ms@  Solve  ms@ rot -  swap
            IF  s" Time taken to solve: " pad place  (.) pad +place  s"  milliseconds" pad +place
                  pad  0 UpdatePart: SudokuStatusBar  true
            ELSE  drop  c" Unable to find a solution with current position (try restart)"  1  UpdatePart: SudokuStatusBar  false
            THEN
        THEN ;
: Hint ( -- )   SolutionNeeded? IF  SolveCurrentPosition  ELSE  true  THEN
      IF  x y CellAddress c@ PutNumber  NextSpace  Redraw: Frame    THEN ;   IDM_HINT SetCommand
: SeeSolution ( -- )   \ toggle
      ShowSolution
      IF  Temp>Current  CheckAll ShowMoves  ShowElimination IF eliminate THEN
          EditMode
          IF  c" Edit mode (escape to finish) " 0 UpdatePart: SudokuStatusBar
          ELSE  ResumeTimer
          THEN
          Redraw: frame
          false to ShowSolution false check: hSolution
      ELSE
          SolveCurrentPosition
          IF
              Current>Temp  Solution>Current RemoveWarnings  CheckAll Eliminate redraw: frame
              PauseTimer c" Solution found (escape to continue)"  1  UpdatePart: SudokuStatusBar
              true to ShowSolution true check: hSolution
          THEN
      THEN ;  IDM_SOLUTION SetCommand
: FindSolutions ( -- )
        solution>temp
        s"  Looking for solutions..." pad place pad 1  UpdatePart: SudokuStatusBar
        true to FindNumber  0 to counter SetEliminations current>solution
        ms@  Solve  ( ms@ rot -  swap ) drop  false to FindNumber
        Counter MaxToFind = IF  s" More than " pad place  -1 +to counter  ELSE  0 pad c!  THEN
        counter (.) pad +place  s"  solutions found" pad +place
        pad 1  UpdatePart: SudokuStatusBar
        temp>solution ;   IDM_NUMBER_SOLUTIONS SetCommand
: Visible ( -- )   VisibleWarning
        IF  false to VisibleWarning  false check: hVisible  RemoveWarnings
        ELSE   true to VisibleWarning  true check: hVisible  check
        THEN  Redraw: Frame ;   IDM_TOGGLE_VISIBLE SetCommand
: Audible ( -- )   AudibleWarning
        IF  false to AudibleWarning  false check: hAudible
        ELSE   true to AudibleWarning  true check: hAudible
        THEN ;   IDM_TOGGLE_AUDIBLE SetCommand
: ShowEliminations ( -- )   \ toggle
        ShowElimination
        IF  RemoveEliminations  false false
        ELSE  eliminate  true true
        THEN  to ShowElimination  Check: hEliminate  redraw: frame ;   IDM_ELIMINATION SetCommand

\ Help menu \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
: Help ( -- )   Frame start: SudokuHelp drop ;   IDM_HELP SetCommand
: About ( -- )   Frame start: AboutSudoku drop ;   IDM_ABOUT SetCommand
: UninstallMessage ( -- n )   \ IDYES or IDNO
        s" Do you want to remove all Sudoku registry settings?" pad place
        s" \nYes will quit this application and all settings will be lost." pad +place
        pad +null
        pad 1+ z" Sudoku"  MB_ICONEXCLAMATION MB_YESNO or  NULL  MessageBox ;
: Uninstall ( -- )   UninstallMessage  IDYES = IF
        WindowSettings SaveSettings  SaveRecentFiles  RemoveRegKeys  bye  THEN ;   IDM_UNINSTALL SetCommand
\ : RestoreOptions ( -- )   Options RestoreSettings ;                 IDM_RESTORE_SETTINGS SetCommand
\ : SaveOptions ( -- )   Options SaveSettings ;                       IDM_SAVE_SETTINGS SetCommand
\ : DefaultOptions ( -- )   Options DefaultSettings ;                 IDM_DEFAULT_SETTINGS SetCommand

\ Miscellaneous
: Left ( -- )   BlankWrongNumber
        DecreaseX  RemoveWarnings check Redraw: Frame ;    IDM_LEFT SetCommand
: Right ( -- )   BlankWrongNumber
        IncreaseX  RemoveWarnings check Redraw: Frame ;   IDM_RIGHT SetCommand
: Up ( -- )   BlankWrongNumber
        DecreaseY  RemoveWarnings check Redraw: Frame ;      IDM_UP SetCommand
: Down ( -- )   BlankWrongNumber
        IncreaseY  RemoveWarnings check Redraw: Frame ;    IDM_DOWN SetCommand
: Select ( n -- )   dup CheckNumber SelectCursor: frame ;
: Select1 ( -- )   1 select ;       IDM_SELECT_1 SetCommand
: Select2 ( -- )   2 select ;       IDM_SELECT_2 SetCommand
: Select3 ( -- )   3 select ;       IDM_SELECT_3 SetCommand
: Select4 ( -- )   4 select ;       IDM_SELECT_4 SetCommand
: Select5 ( -- )   5 select ;       IDM_SELECT_5 SetCommand
: Select6 ( -- )   6 select ;       IDM_SELECT_6 SetCommand
: Select7 ( -- )   7 select ;       IDM_SELECT_7 SetCommand
: Select8 ( -- )   8 select ;       IDM_SELECT_8 SetCommand
: Select9 ( -- )   9 select ;       IDM_SELECT_9 SetCommand
: SelectBlank ( -- )   0 select ;  IDM_SELECT_BLANK SetCommand
: KeyDown ( n -- )   dup select  48 + PutNumber  check  Redraw: Frame  Solved?  NoRedo ;
: Key1 ( -- )   1 KeyDown ;   IDM_KEY_1 SetCommand
: Key2 ( -- )   2 KeyDown ;   IDM_KEY_2 SetCommand
: Key3 ( -- )   3 KeyDown ;   IDM_KEY_3 SetCommand
: Key4 ( -- )   4 KeyDown ;   IDM_KEY_4 SetCommand
: Key5 ( -- )   5 KeyDown ;   IDM_KEY_5 SetCommand
: Key6 ( -- )   6 KeyDown ;   IDM_KEY_6 SetCommand
: Key7 ( -- )   7 KeyDown ;   IDM_KEY_7 SetCommand
: Key8 ( -- )   8 KeyDown ;   IDM_KEY_8 SetCommand
: Key9 ( -- )   9 KeyDown ;   IDM_KEY_9 SetCommand
: Delete ( -- ) SelectBlank  '0' PutNumber check Redraw: Frame    NoRedo ;   IDM_DELETE SetCommand
: SizePlus ( -- )   SW_RESTORE show: Frame  size 5 + 100 min to size  autosize: Frame  0 CheckSize ;   IDM_PLUS SetCommand
: SizeMinus ( -- )   SW_RESTORE show: Frame  size 5 - 30 max to size  autosize: Frame  0 CheckSize ;   IDM_MINUS SetCommand
: Pause/Resume ( -- )   IDM_PAUSE IsButtonChecked: SudokuToolbar
        IF  PauseTimer  ELSE  ResumeTimer  THEN ;   IDM_PAUSE SetCommand
: Stop ( -- )   PlayApplause  StopTimer ;   IDM_STOP SetCommand
: UpdateColour ( n -- )   to CurrentTextColour  x y GetColour 127 and
        IF  x y CurrentTextColour SetColour  Redraw: Frame  THEN ;
: Colour1 ( -- )   1 UpdateColour ;   IDM_COLOUR_1 SetCommand
: Colour2 ( -- )   2 UpdateColour ;   IDM_COLOUR_2 SetCommand
: Colour3 ( -- )   4 UpdateColour ;   IDM_COLOUR_3 SetCommand
: Colour4 ( -- )   8 UpdateColour ;   IDM_COLOUR_4 SetCommand
: SaveToolbar   true SaveRestore: SudokuToolbar ;                IDM_SAVE_TOOLBAR SetCommand
: RestoreToolbar   false SaveRestore: SudokuToolbar ;         IDM_RESTORE_TOOLBAR SetCommand
: DefaultToolbar   false SaveRestoreDefault: SudokuToolbar ;  IDM_DEFAULT_TOOLBAR SetCommand
: FlatToolbar ( -- )   FlatToolbar?
        IF
            false check: hFlat false to FlatToolbar?
            TBSTYLE_FLAT -Style: SudokuToolbar
        ELSE
            true check: hFlat true to FlatToolbar?
            TBSTYLE_FLAT +Style: SudokuToolbar
        THEN  paint: SudokuToolbar ;                                     IDM_FLAT SetCommand


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Registry settings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WindowSettings entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
&of: Frame.Width ( 4 )     539              REG_DWORD     RegEntry  "WindowWidth"
&of: Frame.Height          429              REG_DWORD     RegEntry  "WindowHeight"
&of: Frame.OriginX         135              REG_DWORD     RegEntry  "WindowLeft"
&of: Frame.OriginY         66               REG_DWORD     RegEntry  "WindowTop"
EndEntries

Options entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
' FlatToolbar? 4 +         false            REG_DWORD     RegEntry  "Flat Toolbar"
' ToolbarHeight 4 +        28               REG_DWORD     RegEntry  "ToolbarHeight"
' StatusBarHeight 4 +      20               REG_DWORD     RegEntry  "StatusBarHeight"
' ShowNumber 4 +           true             REG_DWORD     RegEntry  "ShowNumber"
' ShowWhileSizing 4 +      0                REG_DWORD     RegEntry  "ShowWhileSizing"
' ShowElimination 4 +      0                REG_DWORD     RegEntry  "ShowEliminations"
' WindowState 4 +          SIZE_RESTORED    REG_DWORD     RegEntry  "Window State"
Directory 256              0 0              REG_SZ        RegEntry  "Directory"
' Size 4 +                 0                REG_DWORD     RegEntry  "CellSize"
' VisibleWarning 4 +       true             REG_DWORD     RegEntry  "VisibleWarning"
' AudibleWarning 4 +       true             REG_DWORD     RegEntry  "AudibleWarning"
' NumberRecentFiles 4 +    6                REG_DWORD     RegEntry  "Files"
rtMargin                   100              REG_DWORD     RegEntry  "MarginLeft"
rtMargin 4 +               100              REG_DWORD     RegEntry  "MarginTop"
rtMargin 8 +               100              REG_DWORD     RegEntry  "MarginRight"
rtMargin 12 +              100              REG_DWORD     RegEntry  "MarginBottom"
' CurrentTextColour 4 +    1                REG_DWORD     RegEntry  "CurrentTextColour"
CustomColors: FixedColor   2dup             REG_BINARY    RegEntry  "CustomColors"
FixedColor                 dup @            REG_DWORD     RegEntry  "FixedColour"
TextColor1                 dup @            REG_DWORD     RegEntry  "TextColour1"
TextColor2                 dup @            REG_DWORD     RegEntry  "TextColour2"
TextColor3                 dup @            REG_DWORD     RegEntry  "TextColour3"
TextColor4                 dup @            REG_DWORD     RegEntry  "TextColour4"
VariableBackgroundColor    dup @            REG_DWORD     RegEntry  "VariableBackgroundColour"
FixedBackgroundColor       dup @            REG_DWORD     RegEntry  "FixedBackgroundColour"
HighLightColor             dup @            REG_DWORD     RegEntry  "HighLightColour"
MarginColor                dup @            REG_DWORD     RegEntry  "MarginColour"
SudokuFont 4 + 60          2dup             REG_BINARY    RegEntry  "SudokuFont"
EndEntries

Sudoku entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
SudokuVersion    20        0 0              REG_SZ        RegEntry  "" ( default )
EndEntries


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Accelerator Table Entries \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

SudokuAccelerators table
\   Flags            Key Code      Command ID

\ File menu
    FCONTROL         'N'           IDM_NEW                 AccelEntry
    FCONTROL         'O'           IDM_OPEN                AccelEntry
    FCONTROL         'P'           IDM_PRINT               AccelEntry
    FCONTROL         'I'           IDM_IMPORT              AccelEntry

\ View menu
    FCONTROL         '1'           IDM_SIZE_1              AccelEntry
    FCONTROL         '2'           IDM_SIZE_2              AccelEntry
    FCONTROL         '3'           IDM_SIZE_3              AccelEntry
    FCONTROL         '4'           IDM_SIZE_4              AccelEntry
    FCONTROL         'F'           IDM_FONT                AccelEntry

\ Game menu
    FCONTROL         VK_RIGHT      IDM_FORWARD             AccelEntry
    FCONTROL         VK_LEFT       IDM_BACKWARD            AccelEntry
\    FCONTROL         'E'           IDM_START_EDIT          AccelEntry
    0                VK_ESCAPE     IDM_ESCAPE              AccelEntry
    FCONTROL         'R'           IDM_RESTART             AccelEntry
    FCONTROL         'E'           IDM_ELIMINATION         AccelEntry
    FCONTROL         'H'           IDM_HINT                AccelEntry
    FCONTROL         'S'           IDM_SOLUTION            AccelEntry
    FCONTROL         'C'           IDM_CHECK_ALL           AccelEntry

\ Help menu
    0                VK_F1         IDM_HELP                AccelEntry

\ Miscellaneous
    0                VK_LEFT       IDM_LEFT                AccelEntry
    0                VK_RIGHT      IDM_RIGHT               AccelEntry
    0                VK_UP         IDM_UP                  AccelEntry
    0                VK_DOWN       IDM_DOWN                AccelEntry
    0                VK_DELETE     IDM_DELETE              AccelEntry
    0                '1'           IDM_KEY_1               AccelEntry
    0                '2'           IDM_KEY_2               AccelEntry
    0                '3'           IDM_KEY_3               AccelEntry
    0                '4'           IDM_KEY_4               AccelEntry
    0                '5'           IDM_KEY_5               AccelEntry
    0                '6'           IDM_KEY_6               AccelEntry
    0                '7'           IDM_KEY_7               AccelEntry
    0                '8'           IDM_KEY_8               AccelEntry
    0                '9'           IDM_KEY_9               AccelEntry
    0                '1'           IDM_KEY_1               AccelEntry
    0                VK_NUMPAD1    IDM_KEY_1               AccelEntry
    0                VK_NUMPAD2    IDM_KEY_2               AccelEntry
    0                VK_NUMPAD3    IDM_KEY_3               AccelEntry
    0                VK_NUMPAD4    IDM_KEY_4               AccelEntry
    0                VK_NUMPAD5    IDM_KEY_5               AccelEntry
    0                VK_NUMPAD6    IDM_KEY_6               AccelEntry
    0                VK_NUMPAD7    IDM_KEY_7               AccelEntry
    0                VK_NUMPAD8    IDM_KEY_8               AccelEntry
    0                VK_NUMPAD9    IDM_KEY_9               AccelEntry
    0                VK_DECIMAL    IDM_DELETE              AccelEntry
    0                VK_ADD        IDM_PLUS                AccelEntry
    0                VK_SUBTRACT   IDM_MINUS               AccelEntry

Frame HandlesThem


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Opening files from the command line
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 0 2value Arg
0 0 2value Arg-pos

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

: Arg-1 ( -- a1 n1 )   CmdLine NextArg ;   \ first argument

: OpenCommandLine ( -- )                   \ open first file on the command line
        Arg-1  pad place  pad c@
        IF  pad IDM_OPEN_FILE DoCommand
        ELSE  1 GetRecentFile: RecentFiles  dup c@ IF  OpenRecentFile  ELSE  drop Restart  THEN
        THEN ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Turnkey without needing w32fConsole.dll \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Main ( -- )
        96 to Resolution   \ needs to be adjusted to make print size same as screen size
        DefaultPrinter
        Paper-size Resolution 254 */ swap
        Resolution 254 */ swap to PaperSize   \ get paper size of default printer
        WindowSettings RestoreSettings
        Options RestoreSettings
        Color: VariableBackgroundColor VariableBackgroundColor off NewColor: VariableBackgroundColor
        Color: FixedBackgroundColor FixedBackgroundColor off NewColor: FixedBackgroundColor
        Color: HighLightColor HighLightColor off NewColor: HighLightColor
        Color: MarginColor MarginColor off NewColor: MarginColor
        Start: Frame
        Colour1
        RestoreRecentFiles
        VisibleWarning check: hVisible
        AudibleWarning check: hAudible
        ShowWhileSizing check: hSizing
        ShowNumber check: hCursor
        ShowElimination check: hEliminate
        Directory count 2dup SetDir: OpenDialog SetDir: SaveDialog
        NumberRecentFiles SetNumber: RecentFiles
        Turnkeyed? IF  SudokuAccelerators EnableAccelerators  OpenCommandLine THEN
        ;

[defined] sysgen [IF]
          &forthdir count &appdir place   \ make turnkey in Win32Forth folder
          ' Main turnkey Sudoku.exe
          Needs SudokuResources
          Require Checksum.f
          s" Sudoku.exe" prepend<home>\ (AddCheckSum)
          1 pause-seconds  bye
  [ELSE]  Main
  [THEN]
