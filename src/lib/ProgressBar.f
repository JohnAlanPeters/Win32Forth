\ $Id: ProgressBar.f,v 1.4 2013/03/15 00:23:07 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -ProgressBar.f

WinLibrary COMCTL32.DLL

cr .( Loading Progressbar Class...)

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="Progressbar"></a>
\ *S Progressbar class
\ ------------------------------------------------------------------------
:Class Progressbar	<Super Control
\ *G Progressbar control
\ ** A progress bar is a window that an application can use to indicate the progress
\ ** of a lengthy operation. It consists of a rectangle that is gradually filled with
\ ** the system highlight color as an operation progresses.

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent Z" msctls_progress32" Create-Control ;M

:M +Value: 	( n -- )
\ *G Advances the current position of the progress bar by a specified increment
\ ** and redraws the bar to reflect the new position.
		0 SWAP PBM_DELTAPOS SendMessage:SelfDrop ;M

:M GetValue: 	( -- n )
\ *G Returns the current position of the progress bar.
		0 0 PBM_DELTAPOS SendMessage:Self ;M

:M SetValue: 	( n -- )
\ *G Sets the current position for the progress bar and redraws the bar to
\ ** reflect the new position.
		0 SWAP PBM_SETPOS SendMessage:SelfDrop ;M

:M SetRange: 	( min max -- )
\ *G Sets the minimum and maximum values for the progress bar and redraws the
\ ** bar to reflect the new range.
\ *P \i min \d is the minimum range value. By default, the minimum value is zero.
\ *P \i max \d is the maximum range value. By default, the maximum value is 100.
		word-join 0 PBM_SETRANGE SendMessage:Self  ?Win-error ;M

: SetStep       ( n -- n1 )
		0 SWAP PBM_SETSTEP SendMessage:Self ;

:M SetStep: 	( n -- )
\ *G Specifies the step increment for the progress bar. The step increment is
\ the amount by which the progress bar increases its current position whenever
\ the StepIt: method is used. By default, the step increment is set to 10.
		SetStep DROP ;M

:M GetStep: 	( -- n )
\ *G Returns the current step increment for the progress bar.
		0 SetStep dup SetStep ;M

:M StepIt: 	( -- )
\ *G Advances the current position for the progress bar by the step increment
\ ** and redraws the bar to reflect the new position.
\ *P When the position exceeds the maximum range value, this method resets the current
\ ** position so that the progress indicator starts over again from the beginning.
		0 0 PBM_STEPIT SendMessage:SelfDrop ;M

;Class
\ *G End of Progressbar class

\ ------------------------------------------------------------------------
\ *W <a name="SmoothProgressbar"></a>
\ *S SmoothProgressbar class
\ ------------------------------------------------------------------------
:Class SmoothProgressbar <Super Progressbar
\ *G Progressbar control
\ ** A progress bar is a window that an application can use to indicate the progress
\ ** of a lengthy operation. It consists of a rectangle that is gradually filled with
\ ** the system highlight color as an operation progresses.
\ *P The progress bar displays progress status in a smooth scrolling bar instead of the
\ ** default segmented bar.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: PBS_SMOOTH.
		WindowStyle: super PBS_SMOOTH OR ;M

;Class
\ *G End of SmoothProgressbar class

MODULE

\ *Z
