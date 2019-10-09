\ $Id: ButtonBar.f,v 1.4 2011/11/18 11:08:05 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -ButtonBar.f

WinLibrary COMCTL32.DLL

cr .( Loading ButtonBar Class...)

INTERNAL
EXTERNAL

\ *T ExControls -- More (enhanced) classes for non-standard windows controls.

\ ------------------------------------------------------------------------
\ *W <a name="VertButtonBar"></a>
\ *S VertButtonBar class
\ ------------------------------------------------------------------------
:Class VertButtonBar	<super VButtonBar
\ *G VertButtonBar control
\ *P This is an enhanced Version of the VButtonBar class.
\ *P Note: this control isn't one of the standard control of MS windows.
:M SetFont:     { fonthndl \ hb1 -- }
\ *G Set the font in the control.
                hbb to hb1
                begin  hb1
                while  fonthndl GetID: hb1 SetDlgItemFont: self
                       GetPrev: hb1 to hb1
                repeat ;M

:M Enable:     	{ flag \ hb1 -- }
\ *G Enable the control.
                hbb to hb1
                begin  hb1
                while  flag GetID: hb1 EnableDlgitem: self
                       GetPrev: hb1 to hb1
                repeat ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class
\ *G End of VertButtonBar class

\ ------------------------------------------------------------------------
\ *W <a name="HorizButtonBar"></a>
\ *S HorizButtonBar class
\ ------------------------------------------------------------------------
:Class HorizButtonBar	<super HButtonBar
\ *G HorizButtonBar control
\ *P This is an enhanced Version of the HButtonBar class.
\ *P Note: this control isn't one of the standard control of MS windows.

:M SetFont:     { fonthndl \ hb1 -- }
\ *G Set the font in the control.
                hbb to hb1
                begin  hb1
                while  fonthndl GetID: hb1 SetDlgItemFont: self
                       GetPrev: hb1 to hb1
                repeat ;M

:M Enable:     	{ flag \ hb1 -- }
\ *G Enable the control.
                hbb to hb1
                begin  hb1
                while  flag GetID: hb1 EnableDlgitem: self
                       GetPrev: hb1 to hb1
                repeat ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class
\ *G End of HorizButtonBar class

MODULE

\ *Z
