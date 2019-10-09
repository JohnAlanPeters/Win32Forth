\ *D doc\classes\
\ *! gdiBrush
\ *T GdiBrush -- Classes for GDI Brushes.
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch

cr .( Loading GDI class library - Brush...)

needs gdiBase.f

internal
external

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
internal

\ *W <a name="gdiBrush"></a>
\ *S gdiBrush class
:class gdiBrush <super gdiObject
\ *G Base class for all brush objects. \n
\ ** This is an internal class of the GDI Class library. Don't use it yourself.

gdiPoint origin

:M ClassInit:   ( -- )
        ClassInit: super
        ;M

:M SetOrigin:   { xOrg yOrg hdc -- }
\ *G Set the brush origin that GDI assigns to the next brush an application selects
\ ** into the specified device context. \n
\ ** Note: hdc can be the address of a gdiDC class instance or a DC handle. \n
\ ** A brush is a bitmap that the system uses to paint the interiors of filled shapes. \n
\ ** The brush origin is a pair of coordinates specifying the location of one pixel in
\ ** the bitmap. The default brush origin coordinates are (0,0). For horizontal coordinates,
\ ** the value 0 corresponds to the leftmost column of pixels; the width corresponds to the
\ ** rightmost column. For vertical coordinates, the value 0 corresponds to the uppermost
\ ** row of pixels; the height corresponds to the lowermost row. \n
\ ** The system automatically tracks the origin of all window-managed device contexts and
\ ** adjusts their brushes as necessary to maintain an alignment of patterns on the surface.
\ ** The brush origin that is set with this call is relative to the upper-left corner of the
\ ** client area. \n
\ ** An application should call SetOrigin: after setting the bitmap stretching mode to
\ ** HALFTONE by using SetStretchBltMode. This must be done to avoid brush misalignment. \n
\ ** Windows NT/ 2000: The system automatically tracks the origin of all window-managed device
\ ** contexts and adjusts their brushes as necessary to maintain an alignment of patterns on
\ ** the surface. \n
\ ** Windows 95/98: Automatic tracking of the brush origin is not supported. Applications must
\ ** use the UnrealizeObject, SetBrushOrgEx, and SelectObject functions to align the brush before
\ ** using it. \n
        NULL yOrg xOrg hdc GetGdiObjectHandle call SetBrushOrgEx ?win-error ;M

:M GetOrigin:   ( hdc -- xOrg yOrg )
\ *G Get the current brush origin for the specified device context.
        Addr: origin call GetBrushOrgEx 0=
        if   -1 -1 \ error
        else GetX: origin GetY: origin
        then ;M

:M Create:      ( lplb -- f )
\ *G The Create function creates a logical brush that has the specified style, color, and pattern.
\ ** lplb Pointer to a LOGBRUSH structure that contains information about the brush.
        call CreateBrushIndirect SetHandle: super
        Valid?: super ;M

;class
\ *G End of gdiBrush class

external

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
\ *W <a name="gdiSolidBrush"></a>
\ *S gdiSolidBrush class
:class gdiSolidBrush <super gdiBrush
\ *G Solid brush class

\ Color of the brush.
gdiCOLORREF Color

:M ClassInit:   ( -- )
        ClassInit: super
        ;M

:M SetRValue:   ( r -- )
\ *G Set the red component of the brush color.
        SetRValue: Color ;M

:M SetGValue:   ( g -- )
\ *G Set the green component of the brush color.
        SetGValue: Color ;M

:M SetBValue:   ( b -- )
\ *G Set the blue component of the brush color.
        SetBValue: Color ;M

:M SetRGB:      ( r g b -- )
\ *G Set the red, green and blue component of the brush color.
        SetRGB: Color ;M

:M SetColor:    ( colorref -- )
\ *G Set color of the brush.
        SetColor: Color ;M

:M SetSysColor: ( n -- )
\ *G Set the color of the brush to a system color.
        SetSysColor: Color ;M

:M ChooseColor: ( hWnd -- f )
\ *G Open a dialog to choose the color of the brush.
        Choose: Color ;M

:M GetRValue:   ( -- r )
\ *G Get the red component of the brush color.
        GetRValue: Color ;M

:M GetGValue:   ( -- g )
\ *G Get the green component of the brush color.
        GetGValue: Color ;M

:M GetBValue:   ( -- b )
\ *G Get the blue component of the brush color.
        GetBValue: Color ;M

:M GetColor:    ( -- colorref )
\ *G Get the color of the brush as a windows COLORREF value.
        GetColor: Color ;M

:M Create:      ( -- f )
\ *G Create the brush with the current color.
        GetColor: color call CreateSolidBrush SetHandle: super
        Valid?: super ;M

;class
\ *G End of gdiSolidBrush class

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
\ *W <a name="gdiHatchBrush"></a>
\ *S gdiHatchBrush class
:class gdiHatchBrush <super gdiSolidBrush
\ *G Hatch brush class

\ Style of the brush. Possible values are:
\ HS_BDIAGONAL  45-degree downward left-to-right hatch
\ HS_CROSS      Horizontal and vertical crosshatch
\ HS_DIAGCROSS  45-degree crosshatch
\ HS_FDIAGONAL  45-degree upward left-to-right hatch
\ HS_HORIZONTAL Horizontal hatch
\ HS_VERTICAL   Vertical hatch
int Style

:M ClassInit:   ( -- )
        ClassInit: super
        HS_BDIAGONAL to style
        ;M

:M SetStyle:    ( style -- )
\ *G Set the style of the brush. Possible values are:
\ *L
\ *| HS_BDIAGONAL  | 45-degree downward left-to-right hatch     |
\ *| HS_CROSS      | Horizontal and vertical crosshatch         |
\ *| HS_DIAGCROSS  | 45-degree crosshatch                       |
\ *| HS_FDIAGONAL  | 45-degree upward left-to-right hatch       |
\ *| HS_HORIZONTAL | Horizontal hatch                           |
\ *| HS_VERTICAL   | Vertical hatch                             |
        to style ;M

:M GetStyle:    ( -- style )
\ *G Get the style of the brush. Possible return values are:
\ *L
\ *| HS_BDIAGONAL  | 45-degree downward left-to-right hatch     |
\ *| HS_CROSS      | Horizontal and vertical crosshatch         |
\ *| HS_DIAGCROSS  | 45-degree crosshatch                       |
\ *| HS_FDIAGONAL  | 45-degree upward left-to-right hatch       |
\ *| HS_HORIZONTAL | Horizontal hatch                           |
\ *| HS_VERTICAL   | Vertical hatch                             |
        style ;M

:M Create:      ( -- f )
\ *G Create the brush with the current style and color.
        GetColor: color Style call CreateHatchBrush SetHandle: super
        Valid?: super ;M

;class
\ *G End of gdiHatchBrush class

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
\ *W <a name="gdiPatternBrush"></a>
\ *S gdiPatternBrush class
:class gdiPatternBrush <super gdiBrush
\ *G Pattern brush class. \n

\ Bitmap of the brush.
int Bitmap

:M ClassInit:   ( -- )
        ClassInit: super
        0 to Bitmap
        ;M

:M SetBitmap:   ( Bitmap -- )
\ *G Set the Bitmap for the PatternBrush. The Bitmap can be a DIB section bitmap,
\ ** which is created by the CreateDIBSection function.
        to Bitmap ;M

:M GetBitmap:   ( -- Bitmap )
\ *G Get the Bitmap for the PatternBrush.
        Bitmap ;M

:M Create:      ( -- f )
\ *G Creates a logical brush with the specified bitmap pattern.
        Bitmap ?dup if call CreatePatternBrush SetHandle: super then
        Valid?: super ;M

;class
\ *G End of gdiPatternBrush class

\ ----------------------------------------------------------------------
\ DIBPattern brush class
\ ----------------------------------------------------------------------
\ *W <a name="gdiDIBPatternBrush"></a>
\ *S gdiDIBPatternBrush class
:class gdiDIBPatternBrush <super gdiBrush
\ *G DIB Pattern brush class

:M ClassInit:   ( -- )
        ClassInit: super
        ;M

:M Create:      ( lpPackedDIB iUsage -- f )
\ *G The Create function creates a logical brush that has the pattern specified
\ ** by the device-independent bitmap (DIB).    \n
\ ** lpPackedDIB Pointer to a packed DIB consisting of a BITMAPINFO structure immediately
\ ** followed by an array of bytes defining the pixels of the bitmap.   \n
\ ** Windows 95: Creating brushes from bitmaps or DIBs larger than 8 by 8 pixels
\ ** is not supported. If a larger bitmap is specified, only a portion of the bitmap
\ ** is used.   \n
\ ** Windows NT/ 2000 and Windows 98: Brushes can be created from bitmaps or DIBs
\ ** larger than 8 by 8 pixels. \n
\ ** iUsage Specifies whether the bmiColors member of the BITMAPINFO structure contains
\ ** a valid color table and, if so, whether the entries in this color table contain
\ ** explicit red, green, blue (RGB) values or palette indexes. The iUsage parameter
\ ** must be one of the following values.
\ *L
\ *| DIB_PAL_COLORS | A color table is provided and consists of an array of 16-bit indexes into the logical palette of the device context into which the brush is to be selected. |
\ *| DIB_RGB_COLORS | A color table is provided and contains literal RGB values. |
        call CreateDIBPatternBrushPt SetHandle: super
        Valid?: super ;M

;class
\ *G End of gdiDIBPatternBrush class

module

\ *Z
