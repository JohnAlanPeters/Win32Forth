\ $Id: EdAbout.f,v 1.2 2006/05/07 06:34:26 dbu_de Exp $

\    File: EdAbout
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, Juli 04 2004  - dbu
\ Updated: Mittwoch, Juli 28 2004 - dbu

cr .( Loading About dialog...)

needs EdVersion.f

\ ------------------------------------------------------------------------------
\ the about dialog
\ ------------------------------------------------------------------------------

:Object about-sci-dialog       <SUPER dialog

IDD_ABOUT_FORTH forthdlg find-dialog-id constant template

create about-head
         z," SciEdit (Public Domain since June 2004)"

create about-msg1
        z," Version: " -null,
        sciedit_version# ((version)) +z",
        +z," \nCompiled: "
        sciedit-compile-version >date" +z",
        +z," , "
        sciedit-compile-version >time" +z", +z,"  "

create about-msg2
         z," Written in 2004 by: Dirk Busch (dbu)\n"
        +z," eMail: dirk@win32forth.org\n"
        +z," Contributions by\n"
        +z," Ezra Boyce and Rod Oakford\n"

create about-msg3
         z," This Editor is based on the: 'Scintilla source code edit control'."
        +z," See www.scintilla.org for more information about the control."

:M On_Init:     ( hWnd-focus -- f )
                about-head zcount IDD_ABOUT_HEAD  SetDlgItemText: self
                about-msg1 zcount IDD_ABOUT_TEXT  SetDlgItemText: self
                about-msg2 zcount IDD_ABOUT_TEXT2 SetDlgItemText: self
                about-msg3 zcount IDD_ABOUT_TEXT3 SetDlgItemText: self
                1 ;M

:M GetTemplate: ( -- template )
                template
                ;M

:M On_Command:  ( hCtrl code ID -- f1 )
                CASE
                IDCANCEL OF     0 end-dialog    ENDOF
                                false swap ( default result )
                ENDCASE ;M

;Object
