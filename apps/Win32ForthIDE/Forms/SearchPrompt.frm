\ SEARCHPROMPT.FRM
\- textbox needs excontrols.f

Label lblSearchString
Label lblReplaced
ListBox lstFoundFiles
PushButton btnCancel

:Object frmSearching                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
350 175  2value XYPos  \ save screen location of form

Label lblSearch


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
                z" Search & Replace in Folder"
                ;M

:M StartSize:   ( -- width height )
                278 271 
                ;M

:M StartPos:    ( -- x y )
                XYPos
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


                self Start: lblSearch
                18 22 70 20 Move: lblSearch
                Handle: Winfont SetFont: lblSearch
                s" Searching for:" SetText: lblSearch

                IDNO SetID: lblSearchString
                self Start: lblSearchString
                88 22 177 20 Move: lblSearchString
                Handle: Winfont SetFont: lblSearchString
                s" " SetText: lblSearchString

                self Start: lblReplaced
                18 48 240 20 Move: lblReplaced
                Handle: Winfont SetFont: lblReplaced
                s" Replaced in:" SetText: lblReplaced

                self Start: lstFoundFiles
                18 75 246 141 Move: lstFoundFiles
                Handle: Winfont SetFont: lstFoundFiles

                IDCANCEL SetID: btnCancel
                self Start: btnCancel
                83 233 119 28 Move: btnCancel
                Handle: Winfont SetFont: btnCancel
                s" Cancel" SetText: btnCancel

                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object
