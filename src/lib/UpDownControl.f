\ $Id: UpDownControl.f,v 1.8 2013/11/28 20:51:55 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -UpDownControl.f

WinLibrary COMCTL32.DLL

needs textbox.f

cr .( Loading UpDownControl Class...)

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="UpDownControl"></a>
\ *S Up-Down Control class
\ ------------------------------------------------------------------------
:Class UpDownControl	<Super Control
\ *G Up-Down control
\ *P An up-down control is a pair of arrow buttons that the user can click to
\ ** increment or decrement a value, such as a scroll position or a number displayed
\ ** in a companion control.
\ *P For 16 Bit values only.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is:
\ ** WS_BORDER, UDS_ARROWKEYS, UDS_SETBUDDYINT and UDS_ALIGNRIGHT.
		WindowStyle: super
		[ WS_BORDER UDS_ARROWKEYS OR UDS_SETBUDDYINT OR UDS_ALIGNRIGHT OR ] literal or ;M

:M Start:       ( Parent -- )
\ *G Create the control.
		to parent Z" msctls_updown32" create-control ;M

:M StartSize:	( -- cx cy )
\ *G default window size
		40 20 ;M

:M StartPos: 	( -- x y )
\ *G default window position
		0 0 ;M

:M SetBuddy:	( hBuddy -- )
\ *G Sets the buddy window for the up-down control.
		0 SWAP UDM_SETBUDDY SendMessage:SelfDrop ;M

:M GetValue: 	( -- n )
\ *G Retrieves the current position of the up-down control.
\ ** Note: This method ABORT's on error.
		0 0 UDM_GETPOS SendMessage:Self
		word-split ABORT" Up/Down Control read error"
		;M

:M SetValue:	( n -- )
\ *G Set the current position for the up-down control.
		0 word-join 0 UDM_SETPOS SendMessage:SelfDrop ;M

:M SetDecimal: 	( -- )
\ *G Sets the radix base for the control to decimal.
\ ** Decimal numbers are signed.
		0 10 UDM_SETBASE SendMessage:SelfDrop ;M

:M SetHex: 	( -- )
\ *G Sets the radix base for the control to hexadecimal.
\ ** Hexadecimal numbers are always unsigned.
		0 16 UDM_SETBASE SendMessage:SelfDrop ;M

:M GetBase: 	( -- n )
\ *G Get the current radix base (that is, either base 10 or 16).
		0 0 UDM_GETBASE SendMessage:Self ;M

:M SetRange: 	( lower upper -- )
\ *G Sets the minimum and maximum positions (range) the control.
\ ** Neither position can be greater than the UD_MAXVAL value or less than
\ ** the UD_MINVAL value. In addition, the difference between the two positions
\ ** cannot exceed UD_MAXVAL.
		swap word-join 0 UDM_SETRANGE SendMessage:SelfDrop ;M

:M GetRange: 	( -- lower upper )
\ *G Retrieves the minimum and maximum positions (range) for the control.
		0 0 UDM_GETRANGE SendMessage:Self word-split SWAP ;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class
\ *G End of Up-Down Control Class

\ *W <a name="SpinnerControl"></a>
\ *S Spinner Control class

:Class SpinnerControl           <Super UpDownControl
\ *G Spinner Control Class.

\ *P This class is a combination of an up-down control and a Text Box (the buddy).

TextBox TheBox

:M start:     ( parent -- )
\ *G Start the control.
              dup Start: TheBox \ both must have same parent
              Start: super
              ;M

:M TheBox:   ( -- spinbox )
\ *G Object address of the text box for directly manipulating it (though it shouldn't really be done).
              TheBox ;M

:M Move:      ( x y w h -- )
\ *G Move the text box to the specified positon and the up-down control as well.
              Move: TheBox
              \ allow the updowncontrol to move with the editcontrol
              GetHandle: TheBox SetBuddy: self ;M

:M Select:    ( -- )
\ *G Selects the text inside the spinner
              SetFocus: TheBox
              0 0 word-join EM_SETSEL
              GetHandle: TheBox Call SendMessage ;M


:M SetFont:   ( hndl -- )
\ *G Set the font of the text box.
              Setfont: TheBox ;M


:M Close:     ( -- )
\ *G Close the control.
              Close: TheBox
              Close: self ;M
;class

\ *G End of Spinner Control Class.

MODULE

\ *Z
