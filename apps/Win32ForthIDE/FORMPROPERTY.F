\ Form and control editing
load-bitmap savebmp1 "save1.bmp"
load-bitmap savebmp2 "save2.bmp"
\ load-bitmap stopbmp1 "stop1.bmp"
\ load-bitmap stopbmp2 "stop2.bmp"

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

: Fill-IDList		( -- )
		Clear: cmblstIDs
		#ids 0
		do	i GetID$ asciiz AddStringTo: cmblstIDs
		loop	ID: eActiveControl check-id SetSelection: cmblstIDs ;

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
                Fill-IDList
                GetType: eActiveControl font-type? Enable: btnChangeFont
                GetType: eActiveControl dup
                TypeBitmapButton = swap TypeStaticBitmap = or
                if      Disable: radLeft
                        Disable: radCenter
                        Disable: radRight
                        Disable: radLefttext
                        Disable: grpOrientation
                        true Enable: txtBitmap
                        true Enable: btnBrowse
                else    \ first clear any previous orientation sel                                                                        ection
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
                then	GetCurrent: cmblstIDs IsID: eActiveControl
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
                Paint: eActiveForm                     \ and refresh display
                doUpdate ;

: ClearControlProperties  ( -- )
		s" No control selected!" SetText: txtName
		s" "
		2dup SetText: txtCaption
		2dup SetText: txtTooltip
		     SetText: txtBitmap
		Disable: btnChangeFont ;

: initload      ( -- )
		ActiveForm 0= ?exit
                ActiveControl: ActiveForm to eActiveControl
                ActiveForm to eActiveForm
                eActiveControl
                if	LoadProperties
                else	ClearControlProperties
                then	RefreshCodeWindow
                eActiveControl
                if	ControlCode: eActiveControl Highlight-Code
                then	;

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

: doEditCode	( -- )
		FLAG_CODE RefreshActiveCoder ;

: PropertyFunc  ( h m w l id obj -- h m w l )
                { cid obj -- }
                cid     \ control id
                case
                                 IDOK     of      SaveProperties   endof
                                 GetID: btnPrevious
                                          of      doPrevious       endof
                                 GetID: btnNext
                                          of      doNext           endof
                                 GetID: btnChangeFont
					  of	GetUserFont: eActiveControl
					  endof
                                 endcase ;

:Noname         ( -- )
\               GetHandle: frmEditProperties 0= ?exit    \ window  is not open
\ Remove comment from the following if you will need to save the properties first
\ If you do and you are just browsing controls the form(s) will be marked as
\ modified even though you haven't made any changes.

\                SaveProperties          \ save first
		initload                \ reload for new control
                ; is UpDatePropertyWindow

:Object frmEditForm                <Super frmEditFormProperties

:M ClearFormProperties: ( -- )
		s" No form opened!" SetText: txtName
		s" " SetText: txtTitle
		1 SetValue: spnXpos
		1 SetValue: spnYpos
		1 SetValue: spnWidth
		1 SetValue: spnHeight
		false
                        dup Check: chkModal
                        dup Check: chkSave
                        dup Check: chkChildState
                        dup Check: chkStatusBar
                        dup Check: chkMin
                        dup Check: radChildWindow
                        dup Check: radMDIDialogWindow
                        dup Check: radDialogWindow
                            Check: radTrayWindow
		;M

:M LoadProperties:        ( -- )
		ActiveForm 0=
		if	ClearFormProperties: self exitm
		then	FormName: ActiveForm count SetText: txtName
                FormTitle: ActiveForm count SetText: txtTitle
                   Origin: ActiveForm  SetValue: spnYpos
                                       SetValue: spnXpos
               Dimensions: ActiveForm  SetValue: spnHeight
                                       SetValue: spnWidth
                   GetModal: ActiveForm Check: ChkModal
                SaveScreen?: ActiveForm Check: chkSave
                 ChildState: ActiveForm Check: chkChildState
                 StatusBar?: ActiveForm Check: chkStatusBar
                     HasMin: ActiveForm Check: chkMin
              GetSuperClass: ActiveForm
                case
                        CHILD-CLASS     of  CheckButton: radChildWindow
                                            UnCheckButton: radMDIDialogWindow
                                            UnCheckButton: radDialogWindow
                                            UnCheckButton: radTrayWindow
                                            true Enable: chkChildState
                                        endof
                        MDIDIALOG-CLASS of  CheckButton: radMdiDialogWindow
                                            UnCheckButton: radChildWindow
                                            UnCheckButton: radDialogWindow
                                            UnCheckButton: radTrayWindow
                                            false Enable: chkChildState
                                        endof
                        TRAY-CLASS      of  CheckButton: radTrayWindow
                                            UnCheckButton: radMdiDialogWindow
                                            UnCheckButton: radChildWindow
                                            UnCheckButton: radDialogWindow
                                            false Enable: chkChildState
                                        endof
                                            CheckButton: radDialogWindow    \ default
                                            UnCheckButton: radMDIDialogWindow
                                            UnCheckButton: radChildWindow
                                            UnCheckButton: radTrayWindow
                                            false Enable: chkChildState
                endcase
                ;M

:M SaveProperties:   { \ x y w h -- }
		ActiveForm 0= ?exitm
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
                IsButtonChecked?: chkMin SetMin: ActiveForm
                IsButtonChecked?: radDialogWindow
                if  DIALOG-CLASS
                else    IsButtonChecked?: radChildWindow
                        if  CHILD-CLASS
                        else   IsButtonChecked?: radTrayWindow
                                if TRAY-CLASS
                                else MDIDIALOG-CLASS
                                then
                        then
                then    IsSuperClass: ActiveForm
                0 0 Dimensions: ActiveForm        ( x y w h )
                SetRect: winRect
                0                                       \ no menu
                WindowStyle: ActiveForm                 \ the window style
                winRect                         \ make a new rectangle
                Call AdjustWindowRect ?win-error        \ adjust the window
                Right: winRect Left: winRect -         \ adjusted  width
                Bottom: winRect  Top: winRect -         \ adjusted height
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

:M Clear:	( -- )
		ClearFormProperties: frmEditForm
		ClearControlProperties
		;M

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
                endcase  LoadProperties: frmEditForm
                ;

: ?apply        ( -- )
		ActiveForm 0= ?exit
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
                endcase ;

:M On_Init:     ( -- )

                IDOK SetId: btnApply
                IDCANCEL SetID: btnClose

               ( TCS_BUTTONS ) TCS_FLATBUTTONS  ( or ) AddStyle: TabProperties

                On_Init: Super

                self Start: btnApply
                4 ( btnApplyX ) btnApplyY btnApplyW btnApplyH Move: btnApply
                savebmp2 usebitmap map-3DColors
                savebmp2 setimage: btnapply             \ normal displayed image
                savebmp1 usebitmap map-3DColors
                savebmp1 SetImage#2: btnApply      \ image to display when hovering mouse
                s" Apply" SetText: btnApply
                Handle: WinFont SetFont: btnApply

\                 self Start: btnClose
\                 btnCloseX btnCloseY btnCloseW btnCloseH Move: btnClose
\                 stopbmp2 usebitmap map-3DColors
\                 stopbmp2 setimage: btnclose             \ normal displayed image
\                 stopbmp1 usebitmap map-3DColors         \ image to display when hovering mouse
\                 stopbmp1 SetImage#2: btnClose
\                 s" Close" SetText: btnClose
\                 Handle: WinFont SetFont: btnClose


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

                Clear: self

                ;M

:M ShowTab:     ( n -- )
                SetSelectedTab: TabProperties
                0 Addr: TabProperties ontab
                ;M

;Object

: UpdateProperties++    ( -- )
                LoadProperties: frmEditForm     \ and update for form
                initload  ;			\ and for controls as well

: FormProperty  ( -- )   \ edit form properties
                ActiveForm 0= ?exit
		0 ShowTab: frmProperties++      \ show the form tab
                UpdateProperties++
                SetFocus: ActiveForm  ;  IDM_FORM_FORMPROPERTY SetCommand

: ControlProperty  ( -- )   \ edit control properties
                ActiveForm 0= ?exit
		1 ShowTab: frmProperties++      \ show the control tab
                UpdatePropertyWindow
                SetFocus: ActiveForm ;  IDM_FORM_CONTROLPROPERTY SetCommand

: GroupAction   ( -- )   \ multiple action on controls
                ActiveForm 0= ?exit
		2 ShowTab: frmProperties++      \ show the action tab
                ;  IDM_FORM_GroupAction SetCommand

\s
