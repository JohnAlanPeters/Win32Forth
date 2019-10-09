\ FormControls.f
Comment:
Actual controls are used in a form. Some messages are overridden so that the
controls would behave themselves. Subclassing was tried but was unsuccessful.
Comment;

: mousepos      ( -- n )
                ActiveForm
                if      Gethandle: ActiveForm get-mouse-xy word-join
                else    0
                then    ;

:Class FFLabel          <Super Label

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFTextBox        <Super TextBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFCheckBox       <Super CheckBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFRadioButton    <Super RadioButton

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFPushButton     <Super PushButton

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFListBox        <Super ListBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class


:Class FFComboBox       <Super ComboBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M


;Class

:Class FFComboListBox   <Super ComboListBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFMultiListBox   <Super MultiListBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFBitmapButton   <Super BitmapButton

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFMultiLineTextBox       <Super MultiLineTextBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFGroupBox       <Super GroupBox

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFStaticBitmap   <Super StaticBitmap

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class


:Class FFHorizScroll   <Super HorizScroll

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFVertScroll    <Super VertScroll

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

;Class

:Class FFGenericControl    <Super Child-Window

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

:M ClassInit:       ( -- )
                    ClassInit: Super
                    NextID to ID ;M

:M WindowStyle:      ( -- style )
                     WindowStyle: Super
                     WS_BORDER or
                     ;M

int cfont
:M SetFont:          ( fonthndl -- )
                     to cfont ;M

33 bytes ChildName
:M SetText:         ( addr cnt -- )
                    ChildName place ;M

:M On_Paint:        ( -- )
                    0 0 Width Height WHITE fillArea: dc
                    Childname c@
                    if      cfont SetFont: dc
                            1 1 ChildName count TextOut: dc
                    then    ;M

;Class

:Class FFFileWindow    <Super Child-Window
FolderViewer TheFileLister

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

:M SetFont:             ( fonthndl -- )
                        drop ;M

:M WindowStyle:         ( -- style )
                        WindowStyle: Super
                        WS_BORDER or ;M

:M ClassInit:       ( -- )
                    ClassInit: Super
                    NextId to ID ;M

:M On_Init:         ( -- )
                    self Start: TheFileLister ;M

:M On_Paint:        ( -- )
                    0 0 Width 8 BLACK FillArea: dc ;M

:M On_Size:         ( -- )
                    0 9 Width Height 2 pick - Move: TheFileLister ;M

:M SetPath:     ( addr cnt -- )
                SetPath: TheFileLister ;M

:M UpdateFiles: ( -- )
                UpdateFiles: TheFileLister ;M

;Class

:Class FFTabControl    <Super TabControl
int firsttime

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

33 bytes ChildName
:M SetText:         ( addr cnt -- )
                    ChildName place
                    ChildName count asciiz IsPsztext: self
                    TCIF_TEXT IsMask: self
                    0 firsttime
                    if      InsertTab: self
                            false to firsttime
                    else    SetTabInfo: self
                    then    ;M

:M ClassInit:       ( -- )
                    ClassInit: Super
                    true to firsttime ;M

;Class

:Class FFSpinnerControl       <Super SpinnerControl

:M WM_LBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_LBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONDOWN       { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_RBUTTONUP         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_MOUSEMOVE         { h m w l -- res }
                        mousepos w  m SendMessage: ActiveForm
                        0 ;M

:M WM_SETFOCUS          { h m w l -- res }
                        l w m SendMessage: ActiveForm
                        0 ;M

:M SetText:             ( addr cnt -- )
                        SetText: TheBox ;M
;Class


create txtStyle ES_LEFT , ES_CENTER , ES_RIGHT , 0 ,           \ possible styles for textboxes
create btnStyle BS_LEFT , BS_CENTER , BS_RIGHT , 0 ,           \ possible styles for pushbuttons
create lblStyle SS_LEFT , SS_CENTER , SS_RIGHT , 0 ,           \ possible styles for labels
create chkStyle BS_LEFT , BS_CENTER , BS_RIGHT , BS_LEFTTEXT ,  \ possible styles for checkboxes

\ bitmaps for controls
load-bitmap Static_Bitmap "static.bmp"
load-bitmap PictureBitmap "picture.bmp"


\ define class object that will be use to store control information
:Class ControlObject      <Super Object
65 constant maxtooltip
100 constant maxbitmap
LF_FACESIZE 28 + constant sizeof(LogFont)
int TheControl

UpDownControl spinner     \ used only for textboxes

Record: ctrlData
            int ctrlWidth
            int ctrlHeight
            int ctrlOriginX
            int ctrlOriginY
            int ctrlType
maxstring bytes ctrlTitle
       32 bytes ctrlName
            int ctrlFlags
         1 bits ctrlGroup
         1 bits ctrlBorder
         1 bits ctrlDefButton   \ for pushbuttons
         1 bits ctrlNumberOnly  \ for textboxes
         1 bits ctrlPassword    \ ditto
         2 bits ctrlOrientation
         1 bits ctrlGlobal      \ 1 = make this control available globally
         1 bits fontchanged
         1 bits ctrlSpinner
        22 bits moreFlags       \ flags such as BS_CENTER, SS_CENTRE etc. could be added if desired
            int Reserved2       \ for future
       16 bytes Reserved        \ extensions
       maxtooltip bytes ctrlToolTip
       maxbitmap bytes ctrlBitmap
       sizeof(LogFont) bytes ctrlfont         \ for font structure
       520 maxtooltip maxbitmap + sizeof(LogFont) + - bytes strReserved
;RecordSize: SizeOf(ctrlData)

Font TheFont

int oldstyle

: control-rect  ( -- left top right bottom )
                ctrlOriginx ctrlOriginy
                over ctrlWidth + over ctrlHeight + ;

:M GetWindowRect:   ( -- left top right bottom )
                    control-rect ;M


:M SetWindowPos: { x y -- }
                 x to ctrlOriginx y to ctrlOriginy
                 ;M

:M Move:        { x y w h -- }
                x to ctrlOriginx y to ctrlOriginy
                w to ctrlWidth h to ctrlHeight
                TheControl
                if      x y w h Move: TheControl
                then    ;M

\ BS_LEFTTEXT valid only for checkboxes and radiobuttons
: ?whichstyle   ( -- style )
                ctrlType dup TypeCheckBox = swap TypeRadioButton = or
                if      chkStyle
                else    btnStyle   \ ignore for any other control
                then    ;

: ?ButtonStyle  ( -- n )
                ctrlType
                case
                        TypeLabel        of     lblStyle        endof
                        TypeMultiLineBox of     txtStyle        endof
                        ?whichstyle swap
                endcase ctrlOrientation cells+ @ ;


: ?IsTypeListBox ( --  )
                ctrltype
                |   TypeListBox
                    TypeComboBox
                    TypeComboListBox
                    TypeMultiListBox
                |if     Clear: TheControl
                        ctrlName count asciiz AddStringTo: TheControl
                        0 SetSelection: TheControl
                then    ;

: ?IsTypeButton/Text ( -- )
                ctrlType
                |   TypePushbutton
                    TypeGroupBox
                    TypeCheckBox
                    TypeRadioButton
                    TypeLabel
                    TypeTextBox
                    TypeMultiLineBox
                |if ?ButtonStyle
                    Close: spinner  \ do this first
                    \ if control property window is open we need to save parent first
                    GetParent: TheControl Close: TheControl
                    \ we add the style before the control is created in case it was changed
                    swap AddStyle: TheControl
                    ( parent ) Start: TheControl  \ restart
                    Handle: TheFont SetFont: TheControl
                    \ we need to use a copy of the control caption in case we are using line
                    \ breaks which btw seems to be valid only in labels
                    ctrlTitle count pad place
                    ctrltype Typelabel =
                    if      pad count \n->crlf
                    then    pad count SetText: TheControl
                then    ;

: ?IsTypeImage  ( -- )
                ctrlType
                |   TypeBitmapButton
                    TypeStaticBitmap
                    TypeIconButton
                |if ctrlBitmap count ?dup
                    if      asciiz LoadBitmap dup 0=
                            if      drop picturebmp
                            then
                    else    drop picturebmp
                    then    SetImage: TheControl
                then    ;

: ?IsTypeGeneric  ( -- )
                ctrlType TypeGeneric =
                if      ctrlName count SetText: TheControl
                then    ;

: ?IsTypeFileWindow ( -- )
                ctrltype TypeFileWindow =
                if      UpdateFiles: TheControl
                then    ;

: ?IsTypeTabControl ( -- )
                ctrlType TypeTabControl =
                if     ctrlName count SetText: TheControl
                then    ;

:M TheControl:  ( -- control )
                TheControl ;M

: ?addspinner ( -- )
              ctrltype TypeTextBox = ctrlspinner and
              if       GetParent: TheControl Start: spinner
                       GetHandle: TheControl SetBuddy: spinner
              else     Close: spinner
              then ;

:M Update:      ( -- )
                TheControl
                if      ?IsTypeListBox
                        ?IsTypeButton/Text
                        ?IsTypeImage
                        ?IsTypeGeneric
                        ?IsTypeFileWindow
                        ?IsTypeTabControl
                        \ adjust dimensions last for static labels
                        ctrlOriginX ctrlOriginY ctrlWidth ctrlHeight Move: TheControl
                        ?addspinner
                        Paint: TheControl
                then     ;M

:M CreateFont:  ( -- )
                Delete: TheFont
                Create: TheFont
                Handle: TheFont SetFont: TheControl ;M

:M GetUserFont: ( -- )
                Delete: TheFont
                GetHandle: ActiveForm Choose: TheFont drop
                GetLogFont: TheFont ctrlFont sizeof(LogFont) move  \ save font info
                true to fontchanged
                CreateFont: self
                Update: self
                ;M

: default-font  ( -- )
                Delete: TheFont
                ControlFont.LogFont TheFont.LogFont sizeof(LogFont) move
                ControlFont.LogFont ctrlFont sizeof(LogFont) move ;

:M DefaultFont: ( -- ) \ reset to default font
\                fontchanged not ?exitm
                default-font
                CreateFont: self
                false to fontchanged
                Update: self
                ;M

: SetTheFont    (  -- )
                ctrlFont TheFont.LogFont sizeOf(LogFont) move
                \ the following is done to correct any previously created forms which have the
                \ font flag invalidly set and no font information
                GetFaceName: TheFont nip 0=
                if    default-font
                      false to fontchanged
                then  ;

:M ClassInit:   ( -- )
                ClassInit: super
                ctrlTitle maxstring erase
                TypePushButton to ctrlType
                0 to TheControl
                0 to ctrlflags    \ avoid random flags for any future enhancements
                10 to ctrlOriginY
                10 to ctrlOriginX
                16 to ctrlHeight
                40 to ctrlWidth
                false to ctrlGroup
                false to ctrlBorder
                false to ctrlDefButton
                0 to ctrlOrientation
                0 to ctrlGlobal         \ local by default
                0 to oldstyle
                false to fontchanged
                ctrlToolTip maxtooltip erase
                ctrlBitmap maxbitmap erase
                default-font
                ;M

:M GetData:      ( -- addr cnt )
                ctrlData sizeof(ctrlData)
                ;M

:M SetData:     ( addr cnt -- )
                sizeof(ctrlData) min 0max ctrlData swap move
                ;M

:M GetTitle:    ( -- title )
                ctrlTitle count
                ;M

:M SetTitle:    ( addr cnt -- )
                maxcounted min 0max ctrlTitle place
                ;M

:M GetName:     ( -- addr cnt )
                ctrlName count
                ;M

:M SetName:     ( addr cnt -- )
                31 min 0max ctrlName place
                ;M

:M Dimensions:  ( -- width height )
                ctrlWidth ctrlHeight
                ;M

:M SetDimensions:       ( width height -- )
                to ctrlHeight to ctrlWidth
                ;M

:M Origin:      ( -- x y )
                ctrlOriginx ctrlOriginy
                ;M

:M SetOrigin:   ( x y -- )
                to ctrlOriginy to ctrlOriginx
                ;M

:M GetType:     ( -- ctrltype )
                ctrlType
                ;M

:M SetType:     ( type -- )
                to ctrlType
                ;M

:M IsBitmap:    ( addr cnt -- )
                maxbitmap 2 - min 0max ctrlBitmap place
                ctrlbitmap +null ;M

:M GetBitmap:   ( -- addr cnt )
                ctrlBitmap count ;M

:M IsToolTip:   ( addr cnt -- )
                maxtooltip 1- min 0max ctrlToolTip place ;M

:M GetToolTip:  ( -- addr cnt )
                ctrlToolTip count ;M

:M IsGROUP:     ( f -- )
                to ctrlGroup ;M

:M GROUP?:      ( -- f )
                ctrlGroup ;M

:M Orientation: ( -- f )
                ctrlOrientation ;M

:M IsOrientation: ( f -- )
                to ctrlOrientation ;M

:M Global?:     ( -- f )
                ctrlGlobal ;M

:M IsGlobal:    ( f -- )
                to ctrlGlobal ;M

:M Spinner?:    ( -- f )
                ctrlSpinner ;M

:M IsSpinner:   ( f -- )
                to ctrlSpinner ;M

:M FontChanged: ( -- f )
                fontchanged ;M

:M FontData:    ( -- addr cnt )
                ctrlfont sizeof(logfont) ;M

: Do-Init      ( -- )
                ctrltype
                case
                        TypePushbutton          of      New> FFPushButton       endof
                        TypeLabel               of      New> FFLabel            endof
                        TypeTextBox             of      New> FFTextBox          endof
                        TypeRadioButton         of      New> FFRadioButton      endof
                        TypeCheckBox            of      New> FFCheckBox         endof
                        TypeListBox             of      New> FFListBox          endof
                        TypeComboBox            of      New> FFComboListBox     endof
                        TypeGroupBox            of      New> FFGroupBox         endof
                        TypeBitmapButton        of      New> FFBitmapButton     endof
                        TypeHorizScroll         of      New> FFHorizScroll      endof
                        TypeVertScroll          of      New> FFVertScroll       endof
                        TypeStaticBitmap        of      New> FFStaticBitmap     endof
                        TypeComboListBox        of      New> FFComboListBox     endof
                        TypeMultiLineBox        of      New> FFMultiLineTextBox endof
                        TypeMultiListBox        of      New> FFMultiListBox     endof
                        TypeGeneric             of      New> FFGenericControl   endof
                        TypeFileWindow          of      New> FFFileWindow       endof
                        TypeTabControl          of      New> FFTabControl       endof
                        ( default )        New> FFPushButton swap
                endcase to TheControl
                ActiveForm Start: TheControl
                SetTheFont CreateFont: self
                Update: self ;

:M DoInit:      ( -- )
                ['] Do-Init catch ExitOnError
                ;M

:M Initialize:  { \ temp$ -- }
                32 LocalAlloc: temp$
                ctrlType
                case
                        TypePushbutton          of      s" Button"      endof
                        TypeLabel               of      s" Label"       endof
                        TypeTextBox             of      s" TextBox"     endof
                        TypeRadioButton         of      s" Radio"       endof
                        TypeCheckBox            of      s" Check"       endof
                        TypeListBox             of      s" List"        endof
                        TypeComboBox            of      s" Combo"       endof
                        TypeGroupBox            of      s" Group"       endof
                        TypeBitmapButton        of      s" Bitmap"      endof
                        TypeHorizScroll         of      s" Horiz"       endof
                        TypeVertScroll          of      s" Vert"        endof
                        TypeStaticBitmap        of      s" Static"      endof
                        TypeComboListBox        of      s" CmbList"     endof
                        TypeMultiLineBox        of      s" MText"       endof
                        TypeMultiListBox        of      s" MList"       endof
                        TypeGeneric             of      s" Generic"     endof
                        TypeFileWindow          of      s" FileWindow"  endof
                        TypeTabControl          of      s" TabControl"  endof
                        ( default )                     s" Control" rot
                endcase \ default is name + count
                temp$ place ctrltype Array(): ActiveForm (.) temp$ +place
                temp$ count 2dup SetTitle: self     \ caption
                                  SetName: self    \ name
                DoInit: self
                 ;M

:M Free:           ( -- )  \ what to do when disposing control
                TheControl
                if      GetHandle: TheControl
                        if      Close: Spinner  \ must close this!!, bug took me a looooooong time to find :-(
                                Close: TheControl       \ if open close first
                                Delete: TheFont
                        then    TheControl dispose
                        0 to TheControl
                then    ;M

;Class
\s
