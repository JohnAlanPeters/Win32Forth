\ $Id: SudokuMenu.f,v 1.3 2012/05/08 20:57:38 georgeahubert Exp $
\ SudokuMenu.f          Command IDs and Menus for Sudoku by Rod Oakford
\                       September 2005


needs RecentFiles

cr .( Loading Menu and Command ID's...)

: NewID ( <name> -- )
        defined
        IF  drop
        ELSE NextID swap count ['] constant execute-parsing
        THEN ;

IDCounter constant IDM_FIRST

\ File menu
NewID IDM_NEW
NewID IDM_OPEN
NewID IDM_CLOSE
NewID IDM_SAVE
NewID IDM_SAVE_AS
NewID IDM_PAGE_SETUP
NewID IDM_PRINT
NewID IDM_IMPORT
NewID IDM_OPEN_FILE
NewID IDM_EXIT

\ View menu
NewID IDM_SIZE_1
NewID IDM_SIZE_2
NewID IDM_SIZE_3
NewID IDM_SIZE_4
NewID IDM_CURSOR_NUMBER
NewID IDM_SHOW_SIZING
NewID IDM_TOGGLE_TOOLBAR
NewID IDM_TOGGLE_STATUSBAR
NewID IDM_FONT
NewID IDM_TEXT_COLOUR_1
NewID IDM_TEXT_COLOUR_2
NewID IDM_TEXT_COLOUR_3
NewID IDM_TEXT_COLOUR_4
NewID IDM_FIXED_COLOUR
NewID IDM_VARIABLE_BACKGROUND_COLOUR
NewID IDM_FIXED_BACKGROUND_COLOUR
NewID IDM_WARNING_COLOUR
NewID IDM_HIGHLIGHT_COLOUR
NewID IDM_MARGIN_COLOUR
NewID IDM_ELIMINATION_COLOUR

\ Game menu
NewID IDM_FORWARD
NewID IDM_BACKWARD
NewID IDM_START_EDIT
NewID IDM_ESCAPE
NewID IDM_TOGGLE_EDIT
NewID IDM_RESTART
NewID IDM_ELIMINATION
NewID IDM_HINT
NewID IDM_SOLUTION
NewID IDM_NUMBER_SOLUTIONS
\ NewID IDM_CONTINUE
NewID IDM_CHECK_ALL
NewID IDM_TOGGLE_VISIBLE
NewID IDM_TOGGLE_AUDIBLE

\ Help menu
NewID IDM_HELP
NewID IDM_ABOUT
NewID IDM_UNINSTALL
NewID IDM_SAVE_SETTINGS
NewID IDM_RESTORE_SETTINGS
NewID IDM_DEFAULT_SETTINGS

\ Toolbar popup
NewID IDM_SAVE_TOOLBAR
NewID IDM_RESTORE_TOOLBAR
NewID IDM_DEFAULT_TOOLBAR
NewID IDM_FLAT

\ Miscellaneous
NewID IDM_LEFT
NewID IDM_RIGHT
NewID IDM_UP
NewID IDM_DOWN
NewID IDM_DELETE
NewID IDM_KEY_1
NewID IDM_KEY_2
NewID IDM_KEY_3
NewID IDM_KEY_4
NewID IDM_KEY_5
NewID IDM_KEY_6
NewID IDM_KEY_7
NewID IDM_KEY_8
NewID IDM_KEY_9
NewID IDM_SELECT_BLANK
NewID IDM_SELECT_1
NewID IDM_SELECT_2
NewID IDM_SELECT_3
NewID IDM_SELECT_4
NewID IDM_SELECT_5
NewID IDM_SELECT_6
NewID IDM_SELECT_7
NewID IDM_SELECT_8
NewID IDM_SELECT_9
NewID IDM_PLUS
NewID IDM_MINUS
NewID IDM_PAUSE
NewID IDM_STOP
NewID IDM_COLOUR_1
NewID IDM_COLOUR_2
NewID IDM_COLOUR_3
NewID IDM_COLOUR_4
NewID IDM_OPTIONS

IdCounter constant IDM_LAST

: allot-erase ( n -- )
        here over allot swap erase ;

Create CommandTable  IDM_LAST IDM_FIRST - cells allot-erase

: IsCommand? ( ID -- f )
        IDM_FIRST IDM_LAST within ;

: >CommandTable ( ID -- addr )
        dup IsCommand?
        IF  IDM_FIRST - cells CommandTable +
        ELSE  drop abort" error - command ID out of range"
        THEN ;

: DoCommand	( ID -- )
        >CommandTable @ ?dup IF execute THEN ;

: SetCommand ( ID -- )
        last @ name> swap >CommandTable ! ;


MENUBAR SudokuMenu

Popup "&File"
        MenuItem "&New...  \tCtrl+N"                       IDM_NEW DoCommand ;
        MenuItem "&Open... \tCtrl+O"                      IDM_OPEN DoCommand ;
        MenuItem "&Save"                                  IDM_SAVE DoCommand ;
        MenuItem "Save &As..."                         IDM_SAVE_AS DoCommand ;
        MenuSeparator
        MenuItem  "Page setup"                      IDM_PAGE_SETUP DoCommand ;
        MenuItem  "Print \tCtrl+P"                       IDM_PRINT DoCommand ;
        MenuSeparator
        MenuItem  "&Import... \tCtrl+I"                 IDM_IMPORT DoCommand ;
      9 RECENTFILES  RecentFiles                     IDM_OPEN_FILE DoCommand ;
        MenuSeparator
        MenuItem "E&xit  \tAlt+F4"                        IDM_EXIT DoCommand ;

Popup "&View"
        :MENUITEM  hSize1  "Size&1 \tCtrl+1"            IDM_SIZE_1  DoCommand ;
        :MENUITEM  hSize2  "Size&2 \tCtrl+2"            IDM_SIZE_2  DoCommand ;
        :MENUITEM  hSize3  "Size&3 \tCtrl+3"            IDM_SIZE_3  DoCommand ;
        :MENUITEM  hSize4  "Size&4 \tCtrl+4"            IDM_SIZE_4  DoCommand ;
        MenuSeparator
        :MENUITEM  hCursor "Show number by cursor"     IDM_CURSOR_NUMBER  DoCommand ;
        :MENUITEM  hSizing "Adjust game while sizing"    IDM_SHOW_SIZING  DoCommand ;
        MenuSeparator
        :MENUITEM  hToolbar    "&Toolbar"      IDM_TOGGLE_TOOLBAR  DoCommand ;
        :MENUITEM  hStatusBar  "&Statusbar"  IDM_TOGGLE_STATUSBAR  DoCommand ;
        MenuSeparator
        MenuItem "&Font...  \t Ctrl+F"                  IDM_FONT DoCommand ;
        MenuSeparator
        SubMenu "&Change colours"
\            MenuItem "&Variable"                        IDM_VARIABLE_COLOUR DoCommand ;
            MenuItem "Text colour &1"                     IDM_TEXT_COLOUR_1 DoCommand ;
            MenuItem "Text colour &2"                     IDM_TEXT_COLOUR_2 DoCommand ;
            MenuItem "Text colour &3"                     IDM_TEXT_COLOUR_3 DoCommand ;
            MenuItem "Text colour &4"                     IDM_TEXT_COLOUR_4 DoCommand ;
            MenuItem "&Fixed"                              IDM_FIXED_COLOUR DoCommand ;
            MenuItem "&Warning"                          IDM_WARNING_COLOUR DoCommand ;
            MenuItem "&Variable background"  IDM_VARIABLE_BACKGROUND_COLOUR DoCommand ;
            MenuItem "&Fixed background"        IDM_FIXED_BACKGROUND_COLOUR DoCommand ;
            MenuItem "&Highlight"                      IDM_HIGHLIGHT_COLOUR DoCommand ;
            MenuItem "&Margin"                            IDM_MARGIN_COLOUR DoCommand ;
            MenuItem "&Elimination"                  IDM_ELIMINATION_COLOUR DoCommand ;
        EndSubMenu

Popup "&Game"
        :MENUITEM  hEdit  "&Edit fixed numbers"             IDM_TOGGLE_EDIT DoCommand ;
        MenuSeparator
        MenuItem "&Undo move \tCtrl+<--"                     IDM_BACKWARD DoCommand ;
        MenuItem "Re&do move \tCtrl+-->"                      IDM_FORWARD DoCommand ;
        MenuItem "&Restart   \tCtrl+R"                 IDM_RESTART DoCommand ;
        MenuItem "&Hint      \tCtrl+H"                    IDM_HINT DoCommand ;
\        MenuItem "Continue"                         IDM_CONTINUE DoCommand ;
        MenuItem "&Check   \tCtrl+C"                 IDM_CHECK_ALL DoCommand ;
        MenuSeparator
        :MenuItem  hSolution  "&See solution \tCtrl+S"            IDM_SOLUTION DoCommand ;
        :MenuItem  hNumberSolutions  "Find &number of solutions"  IDM_NUMBER_SOLUTIONS DoCommand ;
        :MenuItem  hEliminate "Show &Eliminations \tCtrl+E"          IDM_ELIMINATION DoCommand ;
        :MENUITEM  hVisible "&Visible warning on errors"   IDM_TOGGLE_VISIBLE  DoCommand ;
        :MENUITEM  hAudible "&Audible warning on errors"   IDM_TOGGLE_AUDIBLE  DoCommand ;

Popup "&Help"
        MenuItem "&Help    \tF1"                          IDM_HELP DoCommand ;
        MenuItem "&About"                                IDM_ABOUT DoCommand ;
        MenuItem "&Uninstall"                        IDM_UNINSTALL DoCommand ;
\        MenuItem "&Save settings"                IDM_SAVE_SETTINGS DoCommand ;
\        MenuItem "&Restore settings"          IDM_RESTORE_SETTINGS DoCommand ;
\        MenuItem "&Default settings"          IDM_DEFAULT_SETTINGS DoCommand ;

ENDBAR

POPUPBAR ToolbarPopup
Popup " "
        :MenuItem   hFlat	  "&Flat Toolbar"           IDM_FLAT  DoCommand ;
        MenuSeparator
        MenuItem     "&Save Toolbar"              IDM_SAVE_TOOLBAR  DoCommand ;
        MenuItem     "&Restore Toolbar"        IDM_RESTORE_TOOLBAR  DoCommand ;
        MenuItem     "&Default Toolbar"        IDM_DEFAULT_TOOLBAR  DoCommand ;
ENDBAR

: CheckSize { n -- }   \ check nth size on view menu, uncheck the rest
        5 1 DO  i n = IF  true  ELSE  false  THEN  LOOP
        check: hSize4  check: hSize3  check: hSize2  check: hSize1
        ;
