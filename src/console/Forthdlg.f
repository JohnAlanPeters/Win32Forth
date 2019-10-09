\ $Id: Forthdlg.f,v 1.3 2013/03/15 00:23:06 georgeahubert Exp $

cr .( Loading Forth System Dialogs...)

only forth also definitions

load-dialog FORTHDLG    \ load the dialogs for Forth

INTERNAL        \ start of non-user definitions

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ About Win32forth
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object about-forth-dialog <SUPER dialog

IDD_ABOUT_FORTH forthdlg find-dialog-id constant template

create about-head
        z," Win32Forth (Public Domain January 1994)"

create about-msg1
         z," Version: " -null,
        version# ((version)) +z",
        +z,"    "               \ some extra spaces for safety
        +z," \nCompiled: "
        compile-version >date" +z",
        +z," , "
        compile-version >time" +z",
        +z," \nContributors (up to V4.2):\n"
        +z,"    Andrew McKewan, Tom Zimmer, Jim Schneider,\n"
        +z,"    Robert Smith, Y. T. Lin, Andy Korsak"

create about-msg2
         z," Portions derived from:\n   F-PC Forth, Public Domain, November 1987\n"
        +z," Assembler 486ASM.F:\n   LGPL (c) September 1994, Jim Schneider \n"

create about-msg3
         z," Further development since V4.2 by:\n"
        +z,"    Ron Aaron, Ezra Boyce, Dirk Busch,\n"
        +z,"    George Hubert, Alex McDonald, John A Peters,\n"
        +z,"    Rainbow Sally, Jos v.d. Ven\n"
        +z,"    other's contributions acknowledged\n"

:M On_Init:     ( hWnd-focus -- f )
                about-head zcount IDD_ABOUT_HEAD  SetDlgItemText: self
                about-msg1 zcount IDD_ABOUT_TEXT  SetDlgItemText: self
                about-msg2 zcount IDD_ABOUT_TEXT2 SetDlgItemText: self
                about-msg3 zcount IDD_ABOUT_TEXT3 SetDlgItemText: self
                1 ;M

:M Start:       ( -- f )
                template run-dialog
                ;M

:M On_Command:  ( hCtrl code ID -- f1 )
                case
                IDCANCEL of     0 end-dialog    endof
                                false swap ( default result )
                endcase ;M

;Object

EXTERNAL

: about-win32forth ( -- )
                conhndl start: about-forth-dialog drop ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object page-up-dialog <SUPER dialog

IDD_PAGEUP forthdlg find-dialog-id constant template

:M Start:       ( parent-window -- n1 )       \ return size of image
                template run-dialog ;M

:M On_Command:  ( hCtrl code ID -- f1 )
                case
                IDCANCEL of     0 end-dialog    endof
                IDD_2UP  of     2 end-dialog    endof
                IDD_4UP  of     4 end-dialog    endof
                                false swap ( default result )
                endcase ;M

;Object

: page-up-setup ( -- )
                conhndl Start: page-up-dialog to #pages-up  ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Edit text dialog Class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class NewEditDialog    <Super  dialog

IDD_EDIT_DIALOG forthdlg find-dialog-id constant template

int szText
int szTitle
int szPrompt
int szDoit
int szCancel
int szOption
int OptionState

:M ClassInit:   ( -- )
                ClassInit: super
                here to szText   0 ,            \ null text string
                here to szTitle  ,"text"
                here to szPrompt ,"text"
                here to szDoit   ,"text"
                here to szCancel ,"text"
                here to szOption ,"text"
                ;M

:M On_Init:     ( hWnd-focus -- f )
\ Setting the title must be handled specially, since the dialog itself isn't
\ considered to be a dialog item
                szTitle  count                          SetText: self
                szText   count IDD_EDIT_TEXT            SetDlgItemText: self
                szPrompt count IDD_PROMPT_TEXT          SetDlgItemText: self
                szOption c@
                if      szOption count IDB_OPTION       SetDlgItemText: self
                        OptionState    IDB_OPTION       CheckDlgButton: self
                        TRUE
                else    FALSE
                then                   IDB_OPTION       ShowDlgItem: self
                szDoit   count dup
                if       2dup  IDOK                     SetDlgItemText: self
                then     2drop
                szCancel count dup
                if       2dup  IDCANCEL                 SetDlgItemText: self
                then     2drop
                1 ;M

:M Start:       ( counted_text_buffer parent -- f )
                swap to szText
                template run-dialog
                ;M

:M On_Command:  ( hCtrl code ID -- f1 ) \ returns 0=cancel,
                                        \ returns 1=option-off
                                        \ returns 2=option-on
                case
                IDOK     of     szText 1+ max-handle 2 - IDD_EDIT_TEXT GetDlgItemText: self
                                szText c!
                                IDB_OPTION IsDlgButtonChecked: self
                                dup to OptionState
                                1 and 1+ end-dialog    endof
                IDCANCEL of     0        end-dialog    endof
                                false swap ( default result )
                endcase ;M

:M SetOptionState: ( n -- )
		to OptionState ;M

;Class

MODULE          \ finish up the module

only forth also definitions

