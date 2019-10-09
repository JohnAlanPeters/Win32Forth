\ $Id: EdMenu.f,v 1.35 2011/05/25 20:53:09 georgeahubert Exp $

\    File: EdMenu.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, Juli 04 2004  - dbu
\ Updated: Saturday, May 06 2006 - Rod
\
\ Menu support for SciEdit

cr .( Loading Scintilla Menu...)

needs CommandID.f
needs ExUtils.f
needs w_search.f


: Start-Win32Forth   ( -- )    \  Start Win32Forth
          0 0 ExecForth drop ;

MenuBar MainMenu
        Popup "&File"
                MenuItem "&New file\tCtrl+N"			IDM_NEW_SOURCE_FILE	DoCommand ;
                MenuItem "&Open file...\tCtrl+O" 		IDM_OPEN_SOURCE_FILE	DoCommand ;
                :MenuItem mf_close "&Close file" 		IDM_CLOSE		DoCommand ;
                MenuSeparator
                :MenuItem mf_save   "&Save file\tCtrl+S"	IDM_SAVE		DoCommand ;
                :MenuItem mf_saveas "Save file &as..."		IDM_SAVE_AS		DoCommand ;
                :MenuItem mf_saveall "Save all files\tAlt+S"	IDM_SAVE_ALL		DoCommand ;
                MenuSeparator
\                :MenuItem mf_reload "&Revert to last saved version\tCtrl+R"	IDM_RELOAD	DoCommand ;
\                MenuSeparator
                :MenuItem mf_openhl "Open Highlighted File\tCtrl+Shift+O"	IDM_OPEN_HIGHLIGHTED_FILE	DoCommand ;
                MenuSeparator
                MENUITEM  "Open &HTML File..."			IDM_OPEN_HTML_FILE	DoCommand ;
		MENUITEM  "New Html Source File"		IDM_NEW_HTML_SOURCE_FILE DoCommand ;
                MenuSeparator
                :MenuItem mf_print "&Print...\tCtrl+P" 		IDM_PRINT		DoCommand ;
                :MenuItem mf_page_setup "Page Set&up..." 	IDM_PAGE_SETUP          DoCommand ;
                MenuSeparator
                MenuItem "E&xit\tALT+F4"			IDM_EXIT		DoCommand ;
\                MenuSeparator
                8 RECENTFILES RecentFiles             		IDM_OPEN_RECENT_FILE	DoCommand ;

        Popup "&Edit"
                :MenuItem me_undo "&Undo\tCtrl+Z"			IDM_UNDO		DoCommand ;
                :MenuItem me_redo "&Redo\tCtrl+Y"			IDM_REDO		DoCommand ;
                MenuSeparator
                :MenuItem me_cut "&Cut\tCtrl+X"				IDM_CUT			DoCommand ;
                :MenuItem me_copy "C&opy\tCtrl+C"			IDM_COPY		DoCommand ;
                :MenuItem me_paste "&Paste\tCtrl+V"			IDM_PASTE		DoCommand ;
                :MenuItem me_delete "&Delete\tDel" 			IDM_DELETE		DoCommand ;
                MenuSeparator
                :MenuItem me_linecut "&Line cut\tCtrl+L"		IDM_LINECUT		DoCommand ;
                :MenuItem me_linecopy "&Line copy\tCtrl+Shift+T"	IDM_LINECOPY		DoCommand ;
                :MenuItem me_linedelete "&Line delete\tCtrl+Shift+L"	IDM_LINEDELETE		DoCommand ;
                :MenuItem me_linetranspose "&Line transpose\tCtrl+T"	IDM_LINETRANSPOSE	DoCommand ;
                :MenuItem me_lineduplicate "&Line duplicate\tCtrl+D"	IDM_LINEDUPLICATE	DoCommand ;
                MenuSeparator
                :MenuItem me_selectall "&Select all\tCtrl+A"                   IDM_SELECT_ALL       DoCommand ;
                :MenuItem me_removesel "R&emove selection"                     IDM_REMOVE_SELECTION DoCommand ;
                SUBMENU "Selection Type"
                        :MenuItem me_normal "Normal" 	IDM_NORMALSELECTION DoCommand ;
                        :MenuItem me_column "Column" 	IDM_COLUMNSELECTION DoCommand 	;
                        :MenuItem me_line   "Line" 	IDM_LINESELECTION DoCommand	;
                ENDSUBMENU
                MenuSeparator
                :MenuItem me_find "Se&arch...\tCtrl+F"                         IDM_FIND_TEXT        DoCommand ;
                :MenuItem me_findnext "Search &next\tF3"                       IDM_FIND_NEXT        DoCommand ;
                :MenuItem me_findprev "Search &prev\tShift+F3"                 IDM_FIND_PREVIOUS    DoCommand ;
                :MenuItem me_replace "Search and &Replace\tCtrl+R"             IDM_REPLACE_TEXT     DoCommand ;
                MenuSeparator
                :MenuItem me_findinfiles "Find Text in Files...\tCtrl+Shift+F" IDM_FIND_IN_FILES DoCommand ;
                MenuSeparator
                :MenuItem me_date      "&Insert Date\tAlt+D"		IDM_INSERT_DATE		DoCommand ;
                :MenuItem me_date&time "&Insert Date and Time\tAlt+T"	IDM_INSERT_DATE&TIME	DoCommand ;
                MenuSeparator
                :MenuItem me_commentblock "&Block comment\tAlt+C"	IDM_COMMENT_BLOCK	DoCommand ;
                :MenuItem me_uncommentblock "B&lock &uncomment\tAlt+U"	IDM_UNCOMMENT_BLOCK	DoCommand ;
                MenuSeparator
                :MenuItem me_lower "&Lowercase\tCtrl+U"			IDM_LOWERCASE		DoCommand ;
                :MenuItem me_upper "&Uppercase\tCtrl+Shift+U"		IDM_UPPERCASE		DoCommand ;

        Popup "&Project"
                MenuItem "&New project...  \tCtrl+N"               IDM_NEW_PRJ DoCommand ;
                MenuItem "&Close project  "               IDM_CLOSE_PRJ DoCommand ;
                MenuSeparator
                MenuItem "&Open project... \tCtrl+O"              IDM_OPEN_PRJ DoCommand ;
                MenuItem "&Save project\tCtrl+S"                  IDM_SAVE_PRJ DoCommand ;
                MenuItem "Save project &as..."                 IDM_SAVE_AS_PRJ DoCommand ;
                MenuSeparator
                MenuItem "&Rename...\tCtrl+R"                   IDM_RENAME_PRJ DoCommand ;
                MenuSeparator
                MenuItem "&Build   \tCtrl+B"                     IDM_BUILD_PRJ DoCommand ;
                MenuItem "&Rebuild \tCtrl+B"                   IDM_REBUILD_PRJ DoCommand ;
\                 MenuItem "Set build file\tCtrl+B"       IDM_SET_BUILD_FILE_PRJ DoCommand ;
                MenuItem "Set search &path for build..." IDM_SET_BUILD_PATH_PRJ DoCommand ;
                MenuSeparator
                MenuItem "&New Module... \tCtrl+M"          IDM_NEW_MODULE_PRJ DoCommand ;
                MenuSeparator
                MenuItem "&Add files to... \tCtrl+A"           IDM_ADD_PRJ DoCommand ;
                :MenuItem me_addopenfls "Add opened files"	IDM_ADD_OPEN_PRJ DoCommand ;
                MenuItem "&Delete from project \tCtrl+D"            IDM_DELETE_PRJ DoCommand ;
                :MenuItem me_addforms "Add open &forms \tCtrl+F" IDM_ADD_FORMS_PRJ DoCommand ;
\                 MenuSeparator
\                 SubMenu "Copy/&Zip files"
\                     MenuItem "&Zip non-library files..."           IDM_ZIP_PRJ DoCommand ;
\                     MenuItem "Zip all files..."                IDM_ZIP_ALL_PRJ DoCommand ;
\                     MenuItem "&Copy non-library files..."         IDM_COPY_PRJ DoCommand ;
\                     MenuItem "Copy all files..."              IDM_COPY_ALL_PRJ DoCommand ;
\                 EndSubMenu
\                 MenuSeparator
                8 RECENTFILES RecentProjectFiles        IDM_OPEN_RECENT_FILE_PRJ DoCommand ;

	Popup "For&m"
		MenuItem "&New"         IDM_FORM_NEW DoCommand   ;
		MenuItem "&Open"       IDM_FORM_Open DoCommand   ;
		:MenuItem mnu_doform "&Edit properties"       	IDM_FORM_FORMPROPERTY DoCommand   ;

		:MenuItem mnu_close "Close Active &Form" ActiveForm if ActiveForm IDM_FORM_Close DoCommand then ;

		:MenuItem mnu_closeall "&Close All"          	IDM_FORM_CloseAll DoCommand ;
		MenuSeparator
		:MenuItem mnu_save "&Save"       	IDM_FORM_Save  DoCommand ;
		:MenuItem mnu_saveas "Save &As"    	IDM_FORM_SaveAs DoCommand ;
		:MenuItem mnu_saveall "Save a&ll modified"  IDM_FORM_SaveAll DoCommand ;
		MenuSeparator
		:MenuItem mnu_merge "&Merge open forms"  	IDM_FORM_Merge DoCommand ;
		:MenuItem mnu_psheet "Property Form Template" IDM_FORM_PropertyForm DoCommand ;
		MenuSeparator
		:MenuItem mnu_compile "Com&pile"  	IDM_FORM_Write DoCommand ;
		:MenuItem mnu_compileall "Compile All" 	IDM_FORM_WriteAll DoCommand ;
		:MenuItem mnu_copy "Cop&y to Clipboard" IDM_FORM_Copy DoCommand ;
		:MenuItem mnu_test "&Test"     		IDM_FORM_Test DoCommand ;
		MenuSeparator
		MenuItem "Create ToolBar"   		IDM_FORM_CreateToolBar DoCommand ;
		MenuItem "Splitter Window Templates" 	IDM_FORM_Splitter DoCommand ;
		MenuItem "Define Menu" 			IDM_FORM_CreateMenu DoCommand ;
                MenuItem "MessageBox Builder" IDM_MSGBOX_BUILDER DoCommand ;
		8 RECENTFILES RecentFormFiles 		count IDM_FORM_(Open) DoCommand ;


        Popup "&DexH"
                :MenuItem me_dexGlossary      "&Glossary\tAlt+G"	    IDM_DEX_GLOSSARY	   DoCommand ;
                :MenuItem me_dexParagraph     "&Paragraph\tAlt+P"	    IDM_DEX_PARAGRAPH	   DoCommand ;
                :MenuItem me_dexCodeParagraph "&Code paragraph\tCtrl+Alt+C" IDM_DEX_CODE_PARAGRAPH DoCommand ;
                MenuSeparator
                :MenuItem me_dexStyleBold       "&Bold\tAlt+B"	           IDM_DEX_STYLE_BOLD	    DoCommand ;
                :MenuItem me_dexStyleItalic     "&Italic\tAlt+I"	   IDM_DEX_STYLE_ITALIC	    DoCommand ;
                :MenuItem me_dexStyleTypewriter "&Typewriter\tCtrl+Alt+T"  IDM_DEX_STYLE_TYPEWRITER DoCommand ;

        Popup "&View"
                :MenuItem mp_vieweol "Display &Line endings"	IDM_VIEW_EOL		DoCommand ;
                :MenuItem mp_viewws "Display &White space"	IDM_VIEW_WHITESPACE	DoCommand ;
                :MenuItem mp_viewln "Display Line &numbers"	IDM_VIEW_LINE_NUMBERS	DoCommand ;
                MenuSeparator
                :MenuItem mp_colorize "&Colorize source"	IDM_COLORIZE		DoCommand ;
                MenuSeparator
                :MenuItem mp_browse "&Browse\tF7"		IDM_BROWSE		DoCommand ;
		:MenuItem mp_viewhtml "&PreView As HTML\tF10"            IDM_HTML_PREVIEW	DoCommand ;

        Popup "&Options"
                SUBMENU "&Line endings"
                        :MenuItem mf_windows "&Windows (CR\LF)" IDM_EOL_CRLF		DoCommand ;
                        :MenuItem mf_unix "&Unix (LF)" 		IDM_EOL_LF		DoCommand ;
                        :MenuItem mf_mac "&Mac (CR)" 		IDM_EOL_CR		DoCommand ;
                ENDSUBMENU
                MenuSeparator
                :MenuItem mp_backup "&Create Backup File (*.BAK)"	IDM_CREATE_BAK	DoCommand ;
                MenuSeparator
                :MenuItem mp_rtwh "&Remove trailing white space"	IDM_REMOVE_TRAILING_WHITE	DoCommand ;
                :MenuItem mp_efle "&Ensure final line ending"		IDM_ENSURE_FINAL_LINE_ENDING    DoCommand ;
                MenuSeparator
                :MenuItem mp_sabcompile "&Save all files before Compile" IDM_SAVE_ALL_BEFORE_COMPILE	DoCommand ;
                :MenuItem mp_compileproject "&Always compile main Project file"	IDM_COMPILE_PROJECT	DoCommand ;
                MenuSeparator
                :MenuItem mp_tabs "&Set Tab options..."		IDM_TABS	DoCommand ;
                 MenuItem         "IDE &Preferences"     IDM_PREFERENCES DoCommand ;
                MenuSeparator
                 MenuItem         "Save Defaults now" IDM_SAVEDEFAULTS DoCommand ;
                 MenuItem         "Save Default Session" IDM_SAVEDEFAULT_SESSION DoCommand ;
                 MenuItem         "Reload Default Session" IDM_LOADDEFAULT_SESSION DoCommand ;
                MenuSeparator
                MenuItem	  "Load Session" IDM_FORM_LoadSession DoCommand ;
                MenuItem	  "Save Session" IDM_FORM_SaveSession DoCommand ;
                MenuSeparator
                :MenuItem mp_showsb "&Show Statusbar"		IDM_SHOW_STATUSBAR	DoCommand ;
                :MenuItem mp_showtb "&Show Toolbar"		IDM_SHOW_TOOLBAR	DoCommand ;
\                 :MenuItem mp_customizetb "&Customize toolbar" Customize: ControlToolbar ;

        Popup "&Tools"
                 MenuItem "&Win32Forth" Start-Win32Forth ;
                MenuSeparator
                :MenuItem mp_compileLine "Compile current line\tF8" IDM_COMPILE_LINE DoCommand ;
                :MenuItem mp_compileSel "Compile selected &text\tF9" 		IDM_COMPILE_SELECTION DoCommand ;
                :MenuItem mp_compile "&Compile\tF12"		IDM_COMPILE		DoCommand ;
                MenuSeparator
                MenuItem "BookMarks" 		IDM_BOOKMARKS DoCommand ;
\                MenuSeparator
\                :MenuItem mp_setbp "&Set breakpoint...\tCTRL+B"		IDM_SET_BREAK_POINT		DoCommand ;
\                :MenuItem mp_debug "&Debug...\tF11"		IDM_DEBUG		DoCommand ;

        POPUP "&Window"
                :MenuItem mf_tile_hor "Tile &horizontally"	IDM_TILE_HORIZONTAL	DoCommand ;
                :MenuItem mf_tile_ver "Tile &vertically"	IDM_TILE_VERTICAL	DoCommand ;
                :MenuItem mf_arrange "&Arrange"			IDM_ARRANGE		DoCommand ;
                :MenuItem mf_cascade "Ca&scade"			IDM_CASCADE		DoCommand ;
                MenuSeparator
                :MenuItem mf_split_hor "Dual View Horizontal" IDM_SPLIT_HORIZONTAL DoCommand ;
                :MenuItem mf_split_ver "Dual View Vertical" IDM_SPLIT_VERTICAL DoCommand ;
                :MenuItem mf_split_none "Single View" IDM_NO_SPLIT_WINDOW DoCommand ;
                MenuSeparator
                :MenuItem mf_close_all "&Close all"		IDM_CLOSE_ALL		DoCommand ;

        Popup "&Help"
                MENUITEM    "Win32Forth &Documentation\tF1"	   IDM_W32F_DOC		DoCommand ;
                MENUITEM    "Get help for selected word \tCtrl+F1" IDM_WORDHELP		DoCommand ;
                MenuSeparator
                MENUITEM "&About..."				IDM_ABOUT		DoCommand ;
EndBar

8 constant WINDOW-MENU

: GetFileType	( -- n )
		ActiveChild
		if   GetFileType: ActiveChild
		else -1
		then ;

: IsEditWnd?	( -- f )
		GetFileType FT_SOURCE = ;

: IsHtmlWnd?	( -- f )
		GetFileType FT_HTML = ;

: IsBinaryWnd?	( -- f )
		GetFileType FT_BINARY = ;

: IsBitmapWnd?	( -- f )
		GetFileType FT_BITMAP = ;

: NoTextToPad   ( -- addr len ) \ copy empty string to PAD
                0 pad ! pad count ;

: SelTextToPad  ( -- addr len ) \ copy the selected text into PAD
                \ default no Text
                ActiveChild 0<>
                0 GetSelText: ActiveChild MAXSTRING CHARS < and \ check size of selected text
                if   pad GetSelText: ActiveChild
                     if   pad zcount BL skip -trailing 10 -TRAILCHARS 13 -TRAILCHARS
                     else NoTextToPad
                     then
                else NoTextToPad
                then ;

: EnableEdit	( f -- )
                \ File menu
                dup Enable: mf_save
                dup Enable: mf_saveas
\               dup Enable: mf_reload
                dup Enable: mf_openhl
                dup Enable: mf_print
                dup Enable: mf_page_setup

                \ Edit menu
                dup Enable: me_undo
                dup Enable: me_redo
                dup Enable: me_cut
                dup Enable: me_copy
                dup Enable: me_paste
                dup Enable: me_delete
                dup Enable: me_selectall
                dup Enable: me_removesel
                dup Enable: me_find
                dup Enable: me_findnext
                dup Enable: me_findprev
\                dup Enable: me_replace
                dup Enable: me_date
                dup Enable: me_date&time
                dup Enable: me_commentblock
                dup Enable: me_uncommentblock
                dup Enable: me_lower
                dup Enable: me_upper
                dup Enable: me_linecut
                dup Enable: me_linedelete
                dup Enable: me_linecopy
                dup Enable: me_linetranspose
                dup Enable: me_lineduplicate
                dup Enable: me_normal
                dup Enable: me_column
                dup Enable: me_line

                \ DexH menu
                dup Enable: me_dexGlossary
                dup Enable: me_dexParagraph
                dup Enable: me_dexCodeParagraph
                dup Enable: me_dexStyleBold
                dup Enable: me_dexStyleItalic
                dup Enable: me_dexStyleTypewriter

                \ View menu
                dup Enable: mp_vieweol
                dup Enable: mp_viewws
                dup Enable: mp_viewln
                dup Enable: mp_colorize
                dup Enable: mp_browse
                dup Enable: mp_viewhtml

                \ Options menu
                dup Enable: mf_windows
                dup Enable: mf_unix
                dup Enable: mf_mac
                dup Enable: mp_backup
                dup Enable: mp_sabcompile
                dup Enable: mp_tabs
                dup Enable: mp_rtwh
                dup Enable: mp_efle

                \ Win32Forth menu
\                 dup Enable: mp_setbp
\                 dup Enable: mp_debug
                dup Enable: mp_compileSel
                dup Enable: mp_compileLine

                dup Enable: mf_split_hor
                dup Enable: mf_split_ver
                dup Enable: mf_split_none

                drop ;

: ?EnableFormBarItems  ( flag -- )
	    TheFormBar 0= ?exit
	    GetHandle: TheFormBar 0= ?exit
            dup IDM_FORM_SAVE           EnableButton: TheFormBar
            dup IDM_FORM_COPY           EnableButton: TheFormBar
            dup IDM_FORM_WRITE          EnableButton: TheFormBar
            dup IDM_FORM_TEST           EnableButton: TheFormBar
            dup IDM_FORM_EDITOR         EnableButton: TheFormBar
            dup IDM_FORM_SAVEALL        EnableButton: TheFormBar
            dup IDM_FORM_MOVETOBACK   	EnableButton: TheFormBar
            dup IDM_FORM_MOVETOFRONT  	EnableButton: TheFormBar
            dup IDM_FORM_DELETE 	EnableButton: TheFormBar
            dup IDM_FORM_TABORDER    	EnableButton: TheFormBar
            dup IDM_FORM_SELECT         EnableButton: TheFormBar
            dup IDM_FORM_BITMAP         EnableButton: TheFormBar
            dup IDM_FORM_LABEL          EnableButton: TheFormBar
            dup IDM_FORM_TEXTBOX        EnableButton: TheFormBar
            dup IDM_FORM_GROUPBOX       EnableButton: TheFormBar
            dup IDM_FORM_PUSHBUTTON     EnableButton: TheFormBar
            dup IDM_FORM_CHECKBOX       EnableButton: TheFormBar
            dup IDM_FORM_RADIOBUTTON    EnableButton: TheFormBar
            dup IDM_FORM_COMBOBOX       EnableButton: TheFormBar
            dup IDM_FORM_LISTBOX        EnableButton: TheFormBar
            dup IDM_FORM_HORIZSCROLL    EnableButton: TheFormBar
            dup IDM_FORM_VERTSCROLL     EnableButton: TheFormBar
            dup IDM_FORM_GENERIC        EnableButton: TheFormBar
            dup IDM_FORM_FILEWINDOW     EnableButton: TheFormBar
                IDM_FORM_TABCONTROL     EnableButton: TheFormBar ;

: ?EnableFormMenuItems ( -- )
                FormList
                if      Data@: FormList
                        if      #Links: FormList
                        else    0
                        then
                else    0
                then    dup>r
            dup Enable: mnu_doform
            dup Enable: mnu_close
            dup Enable: mnu_closeall
            dup Enable: mnu_save
            dup Enable: mnu_saveas
            dup Enable: mnu_saveall
            dup Enable: mnu_compile
            dup Enable: mnu_compileall
            dup Enable: mnu_copy
            dup Enable: mnu_test
            dup Enable: me_addforms	\ project manager
               ?EnableFormBarItems
            r> 2 < not
               \  Enable: mnu_psheet
                 Enable: mnu_merge ;

: ?EnableDebugWindow    ( -- )
                ActiveRemote dup ActiveChild = swap 0<> and
                GetHandle: frmDebugDlg Call EnableWindow drop ;

: EnableMenuBar	( -- )  \ enable/disable the menu items
                IsEditWnd? dup EnableEdit

                if      \ File menu
 			?Modified:     ActiveChild 0<> ?BrowseMode: ActiveChild not and Enable: mf_save
 			?BrowseMode:   ActiveChild not Enable: mf_saveas
			?Selection:    ActiveChild Enable: mf_openhl
                        GetTextLength: ActiveChild Enable: mf_print

 			\ Edit menu
 			CanUndo:       ActiveChild Enable: me_undo
 			CanRedo:       ActiveChild Enable: me_redo
 			?Selection:    ActiveChild Enable: me_cut
 			?Selection:    ActiveChild Enable: me_copy
 			CanPaste:      ActiveChild Enable: me_paste
 			?Selection:    ActiveChild Enable: me_delete
 			GetTextLength: ActiveChild Enable: me_selectall
 			?Selection:    ActiveChild Enable: me_removesel
 			GetTextLength: ActiveChild Enable: me_find
 			?Find:         ActiveChild Enable: me_findnext
 	                ?Find:         ActiveChild Enable: me_findprev
\ 	                GetTextLength: ActiveChild Enable: me_replace
			?BrowseMode:   ActiveChild not Enable: me_date
			?BrowseMode:   ActiveChild not Enable: me_date&time
 			?Selection:    ActiveChild Enable: me_commentblock
 			?Selection:    ActiveChild Enable: me_uncommentblock
 			?Selection:    ActiveChild Enable: me_lower
 			?Selection:    ActiveChild Enable: me_upper
 			GetTextLength: ActiveChild Enable: me_linecut
 			GetTextLength: ActiveChild Enable: me_linedelete
 			GetTextLength: ActiveChild Enable: me_linecopy
 			GetTextLength: ActiveChild Enable: me_linetranspose
 			GetTextLength: ActiveChild Enable: me_lineduplicate
 			SelectionMode SC_SEL_STREAM    = Check: me_normal
 			SelectionMode SC_SEL_RECTANGLE = Check: me_column
 			SelectionMode SC_SEL_LINES     = Check: me_line


 			\ DexH menu
 			?Selection:    ActiveChild Enable: me_dexGlossary
 			?Selection:    ActiveChild Enable: me_dexParagraph
 			?Selection:    ActiveChild Enable: me_dexCodeParagraph
 			?Selection:    ActiveChild Enable: me_dexStyleBold
 			?Selection:    ActiveChild Enable: me_dexStyleItalic
 			?Selection:    ActiveChild Enable: me_dexStyleTypewriter

 			\ View menu
 			ViewEOL?         Check: mp_vieweol
 			ViewWhiteSpace?	 Check: mp_viewws
			ViewLineNumbers? Check: mp_viewln
			Colorize?	 Check: mp_colorize
 			?BrowseMode: ActiveChild Check: mp_browse

			\ Options menu
 			EOL SC_EOL_CRLF = 	 Check: mf_windows
 			EOL SC_EOL_LF   = 	 Check: mf_unix
 			EOL SC_EOL_CR   = 	 Check: mf_mac
 			CreateBackup?   	 Check: mp_backup
 			SaveAllBeforeCompile?    Check: mp_sabcompile
            StripTrailingWhitespace? Check: mp_rtwh
            FinalNewLine?            Check: mp_efle

 			\ Win32Forth menu
   \         ActiveRemote ActiveChild = Enable: mp_debug
   \         ActiveRemote ActiveChild = Enable: mp_setbp
			?Selection:     ActiveChild Enable: mp_compileSel
			GetCurrentLineLength: ActiveChild 2 - 0> Enable: mp_compileLine

		then

                ShowToolbar?    Check:  mp_showtb
                ShowStatusbar?  Check:  mp_showsb
\                ShowToolbar?    Enable: mp_customizetb
                CompileProject? Check:  mp_compileproject
                Compile?        Enable: mp_compile
\                true            Enable: mp_reset

		ActiveChild 0<> dup Enable: mf_saveall
				dup Enable: mf_close
		                dup Enable: mf_close_all
		                dup Enable: mf_tile_hor
		                dup Enable: mf_tile_ver
		                dup Enable: mf_arrange
		                dup Enable: mf_cascade
		                    Enable: me_addopenfls
		?EnableFormMenuItems
		0 ;

