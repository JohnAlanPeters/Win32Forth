\ VIEW.FRM
\- textbox needs excontrols.f

:Object ViewForm                <Super DialogWindow

Font WinFont
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

GroupBox Group1
GroupBox Group2
GroupBox Group3
CheckBox lbl_Index
CheckBox lbl_File_size
CheckBox lbl_#Random
CheckBox lbl_#Played
CheckBox lbl_Drivetype
CheckBox lbl_Label
CheckBox R_Filename
CheckBox R_Record
PushButton Button1
PushButton Button2
RadioButton s_filesize
RadioButton s_#Random
RadioButton s_Random_popular
RadioButton s_Random_impopular
RadioButton s_#played
RadioButton s_DriveType
RadioButton s_label
RadioButton s_Filename
RadioButton s_Artist_Title
Label lbl_Random_popular
Label lbl_Random_impopular

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                parent
                ;M

:M SetParent:  ( hwndparent -- ) \ set owner window
                to parent
                ;M

:M WindowTitle: ( -- ztitle )
                z" View"
                ;M

:M StartSize:   ( -- width height )
                213 351
                ;M

:M StartPos:    ( -- x y )
                CenterWindow: Self
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: Group1
                20 10 179 301 Move: Group1
                Handle: Winfont SetFont: Group1
                s" Sort/Group" SetText: Group1

                self Start: Group2
                50 30 135 187 Move: Group2
                Handle: Winfont SetFont: Group2
                s" Optional" SetText: Group2

                self Start: Group3
                50 230 134 65 Move: Group3
                Handle: Winfont SetFont: Group3
                s" Name" SetText: Group3

                self Start: lbl_Index
                60 50 75 16 Move: lbl_Index
                Handle: Winfont SetFont: lbl_Index
                s" Index" SetText: lbl_Index

                self Start: lbl_File_size
                60 70 94 16 Move: lbl_File_size
                Handle: Winfont SetFont: lbl_File_size
                s" File size (Kb)" SetText: lbl_File_size

                self Start: lbl_#Random
                60 90 94 16 Move: lbl_#Random
                Handle: Winfont SetFont: lbl_#Random
                s" Random" SetText: lbl_#Random

                self Start: lbl_#Played
                60 150 94 16 Move: lbl_#Played
                Handle: Winfont SetFont: lbl_#Played
                s" #Played" SetText: lbl_#Played

                self Start: lbl_Drivetype
                60 170 77 16 Move: lbl_Drivetype
                Handle: Winfont SetFont: lbl_Drivetype
                s" Drivetype" SetText: lbl_Drivetype

                self Start: lbl_Label
                60 190 77 16 Move: lbl_Label
                Handle: Winfont SetFont: lbl_Label
                s" Label" SetText: lbl_Label

                self Start: R_Filename
                60 250 77 16 Move: R_Filename
                Handle: Winfont SetFont: R_Filename
                s" Filename" SetText: R_Filename

                self Start: R_Record
                60 270 104 16 Move: R_Record
                Handle: Winfont SetFont: R_Record
                s" Record" SetText: R_Record

                IDOK SetID: Button1
                self Start: Button1
                50 320 50 20 Move: Button1
                Handle: Winfont SetFont: Button1
                s" Ok" SetText: Button1

                IDcancel SetID: Button2
                self Start: Button2
                120 320 50 20 Move: Button2
                Handle: Winfont SetFont: Button2
                s" Cancel" SetText: Button2

                self Start: s_filesize
                30 70 18 18 Move: s_filesize
                Handle: Winfont SetFont: s_filesize
                s" " SetText: s_filesize

                self Start: s_#Random
                30 90 18 18 Move: s_#Random
                Handle: Winfont SetFont: s_#Random
                s" " SetText: s_#Random

                self Start: s_Random_popular
                30 110 18 18 Move: s_Random_popular
                Handle: Winfont SetFont: s_Random_popular
                s" " SetText: s_Random_popular

                self Start: s_Random_impopular
                30 130 18 18 Move: s_Random_impopular
                Handle: Winfont SetFont: s_Random_impopular
                s" " SetText: s_Random_impopular

                self Start: s_#played
                30 150 18 18 Move: s_#played
                Handle: Winfont SetFont: s_#played
                s" " SetText: s_#played

                self Start: s_DriveType
                30 170 18 18 Move: s_DriveType
                Handle: Winfont SetFont: s_DriveType
                s" " SetText: s_DriveType

                self Start: s_label
                30 190 19 22 Move: s_label
                Handle: Winfont SetFont: s_label
                s" " SetText: s_label

                self Start: s_Filename
                30 250 18 18 Move: s_Filename
                Handle: Winfont SetFont: s_Filename
                s" " SetText: s_Filename

                self Start: s_Artist_Title
                30 270 18 18 Move: s_Artist_Title
                Handle: Winfont SetFont: s_Artist_Title
                s" " SetText: s_Artist_Title

                self Start: lbl_Random_popular
                60 110 115 16 Move: lbl_Random_popular
                Handle: Winfont SetFont: lbl_Random_popular
                s" Random popular" SetText: lbl_Random_popular

                self Start: lbl_Random_impopular
                60 130 115 16 Move: lbl_Random_impopular
                Handle: Winfont SetFont: lbl_Random_impopular
                s" Random impopular" SetText: lbl_Random_impopular


        vadr-config dup s_Drivetype-        c@ Check: s_DriveType
                    dup s_Label-            c@ Check: s_Label
                    dup s_filesize-         c@ Check: s_filesize
                    dup s_#Random-          c@ Check: s_#Random
                    dup s_Random_popular-   c@ Check: s_Random_popular
                    dup s_Random_impopular- c@ Check: s_Random_impopular
                    dup s_#Played-          c@ Check: s_#Played
                    dup s_Filename-         c@ Check: s_Filename
                    dup s_Artist_Title-     c@ Check: s_Artist_Title
                    dup l_Index-            c@ Check: lbl_Index
                    dup l_Drivetype-        c@ Check: lbl_DriveType
                    dup l_Label-            c@ Check: lbl_Label
                    dup l_File_size-        c@ Check: lbl_File_size
                    dup l_#Random-          c@ Check: lbl_#Random
                    dup l_#Played-          c@ Check: lbl_#Played
                        l_Filename-         c@
                               if   CheckButton: R_Filename
                               else CheckButton: R_Record
                               then
                ;M

: SaveSettingsForm  ( - )
   vadr-config
   IsButtonChecked?: s_Drivetype        over s_DriveType-    c!
   IsButtonChecked?: s_Label            over s_Label-        c!
   IsButtonChecked?: s_filesize         over s_filesize-     c!
   IsButtonChecked?: s_#Random          over s_#Random-      c!
   IsButtonChecked?: s_Random_popular   over s_Random_popular-   c!
   IsButtonChecked?: s_Random_impopular over s_Random_impopular- c!
   IsButtonChecked?: s_#Played          over s_#Played-      c!
   IsButtonChecked?: s_Filename         over s_Filename-     c!
   IsButtonChecked?: s_Artist_Title     over s_Artist_Title- c!
   IsButtonChecked?: lbl_Index          over l_Index-        c!
   IsButtonChecked?: lbl_Drivetype      over l_DriveType-    c!
   IsButtonChecked?: lbl_Label          over l_Label-        c!
   IsButtonChecked?: lbl_File_size      over l_File_size-    c!
   IsButtonChecked?: lbl_#Random        over l_#Random-      c!
   IsButtonChecked?: lbl_#Played        over l_#Played-      c!
   IsButtonChecked?: R_Filename         over l_Filename-     c!
   IsButtonChecked?: R_Record           swap l_Record-       c!
 ;

: HandleButtons  ( Action/Button - )
            case
                IDOK     of SaveSettingsForm close: Self SortCatalog  endof
                IDcancel of close: Self                  endof
            endcase
 ;

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute drop HandleButtons
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object

: StartViewForm Start: ViewForm ;

