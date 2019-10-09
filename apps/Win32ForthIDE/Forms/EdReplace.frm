\ EDREPLACE.FRM
\- textbox needs excontrols.f

ComboBox cmbSearch
ComboBox cmbReplace

:Object frmReplace                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpOptions
GroupBox grpDirection
GroupBox grpScope
GroupBox grpSearch
Label lblSearch
Label lblReplace
CheckBox chkCase
CheckBox chkWholeWord
CheckBox chkPrompt
GroupRadioButton radForward
RadioButton radBackward
GroupRadioButton radGlobal
RadioButton radCurrent
GroupRadioButton radActiveFile
RadioButton radOpenFiles
RadioButton radFolder
CheckBox chkSubdirs
TextBox txtFilespecs
TextBox txtSearchPath
PushButton btnBrowse
PushButton btnOk
PushButton btnCancel
Label lblSpecs
Label lblSearchPath


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
                z" Search & Replace"
                ;M

:M StartSize:   ( -- width height )
                426 342 
                ;M

:M StartPos:    ( -- x y )
                150  175
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


                self Start: grpOptions
                6 68 128 104 Move: grpOptions
                Handle: Winfont SetFont: grpOptions
                s" Options" SetText: grpOptions

                self Start: grpDirection
                144 68 120 78 Move: grpDirection
                Handle: Winfont SetFont: grpDirection
                s" Direction" SetText: grpDirection

                self Start: grpScope
                273 68 144 77 Move: grpScope
                Handle: Winfont SetFont: grpScope
                s" Search Scope" SetText: grpScope

                self Start: grpSearch
                5 181 303 151 Move: grpSearch
                Handle: Winfont SetFont: grpSearch
                s" Search in" SetText: grpSearch

                self Start: lblSearch
                7 8 71 19 Move: lblSearch
                Handle: Winfont SetFont: lblSearch
                SS_RIGHT +Style: lblSearch
                s" Search for:" SetText: lblSearch

                self Start: cmbSearch
                82 8 328 19 Move: cmbSearch
                Handle: Winfont SetFont: cmbSearch

                self Start: lblReplace
                7 31 74 19 Move: lblReplace
                Handle: Winfont SetFont: lblReplace
                SS_RIGHT +Style: lblReplace
                s" Replace with:" SetText: lblReplace

                self Start: cmbReplace
                82 31 328 19 Move: cmbReplace
                Handle: Winfont SetFont: cmbReplace

                self Start: chkCase
                12 88 100 25 Move: chkCase
                WS_GROUP +Style: chkCase
                Handle: Winfont SetFont: chkCase
                s" Case Sensitive" SetText: chkCase

                self Start: chkWholeWord
                12 115 100 25 Move: chkWholeWord
                Handle: Winfont SetFont: chkWholeWord
                s" Whole words only" SetText: chkWholeWord

                self Start: chkPrompt
                12 142 118 25 Move: chkPrompt
                Handle: Winfont SetFont: chkPrompt
                s" Prompt each replace" SetText: chkPrompt

                self Start: radForward
                148 88 100 25 Move: radForward
                Handle: Winfont SetFont: radForward
                s" Forward" SetText: radForward

                self Start: radBackward
                149 116 100 25 Move: radBackward
                Handle: Winfont SetFont: radBackward
                s" Backward" SetText: radBackward

                self Start: radGlobal
                279 88 100 25 Move: radGlobal
                Handle: Winfont SetFont: radGlobal
                s" Global" SetText: radGlobal

                self Start: radCurrent
                279 115 119 25 Move: radCurrent
                Handle: Winfont SetFont: radCurrent
                s" From current position" SetText: radCurrent

                self Start: radActiveFile
                14 196 90 25 Move: radActiveFile
                Handle: Winfont SetFont: radActiveFile
                s" Active File" SetText: radActiveFile

                self Start: radOpenFiles
                14 223 90 25 Move: radOpenFiles
                Handle: Winfont SetFont: radOpenFiles
                s" Opened Files" SetText: radOpenFiles

                self Start: radFolder
                14 250 90 25 Move: radFolder
                Handle: Winfont SetFont: radFolder
                s" Folder" SetText: radFolder

                self Start: chkSubdirs
                110 250 125 28 Move: chkSubdirs
                WS_GROUP +Style: chkSubdirs
                Handle: Winfont SetFont: chkSubdirs
                s" Include Subdirectories" SetText: chkSubdirs

                self Start: txtFilespecs
                50 278 220 20 Move: txtFilespecs
                WS_GROUP +Style: txtFilespecs
                Handle: Winfont SetFont: txtFilespecs

                self Start: txtSearchPath
                80 304 190 20 Move: txtSearchPath
                Handle: Winfont SetFont: txtSearchPath

                self Start: btnBrowse
                275 304 30 20 Move: btnBrowse
                Handle: Winfont SetFont: btnBrowse
                s" ..." SetText: btnBrowse

                self Start: btnOk
                314 277 100 25 Move: btnOk
                Handle: Winfont SetFont: btnOk
                s" OK" SetText: btnOk

                self Start: btnCancel
                314 307 100 25 Move: btnCancel
                Handle: Winfont SetFont: btnCancel
                s" Cancel" SetText: btnCancel

                self Start: lblSpecs
                14 278 32 20 Move: lblSpecs
                Handle: Winfont SetFont: lblSpecs
                s" Filters:" SetText: lblSpecs

                self Start: lblSearchPath
                14 304 62 19 Move: lblSearchPath
                Handle: Winfont SetFont: lblSearchPath
                s" Search path:" SetText: lblSearchPath

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
