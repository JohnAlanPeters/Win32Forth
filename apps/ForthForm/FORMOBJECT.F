\ FormObject.f

: RefreshForms  ( -- )  \ refresh all forms for a change in color settings
\ forms will be automatically updated but still available from any form popup menu
                #Forms 0= ?exit         \ no forms open
                COLOR_BTNFACE Call GetSysColor NewColor: FormColor      \ get new system color
                Link#: FormList >r                                      \ save current link
                >FirstLink: FormList                                    \ start from the beginning
                #Forms 0                                                \ for each open form
                ?do     Data@: FormList dup to ThisForm
                        if      Paint: ThisForm                         \ repaint
                        then    >NextLink: FormList                     \ next form
                loop    r> >Link#: FormList ;

\ Popup menus for forms
PopUpBar FormPopup
PopUp ""
         MenuItem "Properties"            doform ;
         MenuSeparator
         MenuItem "Test"          dotest ;
         MenuItem "View/Edit Source"      doEditor ;
         MenuSeparator
         MenuItem "Group Action"          doGroupAction ;
         MenuSeparator
         MenuItem "Copy to Clipboard"     docopy ;
         MenuItem "Save (.ff)"        doSave ;
         MenuItem "Compile (.frm)"    doWrite ;
         :MenuItem mnu_lock "View Only"  Lock: ActiveForm ;
         MenuSeparator
         MenuItem "Refresh"               RefreshForms ;
         MenuSeparator
         MenuItem "Close"                 ActiveForm doCloseForm ;
Endbar

PopupBar ChildPopup

Popup ""
         MenuItem "Properties"        doedit ;
         SubMenu "Align"
                MenuItem "to grid point"  AlignGridXY ;
                MenuItem "to grid's vertical plane" AlignGridY ;
                MenuItem "to grid's horizontal plane" AlignGridX ;
         EndSubMenu
         MenuItem "Size sequential controls" AutoSize  ;
         MenuItem "Arrange sequential controls vertically" ArrangeVertical ;
         MenuItem "Arrange sequential controls horizontally" ArrangeHorizontal ;
         MenuSeparator
         MenuItem "Delete"      doDelete ;
         MenuItem "Change type"          ChangeControl ;
         MenuSeparator
         :MenuItem mnu_font "Change Font"  ChangeControlFont ;
         :MenuItem mnu_dfont "Reset to default font" ResetControlFont ;
         MenuSeparator
         MenuItem "Bring to Front"   doMoveToFront ;
         MenuItem "Move to Back"    doMoveToBack  ;
EndBar

: 2tabs              ( -- )
                     2 +tabs ;

\ Define Form Object class for ForthForm
:Class Form  <Super Window

Record: Info
        int frmWidth
        int frmHeight
        int frmXPos
        int frmYPos
  maxstring bytes frmTitle
   32 bytes frmName
        int controlcount
       byte FormFlags
     1 bits Modal
     1 bits SaveScreen?
     2 bits FormSuperClass  \ 0 = dialogwindow, 1 = childwindow, 2 = mdi dialog window
     1 bits Childstate
     1 bits with-statusbar
     2 bits ReservedFlags
maxstring 1- bytes Reserved    \ for future features?    original 260
;RecordSize: sizeof(Info)

Rect FormBox    \ for drawing boxes
max-path bytes formname   \ filename for this form
int ActiveControl         \ selected control
int ControlList           \ pointer to list of controls for this form
int modified?             \ was this form modified ?
int ThisControl           \ used temporarily for newly created control
int sizing?
int moving?
int cclicked?           \ control clicked ?
int selecting?          \ true if selecting a group of controls
LTGRAY value BackGroundColor  \ duh!
ffPoint upperleft         \ bounding coordinates
ffPoint lowerright        \ for active control
File FormFile           \ file name for this window
5 constant hsize        \ square handle size
int lastx
int lasty
int firsttime?          \ are we sizing for the first time?
int locked?
MultistatusBar frmStatusbar

32 constant array-size  \ holds count of each control type created for naming
\ purposes. Limit of 255 of any one type per form. If more is needed increase the
\ constant value
array-size bytes array()

: inc-array     ( index -- )
                1- array() + cincr ;

: dec-array     ( index -- )
                1- array() + cdecr ;

: get-array     ( index -- value )
                1- array() + c@ ;

:M Array():     ( n -- val )
                get-array ;M

: ShowModified     ( -- )
                modified?
                if      z" Modified"
                else    z" "
                then    3 SetText: statuswindow ;

: modified      ( -- )
                true to modified? ShowModified
                UpdateSystem ;

:M SendMessage: ( l w m -- res )
                hwnd Call SendMessage ;M

: ShowFormName  ( -- )
                frmName count asciiz 4 SetText: statuswindow ;

:M UpdateStatus:  ( -- ) \ refresh display of control information
                ActiveControl 0=
                if  ClearStatusWindow ShowModified
                    ShowFormName
                    exitm
                then    Origin: ActiveControl ShowPosition
                Dimensions: ActiveControl ShowSize
                GetName: ActiveControl asciiz 0 SetText: statuswindow
                ShowModified
                ShowFormName
                ;M

: IsActiveControl ( ctrl -- )
                to ActiveControl
                self to Activeform
                AutoProperty?
                if	doedit
                then
                UpdatePropertyWindow
                UpdateStatus: self ;

: NoActiveControl  ( -- )
                0 to ActiveControl
                ClearStatusWindow
                ShowModified    \ nevertheless show form status
                ShowFormName ;

: #controls      ( -- n )
                ControlList
                if      Data@: ControlList
                        if      #Links: ControlList
                        else    0
                        then
                else    0
                then    ;

: ?controlnumber { <object> -- n } \ given object address return position in list
                <object> 0= ControlList 0= or
                if      false exit
                then    >FirstLink: ControlList
                #controls 1+ 1
                ?do     Data@: ControlList <object> =
                        if     i unloop
                               exit
                        then   >NextLink: ControlList
                loop    0 ;

:M ?ControlNumber:      ( ctrl -- n )
                ?controlnumber ;M

: DisposeControls   ( -- )
                #controls 0= ?exit
                ControlList
                if      >FirstLink: ControlList
                        begin       Data@: ControlList dup to ThisControl
                        while       Free: ThisControl
				    \ ThisControl Dispose
                                    0 Data!: ControlList
                                    DeleteLink: ControlList
                        repeat      ControlList Dispose
                        0 to ControlList
                then    0 to ActiveControl ;

: NewControl (  -- addr )
   New> ControlObject dup to ThisControl ;

: (AddNewControl) (  --  )
                ControlList 0=
                if      New> Linked-List to ControlList
                then    Data@: ControlList
                if      AddLink: ControlList
                then    NewControl Data!: ControlList ;

: AddNewControl ( -- )
                ['] (AddNewControl) catch ExitOnError ;


: fonttype?     ( ctrltype -- f )
                dup 0= ?exit
                |   TypePushbutton
                    TypeGroupBox
                    TypeCheckBox
                    TypeRadioButton
                    TypeLabel
                    TypeTextBox
                    TypeMultiLineBox
                    TypeListBox
                    TypeComboBox
                    TypeComboListBox
                    TypeMultiListBox
                    TypeGeneric     \ in case we just want a font
                |if    true
                else   false
                then   ;

: ?mnu_font     ( -- )  \ according to type of control allow changing font
                ActiveControl dup
                if     GetType: [ ] fonttype?
                then   dup Enable: mnu_font Enable: mnu_dfont ;

:M AlignGridXY: ( -- )  \ align control to grid's x,y plane
                ActiveControl 0= ?exitm
                Origin: ActiveControl >r gridspacing / gridspacing *
                r> gridspacing / gridspacing *
                SetOrigin: ActiveControl
                Update: ActiveControl modified ;M

:M AlignGridY:  ( -- ) \ align to grid's vertical plane
                ActiveControl 0= ?exitm
                Origin: ActiveControl >r gridspacing / gridspacing *
                r> SetOrigin: ActiveControl
                Update: ActiveControl modified ;M

:M AlignGridX:  ( -- )  \ align to grid's horizontal plane
                ActiveControl 0= ?exitm
                Origin: ActiveControl gridspacing / gridspacing *
                SetOrigin: ActiveControl
                Update: ActiveControl modified ;M

: islastlink?   ( -- f )
                Link#: ControlList >r
                ActiveControl ?controlnumber >Link#: ControlList
                LastLink?: ControlList
                r> >Link#: ControlList ;

: activecontrol#        ( -- n )
                ActiveControl ?controlnumber ;

\ size a group of controls to same size of active control
\ terminate when group ends
:M AutoSize:    { \ awidth aheight atype ctrl -- }
                ActiveControl 0= #controls 2 < or islastlink? or ?exitm
                Dimensions: ActiveControl to aheight to awidth
                GetType: ActiveControl to atype
                #controls activecontrol# - 0     \ to end of list
                do      >NextLink: ControlList
                        Data@: Controllist to ctrl
                        GetType: ctrl atype =
                        if      awidth aheight SetDimensions: ctrl
                                Update: ctrl
                        else    leave            \ similarity ends
                        then
                loop    modified ;M

\ these two definitions arrange all similiar controls evenly spaced
\ assumes window is big enough
:M ArrangeVertical:     { \ height ctrl x y atype -- }
\ arrange orderly all sequential controls of this type
                ActiveControl 0= #controls 2 < or islastlink? or ?exitm
                GetType: ActiveControl to atype
                Dimensions: ActiveControl nip to height
                Origin: ActiveControl height + 2 + to y to x
                #controls activecontrol# - 0
                ?do     >NextLink: ControlList
                        Data@: ControlList to ctrl
                        GetType: ctrl atype =
                        if      x y SetOrigin: ctrl
                                Update: ctrl
                                y height + 2 + to y
                        else    leave    \ end at first change
                        then
                loop    modified ;M

:M ArrangeHorizontal: { \ width ctrl x y atype -- }
\ arrange orderly all sequential controls of this type
                ActiveControl 0= #controls 2 < or islastlink? or ?exitm
                GetType: ActiveControl to atype
                Dimensions: ActiveControl drop to width
                Origin: ActiveControl to y width + 2 + to x
                #controls activecontrol# - 0
                ?do     >NextLink: ControlList
                        Data@: ControlList to ctrl
                        GetType: ctrl atype =
                        if      x y SetOrigin: ctrl
                                Update: ctrl
                                x width + 2 + to x
                        else    leave    \ end at first change
                        then
                loop    modified ;M

: inbox?        { ctrl -- f } \ f = true if top left corner of ctrl is in box
                Origin: ctrl >r Left: FormBox Right: FormBox between
                r> Top: FormBox Bottom: FormBox between and ;

:M GroupAlignLeft:  { \ ctrl -- }   \ align grouped controls to left edge of box
                selecting? not ?exitm
                #controls 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Left: FormBox Origin: ctrl nip SetOrigin: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupAlignRight: { \ ctrl -- }   \ align grouped controls to right edge of box
                selecting? not ?exitm
                #controls 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl drop Dimensions: ctrl drop +   ( x + w )
                                Right: FormBox swap - Origin: ctrl >r + r>
                                SetOrigin: ctrl Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupAlignTop:   { \ ctrl -- }   \ align grouped controls to top edge of box
                selecting? not ?exitm
                #controls 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl drop Top: FormBox SetOrigin: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupAlignBottom:    { \ ctrl -- }   \ align grouped controls to bottom edge of box
                selecting? not ?exitm
                #controls 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl nip Dimensions: ctrl nip +  ( y + h )
                                Bottom: FormBox swap - >r Origin: ctrl r> +
                                SetOrigin: ctrl Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

: sizecontrol   { n \ ctrl this w h flag -- } \ n=1=tallest,2=shortest,3=widest,4=narrowest
\ this test code can be simplified, get rid of all these "if "then"!
                >FirstLink: ControlList
                0 to this   \ will hold desired control
                n 2 > to flag
                #controls 0
                do  Data@: ControlList dup to ctrl inbox?
                    if  Dimensions: ctrl to h to w
                        this 0= \ not yet have a value
                        if  flag
                            if  w   \ we want width
                            else    h
                            then    to this
                        else    flag
                            if  w
                            else    h
                            then    dup this n 2 mod
                            if  >
                            else    <
                            then
                            if  to this
                            else    drop
                            then
                        then
                    then    >NextLink: ControlList
                loop    \ we should now have the one we want
                this 0= ?exit   \ leave if we don't
                >FirstLink: ControlList
                #controls 0
                do  Data@: ControlList dup to ctrl inbox?
                    if  Dimensions: ctrl flag
                        if  nip this swap
                        else    drop this
                        then    SetDimensions: ctrl
                        Update: ctrl modified
                    then    >NextLink: ControlList
                loop    UpdateStatus: self UpdatePropertyWindow ;

:M GroupSizeTallest:    ( -- )
            selecting? not ?exitm
            #controls 0= ?exitm
            Link#: ControlList >r
            1 sizecontrol
            r> >Link#: ControlList Paint: self ;M

:M GroupSizeShortest:   ( -- )
            selecting? not ?exitm
            #controls 0= ?exitm
            Link#: ControlList >r
            2 sizecontrol
            r> >Link#: ControlList Paint: self ;M

:M GroupSizeWidest: ( -- )
            selecting? not ?exitm
            #controls 0= ?exitm
            Link#: ControlList >r
            3 sizecontrol
            r> >Link#: ControlList Paint: self ;M

:M GroupSizeNarrowest:  ( -- )
            selecting? not ?exitm
            #controls 0= ?exitm
            Link#: ControlList >r
            4 sizecontrol
            r> >Link#: ControlList Paint: self ;M

:M GroupSizeToBox:  { \ bx by bw bh ctrl -- }
            selecting? not ?exitm
            #controls 0= ?exitm
            Link#: ControlList >r
            >FirstLink: ControlList
            #controls 0
            do  Data@: ControlList dup to ctrl inbox?
                if  Left: FormBox Origin: ctrl nip SetOrigin: ctrl
                    Right: FormBox Left: FormBox - ( new width)
                    Dimensions: ctrl nip SetDimensions: ctrl
                    Update: ctrl modified
                then    >NextLink: ControlList
            loop    r> >Link#: ControlList
            UpdateStatus: self UpdatePropertyWindow
            Paint: self ;M

create spad 100 allot    \ temporary sort pad, 24 controls maximum at a time

: findcontrols      ( -- ) \ find all controls in box, save to spad
            spad off
            >FirstLink: ControlList
            #controls 0
            do  Data@: ControlList dup inbox?
                if  spad lcount cells+ !
                    1 spad +!
                else    drop
                then
                >NextLink: ControlList
            loop    ;

: sortcontrols  { n -- }    \ n=0 vertical sort else horizontal sort ascending
\ Simple sort algorithm, e.g 4 3 2 1 - test 4,3 then 3,2 then 2,1 - swap if
\ necessary after compare, do this for (n items - 1) times
            spad @ 2 < ?exit
            spad @ 1- 0          \ n-1 iterations
            do  spad lcount 1- cells bounds
                do  i @ Origin: [ ] n
                    if      drop    ( x )
                    else    nip     ( y )
                    then    i cell+ @ Origin: [ ] n
                    if  drop
                    else    nip
                    then    >
                    if  i @ i cell+ tuck @ i ! swap !   \ swap memory
                    then
               cell +loop
            loop ;

:M GroupArrangeVertical: { \ ctrl x y h -- }    \ starting at first control
            selecting? not ?exitm
            #controls 2 < ?exitm
            Link#: ControlList >r
            findcontrols
            0 sortcontrols
            r> >Link#: ControlList
            spad @ 2 < ?exitm
            spad lcount >r @ to ctrl
            Dimensions: ctrl nip to h
            Origin: ctrl h + 2 + to y to x
            spad 2 cells+ r> 1- cells bounds
            do  x y i @ >r SetOrigin: [ r@ ]
                Update: [ r@ ]
                Dimensions: [ r> ] nip y + 2 + to y
          cell  +loop   modified UpdateStatus: self UpdatePropertyWindow
            Paint: self ;M

:M GroupArrangeHorizontal: { ctrl x y w -- }    \ starting at first control
            selecting? not ?exitm
            #controls 2 < ?exitm
            Link#: ControlList >r
            findcontrols
            1 sortcontrols
            r> >Link#: ControlList
            spad @ 2 < ?exitm
            spad lcount >r @ to ctrl
            Dimensions: ctrl drop to w
            Origin: ctrl to y w + 2 + to x
            spad 2 cells+ r> 1- cells bounds
            do  x y i @ >r SetOrigin: [ r@ ]
                Update: [ r@ ]
                Dimensions: [ r> ] drop x + 2 + to x
           cell +loop   modified UpdateStatus: self UpdatePropertyWindow
            Paint: self ;M

:M GroupMoveUp:   { \ ctrl val -- }   \ shift up by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl val - SetOrigin: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupMoveDown:   { \ ctrl val -- }   \ shift down by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl val + SetOrigin: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupMoveLeft:   { \ ctrl val -- }   \ shift left by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl val negate under+ SetOrigin: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupMoveRight:   { \ ctrl val -- }   \ shift right by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Origin: ctrl val under+ SetOrigin: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupHeightUp:   { \ ctrl val -- }   \ increase height by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Dimensions: ctrl val + SetDimensions: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupHeightDown:   { \ ctrl val -- }   \ reduce height by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Dimensions: ctrl val - SetDimensions: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupWidthUp:   { \ ctrl val -- }   \ increase width by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Dimensions: ctrl val under+ SetDimensions: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GroupWidthDown:   { \ ctrl val -- }   \ reduce width by specified value
                selecting? not ?exitm
                #controls 0= ?exitm
                GetValue: frmAction to val
                val 0= ?exitm
                Link#: ControlList >r
                >FirstLink: ControlList
                #controls 0
                do      Data@: ControlList dup to ctrl inbox?
                        if      Dimensions: ctrl val negate under+ SetDimensions: ctrl
                                Update: ctrl modified
                        then    >NextLink: ControlList
                loop    r> >Link#: ControlList Paint: self UpdateStatus: self
                UpdatePropertyWindow ;M

:M GetData:     ( -- addr cnt )
                Info sizeof(Info)
                ;M

:M SetData:     ( addr cnt -- )
                sizeof(Info) min 0max Info swap move
                ;M

:M GetCount:    ( -- cnt )
                controlcount
                ;M

:M SetCount:    ( count -- )
                to controlcount
                ;M

: +hsize        { x y  -- x2 y2 }
                hsize x + hsize y + ;

: controlbox    ( -- )  \ set the boundaries for the active control
                GetWindowRect: ActiveControl
                SetPoint: lowerright
                SetPoint: upperleft ;

: topleft       ( -- tlx tly brx bry )  \ return rect of topleft handle
                GetPoint: upperleft 7 -   \ box points must be set
                2dup +hsize ;

: topright      ( -- tlx tly brx bry )
                lowerright.x 4 - upperleft.y 7 -
                2dup +hsize ;

: bottomleft    ( -- tlx tly brx bry )
                upperleft.x lowerright.y 2 +
                2dup +hsize ;

: bottomright   ( -- tlx tly brx bry )
                lowerright.x 4 - lowerright.y 2 +
                2dup +hsize ;

\ if mouse is in handle set handle id
\ 1=topleft, 2=topright, 3=bottomleft, 4=bottomright
0 value hid

: inhandle?     ( -- f )        \ is mouse in a sizing handle?
                0 to hid        \ reset
                ActiveControl 0=
                if      false exit
                then    controlbox
                topleft     >r swap >r mousex -rot between mousey r> r> between and ?dup
                if      1 to hid exit   then
                topright    >r swap >r mousex -rot between mousey r> r> between and ?dup
                if      2 to hid exit   then
                bottomleft  >r swap >r mousex -rot between mousey r> r> between and ?dup
                if      3 to hid exit   then
                bottomright >r swap >r mousex -rot between mousey r> r> between and ?dup
                if      4 to hid exit   then
                false ;

:M ShowSizingHandles:   { flag \ fillcolor -- }
\ if flag = true show handles, else erase them
               ActiveControl 0<> moving? not and
               if       flag
                        if      LTBLUE
                        else    BackGroundColor
                        then    to fillcolor
                        get-dc
                        controlbox
                        topleft     fillcolor FillArea: dc \ 5x5 handles
                        topright    fillcolor FillArea: dc \ at each
                        bottomleft  fillcolor FillArea: dc \ of four
                        bottomright fillcolor FillArea: dc \ corners
                        release-dc
                then    ;M

: ShowHandles   ( -- )
                true ShowSizingHandles: self ;

: HideHandles   ( -- )
                false ShowSizingHandles: self ;


: (drawBox)     { n  -- }
                get-dc
                addr: dc
                SetDC: FormBox
                n
                if     DrawDotted: FormBox
                else   DrawNormal: FormBox
                then   release-dc ;

: drawbox       ( -- )
                0 (drawbox) ;

: drawdottedbox    ( -- )
                1 (drawbox) ;

: eraseBox      ( -- ) \ really same as drawbox
                drawBox ;

: ShowBox       ( left top right bottom -- )
                mousex to lastx mousey to lasty  \ save mouse first
                eraseBox
                4dup SetRect: FormBox drawBox
                selecting? not
                if      2over ShowPosition
                        rot - -rot swap - swap ShowSize
                else    4drop
                then    ;

\ The following four routines adjust the selection rectangle using the arrow keys
\ Each press of the arrow key adjusts by 4, but can be modified
\ Handy when a group of controls has been moved out of the selection rectangle
: adjust-left   ( -- )
                selecting? not ?exit
                Left: FormBox cell- Top: FormBox Right: FormBox Bottom: FormBox
                SetRect: FormBox Paint: self ;

: adjust-right  ( -- )
                selecting? not ?exit
                Left: FormBox Top: FormBox Right: FormBox cell+ Bottom: FormBox
                SetRect: FormBox Paint: self ;

: adjust-up     ( -- )
                selecting? not ?exit
                Left: FormBox Top: FormBox cell- Right: FormBox Bottom: FormBox
                SetRect: FormBox Paint: self ;

: adjust-down   ( -- )
                selecting? not ?exit
                Left: FormBox Top: FormBox Right: FormBox Bottom: FormBox cell+
                SetRect: FormBox Paint: self ;

: sizebottomright     { \ l t r b -- }
                ActiveControl 0= ?exit
                Left: FormBox to l
                Top: FormBox to t
                mousex lastx - Right: FormBox +  to r
                mousey lasty - Bottom: FormBox +  to b
                l t r b ShowBox ;

: sizetopleft      ( -- )
                ActiveControl 0= ?exit
                mousex lastx - Left: FormBox +
                mousey lasty - Top: FormBox +
                Right: FormBox Bottom: FormBox
                ShowBox ;

: sizetopright  ( -- )
                ActiveControl 0= ?exit
                Left: FormBox
                mousey lasty - Top: FormBox +
                mousex lastx - Right: FormBox +
                Bottom: FormBox
                ShowBox ;

: sizebottomleft  ( -- )
                ActiveControl 0= ?exit
                mousex lastx - Left: FormBox +
                Top: FormBox
                Right: FormBox
                mousey lasty - Bottom: FormBox +
                ShowBox ;

: incontrol?    { ctrl \ left top right bottom -- }   \ is mouse in control object ?
                GetWindowRect: ctrl to bottom to right to top to left
                mousex left right between
                mousey top bottom between and ;

: ControlClicked?       ( -- ctrl | 0 )
                false        \ default
                #controls 0= ?exit
                >LastLink: ControlList          \ start from back
                #controls 0
                do      Data@: ControlList dup incontrol?
                        if      nip unloop exit
                        else    drop
                        then    >PrevLink: ControlList
                loop    ;

: clicked       ( -- )
                hwnd call SetCapture drop
		SingleControl?
		if	ButtonID IDC_BITMAP IDC_Generic between
                	if      false ButtonID   CheckButton: TheControlToolBar     \ uncheck it
                        	true  IDC_SELECT CheckButton: TheControlToolBar     \ set default
                	then    0 to ButtonID  \ clear buttonid
		then	HideHandles
                locked?
                if      ControlClicked? IsActiveControl         \ set temporary for status display
                        0 to ActiveControl                      \ clear when done
                        exit
                then    mousex to lastx mousey to lasty
                newcontrol?
                if      mousex mousey 2dup        \ starting size
                        SetRect: FormBox
                        drawBox
                        NoActiveControl exit
                then    sizing? ?exit
                inhandle?
                if      GetWindowRect: ActiveControl
                        SetRect: FormBox
                        drawBox
                        true to sizing? exit
                then    ControlClicked? ?dup
                if      IsActiveControl
                        GetWindowRect: ActiveControl SetRect: FormBox
                        drawbox
                        true to cclicked? false to selecting?
                        hand-cursor
                        ShowHandles exit
                then    selecting?
                if      erasebox            \ remove old box
                then    true to selecting?          \ selecting controls
                mousex mousey 2dup SetRect: FormBox     \ no initial size
                drawbox ;                   \ keep control active

: DefaultNewControl  ( -- )
                NextControlType ?dup
                if      dup SetType: ThisControl
                        dup TypePushButton =
                        if      1 IsOrientation: ThisControl \ default center
                        then    inc-array
                        Initialize: ThisControl
                then    ;

: SetupNewControl       ( -- )
                AddNewControl
                Left: FormBox Top: FormBox 2dup SetOrigin: ThisControl
                Bottom: FormBox - abs swap Right: FormBox - abs swap
                SetDimensions: ThisControl
                DefaultNewControl ;

: DefaultControlSize   ( -- )  \ set up formbox for default size
                Left: FormBox Top: FormBox
                NextControlType
                case
                     TypeVertScroll             of  25 100      endof
                     TypeFileWindow             of  120 135     endof
                     | TypeMultiLineBox
                       TypeStaticBitmap
                       TypeListBox
                       TypeGroupBox
                       TypeTabControl           |of 120 75      endof
                                                100 25 rot
                endcase 2over d+ SetRect: FormBox ;

: adjust-box    ( --)   \ adjust in case end point is less than beginning point
                Left: FormBox Top: FormBox Right: FormBox Bottom: FormBox
                { l t r b \ w h }
                r l - to w       \ width
                b t - to h       \ height
                w 0<
                if    w +to l
                then  h 0<
                if    h +to t
                then  l w abs + to r
                t h abs + to b
                l t r b SetRect: FormBox ;

: unclicked     ( -- )
                hwnd Call ReleaseCapture drop
                locked? ?exit
		adjust-box
                newcontrol?
                if      SingleControl?
			if	false to newcontrol?
			then
                        \ single click will create control with default size
                        Left: FormBox Right: FormBox - abs hsize 3 * <
                        if       DefaultControlSize
                        then    SetupNewControl
                        ThisControl IsActiveControl
                        ShowHandles modified false to selecting?
                then    sizing? moving? or
                if      Left: FormBox Top: FormBox SetOrigin: ActiveControl
                        Right: FormBox Left: FormBox - abs    \ width
                        Bottom: FormBox Top: FormBox - abs   \ height
                        SetDimensions: ActiveControl
                        false to sizing? false to moving? false to selecting?
                        Update: ActiveControl
                        UpdatePropertyWindow
                        ShowHandles modified
                then    false to cclicked?
                Left: FormBox Top: FormBox Right: FormBox Bottom: FormBox d=
                if      false to selecting? NoActiveControl     \ no box drawn
                then
                ActiveControl 0=
                if	AutoProperty?
			if	doform
			then
		then
		Paint: self     ;

: dosize        { \ deltax deltay -- }
                locked? ?exit
                newcontrol?
                if      Left: FormBox Top: FormBox
                        mousex lastx - Right: FormBox +
                        mousey lasty - Bottom: FormBox +
                        ShowBox exit
                then    hid
                if      hid
                        case
                                1  of sizetopleft     endof
                                2  of sizetopright    endof
                                3  of sizebottomleft  endof
                                4  of sizebottomright endof
                        endcase exit
                then    cclicked?
                if      true to moving?
                        mousex lastx - to deltax mousey lasty - to deltay
                        deltax   Left: FormBox + abs
                        deltay    Top: FormBox + abs
                        deltax  Right: FormBox + abs
                        deltay Bottom: FormBox + abs ShowBox exit
                then    selecting?
                if      Left: FormBox Top: FormBox
                        mousex lastx - Right: FormBox +
                        mousey lasty - Bottom: FormBox +
                        ShowBox
                then    ;
int mousedown
: ?mousepointer (  -- )
                sizing? newcontrol? or moving? or ?exit
                mousedown selecting? and ?exit
                inhandle?
                if      sizeall-cursor
                else    ControlClicked?       \ not really in this case, check if mouse in control
                        if   hand-cursor
                        else arrow-cursor
                        then
                then    ;

:M WM_MOUSEMOVE ( h m w l -- )
                over MK_LBUTTON and to mousedown    \ mouse left button pressed?
                WM_MOUSEMOVE WM: Super
                ?mousepointer
                ;M

:M WM_RBUTTONDOWN  { h m w l -- }
                l set-mousexy
                HideHandles
                ControlClicked? ?dup
                if      locked?
                        if      drop
                        else    IsActiveControl
                        then    ChildPopup to CurrentPopup
                        ?mnu_font
                else    locked? Check: mnu_lock
                        FormPopup  to CurrentPopup
                then    h m w l WM_RBUTTONDOWN WM: Super
                ;M

:M Refresh:     ( -- )
                hwnd 0= ?exitm
                with-statusbar
                if      GetHandle: frmStatusBar 0=
                        if      self Start: frmStatusBar
                                SetSimple: frmStatusBar
                        then
                else    Close: frmStatusBar
                then    ;M

:M Init:        ( -- )
                150 to frmXPos
                175 to frmYPos
                350 to frmWidth
                200 to frmHeight
                0 to controlcount
                s" Form" frmTitle place
                frmTitle +null
                s" Form1" frmName place
                false to Modal
                false to SaveScreen?
                DIALOG-CLASS to FormSuperClass         \ default to dialog
                false to ChildState
                false to with-statusbar
                ;M

:M SetName:     ( addr cnt -- )
                31 min 0max frmName place
                ;M

:M ClassInit:   ( -- )
                ClassInit: super
                Erase: upperleft
                Erase: lowerright
                0 to ActiveControl
                0 to ControlList
                0 to modified?
                0 to ThisControl
                0 to sizing?
                0 to moving?
                0 to cclicked?
                0 to selecting?
                true to firsttime?
                false to locked?
                Init: self
                ;M

:M WindowTitle: ( -- )
                frmTitle 1+ ;M

:M StartSize:   ( -- w h )
                0 0                     \ adjust x,y relative to 0,0
                frmWidth frmHeight
                SetRect: TempRect
                0                       \ no menu
                WindowStyle:   [ self ]                 \ the window style
                AddrOf: TempRect                        \ make a new rectangle
                call AdjustWindowRect ?win-error        \ adjust the window
                Right: TempRect Left: TempRect -         \ adjusted  width
                Bottom: TempRect  Top: TempRect -         \ adjusted height
                ;M

:M StartPos:    ( -- x y )
                frmXPos frmYPos ;M

:M WindowStyle: ( -- wstyle )
                WindowStyle: super
                ;M

:M Start:       ( -- )         \ create a new window object
                hWnd 0=
                if      register-frame-window drop
                        create-frame-window to hWnd
                       \  SW_SHOWNORMAL Show: self
                        Update: self
                else    SetFocus: self
                then	AutoProperty?
                if	doform
                then	;M

:M On_Size:     ( -- )
                locked? ?exitm          \ if form is locked disable sizing
                width to frmWidth height to frmHeight
                firsttime? not    \ ignore sizing message when when window is created
                if      modified
                else    false to firsttime?
                then    with-statusbar
                if      Redraw: frmStatusBar
                then    doupdate ;M

:M MinSize:     ( -- w h )  \ if form is locked disable sizing
                locked?
                if      frmwidth frmheight
                else    0 0
                then    ;M

:M Maxsize:     ( -- w h )  \ if form is locked disable sizing
                locked?
                if      frmwidth frmheight
                else    screen-size
                then    ;M

:M On_Init:     ( -- )
                ['] dosize      SetTrackFunc: self
                ['] clicked     SetClickFunc: self
                ['] unclicked SetUnClickFunc: self
                FormPopup        SetPopupBar: self   \ need to start
                ChildPopup       SetPopupBar: self   \ both popups
                self to ActiveForm
                array() array-size erase
                FormColor to BackGroundColor
                Refresh: self
                UpdateSystem
                ;M

: drawgrid      ( -- )
                Height: self gridspacing / 1+ 1
                ?do     Width: self gridspacing / 1+ 1
                        ?do     i gridspacing * j gridspacing *
                                GREEN SetPixel: dc
                        loop
                loop    ;

:M On_Paint:    ( -- )
                0 0 Getsize: self FormColor FillArea: dc
                drawgrid
                locked? ?exitm
                ActiveControl 0<> moving? not and sizing? not and
                if      ShowHandles
                then    selecting?
                if      drawdottedbox
                then    ;M

:M On_Done:     ( -- )
     \           DisposeControls
                On_Done: Super
                ;M

:M ParentWindow:        ( -- parent )
                GetHandle: TheMainWindow ;M

:M DeleteControl:      ( -- )
                ActiveControl 0= ?exitm
                GetType: ActiveControl dec-array
                ActiveControl ?ControlNumber >Link#: ControlList
                Free: ActiveControl
                ActiveControl Dispose   \ closes control before disposing
                0 Data!: ControlList
                DeleteLink: ControlList
                NoActiveControl
                Paint: self
                modified ;M

:M ChangeControl: ( -- )
\ not all attributes of the old control are kept
\ the name and some others will have to be re-setup
                  AddNewControl
                  Origin: ActiveControl SetOrigin: ThisControl
                  Dimensions: ActiveControl SetDimensions: ThisControl
                  Group?: ActiveControl IsGroup: ThisControl
                  Global?: ActiveControl IsGlobal: ThisControl
                  DefaultNewControl
                  false to newcontrol?  \ clear flag
                  ButtonID 0 to ButtonID  \ clear buttonid
                  IDC_BITMAP IDC_Generic between
                  if      false ButtonID   CheckButton: TheControlToolBar
                          true  IDC_SELECT CheckButton: TheControlToolBar
                  then    \ we will keep our position in the tab order
                  ThisControl ?ControlNumber    \ link to be deleted
                  ActiveControl ?ControlNumber dup>r >Link#: ControlList
                  ThisControl Data!: ControlList    \ set new control at active control location
                  >Link#: ControlList       \ return to new link added
                  0 Data!: ControlList      \ zero it
                  DeleteLink: ControlList   \ and delete
                  Free: ActiveControl
                  ActiveControl Dispose     \ ditto for old control
                  r> >Link#: ControlList    \ as we were
                  ThisControl IsActiveControl
                  ShowHandles modified ;M

:M MoveToFront:  ( -- )  \ position control in list so it will be found first
                ActiveControl 0= ?exitm
                #controls 2 < ?exitm
                ActiveControl ?controlnumber
                >LastLink: ControlList Link#: ControlList over =
                if      drop exitm       then             \ already in front
                    >Link#: ControlList
                     Data@: ControlList >r
                DeleteLink: ControlList
                   AddLink: ControlList
                r>   Data!: ControlList
                     Paint: self
                     modified ;M

:M MoveToBack:   ( -- )  \ position control in list so it will be found last
                ActiveControl 0= ?exitm
                #controls 2 < ?exitm
                ActiveControl ?controlnumber
                >FirstLink: ControlList Link#: ControlList over =
                if      drop exitm       then              \ already at back
                    >Link#: ControlList
                     Data@: ControlList >r
                DeleteLink: ControlList
                >FirstLink: ControlList
                InsertLink: ControlList
                r>   Data!: ControlList
                     Paint: self
                     modified ;M

:M Locked?:     ( -- f )
                locked? ;M

:M Lock:        ( -- )
                locked? 0= dup to locked?           \ toggle flag
                0=
                if      frmtitle count SetText: self
                        exitm
                then    false to modified?
                ShowModified
                HideHandles
                NoActiveControl
                frmTitle count pad place
                s" (Locked)" pad +place
                pad count Settext: self
                false to selecting?
                Paint: self ;M

: IsNewForm?    ( -- f )  \ has form not yet been saved?
                formname count s" untitled.ff" istr= ;

: SaveIt?       { \ temp$ -- f }
                join$( 	s" File "
			formname count
			s"  has been modified. Save it?"
                )join$  1+
                z" Heads up!" MB_YESNO MB_ICONQUESTION or
                MessageBox: self IDYES = ;

: ShowFileName  { \ temp$ -- }
                join$(  ForthFormTitle$
			s"  - "
			formname count
                )join$  count SetText: TheMainWindow ;

: ?addext       ( -- )
                formname count ".ext-only" nip 0=
                if      s" .ff" formname +place
                then    formname +null ;

: SaveForm      (  --  )
                modified? 0= ?exit
                IsNewForm?
                if      hwnd Start: SaveFormDlg
                        dup c@ 0=
                        if      drop exit
                        then    count formname place ?addext
                        ShowFileName
                then    formname count SetName: FormFile
                Create: FormFile ?exit
                #controls SetCount: self
                GetData: self Write: FormFile   \ save header first
                if      Close: FormFile exit    \ exit if error
                then    ControlList
                if      >FirstLink: ControlList         \ next the control info
                        #controls 0
                        ?do     Data@: ControlList to ThisControl
                                GetData: ThisControl Write: FormFile
                                if      Close: FormFile unloop  \ error ocurred
                                        exit
                                then    >NextLink: ControlList
                        loop
                then    Close: FormFile false to modified? ;

:M Save:        ( -- )
                SaveForm ;M

:M SaveAs:        ( -- )
                hwnd Start: SaveFormDlg dup c@
                if      count formname place ?addext ShowFileName
                        modified
                        SaveForm
                else    drop
                then    ;M

:M SetFileName: ( addr cnt -- )
                formname place ;M

:M GetFileName: ( -- addr cnt )
                formname count ;M

: LoadForm      ( -- )
                formname count SetName: FormFile
                Open: FormFile ?exit
                GetData: self Read: FormFile
                if      Close: FormFile
                        exit
                then    GetCount: self 0
                ?do     AddNewControl
                        GetData: ThisControl Read: FormFile
                        if      leave       \ don't exit
                        else    DoInit: ThisControl
                                GetType: ThisControl inc-array  \ update count
                        then
                loop    Close: FormFile
                ShowFileName
                frmtitle count SetTitle: Self
                StartSize: self hwnd AdjustWindowSize
                Refresh: self ;

:M Load:        ( -- f )
                LoadForm
                ;M

:M On_SetFocus: ( -- )
                self to ActiveForm
                ShowFileName
                doUpdate
                UpdateStatus: self
                ActiveControl
                if      UpdatePropertyWindow
                then    UpdateSystem ;M

:M Close:       ( -- )
                modified?
                if      SaveIt?
                        if      SaveForm
                        then
                then   DisposeControls
		Close: Super ;M

:M WM_CLOSE     ( -- ) \ let parent do the closing
                self doCloseForm
                ;M

:M PushKey:     ( c -- )
                case
     ( Ctrl-R )         'R' +k_control  of       doSaveAs               endof
     ( Ctrl-S )         'S' +k_control  of       doSave                 endof
     ( Ctrl-T )         'T' +k_control  of       doTest                 endof
     ( Ctrl-V )         'V' +k_control  of       doEditor               endof
     ( Ctrl-W )         'W' +k_control  of       doWrite                endof
                         K_DELETE       of       dodelete               endof
                         K_LEFT         of       adjust-left            endof
                         K_RIGHT        of       adjust-right           endof
                         K_UP           of       adjust-up              endof
                         K_DOWN         of       adjust-down            endof
                         K-F12          of K-F12 PushKey: TheMainWindow endof
                         K-F9           of K-F9  PushKey: TheMainWindow endof
                         K-F1           of K-F1  PushKey: TheMainWindow endof
                endcase ;M

:M Display:     ( -- )
                SW_SHOWNORMAL Show: self
                ;M

:M ControlList:        ( -- lit )
                ControlList
                ;M

:M ActiveControl:       ( -- ctrl )
                ActiveControl
                ;M

:M SetActiveControl: ( ctrl -- )
        to ActiveControl
        ;M

:M #Controls:   ( -- n )
                #controls
                ;M

:M IsModified:  ( -- )
                modified
                ;M

:M FormName:    ( -- addr )
                frmName
                ;M

:M IsFormName:  ( addr cnt -- )
                SetName: self
                ;M

:M FormTitle:   ( -- addr )
                frmTitle
                ;M

:M IsFormTitle: ( addr cnt -- )
                maxstring 2 - min 0max frmTitle place
                frmtitle +null
                ;M

:M Origin:      ( -- x y )
                frmXPos frmYPos
                ;M

:M SetOrigin:   ( x y -- )
                to frmYPos to frmXPos
                ;M

:M Dimensions:  ( -- w h )
                frmWidth frmHeight
                ;M

:M SetDimensions: ( w h -- )
                to frmHeight to frmWidth
                ;M

:M SetModal:    ( n -- ) \ set modal flag
                to modal ;M

:M GetModal:    ( -- n )
                modal ;M

:M IsSaveScreen?: ( f -- )
        to SaveScreen? ;M

:M SaveScreen?: ( --f )
        SaveScreen? ;M

:M GetSuperClass: ( -- n )
        FormSuperClass ;M

:M IsSuperClass: ( n -- )
        to FormSuperClass ;M

:M ChildState:  ( -- f )
        ChildState ;M

:M IsChildState: ( f -- )
        to ChildState ;M

:M StatusBar?:  ( -- f )
        with-statusbar ;M

:M IsStatusBar: ( f -- )
            to with-statusbar ;M

\ ****************** Definitions to write form information ********************

: writeGroupStyle   ( -- )      \ write WS_GROUP style if needed
                 Group?: ThisControl
                GetType: ThisControl TypeRadioButton <> and
                if      +crlf 2tabs s" WS_GROUP +Style: " append
                        GetName: ThisControl append
                then    ;

: writecommoncode   ( -- )     \ startup code common to all controls
                +crlf
                2tabs s" self Start: " append GetName: ThisControl append&crlf
                2tabs Origin: ThisControl swap #append #append
                Dimensions: ThisControl swap #append #append
                s" Move: " append GetName: ThisControl append

                writeGroupStyle ;

: writetext     ( -- ) \ code to set the text of control
                +crlf
                2tabs s"append GetTitle: ThisControl append "append
                s"  SetText: " append GetName: ThisControl append  ;

: writeStyle    ( addr cnt -- )
                +crlf
                2tabs append s"  +Style: " append GetName: ThisControl append ;

: fontname      ( -- name cnt )
                GetName: ThisControl pad place s" -font" pad +place pad count ;

: writefont     ( -- )
                +crlf 2tabs
                FontChanged: ThisControl
                if     s" Set-" append fontname append&crlf 2tabs
                       s" Create: " append fontname append&crlf 2tabs
                       s" Handle: " append fontname append s"  SetFont: " append GetName: ThisControl append
                else   s" Handle: Winfont SetFont: " append GetName: ThisControl append
                then   ;

: write-fontfuncs  ( -- )  \ create a definition for each font to be changed
                #controls 0= ?exit
                #controls 1+ 1
                do      i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        FontChanged: ThisControl
                        if          +crlf
                                    i 1 =  \ comment once only
                                    if     s" \ Font setting definitions" append&crlf
                                    then   s" Font " append fontname append&crlf
                                     s" : Set-" append fontname append s"  ( -- )" append&crlf
                                     2 +tabs FontData: ThisControl drop
                                     dup @ (.)  5 append.l s"         Height: " append fontname append&crlf 2tabs cell+
                                     dup @ (.)  5 append.l s"          Width: " append fontname append&crlf 2tabs cell+
                                     dup @ (.)  5 append.l s"     Escapement: " append fontname append&crlf 2tabs cell+
                                     dup @ (.)  5 append.l s"    Orientation: " append fontname append&crlf 2tabs cell+
                                     dup @ (.)  5 append.l s"         Weight: " append fontname append&crlf 2tabs cell+
                                     dup c@ if             s" true    Italic: " append fontname append&crlf 2tabs then 1+
                                     dup c@ if             s" true Underline: " append fontname append&crlf 2tabs then 1+
                                     dup c@ if             s" true StrikeOut: " append fontname append&crlf 2tabs then 1+
                                     dup c@ (.) 5 append.l s"        CharSet: " append fontname append&crlf 2tabs 1+
                                     dup c@ (.) 5 append.l s"   OutPrecision: " append fontname append&crlf 2tabs 1+
                                     dup c@ (.) 5 append.l s"  ClipPrecision: " append fontname append&crlf 2tabs 1+
                                     dup c@ (.) 5 append.l s"        Quality: " append fontname append&crlf 2tabs 1+
                                     dup c@ (.) 5 append.l s" PitchAndFamily: " append fontname append&crlf 2tabs 1+
                                     s"append zcount append "append s"  SetFacename: " append fontname append s"  ;" append&crlf
                        then
                loop    ;

: write-delete-fonts ( -- )
                #controls 0= ?exit
                #controls 1+ 1
                do      i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        FontChanged: ThisControl
                        if     2tabs s" Delete: " append fontname append&crlf
                        then
                loop    ;

: writeneeds    ( -- )  \ what files are needed by the form
                s" \ " append TextFile: [ self ] "to-pathend" 2dup upper append&crlf
                #controls 0<> with-statusbar or
                if      s" \- textbox needs excontrols.f" append&crlf
\ only add "needs bitmap.f" if we have a bitmap or an icon button
                        TypeBitmapButton  get-array
                        TypeIconButton  get-array or
                        TypeStaticBitmap get-array or
                        if      s" \- usebitmap needs bitmap.f" append&crlf
                        then
                        TypeFileWindow  get-array       \ do we have any?
                        if      s" \- -FolderView.f needs folderview.f   \ folder browser" append&crlf
                        then
                then    GetSuperClass: self MDIDIALOG-CLASS =
                if  s" \- notcancelled needs mdi.f         \ multiple document interface routines" append&crlf
                    s" \- mdidialogwindow needs mdidialog.f    \ actual super class" append&crlf
                then    ;

: writeopening  ( -- )
                +crlf
                s" :Object " append frmName count append
                2tabs s" <Super " append
                GetSuperClass: self dup CHILD-CLASS =
                if      drop s" Child-Window"
                else    MDIDIALOG-CLASS =
                        if  s" MDIDialogWindow"
                        else    s" DialogWindow"
                        then
                then    append&crlf
                +crlf s" Font WinFont           \ default font" append&crlf     \ font for controls
                s" ' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND" append&crlf
                s" ColorObject FrmColor      \ the background color " append&crlf
                with-statusbar
                if      s" StatusBar TheStatusBar" append&crlf
                then    GetSuperclass: self DIALOG-CLASS =      \ only for dialogwindow super class
                if  SaveScreen?
                    if  frmXPos #append frmYPos #append
                        s"  2value XYPos  \ save screen location of form" append&crlf
                    then
                then    write-fontfuncs ;

: write-child-params    { \ cx cy cw ch -- }
\ For a child window we want only the size and position
                Origin: ThisControl to cy to cx
                Dimensions: ThisControl to ch to cw
                s" \ Coordinates and dimensions for " append GetName: ThisControl append&crlf
                cx #append s"  value " append GetName: ThisControl append s" X" append&crlf
                cy #append s"  value " append GetName: ThisControl append s" Y" append&crlf
                cw #append s"  value " append GetName: ThisControl append s" W" append&crlf
                ch #append s"  value " append GetName: ThisControl append s" H" append&crlf
                ;

: writeglobals  ( -- )  \ write any global controls
                #controls 0= ?exit
                +crlf   \ force start on new line
                #controls 1+ 1
                do      i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        Global?: ThisControl
                        if      GetType: ThisControl
                                case
                                        TypeTextBox        of Spinner?: ThisControl
                                                              if   s" SpinnerControl "
                                                              else s" TextBox "
                                                              then                  endof
                                        TypeGroupBox       of s" GroupBox "         endof
                                        TypePushButton     of s" PushButton "       endof
                                        TypeCheckBox       of s" CheckBox "         endof
                                        TypeRadioButton    of Group?: ThisControl
                                                              if   s" GroupRadioButton "
                                                              else s" RadioButton "
                                                              then                  endof
                                        TypeBitmapButton   of s" BitmapButton "     endof
                                        TypeListBox        of s" ListBox "          endof
                                        TypeComboBox       of s" ComboBox "         endof
                                        TypeHorizScroll    of s" HorizScroll "      endof
                                        TypeVertScroll     of s" VertScroll "       endof
                                        TypeLabel          of s" Label "            endof
                                        TypeComboListBox   of s" ComboListBox "     endof
                                        TypeMultiLineBox   of s" MultiLineTextBox " endof
                                        TypeStaticBitmap   of s" StaticBitmap "     endof
                                        TypeMultiListBox   of s" MultiListBox "     endof
                                        TypeFileWindow     of s" FolderViewer "     endof
                                        TypeTabControl     of s" TabControl "       endof
                                        TypeGeneric        of write-child-params
                                                              s" "                  endof
                                        s"  \ UnKnown Control " ( default ) rot
                                endcase ?dup
                                if      append GetName: ThisControl append&crlf
                                else    drop
                                then
                        then
                loop    ;

: writecontrols { \ ctrl -- }  \ write local controls in form
                #controls 0= ?exit
                +crlf   \ force start on new line
                #controls 1+ 1
                do      i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        Global?: ThisControl not
                        if      GetType: ThisControl
                                case
                                        TypeTextBox        of Spinner?: ThisControl
                                                              if   s" SpinnerControl "
                                                              else s" TextBox "
                                                              then                  endof
                                        TypeGroupBox       of s" GroupBox "         endof
                                        TypePushButton     of s" PushButton "       endof
                                        TypeCheckBox       of s" CheckBox "         endof
                                        TypeRadioButton    of Group?: ThisControl
                                                              if   s" GroupRadioButton "
                                                              else s" RadioButton "
                                                              then                  endof

                                        TypeBitmapButton   of s" BitmapButton "     endof
                                        TypeListBox        of s" ListBox "          endof
                                        TypeComboBox       of s" ComboBox "         endof
                                        TypeHorizScroll    of s" HorizScroll "      endof
                                        TypeVertScroll     of s" VertScroll "       endof
                                        TypeLabel          of s" Label "            endof
                                        TypeComboListBox   of s" ComboListBox "     endof
                                        TypeMultiLineBox   of s" MultiLineTextBox " endof
                                        TypeStaticBitmap   of s" StaticBitmap "     endof
                                        TypeMultiListBox   of s" MultiListBox "     endof
                                        TypeFileWindow     of s" FolderViewer "     endof
                                        TypeTabControl     of s" TabControl "       endof
                                        TypeGeneric        of write-child-params
                                                              s" "                  endof
                                        s"  \ UnKnown Control " ( default ) rot
                                endcase ?dup
                                if      append GetName: ThisControl append&crlf
                                 else    drop
                                then
                        then
                loop    ;

: writeClassInit        ( -- )
                        +crlf
                        s" :M ClassInit:   ( -- )" append&crlf
                        2tabs
                        s" ClassInit: super" append&crlf
                        GetSuperClass: self CHILD-CLASS =
                        if      2tabs s" +dialoglist  \ allow handling of dialog messages" append&crlf
                                2tabs NextId #append s"  to id     \ set child id, changeable" append&crlf
                        then    2tabs
                        s" \ Insert your code here" append&crlf
                        2tabs
                        s" ;M" append&crlf ;

: ?write-child-style    ( -- )
                    GetSuperClass: self CHILD-CLASS <> ?exit
                    +crlf
                    s" :M Display:     ( -- ) \ unhide the child window" append&crlf
                    2tabs s" SW_SHOWNORMAL Show: self ;M" append&crlf
                    +crlf
                    s" :M Hide:        ( -- )   \ hide the...aughhh but you know that!" append&crlf
                    2tabs s" SW_HIDE Show: self ;M" append&crlf
                    ChildState: self 0= ?exit   \ not initially invisible
                    +crlf
                    s" :M WindowStyle:  ( -- style )" append&crlf
                    2tabs s" WS_CHILD " append&crlf
                    2tabs s" ;M" append&crlf
                    +crlf
                    s" :M Start:       ( Parent -- )" append&crlf
                    2tabs s" to parent" append&crlf
                    2tabs s" register-child-window drop" append&crlf
                    2tabs s" create-child-window to hWnd ;M " append&crlf ;

: writeWindowStyle      ( -- )
                        ?write-child-style
                        GetSuperClass: self DIALOG-CLASS <> ?exit   \ don't write style for child windows or mdi dialogs
                        +crlf
                        s" :M WindowStyle:  ( -- style )" append&crlf
                        2tabs s" WS_POPUPWINDOW WS_DLGFRAME or " append&crlf
                        2tabs s" ;M" append&crlf ;

: writeWindowTitle      ( - )
                        +crlf
                        s" :M WindowTitle: ( -- ztitle )" append&crlf
                        2tabs
                        [char] z cappend [char] " cappend 1 +spaces frmTitle count append [char] " cappend +crlf
                        2tabs
                        s" ;M" append&crlf ;

: writeStartSize        ( -- )
                        +crlf
                        s" :M StartSize:   ( -- width height )" append&crlf
                        2tabs
                        frmWidth #append frmHeight #append +crlf
                        2tabs s" ;M" append&crlf ;

: writeStartPos         ( -- )
                        GetSuperClass: self DIALOG-CLASS <> ?exit
                        +crlf
                        s" :M StartPos:    ( -- x y )" append&crlf
                        2tabs
                        SaveScreen?
                        if  s" XYPos"
                        else    frmXPos #append 1 +spaces frmYPos (.)
                        then    append&crlf
                        2tabs s" ;M" append&crlf ;

: writeWM_COMMAND       ( -- )
                        +crlf
                        GetSuperClass: self MDIDIALOG-CLASS =
                        if  s" :M ON_COMMAND:  ( h m w l -- res )" append&crlf
                        else    s" :M WM_COMMAND   ( h m w l -- res )" append&crlf
                        then
                        2tabs s" over LOWORD ( ID ) self   \ object address on stack" append&crlf
                        2tabs s" WMCommand-Func ?dup    \ must not be zero" append&crlf
                        2tabs s" if" append 1 +tabs s" execute" append&crlf
                        2tabs s" else" append 1 +tabs s" 2drop   \ drop ID and object address"
                        append&crlf 2tabs s" then" append 1 +tabs s" 0 ;M" append&crlf
                        \ write function to set OnWMCommand
                        +crlf s" :M SetCommand:  ( cfa -- )  \ set WMCommand function" append&crlf
                        2tabs s" to WMCommand-Func" append&crlf
                        2tabs s" ;M" append&crlf ;

: writeOnPaint          ( -- )
                        +crlf
                        s" :M On_Paint:    ( -- )" append&crlf
                        2tabs s" 0 0 GetSize: self Addr: FrmColor FillArea: dc" append&crlf
                        2tabs s" ;M" append&crlf ;

: writeOnSize           ( -- )
                        with-statusbar not ?exit
                        +crlf
                        s" :M On_Size:      ( -- )" append&crlf
                        2tabs s" Redraw: TheStatusBar" append&crlf
                        2tabs s" ;M" append&crlf ;

: writeClose            ( -- )
                        +crlf
                        s" :M Close:" append 1 +tabs s" ( -- )" append&crlf
                        \ we close any FolderViewer object, avoid head scratching bugs :-p
                        TypeFileWindow  get-array       \ do we have any?
                        if      #controls 1+ 1
                                do      i >Link#: ControlList
                                        Data@: ControlList to ThisControl
                                        GetType: ThisControl TypeFileWindow =
                                        if       2tabs s" Close: " append
                                                 GetName: ThisControl append&crlf
                                        then
                                loop
                        then    2tabs s" \ Insert your code here" append&crlf
                        2tabs s" Close: super" append&crlf
                        2tabs s" ;M" append&crlf ;

: writeOnDone   ( -- )
                +crlf
                s" :M On_Done:    ( -- )" append&crlf
                2tabs s" Delete: WinFont" append&crlf
                write-delete-fonts        \ delete any other fonts created
                GetSuperClass: self DIALOG-CLASS =
                if  SaveScreen?
                    if      2tabs s" originx originy 2to XYPos" append&crlf
                    then
                    \ write following code only if this is a modal form
                    modal
                    if      2tabs s" ParentWindow: self   \ if modal form re-enable parent" append&crlf
                            2tabs s" if   1 ParentWindow: self Call EnableWindow drop" append&crlf
                            2tabs s"      \ reset focus to parent if we have one"
                            append&crlf
                            2tabs s"      ParentWindow: self Call SetFocus drop"
                            append&crlf
                            2tabs s" then" append&crlf
                    then
                then    2tabs s" \ Insert your code here" append&crlf
                2tabs s" On_Done: super" append&crlf
                2tabs s" ;M" append&crlf ;

: writeParentWindow     ( -- )
        GetSuperClass: self DIALOG-CLASS <> ?exit
                +crlf
                s" \ if this form is a modal form a non-zero parent must be set" append&crlf
                s" :M ParentWindow:  ( -- hwndparent | 0 if no parent )" append&crlf
                2tabs s" hWndParent" append&crlf
                2tabs s" ;M" append&crlf
                \ write function for setting parent window
                +crlf s" :M SetParentWindow:  ( hwndparent -- ) \ set owner window" append&crlf
                2tabs s" to hWndParent" append&crlf
                2tabs s" ;M" append&crlf ;

: writeclosing  ( -- )
                +crlf
                s" ;Object" append&crlf ;

: writeWMNotify ( -- )
                TypeTabControl get-array 0= ?exit   \ we don't have a tabcontrol
                #controls 1+ 1
                do      i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        GetType: ThisControl TypeTabControl = ?leave
                loop    +crlf
                s" :M WM_NOTIFY  ( h m w l -- f )" append&crlf
                s" \ if this form has more than one tab control this handler will need to be modified"
                append&crlf
                2tabs s" Handle_Notify: " append GetName: ThisControl append&crlf
                2tabs s" ;M" append&crlf ;

: startpushbutton  ( -- )
                writecommoncode
                writefont
                \ write style only if not default
                Orientation: ThisControl dup 1 <>
                if      case
                                0       of      s" BS_LEFT"         endof
                                2       of      s" BS_RIGHT"        endof
                                s" BS_LEFT" rot
                        endcase writestyle
                else    drop
                then    writetext +crlf ;

: starttextbox  ( -- )
                \ write style only if not default
                GetType: ThisControl TypeMultiLineBox =
                Orientation: ThisControl 0<> and
                if      Orientation: ThisControl
                        case
                                1       of      s" ES_CENTER"       endof
                                2       of      s" ES_RIGHT"        endof
                                s" ES_LEFT" rot
                        endcase +crlf 2tabs append
                        s"  AddStyle: " append GetName: ThisControl append
                then    writecommoncode writefont +crlf
                GetType: ThisControl TypeTextBox = Spinner?: ThisControl and
                if       2tabs s" \ set default values, easily changed " append&crlf
                         2tabs s" 0 1024 SetRange: " append GetName: ThisControl append&crlf
                         2tabs s" 1 SetValue: " append GetName: ThisControl append&crlf
                then
                 ;

: startlabel    ( -- )
                writecommoncode
                writefont
                \ write style only if not default
                Orientation: ThisControl ?dup
                if      case
                                1       of      s" SS_CENTER"       endof
                                2       of      s" SS_RIGHT"        endof
                                s" SS_LEFT" rot
                        endcase writestyle
                then    writetext +crlf ;

: startlistbox  ( -- )
                writecommoncode
                writefont +crlf ;

: startcombobox ( -- )
                writecommoncode
                writefont +crlf ;

: startradiobutton  ( -- )
                writecommoncode
                writefont
                \ write style only if not default
                Orientation: ThisControl ?dup
                if      case
                                1       of      s" BS_CENTER"       endof
                                2       of      s" BS_RIGHT"        endof
                                3       of      s" BS_LEFTTEXT"     endof
                        endcase writestyle
                then    writetext +crlf ;

: startcheckbox ( -- )
                writecommoncode
                writefont
                \ write style only if not default
                Orientation: ThisControl ?dup
                if      case
                                1       of      s" BS_CENTER"       endof
                                2       of      s" BS_RIGHT"        endof
                                3       of      s" BS_LEFTTEXT"     endof
                        endcase writestyle
                then    writetext +crlf ;

: startgroupbox ( -- )
                writecommoncode
                writefont
                Orientation: ThisControl ?dup
                if      case
                                1       of      s" BS_CENTER"       endof
                                2       of      s" BS_RIGHT"        endof
                                s" BS_LEFT" rot
                        endcase writestyle
                then    writetext +crlf ;

: startbitmapbutton   ( -- )
                writecommoncode +crlf
                GetBitmap: ThisControl dup
                if      2tabs s"append append ( bitmap ) "append
                        s"  asciiz LoadBitmap SetImage: " append GetName: ThisControl append&crlf
                else    2drop
                then    GetToolTip: ThisControl ?dup
                if      2tabs s"append append ( tooltip ) "append
                        s"  ToolString: " append GetName: ThisControl append&crlf
                else    drop
                then	+crlf ;

: startstaticbitmap     ( -- ) \
\ for these controls image must be set before sizing control so image size
\ will be adjusted correctly
                +crlf
                2tabs s" self Start: " append GetName: ThisControl append&crlf
                GetBitmap: ThisControl dup
                if      2tabs s"append append ( bitmap ) "append
                        s"  asciiz LoadBitmap SetImage: " append GetName: ThisControl append
                        +crlf
                else    2drop
                then    2tabs Origin: ThisControl swap #append #append
                Dimensions: ThisControl swap #append #append
                s" Move: " append GetName: ThisControl append
                Group?: ThisControl
                if      +crlf 2tabs s" WS_GROUP +Style: " append
                        GetName: ThisControl append
                then    +crlf ;

: starthorizscroll  ( -- )
                writecommoncode +crlf ;

: startvertscroll  ( -- )
                writecommoncode +crlf ;

: startfilewindow  ( -- )
                writecommoncode +crlf ;

: starttabcontrol ( -- )
                writecommoncode
                writefont
                +crlf ;

: writeOnInit   ( -- )  \ create control objects in form
                +crlf
                s" :M On_Init:     ( -- )" append&crlf
                2tabs s"append s" MS Sans Serif" append "append
                s"  SetFaceName: WinFont" append&crlf
                2tabs s" 8 Width: WinFont" append&crlf
( create font ) 2tabs s" Create: WinFont " append&crlf
        +crlf
        2tabs s" \ set form color to system color" append&crlf
        2tabs s" COLOR_BTNFACE Call GetSysColor NewColor: FrmColor" append&crlf  +crlf
        with-statusbar
        if      2tabs s" self Start: TheStatusBar" append&crlf
\                2tabs s" SetSimple: TheStatusBar   \ can be changed if desired" append&crlf
                +crlf
        then    #controls 1+ 1
                ?do     i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        GetType: ThisControl
                        case
                                TypeTextBox        of starttextBox       endof
                                TypeGroupBox       of startGroupBox      endof
                                TypePushButton     of startPushButton    endof
                                TypeCheckBox       of startCheckBox      endof
                                TypeRadioButton    of startRadioButton   endof
                                TypeBitmapButton   of startBitmapButton  endof
                                TypeListBox        of startListBox       endof
                                TypeComboBox       of startComboBox      endof
                                TypeHorizScroll    of startHorizScroll   endof
                                TypeVertScroll     of startVertScroll    endof
                                TypeLabel          of startLabel         endof
                                TypeStaticBitmap   of StartStaticBitmap  endof
                                TypeComboListBox   of startComboBox      endof
                                TypeMultiLineBox   of startTextBox       endof
                                TypeMultiListBox   of startListBox       endof
                                TypeFileWindow     of startfilewindow    endof
                                TypeTabControl     of starttabcontrol    endof
                        endcase
                loop    GetSuperClass: self DIALOG-CLASS =
                if  modal
                    if      +crlf 2tabs s" ParentWindow: self   \ if this is a modal form disable parent" append&crlf
                            2tabs s" if   0 ParentWindow: self Call EnableWindow drop then" append
                    then
                then    +crlf 2tabs s" ;M" append&crlf ;

:M Validate:    ( -- )  \ check form and controls for spaces in names
\ in case they were loaded with such
               frmname count -trailing bl scan nip
               s" Spaces not allowed in form name!" ?Errorbox
               #controls 0= ?exitm
               #controls 1+ 1
               do       i >Link#: ControlList
                        Data@: ControlList to ThisControl
                        GetName: ThisControl -trailing bl scan nip
                        if       join$(  s" ( "
					 GetName: ThisControl
					 s"  ) spaces not allowed in control name!"
                                 )join$ true swap count ?Errorbox
                        then
               loop    ;M

: WritetoBuffer ( -- )
                Validate: self
                writeneeds
                writeglobals
                writeopening
                writecontrols
                writeClassInit
                writeWindowStyle
                writeParentWindow
                writeWindowTitle
                writeStartSize
                writeStartPos
                writeWMNotify
                writeClose
                writeOnInit
                writeWM_COMMAND
                writeOnPaint
                writeOnSize
                WriteOnDone
                writeClosing ;

:M GetBuffer:   ( -- addr len )
                initbuffer
                WriteToBuffer
                TheBuffer
                ;M

:M UninitedBuffer: ( -- addr len )
                   WriteToBuffer TheBuffer ;M

:M TestChildDialog: ( -- addr len )
        initbuffer
        s" :Object TestChildForm    <Super Window" append&crlf
        +crlf
        s" :M On_Init:  ( -- )" append&crlf
        2tabs s" self Start: " append FormName: self count 2dup 2>r append&crlf
        2tabs s" 0 0 StartSize: " append 2r@ append s"  Move: " append 2r@ append&crlf
        2tabs s" ;M" append&crlf
        +crlf
        s" :M WindowTitle: ( -- zstring )" append&crlf
        2tabs 'z' cappend "append s"  Test Window for " append 2r@ append "append
        s"  ;M" append&crlf
        +crlf
        s" :M StartSize:  ( -- )" append&crlf
        2tabs s" StartSize: " append 2r> append s"  ;M" append&crlf
        +crlf
        s" ;Object" append&crlf
        s" Start: TestChildForm" append&crlf ;M

:M TestMDIDialog: ( -- addr len )
        initbuffer
        s" MENUBAR MDIMenu" append&crlf
            s" POPUP " append "append s" &File" append "append +crlf
        s" MENUITEM " append "append s" E&xit  \tAlt-F4" append "append  s"  ;" append&crlf
            s" POPUP " append "append s" &Window" append "append +crlf
        s" ENDBAR" append&crlf
        s" :Object Frame        <Super MDIFrameWindow" append&crlf
        +crlf
                s" :M ClassInit:   ( -- )" append&crlf
                s" ClassInit: super" append&crlf
                s" MDIMenu to CurrentMenu" append&crlf
                s" ;M" append&crlf
        s" :M On_Size:  ( -- )" append&crlf
        2tabs s" 0 0 Width Height Move: MDIClient ;M" append&crlf
        +crlf
        s" ;Object" append&crlf
        s" Start: Frame" append&crlf
        s" MDICLientWindow: Frame Start: " append FormName: self count append&crlf ;M

: textfile      ( -- addr cnt ) \ return text (.frm) file name
                new$ >r formname count "minus-ext" r@  place
                s" .frm" r@ +place r> count ;

:M TextFile:    ( addr cnt -- )
                textfile
                ;M

: OverWrite?    ( \ temp$ -- f )
                z" This form file already exist, overwrite?"
                z" Warning!" MB_YESNO MB_ICONQUESTION or
                MessageBox: TheMainWindow IDYES = ;

: WriteForm     { flag \ file$ -- } \ flag is true if showing messages
                max-path LocalAlloc: file$
                IsNewForm?
                if      SaveIt?
                        if      SaveForm                  \ save it first
                        else    exit
                        then
                then    textfile file$ place             \ add new extension
                file$ count file-status nip 0=          \ already exist?
                if      SetFocus: self OverWrite? 0= ?exit
                then    GetBuffer: self nip    \ do we have info?
                if      file$ count SetName: FormFile
                        Create: FormFile ?exit
                        TheBuffer Write: FormFile
                        Close: FormFile         \ close first then
                        ?exit                   \ exit on error
                        flag 0= ?exit
                        join$(  s" File "
				file$ count
				s"  has been successfully compiled!"
                        )join$ 1+
                        z" Yes!"                   \ title
                        MB_OK                          \ style
                        MessageBox: TheMainWindow
                else    flag s" Nothing compiled!" ?MessageBox
                then    ;

:M CompileForm: ( -- )
                true WriteForm
                ;M

:M Compile:     ( -- )
                false WriteForm ;M

;Class

: NewForm (  -- addr )
   New> Form dup to ThisForm ;

: (AddNewForm)  (  --  )
                FormList 0=             \ if we don't have one
                if      New> Linked-List to FormList    \ create it
                then    Data@: FormList         \ an entry of zero means it's empty
                if      AddLink: FormList
                then    NewForm Data!: FormList
                1 +to formcount ;

: AddNewForm    ( -- )
                ['] (AddNewForm) catch ExitOnError ;

: .forms        ( -- )
                #forms 0= ?exit
                Link#: FormList >r
                cr ." FormList= " FormList u.
                #forms 1+ 1
                do      i >Link#: FormList
                        cr i . 8 spaces Data@: FormList dup u.
                        8 spaces
                        ?dup if FormName: [ ] count type then
                        cr
                loop    ." ActiveForm = " ActiveForm u. cr
                r> >Link#: FormList ;

: DisposeForms   ( -- )
                #Forms 0= ?exit         \ no forms open
                >FirstLink: FormList            \ start from the beginning
                #Forms 0                                        \ for each open form
                ?do     Data@: FormList dup to ThisForm
                        if      GetHandle: ThisForm             \ is it open?
                                if      SetFocus: ThisForm
                                        Close: ThisForm
                                then    ThisForm dispose        \ release memory
                                0 Data!: FormList               \ mark as empty
                                DeleteLink: FormList    \ and delete
                        then    >NextLink: FormList             \ next form
                loop    FormList Dispose 0 to FormList ;

\s
