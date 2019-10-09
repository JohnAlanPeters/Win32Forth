\ $Id: Label.f,v 1.4 2013/03/15 00:23:07 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -Label.f

WinLibrary COMCTL32.DLL

cr .( Loading Label Classes...)

INTERNAL
EXTERNAL

\ ------------------------------------------------------------------------
\ *W <a name="Label"></a>
\ *S Label class
\ ------------------------------------------------------------------------
:Class Label		<super StaticControl
\ *G Class for static controls

:M Setfont:     ( handle -- )
\ *G Set the font in the control.
                1 swap WM_SETFONT SendMessage:SelfDrop ;M

;Class
\ *G End of Label class

\ ------------------------------------------------------------------------
\ *W <a name="StaticImage"></a>
\ *S StaticImage class
\ ------------------------------------------------------------------------
|Class StaticImage	<Super Label
\ *G Base class for static control showing an image.
\ ** This is an internal class; don't use it directly.

:M ImageType:	( -- ImageType )
\ *G Get the image type of the control. \i ImageType \d is IMAGE_BITMAP.
		IMAGE_BITMAP ;M

:M GetImage:	( -- hImage )
\ *G Retrieve a handle to the image associated with the control.
		0 ImageType: [ self ] STM_GETIMAGE SendMessage:Self ;M

:M SetImage:	( hImage -- )
\ *G Associate a new image (icon or bitmap) with the control.
		GetImage: self over <>
		if   ImageType: [ self ] STM_SETIMAGE SendMessage:SelfDrop
		else drop
		then ;M

:M SetFont:     ( fhndl -- )
\ *G Set the font in the control.
                drop ;M

;Class
\ *G End of StaticImage class

\ ------------------------------------------------------------------------
\ *W <a name="StaticBitmap"></a>
\ *S StaticBitmap class
\ ------------------------------------------------------------------------
:Class StaticBitmap	<Super StaticImage
\ *G Static control showing a bitmap.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: SS_BITMAP.
		WindowStyle: super SS_BITMAP OR ;M

;Class
\ *G End of StaticImage class

\ ------------------------------------------------------------------------
\ *W <a name="StaticIcon"></a>
\ *S StaticIcon class
\ ------------------------------------------------------------------------
:Class StaticIcon	<Super StaticImage
\ *G Static control showing an icon.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: SS_ICON.
		WindowStyle: super SS_ICON OR ;M

:M ImageType: 	( -- ImageType )
\ *G Get the image type of the control. \i ImageType \d is IMAGE_ICON.
		IMAGE_ICON ;M

;Class
\ *G End of StaticIcon class

\ ------------------------------------------------------------------------
\ *W <a name="StaticMetafile"></a>
\ *S StaticMetafile class
\ ------------------------------------------------------------------------
:Class StaticMetafile	<Super StaticImage
\ *G Static control showing an enhanced metafile.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. Default style is: SS_ENHMETAFILE.
		WindowStyle: super SS_ENHMETAFILE OR ;M

:M ImageType: 	( -- ImageType )
\ *G Get the image type of the control. \i ImageType \d is IMAGE_ENHMETAFILE.
		IMAGE_ENHMETAFILE ;M

;Class
\ *G End of StaticMetafile class

\ ------------------------------------------------------------------------
\ *W <a name="StaticFrame"></a>
\ *S StaticFrame class
\ ------------------------------------------------------------------------
:Class StaticFrame	<Super Label
\ *G Static control showing a frame.

:M BlackRect:	( -- )
\ *G Rectangle in the window frame color (default is black).
		WindowStyle: super  SS_BLACKRECT OR  SetStyle: self ;M

:M GrayRect:	( -- )
\ *G Rectangle in the screen background color (default is gray).
		WindowStyle: super  SS_GRAYRECT OR  SetStyle: self ;M

:M WhiteRect:	( -- )
\ *G Rectangle in the window background color (default is white).
		WindowStyle: super  SS_WHITERECT OR  SetStyle: self ;M

:M BlackFrame:	( -- )
\ *G Frame in the window frame color (default is black).
		WindowStyle: super  SS_BLACKFRAME OR  SetStyle: self ;M

:M GrayFrame:	( -- )
\ *G Frame in the screen background color (default is gray).
		WindowStyle: super  SS_GRAYFRAME OR  SetStyle: self ;M

:M WhiteFrame:	( -- )
\ *G Frame in the window background color (default is white).
		WindowStyle: super  SS_WHITEFRAME OR  SetStyle: self ;M

:M EtchedFrame:	( -- )
\ *G draws an etched frame (frame appears lower than background)
		WindowStyle: super  SS_ETCHEDFRAME OR  SetStyle: self ;M

:M SunkenFrame:	( -- )
\ *G Draws frame with half-sunken border.
		WindowStyle: super  SS_SUNKEN OR  SetStyle: self ;M

;Class
\ *G End of StaticFrame class

MODULE

\ *Z
