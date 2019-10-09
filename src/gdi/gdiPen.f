
\ *D doc\classes\
\ *! gdiPen
\ *T GdiPen -- Class for GDI Pens
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch

\ TODO: finish gdiGeometricPen class

cr .( Loading GDI class library - Pen...)

needs gdiBase.f

internal
external

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
\ *W <a name="gdiPen"></a>
\ *S gdiPen class
:class gdiPen <super gdiObject
\ *G Class for cosmetic pen's

\ Syle of the pen.
int Style

\ Width of the pen, in logical units. If Width is zero, the pen is a single pixel
\ wide, regardless of the current transformation.
int Width

\ Color of the pen.
gdiCOLORREF Color

:M ClassInit:   ( -- )
\ *G Init the class
        ClassInit: super

        PS_SOLID to Style
        1 to Width
        ;M

:M SetStyle:    ( style -- )
\ *G Set Syle of the pen. Possible values are:
\ *L
\ *| PS_SOLID       | The pen is solid. |
\ *| PS_DASH        | The pen is dashed. This style is valid only when the pen width is one or less in device units. |
\ *| PS_DOT         | The pen is dotted. This style is valid only when the pen width is one or less in device units. |
\ *| PS_DASHDOT     | The pen has alternating dashes and dots. This style is valid only when the pen width is one or less in device units. |
\ *| PS_DASHDOTDOT  | The pen has alternating dashes and double dots. This style is valid only when the pen width is one or less in device units. |
\ *| PS_NULL        | The pen is invisible. |
\ *| PS_INSIDEFRAME | The pen is solid. When this pen is used the dimensions of the figure are shrunk so that it fits entirely in the bounding rectangle, taking into account the width of the pen. Only for geometric pens. |
        to style ;M

:M SetWidth:    ( width -- )
\ *G Set the width of the pen in logical units. If Width is zero, the pen is a single pixel
\ ** wide, regardless of the current transformation.
    0 max to width ;M

:M SetRValue:   ( r -- )
\ *G Set the red component of the pen color.
        SetRValue: Color ;M

:M SetGValue:   ( g -- )
\ *G Set the green component of the pen color.
        SetGValue: Color ;M

:M SetBValue:   ( b -- )
\ *G Set the blue component of the pen color.
        SetBValue: Color ;M

:M SetRGB:      ( r g b -- )
\ *G Set the red, green and blue component of the pen color.
        SetRGB: Color ;M

:M SetColor:    ( colorref -- )
\ *G Set color of the pen.
        SetColor: Color ;M

:M SetSysColor: ( n -- )
\ *G Set the color of the pen to a system color.
        SetSysColor: Color ;M

:M ChooseColor: ( hWnd -- f )
\ *G Open a dialog to choose the color of the pen.
        Choose: Color ;M

:M GetStyle:    ( -- style )
\ *G Get Syle of the pen. Possible values are:
\ *L
\ *| PS_SOLID       | The pen is solid. |
\ *| PS_DASH        | The pen is dashed. This style is valid only when the pen width is one or less in device units. |
\ *| PS_DOT         | The pen is dotted. This style is valid only when the pen width is one or less in device units. |
\ *| PS_DASHDOT     | The pen has alternating dashes and dots. This style is valid only when the pen width is one or less in device units. |
\ *| PS_DASHDOTDOT  | The pen has alternating dashes and double dots. This style is valid only when the pen width is one or less in device units. |
\ *| PS_NULL        | The pen is invisible. |
\ *| PS_INSIDEFRAME | The pen is solid. When this pen is used the dimensions of the figure are shrunk so that it fits entirely in the bounding rectangle, taking into account the width of the pen. This applies only to geometric pens. |
        style ;M

:M GetWidth:    ( -- width )
\ *G Get the width of the pen in logical units. If the width is zero, the pen is a single pixel
\ ** wide, regardless of the current transformation.
        width ;M

:M GetRValue:   ( -- r )
\ *G Get the red component of the pen color.
        GetRValue: Color ;M

:M GetGValue:   ( -- g )
\ *G Get the green component of the pen color.
        GetGValue: Color ;M

:M GetBValue:   ( -- b )
\ *G Get the blue component of the pen color.
        GetBValue: Color ;M

:M GetColor:    ( -- colorref )
\ *G Get the color of the pen as a windows COLORREF value.
        GetColor: Color ;M

:M Create:      ( -- f )
\ *G Create the pen with the current style, color and width.
        GetColor: color width style call CreatePen SetHandle: super
        Valid?: super ;M

:M CreateIndirect: ( pLogpen -- f )
\ *G The CreateIndirect function creates a logical cosmetic pen that
\ ** has the style, width, and color specified in a structure.
        dup           @ SetStyle: self
        dup   cell+   @ SetWidth: self
        dup 3 cells + @ SetColor: self
        call CreatePenIndirect SetHandle: super
        Valid?: super ;M

;class
\ *G End of class

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
\ *W <a name="gdiGeometricPen"></a>
\ *S gdiGeometricPen class
:class gdiGeometricPen <super gdiObject
\ *G Class for geometric pen's   \n
\ ** Note: this class isn't implemented yet

:M ClassInit:   ( -- )
\ *G Init the class
        ClassInit: super
        ;M

;class
\ *G End of class

module

\ *Z
