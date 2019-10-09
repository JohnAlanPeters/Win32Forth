\ $Id: EdCommand.f,v 1.10 2013/12/09 21:34:02 georgeahubert Exp $

\    File: EdCommand.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Mittwoch, Juni 09 2004 - dbu
\ Updated: Saturday, May 06 2006 - Rod

cr .( Loading Menu Commands...)

needs CommandID.f
needs EdAbout.f
needs AnsLink.f
needs src/tools/SdkHelp.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Some helper words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

MultiFileOpenDialog HtmlFileOpenDialog "Open HTML Files" "HTML Files (*.htm,*.html)|*.htm;*.html|All Files (*.*)|*.*"

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Define the Menu command
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ --------------------------------------------------------------------------
\ File menu
\ --------------------------------------------------------------------------
0 value #new
: NewSourceFile ( -- )
                s" New File " temp$ place #new (.) temp$ +place
                1 +to #new
                NewEditWnd NewFile: ActiveChild
                ; IDM_NEW_SOURCE_FILE SetCommand

: Close         ( -- )
                GetHandle: ActiveChild CloseChild: Frame
                GetActive: Frame 0= if 0 to ActiveChild then Update
                ; IDM_CLOSE SetCommand

: OpenSourceFile ( -- )
                Gethandle: Frame Start: SourceFileOpenDialog c@
                if   #SelectedFiles: SourceFileOpenDialog 0
                     do   i GetFile: SourceFileOpenDialog (OpenSourceFile)
                     loop
                then ; IDM_OPEN_SOURCE_FILE SetCommand

: UpdateFileName ( -- )
                GetFileName: ActiveChild count 2dup
                temp$ place SetFileName: ActiveChild ;

: SaveSourceFile ( -- )
                IsEditWnd?
                if   SaveFile: ActiveChild
                     UpdateFileName Update
                else beep
                then ; IDM_SAVE SetCommand

: SaveSourceFileAs ( -- )
                SaveFileAs: ActiveChild
                UpdateFileName Update
                ; IDM_SAVE_AS SetCommand

: SaveAllSourceFiles ( -- )
                0 0 WM_SAVE SendMessageToAllChildren: Frame
                UpdateFileName Update ; IDM_SAVE_ALL SetCommand

: ReloadSourceFile ( -- )
                ReloadFile: ActiveChild ; IDM_RELOAD SetCommand

: OpenHtmlFile  ( -- )
                Gethandle: Frame Start: HtmlFileOpenDialog c@
                if   #SelectedFiles: HtmlFileOpenDialog 0
                     do   i GetFile: HtmlFileOpenDialog (OpenHtmlFile)
                     loop
                then ; IDM_OPEN_HTML_FILE SetCommand

: OnPrint       ( -- )
                ActiveChild IF Print: CurrentWindow THEN ; IDM_PRINT SetCommand

: PageSetup     ( -- )
                GetHandle: frame  hOwner !
                [ PSD_MARGINS ( PSD_MINMARGINS or ) PSD_INTHOUSANDTHSOFINCHES or ] literal PSDFlags !
                PageSetupDlg drop
                ;  IDM_PAGE_SETUP SetCommand

: ExitApp       ( -- )
                0 0 WM_CLOSE Gethandle: Frame call SendMessage
                0= if 0 call PostQuitMessage drop then ; IDM_EXIT SetCommand

: OpenRecentFile ( File$ -- )
                count 2dup IsHtmlFile?
                if   (OpenHtmlFile)
                else (OpenSourceFile)
                then ; IDM_OPEN_RECENT_FILE SetCommand

: OpenHighlightedFile (  -- )
                IsEditWnd?
                if   OpenHighlightedFile: ActiveChild update
                else beep
                then ; IDM_OPEN_HIGHLIGHTED_FILE SetCommand

\ --------------------------------------------------------------------------
\ Edit menu
\ --------------------------------------------------------------------------

: Undo		( -- )
                Undo: ActiveChild Update ; IDM_UNDO SetCommand

: Redo		( -- )
                Redo: ActiveChild Update ; IDM_REDO SetCommand

: Cut		( -- )
                Cut: ActiveChild Update ; IDM_CUT SetCommand

: Copy		( -- )
                Copy: ActiveChild Update ; IDM_COPY SetCommand

: Paste		( -- )
                Paste: ActiveChild Update ; IDM_PASTE SetCommand

: Delete	( -- )
                Delete: ActiveChild Update ; IDM_DELETE SetCommand

: SelectAll	( -- )
                SelectAll: ActiveChild Update ; IDM_SELECT_ALL SetCommand

: RemoveSel	( -- )
                RemoveSel: ActiveChild Update ; IDM_REMOVE_SELECTION SetCommand

: FindText	( -- )
                FindText: ActiveChild Update ; IDM_FIND_TEXT SetCommand

: SearchNext    ( -- )
                SearchNext: ActiveChild Update ; IDM_FIND_NEXT SetCommand

: SearchPrev    ( -- )
                SearchPrev: ActiveChild Update ; IDM_FIND_PREVIOUS SetCommand

: FindTextInFiles ( -- )

		\ move selected text into find-buf
		IsEditWnd?
		if   SelTextToPad ?dup
		     if   Find-buf place
		     else drop
		     then
		then

		GetHandle: FindInFilesDlg \ if window already open, then set search text
		IF   Find-buf count ID_SEARCHTEXT SetDlgItemText: FindInFilesDlg
		ELSE Frame Start: FindInFilesDlg
		THEN ; IDM_FIND_IN_FILES SetCommand

:noname		( -- )
		GetSelection: FindInWindow  >sifEntry \ selected item number
		IF   dup >sifLine# 1+ swap >sifFile"
		     NewBrowseChild
		     LoadHyperFile: ActiveBrowser \ open the file
			  SetFocus: ActiveBrowser
		     SetBrowseMode: ActiveBrowser
		     Update
		ELSE drop beep
		THEN ; is do-file-search-open

: InsertDate    ( -- )
                InsertDate: ActiveChild Update ; IDM_INSERT_DATE SetCommand

: InsertDate&Time ( -- )
                InsertDate&Time: ActiveChild Update ; IDM_INSERT_DATE&TIME SetCommand

: CommentBlock ( -- )
                CommentBlock: ActiveChild Update ; IDM_COMMENT_BLOCK SetCommand

: UnCommentBlock ( -- )
                UnCommentBlock: ActiveChild Update ; IDM_UNCOMMENT_BLOCK SetCommand

: mcLowercase   ( -- )
                SCI_LOWERCASE KeyCommand: CurrentWindow Update ; IDM_LOWERCASE SetCommand

: mcUppercase   ( -- )
                SCI_UPPERCASE KeyCommand: CurrentWindow Update ; IDM_UPPERCASE SetCommand

: LineCut   ( -- )
                SCI_LINECUT KeyCommand: CurrentWindow Update ; IDM_LINECUT SetCommand

: LineDelete    ( -- )
                SCI_LINEDELETE KeyCommand: CurrentWindow Update ; IDM_LINEDELETE SetCommand

: LineCopy  ( -- )
                SCI_LINECOPY KeyCommand: CurrentWindow Update ; IDM_LINECOPY SetCommand

: LineTranspose ( -- )
                SCI_LINETRANSPOSE KeyCommand: CurrentWindow Update ; IDM_LINETRANSPOSE SetCommand

: LineDuplicate ( -- )
                SCI_LINEDUPLICATE KeyCommand: CurrentWindow Update ; IDM_LINEDUPLICATE SetCommand

\ --------------------------------------------------------------------------
\ DexH menu
\ --------------------------------------------------------------------------
: DexGlossary 	( -- )
                DexGlossary: ActiveChild Update ; IDM_DEX_GLOSSARY SetCommand

: DexParagraph 	( -- )
                DexParagraph: ActiveChild Update ; IDM_DEX_PARAGRAPH SetCommand

: DexCodeParagraph ( -- )
                DexCodeParagraph: ActiveChild Update ; IDM_DEX_CODE_PARAGRAPH SetCommand

: DexStyleBold 	( -- )
                DexStyleBold: ActiveChild Update ; IDM_DEX_STYLE_BOLD SetCommand

: DexStyleItalic ( -- )
                DexStyleItalic: ActiveChild Update ; IDM_DEX_STYLE_ITALIC SetCommand

: DexStyleTypewriter ( -- )
                DexStyleTypewriter: ActiveChild Update ; IDM_DEX_STYLE_TYPEWRITER SetCommand

\ --------------------------------------------------------------------------
\ View menu
\ --------------------------------------------------------------------------
: ViewEOL	( -- )
		ViewEOL? 0= to ViewEOL? Update ; IDM_VIEW_EOL SetCommand

: ViewWhiteSpace ( -- )
		ViewWhiteSpace? 0= to ViewWhiteSpace? Update ; IDM_VIEW_WHITESPACE SetCommand

: ViewLineNumbers ( -- )
		ViewLineNumbers? 0= to ViewLineNumbers? Update ; IDM_VIEW_LINE_NUMBERS SetCommand

: Colorize	( -- )
		Colorize? 0= to Colorize? Update ; IDM_COLORIZE SetCommand

: mcBrowse	( -- )
                ?BrowseMode: ActiveChild 0= SetBrowseMode: ActiveChild Update ; IDM_BROWSE SetCommand

\ --------------------------------------------------------------------------
\ Options menu
\ --------------------------------------------------------------------------
: Eol_CRLF  ( -- )
                SC_EOL_CRLF to EOL Update ; IDM_EOL_CRLF SetCommand

: Eol_CR    ( -- )
                SC_EOL_CR to EOL Update ; IDM_EOL_CR SetCommand

: Eol_LF    ( -- )
                SC_EOL_LF to EOL Update ; IDM_EOL_LF SetCommand

: CreateBAK ( -- )
                CreateBackup? 0= to CreateBackup? Update ; IDM_CREATE_BAK SetCommand

: SaveAllBeforeCompile  ( -- )
                SaveAllBeforeCompile? 0= to SaveAllBeforeCompile? Update ; IDM_SAVE_ALL_BEFORE_COMPILE SetCommand

: StripTrailingSpaces  ( -- )
                StripTrailingWhitespace? 0= to StripTrailingWhitespace? Update ; IDM_REMOVE_TRAILING_WHITE SetCommand

: EnsureFinalNewLine  ( -- )
                FinalNewLine? 0= to FinalNewLine? Update ; IDM_ENSURE_FINAL_LINE_ENDING SetCommand

NewEditDialog SetTabSizeDlg "Tab options"  "&Tab size (1 to 8):"    "Ok"    ""  "&Use Tabs"

: TabOptions    { \ tabsize$ -- }
		maxstring localalloc: tabsize$
		TabSize s>d (d.) tabsize$ place

		UseTabs? SetOptionState: SetTabSizeDlg

		tabsize$ Frame Start: SetTabSizeDlg ?dup
                IF   2 = to UseTabs?
		     tabsize$ count number? >r d>s r>
                     IF to TabSize ELSE drop THEN
                THEN Update ; IDM_TABS SetCommand

\ --------------------------------------------------------------------------
\ Win32Forth menu
\ --------------------------------------------------------------------------
: mcCompile	( -- )
		IsEditWnd?
		if   SaveAllBeforeCompile?
		     if SaveAllSourceFiles then
		     Compile: ActiveChild
		     ActiveChild to ActiveRemote \ make the current child to our active
		                                 \ remote window for debugging
		else beep
		then ; IDM_COMPILE SetCommand

: mcDebug       ( -- )
                debug-buttons ; IDM_DEBUG SetCommand

: Browser       ( -- )
                StartBrowser ; IDM_VOC_BROWSER SetCommand

: mcHandleW32FMsg ( -- )
                HandleW32FMsg? 0= to HandleW32FMsg? ; IDM_HANDLEW32FMSG SetCommand

\ --------------------------------------------------------------------------
\ Window menu
\ --------------------------------------------------------------------------
: TileHorizontal ( -- )
		MDITILE_HORIZONTAL Tile: Frame ; IDM_TILE_HORIZONTAL SetCommand

: TileVertical  ( -- )
		MDITILE_VERTICAL Tile: Frame ; IDM_TILE_VERTICAL SetCommand

: Arrange	( -- )
		Arrange: Frame ; IDM_ARRANGE SetCommand

: Cascade	( -- )
		Cascade: Frame ; IDM_CASCADE SetCommand

: CloseAll	( -- )
		CloseAll: Frame
		GetActive: Frame 0= if 0 to ActiveChild then Update
		; IDM_CLOSE_ALL SetCommand

: ShowToolbar	( -- )
		ShowToolbar? 0= dup to ShowToolbar?
		Show: TheRebar ReSize: Frame Update ; IDM_SHOW_TOOLBAR SetCommand

: ShowStatusbar	( -- )
		ShowStatusbar? 0= dup to ShowStatusbar?
		Show: ScintillaStatusbar ReSize: Frame Update ; IDM_SHOW_STATUSBAR SetCommand

\ --------------------------------------------------------------------------
\ Help menu
\ --------------------------------------------------------------------------

: ANS-Help	( -- )
		SelTextToPad GetAnsLink ?dup
		if   (OpenHtmlFile)
		else drop beep
		then ; IDM_W32F_ANS_HELP SetCommand

: API-help	( -- ) \ show help for the highlighted Win32 API function
		SelTextToPad ?dup
		if   (sdk-help)
		else drop beep
		then ; IDM_API_HELP SetCommand

: W32F-Homepage ( -- )
		s" http://www.win32forth.org/" (OpenHtmlFile) ; IDM_W32F_HOMEPAGE SetCommand

: W32F-Forum    ( -- )
		s" http://groups.yahoo.com/group/win32forth/" (OpenHtmlFile) ; IDM_W32F_FORUM SetCommand

: W32F-Doc  	( -- )
		s" doc\p-index.htm" Prepend<home>\ (OpenHtmlFile) ; IDM_W32F_DOC SetCommand

: ANS-Doc   	( -- )
		s" doc\dpans\dpans.htm" Prepend<home>\ (OpenHtmlFile) ; IDM_ANS_DOC SetCommand

: About     	( -- )
                Frame Start: about-sci-dialog drop
                SetFocus: Frame ; IDM_ABOUT SetCommand

\ --------------------------------------------------------------------------
\ Toolbar
\ --------------------------------------------------------------------------

: tbBack	( -- )
		GoBack: ActiveChild ; IDM_BACK SetCommand

: tbForward	( -- )
		GoForward: ActiveChild ; IDM_FORWARD SetCommand

