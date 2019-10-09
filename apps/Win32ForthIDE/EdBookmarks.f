\ EdBookMarks.f

\ Bookmarking allows setting markers at points anywhere in a source file for quick
\ navigating.
\ Click "Add Bookmark" to save the position of the current line in the current
\ file as a bookmark. To return to a saved bookmark click on the desired mark.
\
\ "Clear BookMarks" does as it says, clears all bookmarks from all open files.

PushButton btnAddBookMark
PushButton btnClearBookMarks

:Object BookMarksWindow   <Super Window

0 value BookMarkList
Listbox BMListBox
ColorObject FrmColor      \ the background color

0 value ThisItem

: UpdateList    ( -- )
                currentname count SetName: ThisItem
                source islinetext: ThisItem
                #linecount islinenumber: ThisItem
                curfilename count isfilename: ThisItem
                markerhandle ismarkerhandle: ThisItem ;

: Addbookmark       ( -- )
                Data@: BookMarkList
                if      AddLink: BookMarkList
                then    New> CodeItem dup Data!: BookMarkList to ThisItem
                updatelist
                linetext: thisitem asciiz addstringto: BMListBox ;

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height FrmColor FillArea: dc
        ;M

:M StartSize:   ( -- width height )
                BookMarksSize
                ;M

:M StartPos:    ( -- x y )
                BookMarksPos
                ;M

:M WindowTitle: ( -- ztitle )
                z" Bookmarks"
                ;M

:M On_Done:    ( -- )
                originx originy 2to BookMarksPos
                Width Height 2to BookMarksSize
                On_Done: Super
                ;M

:m On_Init:	( -- )
		New> Linked-List to BookMarkList

		CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

 		self Start: BMListBox
 		Handle: TabFont SetFont: BMListBox

		self Start: btnAddBookMark
		s" Add Bookmark" SetText: btnAddBookMark
		Handle: TabFont SetFont: btnAddBookMark

		self Start: btnClearBookMarks
		s" Clear Bookmarks" SetText: btnClearBookMarks
		Handle: TabFont SetFont: btnClearBookMarks
		;m

:m on_size:	( -- )
		0 0 100 24 		Move: btnAddBookMark
		102 0 100 24 		Move: btnClearBookMarks
		0 25 width height 25 - 	Move: BMListBox ;m

: -leading	( addr cnt -- addr2 cnt2 ) \ remove leading blanks and tabs
		dup 0
		?do	over i + c@ bl <=
			if	1 /string
			else	leave		\ leave if not bl or tab
			then
		loop	;

: add-bookmark	( -- )
		ActiveChild 0= ?exit
		GetFileType: ActiveChild FT_SOURCE <> ?exit
		GetFileName: ActiveChild count curfilename place
		GetCurrentLine: ActiveChild dup to #linecount
		LineLength: CurrentWindow cell+ malloc >r
		#linecount r@ GetLine: CurrentWindow 2 - 0max r@ swap   ( -- addr len )
		-leading maxstring min 0max 2dup currentname place
		0 #linecount SCI_MARKERADD GetHandle: CurrentWindow call SendMessage to markerhandle
		source 2>r
		(source) 2!
		AddBookMark
		-1 to markerhandle     \ reset it
		2r> (source) 2!
		r> release ;

:M BookMark:	( -- )
		add-bookmark ;M

:M ClearBookMarks:	{ \ this -- }
		Clear: BMListBox
                GetTabCount: OpenFilesTab dup 0>
                if      1+ 0
                        do      TCIF_PARAM IsMask: OpenFilesTab
				i GetTabInfo: OpenFilesTab
                                Lparam: OpenFilesTab to this
                                This
                                if	GetFileType: This FT_SOURCE =
					if      ChildWindow: This GetHandle: [ ] >r
						0 -1 SCI_MARKERDELETEALL r> Call SendMessage drop
					then
				then
                        loop
                else    drop
                then    ;M

:M Close:        ( -- )
		ClearBookMarks: self
                Close: BMListBox
                BookMarkList DisposeList
                Close: super
                ;M

: ShowFile	{ \ item -- }
		FileName: Thisitem (OpenSourceFile)
		markerhandle: Thisitem dup 0<
		if	drop LineNumber: Thisitem
		else	0 swap SCI_MARKERLINEFROMHANDLE GetHandle: CurrentWindow call SendMessage
			dup 0<
			if	drop LineNumber: Thisitem
			then
		then	GotoLine: CurrentWindow
		SetFocus: CurrentWindow
		;

:M WM_COMMAND	( h m w l -- f )
		over LOWORD GetID: BMListBox =
		if	over HIWORD LBN_SELCHANGE =
			if	GetSelection: BMListBox dup LB_ERR <>
				if	1+ >Link#: BookMarkList
					Data@: BookMarkList to ThisItem
					ShowFile
				else	drop
				then
			then
		then	false ;M

;Object

: add-bookmark	( -- )
		BookMark: BookMarksWindow ; IDM_SET_BOOKMARK SetCommand
' add-bookmark SetFunc: btnAddBookMark

: clear-bookmarks ( -- )
		ClearBookMarks: BookMarksWindow ;
' clear-bookmarks SetFunc: btnClearBookMarks

: BookMarker	( -- )
		GetHandle: MainWindow SetParentWindow: BookMarksWindow
		Start: BookMarksWindow ; IDM_BOOKMARKS SetCommand

\s
