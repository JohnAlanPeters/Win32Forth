\ $Id: Pl_About.f,v 1.4 2013/11/20 18:45:34 georgeahubert Exp $

\    File: Pl_About.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Samstag, April 16 2005 - dbu
\ Updated: Samstag, April 16 2005 - dbu

cr .( Loading About dialog...)

needs Pl_Version.f

\ ------------------------------------------------------------------------------
\ the about dialog
\ ------------------------------------------------------------------------------

:Object AboutPlayer4 <SUPER dialog

IDD_ABOUT_FORTH forthdlg find-dialog-id constant template

create about-head
         z," Player 4th - Version: " -null,
        player_version# ((version)) +z",
        
create about-msg1
         z," Written in 2005 by:\n"
        +z,"   Bruno Gauthier - bgauthier@free.fr\n"
        +z,"   Dirk Busch - dirk@win32forth.org\n"
        +z,"   Jos van de Ven - josv@wxs.nl\n"
        +z,"   Rod Oakford - rodoakford@yahoo.com"

create about-msg2
         z," This is a simple Audio- and Videoplayer\n"
        +z," based on the Windows 'Media Control Interface'."

create about-msg3
         z," This application was build with Win32Forth\n" 
        +z," Version " -null, version# ((version)) +z",
        +z," . See www.win32forth.org for\n"
        +z," more information about Win32Forth."

:M On_Init:     ( hWnd-focus -- f )
                about-head zcount IDD_ABOUT_HEAD  SetDlgItemText: self
                about-msg1 zcount IDD_ABOUT_TEXT  SetDlgItemText: self
                about-msg2 zcount IDD_ABOUT_TEXT2 SetDlgItemText: self
                about-msg3 zcount IDD_ABOUT_TEXT3 SetDlgItemText: self
                1 ;M

:M On_Command:  ( hCtrl code ID -- f1 )
                CASE
                IDCANCEL OF     0 end-dialog    ENDOF
                                false swap ( default result )
                ENDCASE ;M

:M Start:       ( -- f )
                Addr: Player4W template run-dialog ;M

;Object


 
