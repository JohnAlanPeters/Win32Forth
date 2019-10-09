\ $Id: Dialog.f,v 1.9 2013/11/06 21:56:29 georgeahubert Exp $

\ *D doc\classes\
\ *! Dialog
\ *T Dialog -- Class for dialog boxes.

cr .( Loading Dialog Box...)

\ *S Load Dialog Resource File

\ *P The .RES file structure is a series of records.  Each record contains
\ ** a header and a data field.  The structure of a header is as follows:
\ *L
\ *| offset | length | |
\ *|      0 |      4 | length of data field |
\ *|      4 |      4 | length of header |
\ *|     10 |      2 | record type |
\ *|     14 |      2 | dialog ID number (for dialogs) |

: dialogID?     ( hdr ID -- f )
\ *G Given the address of a header in a resource file, return true if this
\ ** is the header for a dialog resource.  I'm only guessing here.
                over 14 + w@   =                \ does ID match
                swap 10 + w@ 5 = and ;          \ is this also a dialog

: ?dlgerr  ( ior -- )   abort" Error loading dialog resource" ;

\ April 18th, 1996 tjz switched to LONG count from WORD count
: find-dialog-ID ( id addr -- address-of-template-header )
\ *G Find dialog template given address and length of resource file in memory.
                swap >r
                lcount
                begin   over r@ dialogID?
                        if      rdrop                  \ discard the ID
                                drop                    \ discard the length
                                \ return the template header address
                                EXIT                    \ ALL DONE, LEAVE
                        then
                        over 2@ + aligned
                        /string dup 0=
                until   2drop r>
                cr ." Looking for dialog: " . true ?dlgerr ;

\ Read resource file and return address and length of dialog template.

in-system

\ April 18th, 1996 tjz switched to LONG count from WORD count
\ September 21st, 2003 - 13:44 dbu changed to use "open instead of n"open
: read-dialog   ( name namelen -- )
                "open ?dlgerr >r
                r@ file-size 2drop here !
                here lcount dup cell+ allot       \ room for file and word cnt
                r@ read-file ?dlgerr 0= ?dlgerr
                r> close-file ?dlgerr ;

\ changed to work with blanks in file name
\ January 31st, 2004 - 20:38 dbu
: load-dialog   ( -<filename-without-an-extension>- )
\ *G Load template from dialog resource (*.res) to here and allot memory. \n
\ ** Usage:  load-dialog dialog
                { \ ld-buf -- }
                maxstring localalloc: ld-buf
                >in @ >r                        \ save the input pointer
                bl word c@ name-max-chars >     \ check filename length
                abort" Dialog files are limited to 255 chars"
                r> >in !                        \ restore the input pointer
                create last @ nfa-count         \                     name length
                2dup       ld-buf  place        \ lay in filename
                s" .res"   ld-buf +place        \ add extension       name.res
                ld-buf count read-dialog        \ load resource file
                s" fload '" ld-buf  place       \ load header file
                ( a1 n1 )  ld-buf +place        \ Append filename
                s" .h'"     ld-buf +place       \ add extension       name.h
                ld-buf count evaluate
                postpone \ ;                    \ ignore rest of line

in-application

\ *W <a name="Dialog"></a>
\ *S Dialog Class
:CLASS Dialog   <SUPER Generic-Window
\ *G Dialog class. \n
\ ** To use this class you have to create a ressource file (*.res) which must contain
\ ** the dialog resource. Since Win32Forth doesn't provide any tool's to create a dialog
\ ** resource you should use the Win32ForthIDE Forth Designer to create your dialog windows instead.

: (DialogProc)   ( hwnd msg wparam lparam -- res )
        [ also classes ]

        GWL_USERDATA 4 pick Call GetWindowLong  ( object address )

        ?dup 0=
        if
                2 pick WM_INITDIALOG <>
                if
                        0 exit
                then

                dup             \ window object pointer from
                                \ lparam of DialogBoxIndirectParam

                4 pick ( obj hwnd )
                2dup GWL_USERDATA swap Call SetWindowLong drop  \ save obj pointer
                over !          \ set hWnd parameter of window struc

        then

        3 pick ( msg ) over obj>class MFA ((findm))
        if
                execute
        else
                0
        then

        [ previous ] ;

4 callback DialogProc (DialogProc)


\ TEMPLATE has been changed to be the template header address, instead of
\ the address of the template it self, so we can move the template into
\ globally allocated memory

: run-dialog  { parent template \ tmplhndl -- f }
        self
        DialogProc
        parent 0 <>                     \ if parent is not zero
        parent conhndl <> and           \ and parent is not the console handle
        if      GetHandle: parent       \ then use the specified parent
        else    conhndl                 \ else use the console for the parent
        then
        template 2@ + malloc to tmplhndl
        template dup cell+ @ +                  \ from
        tmplhndl template @ move                \ move the length
        tmplhndl                                \ new way, template handle
        appInst
        Call DialogBoxIndirectParam
        tmplhndl release ;

\ -------------------- Helpers --------------------


:M Start:       ( parent -- flag )
\ *G Open the dialog
                GetTemplate: [ self ] run-dialog
                ;M

:M EndDialog:   ( return-value -- )
\ *G Close the dialog
                hwnd Call EndDialog drop
                ;M

: end-dialog    ( value -- flag )
                EndDialog: [ self ] 1 ;


\ -------------------- Initialization --------------------

:M WM_INITDIALOG  swap On_Init: [ self ] ;M

:M On_Init:  ( hwndfocus -- f )
\ *G Init the dialog
        drop true ;M

\ -------------------- Process Commands from Controls --------------------

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: [ self ] ;M

:M On_Command:  ( hCtrl code ID -- f )
\ *G Process Commands from Controls
        case

          IDOK of
                1 end-dialog
          endof

          IDCANCEL of
                0 end-dialog
          endof

          false swap ( default result )

        endcase ;M

;Class
\ *G End of Dialog class

\ December 11th, 2003 jeh, In order to use ModelessDialog you must extend the
\ class and add your own GetTemplate method. ( -- template | tmplhndl )
\ The common implementation is to also create a constant to hold
\ The template associated with each instance of the class although this is
\ not required, only the GetTemplate method is required.

\ *W <a name="ModelessDialog"></a>
\ *S Modless Dialog class
:Class ModelessDialog   <SUPER Dialog
\ *G Modless Dialog class \n
\ ** To use this class you have to create a ressource file (*.res) which must contain
\ ** the dialog resource. Since Win32Forth doesn't provide any tool's to create a dialog
\ ** resource you should use Win32ForthIDE Forth Designer to create your dialog windows instead.

int hTemplate

:M ClassInit:   ( -- )
                ClassInit: super
                0 to hTemplate
                +dialoglist
                ;M

:M WindowStyle: ( -- n1 )
\ *G Get the window style of the dialog.
                GetTemplate: [ self ] dup
                if      dup cell+ @ + @
                then
                ;M

:M ExWindowStyle: ( -- n1 )
\ *G Get the extended window style of the dialog.
                GetTemplate: [ self ] dup
                if      dup cell+ @ + cell+ @
                then
                ;M

:M Origin:      ( -- x y )
\ *G Get the origin (upper left corner) of the dialog.
                GetTemplate: [ self ] ?dup
                if      dup cell+ @ + 2 cells+ 2 + @ word-split
                else    0 0
                then
                ;M

: run-modeless-dialog  { parent template \ tmplhndl -- hwnd tmplhndl }
                self
                DialogProc
                parent 0 <>                      \ if parent is not zero
                parent conhndl <> and            \ and parent is not the console handle
                if      GetHandle: parent        \ then use the specified parent
                else    conhndl                  \ else use the console for the parent
                then
                template 2@ + malloc to tmplhndl
                template dup cell+ @ +           \ from
                tmplhndl template @ move         \ move the length
                  WindowStyle: [ self ]    tmplhndl       !
                ExWindowStyle: [ self ]    tmplhndl cell+ !
                Origin: [ self ] word-join tmplhndl 2 cells+ 2 + !
                tmplhndl                         \ new way, template handle
                appInst
                Call CreateDialogIndirectParam
                SW_SHOW over Call ShowWindow drop
                dup Call UpdateWindow drop
                dup Call SetFocus drop
                tmplhndl ;

:M Start:       ( parent -- )
\ *G Open the dialog
                hTemplate 0=
                if      GetTemplate: [ self ]
                        run-modeless-dialog to hTemplate to hWnd
                else    drop
                        SetFocus: self
                then
                ;M

:M EndDialog:   ( n1 -- )
\ *G Close the dialog
                drop
                DestroyWindow: self
                ;M

:M WM_DESTROY   ( -- result )
                hTemplate release
                0 to hTemplate
                0 to hwnd
                0 ;M

:M WM_CLOSE     ( -- )
                DestroyWindow: Self ;M

:M ~:           ( -- )
                -dialoglist ;M

;Class
\ *G End of ModlessDialog class

\ *Z
