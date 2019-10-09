\    File: Pl_MciWindow.f
\
\  Authors: Bruno Gauthier  bgauthier@free.fr
\           Dirk Busch      dirk@win32forth.org
\           Jos van de Ven  josv@wxs.nl
\
\ Created: Sonntag, April 17 2005 - dbu
\ Updated: Sonntag, April 17 2005 - dbu

anew -Pl_MciWindow.f

needs Resources.f
needs MCIWnd.f

FileOpenDialog PlayViewDLG "Open Mediafile" "MPEG Audio & Video |*.mpeg;*.mpg;*.mp2;*.mp3;*.mp4;*.mpa;*.dat|Windows Media (*.wma *.wmv)|*.wma;*.wmv|Avi Files (*.avi)|*.avi|Midi Files (*.mid *.midi)|*.midi;*.mid|Waves Files (*.wav)|*.wav|All files (*.*)|*.*|"
FileOpenDialog PlayListDLG "OpenPlayList" "Generic M3U Playlist|*.m3u"

create FileName  maxstring allot
false value Playing?


: music? ( adr len - f ) valid-sound-ext count (IsValidFileType?) ;

POPUPBAR player4-Popup-bar  \ Not yet working
    POPUP " "
((        MENUITEM     "&Play file...\tCtrl+O"    'O' +k_control pushkey ;
        MENUITEM     "Play &folder...\tCtrl+F"  'F' +k_control pushkey ;
        MENUITEM     "Play &list...\tShift+L"   'L' +k_control pushkey ;
        MENUSEPARATOR
        MENUITEM     "&Pause/Resume\tSpace"     BL pushkey ;
        MENUSEPARATOR
        MENUITEM     "&Stop/Next\tArrow down"   k_down pushkey ;
        MENUITEM     "&Rewind\tArrow left"      k_left pushkey ;
        MENUITEM     "&Forward\tArrow right"    k_right pushkey ;
        MENUSEPARATOR
        MENUITEM     "&Exit\tAlt+F4"            'Q' +k_control pushkey ;  ))
ENDBAR

internal
external

\ -----------------------------------------------------------------------------
\ MouseHandlerWindow class
\ This window is placed on top of the video window in order to handle the
\ mouse clicks
\ -----------------------------------------------------------------------------
:Object MouseHandlerWindow  <super child-window

Font vFont
40 constant FontHeight

:M ExWindowStyle:    ( -- style )
                ExWindowStyle: Super
                [ WS_EX_CLIENTEDGE WS_EX_TRANSPARENT or ] literal or ;M

:M WndClassStyle:    ( -- style )
                 \ CS_DBLCLKS only to prevent flicker in window on sizing.
                 CS_DBLCLKS ;M

:M On_Init:     ( -- )
                22 Width: vFont
                FontHeight Height: vFont
                s" Freestyle Script" SetFaceName: vFont
                Create: vFont
                ;M

: ColorBackground  ( Color - ) >r 0 0 GetSize: self 24 - r> FillArea: dc ;

:M On_Paint:    ( -- )
                FileName count music? Playing? not or
                if   SaveDC: dc                      \ save device context
                     vadr-config BlackBackGround- c@
                         if    BLACK ColorBackground
                         else  WHITE ColorBackground
                         then
                     Playing?
                         if    FileName count ExtractRecord
                               vFont    SelectObject: dc
                               TRANSPARENT SetBkMode: dc
                               ltgreen  SetTextColor: dc
                               TA_CENTER SetTextAlign: dc drop
                               GetSize: self 24 - swap 2/ swap 4 / 2dup
                               struct, InlineRecord RecordDef Artist
                               struct, InlineRecord RecordDef Cnt_Artist c@ Textout: dc
                               FontHeight +  struct, InlineRecord RecordDef Title
                               struct, InlineRecord RecordDef Cnt_Title c@ Textout: dc
                      then
                RestoreDC: dc
                then
                ;M

:M on_done:     ( -- )
                Delete: vFont
                on_done: super
                ;M

;Object

: GetLabel ( path cnt - ) VolumeLabel to /VolumeNameBuffer drop to _DriveType ;
MultiFileOpenDialog GetFilesDialog "Select File" "Media Files (*.mp3,*.midi,*.mid,*.wav,*.mpeg,*.mpg,*.mp2,*.mp4,*.mpa,*.wma,*.wmv,*.avi,*.dat)|*.mp3;*.midi;*.mid;*.wav;*.mpeg;*.mpg;*.mp2;*.mp4;*.mpa;*.wma;*.wmv;*.avi;*.dat|"

\ -----------------------------------------------------------------------------
\ define the child window for the right part of the main window
\ in this area the video's will be shown
\ -----------------------------------------------------------------------------
:Object Player4W        <Super MciChildWindow

int Pause?
int Iconic?
int list-aborted?
int catalog-aborted?
int drag-aborted?
int (UpdateTitle)

maxstring bytes title$
maxstring bytes string1$

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_ACCEPTFILES or ;M

\ -----------------------------------------------------------------------------
\ Open / play a file
\ -----------------------------------------------------------------------------
:M Playing?:    ( -- f ) \ true if we are playing a file
        Playing? ;M

:M Audio?:      ( -- f ) \ true if we are playing an audio file
        Video?: self 0= ;M

:M GetVolume:      ( -- vol )         GetVolume: MCI  ;M
:M SetVolume:      ( vol -- )         SetVolume: MCI  ;M

: ReTitle       ( addr len -- )
        WindowTitle: parent zcount title$ place ?dup
        if   s"  - " title$ +place title$ +place \ append filename
             s"  - " title$ +place GetLength: self (.ms) title$ +place
             s"  / " title$ +place GetPosition: self (.ms) title$ +place
        else drop
        then title$ count SetTitle: parent
         ;

:M Close:       ( -- ) \ stop playing
        Playing?
        if   0 0 ReTitle false to Playing?
               FileName count music? not
                 if   SW_HIDE Show: MouseHandlerWindow
                 then
             Close: super
             \ false to Playing?
        then ;M

:M Open:        ( addr len -- ) \ open a audio/video file
        2dup FileName place
        type-of-media >r
        GetShortPathName r>
        if   SW_HIDE Show: MouseHandlerWindow
             OpenVideo: super
        else OpenAudio: super
             SW_SHOW Show: MouseHandlerWindow
        then \ SW_SHOW Show: self
        ;M

:M Play:        ( n -- ) \ plays the current file from position n (ms)
        Play: super
        0     to (UpdateTitle)
        false to Pause?
        true  to Playing?
        ;M

:M PlayFile:    ( addr len -- ) \ open and play a file
        Playing?
                if      GetVolume: Self vadr-config  VolLevel !
                        Close: self
                then
        2dup file-status nip 0=
        if   \ don't try play RealPlayer files, sometimes MCI crashes on my system, when trying (dbu)
             2dup IsRealMedia?
             if   2drop
             else Open: self 0 Play: self
                  vadr-config  VolLevel @  SetVolume: Self   \ Restore the volume to VolLevel
             then
        else 2drop
        then ;M

:M AbortPlaying: ( -- )
        Close: self
        true to search-aborted?  \ abort OpenFolder: if running
        true to list-aborted?    \ abort PlayList: if running
        true to catalog-aborted? \ abort play-catalog-random: if running
        true to drag-aborted?    \ abort playing dropped files if running
        ;M

:M OpenFile:    ( -- ) \ let user choose a file and play it
        GetHandle: self Start: PlayViewDLG
        dup c@ \ ( -- a1 n1 )
        IF   AbortPlaying: self
             count PlayFile: self
        ELSE DROP
        THEN ;M

\ -----------------------------------------------------------------------------
\ -----------------------------------------------------------------------------
: PauseIfIconic ( -- ) \ pause video if iconic window
        Video?: self
        if   Iconic? GetHandle: self Call IsIconic dup to Iconic? <>
             if   Iconic?
                  if   Pause? 0= if Pause: super then
                  else Pause? 0= if Resume: super then
                  then
             then
        then ;

: FinishPlaying ( -- ) \ close video/audio if playing is finished
        Playing? Pause? 0= and
        if   Iconic? 0= Audio?: self or
             if   GetPosition: self GetLength: self >=
                  if Close: self ( SW_HIDE Show: self ) then
             then
        then ;

: UpdateTitle   ( -- ) \ update the window title once in a second
        Playing? Pause? 0= and
        if   GetPosition: self (UpdateTitle) - 1000 >= (UpdateTitle) 0= or
             if   GetPosition: self to (UpdateTitle)
                  FileName count ReTitle
             then
        then ;

:M Playing:     ( -- ) \ the main player; must be called while playing
        PauseIfIconic
        UpdateTitle
        FinishPlaying ;M

\ -----------------------------------------------------------------------------
\ Play all files in directory
\ -----------------------------------------------------------------------------
: (PlayOneFile) ( addr len -- ) \ plays a file and waits until playing is finished
        PlayFile: self \ play this file
        begin Playing: Self winpause 10 ms   \ handle the messages
              Playing? 0=      \ and wait until playing is finished
        until ;

: PlayOneFile   ( -- ) \ this is called by SDIR to play the file
        name-buf count (PlayOneFile) ;
' PlayOneFile is process-1file

:M PlayFolder:  ( addr len -- ) \ play all files in folder
        AbortPlaying: self false to search-aborted?
        s" *.*" true sdir ;M

:M OpenFolder:  ( -- ) \ let user choose a folder and play all files in it
        z" Play this folder" string0$ GetHandle: self
        BrowseForFolder
        if   string0$ count PlayFolder: self
        then ;M

\ -----------------------------------------------------------------------------
\ Play files from a 'Generic M3U' playlist file (*.m3u)
\ See: http://forums.winamp.com/showthread.php?s=&threadid=65772
\ for more information about this format.
\ -----------------------------------------------------------------------------
: MakeAbsolutePath ( addr1 len1 addr2 len2 -- addr3 len3 ) \ make path a1 n1 absolute to path a2 n2
        string0$ place string0$ +null
        string1$ place string1$ +null

        string0$ 1+ call PathRemoveFileSpec drop
        string1$ 1+ string0$ 1+ call PathAppend drop

        string0$ 1+ zcount ;

:M PlayList:    { addr len \ sfile -- } \ plays all files from the playlist-file
        AbortPlaying: self false to list-aborted?

        addr len r/o open-file swap to sfile 0=
        if   begin  pad maxstring 2 - sfile read-line 0= swap 0<> list-aborted? 0= and and
             while  pad swap addr len MakeAbsolutePath (PlayOneFile)
             repeat drop sfile close-file drop
        then ;M

:M OpenPlaylist:  ( -- ) \ let user choose a playlist-file (*.pl4)
                         \ and plays all files from the list
        GetHandle: self Start: PlayListDLG
        dup c@ \ ( -- a1 n1 )
        IF   count PlayList: self
        ELSE DROP
        THEN ;M

\ -----------------------------------------------------------------------------
\ Play files from catalog
\ -----------------------------------------------------------------------------

:M PlayFileFromCatalog: ( adr n - )
    CatalogPath  full-path
        if      turnkey? not
                        if   2dup type ."  Not found in path"
                        then
       then
    2dup file-status nip not
        if      (PlayOneFile)
        else    2drop
        then

 ;M

:M play-catalog-random: ( -- )
     database-mhndl #records-in-database vadr-config #free-list @ - 0>
     if  AbortPlaying: self false to catalog-aborted?
         begin catalog-aborted?   if   exitm   then
               Playing?: Self not
               if   next-not-played dup -1 =
                    if   vadr-config Endless- c@
                           if    EnableAllRecords randomize-catalog
                           else  exitm
                           then
                    else n>record dup>r
                         RecordDef File_name r@ Cnt_File_name c@
			 turnkey? not
				if   2dup type-cr
				then
                         r@ incr-#played r@ to #playing r> mark-played
                         PlayFileFromCatalog: Self
                    then
               then

         again
     then
     ;M

: add-to-catalog        ( -- ) \ Delete the *.dat files to start a new catalog
        z" Folder(s) to catalog"
        vadr-config PathMediaFiles dup +null GetHandle: Self
        BrowseForFolder
        If     vadr-config PathMediaFiles count GetLabel add_dir_tree
        then ;

:M Import-to-catalog:   ( -- )
        add-to-catalog ;M

:M AddFilesFromSelector:  ( - )    \ add one or more files
        GetHandle: self Start: GetFilesDialog count nip 0>
        if   vadr-config 0= if map-config-file then
             OpenAppendDatabase 0 GetFile: GetFilesDialog GetLabel
             #SelectedFiles: GetFilesDialog
             wait-cursor 0
                do   dup i GetFile: GetFilesDialog AddFile
                loop
             RemoveDuplicates
             arrow-cursor  CloseReMap  RefreshCatalog
        then ;M

\ -----------------------------------------------------------------------------
\ Play files via Drag&Drop
\ -----------------------------------------------------------------------------
: PlayDropFiles { hndl message wParam lParam \ drop$ #File -- res }
        SetForegroundWindow: self

        AbortPlaying: self false to drag-aborted?

        MAXCOUNTED 1+ LocalAlloc: drop$
        0 to #File

        0 0 -1 wParam Call DragQueryFile ?dup
        if   begin  MAXCOUNTED drop$ #File wParam Call DragQueryFile dup 0> drag-aborted? 0= and
             while  drop$ swap (PlayOneFile) 1 +to #File
             repeat drop
        then wParam Call DragFinish ;

:M WM_DROPFILES ( hndl message wParam lParam -- res )
        PlayDropFiles ;M

\ -----------------------------------------------------------------------------
\ -----------------------------------------------------------------------------
:M Pause/Resume: ( -- )
        Playing?
        if   Pause? 0= dup to Pause?
             if   Pause: super
             else Resume: super
             then
        then ;M

:M On_Init:     ( -- ) \ initialize the class
        On_Init: super            \ first init super class

        false to Pause?
        false to Playing?
        false to Iconic?
        false to list-aborted?
        false to catalog-aborted?
        false to drag-aborted?
            0 to (UpdateTitle)

        FileName maxstring erase
        title$ maxstring erase
        string1$ maxstring erase

        self Start: MouseHandlerWindow
        player4-popup-Bar SetPopupBar: MouseHandlerWindow

        ;M

:M On_Size:     ( h m w -- ) \ handle resize message
        \ resize MouseHandler-Window
        FullScreen?: self 0=
        if    0 0 Width Height Move: MouseHandlerWindow
        then

        \ resize Video-Window
        On_Size: super
        ;M

:M MCIWNDM_NOTIFYMODE ( h m w l -- res )
        case    of MCI_MODE_PAUSE   true to Pause?                   endof
                of MCI_MODE_PLAY   false to Pause?  true to Playing? endof
                of MCI_MODE_STOP   false to Pause? false to Playing? endof
        endcase \ GetZoom: MCI SetVideoSize: self
        ;M

:M MCIWNDM_NOTIFYPOS  ( h m w l -- res )
\         GetZoom: MCI SetVideoSize: self
        ;M

:M MCIWNDM_NOTIFYSIZE ( h m w l -- res )
        GetZoom: MCI SetVideoSize: self ;M

;Object

module
