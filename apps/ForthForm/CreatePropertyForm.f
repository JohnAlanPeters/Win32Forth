\ CreatePropertyForm.f

:Object frmCreatePropertyForm              <Super frmPropertyForm

create sheetname 40 allot sheetname off
create sheetcaption 40 allot sheetcaption off
false value defaultbuttons?
false value multi-line-tabs?
false value compile-to-disk?
false value button-tabs?

: append&crlf&tabs     ( -- )
                       append&crlf 2tabs ;

: getFormName          { n -- addr cnt }
                       n >Link#: FormList FormName: [ Data@: FormList ] count ;

: maxtabsize            { \ w h -- w h }
                       0 to w 0 to h
                       #Forms 1+ 1
                       ?do    i >Link#: FormList
                              Dimensions: [ Data@: FormList ]
                              h max to h
                              w max to w
                       loop   w 10 + h 30 + ;

: sheetsize            ( -- w h )
                       maxtabsize
                       defaultbuttons?  \ each default button 80 * 25
                       if     swap 260 max swap 35 +
                       then   ;

: (write-show/hide)    { curform \ this -- }
                       Link#: FormList >r      \ save link
                       #forms 1+ 1
                       ?do     i >Link#: FormList
                               Data@: FormList to this
                               +crlf 2tabs
                               this curform <>
                               if     s" Hide: " append
                               else   s" Display: " append
                               then   FormName: this count append
                       loop    r> >Link#: FormList ;

: write-show/hide      ( -- )
                       Link#: FormList >r      \ save link
                       #forms 1+ 1
                       ?do     i >Link#: FormList
                               Data@: FormList >r
                               +crlf
                               s" : show-" append FormName: [ r@ ] count append
                               1 +tabs s" ( -- )" append
                               r> (write-show/hide)
                               s"  ;" append&crlf
                               +crlf
                       loop    r> >Link#: FormList ;

: write-ontab          ( -- )
                       +crlf
                       s" : ontab         { l obj -- }" append&crlf&tabs
                       s" GetSelectedTab: obj" append&crlf&tabs
                       s" case" append&crlf
                       #Forms 0
                       do     3 +tabs
                              i (.) append 1 +tabs
                              s" of" append 1 +tabs
                              s" show-" append
                              i 1+ GetFormName append
                              1 +tabs
                              s" endof" append&crlf
                       loop   2tabs s" endcase  ;" append&crlf ;

: write-showtab        ( -- )
                       +crlf
                       s" :M ShowTab:    ( n -- )" append&crlf&tabs
                       s" dup SetSelectedTab: SheetTab" append&crlf&tabs
                       s" Addr: SheetTab ontab" append&crlf&tabs
                       s" ;M"  append&crlf ;

: write-on_init        ( -- )
                       +crlf
                       s" :M on_init:     ( -- )" append&crlf&tabs

                       s" COLOR_BTNFACE Call GetSysColor NewColor: FrmColor" append&crlf&tabs
                       +crlf 2tabs

                       s"append s" MS Sans Serif" append "append
                       s"  SetFaceName: WinFont"  append&crlf&tabs
                       s" 8 Width: WinFont" append&crlf&tabs
                       s" Create: WinFont drop " append&crlf +crlf 2tabs

                       s" ['] ontab IsChangeFunc: SheetTab" append&crlf +crlf 2tabs

                       multi-line-tabs? dup>r
                       if     s" TCS_MULTILINE " append
                       then   button-tabs? dup>r
                       if     s" TCS_BUTTONS " append
                       then   r> r> 2dup and
                       if     s" or " append
                       then   or
                       if     s" Addstyle: SheetTab" append&crlf +crlf 2tabs
                       then

                       s" \ start the individual forms of the property sheet" append&crlf&tabs
                       s" self Start: SheetTab" append&crlf&tabs
                       s" 0 0 1 1 Move: SheetTab" append&crlf&tabs
                       s" Handle: WinFont SetFont: SheetTab" append&crlf&tabs

                       #Forms 0   \ add each tab and it's title
                       ?do    +crlf 2tabs
                              z"append
                              i 1+ >Link#: FormList FormTitle: [ Data@: FormList ] count append
                              "append s"  IsPsztext: SheetTab" append&crlf&tabs
                              s" TCIF_TEXT IsMask: SheetTab" append&crlf&tabs
                              i #append s" InsertTab: SheetTab" append&crlf
                       loop

                       #Forms 0 \ start each form
                       ?do    +crlf 2tabs
                              s" Addr: SheetTab Start: " append
                              i 1+ GetFormName append&crlf&tabs
                       loop
                       
                       +crlf 2tabs
                       s" 0 ShowTab: self" append&crlf         \ default to show first form
                       \ if wanted generate the three default buttons
                       defaultbuttons?
                       if      +crlf 2tabs
                               s" self Start: btnOk" append&crlf&tabs
                               sheetsize  >r 246 - r> 30 -   \ -- x y, starting pos
                               2dup swap #append #append
                               80 #append 25 #append s" Move: btnOk" append&crlf&tabs
                               s" Handle: WinFont SetFont: btnOk" append&crlf&tabs
                               s"append s" &Ok" append "append s"  SetText: btnOk" append&crlf

                               +crlf 2tabs
                               s" self Start: btnCancel" append&crlf&tabs
                               ( x y -- ) 82 under+ 2dup swap #append #append
                               80 #append 25 #append s" Move: btnCancel" append&crlf&tabs
                               s" Handle: WinFont SetFont: btnCancel" append&crlf&tabs
                               s"append s" &Cancel" append "append s"  SetText: btnCancel" append&crlf

                               +crlf 2tabs
                               s" self Start: btnApply" append&crlf&tabs
                               ( x y -- ) swap 82 + #append #append
                               80 #append 25 #append s" Move: btnApply" append&crlf&tabs
                               s" Handle: WinFont SetFont: btnApply" append&crlf&tabs
                               s"append s" &Apply" append "append s"  SetText: btnApply" append&crlf

                        then   +crlf 2tabs s" ;M" append&crlf ;


: write-opening  ( -- )
                 s" \- textbox needs excontrols.f" append&crlf
                +crlf
                s" :Object " append sheetName count append
                2tabs s" <Super DialogWindow" append&crlf
                +crlf s" Font WinFont" append&crlf
                s" ColorObject FrmColor" append&crlf
                s" TabControl SheetTab" append&crlf
                defaultbuttons?
                if     s" PushButton btnOk" append&crlf
                       s" PushButton btnCancel" append&crlf
                       s" PushButton btnApply" append&crlf
                then   ;

: write-on_done ( -- )
                +crlf
                s" :M On_Done:    ( -- )" append&crlf&tabs
                s" Delete: WinFont" append&crlf&tabs
                s" \ Insert your code here" append&crlf&tabs
                s" On_Done: super  ;M" append&crlf ;

: write-startsize ( -- )
                +crlf
                s" :M StartSize:    ( -- w h )" append&crlf&tabs
                sheetsize swap #append #append s" ;M" append&crlf ;

: write-startpos ( -- )
                +crlf
                s" :M StartPos:    ( -- x y )" append&crlf&tabs
                \ use the position of the first form for the start position
                >FirstLink: FormList
                Origin: [ Data@: FormList ]
                swap #append #append s" ;M" append&crlf ;

: write-close   ( -- )
                +crlf
                s" :M Close:  ( -- )" append&crlf&tabs
                #forms 1+ 1
                ?do    s" Close: " append
                       i GetFormName append&crlf&tabs
                loop   s" Close: super ;M" append&crlf ;

: write-title   ( -- )
                +crlf
                s" :M WindowTitle: ( -- ztitle )" append&crlf&tabs
                z"append sheetcaption count append "append +crlf
                2tabs s" ;M" append&crlf ;

: write-on_paint ( -- )
                 +crlf
                 s" :M On_Paint:    ( -- )" append&crlf&tabs
                 s" 0 0 GetSize: self Addr: FrmColor FillArea: dc ;M" append&crlf ;

: write-on_size  ( -- )
                 +crlf
                 s" :M On_Size:     ( -- )" append&crlf&tabs
                 s" 0 0 Width Height " append
                 defaultbuttons?
                 if     s" 35 - " append
                 then   s" Move: SheetTab" append&crlf&tabs
                 #forms 1+ 1
                 ?do     s" ClientSize: SheetTab 2over d- Move: " append
                         i GetFormName append&crlf&tabs
                 loop   s" ;M" append&crlf ;

: write-notify  ( -- )
                +crlf
                s" :M WM_NOTIFY  ( h m w l -- f )" append&crlf&tabs
                s" Handle_Notify: SheetTab ;M" append&crlf ;

: write-style   ( -- )
                +crlf
                s" :M WindowStyle:  ( -- style )" append&crlf&tabs
                s" WS_POPUPWINDOW WS_DLGFRAME or ;M" append&crlf ;

: write-end     ( -- )
                +crlf
                s" ;Object" append&crlf ;

: getmergename  ( -- )
                GetName: MergeFile c@ ?exit
                GetFilter: SaveFormDlg new$ dup>r place
                s" Forms|*.frm|All Files|*.*|" SetFilter: SaveFormDlg
                GetHandle: TheMainWindow Start: SaveFormDlg
                r> count SetFilter: SaveFormDlg
                dup c@ 0= ?abort
                count 2dup pad place ".ext-only" nip 0=
                if  s" .frm" pad +place
                then    pad count SetName: MergeFile ;

: write-forms   { \ this -- }
                Link#: FormList >r      \ save link
                #forms 1+ 1
                ?do     i >Link#: FormList
                        Data@: FormList to this
                        GetSuperClass: this >r           \ save these
                        ChildState: this >r              \ states
                        true IsChildState: this          \ and set them
                        CHILD-CLASS IsSuperClass: this   \ temporarily
                        UnInitedBuffer: this 2drop       \ compile without initializing
                        +crlf +crlf
                        r> IsChildstate: this            \ restore all
                        r> IsSuperClass: this
                loop    r> >Link#: FormList
                compile-to-disk?
                if      getmergename
                        Create: MergeFile ?abort
                        TheBuffer Write: MergeFile
                        Close: MergeFile ?abort
                        initbuffer       \ restart
                        s" needs " append GetName: MergeFile count append&crlf +crlf
                else    ClearName: MergeFile       \ acts as a flag
                then    ;

: compile-sheet ( -- )
                initbuffer
                write-forms
                write-opening
                write-show/hide
                write-ontab
                write-showtab
                write-startsize
                write-startpos
                write-on_size
                write-title
                write-style
                write-on_init
                write-on_paint
                write-close
                write-on_done
                write-notify
                write-end ;

: getselections ( -- )
                IsButtonChecked?: chkDefault    to defaultbuttons?
                IsButtonChecked?: chkMultiLine  to multi-line-tabs?
                IsButtonChecked?: chkCompile    to compile-to-disk?
                IsButtonChecked?: chkButtonTabs to button-tabs?
                GetText: txtName dup 0=      \ if no name supplied
                if      2drop s" Sheet" 2dup SetText: txtName     \ provide one by default
                then     sheetname place
                GetText: txtCaption sheetcaption place
                compile-sheet ;
                
: load-sheet    ( -- )
                getselections 
                s" anew -psheet" evaluate
                fload-buffer
                s" Start: " new$ dup>r place
                sheetname count r@ +place
                r> count evaluate ;
                
: command-func  { id obj -- }
                id
                  case
                         GetId: btnClipBoard     of    getselections 
                                                       TheBuffer copy-clipboard   endof
                         GetId: btnEdit          of    getselections 
                                                       TheBuffer s" PropertyForm"
                                                       ShowSource                 endof
                         GetID: btnTest          of    nostack1 load-sheet        endof
                         GetId: btnClose         of    Close: self                endof
                  endcase ;

:m on_init:     ( -- )
                on_init: super
                
                ['] command-func SetCommand: self

                defaultbuttons?           Check: chkDefault
                multi-line-tabs?          Check: chkMultiLine
                compile-to-disk?          Check: chkCompile
                button-tabs?              Check: chkButtonTabs
                sheetname count         SetText: txtName
                sheetcaption count      SetText: txtCaption
                ;M
                
:M ParentWindow:  ( -- hwnd )
                  GetHandle: TheMainWindow ;M
                  
:M ClassInit:     ( -- )
                  ClassInit: Super
                  self link-formwindow
                  ;M
                
;Object
                
:NoName         ( -- )
\ MergeFile object acts as a flag, if the name is not set a file can be selected
\ otherwise use whatever name is there. To choose file of different name disselect
\ option and test, edit or clipboard
                ClearName: MergeFile
                Start: frmCreatePropertyForm ; is doPropertyForm

\s
