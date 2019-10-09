\ CreateMenu.f
\ Menu generator for ForthForm
\ Muchly derived from Project Manager :-)

anew -createmenu.f

needs treeview.f
needs enum.f
\ needs CreateMenuFormII.frm

enum:       \ menu ids
 IDM_MENUBAR
 IDM_MENUPOPUP
 IDM_MENUITEM
 IDM_SUBMENU
 IDM_MENUSEPARATOR ;

\- ?exitm macro ?exitm " if exitm then"

\ These deferred  functions allow different compilation options
defer OnMenuBar  ' drop is OnMenuBar
defer OnPopup    ' drop is OnPopup
defer OnSubMenu  ' drop is OnSubMenu
defer OnMenuItem ' drop is  OnMenuItem
defer OnMenuEnd  \ ' drop is OnMenuEnd
defer OnExit     ' drop is OnExit
0 value ThisItem

:Class MenuEntry            <super Object

record: iteminfo
max-path 1+ bytes itemname
max-path bytes itemimage    \ image to associate with menu item \ future extended compilation
    int parenttree        \ parent treeview control
    int parentitem        \ parent item in treeview control
    int hwnditem          \ handle for item
    int parenthandle
    int itemid
    int menuid
33 bytes menuname
;recordsize: sizeof(iteminfo)

:M classinit:   ( -- )
        classinit: super
        iteminfo sizeof(iteminfo) erase
        IDM_MENUITEM to itemid  \ default
        NextID to menuid
        ;M

:M setname: ( addr cnt -- ) \
        itemname max-path erase
        max-path min 0max itemname swap move
        ;M

:m getname: ( -- addrz )
        itemname ;m

:m getmenuname:  ( -- addr cnt )
                menuname count ;m

:m setmenuname:  ( addr cnt -- )
                32 min 0max menuname place ;m

:m isparentitem: ( n -- )
        to parentitem ;m

:m parentitem:  ( -- n )
        parentitem ;m

:m isparenttree: ( n -- )
        to parenttree ;m

:m parenttree:  ( -- n )
        parenttree ;m

:m handle:  ( -- hwnd )
        hwnditem ;m

:m ishandle:    ( n -- )
        to hwnditem ;m

:m itemid:  ( -- f )
        itemid ;m

:m isitemid:    ( f -- )
        to itemid ;m

:m itemimage:   ( -- image )
        itemimage ;m

:m isitemimage: ( image cnt -- )
        itemimage place ;m

:m isParentWindow: ( n -- )
        to parenthandle ;m

:m ParentWindow:    ( -- n )
        parenthandle ;m

:m menuid:  ( -- menuid )
        menuid ;m

;class

:Object TheMenu     <super TreeViewControl

int SelectedItem
int hwndmain        \ handle to root
int hwndimage
0 value modified?
create menu-name 33 allot
150 value max-items \ if a menu will have more than 150 entries increase the value
max-items 1+ cells bytes item-buffer

\ The OS does most of the work of managing the tree items but as there are dynamic objects
\ we save them in a buffer for easy disposal.
: add-to-buffer ( -- )  \ save dynamic object pointed to by ThisItem in buffer
        item-buffer @ 1+ max-items > abort" Item buffer full!"
        ThisItem item-buffer lcount cells+ !
        item-buffer incr ;

: erase-buffer  ( -- )
        item-buffer off ;

: dispose-buffer ( -- )
        item-buffer lcount cells bounds
        ?do     i @ ?dup
                if  dispose
                    i off
                then
   cell +loop   erase-buffer ;

: DefaultName   ( -- str cnt )
                s" DefaultMenuBar" ;

: modified  ( -- )
        true to modified? ;

:m Modified?:   ( -- f )
        modified? ;m

:M Handle:  ( -- hwndmain )
        hwndmain ;M

:m SetMenuName: ( addr cnt -- )
        menu-name 32 erase
        menu-name swap 32 min 0max move ;m

:m GetMenuName: ( -- addr cnt )
                menu-name zcount ;m

: NewMenuItem   ( -- )
        New> MenuEntry to ThisItem
        add-to-buffer ;

: AddMenuBar    ( -- )
        NewMenuItem
        IDM_MENUBAR isitemid: ThisItem
        0 isparentitem: ThisItem
        0 isParentWindow: ThisItem
        self isparenttree: ThisItem
        GetMenuName: self dup 0=
        if  2drop DefaultName 2dup SetMenuName: self
        then    setname: ThisItem
        tvins  /tvins  erase
        tvitem /tvitem erase
        1                   to cChildren
        TVI_ROOT            to hParent
        TVI_LAST            to hInsertAfter
        ThisItem            to lparam
        getname: lparam     to pszText
        [ TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or TVIF_STATE or ] LITERAL
                            to mask
        TVIS_BOLD dup to state to statemask \ embolden menubar name
        tvitem->tvins
        tvins 0 TVM_INSERTITEMA SendMessage:self dup
        ishandle: ThisItem to hwndmain
        false to modified? ;

: AddTreeItem   ( -- )
                tvins  /tvins  erase
                tvitem /tvitem erase
                ParentWindow: ThisItem      to hParent
                TVI_LAST                    to hInsertAfter
                GetName: ThisItem           to pszText
                ThisItem                    to lparam
                TVIF_TEXT  TVIF_PARAM or
                itemid: ThisItem dup IDM_MENUPOPUP = swap IDM_SUBMENU = or
                if      TVIF_CHILDREN or TVIF_STATE or
                        1                   to cChildren
                        TVIS_BOLD           dup to state    \ popups and submenus will be bold
                                            to statemask
                then                        to mask
                tvitem->tvins
                tvins 0 TVM_INSERTITEMA SendMessage:self IsHandle: ThisItem ;

: add-menu-item { str cnt mid -- }
        SelectedItem 0= ?exit
        cnt 0= ?exit
        str cnt -trailing
        -if     to cnt drop
        else    2drop s" ???" to cnt to str
        then    itemid: SelectedItem IDM_MENUITEM =
        if      parentitem: SelectedItem
        else    SelectedItem
        then    NewMenuItem
        dup handle:  [ ] isParentWindow: ThisItem
        isparentitem: ThisItem
        str cnt setname: ThisItem
        self isparenttree: ThisItem
        mid isitemid: ThisItem
        AddTreeItem
        modified ;

:M AddPopup:    ( str cnt -- )
        IDM_MENUPOPUP add-menu-item ;M

:M AddMenuItem: ( str cnt -- )
        IDM_MENUITEM add-menu-item ;M

:M MenuSeparator: ( -- )
        s" -------------------" IDM_MENUSEPARATOR add-menu-item ;M

:M AddSubMenu:  { str cnt -- }  \ really same as addpopup:
        SelectedItem 0= ?exitm
        cnt 0= ?exitm
        str cnt -trailing
        -if     to cnt drop
        else    2drop s" ???" to cnt to str
        then    itemid: SelectedItem IDM_MENUITEM =
        if      parentitem: SelectedItem
        else    SelectedItem
        then    dup itemid: [ ] IDM_MENUBAR = >r
        NewMenuItem
        dup handle:  [ ] isParentWindow: ThisItem
        isparentitem: ThisItem
        str cnt setname: ThisItem
        r>      \ if true change to popup if parent is the menubar
        if      IDM_MENUPOPUP
        else    IDM_SUBMENU
        then    isitemid: ThisItem
        self isparenttree: ThisItem
        AddTreeItem
        modified ;M


:M start:       ( parent -- )
                start: super
                erase-buffer
                AddMenuBar
                ;M

:m Classinit:   ( -- )
        Classinit: super
        s" DefaultMenubar" SetMenuName: self
        null to hwndmain
        null to hwndimage
        null to SelectedItem
        null to ThisItem ;m


:M WindowStyle: ( -- style )
                WindowStyle: super
                TVS_HASLINES        or
                TVS_HASBUTTONS      or
                TVS_DISABLEDRAGDROP or
                TVS_SHOWSELALWAYS   or
                TVS_LINESATROOT     or
                TVS_EDITLABELS      or
                WS_BORDER           or
                ;M

 :m ~:   ( -- )
         Dispose-buffer ;m

:m Close: ( -- )
         Dispose-buffer
         0 to hwndmain
         Close: super
         ;m

:M On_SelChanged: ( -- f )
                lparamNew to SelectedItem
                SelectedItem Update: parent
                false
                ;M

:M SelectedItem: ( -- item )
                SelectedItem ;M

:M On_BeginLabelEdit: ( -- f )
        itemid: SelectedItem IDM_MENUSEPARATOR = ?dup ?exitm    \ don't edit menuseparator
        BeginEdit: parent   \ send message
        false ;M

:M On_EndLabelEdit: ( -- f )
        EndEdit: parent
        psztext ?dup                                        \ if we have text
        if  zcount ?dup                                     \ and not zero
            if  setname: lparam                             \ update menu object
                TVIF_TEXT to mask
                tvitem 0 TVM_SETITEM SendMessage:self drop  \ and rename item in tree
                modified
            else    drop false to psztext
            then
        then    psztext 0<>                                 \ return false if cancelled
        ;M

: getmenuitem   { hnd -- item-object }  \ given handle return object address
        tvitem /tvitem erase
        hnd to hitem
        TVIF_PARAM to mask  \ we want our menu item object
        tvitem 0 TVM_GETITEM SendMessage:self drop lparam ;

: getnextitem   ( hnd -- handle )
        TVGN_NEXT TVM_GETNEXTITEM SendMessage:self ;

: getchilditem  ( hnd -- handle )
        TVGN_CHILD TVM_GETNEXTITEM SendMessage:self ;

: (traverse-menu) { mobj \ thndl  tobj -- }
        itemid: mobj IDM_SUBMENU =
        if  mobj OnSubMenu      \ beginning submenu
        then    handle: mobj getchilditem to thndl
        begin   thndl
        while   thndl getmenuitem to tobj
                itemid: tobj IDM_SUBMENU =
                if      tobj RECURSE
                else    tobj OnMenuItem
                then    thndl getnextitem to thndl
        repeat  mobj OnExit ;

: traverse-menu { \ thndl tobj -- }
        hwndmain 0= ?exit
        hwndmain getmenuitem OnMenuBar  \ creating the menubar
        hwndmain getchilditem to thndl  \ need to get child first
        begin   thndl
        while   thndl getmenuitem to tobj
                itemid: tobj IDM_MENUPOPUP =
                if      tobj OnPopup            \ creating popup
                        tobj (traverse-menu)
                else    tobj OnMenuitem         \ executable item in menubar?
                then    thndl getnextitem to thndl  \ now we get next items
        repeat  OnMenuEnd ;

:m Delete:      ( -- )
                Selecteditem 0= ?exitm
                itemid: SelectedItem IDM_MENUBAR = ?exitm   \ can't delete menubar, use new:
                s" Remove '" new$ dup>r place
                getname: SelectedItem zcount r@ +place
                s" ' from menu?" r@ +place
                r@ +NULL
                r> 1+               ( sztext )
                itemid: SelectedItem dup IDM_MENUPOPUP = swap IDM_SUBMENU = or
                if      z" Warning! This item may have sub-entries, are you sure?"
                else    z" Are you sure?"
                then    ( title )
                MB_YESNO                ( style  )
                MessageBox: parent IDNO = ?exitm
                handle: SelectedItem    \ lparam
                0                       \ wparam
                TVM_DELETEITEM          \ msg
                hwnd
                Call SendMessage 0= abort" Delete menu item failed!"
                0 to SelectedItem
                modified ;m

:m Rename:      { str cnt -- }
                SelectedItem 0= ?exitm
                cnt 0= ?exitm
                itemid: SelectedItem IDM_MENUSEPARATOR = ?exitm     \ can't rename menuseparator
                tvitem /tvitem erase
                Handle: SelectedItem to hitem
                TVIF_TEXT to mask
                str cnt SetName: SelectedItem
                str cnt asciiz to psztext
                tvitem 0 TVM_SETITEM SendMessage:self drop
                modified
                ;m

0 0 2value menu-origin
0 0 2value menu-dimensions

:m Move:    { x y w h -- }
            x y 2to menu-origin         \ save these parameters
            w h 2to menu-dimensions     \ for when we are 'newing'
            x y w h Move: super ;m

:m New:     ( -- )
            modified? not ?exitm
            z" Do you want to restart?"     ( sztext )
            z" Please confirm"              ( title )
            MB_YESNO                        ( style  )
            MessageBox: parent IDNO = ?exitm
            Close: self
            DefaultName SetMenuName: self
            parent start: self
            menu-origin menu-dimensions Move: super  ;m

: menustring    ( addr1 cnt1 textz  -- )
                -rot append "append zcount append "append ;

: (Onmenubar)   { mitem -- }
                +crlf
                s" Menubar " append GetName: mitem zcount append&crlf ;

: (OnPopup)     { mitem -- }
                +crlf
                s" Popup " GetName: mitem menustring +crlf ;

: (OnMenuItem)  { mitem -- }
                1 +tabs
                itemid: mitem IDM_MENUSEPARATOR =
                if      s" MenuSeparator" append&crlf
                else    GetMenuName: mitem ?dup     \ it is a :menuitem only if it has text
                        if      s" :MenuItem " pad place pad +place s"  " pad +place pad count
                        else    drop s" MenuItem "
                        then    GetName: mitem menustring
                        60 #chars - +spaces s"  noop ;" append&crlf
                then    ;

: (OnSubMenu)   { mitem -- }
                1 +tabs
                s" SubMenu " GetName: mitem menustring
                +crlf
                4 +to tabsize   \ indent the submenu items
                ;

: (OnExit)      { mitem -- }
                itemid: mitem IDM_SUBMENU =
                if      -4 +to tabsize      \ remove indentation
                        1 +tabs
                        s" EndSubmenu" append&crlf
                then    ;

: (OnMenuEnd)   ( -- )
                +crlf
                s" EndBar" append&crlf ;

:M W32FCompile: ( -- )
                tabsize >r      \ save it
                initbuffer
                ['] (OnMenuBar)     is OnMenubar
                ['] (OnPopup)       is OnPopup
                ['] (OnMenuItem)    is OnMenuItem
                ['] (OnSubMenu)     is OnSubMenu
                ['] (OnExit)        is OnExit
                ['] (OnMenuEnd)     is OnMenuEnd
                traverse-menu
                r> to tabsize ;M

:M Test:    ( -- )
            s" anew _test" evaluate
            W32FCompile: self
            +crlf +crlf
            s" :Object TestWindow           <Super Window" append&crlf
            +crlf
            s" :M On_Init:  ( -- )" append&crlf
            2 +tabs GetMenuName: self 2dup 2>r append s"  SetMenuBar: self  ;M" append&crlf
            +crlf
            s" :M WindowHasMenu:  ( -- )" append&crlf
            2 +tabs s" true ;M" append&crlf
            s" :M WindowTitle: ( -- zstring )" append&crlf
            2 +tabs 'z' cappend "append s"  Test Window for " append 2r> append "append
            s"  ;M" append&crlf
            +crlf
            s" :M On_Done:  ( -- )" append&crlf
            2 +tabs s" MenuHandle: CurrentMenu ?dup" append&crlf
            2 +tabs s"   if      Call DestroyMenu drop  \ need to discard the menubar" append&crlf
            2 +tabs s"           ZeroMenu: CurrentMenu" append&crlf
            2 +tabs s"   then    On_Done: Super ;M " append&crlf
            +crlf
            s" ;Object" append&crlf
            s" Start: TestWindow" append&crlf fload-buffer ;M

: i-buffer ( -- addr )  \ item buffer
           here 100 + ;

: >i-buffer  ( -- )
             ThisItem i-buffer lcount cells+ !    \ save last created item
             i-buffer incr ;            \ and increment

: select-item ( -- )    \ programmatically select item, API function doesn't seem to work
                i-buffer lcount 1- cells+ @ to SelectedItem ;

: -i-buffer ( -- ) \ effectively pop item and discard
                i-buffer @ 1 = ?exit \ first popup being defined
                i-buffer decr
                select-item ;

: end-line      ( -- )  \ terminate scanning of the current line
                (source) >in ! ;

\ The following $words interpret a menu definition, either from a .mdf or .f file
: $menubar      ( -- )
                bl word count dup 0= abort" No menu name specified!"
                SetMenuName: self
                Close: self
                parent start: self
                menu-origin menu-dimensions Move: super
                >i-buffer select-item ;

: $menuitem     ( -- )
                [CHAR] " word count dup 0= abort" Missing menuitem name!" AddMenuItem: self
                end-line ;

: $popup        ( -- )
                -i-buffer
                [CHAR] " word count dup 0= abort" Popup without a pop!" AddPopup: self
                >i-buffer select-item
                end-line ;

: $menuseparator ( -- )
                MenuSeparator: self
                end-line ;

: $submenu      ( -- )
                [CHAR] " word count dup 0= abort" No submenu name specified!"
                AddSubMenu: self
                >i-buffer select-item
                end-line ;

: $endsubmenu   ( -- )
                -i-buffer
                end-line ;

: $:menuitem    ( -- )
                bl word count dup 0= abort" :MenuItem missing name!"
                pad place
                more? not abort" :MenuItem missing text!"
                $menuitem
                pad count setmenuname: ThisItem ;

false value done
: $endbar       ( -- )
                true to done
                end-line ;

: ?menu-word    ( word$ -- )
                dup count upper
                case    s" MENUBAR"         "of     $menubar        endof
                        s" MENUITEM"        "of     $menuitem       endof
                        s" POPUP"           "of     $popup          endof
                        s" SUBMENU"         "of     $submenu        endof
                        s" MENUSEPARATOR"   "of     $menuseparator  endof
                        s" ENDSUBMENU"      "of     $endsubmenu     endof
                        s" ENDBAR"          "of     $endbar         endof
                        s" :MENUITEM"       "of     $:menuitem      endof
                endcase ;

: BuildMenuTree  { fname fcnt \ temp$ -- }
                maxstring localalloc: temp$
                fname fcnt "open
                if      drop true s" Open file error!" ?MessageBox
                        exit
                then    source-ID >r to source-ID
                >in @ >r
                source 2>r                     \ save current source
                temp$ (source) cell+ !
                refill
                begin   more? dup 0=
                        if      drop refill
                        then    done not and
                while   bl word dup c@
                        if      ?menu-word
                        else    drop
                        then
                repeat  source-id close-file drop
                2r> (source) 2!
                r> >in !
                r> to source-id ;

:M Load:        ( addr cnt -- )
                false to done
                i-buffer off
                BuildMenuTree
                hwndmain ToggleExpandItem: self ;m

;object

FileOpenDialog OpenMDFDlg "Load Menu" "Menu Definition Files|*.mdf|Forth Files|*.f|"
FileSaveDialog SaveMDFDlg "Save Menu" "Menu Definition Files|*.mdf|"

:Object frmCreateMenuForm       <Super frmDefineMenu

File MenuFile

:M Close:       ( -- )
                Close: TheMenu
                Close: Super ;M

: MenuTitle     ( -- addr cnt )
                s" Menu-" pad place
                GetMenuName: TheMenu pad +place
                pad count ;

: DoMenuCommand { mid obj -- }
        mid
        case
            GetID: btnPopup     of  GetText: txtMenutext AddPopup: TheMenu      endof
            GetID: btnSubMenu   of  GetText: txtMenutext AddSubMenu: TheMenu    endof
            GetID: btnMenuItem  of  GetText: txtMenutext AddMenuitem: TheMenu
				    GetText: txtName SetMenuName: ThisItem
										endof
            GetID: btnRename    of  GetText: txtMenutext Rename: TheMenu        endof
            GetID: btnSeparator of  MenuSeparator: TheMenu                      endof
            GetID: btnNew       of  New: TheMenu                                endof
            GetID: btnDelete    of  Delete: TheMenu                             endof
            GetID: btnClear     of  pad 0 2dup SetText: txtName
                                    SetText: txtMenuText                        endof
            GetID: btnTest      of  Test: TheMenu                               endof
            GetID: btnClose     of  Close: self                                 endof
            GetId: btnClipBoard of  W32FCompile: TheMenu
                                    TheBuffer copy-clipboard                    endof
            GetID: btnEdit      of  W32FCompile: TheMenu
                                    TheBuffer MenuTitle  ShowSource             endof
            GetID: btnLoad      of  hwnd Start: OpenMDFDlg count ?dup
                                    if      Load: TheMenu
                                    else    drop
                                    then                                        endof
\ Despite future compilation options menus will always be saved in W32f format
\ This means that .mdf files are actually loadable from Win32Forth
            GetID: btnSave      of  hwnd Start: SaveMDFDlg count ?dup
                                    if      pad place
                                            pad count ".ext-only" nip 0=
                                            if      s" .mdf" pad +place     \ add default extension
                                            then    pad count SetName: MenuFile
                                            Create: MenuFile ?exit
                                            W32FCompile: TheMenu
                                            TheBuffer Write: MenuFile drop
                                            Close: MenuFile
                                    else    drop
                                    then                                        endof
        endcase ;

:M On_Init: ( -- )
        On_Init: super

        self Start: TheMenu
        tvMenuTreeX tvMenuTreeY tvMenuTreeW tvMenuTreeH Move: TheMenu

        ['] DoMenuCommand SetCommand: self

        ;M

:M WM_NOTIFY    ( h m w l -- f )
        Handle_Notify: TheMenu ;M

\ The following two methods allow pressing ENTER to accept changes when directly editing
\ a tree item
:M BeginEdit:   ( -- )
        -dialoglist     \ remove from list
        ;M

:M EndEdit:     ( -- )
        +dialoglist     \ put it back
        ;M

:M Update:  { mitem -- }
            itemid: mitem IDM_MENUITEM =
            if      GetMenuName: mitem
            else    pad 0
            then    SetText: txtname ;M

:M ClassInit:   ( -- )
                ClassInit: Super
                self link-formwindow
                ;M

;Object

:NoName        ( -- )
                GetHandle: TheMainWindow SetParentWindow: frmCreateMenuForm
                Start: frmCreateMenuForm ; is doCreateMenu

\s
