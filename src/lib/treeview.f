\ $Id: treeview.f,v 1.16 2010/06/03 08:56:38 jos_ven Exp $

\ TreeView.f    Thursday, June 15 2006  Rod
\               Changed to use Control rather than Child-Window
\               On creation needs a sensible StartSize: ( default set to size of parent )
\               Class control does not have the definition "null-check" which is in
\               class Window and hence Child-Window.

(( TreeView.F   A rudimentary TreeView class              by Michael Hillerström
                                                     michael-hillerstrom@usa.net


                This TreeView class hooks into Windows own library class.
                But be warned; this is a very 'stripped to the bone implementation'
                i.e. it has just what I need for DiaEdit...  Some day (soon) I
                will try to correct this.

                Please note that this code needs a new version of WINCON.DLL
                (dated September 15, 1997 or later).

                An example is included last in this file...


                Any comments/suggestions to:    michael-hillerstrom@usa.net



        Change log:
                November 23rd, 1997 - 21:59 MIH
                Added the line:   WinLibrary COMCTL32.DLL   to this source.

                September 16th, 1997 - 21:42 MIH
                Removed reference to COMMCTRL.F as Tom Zimmer has released an
                extended WINCON.DLL.  Thanks, Tom!

                August 31st, 1997 - 23:15 MIH
                First attempt...(which is VERY bare bones...)
                Need to convince Tom Zimmer to include #define's from COMMCTRL.H
                in WINCON.DLL.  For the time beeing, we'll have to cope with my
                FORTH constants in COMMCTRL.F.

))

cr .( Loading TreeView Class...)


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Prerequisites...
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WinLibrary COMCTL32.DLL         \ Make sure that ComCtl32.dll is loaded...


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       TreeView Constants and their significance...
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

comment:

A treeview can have a combination of the following styles:


TVS_DISABLEDRAGDROP  disables drag n' drop of tree-view items.

TVS_LINESATROOT      draws lines linking child items to the root of the hierarchy.

TVS_HASLINES         enhances the graphic representation of a tree-view by
                     drawing lines that link child items to their parent item.
                     To link items at the root of the hierarchy, you need to
                     combine this and the TVS_LINESATROOT style.

TVS_HASBUTTONS       adds a button to the left side of each parent item. The
                     user can click the button to expand or collapse the child
                     items as an alternative to double-clicking the parent
                     item. To add buttons to items at the root of the
                     hierarchy, this style must be combined with TVS_HASLINES,
                     and TVS_LINESATROOT.

TVS_EDITLABELS       makes it possible for the user to edit the labels of
                     tree-view items.

TVS_SHOWSELALWAYS    causes a selected item to remain selected when the
                     tree-view control loses focus.


comment;



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       TreeView Class...
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class TreeViewControl <super control

     Record:    nmhdr
        int     hWndFrom
        int     idFrom
        int     code
    ;RecordSize: /nmhdr

     Record:    tvins
        int     hParent
        int     hInsertAfter
\ tvitem starts here
        int     mask
        int     hItem
        int     state
        int     stateMask
        int     pszText
        int     cchTextMax
        int     iImage
        int     iSelectedImage
        int     cChildren
        int     lParam
    ;RecordSize: /tvins

: tvitem ( - adr ) tvins 2 cells+ ;

/tvins 2 cells- constant /tvitem

\    Record:    tvdi
\     NMHDR     hdr
\   TV_ITEM     item
\   ;Record


     Record:    tvkd
\     NMHDR     hdr
        int     wVKey
        int     flags
    ;RecordSize: /tvkd


     Record:    nmtv
\     NMHDR     hdr
        int     action
\   TV_ITEM     itemOld
        int     maskOld
        int     hItemOld
        int     stateOld
        int     stateMaskOld
        int     pszTextOld
        int     cchTextMaxOld
        int     iImageOld
        int     iSelectedImageOld
        int     cChildrenOld
        int     lParamOld
\   TV_ITEM     itemNew
        int     maskNew
        int     hItemNew
        int     stateNew
        int     stateMaskNew
        int     pszTextNew
        int     cchTextMaxNew
        int     iImageNew
        int     iSelectedImageNew
        int     cChildrenNew
        int     lParamNew
\     POINT     ptDrag
        int     x
        int     y
    ;RecordSize: /nmtv

Rectangle ItemRect

: fill-nmhdr    ( l -- )
                nmhdr   /nmhdr   2dup erase move ;

: fill-tvkd     ( l -- )
                3 cells+
                tvkd    /tvkd    2dup erase move ;

: fill-tvitem   ( l -- )
                3 cells+
                tvitem  /tvitem  2dup erase move ;

: fill-nmtv     ( addr -- )
                3 cells+
                nmtv    /nmtv    2dup erase move ;

 : tvitem->tvins ( -- )  ; immediate  \ Does nothing now
\                tvitem item /tvitem move ;


\ -------------------- Create Tree-View Control --------------------

:M WindowStyle: ( -- style )
                [ WS_CHILD WS_VISIBLE or ] literal
                ;M

:M StartSize: ( -- w h )   width: parent  height: parent ;M

:M Start:       ( Parent -- )
                hWnd
                if   drop
                     SW_SHOWNOACTIVATE Show: self
                else to Parent
\                     Call InitCommonControls drop
                     z" SysTreeView32" Create-Control
                then ;M

:M Handle_Notify: ( h m w l -- f )
                dup fill-nmhdr
                code
                case
                   TVN_BEGINDRAGA      of  fill-nmtv   On_BeginDrag:      [ self ] endof
                   TVN_BEGINRDRAGA     of  fill-nmtv   On_BeginRDrag:     [ self ] endof
                   TVN_BEGINLABELEDITA of  fill-tvitem On_BeginLabelEdit: [ self ] endof
                   TVN_DELETEITEMA     of  fill-nmtv   On_DeleteItem:     [ self ] endof
                   TVN_ENDLABELEDITA   of  fill-tvitem On_EndLabelEdit:   [ self ] endof
                   TVN_GETDISPINFOA    of  fill-tvitem On_GetDispInfo:    [ self ] endof
                   TVN_ITEMEXPANDEDA   of  fill-nmtv   On_ItemExpanded:   [ self ] endof
                   TVN_ITEMEXPANDINGA  of  fill-nmtv   On_ItemExpanding:  [ self ] endof
                   TVN_KEYDOWN         of  fill-tvkd   On_KeyDown:        [ self ] endof
                   TVN_SELCHANGEDA     of  fill-nmtv   On_SelChanged:     [ self ] endof
                   TVN_SELCHANGINGA    of  fill-nmtv   On_SelChanging:    [ self ] endof
                   TVN_SETDISPINFOA    of  fill-tvitem On_SetDispInfo:    [ self ] endof
                   NM_RCLICK           of              On_RightClick:     [ self ] endof
                          false swap ( default)
                endcase
                ;M

:M ToggleExpandItem:  ( hItem -- )
                TVE_TOGGLE TVM_EXPAND SendMessage:SelfDrop ;M

:M ExpandItem:  ( hItem -- )
                TVE_EXPAND TVM_EXPAND SendMessage:SelfDrop ;M

:M CollapseItem:  ( hItem -- )
                TVE_COLLAPSE TVM_EXPAND SendMessage:SelfDrop ;M

:M SortChildren:      ( hItem -- )
                false TVM_SORTCHILDREN SendMessage:SelfDrop ;M

:M DeleteItem:  ( hItem -- f )
\ *G Removes an item and all its children from the tree view control.
\ ** hItem is the handle of the item to delete. If hItem is set to TVI_ROOT,
\ ** all items are deleted.
                0 TVM_DELETEITEM SendMessage:Self ;M

:M InsertItem:   ( -- hItem )   tvins 0 TVM_INSERTITEM SendMessage:Self ;M
:M SetImageList: ( himl iImage -- )   TVM_SETIMAGELIST SendMessage:SelfDrop ;M
\ :M DeleteItem:   ( hItem -- f )       0 TVM_DELETEITEM SendMessage:Self ;M
:M SetItem:      ( -- )           tvitem 0 TVM_SETITEM SendMessage:SelfDrop ;M
:M Expand:       ( hItem f -- )             TVM_EXPAND SendMessage:SelfDrop ;M
\ :M ToggleExpandItem: ( hItem -- )   TVE_TOGGLE Expand: self ;M
:M CollapseReset: ( hItem -- )  TVE_COLLAPSERESET TVE_COLLAPSE or Expand: self ;M
:M Collapse:     ( hItem -- )        TVE_COLLAPSE TVE_COLLAPSE or Expand: self ;M
:M GetItemRect: ( hItem -- f )  ItemRect ! ItemRect true TVM_GETITEMRECT SendMessage:Self ;M
:M SelectItem:  ( hItem flag -- )      TVM_SELECTITEM  SendMessage:SelfDrop ;M
:M GetNextItem: ( hItem flag -- h )   TVM_GETNEXTITEM SendMessage:Self   ;M
:M GetRoot:     ( -- hItem )               0 TVGN_ROOT GetNextItem: self ;M
:M GetChild:    ( hItem -- hItem )          TVGN_CHILD GetNextItem: self ;M
:M GetParentItem: ( hItem -- hItem )       TVGN_PARENT GetNextItem: self ;M
:M GetNext:     ( hItem -- hItem )           TVGN_NEXT GetNextItem: self ;M
:M GetPrevious: ( hItem -- hItem )       TVGN_PREVIOUS GetNextItem: self ;M
:M GetLastVisible:  ( hItem -- hItem )  TVGN_LASTVISIBLE GetNextItem: self ;M
:M GetFirstVisible: ( hItem -- hItem ) TVGN_FIRSTVISIBLE GetNextItem: self ;M

int maxwidth
: ItemWidthMax ( hItem -- hItem )
        dup GetItemRect: self IF  right: ItemRect  maxwidth max to maxwidth  THEN ;

:M GetMaxWidth: ( -- n )
        0 to MaxWidth
        GetRoot: self
        ItemWidthMax
        GetChild: self
        Begin  dup dup
        While
            ItemWidthMax
            GetChild: self
            Begin  dup
            While
               ItemWidthMax
               GetNext: self
            Repeat  drop
            GetNext: self
        Repeat  drop drop
        MaxWidth
        ;M

\ --------------------- Overridable methods ----------------------

:M On_BeginDrag: ( -- f )
                false
                ;M
:M On_BeginRDrag: ( -- f )
                false
                ;M
:M On_BeginLabelEdit: ( -- f )  \ f=true, cancel edit,  f=false, ok edit
                false
                ;M
:M On_DeleteItem: ( -- f )
                false
                ;M
:M On_EndLabelEdit: ( -- f )
                false
                ;M
:M On_GetDispInfo: ( -- f )
                false
                ;M
:M On_ItemExpanded: ( -- f )
                false
                ;M
:M On_ItemExpanding: ( -- f )   \ f=true, don't expand/collapse, f=false, ok go ahead
                false
                ;M
:M On_KeyDown: ( -- f )
                false
                ;M
:M On_SelChanged: ( -- f )
                false
                ;M
:M On_SelChanging: ( -- f )     \ f=true, don't change, f=false, ok change
                false
                ;M
:M On_SetDispInfo: ( -- f )
                false
                ;M
:M On_RightClick: ( -- f )
                false
                ;M
;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       End  of Class definition(s)
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


\   ***************************************************
\S  ******** Below please find a small example ********
\   ***************************************************


:Class NewTVC <super TreeViewControl

        Font WinFont


:M WindowStyle: ( -- style )
                WindowStyle: super
                TVS_HASLINES        or
                TVS_HASBUTTONS      or
                TVS_DISABLEDRAGDROP or
                TVS_SHOWSELALWAYS   or
                TVS_LINESATROOT     or
                ;M

int hRoot
int hSon
int hPrev

: AddItem       ( sztext hAfter hParent nChildren -- )
                tvins  /tvins  erase
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                                  to pszText
                TVIF_TEXT TVIF_CHILDREN or
                to mask
                tvins 0 TVM_INSERTITEMA hWnd Call SendMessage
                to hPrev
                ;


: FillTreeView  ( -- )
                z" Root Item"        TVI_LAST  TVI_ROOT  1  AddItem
                hPrev to hRoot
                z" First son"        hPrev     hRoot     1  AddItem
                hPrev to hSon
                z" First Grandson"   hPrev     hSon      0  AddItem
                z" Second Grandson"  hPrev     hSon      0  AddItem
                z" Second son"       hPrev     hRoot     0  AddItem
                z" Third son"        hPrev     hRoot     1  AddItem
                hPrev to hSon
                z" Third Grandson"   hPrev     hSon      0  AddItem
                ;

:M Start:       ( Parent -- )
                Start: super

                8 Width: WinFont
                16 Height: WinFont
                s" Courier New" SetFaceName: WinFont
                Create: WinFont
                true Handle: WinFont WM_SETFONT hWnd CALL SendMessage drop \ activate a new font

                \ Insert items...
                FillTreeView
                ;M


:M On_SelChanged: { \ text$ -- f }      \ Show text of selected item in message box
                maxstring LocalAlloc: text$

                TVIF_TEXT        to mask
                hItemNew         to hItem
                text$            to pszText
                maxstring        to cchTextMax
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop

                text$ z" TreeView selection"
                MB_OK MessageBox: Parent drop

                false
                ;M

;Class


:Object MainWindow  <super Window

        int TreeView

:M On_Init:     ( -- )
                On_Init: super

                New> NewTVC to TreeView
                1001 SetId: TreeView
                self Start: TreeView
                ;M

:M WindowTitle: ( -- sztitle )
                z" TreeView Test"
                ;M

:M StartSize:   ( -- w h )
                100 100
                ;M

:M On_Size:     ( -- )
                AutoSize: TreeView
                ;M

:M WM_NOTIFY    ( h m w l -- f )
                dup @  GetHandle: TreeView  =
                if      Handle_Notify: TreeView
                else    false
                then
                ;M

;Object

Start: MainWindow


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       End of File
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
