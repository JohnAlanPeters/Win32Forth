\ $Id: Ed_Remote.F,v 1.8 2011/06/25 15:45:24 georgeahubert Exp $
\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 60    Message support from Win32Forth, allows files to be opened remotely
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\
\ Message support from Win32Forth, allows files to be opened remotely
\ also needed for debug support

: remote-window ( -- )
        cursor-line 2 - VPosition: edit-window
        refresh-screen ;

: remote-open   { addr flag \ ed-line ed-filename -- }
                \ flag: 1=edit 2=browse 3=watch
                max-path localalloc: ed-filename
                addr @ to ed-line
                addr cell+ count ed-filename place
\ ???        ed-ptr 0= ?EXIT                 \ leave if shared memory not inited
                >E
                flag 3 <>
                if SetForegroundWindow: self then
\ ??? SW_RESTORE Show: self

\ ??? open the file only if it exists

                ed-filename  uppercase count "to-pathend"
                cur-filename uppercase count "to-pathend" compare 0=
                \ only move cursor if we are not near the correct location already
                IF      ed-line 1- 0max cursor-line dup screen-rows 4 - + between 0=
                        IF      ed-line 1- 0max to cursor-line
                                remote-window
                        THEN
                ELSE    ed-filename count "already-open? >R
                        ed-filename count "+open-text
                        ed-filename count "to-pathend"
                        cur-filename count "to-pathend" compare 0=
                        IF      R@
                                if flag 2 = to browse? then      \ browsing?
                                ed-line 1- 0max to cursor-line
                                remote-window
                        THEN
                        R>DROP

                then
                Refresh: EditorWindow
                refresh-screen
                RefreshCursor: DocWindow
                EditMode: Win-EdToolbar ;

: remote-word   { addr \ ed-line ed-column -- }
\ ???           ed-ptr 0= ?EXIT                     \ leave if shared memory not inited
                addr @       to ed-line
                addr cell+ @ to ed-column
                browse? 0= if browse-toggle then
                ed-line @ 1- 0max to cursor-line
                ed-column @  0max to cursor-col
                highlight-word
                line-cur cursor-line screen-rows 4 - - 0max cursor-line between 0=
                IF      cursor-line screen-rows 2 - 2/ -
                        VPosition: edit-window
                THEN
                refresh-screen
                RefreshCursor: DocWindow
                EditMode: Win-EdToolbar ;

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
                  w32fWinEd  OF
                     CASE
                        ED_OPEN_EDIT   OF drop 1 remote-open    -1 ENDOF
                        ED_OPEN_BROWSE OF drop 2 remote-open    -1 ENDOF
                       2drop 0 swap
                     ENDCASE
                  ENDOF
                  3drop 0 swap
                ENDCASE ; is HandleForthMsg

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 61    Automatic save of edit changes after a specifiable number of minutes
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:M WM_TIMER     ( h m w l -- res )
        over SAVE_TIMER =
        IF      SAVE_TIMER hWnd Call KillTimer drop
                save-text
        THEN    0 ;M

;Object

: "find-label   ( a1 n1 -- )
        2dup InsertString: findComboEdit
        "CLIP" find-buf place
        Home: DocWindow
        0 to cursor-col
        TRUE to find-label?
        find-text-again         \ then try to find it
        FALSE to find-label?
        line-cur cursor-line 1 - max to line-cur
        no-highlight  ;
