\ FormPad.f         A Simple Editor For ForthForm

\ needs FormPad.frm

:Object FormPad             <Super frmFormPad

File FormFile
int eActiveForm
ScintillaControl scnEditor

: SaveToDisk        { \ fname buf -- }
            GetFilter: SaveFormDlg new$ dup>r place
            s" Forth Files|*.frm;*.f|All Files|*.*|" SetFilter: SaveFormDlg
            hwnd Start: SaveFormDlg to fname
            r> count SetFilter: SaveFormDlg
            fname c@
            if  fname count 2dup pad place
                ".ext-only" nip 0=
                if  s" .f" pad +place
                then    pad count SetName: FormFile
                Create: FormFile ?exit
                GetTextLength: scnEditor dup>r cell+ malloc to buf
                buf r@ 1+ GetText: scnEditor
                buf r> Write: FormFile   ( -- f )
                Close: FormFile
                buf release
                ( f -- ) 0= s" Saved!" ?MessageBox
            then    ;

:M WindowStyle:     ( -- style )
            WS_OVERLAPPEDWINDOW
            ;M

:M StartSize:       ( -- w h )
            screen-size >r 2/ r> 2/ ;M

:M MinSize:     ( -- w h )
            StartSize: self ;M

: >dimensions       { l t r b -- w h }
            r l - b t - ;

:M On_Size:     ( -- )
            0 0 Width Height 50 - Move: scnEditor
            getwindowrect: btnSaveToDisk >dimensions
            height over - cell- 2 swap 2swap 4dup Move: btnsavetodisk
            2dup 2>r drop rot + 2 + swap 2r> move: btnexit
            ;m


:M On_Init:     ( -- )
            On_Init: Super
            Close: btnCompile
            self start: scnEditor
            ;M

:M On_Done:     ( -- )
            On_Done: Super
            ;M

:M Start:       ( -- )
            Start: Super ;M

:M Close:       ( -- )
            Close: scnEditor
            Close: Super ;M

:M View:            { saddr scnt title$ cnt -- }
            Start: self
            saddr scnt + off    \ null terminate
            saddr SetText: scnEditor
            s" FormPad - " here place
            title$ cnt here +place
            here count Settext: self     \ set caption
            ;M

:M WM_COMMAND       ( h m w l -- res )
            over LOWORD ( ID )
            case
                    GetID: btnExit          of  Close: super    endof
                    GetID: btnSaveToDisk    of  SaveToDisk      endof
            endcase 0 ;M

:M ParentWindow:    ( -- hwndparent )
            GetHandle: TheMainWindow ;M

:M ClassInit:   ( -- )
                ClassInit: Super
                self link-formwindow
                ;M

;Object

: ShowSource     ( addr cnt title$ cnt -- )
                 false \ editor-present?   \ is SciEdit open?
                 if     \ ed-filename place             \ pass name through shared memory
                        \ copy-clipboard                \ send source to clipboard
                        \ 0 FF_PASTE editor-message     \ tell SciEdit to paste it
                 else    View: FormPad
                 then    ;

: EditForm      ( -- )
            ActiveForm 0= ?exit
            GetBuffer: ActiveForm FormName: ActiveForm count
            View: FormPad ;
' EditForm is doEditor
