\ $Id: editor_io.f,v 1.9 2008/09/02 07:01:21 camilleforth Exp $
\ Editor_io.F
\ Moved here form Mapfile.f

cr .( Loading Editor-io.f : communication between editor & console...)

anew -Editor_io.F

\ ----------------------------------------------------------------------------------------
\ Communication beetween the Editor (e.g. the Win32ForthIDE) and the Console window.
\ ----------------------------------------------------------------------------------------

INTERNAL
EXTERNAL
IN-APPLICATION

create msgpad maxstring 2 * allot \ data area used by messages

: editor-present? ( -- flag ) \ true flag if editor is present (running)
                w32fEditor IsRunning? ;


INTERNAL

IN-SYSTEM

LOADED? debug.f [IF]

: do-inquire    { addr -- }
\ *G Respond to an inquiry from the editor : addr contain vars to EVALUATE
\ ** and a WM_RESPONSE message (vars contents) is sent back
                [ also bug ]
                msgpad off
                here   here-save     MAXSTRING move
                pocket pocket-save   MAXSTRING move
                source tib-save swap MAXSTRING min move \ save SOURCE buffer
                (source) 2@ 2>r >in @ >r                \ save SOURCE and >IN
                sp@ >r depth >r
                addr count ['] evaluate catch
                if      beep
                else    depth r@ - 0max dup msgpad !
                        32 min 0                        \ no more than 32 data items
                        ?do     msgpad i 1+ cells+ !    \ move results in
                        loop
                then
                r>drop r> sp!                           \ restore stack depth
                r> >in ! 2r> (source) 2!                \ restore SOURCE and >IN
                tib-save source move                    \ restore SOURCE buffer
                pocket-save pocket MAXSTRING move
                here-save   here   MAXSTRING move
                [ previous ]
                msgpad 33 cells ED_RESPONSE w32fEditor Sendw32fMsg drop ;

: db-pushkey    ( c1 -- )
\ *G Push a key to the console window during debugging.
                in-breakpoint?
                if   pushkey
                else drop beep
                then ;

: do-set-breakpoint { addr \ bp$ ed-name -- result }
\ *G Set breakpoint to a word from editor (eg: win32ForthIDE)
\ ** Result : 0=failure  -1=ok
                MAXSTRING LocalAlloc: bp$
                MAXSTRING LocalAlloc: ed-name
                addr count ed-name place
                context @ >r                \ save context vocabulary
                ed-name count bl skip 2dup bl scan ?dup
                if      2dup 2>r nip - bp$ place
                        bp$ anyfind
                        if      execute
                                2r> bl skip bp$ place
                                bp$ anyfind
                        else    2r> 2drop
                                FALSE
                        then
                else    ed-name anyfind
                then
                if      unbug               \ remove any previous BP
                        remote-debug        \ set the breakpoint
                        0<> dup             \ non zero=success
                        if   with-source    \ enable source viewing
                        then
                else    drop                \ couldn't find it
                        0                   \ 0=failure
                then
                dup 0= if beep then
                r> context !                \ restore the context vocabulary
                ;

EXTERNAL
IN-APPLICATION
defer paste-load ' noop is paste-load

[ENDIF]


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\   primitive utilities to support VIEW, BROWSE, EDIT and LOCATE
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INTERNAL
EXTERNAL
IN-APPLICATION

INTERNAL
IN-SYSTEM

: do-line-file  ( -- addr len )
                cur-line @ msgpad !
                cur-file count "path-file drop dup>r msgpad cell+ place
                msgpad r> 1+ cell+ ;

: do-edit       ( -- )
                0 0 ExecEditor ?exit
                do-line-file ED_OPEN_EDIT w32fEditor Sendw32fMsg drop ;

: do-browse     ( -- )
                0 0 ExecEditor ?exit
                do-line-file ED_OPEN_BROWSE w32fEditor Sendw32fMsg drop ;

[defined] watched-cfa [if]
: do-watch      ( -- )
                0 0 ExecEditor drop                               \ launch or set on top

                watched-cfa >name nfa-count msgpad place          \ send name
                msgpad dup c@ 1+ ED_NAME w32fEditor Sendw32fMsg drop

                cur-line @ msgpad !                               \ send line & file
                cur-file count "path-file
                if 2drop cur-file count then
                dup 1+ >r msgpad cell+ place
                msgpad r> cell+ ED_WATCH w32fEditor Sendw32fMsg drop
                ;
[else]
: do-watch      ;
[then]

IN-APPLICATION

: [$edit]       { line_number file_name edit_cfa -- }
                \ works with blanks in filename
                file_name -1 <>
                if   file_name count bl skip "CLIP" cur-file place
                     line_number &linenum !  \ set the line# variables
                     line_number cur-line !
                     edit_cfa execute        \ execute the editor
                then ;

EXTERNAL

: $edit         ( line filename | dummy -1 -- )  \ W32F
\ *G Open the file, filename in the editor at line, in edit mode.
                ['] do-edit   [$edit] ;

: $browse       ( line filename | dummy -1 -- )  \ W32F
\ *G Open the file, filename in the editor at line, in browse mode.
                ['] do-browse [$edit] ;

INTERNAL
IN-SYSTEM

[defined] $watch [if]
: _$watch       ( line filename -- )
                ['] do-watch  [$edit] ;
' _$watch is $watch     \ $watch is used in debug.f to follow source
[then]



INTERNAL
IN-SYSTEM


: locate-height ( -- n1 )
                getcolrow nip 8 - 20 min ;

: locate-header ( -- n1 )
                locate-height 4 / ;

: $locate       ( line# filename | dummy -1 -- )
                { line# file$ \ loc$ locHdl lcnt -- }
                file$ ( 0< ) -1 = ?EXIT \ September 9th, 2003 - 15:18 dbu
                max-path LocalAlloc: loc$
                file$ $open abort" Couldn't open source file!"
                to locHdl
                0 to lcnt
                base @ >r decimal
                cls ." From file: " cur-file count type
                ."  At line: " line# . line# cur-line !
                cr horizontal-line
                line# locate-header - 0 max 0
                ?do     loc$ MAXCOUNTED locHdl read-line
                        abort" Read Error"
                        nip 0= ?leave
                        1 +to lcnt
                loop
                locate-height 0
                do      loc$ dup MAXCOUNTED locHdl read-line
                        abort" Read Error"
                        if      cols 1- min
                                1 +to lcnt
                                lcnt orig-loc =
                                if      horizontal-line
                                        type cr
                                        horizontal-line
                                else          type cr
                                then
                                getxy nip getcolrow nip 4 - >
                                ?leave
                        else    2drop leave
                        then
                loop    horizontal-line
                locHdl close-file drop
                r> base ! ;

EXTERNAL
IN-SYSTEM

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  12  Highlevel words used to view, browse and edit words and file
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: where         ( -<name>- )    \ tell me WHERE the source for a word is
                .viewinfo drop cur-line ! ;

\ synonym .v where                 \ made a colon def - [cdo-2008May13]
: .v            \ synonym of WHERE
                where ;

: locate        ( -<name>- )    \ show some source lines of word
                .viewinfo $locate ;

\ synonym l  locate            \ made a colon def - [cdo-2008May13]
\ synonym ll locate            \ made a colon def - [cdo-2008May13]
: l             \ synonym of locate
                locate ;
: ll            \ synonym of locate
                locate ;

: n             ( -- )          \ show the next bunch of lines
                cur-line @ locate-height 4 - + cur-file $locate ;

\ removed B because it's a valid HEX number
\ September 23rd, 2003 - 10:44 dbu
\ : b            ( -- )          \ show the previous bunch of lines
\                cur-line @ locate-height 4 - - 0 max cur-file $locate ;

: linelist      ( n1 -- )
                cur-file $locate ;

: view          ( -<name>- )    \ VIEW the source for a word
                .viewinfo $browse ;

\ synonym v view                   \ made a colon def - [cdo-2008May13]
\ synonym Vv view                  \ made a colon def - [cdo-2008May13]
: v             \ synonym of VIEW
                view ;
: vv            \ synonym of VIEW
                view ;

: ed            ( -<name>- )    \ EDIT the source for a word
                .viewinfo $edit ;

\ removed E because it's a valid HEX number
\ September 23rd, 2003 - 10:44 dbu
\ synonym e ed                    \ E is a synonym for EDIT

: edit          ( -<filename>- ) \ EDIT a particular file
                0 word c@
                if      cur-line off
                        0 pocket
                else    cur-line @ cur-file
                then    $edit ;

\ synonym z edit                   \ made a colon def - [cdo-2008May13]
: z             \ synonym of EDIT
                edit ;

: browse        ( -<filename>- ) \ BROWSE a particular file
                0 word c@
                if      cur-line off
                        0 pocket
                else    cur-line @ cur-file
                then    $browse ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\   15  Linkage to automatically invoke the editor on a compile error
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: _edit-error   ( -- )
                loadline @ loadfile $edit ;

: autoediton    ( -- )  \ link into deferred auto edit on error word
                ['] _edit-error is edit-error ;

autoediton

: autoeditoff   ( -- )  \ disable automatic edit on error
                ['] noop is edit-error ;


in-application

EXTERNAL



MODULE
