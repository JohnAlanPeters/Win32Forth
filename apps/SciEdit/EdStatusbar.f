\ $Id: EdStatusbar.f,v 1.7 2006/05/17 20:12:49 rodoakford Exp $

\    File: EdStatusbar.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, Juli 04 2004  - dbu
\ Updated: Mittwoch, Juli 28 2004 - dbu
\
\ Statusbar support for SciEdit

cr .( Loading Scintilla Statusbar...)

needs StatusBar.f

\ ------------------------------------------------------------------------------
\ the status bar
\ ------------------------------------------------------------------------------
:Object ScintillaStatusbar  <Super MultiStatusbar

create MultiWidth 60 , -1 , \ width of statusbar parts
create SingleWidth -1 , \ width of statusbar parts

2 constant MultiParts
0 constant EdPart
1 constant LinePart

:M SetMulti:    ( -- )
                MultiWidth MultiParts SetParts: self
                ;M

:M SetSingle:   ( -- )
                SingleWidth 1 SetParts: self
                ;M

:M Start:       ( Parent -- )
                Start: super
                SetMulti: self
                ;M

:M Clear:	( -- )
                z"  " EdPart   SetText: self
                z"  " LinePart SetText: self ;M

: SetHtmlView	( -- )
		Clear: self
                z"  HTML view" EdPart SetText: self ;

: SetEditView	( -- )
		?BrowseMode: ActiveChild
		if   z"  Browsing"
		else z"  Editing"
		then EdPart SetText: self

		GetLineCount: ActiveChild GetCurrentLine: ActiveChild 1+
                s" Line: " pad place (.) pad +place
                s"  of " pad +place (.) pad +place

		?BrowseMode: ActiveChild
		if   s"  - Use Rightclick to go to the source of the selected definition and CTRL+Rightclick to go back."
                     pad +place
		then pad +null pad 1+ LinePart SetText: self ;

:M Update:	( -- )
                base @ >r decimal

		ActiveChild 0=
		if   Clear: self
		else GetFileType: ActiveChild FT_SOURCE =
		     if   SetEditView
		     else SetHtmlView
		     then
		then

                r> base ! ;M

:M Show:	( f -- )
		if   SW_SHOW Show: super
                else SW_HIDE Show: super
                then ;M

;Object

: UpdateStatusBar ( -- )
		ActiveChild
		if   UpdateStatusBar: ActiveChild
		else Clear: ScintillaStatusbar
		then ;
