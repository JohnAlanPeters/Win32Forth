\    File: PLAYER4.F
\
\  Authors: Bruno Gauthier  bgauthier@free.fr
\           Dirk Busch      dirk@win32forth.org
\           Jos van de Ven  josv@wxs.nl
\
\ Created: Donnerstag, März 31 2005 - dbu
\ Updated: Dienstag, Mai 16 2006 - dbu
\
\ A simple Audio- and Videoplayer using the MciVideoWindow class.

cr .( Loading Player 4th...)

anew -PLAYER4.F

s" apps\Player4"   "fpath+

VOCABULARY Player
only forth also Player definitions \ put all words into the PLAYER vocabulary
decimal

true value turnkey?
true value MciDebug?

needs excontrols.f
needs w_search.f
needs volinfo.f
needs sub_dirs.f
needs TrayWindow.f
needs Resources.f
needs multiopen.f
needs AcceleratorTables.f
needs Joystick.f
needs security.f

200 value IDJoystick

defer RefreshCatalog ' noop is RefreshCatalog
defer SortCatalog    ' noop is SortCatalog
defer RequestRecord  ' noop is RequestRecord
defer MenuChecks     ' noop is MenuChecks
defer HandleJoystick ' noop is HandleJoystick

0 value JoycenterX
0 value JoycenterY

needs Pl_Toolset.f
needs number.f
needs mshell_r.f
needs catalog.f
needs view.f
needs SearchPath.f
needs Player4.frm \ "Control center" dialog

AcceleratorTable AccelTable

\ -----------------------------------------------------------------------------
\ define the child window for the right part of the main window
\ in this area the video's will be shown
\ -----------------------------------------------------------------------------
needs Pl_MciWindow.f

\ -----------------------------------------------------------------------------
\ define the child window for the left part of the main window
\ in this area the catalog will be shown
\ -----------------------------------------------------------------------------
needs MediaTree.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Splitter <Super child-window

:M WindowStyle: ( -- style )   \ return the window style
        WindowStyle: super
        [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or
        ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Paint: ( -- )            \ screen redraw method
        0 0 Width Height LTGRAY FillArea: dc
        ;M

;Object

\ -----------------------------------------------------------------------------
\ ID's for WM_COMMAND
\ -----------------------------------------------------------------------------
needs CommandID.f

: SetVolLevel       ( Volume - )  dup 1000 min 0 max vadr-config VolLevel ! SetVolume: Player4W  ;

\ -----------------------------------------------------------------------------
\       Define the Main Window
\ -----------------------------------------------------------------------------

:Object MainWindow  <super TrayWindow

3 value thickness
0 value toolbarH    \ set to height of toolbar if any
0 value statusbarH  \ set to height of status bar if any
0 value clicked
int dragging?
int mousedown?

:M WindowTitle: ( -- Zstring ) \ window caption
        z" Player 4th" ;M

:M WndClassStyle: ( -- style )  CS_DBLCLKS                              ;M


:M DefaultIcon: ( -- hIcon )            \ return the default icon handle for window
        LoadAppIcon ;M

:M WindowStyle:    ( -- style )  WindowStyle: Super  WS_CLIPCHILDREN or ;M

: LeftHeight            ( -- n )
        Height statusbarH - toolbarH - ;

: position-windows ( -- )
        0  toolbarH  SeparatorX @  Height  Move: Catalog
        SeparatorX @ thickness +  toolbarH Width SeparatorX @ thickness + -  Height Move: Player4W
        SeparatorX  toolbarH  thickness  LeftHeight  Move: Splitter
        ;

: InSplitter? ( -- f1 )   \ is cursor on splitter window
        hWnd get-mouse-xy
        0 height within
        swap  SeparatorX @ dup thickness + within  and ;

:M WM_SETCURSOR ( h m w l -- )
        hWnd get-mouse-xy
        toolbarH dup Height + within
        swap  0 width within and
        IF  InSplitter? IF  SIZEWE-CURSOR   ELSE  arrow-cursor  THEN  1
        ELSE  DefWindowProc: self
        THEN
        ;M

:noname  GetWindowRect:  Self 2drop ; is  GetPositionCatalog ( - x y )

:M WM_INITMENU  ( h m w l -- res )
                MenuChecks  0
                ;M

:M StartPos:    ( -- x y )
                CenterWindow: Self
                ;M

: On_Mousemove  ( -- )
        mousex SeparatorX @ =
        mousex SeparatorX @ 1+ = or
        if      SIZEWE-CURSOR
        else    arrow-cursor
        then    ;

:M WM_MOUSEMOVE ( h w m l -- res )
        WM_MOUSEMOVE WM: super
        on_mousemove ;M

\ mouse click routines for Main Window to track the Splitter movement

: DoSizing ( -- )
        mousedown? dragging? or 0= ?EXIT
        mousex ( 1+ ) width min  thickness 2/ -
        [ thickness 2* ] literal max width  [ thickness 2* ] literal - min
        SeparatorX !
        position-windows
        WINPAUSE ;

: On_clicked ( -- )
        mousedown? 0= IF  hWnd Call SetCapture drop  THEN
        true to mousedown?
        InSplitter? to dragging?
        DoSizing ;

: On_unclicked ( -- )
        mousedown? IF  Call ReleaseCapture drop  THEN
        false to mousedown?
        false to dragging? ;

: On_DblClick ( -- )
        false to mousedown?
        InSplitter? 0= ?EXIT
        SeparatorX @ 8 >
        IF      0 thickness 2/ -  SeparatorX !
        ELSE    132 Width 2/ min  SeparatorX !
        THEN
        position-windows
        ;

:M Classinit:   ( -- )
        ClassInit: super   \ init super class
        ['] On_clicked     SetClickFunc: self
        ['] On_unclicked   SetUnClickFunc: self
        ['] DoSizing       SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        ;M

:M StartSize:   ( -- w h )
        screen-size >r 4 * 6 / r> 2/ ;M

:M On_Size:     ( -- )
        position-windows ;M

: check/resize-config-file
        DatFile$ count file-exist?
        if   DatFile$ count r/o open-file throw dup file-size throw d>s pad !
             close-file throw pad @
             sizeof ConfigDef =
        else false
        then check-config unmap-configuration ;

string: StartupDir

: ?SetPath  ( flag - )
        if     Catalogpath count dup>r + r@ ascii \ -scan 1- r> swap -
               StartupDir count 1- pad place   pad +place  pad count Catalogpath place
               Catalogpath +null  z" Player4.exe" zEXEC-CMD  drop bye
        then
 ;

:M On_Init:  { RomBooted }   ( -- )
        On_Init: super
        AccelTable EnableAccelerators \ init the accelerator table
        COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hwnd  Call SetClassLong drop
        CURRENT-DIR$ count  drop 3 StartupDir place
        RomBoot to RomBooted
        InitFileNames check/resize-config-file
        catalog-exist?
        if    map-config-file  RomBooted ?SetPath
              map-database vadr-config ExitFailed- c@
                        if      MciDebug?
                                        if cr ." REBUILD "
                                        then
                                generate-index-file build-free-list
                        then
                true vadr-config ExitFailed- c!
                MciDebug?
                        if      database-mhndl #records-in-database . ." records, "
                                ." freelist: " vadr-config  #free-list @ .
                        then
                vadr-config s_Random_popular- w@
                        if      shuffle-catalog
                        then
                SortByFlags
        else    map-config-file
        then

        -1 to #playing
        GetHandle: Self SetParent: ControlCenter
        GetHandle: Self SetParent: ViewForm

        self Start: Catalog
        self Start: Player4W
        self Start: Splitter
        vadr-config VolLevel @ SetVolLevel
        SeparatorX @ 0=
        if   Startsize: self drop 2/ SeparatorX !
        then position-windows
        addr: self to player-base
        RefreshCatalog
        FindFirstJoyStick dup to IDJoystick
        MaxJoysticks <
                if      [ *lpjoycapsa joycapsa wYmax ] literal @
                        [ *lpjoycapsa joycapsa wYmin ] literal @ - 2/ to JoycenterY
                        [ *lpjoycapsa joycapsa wXmax ] literal @
                        [ *lpjoycapsa joycapsa wXmin ] literal @ - 2/ to JoycenterX
                        0 100 1 hWnd Call SetTimer drop
                then
        ;M

:M WM_TIMER     ( hm wl -- res ) \ handle the WM_TIMER events
     2drop HandleJoystick 0
 ;M

:M On_Done:     ( h m w l -- res )
        MaxJoysticks <
           if  1 hWnd Call KillTimer
           then
        Close: self
        0 call PostQuitMessage drop
        On_Done: super 0 ;M

:M WM_CLOSE     ( h m w l -- res )
        GetVolume: Player4W  vadr-config VolLevel !
        AccelTable DisableAccelerators \ free the accelerator table
        Close: self
        WM_CLOSE WM: Super
        unmap-database
        unmap-configuration
        false vadr-config ExitFailed- c!
        bye 0 ;M

\ -----------------------------------------------------------------------------
\ Command handling
\ -----------------------------------------------------------------------------
:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        over LOWORD ( command ID ) dup
        IsCommand? IF DoCommand \ intercept Toolbar and shortkey commands
        ELSE drop OnWmCommand: Super \ intercept Menu commands
        THEN ;M

\ -----------------------------------------------------------------------------
\ Traybar handling
\ -----------------------------------------------------------------------------
:M ShowWindow:  ( -- )
        IsVisible?: self 0=
        if   ShowWindow: super
             Video?: Player4W if Resume: Player4W then
             SW_RESTORE Show: ControlCenter Update: ControlCenter
        then ;M

:M HideWindow:  ( -- )
        IsVisible?: self
        if   Video?: Player4W if Pause: Player4W then
             SW_HIDE Show: ControlCenter Update: ControlCenter
             HideWindow: super
        then ;M

:M GetTooltip:  ( -- addr len )
        WindowTitle: self zcount ;M

;Object

\ -----------------------------------------------------------------------------
\ "Control center" dialog
\ -----------------------------------------------------------------------------
: Pause/Resume  ( -- )
        Playing?: Player4W if Pause/Resume: Player4W then ; IDM_PAUSE/RESUME SetCommand

: Stop          ( -- )
        Playing?: Player4W if -1 to #playing AbortPlaying: Player4W then ; IDM_STOP SetCommand

: Next          ( -- )
        Playing?: Player4W
        if   Close: Player4W
        else catalog-exist?
                if   SetFocus: ControlCenter
                     play-catalog-random: Player4W
                then
        then ; IDM_NEXT SetCommand

5000 value step

: Forward       ( -- )
        Playing?: Player4W if step Forward: Player4W then ; IDM_FORWARD SetCommand

: Rewind        ( -- )
        Playing?: Player4W if step Rewind: Player4W then ; IDM_REWIND SetCommand

' Pause/Resume  SetFunc: PauseButton
' Stop          SetFunc: StopButton
' Next          SetFunc: NextButton
' Forward       SetFunc: ForwardButton
' Rewind        SetFunc: BackButton

\ -----------------------------------------------------------------------------
\ "About" dialog
\ -----------------------------------------------------------------------------
needs Pl_About.f

\ -----------------------------------------------------------------------------
\ Simple command line handling
\
\ Start player and play a file:
\       player4.exe "c:\temp\test.mp3"
\
\ Start player and open a playlist-file:
\       player4.exe /l "c:\temp\PlayList.pl4"
\
\ Start player and play files in a folder:
\       player4.exe /f "c:\temp\audio files"
\ -----------------------------------------------------------------------------
: strip-cmdline ( addr cnt -- addr2 cnt2 )
        [CHAR] " skip [CHAR] ' skip BL skip
        [CHAR] " -TRAILCHARS [CHAR] ' -TRAILCHARS BL -TRAILCHARS ;

: HandleCmdLine { \ bPlayFolder bPlayList -- } \ simple command-line handling
        CMDLINE ?dup
        if   false to bPlayFolder
             false to bPlayList

             over c@ UPC [char] / =
             if   over char+ c@ UPC [char] F = to bPlayFolder
                  over char+ c@ UPC [char] L = to bPlayList
                  swap 3 chars + swap 3 chars -
             then strip-cmdline

             bPlayFolder
             if   PlayFolder: Player4W
             else bPlayList
                  if   PlayList: Player4W
                  else PlayFile: Player4W
                  then
             then
        else drop
        then ;

\ -----------------------------------------------------------------------------
\ Commands
\ -----------------------------------------------------------------------------

needs Commands.f

: GetVolume/timeOut ( - Volume VolumeChange )  100 ms GetVolume: Player4W dup 10 / ;
: ButtonIn?         ( - ButtonIn )  IDJoystick GetJoystickInfo  2nip nip 0= ;
: WaitTillDepressed ( - )           begin      ButtonIn?    until   ;

: DecreaseVolume    ( - )
    begin       GetVolume/timeOut - SetVolLevel
                ButtonIn?
     until
 ;

: IncreaseVolume    ( - )
     begin     GetVolume/timeOut 20 max + SetVolLevel
               ButtonIn?
     until
 ;

: ChangeFont ( Big|small - )
        to UseBigFont   Delete: TreeViewFont       SetfontTreeView: Catalog
        SW_SHOWMAXIMIZED Show:  MainWindow
 ;

: ShowPlaying
    #playing  -1 >
        if      #playing RecordDef hIntree @ SelectTreeViewItem: Catalog
        then
 ;

: PlayFromJoystick  ( - )
    GetSelectedItem: Catalog
    GetLparm: Catalog dup -1 =
        if      drop
        else    to last-selected-rec  PlaySelectedFromTreeView
        then
 ;

: JoystickBrowser       ( button - )
     case
                        JOY_BUTTON1   of   IDM_NEXT            DoCommand   endof
                        JOY_BUTTON2   of   UseBigFont not ChangeFont       endof
                        JOY_BUTTON3   of   DecreaseVolume                  endof
                        JOY_BUTTON4   of   IncreaseVolume                  endof
                        JOY_BUTTON5   of   IDM_PAUSE/RESUME     DoCommand  endof
                        JOY_BUTTON6   of   down                            endof
                        JOY_BUTTON9   of   10 to MaxDif       ShowPlaying  endof
     endcase
 ;

: DifToCenter? { pos } ( Joycenter pos - dif )
     dup  2 / over pos - abs >
        if      drop 0
        else    pos - negate
        then
 ;

: XYDifCenter ( posx posy - difx dify )
   JoycenterY swap DifToCenter? >r
   JoycenterX swap DifToCenter? r>
 ;

0 value incr-fact

: 2abs ( n1 n2 - n1Abs n2Abs )     abs swap abs swap ;

: ScrollFlag     ( difx dify - f )
    2abs max dup to MaxDif dup  0=
        if      to incr-fact
        else    incr-fact JoycenterY >=
                if      drop 0 to incr-fact
                else    +to incr-fact
                then
        then
   incr-fact 0=
 ;

: down/up  ( Y - )
    dup 0<>
        if      0>
                        if      DownInTree: Catalog
                        else    UpInTree:   Catalog
                        then
        else    drop
        then
 ;

: Left/Right  ( X - )
    dup 0<>
        if      0>
                        if     OpenChild: Catalog
                        else   CloseChild: Catalog
                        then   JoycenterY negate 3 * to incr-fact
        else    drop
        then
 ;

: HandleMovesJoystickBrowser ( x y z button - )
   2drop XYDifCenter 2dup  ScrollFlag
        if   2dup 2abs <=
                if    down/up drop
                else  drop Left/Right
                then
        else    2drop
        then

 ;

:Noname             ( - )
  vadr-config JoyStickDisabled- c@ 0=
        if   IDJoystick GetJoystickInfo  dup JOY_BUTTON1 >=
                if      JoystickBrowser  WaitTillDepressed 3drop
                else    HandleMovesJoystickBrowser
                then
        then
 ; is  HandleJoystick

\ -----------------------------------------------------------------------------
\       Define the Menu bar
\ -----------------------------------------------------------------------------
MENUBAR player4-Menu-bar
    POPUP "&File"
        MENUITEM     "&Play file...\tCtrl+O"     IDM_OPEN_FILE     DoCommand ;
        MENUITEM     "Play &folder...\tCtrl+F"   IDM_OPEN_FOLDER   DoCommand ;
        MENUITEM     "&Play &list...\tShift+L"   IDM_OPEN_PLAYLIST DoCommand ;
        MENUSEPARATOR
        MENUITEM     "&Exit\tAlt+F4"                            IDM_QUIT          DoCommand ;

    POPUP "&Catalog"
        MENUITEM     "&Add file(s)...\tCtrl+M"                  IDM_ADD_FILES     DoCommand ;
        MENUITEM     "&Import directory tree...\tCtrl+I"        IDM_IMPORT_FOLDER DoCommand ;
        MENUITEM     "&Export the catalog to Player.csv"        csv-catalog ;
        MENUITEM     "S&earch and make a collection..."         SearchCatalog ;
        MENUITEM     "&Mark collection as not yet played"       SetCollectionToNotPlayed ;
        MENUSEPARATOR
       :MENUITEM      mEndless "Endless play"                   Endless ;
        MENUITEM     "&Start/Resume playing\tCtrl+R"            IDM_START/RESUME  DoCommand ;
        MENUSEPARATOR
        SUBMENU      "S&ort and view"
           MENUITEM  "Define a view and sort"                  StartViewForm ;
           MENUITEM  "&Sort / Refresh"                         SortCatalog ;
        MENUSEPARATOR
           MENUITEM  "Se&t maximum random level"                SetRandomLevel ;
           MENUITEM  "&Generate random numbers"                 RandomizeCatalog ;
        ENDSUBMENU
        SUBMENU      "Re&quest handling"
          :MENUITEM   mHandelReq  "Ignore requests"             DoIgnoreRequests ;
          :MENUITEM   mKeepReq  "Keep requests"                 DoKeepRequests ;
\           MENUITEM  "&Enable all kept requests"               EnableKeptRequests ;
           MENUITEM  "Se&t request level"                       DoSetRequestLevel ;
           MENUITEM  "Set a&ll requests to the same level"      SetRequestLevel ;
        ENDSUBMENU
        MENUSEPARATOR
        MENUITEM     "Show &collection"                         RefreshCatalog ;
        MENUITEM     "Sho&w deleted records"                    ShowDeleted ;
        MENUSEPARATOR
        MENUITEM     "&Delete item"                             DeleteItem ;
        MENUITEM     "D&elete collection..."                    DeleteCollection ;
        MENUSEPARATOR
        MENUITEM     "&Undelete item"                           Undelete ;
        MENUITEM     "Undelete &all"                            UndeleteAll ;

    POPUP "&Options"
        MENUITEM     " &50%\tCtrl+5"                            IDM_VIEW_50     DoCommand ;
        MENUITEM     "&100%\tCtrl+1"                            IDM_VIEW_100    DoCommand ;
        MENUITEM     "&200%\tCtrl+2"                            IDM_VIEW_200    DoCommand ;
        MENUSEPARATOR
        MENUITEM     "&FullScreen toggle\tCtrl+F"               IDM_VIEW_FULLSCREEN     DoCommand ;
        MENUSEPARATOR
        MENUITEM     "&Audio on\tCtrl+A"                        IDM_AUDIO_ON    DoCommand ;
        MENUITEM     "&Audio off\tShift+A"                      IDM_AUDIO_OFF   DoCommand ;
        MENUSEPARATOR
       :MENUITEM     mBlackBackGround "Black background"           BlackBackGround ;
        MENUITEM     "&Setup search path catalog"   Self start: Form_search_path ;
       :MENUITEM     mAutostart "Auto play the catalog at the start" AutoPlay ;
       :MENUITEM     mTray "Tray window at the start"           TrayWindowCmd ;
       :MENUITEM     mJoyStickDisabled "Disable joystick"       NoJoysticks ;

    POPUP "&Help"
        MENUITEM     "About Player 4th..."                      IDM_ABOUT         DoCommand ;
ENDBAR

:Noname ( -- )
        vadr-config AutoStart-          c@ Check: mAutostart
        vadr-config AutoMinimized-      c@ Check: mTray
        vadr-config IgnoreRequests      c@ Check: mHandelReq
        vadr-config KeepRequests        c@ Check: mKeepReq
        vadr-config Endless-            c@ Check: mEndless
        vadr-config JoyStickDisabled-   c@ Check: mJoyStickDisabled
        vadr-config BlackBackGround-    c@ Check: mBlackBackGround

        ; is MenuChecks    \ enable/disable the menu items

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Accelerator Table - support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AccelTable table

        \ falgs         key-code        command-id

        \ File menu
        FCONTROL        'O'             IDM_OPEN_FILE           ACCELENTRY
        FCONTROL        'F'             IDM_OPEN_FOLDER         ACCELENTRY
        FCONTROL        'L'             IDM_OPEN_PLAYLIST       ACCELENTRY
        FALT            VK_F4           IDM_QUIT                ACCELENTRY

        \ Catalog menu
        FCONTROL        'M'             IDM_ADD_FILES           ACCELENTRY
        FCONTROL        'I'             IDM_IMPORT_FOLDER       ACCELENTRY
        FCONTROL        'R'             IDM_START/RESUME        ACCELENTRY

        \ Options menu
        FCONTROL        '5'             IDM_VIEW_50             ACCELENTRY
        FCONTROL        '1'             IDM_VIEW_100            ACCELENTRY
        FCONTROL        '2'             IDM_VIEW_200            ACCELENTRY
        FCONTROL        'F'             IDM_VIEW_FULLSCREEN     ACCELENTRY
        FCONTROL        'A'             IDM_AUDIO_ON            ACCELENTRY
        FSHIFT          'A'             IDM_AUDIO_OFF           ACCELENTRY

        \ Help menu
        0                VK_F1          IDM_ABOUT               ACCELENTRY

        \ other commands
        FCONTROL         'Q'            IDM_STOP                ACCELENTRY
        FCONTROL         'S'            IDM_STOP                ACCELENTRY
        FCONTROL         'P'            IDM_PAUSE/RESUME        ACCELENTRY
        0                VK_ESCAPE      IDM_STOPPLAYER          ACCELENTRY

        0                VK_LEFT        IDM_REWIND              ACCELENTRY
        0                VK_RIGHT       IDM_FORWARD             ACCELENTRY
        0                VK_PRIOR       IDM_NEXT                ACCELENTRY      \ page up
        0                VK_NEXT        IDM_NEXT                ACCELENTRY      \ page down

MainWindow HandlesThem

\ -----------------------------------------------------------------------------
\ PLAYER4 the main word
\ -----------------------------------------------------------------------------

: InitPlayer    ( -- )
        Start: MainWindow
        Start: ControlCenter
        player4-menu-bar SetMenuBar: MainWindow
        ['] FullScreen SetDblClickFunc: MouseHandlerWindow
        vadr-config AutoMinimized- c@   if   HideWindow: MainWindow  then
        vadr-config AutoStart-     c@   if   start/resume            then
        ;

: PLAYER4       ( -- )
        InitPlayer
        HandleCmdLine
        Playing: Player4W
        ;


: uninit-player4   ( -- )
        DestroyWindow: MainWindow ;
        unload-chain chain-add-before uninit-player4

\ -----------------------------------------------------------------------------
\ build an application on disk or run Player
\ -----------------------------------------------------------------------------

turnkey? [if]
        ' QuitPlayer is StopPlayer
        false to MciDebug?

        &forthdir count &appdir place
        ' player4 turnkey Player4.exe

        \ add the resources to the exe file
version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]  \ Not for V6.xx.xx older OSs
                &forthdir count pad place
                s" Player4.exe" pad +place
                pad count "path-file drop AddToFile

                CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST s" Player4.exe.manifest" "path-file drop  AddResource
                101 s" Player4.ico" "path-file drop AddIcon

                false EndUpdate

        [else]
                s" Player4.ico" s" Player4.exe" Prepend<home>\ AddAppIcon
        [then]
        Require Checksum.f
        s" Player4.exe" prepend<home>\ (AddCheckSum)
        1 pause-seconds bye
[else]
        true to MciDebug?
        ' quit is StopPlayer   \ Access to Forth ( Not fullproof )
        s" Player4.ico" s" Player4.exe" AddAppIcon

        PLAYER4

[then]
