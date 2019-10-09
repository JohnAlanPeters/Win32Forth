 \ ensure path to files is set in search path
needs EditorForm.frm
needs IDEForm.frm
needs DesignerForm.frm
needs NavigatorForm.frm

\- textbox needs excontrols.f

:Object frmPreferenceSheet                <Super DialogWindow

Font WinFont
ColorObject FrmColor
TabControl SheetTab
150 175 2value XYPos
PushButton btnOk
PushButton btnCancel
PushButton btnApply

: show-frmEditor        ( -- )
                Display: frmEditor
                Hide: frmIDE
                Hide: frmDesigner
                Hide: frmNavigator ;


: show-frmIDE        ( -- )
                Hide: frmEditor
                Display: frmIDE
                Hide: frmDesigner
                Hide: frmNavigator ;


: show-frmDesigner        ( -- )
                Hide: frmEditor
                Hide: frmIDE
                Display: frmDesigner
                Hide: frmNavigator ;


: show-frmNavigator        ( -- )
                Hide: frmEditor
                Hide: frmIDE
                Hide: frmDesigner
                Display: frmNavigator ;


: ontab         { l obj -- }
                GetSelectedTab: obj
                case
                        0        of        show-frmEditor        endof
                        1        of        show-frmIDE        endof
                        2        of        show-frmDesigner        endof
                        3        of        show-frmNavigator        endof
                endcase  ;

:M ShowTab:    ( n -- )
                dup SetSelectedTab: SheetTab
                Addr: SheetTab ontab
                ;M

:M StartSize:    ( -- w h )
                419 344 ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M On_Size:     ( -- )
                0 0 Width Height 35 - Move: SheetTab
                ClientSize: SheetTab 2over d- Move: frmEditor
                ClientSize: SheetTab 2over d- Move: frmIDE
                ClientSize: SheetTab 2over d- Move: frmDesigner
                ClientSize: SheetTab 2over d- Move: frmNavigator
                ;M

:M WindowTitle: ( -- ztitle )
                z" Preferences"
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or ;M

:M on_init:     ( -- )
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor
                
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                ['] ontab IsChangeFunc: SheetTab

                \ start the individual forms of the property sheet
                self Start: SheetTab
                0 0 1 1 Move: SheetTab
                Handle: WinFont SetFont: SheetTab
                
                z" Editor" IsPsztext: SheetTab
                TCIF_TEXT IsMask: SheetTab
                1 InsertTab: SheetTab

                z" IDE" IsPsztext: SheetTab
                TCIF_TEXT IsMask: SheetTab
                2 InsertTab: SheetTab

                z" Form Designer" IsPsztext: SheetTab
                TCIF_TEXT IsMask: SheetTab
                3 InsertTab: SheetTab

                z" Project Navigator" IsPsztext: SheetTab
                TCIF_TEXT IsMask: SheetTab
                4 InsertTab: SheetTab

                Addr: SheetTab Start: frmEditor
                
                Addr: SheetTab Start: frmIDE
                
                Addr: SheetTab Start: frmDesigner
                
                Addr: SheetTab Start: frmNavigator
                
                0 ShowTab: self

                IDOK SetID: btnOk
                self Start: btnOk
                173 314 80 25 Move: btnOk
                Handle: WinFont SetFont: btnOk
                s" &Ok" SetText: btnOk

                IDCANCEL SetID: btnCancel
                self Start: btnCancel
                255 314 80 25 Move: btnCancel
                Handle: WinFont SetFont: btnCancel
                s" &Cancel" SetText: btnCancel

                self Start: btnApply
                337 314 80 25 Move: btnApply
                Handle: WinFont SetFont: btnApply
                s" &Apply" SetText: btnApply

                GetParentWindow: self ?dup \ if this is a modal form disable parent
                if   0 swap Call EnableWindow drop then

                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc ;M

:M Close:  ( -- )
                Close: frmEditor
                Close: frmIDE
                Close: frmDesigner
                Close: frmNavigator
                Close: super ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here
                GetParentWindow: self ?dup  \ if modal form re-enable parent
                if   1 swap Call EnableWindow drop
                     \ reset focus to parent if we have one
                     GetParentWindow: self Call SetFocus drop
                then
                On_Done: super  ;M

:M WM_NOTIFY  ( h m w l -- f )
                Handle_Notify: SheetTab ;M

;Object
