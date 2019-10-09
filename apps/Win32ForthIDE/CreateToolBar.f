\ CreateToolbar.f       \ Create a Win32 API Toolbar

0 value ThisTBButton
0 value TBList
BitmapObject ButtonBitmap
ReadFile BitmapFile
0 value DesignToolBar
0 value automode
1 value nextbuttonid

FileOpenDialog OpenToolBarDlg "Open ToolBar Definition File" "TDF Files|*.tdf|All Files|*.*|"
FileSaveDialog SaveToolBarDlg "Save Toolbar Definition File" "TDF Files|*.tdf|All Files|*.*|"


: get-id	( -- n )
		nextbuttonid 1 +to nextbuttonid ;

:Class TBButton                <Super Object

Record: ButtonInfo
        int id
        int bitmapindex
        33  bytes tooltip
        33  bytes buttontext
	33  bytes description
	int flags
	1 bits extrabutton
	1 bits styleseparator
	1 bits stylebutton
	1 bits stylecheck
	1 bits stylecheckgroup
	1 bits stylegroup
	1 bits statechecked
	1 bits stateenabled
	1 bits statehidden
	1 bits stategrayed
	1 bits statepressed
	1 bits statewrap
	20 bits reservedflags
        16 cells bytes Reserved
;RecordSize: sizeof(ButtonInfo)


:m info:     ( -- addr cnt )
             buttoninfo sizeof(buttoninfo) ;m

:m isinfo:   ( addr cnt -- )
             buttoninfo swap sizeof(buttoninfo) min 0max move ;m

:m classinit:	( -- )
		classinit: super
		buttoninfo sizeof(buttoninfo) erase
		-1 to bitmapindex
		get-ID to id
		true to stylebutton
		true to stateenabled ;m

:m id: ( -- n )
             id ;m

:m isid: ( n -- )
               to id ;m

:m bitmapindex: ( -- n )
                bitmapindex ;m

:m isbitmapindex: ( n -- )
                  to bitmapindex ;m

:m tooltip:       ( -- addr cnt )
                  tooltip count ;m

:m istooltip:     ( addr cnt -- )
                  32 min 0max tooltip place ;m

:m buttontext:    ( -- addr cnt )
                  buttontext count ;m

:m isbuttontext: ( addr cnt -- )
                 32 min 0max buttontext place ;m

:m description:  (  -- addr cnt )
		description count ;m

:m isdescription: ( addr cnt -- )
		32 min 0max description place ;m

:m extrabutton:  ( -- f )
		extrabutton ;m

:m isextrabutton: ( f -- )
		to extrabutton ;m

:m styleseparator:	( -- f )
		styleseparator ;m

:m isstyleseparator:	( f -- )
		to styleseparator ;m

:m stylebutton:	( -- f )
		stylebutton ;m

:m isstylebutton:	( f -- )
		to stylebutton ;m

:m stylecheck:	( -- f )
		stylecheck ;m

:m isstylecheck: ( f -- )
		 to stylecheck ;m

:m stylecheckgroup:  ( -- f )
		stylecheckgroup ;m

:m isstylecheckgroup: ( f -- )
			to stylecheckgroup ;m

:m stylegroup:	( -- f )
		stylegroup ;m

:m isstylegroup:	( f -- )
		to stylegroup ;m

:m statechecked: ( -- f )
		statechecked ;m

:m isstatechecked: ( f -- )
		to statechecked ;m

:m stateenabled:	( -- f )
		stateenabled ;m

:m isstateenabled: ( f -- )
		to stateenabled ;m

:m statehidden:  ( -- f )
		statehidden ;m

:m isstatehidden:  ( f -- )
		to statehidden ;m

:m stategrayed:	 ( -- f )
		stategrayed ;m

:m isstategrayed:  ( f -- )
		to stategrayed ;m

:m statepressed:  ( -- f )
		statepressed ;m

:m isstatepressed:   ( f -- )
		to statepressed ;m

:m statewrap:	( -- f )
		statewrap ;m

:m isstatewrap:	( f -- )
		to statewrap ;m

;Class

TBButton TBBtn	\ dummy

: NoList?	( -- f )
		TBList 0= ?dup ?exit
		Data@: TBList 0= ;

:object imgWindow		<Super Child-Window

:m on_paint:	( -- )
		0 0 width height white fillarea: dc
		nolist? not
		if	GetHandle: dc SetParentDC: ButtonBitmap
			bitmapindex: [ Data@: TBLIST ] dup -1 <>
			if	0 0 PutImage: ButtonBitmap
			else	drop
			then
		then	;m

:m windowstyle:	( -- style )
		windowstyle: super ws_border or ;m

;object

:Object ToolBarPreviewWindow	<Super Window

16 value sprite-width
dint xypos
dint dimensions

:M StartPos:    ( -- x y )
                xypos ;M

:M StartSize:   ( -- w h )
                dimensions ;M

:M SetPos:      ( x y -- )
                2to xypos ;M

:M SetDim:      ( w h -- )
                2to dimensions ;M

:M ClassInit:   ( -- )
                ClassInit: super
                100 200 2to xypos
                300 28 2to dimensions ;M

:m On_Paint:	( -- )
		0 0 width height white fillarea: dc
		nolist? not
		if	GetHandle: dc SetParentDC: ButtonBitmap
			GetSpriteSize: ButtonBitmap drop to sprite-width
			Link#: TBList >r
			#Links: TBList 1+ 1
			do	i >Link#: TBList
				Data@: TBList to ThisTBButton
				bitmapindex: ThisTBButton dup -1 <>
				if	i 1- sprite-width * 0 PutImage: ButtonBitmap
				else	drop
				then
			loop	r> >Link#: TBList
		then	;m

:M WindowTitle:	( -- zcount$ )
		z" Toolbar Bitmap Preview Window" ;M

;object

:Object BitmapPreviewWindow           <Super Window

BitmapObject TheBitmap
dint xypos
dint dimensions
create title$ ," Bitmap Preview Window" 0 ,
Rect bitmapbox

: NoBitmap      ( -- )
                Title$ count SetText: self
		ClearName: BitmapFile
                Paint: self ;

:M ClassInit:   ( -- )
                ClassInit: super
                100 200 2to xypos
                300 28 2to dimensions ;M

:M SetFile:     { addr cnt \ hndl -- }
                cnt 0= ?exitm
		hwnd 0=
                if      Start: self
                then    Getname: BitmapFile count addr cnt istr= ?exitm
                Close: ButtonBitmap
		addr cnt LoadFile: BitmapFile 0=
                if      NoBitmap  exitm
                then   GetBuffer: BitmapFile drop SetBitmap: ButtonBitmap Start: ButtonBitmap
		Paint: self ;M

:M StartPos:    ( -- x y )
                xypos ;M

:M StartSize:   ( -- w h )
                dimensions ;M

:M On_Paint:    ( -- )
                GetBuffer: BitmapFile 0<>
                if       SetBitmap: TheBitmap
                        \ width height dc.hdc ShowFittedBitmap: TheBitmap
			 0 0  GetHandle: dc ShowBitmap: TheBitmap
                else    drop 0 0 width height WHITE FillArea: dc
                then    ;M

:M On_Size:     ( -- )
                Paint: self ;M

:M On_Done:     ( -- )
                ReleaseBuffer: BitmapFile
		originx originy 2to xypos
                width height 2to dimensions
                On_Done: super ;M

:M ParentWindow: ( -- hwnd )
                hwndparent ;M

:M SetParentWindow:    ( hwnd -- )
                to hwndparent ;M

:M WindowTitle: ( -- stringz )
                Title$ 1+ ;M

: getbitmapindex  ( -- )
		GetName: BitmapFile c@ 0= ?exit
		mousex BitmapDimensions: DesignToolbar drop / setindex: DesignToolbar ;

:M On_Init:     ( -- )
                On_Init: super
                ['] getbitmapindex setclickfunc: self
                ;M

:M SetPos:      ( x y -- )
                2to xypos ;M

:M SetDim:      ( w h -- )
                2to dimensions ;M

:M Close:       ( -- )
		Close: ButtonBitmap
                Close: super ;M

;Object
File TDFFile

:Object frmCreateToolBar		<Super frmDefineToolBar

Record: ToolBarInfo
    33 bytes  Name
    max-path bytes  ToolBarBitmap
    int BitmapWidth
    int BitmapHeight
    int ButtonWidth
    int ButtonHeight
    int ToolBarFlags
    1 bits  Flat
    1 bits ShowText
    1 bits  Customizable
    1 bits Tooltips
    1 bits Wrap
    1 bits List
    1 bits Bottom
    1 bits  NoDivider
    1 bits NoMoveY
    1 bits  AltDrag
    1 bits ExcludePath
    21 bits Reserved
    int buttoncount
   62 cells bytes Reserved2
;RecordSize: sizeOf(ToolBarInfo)


: GetBitmap     ( -- )
                hwnd Start:  GetBitmapDlg  dup c@
                if      count 2dup SetText: txtBitmapFile
                        SetFile: BitmapPreviewWindow
                else    drop
                then    ;

: clear-info    ( -- )
                ToolBarInfo sizeof(ToolBarInfo) erase ;

: DefaultToolBar ( -- )
                clear-info
                16 to BitmapWidth 15 to BitmapHeight
                24 to ButtonWidth 22 to ButtonHeight
                true to Flat
                true to Tooltips ;

: LoadProperties        ( -- )
                Name count SetText: txtName
                ToolBarBitmap count SetText: txtBitmapFile
                BitmapWidth  SetValue: spnbmpWidth
                BitmapHeight SetValue: spnbmpHeight
                ButtonWidth  SetValue: spnBtnWidth
                ButtonHeight SetValue: spnBtnHeight
                Flat Check: chkFlat
                ShowText Check: chkText
                Customizable Check: chkCustomizable
                ToolTips Check: chkToolTips
                Wrap Check: chkWrap
                List Check: chkList
                Bottom Check: chkBottom
                NoDivider Check: chkNoDivider
                NoMoveY Check: chkNoMoveY
                AltDrag Check: chkAltDrag
                ExcludePath Check: chkExcludePath
                ToolBarBitmap count SetFile: BitmapPreviewWindow ;

: SaveProperties ( -- )
                GetText: txtName 32 min 0max Name place
                GetText: txtBitmapFile ToolbarBitmap place
                GetValue: spnbmpWidth to BitmapWidth
                GetValue: spnbmpHeight to BitmapHeight
                GetValue: spnBtnWidth to ButtonWidth
                GetValue: spnBtnHeight to ButtonHeight
                IsButtonChecked?: chkFlat to Flat
                IsButtonChecked?: chkText to ShowText
                IsButtonChecked?: chkCustomizable to Customizable
                IsButtonChecked?: chkToolTips to ToolTips
                IsButtonChecked?: chkWrap to Wrap
                IsButtonChecked?: chkList to List
                IsButtonChecked?: chkBottom to Bottom
                IsButtonChecked?: chkNoDivider to NoDivider
                IsButtonChecked?: chkNoMoveY to NoMoveY
                IsButtonChecked?: chkAltDrag to AltDrag
                IsButtonChecked?: chkExcludePath to ExcludePath
                ;

:M BitmapDimensions:	( -- w h )
                GetValue: spnbmpWidth
                GetValue: spnbmpHeight 2dup or 0=	\ if zero set default
		if	2drop 16 15
		then	;M

: NewTBButton (  -- addr )
   New> TBButton dup to ThisTBButton ;

: AddNewButton  (  --  )
                TBList 0=             \ if we don't have one
                if      New> Linked-List to TBList    \ create it
                then    Data@: TBList         \ an entry of zero means it's empty
                if      AddLink: TBList
                then    NewTBButton Data!: TBList ;


: saveinfo	( -- )
		nolist? ?exit
		Data@: TBList to ThisTBButton
		GetText: txtToolTip                         isToolTip: ThisTBButton
		GetText: txtButtonText                   isButtonText: ThisTBButton
		GetText: txtDescription                 isDescription: ThisTBButton
		IsButtonChecked?: chkExtra 		isExtraButton: ThisTBButton
		IsButtonChecked?: chkSeparator 	     isStyleSeparator: ThisTBButton
		IsButtonChecked?: chkButton             isStyleButton: ThisTBButton
		IsButtonChecked?: chkCheck               isStyleCheck: ThisTBButton
		IsButtonChecked?: chkCheckGroup     isStyleCheckGroup: ThisTBButton
		IsButtonChecked?: chkGroup               isStyleGroup: ThisTBButton
		IsButtonChecked?: chkPressed           isStatePressed: ThisTBButton
		IsButtonChecked?: chkGrayed             isStateGrayed: ThisTBButton
		IsButtonChecked?: chkEnabled           isStateEnabled: ThisTBButton
		IsButtonChecked?: chkChecked           isStateChecked: ThisTBButton
		IsButtonChecked?: chkHidden             isStateHidden: ThisTBButton
		IsButtonChecked?: chkWrapped              isStateWrap: ThisTBButton ;

: UnCheckButtons (  -- )
		 false  Check: chkExtra
		 false  Check: chkSeparator
		 false  Check: chkButton
		 false  Check: chkCheck
		 false  Check: chkCheckGroup
		 false  Check: chkGroup
		 false  Check: chkChecked
		 false  Check: chkEnabled
		 false  Check: chkHidden
		 false  Check: chkGrayed
		 false  Check: chkPressed
		 false  Check: chkWrapped ;

: ?EnableButtons	( f -- )
		dup 0= if UnCheckButtons then
		dup	Enable: txtTooltip
		dup	Enable: txtButtonText
		dup	Enable: txtDescription
		dup	Enable: chkExtra
		dup	Enable: chkSeparator
		dup	Enable: chkButton
		dup	Enable: chkcheck
		dup	Enable: chkCheckGroup
		dup	Enable: chkGroup
		dup	Enable: chkPressed
		dup	Enable: chkGrayed
		dup	Enable: chkEnabled
		dup	Enable: chkChecked
		dup	Enable: chkHidden
		dup	Enable: chkWrapped
		dup	Enable: btnDelete
		dup	Enable: btnPrevious
		dup	Enable: btnNext
		dup	Enable: btnFirst
		dup	Enable: btnLast
		dup	Enable: btnMoveUp
			Enable: btnMoveDown ;

: refresh	( -- )
		nolist? dup 0= ?EnableButtons
		if	Paint: imgWindow
			Paint: ToolBarPreviewWindow
			Paint: BitmapPreviewWindow
			s" ToolBar Button" SetText: grpTBButton
			s" " 2dup SetText: txtDescription
			     2dup SetText: txtButtonText
				  SetText: txtTooltip
			exit
		then	Data@: TBList to ThisTBButton
		ToolTip: 	 ThisTBButton SetText: txtToolTip
		ButtonText: 	 ThisTBButton SetText: txtButtonText
		Description: 	 ThisTBButton SetText: txtDescription
		ExtraButton: 	 ThisTBButton   Check: chkExtra
		StyleSeparator:  ThisTBButton   Check: chkSeparator
		StyleButton: 	 ThisTBButton   Check: chkButton
		StyleCheck: 	 ThisTBButton   Check: chkCheck
		StyleCheckGroup: ThisTBButton   Check: chkCheckGroup
		StyleGroup: 	 ThisTBButton   Check: chkGroup
		StateChecked: 	 ThisTBButton   Check: chkChecked
		StateEnabled: 	 ThisTBButton   Check: chkEnabled
		StateHidden: 	 ThisTBButton   Check: chkHidden
		StateGrayed: 	 ThisTBButton   Check: chkGrayed
		StatePressed: 	 ThisTBButton   Check: chkPressed
		StateWrap: 	 ThisTBButton   Check: chkWrapped
		StyleSeparator:  ThisTBButton
		if	-1 IsBitmapIndex: ThisTBButton	\ clear any bitmap
		then	join$(   s" ToolBar Button "
				 Link#: TBList >str
				 s" /"
				 #Links: TBList (.)
			)join$ count SetText: grpTBButton
                GetValue: spnbmpWidth GetValue: spnbmpHeight SetSpriteSize: ButtonBitmap
		Paint: imgWindow
		Paint: ToolBarPreviewWindow ;

: DeleteButton	( -- )
		NoList? ?exit
		Data@: TBList Dispose
		0 Data!: TBList
		DeleteLink: TBList
		refresh ;

: MoveButtonUp	( -- )
		NoList? ?exit
		FirstLink?: TBList ?exit
		saveinfo
		Data@: TBList >PrevLink: TBList Data@: TBList
		swap Data!: TBList >NextLink: TBList Data!: TBList
		>PrevLink: TBList
		refresh ;

: MoveButtonDown ( -- )
		NoList? ?exit
		LastLink?: TBList ?exit
		saveinfo
		Data@: TBList >NextLink: TBList Data@: TBList
		swap Data!: TBList >PrevLink: TBList Data!: TBList
		>NextLink: TBList
		refresh ;

: PreviousButton	( -- )
		NoList? ?exit
		saveinfo
		>PrevLink: TBList
		refresh ;

: NextButton	( -- )
		NoList? ?exit
		saveinfo
		>NextLink: TBList
		refresh ;

: FirstButton	( -- )
		nolist? ?exit
		saveinfo
		>FirstLink: TBList
		refresh ;

: LastButton	( -- )
		nolist? ?exit
		saveinfo
		>LastLink: TBList
		refresh ;

: #Buttons	( -- n )
		nolist?
		if	0
		else	#Links: TBList
		then	;

: DisposeTBList   ( -- )
                TBList 0= ?exit
                TBList DisposeList
                0 to TBList ;

: AddButton	( -- )
		saveinfo
		AddNewButton
		refresh ;

:M ResetButtons:	( -- )
		DisposeTBList
		refresh ;M

:M Close:        ( -- )
		hwnd
		if	IsButtonChecked?: chkAuto to automode
		then	Close: BitmapPreviewWindow
		Close: ToolBarPreviewWindow
                Close: super
                ;M

:M On_Init:	( -- )
		On_Init: Super

		self Start: imgWindow
		imgButtonX imgButtonY imgButtonW imgButtonH Move: ImgWindow

		self to DesignToolBar

		1 96 SetRange: spnbmpWidth

		1 64 SetRange: spnbmpHeight

		1 96 SetRange: spnBtnWidth

		1 96 SetRange: spnBtnHeight

		hwnd SetParentWindow: BitmapPreviewWindow
		StartPos: Self StartSize: BitmapPreviewWindow nip - 27 - SetPos: BitmapPreviewWindow
		StartSize: self drop StartSize: BitmapPreviewWindow nip SetDim: BitmapPreviewWindow
		start: BitmapPreviewWindow

		hwnd SetParentWindow: ToolBarPreviewWindow
		StartPos: self StartSize: self nip + 32 + SetPos: ToolBarPreviewWindow
		StartSize: self drop StartSize: ToolBarPreviewWindow nip SetDim: ToolBarPreviewWindow
		start: toolbarpreviewwindow

		DefaultToolBar

		LoadProperties

		WM_USER Random to NextButtonID

		false ?EnableButtons

\           current-dir$ count 2dup SetDir: OpenToolBarDlg
\                                   SetDir: SaveToolBarDlg

		;M

: NewToolBar    ( -- )
		ResetButtons: self
		ReleaseBuffer: BitmapFile
		ClearName: BitmapFile
                DefaultToolBar
                LoadProperties
		;

: SaveToolBarFile   ( -- )
                    hwnd Start: SaveToolBarDlg count ?dup
                    if  pad place
                        pad count ".ext-only" nip 0=
                        if  s" .tdf" pad +place
                        then    pad count SetName: TDFFile
                        SaveProperties saveinfo
			#Buttons to ButtonCount
                        Create: TDFFile ?exit
                        ToolBarInfo sizeof(ToolBarInfo) Write: TDFFile
			if	Close: TDFFile exit
			then	Link#: TBList >r >FirstLink: TBList
			#Buttons 0
			do	info: [ Data@: TBList ] Write: TDFFile ?leave
				>NextLink: TBList
			loop	Close: TDFFile r> >Link#: TBList
                    else    drop
                    then    ;

: check-file      { \ fsize -- f }      \ check integrity of file before opening
                  Open: TDFFile ?dup ?exit
                  FileSize: TDFFile drop to fsize
                  Close: TDFFile
                  fsize sizeof(ToolBarInfo) < ?dup ?exit   \ must have at least a header
                  fsize sizeof(ToolBarInfo) - info: TBBtn nip mod 0<>  \ must be evenly divisible
                  ;


: (OpenToolBarFile)  ( addr cnt -- )
                SetName: TDFFile
		check-file abort" Invalid toolbar definition file!"
                Open: TDFFile 0=
                if  	NewToolBar
			ToolBarInfo sizeof(ToolbarInfo) Read: TDFFile
			if	Close: TDFFile exit
			then	ButtonCount 0
			?do	AddNewButton
				info: ThisTBButton Read: TDFFile ?leave
			loop	Close: TDFFile >FirstLink: TBList
		then    LoadProperties refresh ;

: OpenToolBarFile	( -- )
                hwnd Start: OpenToolbarDlg count ?dup
		if	(OpenToolBarFile)
		else	drop
		then	;

:M LoadToolBarFile:	( addr cnt -- )
			Start: self	\ set focus to self
			(OpenToolBarfile) ;M

:m setindex:   { n -- }
		saveinfo
		IsButtonChecked?: chkAuto dup to automode
		if	AddNewButton
		then	nolist? ?exitm
		n isbitmapindex: [ Data@: TBList ] refresh
		;m

:M ClassInit:       ( -- )
                    ClassInit: super
                    clear-info
                    self link-formwindow
                    ;M

: tooltipname   ( -- pad count )
        join$(   Name count
		 s" Tooltips"
	)join$ count ;

: buttontextname ( -- pad count )
        join$(   Name count
		 s" ButtonText"
	)join$ count ;

: WriteToolTips ( -- )
        ToolTips not ?exit
	#Buttons 0= ?exit
        +crlf s" :ToolStrings " append tooltipname append&crlf
	Link#: TBList >r
	>FirstLink: TBList
	#Buttons 0
	do	1 +tabs s" ts," append "append bl cappend
		ToolTip: [ Data@: TBList ] ?dup
		if	append
		else	bl cappend
		then	"append +crlf
		>NextLink: TBList
	loop	s" ;ToolStrings" append&crlf +crlf
	r> >Link#: TBList ;

: WriteButtonText   ( -- )
        ShowText not ?exit
	#Buttons 0= ?exit
        +crlf s" :ToolStrings " append buttontextname append&crlf
	Link#: TBList >r
	>FirstLink: TBList
	#Buttons 0
	do	1 +tabs s" ts," append "append bl cappend
		ButtonText: [ Data@: TBList ] ?dup
		if	append
		else	drop bl cappend
		then	"append +crlf
		>NextLink: TBList
	loop	s" ;ToolStrings" append&crlf +crlf
	r> >Link#: TBList ;


\ : WriteDefaultButtonText ( -- )
\                 +crlf s" :ToolStrings ButtonText" append&crlf
\                 1 +tabs s" ts," append "append s"  Cut" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Copy" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Paste" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Properties" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Print" append "append +crlf
\                 1 +tabs s" ts," append "append s"  New" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Open" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Save" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Undo" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Redo" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Delete" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Print Preview" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Find" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Replace" append "append +crlf
\                 1 +tabs s" ts," append "append s"  Help" append "append +crlf
\                 s" ;ToolStrings" append&crlf +crlf ;


: WriteDefaultTooltips ( -- )
                +crlf s" :ToolStrings ButtonToolTips" append&crlf
                1 +tabs s" ts," append "append s"  Cut Text" append "append +crlf
                1 +tabs s" ts," append "append s"  Copy Text" append "append +crlf
                1 +tabs s" ts," append "append s"  Paste Text" append "append +crlf
                1 +tabs s" ts," append "append s"  Properties" append "append +crlf
                1 +tabs s" ts," append "append s"  Print File" append "append +crlf
                1 +tabs s" ts," append "append s"  New File" append "append +crlf
                1 +tabs s" ts," append "append s"  Open File" append "append +crlf
                1 +tabs s" ts," append "append s"  Save File" append "append +crlf
                1 +tabs s" ts," append "append s"  Undo" append "append +crlf
                1 +tabs s" ts," append "append s"  Redo" append "append +crlf
                1 +tabs s" ts," append "append s"  Delete" append "append +crlf
                1 +tabs s" ts," append "append s"  Print preview" append "append +crlf
                1 +tabs s" ts," append "append s"  Find" append "append +crlf
                1 +tabs s" ts," append "append s"  Replace" append "append +crlf
                1 +tabs s" ts," append "append s"  Help" append "append +crlf
                s" ;ToolStrings" append&crlf +crlf ;

: WriteIDConstants	( -- )
		nolist? ?exit
		Link#: TBList >r >FirstLink: TBList +crlf
		#Buttons 1+ 1
		do	Data@: TBList to ThisTBButton
			StyleSeparator: ThisTBButton not
			if	Description: ThisTBButton dup 0=
				if	2drop
					join$( 	s" IDD_BUTTON"
						i (.)
					)join$ count 2dup IsDescription: ThisTBButton
				else	2dup bl scan nip
					if	join$(   s" No spaces allowed in button"
							i (.)
							s"  description!"
						)join$  true swap count ?MessageBox abort
					then
				then	ID: ThisTBButton (.) append s"  Constant " append append&crlf
			then	>NextLink: TBList
		loop	r> >Link#: TBList refresh ;

: bitmapname    ( -- addr count )
        join$(   Name count
		 s" Bitmap "
	)join$ count ;

: WriteLoadBitmap   ( -- )
        ToolBarBitmap count ?dup
        if  ExcludePath
            if      "to-pathend"
            then    +crlf s" load-bitmap " append
            bitmapname append "append
            append "append +crlf
        else    2drop
        then    ;

: tablename ( -- pad count )
        join$(   Name count
		 s" Table "
	)join$ count ;

: write-state	{ \ flag -- }
	0 to flag
	StateEnabled: ThisTBButton
	if	s" TBSTATE_ENABLED " 		append 1 +to flag then
	StateHidden: ThisTBButton
	if	s" TBSTATE_HIDDEN "  		append 1 +to flag then
	StateChecked: ThisTBButton
	if	s" TBSTATE_CHECKED " 		append 1 +to flag then
	StateGrayed: ThisTBButton
	if	s" TBSTATE_INDETERMINATE " 	append 1 +to flag then
	StatePressed: ThisTBButton
	if	s" TBSTATE_PRESSED " 		append 1 +to flag then
	StateWrap: ThisTBButton
	if	s" TBSTATE_WRAP "          	append 1 +to flag then
	flag 1- 0max 0 ?do  s" or " append loop
	flag 1 > if  +crlf 35 +spaces then
	flag 0= if s" 0                " append  then ;

: write-style	{ \ flag -- }
	0 to flag
	StyleButton: ThisTBButton
	if	s" TBSTYLE_BUTTON " 		append 1 +to flag then
	StyleCheck: ThisTBButton
	if	s" TBSTYLE_CHECK "  		append 1 +to flag then
	StyleCheckGroup: ThisTBButton
	if	s" TBSTYLE_CHECKGROUP " 	append 1 +to flag then
	StyleGroup: ThisTBButton
	if	s" TBSTYLE_GROUP " 		append 1 +to flag then
	flag 1- 0max 0 ?do  s" or " append loop
	flag 1 > if  +crlf 48 +spaces then
	flag 0= if s" 0              " append then ;

: write-tableline { ndx -- }
\ given a button in ThisTBButton write a table line for it
	StyleSeparator: ThisTBButton
	if	54 +spaces s" SeparatorButton,"  append&crlf exit then
        bitmapindex: ThisTBButton (.)   9 append.l
        id: ThisTBButton (.) 		8 append.l
	write-state
	write-style
        ndx (.)                         4 append.l
        s"  ToolBarButton, " append&crlf ;

: WriteExtraButtonTable	( -- )
	Link#: TBList >r
	>FirstLink: TBList
	0 ( flag ) #Buttons 0
	do	Data@: TBList to ThisTBButton
		ExtraButton: ThisTBButton
		if	dup 0=
			if	s" ToolBarTableExtraButtons:" append&crlf
				not
			then	i write-tableline
		then	>NextLink: TBList
	loop	drop r> >Link#: TBList ;

: WriteMainButtonTable ( -- )
	Link#: TBList >r
	>FirstLink: TBList
	#Buttons 0
	do	Data@: TBList to ThisTBButton
		ExtraButton: ThisTBButton not
		if	 i write-tableline
		then	>NextLink: TBList
	loop	drop r> >Link#: TBList ;

: WriteButtonTable  ( -- )
                    #Buttons 0= ?exit
                    +crlf s" :ToolBarTable " append tablename append&crlf
                    s" \ " append
                    s" Bmp ndx" 9 append.l
                    s" ID" 8 append.l
                    s" Initial State" 16 append.l
                    s" Initial Style" 16 append.l
                    s" Tooltip Ndx" append&crlf
		    WriteMainButtonTable
		    WriteExtraButtonTable
                    s" ;ToolBarTable " append&crlf ;


: WriteDefaultTable ( -- )
                    +crlf s" :ToolBarTable TheButtonTable" append&crlf
s" \  Bitmap index    id    Initial state    Initial style       tool string index" append&crlf
s"  STD_CUT         1001  TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  0 ToolBarButton," append&crlf
s"  STD_COPY        1002  TBSTATE_CHECKED  TBSTATE_ENABLED or TBSTYLE_CHECKGROUP  1 ToolBarButton," append&crlf
s"                                                                SeparatorButton," append&crlf
s"  STD_PASTE       1003  TBSTATE_ENABLED  TBSTYLE_BUTTON      2 ToolBarButton," append&crlf
s"                                                                SeparatorButton," append&crlf
s"  STD_PROPERTIES  1004  TBSTATE_ENABLED  TBSTYLE_BUTTON      3 ToolBarButton," append&crlf
s"  STD_PRINT       1005  TBSTATE_ENABLED  TBSTYLE_BUTTON      4 ToolBarButton," append&crlf
+crlf
s" ToolBarTableExtraButtons:" append&crlf

s" \  The following buttons will initialy not be in the tool-bar, but you can" append&crlf
s" \  put them there by customizing it (double click on gray part of the toolbar)." append&crlf
+crlf
s" STD_FILENEW     1006  TBSTATE_ENABLED  TBSTYLE_BUTTON      5 ToolBarButton," append&crlf
s" STD_FILEOPEN    1007  TBSTATE_ENABLED  TBSTYLE_BUTTON      6 ToolBarButton," append&crlf
s" STD_FILESAVE    1008  TBSTATE_ENABLED  TBSTYLE_BUTTON      7 ToolBarButton," append&crlf
s" STD_UNDO        1009  TBSTATE_ENABLED  TBSTYLE_BUTTON      8 ToolBarButton," append&crlf
s" STD_REDOW       1010  TBSTATE_ENABLED  TBSTYLE_BUTTON      9 ToolBarButton," append&crlf
s" STD_DELETE      1011  TBSTATE_ENABLED  TBSTYLE_BUTTON     10 ToolBarButton," append&crlf
s" STD_PRINTPRE    1012  TBSTATE_ENABLED  TBSTYLE_BUTTON     11 ToolBarButton," append&crlf
s" STD_FIND        1013  TBSTATE_ENABLED  TBSTYLE_BUTTON     12 ToolBarButton," append&crlf
s" STD_REPLACE     1014  TBSTATE_ENABLED  TBSTYLE_BUTTON     13 ToolBarButton," append&crlf
s" STD_HELP        1015  TBSTATE_ENABLED  TBSTYLE_BUTTON     14 ToolBarButton," append&crlf
s" ;ToolBarTable" append&crlf ;


: WriteOpening      ( -- )
                +crlf
                s" :Object " append Name count append 1 +tabs s" <Super Win32Toolbar" append&crlf
                +crlf s" int hbitmap" append&crlf ;

: WriteClassInit    ( -- )
                +crlf s" :M ClassInit:  ( -- )" append&crlf
                1 +tabs s" ClassInit: super" append&crlf
                1 +tabs s" 0 to hbitmap" append&crlf
                1 +tabs NextId (.) append s"  to id" append&crlf
                1 +tabs s" ;M" append&crlf ;

: WriteStart    ( -- )
                +crlf s" :M Start:   ( parent -- )" append&crlf
                #Buttons
                if      1 +tabs tablename append 1 +tabs s" IsButtonTable: self"
                        append&crlf
                then    ToolTips #Buttons 0<> and
                if      1 +tabs tooltipname append 1 +tabs s" IsTooltips: self"
                        append&crlf
                then    ShowText #Buttons 0<> and
                if      1 +tabs buttontextname append 1 +tabs s" IsButtonStrings: self" append&crlf
                then    +crlf 1 +tabs s" Start: super" append&crlf +crlf
                1 +tabs ButtonWidth (.) append bl cappend ButtonHeight (.) append
                s"  word-join 0 TB_SETBUTTONSIZE hwnd Call SendMessage drop" append&crlf
                1 +tabs BitmapWidth (.) append bl cappend BitmapHeight (.) append
                s"  word-join 0 TB_SETBITMAPSIZE hwnd call SendMessage drop" append&crlf +crlf
                1 +tabs bitmapname  append s"  usebitmap  map-3Dcolors" append&crlf
                1 +tabs s" \ create bitmap handle from memory image" append&crlf
                1 +tabs s" GetDc: self dup CreateDIBitmap to hbitmap" append&crlf
                1 +tabs s" ReleaseDc: self" append&crlf
                1 +tabs s" hbitmap      \ do we have a handle?" append&crlf
                1 +tabs s" if      0 hbitmap " append #Buttons (.) append
                        s"  AddBitmaps: self drop" append&crlf
                1 +tabs s" then" append&crlf
                1 +tabs s" ;M " append&crlf ;

: WriteDefaultStart ( -- )
                +crlf s" :M Start:       ( parent -- )" append&crlf
\               1 +tabs s" ButtonText IsButtonStrings: self" append&crlf
                1 +tabs s" TheButtonTable   IsButtonTable: self" append&crlf
                1 +tabs s" ButtonToolTips      IsToolTips: self" append&crlf
                +crlf 1 +tabs s" Start: super" append&crlf +crlf
                +crlf
                1 +tabs s"  HINST_COMMCTRL  IDB_STD_SMALL_COLOR  15 AddBitmaps: self drop" append&crlf
\                1 +tabs s" \ HINST_COMMCTRL  IDB_STD_LARGE_COLOR  15 AddBitmaps: self drop" append&crlf
                1 +tabs s" ;M" append&crlf ;

: WriteWindowStyle ( -- )
                +crlf
                s" :M WindowStyle:  ( -- style )" append&crlf
                1 +tabs s" WindowStyle: super" append&crlf
                Tooltips  if    1 +tabs s" TBSTYLE_TOOLTIPS or" append&crlf then
                Flat      if    1 +tabs s" TBSTYLE_FLAT  or"    append&crlf then
                Customizable
                          if    1 +tabs s" CCS_ADJUSTABLE or"   append&crlf then
                Wrap      if    1 +tabs s" TBSTYLE_WRAPABLE or" append&crlf then
                Bottom    if    1 +tabs s" CCS_BOTTOM or"       append&crlf then
                List      if    1 +tabs s" TBSTYLE_LIST or"     append&crlf then
                NoDivider if    1 +tabs s" CCS_NODIVIDER or"    append&crlf then
                NoMoveY   if    1 +tabs s" CCS_NOMOVEY or"      append&crlf then
                AltDrag   if    1 +tabs s" TBSTYLE_ALTDRAG or"  append&crlf then
                1 +tabs s" ;M" append&crlf ;

: WriteDefaultStyle ( -- )
                +crlf
                s" :M WindowStyle: ( -- style )" append&crlf
                1 +tabs s" WindowStyle: super" append&crlf
                1 +tabs s" CCS_ADJUSTABLE or " append&crlf
                1 +tabs s" TBSTYLE_TOOLTIPS or" append&crlf
                1 +tabs s" TBSTYLE_FLAT or" append&crlf
                1 +tabs s" ;M" append&crlf ;

: WriteOnDone   ( -- )
                +crlf
                s" :M On_Done:   ( -- )" append&crlf
                1 +tabs s" hbitmap" append&crlf
                1 +tabs s" if      hbitmap Call DeleteObject drop" append&crlf
                2 +tabs s" 0 to hbitmap" append&crlf
                1 +tabs s" then    On_Done: super" append&crlf
                1 +tabs s" ;M" append&crlf ;

: WriteEnd      ( -- )
                +crlf
                s" ;Object" append&crlf ;

: WriteNeeds    ( -- )
                s" anew _tbar" append&crlf +crlf
                s" \- :ToolBarTable  needs ToolBar.f   \ " append
                s" Michael Hillerström's toolbar class" append&crlf
                s" \- usebitmap needs Bitmap.f" append&crlf ;

:M ToolbarCommand:  ( -- )  \ factored to facilitate application wizard
                +crlf
                s" :M On_Command:  { hCtrl code bid -- } " append&crlf
                1 +tabs s" bid" append&crlf
                1 +tabs s" case   \ insert your code for button ids here" append&crlf
		nolist? not
		if	Link#: TBList
			#Buttons 1+ 1   \ write the id codes
			?do     i >Link#: TBList
				StyleSeparator: [ Data@: TBList ] not
				if	2 +tabs
					Description: [ Data@: TBLIST ]  14 append.l
					s"  of    ( insert code here ) " append
					1 +tabs s"  endof" append&crlf
				then
			loop	>Link#: TBList
		then
                1 +tabs s" endcase" append&crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" :M WM_COMMAND   ( hwnd msg wparam lparam -- res )" append&crlf
                1 +tabs s" ?dup 0=" append&crlf
                1 +tabs s" if     LOWORD" append&crlf
                1 +tabs s"        CurrentMenu" append&crlf
                1 +tabs s"        if      dup DoMenu: CurrentMenu" append&crlf
                1 +tabs s"        then" append&crlf
                1 +tabs s"        CurrentPopup" append&crlf
                1 +tabs s"        if      dup DoMenu: CurrentPopup" append&crlf
                1 +tabs s"        then    drop" append&crlf
                1 +tabs s" else   over HIWORD ( notification code ) rot LOWORD ( ID )" append&crlf
                1 +tabs s"        On_Command: [ self ]" append&crlf
                1 +tabs s" then" append&crlf
                1 +tabs s" 0 ;M" append&crlf ;M


: WriteDemoWindow ( -- )    \ demonstration window for toolbar
                +crlf +crlf
                s" :Object " append Name count append s" Window" append
                2 +tabs s" <Super Window" append&crlf
                +crlf
                s" int TheToolBar" append&crlf
                +crlf
                s" :M ClassInit:   ( -- )" append&crlf
                1 +tabs s" ClassInit: super" append&crlf
                1 +tabs s" NULL to TheToolBar" append&crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" :M On_Init:     ( -- )" append&crlf
                1 +tabs name count append s"  to TheToolBar" append&crlf
                +crlf
                1 +tabs s" self Start: TheToolBar" append&crlf
                Flat    \ is this a flat toolbar?
                if      +crlf
 s" \ The following code line will be necessary depending on the background color" append&crlf
 s" \ of your windows. Flat toolbars are displayed using the default background" append&crlf
 s" \ window color of the parent window which is WHITE in Win32Forth. If you" append&crlf
 s" \ want the toolbar to display using system colors, e.g on WinXP, set the" append&crlf
 s" \ color that best suits you. You can check the Windows API for more infomation" append&crlf
                1 +tabs s" COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hwnd  Call SetClassLong drop" append&crlf
 s" \ BTW, note that the above will change the default background color of future windows" append&crlf
                then    +crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" :M WM_NOTIFY    ( h m w l -- f )" append&crlf
                1 +tabs s" Handle_Notify: TheToolBar" append&crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" :M On_Size:      ( -- )" append&crlf
                1 +tabs s" AutoSize: TheToolBar" append&crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                ToolBarCommand: self
                s" :M Close:  ( -- )" append&crlf
                1 +tabs s" Close: TheToolBar" append&crlf
                1 +tabs s" Close: super" append&crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" :M WindowTitle: ( -- zstring )" append&crlf
                1 +tabs 'z' cappend "append s"  TestWindow" append "append +crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" :M On_Paint: ( -- )" append&crlf
                1 +tabs s" 0 0 GetSize: self Gray FillArea: dc" append&crlf
                1 +tabs s" ;M" append&crlf
                +crlf
                s" ;Object" append&crlf
                +crlf
                s" Start: " append name count append s" window" append&crlf ;

:M WriteToolBar:    ( -- ) \ factored to facilitate application wizard
                ToolBarBitmap c@
                if      WriteLoadBitmap
			WriteIDConstants
                        WriteTooltips
                        WriteButtonText
                        WriteButtonTable
                        WriteOpening
                        WriteClassInit
                        WriteStart
                        WriteWindowStyle
                        WriteOnDone
                else    \ WriteDefaultButtonText
                        WriteDefaultTooltips
                        WriteDefaultTable
                        WriteOpening
                        WriteClassInit
                        WriteDefaultStart
                        WriteDefaultStyle
                        WriteOnDone
                then    WriteEnd ;M

: CompileToolbar        ( -- )
                initbuffer
                SaveProperties
		SaveInfo
                Name c@ 0= abort" Toolbar name not specified!"
                WriteNeeds
                WriteToolbar: Self
                WriteDemoWindow ;

: ToolBarTest   { \ s1 c1 -- }  \ toolbar testing on the fly!
                CompileToolbar TheBuffer to c1 to s1
                begin       c1
                while       s1 c1 readline-memory to c1 to s1 evaluate
                repeat      ;

\ : TestToolBar   (  -- ) \ test from a file on disk, not used right now
\ There was an insidious bug that popped up when compiling from memory which
\ I still haven't figured out what caused it. It may return as mysteriously as
\ it disappeared :-(
\                 CompileToolbar
\                 s" $test$.f" SetName: TDFFile
\                 Create: TDFFile ?exit
\                 TheBuffer Write: TDFFile
\                 Close: TDFFile ?exit
\                 s" fload $test$.f" evaluate ;

: ViewSource    ( -- )  \ view source code for a toolbar
                CompileToolBar TheBuffer
                join$( s" Toolbar-"
			name count
		)join$ count ShowSource ;

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID )
                case
                          GetID: btnOpen      of      OpenToolBarFile     endof
                          GetID: btnSave      of      SaveToolBarFile     endof
                          GetID: btnBrowse    of      GetBitmap           endof
                          GetID: btnNew       of      NewToolBar          endof
                          GetID: btnClose     of      Close: self         endof
                          GetID: btnView      of      ViewSource          endof
                          GetID: btnTest      of      ToolBarTest         endof
			  GetID: btnRefresh   of      refresh		  endof
			  GetID: btnAdd       of      addbutton 	  endof
			  GetID: btnDelete    of      deletebutton	  endof
			  GetID: btnPrevious  of      previousbutton      endof
			  GetID: btnNext      of      nextButton          endof
			  GetID: btnMoveUp    of      movebuttonup        endof
			  GetID: btnMoveDown  of      movebuttondown      endof
			  GetID: btnFirst     of      firstbutton	  endof
			  GetID: btnLast      of      lastbutton          endof
                endcase 0 ;M


:M ParentWindow:    ( -- hwndparent )
                    GetHandle: MainWindow ;M


:M ToolBarName:     ( -- addr cnt )
                    Name count ;M

;object

: CreateToolBar ( -- )
                Start: frmCreateToolBar ; IDM_FORM_CreateToolBar SetCommand


\s
