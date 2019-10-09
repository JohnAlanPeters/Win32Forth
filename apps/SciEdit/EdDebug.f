\ $Id: EdDebug.f,v 1.3 2007/05/13 07:52:26 dbu_de Exp $

\    File: EdDebug.f
\  Author: Dirk Busch
\ Created: Samstag, Juli 10 2004 - 10:16 dbu
\ Updated: Samstag, Juli 10 2004 - 10:16 dbu
\
\ Debug an application in the Editor

\ [undefined] EditorWindow [if]
\ 0 value EditorWindow
\ s" src\wined\res" "fpath+
\ load-dialog WINEDIT     \ load the dialogs for WinEd
\ [then]

\ -----------------------------------------------------------------------------
\ -----------------------------------------------------------------------------
: stepbp        ( -- )          \ execute a single step
                0 WM_STEPBP win32forth-message ;

: nestbp        ( -- )          \ nest into definition
                0 WM_NESTBP win32forth-message ;

: unestbp       ( -- )          \ unnest from definition
                0 WM_UNESTBP win32forth-message ;

: contbp        ( -- )          \ run continuous till key press
                0 WM_CONTBP win32forth-message ;

: jumpbp        ( -- )          \ jump over branch
                0 WM_JUMPBP win32forth-message ;

: beginbp       ( -- )          \ stop at beginning again
                0 WM_BEGNBP win32forth-message ;

: herebp        ( -- )          \ stop here next time
                0 WM_HEREBP win32forth-message ;

: rstkbp        ( -- )          \ display return stack
                0 WM_RSTKBP win32forth-message ;

: donebp        ( -- )          \ done debugging
                0 WM_DONEBP win32forth-message ;

0 value debug-buttons?

create prev-lines MAXSTRING 5 * allot
       prev-lines MAXSTRING 5 * blank

:Object DbgButtonsDlg  <Super  ModelessDialog

IDD_DEBUG WINEDIT find-dialog-id constant template

 int HexBase
Font dbFont

:M ClassInit:   ( -- )
                ClassInit: super
                FALSE to HexBase        \ FALSE = Decimal, TRUE = Hex
                 8                Width: dbFont
                14               Height: dbFont
                s" Courier" SetFaceName: dbFont         \ default to Courier
                ;M

:M GetTemplate: ( -- template )
                template
                ;M

:M ExWindowStyle: ( -- )
                ExWindowStyle: super
                WS_EX_TOOLWINDOW or
                ;M

: "addstack     { adr len \ ztemp -- }
                MAXSTRING LocalAlloc: ztemp             \ allocate buffer
                ztemp MAXSTRING erase                   \ null fill buffer
                adr ztemp len MAXSTRING 1- min move     \ move text to buffer
                ztemp
                0 LB_ADDSTRING IDL_STACK SendDlgItemMessage: self drop ;

: "addreturn    { adr len \ ztemp -- }
                MAXSTRING LocalAlloc: ztemp             \ allocate buffer
                ztemp MAXSTRING erase                   \ null fill buffer
                adr ztemp len MAXSTRING 1- min move     \ move text to buffer
                ztemp
                0 LB_ADDSTRING IDL_RETURN SendDlgItemMessage: self drop ;

: n>"           ( n1 -- a1 n2 )
                base @ >r
                HexBase
                IF      HEX
                ELSE    DECIMAL
                THEN
                HexBase
                IF      0 <# #s s" 0x" "hold #>
                ELSE    s>d tuck dabs <# #s rot sign #>
                THEN
                r> base ! ;

:M ShowStack:   { \ temp$ -- }
                MAXSTRING LocalAlloc: temp$
                s" Debugging: " temp$  place
                ed-name count   temp$ +place
                temp$ count IDT_NAME SetDlgItemText: self drop
                0 0 LB_RESETCONTENT IDL_STACK SendDlgItemMessage: self drop
                ed-stack @ ?dup
                IF      dup 0<
                        IF      drop 11 0
                                ?DO     s" UnderFlow!" "addstack
                                LOOP
                        ELSE    10 min 1 swap
                                DO      ed-stack i cells+ @ n>" "addstack
                            -1 +LOOP
                        THEN
                ELSE    s" Empty" "addstack
                THEN
                0 0 LB_RESETCONTENT IDL_RETURN SendDlgItemMessage: self drop
                ed-return count bl skip
                bl scan bl skip                 \ skip "RETURN"
                bl scan bl skip                 \ skip "STACK[xx]"
                BEGIN   2dup bl scan 2dup 2>r nip - dup
                WHILE   "addreturn 2r> bl skip
                REPEAT  2drop 2r> 2drop ;M

: "adddebug     { adr len \ ztemp -- }
                MAXSTRING LocalAlloc: ztemp             \ allocate buffer
                ztemp MAXSTRING erase                   \ null fill buffer
                adr ztemp len MAXSTRING 1- min move     \ move text to buffer
                ztemp
                0 LB_ADDSTRING IDL_WORDS SendDlgItemMessage: self drop ;

:M ShowDebug:   ( -- )
                0 0 LB_RESETCONTENT IDL_WORDS SendDlgItemMessage: self drop
                prev-lines dup MAXSTRING + swap MAXSTRING 4 * move
                ed-dbgline count 2dup 0x0D scan 2dup 1 /string 2>r
                2drop
                2r> prev-lines MAXSTRING 4 * + place
                5 0
                ?DO     prev-lines i MAXSTRING * + count "adddebug
                LOOP
                ;M

:M On_Init:     ( -- )
                On_Init: super
                HexBase
                IF      IDR_HEX
                ELSE    IDR_DECIMAL
                THEN    IDR_DECIMAL IDR_HEX CheckRadioButton: self
                Handle: dbFont 0=
                IF      Create: dbFont
                THEN
                Handle: dbFont
                IF      Handle: dbFont IDL_STACK  SetDlgItemFont: self
                        Handle: dbFont IDL_RETURN SetDlgItemFont: self
                        Handle: dbFont IDL_WORDS  SetDlgItemFont: self
                THEN
                ShowStack: self
                ;M

:M On_Command:  ( hCtrl code ID -- f1 ) \ returns 0=cancel
                CASE
                     IDB_STEP     OF stepbp                             ENDOF
                     IDB_NEST     OF nestbp                             ENDOF
                     IDB_UNEST    OF unestbp                            ENDOF
                     IDB_CONT     OF contbp                             ENDOF
                     IDB_JUMP     OF jumpbp                             ENDOF
                     IDB_PROC     OF beginbp                            ENDOF
                     IDB_HERE     OF herebp                             ENDOF
                     IDB_DONE     OF donebp                             ENDOF
                     IDR_HEX      OF TRUE  to HexBase ShowStack: self   ENDOF
                     IDR_DECIMAL  OF FALSE to HexBase ShowStack: self   ENDOF
                     IDCANCEL     OF FALSE to debug-buttons?
                                     Delete: dbFont
                                     DestroyWindow: self                ENDOF
                                     false swap ( default result )
                ENDCASE ;M

:M WM_CLOSE     ( -- )
                FALSE to debug-buttons?
                Delete: dbFont
                WM_CLOSE WM: Super
                ;M

;Object

: debug-buttons ( -- )          \ open the Debug dialog
                Frame Start: DbgButtonsDlg
                TRUE to debug-buttons? ;

: receive-stack ( -- )          \ get stack from Forth
                ShowStack: DbgButtonsDlg ;

: receive-debug ( -- )
                ShowDebug: DbgButtonsDlg ;

\ -----------------------------------------------------------------------------
\ -----------------------------------------------------------------------------
\ : zMessageBox   ( szString -- )
\                 z" Notice"
\                 MB_OK MB_ICONSTOP or
\                 MessageBox: Frame ;
\
\ MAXSTRING pointer debug-buf
\ NewEditDialog DebugDlg "Insert BreakPoint at Word" "BreakPoint at: ' [ vocabulary (sp) ]  word '" "Set" "" ""
\
\ : "debug-word   ( a1 n1 -- )
\                 ed-name place                   \ the name we want debugged
\                 ed-response off                 \ clear return result
\                 0 WM_SETBP win32forth-message
\                 ed-response @ 0=
\                 IF   z" Failed to set BreakPoint!" zMessageBox
\                 THEN
\                 ed-response @                   \ browse mode it BP is set
\                 IF   debug-buttons
\                 THEN ;
