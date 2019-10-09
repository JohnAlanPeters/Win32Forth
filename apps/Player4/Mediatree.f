\ $Id: Mediatree.f,v 1.38 2010/06/03 08:56:38 jos_ven Exp $

needs number.f
needs w_search.f
needs mshell_r.f
needs catalog.f
needs TreeView.F
needs struct.f
needs PopupWindow.f

0 value hItem-last-selected
defer GetPositionCatalog
Font TreeViewFont
0 value UseBigFont
0 value MaxDif

:Class MediaTree <super TreeViewControl

:M WindowStyle: ( -- style )
                WindowStyle: super
                [ WS_BORDER WS_CHILD or WS_VISIBLE or ] literal or
                [ LVS_REPORT TVS_HASLINES or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] literal or
                ;M

:M ExWindowStyle:    ( -- style )
                ExWindowStyle: Super
                [ WS_EX_CLIENTEDGE WS_EX_TRANSPARENT or ] literal or ;M


: +InlineRecord ( str cnt - )   InlineRecord  +place  s"  " InlineRecord +place ;
: +(l.int) ( n )                (l.int) +InlineRecord ;


: NotIncollection? ( n - f )
    n>record dup RecordDef Deleted- c@ 0= dup>r show-deleted =
    swap RecordDef Excluded- c@ dup r> and 1 min +to #Excluded  or
  ;

: ResetInlineRecord ( n - n vadr-config )
  1 +to #InCollection vadr-config 0 InlineRecord !
 ;

: CountedArtist   ( adr - adr count ) dup RecordDef Artist swap Cnt_Artist c@ ;
: CountedFilename ( adr - adr count ) dup RecordDef File_name swap Cnt_File_name c@ ;
: CountedAlbum    ( adr - adr count ) dup RecordDef Album  swap Cnt_Album  c@ ;
: CountedTitle    ( adr - adr count ) dup RecordDef Title  swap Cnt_Title  c@ ;

: OptionalElements    ( vadr-config rec-addr - vadr-config rec-addr )
          over l_Drivetype- c@
            if   dup RecordDef DriveType c@ DriveType$ +InlineRecord
            then
          over l_Label-     c@
            if   dup RecordDef MediaLabel over Cnt_MediaLabel c@ +InlineRecord
            then
          over l_File_size- c@
             if  dup RecordDef FileSize @ 1000 / 1 max +(l.int)  \ In KB
             then
          over l_#Random-   c@
             if  dup RecordDef RandomLevel @  +(l.int)
             then
          over l_#Played-   c@
             if  dup RecordDef #played @  +(l.int)
             then
 ;

: AddRecordFlat    ( n - )   \ Add when not deleted and found in a collection
   dup NotIncollection?
     if   drop
     else ResetInlineRecord
          dup l_Index-      c@
            if   over +(l.int)
            then
          swap dup to lParam n>record       \ ( vadr-config rec-addr - )
          OptionalElements
          swap l_Filename-  c@
             if     CountedFilename
             else   dup CountedArtist     +InlineRecord
                    s" --" +InlineRecord
                    dup CountedAlbum      +InlineRecord
                    s" --" +InlineRecord
                   CountedTitle
             then
          InlineRecord +place InlineRecord +null
          InlineRecord 1+ to pszText
          tvins 0 TVM_INSERTITEMA hWnd Call SendMessage to hInsertAfter
         then
                ;

int hPrev

: AddItemHierarical  ( sztext hAfter hParent nChildren -- hPrev )
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                                  to pszText
                tvins 0 TVM_INSERTITEMA hWnd Call SendMessage
                dup to hPrev
                ;
struct{ \ PrevMusic
        DWORD PrevMusicRecord
        DWORD hArtist
        DWORD hAlbum
}struct PrevMember

sizeof  PrevMember mkstruct: &PrevMusic
sizeof  PrevMember mkstruct: &PrevMovie
sizeof  PrevMember mkstruct: &PrevRequest

int hMovies
int hMusic
int hMovieChar
int hMusicChar
int hRequests
int OtherArtist?
int PrevRecAdr
int rec-addr
int LastChar

sizeof  RecordDef dup create dummy  allot dummy swap 01 fill

: NotPlayable ( - )     -1 to lParam ;

: root-items  ( - hPrev )
    NotPlayable TVI_LAST  TVI_ROOT 2>r
    z" Movies"    2r@ 1 AddItemHierarical to hMovies
    z" Music"     2r@ 1 AddItemHierarical dup to hMusic
    z" Requests"  2r> 1 AddItemHierarical dup to hRequests
    dummy dup &PrevMusic   ! dup &PrevMovie ! dup to LastChar &PrevRequest !
    dup &PrevMovie hArtist ! &PrevMovie hArtist !
((         z" First Artist"  hPrev     hMusic     1  AddItemHierarical to hArtist
           z" Second Music"  hPrev     hArtist    0  AddItemHierarical drop
           z" Third Music"   hPrev     hArtist    0  AddItemHierarical drop  ))
 ;

: AddNewChar  ( hMusic|hMovie hChar - hChar )
   rec-addr RecordDef Artist c@ upc dup  LastChar <>
        if      dup to LastChar 0x100 * 1+ pad !
                drop dup pad 1+ -rot 1 AddItemHierarical
        else    drop nip
        then
 ;

: hMusic/hMovie  ( - hMusic|hMovie|hChar )   \ hMovieChar
    rec-addr CountedFilename music?
       if    hMusic  vadr-config s_Artist_Title- c@  \ When sorted by artist + title
                if    hMusicChar AddNewChar dup to hMusicChar
                then
       else  hMovies true  \ sorted by rec
                if    hMovieChar AddNewChar dup to hMovieChar
                then
       then
 ;

: AddArtist ( - )
   rec-addr CountedArtist 1 max PrevRecAdr @ CountedArtist 1 max compareia 0<>
   rec-addr RecordDef Cnt_Artist c@ 0>  and
       if   rec-addr PrevRecAdr ! true to OtherArtist? NotPlayable
            rec-addr RecordDef Artist hPrev
            rec-addr RecordDef Request- c@
               if     hRequests
               else   hMusic/hMovie
            then
             1 AddItemHierarical PrevRecAdr hArtist !
       else  false to OtherArtist?
       then
 ;

: AddAlbum  ( - )
   rec-addr CountedAlbum 1 max PrevRecAdr @ CountedAlbum 1 max compareia 0<> OtherArtist? or
   rec-addr RecordDef Cnt_Artist c@ 0>  and
       if   rec-addr PrevRecAdr !  NotPlayable
            rec-addr RecordDef Album hPrev PrevRecAdr hArtist @
            1 AddItemHierarical PrevRecAdr RecordDef hAlbum !
       then
 ;

: AddTitle  ( - )
   rec-addr RecordDef CountedTitle +InlineRecord InlineRecord +null
   InlineRecord 1+ hPrev PrevRecAdr
   rec-addr RecordDef Cnt_Artist c@ 0>
      if     hAlbum @
      else   drop hMusic/hMovie
      then
   0 AddItemHierarical rec-addr RecordDef hIntree !
 ;

: AddRecordHierarical ( n - )
   dup NotIncollection? over n>record RecordDef Request- c@ not and
     if     drop
     else   >r ResetInlineRecord
            r@ n>record dup RecordDef Request- c@
               if    1 +to #requests  &PrevRequest
               else  dup CountedFilename music?
                      if    &PrevMusic
                      else  &PrevMovie
                      then
               then   \  ( n vadr-config rec-addr PrevRecAdr - )
            to PrevRecAdr to rec-addr
            AddArtist
            AddAlbum
            dup l_Index- c@
                if   r> dup +(l.int)
                else r>
                then
            to lParam
            rec-addr OptionalElements 2drop
            AddTitle
     then
 ;

:M FillTreeView:  ( -- )
                TVI_ROOT DeleteItem: self \ delete all items from the tree view
                0 to #Excluded
                0 to #InCollection
                0 to #requests
                0 to last-selected-rec
                tvins  /tvins  erase
                TVI_ROOT to hParent
                [ TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or TVIF_STATE or ] literal to mask
                vadr-config l_Filename-  c@
                if      1 to cChildren TVI_LAST to hInsertAfter
                        for-all-records AddRecordFlat
                else    root-items to hPrev
                        0 to hMovieChar 0 to hMusicChar
                        for-all-records AddRecordHierarical
                        hMovies TVGN_CARET SelectItem: Self
                then
                ;M

:M Start:       ( Parent -- )
                Start: super
                -1 to last-selected-rec
                ;M

: StartPopupWindow ( -- )
        last-selected-rec n>record CountedFilename IsValidFileType?
          if   hWnd dup get-mouse-xy
               GetPositionCatalog
               rot + >r + r>
               Start: PopupWindow
          then
          ;

:M GetLparm:    ( hItem - lParm )
                to hItem
                TVIF_PARAM
                TVIF_HANDLE or  to mask
                0               to pszText
                0               to cchTextMax
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop
                hItem       to hItem-last-selected
                lParam    \ cr .s
 ;M

:M On_SelChanged: ( -- )
                hItemNew    GetLparm: Self
                dup to last-selected-rec -1 <>
                if    MaxDif not
                        if      StartPopupWindow
                        then
                then
                ;M

:M On_RightClick: ( -- )
               On_SelChanged: self
                ;M

\ :M ~:   ( -- )
\         GetHandle: self call DestroyWindow drop ;M

;Class

\ -----------------------------------------------------------------------------
\ define the child window for the left part of the main window
\ in this area the catalog will be shown
\ -----------------------------------------------------------------------------
:Object Catalog        <Super Child-Window

MediaTree TreeView
int EnableNotify?

: SendToTreeView  ( lparm wparm msg -- ) GetHandle: TreeView CALL SendMessage drop ;

:M SetBlackBackGround:  (  - )
               Color: Black     0 TVM_SETBKCOLOR    SendToTreeView
               Color: ltYellow  0 TVM_SETTEXTCOLOR  SendToTreeView
               ;M

:M SetWhiteBackGround:  (  - )
               Color: White     0 TVM_SETBKCOLOR    SendToTreeView
               Color: Black     0 TVM_SETTEXTCOLOR  SendToTreeView
               ;M

:M SetfontTreeView:  (  - )
                UseBigFont
                        if   24 32
                        else  8 16
                        then
                Height: TreeViewFont
                Width:  TreeViewFont
                s" Times New Roman (TrueType)" SetFaceName: TreeViewFont
                Create: TreeViewFont
                true Handle: TreeViewFont WM_SETFONT SendToTreeView
                vadr-config BlackBackGround- c@
                     if     SetBlackBackGround: Self  \ A black background and a yellow font.
                     else   SetWhiteBackGround: Self  \ Default: A white background and a black font.
                     then
                ;M

:M Start:       ( Parent -- )
                Start: super
                 false to UseBigFont SetfontTreeView: Self
                 0 to MaxDif
                ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

: AddDropFiles {  hDrop \ drop$ #File wHndl -- res }
        SetForegroundWindow: self
        wait-cursor
        MAXCOUNTED 1+ LocalAlloc: drop$
        0 to #File
        0 0 -1 hDrop  Call DragQueryFile  ?dup
           if  datfile$ count file-exist? check-config
               MAXCOUNTED drop$ 0 hDrop Call DragQueryFile
               drop$ swap GetLabel
               OpenAppendDatabase to wHndl
                   begin    MAXCOUNTED drop$ #File hDrop Call DragQueryFile dup 0>
                   while    wHndl drop$ rot AddFile  1 +to #File
                   repeat
          then
        2drop hDrop Call DragFinish
        wHndl CloseReMap
        RemoveDuplicates
        RefreshCatalog ;

:M WM_DROPFILES ( hDrop lParam -- res )
        drop AddDropFiles  ;M


:M SelectTreeViewItem:  ( hitem - )
    dup 0<>
         if     TVGN_CARET SelectItem: TreeView
         else   drop
         then
 ;M

:M GetLparm:            ( - hItem )   GetLparm: TreeView ;M
:M GetSelectedItem:     ( - hItem )   0 TVGN_CARET GetNextItem: TreeView ;M

:M DownInTree:        ( - )
   GetSelectedItem: Self   TVGN_NEXT GetNextItem: TreeView
   SelectTreeViewItem: Self
 ;M

:M UpInTree:          ( - )
   GetSelectedItem: Self GetPrevious: TreeView
   SelectTreeViewItem: Self
;M

:M OpenChild:        ( - )
   GetSelectedItem: Self   GetChild: TreeView
   SelectTreeViewItem: Self
 ;M

:M CloseChild:        ( - )
   GetSelectedItem: Self    GetParentItem: TreeView
   Collapse: TreeView
 ;M

:M On_Init:     ( -- )
        On_Init: super
        self Start: TreeView
        true to EnableNotify?
        ;M

:M On_Size:     ( -- )
        AutoSize: TreeView ;M

:M Refresh:     ( -- )
        MciDebug? if cr ." Fill-time: " timer-reset then
        wait-cursor

        EnableNotify? false to EnableNotify?

        SW_HIDE Show: TreeView    \ hide,
        FillTreeView: TreeView    \ fill,
        SW_RESTORE Show: TreeView \ and show it

        to EnableNotify?

        arrow-cursor
        MciDebug? if .elapsed then
        ;M

:M WM_NOTIFY    ( h m w l -- f )
        dup @ GetHandle: TreeView = EnableNotify? and
        if   Handle_Notify: TreeView
        else false
        then ;M

:noname ( -- )
        vadr-config RequestLevel c@
        last-selected-rec dup EnableKeptRequest
        n>record dup>r RecordDef RequestLevelRecord c!
        1 r> RecordDef Request- c!
        1 +to #requests
        0 to last-selected-rec
        ;  is RequestRecord

;Object



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       End of File
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\s


