\ EdReplace.f

needs EdReplace.frm
needs EdPrompt.frm
needs SearchPrompt.frm
needs sub_dirs.f

string: findbuf findbuf off
string: replacebuf replacebuf off
string: specsbuf s" *.f" specsbuf place
string: pathbuf pathbuf off
0 value case?
0 value wholeword?
0 value prompt?
0 value direction
0 value scope
0 value replacecount
0 value savedpos
true value active?
false value opened?
false value folder?
false value subdirs?
false value cancelled?
ReadFile TempFile

: SearchForText	( -- f )
		findbuf count SearchInTarget: CurrentWindow -1 <> ;

: SavePosition	( -- )
                IsEditWnd? 0= ?exit
		GetCurrentPos: CurrentWindow to savedpos ;

: RestorePosition ( -- )
		savedpos GotoPos: CurrentWindow ;

: setflags	( -- )
		0	\ default
		case?		if	SCFIND_MATCHCASE +	then
		wholeword?	if	SCFIND_WHOLEWORD +	then
		SetSearchFlags: CurrentWindow ;

: SetScope	( -- )  \ global or from cuurent position
		scope
		if	GetCurrentPos: CurrentWindow
		else	0
		then	GetTextLength: CurrentWindow	( -- start end )
		\ forward or backward search?
		direction
		if	scope 0=	\ if global just swap parameters
			if	swap
			else	2drop GetCurrentPos: CurrentWindow 0
			then
		then	SetTargetEnd: CurrentWindow SetTargetStart: CurrentWindow ;

: SetTargetRange	( -- ) \ what to search
		direction
		if	GetTargetStart: CurrentWindow 0		\ backwards
		else	GetTargetEnd: CurrentWindow GetTextLength: CurrentWindow
		then	SetTargetEnd: CurrentWindow SetTargetStart: CurrentWindow ;

: ReplaceFoundText	( -- )
		replacebuf count ReplaceTarget: CurrentWindow
		SetTargetRange
		1 +to replacecount ;

: ReplaceAllText	( -- )
		begin	ReplaceFoundText
			SearchForText 0=
		until	folder? ?exit
		update ;

: ShowCount	( -- )
		opened? folder? or ?exit   \ no stopping if multiple files
		join$(  s" Text was found and replaced "
                        replacecount (.)
                        s"  time(s)."
		)join$  true swap count ?MessageBox
		RestorePosition ;

:Object frmConfirmPrompt	<Super frmPrompt

:  ?MoreText	( -- )
		SearchForText 0=
		if	Close: self
		else	GetTargetStart: CurrentWindow GetTargetEnd: CurrentWindow
			SetSel: CurrentWindow	\ highlight found text
		then	;

: command-func	( id obj -- )
		drop
		case	GetID: btnYes		of	ReplaceFoundText update
							?MoreText			endof
			GetID: btnNo		of	SetTargetRange ?MoreText	endof
			GetID: btnYesToAll	of	ReplaceAllText opened?          \ disable further
                                                        if      false to prompt?        \ prompting
                                                        then    Close: self
							ShowCount			endof
			GetID: btnCancel	of	Close: self true to cancelled?	endof
		endcase	;

:M On_Init:	( -- )
		On_Init: Super

		['] command-func SetCommand: self

		\ give a little reminder
		join$(  findbuf count
                        s"  --> "
                        replacebuf count
		)join$  count SetText: lblReplaceString

		;M

;Object

:Object frmFoundFiles	<Super frmSearching

:M On_Command:  { ncode id -- f }
                id
		case	IDCANCEL		of	true to search-aborted?		endof
                        GetId: lstFoundFiles    of      ncode LBN_DBLCLK =
                                                        if     	GetSelectedString: lstFoundFiles
                                                                OpenSource
                                                        then                            endof
		endcase	;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: self
        0 ;M

;Object

: StringNotFound	( -- )
                opened? folder? or ?exit   \ if searching multiple files don't want to know
		join$(  s" Text '"
                        findbuf count
                        s"  ' not found!"
		)join$  true swap count ?MessageBox ;

: ReplaceText	( -- )
		SetFlags
		SetScope
		SearchForText
		if	prompt?
			if	GetTargetStart: CurrentWindow GetTargetEnd: CurrentWindow
				SetSel: CurrentWindow	\ highlight found text
				GetHandle: MainWindow SetParentWindow: frmConfirmPrompt
				Start: frmConfirmPrompt
			else	ReplaceAllText
				ShowCount
			then
		else	StringNotFound
		then	;

: ReplaceInOpenFiles      ( -- )
                false to cancelled?
                ActiveChild >r
                CurrentWindow >r
                scope >r 0 to scope             \ always global
                direction >r 0 to direction     \ and in forward direction
                TabFile? 0
                do      i GetFileTabChild dup to ActiveChild
                        if      GetFileType: ActiveChild FT_SOURCE =
                                if      ?BrowseMode: ActiveChild 0=
                                        if      ChildWindow: ActiveChild to CurrentWindow
                                                ActiveChild OnSelect
                                                ReplaceText
                                                cancelled? ?leave
                                         then
                                then
                        then
                loop   r> to direction r> to scope r> to CurrentWindow r> to ActiveChild
                ActiveChild OnSelect    \ as we were
                ;

: SaveModifiedFile      ( -- )
                name-buf count pad place
                s" .bak" pad +place
                pad count delete-file drop              \ delete any previous backup
                GetName: TempFile count pad count rename-file drop   \ create backup
                ReleaseBuffer: TempFile
                GetTextLength: CurrentWindow 1+ AllocBuffer: TempFile
                GetBuffer: TempFile GetText: CurrentWindow
                GetLength: TempFile 1- SetLength: TempFile

                \ save the text to the file
                SaveFile: TempFile
                ReleaseBuffer: TempFile  ;

: SearchFoundFile       ( -- )     \ full path name to file in name-buf (from sub_dirs.f)
                WINPAUSE
                name-buf count LoadFile: TempFile 0= ?exit
                CurrentWindow >r
                New> ScintillaControl to CurrentWindow
                frmFoundFiles Start: CurrentWindow
                GetBuffer: TempFile over + off SetText: CurrentWindow
                ReleaseBuffer: TempFile
                SetSavePoint: CurrentWindow     \ mark as unmodified
                ReplaceText             \ search and replace if found
                GetModify: CurrentWindow
                if      name-buf count asciiz AddStringto: lstFoundFiles      \ show files that had text replaced
                        SaveModifiedFile
                then    Close: CurrentWindow
                CurrentWindow Dispose
                r> to CurrentWindow ;


: SetStrings    ( -- )
		findbuf count SetText: lblSearchString
                join$(  s" Replaced with '"
                        replacebuf count
                        s" ' in"
                )join$  count SetText: lblReplaced ;

: ReplaceInFolder       ( -- )
                specsbuf c@ 0= ?exit
                pathbuf c@ 0= ?exit
                scope >r 0 to scope
                direction >r 0 to direction
                prompt? >r 0 to prompt?
                ['] SearchFoundFile is process-1file
                false to open-file?

		GetHandle: MainWindow SetParentWindow: frmFoundFiles
		Start: frmFoundFiles
		SetStrings

                pathbuf count specsbuf count subdirs? sdir      \ do the search & replace
                r> to prompt?
                r> to direction
                r> to scope
                search-aborted? 0=
                if      s" Done" SetText: btnCancel
                        begin   WINPAUSE search-aborted?
                        until
                then    Close: frmFoundFiles ;

: DoSearch&Replace      ( -- )
                GetSelectedString: cmbSearch findbuf place
                GetSelectedString: cmbReplace replacebuf place
		findbuf c@ 0= ?exit	\ nothing to find
                active?
                if      ReplaceText exit
                then    opened?
                if      ReplaceInOpenFiles exit
                then    ReplaceInFolder ;

\ The need to check for the return key to save the text seems not to be necessary
\ in the dialog. Pressing return automatically selects the OK button thereby
\ losing the focus in the combobox. Don't know if the behaviour is right but
\ it works!

\ : SrchWmChar    ( h m w l obj -- res )
\                 2 pick VK_RETURN  =
\                 if      >r GetText: [ r@ ]  ?dup  \ get adr,len of edit control text
\                         if      InsertString: cmbSearch
\                         else    drop
\                         then    setfocus: [ r> ] false           \ we already processed this message
\                 else    drop            \ discard object
\                         true            \ and use default processing
\                 then    ;

: SrchWmKillFocus  ( h m w l obj -- res ) \ save text when control loses focus
                GetText: [  ]  ?dup  \ get adr,len of edit control text
                if      InsertString: cmbSearch
                else    drop
                then    true  ;         \ we must still use default processing

\ : RplWmChar     ( h m w l obj -- res )
\                 2 pick VK_RETURN  =
\                 if      >r GetText: [ r@ ]  ?dup  \ get adr,len of edit control text
\                         if      InsertString: cmbReplace
\                         else    drop
\                         then    setfocus: [ r> ] false           \ we already processed this message
\                 else    drop            \ discard object
\                         true            \ and use default processing
\                 then    ;

: RplWmKillFocus      ( h m w l obj -- res )   \ save text when control loses focus
                GetText: [  ]  ?dup  \ get adr,len of edit control text
                if      InsertString: cmbReplace
                else    drop
                then    true  ;         \ we must still use default processing

:Object frmSearch&Replace	<Super frmReplace

:M WindowStyle: ( -- style )    \ no closing of window by means of close button
                WS_CAPTION ;M

: SaveParameters ( -- )
		IsButtonChecked?: chkCase to case?
		IsButtonChecked?: chkWholeWord to wholeword?
		IsButtonChecked?: chkPrompt to prompt?
		IsButtonChecked?: radForward 0= to direction
		IsButtonChecked?: radGlobal 0= to scope
		IsButtonChecked?: radActiveFile to active?
		IsButtonChecked?: radOpenFiles to opened?
		IsButtonChecked?: radFolder to folder?
		IsButtonChecked?: chkSubdirs to subdirs?
		GetText: txtFilespecs specsbuf place
		GetText: txtSearchPath pathbuf place ;

: GetFolder      ( -- )
                 z" Select a drive or folder"
                 \ use a copy of path because if cancelled path info is changed to null
                 pathbuf count pad place
                 pad hwnd BrowseForFolder
                 if       pad count 2dup pathbuf place SetText: txtSearchPath
                 then     ;

: ?TextSelected	{ \ SelBuf$ -- }
                IsEditWnd? 0= ?exit
                \ replace findbuf contents if text is selected
                0 GetSelText: CurrentWindow LocalAlloc: SelBuf$
                SelBuf$ GetSelText: CurrentWindow
                if   SelBuf$ zcount BL skip -trailing 10 -TRAILCHARS 13 -TRAILCHARS
                     ?dup
                     if 	maxstring min InsertString: cmbSearch
                     else 	drop
                     then
                then	;

: ValidateOptions  ( -- )
                TabFile? dup Enable: radActiveFile
                         dup Enable: radOpenFiles
                0=
                if      false to active?
                        false to opened?
                        true to folder?
                else    IsEditWnd? 0=
                        if      false to active?
                                false Enable: radActiveFile
                                true to folder?
                        else    ?BrowseMode: ActiveChild
                                if      false to active?
                                        false Enable: radActiveFile
                                        true to folder?
                                then
                        then
                then    ;


: InitializeOptions ( -- )
		case?           Check: chkCase
		prompt?	        Check: chkPrompt
		wholeword?      Check: chkWholeWord

		direction 0=    Check: radForward
		direction       Check: radBackward

		scope 0=        Check: radGlobal
		scope           Check: radCurrent

		ValidateOptions

		active?         Check: radActiveFile
		opened?         Check: radOpenFiles
		folder?         Check: radFolder
		subdirs?        Check: chkSubdirs
		folder?     dup Enable: chkSubdirs
			    dup Enable: txtFilespecs
			    dup Enable: txtSearchPath
			        Enable: btnBrowse

		?TextSelected

		specsbuf count SetText: txtFilespecs
		pathbuf count SetText: txtSearchpath

		0 to replacecount

		SavePosition ;

:M Display:     ( -- ) \ unhide
                InitializeOptions
                SW_SHOWNORMAL Show: self
                0 ParentWindow: self Call EnableWindow drop \ disable parent
                ;M

:M Hide:        ( -- )
                SW_HIDE Show: self
                1 ParentWindow: self Call EnableWindow drop     \ re-enable parent
                ParentWindow: self Call SetFocus drop ;M

: command-func	( id obj -- )
		drop
		case	IDOK		        of	SaveParameters
                                                        Hide: self
                                                        DoSearch&Replace        endof
			IDCANCEL	        of	Hide: Self	        endof
			GetID: btnBrowse        of      GetFolder               endof
			IsButtonChecked?: radActiveFile IsButtonChecked?: radOpenFiles or 0=
			dup Enable: chkSubdirs
			dup Enable: txtFilespecs
			dup Enable: txtSearchPath
			    Enable: btnBrowse
		endcase	;

:M ON_INIT:	( -- )
		IDOK SetID: btnOK
		IDCANCEL SetID: btnCancel

		On_Init: Super

		['] command-func SetCommand: self

	\	['] SrchWmChar SetWmChar: cmbSearch
		['] SrchWmKillFocus SetWmKillFocus: cmbSearch
 	\	['] RplWmChar SetWmChar: cmbReplace
 		['] RplWmKillFocus SetWmKillFocus: cmbReplace

		;m

;Object

: Search&Replace	( -- )
                GetHandle: frmSearch&Replace 0=
                if      GetHandle: MainWindow SetParentWindow: frmSearch&Replace
                        Start: frmSearch&Replace        \ started but hidden
                then    Display: frmSearch&Replace ; IDM_REPLACE_TEXT SetCommand


\s


