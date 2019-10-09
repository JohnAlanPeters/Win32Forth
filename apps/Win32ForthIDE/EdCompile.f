\ $Id: EdCompile.f,v 1.11 2010/07/11 02:45:17 ezraboyce Exp $

\    File: EdCompile.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, Juni 27 2004 - dbu
\ Updated: Dienstag, Juni 29 2004 - dbu

\ -----------------------------------------------------------------------------
\ Send keystrokes to the Forth console
\ -----------------------------------------------------------------------------

: "Forth ( a1 n1 -- )   \ send a string to the console
        bounds
        ?do  i c@ msgpad c!
             msgpad 1 WM_KEY w32fForth Sendw32fMsg drop
             0 ms \ release control to OS for a moment
        loop
        0x0D msgpad c!
        msgpad 1 WM_KEY w32fForth Sendw32fMsg drop ;  \ send CR to execute the string

\ -----------------------------------------------------------------------------
\ Compile file or selection in the Forth console
\ -----------------------------------------------------------------------------

:noname ( addr n -- )   \ compile a file
        { \ load$ file$ -- }
	MAXSTRING LocalAlloc: load$
        MAXSTRING LocalAlloc: file$
        file$ place

        0 0 ExecForth drop               \ launch forth or set it in front

        s" chdir '" load$ place
        file$ COUNT "path-only" load$ +place
        s" '" load$ +place
        load$ COUNT "Forth               \ make file directory active
        s" FLOAD '" load$ place
        file$ COUNT load$ +place
        s" '" load$ +place
        load$ COUNT "Forth               \ compile the source file
        ; is Compile-File

: Compile-Selection	 ( -- )
	IsEditWnd? not ?exit
	GetSelectionEnd: CurrentWindow GetSelectionStart: CurrentWindow -
	if   Copy: CurrentWindow
             0 0 ExecForth drop               \ launch forth or set it in front
\ 200 ms
	     0 0 WM_PASTELOAD w32fForth Sendw32fMsg drop
200 ms
             0x0D msgpad c!
             msgpad 1 WM_KEY w32fForth Sendw32fMsg drop \ send CR to execute the string
	then ; IDM_COMPILE_SELECTION SetCommand

: Compile-Line	{ \ buf$ -- }
		IsEditWnd? not ?exit
                GetCurrentPos: CurrentWindow
                LineFromPosition: CurrentWindow
                LineLength: CurrentWindow dup 2 - 0 <= 	\ if line doesn't have a length?
                if	drop exit
                then	1+ dup LocalAlloc: buf$
                buf$ GetCurLine: CurrentWindow drop
                buf$ zcount copy-clipboard
                0 0 ExecForth
	        0 0 WM_PASTELOAD w32fForth Sendw32fMsg drop
		200 ms
		0x0D msgpad c!
		msgpad 1 WM_KEY w32fForth Sendw32fMsg drop \ send CR to execute the string
		; IDM_COMPILE_LINE SetCommand


