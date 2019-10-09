\ $Id: Commands.f,v 1.9 2008/09/26 12:00:27 jos_ven Exp $

\    File: Commands.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Mittwoch, Juni 09 2004 - dbu
\ Updated: Saturday, May 06 2006 - Rod

cr .( Loading Menu Commands...)

needs CommandID.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Some helper words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Define the Menu commands
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ --------------------------------------------------------------------------
\ File menu
\ --------------------------------------------------------------------------

: PlayFile      ( -- )
       OpenFile: Player4W ; IDM_OPEN_FILE SetCommand

: OpenFolder    ( -- )
       OpenFolder: Player4W ; IDM_OPEN_FOLDER SetCommand

: OpenPlayList  ( -- )
       OpenPlayList: Player4W ; IDM_OPEN_PLAYLIST SetCommand

: QuitPlayer    ( -- )
        Close: MainWindow bye ; IDM_QUIT SetCommand

defer StopPlayer ( -- ) ' noop is StopPlayer
        IDM_STOPPLAYER SetCommand

\ --------------------------------------------------------------------------
\ Catalog menu
\ --------------------------------------------------------------------------

: AddFiles      ( -- )
       AddFilesFromSelector: Player4W ; IDM_ADD_FILES SetCommand

: ImportFolder  ( -- )
       Import-to-catalog: Player4W RefreshCatalog ; IDM_IMPORT_FOLDER SetCommand

: start/resume  ( -- )
        catalog-exist?
        if   play-catalog-random: Player4W
        then ; IDM_START/RESUME SetCommand

: SearchCatalog ( -- ) \ search the catalog
        catalog-exist?
        if   0 to last-selected-rec player-base search-records
             SortByFlags RefreshCatalog
        then ;

:noname         ( -- ) \ sort catalog by file names
        catalog-exist?
        if   EnableKeptRequests SortByFlags RefreshCatalog
        then ; is SortCatalog

: SetRandomLevel        ( -- )
        catalog-exist?
        if   player-base ask-max-random-level
        then ;

: RandomizeCatalog      ( -- ) \ sort catalog by random
        catalog-exist?
        if   randomize-catalog RefreshCatalog
        then ;

: RefreshWindow ( -- )      \ redraw the window
        Paint: Mainwindow ;

: invert-check          ( check -- )
        dup c@ not swap c! RefreshWindow ;

: DoIgnoreRequests      ( -- )
        vadr-config IgnoreRequests dup invert-check c@ not
        if SortCatalog then ;

: DoKeepRequests        ( -- )
        vadr-config KeepRequests invert-check ;

: DoSetRequestLevel     ( -- )
        player-base SetRequestLevel ;

: DoSameRequestLevel    ( -- )
        Level-requests SortCatalog ;

:noname ( -- )
        catalog-exist?
        if   Refresh: Catalog
        then ; is RefreshCatalog

: ShowDeleted   ( -- )
        true to show-deleted
        Refresh: Catalog
        false to show-deleted
        ;

: valid-record? ( -- flag )
        catalog-exist?  last-selected-rec -1 <> and ;

: DeleteItem    ( -- )
        valid-record?
        if   last-selected-rec delete-record RefreshCatalog
             -1 to last-selected-rec
        then ;

: DeleteCollection      ( -- )
        catalog-exist?
        if   delete-collection RefreshCatalog
             -1 to last-selected-rec
        then ;

: Undelete      ( -- )
        valid-record?
        if   last-selected-rec undelete-record RefreshCatalog
             -1 to last-selected-rec
        then ;

: UndeleteAll   ( -- )
        catalog-exist?
        if   undelete-all RefreshCatalog
             -1 to last-selected-rec
        then ;

\ : SortRandom ( -- ) \ sort the catalog
\         catalog-exist?
\         if   sort_by_RandomLevel RefreshCatalog
\         then ;

\ : SortLeastPlayed ( -- ) \ sort the catalog
\         catalog-exist?
\         if   sort_by_leastPlayed RefreshCatalog
\         then ;

\ : SortSize ( -- ) \ sort the catalog
\         catalog-exist?
\         if   sort_by_size        RefreshCatalog
\         then ;

\ --------------------------------------------------------------------------
\ Options menu
\ --------------------------------------------------------------------------

: View50        ( -- )
        50 SetVideoSize: Player4W ; IDM_VIEW_50 SetCommand

: View100       ( -- )
        100 SetVideoSize: Player4W ; IDM_VIEW_100 SetCommand

: View200       ( -- )
        200 SetVideoSize: Player4W ; IDM_VIEW_200 SetCommand

: FullScreen    ( -- )
        FullScreenToggle: Player4W ; IDM_VIEW_FULLSCREEN SetCommand

: AudioOn       ( -- )
        AudioOn: Player4W ; IDM_AUDIO_ON SetCommand

: AudioOff      ( -- )
        AudioOff: Player4W ; IDM_AUDIO_OFF SetCommand

: AutoPlay      ( -- )
        vadr-config AutoStart- invert-check ;

: Endless       ( -- )
        vadr-config Endless-   invert-check ;

: TrayWindowCmd ( -- )
        vadr-config AutoMinimized- invert-check ;

: NoJoysticks   ( -- )
        vadr-config JoyStickDisabled- invert-check ;

: BlackBackGround   ( -- )
        vadr-config BlackBackGround- dup invert-check c@
             if        SetBlackBackGround: Catalog
             else      SetWhiteBackGround: Catalog
             then
        true 0 InvalidateRect: MouseHandlerWindow
        Paint: MouseHandlerWindow
;

\ --------------------------------------------------------------------------
\ Help menu
\ --------------------------------------------------------------------------

: PauseVideo    ( -- )
        Playing?: Player4W
        if   Video?: Player4W
             if   Pause: Player4W
             then
        then ;

: ResumeVideo   ( -- )
        Playing?: Player4W
        if   Video?: Player4W
             if   Resume: Player4W
             then
        then ;

: AboutPlayer   ( -- )
        PauseVideo
        Start: AboutPlayer4
        ResumeVideo
        On_Paint: MainWindow ; IDM_ABOUT SetCommand
\s
