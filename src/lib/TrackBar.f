\ $Id: TrackBar.f,v 1.4 2013/03/15 00:23:07 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -TrackBar.f

WinLibrary COMCTL32.DLL

cr .( Loading Trackbar Class...)

INTERNAL
EXTERNAL

 \ ------------------------------------------------------------------------
\ *W <a name="Trackbar"></a>
\ *S Trackbar class
\ ------------------------------------------------------------------------
:Class Trackbar		<Super Control
\ *G Trackbar control (horizontal)
\ *P A trackbar is a window that contains a slider and optional tick marks.
\ ** When the user moves the slider, using either the mouse or the direction keys,
\ ** the trackbar sends notification messages to indicate the change.

:M Start:       ( Parent -- )
\ *G Create the control.
		to parent Z" msctls_trackbar32" create-control ;M

:M GetLineSize: ( -- n )
\ *G Retrieves the number of logical positions the trackbar's slider moves in
\ ** response to keyboard input from the arrow keys, such as the RIGHT ARROW or
\ ** DOWN ARROW keys. The logical positions are the integer increments in the
\ ** trackbar's range of minimum to maximum slider positions.
		0 0 TBM_GETLINESIZE SendMessage:Self ;M

:M SetLineSize: ( n -- )
\ *G Sets the number of logical positions the trackbar's slider moves in
\ ** response to keyboard input from the arrow keys, such as the RIGHT ARROW or
\ ** DOWN ARROW keys. The logical positions are the integer increments in the
\ ** trackbar's range of minimum to maximum slider positions.
		0 TBM_SETLINESIZE SendMessage:SelfDrop ;M

:M GetPageSize: ( -- n )
\ *G Retrieves the number of logical positions the trackbar's slider moves in
\ ** response to keyboard input, such as the PAGE UP or PAGE DOWN keys, or mouse
\ ** input, such as clicks in the trackbar's channel. The logical positions are the
\ ** integer increments in the trackbar's range of minimum to maximum slider positions.
                0 0 TBM_GETPAGESIZE SendMessage:Self ;M

:M SetPageSize: ( n -- )
\ *G Sets the number of logical positions the trackbar's slider moves in response to
\ ** keyboard input, such as the PAGE UP or PAGE DOWN keys, or mouse input, such as clicks
\ ** in the trackbar's channel. The logical positions are the integer increments in the
\ ** trackbar's range of minimum to maximum slider positions.
		0 TBM_SETPAGESIZE SendMessage:SelfDrop ;M

:M GetValue: 	( -- n)
\ *G Retrieves the current logical position of the slider in the trackbar. The logical positions
\ ** are the integer values in the trackbar's range of minimum to maximum slider positions.
                0 0 TBM_GETPOS SendMessage:Self ;M

:M SetValue: 	( n -- )
\ *G Sets the current logical position of the slider in the trackbar.
		TRUE TBM_SETPOS SendMessage:SelfDrop ;M

:M GetRangeMax: ( -- n )
\ *G Retrieves the maximum position for the slider in the trackbar.
		0 0 TBM_GETRANGEMAX SendMessage:Self ;M

:M SetRangeMax: ( max f -- )
\ *G Sets the maximum logical position for the slider in the trackbar.
\ *P If the \i f \d is TRUE, the trackbar is redrawn after the range is set.
\ ** If this parameter is FALSE, the message sets the range but does not redraw
\ ** the trackbar.
                TBM_SETRANGEMAX SendMessage:SelfDrop ;M

:M GetRangeMin: ( -- n )
\ *G Retrieves the minimum position for the slider in the trackbar.
		0 0 TBM_GETRANGEMIN SendMessage:Self ;M

:M SetRangeMin: ( min f -- )
\ *G Sets theminimum logical position for the slider in the trackbar.
\ *P If the \i f \d is TRUE, the trackbar is redrawn after the range is set.
\ ** If this parameter is FALSE, the message sets the range but does not redraw
\ ** the trackbar.
		TBM_SETRANGEMIN SendMessage:SelfDrop ;M

:M GetSelEnd: 	( -- n )
\ *G Retrieves the ending position of the current selection range in the trackbar.
\ ** A trackbar can have a selection range only if you specified the TBS_ENABLESELRANGE
\ ** style when you created it.
		0 0 TBM_GETSELEND SendMessage:Self ;M

:M SetSelEnd: 	( end f -- )
\ *G Sets the ending logical position of the current selection range in a trackbar.
\ ** This message is ignored if the trackbar does not have the TBS_ENABLESELRANGE style.
\ *P If the \i f \d is TRUE, the trackbar is redrawn after the range is set.
\ ** If this parameter is FALSE, the message sets the range but does not redraw
\ ** the trackbar.
		TBM_SETSELEND SendMessage:SelfDrop ;M

:M GetSelStart: ( -- n)
\ *G Retrieves the starting position of the current selection range in the trackbar.
\ ** A trackbar can have a selection range only if you specified the TBS_ENABLESELRANGE
\ ** style when you created it.
		0 0 TBM_GETSELSTART SendMessage:Self ;M

:M SetSelStart: ( start f -- )
\ *G Sets the starting logical position of the current selection range in the trackbar.
\ ** This message is ignored if the trackbar does not have the TBS_ENABLESELRANGE style.
\ *P If the \i f \d is TRUE, the trackbar is redrawn after the range is set.
\ ** If this parameter is FALSE, the message sets the range but does not redraw
\ ** the trackbar.
		TBM_SETSELSTART SendMessage:SelfDrop ;M

:M GetThumbLength: ( -- n )
\ *G Retrieves the length (in Pixel) of the slider in the trackbar.
		0 0 TBM_GETTHUMBLENGTH SendMessage:Self ;M

:M SetThumbLength: ( n -- )
\ *G Set the length (in Pixel) of the slider in the trackbar.
		0 SWAP TBM_SETTHUMBLENGTH SendMessage:SelfDrop ;M

:M GetChannelRect: ( lpRect -- )
\ *G Retrieves the size and position of the bounding rectangle for the
\ ** trackbar's channel. (The channel is the area over which the slider
\ ** moves. It contains the highlight when a range is selected.)
		0 TBM_GETCHANNELRECT SendMessage:SelfDrop ;M

:M GetThumbRect: ( lpRect -- )
\ *G Retrieves the size and position of the bounding rectangle for the slider
\ ** in the trackbar.
		0 TBM_GETTHUMBRECT SendMessage:SelfDrop ;M

:M GetTick: 	( iTic -- n )
\ *G Retrieves the logical position of a tick mark in a trackbar. The logical
\ ** position can be any of the integer values in the trackbar's range of minimum
\ ** to maximum slider positions.
		0 SWAP TBM_GETTIC SendMessage:Self ;M

:M SetTick: 	( pos -- )
\ *G Sets a tick mark in a trackbar at the specified logical position.
                0 TBM_SETTIC SendMessage:SelfDrop ;M

:M ClearTicks: 	( f -- )
\ *G Removes the current tick marks from a trackbar. This message does not remove
\ ** the first and last tick marks, which are created automatically by the trackbar.
\ *P If the \i f \d is TRUE, the trackbar is redrawn after the tick marks are cleared.
\ ** If this parameter is FALSE, the message clears the tick marks but does not redraw
\ ** the trackbar.
                0 SWAP TBM_CLEARTICS SendMessage:SelfDrop ;M

:M GetTickPos: 	( iTic -- n )
\ *G Retrieves the current physical position of a tick mark in a trackbar.
		0 SWAP TBM_GETTICPOS SendMessage:Self ;M

:M GetTicksPtr: ( -- pointer )
\ *G Retrieves the address of an array that contains the positions of the tick marks
\ ** for a trackbar.
\ *P Returns the address of an array of DWORD values. The elements of the array specify
\ ** the logical positions of the trackbar's tick marks, not including the first and last
\ ** tick marks created by the trackbar. The logical positions can be any of the integer
\ ** values in the trackbar's range of minimum to maximum slider positions.
\ *P The number of elements in the array is two less than the tick count returned by the
\ ** GetNumTicks: method. Note that the values in the array may include duplicate positions
\ ** and may not be in sequential order. The returned pointer is valid until you change the
\ ** trackbar's tick marks.
                0 0 TBM_GETPTICS SendMessage:Self ;M

:M SetTickFreq: ( pos freq -- )
\ *G Sets the interval frequency for tick marks in a trackbar. For example, if the frequency
\ ** is set to two, a tick mark is displayed for every other increment in the trackbar's range.
\ ** The default setting for the frequency is one; that is, every increment in the range is
\ ** associated with a tick mark.
\ *P The trackbar must have the TBS_AUTOTICKS style to use this method.
		TBM_SETTICFREQ SendMessage:SelfDrop ;M

:M GetNumTicks: ( -- n )
\ *G Retrieves the number of tick marks in the trackbar.
\ *P The GetNumTicks: method counts all of the tick marks, including the first and last tick
\ ** marks created by the trackbar.
		0 0 TBM_GETNUMTICS SendMessage:Self ;M

:M SetRange: 	( min max f -- )
\ *G Sets the range of minimum and maximum logical positions for the slider in the trackbar.
\ *P If the \i f \d parameter is TRUE, the trackbar is redrawn after the range is set. If this
\ ** parameter is FALSE, the message sets the range but does not redraw the trackbar.
		>R word-join R> TBM_SETRANGE SendMessage:SelfDrop ;M

:M SetSel: 	( min max f -- )
\ *G Sets the starting and ending positions for the available selection range in the trackbar.
\ *P If the \i f \d is TRUE, the message redraws the trackbar after the selection range is set.
\ ** If this parameter is FALSE, the message sets the selection range but does not redraw the trackbar.
\ *P This method is ignored if the trackbar does not have the TBS_ENABLESELRANGE style.
		>R word-join R> TBM_SETSEL SendMessage:SelfDrop ;M

:M ClearSel: 	( f -- )
\ *G Clears the current selection range in the trackbar.
\ *P If the \i f \d is TRUE, the trackbar is redrawn after the selection is cleared.
		0 SWAP TBM_CLEARSEL SendMessage:SelfDrop ;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class
\ *G End of Trackbar class

\ ------------------------------------------------------------------------
\ *W <a name="VTrackBar"></a>
\ *S VTrackBar class
\ ------------------------------------------------------------------------
:Class VTrackBar	<super TrackBar
\ *G Trackbar control (vertical)
\ *P A trackbar is a window that contains a slider and optional tick marks.
\ ** When the user moves the slider, using either the mouse or the direction keys,
\ ** the trackbar sends notification messages to indicate the change.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: TBS_VERT.
		WindowStyle: super TBS_VERT or ;M

;Class
\ *G End of VTrackBar class

MODULE

\ *Z
