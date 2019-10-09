\ $Id: TextBox.f,v 1.7 2016/01/02 16:45:35 jos_ven Exp $

\ *D doc\classes\
\ *> Controls

anew -TextBox.f

WinLibrary COMCTL32.DLL
WinLibrary RichEd32.DLL

cr .( Loading TextBox Classes...)

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="TextBox"></a>
\ *S TextBox class
\ ------------------------------------------------------------------------
:Class TextBox		<Super EditControl
\ *G Class for Edit controls.
\ ** An edit control is a rectangular control window typically used in a dialog
\ ** box to permit the user to enter and edit text by typing on the keyboard.
\ *P This is an enhanced Version of the EditControl class.

int pWmSetFocus	\ pointer to WM_SETFOCUS handler

:M ClassInit:   ( -- )
\ *G Initialise the class.
                ClassInit: super
                0 to pWmSetFocus ;M

:M SetWmSetFocus: ( xt -- )
\ *G Set handler for WM_SETFOCUS messages.
                to pWmSetFocus ;M

:M WM_SETFOCUS  ( h m w l -- res )
                pWmSetFocus
                if   self pWmSetFocus execute
                then old-wndproc CallWindowProc  \ still needs to be called
                ;M

:M WindowStyle: ( -- style )
\ *G Get the window style of the control.
                WindowStyle: super ;M

:M ReadOnly:    ( f -- )
\ *G Set or remove the read-only style of the edit control.
\ ** A value of TRUE sets the read-only style; a value of FALSE removes it.
                0 SWAP EM_SETREADONLY SendMessage:Self ?Win-error ;M

:M SetSelection: ( nEnd nStart -- )
\ *G Selects a range of characters in the edit control. \i nEnd \d specifies the
\ ** ending character position of the selection. \i nStart \d specifies the
\ ** starting character position of the selection.
\ *P The start value can be greater than the end value. The lower of the two values
\ ** specifies the character position of the first character in the selection. The
\ ** higher value specifies the position of the first character beyond the selection.
\ *P The start value is the anchor point of the selection, and the end value is the
\ ** active end. If the user uses the SHIFT key to adjust the size of the selection,
\ ** the active end can move but the anchor point remains the same.
\ *P The control displays a flashing caret at the end position regardless of the relative
\ ** values of start and end.
                EM_SETSEL SendMessage:selfDrop ;M

:M GetSelection: ( -- nEnd nStart )
\ *G Get the starting and ending character positions of the current selection in the edit control
		NULL NULL EM_GETSEL SendMessage:Self
		DUP HIWORD SWAP LOWORD ;M

:M SelectAll: 	( -- )
\ *G Set the focus to the edit control and select all the text in the control.
                SetFocus: Self   \ Change the focus for deselecting.
                -1 0 SetSelection: self
                ;M

:M RemoveSelection: ( -- )
\ *G Remove any selection.
		0 -1 SetSelection: self ;M

:M GetCursor:   ( -- n )
\ *G Get location of cursor (chars from start)
                GetSelection: self
                RemoveSelection: self
                GetSelection: self  >R
                SetSelection: self  R>
                ;M

:M IsModified?: ( -- f )
\ *G Get the state of an edit control's modification flag. The flag indicates whether
\ ** the contents of the edit control have been modified.
                0 0 EM_GETMODIFY SendMessage:Self
                ;M

:M SetModify:	( f -- )
\ *G Sets or clears the modification flag for an edit control. The modification flag
\ ** indicates whether the text within the edit control has been modified.
                swap 0 EM_SETMODIFY SendMessage:SelfDrop ;M

DPR-WARNING-OFF
:M NotModified: ( -- )
\ *G Depreacted method. Use \i SetModify: \d instead.
                0 0 EM_SETMODIFY SendMessage:SelfDrop ;M DEPRECATED
DPR-WARNING-ON

:M Undo?:       ( -- f )
\ *G Check is there is an operation in the control's undo queue.
		0 0 EM_CANUNDO SendMessage:Self ;M

:M Undo:	( -- )
\ *G Undoes the last edit control operation in the control's undo queue.
                Undo?: self
		IF   0 0 EM_UNDO SendMessage:SelfDrop
		ELSE MB_OK
		     Z" Undo notification"
		     Z" Nothing to undo."
		     GetHandle: self Call MessageBox DROP
		THEN ;M

:M Redo?:       ( -- f )
\ *G Check is there is an operation in the control's redo queue.
		0 0 EM_CANREDO SendMessage:Self ;M

:M Redo:	( -- )
\ *G Redoes the last edit control operation in the control's redo queue.
		Redo?: self
		IF   0 0 EM_REDO SendMessage:SelfDrop
		ELSE MB_OK
		     Z" Redo notification"
		     Z" Nothing to redo."
		     GetHandle: self Call MessageBox DROP
		THEN ;M

:M Cut: 	( -- )
\ *G Delete (cut) the current selection, if any, in the edit control and
\ ** copy the deleted text to the clipboard in CF_TEXT format.
		0 0 WM_CUT SendMessage:SelfDrop ;M

:M Copy: 	( -- )
\ *G Copy the current selection to the clipboard in CF_TEXT format.
		0 0 WM_COPY SendMessage:SelfDrop ;M

:M Paste: 	( -- )
\ *G Copy the current content of the clipboard to the edit control at the current
\ ** caret position. Data is inserted only if the clipboard contains data in CF_TEXT
\ ** format.
		0 0 WM_PASTE SendMessage:SelfDrop ;M

:M Clear: 	( -- )
\ *G Delete selected text.
		0 0 WM_CLEAR SendMessage:SelfDrop ;M

:M SetFont:     ( handle -- )
\ *G Set the font in the control.
                1 swap WM_SETFONT SendMessage:SelfDrop ;M

:M SetTextLimit: ( n -- )
\ *G Set the text limit of an edit control.
\ *P \i n \d Specifies the maximum number of characters the user can enter. This number does
\ ** not include the null terminator. \n
\ ** Edit controls on Windows NT/ 2000: If this parameter is zero, the text length is set
\ ** to 0x7FFFFFFE characters for single-line edit controls or -1 for multiline edit controls. \n
\ ** Edit controls on Windows 95/98: If this parameter is zero, the text length is set to 0x7FFE
\ ** characters for single-line edit controls or 0xFFFF for multiline edit controls.
\ *P The SetTextLimit: method limits only the text the user can enter. It does not affect any text
\ ** already in the edit control when the message is sent, nor does it affect the length of the text
\ ** copied to the edit control by the SetText: method. If an application uses the SetText: method
\ ** to place more text into an edit control than is specified in the SetTextLimit: method, the user can
\ ** edit the entire contents of the edit control.
\ *P Before the SetTextLimit: method is called, the default limit for the amount of text a user can enter
\ ** in an edit control is 32,767 characters.
\ *P Edit controls on Windows NT/ 2000: For single-line edit controls, the text limit is either 0x7FFFFFFE bytes
\ ** or the value of \i n \d, whichever is smaller. For multiline edit controls, this value is either
\ ** -1 bytes or the value of \i n \d, whichever is smaller.
\ *P Edit controls on Windows 95/98: For single-line edit controls, the text limit is either 0x7FFE bytes or
\ ** the value of \i n \d, whichever is smaller. For multiline edit controls, this value is either 0xFFFF bytes
\ ** or the value of \i n \d, whichever is smaller.
                0 swap EM_SETLIMITTEXT SendMessage:SelfDrop ;M

:M GetTextEx:  \ { buffer$ maxlen -- buffer$ len }
\ *G Copies the text of the edit control into a buffer.
\ *P \i buffer$ \d is the address of the buffer that will receive the text.
\ *P \i maxlen \d Specifies the maximum number of characters to copy to the
\ ** buffer, including the NULL character. If the text exceeds this limit, it
\ ** is truncated.
\ *P If the method succeeds, \i len \d is the length, in characters, of the copied
\ ** string, not including the terminating null character.
\                maxlen buffer$ hwnd Call GetWindowText buffer$ swap ;M
                over hwnd Call GetWindowText ;M

:M SetTextZ:    ( addrz -- )
\ *G Copy the text from the 0 terminated string \i addrz \d into the edit control.
                hwnd
                if   hwnd Call SetWindowText ?win-error
		else drop
                then ;M

;Class
\ *G End of TextBox class

\ ------------------------------------------------------------------------
\ *W <a name="PassWordBox"></a>
\ *S PassWordBox class
\ ------------------------------------------------------------------------
:Class PassWordBox	<super TextBox
\ *G Class for Edit controls.
\ ** All characters in the control are displayed as an asterisk (*).

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is ES_PASSWORD.
	WindowStyle: super ES_PASSWORD or ;M

;Class
\ *G End of PassWordBox class

\ ------------------------------------------------------------------------
\ *W <a name="MultiLineTextBox"></a>
\ *S MultiLineTextBox class
\ ------------------------------------------------------------------------
:Class MultiLineTextBox         <super TextBox
\ *G Class for multi line text edit controls.

CREATE 'tabs  16 ,   \ tabstops in dialog-box units (32 default)

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is:
\ ** ES_AUTOVSCROLL, ES_MULTILINE, ES_WANTRETURN and ES_NOHIDESEL.
                WindowStyle: super
                [ ES_AUTOVSCROLL ES_MULTILINE OR ES_WANTRETURN OR ES_NOHIDESEL OR ] literal or
                ;M

:M SetTabStops: ( tabarray #tabs -- )
\ *G Sets the tab stops in the multiline edit control. When text is copied to
\ ** the control, any tab character in the text causes space to be generated up
\ ** to the next tab stop.
\ *P \i #tabs \d Specifies the number of tab stops contained in the array. If this
\ ** parameter is zero, the lParam parameter is ignored and default tab stops are
\ ** set at every 32 dialog template units. If this parameter is 1, tab stops are
\ ** set at every n dialog template units, where n is the distance pointed to by
\ ** the \i tabarray \d parameter. If this parameter is greater than 1, \i tabarray \d
\ ** is a pointer to an array of tab stops.
\ *P \i tabarray \d Pointer to an array of unsigned integers specifying the tab stops,
\ ** in dialog template units. If the \i #tabs \d parameter is 1, this parameter is a pointer
\ ** to an unsigned integer containing the distance between all tab stops, in dialog template
\ ** units.
                EM_SETTABSTOPS SendMessage:self  ?Win-Error
                Paint: self \ froce a repaint of the control
                ;M

:M DefaultTabs: ( -- )
\ *G Set the default tab stops in the multiline edit control (16 dialog template units).
                'tabs 1 SetTabStops: self ;M

:M SetMargins:  ( left right -- )
\ *G Sets the widths of the left and right margins for an edit control.
                word-join
                [ EC_LEFTMARGIN EC_RIGHTMARGIN OR ] literal EM_SETMARGINS
                SendMessage:selfDrop ;M

:M SelectAll:	( -- )
\ *G Select all the text in the multiline edit control.
		-1 0 SetSelection: self ;M

:M GetLine:     ( -- n )
\ *G Return location of the cursor (lines from start).
                0 -1 EM_LINEFROMCHAR SendMessage:self ;M

:M Wrap:        ( -- )
\ *G Set control to wrap text.
\ ** Note this method does nothing!
                ;M

:M Unwrap:      ( -- )
\ *G Set control to scroll instead of wrap text.
\ ** Note this method does nothing!
                ;M

:M GetLineCount: ( -- n )
\ *G Retrieves the number of lines in the multiline edit control.
\ *P The return value is an integer specifying the total number of
\ ** text lines in the multiline edit control. If the control has no text,
\ ** the return value is 1. The return value will never be less than 1.
                0 0 EM_GETLINECOUNT SendMessage:self ;M

: GetClipboardText ( addr -- n ) \ get text from clipboard
                0 Call OpenClipboard
                if   CF_TEXT Call GetClipboardData ?DUP
                     if   dup>r Call GlobalLock zcount
                          rot dup>r place r> count nip
                          r> Call GlobalUnlock drop
                     else 0
                     then Call CloseClipboard drop
                else 0
                then ;

:M GetSelText:  ( addr -- n )
\ *G Retrieves the currently selected text from the edit control.
\ *P \i addr \d is the address of the a buffer that receives the selected text.
\ ** The calling application must ensure that the buffer is large enough to hold
\ ** the selected text.
\ *P Note: The text is copyied to the clipboard, too!
                Copy: self       \ copy the selected text into the clipboard
                GetClipboardText \ and copy it from there into the buffer
                ;M

:M LineScroll:  ( n -- )
\ *G scroll n lines
                0 EM_LINESCROLL SendMessage:self ;M

;Class
\ *G End of MultiLineTextBox class

\ ------------------------------------------------------------------------
\ *W <a name="RichEditControl"></a>
\ *S RichEditControl class
\ ------------------------------------------------------------------------
:Class RichEditControl	<Super MultiLineTextBox
\ *G Class for rich edit controls.

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent z" RichEdit" Create-Control ;M

:M GetSelText:  ( addr -- n )
\ *G Retrieves the currently selected text from the edit control.
\ *P \i addr \d is the address of the a buffer that receives the selected text.
\ ** The calling application must ensure that the buffer is large enough to hold
\ ** the selected text.
                0 EM_GETSELTEXT SendMessage:self ;M

DPR-WARNING-OFF
:M GetLines: 	( -- nr )
\ *G Depreacted method. Use \i GetLineCount: \d instead.
                GetLineCount: super ;M DEPRECATED
DPR-WARNING-ON

;Class
\ *G End of RichEditControl class

MODULE


\ *Z

