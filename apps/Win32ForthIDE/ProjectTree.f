\ ProjectTree.f

needs linklist.f
needs treeview.f
needs file.f
needs bitmap.f
needs enum.f
needs ExUtils.f
needs fcases.f

true value name-only?
true value no-duplicates?
   0 value #addedfiles
   0 value #linecount
   0 value total-size
   0 value SelectedItem
   0 value ThisList    \ temp pointer to list being used
   0 value ThisItem    \ temp pointer to new item
\   0 value TheProject
\   0 value TheStatusBar
   0 value TheStatusBar

   0 value dirty?
   0 value Modified

    create FileExt 16 allot

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Dialogs \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

MultiFileOpenDialog GetFilesDialog "Select File" "All Files|*.*|Forth Files|*.f|"
FileOpenDialog OpenProjectDialog "Open Project File" "Project Files|*.fpj|"
FileSaveDialog SaveFileDialog "Save Project File" "Project Files|*.fpj|"
NewEditDialog GetProjectNameDlg "New Project Name" "Project Name:" "Create"   "Cancel"   ""
NewEditDialog GetPathDialog "Set Build Search Path" "Search Path:" "&Apply" "Cancel" "Save to Disk"
NewEditDialog SetForthName "Win32Forth Name" "Win32For.exe:" "&Apply" "Cancel"

: OpenProjectFile       ( -- addr )
                s" Project Files|*.fpj|" SetFilter: OpenProjectDialog
                s" Open Project File"     SetTitle: OpenProjectDialog
                Gethandle: MainWindow Start: OpenProjectDialog ;

: SelectAFile   ( -- addr )
                s" All Files|*.*|Forth Files|*.f|" SetFilter: GetFilesDialog
                s" Select File"                    SetTitle: GetFilesDialog
                GetHandle: MainWindow Start: GetFilesDialog ;

: SaveProjectFile ( -- addr )
                s" Project Files|*.fpj|" SetFilter: SaveFileDialog
                s" Save Project File"     SetTitle: SaveFileDialog
                GetHandle: MainWindow Start: SaveFileDialog ;

: SaveZipFile   ( -- addr )
                s" Zip files|*.zip|All Files|*.*|" SetFilter: SaveFileDialog
                s" Select archive file"             SetTitle: SaveFileDialog
                Gethandle: MainWindow Start: SaveFileDialog ;

: SaveModuleFile ( -- addr )
                s" Forth Files|*.f|All Files|*.*" SetFilter: SaveFileDialog
                s" New Module File"                SetTitle: SaveFileDialog
                GetHandle: MainWindow Start: SaveFileDialog ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Tree Item object \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class Treeitem                 <super Object

record: iteminfo
max-path 1+ bytes itemname
              int parenttree        \ parent treeview control
              int parentitem        \ parent item in treeview control
              int hwnditem          \ handle for item
            short itemflags
           1 bits itemid            \ item id, 0 for child item
          15 bits reservedflags
        4 cells bytes reserved
;recordsize: sizeof(iteminfo)

:M classinit:   ( -- )
                classinit: super
                iteminfo sizeof(iteminfo) erase ;m

:M setname:     ( addr cnt -- )
                itemname max-path erase
                max-path min 0max itemname swap move ;m

:m getname:     ( -- addrz )
                itemname ;m

:m getname$:     ( -- addrz )
                itemname zcount ;m

:m isparentitem: ( n -- )
                to parentitem ;m

:m parentitem:  ( -- n )
                parentitem ;m

:m isparenttree: ( n -- )
                to parenttree ;m

:m parenttree:  ( -- n )
                parenttree ;m

:m handle:      ( -- hwnd )
                hwnditem ;m

:m ishandle:    ( n -- )
                to hwnditem ;m

:m itemid:      ( -- f )
                itemid ;m

:m isitemid:    ( f -- )
                to itemid ;m
;class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Tree Linked-list \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:class Treelinked-list          <super linked-list

int hwndlist
int itemid
32 constant listmax     \ maximum length of list name
listmax 1+ bytes listname

:m handle:      ( -- n )
                hwndlist ;m

:m ishandle:    ( hwnd -- )
                to hwndlist ;m

:m itemid:      ( -- f )
                itemid ;m

:m isitemid:    ( f -- )
                to itemid ;m

:m setname: ( addr cnt  -- )
            listname dup listmax erase swap listmax min 0max move ;m

:m getname: ( -- namez )
            listname ;m

:m classinit: ( n addr cnt --)
            listname listmax 1+ erase
            classinit: super
            setname: self
            isitemid: self   ;m

:m DeleteItem: { item \ flag -- }
                Data@: self 0= if  exitm then
                false to flag
                #Links: self 1+ 1
                ?do      i >Link#: self Data@: self item =
                         if     0 Data!: self DeleteLink: self
                                item dispose
                                true to flag   \ mark as found
                                leave
                         then
                loop     flag 0= abort" Item not found in list!"
                ;m

:m #items:  ( -- n )
            Data@: self
            if      #links: self
            else    0
            then    ;m

;class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The project tree-view control \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
load-bitmap imagelist "treeimages.bmp"

:class ProjectTreeViewControl  <super TreeViewControl

File ProjectFile
path: project-path-ptr

wm_user 100 + value TreeId

int hwndmain    \ handle of root item in tree
int hwndimage   \ handle to imagelist

\ pointers to dynamic parent list
int MainList
int ModuleList
int DllList
int FormList
int AuxList
int ResList
int DocList

8 cells bytes all-lists

:m GetList: ( -- addr ) \ return counted list of all tree items
            all-lists >r
            7          r@          !        \ number of list items
            mainlist   r@   cell+  !
            modulelist r@ 2 cells+ !
            dlllist    r@ 3 cells+ !
            formlist   r@ 4 cells+ !
            auxlist    r@ 5 cells+ !
            reslist    r@ 6 cells+ !
            doclist    r@ 7 cells+ !
            r> ;m

:m totalfiles: ( -- n )
            0       \ starting count
            GetList: self lcount cells bounds
            do      #items: [ i @ ] +
       cell +loop   ;m

max-path 1+ bytes mainfile
33 bytes projectname

: GenerateID    ( -- )
                TreeId to id
                1 +to TreeId ;

:M MainList:    ( -- list )
                MainList ;M

:M ModuleList:   ( -- list )
                ModuleList ;M

:M DLLList:     ( -- list )
                DllList ;M

:M FormList:    ( -- list )
                FormList ;M

:M AuxList:     ( -- list )
                AuxList ;M

:M ResList:     ( -- list )
                ResList ;M

:M DocList:     ( -- list )
                DocList ;M

: ?itemimages   ( -- i1 i2 ) \ i2= normal image, i1=image to display when selected
                ThisList
                case
                        ResList     of  4 4     endof
                        FormList    of  5 5     endof
                        ModuleList  of  3 3     endof
                        DLLList     of  6 6     endof
                                        2 2 rot
                endcase ;

: AddChildItem  ( -- )
                tvins  /tvins  erase
                0                           to cChildren
                Handle: ThisList            to hParent
                TVI_LAST                    to hInsertAfter
                GetName: ThisItem name-only?
                if   zcount "to-pathend" asciiz
                then                        to pszText
                ThisItem                    to lparam

                GetName: ThisItem zcount mainfile count ISTR=
                if   7 7 \ display the main project file with a different icon
                else ?itemimages
                then to iImage to iSelectedImage

                [ TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE or ] literal to mask
                InsertItem: self
                IsHandle: ThisItem ;

: UpdateList    ( addr cnt -- )
                SetName: ThisItem
                ThisList IsParentItem: ThisItem
                self IsParentTree: ThisItem
                AddChildItem
                1 +to #addedfiles
                ;

:M AddItem:     ( str cnt parentlist -- )
                to ThisList pad place
                no-duplicates?
                if      #items: ThisList ?dup
                        if      1+ 1
                                do      i >Link#: ThisList
                                        Data@: ThisList Getname: [ ] zcount
                                        pad count istr=
                                        if      unloop exitm
                                        then
                                loop
                        then
                then    Data@: ThisList
                if              AddLink: ThisList
                then    New> TreeItem dup Data!: ThisList to ThisItem
                pad count UpdateList ;M

:m AddModule:   ( str cnt -- )
                ModuleList AddItem: self ;m

:m AddForm:     ( str cnt -- )
                FormList AddItem: self ;m

:m AddDLL:      ( str cnt -- )
                DllList AddItem: self ;m

:m AddResource: ( str cnt -- )
                ResList AddItem: self ;m

:m AddAux:      ( str cnt -- )
                AuxList AddItem: self ;m

:m AddDoc:      ( str cnt -- )
                DocList AddItem: self ;m

:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_BORDER invert and \ remove WS_BORDER style
                WS_CLIPCHILDREN or
                [ TVS_HASLINES TVS_HASBUTTONS or TVS_DISABLEDRAGDROP or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] literal or
                ;M

: AddParentItem ( lparam hAfter hParent nChildren -- hwnd )
                tvins  /tvins  erase
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                ( lparam)         to lparam
                getname: lparam
                                  to pszText
                0                 to iImage
                1                 to iSelectedImage
                TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or
                TVIF_IMAGE or TVIF_SELECTEDIMAGE or to mask
                InsertItem: self ;

: AddParentLists   ( -- )
                mainlist    TVI_LAST  TVI_ROOT   1  AddParentItem dup to hwndmain ishandle: mainlist
                modulelist  TVI_LAST  hwndmain   1  AddParentItem isHandle: modulelist
                formlist    TVI_LAST  hwndmain   1  AddParentItem isHandle: formlist
                DLLList     TVI_LAST  hwndmain   1  AddParentItem isHandle: DLLList
                auxlist     TVI_LAST  hwndmain   1  AddParentItem isHandle: auxlist
                reslist     TVI_LAST  hwndmain   1  AddParentItem isHandle: reslist
                doclist     TVI_LAST  hwndmain   1  AddParentItem isHandle: doclist
                ;

:M SortParentLists:   ( -- )
\ Sort the content of the lists
                handle: modulelist SortChildren: self
                handle: formlist   SortChildren: self
                handle: DLLList    SortChildren: self
                handle: auxlist    SortChildren: self
                handle: reslist    SortChildren: self
                handle: doclist    SortChildren: self
                ;M

:m SetProjectName: ( addr cnt -- )
                projectname 33 erase
                32 min 0max projectname place ;m

:m ProjectName:  ( -- addr cnt )
                projectname count ;m

:m &ProjectName: ( -- addr )
                projectname ;m

: .buildfile    ( -- )
\                 mainfile c@ dup
\                 if      s" "
\                 else    s" No build file set"
\                 then    new$ dup>r place
\                 mainfile count r@ +place
\                 if       s"  ---- Total files in project= " r@ +place
\                          totalfiles: self (.) r@ +place
\                 then     r> count SetText: ProjInfo false to dirty?
                ;

:m setbuildfile:  ( addr cnt -- )
                mainfile place .buildfile
		;m

:m getbuildfile:   ( -- addr cnt )
                mainfile count ;m

:m Classinit:   ( -- )
                Classinit: super
                generateID
                0 to SelectedItem
                s" Project" setprojectname: self ;m

: DisposeThisList ( <list> -- )
                to ThisList
                >FirstLink: ThisList
                #Links: ThisList 0
                do      Data@: ThisList ?dup
                        if      Dispose
                                0 Data!: ThisList
                        then    DeleteLink: ThisList
                        >NextLink: ThisList
                loop    ;

: DisposeLists ( -- )
          mainlist 0= ?exit
          mainlist   DisposeThisList 0 to mainlist
          modulelist DisposeThisList 0 to modulelist
          formlist   DisposeThisList 0 to formlist
          dlllist    DisposeThisList 0 to dlllist
          auxlist    DisposeThisList 0 to auxlist
          reslist    DisposeThisList 0 to reslist
          doclist    DisposeThisList 0 to doclist  ;

\ enumerate parent ids
enum:
_main
_module
_form
_dll
_aux
_res
_doc ;

: CreateTree ( -- )
              _main   projectname: self     new> treelinked-list to mainlist     \ main file
              _module s" Modules"           new> treelinked-list to modulelist   \ .f files
              _form   s" Forms"             new> treelinked-list to formlist     \ *.frm files
              _dll    s" DLLs"              new> treelinked-list to dlllist      \ dll list
              _aux    s" Auxiliary Files"   new> treelinked-list to auxlist      \  .cfg files
              _res    s" Resources"         new> treelinked-list to reslist      \ resource files
              _doc    s" Docs"              new> treelinked-list to doclist      \ .htm, .doc, .txt
                ;

: CreateImageList ( -- )    \ create image list for treeview control
            8               \ maximum images
            7               \ number of images to use
            ILC_COLOR4      \ color depth
            18 16           \ bitmap size height,width
            Call ImageList_Create to hwndimage ;

: AddImages { \ ptreebmp -- }
            hwndimage 0= ?exit    \ we don't have any
            ImageList usebitmap   \ create bitmap handle
            GetDc: self dup>r CreateDIBitmap to ptreebmp
            r> ReleaseDc: self
            ptreebmp              \ was it successful?
            if      NULL          \ no overlay image list
                    ptreebmp
                    hwndimage
                    Call ImageList_Add -1 = s" Add images failed!" ?messagebox
                    ptreebmp Call DeleteObject drop \ discard, windows has a copy
            then    ;

: RegisterList ( -- )   \ register imagelist with this treeview control
        hwndimage ?dup 0= ?exit
        TVSIL_NORMAL SetImageList: self ;

:M start:   ( parent -- )
            start: super
            self to TheProject
            project-path-ptr program-path-init \ init project search path
            CreateImageList
            AddImages
            RegisterList
            CreateTree
            AddParentLists
            ;M

:m ~:   ( -- )
        DisposeLists ;m

:m Close: ( -- )
        DisposeLists
        hwndimage ?dup
        if      Call ImageList_Destroy drop
                0 to hwndimage
        then
        Close: super
        ;m

:M On_SelChanged: ( -- f )
        new$ >r
        lparamNew to SelectedItem

        itemid: SelectedItem
        if
            s" Number of files = " r@ place
            #items: SelectedItem (.) r@ +place
            FileExt off
        else
            GetName$: SelectedItem
            2dup r@ place
            2dup ".ext-only"
            2dup lower
                 FileExt place   \ set FileExt
             r@ IDM_OPEN_RECENT_FILE DoCommand
        then  r>drop
	.buildfile
        SetFocus: self   \ ProjectManager.htm item lost focus before
        false
        ;M

:M SelectItem: ( hItem -- )   TVGN_CARET TVM_SELECTITEM SendMessage:SelfDrop ;M

:M Delete: ( -- )
        SelectedItem 0=      if exitm then
        itemid: SelectedItem if exitm then \ can't delete parent
        s" Remove " new$ dup>r place
        getname: SelectedItem zcount r@ +place
        s"  from project?" r@ +place
        r@ +NULL
        r> 1+               ( sztext )
        z" Are you sure?"   ( ztitle )
        MB_YESNO            ( style  )
        MessageBox: parent IDNO = if  SetFocus: self  exitm  then
        handle: SelectedItem    \ save handle of selected item on stack
        SelectedItem  ParentItem: SelectedItem to SelectedItem  DeleteItem: SelectedItem
        #items: SelectedItem    \ SelectedItem is now ParentItem
        SelectedItem MainList = or   \ don't reset main list
        IF  DeleteItem: self 0= abort" Delete item failed!"
        ELSE  drop  handle: SelectedItem  dup SelectItem: self  CollapseReset: self
        THEN
        true to Modified
        ;M

:M Rename: ( -- )
        tvitem /tvitem erase
        hwndmain to hitem
        TVIF_TEXT to mask
        ProjectName 1+ to psztext
        SetItem: self
        ProjectName count SetName: mainlist
        ;M

:M SetProjectFileName:   ( addr cnt -- )
                2dup SetName: ProjectFile
                pad place pad Insert: RecentProjectFiles
                ;M

:M GetProjectFileName:   ( -- addr cnt )
                ProjectFile.filename count ;M

:M SaveProject: ( -- )

                ProjectFile.filename c@ 0=
                if      SaveProjectFile count ?dup
                        if      2dup pad place ".ext-only" nip 0=
                                if      s" .fpj" pad +place
                                then    pad count SetProjectFileName: self
                        else    drop exitm
                        then
                then    initbuffer
                s" ProjectName= " append ProjectName: self append&crlf
                s" BuildFile= " append GetBuildFile: self  relpath&append&crlf \ Sonntag, Mai 30 2004 - 10:40 dbu
                s" SearchPath= " append project-path-ptr count append&crlf
                GetList: self lcount cells bounds
                do      i @ to ThisList
                        getname: ThisList zcount append
                        ',' cappend
                        #items: ThisList (.) append&crlf
                        #items: ThisList 1+ 1
                        ?do     i >Link#: ThisList
                                Data@: ThisList getname: [ ] zcount relpath&append&crlf \ Sonntag, Mai 30 2004 - 10:40 dbu
                        loop
           cell +loop    Create: ProjectFile ?exitm
                TheBuffer Write: ProjectFile
                Close: ProjectFile
                false to Modified
                s" Error saving project" ?MessageBox ;M

0 0 2value rem-buffer

: readlist      { laddr -- }
                0 word count number? nip
                if      0
                        ?do         rem-buffer readline-memory 2to rem-buffer
                                    ?dup
                                    if      Prepend<home>\ \ Sonntag, Mai 30 2004 - 10:40 dbu
                                            laddr additem: self
                                    else    drop
                                    then
                        loop
                else    drop true abort" Missing number!"
                then    ;

: get-word      { ch -- addr cnt }
                rem-buffer readline-memory 2to rem-buffer
                (source) 2! >in off ch word count ;

:M OpenProject: ( -- )
        ProjectFile.filename c@
        IF
            Open: ProjectFile 0=
            IF
                FileSize: ProjectFile drop bufferaddress !
                TheBuffer Read: ProjectFile
                Close: ProjectFile
                ?exitm      \ test flag from read operation
                source 2>r >in @ >r
                TheBuffer 2to rem-buffer
                bl get-word s" ProjectName=" caps-compare 0=
                if      0 word count SetProjectName: self
                else    true abort" Expected project name not found!"
                then    bl get-word s" BuildFile=" caps-compare 0=
                if      0 word count Prepend<home>\ SetBuildFile: self
                else    true abort" Build file name not found!"
                then    bl get-word s" SearchPath=" caps-compare 0=
                if      bl word count project-path-ptr place
                else    true abort" Search path not found!"
                then    \ now we read in files
                begin   rem-buffer nip
                while   ',' get-word pad place
                        pad dup count lower
                        case
                                s" docs"            "of doclist readlist     endof
                                s" modules"         "of modulelist readlist  endof
                                s" forms"           "of formlist readlist    endof
                                s" resources"       "of reslist readlist     endof
                                S" dlls"            "of dlllist readlist     endof
                                S" auxiliary files" "of auxlist readlist     endof
                                projectname: self here place here count
                                2dup lower          "of mainlist readlist    endof
                                true abort" Unknown name in project file"
                        endcase
                repeat  r> >in ! 2r> (source) 2!
             THEN
        THEN
        hwndmain TVE_EXPAND Expand: self
        hwndmain GetChild: self SelectItem: self
        ;M

:M Clear:       ( -- )
        TVI_ROOT DeleteItem: self drop

        DisposeLists
        RegisterList
        CreateTree
        AddParentLists
        ;M

:M path-ptr:    ( -- addr )
        project-path-ptr ;M

;class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ The commands for working with a project
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

((
: Expand/Collapse ( a f -- )   swap to ThisList Handle: ThisList swap Expand: TheProject ;
: Expand ( a -- )   TVE_EXPAND Expand/Collapse ;
: Collapse ( a -- )   TVE_COLLAPSE Expand/Collapse ;

: ExpandAll ( -- )
        ModuleList: TheProject expand
        FormList: TheProject expand
        DLLList: TheProject expand
        AuxList: TheProject expand
        ResList: TheProject expand
        DocList: TheProject expand
        MainList: TheProject expand
        ModuleList: TheProject to ThisList Handle: ThisList SelectItem: TheProject
\         SetSplitter
        ; \ IDM_EXPAND_ALL SetCommand

: CollapseAll ( -- )
        ModuleList: TheProject collapse
        FormList: TheProject collapse
        DLLList: TheProject collapse
        AuxList: TheProject collapse
        ResList: TheProject collapse
        DocList: TheProject collapse
        MainList: TheProject collapse
        MainList: TheProject to ThisList Handle: ThisList SelectItem: TheProject
        ; \ IDM_COLLAPSE_ALL SetCommand
))

: SetProjectTitle   ( -- )
\         s" Forth Project Manager - " pad place
\         GetProjectFileName: TheProject dup 0=
\         if   2drop s" untitled.fpj"
\         then pad +place pad count SetText: TheProjectWindow
        ;

: reset-results ( -- )
        0 to #addedfiles
        0 to #linecount
        0 to total-size
        ;

: (open-project) ( a1 n1 -- )
        wait-cursor
        2dup SetProjectFileName: TheProject
        "path-only" 2dup SetDir: OpenProjectDialog
        2dup SetDir: SaveFileDialog  SetDir: GetFilesDialog

        Clear: TheProject
        OpenProject: TheProject
        Rename: TheProject
        SetFocus: TheProject
        SortParentLists: TheProject
        SetProjectTitle
        reset-results
        ReleaseBuffer: viewerfile
        arrow-cursor
        IDM_SHOWPROJECT_TAB DoCommand
        Update
        ;

: ?SaveMessage  ( -- n )
\ returns IDYES, IDNO or IDCANCEL
        s" Do you want to save " pad place
        GetProjectFileName: TheProject ?dup
        IF  "to-pathend"
        ELSE  drop ProjectName: TheProject
        THEN  pad +place
        s"  ?" pad +place  pad +NULL
        pad 1+ z" Project Manager"
        [ MB_ICONEXCLAMATION MB_YESNOCANCEL or ] literal
        NULL MessageBox ;

: SaveIfModified        ( -- f )
\ returns true if not cancelled or not modified
        true
        Modified
        IF   ?SaveMessage
             Case
                IDCANCEL Of drop false              Endof
                IDYES    Of SaveProject: TheProject Endof
                ( otherwise IDNO )  false to Modified
             EndCase
        THEN ;

: GetProjectName        ( -- f1 )
        &ProjectName: TheProject MainWindow Start: GetProjectNameDlg ;

: (rename-project)      ( -- )
        ProjectName: TheProject nip 0=
        if   s" Project" SetProjectName: TheProject
        then Rename: TheProject ;

: new-project   ( -- )
\ Create a new project
        SaveIfModified 0= ?exit

        GetProjectName 0= ?exit
        (rename-project)

        pad 0 SetBuildFile: TheProject
        pad 0 (open-project)
        ; IDM_NEW_PRJ SetCommand

: close-project	( -- )
        SaveIfModified 0= ?exit
	s" Project" SetProjectName: TheProject
        pad 0 SetBuildFile: TheProject
        pad 0 (open-project)
	; IDM_CLOSE_PRJ SetCommand

: open-project  ( -- )
\ Open a project
        SaveIfModified  0= ?exit
        OpenProjectFile count ?dup
        if   WINPAUSE (open-project)
        else drop
        then ; IDM_OPEN_PRJ SetCommand

: OpenRecentProjectFile ( File$ -- )
        SaveIfModified
        IF   count (open-project)
        ELSE drop
        THEN ; IDM_OPEN_RECENT_FILE_PRJ SetCommand

: save-project  ( -- )
\ Save the project
        SaveProject: TheProject
        SetProjectTitle ; IDM_SAVE_PRJ SetCommand

: save-as       ( -- )
\ Save the project to a new file
        GetProjectFileName: TheProject   \ save filename on stack
        s" " SetProjectFileName: TheProject
        SaveProject: TheProject
        GetProjectFileName: TheProject nip
        IF   2drop SetProjectTitle   \ if not cancelled set new title
        ELSE SetProjectFileName: TheProject   \ else restore filename
        THEN ; IDM_SAVE_AS_PRJ SetCommand

: rename-project        ( -- )
\ Rename the project
        GetProjectName 0= ?exit
        (rename-project)
        true to Modified
        ; IDM_RENAME_PRJ SetCommand

: New-module    { \ tempfile -- }
\ Create and edit a new .f file
                SaveModuleFile count dup 0=
                if      2drop exit
                then
\                 clear-status-bar
                2dup pad place ".ext-only" nip 0=
                if      s" .f" pad +place
                then    initbuffer
                s" \ " append
                pad count "to-pathend" append&crlf
                New> File to Tempfile
                pad count SetName: TempFile
                Create: Tempfile 0=
                if      TheBuffer Write: TempFile
                        Close: TempFile
                        0=      \ test flag from write operation
                        if      pad count AddModule: TheProject
                                Handle: ThisItem SelectItem: TheProject
\                                 IDM_EXECUTEFILE DoCommand   \ open default editor
                                true to Modified
                        then
                then    TempFile dispose ;   IDM_NEW_MODULE_PRJ SetCommand

: add-tree-file   { \ sitem -- }
\ Add one or more files to the project
                SelectedItem 0= ?exit
                SelectedItem dup itemid: [ ] 0=     \ if child selected
                if   parentitem: [ ]             \ use its parent
                then to sitem SelectAFile c@
                if   #SelectedFiles: GetFilesDialog 0
                     do   i GetFile: GetFilesDialog sitem AddItem: TheProject
                     loop
                     Handle: ThisItem SelectItem: TheProject
                     SortParentLists: TheProject
                     true to Modified
            \    else drop
                then ; IDM_ADD_PRJ SetCommand

: delete-item   ( -- )
\ Delete a file from the project.
                Delete: TheProject ; IDM_DELETE_PRJ SetCommand

create datfile ," projectpath.dat"

: save-path-to-file  ( -- )
                prognam>pad datfile count pad +place
                pad count w/o create-file
                if drop exit then
                >r path-ptr: TheProject count r@ write-line drop
                r> close-file drop ;

: set-build-path ( -- )
                path-ptr: TheProject MainWindow Start: GetPathDialog
                dup if  true to Modified  then
                2 = if  save-path-to-file  then
                ;   IDM_SET_BUILD_PATH_PRJ SetCommand

: AddFile ( a n -- )   \ add this file to needed list
        2dup ".ext-only" FileExt place
        FileExt dup count lower
        Case
            s" .f"      "of  addmodule:   TheProject  endof
            s" .frm"    "of  addform:     TheProject  endof
            s" .dll"    "of  adddll:      TheProject  endof
            s" .bmp"    "of  addresource: TheProject  endof
            s" .ico"    "of  addresource: TheProject  endof
            s" .cur"    "of  addresource: TheProject  endof
            s" .res"    "of  addresource: TheProject  endof
            s" .h"      "of  addresource: TheProject  endof
            s" .txt"    "of  adddoc:      TheProject  endof
            s" .htm"    "of  adddoc:      TheProject  endof
            s" .html"   "of  adddoc:      TheProject  endof
            ( default ) -rot addaux:      TheProject
        EndCase
        ;

false value skip-recurse?
false value dialog?
false value comment?
\    // --   -1   \S
\    (         1    )
\    ((        2   ))
\    /*        4   */
\    (*        8   *)
\    comment:  16  comment;
\    DOC  keep this for adding files like docs  ENDDOC

: +Comment ( n -- )   comment? IF  drop  ELSE  comment? or to comment?  THEN ;
: -Comment ( n -- )   invert comment? and to comment? ;
: \Comment ( -- )   comment? 0= IF  source nip >in !  THEN ;   \ ignore till end of line

Create squote ,$ 's"'
Create zquote ,$ 'z"'
Create fpathplus ,$ '"fpath+'

: skip-"	( -- )
		'"' parse 2drop ;

: "fpath+? ( -- )   \ if next word but one is "fpath+ then append to search path
        >in @
        bl word count '"' -TrailChars pad place
        bl word count fpathplus count caps-compare 0=
        IF  pad count "fpath+ drop
        ELSE  >in !
        THEN ;

: needed-file? ( -- f )   \  if 2nd word is needed-file or loadbitmapfile
        >in @             \  or 4th/5th word is AddAppIcon then add file to project
        bl word drop      \  skip 1st word
        bl word  dup count lower   \ 2nd word
        Case
            s" loadbitmapfile"  "of  true  endof
            s" needed-file"     "of  true  endof
            s" addcursor"       "of  true  endof
            s" addicon"         "of  true  endof
            ( default ) false swap
        Endcase
        bl word drop  bl word count  s" AddAppIcon" caps-compare 0= or   \ 4th word
        bl word count  s" AddAppIcon" caps-compare 0= or   \ 5th word
        swap >in !
        ;

: LoadLibrary? ( -- f )   \  if next word but two is LoadLibrary then add file to project
        >in @
        bl word drop  bl word drop
        bl word count  s" LoadLibrary" caps-compare 0=
        swap >in !
        ;

: include-word? ( -- f )   \ search input stream for include strings, true if found
        false to dialog?
        false to skip-recurse?
        bl word  dup count lower  dup c@
        IF
            Case
                s" \"               "of  \comment                             false  endof
                s" //"              "of  \comment                             false  endof
                s" --"              "of  \comment                             false  endof
                s" \s"              "of  -1 +Comment                          false  endof
                s" ("               "of  1  +Comment                          false  endof
                s" )"               "of  1  -Comment                          false  endof
                s" (("              "of  2  +Comment                          false  endof
                s" ))"              "of  2  -Comment                          false  endof
                s" /*"              "of  4  +Comment                          false  endof
                s" */"              "of  4  -Comment                          false  endof
                s" (*"              "of  8  +Comment                          false  endof
                s" *)"              "of  8  -Comment                          false  endof
                s" comment:"        "of  16 +Comment                          false  endof
                s" comment;"        "of  16 -Comment                          false  endof
                squote count        "of  "fpath+? needed-file? dup 0=
					 if	skip-"		\ if not needed file
					 then	true to skip-recurse? 		     endof
                zquote count        "of  LoadLibrary? dup 0=
					 if	skip-"
					 then	true to skip-recurse?         	     endof
                s" needs"           "of                                        true  endof
                s" fload"           "of                                        true  endof
                s" include"         "of                                        true  endof
                s" require"         "of                                        true  endof
                s" sys-fload"       "of                                        true  endof
                s" winlibrary"      "of  true to skip-recurse?                 true  endof    \ don't search .dll file
                s" sys-winlibrary"  "of  true to skip-recurse?                 true  endof    \ don't search .dll file
                s" load-dialog"     "of  true to skip-recurse? true to dialog? true  endof    \ add .res and .h later
                s" load-bitmap"     "of  bl word drop  true to skip-recurse?   true  endof    \ skip bitmap name
                s" toolbar"         "of  bl word drop  true to skip-recurse?   true  endof    \ skip bitmap name
                ( default ) 	    AddWord: TheNavigator false dup
            EndCase
            comment? 0= and
        ELSE  drop false
        THEN ;

: is-file? ( -- name len true | false )   \ scan input stream for next word, return true if it is a valid filename
        bl word count ?dup
        IF
            '"' skip  '"' -TrailChars   \ remove opening and closing quotes in event it is from load-bitmap
            dialog? IF  pad place  s" .h" pad +place  pad count  THEN   \ add .h to file if from load-dialog
            "path-file
            IF   2drop  false  \ missing-file
            ELSE  true
            THEN
        ELSE  drop  false
        THEN ;

\ Given file name search for needed files
: BuildNeededFiles  { fname fcnt \ tmp$ file$ -- }      \ recursive routine
                false to comment?
                0 to nav-linecount
                maxstring malloc to tmp$
                max-path malloc to file$
                fname fcnt 2dup curfilename place "open
                if   drop exit
                then source-ID >r to source-ID
                source-ID file-size 2drop +to total-size
                >in @ >r
                source 2>r                     \ save current source
                tmp$ (source) cell+ !
                refill
                if      1 +to #linecount
			1 +to nav-linecount
                then
                begin   more? dup 0=
                        if      drop refill dup
                                if      1 +to #linecount     \ bump line count
					1 +to nav-linecount
                                then
                        then
                while   include-word?
                        if  is-file?
                            if	#addedfiles -rot
				2dup addfile
                                dialog? IF
                                            2dup pad place -2 pad c+! s" .res" pad +place
                                            pad count addfile

                                        THEN
                                rot #addedfiles -		\ was a file added?
                                skip-recurse? not and
                                if     comment? nav-linecount 2swap	\ save some things
					curfilename count file$ place
					recurse
					to nav-linecount to comment?   \ restore some things
					file$ count curfilename place
				else	2drop
                                then
                            then
                        then ( false to skip-recurse? )
                repeat  source-id close-file drop
                2r> (source) 2!
                r> >in !
                r> to source-id
                tmp$ release
                file$ release ;

: InitNavigator	( -- )
		ProjectName: TheProject SetName: TheNavigator
		Clear: TheNavigator
		0 to nav-linecount
		curfilename off ;

: (build-project) { fClear \ old-path$ -- }

                MAXSTRING CHARS 1+ LocalAlloc: old-path$
                search-path count old-path$ place \ save current search path

                path-ptr: TheProject count dup
                if   search-path place \ set project search path
                else drop program-path-init \ set default project search path
                then reset-results
                GetBuildFile: TheProject nip 0=
                if      SelectAFile c@
                        if      0 GetFile: GetFilesDialog
                                SetBuildFile: TheProject
                        else    drop exit
                        then    GetBuildFile: TheProject ModuleList: TheProject
                                AddItem: TheProject
                                true to Modified
                then
                fClear if Clear: TheProject then
                GetBuildFile: TheProject ModuleList: TheProject
                AddItem: TheProject
                true to Modified
		s" Building project" "message
		InitNavigator
                GetBuildFile: TheProject BuildNeededFiles
                UnInit: TheNavigator
                message-off
                #addedfiles Modified or to Modified
                #addedfiles (.) pad place
                s"  files added\n " pad +place
                #linecount 0 (UD,.) pad +place
                s"  lines searched totalling " pad +place
                total-size 0 (UD,.) pad +place
                s"  bytes" pad +place
                true pad count ?Messagebox

                GetBuildFile: TheProject SetBuildFile: TheProject \ update info

                SortParentLists: TheProject
                SortParentLists: TheNavigator

                old-path$ count search-path place \ restore current search path
                ;   IDM_BUILD_PRJ SetCommand

: build-project ( -- )
\ Build the project
\ The files that are currently added to the project are not removed.
                control-key?	\ full rebuild if control key pressed
                if	true
                else	false
                then	(build-project) ;   IDM_BUILD_PRJ SetCommand

: rebuild-project ( -- )
\ Rebuild the project
\ The files that are currently added to the project are removed first.
                true (build-project) ;   IDM_REBUILD_PRJ SetCommand

: add-opened-files { \ thechild -- }
                TabFile? ?dup
                if      0
                        do      i GetFileTabChild dup to TheChild
                                if	TheChild ActiveCoder <>
					if	GetFileName: TheChild count ".ext-only" nip \ not viewing source?
						if	GetFileName: TheChild count AddFile
						then
					then
				then
                        loop
                then    ; IDM_ADD_OPEN_PRJ SetCommand

