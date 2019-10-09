\ $Id: ScintillaMDI.f,v 1.12 2006/08/26 15:25:31 jos_ven Exp $

\    File: ScintillaMDI.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Mittwoch, Juni 09 2004 - dbu
\ Updated: Samstag, Juli 03 2004 - 10:52 - dbu
\
\ A wrapper class around the ScintillaControl class.
\ This Class can be used to build a real Editor around the control.

cr .( Loading Scintilla MDI Window...)

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

MultiFileOpenDialog SourceFileOpenDialog "Open Source Files" "Forth Files (*.f,*.fs,*.4th,*.fth,*.seq)|*.f;*.fs;*.4th;*.fth;*.seq|All Files (*.*)|*.*"
FileSaveDialog      SaveSourceFileDialog "Save Source File"  "Forth Files (*.f)|*.f|All Files (*.*)|*.*|"

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

:Class EditorChild <super MDIChild

ReadFile EditFile
create FindText$ MAXSTRING char+ allot
int FindMode
int CreateBackup?
int Lexer
int StripTrailingSpaces?
int EnsureFinalNewLine?

:M ?Modified:   ( -- f )
                GetModify: ChildWindow ;M

:M GetFileType: ( -- n )
                FT_SOURCE ;M

fload ScintillaLexer.f

:M InitLexer:   ( -- )
                SCLEX_FORTH dup to Lexer SetLexer: ChildWindow

                0 ANSKeywords  SetKeyWords: ChildWindow
                1 commentStart SetKeyWords: ChildWindow
                2 commentEnd   SetKeyWords: ChildWindow
                3 UserWords1   SetKeyWords: ChildWindow
                4 UserWords2   SetKeyWords: ChildWindow
                5 UserWords3   SetKeyWords: ChildWindow
                6 UserWords4   SetKeyWords: ChildWindow
                7 UserWords5   SetKeyWords: ChildWindow
                8 UserWords6   SetKeyWords: ChildWindow

                SCE_FORTH_DEFAULT COL_FORTH_DEFAULT StyleSetFore: ChildWindow
                SCE_FORTH_COMMENT COL_FORTH_COMMENT StyleSetFore: ChildWindow
                SCE_FORTH_STRING  COL_FORTH_STRING  StyleSetFore: ChildWindow
                SCE_FORTH_NUMBER  COL_FORTH_NUMBER  StyleSetFore: ChildWindow
                SCE_FORTH_LOCALS  COL_FORTH_LOCALS  StyleSetFore: ChildWindow
                SCE_FORTH_ANS     COL_FORTH_ANS     StyleSetFore: ChildWindow
                SCE_FORTH_USER1   COL_FORTH_USER1   StyleSetFore: ChildWindow
                SCE_FORTH_USER2   COL_FORTH_USER2   StyleSetFore: ChildWindow
                SCE_FORTH_USER3   COL_FORTH_USER3   StyleSetFore: ChildWindow
                SCE_FORTH_USER4   COL_FORTH_USER4   StyleSetFore: ChildWindow
                SCE_FORTH_USER5   COL_FORTH_USER5   StyleSetFore: ChildWindow
                SCE_FORTH_USER6   COL_FORTH_USER6   StyleSetFore: ChildWindow
                ;M


create WordChars MAXSTRING allot 0 WordChars !
s" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" WordChars place
s" 0123456789°!§$%&/()=?`´^{[]}\+*~#,.-;:_@<>|" WordChars +place
WordChars count + dup 34 swap c! ( " ) char+ dup 39 swap c! ( ' ) char+ 0 swap c!

:M Start:       ( parent -- )
                New> ScintillaControl to ChildWindow
                self to ChildParent
                Start: super
                0 to FindMode
                true to CreateBackup?
                true to StripTrailingSpaces?
                true to EnsureFinalNewLine?
                FindText$ off
                InitLexer: self
                STYLE_DEFAULT z" Fixedsys" StyleSetFont: ChildWindow
                WordChars 1+ SetWordChars: ChildWindow
                ShowLineNumbers: ChildWindow    \ Monday, August 16 2004 - EAB
                ;M

:M GetFileName: ( -- addr )
                GetName: EditFile ;M

:M SetWindowTitle: { \ Text$ -- }
                1024 LocalAlloc: Text$
                GetFileName: self count dup 0=
                if 2drop s" [NEW FILE]" then Text$ place \ +place
                Text$ count SetText: super ;M

:M SetFileName: ( addr len -- )
                SetName: EditFile
                ;M

: MessageBox    ( n a1 n1 -- n2 )
                pad place pad +NULL
                z" ScintillaEdit"
                pad count drop
                Gethandle: self Call MessageBox ;

: GetOpenFilename ( -- addr len )
                GetHandle: self Start: SourceFileOpenDialog count ;

: GetSaveFilename ( -- addr len )
                GetHandle: self Start: SaveSourceFileDialog count
; \             pad place pad ?DEFEXT pad count ; \ add default extension (.f) if needed

:M GetTextLength: ( -- n )
                GetTextLength: ChildWindow ;M

:M Delete:      ( -- )          \ delete the selected text
                0 PAD ! PAD ReplaceSel: ChildWindow ;M

:M RemoveSel:   ( -- )          \ remove the current selection
                -1 GetCurrentPos: ChildWindow SetSel: ChildWindow ;M

:M ?Selection:  ( -- f )
                GetSelectionStart: ChildWindow GetSelectionEnd: ChildWindow - ;M

:M ?Find:       ( -- f )
                FindText$ c@ 0<> ;M

:M FindText:    { \ SelBuf$ -- }
                \ move selected text into find-buf
                0 GetSelText: ChildWindow LocalAlloc: SelBuf$
                SelBuf$ GetSelText: ChildWindow
                if   SelBuf$ zcount BL skip -trailing 10 -TRAILCHARS 13 -TRAILCHARS
                     ?dup if FindText$ place else drop then
                then

                FindText$ self Start: FindTextDlg
                case    0 of exitm            endof
                        1 of 0                endof \ ignore case
                        2 of SCFIND_MATCHCASE endof
                endcase dup to FindMode

                ?Find: self
                if   FindText$ +null
                     0 GetTextLength: self
                     FindText$ 1+ FindText: ChildWindow ( nStart nEnd flag )
                     if   SetSel: ChildWindow
                     then
                else drop
                then ;M

:M SearchNext:  ( -- )
                ?Find: self
                if
                     GetSelectionEnd: ChildWindow SetSelectionStart: ChildWindow
                     SearchAnchor: ChildWindow
                     FindMode FindText$ 1+ SearchNext: ChildWindow INVALID_POSITION <>
                     if ScrollCaret: ChildWindow then
                then ;M

:M SearchPrev:  ( -- ) \ this doesn't work... why?
                ?Find: self
                if
                     GetSelectionEnd: ChildWindow SetSelectionStart: ChildWindow
                     SearchAnchor: ChildWindow
                     FindMode FindText$ 1+ SearchPrev: ChildWindow INVALID_POSITION <>
                     if ScrollCaret: ChildWindow then
                then ;M

:M GetCurrentLine: ( -- #line )
                GetCurrentPos: ChildWindow
                LineFromPosition: ChildWindow ;M

:M InsertDate:  { \ $buf -- } \ replace selection with current date
                MAXSTRING LocalAlloc: $buf
                get-local-time time-buf
                >month,day,year" $buf place
                $buf +null $buf 1+ ReplaceSel: ChildWindow ;M

:M InsertDate&Time: { \ $buf -- } \ replace selection with current date and time
                MAXSTRING LocalAlloc: $buf
                get-local-time time-buf
                >month,day,year" $buf place
                time&date 2drop drop
                s"  - " $buf +place
                (.)   $buf +place s" :" $buf +place
                2 .#" $buf +place drop
                $buf +null $buf 1+ ReplaceSel: ChildWindow ;M

: SelBounds     ( -- n1 n2 )
                GetSelectionEnd: ChildWindow LineFromPosition: ChildWindow
                GetSelectionStart: ChildWindow LineFromPosition: ChildWindow ;

: Comment?      ( #line -- f ) \ check if line starts with a comment
                PositionFromLine: ChildWindow
                dup GetCharAt: ChildWindow [char] \ = swap
                1+ GetCharAt: ChildWindow bl = and ;

:M CommentBlock: ( -- ) \ comment a block of lines
                ?Selection: self
                if   BeginUndoAction: ChildWindow
                     SelBounds
                     ?do  i Comment? not
                          if   i PositionFromLine: ChildWindow
                               z" \ " InsertText: ChildWindow
                          then
                     loop EndUndoAction: ChildWindow
                then ;M

:M UnCommentBlock: ( -- ) \ uncomment a block of lines
                ?Selection: self
                if   BeginUndoAction: ChildWindow
                     SelBounds
                     ?do  i Comment?
                          if   i PositionFromLine: ChildWindow
                               dup 2 + SetSel: ChildWindow Delete: self
                          then
                     loop EndUndoAction: ChildWindow
                then ;M

:M GotoColumn:  ( n -- )
                GetCurrentPos: ChildWindow
                + ( 1- ) dup SetCurrentPos: ChildWindow SetAnchor: ChildWindow ;M

:M GetCurrentLineLength: ( -- n )
                GetCurrentLine: self
                LineLength: ChildWindow ;M

:M HighlightWord: { \ buf$ Pos Anchor -- } \ highlight the current word under cursor
                GetCurrentLineLength: self 1+ dup LocalAlloc: buf$
                buf$ GetCurLine: ChildWindow
                GetCurrentLineLength: self min ( curpos )

                buf$ swap 2dup
                BEGIN   2dup bl scan dup
                WHILE   2nip
                        bl skip
                REPEAT  2drop drop 2 pick - dup dup>r
                /string 2dup bl scan nip - r@ + nip

                r> swap

                GetCurrentLine: self PositionFromLine: ChildWindow dup>r
                   + SetCurrentPos: ChildWindow
                r> + SetAnchor: ChildWindow

                SCI_WORDRIGHTENDEXTEND KeyCommand: ChildWindow
                ;M

:M CanUndo:     ( -- f )
                CanUndo: ChildWindow ;M

:M Undo:        ( -- )
                Undo: ChildWindow ;M

:M CanRedo:     ( -- f )
                CanRedo: ChildWindow ;M

:M Redo:        ( -- )
                Redo: ChildWindow ;M

:M Cut:         ( -- )
                Cut: ChildWindow ;M

:M Copy:        ( -- )
                Copy: ChildWindow ;M

:M CanPaste:    ( -- f )
                CanPaste: ChildWindow ;M

:M Paste:       ( -- )
                Paste: ChildWindow ;M

:M SelectAll:   ( -- )
                SelectAll: ChildWindow ;M

:M GotoLine:    ( n -- )
                GotoLine: ChildWindow ;M

:M GetLineCount: ( -- n )
                GetLineCount: ChildWindow ;M

:M GetSelText:  ( addr -- n )
\ *G Copy the selected text to the memory pointed by \i addr \d
\ ** and return the length of the selected text (including terminating
\ ** 0 byte. If \i addr \d is NULL no text is copied and only the
\ ** length is returned.
                GetSelText: ChildWindow ;M

:M EnableBackup: ( f -- )
                to CreateBackup? ;M

:M EnableStripTrailingSpaces:   ( f -- )
                to StripTrailingSpaces? ;M

:M EnableEnsureFinalNewLine:    ( f -- )
                to EnsureFinalNewLine? ;M

:M SetEOL:      ( eolMode -- )
                dup ConvertEOL: ChildWindow SetEOL: ChildWindow ;M

:M ViewEOL:     ( f -- )
                SetViewEOL: ChildWindow ;M

:M ViewWhiteSpace: ( f -- )
                if SCWS_VISIBLEALWAYS else SCWS_INVISIBLE then
                SetWhiteSpace: ChildWindow ;M

:M Colorize:    ( f -- )
                if   SCLEX_FORTH
                else SCLEX_NULL
                then dup Lexer <>
                if   dup to Lexer
                     SetLexer: ChildWindow
                     0 -1 Colourise: ChildWindow
                else drop
                then ;M

:M ViewLineNumbers: ( f -- )
                if ShowLineNumbers: ChildWindow else HideLineNumbers: ChildWindow then ;M

:M SetTabWidth: ( n -- )
                1 max 8 min SetTabWidth: ChildWindow ;M

:M SetUseTabs:  ( n -- )
                SetUseTabs: ChildWindow ;M

:m ~:           ( -- )
                ReleaseBuffer: EditFile ;m

\ remove trailing white space char's (spaces and tabs) form the end
\ of all lines in the file
:M StripTrailingSpaces: { \ lineStart lineEnd -- }
                GetLineCount: ChildWindow 0
                ?DO  i PositionFromLine: ChildWindow to lineStart
                     i GetLineEndPosition: ChildWindow dup to lineEnd 0>
                     if   lineEnd
                          begin 1-
                                dup GetCharAt: ChildWindow
                                dup BL = swap 0x09 ( TAB ) = or
                                swap dup lineStart >= rot and 0=
                          until
                          dup i lineEnd 1- <
                          if   1+ SetTargetStart: ChildWindow
                               lineEnd SetTargetEnd: ChildWindow
                               0 pad ! pad 0 ReplaceTarget: ChildWindow drop
                          else drop
                          then
                     then
                LOOP ;M

\ make shure that the last line of the file ends with a line end marker
:M EnsureFinalNewLine: { \ maxLines endDoc appendNewLine -- }
                GetLineCount: ChildWindow to maxLines
                maxLines 1 = to appendNewLine
                maxLines PositionFromLine: ChildWindow to endDoc

                maxLines 1 >
                if   endDoc maxLines 1- PositionFromLine: ChildWindow > to appendNewLine
                then

                appendNewLine
                if   GetEOL: ChildWindow
                     case    SC_EOL_CRLF of 0x0D pad c! 0x0A pad 1+ c! 0 pad 2+ c! endof
                             SC_EOL_CR   of 0x0D pad c! 0 pad 1+ c! endof
                             SC_EOL_LF   of 0x0A pad c! 0 pad 1+ c! endof
                     endcase endDoc pad InsertText: ChildWindow
                then ;M

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------

: SaveText      ( -- )          \ save the Text in the control to the file

                StripTrailingSpaces? dup . space
                if   StripTrailingSpaces: self
                then

                EnsureFinalNewLine? dup . space
                if   EnsureFinalNewLine: self
                then

                \ get the complete text from the control
                ReleaseBuffer: EditFile
                GetTextLength: self 1+ AllocBuffer: EditFile
                GetBuffer: EditFile GetText: ChildWindow

                \ adjust the Text length in the EditFile because
                \ the Scintilla-Control returns a null byte at the
                \ end of the Text. Thank's Ezra for telling me about this
                \ bug (Freitag, August 19 2005 - dbu)
                GetLength: EditFile 1- SetLength: EditFile

                \ save the text to the file
                SaveFile: EditFile
                ReleaseBuffer: EditFile

                \ and mark the text in the control as unchanged
                SetSavepoint: ChildWindow
                SetWindowTitle: self ;

:M SaveFileAs:  ( -- )          \ save the file under a new name
                GetSaveFilename ?dup
                if      SetFileName: self
                        SaveText
                else    drop
                then    ;M

: CreateBackup  ( -- ) \ create a Backup of the active file (*.BAK)
                CreateBackup?
                if
                     GetFileName: self count pad place
                     pad count "minus-ext" pad place s" .bak" pad +place pad +null

                     false pad count drop  GetFileName: self count drop
                     Call CopyFile ?win-error
                then ;

:M SaveFile:    ( -- )          \ save the file under it's current name
                GetFileName: self c@ 0=
                if   SaveFileAs: self
                else CreateBackup
                     SaveText
                then ;M

:M SaveBeforeCloseing: ( -- )
                GetModify: ChildWindow 0<>
                if   [ MB_YESNO MB_ICONQUESTION or ] literal
                     s" The current File has changed. Would you like to save your changes?" MessageBox
                     IDYES = if SaveFile: self then
                then ;M

:M NewFile:     ( -- )          \ open a new empty file
                ClearName: EditFile ;M

: SetFile       ( f -- )
                GetBuffer: EditFile ?dup
                if   over + 0 swap c! \ add 0-terminator
                     SetText: ChildWindow
                then
                EmptyUndoBuffer: ChildWindow
                SetSavepoint: ChildWindow
                0 -1 Colourise: ChildWindow ;

:M OpenNamedFile: ( addr len -- f )          \ open a file
                SaveBeforeCloseing: self
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
                if   GetModify: ChildWindow 0<>
                     if   [ MB_YESNO MB_ICONQUESTION or ] literal
                          s" The current File has changed. All changes will be lost. Would you like to continue?" MessageBox
                          IDYES =
                          if   GetFileName: self count pad place
                               SetSavepoint: ChildWindow NewFile: self
                               pad count LoadFile SetFile
                          then
                     then
                then ;M

\ ----------------------------------------------------------------------------
\ DexH support
\ ----------------------------------------------------------------------------

: DexBlock      { addr \ FirstLine? -- }
                ?Selection: self
                if   true to FirstLine?
                     BeginUndoAction: ChildWindow
                     SelBounds
                     ?do  i Comment?
                          if   \ remove current comment " \ " first
                               i PositionFromLine: ChildWindow
                               dup 2 + SetSel: ChildWindow Delete: self
                          then
                          i PositionFromLine: ChildWindow
                          FirstLine?
                          if   addr false to FirstLine?
                          else z" \ ** "
                          then InsertText: ChildWindow
                     loop EndUndoAction: ChildWindow
                then ;

:M DexGlossary: ( -- )
\ *G Turn a block of lines into a Glossary entry.
                z" \ *G " DexBlock ;M

:M DexParagraph: ( -- )
\ *G Turn a block of lines into a Paragraph.
                z" \ *P " DexBlock ;M

:M DexCodeParagraph: ( -- )
\ *G Turn a block of lines into a Paragraph which is a code example.
                z" \ *E " DexBlock ;M

: DexStyle      { addr len \ slen $buf1 $buf2 -- }
                0 GetSelText: ChildWindow dup to slen
                if   slen LocalAlloc: $buf1 $buf1 GetSelText: ChildWindow
                     if   slen 16 + LocalAlloc: $buf2
                          addr len $buf2 lplace $buf1 slen 1- $buf2 +lplace s"  \d" $buf2 +lplace
                          0 $buf2 lcount + c!
                          $buf2 lcount drop ReplaceSel: ChildWindow
                     then
                then ;

:M DexStyleBold: ( -- )
\ *G Set \b bold \d text style for the selected text.
                s" \b " DexStyle ;M

:M DexStyleItalic: ( -- )
\ *G Set \i italic \d text style for the selected text.
                s" \i " DexStyle ;M

:M DexStyleTypewriter: ( -- )
\ *G Set \t typewriter \d text style for the selected text.
                s" \t " DexStyle ;M

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------

:M Compile:     ( -- ) \ compile this File
                GetModify: ChildWindow 0<>
                if   SaveFile: self
                then GetFileName: self count Compile-File
                ;M

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------

: OpenFile      ( adr -- f ) \ f=false = file is opend
                dup count FILE-STATUS nip 0=
                if   IDM_OPEN_RECENT_FILE DoCommand false
                else drop true
                then ;

:M OpenHighlightedFile: { \ buf$ old-path$ -- }
             0 GetSelText: ChildWindow MAXSTRING CHARS <
                if   MAXSTRING CHARS 1+ LocalAlloc: buf$
                     buf$ 1+ GetSelText: ChildWindow 1- 255 min buf$ c!

                     \ try to open the file with the given path
                     buf$ ?defext buf$ OpenFile
                     if   \ try to find the file in the folder of the current file
                          buf$ count "to-pathend" pad place
                          GetName: EditFile count "path-only"
                          buf$ place buf$ ?+\ pad count buf$ +place
                          buf$ OpenFile
                          if   \ search for the file in the Forth search path
                               buf$ count "to-pathend" buf$ place

                               MAXSTRING CHARS 1+ LocalAlloc: old-path$
                               search-path count old-path$ place \ save current path

                               search-path program-path-init  \ init forth search path
                               buf$ count "path-file 0=    \ search through the Forth path
                               if   buf$ place
                                    buf$ IDM_OPEN_RECENT_FILE DoCommand
                               else 2drop beep
                               then

                               old-path$ count search-path place \ restore path
                          then
                     then
                else 2drop beep
                then
  ;M

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
