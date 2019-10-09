\ $Id: About.f,v 1.1 2008/04/30 15:58:01 dbu_de Exp $

:Object AboutSolipion <SUPER dialog

IDD_ABOUT_FORTH forthdlg find-dialog-id constant template

create about-head
         z," Solipion Version: 2.0"

create about-msg1
         z," Written 2005 by:\n"
        +z,"   Bruno  Gauthier\n"
        +z,"   eMail: bgauthier@free.fr\n"
        +z,"   http:\\bgauthier.free.fr"

create about-msg2
         z,"   \n"
        +z,"   \n"
        +z,"   \n"
        +z,"   "

create about-msg3
         z," This is a Morpion Solitaire Game."


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
                Addr: SolipionW template run-dialog ;M

;Object

: about-solipion ( -- )
        start: AboutSoliPion ;
