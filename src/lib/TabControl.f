\ $Id: TabControl.f,v 1.10 2013/11/28 20:51:55 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -TabControl.f

WinLibrary COMCTL32.DLL

cr .( Loading TabControl Class...)

INTERNAL
EXTERNAL


\ ------------------------------------------------------------------------
\ *W <a name="TabControl"></a>
\ *S TabControl class
\ ------------------------------------------------------------------------
:Class TabControl	<Super Control
\ *G Tab control.
\ *P A tab control is analogous to the dividers in a notebook or the labels in a
\ ** file cabinet. By using a tab control, an application can define multiple pages
\ ** for the same area of a window or dialog box. Each page consists of a certain
\ ** type of information or a group of controls that the application displays when
\ ** the user selects the corresponding tab.

Record: tc_Item
\ *G The TCITEM struct.
    INT mask         \ value specifying which members to retrieve or set
    INT lpReserved1  \ reserved; do not use
    INT lpReserved2  \ reserved; do not use
    int pszText      \ pointer to string containing tab text
    int cchTextMax   \ size of buffer pointed to by the pszText member
    int iImage       \ index to tab control's image
    int lParam       \ application-defined data associated with tab
;Recordsize:  /tc_item

int selchange-func   \ selection change function
int selchanging-func \ selection changing function

:M IsMask:      ( n -- )
\ *G Set the \i mask \d member of the TCITEM struct. Possible values are:
\ *L
\ *| TCIF_TEXT       | The pszText member is valid. |
\ *| TCIF_IMAGE      | The iImage member is valid. |
\ *| TCIF_PARAM      | The lParam member is valid. |
\ *| TCIF_RTLREADING | Displays the text of pszText using right-to-left reading order on Hebrew or Arabic systems. |
                to mask ;M

:M Mask:        ( -- n )
\ *G Get the \i mask \d member of the TCITEM struct.
                mask ;M

:M IsPszText:   ( addr -- )
\ *G Set the \i mask \d member of the TCITEM struct.
                to pszText ;M

:M PszText:     ( -- n )
\ *G Get the \i pszText \d member of the TCITEM struct.
                pszText ;M

:M IscchTextMax: ( n -- )
\ *G Set the \i pszText \d member of the TCITEM struct.
		to cchTextMax ;M

:M cchTextMax:  ( -- n )
\ *G Get the \i cchTextmax \d member of the TCITEM struct.
                cchTextmax ;M

:M IsiImage:    ( n -- )
\ *G Set the \i iImage \d member of the TCITEM struct.
                to iImage ;M

:M iImage:      ( -- n )
\ *G Get the \i iImage \d member of the TCITEM struct.
                iImage ;M

:M IsLparam:    ( n -- )
\ *G Set the \i lparam \d member of the TCITEM struct.
                to lparam ;M

:M LParam:      ( -- n )
\ *G Get the \i lparam \d member of the TCITEM struct.
                lparam ;M

\ You can cause the tabs to look like buttons by specifying the TCS_BUTTONS style. Tabs in this type of tab control
\ should serve the same function as button controls; that is, clicking a tab should carry out a command instead of
\ displaying a page. Because the display area in a button tab control is typically not used, no border is drawn
\ around it.
\
\ You can cause a tab to receive the input focus when clicked by specifying the TCS_FOCUSONBUTTONDOWN style. This
\ style is typically used only with the TCS_BUTTONS style. You can specify that a tab never receives the input
\ focus by using the TCS_FOCUSNEVER style.
\
\ By default, a tab control displays only one row of tabs. If not all tabs can be shown at once, the tab control
\ displays an up-down control so that the user can scroll additional tabs into view.  You can cause a tab control
\ to display multiple rows of tabs, if necessary, by specifying the TCS_MULTILINE style. In this way, all tabs can
\ be displayed at once. The tabs are left-aligned within each row unless you specify the TCS_RIGHTJUSTIFY style.
\ In this case, the width of each tab is increased so that each row of tabs fills the entire width of the tab control.
\
\ A tab control automatically sizes each tab to fit its icon, if any, and its label. To give all tabs the same width,
\ you can specify the TCS_FIXEDWIDTH style. The control sizes all the tabs to fit the widest label, or you can assign
\ a specific width and height by using the TCM_SETITEMSIZE message. Within each tab, the control centers the icon and
\ label with the icon to the left of the label. You can force the icon to the left, leaving the label centered, by
\ specifying the TCS_FORCEICONLEFT style. You can left-align both the icon and label by using the TCS_FORCELABELLEFT
\ style. You cannot use the TCS_FIXEDWIDTH style with the TCS_RIGHTJUSTIFY style.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: TCS_FOCUSONBUTTONDOWN.
	WindowStyle: Super TCS_FOCUSONBUTTONDOWN or ;M

\ :M AddStyle:    ( n -- )
\ *G Set any additional style of the control. Must be done before the control
\ ** is created. Possible values are:
\ *L
\ *| TCS_BOTTOM | Tabs appear at the bottom of the control. This value equals TCS_RIGHT. |
\ *| TCS_BUTTONS | Tabs appear as buttons, and no border is drawn around the display area. |
\ *| TCS_FIXEDWIDTH | All tabs are the same width. This style cannot be combined with the TCS_RIGHTJUSTIFY style. |
\ *| TCS_FLATBUTTONS | Selected tabs appear as being indented into the background while other tabs appear as being on the same plane as the background. This style only affects tab controls with the TCS_BUTTONS style. |
\ *| TCS_FOCUSNEVER | The tab control does not receive the input focus when clicked. |
\ *| TCS_FOCUSONBUTTONDOWN | The tab control receives the input focus when clicked. |
\ *| TCS_FORCEICONLEFT | Icons are aligned with the left edge of each fixed-width tab. This style can only be used with the TCS_FIXEDWIDTH style. |
\ *| TCS_FORCELABELLEFT | Labels are aligned with the left edge of each fixed-width tab; that is, the label is displayed immediately to the right of the icon instead of being centered. |
\ *| TCS_HOTTRACK | Items under the pointer are automatically highlighted. You can check whether or not hot tracking is enabled by calling SystemParametersInfo. |
\ *| TCS_MULTILINE | Multiple rows of tabs are displayed, if necessary, so all tabs are visible at once. |
\ *| TCS_MULTISELECT | Multiple tabs can be selected by holding down CTRL when clicking. This style must be used with the TCS_BUTTONS style. |
\ *| TCS_OWNERDRAWFIXED | The parent window is responsible for drawing tabs. |
\ *| TCS_RAGGEDRIGHT | Rows of tabs will not be stretched to fill the entire width of the control. This style is the default. |
\ *| TCS_RIGHT | Tabs appear vertically on the right side of controls that use the TCS_VERTICAL style. This value equals TCS_BOTTOM. |
\ *| TCS_RIGHTJUSTIFY | The width of each tab is increased, if necessary, so that each row of tabs fills the entire width of the tab control. |
\ *| TCS_SCROLLOPPOSITE | Unneeded tabs scroll to the opposite side of the control when a tab is selected. |
\ *| TCS_SINGLELINE | Only one row of tabs is displayed. The user can scroll to see more tabs, if necessary. This style is the default. |
\ *| TCS_TABS | Tabs appear as tabs, and a border is drawn around the display area. This style is the default. |
\ *| TCS_TOOLTIPS | The tab control has a tooltip control associated with it. |
\ *| TCS_VERTICAL | Tabs appear at the left side of the control, with tab text displayed vertically. This style is valid only when used with the TCS_MULTILINE style. To make tabs appear on the right side of the control, also use the TCS_RIGHT style. |
\        to style ;M

:M TC_Item: 	( -- addr )
\ *G Get the address of the TCITEM struct.
        tc_item ;M

:M InsertTab:   ( index -- )
\ *G Inserts a new tab into the tab control.
\ *P \i mask \d and other members of the TCITEM struct must be set.
        tc_item swap TCM_INSERTITEM SendMessage:SelfDrop ;M

:M GetTabInfo:  ( index -- )
\ *G Retrieves information about a tab in the tab control.
        tc_item swap TCM_GETITEM SendMessage:SelfDrop \ (?WinError)
        ;M

:M SetTabInfo:  ( index -- )
\ *G Sets some or all of a tab's attributes.
\ *P \i mask \d and other members of the TCITEM struct must be set.
        tc_item swap TCM_SETITEM SendMessage:SelfDrop \  (?WinError)
        ;M

:M GetTabCount: ( -- n )
\ *G Retrieves the number of tabs in the tab control.
        0 0 TCM_GETITEMCOUNT SendMessage:Self ;M

:M DeleteTab:   ( index -- )
\ *G Removes an item from the tab control.
        0 swap TCM_DELETEITEM SendMessage:SelfDrop \  (?WinError)
        ;M

:M DeleteAllTabs:   ( -- )
\ *G Removes all items from the tab control.
        0 0 TCM_DELETEALLITEMS SendMessage:SelfDrop \  (?WinError)
        ;M

:M AdjustRect:  ( rect flag -- )
\ *G Calculates a tab control's display area given a window rectangle, or
\ ** calculates the window rectangle that would correspond to a specified
\ ** display area.
\ *P \i rect \d is the address of a RECT structure that specifies the given rectangle
\ ** and receives the calculated rectangle.
\ *P \i flag \d If this parameter is TRUE, prc specifies a display rectangle and receives
\ ** the corresponding window rectangle. If this parameter is FALSE, prc specifies a window
\ ** rectangle and receives the corresponding display area.
        TCM_ADJUSTRECT SendMessage:selfDrop ;M

:M ClientSize:  ( -- l t r b )
\ *G Return size of display area of the tab control.
        winRect GetClientRect: self
        winRect false AdjustRect: self
        left: winRect top: winRect right: winRect bottom: winRect ;M

:M WindowSize:	( l t r t -- l t r b )
\ *G Given display area return window size required.
        SetRect: winRect
        winRect true AdjustRect: self
        left: winRect top: winRect right: winRect bottom: winRect ;M

:M GetSelectedTab: ( -- index )
\ *G Determines the currently selected tab in the tab control.
        0 0 TCM_GETCURSEL SendMessage:self ;M

:M SetSelectedTab: ( index --  )
\ *G Selects a tab in the tab control.
\ *P Note: A tab control does not send a TCN_SELCHANGING or TCN_SELCHANGE
\ ** notification message when a tab is selected using this message.
        0 swap TCM_SETCURSEL SendMessage:selfDrop ;M

:M GetRowCount: ( -- n )
\ *G Retrieves the current number of rows of tabs in a tab control.
		0 0 TCM_GETROWCOUNT SendMessage:self ;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

:M Setfont:     ( handle -- )
\ *G Set the font in the control.
                1 swap WM_SETFONT SendMessage:SelfDrop ;M

:M WindowTitle: ( -- null$ )
\ *G SintillaControl asks for window title of parent
                z" " ;M

:M Handle_Notify:  { w l \ ncode tabid -- f }
\ *G Handle the notification messages of the tab control. This method must
\ ** be called within the WM_NOTIFY handler of the parent window.
\ *P Currently only these notification messages are handled:
\ *L
\ *| TCN_SELCHANGE | Notifies a tab control's parent window that the currently selected tab has changed. |
\ *| TCN_SELCHANGING | Notifies a tab control's parent window that the currently selected tab is about to change. |
        w LOWORD to tabID
        l 2 cells+ @  to ncode
        ncode
        case
            TCN_SELCHANGE   of    l On_SelChanged:  [ self ] endof
            TCN_SELCHANGING of    l On_SelChanging: [ self ] endof
            false swap \ default
        endcase ;M

:M On_SelChanged:  ( l -- f )
\ *G Handle the TCN_SELCHANGE notification message.
\ ** Default calls the \i change function \d set with the \i IsChangeFunc: \d method.
		self selchange-func dup 0= abort" SelChanged function not set!"
		execute ;M

:M On_SelChanging: ( l -- f )
\ *G Handle the TCN_SELCHANGING notification message.
\ ** Default calls the \i changeing function \d set with the \i IsChangingFunc: \d method.
		self selchanging-func dup 0= abort" SelChanging function not set!"
		execute ;M

:M IsChangeFunc:   ( cfa -- )
\ *G Set the \i change function \d. This function es executed when
\ ** the currently selected tab has changed.
                to selchange-func ;M

:M IsChangingFunc: ( cfa -- )
\ *G Set the \i changeing function \d. This function es executed when
\ ** the currently selected tab is about to change.
                to selchanging-func ;M

: default-func     ( lParam obj -- false )
\ *G The default \i change(-ing) function \d.
\ *P \i lParam \d is the adress of the Address of an NMHDR structure.
\ ** \i obj \d is the address of the TabControl object that has send the
\ ** notification message.
                2drop false ;

:M ClassInit:   ( -- )
\ *G Initialise the class.
		ClassInit: Super
		tc_item /tc_item erase
		-1  to iImage       \ default no image
		['] default-func to selchange-func
		['] default-func to selchanging-func
		;M

:M Start:       ( Parent -- )
\ *G Create the control.
                to parent z" SysTabControl32" create-control
	        DEFAULT_GUI_FONT call GetStockObject SetFont: self
                ;M

;Class
\ *G End of TabControl class

\ ------------------------------------------------------------------------
\ *W <a name="MultiLineTabControl"></a>
\ *S MultiLineTabControl class
\ ------------------------------------------------------------------------
:Class MultiLineTabControl	<Super TabControl
\ *G Multiline Tab control.
\ ** Multiple rows of tabs are displayed, if necessary, so all tabs are visible at once.

:M Start:	( Parent -- )
	        TCS_MULTILINE AddStyle: self
	        Start: super
	       ;M
;class
\ *G End of MultiLineTabControl class


\ *P For a demo how to use the TabControl see: TabControlDemo.f

MODULE

\ *Z
