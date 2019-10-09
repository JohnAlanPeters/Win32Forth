\ $Id: EdRemote.f,v 1.13 2011/05/25 20:53:09 georgeahubert Exp $

\    File: EdRemote.f
\  Author: Dirk Busch
\ Created: Samstag, Juli 10 2004 - 10:16 dbu
\ Updated: Samstag, August 20 2005 - 12:35 dbu
\
\ Message support from Win32Forth, allows files to be opened remotely
\ also needed for debug support

: ConsoleReady? ( -- flag )
                w32fForth IsRunning? ;

: IsHtmlFile?   ( adr len -- f )
                ".ext-only" 2dup upper
                2dup s" .HTM"  compare 0= -rot s" .HTML" compare 0= or ;

: IsProjectFile?   ( adr len -- f )
                ".ext-only" 2dup upper
                s" .FPJ"  compare 0= ;

: remote-open   { addr flag \ ed-line ed-filename -- }
                \ flag: 1=edit 2=browse 3=watch
                max-path localalloc: ed-filename
                addr @ to ed-line
                addr cell+ count ed-filename place

                flag 3 <>
                if SetForegroundWindow: Frame then

                \ open the file only if it exists (Samstag, August 20 2005 dbu)
                ed-filename count file-exist?
                if   ed-filename count
                     IsProjectFile?
                     if   ed-filename count (open-project)
                     else
                     ed-filename count IsHtmlFile?
                          if   ed-filename count (OpenHtmlFile)
                          else \ avoid duplicate files loaded when compiling and error occurs
                               ed-filename count (OpenRemoteFile) \ switch if already loaded
                               ed-line GotoLine: ActiveRemote
\                               ed-line ed-filename count LoadHyperFile: ActiveRemote \ load the file
                               flag 2 = SetBrowseMode: ActiveRemote  \ browsing?
                          then
                     then
                then
                Update
                2drop ;

: remote-word   { addr \ ed-line ed-column -- }
                addr @       to ed-line
                addr cell+ @ to ed-column
                ActiveRemote 0= ?exit
                ?BrowseMode: ActiveRemote 0=
                if true SetBrowseMode: ActiveRemote then

                ed-line 1- 0max  GotoLine: ActiveRemote
                ed-column 0max   GotoColumn: ActiveRemote
                HighlightWord: ActiveRemote
                SetFocus: ActiveRemote
                Update ;



:noname         ( hwnd msg wparam lparam -- result )
                \ messages from other applications to be handled by IDE
                Decodew32fMsg ( hwnd msg wparam lparam -- addr siz w32fmsg w32fAppIDSender )
                CASE
                  w32fForth  OF
                     CASE
                        ED_OPEN_EDIT   OF drop 1 remote-open    -1 ENDOF
                        ED_OPEN_BROWSE OF drop 2 remote-open    -1 ENDOF
                        ED_WATCH       OF drop 3 remote-open    -1 ENDOF
                        ED_WORD        OF drop remote-word      -1 ENDOF
                        ED_STACK       OF drop receive-stack    -1 ENDOF
                        ED_DEBUG       OF drop receive-debug    -1 ENDOF
                        ED_RESPONSE    OF drop receive-response -1 ENDOF
                        ED_NAME        OF drop receive-name     -1 ENDOF
                       2drop 0 swap
                     ENDCASE
                  ENDOF
                  w32fIDE    OF
                     CASE
                        ED_OPEN_EDIT   OF drop 1 remote-open    -1 ENDOF
                        ED_OPEN_BROWSE OF drop 2 remote-open    -1 ENDOF
                       2drop 0 swap
                     ENDCASE
                  ENDOF
                  3drop 0 swap
                ENDCASE ; is HandleW32FMsg
\ ??? ed-open-edit and browse are not really debugger messages : separate them ?
\ ??? but ed-open-edit in case of watch is one ...

