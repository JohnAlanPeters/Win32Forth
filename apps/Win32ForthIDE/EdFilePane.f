\ EdFilePane.f

needs filewindow.frm

NewEditDialog AddFilterDialog "Add/Edit Filter" "Enter filter e.g Forth Files (*.f;*.frm):" "&Ok" "Cancel" ""
NewEditDialog DupeFileDialog "Duplicate File" "Enter new file name:" "&Duplicate" "&Cancel" ""
NewEditDialog RenameFileDialog "Rename File" "Enter new name:" "&Rename"  "&Cancel" ""

ImageButton imgdrvbutton
ImageButton imgspecsbutton
ImageButton imgCopyButton
ImageButton imgDeleteButton
ImageButton imgDupeButton

defer UpdateAsTask

:Object TheFolderview        <Super Child-Window

load-bitmap drvbitmap "drive.bmp"
load-bitmap specsbmp "specs.bmp"
load-bitmap copybmp "copy.bmp"
load-bitmap deletebmp "delete.bmp"
load-bitmap dupebmp "dupe.bmp"

string: tmp-buf
: AdjustWindowSize      { width height winhndl -- }
                SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                winhndl Call SetWindowPos drop ;

\ Modify this object according to your needs

: parse-filters { str cnt \ tempaddr -- addr cnt }
\ example of filter specs - "Forth Files (*.f;*.frm)"
\ specs can be preceded by a description but actual specs must be enclosed by brackets
                str cnt '(' scan dup
                if      1 /string over to tempaddr
                        ')' scan dup
                        if      drop tempaddr - tempaddr swap
                        then
                then    ;

: update-dir   ( -- )
                GetSelectedString: cmblstFilters parse-filters SetSpecs: TheDirectory
                UpdateAsTask ;

: add-filter    { \ editing? -- }
                control-key? dup to editing?
                if      GetSelectedString: cmblstFilters tmp-buf place
                else    tmp-buf off
                then    tmp-buf frmfileWindow Start: AddFilterDialog
                if      tmp-buf count 2dup parse-filters nip 0= abort" Error in filter string!"
                        asciiz editing?
                        if      GetCurrent: cmblstFilters dup DeleteString: cmblstFilters       \ remove old
                                tuck InsertStringAt: cmblstFilters                              \ add new
                                SetSelection: cmblstFilters                                     \ and select it
                                update-dir                                                     \ refresh
                        else    AddStringto: cmblstFilters                                      \ just add new
                        then
                then    ;

: get-file      { \ selection -- addr cnt | 0 }
                SelectedItem: TheDirectory dup to selection
                if            IsFile?: selection
                              if      getname$: selection
                              else    0 0
                              then
                else          0 0
                then          ;

: duplicate-file    ( -- ) \ make a copy of selected file with a different name
                #Files: TheDirectory 0= ?exit
                get-file ?dup
                if      tmp-buf dup off frmfileWindow Start: DupefileDialog
                        if      2dup "to-pathend"
                                tmp-buf count istr= abort" Can't duplicate file to itself!"
                                2dup "path-only" pad place
                                pad ?+\
                                tmp-buf count pad +place
                                pad +NULL
                                drop 0 pad 1+ rot Call CopyFile
                                if      UpdateFiles: TheDirectory
                                else    true s" File duplication failed!" ?MessageBox
                                then
                        then
                else    drop
                then    ;

: RenameFile    ( -- )  \ rename highlighted file
                #Files: TheDirectory 0= ?exit
                get-file dup 0=
                if       2drop exit
                then     2dup new$ dup>r place
                "to-pathend" pad place
                pad frmfileWindow Start: RenameFileDialog
                if      pad c@ 0= abort" No name specified!"
                        r@ count "path-only" tmp-buf place
                        tmp-buf ?+\
                        pad count tmp-buf +place
                        r@ count tmp-buf count rename-file abort" File rename failed!"
                        Updatefiles: TheDirectory
                then    r>drop ;

0 value moving?

: copy-file        { \ cnt flag from$  -- }
                    #Files: TheDirectory 0= ?exit
                    get-file nip 0= ?exit
                    z" Select path to copy/move file to:"
                    pad dup off
                    GetHandle: frmFileWindow BrowseForFolder 0= ?exit
                    pad ?+\
                    new$ >r
                    pad count r@ place      \ lay in path
                    get-file 2dup asciiz to from$
                    "to-pathend" r@ +place
                    r> dup +NULL 1+         \ new filename
                    from$                   \ existing file name
                    moving?
                    if      0 -rot Call MoveFile
                    else    Call CopyFile
                    then    ( flag )
                    if      moving?
                            if      UpdateFiles: TheDirectory
                            then
                    else    true s" File copy/move failed!" ?MessageBox
                    then    ;

: delete_file       ( -- )
                    #Files: TheDirectory 0= ?exit
                    DeleteFile: TheDirectory ;

: command-func  { id obj -- } ( h m w l id obj -- ) \ OnCommand function for frmFileWindow
                id
                case
                        GetId: cmblstfilters    of      over HIWORD CBN_SELCHANGE =
                                                        if      update-dir
                                                        then
                                                endof
                        GetId: imgDrvButton     of      ChooseFolder: TheDirectory
                                                endof
                        GetId: imgSpecsButton   of      add-filter          endof
                        GetID: imgCopyButton    of      copy-file           endof
                        GetID: imgDeleteButton  of      delete_file         endof
                        GetID: imgDupeButton    of      duplicate-file      endof

                        GetId: cmblstPathPicker of      over HIWORD CBN_SELCHANGE  =
                                                        if      GetSelectedString: cmblstPathPicker
                                                                Update: TheDirectory
                                                        then
                                              endof

                endcase ;

: UpdatetxtFolder ( obj -- )
                  GetPath: [ ] InsertString: cmblstPathPicker ;

: openfile       { item -- }
		 getname$: item new$ dup>r place
		 control-key?	\ control and double click opens file for editing, it had better be text!
		 if   	NewEditWindow r@ count OpenNamedFile: ActiveChild drop
			UpdateFileTab
		 else r@ IDM_OPEN_RECENT_FILE DoCommand
		 then   r>drop ;

:M On_Init:     ( -- )
                self Start: frmFileWindow

                ['] command-func SetCommand: frmFileWindow
                ['] UpdatetxtFolder   IsOn_Update: TheDirectory
                ['] openfile IsOn_DblClick: TheDirectory

                \ the generic controls in the form can be configured for any function
                drvbitmap usebitmap map-3dcolors    \ adjust colors to system
                frmFileWindow Start: imgdrvbutton
                imgButton1X imgButton1Y imgButton1W imgButton1H move: imgDrvButton
                drvbitmap SetImage: imgDrvButton
                s" Change drive/folder" BInfo: imgDrvButton place   \ tooltip
                WS_CLIPSIBLINGS +Style: imgDrvButton

                \ allow user specified filespecs, N.B. changes lost when program exited
                specsbmp usebitmap map-3dcolors
                frmFileWindow Start: imgspecsbutton
                imgButton2X imgButton2Y imgButton2W imgButton2H move: imgSpecsButton
                specsbmp SetImage: imgSpecsButton
                s" Add (press ctrl key to edit) file specification string e.g (*.f;*.4th)" Binfo: imgSpecsButton place
                WS_CLIPSIBLINGS +Style: imgSpecsButton

                copybmp usebitmap map-3dcolors
                frmFileWindow Start: imgCopyButton
                imgButton3X imgButton3Y imgButton3W imgButton3H Move: imgCopyButton
                copybmp SetImage: imgCopyButton
                s" Copy selected file" Binfo: imgCopyButton place
                WS_CLIPSIBLINGS +Style: imgCopyButton

                deletebmp usebitmap map-3dcolors
                frmFileWindow Start: imgDeleteButton
                imgButton4X imgButton4Y imgButton4W imgButton4H Move: imgDeleteButton
                deletebmp SetImage: imgDeleteButton
                s" Delete selected file" Binfo: imgDeleteButton place
                WS_CLIPSIBLINGS +Style: imgDeleteButton

                dupebmp usebitmap map-3dcolors
                frmFileWindow Start: imgDupeButton
                imgButton5X imgButton5Y imgButton5W imgButton5H Move: imgDupeButton
                dupebmp SetImage: imgDupeButton
                s" Duplicate selected file" Binfo: imgDupeButton place
                WS_CLIPSIBLINGS +Style: imgDupeButton

\                true ReadOnly: cmblstPathPicker

                \ add default filters, see definition of parse-filters for note on format
                z" All Files (*.*)"                            AddstringTo: cmblstFilters
                z" Forth Files (*.f;*.frm;*.seq;*.4th;*.fs)"   Addstringto: cmblstfilters
                z" C Source (*.c;*.h;*.cpp)"                   AddStringto: cmblstFilters
                z" Basic Source (*.bas;*.inc)"                 Addstringto: cmblstfilters
                z" Html Files (*.html;*.htm)"		       Addstringto: cmblstfilters
                z" Text Files (*.txt;*.bat;*.ini;*.cfg)"       Addstringto: cmblstfilters
                z" ForthForm Files (*.ff)"                     AddStringto: cmblstfilters
                1 SetSelection: cmblstFilters             \ default to Forth files

                update-dir
                ;M

:M Close:       ( -- )
                Close: TheDirectory  \ close this!, bug took me days to find!!!
                Close: frmFileWindow
                Close: Super ;M

:M On_Size:         ( -- )
                \ we first get the height of this window
                winRect GetClientrect: self
                winRect.right to width
                winRect.bottom to height

                0 0 width height Move: frmFileWindow

                winRect GetClientRect: cmblstPathPicker       \ this width only we are changing
                width 2 - winRect.bottom GetHandle: cmblstPathPicker AdjustWindowSize

                1 imgbutton1y imgbutton1h + cell+ winRect.bottom + 2 +  \ x y of directory window

                winRect GetClientRect: cmblstFilters
                0 height winRect.bottom dup>r - width r> Move: cmblstFilters

                \ now we adjust the directory window
                width 2 - height 2 pick - winRect.bottom - 2 - Move: TheDirectory
                ;M

:M Display:     ( -- )
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )
                SW_HIDE Show: self ;M

:M WindowStyle:  ( -- style )
                WS_CHILD
                ;M

:M ExWindowStyle: ( -- )
        WS_EX_CLIENTEDGE ;M

:M WndClassStyle: ( -- style )
        \ CS_DBLCLKS only to prevent flicker in window on sizing.
        CS_DBLCLKS ;M

:m classinit:  classinit: super 1290 to id ;m

;Object
