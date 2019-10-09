\ $Id: PVMenu.f,v 1.3 2012/05/08 20:57:38 georgeahubert Exp $

\ PVMenu.f              Command IDs and Menus for PictureViewer by Rod Oakford
\                       February 2006

cr .( PVMenu.f : Loading PictureViewer Menus)

Needs RecentFiles

cr  .( Loading PVMenu)

: NewID ( <name> -- )
        defined
        IF  drop
        ELSE NextID swap count ['] constant execute-parsing
        THEN ;

IDCounter constant IDM_FIRST

NewID IDM_OPEN
NewID IDM_OPEN_DIRECTORY
NewID IDM_CLOSE
NewID IDM_SAVE_AS
NewID IDM_PRINT
NewID IDM_PAGE_SETUP
NewID IDM_EXIT
NewID IDM_NO_ADJUST
NewID IDM_CENTRE_IN_WINDOW
NewID IDM_CENTRE_AND_STRETCH
NewID IDM_STRETCH_TO_WINDOW
NewID IDM_FIXED_ASPECT_RATIO
NewID IDM_OPTIONS
NewID IDM_TOGGLE_TOOLBAR
NewID IDM_TOGGLE_STATUSBAR
NewID IDM_ROTATE_90
NewID IDM_ROTATE_-90
NewID IDM_ROTATE_180
NewID IDM_FLIP_HORIZONTAL
NewID IDM_FLIP_VERTICAL
NewID IDM_ZOOM_IN
NewID IDM_ZOOM_OUT
NewID IDM_PREVIOUS_SLIDE
NewID IDM_NEXT_SLIDE
NewID IDM_SLIDE_SHOW
NewID IDM_TILE
NewID IDM_ARRANGE
NewID IDM_CASCADE
NewID IDM_CLOSE_ALL
NewID IDM_HELP
NewID IDM_ABOUT
NewID IDM_UNINSTALL
NewID IDM_SAVE
NewID IDM_RESTORE
NewID IDM_DEFAULT
NewID IDM_OPEN_FILE
NewID IDM_SCALE
NewID IDM_SCROLL_LEFT
NewID IDM_SCROLL_RIGHT
NewID IDM_SCROLL_UP
NewID IDM_SCROLL_DOWN
NewID IDM_ESCAPE
\ NewID IDM_ADJUST_MARGINS
NewID IDM_PAGE_ADJUST
NewID IDM_FULL_SCREEN
NewID IDM_OPEN_NEXT
NewID IDM_OPEN_PREV
NewID IDM_OPEN_PRELOADED
NewID IDM_MARK
NewID IDM_UNMARK
NewID IDM_TOGGLE_MARK
NewID IDM_TOGGLE_NEW_WINDOW
\ NewID IDM_NEXT_FILE
NewID IDM_OPEN_RECENT_FILE

\ ToolbarPopup
NewID IDM_FLAT
NewID IDM_SAVE_TOOLBAR
NewID IDM_RESTORE_TOOLBAR
NewID IDM_DEFAULT_TOOLBAR


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


MENUBAR PVMenu
    POPUP "&File"
        MENUITEM     "&Open... \tCtrl+O"      IDM_OPEN              DoCommand ;
        MENUITEM     "Open &directory... \tCtrl+D"  IDM_OPEN_DIRECTORY  DoCommand ;
        :MENUITEM  hClose  "&Close \tCtrl+W"          IDM_CLOSE             DoCommand ;
        :MENUITEM  hSaveAs  "&Save As... \tShift+Ctrl+S"  IDM_SAVE_AS     DoCommand ;
        MENUSEPARATOR
        :MENUITEM  hPrint  "&Print... \tCtrl+P"  IDM_PRINT          DoCommand ;
        MENUITEM   "Page Set&up... \tShift+Ctrl+P"  IDM_PAGE_SETUP  DoCommand ;
      9 RECENTFILES  RecentFiles              IDM_OPEN_RECENT_FILE  DoCommand ;
        MENUSEPARATOR
        MENUITEM     "E&xit  \tAlt-F4"        IDM_EXIT              DoCommand ;
    POPUP "&Options"
        :MENUITEM   hNewWindow  "Open in new window"           IDM_TOGGLE_NEW_WINDOW  DoCommand ;
        MENUSEPARATOR
        :MENUITEM   hNoAdjust  "&No adjustment \tCtrl+N"               IDM_NO_ADJUST  DoCommand ;
        :MENUITEM   hCentre  "&Centre in window \tCtrl+C"       IDM_CENTRE_IN_WINDOW  DoCommand ;
        :MENUITEM   hStretch  "Centre and &stretch \tCtrl+S"  IDM_CENTRE_AND_STRETCH  DoCommand ;
        :MENUITEM   hFit  "&Fit in window \tCtrl+F"            IDM_STRETCH_TO_WINDOW  DoCommand ;
        :MENUITEM   hAspect  "Fixed &aspect ratio  \tCtrl+R"  IDM_FIXED_ASPECT_RATIO  DoCommand ;
        MENUSEPARATOR
        MENUITEM     "More &Options..."                IDM_OPTIONS  DoCommand ;
    POPUP "&View"
        :MENUITEM   hToolbar    "&Toolbar"    IDM_TOGGLE_TOOLBAR    DoCommand ;
        :MENUITEM   hStatusBar  "&Statusbar"  IDM_TOGGLE_STATUSBAR  DoCommand ;
        MENUSEPARATOR
        MENUITEM   "Zoom in"                           IDM_ZOOM_IN  DoCommand ;
        MENUITEM   "Zoom out"                         IDM_ZOOM_OUT  DoCommand ;
        MENUITEM   "Rotate 90 \tShift+R"                  IDM_ROTATE_90  DoCommand ;
        MENUITEM   "Rotate -90 \tR"           IDM_ROTATE_-90  DoCommand ;
        MENUITEM   "Rotate 180"                     IDM_ROTATE_180  DoCommand ;
        MENUITEM   "Flip &horizontally"        IDM_FLIP_HORIZONTAL  DoCommand ;
        MENUITEM   "Flip &vertically"            IDM_FLIP_VERTICAL  DoCommand ;
    POPUP "&Window"
        MENUITEM     "&Tile"                  IDM_TILE              DoCommand ;
        MENUITEM     "&Arrange"               IDM_ARRANGE           DoCommand ;
        MENUITEM     "Ca&scade"               IDM_CASCADE           DoCommand ;
        MENUITEM     "&Close all"             IDM_CLOSE_ALL         DoCommand ;
    POPUP "&Help"
        MENUITEM     "&About"                 IDM_ABOUT             DoCommand ;
        MENUITEM     "&Keyboard shortcuts  \tF1" IDM_HELP           DoCommand ;
        MENUITEM     "&Uninstall"             IDM_UNINSTALL         DoCommand ;
        MENUITEM     "&Save settings"         IDM_SAVE              DoCommand ;
        MENUITEM     "&Restore settings"      IDM_RESTORE           DoCommand ;
        MENUITEM     "&Default settings"      IDM_DEFAULT           DoCommand ;
ENDBAR


POPUPBAR ToolbarPopup
    POPUP " "
        :MENUITEM   hFlat	  "&Flat Toolbar"           IDM_FLAT  DoCommand ;
        MENUSEPARATOR
        MENUITEM     "&Save Toolbar"              IDM_SAVE_TOOLBAR  DoCommand ;
        MENUITEM     "&Restore Toolbar"        IDM_RESTORE_TOOLBAR  DoCommand ;
        MENUITEM     "&Default Toolbar"        IDM_DEFAULT_TOOLBAR  DoCommand ;
ENDBAR


POPUPBAR ChildPopup
    POPUP " "
        MENUITEM   "Zoom in"                           IDM_ZOOM_IN  DoCommand ;
        MENUITEM   "Zoom out"                         IDM_ZOOM_OUT  DoCommand ;
        MENUITEM   "Rotate 90"                       IDM_ROTATE_90  DoCommand ;
        MENUITEM   "Rotate -90"                     IDM_ROTATE_-90  DoCommand ;
        MENUITEM   "Rotate 180"                     IDM_ROTATE_180  DoCommand ;
        MENUITEM   "Flip &horizontally"        IDM_FLIP_HORIZONTAL  DoCommand ;
        MENUITEM   "Flip &vertically"            IDM_FLIP_VERTICAL  DoCommand ;
ENDBAR
