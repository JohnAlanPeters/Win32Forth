\ ForthForm generated splitter-window template
\ Modify according to your needs

ListBox lstCodeForms
ListBox lstCodeControls
PushButton btnTestForm
s" Test the selected form and it's code using the console" BInfo: btnTestForm place
PushButton btnPreview
s" Open a window to preview form code as it is edited" BInfo: btnPreview place

needs scintillaedit.f

:Object scnCodePreviewer	<Super Scintillaedit

\ we need the original version for this, I don't think FindText: Super Super would work!
:M FindText:    ( Flags nMin nMax addr -- nStart nEnd flag )
                to ttrAddr to ttfMax to ttfMin
                TextToFind swap SCI_FINDTEXT SendMessage:Self -1 =
                if   0 0 false
                else ttfStart ttfEnd true
                then ;M
;Object

true value no-preview?		\ true if preview window not open

: SaveCode	{ -- }	\ save edited code for form or control
		ActiveCoder 0= ?exit
		SaveCode: ActiveCoder ;

: RefreshControlsList  { -- } \ fill control listbox
                        Clear: lstCodeControls		\ clear
                        \ form functions first
                        z" Global Code"       	AddStringTo: lstCodeControls	\ global to form
                        z" Local Code"      	AddStringTo: lstCodeControls	\ local to form
                        z" On_InitFunction"   	AddStringTo: lstCodeControls	\ for On_Init: method
                        z" On_DoneFunction"   	AddStringTo: lstCodeControls	\ for On_Done: method
                        GetSelection: lstCodeForms 1+ GetForm to ThisForm
                        #Controls: ThisForm 0= ?exit
                        \ now the controls
                        #Controls: ThisForm 1+ 1
                        ?do     i GetControl: ThisForm  GetName: [ ] asciiz
                                AddstringTo: lstCodeControls
                        loop	;

: ShowSelectionCode	{ Theform -- } \ show code of selected item
		TheForm 0= ?exit
		TheForm ?FormNumber 1- SetSelection: lstCodeForms	\ show selected form
		RefreshControlsList					\ fill control list
		show-code? 0= ?exit					\ don't show code
		ActiveControl: TheForm ?ControlNumber: TheForm ?dup	\ if it has an active control
		if	2 + SetSelection: lstCodeControls		\ select it
			FLAG_CODE RefreshActiveCoder	\ and show its code
		then	;

: Update-CodePreviewer  { TheForm flag -- }	\ display code for active form, flag =true if saving position
		no-preview? ?exit
		TheForm 0= ?exit
                flag
		if	GetCurrentPos: scnCodePreviewer >r
		then	false SetReadOnly: scnCodePreviewer
                GetBuffer: TheForm over + off SetText: scnCodePreviewer
		flag
		if	r> GotoPos: scnCodePreviewer
		then	true SetReadOnly: scnCodePreviewer
		join$(
			s" Form Code Previewer - ["
			FormName: TheForm count
			s" ]"
		)join$	count GetParent: scnCodePreviewer SetText: [ ]
		;

: Highlight-Code	{ code-addr -- }				\ highlight code in previewer
		no-preview? ?exit
		code-addr zcount					\ if we have code
		if	>r 0 						\ search flag
			0 GetTextLength: scnCodePreviewer		\ range
			r> FindText: scnCodePreviewer			\ look for it
			if	SetSel: scnCodePreviewer		\ found it
			else	2drop RemoveSel: scnCodePreviewer	\ nope, so clear
			then
		else	drop RemoveSel: scnCodePreviewer		\ don't have anything
		then	;

: RefreshFormsList     ( -- )	\ fill forms listcontrol
		don't-refresh?
		if	false to don't-refresh? 		\ one time only
			exit
		then	Clear: lstCodeForms			\ clear everything
                #Forms 1+ 1					\ should be at least one form
                ?do     i GetForm to ThisForm
                        FormName: ThisForm count asciiz AddStringTo: lstCodeForms
                loop    ActiveForm ShowSelectionCode
                no-preview? ?exit
                ActiveForm false Update-CodePreviewer	\ update
                 ;

: Remote-Test	{ \ flag -- } \ open W32F and load form from console
		Validate: ActiveForm
		s" anew _frm" evaluate
		TextFile: ActiveForm pad place
		s" _test" pad +place
		pad count SetName: TheFile
		Create: TheFile ?exit
		initbuffer
		s" \ NOTE! THIS IS A TEST FILE ONLY, NOT INTENDED TO BE EDITED!" append&crlf
		s" \ MAKE ANY CHANGES OR CORRECTIONS FROM THE FORM CODE EDITOR OR THE .FRM FILE ONLY" append&crlf
		+crlf
		UnInitedBuffer: ActiveForm Write: TheFile dup to flag 0=
		if	GetSuperClass: ActiveForm dup CHILD-CLASS =     \ compiling as a child window?
			if      drop TestChildDialog: ActiveForm
				s" Display: " append FormName: ActiveForm count append&crlf
			else    MDIDIALOG-CLASS =               \ or as a MDI dialog?
				if      TestMDIDialog: ActiveForm
				else    initbuffer
					s" Start: " append FormName: ActiveForm count append&crlf
				then
			then	TheBuffer Write: TheFile to flag
		then	Close: TheFile
		flag 0=
		if	GetName: TheFile count Compile-File
		then	;

: TestSelection		( -- )
	GetSelection: lstCodeForms LB_ERR = ?exit
	GetSelection: lstCodeForms 1+ GetForm to ActiveForm
	control-key?
	if	IDM_FORM_TEST DoCommand
	else	Remote-Test
	then
	;

: Clear-CodeLists	( -- )
			Clear: lstCodeForms
			Clear: lstCodeControls ;

:Object FormPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M On_Init:     ( -- )
                CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop
                self Start: lstCodeForms
                Handle: ControlFont SetFont: lstCodeForms
                ;M

:M On_Size:     ( -- )
                0 0 Width Height Move: lstCodeForms
                ;M

:M Close:       ( -- )
                Close: lstCodeForms
                Close: Super
                ;M

:M On_Command:  { ncode id -- f }
                id GetId: lstCodeForms =
                if      ncode LBN_SELCHANGE  =
                        if     	GetSelection: lstCodeForms 1+ GetForm
				to ActiveForm	\ make it the active one for testing
				SetFocus: ActiveForm
				ActiveForm ShowSelectionCode
				ActiveForm false Update-CodePreviewer
                        then
                then    ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: self
        0 ;M

;Object

:Object ControlsPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M On_Init:     ( -- )
                CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop
                self Start: lstCodeControls
                Handle: ControlFont SetFont: lstCodeControls
                ;M

:M On_Size:     ( -- )
                0 0 Width Height Move: lstCodeControls
                ;M

:M Close:       ( -- )
                Close: lstCodeControls
                Close: Super
                ;M

: UpdateForm	( n -- ) \ n = activecontrol
		SetActiveControl: ActiveForm
                Paint: ActiveForm
		UpdateStatus: ActiveForm
		UpdatePropertyWindow ;


: ShowControlCode	( n -- )
			GetControl: ActiveForm UpdateForm
                        FLAG_CODE RefreshActiveCoder
                        ;

\ set activecontrol to nothing so that when for example, editing global, local or oninit code,
\ the activecoder would not switch to activecontrol code for a simple window focus change
: ShowGlobalCode	( -- )
                        0 UpdateForm
                        FLAG_Global RefreshActiveCoder
                        ;

: ShowLocalCode		( -- )
                        0 UpdateForm
                        FLAG_LOCAL RefreshActiveCoder
                        ;

: ShowOnInitCode	( -- )
                        0 UpdateForm
                        FLAG_ONINIT RefreshActiveCoder
                        ;

: ShowOnDoneCode	( -- )
                        0 UpdateForm
                        FLAG_ONDONE RefreshActiveCoder
                        ;

:M On_Command:  { ncode id -- }
                id GetId: lstCodeControls =
                if      true to show-code?	\ open code editing window
			ncode LBN_SELCHANGE  =
                        if	GetSelection: lstcodeForms 1+ GetForm to ActiveForm
				true to don't-refresh?		\ not necessary here
				GetSelection: lstCodeControls
				case
					0	of	ShowGlobalCode	endof
					1	of	ShowLocalCode	endof
					2	of	ShowOnInitCode  endof
                                        3       of      ShowOnDoneCode  endof
					3 - ShowControlCode false
				endcase
                         then
                then    ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: Self
        0 ;M

;Object

:Object CodePreviewWindow   <Super Window

:M On_Init:     ( -- )
		CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop
                self Start: scnCodePreviewer
                ShowLineNumbers: scnCodePreviewer
\                Color: BLACK Color: LTGRAY SetColors: scnCodePreviewer
\ 		Color: LTYELLOW SetCaretBackColor: scnCodePreviewer

		false to no-preview?
		ActiveForm false Update-CodePreviewer
                ;M

:M On_Size:     ( -- )
                0 0 Width Height Move: scnCodePreviewer
                ;M

:M WindowTitle:	( -- zstring )
		z" Forms Code Previewer"
		;M

:M ParentWindow: ( -- )
		GetHandle: MainWindow
		;M

:M Close:       ( -- )
                Close: scnCodePreviewer
                true to no-preview?
                Close: Super
                ;M

;Object

: RefreshCodeWindow	( -- )
 		RefreshFormsList ; IDM_FORM_ADDCODE SetCommand
