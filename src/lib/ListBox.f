\ $Id: ListBox.f,v 1.6 2013/03/15 00:23:07 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -ListBox.f

WinLibrary COMCTL32.DLL

cr .( Loading ListBox Classes...)

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="ComboBox"></a>
\ *S ComboBox class
\ ------------------------------------------------------------------------
:Class ComboBox		<super ComboControl
\ *G ComboBox control
\ ** (enhanced Version of the ComboControl class)

:M SetDir:      ( dirz$ attrib -- )
\ *G Add the names of directories and files that match a specified string and
\ ** set of file attributes. SetDir: can also add mapped drive letters to the list.
\ *P \i attrib \d Specifies the attributes of the files or directories to be added to
\ ** the combo box. This parameter can be one or more of the following values:
\ *L
\ *| DDL_ARCHIVE    | Includes archived files. |
\ *| DDL_DIRECTORY  | Includes subdirectories, which are enclosed in square brackets ([ ]). |
\ *| DDL_DRIVES All | mapped drives are added to the list. Drives are listed in the form [-x-], where x is the drive letter. |
\ *| DDL_EXCLUSIVE  | Includes only files with the specified attributes. By default, read-write files are listed even if DDL_READWRITE is not specified. |
\ *| DDL_HIDDEN     | Includes hidden files. |
\ *| DDL_READONLY   | Includes read-only files. |
\ *| DDL_READWRITE  | Includes read-write files with no additional attributes. This is the default. |
\ *| DDL_SYSTEM     | Includes system files. |
\ *P \i dirz$ \d specifies an absolute path, relative path, or file name. An absolute path
\ ** can begin with a drive letter (for example, d:\) or a UNC name (for example, \\machinename\sharename).
\ ** If the string specifies a file name or directory that has the attributes specified by
\ ** the wParam parameter, the file name or directory is added to the list. If the file name
\ ** or directory name contains wildcard characters (? or *), all files or directories that
\ ** match the wildcard expression and have the attributes specified by the wParam parameter
\ ** are added to the list displayed in the combo box.
                CB_DIR SendMessage:SelfDrop ;M

:M AddStringTo: ( z"string" -- )
\ *G Add a string to the list box of a combo box. If the combo box does not have the
\ ** CBS_SORT style, the string is added to the end of the list. Otherwise, the string
\ ** is inserted into the list, and the list is sorted.
                0 CB_ADDSTRING SendMessage:SelfDrop ;M

:M SetSelection: ( n -- )
\ *G Select a string in the list of a combo box.
                0 swap CB_SETCURSEL SendMessage:SelfDrop ;M

:M GetSelection: ( -- n )
\ *G Retrieve the index of the currently selected item, if any.
\ *P The return value is the zero-based index of the currently selected item. If there is no
\ ** selection, the return value is CB_ERR.
                0 0 CB_GETCURSEL SendMessage:Self ;M

:M GetString:    ( index -- addr n )
\ *G Retrieve a string from the combo box.
\ *P The return value is the address and length of the string.
\ ** If \i n \d does not specify a valid index, the length is CB_ERR.
                new$ dup rot CB_GETLBTEXT SendMessage:Self  ;M

:M GetSelectedString: ( -- addr cnt )
\ *G Retrieve the currently selected string from the combo box.
\ ** Note: The string is returned in a dynamicly allocated buffer of medium persistance. If a
\ ** permenant copy is needed it should be moved.
                GetSelection: self GetString: self ;M

:M Setfont:     ( handle -- )
\ *G Set the font in the control.
                1 swap WM_SETFONT SendMessage:SelfDrop ;M

:M InsertStringAt: ( lpszString posn -- )
\ *G Insert string at the specified position.
\ *P \i posn \d specifies the zero-based index of the position at which to insert
\ ** the string. If this parameter is -1, the string is added to the end of the list.
\ *P \i lpszString \d is a null-terminated string to be inserted.
                CB_INSERTSTRING SendMessage:Self
		CB_ERR OVER = SWAP CB_ERRSPACE = OR
		ABORT" Error adding string to combo box" ;M

:M DeleteString: ( index -- )
\ *G Delete a string.
\ *P \i index \d specifies the zero-based index of the string to delete.
		0 SWAP CB_DELETESTRING SendMessage:SelfDrop ;M

:M Clear: 	( -- )
\ *G Remove all strings from the combo box
		0 0 CB_RESETCONTENT SendMessage:SelfDrop ;M

:M Find: 	( lpszString -- index )
\ *G Search the list for an item beginning with the string (case-insensitive)
		-1 CB_FINDSTRING SendMessage:Self ;M

:M FindExact: 	( lpszString -- index )
\ *G Find the first item that matches the string exactly (case-insensitive)
		-1 CB_FINDSTRINGEXACT SendMessage:Self ;M

:M GetCount: 	( -- n )
\ *G Return count of items in list
		0 0 CB_GETCOUNT SendMessage:Self ;M

:M SelectString: ( lpszString -- index )
\ *G Select item beginning with string
		-1 CB_SELECTSTRING SendMessage:Self ;M

:M GetStringAt:	( index -- a n )
\ *G Return string of specified item.

\ TODO: Don't use HERE here !!!
		HERE SWAP CB_GETLBTEXT SendMessage:Self  HERE SWAP ;M

:M GetCurrent: 	( -- index )
\ *G return current selection item
		0 0 CB_GETCURSEL SendMessage:Self ;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class
\ *G End of ComboBox class

\ ------------------------------------------------------------------------
\ *W <a name="ComboListBox"></a>
\ *S ComboListBox class
\ ------------------------------------------------------------------------
:Class ComboListBox	<super ComboBox
\ *G ComboBox list control

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: CBS_DROPDOWNLIST
                WindowStyle: SUPER CBS_DROPDOWNLIST OR ;M

:M Start:       ( Parent -- )
\ *G Create the control.
\ We don't want the editcontrol in this control to be subclassed as with
\ super class. It shows the ibeam cursor so we override the start method.
                TO Parent
                z" COMBOBOX" Create-Control ;M

;Class
\ *G End of ComboListBox class

\ ------------------------------------------------------------------------
\ *W <a name="ListBox"></a>
\ *S ListBox class
\ ------------------------------------------------------------------------
:Class ListBox		<super ListControl
\ *G ListBox control (single selection)
\ ** (enhanced Version of the ListControl class)

:M SetDir:      ( dirz$ attrib -- )
\ *G Add the names of directories and files that match a specified string and
\ ** set of file attributes. SetDir: can also add mapped drive letters to the list.
\ *P \i attrib \d Specifies the attributes of the files or directories to be added to
\ ** the combo box. This parameter can be one or more of the following values:
\ *L
\ *| DDL_ARCHIVE    | Includes archived files. |
\ *| DDL_DIRECTORY  | Includes subdirectories, which are enclosed in square brackets ([ ]). |
\ *| DDL_DRIVES All | mapped drives are added to the list. Drives are listed in the form [-x-], where x is the drive letter. |
\ *| DDL_EXCLUSIVE  | Includes only files with the specified attributes. By default, read-write files are listed even if DDL_READWRITE is not specified. |
\ *| DDL_HIDDEN     | Includes hidden files. |
\ *| DDL_READONLY   | Includes read-only files. |
\ *| DDL_READWRITE  | Includes read-write files with no additional attributes. This is the default. |
\ *| DDL_SYSTEM     | Includes system files. |
\ *P \i dirz$ \d specifies an absolute path, relative path, or file name. An absolute path
\ ** can begin with a drive letter (for example, d:\) or a UNC name (for example, \\machinename\sharename).
\ ** If the string specifies a file name or directory that has the attributes specified by
\ ** the wParam parameter, the file name or directory is added to the list. If the file name
\ ** or directory name contains wildcard characters (? or *), all files or directories that
\ ** match the wildcard expression and have the attributes specified by the wParam parameter
\ ** are added to the list displayed in the combo box.
                LB_DIR SendMessage:SelfDrop ;M

:M Clear:       ( -- )
\ *G Remove all items from the list box.
                0 0 LB_RESETCONTENT SendMessage:SelfDrop ;M

:M AddStringTo: ( z"string" -- )
\ *G Add a string to a list box. If the list box does not have the LBS_SORT style,
\ ** the string is added to the end of the list. Otherwise, the string is inserted
\ ** into the list and the list is sorted.
                0 LB_ADDSTRING SendMessage:SelfDrop ;M

:M SetSelection: ( n -- )
\ *G Select a string and scroll it into view, if necessary. When the new string is
\ ** selected, the list box removes the highlight from the previously selected string.
\ *P \i n \d specifies the zero-based index of the string that is selected. If this parameter
\ ** is -1, the list box is set to have no selection.
\ *P Windows 95/98: The \i n \d parameter is limited to 16-bit values. This means list boxes
\ ** cannot contain more than 32,767 items. Although the number of items is restricted, the
\ ** total size in bytes of the items in a list box is limited only by available memory.
                0 swap LB_SETCURSEL SendMessage:SelfDrop ;M

:M GetSelection: ( -- n )
\ *G Retrieve the index of the currently selected item, if any.
\ *P The return value is the zero-based index of the currently selected item. If there is no
\ ** selection, the return value is LB_ERR.
                0 0 LB_GETCURSEL SendMessage:Self ;M

:M GetString:    ( index -- addr n )
\ *G Retrieve a string from the list box.
\ *P The return value is the address and length of the string.
\ ** If \i n \d does not specify a valid index, the length is LB_ERR.
                new$ dup rot LB_GETTEXT SendMessage:Self  ;M

:M GetSelectedString: ( -- addr cnt )
\ *G Retrieve the currently selected string from the list box.
\ ** Note: The string is returned in a dynamicly allocated buffer of medium persistance. If a
\ ** permenant copy is needed it should be moved.
                GetSelection: self GetString: self ;M

:M GetCount:    ( -- n )
\ *G Retrieve the number of items in the list box.
                0 0 LB_GETCOUNT SendMessage:Self ;M

:M Setfont:     ( handle -- )
\ *G Set the font in the control.
                1 swap WM_SETFONT SendMessage:SelfDrop ;M

:M AddString: 	( lpszString -- )
\ *G Add a string to a list box. If the list box does not have the LBS_SORT style,
\ ** the string is added to the end of the list. Otherwise, the string is inserted
\ ** into the list and the list is sorted.
\ ** Note: This method ABORT's on error.
                0 LB_ADDSTRING SendMessage:Self
                LB_ERR OVER = SWAP LB_ERRSPACE = OR
                ABORT" Error adding string to list box"
                ;M

:M InsertString: ( lpszString index -- )
\ *G Insert a string into the list box. Unlike the AddString: method, the InsertString: method
\ ** does not cause a list with the LBS_SORT style to be sorted.
\ ** Note: This method ABORT's on error.
\ *P \i index \d specifies the zero-based index of the position at which to insert
\ ** the string. If this parameter is -1, the string is added to the end of the list.
\ *P Windows 95/98: The \i index \d parameter is limited to 16-bit values. This means list
\ ** boxes cannot contain more than 32,767 items. Although the number of items is restricted,
\ ** the total size in bytes of the items in a list box is limited only by available memory.
		LB_INSERTSTRING SendMessage:Self
		LB_ERR OVER = SWAP LB_ERRSPACE = OR
		ABORT" Error inserting string in list box"
		;M

:M DeleteString: ( index -- )
\ *G Delete a string from the list box.
\ *P \i index \d specifies the zero-based index of the string to be deleted.
\ *P Windows 95/98: The \i index \d parameter is limited to 16-bit values. This means list boxes
\ ** cannot contain more than 32,767 items. Although the number of items is restricted, the total
\ ** size in bytes of the items in a list box is limited only by available memory.
		0 SWAP LB_DELETESTRING SendMessage:SelfDrop ;M

:M Find: 	( lpszString -- index )
\ *G Find the first string in the list box that begins with the specified string.
\ ** The entire list box is searched from the beginning.
\ ** The search is case independent, so the string (\i lpszString \d) can contain any combination of
\ ** uppercase and lowercase letters.
\ *P The return value is the zero-based index of the matching item, or LB_ERR if the search was unsuccessful.
		-1 LB_FINDSTRING SendMessage:Self ;M

:M FindExact: 	( lpszString -- index )
\ *G Find the first list box string that exactly matches the specified string, except that the search
\ ** is not case sensitive.
\ ** The entire list box is searched from the beginning.
\ *P The return value is the zero-based index of the matching item, or LB_ERR if the search was unsuccessful.
	-1 LB_FINDSTRINGEXACT SendMessage:Self ;M

:M GetCurrent: 	( -- index )
\ *G Retrieve the index of the currently selected item, if any.
\ *P The return value is the zero-based index of the currently selected item. If there is no
\ ** selection, the return value is LB_ERR.
                GetSelection: self ;M

:M SelectString: ( lpszString -- index )
\ *G Search the list box for an item that begins with the characters in a specified string.
\ ** If a matching item is found, the item is selected.
\ ** The entire list box is searched from the beginning.
\ *P If the search is successful, the return value is the index of the selected item. If the
\ ** search is unsuccessful, the return value is LB_ERR and the current selection is not changed.
		-1 LB_SELECTSTRING SendMessage:Self ;M

:M GetState:	( index -- f )
\ *G Retrieve the selection state of an item.
\ ** If an item is selected, the return value is true; otherwise, it is false.
\ ** Note: This method ABORT's on error.
		0 SWAP LB_GETSEL SendMessage:Self
		LB_ERR OVER = ABORT" GetState: error occurred."
		0>
		;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

:M SetTabStops: ( addr cnt -- )
\ *G Set the tab-stop positions in the list box.
\ *P \i cnt \d Specifies the number of tab stops in the list box.
\ *P \i addr \d is a pointer to the first member of an array of integers containing the tab
\ ** stops. The integers represent the number of quarters of the average character width for
\ ** the font that is selected into the list box. For example, a tab stop of 4 is placed at
\ ** 1.0 character units, and a tab stop of 6 is placed at 1.5 average character units. However,
\ ** if the list box is part of a dialog box, the integers are in dialog template units. The tab
\ ** stops must be sorted in ascending order; backward tabs are not allowed.
\ *P The list box must have been created with the LBS_USETABSTOPS style.
                LB_SETTABSTOPS SendMessage:SelfDrop ;M

;Class
\ *G End of ListBox class

\ ------------------------------------------------------------------------
\ *W <a name="MultiListbox"></a>
\ *S MultiListbox class
\ ------------------------------------------------------------------------
:Class MultiListbox  	<Super Listbox
\ *G ListBox control
\ ** MultiListbox allows multiple selections to be made.
\ ** Click once on an item to select it.  Click again to deselect.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: LBS_MULTIPLESEL
		WindowStyle: super
		LBS_MULTIPLESEL OR
		;M

:M Select:	( index -- )
\ *G Select a string in the list box.
\ *P \i index \d specifies the zero-based index of the string to set. If this parameter
\ ** is -1, the selection is added to all strings.
\ ** Note: This method ABORT's on error.
		TRUE LB_SETSEL SendMessage:Self
		LB_ERR = ABORT" Select: error occurred."
		;M

:M Unselect: 	( index -- )
\ *G Deselect a string in the list box.
\ *P \i index \d specifies the zero-based index of the string to set. If this parameter
\ ** is -1, the selection is removed from all strings.
\ ** Note: This method ABORT's on error.
		FALSE LB_SETSEL SendMessage:Self
		LB_ERR = ABORT" Unselect: error occurred."
		;M

:M GetSelCount:	( -- n )
\ *G Retrieve the total number of selected items in the list box.
		0 0 LB_GETSELCOUNT SendMessage:Self ;M

:M GetSelectedItems: ( array cnt -- count )
\ *G Fill a buffer with an array of integers that specify the item numbers of selected
\ ** items in the list box.
\ *P \i array \d is a pointer to a buffer large enough for the number of integers specified
\ ** by the \i cnt \d parameter.
\ *P \i cnt \d specifies the maximum number of selected items whose item numbers are to be placed
\ ** in the buffer. Windows 95/98: The \i cnt \d parameter is limited to 16-bit values. This means
\ ** list boxes cannot contain more than 32,767 items. Although the number of items is restricted,
\ ** the total size in bytes of the items in a list box is limited only by available memory.
		LB_GETSELITEMS SendMessage:Self ;M
;Class
\ *G End of MultiListbox class

\ *W <a name="MultiExListbox"></a>
\ *S MultiExListbox class
:Class MultiExListbox	<Super MultiListbox
\ *G ListBox control
\ ** Also allows multiple selections to be made.
\ ** The difference is that Ctrl-Click selects and unselects
\ ** individual items and Shift-Click will select a range (as will
\ ** Shift-Drag.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: LBS_EXTENDEDSEL
      WindowStyle: super LBS_EXTENDEDSEL OR ;M

;Class
\ *G End of MultiExListbox class

\ ------------------------------------------------------------------------
\ *W <a name="DragListbox"></a>
\ *S DragListbox class
\ ------------------------------------------------------------------------
:Class DragListbox	<Super Listbox
\ *G ListBox control
\ ** Allows dragging of items in list box to re-order them
\ ** requires processing of drag list notification messages by the
\ ** application to actually do the dragging.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: LBS_EXTENDEDSEL
		WindowStyle: super
		LBS_EXTENDEDSEL OR
		;M

:M Start:       ( Parent -- )
\ *G Create the control.
		Start: super \ create a single-selection list box
		hWnd Call MakeDragList ?Win-Error \ convert it to a Drag-type
		;M

;Class
\ *G End of DragListbox class

MODULE

\ *Z
