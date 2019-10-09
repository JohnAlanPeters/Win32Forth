\ $Id: ConsoleMenu.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $
\ ConsoleMenu.F

cr .( Loading Console Menus...)

only forth also definitions

defer mark-all
' mark_all     is mark-all

in-application

INTERNAL        \ internal definitions start here

defer copy-console
defer cut-console

' copy_console is copy-console
' cut_console  is cut-console

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

FileOpenDialog LoadForth  "Load Forth File"   "Forth Files (*.f)|*.f|All Files (*.*)|*.*|"
FileOpenDialog EditForth  "Edit Forth File"   "Forth Files (*.f)|*.f|Text Files (*.txt)|*.txt|All Files (*.*)|*.*|"
FileOpenDialog PrintForth "Print Forth File"  "Forth Files (*.f)|*.f|Text Files (*.txt)|*.txt|All Files (*.*)|*.*|"
FileSaveDialog SaveForth  "Save Forth Image"  "Image Files (*.exe)|*.exe|All Files (*.*)|*.*|"
FileOpenDialog EditLog    "Edit Key Log File" "Log Files (*.LOG)|*.LOG|Text Files (*.txt)|*.txt|All Files (*.*)|*.*|"
NewEditDialog  HtmlDlg    "Open Web Page Address" "Page (WWW. and .COM optional):" "Open"  ""   ""

: edit-forth    ( -- ) \ edit a forth file
                conhndl start: EditForth dup c@
                IF      count pocket place
                        0 pocket $edit
                ELSE    drop
                THEN    ;

\ changed to work with blanks in file name
\ January 31st, 2004 - 20:38 dbu
: load-forth    ( -- )
        conhndl start: LoadForth dup c@
        IF      count pocket place
                s" FLOAD '"  "pushkeys
                pocket count "pushkeys
                s" '"        "pushkeys
                0x0D pushkey
        ELSE    drop
        THEN    ;

: print-forth    ( -- ) \ print a forth file
        conhndl start: PrintForth dup c@
        IF      count pocket place
                #pages-up ?dup
                IF      2 =
                        IF      two-page
                        ELSE    four-page
                        THEN    pocket $fprint
                        single-page
                ELSE    pocket $fprint
                THEN
        ELSE    drop
        THEN    ;

: edit-log      ( -- ) \ edit a macro file
        conhndl start: EditLog dup c@
        IF      count pocket place
                0 pocket $edit
        ELSE    drop
        THEN    ;

: adjust-forth  ( -- ) \ show help on how to change the dictionary size
                1 c" ADJFORTH.TXT" $browse ;

: save-forth    ( -- ) \ save a new Forth image
                turnkeyed? ?exit
                conhndl start: SaveForth dup c@
\in-system-ok   if count "fsave
                else drop
                then ;

: open-web      { \ web$ -- }
                MAXSTRING LocalAlloc: web$
                web$ off
                web$ conhndl Start: HtmlDlg
                IF      web$ count conhndl "Web-Link
                THEN    ;

: ChdirDlg      { \ path$ -- } \ set current directory
                MAXSTRING LocalAlloc: path$
                current-dir$ count path$ place
                z" Choose the current directory"
                path$ conhndl BrowseForFolder
\in-system-ok   if   path$ dup +null count "chdir .dir cr
                then ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Function key additions to the keyboard interpreter during commandline entry
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: F1-doc        ( -- ) \ F1 start the Help
                0 0 ExecHelp drop ;

: ?f1-help      ( char flag -- char flag )
                dup ?exit               \ exit if flag is TRUE
\ [cdo]         over k_F2 = if 0= F2-help then
                over k_F1 = if 0= F1-doc  then  ;

: .IDE          ( -- ) \ load the IDE
                turnkeyed? 0=
                if 0 0 ExecIDE drop then ;


ledit-chain chain-add ?f1-help          \ help key recognition

: ?macro-keys   ( chad flag -- char flag )
                dup ?exit
                over [ 'S' +k_control +k_shift ] literal =
                if 0= start/stop-macro      EXIT then
                over [ 'M' +k_control +k_shift ] literal =
                if 0= replay-macro          EXIT then
                over [ 'R' +k_control +k_shift ] literal =
                if 0= CONHNDL repeat-amacro EXIT then
                over [ 'O' +k_control          ] literal =
   if 0= edit-forth            EXIT then
                over [ 'W' +k_control          ] literal =
   if 0= open-web              EXIT then
                over [ K_F12                   ] literal =
\in-system-ok   if 0= 2>r >r LoadProject  r> 2r> EXIT then
                over [ 'L' +k_control          ] literal =
   if 0=   load-forth            EXIT then
                over [ 'P' +k_control          ] literal =
                if 0= print-screen          EXIT then
                over [ 'X' +k_control          ] literal =
                if 0= cut-console
      [DEFINED] ledit-y
      [IF]      getxy nip to ledit-y
      [THEN]                                EXIT then
                over [ 'A' +k_control          ] literal =
                if 0= mark-all              EXIT then
                over [ 'C' +k_control          ] literal =
                if 0= copy-console          EXIT then
                over [ 'V' +k_control          ] literal =
                if 0= paste-load            EXIT then
                turnkeyed? ?exit
                over [ 'D' +k_control          ] literal =
   if 0= ChdirDlg              EXIT then
                ;

ledit-chain chain-add ?macro-keys       \ add macro key recognition

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ INTERNAL        \ internal definitions start here
\
\ |Class MENUCONSOLE <Super  MENUITEM   \ Only for use with the console window
\
\ :M DoMenu:      ( IDM -- )
\                 mid =
\                 if      mfunc execute-menufunc
\                         cr
\ [DEFINED] ledit-y [IF]  getxy to ledit-y to ledit-x  \ move lineeditor down
\ [THEN]          then    ;M
\
\ ;Class

EXTERNAL

MENUBAR Win32Forth-Menu-bar

\ Note: If you add a new menu entry with a shortcut, you must add
\ add the handling of the shortcut to ?MACRO-KEYS !!!

    POPUP "&File"
  MENUITEM    "&Edit Forth File...\tCtrl+O"      edit-forth ;
  MENUITEM    "&Load Forth File...\tCtrl+L"      load-forth ;
        MENUSEPARATOR
  MENUITEM    "Set current directory...\tCtrl+D" ChdirDlg ;
        MENUSEPARATOR
  MENUITEM    "Open a Web link...\tCtrl+W"       open-web ;
        MENUSEPARATOR
  MENUCONSOLE "&Save Forth System..."            save-forth ;
  MENUCONSOLE "&Adjust Forth Dictionaries..."    adjust-forth ;
        MENUSEPARATOR

\ *****************************************************************************
\ *****************************************************************************
\ ******** The following lines are for example ONLY, they show how to use sub
\ ******** menus, the code will not run, so don't un-comment it out.
\ *****************************************************************************
\ *****************************************************************************
\         SUBMENU         "Keyboard &Macros"
\             MENUITEM    "&New  Key Macro Recording..."   a-new-log ;
\             MENUITEM    "&Stop Key Macro Recording"      logging-off ;
\             MENUSEPARATOR
\             MENUITEM    "&Edit Key Macro Log File..."       edit-log ;
\             MENUITEM    "&Play Key Macro Log File..."       play-log ;
\ \ ******** SUBMENUs can even be nested as many levels as you wish! *********
\ \            SUBMENU         "Keyboard Macros"
\ \                MENUITEM    "Edit Key Log File"        edit-log ;
\ \                MENUITEM    "Play Key Log File"        play-log ;
\ \                ENDSUBMENU
\             ENDSUBMENU
\         MENUSEPARATOR

        MENUITEM        "Print Setup... "                       page-setup ;
        MENUITEM        "Pages Up Setup..."                     page-up-setup ;
  MENUITEM "&Print Forth File..."                  print-forth ;
        MENUITEM        "Print Forth Console Window...\tCtrl+P" print-screen ;
        MENUITEM        "Print Forth Console Buffer..."         print-console ;
        MENUSEPARATOR
        MENUCONSOLE     "E&xit Win32Forth     \tBYE"    bye ;

    POPUP "&Edit"
        MENUITEM        "&Cut and Clear Console \tCtrl+X"  cut-console ;
        MENUITEM        "&Copy Highlighted Text \tCtrl+C"  copy-console ;
        MENUITEM        "&Paste to Keyboard     \tCtrl+V"  paste-load ;
        MENUSEPARATOR
        MENUITEM        "&Mark all Text         \tCtrl+A"  mark-all ;

    POPUP "&Display"
        SUBMENU     "System Functions"
		MENULINE        "This Programs Name             \t.PROGRAM"  ".PROGRAM"
		MENULINE        "Version of Win32Forth          \t.VERSION"  ".VERSION"
		MENULINE        "Operating System Version       \t.PLATFORM" ".PLATFORM"
		MENULINE        "Console Current Size           \tGetColRow . ." "GetColRow . ."
		MENULINE        "Console Maximum Size           \tGetMaxColRow . ." "GetMaxColRow . ."
		MENULINE        "Return Stack Contents          \t.RSTACK"   ".RSTACK"
		MENULINE        "Memory Used and Available      \t.FREE"     ".FREE"
		MENULINE        "File Search Path               \t.FPATH"    ".FPATH"
        ENDSUBMENU
        SUBMENU     "Vocabulary Functions"
		MENULINE        "Words in Current Vocabulary    \tWORDS"     "WORDS"
		MENULINE        "All Vocabulary Statistics      \tVOCS"      "VOCS"
		MENULINE        "Current Vocab Thread Counts    \t.COUNTS"   ".COUNTS"
		MENULINE        "Current Vocab Thread Words     \t.THREADS"  ".THREADS"
        ENDSUBMENU
        SUBMENU     "List Functions"
		MENULINE        "List of Classes in Win32Forth  \t.CLASSES"  ".CLASSES"
		MENULINE        "List of Loaded Files           \t.LOADED"   ".LOADED"
		MENULINE        "List of Fonts in System        \t.FONTS"    ".FONTS"
		MENULINE        "List of Deferred &Word         \t.DEFERRED" ".DEFERRED"
		MENULINE        "List of Execution Chains       \t.CHAINS"   ".CHAINS"
		MENULINE        "List of Pointers               \t.POINTERS" ".POINTERS"
		MENULINE        "List of Dynamic Memory Used    \t.MALLOCS"  ".MALLOCS"
		MENULINE        "List of Win32API Calls Used    \t.PROCS"    ".PROCS"
        ENDSUBMENU
        SUBMENU     "Time and Date Functions"
		MENULINE        "Todays &Date                   \t.DATE"    ".DATE"
		MENULINE        "The Current &Time              \t.TIME"    ".TIME"
        ENDSUBMENU

    POPUP "&Tools"
        MENUITEM    "Win32Forth IDE"			.IDE ;
\in-system-ok  MENUITEM    "Compile &Project\tF12"               LoadProject ;
 MENUSEPARATOR
        MENULINE    "&Class and Vocabulary browser..."	"class-browser"
        MENULINE    "Cross &reference lister"  		"xref"
        MENULINE    "&Dex - Document Extractor"  	"dexh"
        MENULINE    "D&fc - File comparison utility"  	".Dfc"
        MENULINE    "Dump Top-Level-&Windows"  	        ".Windows"

    POPUP "&Macros"
        MENUITEM    "&New Key Recording File..."                con-new-macro ;
        MENUITEM    "&Start - Stop Key Recording \tCtrl+Shft+S" start/stop-macro ;
 MENUITEM "&Edit Key Macro Log File..."               edit-log ;
        MENUSEPARATOR
        MENUITEM    "&Play Key File"                            con-play-macro ;
        MENUITEM    "RePlay &Last Key File       \tCtrl+Shft+M" replay-macro ;
        MENUITEM    "&Repeat Key File 'n' times..\tCtrl+Shft+R" conhndl repeat-amacro ;

    POPUP "&Help"
        MENUITEM    "Win32Forth &Documentation\tF1"     F1-doc ;
        MENULINE    "&Help System"  			"help-system"
        MENUSEPARATOR
        MENUITEM    "&About Win32Forth"                 about-Win32Forth ;
ENDBAR

\ these two lines illustrate how to make a popup that runs code

\   POPUPITEM "WORDS"           words ;

\   BREAKPOPUP                          \ force start of a new menu line
\   POPUPITEM "DUMPHERE"   here 32 dump ;


\ Note: The :MENUITEM hplmc above creates a named menu item that can be
\       later checked or unchecked with the following commands:
\
\       true  Check: hlpmc              \ turn on the items check mark
\       false Check: hlpmc              \ clear the items check mark
\
\ The Enable: method can also be sued in the same way as follows:
\
\       true  Enable: hlpmc             \ Enable the item
\       false Enable: hlpmc             \ Disable the item

Win32Forth-menu-bar value console-menu  \ the default Forth console menu

POPUPBAR Win32Forth-Popup-bar
    POPUP " "
        MENUITEM        "&Copy Highlighted Text \tCtrl+C"  copy-console ;
        MENUITEM        "&Paste to Keyboard     \tCtrl+V"  paste-load ;
        MENUSEPARATOR
        MENUITEM        "&Mark all Text         \tCtrl+A"  mark-all ;
        MENUSEPARATOR
        MENUCONSOLE     "Exit"                  bye ;
ENDBAR

Win32Forth-Popup-bar value console-popup

INTERNAL        \ more internal definitions

: menukey       ( -- c1 )               \ keyboard/event handler for console menus
                cursorinview
                BEGIN   _mkey
                        dup menu_mask and
                WHILE   havemenu?
                        IF      0xFFFF and
                                dup DoMenu: console-menu
                                dup DoMenu: console-popup
                        THEN    drop
                REPEAT  menukey-more ;

: menu-forth-io ( -- )
                ['] menukey is key ;

FORTH-IO-CHAIN CHAIN-ADD MENU-FORTH-IO

menu-forth-io

: RightMouseClick ( -- )                        \ Handle a right mouse click
                mouseflags 3 and 2 <> ?EXIT     \ exit if not right mouse clicked
                mousex mousey conhndl Track: console-popup ;

MOUSE-CHAIN CHAIN-ADD RightMouseClick

: Start-console-menu { \ mlink -- }     \ startup the console's menubar
                menubar-link @          \ clear all menu handles
                begin   dup
                while   dup cell+ @ to mlink
                        ZeroMenu: mlink
                        @
                repeat  drop
                true havemenu!
             ZeroMenu: console-menu
     conhndl loadmenu: console-menu
           menuhandle: console-menu
          conhndl call SetMenu havemenu!
             ZeroMenu: console-popup
     conhndl loadmenu: console-popup ;

INITIALIZATION-CHAIN CHAIN-ADD START-CONSOLE-MENU

Start-console-menu

EXTERNAL

: Menu-off      ( -- )                  \ turn off the console's menubar
                false havemenu!
                0 conhndl call SetMenu 0= havemenu!
                ;

: Set-console-menu ( menubar -- )       \ switch to a new console menubar
                menu-off
                to console-menu
                start-console-menu ;

: Set-console-popup ( menubar -- )       \ switch to a new console popup
                to console-popup ;

MODULE          \ end of the module
