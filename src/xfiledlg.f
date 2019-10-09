\ $Id: xfiledlg.f,v 1.3 2005/08/29 15:56:28 dbu_de Exp $
\ load print/open replacements for xcalls

cr .( Loading Filedialog Functions...)

anew -xfiledlg.f

\ ------------------- Common Open/Save/New Dialog funcs ----------------------

WINLIBRARY COMDLG32.DLL

internal

1 PROC GetOpenFileName      as fdlg-open  ( addr -- rc )
1 PROC GetSaveFileName      as fdlg-save  ( addr -- rc )
1 PROC CommDlgExtendedError

create ofn-struct 19 cells , 22 CELLS allot       \ OPENFILENAME struct
\ This struct can be 22 cells for Windows 2000/XP, but NT or less demands 19?
\ Lowest common denominator - have gone for 19.

: fdlg-filter ( abs-addr -- abs-addr )       \ change all | to \0 in filter
        dup
        begin dup c@ ?dup                    \ fetch char
          while                              \ if not end of string
            [char] | = if 0 over c! then     \ make a \0
            char+                            \ next char
          repeat drop                        \ loose addr
        ;

: fdlg-build    ( filename diraddr titleaddr specaddr owner -- )
        ofn-struct lcount erase                       \ clear structure
        ofn-struct cell+   !                          \ save owner in hwnd
        fdlg-filter                                   \ modify filter
        ofn-struct 3  cells+ !                        \ save filter in filter string
        1 ofn-struct 6  cells+ !                      \ filterindex=1
        ofn-struct 12 cells+ !                        \ save title
        ofn-struct 11 cells+ !                        \ save initial dir
        1+ ofn-struct 7 cells+ !                      \ save initial filename
        maxcounted  ofn-struct  8 cells+ !            \ file length
        ;

: fdlg-getfile  ( -- filename )                  \ fetch filename
        ofn-struct 7 cells+ @                    \ fetch returned filename
        ;

: fdlg-adjfile  ( -- filename )                  \ adjust filename returned
        fdlg-getfile                             \ fetch returned filename
        dup maxcounted 0 scan drop               \ find end of string
        over - over 1- c! 1-                     \ adjust filename to cstr
        ;

: fdlg-nofile   ( -- filename )                  \ return null filename
        fdlg-getfile                             \ fetch returned filename
        1- 0 over c!                             \ null string
        ;

: fdlg-openf    ( -- )                       \ set open flags in struct
        [ OFN_PATHMUSTEXIST OFN_FILEMUSTEXIST OR OFN_HIDEREADONLY OR OFN_SHAREAWARE OR ] LITERAL
        ofn-struct 13 cells+ W!                       \ flags
        ;

: fdlg-newf    ( -- )                       \ set open flags in struct
        [ OFN_PATHMUSTEXIST OFN_HIDEREADONLY OR OFN_SHAREAWARE OR ] LITERAL
        ofn-struct 13 cells+ W!                       \ flags
        ;

: fdlg-savef    ( -- )                       \ set save flags in struct
        [ OFN_OVERWRITEPROMPT OFN_HIDEREADONLY OR ] LITERAL
        ofn-struct 13 cells+ W!                       \ flags
        ;

: fdlg-call     ( xt -- filename )               \ call GetxxxxFileName
        ofn-struct swap execute
        if fdlg-adjfile                          \ return filename
        else call CommDlgExtendedError
          ?dup if ." Error: GetxxxxFileName failed RC=0x" h.
            abort
          else
            fdlg-nofile                          \ no file to return
          then
        then
        ;

: open-dialog   ( filename diraddr titleaddr specaddr owner -- filename )
        fdlg-build                               \ build ofn-struct
        fdlg-openf                               \ set open flags
        ['] fdlg-open fdlg-call                  \ call dialog
        ;

                                        \ rls February 4th, 2002 - 5:47
: open-dialog2  ( filterindx filenam diradr titleadr specadr owner -- filename )
        fdlg-build
        ofn-struct 6 cells+ !                    \ set filter index
        fdlg-openf                               \ set open flags
        ['] fdlg-open fdlg-call                  \ call dialog
        ;

: save-dialog   ( filename diraddr titleaddr specaddr owner -- filename )
        fdlg-build
        fdlg-savef                               \ set save flags
        ['] fdlg-save fdlg-call                  \ call dialog
        ;

: save-dialog2  ( filterindx filename diraddr titleaddr specaddr owner -- filename )
        fdlg-build
        ofn-struct 6 cells+ !                    \ set filter index
        fdlg-savef                               \ set save flags
        ['] fdlg-save fdlg-call                  \ call dialog
        ;

: new-dialog    ( filename diraddr titleaddr specaddr owner -- filename )
        fdlg-build                               \ build ofn-struct
        fdlg-newf                                \ set new flags
        ['] fdlg-open fdlg-call                  \ call dialog
        ;

                                \ rls February 4th, 2002 - 20:18
: new-dialog2   ( filterindex filename diraddr titleaddr specaddr owner -- filename )
        fdlg-build
        ofn-struct 6 cells+ !                    \ set filter index
        fdlg-newf                                \ set new flags
        ['] fdlg-open fdlg-call                  \ call dialog
        ;

external 

: get-filter-Index   ( -- n )
        ofn-struct 6 cells+ @                    \ get filter index
        ;

internal

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ File dialog Class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class FileDialogs      <Super  Object

max-handle bytes szFile
max-handle bytes szDir
int szFilter
int szTitle

:M ClassInit:   ( -- )
        ClassInit: super
        0 szDir !
        0 szFile !
        here 1+ to szTitle  ,"text"
        max-handle here szTitle - - allot       \ extend to max string
        here 1+ to szFilter ,"text"             \ lay in filter, then
        max-handle here szFilter - - allot      \ extend to max string
        ;M

\ Changed to allow Filenames and path's not only in uppercase
\ August 31st, 2003 - 12:58 dbu (SF-ID 745382)
:M SetDir:      ( a1 n1 -- )            \ set the dialog directory string
        max-handle 2 - min szDir place  \ lay in the directory
        szDir +NULL                     \ null terminate
\       szDir count upper               \ make path uppercase - dbu
        szDir ?-\                       \ remove trailing \
        ;M

:M GetDir:      ( -- a1 n1 )    \ get the current dialog directory string
        szDir count
        ;M

:M SetTitle:    ( a1 n1 -- )
        szTitle 1- place        \ lay in new string
        szTitle 1- +NULL        \ null terminate it
        ;M

\ a new file filter string would be in the following format, with vertical
\ bars separating filter name from filter spec, and between filter spec
\ and succeeding filter names.
\ A maximum of 255 characters is allowed for the total filter specs string
\ s" Forth Files (*.f)|*.f|Text Files (*.txt)|*.txt|All Files (*.*)|*.*|"

:M SetFilter:   ( a1 n1 -- )            \ set new file filter spec
        szFilter 1- place       \ lay in new string
        szFilter 1- +NULL       \ null terminate it
        ;M

:M GetFilter:   ( -- a1 n1 )            \ return current file filter string
        szFilter 1- count
        ;M

\ Changed to allow Filenames and path's not only in uppercase
\ August 31st, 2003 - 12:58 dbu (SF-ID 745382)
: run-dialog    ( owner_handle dialog-func-cfa -- a1 )
        2>r
        szFile count "to-pathend" szFile place
        szFile +NULL
        szFile           \ takes a counted string for filename
        szDir    1+ 
        szTitle     
        szFilter    
        2r> execute 
        dup count "path-only" szDir place ;

;Class

EXTERNAL

:Class FileNewDialog    <Super  FileDialogs

:M Start:       ( owner_handle -- a1 )
        ['] new-dialog run-dialog
        ;M

:M Start2:      ( filterindex owner_handle -- a1 )
        ['] new-dialog2 run-dialog
        ;M

;Class

:Class FileOpenDialog   <Super  FileDialogs

:M Start:       ( owner_handle -- a1 )
        ['] open-dialog run-dialog
        ;M

:M Start2:      ( filterindex owner_handle -- a1 )
        ['] open-dialog2 run-dialog
        ;M

;Class

:Class FileSaveDialog   <Super  FileDialogs

:M Start:       ( owner_handle -- a1 )
        ['] save-dialog run-dialog
        ;M

:M Start2:      ( filterindex owner_handle -- a1 )
        ['] save-dialog2 run-dialog
        ;M

;Class

module
