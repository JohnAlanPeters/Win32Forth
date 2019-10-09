\    File: ScintillaEdit.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Mittwoch, Juni 09 2004 - dbu
\ Updated: Samstag, Juli 03 2004 - 10:52 - dbu
\
\ A wrapper class around the ScintillaControl class.
\ This Class can be used to build a real Editor around the control.

cr .( Loading Scintilla Window...)

ANEW -ScintillaEdit.f

needs ScintillaControl.f
needs file.f
\ needs RegistryWindowPos.f

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

INTERNAL

FileOpenDialog OpenFileDialog "Open Source File" "Forth Files (*.f,*.fs,*.4th,*.fth,*.seq)|*.f;*.fs;*.4th;*.fth;*.seq|All Files (*.*)|*.*"
FileSaveDialog SaveFileDialog "Save Source File" "Forth Files (*.f)|*.f|All Files (*.*)|*.*|"

NewEditDialog  FindTextDlg "Find Text" "Search for:" "Find" "" "Case Sensitive Search"


EXTERNAL

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

:Class ScintillaEdit <super ScintillaControl

ReadFile EditFile
create FindText$ MAXSTRING char+ allot
int FindMode
int CreateBackup?

fload ScintillaLexer.f

:M SetCaretBackColor:	( color -- )	\ value of zero turns it off effect
		dup 0=
		if	false SCI_SETCARETLINEVISIBLE hwnd send-window
		else	0 swap SCI_SETCARETLINEBACK hwnd send-window
			0 true SCI_SETCARETLINEVISIBLE hwnd send-window
		then	;M

:M SetColors:	( fore back -- )
		style_default rot stylesetfore: self
		style_default swap stylesetback: self
		0 0 SCI_STYLECLEARALL hwnd send-window
		InitLexer: [ self ]
		;M

:M InitLexer:   ( -- )
                SCLEX_FORTH SetLexer: self

                0 ANSKeywords  SetKeyWords: self
                1 commentStart SetKeyWords: self
                2 commentEnd   SetKeyWords: self
                3 UserWords1   SetKeyWords: self
                4 UserWords2   SetKeyWords: self
                5 UserWords3   SetKeyWords: self
                6 UserWords4   SetKeyWords: self
                7 UserWords5   SetKeyWords: self
                8 UserWords6   SetKeyWords: self

                SCE_FORTH_DEFAULT COL_FORTH_DEFAULT StyleSetFore: self
                SCE_FORTH_COMMENT COL_FORTH_COMMENT StyleSetFore: self
                SCE_FORTH_STRING  COL_FORTH_STRING  StyleSetFore: self
                SCE_FORTH_NUMBER  COL_FORTH_NUMBER  StyleSetFore: self
                SCE_FORTH_LOCALS  COL_FORTH_LOCALS  StyleSetFore: self
                SCE_FORTH_ANS     COL_FORTH_ANS     StyleSetFore: self
                SCE_FORTH_USER1   COL_FORTH_USER1   StyleSetFore: self
                SCE_FORTH_USER2   COL_FORTH_USER2   StyleSetFore: self
                SCE_FORTH_USER3   COL_FORTH_USER3   StyleSetFore: self
                SCE_FORTH_USER4   COL_FORTH_USER4   StyleSetFore: self
                SCE_FORTH_USER5   COL_FORTH_USER5   StyleSetFore: self
                SCE_FORTH_USER6   COL_FORTH_USER6   StyleSetFore: self
                ;M
create WordChars MAXSTRING allot 0 WordChars !
s" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" WordChars place
s" 0123456789°!§$%&/()=?`´^{[]}\+*~#,.-;:_@<>|" WordChars +place
WordChars count + dup 34 swap c! ( " ) char+ dup 39 swap c! ( ' ) char+ 0 swap c!

:M Start:       ( Parent -- )
                Start: super
                0 to FindMode
                true to CreateBackup?
                FindText$ off
                InitLexer: self
                STYLE_DEFAULT z" Fixedsys" StyleSetFont: self
                WordChars 1+ SetWordChars: self ;M

:M GetFileName: ( -- addr )
                GetName: EditFile ;M

:M SetWindowTitle: { \ Text$ -- }
                1024 LocalAlloc: Text$
                WindowTitle: parent zcount Text$ place
                s"  - " Text$ +place
                GetFileName: self count dup 0=
                if 2drop s" [NEW FILE]" then Text$ +place
                Text$ count SetText: parent ;M

:M SetFileName: ( addr len -- )
                SetName: EditFile
                SetWindowTitle: self ;M

: MessageBox    ( n a1 n1 -- n2 )
                pad place pad +NULL
                z" ScintillaEdit"
                pad count drop
                Gethandle: self Call MessageBox ;

: GetOpenFilename ( -- addr len )
                Gethandle: self Start: OpenfileDialog count ;

: GetSaveFilename ( -- addr len )
                Gethandle: self Start: SaveFileDialog count ;

: SaveText      ( -- )          \ save the Text in the control to the file
                \ get the complete text from the control
                ReleaseBuffer: EditFile
                GetTextLength: self 1+ AllocBuffer: EditFile
                GetBuffer: EditFile GetText: self

                \ adjust the Text length in the EditFile because
                \ the Scintilla-Control returns on null byte at the
                \ end of the Text. Thank's Ezra for telling me about this
                \ bug (Freitag, August 19 2005 - dbu)
                GetLength: EditFile 1- SetLength: EditFile

                \ save the text to the file
                SaveFile: EditFile
                ReleaseBuffer: EditFile

                \ and mark the text in the control as unchanged
                SetSavepoint: self ;

:M SaveFileAs:  ( -- )          \ save the file under a new name
                GetSaveFilename ?dup
                if   SetFileName: self
                     SaveText
                else drop
                then ;M

: CreateBackup  { \ from$ to$ -- } \ create a Backup of the active file (*.BAK)
                CreateBackup?
                if   max-path localAlloc: from$
                     max-path localAlloc: to$

                     GetFileName: self count from$ place from$ +null

                     GetFileName: self count to$ place
                     to$ count "minus-ext" to$ place s" .bak" to$ +place to$ +null

                     false to$ count drop from$ count drop
                     Call CopyFile ?win-error
                then ;

:M SaveFile:    ( -- )          \ save the file under it's current name
                GetFileName: self c@ 0=
                if   SaveFileAs: self
                else CreateBackup SaveText
                then ;M

:M SaveBeforeCloseing: ( -- )
                GetModify: self 0<>
                if   [ MB_YESNO MB_ICONQUESTION or ] literal
                     s" The current File has changed. Would you like to save your changes?" MessageBox
                     IDYES = if SaveFile: self then
                then ;M

:M NewFile:     ( -- )          \ open a new empty file
                SaveBeforeCloseing: self
                ClearAll: self
                EmptyUndoBuffer: self
                SetSavepoint: self
                ClearName: EditFile ;M

: SetFile       ( f -- )
                GetBuffer: EditFile ?dup
                if   over + 0 swap c! \ add 0-terminator
                     SetText: self
                then
                EmptyUndoBuffer: self
                SetSavepoint: self
                0 -1 Colourise: self ;

:M OpenNamedFile: ( addr len -- f )          \ open a file
                SaveBeforeCloseing: self
                ClearAll: self
                LoadFile: EditFile
                dup if SetFile then
                SetWindowTitle: self ;M

:M OpenFile:    ( -- f )          \ open a file
                GetOpenFilename ?dup
                if   OpenNamedFile: self
                else drop false
                then ;M

:M ReloadFile:  ( -- )          \ reload the current file
                GetFileName: self c@ 0<>
                if   GetModify: self 0<>
                     if   [ MB_YESNO MB_ICONQUESTION or ] literal
                          s" The current File has changed. All changes will be lost. Would you like to continue?" MessageBox
                          IDYES =
                          if   GetFileName: self count pad place
                               SetSavepoint: self NewFile: self
                               pad count LoadFile SetFile
                          then
                     then
                then ;M

:M Delete:      ( -- )          \ delete the selected text
                0 PAD ! PAD ReplaceSel: self ;M

:M RemoveSel:   ( -- )          \ remove the current selection
                -1 GetCurrentPos: self SetSel: self ;M

:M ?Selection:  ( -- f )
                GetSelectionStart: self GetSelectionEnd: self - ;M

:M ViewEOL:     ( -- )
                GetViewEOL: self not SetViewEOL: self ;M

:M SetEOL:      ( eolMode -- )
                dup ConvertEOL: self SetEOL: super ;M

:M SetOverType: ( -- )
                GetOverType: self not SetOverType: super ;M

:M ViewWhiteSpace: ( -- )
                GetWhiteSpace: self
                SCWS_INVISIBLE = if SCWS_VISIBLEALWAYS else SCWS_INVISIBLE then
                SetWhiteSpace: self ;M

:M ?Find:       ( -- f )
                FindText$ c@ 0<> ;M

:M FindText:    ( -- )
                FindText$ self Start: FindTextDlg
                case    0 of exitm            endof
                        1 of 0                endof \ ignore case
                        2 of SCFIND_MATCHCASE endof
                endcase dup to FindMode

                ?Find: self
                if   FindText$ +null
                     0 GetTextLength: self
                     FindText$ 1+ FindText: super ( nStart nEnd flag )
                     if   SetSel: self
                     then
                else drop
                then ;M

:M SearchNext:  ( -- )
                ?Find: self
                if
                     GetSelectionEnd: self SetSelectionStart: self
                     SearchAnchor: self
                     FindMode FindText$ 1+ SearchNext: super INVALID_POSITION <>
                     if ScrollCaret: super then
                then ;M

:M SearchPrev:  ( -- ) \ this doesn't work... why?
                ?Find: self
                if
                     GetSelectionEnd: self SetSelectionStart: self
                     SearchAnchor: self
                     FindMode FindText$ 1+ SearchPrev: super INVALID_POSITION <>
                     if ScrollCaret: super then
                then ;M

:M GetCurrentLine: ( -- #line )
                GetCurrentPos: self
                LineFromPosition: self ;M

:M IsBackupEnabled: ( -- f )
                CreateBackup? ;M

:M EnableBackup: ( f -- )
                to CreateBackup? ;M

:M InsertDate:  { \ $buf -- } \ replace selection with current date
                MAXSTRING LocalAlloc: $buf
                get-local-time time-buf
                >month,day,year" $buf place

\                time&date 2drop drop
\                s"  - " $buf +place
\                (.)   $buf +place s" :" $buf +place
\                2 .#" $buf +place drop
                $buf +null $buf 1+ ReplaceSel: self ;M

:M InsertDate&Time: { \ $buf -- } \ replace selection with current date and time
                MAXSTRING LocalAlloc: $buf
                get-local-time time-buf
                >month,day,year" $buf place

                time&date 3drop
                s"  - " $buf +place
                (.)   $buf +place s" :" $buf +place
                2 .#" $buf +place drop
                $buf +null $buf 1+ ReplaceSel: self ;M

: SelBounds     ( -- n1 n2 )
                GetSelectionEnd: self LineFromPosition: self
                GetSelectionStart: self LineFromPosition: self ;

: Comment?      ( #line -- ) \ check if line starts with a comment
                PositionFromLine: self
                dup GetCharAt: self [char] \ = swap
                1+ GetCharAt: self bl = and ;

:M CommentBlock: ( -- ) \ comment a block of lines
                ?Selection: self
                if   BeginUndoAction: self
                     SelBounds
                     ?do  i Comment? not
                          if   i PositionFromLine: self
                               z" \ " InsertText: self
                          then
                     loop EndUndoAction: self
                then ;M

:M UnCommentBlock: ( -- ) \ uncomment a block of lines
                ?Selection: self
                if   BeginUndoAction: self
                     SelBounds
                     ?do  i Comment?
                          if   i PositionFromLine: self
                               dup 2 + SetSel: self Delete: self
                          then
                     loop EndUndoAction: self
                then ;M

:M GotoColumn:  ( n -- )
\                GetCurrentLine: self PositionFromLine: self
                GetCurrentPos: self
                + ( 1- ) dup SetCurrentPos: self SetAnchor: self ;M

:M GetCurrentLineLength: ( -- n )
                GetCurrentLine: self
                LineLength: self ;M

:M HighlightLine: ( Anchor Pos -- )
                GetCurrentLine: self PositionFromLine: self dup>r
                   + SetCurrentPos: self
                r> + SetAnchor: self ;M

:M HighlightWord: { \ buf$ Pos Anchor -- } \ highlight the current word under cursor

                GetCurrentLineLength: self 1+ dup LocalAlloc: buf$
                buf$ GetCurLine: self
                GetCurrentLineLength: self min ( curpos )

                buf$ swap 2dup
                BEGIN   2dup bl scan dup
                WHILE   2nip
                        bl skip
                REPEAT  3drop 2 pick - dup dup>r
                /string 2dup bl scan nip - r@ + nip

                r> swap HighlightLine: self ;M

:m ~:           ( -- )
                ReleaseBuffer: EditFile ;m

Record: scn \ struct SCNotification
        int scn_hWndFrom
        int scn_idFrom
        int scn_code
        int scn_position;
        \ SCN_STYLENEEDED, SCN_MODIFIED, SCN_DWELLSTART,
        \ SCN_DWELLEND, SCN_CALLTIPCLICK,
        \ SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK
        int scn_ch               \ SCN_CHARADDED, SCN_KEY
        int scn_modifiers        \ SCN_KEY, SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK
        int scn_modificationType \ SCN_MODIFIED
        int scn_text             \ SCN_MODIFIED
        int scn_length           \ SCN_MODIFIED
        int scn_linesAdded       \ SCN_MODIFIED
        int scn_message          \ SCN_MACRORECORD
        int scn_wParam           \ SCN_MACRORECORD
        int scn_lParam           \ SCN_MACRORECORD
        int scn_line             \ SCN_MODIFIED
        int scn_foldLevelNow     \ SCN_MODIFIED
        int scn_foldLevelPrev    \ SCN_MODIFIED
        int scn_margin           \ SCN_MARGINCLICK
        int scn_listType         \ SCN_USERLISTSELECTION
        int scn_x                \ SCN_DWELLSTART, SCN_DWELLEND
        int scn_y                \ SCN_DWELLSTART, SCN_DWELLEND
;RecordSize: /scn

: fill-scn      ( l -- )
                scn /scn move ;

:M OnNotify:    ( h m w l -- res ) \ handle the Notifications
\ comment:
\                cr ." OnNotify: "
                fill-scn scn_code
                case \   SCN_STYLENEEDED        of ." SCN_STYLENEEDED" endof
                     \   SCN_STYLENEEDED        of ." SCN_STYLENEEDED" endof
                     \   SCN_CHARADDED          of ." SCN_CHARADDED" endof
                     \   SCN_SAVEPOINTREACHED   of ." SCN_SAVEPOINTREACHED" endof
                     \   SCN_SAVEPOINTLEFT      of ." SCN_SAVEPOINTLEFT" endof
                     \    SCN_KEY                of On_ScnKey: self endof
                     \   SCN_DOUBLECLICK        of ." SCN_DOUBLECLICK" endof
                     \   SCN_UPDATEUI           of ." SCN_UPDATEU" endof
                     \   SCN_MODIFIED           of ." SCN_MODIFIED" endof
                     \   SCN_MACRORECORD        of ." SCN_MACRORECORD" endof
                     \   SCN_MARGINCLICK        of ." SCN_MARGINCLICK" endof
                     \   SCN_NEEDSHOWN          of ." SCN_NEEDSHOWN" endof
                     \   SCN_PAINTED            of ." SCN_PAINTED" endof
                     \   SCN_USERLISTSELECTION  of ." SCN_USERLISTSELECTION" endof
                     \   SCN_URIDROPPED         of ." SCN_URIDROPPED" endof
                     \   SCN_DWELLSTART         of ." SCN_DWELLSTART" endof
                     \   SCN_DWELLEND           of ." SCN_DWELLEND" endof
                     \   SCN_ZOOM               of ." SCN_ZOOM" endof
                     \   SCN_HOTSPOTCLICK       of ." SCN_HOTSPOTCLICK" endof
                     \   SCN_HOTSPOTDOUBLECLICK of ." SCN_HOTSPOTDOUBLECLICK" endof
                     \   SCN_CALLTIPCLICK       of ." SCN_CALLTIPCLICK" endof
                endcase
\ comment;
                true ;M

:M OnCommand:   ( h m w l -- res )
comment:
                cr ." OnCommand: "
                over HIWORD
                case    SCEN_CHANGE    of ." SCEN_CHANGE" endof
                        SCEN_SETFOCUS  of ." SCEN_SETFOCUS" endof
                        SCEN_KILLFOCUS of ." SCEN_KILLFOCUS" endof
                endcase
comment;
                true ;M

;Class

MODULE

