\ $Id: EdStatusbar.f,v 1.6 2008/06/30 02:59:04 ezraboyce Exp $

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

create MultiWidth 60 , 700 , -1 , \ width of statusbar parts
create SingleWidth -1 , \ width of statusbar parts

3 constant MultiParts
0 constant EdPart
1 constant LinePart
2 constant projpart

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
                z"  " LinePart SetText: self
                ;M

: SetHtmlView	( -- )
		Clear: self
                z"  HTML" EdPart SetText: self ;

: SetEditView	( -- )
		?BrowseMode: ActiveChild
		if   z"  Browsing"
		else z"  Editing"
		then EdPart SetText: self

		GetLineCount: ActiveChild GetCurrentLine: ActiveChild 1+
                s" Line: " pad place (.) pad +place
                s"  of " pad +place (.) pad +place

                s"   Column: " pad +place
                GetColumn: ActiveChild (.) pad +place

		?BrowseMode: ActiveChild
		if   s"  - Use Rightclick to go to the source of the selected definition and CTRL+Rightclick to go back."
                     pad +place
		then pad +null pad 1+ LinePart SetText: self ;

: SetBinaryView ( -- )
		Clear: self
                z"  BINARY" EdPart SetText: self ;

: SetBitmapView ( -- )
		Clear: self
                z"  BITMAP" EdPart SetText: self ;

:M Update:	( -- )
                base @ >r decimal

		ActiveChild 0=
		if   Clear: self
		else GetFileType: ActiveChild
                     case
                        FT_SOURCE of SetEditView   endof
                        FT_HTML   of SetHtmlView   endof
                        FT_BINARY of SetBinaryView endof
                        FT_BITMAP of SetBitmapView endof
                     endcase
		then  GetProjectFileName: TheProject ?dup
		if	s" Project File: " pad place "to-pathend" pad +place pad +null
		else  drop pad off
		then  pad 1+ projpart SetText: self

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
		then Update: ScintillaStatusbar ;
