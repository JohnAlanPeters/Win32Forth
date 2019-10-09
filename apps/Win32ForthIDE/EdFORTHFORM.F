\ EdForthForm.f

cr .( Loading Form Designer...)

vocabulary forthform
vocabulary testvocab       \ for testing forms to avoid conflicts
also forthform also definitions

needs excontrols.f          \ extended controls for Win32Forth
needs ExUtils.f             \ general utilities
needs linklist.f            \ very useful utility
needs bitmap.f              \ bitmap loading routines
needs point.f               \ simple point class
needs rect.f                \ class for drawing boxes
needs fcases.f              \ case extensions
needs file.f                \ file functions encapsulated in a class
needs fcases.f              \ extension to case and if
needs joinstr.f             \ join any number of counted strings
needs toolbar.f             \ Windows toolbar class
needs enum.f                \ enumerated constants
needs multiopen.f           \ open multiple forms
needs folderview.f          \ listview folder viewer

\ control identifiers
1 to enum-value
enum:      TypeLabel        TypeTextBox      TypeGroupBox      TypePushButton
           TypeCheckBox     TypeRadioButton  TypeBitMapButton  TypeIconButton
           TypeMultiLineBox TypeStaticBitmap TypeUpDownControl
           TypeProgressBar  TypeTrackBar     TypeListBox       TypeComboBox
           TypeComboListBox TypeRadioBar     TypeStatusBar     TypeCalendar
           TypeHorizScroll  TypeVertScroll   TypeMultiListBox  TypePictureButton
           TypeGeneric      TypeFileWindow   TypeTabControl    TypeSpinnerControl
           ;

\ class identifiers
0 to enum-value
enum:
    DIALOG-CLASS			\ normal dialog forms
    CHILD-CLASS				\ child window forms
    MDIDIALOG-CLASS 			\ MDI forms
    TRAY-CLASS
    ;

10 constant gridspacing         	\ pixels between grid points

0 value ThisForm
0 value formcount       		\ running total of created forms
0 value ButtonID        		\ button to be unchecked
0 value NextControlType    		\ next control to be created
false value newcontrol?
0 value picturebmp
0 value staticbmp
32 1024 * cell+ constant max-codesize	\ 32k for now but can be changed

20400 constant fform_version#

20300 constant old_fform_version#


\ registry values
1 value MonitorLeft               	\ monitor window x position
1 value MonitorTop                	\ default is same y position

0 value frmdata-size                	\ set to values for checking a form
0 value ctrldata-size               	\ before opening it
true value SingleControl?	    	\ allow only one control to be added at a time?
false value AutoProperty?	    	\ automatically display appropriate property dialog?
variable formwindow-link            	\ all forthform windows, allow simple closing
         formwindow-link off
false value detached?			\ is form designer window detached from tabcontrol?
false value don't-refresh?		\ refresh code window only when necessary

ColorObject FormColor             	\ background form color
Font ControlFont                  	\ default font for text to be written in control
\ ListBox FormPicker		  	\ list of open forms

\ status labels
Label lblFormName
Label lblControlName
Label lblPosition
Label lblSize
Label lblModified

File MergeFile
File TheFile

macro ?abort " if abort then"

defer OnActive
defer doUpdate
defer UpdatePropertyWindow
defer UpdateSystem
defer NewCodeWindow

\ The value show-code? prevents control code from being displayed automatically in the IDE until
\ the control is selected from the Code Editor. So if just creating forms normally without
\ adding any code the Code Editor can be ignored. If a control is selected from the Code Editor
\ window the flag will be set so that for any further controls added or clicked will display
\ that control's code in the IDE. It can be reset when by closing the code editing window.
false value show-code?

1 to enum-value
enum:
FLAG_GLOBAL
FLAG_LOCAL
FLAG_ONINIT
FLAG_CODE
FLAG_ONDONE ;

: RefreshActiveCoder	( flag -- )
		NewCodeWindow Refresh: ActiveCoder ;

: link-formwindow { win -- }
                formwindow-link link,    \ link into list
                win , ;

\ : close-form-windows  { \ wlink -- } \ close ForthForm windows
\                 formwindow-link @
\                 begin   dup
\                 while   dup cell+ @ to wlink
\                         Close: wlink
\                         @
\                 repeat  drop ;

: no-show?	( -- f )	\ status labels not active?
		GetHandle: lblPosition Call IsWindow 0= 	\ check one only
		;

: ShowPosition  { x y -- } \ display coordinates in status window
		no-show? ?exit
                join$(   s" X= "
			 x >str
			 s"   "
			 s" Y= "
			 y (.)
                )join$ count SetText: lblPosition ;

: ShowSize      { w h -- }  \ display dimensions in status window
		no-show? ?exit
                join$(	s" Width= "
			w >str
			s"   "
			s" Height= "
			h (.)
                )join$ count SetText: lblSize ;

: ClearStatusWindow  ( -- )   \ clear status window duh!
		no-show? ?exit
                s" " SetText: lblSize
                s" " SetText: lblPosition
                s" " SetText: lblControlName
                s" " SetText: lblFormName
                s" " SetText: lblModified
                ;

: AdjustWindowSize      { width height winhndl -- }
               [ SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or ] LITERAL
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                winhndl Call SetWindowPos drop ;

: ALignGridXY   ( -- )
                ActiveForm 0= ?exit
                AlignGridXY: ActiveForm ;

: ALignGridX    ( -- )
                ActiveForm 0= ?exit
                AlignGridX: ActiveForm ;

: ALignGridY    ( -- )
                ActiveForm 0= ?exit
                AlignGridY: ActiveForm ;

: AutoSize      ( -- )
                ActiveForm 0= ?exit
                AutoSize: ActiveForm ;

: ArrangeVertical ( -- )
                ActiveForm 0= ?exit
                ArrangeVertical: ActiveForm ;

: ArrangeHorizontal ( -- )
                ActiveForm 0= ?exit
                ArrangeHorizontal: ActiveForm ;

: DeleteControl ( -- )
                ActiveForm 0= ?exit
                DeleteControl: ActiveForm ; IDM_FORM_Delete SetCommand

: MoveToBack    ( -- )
                ActiveForm 0= ?exit
                MoveToBack: ActiveForm ;  IDM_FORM_MoveToBack SetCommand

: MoveToFront   ( -- )
                ActiveForm 0= ?exit
                MoveToFront: ActiveForm ; IDM_FORM_MoveToFront SetCommand

: ChangeControl ( -- )  \ change current control to new selection
                newcontrol? 0= ?exit    \ must select from toolbar
                ActiveForm  0= ?exit    \ for obvious reasons
                ActiveControl: Activeform 0= ?exit
                ChangeControl: ActiveForm
                doUpdate ;

: ChangeControlFont  ( -- )    \ change the font for a control
                ActiveForm 0= ?exit
                ActiveControl: ActiveForm ?dup
                if    GetUserFont: [ ]
                      IsModified: ActiveForm
                      doUpdate
                then  ;

: ResetControlFont   ( -- )       \ reset control to the default
                ActiveForm 0= ?exit
                ActiveControl: ActiveForm ?dup
                if    DefaultFont: [ ]
                      IsModified: ActiveForm
                      doUpdate
                then  ;

: font-type?    ( ctrltype -- f ) \ allow font change for this control?
                dup 0= ?exit
                |   TypePushbutton
                    TypeGroupBox
                    TypeCheckBox
                    TypeRadioButton
                    TypeLabel
                    TypeTextBox
                    TypeMultiLineBox
                    TypeListBox
                    TypeComboBox
                    TypeComboListBox
                    TypeMultiListBox
                    TypeGeneric     \ in case we just want a font
                |if    true
                else   false
                then   ;

: #Forms        ( -- n )    \ return number of open forms
                FormList
                if      Data@: FormList
                        if      #Links: FormList
                        else    0
                        then
                else    0
                then    ;

: ?FormNumber   { frmobject -- n } \ given object address return position in list
                frmobject 0= FormList 0= or
                if      0 exit
                then    >FirstLink: FormList
                #Forms 1+ 1
                ?do     Data@: FormList frmobject =
                        if     i unloop
                               exit
                        then   >NextLink: FormList
                loop    0 ;

: GetForm	{ n -- form | 0 }
		n 0> #forms 0<> and
		n 1 #forms between and dup 0= ?exitm
		drop
		n >Link#: FormList
		Data@: FormList ;

: ShowSource     ( addr cnt title$ cnt -- )
		NewEditWindow
		SetFileName: ActiveChild
		SetFocus: ActiveChild
		over + off SetText: CurrentWindow
                SetSavePoint: CurrentWindow           \ mark as unmodified
                Update
		;

: ?addext       { ext-name ext-cnt fname -- fname }
                fname c@
                if      fname count ".ext-only" nip 0=
                        if      ext-name ext-cnt fname +place
                        then
                then    fname ;

10 constant #ids
create IDList
s" DEFAULT"	", \ default id
s" IDOK" 	", \ OK button was selected.
s" IDCANCEL" 	", \ Cancel button was selected.
s" IDYES"  	", \ Yes button was selected.
s" IDNO"  	", \ No button was selected.
s" IDABORT" 	", \ Abort button was selected.
s" IDIGNORE" 	", \ Ignore button was selected.
s" IDCONTINUE" 	", \ Continue button was selected.
s" IDRETRY" 	", \ Retry button was selected.
s" IDTRYAGAIN" 	", \ Try Again button was selected.
0 , align

: check-id	( n1 -- n2 ) \ n2 = n1 or 0
		dup 0 #ids within not
		if	drop 0 	\ make it in range
		then	;

: GetID$	( n -- addr cnt )
		check-id IDList swap 0
		?do	count +
		loop	count ;

FileOpenDialog OpenSessionDlg "Load Session File" "Session Files|*.ses|"
FileSaveDialog SaveSessionDlg "Save Session File" "Session Files|*.ses|"
MultiFileOpenDialog OpenFormDlg "Open Form File" "Form Files|*.ff|All Files|*.*|"
FileSaveDialog SaveFormDlg "Save Form File" "Form Files|*.ff|"
FileOpenDialog GetBitmapDlg "Get Bitmap" "Bitmap Files|*.bmp;*.dib|"

\ all ForthForm dialogs
needs ControlProperty.frm
needs CreateMenuForm.frm
needs CreatePropertyForm.frm
needs CreateToolBarForm.frm
needs FormProperty.frm
needs GroupAction.frm
needs SplitterWindow.frm
needs TabPropertyWindow.frm
needs ChooseIcon.frm
\ more sources
needs formcontrols.f        \ subclassed control object
needs groupaction.f         \ positioning of controls
needs FormCodeEditor.f      \ adding code to forms
needs taborder.f            \ change tab order form
needs formproperty.f        \ edit of form properties
needs edformwindow.f       \ form designer window
needs formobject.f          \ load form class
needs CreateToolBar.f       \ toolbar generator ...but you knew that right?
needs SplitterWindow.f      \ this is also an easy guess!
needs CreateMenu.f          \ now what could this file be for?
needs CreatePropertyForm.f  \ generate property sheet like template

Form DummyForm		    \ dummy
ControlObject DummyControl  \ objects


: updatewin     ( -- )      \ update everything
                UpdateProperties++
                ?EnableFormMenuItems
		Update: Monitor
                ; ' updatewin is doupdate

: check-file      { fname fcnt \ fsize -- f }      \ check integrity of file before opening
                  fname fcnt SetName: TheFile   \
                  Open: TheFile ?dup ?exit
                  FileSize: TheFile drop to fsize  \ larger than 4 gig .ff file?
                  Close: TheFile
                  fsize GetData: DummyForm nip  < ?dup ?exit   \ must have at least a form header
                  fsize GetData: DummyForm nip  - GetData: DummyControl nip mod 0<>  \ must be evenly divisible
                  ;

: _NewForm      ( -- )      \ _NewForm
		IDM_SHOW_FORMTAB DoCommand	\ in case it's not showing
                AddNewForm
                Init: ThisForm
                s" untitled.ff" SetFileName: ThisForm
                join$(  s" Form"
			formcount (.)
		)join$ count 2dup  SetName: ThisForm
                               IsFormTitle: ThisForm
                Start: ThisForm
                Display: ThisForm
                doupdate
                ;    IDM_FORM_New SetCommand

: (OpenForm)    { fname fcnt -- } \ open form given its name
		IDM_SHOW_FORMTAB DoCommand	\ in case it's not showing
                fname fcnt check-file ?dup
                if    join$(    fname fcnt
				s"  is an invalid Form file!"
		      )join$  count ?MessageBox
                      exit
                then  AddNewForm
                Start: ThisForm
                fname fcnt SetFileName: ThisForm
                Load: ThisForm
                UpdateStatus: ThisForm
                Display: ThisForm
                doupdate
                UpdateSystem ;   IDM_FORM_(Open) SetCommand

: OpenForm      ( -- ) \ open one or more form files
		IDM_SHOW_FORMTAB DoCommand
                GetHandle: MainWindow Start: OpenFormDlg c@
                if      #SelectedFiles: OpenFormDlg 0
                        do      i GetFile: OpenFormDlg (OpenForm)
                        loop
                then    ;    IDM_FORM_Open SetCommand

: EditForm         ( -- )     \ view/edit form source code
                ActiveForm 0= ?exit
                GetBuffer: ActiveForm FormName: ActiveForm count ShowSource ; IDM_FORM_EDITOR SetCommand

: SaveForm      ( -- )  \ just save form, allow name change if untitled
                ActiveForm 0= ?exit
                Save: ActiveForm ;  IDM_FORM_SAVE SetCommand

: SaveFormAs    ( -- )  \ save under different name
                ActiveForm 0= ?exit
                SaveAs: ActiveForm ;  IDM_FORM_SAVEAS SetCommand

: TurnkeyForm	( -- )	\ compile form to executable file
		Activeform 0= ?exit	\ shouldn't happen but just in case
		GetSuperClass: ActiveForm dup DIALOG-CLASS swap TRAY-CLASS or <> dup		\ dialog only!
		s" Only forms of class dialog window or tray window can be turnkeyed!" ?MessageBox
		?exit
		GetHandle: MainWindow SetParentWindow: frmGetIconFile
		Start: frmGetIconFile	\ is an iconfile needed?
		continue?		\ if yes
		if	Turnkey: ActiveForm	\ then go ahead and compile
		then	; IDM_TURNKEY_FORM SetCommand

: CompileForm   ( -- )  \ compile to disk
                ActiveForm
                if      CompileForm: ActiveForm
                then    ;  IDM_FORM_WRITE SetCommand

: TestForm  ( -- ) \ test form from image in memory
        ActiveForm 0= ?exit
        Validate: ActiveForm
        s" anew _frm" evaluate
        ChildState: ActiveForm >r      \ we want to see the form if it is a child, so we
        false IsChildState: Activeform \ save the state and change in case it is hidden
        GetBuffer: ActiveForm (fload-buffer)
        r> IsChildState: ActiveForm
        0=    	\ form loaded ok?
        if	GetSuperClass: ActiveForm dup CHILD-CLASS =     \ compiling as a child window?
		if      drop TestChildDialog: ActiveForm fload-buffer
		else    MDIDIALOG-CLASS =               \ or as a MDI dialog?
			if      TestMDIDialog: ActiveForm fload-buffer
			else    s" Start: " new$ dup>r place FormName: ActiveForm count r@ +place   \ no, as a dialog window
				r> count evaluate
			then
		then
	else	state @
		if	postpone [ 		\ reset if error occurrs while compiling
\in-system-ok		testvocab		\ set to test vocabulary
			s" _frm" evaluate	\ forget everything
		then
	then	 ;  IDM_FORM_TEST SetCommand

: SaveAllForms  ( -- ) \ save all modified forms
                #Forms ?dup
                if      1+ 1
                        do      Save: [ i GetForm ]
                        loop
                then    ; IDM_FORM_SAVEALL SetCommand

: MergeForms   { \ fname err - } \ compile all open forms to a single file
        #forms 2 < ?exit    \ no use merging 1 form
        \ we get the name of the merge file that will contain all forms
        GetFilter: SaveFormDlg new$ dup>r place
        s" Forms|*.frm|All Files|*.*|" SetFilter: SaveFormDlg
        GetHandle: MainWindow Start: SaveFormDlg to fname
        r> count SetFilter: SaveFormDlg
        fname c@ 0= ?exit       \ operation was cancelled
        \ add a default .frm extension if none specified
        fname count 2dup pad place ".ext-only" nip 0=
        if  s" .frm" pad +place
        then    pad count SetName: MergeFile
        Create: MergeFile ?exit
        \ now we compile all forms to memory and then write to merge file
        >FirstLink: FormList
        #forms 1+ 1
        do  Data@: FormList GetBuffer: [ ] 2drop
            +crlf +crlf     \ couple blank lines
            TheBuffer Write: MergeFile ?leave
            >NextLink: FormList
        loop    Close: MergeFile ClearName: MergeFile ;  IDM_FORM_MERGE SetCommand

: CopyFormToClipBoard   ( -- )       \ copy to clipboard
          ActiveForm 0= ?exit
          GetBuffer: ActiveForm copy-clipboard ;  IDM_FORM_COPY SetCommand

: CloseForm     { TheForm -- }
                SetFocus: TheForm
                Close: TheForm
                GetFileName: TheForm 2dup s" untitled.ff" istr= not
                if	drop 1- Insert: RecentFormFiles \ save filename in recent files list
                else	2drop
                then	TheForm ?FormNumber >Link#: FormList
                TheForm Dispose
                0 Data!: FormList
                DeleteLink: FormList
                #Forms 0=
                if      Blank: Monitor
                        ClearStatusWindow
                        SetFocus: MainWindow
                        0 to ActiveForm
                        Clear: frmProperties++
                        Clear-CodeLists
                        ActiveCoder ?dup
                        if	GetHandle: [ ] CloseChild: MainWindow
                        then	Close: CodePreviewWindow
			FormList Dispose 0 to FormList
			ActiveChild 0=	\ no other file opened
			if	WindowTitle: MainWindow zcount SetText: MainWindow
			then
                else    SetFocus: [ Data@: FormList ]
                        UpdatePropertyWindow
                        ActiveCoder
                        if	ActiveControl: ActiveForm
				if	FLAG_CODE
				else	FLAG_GLOBAL
				then	Refresh: ActiveCoder
			then
                then	#Forms 2 <			\ less than two forms opened
                if      Close: frmCreatePropertyForm	\ makes no sense
                else    Refresh: frmCreatePropertyForm
                then    doUpdate
                ; IDM_FORM_Close SetCommand

: CloseAllForms ( -- )  \ clean slate
                FormList 0= ?exit
		>FirstLink: FormList
		Begin	      FormList
		While	      Data@: FormList CloseForm
		Repeat	;  IDM_FORM_CloseAll SetCommand

: AddFormToProject ( form -- )	\ include in project
\ Form must be compiled first
		TextFile: [ ] 2dup s" untitled.frm" istr= not
		if	AddForm: TheProject
		else	2drop
		then	; IDM_FORM_AddToProject SetCommand

: AddOpenForms	( -- )	\ include all open forms in project
\ Forms should have been compiled first
                #Forms ?dup
                if	1+ 1
			do	i GetForm AddFormToProject
			loop
		then	; IDM_ADD_FORMS_PRJ SetCommand

: CompileAllForms	{ \ flag -- }
		#Forms ?dup
		if	1+ 1
			0 to flag
			do	i GetForm to ThisForm
				UnSaved?: ThisForm not
				if	TextFile: ThisForm SetName: TheFile
					Create: TheFile ?abort	\ overwrite even if exist
					GetBuffer: ThisForm Write: Thefile
					Close: TheFile ?abort	\ on write error
					true to flag
				then
			loop	flag s" Done!" ?MessageBox
		then	; IDM_FORM_WriteAll SetCommand

\ Session file loading definitions
\ A session file is a standard text file defining the current state of the system
\ To add any new status information simply define words for reading and writing it

: Form=         ( <name> -- )   \ get form filename from input stream
                0 word dup c@
                if      count (OpenForm)    \ if we have a form open it
                else    drop
                then    ;

: Project=      ( -- )	\ open project file
                0 word dup c@
                if      IDM_OPEN_RECENT_FILE_PRJ DoCommand
                else    drop
                then    ;

: File=		{ \ tmp# browsing? buf -- } ( <name> -- ) \ get file name from input stream
                max-path LocalAlloc: buf
		false to browsing?
		-1 to tmp#
                ',' word dup c@
                if      count buf place
			more?
			if	',' word count number?
				if	drop to tmp#
				else	2drop
				then	more?
				if	0 word count s" browsing" istr=
					if	true to browsing?
					then
				then
			then	buf count file-status nip 0= 	\ if still exist
			if	buf IDM_OPEN_RECENT_FILE DoCommand  \  open it
				tmp# -1 <>
				if	tmp# GotoPos: CurrentWindow
				then	GetFileType: Activechild FT_SOURCE =
				if      browsing? SetBrowseMode: ActiveChild
				then
			then
                else    drop
                then    ;

: (LoadSession)	( filename$ -- )
		nostack1 ['] $fload catch
                s" Session load aborted!" ?MessageBox
                ;

: LoadSession 	( -- )
                GetHandle: MainWindow Start: OpenSessionDlg dup c@
                if	(LoadSession)
                else    drop
                then    ; IDM_FORM_LOADSESSION SetCommand

: write-formfiles { \ this -- } \ write any forms opened
                  #Forms ?dup
                  if    >FirstLink: FormList
                        1+ 1
                        do      Data@: FormList to this
                                GetFileName: this 2dup s" untitled.ff" istr= not
                                if	s" Form= " append GetFileName: this append&crlf
                                else	2drop
                                then    >NextLink: FormList
                        loop
                  then  ;

: write-projectfile ( -- )
		GetProjectFileName: TheProject ?dup
		if	s" Project= " append
			append&crlf
		else	drop false
		then	;

: write-openfiles	{ \ flag ThisChild -- f }
		false to flag
                TabFile? 0
                ?do      i GetFileTabChild dup to ThisChild
                         if	ThisChild ActiveCoder <>
                                if      GetFileName: ThisChild dup
                                        count "TO-PATHEND" s" <Untitled>" istr= not
                                        if	s" File= " append
                                                count append
                                                GetFileType: ThisChild FT_SOURCE =
                                                if	',' cappend
                                                        ChildWindow: ThisChild
                                                        GetCurrentPos: [ ] (.) append
                                                        ',' cappend
                                                        ?BrowseMode: ThisChild
                                                        if	s" BROWSING"
                                                        else	s" EDITING"
                                                        then	append&crlf
                                                else	+crlf
                                                then
                                        else	drop
                                        then
                                then
			then
                loop	;

: (SaveSession)	( filename$ -- )
		count SetName: TheFile
		Create: TheFile ?exit
		initbuffer
		write-projectfile
		write-openfiles
                write-formfiles
		TheBuffer Write: TheFile drop
		Close: TheFile
		;

: SaveSession   ( -- )  \ save current state of system
                GetHandle: MainWindow Start: SaveSessionDlg
                s" .ses" rot ?addext dup c@
                if      (SaveSession)
                else    drop
                then    ;   IDM_FORM_SaveSession SetCommand

create DefaultSessionFile ," Win32ForthIDE.SES"

: SaveDefaultSession	( -- )
		DefaultSessionFile count Prepend<Home>\ new$ dup>r place
		r> (SaveSession) ; IDM_SAVEDEFAULT_SESSION SetCommand

: LoadDefaultSession	( -- )
		DefaultSessionFile count Prepend<Home>\ new$ dup>r place
		r@ count file-status nip 0=	\ if it exists
		if	r@ (LoadSession)
		else	true s" No default session file saved!" ?MessageBox
		then	r>drop ; IDM_LOADDEFAULT_SESSION SetCommand

editor definitions	\ as we were
\s
