\ $Id: EdAbout.f,v 1.3 2011/07/26 20:29:55 georgeahubert Exp $

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
         z," Win32Forth IDE (Public Domain since June 2006)"

create about-msg1
        z," Version: " -null,
        sciedit_version# ((version)) +z",
        +z," \nCompiled: "
        sciedit-compile-version >date" +z",
        +z," , "
        sciedit-compile-version >time" +z",
        +z," \n\n"
        +z," Written in 2006 by: "
        +z," Dirk Busch, Ezra Boyce, George Hubert, "
        +z," Rod Oakford and some others."

create about-msg2
         z," This Win32Forth IDE based on:\n"
        +z," 'SciEdit' written by Dirk Busch,\n"
        +z," 'Project Manager' and 'ForthForm'\n both written by Ezra Boyce."

create about-msg3
         z," The Win32Forth IDE is using the:\n"
        +z," - 'Scintilla source code edit control' "
        +z," See www.scintilla.org for details.\n"
        +z," - 'FreeImage open source image library' "
        +z," See http://freeimage.sourceforge.net for details. "
        +z," FreeImage is used under the FreeImage Public License."

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
