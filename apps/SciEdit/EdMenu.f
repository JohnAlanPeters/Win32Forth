\ $Id: EdMenu.f,v 1.10 2006/06/07 10:30:15 jos_ven Exp $

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
needs AnsLink.f
needs src/tools/SdkHelp.f

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
                :MenuItem me_selectall "&Select all\tCtrl+A"		IDM_SELECT_ALL		DoCommand ;
                :MenuItem me_removesel "R&emove selection" 		IDM_REMOVE_SELECTION	DoCommand ;
                MenuSeparator
                :MenuItem me_find "Se&arch...\tCtrl+F"			IDM_FIND_TEXT		DoCommand ;
                :MenuItem me_findnext "Search &next\tF3"		IDM_FIND_NEXT		DoCommand ;
\               :MenuItem me_findprev "Search &prev\tShift+F3"		IDM_FIND_PREVIOUS	DoCommand ;
                MenuSeparator
                :MenuItem me_findinfiles "Find Text in Files...\tCtrl+Shift+F"	IDM_FIND_IN_FILES	DoCommand ;
                MenuSeparator
                :MenuItem me_date      "&Insert Date\tAlt+D"		IDM_INSERT_DATE		DoCommand ;
                :MenuItem me_date&time "&Insert Date and Time\tAlt+T"	IDM_INSERT_DATE&TIME	DoCommand ;
                MenuSeparator
                :MenuItem me_commentblock "&Block comment\tAlt+C"	IDM_COMMENT_BLOCK	DoCommand ;
                :MenuItem me_uncommentblock "B&lock &uncomment\tAlt+U"	IDM_UNCOMMENT_BLOCK	DoCommand ;
                MenuSeparator
                :MenuItem me_lower "&Lowercase\tCtrl+U"			IDM_LOWERCASE		DoCommand ;
                :MenuItem me_upper "&Uppercase\tCtrl+Shift+U"		IDM_UPPERCASE		DoCommand ;

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
                :MenuItem mp_sabcompile "&Save all files before Compile"	IDM_SAVE_ALL_BEFORE_COMPILE	DoCommand ;
                MenuSeparator
                :MenuItem mp_tabs "&Set Tab options..."		IDM_TABS	DoCommand ;
                MenuSeparator
                :MenuItem mp_showsb "&Show Statusbar"		IDM_SHOW_STATUSBAR	DoCommand ;
                :MenuItem mp_showtb "&Show Toolbar"		IDM_SHOW_TOOLBAR	DoCommand ;
                :MenuItem mp_customizetb "&Customize toolbar" Customize: ControlToolbar ;

        Popup "&Win32Forth"
                :MenuItem mp_compile "&Compile\tF12"		IDM_COMPILE		DoCommand ;
                :MenuItem mp_debug "&Debug...\tF11"		IDM_DEBUG		DoCommand ;
                :MenuItem mp_HandleW32FMsg "&Handle debug messages?"     IDM_HANDLEW32FMSG		DoCommand ;
                MenuSeparator
                :MenuItem mp_browser "Class and &Vocabulary browser..."	IDM_VOC_BROWSER	DoCommand ;

        POPUP "W&indow"
                :MenuItem mf_tile_hor "Tile &horizontally"	IDM_TILE_HORIZONTAL	DoCommand ;
                :MenuItem mf_tile_ver "Tile &vertically"	IDM_TILE_VERTICAL	DoCommand ;
                :MenuItem mf_arrange "&Arrange"			IDM_ARRANGE		DoCommand ;
                :MenuItem mf_cascade "Ca&scade"			IDM_CASCADE		DoCommand ;
                MenuSeparator
                :MenuItem mf_close_all "&Close all"		IDM_CLOSE_ALL		DoCommand ;

        Popup "&Help"
                :MenuItem mp_anshelp  "Help for highlighted ANS-Word\tCtrl+F1"	IDM_W32F_ANS_HELP	DoCommand ;
                :MenuItem mp_apihelp  "Help for highlighted Win32-API function\tShift+F1" IDM_API_HELP      DoCommand ;
                MenuSeparator
                MENUITEM    "Win32Forth &Documentation\tF1"	IDM_W32F_DOC		DoCommand ;
                MENUITEM    "ANS Forth &Standard\tAlt+F1"	IDM_ANS_DOC		DoCommand ;
                MenuSeparator
                MENUITEM "Win32Forth &Project Group"		IDM_W32F_HOMEPAGE	DoCommand ;
                MENUITEM "Win32Forth &Forum"			IDM_W32F_FORUM		DoCommand ;
                MenuSeparator
                MENUITEM "&About..."				IDM_ABOUT		DoCommand ;
EndBar

6 constant WINDOW-MENU

: GetFileType	( -- n )
		ActiveChild
		if   GetFileType: ActiveChild
		else -1
		then ;

: IsEditWnd?	( -- f )
		GetFileType FT_SOURCE = ;

: IsHtmlWnd?	( -- f )
		GetFileType FT_HTML = ;

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

: IsAnsWordSelected? ( -- f )
                SelTextToPad ?dup
                if   BL skip BL -TRAILCHARS
                     IsAnsWord?
                else drop false
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
\               dup Enable: me_findprev
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
                dup Enable: mp_compile
                dup Enable: mp_debug
\               dup Enable: mp_HandleW32FMsg

                \ Help menu
                dup Enable: mp_anshelp
                dup Enable: mp_apihelp
                drop ;

: EnableMenuBar	( -- )  \ enable/disable the menu items
		IsEditWnd? dup EnableEdit

		if   	\ File menu
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
\ 	                ?Find:         ActiveChild Enable: me_findprev
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
 			EOL SC_EOL_CRLF = 	Check: mf_windows
 			EOL SC_EOL_LF   = 	Check: mf_unix
 			EOL SC_EOL_CR   = 	Check: mf_mac
 			CreateBackup?   	Check: mp_backup
 			SaveAllBeforeCompile?   Check: mp_sabcompile
                        StripTrailingWhitespace? Check: mp_rtwh
                        FinalNewLine?            Check: mp_efle

 			\ Win32Forth menu
 			GetTextLength:   ActiveChild Enable: mp_compile
			ActiveRemote ActiveChild = HandleW32FMsg? and Enable: mp_debug
                        HandleW32FMsg?          Check: mp_HandleW32FMsg

			\ Help menu
 			IsAnsWordSelected? Enable: mp_anshelp
			sdk-help? Enable: mp_apihelp
		then

                ShowToolbar?   Check: mp_showtb
                ShowStatusbar? Check: mp_showsb
                ShowToolbar?   Enable: mp_customizetb

		ActiveChild 0<> dup Enable: mf_saveall
				dup Enable: mf_close
		                dup Enable: mf_close_all
		                dup Enable: mf_tile_hor
		                dup Enable: mf_tile_ver
		                dup Enable: mf_arrange
		                    Enable: mf_cascade
		0 ;

