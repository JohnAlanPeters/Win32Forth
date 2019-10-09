\ $Id: Ed_Statbar.F,v 1.4 2006/05/14 10:40:24 dbu_de Exp $
\    File: Ed_Statbar.f
\  Author: Dirk Busch
\ Created: September 10th, 2003 - 12:20 dbu
\ Updated: September 10th, 2003 - 12:20 dbu
\ Statusbar for WinEd
\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 8     Simple Statusbar Class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

needs ExControls.f

:Object Win-EdStatusbar  <Super MultiStatusbar

create MultiWidth 125 , 250 , 400 , 580 , \ width of statusbar parts
create SingleWidth -1 ,                   \ width of statusbar parts

:M SetMulti:    ( -- )
        MultiWidth 4 SetParts: self ;M

:M SetSingle:   ( -- )
        SingleWidth 1 SetParts: self ;M

:M Start:       ( Parent -- )
        Start: super
        SetMulti: self
        ;M

;Object
