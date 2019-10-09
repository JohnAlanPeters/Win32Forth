\ $Id: toolbar.f,v 1.11 2013/12/17 19:25:23 georgeahubert Exp $

\   ToolBar.F    Customizable toolbar class                by Michael Hillerström
\                                                      michael-hillerstrom@usa.net
\
\
\                 This Toolbar class hooks into Windows own library class.
\                 By doing this, we automatically get access to toolbar
\                 customization which many applications offer...
\                 Well, why not try it out?
\
\                 Please note that this code needs a new version of WINCON.DLL
\                 (dated September 15, 1997 or later).
\
\                 An example is provided in dems\ToolbarDemo.f...
\
\
\                 Any comments/suggestions to:    michael-hillerstrom@usa.net
\
\
\
\         Change log:
\
\                 November 23rd, 2006 - 18:45 - Rod
\                 Changed On_BeginAdjust: to return false so that a toolbar is now restored
\                 correctly when using a manifest for XP Visual Styles (ComCtl32.dll version 6)
\
\                 September 12th, 2006 - 20:47 - gah
\                 Added \in-system-ok to account for ?pairs being moved to system space
\
\                 September 25th, 2005 - 18:59 - Rod
\                 Changed to use Control rather than Child-Window
\
\                 September 22nd, 2003 - 16:11 - EAB
\                 Corrected bug in On_GetButtonInfo: that was causing incorrect tooltips
\                 to be displayed when buttons were non sequential.
\
\                 September 21st, 2003 - 22:52 - EAB
\                 Corrected bug in GetText to allow correct operation with non consecutive
\                 buttons
\
\                 February 6th, 1998 - 23:09 MIH
\                 Cured a mistake in ;ToolBarTable.  It left a value on stack if
\                 no ToolBarTableExtraButtons: had been issued!
\
\                 January 14th, 1998 - 22:16 MIH
\                 Finally, I cracked it!  Customizable Toolbars are now truely
\                 customizable!  Actually, it was quite simple.  We should not end
\                 our registry sub-key specification with a backslash, i.e.
\
\                   z" Software\MyApp" z" TestToolBarLayout" SetRegistryKey: self
\
\                 will be correct.  If we do include a trailing backslash, writing
\                 toolbar configuration data works, but we cannot read it...  There
\                 you have yet another peculiarity of Windows95/NT!!
\                 While I was at it I fixed some minor glitches.  Enjoy!
\
\                 November 23rd, 1997 - 21:59 MIH
\                 Added the line:   WinLibrary COMMCTRL.DLL   to this source.
\
\                 September 20th, 1997 - 14:51 MIH
\                 I've found that the SaveRestore: correctly saves the current button
\                 layout in the registry but it doesn't do any good for restoring the
\                 last saved layout...  It doesn't show!  Suggestions anyone??
\
\                 September 16th, 1997 - 21:42 MIH
\                 Removed reference to COMMCTRL.F as Tom Zimmer has released an
\                 extended WINCON.DLL.  Thanks, Tom!
\
\                 August 31st, 1997 - 20:10 MIH
\                 First attempt...
\                 Need to convince Tom Zimmer to include #define's from COMMCTRL.H
\                 in WINCON.DLL.  For the time beeing, we'll have to cope with my
\                 FORTH constants in COMMCTRL.F.

cr .( Loading Customizable ToolBar Class...)

anew -ToolBar.F
internal
external

WinLibrary COMCTL32.DLL         \ Make sure that CommCtl32.dll is loaded...

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Toolbar specification...
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: :ToolBarTable ( -- addr1 addr2 12 )
                create  here 0 ,                \ Table of button positions (cust. table)
                             0 ,                \ Number of extra buttons
                        here 0 ,                \ Number of buttons
                nostack
                12
                does> ( -- addr ) 3 cells+
                ;

in-system

: ;ToolBarTable ( addr1 addr2 12 -- )
                12 ?pairs
                here rot !                      \ Resolve address of cust. table
                here 0 ,                        \ no of buttons in cust. table
                swap lcount  0                  \ For all entries in button data
                do      i 20 ( /tbb) * over +  cell+ @  \ Is it a button?
                        if i ,                  \ Save index of button...
                           over 1 swap +!       \ one more button in cust. table
                        then
                loop
                cell- cell- dup @ 0=            \ No extra buttons?
                if      dup cell+ @ swap !      \ Point to end of cust. table
                else    drop
                then
                drop
                checkstack
                align
                ;

: ToolBarTableExtraButtons: ( addr 12 -- addr 12 )
                dup 12 ?pairs
                over dup @ swap cell- !
                ;

: ToolBarButton, ( addr 12 bidx id state style txtno -- addr 12 )
                2>r  rot ( bidx)   ,  swap ( id) ,  ( state) c,
                2r> swap ( style) c, 0 w,      0 ,  ( txtno)  ,
                dup 12 ?pairs  over 1 swap +!
                ;

: SeparatorButton, ( addr 12 -- addr 12 )
                0 0 0 TBSTYLE_SEP 0 ToolBarButton,
                ;

: sSeparatorButton, ( addr 12 buttonwidth -- addr 12 )  \ added 2004-04-18, EAB
                0 0  TBSTYLE_SEP 0 ToolBarButton,
                ;

in-previous

: GetButtonData ( buttontable buttonindex  -- addr )
                over
                if      over cell- cell- cell- @ lcount         \ establish index
                        rot dup rot >=
                        if      3drop  -1                       \ Ups! out of bounds!
                        else    cells+ @                        \ Index found...
                                20 ( /tbb) *   +                \ ...and address found
                        then
                else    2drop -1
                then
                ;

: #DefaultButtons ( addr -- n )
                cell- cell- @
                ;



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Toolbar string specification (text underneath bitmaps)...
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: :ToolStrings  ( -- addr 13 )
                create here 0 ,
                nostack
                13
                does> ( -- addr ) cell+
                ;

in-system

: ;ToolStrings  ( addr 13 -- )
                13 ?pairs
                0 , align
                here over !                     \ Resolve address of address table
                here >r 0 ,                     \ no of strings in address table
                cell+ 1-
                begin   1+ dup ,
                        1 r@ +!
                        1000 0 scan 1000 =
                until
                drop  r>drop
                checkstack
                align
                ;

: ts,"          ( 13 -<string">- 13 )
                dup 13 ?pairs
                state @
                if      true abort" Illegal use of tool string compiler"
                else    [char] " word count
                        here over allot  swap cmove   0 c,
                then ; immediate

in-previous

: n->'ToolString ( stringtable stringindex  -- addr | NULL )
                over
                if
                        swap cell- @ lcount  rot dup rot >=     \ Establish index
                        if      3drop  NULL                     \ Ups! out of bounds!
                        else    cells+ @                        \ Address found...
                        then
                else    2drop NULL
                then
                ;

:Class  Win32ToolBar    <super  Control
\ *G Toolbar class hooks into Windows own library class.
\ ** Automatically provides access to toolbar customization.

\ *P The toolbar itself can have a combination of the following styles:
\ **
\ ** CCS_ADJUSTABLE      Enables a toolbar's built-in customization features, which
\ **                     allow you to drag a button to a new position or to remove a
\ **                     button by dragging it off the toolbar. In addition, you can
\ **                     double-click the toolbar to activate a customize Toolbar
\ **                     dialog box, allowing you to add, delete, and rearrange
\ **                     toolbar buttons.
\ **
\ ** CCS_BOTTOM          Causes the control to position itself at the bottom of the
\ **                     parent window's client area.
\ **
\ ** CCS_NODIVIDER       Prevents a two-pixel highlight from being drawn at the top
\ **                     of the control.
\ **
\ ** CCS_NOMOVEY         Causes the control to resize and move itself horizontally,
\ **                     but not vertically, in response to a WM_SIZE message. If
\ **                     CCS_NORESIZE is used, this style does not apply.
\ **
\ ** CCS_NOPARENTALIGN   Prevents the control from automatically moving to the top
\ **                     or bottom of the parent window. Instead, the control keeps
\ **                     its position within the parent window despite changes to
\ **                     the size of the parent. If CCS_TOP or CCS_BOTTOM is also
\ **                     used, the height is adjusted to the default, but the
\ **                     position and width remain unchanged.
\ **
\ ** CCS_NORESIZE        Prevents the control from using the default width and
\ **                     height when setting its initial size or a new size.
\ **                     Instead, the control uses the width and height specified in
\ **                     the request for creation or sizing.
\ **
\ ** CCS_TOP             Causes the control to position itself at the top of the
\ **                     parent window's client area and sets the width to be the
\ **                     same as the parent window's width. Toolbars have this style
\ **                     by default.
\ **
\ **
\ ** TBSTYLE_ALTDRAG     Allows you to change the position of a toolbar button by
\ **                     dragging it while holding down the ALT key. If this style
\ **                     is not specified, you must hold down the SHIFT key while
\ **                     dragging a button. Note that the CCS_ADJUSTABLE style must
\ **                     be specified to enable toolbar buttons to be dragged.
\ **
\ ** TBSTYLE_TOOLTIPS    Creates a tooltip control which can display descriptive
\ **                     text for the buttons in the toolbar.
\ **
\ ** TBSTYLE_WRAPABLE    Creates a toolbar that can have multiple lines of buttons.
\ **
\ **
\ ** A button in a toolbar can have a combination of the following styles:
\ **
\ ** TBSTYLE_BUTTON      Creates a standard push button.
\ **
\ ** TBSTYLE_CHECK       Creates a button that toggles between the pressed and not
\ **                     pressed states each time the user clicks it. Equivalent to
\ **                     a checkbox in a dialog.
\ **
\ ** TBSTYLE_CHECKGROUP  Creates a check button that stays pressed until another
\ **                     button in the group is pressed.  Equivalent to (grouped)
\ **                     radiobuttons in dialogs.
\ **
\ ** TBSTYLE_GROUP       Creates a button that stays pressed until another button in
\ **                     the group is pressed.
\ **
\ ** TBSTYLE_SEP         Creates a separator, providing a small gap between button
\ **                     groups.
\ **
\ **
\ ** A toolbar button can have a combination of the following states:
\ **
\ ** TBSTATE_CHECKED     The button has the TBSTYLE_CHECKED style and is being
\ **                     pressed.
\ **
\ ** TBSTATE_ENABLED     The button accepts user input. A button not having this
\ **                     state does not accept user input and is grayed.
\ **
\ ** TBSTATE_HIDDEN      The button is not visible and cannot receive user input.
\ **
\ ** TBSTATE_INDETERMINATE  The button is grayed.
\ **
\ ** TBSTATE_PRESSED     The button is being pressed.
\ **
\ ** TBSTATE_WRAP        A line break follows the button. The button must also have
\ **                     the TBSTATE_ENABLED state.
\ **
\ **
\ ** In your application you can override all On_ methods.  When overriding the methods
\ ** WindowStyle: and ClassInit: you should always call super method first to assure
\ ** correct behaviour.  Last part of this file contains a small example.





\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Win32Toolbar, a ToolbarWindow32 container class...
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


        int ButtonTable
        int ButtonStrings
        int ToolTips

\ -------------------- Standard Tool-bar Structures --------------------

    Record: tbb
        int iBitmap
        int idCommand
        BYTE fsState
        BYTE fsStyle
      2 BYTES reserved
        int dwData
        int iString
   ;RecordSize: /tbb


    Record: tbab
        int hInst
        int nID
    ;Record


    Record: tbsr
        int hkr
        int pszSubKey
        int pszValueName
    ;Record

    Rectangle   ButtonRect

: register-struct-size ( -- )
                \ Register tbb structure size
                0  /tbb  TB_BUTTONSTRUCTSIZE hwnd Call SendMessage drop
                ;

:M ClassInit:   ( -- )
                ClassInit: super

                HKEY_CURRENT_USER to hkr
                NULL              to pszSubKey
                NULL              to pszValueName
                NULL              to ButtonTable
                NULL              to ButtonStrings
                NULL              to ToolTips
                ;M

:M WindowStyle: ( -- style )
                WS_CHILD
                WS_VISIBLE or
                ;M

:M Start:       ( Parent -- )
                hWnd
                if      drop
                        SW_SHOWNOACTIVATE Show: self
                else
                        to Parent
                        z" ToolbarWindow32" Create-Control
                        register-struct-size

                        ButtonStrings                   \ Add button strings?
                        if      ButtonStrings AddButtonStrings: [ self ] drop
                        then

                        ButtonTable                     \ Add buttons?
                        if      ButtonTable dup #DefaultButtons AddButtons: [ self ] drop
                        then

                        false SaveRestore: [ self ]     \ Read stored layout (if any)
                then
                ;M

:M IsButtonTable: ( buttontable -- )
                to ButtonTable
                ;M

:M IsButtonStrings: ( texttable -- )
                to ButtonStrings
                ;M

:M IsToolTips:  ( texttable -- )
                to ToolTips
                ;M

:M AddBitmaps:  ( hInst nID n -- n' )
                >r  to nID  to hInst
                tbab  r> TB_ADDBITMAP  hwnd Call SendMessage
                ;M

:M AddButtonStrings: ( z" -- n )
                0 TB_ADDSTRINGA  hwnd Call SendMessage
                ;M

:M AddButtons:  ( 'button_table noButtons -- n )
                TB_ADDBUTTONS  hwnd Call SendMessage
                ;M

:M AutoSize:    ( -- )
                0 0 TB_AUTOSIZE hwnd Call SendMessage drop
                ;M

:M Customize:   ( -- )          \ Programmatically force customization
                0 0 TB_CUSTOMIZE hwnd Call SendMessage drop
                ;M

:M SetRegistryKey: ( pszSubKey pszValueName -- )
                to pszValueName
                to pszSubKey
                ;M

:M SaveRestore: ( f -- )       \ f = true, Save,  f = false, Restore.
                               \ Perform operation if Registry keys have been
                               \ properly initialized.
                pszSubKey 0= pszValueName 0= or
                if      drop
                else    tbsr swap TB_SAVERESTOREA hwnd Call SendMessage drop
                then
                ;M

:M Handle_Notify: { w l \ code id index -- f }
                l             to l
                l    cell+ @  to id
                l 2 cells+ @  to code
                l 3 cells+ @  to index
                code
                case
                   TBN_QUERYDELETE    of index  On_QueryDelete:   [ self ] endof
                   TBN_QUERYINSERT    of index  On_QueryInsert:   [ self ] endof
                   TBN_GETBUTTONINFOA of l 4 cells+  index
                                                On_GetButtonInfo: [ self ] endof
                   TBN_BEGINDRAG      of index  On_BeginDrag:     [ self ] endof
                   TBN_ENDDRAG        of index  On_EndDrag:       [ self ] endof
                   TBN_BEGINADJUST    of        On_BeginAdjust:   [ self ] endof
                   TBN_ENDADJUST      of        On_EndAdjust:     [ self ] endof
                   TBN_RESET          of        On_Reset:         [ self ] endof
                   TBN_TOOLBARCHANGE  of        On_ToolBarChange: [ self ] endof
                   TBN_CUSTHELP       of        On_CustHelp:      [ self ] endof
                   TTN_NEEDTEXT       of l 3 cells+  id
                                                On_NeedText:      [ self ] endof
                          false swap ( default)
                endcase
                ;M

:M SetParent:   ( hWndParent -- )
                0 swap TB_SETPARENT             hwnd Call SendMessage drop
                ;M

:M CommandToIndex: ( id -- buttonindex )
                0 swap TB_COMMANDTOINDEX        hwnd Call SendMessage
                ;M

:M GetRows:     ( -- n )
                0 0    TB_GETROWS               hwnd Call SendMessage
                ;M

:M GetButtonCount: (  -- n )
                0 0    TB_BUTTONCOUNT           hwnd Call SendMessage
                ;M

:M GetToolTips: (  -- hToolTip )
                0 0    TB_GETTOOLTIPS           hwnd Call SendMessage
                ;M

:M GetButtonRect: ( buttonindex -- left top right bottom )
                ButtonRect
                swap   TB_GETITEMRECT           hwnd Call SendMessage ?win-error
                ButtonRect.left  ButtonRect.top
                ButtonRect.right ButtonRect.bottom
                ;M

:M ValidID:     ( id -- f ) \ return true if ButtonID is valid
                CommandToIndex: self 0 >= ;M

:M EnableButton: ( f id -- )                    \ f=true, enable;  f=false, disable
                dup ValidID: self
                if   TB_ENABLEBUTTON hwnd Call SendMessage ?win-error
                else 2drop
                then ;M

:M IsButtonEnabled: ( id -- f )                 \ f=true, enabled;  f=false, disabled
                dup ValidID: self
                if   0 swap TB_ISBUTTONENABLED hwnd Call SendMessage
                else drop false
                then ;M

:M HideButton: ( f id -- )                      \ f=true, hide;  f=false, show
                dup ValidID: self
                if   TB_HIDEBUTTON hwnd Call SendMessage ?win-error
                else 2drop
                then ;M

:M IsButtonHidden: ( id -- f )                  \ f=true, hidden;  f=false, shown
                dup ValidID: self
                if   0 swap TB_ISBUTTONHIDDEN hwnd Call SendMessage
                else drop false
                then ;M

:M CheckButton: ( f id -- )                     \ f=true, check;  f=false, uncheck
                dup ValidID: self
                if   TB_CHECKBUTTON hwnd Call SendMessage ?win-error
                else 2drop
                then ;M

:M IsButtonChecked: ( id -- f )                 \ f=true, checked;  f=false, unchecked
                dup ValidID: self
                if  0 swap TB_ISBUTTONCHECKED hwnd Call SendMessage
                else drop false
                then ;M

:M PressButton: ( f id -- )                     \ f=true, press;  f=false, don't press
                dup ValidID: self
                if  TB_PRESSBUTTON hwnd Call SendMessage ?win-error
                else 2drop
                then ;M

:M IsButtonPressed: ( id -- f )                 \ f=true, pressed;  f=false, not pressed
                dup ValidID: self
                if  0 swap TB_ISBUTTONPRESSED hwnd Call SendMessage
                else drop false
                then ;M

:M IndeterminateButton: ( f id -- )             \ f=true, indeterminate;  f=false, don't
                dup ValidID: self
                if   TB_INDETERMINATE hwnd Call SendMessage ?win-error
                else 2drop
                then ;M

:M IsButtonIndeterminate: ( id -- f )           \ f=true, indeterminate;  f=false, no
                dup ValidID: self
                if   0 swap TB_ISBUTTONINDETERMINATE hwnd Call SendMessage
                else drop false
                then ;M


\ --------------------- Overridable methods ----------------------

:M On_QueryDelete: ( buttonindex -- f )         \ f = true, ok to remove button
                drop true
                ;M

:M On_QueryInsert: ( buttonindex -- f )         \ f = true, ok to insert to the
                drop true                       \ left of the button
                ;M

:M On_GetButtonInfo: ( addr buttonindex -- f )  \ f = true, tbb at addr has been
                2dup                            \ filled with useful data
                ButtonTable swap GetButtonData  dup -1 <>
                if      dup>r  swap /tbb move
                        drop ToolTips  r> 16 + @ n->'ToolString
                        swap /tbb + dup>r cell+ @
                        over zcount nip 1+ r> @ min cmove
                        true
                else    3drop false
                then
                ;M

:M On_BeginDrag: ( buttonindex -- f )           \ User starts dragging button
                drop false
                ;M

:M On_EndDrag:  ( buttonindex -- f )            \ Button dragging is complete
                drop false
                ;M

:M On_ToolBarChange: ( -- f )                   \ User has changed toolbar
                false
                ;M

:M On_BeginAdjust: ( -- f )                     \ Beginning customization
                true SaveRestore: self
                false   \ ComCtl32.dll version 6 for XP requires false here
                ;M      \ otherwise SaveRestore: restores an empty toolbar

:M On_EndAdjust: ( -- f )                       \ User done with customization
                true SaveRestore: self
                true
                ;M

:M On_Reset:    ( -- f )                        \ User regrets (current) customization
                false SaveRestore: self
                true
                ;M

:M On_CustHelp: ( -- f )                        \ Request for customization help
                true
                ;M

: GetText       { bid \ ndx -- addr }
                0 to ndx        \ default to not found
                ButtonTable ?dup
                if      dup cell- @ 0               \ get number of buttons
                        ?do     dup cell+ @ bid =   \ compare IDs
                                if      16 + @ ToolTips swap n->'ToolString
                                        to ndx leave    \ we found it so stop searching
                                else    20 +        \ search next button structure
                                then
                        loop    ndx
                else    NULL
                then    ;

:M GetText:     ( id -- addr )
                GetText
                ;M

:M On_NeedText: ( addr id -- )                  \ Request for tool-tip text...
                GetText                         \ put address of text at addr
                swap !                          \ (= lpszText field of ToolTipText)
                ;M

:M ToolTipHandle: ( -- hwnd | 0 )
                  hwnd
                  if    0 0 TB_GETTOOLTIPS SendMessage:Self
                  else  0
                  then  ;M

;Class

module


\s

