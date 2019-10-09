\ $Id: HelpWindow.f,v 1.9 2011/11/18 01:32:27 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008


\ ------------------------------------------------------------------------------
\ ---------------------------- help system - window ----------------------------
\ ------------------------------------------------------------------------------


anew -HelpWindow.f


needs linklist.f        \ help tv data
needs bitmap.f          \ toolbar and treeview images
needs toolbar.f         \ main toolbar
needs statusbar.f
needs treeview.f        \ help and word treeviews
needs tabcontrol        \ tab control
needs listBox.f         \ words index ListBox

needs TextBox.f         \ quick info

needs ScintillaHyperEdit.f
needs HtmlControl


\ ------------------------------------------------------------------------------
\ values which will contain the objects of sub-windows :
\ ------------------------------------------------------------------------------

                               0 value HNewHelp ( main)
                               0 value HToolBar
                               0 value HStatusBar
                               0 value HSplitter
         0 value HLeftPane                                  0 value HTopPane
         0 Value HTabControl                                0 value HEditQuick
0 value HHelpTV  0 value HWordTV  0 value HEditBox
( 0 value HHelpHtmlList)         ( 0 value HWordListBox)    0 value HBottomPane
                                                            0 value HHtmlBox
                                                            0 value HViewBox

\ ------------------------------------------------------------------------------
\ Actual program doers
\ ------------------------------------------------------------------------------

0 Value Currentn0rec
create CurrentSource 254 allot
0 value currentline

Create QuickInfoBuff 8200 allot
0 value QuickInfoCount
Create +crlf 2 c, 0x0D c, 0x0A c,

: Info+Place    ( addr cnt -- )
                QuickInfoBuff QuickInfoCount + swap
                dup +to QuickInfoCount
                cmove ;

: QuickInfo     ( n0recinHelpWrd.hdb -- ) \ display quick info for a word
                dup to Currentn0rec                      \ save current n0rec
                HelpWord vaddr HelpWord SizeOf rot
                HelpWrd.hdb ReadRec                      \ read info from HelpWrd.hdb
                if -1 abort" Read error in HelpWrd.hdb" then
                0 to QuickInfoCount
                HelpWord WordDepr? v@                    \ first line = general info
                if s" DEPRECATED !" Info+Place then
                HelpWord WordImm? v@
                if s"   Immediate" Info+Place then
                HelpWord WordVoc v@ ?dup
                if   s"   " Info+Place
                     HelpVoc[] VocName v@ count Info+Place
                then
                HelpWord WordSrc v@ ?dup
                if   s"   " Info+Place
                     HelpSrc[] SrcName v@ count
                     2dup Info+Place
                     &forthdir count CurrentSource place \ save current source
                     CurrentSource +place
                     CurrentSource +null
                then
                HelpWord WordLine v@ ?dup
                if   dup to CurrentLine                  \ save current line#
                     s"   Line: " Info+Place
                     0 (D.) Info+Place
                then
                HelpWord WordAns v@ ?dup
                if   s"   " Info+Place
                     HelpAns[] AnsInfo v@ count Info+Place
                then
                +crlf count Info+Place
                +crlf count Info+Place
                HelpWord vaddr HelpWord SizeOf
                rot HelpWrd.hdb ReadRec
                if -1 abort" Read error in HelpWrd.hdb" then

                HelpWord WordFrom v@                  \ add HelpWrd.txt lines
                HelpWrd.txt FSeek
                if -1 abort" Seek error in HelpWrd.txt" then
                QuickInfoBuff QuickInfoCount +        \ buffer
                HelpWord WordTo v@
                HelpWord WordFrom v@ -                \ #bytes
                HelpWrd.txt FilChan @
                read-file
                if drop -1 abort" Read error in HelpWrd.txt" then
                +to QuickInfoCount
                0 QuickInfoBuff QuickInfoCount + c!
                QuickInfoBuff                         \ addr z whole info
\ cr dup QuickInfoCount 20 + dump \ ??? to be removed when editbox or textbox works
                SetTextZ: HEditQuick ;                \ display

: /QuickInfo    ( -- ) \ clear quick info
                0 to CurrentN0rec
                HEditQuick if z" " SetTextZ: HEditQuick then ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ Load images for toolbar and treeview objects
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

load-bitmap HelpBitmap "help\res\HelpImages.bmp"   ( ??? path, seems to be ok)


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ Toolbar
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

NextID constant IDM_DUMMY
NextID constant IDM_PREVIOUS
NextID constant IDM_BACKWARDS
NextID constant IDM_FORWARDS
NextID constant IDM_COPY
NextID constant IDM_VIEW

:ToolStrings HToolBarTips
        ts,"  " \ an empty string is illegal !!!
        ts,"  "
        ts," Previous html page"
        ts," Next help treeview page"
        ts," Previous help treeview page"
        ts,"  "
        ts," Copy to clipboard"
        ts," View source"
;ToolStrings

:ToolBarTable HToolBarTable
\ Bmp index   ID          Initial Style    Initial State     Tooltip Ndx
  0        IDM_DUMMY      0                TBSTYLE_BUTTON    0 ToolBarButton,
  0        IDM_DUMMY      0                TBSTYLE_BUTTON    1 ToolBarButton,
 11        IDM_PREVIOUS   TBSTATE_ENABLED  TBSTYLE_BUTTON    2 ToolBarButton,
 12        IDM_BACKWARDS  TBSTATE_ENABLED  TBSTYLE_BUTTON    3 ToolBarButton,
 13        IDM_FORWARDS   TBSTATE_ENABLED  TBSTYLE_BUTTON    4 ToolBarButton,
  0        IDM_DUMMY      0                TBSTYLE_BUTTON    5 ToolBarButton,
 10        IDM_COPY       TBSTATE_ENABLED  TBSTYLE_BUTTON    6 ToolBarButton,
  7        IDM_VIEW       TBSTATE_ENABLED  TBSTYLE_BUTTON    7 ToolBarButton,
;ToolBarTable

8  value #HTools           \ could be changed by app


:Object _HToolBar        <Super Win32Toolbar

int hbitmap

:M ClassInit:   ( -- )
                ClassInit: super
                0 to hbitmap
                ;M

:M Start:      ( parent -- )
               HToolBarTable    IsButtonTable: self
               HToolBarTips     IsTooltips: self

               Start: super                      \ ??? need be after setting table and tips

               16 16 word-join 0 TB_SETBITMAPSIZE hwnd
               call SendMessage drop             \ smaller height of toolbar

               HelpBitmap usebitmap
               map-3Dcolors                      \ use system colors for background
               GetDc: self
               dup CreateDIBitmap to hbitmap     \ create bitmap handle from memory image
               ReleaseDc: self
               hbitmap                           \ do we have a handle?
               if 0 hbitmap #HTools AddBitmaps: self drop then
               ;M

:M WindowStyle: ( -- style )
                \ WindowStyle: super      \ ??? doesn't work
                WS_CHILD                  \ not WS_VISIBLE - start hidden
                TBSTYLE_TOOLTIPS or
                TBSTYLE_FLAT  or
                ;M

:M On_Done:     ( -- )
                hbitmap
                if   hbitmap Call DeleteObject drop
                     0 to hbitmap
                then
                On_Done: super ;M
;Object


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ StatusBar
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

:Object _HStatusBar  <Super Statusbar

:M SetText:	( addr count -- )
                pad place pad +null pad 1+
                SetText: super
		;M

:M On_Init:     ( -- ) \ things to do at the start of wdw creation
\               On_Init: super            \ ??? not understood by class
		Clear: self
                Show: self
                ;M
;Object


\ ------------------------------------------------------------------------------
\ evaluate treeview-structure-text-file lines
\ ------------------------------------------------------------------------------

create TVLineBuff 150 allot
create TVDataBuff 150 allot

: GetTVLine     ( -- zname addrdata cntdata tvdepth -1 | 0 ) \ 0 = end of file
                GetWord dup 0= if 2drop 0 exit then
                >Num                                      \ TV depth
                s" TVN|" SearchWord
                if   s" | " GetString TVLineBuff place    \ TV name
                     TVLineBuff +null                     \ as zstring
                then
                s" TVD|" SearchWord                       \ TV data
                if s" | " GetString TVDataBuff place then \ as addr cnt
                >r TVLineBuff 1+ TVDataBuff count r> -1 ;


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ The words treeview class : data = n0 record of word in HelpWrd.hdb
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:Class _HWordTV  <super TreeViewControl

                \ ------------------------------------------ general settings
:M WindowStyle: ( -- style )
                WindowStyle: super
                [ TVS_HASBUTTONS TVS_HASLINES or TVS_DISABLEDRAGDROP or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] literal
                or ;M

                \ ------------------------------------------ fill the treeview
int hPrev

: AddItem       ( n0rec sztext hAfter hParent nChildren fChildren -- )
                \ add an entry to the treeview
                tvins  /tvins  erase
                >r
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                ( sztext)         to pszText
                ( n0rec)          to lParam
                [ TVIF_TEXT TVIF_PARAM or ] literal
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

: (LoadWrdTV)   ( htvroot -1 [ ...htvitem tvdepth...] -- )
                \ each new level is pushed on stack and removed when tvdepth decreases
                HelpWrd.tv fopen
                0<> if abort" Couldn't open HelpWrd.tv" then
                HelpWrd.tv FilChan @ ( fileid) ParseInit
                true to SkipComment?
                begin
                      GetTVLine
                      while
                      dup 0< if negate false else true then to TVI_
                      to newDepthTV
                      >Num                      \ addr cnt > n0record in HelpWrd.hdb
                      swap                      \ -- ...htvitem tvdepth data zname
                      newDepthTV curDepthTV =           \ ***** TV DEPTH IS SAME
                      if   SORT/LAST 6 pick
                           1 true AddItem               \ transiently has children
                           swap /Children               \ previous has no child
                           hprev swap                   \ update current level
                      else newDepthTV curDepthTV >      \ ***** TV DEPTH INCREASES
                           if   newDepthTV to curDepthTV
                                SORT/LAST 4 pick
                                1 true AddItem          \ transiently has children
                                hprev newDepthTV        \ push new level
                           else 2>r                     \ ***** TV DEPTH DECREASES
                                over /Children          \ previous has no child
                                begin dup newDepthTv >  \ pop previous levels
                                while 2drop
                                repeat
                                newDepthTV to curDepthTV
                                2r>
                                SORT/LAST 6 pick
                                1 true AddItem          \ transiently has children
                                nip hprev swap          \ update previous level
                      then then
                repeat
                HelpWrd.tv fclose drop
                over /Children            \ sure that last item has no child
                begin dup -1 >            \ pop remaining levels
                while 2drop
                repeat ;

: LoadWrdTv     ( -- ) \ load treeview from treeview-structure-text-file
                -1 to curDepthTV
                TVI_ROOT -1 (LoadWrdTv) 2drop ;

:M Update:	( -- )
                LoadWrdTV
                ;M

                \ ------------------------------------------ handle selections
:M On_SelChanged: ( -- f ) \ display quick info for selected word
                hItemNew to hItem
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop
                lParam ( n0index) ?dup
                if QuickInfo then
                false ;M

                \ ------------------------------------------ wdw creation / deletion
:M Start:       ( Parent -- )     \ create the treeview
                Start: super
                ;M
;Class



\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ The html treeview-data linked list class
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

: right$        ( addr cnt char -- addr' cnt' )
                \ Example: s" c:\dir\file.ext" ascii \ right$ gives "file.ext"
                \ Example: s" aaaa.ext" ascii \ right$ gives "aaaa.ext"
                >r swap over + over r> -scan ?dup
                if   rot swap - 1- swap 1+ swap
                else swap
                then ;

\ ------------------------------------------------------------------------------
\ Html-help links list as treeviewitems
\ ------------------------------------------------------------------------------

0 Value img1     \ selected / not selected  TV images, set in setname: below and
0 Value img2     \ used in TV additem

:Class HtmlListItem   <super Object
max-path 2 + bytes htmlfilename
:M classinit:   ( -- )
                classinit: super
                htmlfilename max-path 2 + erase ;m
:M setname:     ( addr cnt -- )
                2dup 7 min s" mailto:" compare 0= >r
                2dup 5 min s" news:"   compare 0= r> or >r
                2dup 7 min s" http://" compare 0= r> or   \ if web link,
                if   htmlfilename place                   \ get unchanged name
                     5 to Img1 5 to Img2
                else &forthdir count htmlfilename place   \ else prepend &ForthDir
                     htmlfilename +place
                     htmlfilename +null
\ ??? todo : do upper in another string
                     htmlfilename count [char] \ right$   ( right$ is not a comment )
                     2dup upper
                     s" W32F-TODO.HTM" compare 0=
                     if   4 to Img1 4 to Img2
                     else htmlfilename count [char] . right$
                          2dup upper
                          s" PDF" compare 0=
                          if   6 to Img1 6 to Img2
                          else 3 to Img1 3 to Img2
\ ??? todo try an open & close ( well, we should have to follow ALL sub-links...)
                     then then
                then ;m
:m getname:     ( -- addr cnt )
                htmlfilename count ;m
;class


:class HtmlList  <super linked-list
:m classinit:   ( n addr cnt --)
                classinit: super ;m
:m AddItem:     ( addr count -- n0listitem )
                Link#: self -rot               \ beware: addlink: increases link#
                new> HtmlListItem Data!: self  \ beware: empty list has one link !!!
                setname: [ Data@: self ]
                addlink: self
                ;m
:m GetData:     ( currentlink# -- addr cnt )
                >Link#: self
                getname: [ Data@: self ] ;m
((
:m ShowList:    ( -- )
                >FirstLink: self
                #links: self 0 do
                  cr Link#: self .
                  Data@: self 0<>
                  if
                       ."  "  Data@: self .    getname: [ Data@: self ] type
                  then
                  >NextLink: self
                loop ;m
))
;class

HtmlList HelpHtmlList


\ ------------------------------------------------------------------------
\ Handle StatusBar display
\ ------------------------------------------------------------------------

0 value CurrentHtmlIndex

: HtmlStatusBar ( -- ) \ show html file in statusabar
                GetHandle: HStatusBar
                if   CurrentHtmlIndex ?dup
                     if   GetData: HelpHtmlList          \ currentlink# -- addr cnt
                          2dup SetText: HStatusBar
\ cr ." HNewHelp " HNewHelp .
\ HNewHelp "Web-link              \ if we use full IE as browser
                          ShowHtml: HBottomPane
                then then ;

create CurrentViewFile 255 allot

: ViewStatusBar ( -- ) \ show view file in statusabar
                GetHandle: HStatusBar
                if   CurrentViewFile count ?dup
                     if SetText: HStatusBar else drop then
                then ;

: /StatusBar    ( -- ) \ clear statusbar
                GetHandle: HStatusBar if Clear: HStatusBar then ;


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ The help treeview class (tv data = list item)
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:Class _HHelpTV  <super TreeViewControl

int HHelpTVImages   \ handle to imagelist

                \ ------------------------------------------ general settings
:M WindowStyle: ( -- style )
                WindowStyle: super
                [ TVS_DISABLEDRAGDROP TVS_SHOWSELALWAYS or ] literal
                or ;M

                \ ------------------------------------------ fill the treeview
int hPrev

: AddItem       ( n0rec sztext hAfter hParent nChildren fChildren -- )
                \ add an entry to the treeview
                tvins  /tvins  erase
                >r
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                ( sztext)         to pszText
                ( n0rec)          to lParam
                Img1              to iImage
                Img2              to iSelectedImage
                [ TVIF_TEXT TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE or ] literal
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

int curDepthTV
int newDepthTV
int TVI_

: SORT/LAST     ( -- tviorder )
                TVI_ if TVI_LAST else TVI_SORT then ;

: (LoadHlpTV)   ( htvroot -1 [ ...htvitem tvdepth...] -- )
                \ each new level is pushed on stack and removed when tvdepth decreases
                classinit: HelpHtmlList
                HelpSummary.tv fopen
                0<> if abort" Couldn't open HelpSummary.tv" then
                HelpSummary.tv FilChan @ ( fileid) ParseInit
                true to SkipComment?
                begin
                      GetTVLine
                      while
                      dup 0< if negate false else true then to TVI_
                      to newDepthTV
                      dup 0=                            \ if html filename cnt=0
                      if   2drop 0                      \ tv data = 0
                           1 to Img1 1 to Img2
                      else AddItem: HelpHtmlList        \ else tv data = n0listitem
                      then                              \ (also set Img1 and Img2)
                      swap                      \ -- ...htvitem tvdepth data zname
                      newDepthTV curDepthTV =           \ ***** TV DEPTH IS SAME
                      if   SORT/LAST 6 pick
                           1 true AddItem               \ transiently has children
                           swap /Children               \ previous has no child
                           hprev swap                   \ update current level
                      else newDepthTV curDepthTV >      \ ***** TV DEPTH INCREASES
                           if   newDepthTV to curDepthTV
                                SORT/LAST 4 pick
                                1 true AddItem          \ transiently has children
                                hprev newDepthTV        \ push new level
                           else 2>r                     \ ***** TV DEPTH DECREASES
                                over /Children          \ previous has no child
                                begin dup newDepthTv >  \ pop previous levels
                                while 2drop
                                repeat
                                newDepthTV to curDepthTV
                                2r>
                                SORT/LAST 6 pick
                                1 true AddItem          \ transiently has children
                                nip hprev swap          \ update previous level
                      then then
                repeat
                HelpSummary.tv fclose drop
                over /Children            \ sure that last item has no child
                begin dup -1 >            \ pop remaining levels
                while 2drop
                repeat ;

: LoadHlpTv     ( -- ) \ load treeview from treeview-structure-text-file
                -1 to curDepthTV
                TVI_ROOT -1 (LoadHlpTv) 2drop ;

:M Update:	( -- )
                LoadHlpTV
                ;M

                \ ------------------------------------------ handle selections
:M On_SelChanged: ( -- f ) \ display html page for selected item
                hItemNew to hItem
                TVIF_PARAM       to mask
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop
                lParam ( listitem) ?dup
                if to CurrentHTMLIndex HtmlStatusBar then
                false ;M

                \ ------------------------------------------ handle expanse/collapse
:M SetImage:    ( hitem iImage -- )
                tvins  /tvins  erase
                dup to iImage
                    to iSelectedImage
                    to hitem
                [ TVIF_HANDLE TVIF_IMAGE or TVIF_SELECTEDIMAGE or ] literal to mask
                SetItem: self ;M

:M On_ItemExpanded: ( -- f )   \ f=true, don't expand/collapse, f=false, ok go ahead
                hItemNew                  to hItem
                TVIF_STATE TVIF_HANDLE or to mask
                TVIS_EXPANDED             to stateMask
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop
                \ state [ TVIS_SELECTED TVIS_EXPANDED or ] literal =
                \ state [ TVIS_SELECTED TVIS_EXPANDED or TVIS_EXPANDEDONCE or ] literal = or
                \ state [ TVIS_SELECTED TVIS_EXPANDEDONCE or ] literal = or
                state dup 34 = swap 98 = or state 66 = or
                if   \ state [ TVIS_SELECTED TVIS_EXPANDEDONCE or ] literal = or
                     state 66 =
                     if   hitem 1 SetImage: self     \ item just collapsed imageindex=1
                     else hitem 2 SetImage: self     \ item just expanded  imageindex=2
                then then
                false
                ;M

                \ ------------------------------------------ wdw creation / deletion
: CreateImageList ( -- )    \ create image list for treeview control
                8               \ maximum images
                7               \ number of images to use
                ILC_COLOR4      \ color depth
                18 16           \ bitmap size height,width
                Call ImageList_Create to HHelpTVImages ;

: AddImages     { \ ptreebmp -- }
                HHelpTVImages 0= ?exit    \ we don't have any
                HelpBitMap usebitmap      \ create bitmap handle
                GetDc: self dup>r CreateDIBitmap to ptreebmp
                r> ReleaseDc: self
                ptreebmp                  \ was it successful?
                if   NULL                 \ no overlay image list
                     ptreebmp
                     HHelpTVImages
                     Call ImageList_Add -1 = s" Add images failed!" ?messagebox
                     ptreebmp Call DeleteObject drop \ discard, windows has a copy
                then ;

: RegisterList  ( -- )   \ register imagelist with this treeview control
                HHelpTVImages ?dup 0= ?exit
                TVSIL_NORMAL SetImageList: self ;

:M Start:       ( Parent -- )     \ create the treeview
                Start: super
                CreateImageList
                AddImages
                RegisterList
                ;M

:M Classinit:   ( -- )
                Classinit: super
                0 to HHelpTVImages ;M

:M Close:       ( -- )
                HHelpTVImages ?dup
                if   Call ImageList_Destroy drop
                     0 to HHelpTVImages
                then
                Close: super ;M
;Class


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ A refined ListBox class
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:class _HListBox <super ListBox

:M WindowStyle: ( -- style )
                WindowStyle: super
                [ LBS_NOTIFY WS_BORDER or WS_VSCROLL or ] literal or
                ;M

:M SetTopIndex: ( n -- ) \ set the index of first displayed item when scrolling
                0 swap LB_SETTOPINDEX SendMessage:SelfDrop ;M

:M Update:      ( -- )
                #Wrd @ 1+ 1 do
                  i HelpWrd[] WordName v@
                  count pad place
                  i HelpWrd[] WordExtra v@ ?dup
                  if   s"   " pad +place
                       HelpWrd[] WordName v@
                       count pad +place
                  then
                  pad +null
                  pad 1+
                  AddString: self
                loop ;M

:M Start:	( Parent -- )
	        Start: super
	        DEFAULT_GUI_FONT call GetStockObject SetFont: self
	        ;M
;class


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ A refined TabControl class
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:class TabControlEx <super TabControl

:M Start:	( Parent -- )
	        TCS_MULTILINE AddStyle: self
	        Start: super
	        DEFAULT_GUI_FONT call GetStockObject SetFont: self
	       ;M

:M On_Paint:    ( -- )
                ClientSize: self WHITE FillArea: [ Getdc: self ] ;M
;class



\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ Define the left part (tabs) of the splitter window.
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

\ some helper words
\ -----------------

: GetNotifyWnd  ( addr -- hWnd )
                \ Get the window handle to the control sending a WM_NOTIFY message.
                @ ;

: GetNotifyId   ( addr -- Id )
                \ Get the identifier of the control sending a WM_NOTIFY message.
                cell+ @ ;

: GetNotifyCode ( addr -- Code )
                \ Get the notification code of the control sending a WM_NOTIFY message.
                2 cells + @ ;


0 constant HELP_TAB
1 constant WORD_TAB
2 constant INDEX_TAB

create findbuf 150 allot

_HListBox      HWordListBox \ the story...

\ You are trying "GetSelection: HWordListBox" from within your myWmCHAR function,
\ which in turn is executed from within your editcontrol HEditBox. Trying to access
\ a local instance from within another local instance is a no-no. That's why
\ "GetSelection: HWordListBox" returns 0. The solution is to make HWordListBox an
\ instance object outside your _HLeftPane child window object i.e make it global.

:Object _HLeftPane        <Super Child-Window

TabControlEx   HTabControl
_HHelpTV       HHelpTV
_HWordTV       HWordTV
EditControl    HEditBox

                \ ------------------------------------------ general settings
:M WndClassStyle: ( -- style )  CS_DBLCLKS      ;M
:M ExWindowStyle: ( -- style )  ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M


                \ ------------------------------------------ wdw resize & reposition
:M ReSize:	( -- ) \ Resize controls within window.
                AutoSize: HTabControl
                ClientSize: HTabControl 2over d- ( x y w h )
                4dup Move: HHelpTV
                4dup Move: HWordTV
                4dup drop 24 Move: HEditBox
 	        4dup rot 24 + -rot 24 - Move: HWordListBox
                4drop ;M

:M On_Size:	( -- )
                GetHandle: HTabControl if ReSize: self then ;M

                \ ------------------------------------------ show selected tab
:M On_Paint:    ( -- )
                0 0 Width Height WHITE FillArea: dc ;M

:M ShowHelpTV:  ( -- )
                SW_SHOW Show: HHelpTV   \ show before hide
HHtmlBox if SW_SHOW Show: HHtmlBox then
HViewBox if SW_HIDE Show: HViewBox then
HtmlStatusBar
true  IDM_PREVIOUS  EnableButton: HToolBar
true  IDM_BACKWARDS EnableButton: HToolBar
true  IDM_FORWARDS  EnableButton: HToolBar
false IDM_COPY      EnableButton: HToolBar
false IDM_VIEW      EnableButton: HToolBar
                SW_HIDE Show: HWordTV
                SW_HIDE Show: HEditBox
                SW_HIDE Show: HWordListBox
                HtmlStatusBar ;M

:M ShowWordTV:  ( -- )
                SW_SHOW Show: HWordTV
HViewBox if SW_SHOW Show: HViewBox then
HHtmlBox if SW_HIDE Show: HHtmlBox then
ViewStatusBar
false IDM_PREVIOUS  EnableButton: HToolBar
false IDM_BACKWARDS EnableButton: HToolBar
false IDM_FORWARDS  EnableButton: HToolBar
CurrentViewFile c@ if true else false then IDM_COPY EnableButton: HToolBar
true  IDM_VIEW      EnableButton: HToolBar
                SW_HIDE Show: HHelpTV
                SW_HIDE Show: HEditBox
                SW_HIDE Show: HWordListBox
                ViewStatusBar ;M

:M ShowIndex:   ( -- )
                SW_SHOW Show: HWordListBox
                SW_SHOW Show: HEditBox
                SetFocus: HEditBox
HViewBox if SW_SHOW Show: HViewBox then
HHtmlBox if SW_HIDE Show: HHtmlBox then
ViewStatusBar
false IDM_PREVIOUS  EnableButton: HToolBar
false IDM_BACKWARDS EnableButton: HToolBar
false IDM_FORWARDS  EnableButton: HToolBar
CurrentViewFile c@ if true else false then IDM_COPY EnableButton: HToolBar
true  IDM_VIEW      EnableButton: HToolBar
                SW_HIDE Show: HHelpTV
                SW_HIDE Show: HWordTV
                ViewStatusBar ;M

                \ ------------------------------------------ sel change / notify
:M SelChange:	( -- ) \ Show the control for the currently selected tab.
	        GetSelectedTab: HTabControl
                case    HELP_TAB  of ShowHelpTV: self  endof
                        WORD_TAB  of ShowWordTV: self  endof
                        INDEX_TAB of ShowIndex: self    endof
                endcase ;M

: selchange-func  { lParam obj \ Parent -- false }
                \ This function is executed when the currently selected tab has changed.
                \ lParam is the adress of the Address of an NMHDR structure.
                \ obj is the address of the TabControl object that has send the
                \ notification message.
	        GetParent: obj to Parent
	        SelChange: Parent
	        false ;

:M ShowTab:	( n -- ) \ show tab n
	        SetSelectedTab: HTabControl
	        SelChange: self ;M

: HandleHEditbox ( msg -- result )
                drop 0 ;
: HandleHListBox ( msg -- result )
                drop 0 ;

:M WM_NOTIFY    ( h m w l -- f ) \ Handle the notification messages of the controls.
                dup GetNotifyWnd GetHandle: HTabControl =
                if   Handle_Notify: HTabControl
                else dup GetNotifyWnd GetHandle: HHelpTV =
                     if   Handle_Notify: HHelpTV
                     else dup GetNotifyWnd GetHandle: HWordTV =
                          if   Handle_Notify: HWordTV
                          else dup GetNotifyWnd GetHandle: HEditBox =
                               if   HandleHEditBox
                               else dup GetNotifyWnd GetHandle: HWordListBox =
                                    if   HandleHListBox
                                    else false
                then then then then then ;M

                \ ------------------------------------------ handle controls commands

\ ???  why did GetSelection give 0 here : see above "the story..."
: myWmChar      ( h m w l obj -- res ) \ process WM_CHAR of EditControl HEditBox
                2 pick VK_RETURN  =
                if   drop
                     GetSelection: HWordListBox
                     dup LB_ERR <>
                     if   1+ HelpWrd[] WordN0rec v@       \ display quick info
                          QuickInfo
                     else drop
                     then
                     FALSE           \ we already processed this message
                ELSE drop            \ discard object
                     TRUE            \ and use default processing
                THEN ;

0 value wmcode
:M WM_COMMAND   ( h m w l -- flg )
                over hiword to wmcode
                case
                  GetHandle: HEditBox                           \ on keystrokes in edit box
                  of  wmcode EN_CHANGE = wmcode EN_SETFOCUS = or
                      if   GetText: HEditBox
                           findbuf place findbuf +null
                           findbuf 1+ Find: HWordListBox        \ search first match
                           dup LB_ERR <>
                           if   dup 1- 0 max
                                SetTopIndex: HWordListBox       \ display item 2nd topmost
                                SetSelection: HWordListBox      \ and select it
                           else drop
                      then then
                  endof
                  GetHandle: HWordListBox                       \ on selection in listbox
                  of  wmcode LBN_SELCHANGE = wmcode LBN_SETFOCUS = or
                      if   GetSelection: HWordListBox
                           dup LB_ERR <>
                           if   1+ HelpWrd[] WordN0rec v@       \ display quick info
                                QuickInfo
                           else drop
                           then
                      then
                  endof
                endcase
                false ;M

:M ShowWord:    ( addr len -- result ) \ show word quickinfo
                \ result=0 if not found in database
                findbuf place findbuf +null
                findbuf 1+ Find: HWordListBox
                dup LB_ERR <>
                if   dup 1- 0 max
                     SetTopIndex: HWordListBox       \ display item 2nd topmost
                     dup SetSelection: HWordListBox  \ and select it
                     1+ HelpWrd[] WordN0rec v@       \ display quick info
                     QuickInfo
                     -1
                else drop 0
                then
                ;M


                \ ------------------------------------------ wdw creation / deletion
:M On_Done:     ( -- )          \ things to do before program termination
	        Close: HEditBox        \ !!! need to be there, not in On_Close
	        Close: HWordListBox
	        Close: HHelpTV
	        Close: HWordTV
                Close: HTabControl
                On_Done: super
                ;M

:M On_Close:    ( -- )
                Close: super
                ;M

:M Start:	( Parent -- )
 	        Start: super
                WS_CLIPCHILDREN +Style: self

	        self Start: HEditBox
	        self Start: HWordListBox
                    Update: HWordListBox  \ here because needs clientrect set
	        self Start: HHelpTV
                    Update: HHelpTV
	        self Start: HWordTV
                    Update: HWordTV

                self Start: HTabControl   \ tab control must be started last
	        TCIF_TEXT IsMask: HTabControl
	        z" Help" IsPszText: HTabControl
	        1 InsertTab: HTabControl
	        TCIF_TEXT IsMask: HTabControl
	        z" Words" IsPszText: HTabControl
	        2 InsertTab: HTabControl
	        TCIF_TEXT IsMask: HTabControl
	        z" Index" IsPszText: HTabControl
	        3 InsertTab: HTabControl

	        ['] selchange-func IsChangeFunc: HTabControl
                SelChange: self \ show the control for the currently selected tab
                ['] MyWmChar SetWmChar: HEditBox

\                resize: self          \ only for correct display the very first time
                ;M
;Object


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ A refined Text Box Control class
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:class _HEditQuick <super TextBox

:M WindowStyle: ( -- style )
                WindowStyle: super
drop [ WS_CHILD WS_VISIBLE or ] literal
                [ ES_LEFT ES_MULTILINE or ES_READONLY or ] literal or
                [ WS_HSCROLL ES_AUTOHSCROLL or WS_VSCROLL or ES_AUTOVSCROLL or ] literal or
                ;M

:M Start:	( Parent -- )
	        Start: super
	        DEFAULT_GUI_FONT call GetStockObject
                1 swap WM_SETFONT SendMessage:SelfDrop
	        ;M
;class


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ Define the top part of the splitter window.
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:Object _HTopPane        <Super Child-Window

_HEditQuick EditQuick

:M WndClassStyle: ( -- style )
                CS_DBLCLKS ;M
:M ExWindowStyle: ( -- style )
                ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M On_Paint:    ( -- )
                0 0 Width Height WHITE FillArea: dc ;M

:M On_Size:     ( -- )
                GetHandle: EditQuick if Autosize: EditQuick then
                ;M
:M On_Init:     ( -- )
                On_Init: super
                WS_CLIPCHILDREN +Style: self
                ;M

:M Start:       ( Parent -- )
                start: super
                self Start: EditQuick
                EditQuick to HEditQuick
                ;M

:M On_Done:     ( -- )
	        Close: HEditQuick   \ !!! needs to be there to NULL handle !
                ;M

:M On_Close:    ( -- )
                \ deleteobject font (is a system font)
                Close: super
                ;M
;Object


\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ Define the bottom part of the splitter window.
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:Object _HBottomPane        <Super Child-Window

HtmlControl   HtmlBox
ScintillaEdit ViewBox
int viewfont

:M WndClassStyle: ( -- style )
                CS_DBLCLKS ;M

:M ExWindowStyle: ( -- style )
                ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M On_Paint:    ( -- )
                0 0 Width Height WHITE FillArea: dc ;M

:M ShowHtml:    ( addr cnt -- )
                SW_SHOW Show: HtmlBox   \ show before hide
                SW_HIDE Show: ViewBox
                GoURL: HtmlBox ;M

:M ShowSource:  ( line# addr cnt -- )
                \ Note: we put SetSavePoint just before closing the previous file
                \       It seems that it works to avoid file write, hence to set
                \       Scintilla as read-only
2dup CurrentViewFile place
                SetSavepoint: ViewBox             \ put this just before close
                OpenNamedFile: ViewBox drop       \ seems to close any previous file
                dup 8 + GotoLine: ViewBox
                1- dup PositionFromLine: ViewBox  \ highlight line
                SetSelectionStart: ViewBox
                GetLineEndPosition: ViewBox
                SetSelectionEnd: ViewBox
       \         0 0 GetSize: self move: ViewBox
                SW_SHOW Show: ViewBox             \ show before hide
                SW_HIDE Show: HtmlBox
                ViewStatusBar
                true IDM_COPY EnableButton: HToolBar \ enable copy tool
                ;M

:M On_Size:     ( -- )
                GetHandle: ViewBox if 0 0 Getsize: self Move: ViewBox  then
                GetHandle: HtmlBox if Autosize: HtmlBox  then
                ;M

: Start-ViewBox ( -- )
                InitScintillaControl
                Gethandle: ViewBox 0=
                if   self start: ViewBox
                     ViewBox to HViewBox
                     WS_BORDER -style: Viewbox
                     false EnableBackup: Viewbox
                     0 0 GetSize: self move: ViewBox
                then ;

: Start-HtmlBox ( -- )
                GetHandle: HtmlBox 0=
                if   self Start: HtmlBox
                     HtmlBox to HHtmlBox
                     WS_BORDER -style: HtmlBox
\                     WS_CLIPCHILDREN +Style: self
                     CS_DBLCLKS GCL_STYLE GetHandle: HtmlBox Call SetClassLong  drop
                     0 0 GetSize: self Move: HtmlBox
                then ;

:M On_Init:     ( -- )
                On_Init: super
                ANSI_FIXED_FONT Call GetStockObject to viewfont
                WS_CLIPCHILDREN +Style: self
                ;M

:M Start:       ( Parent -- )
                start: super
                Start-ViewBox
                Start-HtmlBox
                ;M

: Close-viewers ( -- )
                Close: ViewBox               \ note: this releases file buffer
                ExitScintillaControl
                Close: HtmlBox ;

:M On_Done:     ( -- )
                Close-Viewers         \ need to be there to null viewer handle !!!
                ;M

:M On_Close:    ( -- )
                Close: super ;M

:M Classinit:   ( -- )
                Classinit: super
                0 to HViewBox
                0 to HHtmlBox ;M
;Object




((
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ Define splitter line between the panes.
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

\ Left and right panes can visually define a splitter of thickness t, if for
\ instance the background colors are white for the panes and ltgray for the
\ main window. In this case, there is no need to define a splitter object and
\ to paint it.
\ By default, main window inherits from Forth a white background. To override
\ this, put the following code in the On_Init: method of main window
\     COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hwnd  Call SetClassLong drop

For desperate cases:

:Object _HSplitter        <Super child-window
:M WindowStyle:   ( -- style )
                  WindowStyle: super
                  [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or ;M
:M WndClassStyle: ( -- style )
                  CS_DBLCLKS ;M \ avoid flickering
:M On_Paint:      ( -- )
                  0 0 Width Height LTGRAY FillArea: dc    ;M
;Object
))

( 240) 0 value VertSplitWid
( 100) 0 value HorizSplitHei
3   value thickness   \ not less than 2 !



\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ Main window
\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------

:Object NewHelp     <Super Window

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any


                \ ------------------------------------------ general settings
:M WindowTitle: ( -- Zstring )
                z" Win32Forth Help" ;M
:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_CLIPCHILDREN or ;M
:M WndClassStyle:       ( -- style )
                CS_DBLCLKS ;M
:M WindowHasMenu: ( -- f )
                False ;M

                \ ------------------------------------------ wdw resize & reposition
:M StartPos:    ( -- x y )
                WindowX WindowY ;M

:M StartSize:   ( -- w h )
                WindowW WindowH ;M

: Height-ToolBar-Status ( -- n )   Height StatusBarHeight - ToolBarHeight - ;
: RightSplitterWidth    ( -- n )   Width VertSplitWid - Thickness - ;

: position-panes ( -- )
                0                                 ToolBarHeight
                VertSplitWid                      Height-ToolBar-Status
                GetHandle: _HLeftPane if Move: HLeftPane else 4drop then
\          if only 1 vertical splitter (HTopPane = HRightPane)
\          VertSplitWid Thickness +          ToolBarHeight
\          Width VertSplitWid - thickness -  Height-ToolBar-Status
\          Move: HTopPane
                VertSplitWid Thickness +          ToolBarHeight
                Width VertSplitWid - thickness -  HorizSplitHei
                GetHandle: _HTopPane if Move: HTopPane else 4drop then
                VertSplitWid Thickness +          ToolBarHeight HorizSplitHei + Thickness +
                Width VertSplitWid - Thickness -  Height-ToolBar-Status HorizSplitHei - Thickness -
                GetHandle: _HBottomPane if Move: HBottomPane else 4drop then
                ;
int WindowState
:M On_Size:	( h m w l -- )
                to WindowState \ get WindowState, don't save size of maximised or minimised window
                Autosize: HToolBar
                Redraw: HStatusBar
                position-panes ;M

                \ ------------------------------------------ splitters move
int dragging?
int mousedown?
int VertSplit
int HorizSplit

: InVertSplitter? ( -- f1 )   \ is cursor on vertical splitter "window"
                hWnd get-mouse-xy
                0 height within
                swap VertSplitWid dup thickness + within  and ;

: InHorizSplitter? ( -- f1 )   \ is cursor on horizontal splitter "window"
                hWnd get-mouse-xy ( -- x y )
                HorizSplitHei ToolBarHeight + dup Thickness + within
                swap VertSplitWid Thickness + Width within and ;

: DoSizing      ( -- )
                mousedown? dragging? or 0= ?exit
                VertSplit
                if   mousex width min thickness 2/ -
                     thickness 2* max
                     width Thickness 2* - min
                     to VertSplitWid
                else HorizSplit
                     if   mousey ToolBarHeight - height min thickness 2/ -
                          thickness 2* max
                          height ToolBarHeight - thickness 2* - min
                          to HorizSplitHei
                then  then
                position-panes
                WINPAUSE ;

: On_clicked    ( -- )
                mousedown? 0= if hWnd Call SetCapture drop then
                true to mousedown?
                InVertSplitter?  if true to VertSplit  false to HorizSplit then
                InHorizSplitter? if true to HorizSplit false to VertSplit  then
                VertSplit HorizSplit to dragging?
                DoSizing ;

: On_unclicked ( -- )
                mousedown? if Call ReleaseCapture drop then
                false to mousedown?
                false to dragging? ;

:m WM_SETCURSOR ( h m w l -- )
                hWnd get-mouse-xy
                ToolBarHeight dup Height-ToolBar-Status + within
                swap 0 width within and
                if   InVertSplitter?
                     if   SIZEWE-CURSOR
                     else InHorizSplitter?
                          if   SIZENS-CURSOR
                          else ARROW-CURSOR
                     then then 1
                else DefWindowProc: self
                then ;M

                \ ------------------------------------------ toolbar commands

:M WM_NOTIFY    ( h m w l -- f ) \ for handling tooltips
                Handle_Notify: hToolBar ;M

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
                over LOWORD ( command ID )
                dup IDM_COPY =
                if   GetHandle: HViewBox                                \ copy to clipboard
                     if copy: HViewBox then
\ ??? copy from HHtmlBox ???
                else dup IDM_PREVIOUS =                                 \ <-- previous
                     if   GoBack: HHtmlBox
                     else dup IDM_BACKWARDS =                           \ << backwards
                          if   CurrentHtmlIndex >Link#: HelpHtmlList
                               FirstLink?: HelpHtmlList not
                               if   >PrevLink: HelpHtmlList
                                    Link#: HelpHtmlList
                                    to CurrentHTMLIndex HtmlStatusBar
                                    \ ??? move selection in tv
                               then
                          else dup IDM_FORWARDS =                        \ >> forwards
                               if   CurrentHtmlIndex >Link#: HelpHtmlList
                                    Link#: HelpHtmlList        \ don't use LastLink? !!!
                                    #Links: HelpHtmlList 1- <
                                    if   >NextLink: HelpHtmlList
                                         Link#: HelpHtmlList
                                         to CurrentHTMLIndex HtmlStatusBar
                                        \ ??? move selection in tv
                                    then
                               else dup IDM_VIEW =                       \ view file
                                    if   CurrentLine
                                         currentsource count ShowSource: HBottomPane
                                    else drop OnWmCommand: Super
                then then then then then ;M

:M WM_COPYDATA  ( hwnd msg wParam lParam -- result )   \ respond to messages
                Decodew32fMsg ( hwnd msg wparam lparam -- addr siz w32fmsg w32fAppIDSender )
                drop                     \ no matter who is the sender
                CASE
                  WM_WORDHELP  OF ShowIndex: HLeftPane
                                  drop count
                                  ShowWord: HLeftPane  ( result) ENDOF
                  WM_LINEFILE  OF /QuickInfo
                                  ShowIndex: HLeftPane
                                  drop dup @ ( line)
                                  swap cell+ count ( filename)
                                  ShowSource: HBottomPane     -1 ENDOF
                  WM_HTML      OF ShowHelpTV: HLeftPane
                                  drop count
                                  2dup SetText: HStatusBar
                                  ShowHtml: HBottomPane       -1 ENDOF
                  2drop 0 swap
                ENDCASE ;M

                \ ------------------------------------------ wdw creation / deletion
:M Classinit:   ( -- )
                ClassInit: super   \ init super class
                false to dragging?
                false to mousedown?
                ['] On_clicked     SetClickFunc: self
                ['] On_unclicked   SetUnClickFunc: self
                ['] DoSizing       SetTrackFunc: self
                ;M

:M On_Init:     ( -- ) \ things to do at the start of wdw creation
                On_Init: super                        \ do anything superclass needs

                0 CurrentViewFile c!                  \ various inits before wdw creation
                0 to CurrentHtmlIndex

                WS_CLIPCHILDREN +Style: self
                self to HNewHelp                      \ set main window object

                \ Override Win32Forth default to WHITE background color, for
                \ correct display of toolbar (on COLOR_BTNFACE backgroud) and
                \ good visibility of splitter
                COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hwnd  Call SetClassLong drop
                SplitterV to VertSplitWid             \ values from config
                SplitterH to HorizSplitHei

                _Htoolbar to HToolBar                 \ set toolbar
                1024 SetID: HToolBar
                self Start: HToolBar
                GetWindowRect: HToolBar nip swap - nip to ToolbarHeight
                SW_SHOW show: HToolBar
                false IDM_COPY EnableButton: HToolBar \ start html help : disable other tools
                false IDM_VIEW EnableButton: HToolBar

                _HStatusBar to HStatusBar             \ set status bar
                1028 SetID: HStatusBar
                self Start: HStatusBar
                Height: HStatusBar to StatusBarHeight
                SW_SHOW show: HStatusBar

                _HLeftPane to HLeftPane               \ set panes
                1025 Setid: HLeftPane
                self Start: HLeftPane
                _HTopPane to HTopPane
                1026 Setid: HTopPane
                self Start: HTopPane
                _HBottomPane to HBottomPane
                1027 Setid: HBottomPane
                self Start: HBottomPane
                ;M
((
:M On_Close:    ( -- )
                Close: super ;M
))
:M On_Done:     ( -- ) \ things to do before program termination
                WindowState SIZE_RESTORED =  \ save window if not maximized nor minimized
                if   GetWindowRect: self                 \ (do it before closing window)
                     2drop          to WindowY to WindowX
                     Width: self    to WindowW
                     Height: self   to WindowH
                then
                VertSplitWid  to SplitterV
                HorizSplitHei to SplitterH

                Close: HToolBar
                Close: HStatusBar
                Close: HLeftPane
                Close: HTopPane
                Close: HBottomPane
                Close: HNewHelp
                HelpHtmlList DisposeList            \ ??? put it in ~:
                Clearhdb
turnkey? if 0 Call PostQuitMessage then  \ version without console
                On_Done: super             \ then do things superclass needs
                ;M
;Object


\s
