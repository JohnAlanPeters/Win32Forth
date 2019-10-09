\ $Id: FolderView.f,v 1.7 2013/11/20 12:28:36 georgeahubert Exp $

\ FolderView.f
\ Adapted from FileLister.f Wednesday, July 04 2007 Ezra Boyce
anew -FolderView.f

\ needs linklist.f
needs listview.f
needs quiksort.f
needs statusbar.f

5 proc SHGetFileInfo As get-file-info

\- ?exitm macro ?exitm " if exitm then"
0 value ThisViewer

PopUpBar ViewPopupBar

PopUp ""
         MenuItem "Up one level"                Ascend: ThisViewer ;
         MenuItem "Change Folder or drive"	ChooseFolder: ThisViewer ;
         MenuItem "Refresh"             	UpdateFiles: ThisViewer ;
         MenuSeparator
   false MENUMESSAGE     "View Mode"
         MenuSeparator
         :MenuItem mnuli "Large Icons"         	LVS_ICON SetViewMode: ThisViewer ;
         :MenuItem mnusi "Small Icons"         	LVS_SMALLICON SetViewMode: ThisViewer ;
         :MenuItem mnulst "List"               	LVS_LIST SetViewMode: ThisViewer  ;
         :MenuItem mnurpt "Report"          	LVS_REPORT SetViewMode: ThisViewer ;
Endbar

also hidden
: BrowseFolder       ( lpszTitle pszFolder hwndOwner -- flag )

        hwndOwner !
        swap lpszTitle !

        \ if we have a valid Folder, than we need a callback for
        \ SHBrowseForFolder() to set the startup-folder in the dialog
        dup +null 1+ dup call PathIsDirectory
        if &BrowseCallbackProc else 0 then lpfn !

        dup dup pszDisplayName !

        [ BIF_RETURNONLYFSDIRS BIF_EDITBOX or BIF_VALIDATE or  BIF_NEWDIALOGSTYLE or  ] literal ulFlags !

        0 pidlRoot !
        0 lParam !

        \ OleInitialize() must be called if BIF_NEWDIALOGSTYLE flag is set
	0 call OleInitialize drop

        BROWSEINFO call SHBrowseForFolder dup>r
        call SHGetPathFromIDList
        if   zcount swap 1- c! true
        else drop false
        then r> Call CoTaskMemFree drop ; \ release memory

previous

CODE COMPAREI    ( adr1 len1 adr2 len2 -- n )
    mov     -4 [ebp], esi
    pop     edi                     \ edi = adr2
    pop     ecx                     \ ecx = len1
    pop     esi                     \ esi = adr1
    sub     eax, eax                \ default is 0 (strings match)
    cmp     ecx, ebx                \ compare lengths
    je      short @@2
    ja      short @@1
    dec     eax                     \ if len1 < len2, default is -1
    jmp     short @@2
@@1:
    inc     eax                     \ if len1 > len2, default is 1
    mov     ecx, ebx                \ and use shorter length
@@2:
    mov     bl, BYTE [esi]
    mov     bh, BYTE [edi]
    inc     esi
    inc     edi
    or      bx, # $2020
    cmp     bh, bl
    loopz   @@2

    je      short @@4               \ if equal, return default
    jnc     short @@3
    mov     eax, # 1               \ if str1 > str2, return 1
    jmp     short @@4
@@3:
    mov     eax, # -1                \ if str1 < str2, return -1
@@4:
    mov     ebx, eax
    mov     esi, -4 [ebp]
    xor     edi, edi
    next    c;

\ *************************************************************************
\ Simple no frills wildcard (* and ?) pattern matching of files, emulates API I think.
create filespec-name 40 allot filespec-name off
create filespec-ext 40 allot filespec-ext off
create filebuf max-path allot
create filebuf-ext 32 allot

:  *.*  ( -- addr cnt )
        s" *.*" ;

: ?*-in-name       { buf -- }  \ first cell of buffer stores flag for * check
                   buf cell+ count tuck '*' scan nip dup>r - buf cell+ c!
                   r> buf ! ;

: parse-filespecs  { addr cnt -- }
                   addr cnt "minus-ext" filespec-name cell+ place
                   addr cnt ".ext-only" 1 /string filespec-ext cell+ place
                   filespec-name ?*-in-name
                   filespec-ext ?*-in-name ;

: parse-filename   { addr cnt -- }
                   addr cnt "minus-ext" filebuf place
                   addr cnt ".ext-only" 1 /string filebuf-ext place ;

: compare-buf     { specname bufname \ speclen buflen specflag specaddr bufaddr -- f }
                  specname cell+ count to speclen to specaddr
                  specname @ to specflag
                  bufname count to buflen to bufaddr
                  speclen 0= specflag 0<> and ?dup ?exit   \ assume single * in spec
                  false                                    \ default result
                  speclen buflen > ?exit                   \ filespec greater so fail
                  speclen 0
                  ?do     specaddr i + c@ dup '?' <>
                          if     upc bufaddr i + c@ upc <>
                                 if  unloop exit        \ comparison failed
                                 then
                          else   drop
                          then
                  loop    speclen 0= buflen 0<> and ?exit    \ no specs so leave as false
                  \ comparison should be successful only if both buffers are = in length
                  \ OR if they are not equal but an * is specified in the specs
                  \ ( if they are not equal at this point specs is shorter of two )
                  speclen buflen =   ( -- res f )            \ two buffers are equal
                  dup not ( -- res f -f )                    \ they are not equal
                  specflag 0<> and                           \ but we have an *
                  or or ;                                    \ or to default flag

: match-specs?     { specname speccnt fname fcnt -- f }
                   specname speccnt *.* str= ?dup ?exit   \ special case
                   fname fcnt parse-filename
                   specname speccnt parse-filespecs
                   filespec-name filebuf compare-buf dup 0= ?exit
                   filespec-ext filebuf-ext compare-buf and ;

:Class FolderItem           <super Object

max-path cell+ bytes itemname
int iconhandle
int itemhandle	\ parent handle
\ save information for each individual file
Record: Win32_Find_Data
         int   FileAttributes
         int   FileCreationTimeLow
         int   FileCreationTimeHigh
         int   FileLastAccessTimeLow
         int   FileLastAccessTimeHigh
         int   FileLastWriteTimeLow
         int   FileLastWriteTimeHigh
         int   FileSizeHigh
         int   FileSizeLow
         int   Reserved0
         int   Reserved1
max-path bytes FileName
      14 bytes AlternateFileName
;RecordSize: sizeof(Win32_Find_Data)

Record: psfi            \ structure to be passed to SHGetFileInfo API call
        int    hIcon
        int    iIcon
        int    dwAttributes
        max-path bytes szDisplayName
        80 bytes szTypeName
;RecordSize: sizeof(psfi)

:M GetFileAttributes:  ( -- n )
                       FileAttributes ;M

:M GetFileName:        ( -- adr cnt )
                       FileName zcount ;M

:M GetModifiedTime:	( -- ) \ return info in file-time-buf
			FileLastWriteTimeLow file-time-buf !
			FileLastWriteTimeHigh file-time-buf cell+ !
			;M

:M GetFileSize:         ( -- d )
                        FileSizeLow FileSizeHigh
                        ;M

:M .or..?:            ( -- f ) \ is found file directories . or ..?
                      GetFileName: self drop c@ '.' = ;M

:M IsFile?:             ( -- f )
                        GetFileAttributes: self FILE_ATTRIBUTE_DIRECTORY and 0=
                        ;M

:M IsDirectory?:        ( -- f ) \ exclude . and ..
                        GetFileAttributes: self FILE_ATTRIBUTE_DIRECTORY and
                        ;M

:M Classinit:   ( -- )
            Classinit: super
            0 to iconhandle
            0 to itemhandle
            ;M

:M GetData: ( -- addr cnt ) \ access for any additional information needed
            Win32_Find_Data sizeof(Win32_Find_Data) ;M

: GetInfo       ( -- ) \ get icon info, using attribute _suppose_ to prevent accessing each file on disk
                [ SHGFI_ICON  SHGFI_USEFILEATTRIBUTES or ] LITERAL
                sizeof(psfi)
                psfi
                dir-attribute? if FILE_ATTRIBUTE_DIRECTORY else FILE_ATTRIBUTE_NORMAL then
                itemname 1+
                get-file-info drop
                hIcon to iconhandle ;

:M setup: ( addr cnt -- ) \ assumes name is set for FindFirstFile, FindNextFile etc.
            itemname place
            itemname +null
            \ transfer the info
            _Win32-Find-Data Win32_Find_Data sizeof(Win32_Find_Data) cmove
           GetInfo
            ;M

:M GetName: ( -- addrz )
	    itemname 1+ ;M

:M GetName$: ( -- addr cnt )
        itemname count ;M

:M iconhandle: ( -- n )
               iconhandle ;M

:M SetHandle:	( hwnd -- )
		to itemhandle ;M

\ Windows API say the following isn't necessary but it is
:M ~:           ( -- )
                iconhandle ?dup
                if         Call DestroyIcon drop
                           0 to iconhandle
                then       ;M

;Class

:Class FolderListView <super ListView

:M WindowStyle: ( -- style )
        WindowStyle: super
        [ LVS_REPORT LVS_SHOWSELALWAYS OR ] literal or
        ;M

;Class

:Class FolderViewer              <Super Child-Window

LV_COLUMN lvc
LV_ITEM LvItem
FolderListView TheView
int FolderList
int DirList
int itemindex
int ThisItem            \ temp pointer to new item
int sortorder
int OnSelect          \ called when an item is clicked
int On_Update           \ called when folder tree is refreshed
int On_DblClick
int SelectedItem        \ list item object
int show-files?         \ do we want to display files?
int show-dirs?		\ show directories?
int #dirs               \ number of directories found when updating
int #fls                \ ditto files
dint total-size		\ size of all files found
int hwndlabel           \ handle to window to display path
int popup?
int hwndSmallIcons           \ handle to imagelist for small icons
int hwndLargeIcons
StatusBar ViewStatusBar
32 bytes findspecs
max-path bytes fullpath$

32 1024 * constant max-files    \ 32k max files shown in a folder
max-files cell * constant buffersize

max-path 1+ bytes Treepath
max-path 2 cells + bytes specbuffer

: thespecs      ( -- addr  )
                specbuffer [ 2 cells ] literal + ;

: rootdir?  { pathstr cnt -- f } \ f = true if path is at root
            pathstr cnt + 2 - w@ s" :\" drop w@ = ?dup ?exit
            pathstr cnt + 1- c@ ':' = ;

: releasebuffers  ( -- )
                  FolderList ?dup
                  if    release 0 to FolderList
                  then  DirList ?dup
                  if    release 0 to DirList
                  then  ;

: list[]        ( list ndx -- addr )
                cell under+ cells+ ;

: InitTheViewColumns ( -- )
        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_LEFT                                            Setfmt: lvc
        180                                                     Setcx: lvc
        z" Name"              		SetpszText: lvc
        Addr: lvc 0               	InsertColumn: TheView

        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_RIGHT	                                       Setfmt: lvc
        120                                                     Setcx: lvc
        z" Size"               		SetpszText: lvc
        Addr: lvc swap 1+               InsertColumn: TheView


        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_RIGHT	                                       Setfmt: lvc
        120                                                     Setcx: lvc
        z" Date"                 	SetpszText: lvc
        Addr: lvc swap 1+         	InsertColumn: TheView

        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_RIGHT	                                       Setfmt: lvc
        80                                                      Setcx: lvc
        z" Time"                 	SetpszText: lvc
        Addr: lvc swap 1+         	InsertColumn: TheView drop  ;

: CreateSmallImageList ( -- )    \ create small image list for list control
            FolderList @ DirList @ +              \ maximum images
            dup                             \ number of images to use
            ILC_COLOR16                         \ color depth
	    SM_CYSMICON	Call GetSystemMetrics  \ height of small icon
	    SM_CXSMICON Call GetSystemMetrics  \ width of small icon
            Call ImageList_Create to hwndSmallIcons
            \ do the following BEFORE adding any icons
            Color: WHITE hwndSmallIcons Call ImageList_SetBkColor drop ;

: CreateLargeImageList ( -- )    \ create large image list for listview control
            FolderList @ DirList @ +              \ maximum images
            dup                             \ number of images to use
            ILC_COLOR16                         \ color depth
 	    SM_CYICON Call GetSystemMetrics  \ height of large icon
 	    SM_CXICON Call GetSystemMetrics  \ width of large icon
            Call ImageList_Create to hwndLargeIcons
            \ do the following BEFORE adding any icons
            Color: WHITE hwndLargeIcons Call ImageList_SetBkColor drop ;

: DestroyImageLists	 ( -- )
        hwndSmallIcons ?dup
        if      Call ImageList_Destroy drop
		0 to hwndSmallIcons
        then    hwndLargeIcons ?dup
        if      Call ImageList_Destroy drop
		0 to hwndLargeIcons
        then    ;

: add-icons	{ \ item -- }
	    CreateSmallImageList
	    CreateLargeImageList
            DirList @ 0
            ?do    DirList i list[] @ to item
                   IconHandle: item ?dup
                   if	dup hwndLargeIcons Call ImageList_AddIcon drop
			    hwndSmallIcons Call ImageList_AddIcon drop
		   then
            loop  FolderList @ 0
            ?do    FolderList i list[] @ to item
                   IconHandle: item ?dup
                   if	dup hwndLargeIcons Call ImageList_AddIcon drop
			    hwndSmallIcons Call ImageList_AddIcon drop
		   then
            loop   ;

: AddFile   { str cnt -- }
        FolderList @ max-files >= ?exit  \ don't abort, just don't add any more files
        New> FolderItem dup to ThisItem FolderList dup @ list[] !
        FolderList incr
        hwnd SetHandle: ThisItem
        str cnt SetUp: ThisItem
        ;

: AddDir   { str cnt -- }
        DirList @ max-files >= ?exit    \ don't abort, just don't add any more directories
        New> FolderItem dup to ThisItem DirList dup @ list[] !
        DirList incr
        hwnd SetHandle: ThisItem
        str cnt SetUp: ThisItem ;

: get-date-and-time	( obj -- timestr cnt datestr cnt )
		GetModifiedTime: [ ]
		pad file-time-buf Call FileTimeToLocalFileTime drop
		time-buf pad Call FileTimeToSystemTime drop
                31 time$ z" h':'mm':'tt"
                time-buf null LOCALE_USER_DEFAULT
                call GetTimeFormat time$ swap 1-	\ timestr cnt
                31 date$  z" MM'/'dd'/'yyyy"
                time-buf null LOCALE_USER_DEFAULT
                call GetDateFormat date$ swap 1- 	\ datestr cnt
                ;

: AddViewItem { list ndx \ obj -- }
	list ndx list[] @ to obj
	list FolderList = show-dirs? and \ #dirs 0<> and
	if	#dirs +to ndx		\ offset for files
	then
\ first add the name
        [ LVIF_TEXT LVIF_PARAM or LVIF_IMAGE or ] LITERAL SetMask: LvItem
        ndx                     SetiItem:   LvItem
        obj                     SetlParam:  LvItem
        ndx                     SetIImage: Lvitem
        GetFileName: obj drop   SetpszText:  LvItem
        LvItem InsertItem: TheView drop
\ now we add subitems.
\ size
        LVIF_TEXT               SetMask: LvItem
        ndx                     SetiItem:   LvItem
        1			SetiSubItem: LVItem
        IsFile?: obj
        if	GetFileSize: obj (ud,.) asciiz
        else	z" "	\ show no size for directories
        then	SetpszText: LvItem
        LvItem ndx SetItemText: TheView drop

        obj get-date-and-time
\ date
        LVIF_TEXT SetMask: LvItem
        ndx                     SetiItem:   LvItem
        2			SetiSubItem: LVItem
        ( date )  asciiz  SetpszText: LvItem
        LvItem ndx SetItemText: TheView drop
\ time
        LVIF_TEXT SetMask: LvItem
        ndx                     SetiItem:   LvItem
        3			SetiSubItem: LVItem
        ( time ) asciiz  SetpszText: LvItem
        LvItem ndx SetItemText: TheView drop	;

: show-files     ( -- )  \ add file and stats to the listviewbox
		DeleteAllItems: TheView drop
		DestroyImageLists
		add-icons
                hwndSmallIcons LVSIL_SMALL SetImageList: TheView drop
                hwndLargeIcons LVSIL_NORMAL SetImageList: TheView drop
                0 show-dirs?
                if	#dirs +
                then	show-files?
                if	#fls +
                then	SetItemCount: TheView drop
                show-dirs?
                if	DirList @ 0
			?do	DirList i AddViewItem
			loop
		then	show-files?
		if	FolderList @ 0
			?do	FolderList i AddViewItem
			loop
		then	;

:M Start:   ( parent -- )
            Start: super
            buffersize malloc to FolderList
            buffersize malloc to DirList
            FolderList off
            DirList off ;M

:M On_Init: ( -- )
            self Start: TheView
            InitTheViewColumns
            ViewPopupBar SetPopupBar: self
            self Start: ViewStatusBar
            ;M

:M On_Size:     ( -- )
		Redraw: ViewStatusBar
                0 0 GetSize: self Height: ViewStatusBar - Move: TheView ;M

:M Classinit:   ( -- )
                Classinit: super
                treepath off
                *.* thespecs place
                ['] drop to OnSelect
                ['] drop to On_Update
                ['] drop to On_DblClick
                0 to SelectedItem
                0 to hwndSmallIcons
                0 to hwndLargeIcons
                true to show-files?
                true to show-dirs?
                true to popup?
                -1 to itemindex
                0 to #dirs
                0 to #fls
                0 to FolderList
                0 to DirList
                0.0 2to total-size
                0 to hwndlabel
                NextID to id
                SortAscending: [ self ] ;M

: DisposeTheList ( -- )
            FolderList 0= ?exit
            FolderList lcount cells bounds
            ?do  i @ dispose
       cell +loop FolderList off
            DirList lcount cells bounds
            ?do  i @ dispose
       cell +loop DirList off ;

:M ~:   ( -- )
        DisposeTheList
        releasebuffers ;M

:M Close: ( -- )
        DisposeTheList
        releasebuffers
        DestroyImageLists
        ;M

: FindFirstFile ( -- f )
                TreePath count fullpath$ dup>r place
                r@ ?+\
                *.* r@ +place
                r> count find-first-file nip ;

: get-path-file           ( -- addr cnt ) \ return full path of directory found
                        TreePath count fullpath$ dup>r place
                        r@ ?+\
                        get-file-name zcount r@ +place
                        r> count ;

: GetFileSize         ( -- d )
                      _win32-find-data 7 cells+ 2@ ;

\ scan a directory once for all files, compare each file found to file specs and add
\ if match is found
: FindAllFiles	( -- )
		0 to #dirs
		0 to #fls
                0.0 2to total-size
                FindFirstFile
                begin   0=
                while   dir-attribute?
                        if      get-file-name c@ '.' <>         \ exclude . or ..
				if	  get-path-file AddDir
					 1 +to #dirs
				then
                        else	thespecs first-path"
				begin   dup 0>
				while   get-file-name zcount match-specs?
					if	 get-path-file AddFile
						 GetFileSize 2+to total-size
						1 +to #fls
						0 0		\ set to leave
					else	thespecs next-path"
					then
				repeat  2drop
			then	find-next-file nip
		repeat	find-close drop ;

: dosortorder   ( n -- f )
                sortorder null-check execute ;

: compare-recs  ( n1 n2 -- f )
                >r GetFileName: [ ] r> GetFileName: [ ]
                comparei ( caps-compare ) dosortorder ;

: sortfolders	( -- )
                [']  compare-recs is precedes            \ set sort comparator
		DirList @ 2 >
		if      Dirlist lcount sort
		then    FolderList @ 2 >
		if      FolderList lcount sort
		then    ;

:M Setpath: { addr cnt -- }  \ check for valid path
            addr cnt + 2 - w@ 0x5C3A =         \ are the last chars ':\' i.e root dir?
            if   addr cnt treepath place
                 treepath +null
                 exitm
            then addr cnt lastchar '\' =
            if	1-
            then find-first-file nip ?exitm
            dir-attribute?
            if     addr cnt treepath place     \ it is a directory
                   treepath +null
            then   find-close drop ;M

:M Getpath: ( -- addr cnt )
            treepath count ;M

:M SetSpecs:    ( addr cnt -- ) \ can be multiple e.g "*.f;*.htm;*.txt"
                thespecs place ;M

:M GetSpecs:    ( -- addr cnt )
                thespecs count ;M

: show-path     ( -- )
                hwndlabel 0= ?exit
                hwndlabel Call IsWindow 0= ?exit
                treepath 1+ 0 WM_SETTEXT hwndlabel Call SendMessage drop ;

: show-stats	( -- )
		new$ >r
		#dirs (.) r@ place
		s"  Directories, " r@ +place
		#fls (.) r@ +place
		s"  files totalling " r@ +place
		total-size (ud,.) r@ +place
		s"  bytes" r@ +place
		r@ +null
		r> 1+ SetText: ViewStatusBar ;

:M UpdateFiles:   ( -- ) \ primary word, rebuild files list in view
                treepath c@ 0=
                if      current-dir$ count SetPath: self
                then    _Win32-Find-Data [ 11 cells max-path + 14 + ] LITERAL erase
                s" Building list..." "message
                DisposeTheList
                0 to SelectedItem
                FindAllFiles
                SortFolders
                show-files
                show-path
                show-stats
                message-off
                self On_Update null-check execute           \ user function
                ;M

:M Update:	( addr cnt -- )	\ combination
		SetPath: self
		UpdateFiles: self ;M

:M IsLabelHandle: ( hwnd -- ) \ a window that will display the current path after update
                  to hwndlabel ;M

:M SetViewMode:	( mode -- ) \ view mode ( LVS_ICON, LVS_SMALLICON, LVS_LIST, LVS_REPORT )
		GetStyle: TheView LVS_TYPEMASK invert and 	\ reset style
		or GWL_STYLE SetWindowLong: TheView drop ;M

:M SortAscending:   ( -- )
                ['] 0< to sortorder ;M

:M SortDescending:  ( -- )
                ['] 0> to sortorder ;M

:M DeleteFile:  ( -- ) \ delete selected file I think
                Selecteditem 0= ?exitm
                IsDirectory?: SelectedItem  ?exitm \ can't delete folder or root
                s" Delete " new$ dup>r place
                GetName$: SelectedItem r@ +place
                s" ?" r@ +place
                r@ +NULL
                r> 1+               ( sztext )
                z" Are you sure?"   ( ztitle )
                MB_YESNO            ( style  )
                MessageBox: parent IDNO = ?exitm
                GetName$: SelectedItem delete-file dup
                s" Delete file failed" ?MessageBox
                ?exitm
                0 to SelectedItem
                UpdateFiles: self ;M

:M SelectedItem:    ( -- n )
                    SelectedItem ;M

:M #Dirs:       ( -- n ) \ number of directories found during update
                #dirs ;M

:M #Files:      ( -- n ) \ number of files found during update
                #fls ;M

:M TotalFileSize:	( -- d )
			total-size ;M

:M Showfiles:   ( f -- ) \ flag=true if showing files
                to show-files? ;M

:M ShowDirs:   ( f -- ) \ flag=true if showing directories in tree
                to show-dirs? ;M

:M IsOn_Update: ( cfa -- ) \ user function to execute after update of files
                to On_Update ;M

:M IsOnSelect: ( cfa -- ) \ user function to execute when a file or folder selected
                to OnSelect ;M

:M IsOn_DblClick: ( cfa -- ) \ user function to execute when file is double clicked
                to On_DblClick ;M

:M ShowPopup:	( f -- )	\ do we want popup window on right click?
		to popup? ;M

:M ChooseFolder: ( -- )   \ change folder programatically, also available by right clicking
                 hwnd 0= ?exitm
                 z" Select a drive or folder"
                 \ use a copy of path because if cancelled path info is changed to null
                 GetPath: self pad place
                 pad hwnd BrowseFolder
                 if       pad count Update: Self
                 then     ;M

: ?descend       ( --)
                SelectedItem 0= ?exitm
                IsDirectory?: SelectedItem
                if	GetName$: SelectedItem Update: self
		else	SelectedItem On_DblClick null-check execute
		then	;

:M ascend:      ( -- ) \ move up one level in the directory tree
                GetPath: self 2dup rootdir?
                if      2drop exitm
                then    2dup + swap '\' -scan drop over - Update: Self
                ;M

: check-view	( -- )
		GetStyle: TheView LVS_TYPEMASK  and
		dup LVS_ICON = Check: mnuli
		dup LVS_REPORT = Check: mnurpt
		dup LVS_LIST = Check: mnulst
		    LVS_SMALLICON = Check: mnusi  ;

: show-popup	( -- )
                CurrentPopup
                if	self to ThisViewer
			check-view
                        hwnd get-mouse-xy hwnd Track: CurrentPopup
                then	;

:M WM_NOTIFY    { h m w l \ ncode -- f }
                l @  GetHandle: TheView <> if false exitm then
                l 2 cells+ @ to ncode
		ncode
		case
			LVN_ITEMCHANGED  of	l LVN_GetNotifyParam to SelectedItem
						l LVN_GetNotifyItem dup itemindex <>
						if	to itemindex
							SelectedItem OnSelect null-check execute \ call only once
						else	drop
						then
					endof
			NM_RCLICK 	of	popup? if show-popup then
					endof
			NM_DBLCLK	of	?descend
					endof
		endcase
		false
                ;M

:M GetListView:	( -- obj )
		TheView ;M

;Class

\s
