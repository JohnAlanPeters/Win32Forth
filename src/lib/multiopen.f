\ $Id: multiopen.f,v 1.6 2006/10/13 03:50:29 ezraboyce Exp $

anew -multiopen.f

INTERNAL
\ Multi File Open Dialog

\- ofn-struct  create ofn-struct 19 cells , 22 CELLS allot       \ OPENFILENAME struct

2048 constant  /szFile  \ Was 2048

#ifndef fdlg-filter

: fdlg-filter ( abs-addr -- abs-addr )       \ change all | to \0 in filter
        dup                                  \ back to rel address
        begin dup c@ ?dup                    \ fetch char
          while                              \ if not end of string
            [char] | = if 0 over c! then     \ make a \0
            char+                            \ next char
          repeat drop                        \ loose addr
        ;
#endif

: mfdlg-build    ( filename diraddr titleaddr specaddr owner -- )
        ofn-struct lcount erase                       \ clear structure
        ofn-struct cell+   !                          \ save owner in hwnd
        fdlg-filter                                   \ modify filter
        ofn-struct 3  cells+ !                        \ save filter in filter string
        ofn-struct 12 cells+ !                        \ save title
        ofn-struct 11 cells+ !                        \ save initial dir
        ofn-struct 7 cells+ !                         \ save initial filename
        /szFile  ofn-struct  8 cells+ !               \ file length
        ofn-struct 6  cells+ !                        \ filterindex
        [ OFN_PATHMUSTEXIST   OFN_FILEMUSTEXIST OR  nostack1
        OFN_HIDEREADONLY OR OFN_SHAREAWARE OR
        OFN_ALLOWMULTISELECT OR OFN_EXPLORER OR ]  LITERAL
        ofn-struct 13 cells+ !                       \ flags
        ;

: mfdlg-call     ( -- filename )               \ call GetxxxxFileName
        ofn-struct call GetOpenFileName >r
        ofn-struct 7 cells+ @ r> 0=
        if      call CommDlgExtendedError ?dup
                if      ." Error: GetxxxxFileName failed RC=0x" h.
                        abort
                else    dup off
                then
        then    ;

: mopen-dialog   ( filterndx filename diraddr titleaddr specaddr owner -- filename )
        mfdlg-build                               \ build ofn-struct
        mfdlg-call                  \ call dialog
        ;

EXTERNAL

:Class MultiFileOpenDialog   <Super  Object

/szFile bytes szFile
int fcnt    \ number of selected files
int filterndx
max-handle bytes szDir
int szFilter
int szTitle

:M ClassInit:   ( -- )
        ClassInit: super
        0 szDir !
        szfile /szFile erase
        1 to filterndx
        0 to fcnt
        here 1+ to szTitle  ,"text"
        max-handle here szTitle - - allot       \ extend to max string
        here 1+ to szFilter ,"text"             \ lay in filter, then
        max-handle here szFilter - - allot      \ extend to max string
        ;M

:M SetDir:      ( a1 n1 -- )            \ set the dialog directory string
        max-handle 2 - min szDir place  \ lay in the directory
        szDir +NULL                     \ null terminate
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

: #selected    ( -- n )
               0      \ default
               szfile @ 0= ?exit
               szfile zcount + w@ 0=   \ one file selected
               if      1+ exit
               then    \ more than one file selected
               szfile zcount + 1+      \ first entry is the path spec
               begin   1 under+    \ increment
                       zcount + dup w@ 0<>     \ double null ends list
               while   1+          \ move past terminating null
               repeat  drop ;

:m Getfile:       { ndx -- addr cnt }   \ ndx = 0 to fcnt-1
                fcnt 0= abort" No files selected!"
                ndx 0 fcnt within not abort" Index out of bounds!"
                fcnt 1 =
                if      szfile zcount exitm
                then    new$ >r
                szfile zcount r@ place r@ ?+\       \ lay path in temp buffer
                szfile zcount + 1+
                ndx 0
                ?do      zcount + 1+
                loop    zcount r@ +place
                r> dup +NULL count ;m

:m SetFilterIndex:   ( n -- )
                    to filterndx ;m

\ :m GetFilterIndex:	( -- index )
\ 			filterndx ;m

: run-dialog    ( owner_handle dialog-func-cfa -- a1 )
        2>r
        0 to fcnt
        filterndx
        szFile   dup off \ no initial file
        szDir    1+
        szTitle
        szFilter
        2r> execute
	ofn-struct 6  cells+ @ to filterndx  \ save filter index
        #selected dup to fcnt
        if      0 GetFile: self "path-only" szdir place         \ save path
                szdir +null
        then    ;

:M #SelectedFiles:  ( -- n )
                    fcnt ;M

:M Start:       ( owner_handle -- a1 )
        ['] mopen-dialog run-dialog
        ;M

;Class
MODULE
