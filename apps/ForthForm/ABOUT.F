\ About ForthForm

create about-Forthform-message
z," ForthForm Version "
fform_version# ((version))  +z", +z," \n"
+z," The Form Design Tool\n"
+z," for Win32Forth\n"
+z," ***\n"
+z," Developed by Ezra Boyce\n"
+z," Email: ezraboyce@yahoo.com\n"
+z," with\n"
+z," Contributions by Dirk Busch,Rod Oakford\n"
+z," 2000-2007"
here about-ForthForm-message - constant message-length


:Object AboutForm                <Super DialogWindow

Font WinFont

PushButton btnOk

:M ClassInit:        ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:        ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

:M WindowTitle:        ( -- ztitle )
                z" About ForthForm"
                ;M

:M ParentWindow: ( -- hwnd )
                GetHandle: TheMainWindow
                ;M

:M StartSize:        ( -- width height )
                342 223
                ;M

:M StartPos:        ( -- x y )
                225 175
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:        ( -- )
                10 Width: WinFont
                Create: WinFont

                IDOK SetID: btnOk
                self Start: btnOk
                118 177 113 30 Move: btnOk
                s" &Ok" SetText: btnOk

                0 ParentWindow: self call EnableWindow drop  \ disable parent
                ;M

:M WM_COMMAND        ( h m w l -- res )
                over LOWORD ( ID )
                case
                        IDOK  of Close: self endof
                endcase
                0 ;M

:M On_Paint:        ( -- )
                0 0 GetSize: self FormColor FillArea: dc
                FormColor SetBkColor: dc
                DT_CENTER         \ uformat
                0 0 GetSize: self SetRect: TempRect
                TempRect \ rectangle
                -1                \ null terminated string
                about-ForthForm-message \ zstring
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

: _doAbout      ( -- )
                Start: AboutForm ;  ' _doAbout is doAbout
\s
