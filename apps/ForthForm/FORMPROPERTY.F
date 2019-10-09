\ Form and control editing
load-bitmap savebmp1 "save1.bmp"
load-bitmap savebmp2 "save2.bmp"
load-bitmap stopbmp1 "stop1.bmp"
load-bitmap stopbmp2 "stop2.bmp"

\ The following not working from within the TabControl form, just a litle help info
s" When a control or form is selected display its property" BInfo: chkAutoProperty place
s" Add only one selected control when form is clicked" BInfo: chkSingleControl place

: GetBitmap     ( -- )
                Gethandle: frmEditProperties Start: GetBitmapDlg dup c@
                if      count SetText: txtBitmap
                else    drop
                then    ; ' GetBitmap SetFunc: btnBrowse

0 value eActiveControl
0 value eActiveForm    \ current form, not necessarily the ActiveForm

: IsTypeButton? { \ ctrltype -- f }
                GetType: eActiveControl to ctrltype
                ctrlType TypePushbutton   =  ?dup ?exit
                ctrlType TypeGroupBox     =  ?dup ?exit
                ctrlType TypeCheckBox     =  ?dup ?exit
                ctrlType TypeRadioButton  =  ?dup ?exit
                ctrlType TypeMultiLineBox =  ?dup ?exit
                ctrlType TypeLabel        =  ;

: CheckTypeText ( -- f )
\ Justification is invalid for some controls so we disable this feature if the control
\ is a textbox, listbox or combobox
                GetType: eActiveControl
                |  TypeTextBox
                   TypeListBox
                   TypeComboBox
                   TypeComboListBox
                   TypeHorizScroll
                   TypeVertScroll
                   TypeMultiListBox
                   TypeFileWindow
                   TypeTabControl
                |if   false
                else  true
                then  dup Enable: radLeft
                dup Enable: radCenter
                dup Enable: radRight
                dup Enable: radLefttext
                dup Enable: grpOrientation ;

: ?EnableSpinner        ( -- )
                        GetType: eActiveControl TypeTextBox = dup Enable: chkSpinner
                        if       Spinner?: eActiveControl
                        else     false
                        then     Check: chkSpinner ;

: LoadProperties        ( -- )
                GetName:  eActiveControl SetText: txtName
                GetTitle: eActiveControl SetText: txtCaption
                Origin: eActiveControl SetValue: spnYpos SetValue: spnXpos
                Dimensions: eActiveControl SetValue: spnHeight SetValue: spnWidth
                GetToolTip: eActiveControl SetText: txtToolTip
                GetBitmap: eActiveControl SetText: txtBitmap
                Disable: txtBitmap       \ default
                Disable: btnBrowse       \ ,,
                Group?: eActiveControl Check: chkGroup
                Global?: eActiveControl Check: chkGlobal
                ?EnableSpinner
                GetType: eActiveControl dup
                TypeBitmapButton = swap TypeStaticBitmap = or
                if      Disable: radLeft
                        Disable: radCenter
                        Disable: radRight
                        Disable: radLefttext
                        Disable: grpOrientation
                        true Enable: txtBitmap
                        true Enable: btnBrowse
                else    \ first clear any previous orientation selection
                        UnCheckButton: radLeft
                        UnCheckButton: radCenter
                        UnCheckButton: radRight
                        UnCheckButton: radLeftText
                        CheckTypeText     \ if it is a valid control
                        if  Orientation: eActiveControl
                            case
                                    0       of      CheckButton: radLeft     endof
                                    1       of      CheckButton: radCenter   endof
                                    2       of      CheckButton: radRight    endof
                                    3       of      CheckButton: radLefttext endof
                            endcase
                        then    GetType: eActiveControl dup TypeCheckBox <>
                        swap TypeRadioButton <> and
                        if      Disable: radLeftText     \ not valid for this control
                        then
                then    ;

: SaveProperties        { \ x y w h -- }
                eActiveForm ?FormNumber 0= ?exit    \ form no longer exists
                eActiveControl ?ControlNumber: eActiveForm 0= ?exit
                Origin: eActiveControl to y to x
                Dimensions: eActiveControl to h to w
                GetText: txtName SetName: eActiveControl
                GetText: txtCaption SetTitle: eActiveControl
                GetValue: spnXpos  GetValue: spnYpos SetOrigin: eActiveControl
                GetValue: spnWidth GetValue: spnHeight SetDimensions: eActiveControl
                GetText: txtTooltip IsTooltip: eActiveControl
                GetType: eActiveControl dup
                TypeBitmapButton = swap TypeStaticBitmap = or
                if      GetText: txtBitmap IsBitmap: eActiveControl
                then    IsButtonChecked?: chkGroup IsGroup: eActiveControl
                IsButtonChecked?: chkGlobal IsGlobal: eActiveControl
                GetType: eActiveControl TypeTextBox =
                if       IsButtonChecked?: chkSpinner IsSpinner: eActiveControl
                then
                \ justification
                IsTypeButton?
                if      IsButtonChecked?: radLeft
                        if      0
                        else    IsButtonChecked?: radCenter
                                if      1
                                else    IsButtonChecked?: radRight
                                        if      2
                                        else    IsButtonChecked?: radLeftText
                                                if      3
                                                then
                                        then
                                then
                        then    IsOrientation: eActiveControl
                then    Validate: eActiveForm           \ update
                Ismodified: eActiveForm                 \ and check
                Update: eActiveControl                  \ everything
                UpdateStatus: eActiveForm               \ at this time
                Paint: eActiveForm ;                    \ and refresh display

: initload      ( -- )
                ActiveControl: ActiveForm to eActiveControl
                ActiveForm to eActiveForm
                eActiveControl 0= ?exit
                LoadProperties  \ initialize form
                ;

: doPrevious    ( -- )  \ cycle through controls in current form
                ActiveForm 0= ?exit
                Locked?: ActiveForm ?exit
                #Controls: ActiveForm 0= ?exit
                ActiveControl: ActiveForm ?dup
                if      ?ControlNumber: ActiveForm
                else    1
                then    dup 0=
                if      drop exit       \ no control list
                then    1- 1 max        \ go to previous control
                ControlList: ActiveForm dup>r >Link#: [ ]
                r> Data@: [ ] SetActiveControl: ActiveForm
                Paint: ActiveForm
                UpdateStatus: ActiveForm
                UpdatePropertyWindow ;

: doNext        ( -- ) \ cycle through controls in current form
                ActiveForm 0= ?exit
                Locked?: ActiveForm ?exit
                #Controls: ActiveForm 0= ?exit
                ActiveControl: ActiveForm ?dup
                if      ?ControlNumber: ActiveForm
                else    1
                then    dup 0=
                if      drop exit       \ no control list
                then    1+ #Controls: ActiveForm min        \ go to next control
                ControlList: ActiveForm dup>r >Link#: [ ]
                r> Data@: [ ] SetActiveControl: ActiveForm
                Paint: ActiveForm
                UpdateStatus: ActiveForm
                UpdatePropertyWindow ;

: PropertyFunc  ( h m w l id obj -- h m w l )
                { cid obj -- }
                cid     \ control id
                case
                                 IDOK     of      SaveProperties   endof
                                 GetID: btnPrevious
                                          of      doPrevious       endof
                                 GetID: btnNext
                                          of      doNext           endof
                                 IDCANCEL of      Close: obj       endof
                                 endcase ;

:Noname         ( -- )
               frmEditProperties.hwnd 0= ?exit    \ window  is not open
\ Remove comment from the following if you will need to save the properties first
\ If you do and you are just browsing controls the form(s) will be marked as
\ modified even though you haven't made any changes.

\                SaveProperties          \ save first
		initload                \ reload for new control
                ; is UpDatePropertyWindow

:Object frmEditForm                <Super frmEditFormProperties

:M LoadProperties:        ( -- )
                 FormName: ActiveForm count SetText: txtName
                FormTitle: ActiveForm count SetText: txtTitle
                   Origin: ActiveForm  SetValue: spnYpos
                                       SetValue: spnXpos
               Dimensions: ActiveForm  SetValue: spnHeight
                                       SetValue: spnWidth
                   GetModal: ActiveForm Check: ChkModal
                SaveScreen?: ActiveForm Check: chkSave
                 ChildState: ActiveForm Check: chkChildState
                 StatusBar?: ActiveForm Check: chkStatusBar
              GetSuperClass: ActiveForm
                case
                        CHILD-CLASS     of  CheckButton: radChildWindow
                                            UnCheckButton: radMDIDialogWindow
                                            UnCheckButton: radDialogWindow
                                            true Enable: chkChildState
                                        endof
                        MDIDIALOG-CLASS of  CheckButton: radMdiDialogWindow
                                            UnCheckButton: radChildWindow
                                            UnCheckButton: radDialogWindow
                                            false Enable: chkChildState
                                        endof
                                            CheckButton: radDialogWindow    \ default
                                            UnCheckButton: radMDIDialogWindow
                                            UnCheckButton: radChildWindow
                                            false Enable: chkChildState
                endcase ;M

:M SaveProperties:   { \ x y w h -- }
                Origin: ActiveForm to y to x
                Dimensions: ActiveForm to h to w
                GetText: txtName    IsFormName: ActiveForm
                GetText: txtTitle  IsFormTitle: ActiveForm
                GetValue: spnXpos GetValue: spnYpos SetOrigin: ActiveForm
                GetValue: spnWidth GetValue: spnHeight SetDimensions: ActiveForm
                IsButtonChecked?: chkModal SetModal: ActiveForm
                IsButtonChecked?: chkSave IsSaveScreen?: ActiveForm
                IsButtonChecked?: chkChildState IsChildState: ActiveForm
                IsButtonChecked?: chkStatusBar IsStatusBar: ActiveForm
                IsButtonChecked?: radDialogWindow
                if  DIALOG-CLASS
                else    IsButtonChecked?: radChildWindow
                        if  CHILD-CLASS
                        else    MDIDIALOG-CLASS
                        then
                then    IsSuperClass: ActiveForm
                0 0 Dimensions: ActiveForm        ( x y w h )
                SetRect: TempRect
                0                                       \ no menu
                WindowStyle: ActiveForm                 \ the window style
                AddrOf: TempRect                         \ make a new rectangle
                Call AdjustWindowRect ?win-error        \ adjust the window
                Right: TempRect Left: TempRect -         \ adjusted  width
                Bottom: TempRect  Top: TempRect -         \ adjusted height
                GetHandle: ActiveForm AdjustWindowSize
                FormTitle: ActiveForm count Settext: ActiveForm
                Validate: ActiveForm  \ check everything is ok
                IsModified: ActiveForm
                DoUpdate
                Refresh: ActiveForm ;M

: FormFunc      ( h m w l id obj -- res )
                drop ( ID )
                case
                        GetId: radDialogWindow      of      Disable: chkChildState      endof
                        GetId: radChildWindow       of      true Enable: chkChildState  endof
                        GetId: radMDIDialogWindow   of      Disable: chkChildState      endof
                endcase ;

:M On_Init:        ( -- )
                On_Init: super

                ['] Formfunc SetCommand: self

                LoadProperties: self

                ;M

;Object

:Object frmProperties++                <Super frmPropertiesWindow
imagebutton btnapply
imagebutton btnclose

: ontab         { l obj -- }
                GetSelectedTab: obj
                case
                        0       of      Hide: frmEditProperties
                                        Hide: frmAction
                                        Display: frmEditForm            endof
                        1       of      Hide: frmEditForm
                                        Hide: frmAction
                                        Display: frmEditProperties      endof
                        2       of      Hide: frmEditProperties
                                        Hide: frmEditForm
                                        Display: frmAction              endof
                endcase LoadProperties: frmEditForm ;

: ?apply        ( -- )
                Locked?: ActiveForm ?exitm
                GetSelectedTab: TabProperties
                case
                        0       of      SaveProperties: frmEditForm     endof
                        1       of      SaveProperties  ( control )     endof
                endcase ;

:M Close:       ( -- )
                Close: frmEditForm
                Close: frmEditProperties
                Close: frmAction
                Close: Super ;M

: frmcommand    ( h m w l id obj -- res )
                drop ( ID )
                case
                        IDOK     of     ?apply           endof
                        IDCANCEL of     Close: self      endof
                endcase ;

:M On_Init:     ( -- )

                IDOK SetId: btnApply
                IDCANCEL SetID: btnClose

                TCS_BUTTONS TCS_FLATBUTTONS or AddStyle: TabProperties

                On_Init: Super

                self Start: btnApply
                btnApplyX btnApplyY btnApplyW btnApplyH Move: btnApply
                savebmp2 usebitmap map-3DColors
                savebmp2 setimage: btnapply             \ normal displayed image
                savebmp1 usebitmap map-3DColors
                savebmp1 SetImage#2: btnApply      \ image to display when hovering mouse
                s" Apply" SetText: btnApply
                Handle: WinFont SetFont: btnApply

                self Start: btnClose
                btnCloseX btnCloseY btnCloseW btnCloseH Move: btnClose
                stopbmp2 usebitmap map-3DColors
                stopbmp2 setimage: btnclose             \ normal displayed image
                stopbmp1 usebitmap map-3DColors         \ image to display when hovering mouse
                stopbmp1 SetImage#2: btnClose
                s" Close" SetText: btnClose
                Handle: WinFont SetFont: btnClose


                ['] ontab IsChangeFunc: TabProperties

                ['] frmcommand SetCommand: self

                z" Form" IsPsztext: TabProperties
                TCIF_TEXT IsMask: TabProperties
                0 InsertTab: TabProperties

                z" Control" IsPsztext: TabProperties
                TCIF_TEXT IsMask: TabProperties
                1 InsertTab: TabProperties

                z" Action" IsPsztext: TabProperties
                TCIF_TEXT IsMask: TabProperties
                2 InsertTab: TabProperties

                Addr: TabProperties Start: frmEditForm
                ClientSize: TabProperties 2over d- Move: frmEditForm

                ['] PropertyFunc SetCommand: frmEditProperties
                Addr: TabProperties Start: frmEditProperties
                ClientSize: TabProperties 2over d- Move: frmEditProperties

                Addr: TabProperties Start: frmAction
                ClientSize: TabProperties 2over d- Move: frmAction

                ;M

:M ShowTab:     ( n -- )
                SetSelectedTab: TabProperties
                0 Addr: TabProperties ontab
                ;M

:M ClassInit:   ( -- )
                ClassInit: Super
                self link-formwindow
                ;M

;Object

: UpdateProperties++    ( -- )
                GetHandle: frmProperties++ 0= ?exit
                LoadProperties: frmEditForm     \ and update
                ;

:Noname         ( -- )   \ edit form properties
                ActiveForm 0= ?exit
                GetHandle: TheMainWindow SetParentWindow: frmProperties++
                Start: frmProperties++
                0 ShowTab: frmProperties++      \ show the form tab
                UpdateProperties++ ; is doForm

:Noname         ( -- )   \ edit control properties
                ActiveForm 0= ?exit
                GetHandle: TheMainWindow SetParentWindow: frmProperties++
                Start: frmProperties++
                1 ShowTab: frmProperties++      \ show the control tab
                initload ; is doEdit

:Noname         ( -- )   \ multiple action on controls
                ActiveForm 0= ?exit
                GetHandle: TheMainWindow SetParentWindow: frmProperties++
                Start: frmProperties++
                2 ShowTab: frmProperties++      \ show the action tab
                ; is doGroupAction

\s
