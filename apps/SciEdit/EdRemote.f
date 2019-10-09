\ $Id: EdRemote.f,v 1.5 2008/08/03 10:56:41 camilleforth Exp $

\    File: EdRemote.f
\  Author: Dirk Busch
\ Created: Samstag, Juli 10 2004 - 10:16 dbu
\ Updated: Samstag, August 20 2005 - 12:35 dbu
\
\ Message support from Win32Forth, allows files to be opened remotely
\ also needed for debug support

false value ConsoleReady? \ true if the console is ready to accept char's from the editor

defer remote-open   ( wParam -- )  ' noop is remote-open
defer remote-word   ( -- )         ' noop is remote-word

/* ********************** Support for ForthForm *************************** */
\ August 20, 2005 - Ezra Boyce
WM_USER 256 + Constant FF_PASTE       \ must be same for ForthForm

: FFPasteSource ( -- )
                NewEditWnd NewFile: ActiveChild       \ start the window
                CanPaste: ActiveChild
                if   Paste: ActiveChild
                     ed-filename count SetText: ActiveChild
                     SetSavePoint: CurrentWindow           \ mark as unmodified
                     Update
                then ;
/* ************************ End ********************************************** */

: DebugMsg      ( wParam -- f ) \ handle debug support messages
                                \ returns true if the message wasn't handled
                true >r
                HandleW32FMsg?
                if    dup
                      CASE
                        ED_OPEN_EDIT   OF dup remote-open r>drop false >r ENDOF
                        ED_OPEN_BROWSE OF dup remote-open r>drop false >r ENDOF
                        ED_WATCH       OF dup remote-open r>drop false >r ENDOF
                        ED_WORD        OF remote-word     r>drop false >r ENDOF
                        ED_STACK       OF receive-stack   r>drop false >r ENDOF
                        ED_DEBUG       OF receive-debug   r>drop false >r ENDOF
                     endcase
                then drop r> ;

: ConsoleMsg    ( wParam -- f ) \ console start and termination
                                \ returns true if the message wasn't handled
                true >r
                CASE
                        ED_ALIVE       OF true  to ConsoleReady? r>drop false >r ENDOF
                        ED_SHUTDOWN    OF false to ConsoleReady? r>drop false >r ENDOF
                endcase r> ;

: ForthFormMsg  ( wParam -- f ) \ ForthForm
                                \ returns true if the message wasn't handled
                true >r
                CASE
                        FF_PASTE       of FFPasteSource r>drop false >r endof \ August 20, 2005 - EAB
                endcase r> ;

:noname         { hndl msg wParam lParam -- }   \ respond to Win32Forth messages
                ed-ptr 0= ?EXIT      \ leave if shared memory not inited

                wParam DebugMsg
                if   wparam ConsoleMsg
                     if   wparam ForthFormMsg
                     then
                then ; is HandleW32FMsg

:noname         ( -- )
                ed-ptr 0= ?EXIT      \ leave if shared memory not inited
                ed-window @ call IsWindow dup
                GetHandle: Frame ed-window ! \ set our window handle
                ; is init-shared-type

:noname         ( -- )
                ed-ptr 0= ?EXIT \ leave if shared memory not inited
                0 ed-window !  \ clear our window handle
                ; is uninit-shared-type

: IsHtmlFile?   ( adr len -- f )
                ".ext-only" 2dup upper
                2dup s" .HTM"  compare 0= -rot s" .HTML" compare 0= or ;

:noname         { wParam -- }
                ed-ptr 0= ?EXIT \ leave if shared memory not inited

                wParam ED_WATCH <>
                IF   SetForegroundWindow: Frame
                THEN \ SW_RESTORE Show: Frame

\               ed-filename  uppercase count "to-pathend"
\               cur-filename uppercase count "to-pathend" compare 0=
false
                \ only move cursor if we are not near the correct location already
                IF \  ed-line @ 1- 0max cursor-line dup screen-rows 4 - + between 0=
                   \  IF   ed-line @ 1- 0max to cursor-line
                   \       wParam remote-window
                   \  THEN
                ELSE
                     \ open the file only if it exist (Samstag, August 20 2005 dbu)
                     ed-filename count file-exist?
                     if   ed-filename count
                          IsHtmlFile?
                          if   ed-filename count (OpenHtmlFile)
                          else NewRemoteChild
                               ed-line @ ed-filename count LoadHyperFile: ActiveRemote \ load the file
                               wParam ED_OPEN_BROWSE = SetBrowseMode: ActiveRemote  \ browsing?
                          then
                     then
                THEN Update
                ; is remote-open

:noname         ( -- )
                ed-ptr 0= ?EXIT \ leave if shared memory not inited
                ActiveRemote 0= ?exit
                ?BrowseMode: ActiveRemote 0=
                IF   true SetBrowseMode: ActiveRemote
                then

                ed-line @ 1- 0max GotoLine: ActiveRemote
                ed-column @ 0max GotoColumn: ActiveRemote

                HighlightWord: ActiveRemote
                SetFocus: ActiveRemote

                Update
                ; is remote-word
