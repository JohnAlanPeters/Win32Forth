\ PMMenu.f

needs RecentFiles

cr .( Loading Menu and Command ID's...)

: NewID ( <name> -- )
        defined
        IF  drop
        ELSE NextID swap count ['] constant execute-parsing
        THEN ;

IDCounter constant IDM_FIRST

\ File menu
NewID IDM_NEW_MODULE
NewID IDM_DELETE
NewID IDM_ADD
NewID IDM_ADD_FORMS
NewID IDM_ZIP
NewID IDM_ZIP_ALL
NewID IDM_COPY
NewID IDM_COPY_ALL
NewID IDM_OPEN_FILE
NewID IDM_SHOW_FILE
NewID IDM_EXIT

\ View menu
NewID IDM_TOGGLE_FLAT
NewID IDM_TOGGLE_TOOLBAR
NewID IDM_TOGGLE_STATUSBAR
NewID IDM_COLLAPSE_ALL
NewID IDM_EXPAND_ALL

\ Project menu
NewID IDM_NEW
NewID IDM_OPEN
NewID IDM_CLOSE
NewID IDM_SAVE
NewID IDM_SAVE_AS
NewID IDM_RENAME
NewID IDM_SET_BUILD_PATH
NewID IDM_BUILD
NewID IDM_COMPILE
NewID IDM_SET_FORTH
NewID IDM_EXECUTEFILE

\ Help menu
NewID IDM_HELP
NewID IDM_ABOUT
NewID IDM_UNINSTALL
NewID IDM_SAVE_SETTINGS
NewID IDM_RESTORE_SETTINGS
NewID IDM_DEFAULT_SETTINGS

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


MENUBAR ProjectMenu

Popup "&File"
        MenuItem "&New...  \tCtrl+N"                       IDM_NEW DoCommand ;
        MenuItem "&Open... \tCtrl+O"                      IDM_OPEN DoCommand ;
        MenuItem "&Save    \tCtrl+S"                      IDM_SAVE DoCommand ;
        MenuItem "Save &As..."                         IDM_SAVE_AS DoCommand ;
        MenuItem "&Rename...\tCtrl+R"                   IDM_RENAME DoCommand ;
      9 RECENTFILES  RecentFiles                     IDM_OPEN_FILE DoCommand ;
        MenuSeparator
        MenuItem "E&xit  \tAlt+F4"                        IDM_EXIT DoCommand ;

Popup "&View"
        :MENUITEM  hFlat       "&Flat Toolbar"    IDM_TOGGLE_FLAT  DoCommand ;
        :MENUITEM  hToolbar    "&Toolbar"      IDM_TOGGLE_TOOLBAR  DoCommand ;
        :MENUITEM  hStatusBar  "&Statusbar"  IDM_TOGGLE_STATUSBAR  DoCommand ;
        MenuSeparator
        MenuItem "&Collapse All \tCtrl++"         IDM_COLLAPSE_ALL DoCommand ;
        MenuItem "&Expand All \tCtrl+-"             IDM_EXPAND_ALL DoCommand ;

Popup "&Project"
        MenuItem "&Build   \tCtrl+B" ( fixed with new splitter ) IDM_BUILD DoCommand ;
        MenuItem "Set search &path for build..." IDM_SET_BUILD_PATH DoCommand ;
        MenuSeparator
        MenuItem "&Compile \tF12"                      IDM_COMPILE DoCommand ;
        MenuItem "&Set Forth Name..."                IDM_SET_FORTH DoCommand ;
        MenuSeparator
        MenuItem "&New Module... \tCtrl+M"          IDM_NEW_MODULE DoCommand ;
        MenuSeparator
        MenuItem "&Add files to project... \tCtrl+A"       IDM_ADD DoCommand ;
        MenuItem "&Delete from project \tCtrl+D"        IDM_DELETE DoCommand ;
        MenuItem "Add open &forms \tCtrl+F"          IDM_ADD_FORMS DoCommand ;
        MenuSeparator
        SubMenu "Copy/&Zip files"
            MenuItem "&Zip non-library files..."           IDM_ZIP DoCommand ;
            MenuItem "Zip all files..."                IDM_ZIP_ALL DoCommand ;
            MenuItem "&Copy non-library files..."         IDM_COPY DoCommand ;
            MenuItem "Copy all files..."              IDM_COPY_ALL DoCommand ;
        EndSubMenu

Popup "&Help"
        MenuItem "&Help    \tF1"                          IDM_HELP DoCommand ;
        MenuItem "&About"                                IDM_ABOUT DoCommand ;
        MenuItem "&Uninstall"                        IDM_UNINSTALL DoCommand ;
\        MenuItem "&Save settings"                IDM_SAVE_SETTINGS DoCommand ;
\        MenuItem "&Restore settings"          IDM_RESTORE_SETTINGS DoCommand ;
\        MenuItem "&Default settings"          IDM_DEFAULT_SETTINGS DoCommand ;

ENDBAR

