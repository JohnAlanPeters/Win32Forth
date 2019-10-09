\ MSGBOXBUILDER.FRM
\- textbox needs excontrols.f


needs exutils.f


:Object frmMsgBoxBuilder                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpIcons
GroupBox grpButtons
GroupBox grpModal
Label lblName
TextBox txtName
Label lblTitle
TextBox txtTitle
Label lblText
MultiLineTextBox mtxtText
GroupRadioButton radApplication
RadioButton radTask
RadioButton radSystem
GroupRadioButton radNone
RadioButton radStop
RadioButton radQuestion
RadioButton radExclamation
RadioButton radInformation
GroupRadioButton radOK
RadioButton radYesNo
RadioButton radRetryCancel
RadioButton radOkCancel
RadioButton radYesNoCancel
RadioButton radAbortRetryIgnore
PushButton btnTest
PushButton btnCopy
PushButton btnClose
\ Coordinates and dimensions for imgStop
81  value imgStopX
230  value imgStopY
36  value imgStopW
38  value imgStopH
\ Coordinates and dimensions for imgQuestion
142  value imgQuestionX
230  value imgQuestionY
36  value imgQuestionW
38  value imgQuestionH
\ Coordinates and dimensions for imgExclamation
227  value imgExclamationX
229  value imgExclamationY
36  value imgExclamationW
38  value imgExclamationH
\ Coordinates and dimensions for imgInFormation
303  value imgInFormationX
229  value imgInFormationY
36  value imgInFormationW
38  value imgInFormationH

StaticIcon iconApplication
StaticIcon iconQuestion
StaticIcon iconExclamation
StaticIcon iconInformation

0 value icontype        \ 0-none, 1-stop, 2-question, 3-exclamation, 4-information
0 value modaltype       \ 0-application, 1-task, 2-system
0 value buttontype      \ 0-yes, 1-yesno, 2-retrycancel, 3-okcancel, 4-yesnocancel, 5-abortretryignore
create title$ 0 , maxstring allot
create text$ 0 , maxstring allot
create msgboxName$ 0 , 61 allot

: ?IconType     ( -- n )
        icontype
        case
                1       of      MB_ICONHAND             endof
                2       of      MB_ICONQUESTION         endof
                3       of      MB_ICONEXCLAMATION      endof
                4       of      MB_ICONINFORMATION      endof
                0 swap
        endcase ;
        
: ?ModalType    ( -- n )
        modaltype
        case
                1       of      MB_TASKMODAL            endof
                2       of      MB_SYSTEMMODAL          endof
                MB_APPLMODAL swap
        endcase ;
        
: ?ButtonType   ( -- n )
        buttontype
        case
                1       of      MB_YESNO                endof
                2       of      MB_RETRYCANCEL          endof
                3       of      MB_OKCANCEL             endof
                4       of      MB_YESNOCANCEL          endof
                5       of      MB_ABORTRETRYIGNORE     endof
                MB_OK swap
        endcase ;

: ?IconType$     ( -- str cnt )
        icontype
        case
                1       of      s" MB_ICONHAND "            endof
                2       of      s" MB_ICONQUESTION "        endof
                3       of      s" MB_ICONEXCLAMATION "     endof
                4       of      s" MB_ICONINFORMATION "     endof
                s" 0 " rot
        endcase ;
        
: ?ModalType$    ( -- str cnt )
        modaltype
        case
                1       of      s" MB_TASKMODAL "            endof
                2       of      s" MB_SYSTEMMODAL "         endof
                s" MB_APPLMODAL " rot 
        endcase ;
        
: ?ButtonType$   ( -- str cnt )
        buttontype
        case
                1       of      s" MB_YESNO "                endof
                2       of      s" MB_RETRYCANCEL "          endof
                3       of      s" MB_OKCANCEL "            endof
                4       of      s" MB_YESNOCANCEL "         endof
                5       of      s" MB_ABORTRETRYIGNORE "    endof
                s" MB_OK " rot 
        endcase ;
        
: SaveText$     ( -- )
                GetText: txtTitle title$ place title$ +NULL
                GetText: mtxtText maxstring min text$ place text$ +NULL
                GetText: txtName 60 min msgboxName$ place ;

: crlf->\n     ( a1 n1 -- )    \ parse crlf line end occurances, change to \n (opposite of \n->crlf)
                begin   0x0D scan dup               \ found a CR char
                while   over 1+ c@ 0x0A =           \ followed by LF
                        if      over [char] \ swap c!         \ replace with \
                                over [char] n swap 1+ c!      \ replace with LF
                        then    1 /string               \ else skip '\' char
                repeat  2drop   ;               
        
: BuildMsgBox   ( -- addr cnt )
                initbuffer
                s" : " append msgboxName$ c@ 
                if      msgboxName$ count
                else    s" _MsgBox"
                then    append 1 +tabs s" ( -- result )" append&crlf
                text$ count pad place pad count crlf->\n
                2 +tabs z"append pad count append "append s"      \ message text" append&crlf
                2 +tabs z"append title$ count append "append s"     \ msgbox title" append&crlf
                2 +tabs ?IconType$ append ?ModalType$ append s" or " append ?ButtonType$ append
                s" or " append s"     \ style" append&crlf
                2 +tabs s" NULL    \ owner handle, change as desired" append&crlf
                2 +tabs s" MessageBox ; " append&crlf 
                thebuffer ;



: On_radApplication   ( h m w l -- )  \ what to do when radApplication control has been clicked
0 to modaltype
; 

: On_radTask   ( h m w l -- )  \ what to do when radTask control has been clicked
1 to modaltype
; 

: On_radSystem   ( h m w l -- )  \ what to do when radSystem control has been clicked
2 to modaltype
; 

: On_radNone   ( h m w l -- )  \ what to do when radNone control has been clicked
0 to icontype
; 

: On_radStop   ( h m w l -- )  \ what to do when radStop control has been clicked
1 to icontype
; 

: On_radQuestion   ( h m w l -- )  \ what to do when radQuestion control has been clicked
2 to icontype
; 

: On_radExclamation   ( h m w l -- )  \ what to do when radExclamation control has been clicked
3 to icontype
; 

: On_radInformation   ( h m w l -- )  \ what to do when radInformation control has been clicked
4 to icontype
; 

: On_radOK   ( h m w l -- )  \ what to do when radOK control has been clicked
0 to buttontype
; 

: On_radYesNo   ( h m w l -- )  \ what to do when radYesNo control has been clicked
1 to buttontype
; 

: On_radRetryCancel   ( h m w l -- )  \ what to do when radRetryCancel control has been clicked
2 to buttontype
; 

: On_radOkCancel   ( h m w l -- )  \ what to do when radOkCancel control has been clicked
3 to buttontype
; 

: On_radYesNoCancel   ( h m w l -- )  \ what to do when radYesNoCancel control has been clicked
4 to buttontype
; 

: On_radAbortRetryIgnore   ( h m w l -- )  \ what to do when radAbortRetryIgnore control has been clicked
5 to buttontype
; 

: On_btnTest   ( h m w l -- )  \ what to do when btnTest control has been clicked
SaveText$
text$ 1+                                        \ message
title$ 1+                                       \ title
?IconType ?ButtonType or ?ModalType or          \ style
NULL MessageBox drop
; 

: On_btnCopy   ( h m w l -- )  \ what to do when btnCopy control has been clicked
Savetext$
BuildMsgBox copy-clipboard
; 

: On_btnClose   ( h m w l -- )  \ what to do when btnClose control has been clicked
Close: self
; 

: frmDefaultCommand	( h m w l id obj -- )
                drop
                case
                    GetID: radApplication       of On_radApplication    endof
                    GetID: radTask              of On_radTask           endof
                    GetID: radSystem            of On_radSystem         endof
                    GetID: radNone              of On_radNone           endof
                    GetID: radStop              of On_radStop           endof
                    GetID: radQuestion          of On_radQuestion       endof
                    GetID: radExclamation       of On_radExclamation    endof
                    GetID: radInformation       of On_radInformation    endof
                    GetID: radOK                of On_radOK             endof
                    GetID: radYesNo             of On_radYesNo          endof
                    GetID: radRetryCancel       of On_radRetryCancel    endof
                    GetID: radOkCancel          of On_radOkCancel       endof
                    GetID: radYesNoCancel       of On_radYesNoCancel    endof
                    GetID: radAbortRetryIgnore  of On_radAbortRetryIgnore endof
                    GetID: btnTest              of On_btnTest           endof
                    GetID: btnCopy              of On_btnCopy           endof
                    IDCANCEL                    of On_btnClose          endof
                endcase    ;

: OnInitFunction      ( -- )   \ executed after form and all controls have been created
self Start: iconApplication
imgStopX imgStopY imgStopW imgStopH Move: iconApplication
IDI_HAND NULL Call LoadIcon SetImage: iconApplication

self Start: iconQuestion
imgQuestionX imgQuestionY imgQuestionW imgQuestionH Move: iconQuestion
IDI_QUESTION NULL Call LoadIcon SetImage: iconQuestion

self Start: iconExclamation
imgExclamationX imgExclamationY imgExclamationW imgExclamationH Move: iconExclamation
IDI_EXCLAMATION NULL Call LoadIcon SetImage: iconExclamation

self Start: iconInformation
imgInformationX imgInformationY imgInformationW imgInformationH Move: iconInFormation
IDI_INFORMATION NULL Call LoadIcon SetImage: iconInformation

modaltype 0=   Check: radApplication
modaltype 1 =  Check: radTask
modaltype 2 =  Check: radSystem

icontype 0=    Check: radNone
icontype 1 =   Check: radStop
icontype 2 =   Check: radQuestion
icontype 3 =   Check: radExclamation
icontype 4 =   Check: radInFormation

buttontype 0=  Check: radOk
buttontype 1 = Check: radYesNo
buttontype 2 = Check: radRetryCancel
buttontype 3 = Check: radOkCancel
buttontype 4 = Check: radYesNoCancel
buttontype 5 = Check: radAbortRetryIgnore

title$ count      SetText: txtTitle
text$ count       SetText: mtxtText
msgboxName$ count SetText: txtName

; 


:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ N.B if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" MessageBox Builder"
                ;M

:M StartSize:   ( -- width height )
                393 426 
                ;M

:M StartPos:    ( -- x y )
                350  175
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
                ;M

:M WM_COMMAND   ( h m w l -- res )
                dup 0=      \ id is from a menu if lparam is zero
                if        over LOWORD CurrentMenu if dup DoMenu: CurrentMenu then
                          CurrentPopup if dup DoMenu: CurrentPopup then drop
                else	  over LOWORD ( ID ) self   \ object address on stack
                          WMCommand-Func ?dup    \ must not be zero
                          if        execute
                          else    2drop   \ drop ID and object address
                          then
                then      0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpIcons
                20 184 359 95 Move: grpIcons
                Handle: Winfont SetFont: grpIcons
                s" Icons" SetText: grpIcons

                self Start: grpButtons
                19 289 358 86 Move: grpButtons
                Handle: Winfont SetFont: grpButtons
                s" Buttons" SetText: grpButtons

                self Start: grpModal
                266 39 124 100 Move: grpModal
                Handle: Winfont SetFont: grpModal
                s" MODAL" SetText: grpModal

                self Start: lblName
                17 10 33 20 Move: lblName
                Handle: Winfont SetFont: lblName
                s" Name:" SetText: lblName

                self Start: txtName
                53 11 97 20 Move: txtName
                Handle: Winfont SetFont: txtName

                self Start: lblTitle
                17 42 27 20 Move: lblTitle
                Handle: Winfont SetFont: lblTitle
                s" Title:" SetText: lblTitle

                self Start: txtTitle
                53 42 199 20 Move: txtTitle
                Handle: Winfont SetFont: txtTitle

                self Start: lblText
                17 82 30 19 Move: lblText
                Handle: Winfont SetFont: lblText
                s" Text:" SetText: lblText

                self Start: mtxtText
                53 81 199 89 Move: mtxtText
                Handle: Winfont SetFont: mtxtText

                self Start: radApplication
                278 52 100 25 Move: radApplication
                Handle: Winfont SetFont: radApplication
                s" Application" SetText: radApplication

                self Start: radTask
                278 79 100 25 Move: radTask
                Handle: Winfont SetFont: radTask
                s" Task" SetText: radTask

                self Start: radSystem
                278 106 100 25 Move: radSystem
                Handle: Winfont SetFont: radSystem
                s" System" SetText: radSystem

                self Start: radNone
                25 201 52 25 Move: radNone
                Handle: Winfont SetFont: radNone
                s" None" SetText: radNone

                self Start: radStop
                79 201 48 25 Move: radStop
                Handle: Winfont SetFont: radStop
                s" Stop" SetText: radStop

                self Start: radQuestion
                129 201 70 25 Move: radQuestion
                Handle: Winfont SetFont: radQuestion
                s" Question" SetText: radQuestion

                self Start: radExclamation
                201 201 78 25 Move: radExclamation
                Handle: Winfont SetFont: radExclamation
                s" Exclamation" SetText: radExclamation

                self Start: radInformation
                281 201 79 25 Move: radInformation
                Handle: Winfont SetFont: radInformation
                s" Information" SetText: radInformation

                self Start: radOK
                25 305 100 25 Move: radOK
                Handle: Winfont SetFont: radOK
                s" OK" SetText: radOK

                self Start: radYesNo
                127 305 100 25 Move: radYesNo
                Handle: Winfont SetFont: radYesNo
                s" Yes ,No" SetText: radYesNo

                self Start: radRetryCancel
                250 305 100 25 Move: radRetryCancel
                Handle: Winfont SetFont: radRetryCancel
                s" Retry ,Cancel" SetText: radRetryCancel

                self Start: radOkCancel
                25 332 100 25 Move: radOkCancel
                Handle: Winfont SetFont: radOkCancel
                s" OK ,Cancel" SetText: radOkCancel

                self Start: radYesNoCancel
                127 332 100 25 Move: radYesNoCancel
                Handle: Winfont SetFont: radYesNoCancel
                s" Yes ,No ,Cancel" SetText: radYesNoCancel

                self Start: radAbortRetryIgnore
                250 332 117 25 Move: radAbortRetryIgnore
                Handle: Winfont SetFont: radAbortRetryIgnore
                s" Abort ,Retry , Ignore" SetText: radAbortRetryIgnore

                self Start: btnTest
                45 392 51 24 Move: btnTest
                WS_GROUP +Style: btnTest
                Handle: Winfont SetFont: btnTest
                s" Test" SetText: btnTest

                self Start: btnCopy
                118 392 100 24 Move: btnCopy
                Handle: Winfont SetFont: btnCopy
                s" Copy to Clipboard" SetText: btnCopy

                IDCANCEL SetID: btnClose
                self Start: btnClose
                235 392 74 24 Move: btnClose
                Handle: Winfont SetFont: btnClose
                s" Close" SetText: btnClose

                ['] frmDefaultCommand SetCommand: self

                OnInitFunction 

                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object
