\ $Id: RebarControl.f,v 1.9 2013/03/15 00:23:07 georgeahubert Exp $

\ RebarControl.f       Rebar Control Class

\ Changed to use Control rather than Child-Window
\ Added more methods - Sunday, June 04 2006  21:20:10 Rod

cr .( Loading RebarControl.f : RebarControl Class...)

WinLibrary COMCTL32.DLL

:Class RebarControl   <Super Control

Record: REBARBANDINFO
    int     binfoSize
    int     bfMask
    int     fStyle
    int     clrFore
    int     clrBack
    int     lpText
    int     cch
    int     iImage
    int     hwndChild
    int     cxMinChild
    int     cyMinChild
    int     cx
    int     hbmBack
    int     wID
    int     cyChild
    int     cyMaxChild
    int     cyIntegral
    int     cxIdeal
    int     lParam
    int     cxHeader
;Recordsize: sizeof(REBARBANDINFO)

: Eraseband-info ( -- )
        REBARBANDINFO sizeof(REBARBANDINFO) dup>r erase
        r> to binfoSize ;

:M ClassInit: ( -- )
        ClassInit: super
        Eraseband-info ;M

:M WindowStyle: ( -- style )   [ WS_CHILD WS_VISIBLE or ] literal ;M

:M ExWindowStyle: ( -- style )   WS_EX_TOOLWINDOW ;M

:M AutoSize: ( -- )   0 0 WM_SIZE SendMessage:SelfDrop ;M

:M DeleteBand: ( uBand -- )   0 swap RB_DELETEBAND SendMessage:SelfDrop ;M

:M EndDrag: ( -- )   0 0 RB_ENDDRAG SendMessage:SelfDrop ;M

:M GetBarHeight: ( -- h )   0 0 RB_GETBARHEIGHT SendMessage:SelfDrop ;M

:M Height: ( -- h )   GetWindowRect: self nip swap - nip ;M

Record: RBHITTESTINFO
    int x
    int y
    int flags
    int ib
;Record

:M HitTest: ( -- uBand )
        hWnd get-mouse-XY to y to x
        RBHITTESTINFO 0  RB_HITTEST  SendMessage:Self ;M

:M IdToIndex: ( uBandID -- uBand )   0 swap RB_IDTOINDEX SendMessage:Self ;M

:M InsertBandAt: ( uBand -- )   REBARBANDINFO swap RB_INSERTBAND SendMessage:SelfDrop ;M

:M InsertBand: ( -- )   -1 InsertBandAt: self ;M   \ band info should have been set

:M MaximizeBand: ( fIdeal uBand -- )   RB_MAXIMIZEBAND SendMessage:SelfDrop ;M

:M MinimizeBand: ( uBand -- )   0 swap RB_MINIMIZEBAND SendMessage:SelfDrop ;M

:M SetBarInfo: ( himl fmask -- )   12 sp@ 0 RB_SETBARINFO SendMessage:SelfDrop 3drop ;M

:M ShowBand: ( f uBand -- )   RB_SHOWBAND SendMessage:SelfDrop ;M

:M Start: ( Parent -- )
        hWnd
        if  drop
            SW_SHOWNOACTIVATE Show: self
        else
            to Parent
            \ Make sure Common Controls are loaded
            ICC_COOL_CLASSES 8 sp@ Call InitCommonControlsEx 3drop
            z" ReBarWindow32" Create-Control
            0 0 SetBarInfo: self
        then ;M

((
\ Not yet used/tested
:M BeginDrag: ( uBand -- )  ( GetHandle: self get-mouse-XY word-join ) -1  swap RB_BEGINDRAG SendMessage:SelfDrop ;M
:M DragMove: ( -- )   -1 0 RB_DRAGMOVE SendMessage:SelfDrop ;M
:M GetBandBorders: ( rect uBand -- )   0 RB_GETBANDBORDERS SendMessage:SelfDrop ;M
:M GetBandCount: ( -- n )   0 0 RB_GETBANDCOUNT SendMessage:Self ;M
:M GetBkColor: ( -- clrBk )   0 0 RB_GETBKCOLOR SendMessage:Self ;M
:M GetPalette: ( -- hpal )   0 0 RB_GETPALETTE SendMessage:Self ;M
:M GetRect: ( rect uBand -- )   0 RB_GETRECT SendMessage:SelfDrop ;M
:M GetRowCount: ( -- n )   0 0 RB_GETROWCOUNT SendMessage:Self ;M
:M GetRowHeight: ( iRow -- height )   0 swap RB_GETROWHEIGHT SendMessage:Self ;M
:M GetTextColor: ( -- clrText )   0 0 RB_GETTEXTCOLOR SendMessage:Self ;M
:M GetToolTips: ( -- hwndToolTip )   0 0 RB_GETTOOLTIPS SendMessage:Self ;M
:M MoveBand: ( iTo iFrom -- )    RB_MOVEBAND SendMessage:SelfDrop ;M
:M SetBandInfo: ( uBand -- )   REBARBANDINFO swap RB_SETBANDINFO SendMessage:SelfDrop ;M
:M SetBkColor: ( clrBk -- )   0 swap RB_SETBKCOLOR SendMessage:SelfDrop ;M
:M SetPalette: ( hpal -- )   0 swap RB_SETPALETTE SendMessage:SelfDrop ;M
:M SetParent: ( hwndParent -- )   0 swap RB_SETPARENT SendMessage:SelfDrop ;M
:M SetTextColor: ( clrText -- )   0 RB_SETTEXTCOLOR SendMessage:SelfDrop ;M
:M SetToolTips: ( hwndToolTip -- )   0 swap RB_SETTOOLTIPS SendMessage:SelfDrop ;M
:M SizeToRect: ( rect -- )   0 RB_SIZETORECT SendMessage:SelfDrop ;M
))
;Class


\s
**************************** Some Information On Rebar Controls *******************************

Rebar controls act as containers for child windows. An application assigns child
windows, which are often other controls, to a rebar control band. Rebar
controls contain one or more bands, and each band can have any combination of a
gripper bar, a bitmap, a text label, and a child window. However, bands cannot
contain more than one child window.

A rebar control displays the child window over a specified background bitmap. As
you dynamically reposition a rebar control band, the rebar control manages the
size and position of the child window assigned to that band.


Note  The rebar control is implemented in version 4.70 and later of Comctl32.dll.

Rebar Bands and Child Windows

An application defines a rebar band's traits by using the RB_INSERTBAND and
RB_SETBANDINFO messages. These messages accept the address of a REBARBANDINFO
structure as the lParam parameter. The REBARBANDINFO structure members define
the traits of a given band. To set a band's traits, set the cbsize member to
indicate the size of the structure, in bytes. Then set the fMask member to
indicate which structure members your application is filling.

To assign a child window to a band, include the RBBIM_CHILD flag in the fMask
member of the REBARBANDINFO structure, and then set the hwndChild member to the
child window's handle. Applications can set the minimum allowable width and
height of a child window in the cxMinChild and cyMinChild members.

When a rebar control is destroyed, it destroys any child windows assigned to the
bands within it. To prevent the control from destroying child windows assigned
to its bands, remove the bands by sending the RB_DELETEBAND message, and then
reset the parent to another window with the SetParent function before destroying
the rebar control.

The Rebar Control User Interface

All rebar control bands can be resized, except those that use the RBBS_FIXEDSIZE
style. To resize or change the order of bands within the control, click and drag
a band's gripper bar. The rebar control automatically resizes and repositions
child windows assigned to its bands. Additionally, you can toggle the size of
a band by clicking the band text, if there is any.

The Rebar Control's Image List

If an application is using an image list with a rebar control, it must send the
RB_SETBARINFO message before adding bands to the control. This message accepts
the address of a REBARINFO structure as the lParam parameter. Before
sending the message, prepare the REBARINFO structure by setting the cbSize
member to the size of the structure, in bytes. Then, if the rebar control is
going to display images on the bands, set the fMask member to the RBIM_IMAGELIST
flag and assign an image list handle to the himl member. If the rebar will not
use band images, set fMask to zero.

Rebar Control Message Forwarding

A rebar control forwards all WM_NOTIFY window messages to its parent window.
Additionally, a rebar control forwards any messages sent to it from windows
assigned to its bands, like WM_CHARTOITEM, WM_COMMAND, and others.
Custom Draw Support

Rebar controls support custom draw functionality. For more information,
see Customizing a Control's Appearance Using Custom Draw.
Using Rebar Controls

This section gives sample code that demonstrates how to implement a rebar control.
Creating a Rebar Control

An application creates a rebar control by calling the CreateWindowEx function,
 specifying REBARCLASSNAME as the window class. The application must first register
 the window class by calling the InitCommonControlsEx function, while specifying
the ICC_COOL_CLASSES bit in the accompanying INITCOMMONCONTROLSEX structure.

RB_INSERTBAND Message

Inserts a new band in a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_INSERTBAND, 	    \ message ID
   (WPARAM) wParam, 	    \ = (WPARAM) (UINT) uIndex;
   (LPARAM) lParam 	    \ = (LPARAM) (LPREBARBANDINFO) lprbbi;
);

Parameters
uIndex
Zero-based index of the location where the band will be inserted. If you set
this parameter to -1, the control will add the new band at the last location.
lprbbi
Pointer to a REBARBANDINFO structure that defines the band to be inserted. You
must set the cbSize member of this structure to sizeof(REBARBANDINFO) before
sending this message.

Return Value

Returns nonzero if successful, or zero otherwise.


REBARBANDINFO Structure

Contains information that defines a band in a rebar control.

Syntax

typedef struct tagREBARBANDINFO{
    UINT             cbSize;
    UINT             fMask;
    UINT             fStyle;
    COLORREF    clrFore;
    COLORREF    clrBack;
    LPTSTR         lpText;
    UINT             cch;
    int                 iImage;
    HWND           hwndChild;
    UINT             cxMinChild;
    UINT             cyMinChild;
    UINT             cx;
    HBITMAP       hbmBack;
    UINT             wID;
#if (_WIN32_IE >= 0x0400)
    UINT            cyChild;
    UINT            cyMaxChild;
    UINT            cyIntegral;
    UINT            cxIdeal;
    LPARAM        lParam;
    UINT            cxHeader;
#endif
 } REBARBANDINFO, *LPREBARBANDINFO;


Members
cbSize
Size of this structure, in bytes. Your application must fill this member before
sending any messages that use the address of this structure as a parameter.

FMASK
Flags that indicate which members of this structure are valid or must be filled.
 This value can be a combination of the following:

RBBIM_BACKGROUND
The hbmBack member is valid or must be filled.

RBBIM_CHILD
The hwndChild member is valid or must be filled.

RBBIM_CHILDSIZE
The cxMinChild, cyMinChild, cyChild, cyMaxChild, and cyIntegral members are
valid or must be filled.

RBBIM_COLORS
The clrFore and clrBack members are valid or must be filled.

RBBIM_HEADERSIZE
Version 4.71. The cxHeader member is valid or must be filled.

RBBIM_IDEALSIZE
Version 4.71. The cxIdeal member is valid or must be filled.

RBBIM_ID
The wID member is valid or must be filled.

RBBIM_IMAGE
The iImage member is valid or must be filled.

RBBIM_LPARAM
Version 4.71. The lParam member is valid or must be filled.

RBBIM_SIZE
The cx member is valid or must be filled.

RBBIM_STYLE
The fStyle member is valid or must be filled.

RBBIM_TEXT
The lpText member is valid or must be filled.


FSTYLE
Flags that specify the band style. This value can be a combination of the following:

RBBS_BREAK
The band is on a new line.

RBBS_CHILDEDGE
The band has an edge at the top and bottom of the child window.

RBBS_FIXEDBMP
The background bitmap does not move when the band is resized.

RBBS_FIXEDSIZE
The band can't be sized. With this style, the sizing grip is not displayed on
the band.

RBBS_GRIPPERALWAYS
Version 4.71. The band will always have a sizing grip, even if it is the only
band in the rebar.

RBBS_HIDDEN
The band will not be visible.

RBBS_NOGRIPPER
Version 4.71. The band will never have a sizing grip, even if there is more than
 one band in the rebar.

RBBS_USECHEVRON
Version 5.80. Show a chevron button if the band is smaller than cxIdeal.

RBBS_VARIABLEHEIGHT
Version 4.71. The band can be resized by the rebar control; cyIntegral and
cyMaxChild affect how the rebar will resize the band.

clrFore
Band foreground colors.

clrBack
Band background colors. If hbmBack specifies a background bitmap, these members
 are ignored. By default, the band will use the background color of the rebar
 control set with the RB_SETBKCOLOR message. If a background color is specified
here, then this background color will be used instead.

lpText
Pointer to a buffer that contains the display text for the band. If band
information is being requested from the control and RBBIM_TEXT is specified in
fMask, this member must be initialized to the address of the buffer that will
 receive the text.

cch
Size of the buffer at lpText, in bytes. If information is not being requested
from the control, this member is ignored.

iImage
Zero-based index of any image that should be displayed in the band. The image
 list is set using the RB_SETBARINFO message.

hwndChild
Handle to the child window contained in the band, if any.

cxMinChild
Minimum width of the child window, in pixels. The band can't be sized smaller
than this value.

cyMinChild
Minimum height of the child window, in pixels. The band can't be sized smaller
 than this value.

cx
Length of the band, in pixels.

hbmBack
Handle to a bitmap that is used as the background for this band.

wID
UINT value that the control uses to identify this band for custom draw
notification messages.

cyChild
Version 4.71. Initial height of the band, in pixels. This member is ignored
 unless the RBBS_VARIABLEHEIGHT style is specified.

cyMaxChild
Version 4.71. Maximum height of the band, in pixels. This member is ignored
unless the RBBS_VARIABLEHEIGHT style is specified.

cyIntegral
Version 4.71. Step value by which the band can grow or shrink, in pixels. If the
 band is resized, it will be resized in steps specified by this value. This
member is ignored unless the RBBS_VARIABLEHEIGHT style is specified.

cxIdeal
Version 4.71. Ideal width of the band, in pixels. If the band is maximized to
 the ideal width (see RB_MAXIMIZEBAND), the rebar control will attempt to make
 the band this width.

lParam
Version 4.71. Application-defined value.

cxHeader
Version 4.71. Size of the band's header, in pixels. The band header is the area
 between the edge of the band and the edge of the child window. This is the area
 where band text and images are displayed, if they are specified. If this value
 is specified, it will override the normal header dimensions that the control
calculates for the band.

Remarks

The cxMinChild, cyMinChild, and cx members provide information on dimensions
relative to the orientation of the control. That is, for a horizontal rebar control,
 cxMinChild and cx are horizontal measurements and cyMinChild is a vertical measurement.
 However, if the control uses the CCS_VERT style, cxMinChild and cx are vertical
 measurements and cyMinChild is a horizontal measurement.


RB_SETBARINFO Message

Sets the characteristics of a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_SETBARINFO, 	    \ message ID
   (WPARAM) wParam, 	    \ = 0; not used, must be zero
   (LPARAM) lParam 	    \ = (LPARAM) (LPREBARINFO) lprbi;
);

Parameters
wParam
Must be zero.
lprbi
Pointer to a REBARINFO structure that contains the information to be set. You
 must set the cbSize member of this structure to sizeof(REBARINFO) before
sending this message.

Return Value
Returns nonzero if successful, or zero otherwise.

REBARINFO Structure

Contains information that describes rebar control characteristics.

Syntax

typedef struct tagREBARINFO {
    UINT cbSize;
    UINT fMask;
    HIMAGELIST himl;
} REBARINFO, *LPREBARINFO;

Members
cbSize
Size of this structure, in bytes. Your application must fill this member before
 sending any messages that use the address of this structure as a parameter.

fMask
Flag values that describe characteristics of the rebar control. Currently, rebar
 controls support only one value:

RBIM_IMAGELIST
The himl member is valid or must be filled.

himl
Handle to an image list. The rebar control will use the specified image list to
 obtain images.


Rebar Control Styles

Rebar controls support a variety of control styles in addition to standard window styles.

Constants
RBS_AUTOSIZE
Version 4.71. The rebar control will automatically change the layout of the
bands when the size or position of the control changes. An RBN_AUTOSIZE
notification will be sent when this occurs.

RBS_BANDBORDERS
Version 4.71. The rebar control displays narrow lines to separate adjacent bands.

RBS_DBLCLKTOGGLE
Version 4.71. The rebar band will toggle its maximized or minimized state when
 the user double-clicks the band. Without this style, the maximized or minimized
state is toggled when the user single-clicks on the band.

RBS_FIXEDORDER
Version 4.70. The rebar control always displays bands in the same order. You can
move bands to different rows, but the band order is static.

RBS_REGISTERDROP
Version 4.71. The rebar control generates RBN_GETOBJECT notification messages
when an object is dragged over a band in the control. To receive the RBN_
GETOBJECT notifications, initialize OLE with a call to OleInitialize or
CoInitialize.

RBS_TOOLTIPS
Version 4.71. Not yet supported.

RBS_VARHEIGHT
Version 4.71. The rebar control displays bands at the minimum required height,
when possible. Without this style, the rebar control displays all bands at the
same height, using the height of the tallest visible band to determine the
height of other bands.

RBS_VERTICALGRIPPER
Version 4.71. The size grip will be displayed vertically instead of horizontally
 in a vertical rebar control. This style is ignored for rebar controls that do
 not have the CCS_VERT style.

RB_DELETEBAND Message

Deletes a band from a rebar control.

Syntax

To send this message, call the SendMessage function as follows.

lResult = SendMessage(     \ returns LRESULT in lResult
   (HWND) hWndControl,     \ handle to destination control
   (UINT) RB_DELETEBAND,     \ message ID
   (WPARAM) wParam,     \ = (WPARAM) (UINT) uBand;
   (LPARAM) lParam     \ = 0; not used, must be zero
);

Parameters

uBand
Zero-based index of the band to be deleted. lParam
Must be zero.

Return Value
Returns nonzero if successful, or zero otherwise.


NMREBAR Structure

Contains information used in handling various rebar notification messages.

Syntax

typedef struct tagNMREBAR {
    NMHDR hdr;
    DWORD dwMask;
    UINT uBand;
    UINT fStyle;
    UINT wID;
    LPARAM lParam;
} NMREBAR, *LPNMREBAR;

Members

hdr
NMHDR structure that contains additional information about the notification
message. dwMask Set of flags that define which members of this structure
contain valid information. This can be one or more of the following values:

    RBNM_ID
    The wID member contains valid information. RBNM_LPARAM
    The lParam member contains valid information. RBNM_STYLE
The fStyle member contains valid information.
uBand
Zero-based index of the band affected by the notification.  This will be -1 if
no band is affected. fStyle The style of the band. This is one or more of the
RBBS_ styles detailed in the fStyle member of the REBARBANDINFO  structure.
This member is only valid if dwMask contains RBNM_STYLE. wID
Application-defined identifier of the band. This member is only  valid if
dwMask contains RBNM_ID. lParam Application-defined value associated with the
band. This member is only valid if dwMask contains RBNM_LPARAM.

RB_GETBANDCOUNT Message

Retrieves the count of bands currently in the rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_GETBANDCOUNT, 	    \ message ID
   (WPARAM) wParam, 	    \ = 0; not used, must be zero
   (LPARAM) lParam 	    \ = 0; not used, must be zero
);

Parameters
wParam
Must be zero.
lParam
Must be zero.

Return Value
Returns a UINT value that represents the number of bands assigned to the control.

RB_GETBANDINFO Message

Retrieves information about a specified band in a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_GETBANDINFO, 	    \ message ID
   (WPARAM) wParam, 	    \ = (WPARAM) (UINT) uBand;
   (LPARAM) lParam 	    \ = (LPARAM) (LPREBARBANDINFO) lprbbi;
);

Parameters
uBand
Zero-based index of the band for which the information will be retrieved.
lprbbi
Pointer to a REBARBANDINFO structure that will receive the requested band information.
Before sending this message, you must set the cbSize member of this structure to the size
of the REBARBANDINFO structure and set the fMask member to the items you want to retrieve.
Additionally, you must set the cch member of the REBARBANDINFO structure to the size of the
lpText buffer when RBBIM_TEXT is specified.

Return Value
Returns nonzero if successful, or zero otherwise.

RB_GETRECT Message

Retrieves the bounding rectangle for a given band in a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_GETRECT, 	    \ message ID
   (WPARAM) wParam, 	    \ = (WPARAM) (UINT) uBand;
   (LPARAM) lParam 	    \ = (LPARAM) (LPRECT) lprc;
);

Parameters
uBand
Zero-based index of a band in the rebar control.
lprc
Pointer to a RECT structure that will receive the bounds of the rebar band.

Return Value
Returns nonzero if successful, or zero otherwise.

RB_GETROWHEIGHT Message

Retrieves the height of a specified row in a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_GETROWHEIGHT, 	    \ message ID
   (WPARAM) wParam, 	    \ = (WPARAM) (UINT) uBand;
   (LPARAM) lParam 	    \ = 0; not used, must be zero
);

Parameters
uBand
Zero-based index of a band. The height of the row that contains the specified band will be
retrieved.
lParam
Must be zero.

Return Value
Returns a UINT value that represents the row height, in pixels.


Remarks

To retrieve the number of rows in a rebar control, use the RB_GETROWCOUNT message.

RB_GETROWCOUNT Message

Retrieves the number of rows of bands in a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_GETROWCOUNT, 	    \ message ID
   (WPARAM) wParam, 	    \ = 0; not used, must be zero
   (LPARAM) lParam 	    \ = 0; not used, must be zero
);

Parameters
wParam
Must be zero.
lParam
Must be zero.

Return Value
Returns a UINT value that represents the number of band rows in the control.

RB_GETBARHEIGHT Message

Retrieves the height of the rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_GETBARHEIGHT, 	    \ message ID
   (WPARAM) wParam, 	    \ = 0; not used, must be zero
   (LPARAM) lParam 	    \ = 0; not used, must be zero
);

Parameters
wParam
Must be zero.
lParam
Must be zero.

Return Value
Returns a UINT value that represents the height, in pixels, of the control.

RB_SETBANDINFO Message

Sets characteristics of an existing band in a rebar control.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_SETBANDINFO, 	    \ message ID
   (WPARAM) wParam, 	    \ = (WPARAM) (UINT) uBand;
   (LPARAM) lParam 	    \ = (LPARAM) (LPREBARBANDINFO) lprbbi;
);

Parameters
uBand
Zero-based index of the band to receive the new settings.
lprbbi
Pointer to a REBARBANDINFO structure that defines the band to be modified and the new settings.
Before sending this message, you must set the cbSize member of this structure to the
sizeof(REBARBANDINFO) structure. Additionally, you must set the cch member of the REBARBANDINFO
structure to the size of the lpText buffer when RBBIM_TEXT is specified.

Return Value
Returns nonzero if successful, or zero otherwise.

RB_SETPARENT Message

Sets a rebar control's parent window.

Syntax

To send this message, call the SendMessage function as follows.
lResult = SendMessage( 	    \ returns LRESULT in lResult
   (HWND) hWndControl, 	    \ handle to destination control
   (UINT) RB_SETPARENT, 	    \ message ID
   (WPARAM) wParam, 	    \ = (WPARAM) (HWND) hwndParent;
   (LPARAM) lParam 	    \ = 0; not used, must be zero
);

Parameters
hwndParent
Handle to the parent window to be set.
lParam
Must be zero.

Return Value

Returns the handle to the previous parent window, or NULL if there is no previous parent.


Remarks

The rebar control sends notification messages to the window you specify with this message.
This message does not actually change the parent of the rebar control.
