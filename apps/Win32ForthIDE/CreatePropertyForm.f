\ CreatePropertyForm.f

FileSaveDialog SavePropertyDlg "Save Property File" "Property Files|*.pform|"
FileOpenDialog OpenPropertyDlg "Open Property File" "Property Files|*.pform|"
FileSaveDialog CompileSheetDlg "Compile Property Form" s" Forms|*.frm|All Files|*.*|"


create sheetname 40 allot sheetname off
create sheetcaption 40 allot sheetcaption off
\ create formpath max-path allot formpath off
false value defaultbuttons?
false value multi-line-tabs?
false value compile-to-disk?
false value button-tabs?

\ : ChooseFolder ( -- )   \ select folder for form files
\                  z" Select where to save forms"
\                  \ use a copy of path because if cancelled path info is changed to null
\                  formpath count pad place
\                  pad GetHandle: MainWindow BrowseForFolder
\                  if       pad count formpath place
\                  then     ;

: SheetName=    ( -- )
                bl word count sheetname place ;

: SheetCaption= ( -- )
                0 word count sheetcaption place ;

: PropertyFlags=        ( -- )
                bl word count number?
		if	drop to defaultbuttons?
		else	2drop
		then    bl word count number?
		if	drop to multi-line-tabs?
		else	2drop
		then    bl word count number?
		if	drop to button-tabs?
		else	2drop
		then    bl word count number?
		if	drop to compile-to-disk?
		else	2drop
		then    ;

:Object frmCreatePropertyForm              <Super frmPropertyForm

create listbuffer 84 allot      \ temp buffer for forms
false value modalsheet?    \ sheet will be modal if any of its forms is modal
false value savescreen?    \ ditto

: ?selections ( -- )
                IsButtonChecked?: chkDefault    to defaultbuttons?
                IsButtonChecked?: chkMultiLine  to multi-line-tabs?
                IsButtonChecked?: chkCompile    to compile-to-disk?
                IsButtonChecked?: chkButtonTabs to button-tabs?
                GetText: txtName dup 0=      \ if no name supplied
                if      2drop s" frmSheet" 2dup SetText: txtName     \ provide one by default
                then     sheetname place
                GetText: txtCaption sheetcaption place  ;

: listbuffer[]  ( n -- form )
                listbuffer +cells @ ;

: listparams    ( -- n1 n2 )
                listbuffer @ 1+ 1 ;

: memswap       ( n1 n2 -- ) \ swap contents of listbuffer pointed to by indices n1, n2
                listbuffer cell+ +cells >r
                listbuffer cell+ +cells dup @    ( -- addr*n1 [addr*n1] )
                r@ @ -rot r> ! ! ;

: InitOrderList ( -- ) \ load forms into listbuffer
                Clear: lstOrder    \ rese
                #forms dup listbuffer !
                1+ 1          \ not zero based
                ?do     i GetForm dup
                        FormName: [ ] count asciiz AddString: lstOrder
                        listbuffer i cells+ !        \ init buffer
                loop    0 SetSelection: lstOrder ;

: init-options  ( -- )
                defaultbuttons?           Check: chkDefault
                multi-line-tabs?          Check: chkMultiLine
                compile-to-disk?          Check: chkCompile
                button-tabs?              Check: chkButtonTabs
                sheetname count         SetText: txtName
                sheetcaption count      SetText: txtCaption
                InitOrderList ;

: ?EnableButtons ( -- )
                #Forms 2 >
                dup     Enable: chkDefault
                dup     Enable: chkMultiLine
                dup     Enable: chkCompile
                dup     Enable: chkButtonTabs
                dup     Enable: txtName
                dup     Enable: txtCaption
                dup     Enable: btnTest
                dup     Enable: btnCompile
                dup     Enable: btnClipBoard
                dup     Enable: btnSave
                dup     Enable: btnRefresh
                dup     Enable: btnMoveUp
                dup     Enable: btnMoveDown
                dup     Enable: lstOrder
                if      init-options
                then    ;

: UpOrderList   ( -- )  \ shift one up in list
                GetCurrent: lstOrder ?dup      \ if not the first selection
                if      dup>r GetString: lstOrder
                        r@    DeleteString: lstOrder
                        r@ dup 1- memswap       \ order listbuffer
                        asciiz r> 1- 0max dup>r
                              InsertString: lstOrder
                        r>    SetSelection: lstOrder
                then    ;

: DownOrderList     { \ cursel cnt -- }   \ shift one down in list
                GetCurrent: lstOrder to cursel GetCount: lstOrder to cnt
                cursel cnt 1- 0max <>   \ if not at end of list
                if      cursel GetString: lstOrder
                        cursel DeleteString: lstOrder
                        cursel dup 1+ memswap           \ order listbuffer
                        asciiz cursel 1+ cnt 1- min dup>r
                               InsertString: lstOrder
                        r>     SetSelection: lstOrder
                then    ;

: OpenPropertyFile 	( -- )
                GetHandle: MainWindow Start: OpenPropertyDlg dup c@
                if      nostack1 ['] $fload catch 0=
                        if     ?EnableButtons
                        else   s" Error loading property file!" ?MessageBox
                        then
                else    drop
                then    ;

: write-propformfiles ( -- ) \ write any forms opened,
                      listparams
                      ?do       s" Form= " append
                                i listbuffer[] GetFileName: [ ] append&crlf
                      loop      ;

: write-name&caption  ( -- )
                      s" SheetName= " append sheetname count append&crlf
                      s" SheetCaption= " append sheetcaption count append&crlf ;

: write-propflags     ( -- )
                      s" PropertyFlags= " append
                      defaultbuttons? (.) append bl cappend
                      multi-line-tabs? (.) append bl cappend
                      button-tabs? (.) append bl cappend
                      compile-to-disk? (.) append&crlf ;

: SavePropertyFile  ( -- )  \ save property form definition file
                GetHandle: MainWindow Start: SavePropertyDlg
                s" .pform" rot ?addext count tuck
		SetName: TheFile
		0= ?exit        \ saving was cancelled
		Create: TheFile ?exit
		initbuffer
		?selections
		write-name&caption
		write-propformfiles
		write-propflags
		TheBuffer Write: TheFile drop
		Close: TheFile ;

: append&crlf&tabs     ( -- )
                       append&crlf 2tabs ;

: getFormName          { n -- addr cnt }
                       n listbuffer[] FormName: [ ] count ;

: maxtabsize            { \ w h -- w h }
                       0 to w 0 to h
                       listparams
                       ?do    i listbuffer[] Dimensions: [ ]
                              h max to h
                              w max to w
                       loop   w 10 + h 30 + ;

: sheetsize            ( -- w h )
                       maxtabsize
                       defaultbuttons?  \ each default button 80 * 25
                       if     swap 260 max swap 35 +
                       then   ;

: (write-show/hide)    { curform \ this -- }
                       listparams
                       ?do     i listbuffer[] to this
                               +crlf 2tabs
                               this curform <>
                               if     s" Hide: " append
                               else   s" Display: " append
                               then   FormName: this count append
                       loop    ;

: write-show/hide      ( -- )
                       listparams
                       ?do     i listbuffer[] >r
                               +crlf
                               s" : show-" append FormName: [ r@ ] count append
                               1 +tabs s" ( -- )" append
                               r> (write-show/hide)
                               s"  ;" append&crlf
                               +crlf
                       loop    ;

: write-ontab          ( -- )
                       +crlf
                       s" : ontab         { l obj -- }" append&crlf&tabs
                       s" GetSelectedTab: obj" append&crlf&tabs
                       s" case" append&crlf
                       listbuffer @ 0
                       do     3 +tabs
                              i (.) append 1 +tabs
                              s" of" append 1 +tabs
                              s" show-" append
                              i 1+ GetFormName append
                              1 +tabs
                              s" endof" append&crlf
                       loop   2tabs s" endcase  ;" append&crlf ;

: write-showtab        ( -- )
                       +crlf
                       s" :M ShowTab:    ( n -- )" append&crlf&tabs
                       s" dup SetSelectedTab: SheetTab" append&crlf&tabs
                       s" Addr: SheetTab ontab" append&crlf&tabs
                       s" ;M"  append&crlf ;

: write-on_init        ( -- )
                       +crlf
                       s" :M on_init:     ( -- )" append&crlf&tabs

                       s" COLOR_BTNFACE Call GetSysColor NewColor: FrmColor" append&crlf&tabs
                       +crlf 2tabs

                       s"append s" MS Sans Serif" append "append
                       s"  SetFaceName: WinFont"  append&crlf&tabs
                       s" 8 Width: WinFont" append&crlf&tabs
                       s" Create: WinFont" append&crlf +crlf 2tabs

                       s" ['] ontab IsChangeFunc: SheetTab" append&crlf +crlf 2tabs

                       multi-line-tabs? dup>r
                       if     s" TCS_MULTILINE " append
                       then   button-tabs? dup>r
                       if     s" TCS_BUTTONS " append
                       then   r> r> 2dup and
                       if     s" or " append
                       then   or
                       if     s" Addstyle: SheetTab" append&crlf +crlf 2tabs
                       then

                       s" \ start the individual forms of the property sheet" append&crlf&tabs
                       s" self Start: SheetTab" append&crlf&tabs
                       s" 0 0 1 1 Move: SheetTab" append&crlf&tabs
                       s" Handle: WinFont SetFont: SheetTab" append&crlf&tabs

                       listparams   \ add each tab and it's title
                       ?do    +crlf 2tabs
                              z"append
                              i listbuffer[] FormTitle: [ ] count append
                              "append s"  IsPsztext: SheetTab" append&crlf&tabs
                              s" TCIF_TEXT IsMask: SheetTab" append&crlf&tabs
                              i #append s" InsertTab: SheetTab" append&crlf
                       loop

                       listparams \ start each form
                       ?do    +crlf 2tabs
                              s" Addr: SheetTab Start: " append
                              i GetFormName append&crlf&tabs
                       loop

                       +crlf 2tabs
                       s" 0 ShowTab: self" append&crlf         \ default to show first form
                       \ if wanted generate the three default buttons
                       defaultbuttons?
                       if      +crlf 2tabs
                               s" IDOK SetID: btnOk" append&crlf&tabs
                               s" self Start: btnOk" append&crlf&tabs
                               sheetsize  >r 246 - r> 30 -   \ -- x y, starting pos
                               2dup swap #append #append
                               80 #append 25 #append s" Move: btnOk" append&crlf&tabs
                               s" Handle: WinFont SetFont: btnOk" append&crlf&tabs
                               s"append s" &Ok" append "append s"  SetText: btnOk" append&crlf

                               +crlf 2tabs
                               s" IDCANCEL SetID: btnCancel" append&crlf&tabs
                               s" self Start: btnCancel" append&crlf&tabs
                               ( x y -- ) 82 under+ 2dup swap #append #append
                               80 #append 25 #append s" Move: btnCancel" append&crlf&tabs
                               s" Handle: WinFont SetFont: btnCancel" append&crlf&tabs
                               s"append s" &Cancel" append "append s"  SetText: btnCancel" append&crlf

                               +crlf 2tabs
                               s" self Start: btnApply" append&crlf&tabs
                               ( x y -- ) swap 82 + #append #append
                               80 #append 25 #append s" Move: btnApply" append&crlf&tabs
                               s" Handle: WinFont SetFont: btnApply" append&crlf&tabs
                               s"append s" &Apply" append "append s"  SetText: btnApply" append&crlf

                        then   modalsheet?
                        if      +crlf 2tabs s" GetParentWindow: self ?dup \ if this is a modal form disable parent" append&crlf
                                2tabs s" if   0 swap Call EnableWindow drop then" append&crlf
                        then
                        +crlf 2tabs s" ;M" append&crlf ;


: write-opening  ( -- )
                 s" \- textbox needs excontrols.f" append&crlf
                +crlf
                s" :Object " append sheetName count append
                2tabs s" <Super DialogWindow" append&crlf
                +crlf s" Font WinFont" append&crlf
                s" ColorObject FrmColor" append&crlf
                s" TabControl SheetTab" append&crlf
                savescreen?
                if      1 listbuffer[] Origin: [ ]    \ first form's position
                        swap #append #append s" 2value XYPos" append&crlf
                then    defaultbuttons?
                if     s" PushButton btnOk" append&crlf
                       s" PushButton btnCancel" append&crlf
                       s" PushButton btnApply" append&crlf
                then   ;

: write-on_done ( -- )
                +crlf
                s" :M On_Done:    ( -- )" append&crlf&tabs
                s" Delete: WinFont" append&crlf&tabs
                savescreen?
                if  s" originx originy 2to XYPos" append&crlf&tabs
                then
                s" \ Insert your code here" append&crlf&tabs
                modalsheet?
                if      s" GetParentWindow: self ?dup  \ if modal form re-enable parent" append&crlf&tabs
                        s" if   1 swap Call EnableWindow drop" append&crlf&tabs
                        s"      \ reset focus to parent if we have one"
                        append&crlf&tabs
                        s"      GetParentWindow: self Call SetFocus drop"
                        append&crlf&tabs
                        s" then" append&crlf&tabs
                then    s" On_Done: super  ;M" append&crlf ;

: write-startsize ( -- )
                +crlf
                s" :M StartSize:    ( -- w h )" append&crlf&tabs
                sheetsize swap #append #append s" ;M" append&crlf ;

: write-startpos ( -- )
                +crlf
                s" :M StartPos:    ( -- x y )" append&crlf&tabs
                savescreen?
                if      s" XYPos" append&crlf&tabs
                else    \ use the position of the first form for the start position
                        1 listbuffer[] Origin: [ ]
                        swap #append #append +crlf 2tabs
                then    s" ;M" append&crlf ;

: write-close   ( -- )
                +crlf
                s" :M Close:  ( -- )" append&crlf&tabs
                #forms 1+ 1
                ?do    s" Close: " append
                       i GetFormName append&crlf&tabs
                loop   s" Close: super ;M" append&crlf ;

: write-title   ( -- )
                +crlf
                s" :M WindowTitle: ( -- ztitle )" append&crlf&tabs
                z"append sheetcaption count append "append +crlf
                2tabs s" ;M" append&crlf ;

: write-on_paint ( -- )
                 +crlf
                 s" :M On_Paint:    ( -- )" append&crlf&tabs
                 s" 0 0 GetSize: self Addr: FrmColor FillArea: dc ;M" append&crlf ;

: write-on_size  ( -- )
                 +crlf
                 s" :M On_Size:     ( -- )" append&crlf&tabs
                 s" 0 0 Width Height " append
                 defaultbuttons?
                 if     s" 35 - " append
                 then   s" Move: SheetTab" append&crlf&tabs
                 #forms 1+ 1
                 ?do     s" ClientSize: SheetTab 2over d- Move: " append
                         i GetFormName append&crlf&tabs
                 loop   s" ;M" append&crlf ;

: write-notify  ( -- )
                +crlf
                s" :M WM_NOTIFY  ( h m w l -- f )" append&crlf&tabs
                s" Handle_Notify: SheetTab ;M" append&crlf ;

: write-style   ( -- )
                +crlf
                s" :M WindowStyle:  ( -- style )" append&crlf&tabs
                s" WS_POPUPWINDOW WS_DLGFRAME or ;M" append&crlf ;

: write-end     ( -- )
                +crlf
                s" ;Object" append&crlf ;

: getmergename  ( -- )
                GetName: MergeFile c@ ?exit
                GetFilter: SaveFormDlg new$ dup>r place
                s" Forms|*.frm|All Files|*.*|" SetFilter: SaveFormDlg
                GetHandle: MainWindow Start: SaveFormDlg
                r> count SetFilter: SaveFormDlg
                dup c@ 0= ?abort
                s" .frm" rot ?addext count SetName: MergeFile ;

: write-forms   { \ this -- }
                false to modalsheet?
                false to savescreen?
                listparams
                ?do     i listbuffer[] to this
                        GetModal: this modalsheet? or to modalsheet?
                        SaveScreen?: this savescreen? or to savescreen?
                        GetSuperClass: this >r           \ save these
                        ChildState: this >r              \ states
                        true IsChildState: this          \ and set them
                        CHILD-CLASS IsSuperClass: this   \ temporarily
                        compile-to-disk?                 \ merging forms to a single disk file?
                        if      UnInitedBuffer: this 2drop       \ compile without initializing
                                +crlf +crlf
                        else    UnSaved?: this          \ compiling to individual forms
                                abort" Please save all forms first!"
                                Compile: this
                        then
                        r> IsChildstate: this            \ restore all
                        r> IsSuperClass: this
                loop    compile-to-disk?
                if      getmergename
                        Create: MergeFile ?abort
                        TheBuffer Write: MergeFile
                        Close: MergeFile ?abort
                        initbuffer       \ restart
                        s" needs " append GetName: MergeFile count "to-pathend" append
                        s"  \ ensure path to file is set in search path" append&crlf +crlf
                else    ClearName: MergeFile       \ acts as a flag
                        initbuffer
                        s"  \ ensure path to files is set in search path" append&crlf
                        listparams
                        ?do     i listbuffer[] to this
                                s" needs " append TextFile: this "to-pathend"  append&crlf
                        loop    +crlf
                then    ;

: compile-sheet ( -- )
                initbuffer
                write-forms
                write-opening
                write-show/hide
                write-ontab
                write-showtab
                write-startsize
                write-startpos
                write-on_size
                write-title
                write-style
                write-on_init
                write-on_paint
                write-close
                write-on_done
                write-notify
                write-end ;

: getselections ( -- )
                ?selections
                compile-sheet ;

: load-sheet    ( -- )
                getselections
                s" anew -psheet" evaluate
                fload-buffer
                s" Start: " pad place
                sheetname count pad +place
                pad count evaluate ;

: compile-to-form  ( -- )
                getselections
                GetHandle: MainWindow Start: CompileSheetDlg
                dup c@ 0= ?abort
                s" .frm" rot ?addext count SetName: TheFile
                Create: TheFile ?exit
                TheBuffer Write: TheFile
                Close: TheFile
                0= s" Done!" ?MessageBox ;

: command-func  { id obj -- }
                id
                  case
                         GetId: btnClipBoard     of    getselections
                                                       TheBuffer copy-clipboard   endof
                         GetId: btnCompile       of    compile-to-form            endof
                         GetID: btnTest          of    load-sheet                 endof
                         GetId: btnMoveUp        of    UpOrderList                endof
                         GetId: btnMoveDown      of    DownOrderList              endof
                         GetId: btnLoad          of    OpenPropertyFile           endof
                         GetId: btnSave          of    SavePropertyfile           endof
                         GetId: btnRefresh       of    InitOrderList              endof
                         GetId: btnClose         of    Close: self                endof
                  endcase ;

:m on_init:     ( -- )
                WS_BORDER AddStyle: lstOrder
                on_init: super

                ?EnableButtons

                ['] command-func SetCommand: self

                ;M

:M ParentWindow:  ( -- hwnd )
                  GetHandle: MainWindow ;M

:M Refresh:     ( -- )
                hwnd
                if      InitOrderList
                then    ;M

;Object

: PropertyForm  ( -- )
\ MergeFile object acts as a flag, if the name is not set a file can be selected
\ otherwise use whatever name is there. To choose file of different name disselect
\ option and test, compile or clipboard
                ClearName: MergeFile
                Start: frmCreatePropertyForm ; IDM_FORM_PROPERTYFORM SetCommand

\s
