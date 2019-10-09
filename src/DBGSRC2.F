\ $Id: DBGSRC2.F,v 1.8 2008/09/02 07:01:20 camilleforth Exp $

\ DBGSRC2.F    Add Source Level Debugging to Win32Forth    by Tom Zimmer

cr .( Loading DbgSrc2.f : Source level debugging part 2...)

INTERNAL

create SrcInfoName MAXSTRING allot
       SrcInfoName off

: _DoLoadInfo  { \ temp$ -- }    \ load the debugger information from disk
        MAXSTRING LocalAlloc: temp$
        temp$ off
        UnPointer> SrcInfoPtr           \ release any memory already allocated
        app-size SizeOf!> SrcInfoPtr    \ set the new size
        1 SrcInfoPtr !                  \ mark as not loadable initiallly
        SrcInfoName count                      r/w open-file dup
        if      2drop
                SrcInfoName count "to-pathend" r/w open-file
        then
        dup
        if      2drop
                &prognam count "path-only"     temp$ place
                                               temp$ ?+\
                SrcInfoName count "to-pathend" temp$ +place
                temp$ count                    r/w open-file
        then
        0=
        if      >r
                SrcInfoPtr SrcInfoCnt cells r@ read-file 2drop
                r> close-file
        then    drop ;

' _DoLoadInfo is DoLoadInfo

EXTERNAL

: LoadInfo      ( -<name>- )
        /parse-word count SrcInfoName place
        _DoLoadInfo ;

: SaveInfo      ( -<name>- )    \ save the debugger information to disk
        /parse-word count SrcInfoName place
        SrcInfoName count r/w create-file abort" Failed to create Info File"
        >r
        SrcInfoPtr SrcInfoCnt cells r@ write-file abort" Failed to write Info File"
        r> close-file drop ;

INTERNAL

: buf-type      ( a1 n1 -- )     msgpad  +place ;
: buf-emit      ( c1 -- )        msgpad c+place ;

also bug

: _word-watch   { ip@ -- }
                \ send line & column position in source of token being debugged
                \ sent to the IDE for highlighting the word in source
                with-source?                            \ if we want to show source
                editor-present? and                     \ and if editor is loaded
                if   SrcInfoPtr @ 0=
                     if      _DoLoadInfo
                     then
                     SrcInfoPtr @ -1 =               \ if its in memory
                     if   SrcInfoPtr SrcInfoCnt ip@ lscan
                          if   dup cell + @
                               ?dup            \ only if source is available
                               if   word-split msgpad cell+ ! \ ed-column
                                               msgpad !       \ ed-line
                                    msgpad 2 cells ED_WORD w32fEditor Sendw32fMsg drop
                               then
                          then drop
                     then
                then
                editor-present? 0= ?EXIT
                action-of type >r ['] buf-type is type
                action-of emit >r ['] buf-emit is emit

\               ed-dbgline off

                msgpad off
                .smax @ >r 3 .smax !    \ limit stack display to 3 items
                debug-.s                \ display stack
                r> .smax !              \ restore stack display limit
                0x0D emit               \ use CR as a separator
                .wordtype
                nesting @ 0max ?dup
                if   0 do ." |" loop space
                then
                                        \ display word to be executed
                debugging? >r true to debugging?
                ip@ dup @
\in-system-ok   .execution-class drop
                r> to debugging?
                                        \ if its EXECUTE, display target word
                ip@ @ execute?
                if   ." [ " stack-top .name ." ]"
                then
                r> is emit
                r> is type
                msgpad count 1+ ED_DEBUG w32fEditor Sendw32fMsg drop ;

' _word-watch is word-watch

: rst-type      ( a1 n1 -- )    msgpad 64 cells + +place ;
: rst-emit      ( c1 -- )       msgpad 64 cells + c+place ;

-1 value prev-return

: _stack-watch  { \ stack-cnt -- }
                \ send data and return stack to remote debugger (IDE) for display
                editor-present? 0= ?EXIT
                1 to stack-cnt                       \ data stack
                msgpad 64 cells erase                \ null init
                depth msgpad !                     \ set the counter
                depth 0>
                if      depth 63 min
                        BEGIN   dup pick msgpad stack-cnt cells+ !
                                1 +to stack-cnt
                                1- dup 0=
                        UNTIL   drop
                then
                prev-return return-top -            \ if return stack has changed
                if      action-of type >r ['] rst-type is type
                        action-of emit >r ['] rst-emit is emit
                        msgpad 64 cells + off
                        return-top      \ if returnstack is set
                        if      return-top 1 cells +
                                rp0 @ return-top 12 cells + min
                                #dbg-rstack
                                return-top to prev-return
                        then
                        r> is emit
                        r> is type
                then
                msgpad 64 cells 2dup + c@ 1+ + ED_STACK w32fEditor Sendw32fMsg drop ;

previous

' _stack-watch is stack-watch

MODULE
