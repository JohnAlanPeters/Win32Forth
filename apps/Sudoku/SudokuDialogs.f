\ $Id: SudokuDialogs.f,v 1.2 2006/08/03 20:37:27 rodoakford Exp $
\ SudokuDialogs.f       Dialogs for Sudoku contained in SudokuDialog.res
\                       AboutSudoku - the about dialog
\                       SudokuHelp - the help screen
\                       ImportDialog - for importing numbers into the game
\                       September 2005  Rod Oakford

cr .( Loading Dialogs...)

s" apps\Sudoku\res" "fpath+

Create ImportNumbers 256 allot
0 value start
0 value solution
Font ImportFont
-13 Height: ImportFont
0 Width: ImportFont

\- SudokuVersion   Create SudokuVersion ," 1.0"

FileOpenDialog OpenText "" "Text Files (*.txt)|*.txt|All Files (*.*)|*.*|"
0 value hFile

load-dialog SudokuDialog   \ needs SudokuDialog.res, SudokuDialog.h


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ About box \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object AboutSudoku   <Super dialog

:M GetTemplate: ( -- a )   IDD_ABOUTBOX SudokuDialog find-dialog-id  ;M

:M On_Init: ( -- )
        s" Sudoku version " pad place  SudokuVersion count pad +place  pad count IDC_VERSION SetDlgItemText: self
        ;M

;Object

: SA   conhndl start: AboutSudoku drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Help box \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Create HelpText
         Z," Numbers can be placed on the grid via the keyboard using the arrow keys to select the current square."
        +Z,"  Easier is to use the mouse to select the current number from the toolbar and left click on a square"
        +Z,"  to place it.  Right click will remove the number.  The current number can also be changed using the"
        +Z,"  wheel on the mouse or selected by clicking on one of the fixed numbers.  Moves can be undone and"
        +Z,"  redone using the buttons on the toolbar or from the game menu.\n\nShortcut keys:"

Create Keys
         Z," Keys\n\nCtrl + N\n\nCtrl + O\n\nCtrl + P\n\nCtrl + I\n\n"
        +Z," Ctrl + 1\n\nCtrl + 2\n\nCtrl + 3\n\nCtrl + 4\n\nCtrl + F\n\n"
        +Z," Ctrl + <-\n\nCtrl + ->\n\nCtrl + R\n\nCtrl + H\n\n"
        +Z," Ctrl + C\n\nCtrl + S\n\nCtrl + E"

Create Actions
         Z," Action\n\nstart a new (blank) game, fill in your own starting numbers"
        +Z," \n\nopen a sudoku file (.sku)"
        +Z," \n\nprint the current position (use Page Setup to set margins for both printer and screen)"
        +Z," \n\nimport text to make a new game"
        +Z," \n\nmake the window one of 4 fixed sizes"
        +Z," \n\n(the window can be dragged to any size)"
        +Z," \n\n"
        +Z," \n\n"
        +Z," \n\nchange the font for the digits"
        +Z," \n\nundo last move"
        +Z," \n\nredo last move"
        +Z," \n\nrestart the game"
        +Z," \n\nreveal the number in the current square (provided a solution can be found)"
        +Z," \n\ncheck the current position for errors"
        +Z," \n\nshow the full solution for the current position (if possible)"
        +Z," \n\nshade squares not possible for the current number"

:Object SudokuHelp   <Super dialog

:M GetTemplate: ( -- a )   IDD_HELP SudokuDialog find-dialog-id  ;M

:M On_Init: ( -- )
        HelpText IDC_HELP_TEXT hWnd Call SetDlgItemText drop
        Keys IDC_KEYS hWnd Call SetDlgItemText drop
        Actions IDC_ACTIONS hWnd Call SetDlgItemText drop
        ;M

;Object

: SH   conhndl start: SudokuHelp drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Import Dialog \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Create ImportText
         Z," Copy and paste a Sudoku board into this box. It can be all in one line,
        +Z,"  or in a 9 by 9 box.  The Importer will ignore spaces and read the numbers
        +Z,"  in order.  The characters 0, '.', ?,'_' or * will be interpreted as blanks
        +Z,"  in the game.  Alternatively open a text file to import."

:Object ImportDialog   <Super Dialog

:M GetTemplate: ( -- a )   IDD_IMPORT SudokuDialog find-dialog-id  ;M

:M On_Init: ( -- )
        ImportText IDC_IMPORT_TEXT hWnd Call SetDlgItemText drop
        ImportNumbers 256 erase
        Create: ImportFont
        Handle: ImportFont IDC_SUDOKU_EDIT SetDlgItemFont: self
        ;M

: Blank? ( c -- f )
        Case
            '.'  of  true  endof
            '?'  of  true  endof
            '*'  of  true  endof
            '0'  of  true  endof
            '_'  of  true  endof
            ( default ) false swap
        EndCase
        ;

: CollectNumbers ( -- )
        pad 512 IDC_SUDOKU_EDIT GetDlgItemText: self   \ 889 seems to be largest length of pad possible
        0 ?DO
            pad i +  dup c@  dup 49 58 within
            IF  drop  1
            ELSE   blank? IF  '0' over c!  1  ELSE  0  THEN
            THEN  ImportNumbers +place
        LOOP
        0 to start 0 to solution
        ImportNumbers count 81 / 81 * bounds ?DO
            true  81 0 DO  i j + c@  dup '0' = IF  j to Start  THEN  49 58 within and  LOOP
            IF  i to Solution  THEN
        81 +LOOP ;

: OpenTextFile ( -- )
        GetHandle: self start: OpenText dup dup c@
        IF  count r/o open-file
            IF  2drop ( ReadErrorMessage )     \ file does not exist
\            IF   drop  ReadErrorMessage       \ file does not exist
            ELSE  to hFile
                  pad 512 hFile read-file drop  pad + 0 swap c!
                  pad IDC_SUDOKU_EDIT GetHandle: self call SetDlgItemText drop 
            THEN  hFile close-file drop
        ELSE  drop
        THEN ;

:M On_Command: ( hCtrl code ID -- f )
        Case
            IDC_FILE     Of  OpenTextFile                  EndOf
            IDCANCEL     Of  0 end-dialog                  EndOf
            IDOK         Of  CollectNumbers  1 end-dialog  EndOf
            false swap ( default result )
        Endcase
        ;M

;Object


: SI   conhndl start: ImportDialog  IF \ cr ImportNumbers 243 dump
        Start IF  cr start 81 type  THEN
        Solution IF  cr solution 81 type  THEN
        THEN ;
