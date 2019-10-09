(( ForthForm.F  A Free Form Designer for Win32Forth by Ezra Boyce
Written to simplify the design of forms with user design classes of controls.
The generated file can be saved as a forth form file (.frm), pasted into one's
program and modified as needed or be accessed somewhat like Windows dialogs.
))

anew -ForthForm.f

 : sysgen ;
\ : withbgnd ;
\ add the ForthForm folder's to our path list
\ September 20th, 2003 - 9:57 dbu
s" apps\forthform"     "fpath+
s" apps\forthform\res" "fpath+

only forth also definitions

vocabulary forthform
vocabulary testvocab       \ for testing forms to avoid conflicts
forthform also definitions

needs excontrols.f          \ extended controls for Win32Forth
needs ExUtils.f             \ general utilities
needs w_search.f
needs linklist.f            \ very useful utility
needs bitmap.f              \ bitmap loading routines
needs point.f               \ simple point class
needs rect.f                \ class for drawing boxes
needs fcases.f              \ case extensions
needs file.f                \ file functions encapsulated in a class
needs fcases.f              \ extension to case and if
needs joinstr.f             \ join any number of counted strings
needs toolbar.f             \ Windows toolbar class
needs enum.f                \ enumerated constants
needs multiopen.f           \ open multiple forms
needs rebarcontrol.f        \ allow enhanced toolbar
needs HtmlControl.f         \ for viewing the help file
needs ScintillaControl.f    \ editor for FormPad
\ needs FileLister.f          \ directory viewer using treeview
needs folderview.f
needs Win32Help.f
needs Resources.f

\+ withbgnd needs imagewindow.f   \ utility to allow viewing of different image formats

\ control identifiers
1 to enum-value
enum:      TypeLabel        TypeTextBox      TypeGroupBox      TypePushButton
           TypeCheckBox     TypeRadioButton  TypeBitMapButton  TypeIconButton
           TypeMultiLineBox TypeStaticBitmap TypeUpDownControl
           TypeProgressBar  TypeTrackBar     TypeListBox       TypeComboBox
           TypeComboListBox TypeRadioBar     TypeStatusBar     TypeCalendar
           TypeHorizScroll  TypeVertScroll   TypeMultiListBox  TypePictureButton
           TypeGeneric      TypeFileWindow   TypeTabControl    TypeSpinnerControl
           ;

\ class identifiers
0 to enum-value
enum:
    DIALOG-CLASS
    CHILD-CLASS
    MDIDIALOG-CLASS
    TRAY-CLASS ;

\ identifiers for toolbar alignment
0 to enum-value
enum:
     TOP
     LEFT
     BOTTOM
     RIGHT ;

top value align_rebar \ default
0 value RebarHeight
0 value RebarWidth
create rebar$ 0 , 8 allot	\ order of controls in rebar, room for expansion

10 constant gridspacing         \ pixels between grid points

0 value ActiveForm    \ current form
0 value ThisForm
0 value TheMainWindow  \ allow forward referencing
0 value FormList        \ pointer to list of open forms
0 value formcount       \ running total of created forms
0 value ButtonID        \ button to be unchecked
0 value TheControlToolBar
0 value TheMainToolBar
0 value NextControlType    \ next control to be created
GRAY value BackGroundColor   \ default
false value newcontrol?
0 value statuswindow            \ pointer to status window object
0 value inconsole
0 value picturebmp
0 value staticbmp
\ registry values
100 value WindowTop                 \ main window y position
100 value WindowLeft                \ main window x position
600 value WindowWidth               \ main window width
400 value WindowHeight              \ main window height
536 value MonitorLeft               \ monitor window x position
375 value MonitorTop                \ default is same y position
true value FlatToolBar?             \ do we want a flat toolbar ?
false value ButtonText?             \ display button text ?, actually disabled
true value ShowMonitor?             \ display  the window positioning monitor
0 value frmdata-size                \ set to values for checking a form
0 value ctrldata-size               \ before opening it
true value show-notes?		    \ display release notes on startup?
true value SingleControl?	    \ allow only one control to be added at a time?
false value AutoProperty?	    \ automatically display appropriate property dialog?
variable formwindow-link            \ all forthform windows, allow simple closing
         formwindow-link off

WM_USER 256 + constant FF_PASTE     \ message to tell Win32forthIDE to paste source text

ColorObject FormColor             \ background form color
Font ControlFont                  \ default font for text to be written in control

\+ withbgnd FreeImageWindow BkGndImageWindow  \ create instance
File MergeFile
File TheFile

\ adapted from WinEd
20210 constant fform_version#  \ 2.02.10

\ Version numbers: v.ww.rr
\
\ v   Major version
\ ww  Minor version
\ rr  Release
\
\ Odd minor version numbers are possibly unstable beta releases.

: ForthFormTitle$ ( -- addr cnt )
                s" ForthForm " new$ dup>r place
                fform_version# ((version)) r@ +place
                r> count ;

: ExitOnError   ( f -- )
                S" A serious error has occurred in ForthForm!" ?TerminateBox ;

macro ?abort " if abort then"

\ define defer functions

defer doNew
defer doOpen
defer doSave
defer doSaveAs
defer doDelete
defer doCopy
defer doWrite
defer doTest
defer OnActive
defer doExit
defer doPref
defer doAbout
defer doEdit
defer doForm
defer doForth
defer doEditor
defer doTabOrder
defer doFormHelp
defer doUpdate
defer doSaveSession  \ save the current state of the system to a file
defer doLoadsession  \ reload a saved state
defer doCloseAllForms
defer doCloseForm
defer doSaveAll
defer doMoveToBack
defer doMoveToFront
defer UpdatePropertyWindow
defer domerge
defer doGroupAction
defer doCreateToolBar
defer doSplitter
defer doCreateMenu
defer UpdateSystem
defer (OpenForm)
defer doPropertyForm

: link-formwindow { win -- }
                formwindow-link link,    \ link into list
                win , ;

: close-windows  { \ wlink -- } \ close ForthForm windows
                formwindow-link @
                begin   dup
                while   dup cell+ @ to wlink
                        Close: wlink
                        @
                repeat  drop ;

\+ withbgnd BkGndImageWindow link-formwindow  \ link

\ : Start-Win32ForthIDE   ( -- )  \ start  the editor if not already started
\                      editor-present?
\ 			if      s" Win32Forth*IDE" "SetToForeground drop
\ 			else    s" Win32ForthIDE.exe" PrePend<Home>\
\ 				conhndl ExecuteFile
\ 			then  ;
\
\ : ffLoadProject   	( -- )       \ start the project manager if not started
\                      s" Win32for.exe" PrePend<Home>\
\                      temp$ place  s"  LoadProject" temp$ +place temp$
\                      exec-cmd drop ;
\
\ : Start-ProjectManager   ( -- )       \ start the project manager if not started
\                      ?promgr-started ?exit
\                      s" Project.exe" PrePend<Home>\
\                      GetHandle: TheMainWindow ExecuteFile ;

: set-base-path   ( -- )
                PROGREG-SET-BASE-PATH
                s" ForthForm\" PROGREG +place  \ set the base registry string
                ;

: "GetDefaultValue ( addr n -- n1 flag ) \ read a value from registry
        GetSetting dup
        if      number? >r d>s r>
        else    2drop 0 false
        then    ;

: ShowPosition  { x y -- } \ display coordinates in status window
                join$(   s" X= "
			 x >str
			 s"    "
			 s" Y= "
			 y (.)
                )join$ 1+ 1 SetText: statuswindow ;

: ShowSize      { w h -- }  \ display dimensions in status window
                join$(	s" Width= "
			w >str
			s"   "
			s" Height= "
			h (.)
                )join$ 1+ 2 SetText: statuswindow ;

: ClearStatusWindow  ( -- )   \ clear status window duh!
                z" " 0 SetText: statuswindow
                z" " 1 SetText: statuswindow
                z" " 2 SetText: statuswindow
                z" " 3 SetText: statuswindow
                z" " 4 SetText: statuswindow ;

: AdjustWindowSize      { width height winhndl -- }
               [ SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or ] LITERAL
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                winhndl Call SetWindowPos drop ;

: ALignGridXY   ( -- )
                ActiveForm 0= ?exit
                AlignGridXY: ActiveForm ;

: ALignGridX    ( -- )
                ActiveForm 0= ?exit
                AlignGridX: ActiveForm ;

: ALignGridY    ( -- )
                ActiveForm 0= ?exit
                AlignGridY: ActiveForm ;

: AutoSize      ( -- )
                ActiveForm 0= ?exit
                AutoSize: ActiveForm ;

: ArrangeVertical ( -- )
                ActiveForm 0= ?exit
                ArrangeVertical: ActiveForm ;

: ArrangeHorizontal ( -- )
                ActiveForm 0= ?exit
                ArrangeHorizontal: ActiveForm ;

:NoName         ( -- )
                ActiveForm 0= ?exit
                DeleteControl: ActiveForm ; is doDelete

:NoName         ( -- )
                ActiveForm 0= ?exit
                MoveToBack: ActiveForm ;  is doMoveToBack

:NoName         ( -- )
                ActiveForm 0= ?exit
                MoveToFront: ActiveForm ; is doMoveToFront

: ChangeControl ( -- )  \ change current control to new selection
                newcontrol? 0= ?exit    \ must select from toolbar
                ActiveForm  0= ?exit    \ for obvious reasons
                ActiveControl: Activeform 0= ?exit
                ChangeControl: ActiveForm ;

: ChangeControlFont  ( -- )    \ change the font for a control
                ActiveForm 0= ?exit
                ActiveControl: ActiveForm ?dup
                if    GetUserFont: [ ]
                      IsModified: ActiveForm
                then  ;

: ResetControlFont   ( -- )       \ reset control to the default
                ActiveForm 0= ?exit
                ActiveControl: ActiveForm ?dup
                if    DefaultFont: [ ]
                      IsModified: ActiveForm
                then  ;

: #Forms        ( -- n )    \ return number of open forms
                FormList
                if      Data@: FormList
                        if      #Links: FormList
                        else    0
                        then
                else    0
                then    ;

: ?FormNumber   { frmobject -- n } \ given object address return position in list
                frmobject 0= FormList 0= or
                if      0 exit
                then    >FirstLink: FormList
                #Forms 1+ 1
                ?do     Data@: FormList frmobject =
                        if     i unloop
                               exit
                        then   >NextLink: FormList
                loop    0 ;

FileOpenDialog OpenSessionDlg "Load Session File" "Session Files|*.ses|"
FileSaveDialog SaveSessionDlg "Save Session File" "Session Files|*.ses|"
MultiFileOpenDialog OpenFormDlg "Open Form File" "Form Files|*.ff|All Files|*.*|"
FileSaveDialog SaveFormDlg "Save Form File" "Form Files|*.ff|"
FileOpenDialog GetBitmapDlg "Get Bitmap" "Bitmap Files|*.bmp;*.dib|"

needs forms.frm             \ all ForthForm dialogs
needs formpad.f             \ mini code editor
needs formhelp.f            \ html help for using ForthForm
needs formtoolbar.f         \ customizable toolbar definitions
needs formmenu.f            \ deliver coffee... yeah right!
needs formcontrols.f        \ subclassed control object
needs groupaction.f         \ positioning of controls
needs formobject.f          \ load form class
needs about.f               \ about dialog
needs taborder.f            \ change tab order form
needs formproperty.f        \ edit of form properties
needs CreateToolBar.f       \ toolbar generator ...but you knew that right?
needs SplitterWindow.f      \ this is also an easy guess!
needs CreateMenu.f          \ now what could this file be for?
needs CreatePropertyForm.f  \ generate property sheet like template
needs formmonitor.f         \ monitor window for positioning forms

Form DummyForm		    \ dummy
ControlObject DummyControl  \ objects

: UpdateFormPicker  ( -- )  \ update combolist control
                GetHandle: FormPicker 0= ?exit	\ not opened
                Clear: FormPicker		\ reset it
                #Forms ?dup			\ if we have any
                if      1+ 1
                        ?do     i >Link#: FormList
                                Data@: FormList FormName: [ ]
                                count asciiz AddStringTo: FormPicker	\ add string
                        loop    ActiveForm ?dup
                        if      ?FormNumber 1- 0max SetSelection: FormPicker	\ show active form
                        then
                then    ;

: updatewin     ( -- )      \ update everything
                UpdateFormPicker
                UpdateProperties++
                ShowMonitor?
                if          Update: Monitor
                then    ; ' updatewin is doupdate

\  ******************** Specialised words for ForthForm.cfg ************** */
#IFDEF withbgnd
create BkGndImage$ 0 , max-path allot-to         \ for user supplied BackGroundImage

\ put this command in the ForthForm.cfg file to change the default BackGroundImage
: SetBackGroundImage  ( <file> -- )   \ get file name from input stream
\in-system-ok   also forthform
                /parse-word count ?dup
                if      BkGndImage$ place
                else    drop
\in-system-ok   then    previous ;
' SetBackGroundImage alias SetWallpaper  \ for compatibility
#ENDIF
\  ************************************************************************* */

: SaveRebar    ( -- )
		align_rebar 1 and \ left or right
		if 	width: therebar
		else 	0
		then 	to rebarwidth
		align_rebar 1 and 0= \ top or bottom
		if 	height: therebar
		else 	0
		then 	to rebarheight ;

: SaveDefaults  ( -- ) \ save default information in registry
                decimal

                set-base-path
		SaveRebar

                OriginX: TheMainWindow s>d (d.) s" WindowLeft"          SetSetting
                OriginY: TheMainWindow s>d (d.) s" WindowTop"           SetSetting
                GetHandle: TheMainWindow Call IsIconic 0=   \ if window is not minimised
                if      Width: TheMainWindow s>d (d.) s" WindowWidth"   SetSetting
                       Height: TheMainWindow s>d (d.) s" WindowHeight"  SetSetting
                then    ShowMonitor?
                if      Monitor.OriginX        s>d (d.) s" MonitorLeft" SetSetting
                        Monitor.OriginY        s>d (d.) s" MonitorTop"  SetSetting
                then
#IFDEF withbgnd ImageHandle: BKGndImageWindow
		if 	ImageFileName: BkGndImageWindow
		else	pad 0
		then	s" BackGroundImage" SetSetting
#THEN
                FlatToolbar?           s>d (d.) s" ToolbarStyle"        SetSetting
                ShowMonitor?           s>d (d.) s" ShowMonitor"         SetSetting
                SingleControl?         s>d (d.) s" SingleClick"         SetSetting
                AutoProperty?          s>d (d.) s" AutoProperty"        SetSetting
                align_rebar            s>d (d.) s" AlignRebar"          SetSetting
		RebarHeight	       s>d (d.) s" RebarHeight"         SetSetting
		RebarWidth             s>d (d.) s" RebarWidth"          SetSetting
		GetOrder: TheRebar		s" RebarOrder"          SetSetting
                show-notes?            s>d (d.) s" ShowNotes"           SetSetting
                ;

: LoadDefaults  ( -- )  \ load values from registry
                decimal
                s" WindowLeft"     "GetDefaultValue if to WindowLeft     else drop then
                s" WindowTop"      "GetDefaultValue if to WindowTop      else drop then
                s" WindowWidth"    "GetDefaultValue if to WindowWidth    else drop then
                s" WindowHeight"   "GetDefaultValue if to WindowHeight   else drop then
                s" MonitorLeft"    "GetDefaultValue if to MonitorLeft    else drop then
                s" MonitorTop"     "GetDefaultValue if to MonitorTop     else drop then
\+ withbgnd     s" BackGroundImage" GetSetting ?dup if BkGndImage$ place else drop then
                s" ToolbarStyle"   "GetDefaultValue if to FlatToolBar?   else drop then
                s" ShowMonitor"    "GetDefaultValue if to ShowMonitor?   else drop then
                s" SingleClick"    "GetDefaultValue if to SingleControl? else drop then
                s" AutoProperty"   "GetDefaultValue if to AutoProperty?  else drop then
                s" AlignRebar"     "GetDefaultValue if to align_rebar    else drop then
		s" RebarHeight"    "GetDefaultValue if to RebarHeight    else drop then
		s" RebarWidth"     "GetDefaultValue if to RebarWidth     else drop then
		s" RebarOrder"     GetSetting ?dup  if rebar$ place      else drop then
                s" ShowNotes"      "GetDefaultValue if to show-notes?    else drop then
                ;

: check-file      { fname fcnt \ fsize -- f }      \ check integrity of file before opening
                  fname fcnt SetName: TheFile   \
                  Open: TheFile ?dup ?exit
                  FileSize: TheFile drop to fsize  \ larger than 4 gig .ff file?
                  Close: TheFile
                  fsize GetData: DummyForm nip  < ?dup ?exit   \ must have at least a form header
                  fsize GetData: DummyForm nip  - GetData: DummyControl nip mod 0<>  \ must be evenly divisible
                  ;

:NoName         ( -- )      \ _NewForm
                AddNewForm
                Init: ThisForm
                s" untitled.ff" SetFileName: ThisForm
                join$(  s" Form"
			formcount (.)
		)join$ count 2dup  SetName: ThisForm
                               IsFormTitle: ThisForm
                Start: ThisForm
                Display: ThisForm
                doupdate ;  is doNew

:NoName         { fname fcnt -- } \ open form given its name
                fname fcnt check-file ?dup
                if    join$(    fname fcnt
				s"  is an invalid ForthForm file!"
		      )join$  count ?MessageBox
                      exit
                then  AddNewForm
                Start: ThisForm
                fname fcnt SetFileName: ThisForm
                Load: ThisForm
                Display: ThisForm
                doupdate
                UpdateSystem ; is (OpenForm)

:NoName         ( -- ) \ open one or more form files
                GetHandle: TheMainWindow Start: OpenFormDlg c@
                if      #SelectedFiles: OpenFormDlg 0
                        do      i GetFile: OpenFormDlg (OpenForm)
                        loop
                then    ;    is doOpen

:NoName         ( -- )     \ view/edit form
                ActiveForm 0= ?exit
                GetBuffer: ActiveForm FormName: ActiveForm count ShowSource ; is doEditor

: strip-cmdline ( addr cnt -- addr2 cnt2 )
                [CHAR] " skip [CHAR] ' skip BL skip
                [CHAR] " -TRAILCHARS [CHAR] ' -TRAILCHARS BL -TRAILCHARS ;

: OpenByExtension { addr cnt -- }
                  addr cnt ".ext-only" pad place pad uppercase
                  case	s" .FF"		"of	addr cnt (OpenForm)	endof
			s" .TDF"	"of	addr cnt LoadToolBarFile: frmCreateToolBar
									endof
			s" .MDF"	"of	addr cnt doCreateMenu Load: TheMenu
									endof
			s" .SES"	"of	addr cnt temp$ place
						nostack1 temp$ ['] $fload catch
						s" Session load aborted!" ?MessageBox
									endof
		  endcase ;

: HandleCmdLine ( -- ) \ open the Form given via command line (November 8th, 2003 - 9:52 - dbu)
                CMDLINE ?dup
                if   \ get command line address and length
                     strip-cmdline
                     \ and open the file
                     OpenByExtension
                else drop
                then ;

:NoName         ( -- )  \ just save form, allow name change if untitled
                ActiveForm 0= ?exit
                Save: ActiveForm ;  is doSave

:NoName         ( -- )  \ save under different name
                ActiveForm 0= ?exit
                SaveAs: ActiveForm ;  is doSaveAs

:NoName         ( -- )  \ compile to disk
                ActiveForm
                if      CompileForm: ActiveForm
                then    ;  is doWrite

:NoName  ( -- ) \ test form from image in memory
        ActiveForm 0= ?exit
        Validate: ActiveForm
        s" anew _frm" evaluate
        ChildState: ActiveForm >r      \ we want to see the form if it is a child, so we
        false IsChildState: Activeform \ save the state and change in case it is hidden
        GetBuffer: ActiveForm 2drop
        fload-buffer                        \ load actual form
        GetSuperClass: ActiveForm dup CHILD-CLASS =     \ compiling as a child window?
        if      drop TestChildDialog: ActiveForm fload-buffer
        else    MDIDIALOG-CLASS =               \ or as a MDI dialog?
            if      TestMDIDialog: ActiveForm fload-buffer
            else    s" Start: " new$ dup>r place FormName: ActiveForm count r@ +place   \ no, as a dialog window
                    r> count evaluate
            then
        then    r> IsChildState: ActiveForm ;  is doTest

:NoName         ( -- ) \ save all modified forms
                #Forms ?dup
                if      1+ 1
                        do      i >Link#: FormList
                                Save: [ Data@: FormList]
                        loop
                then    ; is doSaveAll

:NoName   { \ fname err - } \ compile all open forms to a single file
        #forms 2 < ?exit    \ no use merging 1 form
        \ we get the name of the merge file that will contain all forms
        GetFilter: SaveFormDlg new$ dup>r place
        s" Forms|*.frm|All Files|*.*|" SetFilter: SaveFormDlg
        GetHandle: TheMainWindow Start: SaveFormDlg to fname
        r> count SetFilter: SaveFormDlg
        fname c@ 0= ?exit       \ operation was cancelled
        \ add a default .frm extension if none specified
        fname count 2dup pad place ".ext-only" nip 0=
        if  s" .frm" pad +place
        then    pad count SetName: MergeFile
        Create: MergeFile ?exit
        \ now we compile all forms to memory and then write to merge file
        >FirstLink: FormList
        #forms 1+ 1
        do  Data@: FormList GetBuffer: [ ] 2drop
            +crlf +crlf     \ couple blank lines
            TheBuffer Write: MergeFile ?leave
            >NextLink: FormList
        loop    Close: MergeFile ClearName: MergeFile ;  is doMerge

:NoName   ( -- )       \ copy to clipboard
          ActiveForm 0= ?exit
          GetBuffer: ActiveForm copy-clipboard ;  is doCopy

: CloseForm     { TheForm -- }
                SetFocus: TheForm
                Close: TheForm
                TheForm ?FormNumber >Link#: FormList
                TheForm Dispose
                0 Data!: FormList
                DeleteLink: FormList
                #Forms 0=
                if      Blank: Monitor
                        ForthFormTitle$ SetText: TheMainWindow
                        ClearStatusWindow
                        SetFocus: TheMainWindow
                        0 to ActiveForm
                        Close: frmProperties++
                        UpdateSystem
			FormList Dispose 0 to FormList
                else    SetFocus: [ Data@: FormList ]
                        ActiveControl: Activeform
                        if      UpdatePropertyWindow
                        then
                then	UpdateFormPicker
                #Forms 2 <
                if      Close: frmCreatePropertyForm
                then    UpdateSystem
                ; ' CloseForm is doCloseForm

:NoName         ( -- )  \ clean slate
                FormList 0= ?exit
		>FirstLink: FormList
		Begin	      FormList
		While	      Data@: FormList doCloseForm
		Repeat	;  is doCloseAllForms

\    ********************** Main ForthForm Window  *************** */

:Object MainWindow      <Super Window
MultiStatusbar controlstats    \ status window
create bardivisions 136 , 250 , 400 , 460 , -1 ,

\ BackGroundImage can be a bitmap or jpeg file, bitmap taking precedent
\ A file name specified in the configuration file overrides default
\ An image filename saved in the registry overrides all others
\ Search the directory that the program was loaded from
#IFDEF withbgnd
: GetBackGroundImage  ( -- addr cnt f ) \ return BackGroundImage filename, f=0=success
                BkGndImage$ c@    \ if set, check that it exists
                if      BkGndImage$ count 2dup file-status nip exit
                then    prognam>pad s" forthform.bmp" pad +place
                pad count 2dup file-status nip dup
                if      3drop s" jpg" pad count 3 - + swap move  \ just change extension
                        pad count 2dup file-status nip
                then    ;
#ENDIF

:M OriginX:     ( -- originx )
                originx ;M

:M OriginY:     ( -- originy )
                originy ;M

:M StartSize:   ( -- width height )
                WindowWidth WindowHeight
                ;M

:M StartPos:    ( -- x y )
                WindowLeft WindowTop
                ;M

:M MinSize:     ( -- w h )
                520 50 ;M

:M DefaultIcon: ( -- hIcon )  \ return the default icon handle for window
                LoadAppIcon ;M

: rebar_position     { \ h -- x y w h }
		height height: statuswindow - to h
                align_rebar top =
                if        0 0 width height: therebar exit
                then      align_rebar bottom =
                if        0 h height: therebar dup>r - width r> exit
                then      align_rebar left =
                if        0 0 Width: TheRebar h exit
                then      width Width: TheRebar dup>r - 0 r> h
                ;

:M Canvas:      { \ rebarx rebary rebarw rebarh mainw mainh -- x y w h }
                rebar_position
                to rebarh to rebarw to rebary to rebarx
		width height Height: statuswindow - to mainh to mainw
                align_rebar top =
                if        0 rebarh mainw mainh rebarh -  exitm
                then      align_rebar bottom =
                if        0 0 mainw mainh rebarh - exitm
                then      align_rebar left =
                if        rebarw 0 mainw mainh exitm
                then      ( align right ) 0 0 mainw rebarw - mainh
                ;M

:M PositionRebar: ( -- )
                  rebar_position Move: TheRebar
                  ;M

#IFDEF withbgnd
:M ReDrawImage: ( -- )
                Canvas: self Move: BkGndImageWindow ;M
#ENDIF

:M On_Paint:    ( -- )
                0 0 Width Height BackGroundColor FillArea: dc
\+ withbgnd     ReDrawImage: self
                ;M

: InitBitmaps	( -- ) \ create default bitmap handles for bitmap buttons
                PictureBitmap usebitmap   \ create bitmap handle
                GetDc: self dup>r CreateDIBitmap to picturebmp
                Static_Bitmap usebitmap
                r@ CreateDIBitmap to staticbmp
                r> ReleaseDc: self ;

#IFDEF withbgnd
: StartImageWindow	( -- )
                self Start: BkGndImageWindow
                FIT_SIZE SetViewMode: BkGndImageWindow
                GetBackGroundImage
                if      2drop     \ file wasn't found
                else    SetImageFile: BkGndImageWindow
                then	;
#ENDIF

: StartStatusWIndow	( -- )
                self Start: controlstats    \ set up status window
                Handle: ControlFont SetFont: controlstats
                Addr: controlstats to statuswindow
                bardivisions 5 SetParts: controlstats ;

:M On_Init:     ( -- )
                On_Init: super

                MainMenuBar SetMenubar: self

                ControlToolBar to TheControlToolBar
                MainToolBar to TheMainToolBar

                s" MS Sans Serif" SetFaceName: ControlFont
                8 Width: ControlFont
                Create: ControlFont

                self to TheMainWindow

                COLOR_BTNFACE Call GetSysColor NewColor: FormColor

                self Start: TheRebar

                ShowMonitor?
                if      Start: Monitor
                then

		StartStatusWIndow
\+ withbgnd	StartImageWindow
		InitBitmaps
                UpdateSystem

                InitScintillaControl    \ for the editor
                ;M

:M On_Size:     ( -- )
                AutoSize: ControlToolBar
                AutoSize: MainToolBar
                PositionRebar: self
\+ withbgnd     ReDrawImage: self
                Redraw: statuswindow
                SizeHelpWindow
		;M

: DefaultRebar  ( -- )
		align_rebar 1 and
		if   	RebarWidth
			if 	RebarWidth Height: TheRebar GetHandle: TheRebar AdjustWindowSize
			then	exit
		then	RebarHeight
		if      Width: TheRebar RebarHeight GetHandle: TheRebar AdjustWindowSize
		then	;

:m RestoreRebar:	( -- )
			DefaultRebar
			On_Size: self ;m

\    ***************** Toolbar handlers *********************** */

:M WM_NOTIFY    { h m w l \ hwndfrom -- f }
                l @ to hwndfrom
                l 2 cells+ @  RBN_AUTOSIZE =   \ has TheRebar size changed?
                if
\+ withbgnd             RedrawImage: self
                        SizeHelpWindow
                then
                hwndfrom GetHandle: MainToolBar =
                hwndfrom ToolTipHandle: MainToolBar =  or
                if   w l Handle_Notify: MainToolBar
                else hwndfrom GetHandle: ControlToolBar =
                     hwndfrom ToolTipHandle: ControlToolBar = or
                     if    w l Handle_Notify: ControlToolBar
                     else  false
                     then
                then
                ;M

:M WndClassStyle: ( -- style )   CS_DBLCLKS ;M

: setnext       ( nexttype -- )
                to NextControlType true to newcontrol? ;

: ?TypeTextBox  ( --  type )
                ?control       \ control key pressed while buttonclicked?
                if      TypeMultiLineBox
                else    TypeTextBox
                then    ;

: ?TypeLabel    ( -- type )
                ?control        \ control key pressed while buttonclicked?
                if      TypeStaticBitmap
                else    TypeLabel
                then    ;

: ?TypeComboBox ( -- type )
                ?control         \ control key pressed while buttonclicked?
                if      TypeComboListBox
                else    TypeComboBox
                then    ;

: ?TypeListBox  ( -- type )
                ?control          \ control key pressed while buttonclicked?
                if      TypeMultiListBox
                else    TypeListBox
                then    ;

:M On_Command:  { hCtrl ncode id -- f }
                id dup to buttonid
                case
                        GetId: FormPicker of ncode CBN_SELCHANGE  =
                                               if       GetCurrent: FormPicker
                                                        1+ >Link#: FormList
                                                        Data@: FormList SetFocus: [ ]
                                               then                      endof
                        IDC_BITMAP         of   TypeBitMapButton setnext endof
                        IDC_LABEL          of   ?TypeLabel       setnext endof
                        IDC_TEXTBOX        of   ?TypeTextBox     setnext endof
                        IDC_GROUPBOX       of   TypeGroupBox     setnext endof
                        IDC_PUSHBUTTON     of   TypePushButton   setnext endof
                        IDC_CHECKBOX       of   TypeCheckBox     setnext endof
                        IDC_RADIOBUTTON    of   TypeRadioButton  setnext endof
                        IDC_COMBOBOX       of   ?TypeComboBox    setnext endof
                        IDC_LISTBOX        of   ?TypeListBox     setnext endof
                        IDC_HorizScroll    of   TypeHorizScroll  setnext endof
                        IDC_VertScroll     of   TypeVertScroll   setnext endof
                        IDC_Generic        of   TypeGeneric      setnext endof
                        IDC_FILEWINDOW     of   TypeFileWindow   setnext endof
                        IDC_TABCONTROL     of   TypeTabControl   setnext endof
                        IDC_NEW            of   doNew                    endof
                        IDC_OPEN           of   doOpen                   endof
                        IDC_SAVE           of   doSave                   endof
                        IDC_HELP           of   doFormHelp               endof
                        IDC_DELETE         of   doDelete                 endof
                        IDC_COPY           of   doCopy                   endof
                        IDC_COMPILE        of   doWrite                  endof
                        IDC_TEST           of   doTest                   endof
                        IDC_BACK           of   doMoveToBack             endof
                        IDC_FRONT          of   doMoveToFront            endof
                        IDC_CONSOLE        of   doForth                  endof
                        IDC_EDITOR         of   doEditor                 endof
                        IDC_TAB            of   doTabOrder               endof
                        IDC_SAVEALL        of   doSaveAll                endof
                        IDC_LOADSESSION    of   doLoadSession            endof
                        IDC_SAVESESSION    of   doSaveSession            endof
                        0 to NextControlType false to newcontrol?
                endcase ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
                ?dup 0=
                if      LOWORD
                        CurrentMenu
                        if      dup DoMenu: CurrentMenu
                        then
                        CurrentPopup
                        if      dup DoMenu: CurrentPopup
                        then    drop
                else    over HIWORD ( notification code ) rot LOWORD ( ID )
                        On_Command: [ self ]
                then
                0 ;M

:M Close:       ( -- )
                SaveDefaults

                doCloseAllForms
                close-windows

                Close: super
                ;M

:M WindowTitle: ( -- title )
                ForthFormTitle$ asciiz ;M

:M On_SetFocus: ( -- )
                ClearStatusWindow
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_CLIPCHILDREN or
                ;M

:M On_Done:     ( -- )
                MenuHandle: CurrentMenu ?dup
                if      Call DestroyMenu ?win-error  \ discard the menubar
                        ZeroMenu: CurrentMenu
                then    Delete: ControlFont
                picturebmp ?dup
                if      Call DeleteObject drop
                        0 to picturebmp
                then    staticbmp ?dup
                if      Call DeleteObject drop
                        0 to staticbmp
                then    ExitScintillaControl
\+ sysgen       0 Call PostQuitMessage
\ \+ sysgen       false fform-started                 \ set as no longer running

                On_Done: super
                0 ;M

:M WindowHasMenu:       ( -- flag )
                true ;M

:M ClassInit:   ( -- )
                ClassInit: super
                ;M

:M WM_CLOSE     ( h m w l -- res )
                WM_CLOSE WM: Super
\+ sysgen       bye
                0 ;M

:M WM_INITMENU  ( h m w l -- res )
                UpdateSystem
                0 ;M

:M WM_SYSCOLORCHANGE    ( h m w l -- res )
                RefreshForms
                DefaultWindowProc   \ update any other controls
                ;M

\ : answer_message   ( -- ) \ if file specified open it
\                 SetForegroundWindow: self
\                 param-buffer count ?dup
\                 if      OpenByExtension
\                 else    drop
\                 then    ;
\
\ : build-form-list   { \ tmp cnt -- }
\                 0 param-buffer !        \ default at no forms
\                 #Forms 0= ?exit
\                 0 to cnt                \ reset
\                 param-buffer cell+ to tmp
\                 #Forms 1+ 1
\                 ?do     i >Link#: FormList
\                         TextFile: [ Data@: FormList ] dup 1+ cnt +
\                         param-max > not                 \ don't exceed buffer
\                         if      tuck tmp place 1+ +to cnt
\                                 1 param-buffer +!       \ increment form count
\                                 tmp count + to tmp
\                         else    2drop
\                         then
\                 loop    ;
\
\ : send-forms    ( -- )
\                 build-form-list 0 FORMS_SENT win32forth-message ;
\
\ :M Win32Forth:  ( h m w l -- )
\                 over case
\                         FF_ACTIVATE      of   answer_message   endof
\                         WANT_FORMS       of   send-forms       endof
\                         Win32Forth: super
\                       endcase
\                 0 ;M

:M PushKey:     ( c -- )
                case
                        'N' +k_control  of      doNew           endof
                        'O' +k_control  of      doOpen          endof
                         K_F9           of   SetFocus: Monitor  endof
\                         K_F12          of   ffLoadProject      endof
                         K_F1           of      doFormHelp      endof
                endcase ;M

;Object

create toolbar-reg$ MAXSTRING allot

: init-forthform ( -- ) \ initialization stuff for Forthform
                decimal
\in-system-ok   only forth also forthform also testvocab also definitions
                current-dir$ count 2dup SetDir: OpenFormDlg
                                   2dup SetDir: SaveFormDlg
                                   2dup SetDir: OpenSessionDlg
                                   2dup SetDir: SaveSessionDlg
                                   SetDir: GetBitmapDlg
                prognam>pad s" ForthForm.cfg" pad +place
                pad count file-status nip 0=         \ does it exist
                if pad ['] $fload catch drop    \ if so load it
                then

                set-base-path
                \ Set-up registry key for toolbar customization data...
                join$(  s" SOFTWARE\"
			PROGREG count
			s" Settings"
		)join$  1+ dup>r      \ Registry sub-key
                z" ControlToolBar" SetRegistryKey: ControlToolBar
                r> z" MainToolBar" SetRegistryKey: MainToolBar
                ;

\ : check-if-running ( -- )
\                 ed-ptr
\                 if      ?fform-started
\                         if      CmdLine ?dup
\                                 if      strip-cmdline
\                                 else    drop pad 0
\                                 then    param-buffer place
\                                 0 FF_ACTIVATE win32forth-message
\                                 bye
\                         else    true fform-started    \ set as running
\                         then
\                 then    ;

: show-release-notes        ( -- ) \ show one time only
                    show-notes?
                    if         s" doc\forthform\FF-Release Notes.htm" help$ place
                               (FormHelp)
                               \ false to show-notes?
                    then       ;

: FForm         ( -- )
\ \+ sysgen       check-if-running
                init-forthform
                LoadDefaults            \ read default settings in registry
                Start: Mainwindow
		RestoreRebar: MainWindow
\+ sysgen       HandleCmdLine  \ November 8th, 2003 - 9:52 dbu
                show-release-notes
\+ sysgen       z" ForthForm Console" conhndl Call SetWindowText drop
                ;

also forth definitions

: EndForthForm ( -- )
	doCloseAllForms  ( false fform-started  ) k_bye	;

: ff            ( -- )    \ main executable word
                ['] EndForthForm is bye
                ['] FForm catch ExitOnError ;

: run-ff        ( -- )
                ff
                messageloop ;

previous definitions

#IFNDEF sysgen

POPUPBAR ForthForm-Popup-bar
    POPUP " "
        MENUITEM        "&Copy Highlighted Text \tCtrl+C"  copy-console ;
        MENUITEM        "&Paste to Keyboard     \tCtrl+V"  paste-load ;
        MENUSEPARATOR
        MENUITEM        "&Mark all Text         \tCtrl+A"  mark-all ;
        MENUSEPARATOR
        MENUITEM        "&Form Designer"         ff ;
        MENUITEM        "Win32 API Help" help-index ;
        MENUSEPARATOR
        MENUCONSOLE     "Exit"                  bye ;
ENDBAR

also hidden
ForthForm-Popup-bar Set-console-popup
previous
#ENDIF

false to sys-warning?
0 value con
: ForthConsole  ( -- )
                inconsole dup 0= to inconsole
                if      hide-console
                        SetFocus: MainWindow
                else    con
                        if      show-console
                        else    normal-console  \ first time only
                                true to con
                                show-cursor
                        then    foreground-console
                then    ;

: DesignWindow  ( -- )
                inconsole dup 0= to inconsole
                if      SetFocus: MainWindow
                else    foreground-console
                then    ;

true to sys-warning?

#IFDEF sysgen
' ForthConsole is doForth
#ELSE
' DesignWindow is DoForth
#ENDIF

\  ********************** ForthForm Preferences **************** */
\ preferences.frm     \ preferences dialog

: ApplyPreferences ( -- )
                IsButtonChecked?: chkFlatToolBar to FlatToolBar?
                IsButtonChecked?: chkShowMonitor  to ShowMonitor?
                IsButtonChecked?: chkShowReleaseNotes to show-notes?
                IsButtonChecked?: chkSingleControl to SingleControl?
                IsButtonChecked?: chkAutoProperty to AutoProperty?
                IsButtonChecked?: radAlignTop    if top    then
                IsButtonChecked?: radAlignBottom if bottom then
                IsButtonChecked?: radAlignLeft   if left   then
                IsButtonChecked?: radAlignRight  if right  then
		to align_rebar
		rebar$ off	\ start fresh
                Close: TheReBar
                TheMainWindow Start: TheRebar
                PositionRebar: TheMainWindow
\+ withbgnd     ReDrawImage: TheMainWindow
                ?ShowMonitor
                UpdateSystem
                ;

: pref-func     { id obj -- }  ( h m w l id obj -- h m w l )
                id
                case    IDOK            of      ApplyPreferences Close: obj   endof
                        IDCANCEL        of      Close: obj                    endof
                endcase ;

:NoName         ( -- )
                ['] pref-func SetCommand: frmPreferences
                GetHandle: TheMainWindow SetParentWindow: frmPreferences
                IDOK SetID: btnOk
                IDCANCEL SetID: btnCancel
                Start: frmPreferences
                Disable: chkButtonText
                FlatToolbar?  Check: chkFlatToolBar
                ShowMonitor?  Check: chkShowMonitor
                show-notes?   Check: chkSHowReleaseNotes
                SingleControl?  Check: chkSingleControl
                AutoProperty? Check: chkAutoProperty
                align_rebar
                case
                    top       of     CheckButton: radAlignTop          endof
                    bottom    of     CheckButton: radAlignBottom       endof
                    left      of     CheckButton: radAlignLeft         endof
                    right     of     CheckButton: radAlignRight        endof
                endcase  ; is doPref
\  ************************************************************************* */

:NoName       ( -- )  \ shutdown
                Close: MainWindow
\+ sysgen       bye
                ; is doExit

\ Session file loading definitions
\ A session file is a standard text file defining the current state of the system
\ To add any new status information simply define words for reading and writing it
#IFDEF withbgnd
: BackGroundImage=    ( <name> -- )   \ get BackGroundImage filename from input stream
                0 word dup c@
                if      count SetImageFile: BkGndImageWindow
                else    drop
                then    ;  ' BackGroundImage= alias WallPaper=
#ENDIF

: Form=         ( <name> -- )   \ get form filename from input stream
                0 word dup c@
                if      count (OpenForm)    \ if we have a form open it
                else    drop
                then    ;

: ?addext       { fname -- fname }
                fname c@
                if      fname count ".ext-only" nip 0=
                        if      s" .ses" fname +place
                        then
                then    fname ;
handle sfile

:NoName   	( -- )
                GetHandle: TheMainWindow Start: OpenSessionDlg dup c@
                if      nostack1 ['] $fload catch
                        s" Session load aborted!" ?MessageBox
                else    drop
                then    ; is doLoadsession

: ?write-error  ( f -- ) \ if flag is true display message and close file
                if      true s" Error writing session file!" ?MessageBox
                        sfile close-file drop
                then    ;

#IFDEF withbgnd
: write-BkGndImage ( -- f ) \ if we have an image file BackGroundImage write it, f=true=error
                  ImageFilename: BkGndImageWindow ?dup
                  if      s" BackGroundImage= " sfile write-file >r
                          sfile write-line r> or dup ?write-error
                  else  drop false    \ no error
                  then  ;
#ENDIF

: write-formfiles { \ err -- f } \ write any forms opened, f=true=error,
                  0 to err
                  #Forms ?dup
                  if    >FirstLink: FormList
                        1+ 1
                        do      s" Form= " sfile write-file >r
                                Data@: FormList GetFileName: [ ]
                                sfile write-line r> or dup to err ?leave
                                >NextLink: FormList
                        loop
                  then  err dup ?write-error ;

:NoName   ( -- )  \ save current state of system
                GetHandle: TheMainWindow Start: SaveSessionDlg ?addext count ?dup
                if      r/w create-file swap to sfile dup ?write-error ?exit     \ create
                        write-formfiles ?exit       \ do this first so that if we try loading a session
\+ withbgnd             write-BkGndImage ?exit      \ with an invalid background image, the forms will still load
                        sfile close-file drop
                else    drop
                then    ;   is doSaveSession

only forth also definitions

#IFDEF sysgen           \ if we are turnkeying
        warning off     \ we know we are redefining
        mark empty      \ protect our dictionary
        warning on      \ as we were
#ENDIF

\ According to the Windows API if the extension is not specified the following
\ will fail. Strangely enough it works in Win32Forth...but not always.

\+ sysgen       s" %DIRWin32ForthIDE.exe %FILENAME %LINE" editor$ place
\+ sysgen       s" %DIRWin32ForthIDE.exe /B %FILENAME %LINE" browse$ place
\+ sysgen &forthdir count &appdir place \ create ForthForm.exe in the Win32Forth directory
\+ sysgen consolehiddenboot
\+ sysgen ' run-ff save ForthForm.exe

forthform also
\ add the Application Icon to the resource of the exe-file if possible
\+ sysgen s" src\res\ForthForm.ico" s" ForthForm.exe" Prepend<home>\ AddAppIcon
\+ sysgen previous

\+ sysgen 1 pause-seconds bye
\- sysgen  ff

\s
