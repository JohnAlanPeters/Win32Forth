\ TestExample.f   A Demo Form For ForthForm

comment:
Forms created in ForthForm can be used in three ways.
(1) They can be pasted into an application and directly modified.
(2) They can be compiled to a .f file and modified, then included into  an application.
(3) Selected controls can be made global and thus be accessible directly from an
    application.

The last method has certain advantages over the others. When a form is directly modified
it difficult to add or change controls without "upsetting" the app. However, using the
last method, an application is unaware of any changes to the form. Controls can be added,
rearranged or changed as needed. This example describes the latter method.

comment;

anew tst
needs example.f \ load the form
window mywin   \ this will be parent

\ now the function for WM_Command
0 value frm
: ShowResults   ( -- )   \ display form results
                cr ." Your Name is " GetText: txtName type
                cr ." Your Address is " GetText: txtAddress type
                cr ." In the city of " GetText: txtCity type
                cr ." In " GetText: txtCountry type
                IsButtonchecked?: chkWin32Forth
                if      cr ." You are a Win32Forth programmer"
                then    IsButtonchecked?: chkSwiftForth
                if      cr ." You program with SwiftForth"
                then    IsButtonChecked?: chkOther
                if      cr ." You program in another language"
                then    Gettext: txtFilename ?dup
                if      cr ." You selected file " type
                else    drop
                then    cr ;

: ExampleFunc   ( h w m l id obj -- )
                to frm     \ save object address
                case    IDCANCEL of     cr ." You are a quitter!" cr Close: frm endof
                        IDOK     of     ShowResults Close: frm               endof
                endcase ;
' ExampleFunc SetCommand: frmExample    \ install it


\ define function for selecting a file
\ first the get file dialog
FileOpenDialog ExampleDialog "Select A File" "All Files|*.*|"
\ now the function
: GetFile       ( -- )
                frmexample.hwnd Start: ExampleDialog count ?dup
                if      SetText: txtFilename        \ set control text
                else    drop
                then    ;
' GetFile SetFunc: btnBrowse   \ install function

: Dotest        ( -- )
                Start: MyWin     \ the parent window
                0 0 100 100 Move: MyWin

                \ it is a modal form so it needs an owner
                MyWin.hwnd SetParentWindow: frmExample

                IDOK SetID: btnOk    \ some ids
                IDCANCEL SetID: btncancel

                Start: frmExample       \ guess what this does?

                \ set initial values
                s" John Doe" SetText: txtName
                s" Anywhere in the world" SetText: txtAddress
                s" Any city likewise" SetText: txtCity
                s" The Whole Universe" SetText: txtCountry
                s" Click the browse button to select a file" SetText: txtFileName
                CheckButton: chkWin32Forth ;

: StopTest      ( -- )
                Close: MyWin ;

cr .( Type doTest for example, when finish type StopTest) cr

comment:
Things to note: controls are given names that identify the type of control
 e.g  chkWin32forth   - identifies a checkbox control
      btnOk           - identifies this control as a button
      txtName         - identifies a textbox control

Whatever names are chosen they should be descriptive.

If the form is now modified the demo would still work, assuming of course that
none of the controls used by the demo are deleted.

Controls are referenced by name as oppose to IDs a la dialogs.

comment;
\s


