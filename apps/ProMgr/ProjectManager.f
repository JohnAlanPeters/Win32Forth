\ $Id: ProjectManager.f,v 1.21 2010/12/02 05:34:42 ezraboyce Exp $

\ ProjectManager.f    version 2

anew -ProjectManager.f

comment:

Tuesday, June 13 2006 - Rod

    Updated to work with TreeView class derived from Control class by adding
    StartSize: method to TheProject.  Used WndClassStyle: method instead of SetClassLong
    wherever possible.  Splitter bar object NOT needed when background of main window
    is set to COLOR_BTNFACE.

October 07, 2005 - EAB - added class for viewing binary files of any size.

September 5th, 2005  Rod - version 2.01.00

Corrected bug in finding .res file
Build project now finds AddCursor and AddIcon, .ico and .cur files added to resources section
Cursor drawn in right pane for .cur file

July 10th, 2005  Rod - additional features and tidying of code for version 2

More menu items:
    Save As
    Recent files
    Expand/collapse all tree items
    Copy/Zip non library files
    Compile - start up a console to compile the main build file (F12)
    Uninstall - removes registry settings

More shortcut keys:
    <Return> opens current item
    <Delete> deletes current item
    and see menu items

Cosmetic changes:
    Smooth splitter window movement, splitter adjusted to fit treeview with double click
    NO flicker when sizing window (except scroll bars in HTML window)
    Removed border on statusbar and right pane

Build project:
    Ignores ALL filenames commented out except: DOC...ENDDOC (can use to add docs to Project)
    Finds "fpath+ and adds to search path
    Finds needed-file adds file to project
    Finds Load-dialog adds .res and .h files to resources item
    Finds z" ?.dll" Call LoadLibrary adding file to project
    Finds AddAppIcon adds icon file to resources item

Prompt to save project file when modified on closing

May 15, 2004 08:57:31 PM - factored out project manager into a separate application
First integrated into ForthForm, but I thought that it would be a little cumbersome
to have the additional files required - especially the Zip32.dll and w32fScintilla.dll -
distributed with ForthForm.

Sonntag, Mai 30 2004 - dbu
  - Changed to display up to 1MB Text in the preview window under WinNT 4
    and later. Under all other Windows versions 64KB Text is displayed.
  - Changed to store the Paths relative to &forthdir in the Projekt file
  - Made the text preview window readonly
  - Changed to save/restore the window position of the main window
  - Added simple command line handling to open a project file
  - Changed to include into the next Win32Forth distribution
  - Changed to use BrowseForFolder from BROWSEFLD.F to avoid duplicate functionality
    in different files

Sonntag, Juni 06 2004 - dbu
  - Added Hyperlinking between the source files.
    To browse to a word select it in the preview window and press the right
    mouse button. To get back hold the Ctrl-Key and press the right mouse button.
    The Hyperlinking is using the browse information from the word headers, so
    only words that are part or Win32Forth.exe can be found.
  - The folder for project files is saved between two sessions

June 18, 2004 - EAB
    Modified to save search path for a project in the project file. Loading a project file
    will automatically set the path for that project.

Montag, Juni 28 2004 - dbu
    - Made the command line handling work

July 03, 2004 - added version information - EAB

July 31, 2004 - added Html viewer for .htm files and help file - EAB

November 30, 2004 - skips any files after a "\" comment - EAB
                    Displays tree whenever a new project is opened

November 30, 2004 - discovered long-standing bug when building a project from the menu.
                    Serious crash occurs when mouse is moved over the splitter line.

comment;

true value sysgen
s" apps\ProMgr"     "fpath+
s" apps\ProMgr\res" "fpath+

\ Version numbers: v.ww.rr
\
\ v   Major version
\ ww  Minor version
\ rr  Release
\
\ Odd minor version numbers are possibly unstable beta releases.

Create ProjectVersion ," 2.01.02"

needs linklist.f
needs treeview.f
needs enum.f
needs file.f
needs bitmap.f
needs fcases.f
needs excontrols.f
needs toolbar.f
needs zipper.f            \ interface for Info-Zip's free Zip32.dll
needs multiopen.f         \ allow the selection of multiple files
needs exutils.f         \ shared definitions from ForthForm
needs ScintillaHyperEdit.f
needs HtmlDisplayWindow.f
needs hexviewer.f        \ hex dump class
needs RegistrySupport.f
needs RecentFiles.f
needs PMMenu.f            \ Menu and command IDs in separate file
needs AcceleratorTables.f

true value name-only?
true value no-duplicates?
0 value #addedfiles
0 value #linecount
0 value total-size
0 value SelectedItem
0 value ThisList    \ temp pointer to list being used
0 value ThisItem    \ temp pointer to new item
0 value TheProjectWindow
0 value WindowState
0 value Modified
200 value LeftWidth
0 value StatusBarHeight
0 value FlatToolbar?
0 value ToolBarHeight
0 value TheToolBar
: ShowToolbar ( -- )   GetWindowRect: TheToolBar nip swap - nip to ToolbarHeight
        SW_SHOW show: TheToolBar  true check: hToolbar ;
: HideToolbar ( -- )   0 to ToolbarHeight
        SW_HIDE show: TheToolBar  false check: hToolbar ;
0 value TheStatusBar
: ShowStatusBar ( -- )   GetWindowRect: TheStatusBar nip swap - nip to StatusBarHeight
        SW_SHOW show: TheStatusBar  true check: hStatusBar ;
: HideStatusBar ( -- )   0 to StatusBarHeight
        SW_HIDE show: TheStatusBar  false check: hStatusBar ;
0 value dirty?
: clear-status-bar ( -- )
        z" " 0 SetText: TheStatusBar
        dirty? if  z" " 1 SetText: TheStatusBar  false to dirty?  then ;
false value NoLibFiles
: LibFile? ( a n - f )   "path-only"  dup 7 - /string  s" src\lib"  caps-compare 0= ;
Create FileExt 16 allot
Create ThisPath max-path allot
Create ProjectPath max-path allot

needs AboutForm.f


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Define the Accelerator Table \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AcceleratorTable PMAccelerators


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Registry sets and words to save/restore recent files and remove all keys
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

PROGREG-SET-BASE-PATH
create RegPath$ max-path allot
ProgReg count RegPath$ place  s" ProjectManager"  RegPath$ +place
RegPath$ count                                                   RegistrySet ProjectManager
RegPath$ count pad place s" \Window" pad +place pad count        RegistrySet WindowSettings
RegPath$ count pad place s" \Options" pad +place pad count       RegistrySet Options
RegPath$ count pad place s" \Recent Files" pad +place pad count  RegistrySet RecentFilesList

: SaveRecentFiles ( -- )
        RecentFilesList  s" File1"
        10 1 DO
                2dup + 1- i 48 + swap c! 2dup
                i GetRecentFile: RecentFiles count
                2swap REG_SZ SetRegistryValue
        LOOP 2drop ;

: RestoreRecentFiles ( -- )
        RecentFilesList  s" File1"
        9 0 DO
                2dup + 1- 57 i - swap c!  2dup
                REG_SZ GetRegistryValue  over 1- c! 1-  Insert: RecentFiles
        LOOP 2drop ;

: RemoveRegKeys ( -- )
        WindowSettings DeleteKey
        Options DeleteKey
        RecentFilesList DeleteKey
        ProjectManager  s" " s" " REG_SZ SetRegistryValue  DeleteKey ;


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
                Gethandle: TheProjectWindow Start: OpenProjectDialog ;

: SelectAFile   ( -- addr )
                s" All Files|*.*|Forth Files|*.f|" SetFilter: GetFilesDialog
                s" Select File"                    SetTitle: GetFilesDialog
                GetHandle: TheProjectWindow Start: GetFilesDialog ;

: SaveProjectFile ( -- addr )
                s" Project Files|*.fpj|" SetFilter: SaveFileDialog
                s" Save Project File"     SetTitle: SaveFileDialog
                GetHandle: TheProjectWindow Start: SaveFileDialog ;

: SaveZipFile   ( -- addr )
                s" Zip files|*.zip|All Files|*.*|" SetFilter: SaveFileDialog
                s" Select archive file"             SetTitle: SaveFileDialog
                Gethandle: TheProjectWindow Start: SaveFileDialog ;

: SaveModuleFile ( -- addr )
                s" Forth Files|*.f|All Files|*.*" SetFilter: SaveFileDialog
                s" New Module File"                SetTitle: SaveFileDialog
                GetHandle: TheProjectWindow Start: SaveFileDialog ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The Toolbar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ load-bitmap ptoolbarBitmap "pbitmaps.BMP"
load-bitmap ptoolbarBitmap "ToolbarBitmaps.bmp"

:ToolStrings ptoolbarTooltips
        ts," New Project"
        ts," Open Project"
        ts," Save Project"
        ts," Delete item"
        ts," Build Project"
        ts," Archive project"
        ts," Add files"
        ts," Copy project files"
;ToolStrings

:ToolBarTable ptoolbarTable
\ Bmp ndx     ID       Initial Style    Initial State     Tooltip Ndx
\ The default state and style for all buttons are enabled and button style
\ You can modify as desired
  0        IDM_NEW     TBSTATE_ENABLED  TBSTYLE_BUTTON    0 ToolBarButton,
  1        IDM_OPEN    TBSTATE_ENABLED  TBSTYLE_BUTTON    1 ToolBarButton,
  2        IDM_SAVE    TBSTATE_ENABLED  TBSTYLE_BUTTON    2 ToolBarButton,
  3        IDM_DELETE  TBSTATE_ENABLED  TBSTYLE_BUTTON    3 ToolBarButton,
  4        IDM_BUILD   TBSTATE_ENABLED  TBSTYLE_BUTTON    4 ToolBarButton,
  5        IDM_ZIP     TBSTATE_ENABLED  TBSTYLE_BUTTON    5 ToolBarButton,
  6        IDM_ADD     TBSTATE_ENABLED  TBSTYLE_BUTTON    6 ToolBarButton,
  7        IDM_COPY    TBSTATE_ENABLED  TBSTYLE_BUTTON    7 ToolBarButton,
;ToolBarTable

:Object ptoolbar        <Super Win32Toolbar

int hbitmap

:M ClassInit:  ( -- )
        ClassInit: super
        0 to hbitmap
        ;M

:M Start:   ( parent -- )
        ptoolbarTable         IsButtonTable: self
        ptoolbarTooltips        IsTooltips: self

        Start: super

        16 16 word-join 0 TB_SETBITMAPSIZE hwnd call SendMessage drop   \ smaller height of toolbar

        ptoolbarbitmap usebitmap
        map-3Dcolors            \ use system colors for background
        GetDc: self dup CreateDIBitmap to hbitmap   \ create bitmap handle from memory image
        ReleaseDc: self
        hbitmap      \ do we have a handle?
        if      0 hbitmap 8 AddBitmaps: self drop
        then
        ;M

:M WindowStyle:  ( -- style )
        WS_CHILD   \ not WS_VISIBLE - start hidden, not flat
        TBSTYLE_TOOLTIPS or
        ;M

:M On_Done:   ( -- )
        hbitmap
        if      hbitmap Call DeleteObject drop
                0 to hbitmap
        then    On_Done: super
        ;M

;Object


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

:m ishandle: ( hwnd -- )
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

ReadFile ViewerFile
Rectangle ItemRect

:Object TheProject  <super TreeViewControl

:M StartSize: ( w h -- )   width: parent height: parent ;M

File ProjectFile
load-bitmap imagelist "treeimages.bmp"

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

: GenerateID ( -- )
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

: ?itemimages    ( -- i1 i2 ) \ i2= normal image, i1=image to display when selected
                ThisList
                case
                        ResList         of  4 4     endof
                        FormList        of  5 5     endof
                        ModuleList      of  3 3     endof
                        DLLList         of  6 6     endof
                                            2 2 rot
                endcase ;

: AddChildItem  ( -- )
                tvins  /tvins  erase
                tvitem /tvitem erase
                0                                               to cChildren
                Handle: ThisList                to hParent
                TVI_LAST                        to hInsertAfter
                GetName: ThisItem name-only?
                if      zcount "to-pathend" asciiz
                then    to pszText
                                ThisItem                                        to lparam
                ?itemimages                 to iImage
                                            to iSelectedImage
                TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or
                TVIF_IMAGE or TVIF_SELECTEDIMAGE or to mask
                tvitem->tvins
        InsertItem: self
        IsHandle: ThisItem ;

: UpdateList    ( addr cnt -- )
                SetName: ThisItem
                ThisList IsParentItem: ThisItem
                self IsParentTree: ThisItem
                AddChildItem
                1 +to #addedfiles ;

:M AddItem:     ( str cnt parentlist -- )
                to ThisList pad place
                no-duplicates?
                if      #items: ThisList ?dup
                        if      1+ 1
                                do      i >Link#: ThisList
                                        Data@: ThisList Getname: [ ] zcount
                                        pad count caps-compare 0=
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
                TVS_HASLINES        or
                TVS_HASBUTTONS      or
                TVS_DISABLEDRAGDROP or
                TVS_SHOWSELALWAYS   or
                TVS_LINESATROOT     or
                ;M

: AddParentItem ( lparam hAfter hParent nChildren -- hwnd )
                tvins  /tvins  erase
                tvitem /tvitem erase
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
                tvitem->tvins
                InsertItem: self ;

: AddParentLists   ( -- )
                mainlist    TVI_LAST  TVI_ROOT   1  AddParentItem dup to hwndmain ishandle: mainlist
                modulelist      TVI_LAST  hwndmain   1  AddParentItem isHandle: modulelist
                formlist    TVI_LAST  hwndmain   1      AddParentItem isHandle: formlist
                DLLList         TVI_LAST  hwndmain   1  AddParentItem isHandle: DLLList
                auxlist         TVI_LAST  hwndmain   1  AddParentItem isHandle: auxlist
                reslist         TVI_LAST  hwndmain   1  AddParentItem isHandle: reslist
                doclist     TVI_LAST  hwndmain   1      AddParentItem isHandle: doclist
                ;

:m SetProjectName:              ( addr cnt -- )
                                projectname 33 erase
                                32 min 0max projectname place ;m

:m ProjectName:    ( -- addr )
                projectname count ;m

: .buildfile    ( -- )
                mainfile c@ dup
                if      s" Build file: "
                else    s" No build file set"
                then    new$ dup>r place
                mainfile count r@ +place
                if       s"  ---- Total files in project= " r@ +place
                         totalfiles: self (.) r@ +place
                then     r> dup +null 1+ 1 SetText: TheStatusBar false to dirty? ;

:m setbuildfile:  ( addr cnt -- )
                mainfile place .buildfile ;m

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

: RegisterList ( -- )   \ register list with this treeview control
        hwndimage ?dup 0= ?exit
        TVSIL_NORMAL SetImageList: self ;

:M start:   ( parent -- )
            start: super
            CreateImageList
            AddImages
            RegisterList
            CreateTree
            AddParentLists ;M

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
        lparamNew to SelectedItem
        itemid: SelectedItem
        if
            s" Number of files = " pad place
            #items: SelectedItem (.) pad +place
            pad dup +NULL 1+
            ReleaseBuffer: viewerfile
            FileExt off
        else
            GetName: SelectedItem  dup zcount
            2dup ".ext-only"  2dup lower  FileExt place   \ set FileExt
            LoadFile: viewerfile drop
        then
        0 Settext: TheStatusBar .buildfile IDM_SHOW_FILE DoCommand
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
                SetName: ProjectFile ;M

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
                s" SearchPath= " append search-path count append&crlf
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
                if      bl word count search-path place
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

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Left Pane \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object LeftPane  <Super Child-Window

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Init: ( -- )
        On_Init: super
        WS_CLIPCHILDREN +Style: self
        ;M

:M ExWindowStyle: ( -- )   WS_EX_CLIENTEDGE ;M

:M WM_NOTIFY ( h m w l -- f )
        dup @  GetHandle: TheProject =
        if
            dup 2 cells+ @ NM_DBLCLK =
            if  IDM_EXECUTEFILE DoCommand  then
            Handle_Notify: TheProject
        else  false
        then
        ;M

;Object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Right Pane \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object RightPane  <Super Child-Window

ScintillaHyperEdit ViewBox
BitmapObject BitmapFile
int viewfont
HtmlControl HtmlBox
HexViewer BinaryBox

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M ExWindowStyle:   ( -- )
                WS_EX_CLIENTEDGE ;M

: is-binary-file?   ( -- f )
                true       \ default
                GetBuffer: viewerfile 1000 min 0max     \ check first 1000 bytes
                bounds
                ?do     i c@ bl <
                        if      i c@ dup 0x0A <> over 0x0D <> and   \ not cr or lf
                                swap 0x09 <> and                    \ not tab char
                                if      unloop exit
                                then
                        then
                loop    not ;

: Close-viewers ( -- )
                Close: ViewBox  Close: HtmlBox Close: BinaryBox ;

: Start-ViewBox ( -- )
        Gethandle: ViewBox 0=
        if
            self start: ViewBox
            true SetBrowseMode: ViewBox
            WS_BORDER -style: Viewbox
            0 0 GetSize: self move: ViewBox
        then ;

: Start-HtmlBox ( -- )
        GetHandle: HtmlBox 0=
        if
            self Start: HtmlBox
            WS_BORDER -style: HtmlBox
\            WS_CLIPCHILDREN +Style: self
            CS_DBLCLKS GCL_STYLE GetHandle: HtmlBox Call SetClassLong  drop
            0 0 GetSize: self Move: HtmlBox
        then ;

: Start-BinaryBox  ( -- )
                 GetHandle: BinaryBox 0=
                 if         self Start: BinaryBox
                            AutoSize: BinaryBox
                 then       ;

: LoadCursor ( z$ -- h )   >r  LR_LOADFROMFILE 0 0 IMAGE_CURSOR r> 0 call LoadImage ;

int hImage

:M Show-file: ( -- )
        Close-viewers
        DisposeHyperLinks: ViewBox    \ delete the current hyperlinks
        GetBuffer: viewerfile nip
        IF
            FileExt
            Case
                s" .bmp"  "Of  GetBuffer: viewerfile drop SetBitmap: BitmapFile      Endof
                s" .ico"  "Of  Getname: SelectedItem LoadIcon to hImage           Endof
                s" .cur"  "Of  Getname: SelectedItem LoadCursor to hImage         Endof
                s" .htm"  "Of  start-htmlbox  GetName: SelectedItem SetURL: HtmlBox  Endof
                s" .html" "Of  start-htmlbox  GetName: SelectedItem SetURL: HtmlBox  Endof
                ( default ) swap
                is-binary-file?
                IF  Start-BinaryBox GetBuffer: viewerfile Dump: BinaryBox
                ELSE
                    start-ViewBox GetBuffer: viewerfile SetTextz: ViewBox
                    Getname: SelectedItem zcount SetFileName: ViewBox
                    SetSavepoint: ViewBox
                THEN
            EndCase
        THEN
        Paint: self
        ;M

:M On_Size: ( -- )
        GetHandle: ViewBox if  0 0 Getsize: self Move: ViewBox  then
        GetHandle: HtmlBox if  Autosize: HtmlBox  then
        GetHandle: BinaryBox  if AutoSize: BinaryBox then
        ;M

: DrawIcon ( hIcon -- )   0 0 dc.hdc call DrawIcon drop ;

:M On_Paint: ( -- )   \ all painting to the dc should be done here so that only invalidated areas are updated
        FileExt
        Case
            s" .bmp"  "Of  0 0 dc.hdc ShowBitmap: BitmapFile  Endof
            s" .ico"  "Of  hImage DrawIcon                 Endof
            s" .cur"  "Of  hImage DrawIcon                 Endof
        EndCase
        ;M

:M On_Init: ( -- )
        ANSI_FIXED_FONT Call GetStockObject to viewfont
        WHITE_BRUSH Call GetStockObject GCL_HBRBACKGROUND hWnd Call SetClassLong drop   \ so On_Paint: erases to white
        WS_CLIPCHILDREN +Style: self
        ;M

:M On_Done: ( -- )
        ReleaseBuffer: viewerfile
        On_Done: super ;M

:M WM_CONTEXTMENU ( hwnd msg wparam lparam -- res )
        ?BrowseMode: ViewBox
        if   VK_CONTROL Call GetKeyState 0x8000 and
                     if   <Hyper: ViewBox
                     else Hyper>: ViewBox
                     then 0
        then ;M

:M Close:    ( -- )
             Close-Viewers ;M

;Object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Project StatusBar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object ProjectStatusBar  <Super MultiStatusBar

:M WindowStyle:
        WS_CHILD   \ not WS_VISIBLE - start hidden, no border
        ;M

;Object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Project help window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object ProjectHelpWindow       <Super HtmlDisplayWindow

:M WindowTitle: ( -- zstring )
                z" Help using Project Manager" ;M

:M StartPos:    ( -- x y )
                StartPos: TheProjectWindow ;M

:M StartSize:   ( w h -- )
                screen-size >r 2/ r> 2/ ;M

:M ParentWindow: ( -- hwndparent )
                GetHandle: TheProjectWindow ;M

;Object

(( ****not needed as long as HBRBACKGROUND set to COLOR_BTNFACE in main window****
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Splitter <Super child-window

:M WindowStyle: ( -- style )   \ return the window style
        WindowStyle: super
        WS_DISABLED or
        WS_CLIPSIBLINGS or
        ;M

:M On_Paint: ( -- )            \ screen redraw method
        0 0 Width Height LTGRAY FillArea: dc
        ;M

;Object
))

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Main window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ?SaveMessage ( -- n )   \ IDYES, IDNO or IDCANCEL
        s" Do you want to save " pad place
        GetProjectFileName: TheProject ?dup
        IF  "to-pathend"
        ELSE  drop ProjectName: TheProject
        THEN  pad +place
        s"  ?" pad +place  pad +NULL
        pad 1+ z" Project Manager"
        [ MB_ICONEXCLAMATION  MB_YESNOCANCEL or ] literal
        NULL MessageBox ;

: SaveIfModified ( -- f )   \ true if not cancelled or not modified
        True
        Modified
        IF
            ?SaveMessage
            Case
                IDCANCEL  Of              drop false   Endof
                IDYES     Of  SaveProject: TheProject  Endof
                ( otherwise IDNO )  false to Modified
            EndCase
        THEN
        ;

:Object ProjectWindow  <Super Window

Create Statbar 300 , -1 ,
int dragging?
int mousedown?
int thickness
: LeftHeight ( -- n )   Height StatusBarHeight - ToolBarHeight - ;
: position-windows ( -- )
        0  ToolBarHeight  LeftWidth  LeftHeight  Move: LeftPane
        LeftWidth thickness +  ToolBarHeight  Width LeftWidth thickness + -  LeftHeight  Move: RightPane
\        LeftWidth  ToolBarHeight  thickness  LeftHeight  Move: Splitter
        AutoSize: TheProject ;

: InSplitter? ( -- f1 )   \ is cursor on splitter window
        hWnd get-mouse-xy
        0 height within
        swap  LeftWidth dup thickness + within  and ;

\ mouse click routines for Project Window to track the Splitter movement

: DoSizing ( -- )
        mousedown? dragging? or 0= ?EXIT
        mousex ( 1+ ) width min  thickness 2/ -  to LeftWidth
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
((
: On_DblClick ( -- )
        false to mousedown?
        InSplitter? 0= ?EXIT
        LeftWidth 8 >
        IF      0 thickness 2/ - to LeftWidth
        ELSE    132 Width 2/ min to LeftWidth
        THEN
        position-windows
        ;
))
:M WM_SETCURSOR ( h m w l -- )
        hWnd get-mouse-xy
        ToolBarHeight dup LeftHeight + within
        swap  0 width within and
        IF  InSplitter? IF  SIZEWE-CURSOR   ELSE  arrow-cursor  THEN  1
        ELSE  DefWindowProc: self
        THEN
        ;M

:M Classinit:   ( -- )
        ClassInit: super   \ init super class
        ProjectMenu to CurrentMenu
        NULL to TheToolBar
        5 to thickness
        ['] On_clicked     SetClickFunc: self
        ['] On_unclicked   SetUnClickFunc: self
        ['] DoSizing       SetTrackFunc: self
\        ['] On_DblClick    SetDblClickFunc: self   \ set later, SetSplitter
        ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M WindowHasMenu: ( -- f )   true ;M

:M DefaultIcon: ( -- hIcon )            \ return the default icon handle for window
       101 appInst Call LoadIcon
        ;M

:M On_Size: ( -- )
        dup to WindowState   \ get WindowState, don't save size of maximised or minimised window
        AutoSize: TheToolBar
        Redraw: ProjectStatusBar
        position-windows
        ;M

:M SetLeft: ( n -- )   to LeftWidth position-windows ;M

:M On_Init: ( -- )
        WS_CLIPCHILDREN +Style: self
        self to TheProjectWindow
        ptoolbar to TheToolBar
        1024 SetID: TheToolBar
        self Start: TheToolBar
        FlatToolbar? 0= to FlatToolbar? IDM_TOGGLE_FLAT DoCommand
        ToolbarHeight IF  ShowToolbar  THEN
        self Start: ProjectStatusBar
        StatBar 2 SetParts: Projectstatusbar
        ProjectStatusBar to TheStatusBar
        StatusBarHeight IF  ShowStatusbar  THEN

\ The following code line will be necessary depending on the background color
\ of your bitmaps. Flat toolbars are displayed using the default background
\ window color of the parent window which is white in Win32Forth. If your
\ bitmap background is not white the toolbar will seem to display strange. Set the
\ color that best suits you. You can check the Windows API for more infomation

        COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hwnd  Call SetClassLong drop

\ BTW, note that the above will change the default background color of future windows

        1 Setid: Leftpane
        self Start: Leftpane
        2 Setid: Rightpane
        self Start: Rightpane
        s" " SetProjectFileName: TheProject
        LeftPane Start: TheProject
        ;M

:M Close: ( -- )
        Close: TheProject
        Close: LeftPane
        Close: RightPane
        Close: pToolBar
        Close: ProjectStatusBar
        Close: ProjectHelpWindow
        Close: super
        ;M

:M On_Done: ( -- )
        WindowState SIZE_RESTORED = IF  WindowSettings SaveSettings  THEN
        Options SaveSettings
        ProjectManager SaveSettings
\        false promgr-started
        SaveRecentFiles
        SaveRecentFiles
        MenuHandle: CurrentMenu ?dup
        if      Call DestroyMenu ?win-error  \ discard the menubar
                        ZeroMenu: CurrentMenu
        then
        ExitScintillaControl \ Dienstag, August 03 2004 dbu
        PMAccelerators DisableAccelerators   \ free the accelerator table
\+ sysgen       0 Call PostQuitMessage
        On_Done: super
        ;M

:M WM_NOTIFY ( h m w l -- f )
        Handle_Notify: TheToolBar
        ;M

:M WM_CLOSE ( h m w l -- res )
        SaveIfModified
        IF
            GetProjectFileName: TheProject pad place pad Insert: RecentFiles
            WM_CLOSE WM: Super   \ close window
        ELSE  0                  \ abandon the close
        THEN
        ;M

:M WindowTitle: ( -- zstring )
        z" Project Manager" ;M

:M ParentWindow: ( -- hwndparent )
        0 ;M
((
: add-open-forms  ( -- )
                clear-status-bar
                param-buffer lcount dup 0=
                if      2drop true s" No open forms!" ?MessageBox exit
                then    0
                do      dup count 2dup
                        s" untitled.frm" caps-compare 0<>   \ not unsaved forms
                        if      AddForm: TheProject
                        else    pad place s"  not saved!" pad +place
                                pad +null pad 1+ 0 Settext: TheStatusBar
                        then    count +
                loop    drop ;

:M Win32Forth:  ( h m w l -- )
                over case
                        FORMS_SENT       of   add-open-forms     endof
                        Win32Forth: super
                     endcase
                0 ;M
))
:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        over LOWORD ( command ID ) dup
        IsCommand? IF  DoCommand    \ intercept Toolbar and accelerator commands
        ELSE  drop OnWmCommand: Super    \ intercept Menu commands
        THEN ;M

:M On_SetFocus: ( -- )   SetFocus: TheProject ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Set Commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ File Menu Commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: GetProjectName ( -- f1 )
                TheProject.projectname TheProjectWindow Start: GetProjectNameDlg ;

: SetProjectTitle   ( -- )
                    s" Forth Project Manager - " pad place
                    GetProjectFileName: TheProject dup 0=
                    if      2drop s" untitled.fpj"
                    then    pad +place pad count SetText: TheProjectWindow ;

: reset-results ( -- )
                0 to #addedfiles
                0 to #linecount
                0 to total-size ;

: (open-project) ( a1 n1 -- )
        clear-status-bar
        GetProjectFileName: TheProject ?dup
        IF  pad place pad Insert: RecentFiles  ELSE  drop  THEN
        2dup SetProjectFileName: TheProject
        "path-only" 2dup SetDir: OpenProjectDialog
        2dup SetDir: SaveFileDialog  SetDir: GetFilesDialog
        Close: TheProject  Leftpane Start: TheProject
        OpenProject: TheProject
        Rename: TheProject
        SetFocus: TheProject
        SetProjectTitle
        reset-results
        ReleaseBuffer: viewerfile
        IDM_SHOW_FILE DoCommand ;

: new-project ( -- )
        SaveIfModified  0= ?exit
        s" Project" SetProjectName: TheProject
        pad 0  SetBuildFile: TheProject
        pad 0 (open-project)
        ;   IDM_NEW SetCommand

: open-project  ( -- )
        SaveIfModified  0= ?exit
        OpenProjectFile count ?dup
        if   (open-project)
        else drop
        then ;   IDM_OPEN SetCommand

: save-project  ( -- )
        SaveProject: TheProject
        SetProjectTitle ;   IDM_SAVE SetCommand

: save-as  ( -- )
        GetProjectFileName: TheProject   \ save filename on stack
        s" " SetProjectFileName: TheProject
        SaveProject: TheProject
        GetProjectFileName: TheProject nip
        IF  2drop SetProjectTitle   \ if not cancelled set new title
        ELSE  SetProjectFileName: TheProject   \ else restore filename
        THEN ;   IDM_SAVE_AS SetCommand

: rename-project ( -- )
        GetProjectName 0= ?exit
        true to Modified
        ProjectName: TheProject nip 0=
        if      s" Project" SetProjectName: TheProject
        then    Rename: TheProject ;   IDM_RENAME SetCommand

: OpenRecentFile ( File$ -- )
        SaveIfModified
        IF  count (open-project)
        ELSE  drop
        THEN ;   IDM_OPEN_FILE SetCommand

: DoExit ( -- )   0 0 WM_CLOSE GetHandle: TheProjectWindow send-window ;   IDM_EXIT SetCommand

\ View Menu Commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ToggleFlat ( -- )   FlatToolbar? 0= dup check: hFlat to FlatToolbar?
       FlatToolbar? IF TBSTYLE_FLAT +Style: pToolbar
       ELSE TBSTYLE_FLAT -Style: pToolbar THEN  paint: pToolbar ;   IDM_TOGGLE_FLAT SetCommand

: ToggleToolbar ( -- )
        ToolbarHeight IF  HideToolbar  ELSE  ShowToolbar  THEN
        On_Size: ProjectWindow ;   IDM_TOGGLE_TOOLBAR SetCommand

: ToggleStatusBar ( -- )
        StatusBarHeight IF  HideStatusBar  ELSE  ShowStatusBar  THEN
        On_Size: ProjectWindow ;   IDM_TOGGLE_STATUSBAR SetCommand

10 value n1
27 value n2

: SetSplitter   GetMaxWidth: TheProject  GetStyle: TheProject WS_VSCROLL and  IF  n2  ELSE  n1  THEN + SetLeft: TheProjectWindow ;
' SetSplitter   SetDblClickFunc: ProjectWindow

: Expand/Collapse ( a f -- )   swap to ThisList Handle: ThisList swap Expand: TheProject ;
: Expand ( a -- )   TVE_EXPAND Expand/Collapse ;
: Collapse ( a -- )   TVE_COLLAPSE Expand/Collapse ;

: ExpandAll ( -- )
\        MainList: TheProject to ThisList Handle: ThisList SelectItem: TheProject
        ModuleList: TheProject expand
        FormList: TheProject expand
        DLLList: TheProject expand
        AuxList: TheProject expand
        ResList: TheProject expand
        DocList: TheProject expand
        MainList: TheProject expand
        ModuleList: TheProject to ThisList Handle: ThisList SelectItem: TheProject
        SetSplitter ;   IDM_EXPAND_ALL SetCommand

: CollapseAll ( -- )
        ModuleList: TheProject collapse
        FormList: TheProject collapse
        DLLList: TheProject collapse
        AuxList: TheProject collapse
        ResList: TheProject collapse
        DocList: TheProject collapse
        MainList: TheProject collapse
        MainList: TheProject to ThisList Handle: ThisList SelectItem: TheProject
        ;   IDM_COLLAPSE_ALL SetCommand

\ Project Menu Commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: New-module    { \ tempfile -- }  \ create and edit a new .f file
                SaveModuleFile count dup 0=
                if      2drop exit
                then    clear-status-bar
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
                                IDM_EXECUTEFILE DoCommand   \ open default editor
                                true to Modified
                        then
                then    TempFile dispose ;   IDM_NEW_MODULE SetCommand


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
\ // --   -1   \S
\ (         1    )
\ ((        2   ))
\ /*        4   */
\ (*        8   *)
\ comment:  16  comment;
\ DOC  keep this for adding files like docs  ENDDOC

: +Comment ( n -- )   comment? IF  drop  ELSE  comment? or to comment?  THEN ;
: -Comment ( n -- )   invert comment? and to comment? ;
: \Comment ( -- )   comment? 0= IF  source nip >in !  THEN ;   \ ignore till end of line

Create squote ,$ 's"'
Create zquote ,$ 'z"'
Create fpathplus ,$ '"fpath+'

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
                squote count        "of  "fpath+? needed-file? true to skip-recurse? endof
                zquote count        "of  LoadLibrary?  true to skip-recurse?         endof
                s" needs"           "of                                        true  endof
                s" fload"           "of                                        true  endof
                s" include"         "of                                        true  endof
                s" sys-fload"       "of                                        true  endof
                s" winlibrary"      "of  true to skip-recurse?                 true  endof    \ don't search .dll file
                s" sys-winlibrary"  "of  true to skip-recurse?                 true  endof    \ don't search .dll file
                s" load-dialog"     "of  true to skip-recurse? true to dialog? true  endof    \ add .res and .h later
                s" thisfile"        "of  true to skip-recurse?                 true  endof    \ special word for PM   ???
                s" load-bitmap"     "of  bl word drop  true to skip-recurse?   true  endof    \ skip bitmap name
                s" toolbar"         "of  bl word drop  true to skip-recurse?   true  endof    \ skip bitmap name
                ( default ) false swap
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
: BuildNeededFiles  { fname fcnt \ tmp$ -- }      \ recursive routine
                false to comment?
                maxstring localalloc: tmp$
                                fname fcnt "open
                if          drop exit
                then        source-ID >r to source-ID
                source-ID file-size 2drop +to total-size
                >in @ >r
                source 2>r                     \ save current source
                tmp$ (source) cell+ !
                refill
                if      1 +to #linecount
                then
                begin   more? dup 0=
                        if      drop refill dup
                                if      1 +to #linecount    \ bump line count
                                then
                        then
                while   include-word?
                        if  is-file?
                            if
                                2dup addfile
                                2dup asciiz 0 SetText: ProjectStatusBar
                                dialog? IF
                                            2dup pad place -2 pad c+! s" .res" pad +place
                                            pad count addfile
                                            2dup asciiz 0 SetText: ProjectStatusBar
                                        THEN
                                skip-recurse?
                                if     2drop
                                else   comment? -rot  recurse   to comment?   \ save comment? on stack
                                then
                            then
                        then ( false to skip-recurse? )
                repeat  source-id close-file drop
                2r> (source) 2!
                r> >in !
                r> to source-id ;

: add-tree-file   { \ sitem -- }    \ add one or more files
                SelectedItem 0= ?exit
                SelectedItem dup itemid: [ ] 0=     \ if child selected
                if      parentitem: [ ]             \ use its parent
                then    to sitem SelectAFile c@
                if      #SelectedFiles: GetFilesDialog 0
                        do      i GetFile: GetFilesDialog sitem AddItem: TheProject
                        loop
                        Handle: ThisItem SelectItem: TheProject
                        true to Modified
                else    drop
                then
                ;   IDM_ADD SetCommand

create datfile ," projectpath.dat"

: save-path-to-file  ( -- )
                    prognam>pad datfile count pad +place
                    pad count w/o create-file
                    if      drop exit
                    then    >r search-path count r@ write-line drop
                    r> close-file drop ;

: set-build-path ( -- )
        search-path TheProjectWindow Start: GetPathDialog
        dup if  true to Modified  then
        2 = if  save-path-to-file  then
        ;   IDM_SET_BUILD_PATH SetCommand

: build-project { \ old-path$ -- }

                MAXSTRING CHARS 1+ LocalAlloc: old-path$
                search-path count old-path$ place \ save current search path

                search-path count nip 0=
                if   program-path-init \ set default project search path
                then

                reset-results
                GetBuildFile: TheProject nip 0=
                if      SelectAFile c@
                        if      0 GetFile: GetFilesDialog
                                SetBuildFile: TheProject
                        else    drop exit
                        then    GetBuildFile: TheProject ModuleList: TheProject
                                AddItem: TheProject
                                true to Modified
                then     \ Close: TheProject Leftpane Start: TheProject     \ uncomment to start fresh
                clear-status-bar
                GetBuildFile: TheProject BuildNeededFiles
                #addedfiles Modified or to Modified
                #addedfiles (.) pad place
                s"  files added " pad +place
                #linecount (.) pad +place
                s"  total lines search of " pad +place
                total-size (.) pad +place
                s"  bytes" pad +place
                pad +NULL
                pad 1+ 0 SetText: ProjectStatusBar

                old-path$ count search-path place \ restore current search path
                ;   IDM_BUILD SetCommand

: delete-item ( -- )   Delete: TheProject ;   IDM_DELETE SetCommand
((
: AddForms ( -- ) \ get open forms from ForthForm
                msg-buffer 0= ?exit     \ shared memory not initialized
                msg-buffer @ FFORMID <> ?exit       \ ForthForm not running
                0 WANT_FORMS win32forth-message ;   IDM_ADD_FORMS SetCommand
))
Create to$ max-path allot

: CopyThisFile  { from$ -- f } \ f = true if success
                ( filenamez -- f )
                ThisPath count to$ place
                from$ zcount "to-pathend" to$ +place to$ +null
                from$ 0 SetText: TheStatusBar
                0 ( overwrite flag ) to$ 1+ from$ Call CopyFile ;

\ changed to use BrowseForFolder from BROWSEFLD.F
\ Sonntag, Mai 30 2004 - 15:27 dbu
: copy-files    { \ folder$ -- }
                MAX_PATH 1+ LocalAlloc: folder$

                clear-status-bar
                TotalFiles: TheProject 0= ?exit
                z" Choose a folder" folder$ GetHandle: TheProjectWindow
                BrowseForFolder not
                if      exit
                then    folder$ count ThisPath place ThisPath ?+\
                GetList: TheProject lcount cells bounds
                do      i @ to ThisList
                        >FirstLink: ThisList
                        #items: ThisList 0
                        ?do     key?
                                if      key K_ESC = abort" File copy terminated!"
                                then    GetName: [ Data@: ThisList ]
                                dup zcount LibFile? NoLibfiles and
                                IF  drop
                                ELSE
                                    CopyThisFile 0=
                                    if      GetLastWinErr drop
                                        s" - " temp$ +place
                                        to$ count temp$ +place
                                        temp$ +null
                                        temp$ 1+ 1 SetText: TheStatusBar true to dirty?
                                    else    drop
                                    then
                                THEN     >NextLink: ThisList
                        loop
           cell +loop    z" done" 0 SetText: TheStatusBar ;

: CopyAll ( -- )   false to NoLibFiles  copy-files ;   IDM_COPY_ALL SetCommand

: CopyNonLib ( -- )   true to NoLibFiles  copy-files ;   IDM_COPY SetCommand


: cancel-zip?   ( addr cnt -- 0 )
                2drop key?
                if      key K_ESC =     \ cancel on ESC key pressed
                else    0
                then    ;

' cancel-zip? is doZip32Service

0 value zprintcnt
: .zipprint     ( addr cnt -- ) \ every second call is the file that was zipped
                asciiz zprintcnt 2 mod SetText: TheStatusBar 1 +to zprintcnt ;
' .zipprint is dozip32print

: zip-files     { \ tcnt -- }
                clear-status-bar
                TotalFiles: TheProject dup to tcnt 0= ?exit
                SaveZipFile dup c@ 0=
                if      drop exit
                then    WINPAUSE    \ return control for a moment
                count 2dup ThisPath place ".ext-only" nip 0=
                if      s" .zip" ThisPath +place
                then    tcnt Set#FilesToBeZipped

                1 zipoptions put> fJunkDir         \ don't store path info

                GetList: TheProject lcount cells bounds
                do      i @ to ThisList
                        >FirstLink: ThisList
                        #items: ThisList 0
                        ?do     GetName: [ Data@: ThisList ] zcount
2dup LibFile? NoLibfiles and  IF  2drop   [ also hidden ] -1 +to #FilesTobeZipped [ forth ]
                              ELSE  AddFileToBeZipped ( a.k.a +zfile )
                              THEN
                              >NextLink: ThisList
                        loop
          cell +loop    0 to zprintcnt true to dirty? ThisPath count goZip!
                zcode 0=
                if      z" Files successfully zipped!"
                else    z" "
                then    0 SetText: TheStatusBar ;

: ZipAll ( -- )   false to NoLibFiles  zip-files ;   IDM_ZIP_ALL SetCommand

: ZipNonLib ( -- )   true to NoLibFiles  zip-files ;   IDM_ZIP SetCommand

Create ForthName max-path allot

: SetForth ( -- )   ForthName ProjectWindow start: SetForthName drop ;   IDM_SET_FORTH SetCommand

: StartUpForth  { \ file$ -- }
        MAXSTRING LocalAlloc: file$
        ForthName count ?dup
        IF                                    file$ place
        ELSE  drop
            &prognam count "path-only"        file$ place
                                              file$ ?+\
\            &ForthDir count                   file$ place   \ CAPS
            s" Win32For.exe"                  file$ +place
            file$ count ForthName place
        THEN
\        s"  search-path off fpath+ "         file$ +place
\        search-path count                    file$ +place
        s"  chdir "                           file$ +place
        GetBuildFile: TheProject "path-only"  file$ +place
        s"  fload "                           file$ +place
        GetBuildFile: TheProject              file$ +place
                                              file$ +NULL
        file$ 1+ zEXEC-CMD drop ;   IDM_COMPILE SetCommand

\ Help Menu Commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ProjectHelp ( -- )
        s" doc\ProMgr\ProjectManager.htm" "path-file 0= \ Sonntag, Mai 30 2004 - 10:58 dbu
        if  Start: ProjectHelpWindow  asciiz SetURL: ProjectHelpWindow
        else  2drop true s" ProjectManager.htm not found in path!" ?MessageBox
        then ;   IDM_HELP SetCommand

: About ( -- ) Start: AboutForm ;   IDM_ABOUT SetCommand

: UninstallMessage ( -- n )   \ IDYES or IDNO
        s" Do you want to remove all Project Manager registry settings?" pad place
        s" \nYes will quit this application and all settings will be lost." pad +place
        pad +null
        pad 1+ z" Project Manager"  MB_ICONEXCLAMATION MB_YESNO or  NULL  MessageBox ;

: Uninstall ( -- )   UninstallMessage  IDYES = IF  RemoveRegKeys  bye  THEN ;   IDM_UNINSTALL SetCommand

: Restore ( -- )   Options RestoreSettings ;                 IDM_RESTORE_SETTINGS SetCommand

: SaveOps ( -- )   Options SaveSettings ;                       IDM_SAVE_SETTINGS SetCommand

: Default ( -- )   Options DefaultSettings ;                 IDM_DEFAULT_SETTINGS SetCommand

\ Misc Commands \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ShowFile ( -- )   Show-file: RightPane ;   IDM_SHOW_FILE SetCommand

: ExecFile ( -- )
        ItemId: SelectedItem  0=
        IF
            GetName: SelectedItem zcount
            GetHandle: TheProjectWindow
            "ShellExecute 32 <=          \ error?
            s" Failed to execute file!" ?MessageBox
        THEN ;   IDM_EXECUTEFILE SetCommand


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Registry settings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WindowSettings entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
ProjectWindow 12 + ( 4 )   614              REG_DWORD     RegEntry  "WindowWidth"
ProjectWindow 16 +         434              REG_DWORD     RegEntry  "WindowHeight"
ProjectWindow 20 +         135              REG_DWORD     RegEntry  "WindowLeft"
ProjectWindow 24 +         66               REG_DWORD     RegEntry  "WindowTop"
' LeftWidth 4 +            213              REG_DWORD     RegEntry  "SplitterPos"
EndEntries

Options entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
' FlatToolbar? 4 +         True             REG_DWORD     RegEntry  "Flat Toolbar"
' ToolbarHeight 4 +        True             REG_DWORD     RegEntry  "ToolbarHeight"
' StatusBarHeight 4 +      True             REG_DWORD     RegEntry  "StatusBarHeight"
' WindowState 4 +          SIZE_RESTORED    REG_DWORD     RegEntry  "Window State"
ProjectPath 256            0 0              REG_SZ        RegEntry  "ProjectDir"
((
' NumberRecentFiles 4 +    6                REG_DWORD     RegEntry  "Files"
))
EndEntries

ProjectManager entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
ProjectVersion   20        0 0              REG_SZ        RegEntry  "" ( default )
EndEntries


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Accelerator Table Entries \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

PMAccelerators table
\   Flags            Key Code      Command ID
\ File Menu
    FCONTROL         'N'           IDM_NEW                 AccelEntry
    FCONTROL         'O'           IDM_OPEN                AccelEntry
    FCONTROL         'S'           IDM_SAVE                AccelEntry
    FCONTROL         'R'           IDM_RENAME              AccelEntry
\ View Menu
    FCONTROL         VK_ADD        IDM_EXPAND_ALL          AccelEntry
    FCONTROL         VK_SUBTRACT   IDM_COLLAPSE_ALL        AccelEntry
\ Project Menu
    FCONTROL         'M'           IDM_NEW_MODULE          AccelEntry
    FCONTROL         'A'           IDM_ADD                 AccelEntry
    FCONTROL         'D'           IDM_DELETE              AccelEntry
    0                VK_DELETE     IDM_DELETE              AccelEntry
    0                VK_RETURN     IDM_EXECUTEFILE         AccelEntry
    FCONTROL         'F'           IDM_ADD_FORMS           AccelEntry
    FCONTROL         'C'           IDM_COPY                AccelEntry
    FCONTROL         'Z'           IDM_ZIP                 AccelEntry
    FCONTROL         'P'           IDM_SET_BUILD_PATH      AccelEntry
    FCONTROL         'B'           IDM_BUILD               AccelEntry
    0                VK_F12        IDM_COMPILE             AccelEntry
\ Help Menu
    0                VK_F1         IDM_HELP                AccelEntry

ProjectWindow HandlesThem


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The word to start the application \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ Sonntag, Mai 30 2004 - 11:58 - dbu
: HandleCmdLine ( -- )    \ open the Project given via command line
\                clear-status-bar
                CMDLINE ?DUP \ get command line address and length
                if   [CHAR] " skip [CHAR] ' skip BL skip
                     [CHAR] " -TRAILCHARS [CHAR] ' -TRAILCHARS BL -TRAILCHARS
                     \ and open the project
                     (open-project)
                else drop new-project
                then ;

: read-path-file    ( -- )
                    prognam>pad datfile count pad +place
                    pad count r/o open-file
                    if      drop exit
                    then    >r pad maxstring r@ read-line nip 0=
                    if      pad swap search-path place
                    else    drop
                    then    r> close-file drop ;

: PM                ( -- )
                    WindowSettings RestoreSettings
                    Options RestoreSettings
                    InitScintillaControl \ Dienstag, August 03 2004 dbu
\+ sysgen           read-path-file
                    Start: ProjectWindow
\ \+ sysgen           true promgr-started
                    RestoreRecentFiles
                    6 SetNumber: RecentFiles
\+ sysgen           HandleCmdLine
\+ sysgen           PMAccelerators EnableAccelerators
                    SetProjectTitle
                    ;

: run-PM        ( -- )
                PM
                Messageloop ;

[defined] sysgen [IF]

: InitDir       ( -- )
        current-dir$ count SetDir: OpenProjectDialog ;
Initialization-chain Chain-add InitDir

\ :noname ( -- )
\         init-console
\         if  initialization-chain do-chain  then
\         exception@ if bye then
\         default-application ;   is default-hello

        &forthdir count &appdir place
         ' run-PM turnkey Project.exe
        &appdir off

        \ add the Application Icon
        needs Resources
        s" src\res\Project.ico" s" Project.exe" Prepend<home>\ AddAppIcon

        1 pause-seconds bye

[ELSE]

        \ debug PM
        PM

[THEN]

DOC
s" doc\promgr\ProjectManager.htm" needed-file
s" doc\promgr\prjProjectWindow.gif" needed-file    ****  these are not found with spaces in filenames!
s" doc\promgr\prjFileMenu.gif" needed-file         ****  e.g. "prjFile Menu.gif"
s" doc\promgr\prjViewMenu.gif" needed-file
s" doc\promgr\prjProjectMenu.gif" needed-file
s" doc\promgr\prjHelpMenu.gif" needed-file
ENDDOC
