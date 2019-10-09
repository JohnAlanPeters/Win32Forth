\ About Project Manager

create about-ProjectManager-message
z," Project Manager Version "
ProjectVersion count +z", +z," \n\n"
+z," Developed by Ezra Boyce, Dirk Busch and Rod Oakford\n\n"
+z," Email: win32forth@yahoogroups.com\n\n"
+z," This program uses Zip32.dll, the free zip utility from\n"
+z," the Info-Zip group. It can be obtained from their website.\n"
here about-ProjectManager-message - constant message-length


:Object AboutForm                <Super DialogWindow

Font WinFont
ColorObject FormColor
PushButton btnOk

:M ClassInit:        ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:        ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

:M WindowTitle:        ( -- ztitle )
                z" About Project Manager"
                ;M

:M ParentWindow: ( -- hwnd )
                GetHandle: TheProjectWindow
                ;M

:M StartSize:        ( -- width height )
                365 223
                ;M

:M StartPos:        ( -- x y )
                StartPos: TheProjectWindow 50 50 d+
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:        ( -- )
                10 Width: WinFont
                Create: WinFont

                COLOR_BTNFACE Call GetSysColor NewColor: FormColor

                IDOK SetID: btnOk
                self Start: btnOk
                118 177 113 30 Move: btnOk
                s" OK" SetText: btnOk

                0 ParentWindow: self call EnableWindow drop  \ disable parent
                ;M

:M WM_COMMAND        ( h m w l -- res )
                over LOWORD ( ID )
                case
                        IDOK  of Close: self endof
                endcase
                0 ;M

:M On_Paint:        ( -- )
                0 0 GetSize: self Addr: FormColor FillArea: dc
                Addr: FormColor SetBkColor: dc
                DT_CENTER         \ uformat
                0 0 GetSize: self SetRect: TempRect
                TempRect          \ rectangle
                -1                \ null terminated string
                about-ProjectManager-message    \ zstring
                GetHandle: dc
                Call DrawText drop
                ;M

:M On_Done:        ( -- )
                Delete: WinFont
                1 ParentWindow: self call EnableWindow drop  \ modal form
                ParentWindow: self Call SetFocus drop
				\ Insert your code here
                On_Done: super
                ;M

;Object


\s
