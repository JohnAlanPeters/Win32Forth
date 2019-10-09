\ $Id: HelpTestTV.f,v 1.4 2011/11/18 01:51:40 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008
\ (large parts from ClassBrowser.f)

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ This file is used to test a treeview-structure-text-file before launching the
\ whole help stuff. Mainly to be used after a modification of HelpSummary.tv
\ (Appends the TVdata to the TVname in the TV for debugging purpose)
\ May also be used for checking other TV : change filename in (LoadTV)
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------


anew -HelpTestTV


needs FileParser.f
needs HelpFiles.f
needs TreeView.f
needs RegistryWindowPos.f


\ ------------------------------------------------------------------------------
\ evaluate text-treeview-structure-file lines
\ ------------------------------------------------------------------------------

create TVLineBuff 250 allot

: GetTVLine     ( -- zTVname+TVdata tvdepth -1 | 0 ) \ 0 = end of file
                0 TVLineBuff c!
                GetWord dup 0= if 2drop 0 exit then
                evaluate                                   \ TV depth
                s" TVN|" SearchWord
                if   s" | " GetString TVLineBuff place     \ TV name
                then
                s" __" TVLineBuff +place
                s" TVD|" SearchWord                        \ TV data
                if s" | " GetString TVLineBuff +place then
                TVLineBuff +null                           \ as zstring
                TVLineBuff 1+ swap -1 ;

create parsefile 200 allot


\ ------------------------------------------------------------------------------
\ treeview control
\ ------------------------------------------------------------------------------

:Class ClassBrowserWindow <super TreeViewControl

:M WindowStyle: ( -- style )      \ set the windowstyle for the treeview
                WindowStyle: super
                [ TVS_HASBUTTONS TVS_HASLINES or TVS_DISABLEDRAGDROP or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] literal
                or ;M

int hPrev

: AddItem       ( sztext hAfter hParent nChildren fChildren -- ) \ add an entry to the treeview
                tvins  /tvins  erase
                >r
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                ( sztext)         to pszText
                [ TVIF_TEXT ] literal
                r> if TVIF_CHILDREN or then
                to mask
                tvins 0 TVM_INSERTITEMA hWnd Call SendMessage
                to hPrev ;

: /Children     ( hitem -- )
                tvins  /tvins  erase
                    to hitem
                0   to cChildren
                [ TVIF_HANDLE TVIF_CHILDREN or ] literal
                to mask
                SetItem: self ;

create text$ maxstring allot
variable textcount

:M GetItem:     ( hitem -- )
                TVIF_TEXT        to mask
                ( hItem)         to hItem
                text$            to pszText
                maxstring        to cchTextMax
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop
                text$ zcount textcount ! drop ;M

int curDepthTV
int newDepthTV
int TVI_

: SORT/LAST     ( -- tviorder )
                TVI_ if TVI_LAST else TVI_SORT then ;

: (LoadTV)      ( htvroot -1 [ ...htvitem tvdepth...] -- )
                \ each new level is pushed on stack and removed when tvdepth decrease
              \ s" c:\win32Forth\Help\hdb\HelpCls.tv"
              \ s" c:\win32Forth\Help\hdb\HelpWrd.tv"
                s" hdb\HelpSummary.tv"
                parsefile place parsefile +null
                parsefile count r/w open-file
                0<> if abort" Couldn't open ???.tv" then
                ( fileid) ParseInit
                true to SkipComment?
                begin
                      GetTVLine
                      while
                      dup 0< if negate false else true then to TVI_
                      to newDepthTV                     \ -- ...htvitem tvdepth zname+data
                      newDepthTV curDepthTV =           \ ***** TV DEPTH IS SAME
                      if   SORT/LAST 5 pick
                           1 true AddItem               \ transiently has children
                           swap /Children               \ previous has no child
                           hprev swap                   \ update current level
                      else newDepthTV curDepthTV >      \ ***** TV DEPTH INCREASES
                           if   newDepthTV to curDepthTV
                                SORT/LAST 3 pick
                                1 true AddItem          \ transiently has children
                                hprev newDepthTV        \ push new level
                           else >r                      \ ***** TV DEPTH DECREASES
                                over /Children          \ previous has no child
                                begin dup newDepthTv >  \ pop previous levels
                                while 2drop
                                repeat
                                newDepthTV to curDepthTV
                                r>
                                SORT/LAST 5 pick
                                1 true AddItem          \ transiently has children
                                nip hprev swap          \ update previous level
                      then then
                repeat
                ParseFileId close-file drop
                over /Children            \ sure that last item has no child
                begin dup -1 >            \ pop remaining levels
                while 2drop
                repeat ;

: LoadTv        ( -- ) \ load treeview form treeview-structure-text-file
                -1 to curDepthTV
                TVI_ROOT -1 (LoadTv) 2drop ;

:M Update:	( -- )
                LoadTV ;M

:M Start:       ( Parent -- )     \ create the treeview
                Start: super ;M
;Class


\ ------------------------------------------------------------------------------
\ the main window
\ ------------------------------------------------------------------------------

:Object ClassBrowser  <super Window

int TreeView
create RegPath$ ," ClassBrowser\"

:M On_Init:     ( -- )
                On_Init: super
                New> ClassBrowserWindow to TreeView
                1001 SetId: TreeView
                self Start: TreeView
                ;M

:M On_Done:     ( -- )
                hWnd RegPath$ SaveWindowPos
                On_Done: super
                ;M

:M WindowTitle: ( -- sztitle )
                z" Win32Forth - Class and vocabulary browser" ;M

:M StartSize:   ( -- w h )
                RegPath$ LoadWindowPos 2nip
                ;M

:M StartPos:    ( -- x y )
                RegPath$ LoadWindowPos 2drop
                ;M

: AdjustWindowSize      { width height win -- }
                SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                win Call SetWindowPos drop ;

:M On_Size:     ( -- )
                \ adjust the TreeView
                winRect GetClientRect: self
                Left: winRect Top: winRect Right: winRect
                Bottom: winRect
                Move: TreeView ;M

:M WM_NOTIFY    ( h m w l -- f )
                dup  @ GetHandle: TreeView  =
                if   Handle_Notify: TreeView
                else false
                then ;M

:M Update:      ( -- )
                IDC_WAIT NULL call LoadCursor call SetCursor \ set wait cursor
                Update: TreeView      \ fill treeview
                call SetCursor drop   \ restore cursor
                ;M
;Object


:noname  	( -- )
                Start: ClassBrowser
                Update: ClassBrowser
                ; is class-browser

cr .( 'Class browser' loaded )

class-browser

