\ ConsoleMenu.f     ( was ConsoleMenuNew.f)

cr .( Loading ConsoleMenu.f : Console Menus...)

only forth also definitions

in-application

defer copy-console ' noop is copy-console
defer cut-console  ' noop is cut-console
defer mark-all     ' noop is mark-all
\ defer paste-load   \ already deferred in editor_io.f

INTERNAL        \ internal definitions start here

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
                over k_F1 = if 0= F1-doc  then  ;

: .IDE          ( -- ) \ load the IDE
                turnkeyed? 0=
                if 0 0 ExecIDE drop then ;

EXTERNAL

MENUBAR Win32Forth-Menu-bar

\ Note: If you add a new menu entry with a shortcut, you must add
\ add the handling of the shortcut to HandleKeys in NewConsole.f !!!

    POPUP "&File"
  MENUITEM    "&Edit Forth File...\tCtrl+O"      edit-forth ;
  MENUITEM    "&Load Forth File...\tCtrl+L"      load-forth ;
        MENUSEPARATOR
  MENUITEM    "Set current directory...\tCtrl+D" ChdirDlg ;
        MENUSEPARATOR
  MENUITEM    "Open a Web link...\tCtrl+W"       open-web ;
\              MENUSEPARATOR
\        MENUCONSOLE "&Save Forth System..."            save-forth ;
\        MENUCONSOLE "&Adjust Forth Dictionaries..."    adjust-forth ;
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
\		MENULINE        "Console Maximum Size           \tGetMaxColRow . ." "GetMaxColRow . ."
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
 MENUSEPARATOR
        MENULINE    "&Class and Vocabulary browser..."	"class-browser"
        MENULINE    "Cross &reference lister"  		"xref"
        MENUSEPARATOR
        MENULINE    "&DexH - Document Extractor"  	"dexh"
        MENUSEPARATOR
        MENULINE    "D&FC - File comparison utility"  	".Dfc"
        MENULINE    "&LDE - List DLL exports"  	        ".lde"
        MENUSEPARATOR
        MENULINE    "Dump Top-Level-&Windows"  	        ".Windows"

[DEFINED] con-new-macro [IF]
    POPUP "&Macros"
        MENUITEM    "&New Key Recording File..."                con-new-macro ;
        MENUITEM    "&Start - Stop Key Recording \tCtrl+Shft+S" start/stop-macro ;
 MENUITEM "&Edit Key Macro Log File..."               edit-log ;
        MENUSEPARATOR
        MENUITEM    "&Play Key File"                            con-play-macro ;
        MENUITEM    "RePlay &Last Key File       \tCtrl+Shft+M" replay-macro ;
        MENUITEM    "&Repeat Key File 'n' times..\tCtrl+Shft+R" conhndl repeat-amacro ;
[THEN]
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

: Start-console-menu { \ mlink -- }     \ startup the console's menubar
                menubar-link @          \ clear all menu handles
                begin   dup
                while   dup cell+ @ to mlink
                        ZeroMenu: mlink
                        @
                repeat  drop
\                true havemenu!
             ZeroMenu: console-menu
     conhndl loadmenu: console-menu
           menuhandle: console-menu
          conhndl call SetMenu drop \ havemenu!
             ZeroMenu: console-popup
     conhndl loadmenu: console-popup ;

EXTERNAL

: Menu-off      ( -- )                  \ turn off the console's menubar
 \               false havemenu!
                0 conhndl call SetMenu drop \ 0= havemenu!
                ;

: Set-console-menu ( menubar -- )       \ switch to a new console menubar
                menu-off
                to console-menu
                start-console-menu ;

: Set-console-popup ( menubar -- )       \ switch to a new console popup
                to console-popup ;

MODULE          \ end of the module
