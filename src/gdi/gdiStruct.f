\ *D doc\classes\
\ *! gdiStruct
\ *T gdiStruct -- Wrapper classes for GDI structs.
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch

cr .( Loading GDI class library - Structs...)

needs class.f

WinLibrary COMDLG32.DLL

internal

create CustomColors 64 allot \ hold the userdefined custom colors

\ init custom colors
0xE6FFFF CustomColors        !  0xFFE6FF CustomColors 0x04 + !  0xFFFFE6 CustomColors 0x08 + !
0xFFE6E6 CustomColors 0x0C + !  0xE6FFE6 CustomColors 0x10 + !  0xE6E6FF CustomColors 0x14 + !
0xC8F0F0 CustomColors 0x18 + !  0xF0C8F0 CustomColors 0x1C + !  0xF0F0C8 CustomColors 0x20 + !
0xF0C8C8 CustomColors 0x24 + !  0xC8F0C8 CustomColors 0x28 + !  0xC8C8F0 CustomColors 0x2C + !
0xF0F0F0 CustomColors 0x30 + !  0xE6E6E6 CustomColors 0x34 + !  0xF4FFFF CustomColors 0x38 + !
0xFFFFF4 CustomColors 0x3C + !

external

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="gdiPOINT"></a>
\ *S gdiPOINT class
:class gdiPOINT <super object
\ *G Wrapper class for a POINT struct.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Record: &POINT
        int x
        int y
;RecordSize: sizeof(POINT)

:M ClassInit:   ( -- )
        ClassInit: super

        0 to x
        0 to y
        ;M

:M GetX:        ( -- x )
\ *G Get the x value of the point.
                x ;M

:M GetY:        ( -- y )
\ *G Get the y value of the point.
                y ;M

:M SetX:        ( x -- )
\ *G Set the x value of the point.
                to x ;M

:M SetY:        ( y -- )
\ *G Get the y value of the point.
                to y ;M

\ :M Addr:        ( -- addr )
\ *G Get the address of the point struct.
\                 &POINT ;M

:M Size:        ( -- size )
\ *G Get the site of the point struct
                sizeof(POINT) ;M

;class
\ *G End of gdiPOINT class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="gdiCOLORREF"></a>
\ *S gdiCOLORREF class
:class gdiCOLORREF <super object
\ *G Wrapper class for a COLORREF struct.
\ *P A COLORREF value is used to specify an RGB color.
\ *P When specifying an explicit RGB color, the COLORREF value has the following
\ ** hexadecimal form: 0x00bbggrr \n
\ ** The low-order byte contains a value for the relative intensity of red;
\ ** the second byte contains a value for green; and the third byte contains a
\ ** value for blue. The high-order byte must be zero. The maximum value for a
\ ** single byte is 0xFF.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Record: &COLORREF
        byte r
        byte g
        byte b
        byte reserved
;RecordSize: sizeof(COLORREF)

Record: &CHOOSECOLOR
        int lStructSize
        int hwndOwner
        int hInstance
        int rgbResult
        int lpCustColors
        int Flags
        int lCustData
        int lpfnHook
        int lpTemplateName
;RecordSize: sizeof(CHOOSECOLOR)

:M ClassInit:   ( -- )
        ClassInit: super

        \ init &COLOR record
        0 to r
        0 to g
        0 to b
        0 to reserved

        \ init &CHOOSECOLOR record
        sizeof(CHOOSECOLOR) to lStructSize
        CustomColors        to lpCustColors
        [ CC_ANYCOLOR CC_FULLOPEN or CC_RGBINIT or ] literal to Flags
        null to hwndOwner
        null to hInstance
        0    to rgbResult
        0    to lCustData
        null to lpfnHook
        null to lpTemplateName

        ;M

:M SetRValue:   ( r -- )
\ *G Set the red value of the color
        to r ;M

:M SetGValue:   ( g -- )
\ *G Set the green value of the color
        to g ;M

:M SetBValue:   ( b -- )
\ *G Set the blue value of the color
        to b ;M

:M GetRValue:   ( -- r )
\ *G Get the red value of the color
        r ;M

:M GetGValue:   ( -- g )
\ *G Get the green value of the color
        g ;M

:M GetBValue:   ( -- b )
\ *G Get the blue value of the color
        b ;M

:M SetColor:    ( colorref -- )
\ *G Set the color
        0x00ffffff and &COLORREF ! ;M

:M SetSysColor: ( n -- )
\ *G Set a system color. Possible values are:
\ *L
\ *| COLOR_3DDKSHADOW | Dark shadow for three-dimensional display elements. |
\ *| COLOR_3DFACE, COLOR_BTNFACE | Face color for three-dimensional display elements and for dialog box backgrounds. |
\ *| COLOR_3DHILIGHT | Highlight color for three-dimensional display elements (for edges facing the light source.) |
\ *| COLOR_3DHIGHLIGHT | Highlight color for three-dimensional display elements (for edges facing the light source.) |
\ *| COLOR_BTNHILIGHT | Highlight color for three-dimensional display elements (for edges facing the light source.) |
\ *| COLOR_BTNHIGHLIGHT | Highlight color for three-dimensional display elements (for edges facing the light source.) |
\ *| COLOR_3DLIGHT | Light color for three-dimensional display elements (for edges facing the light source.) |
\ *| COLOR_3DSHADOW, COLOR_BTNSHADOW | Shadow color for three-dimensional display elements (for edges facing away from the light source). |
\ *| COLOR_ACTIVEBORDER | Active window border. |
\ *| COLOR_ACTIVECAPTION | Active window title bar. Windows 98, Windows 2000: Specifies the left side color in the color gradient of an active window's title bar if the gradient effect is enabled. |
\ *| COLOR_APPWORKSPACE | Background color of multiple document interface (MDI) applications. |
\ *| COLOR_BACKGROUND, COLOR_DESKTOP | Desktop. |
\ *| COLOR_BTNTEXT | Text on push buttons. |
\ *| COLOR_CAPTIONTEXT | Text in caption, size box, and scroll bar arrow box. |
\ *| COLOR_GRADIENTACTIVECAPTION | Windows 98, Windows 2000: Right side color in the color gradient of an active window's title bar.
\ *| COLOR_ACTIVECAPTION | Windows 98, Windows 2000: specifies the left side color.
\ *| COLOR_GRADIENTINACTIVECAPTION | Windows 98, Windows 2000: Right side color in the color gradient of an inactive window's title bar.
\ *| COLOR_INACTIVECAPTION | Windows 98, Windows 2000: specifies the left side color. |
\ *| COLOR_GRAYTEXT | Grayed (disabled) text. This color is set to 0 if the current display driver does not support a solid gray color. |
\ *| COLOR_HIGHLIGHT | Item(s) selected in a control. |
\ *| COLOR_HIGHLIGHTTEXT | Text of item(s) selected in a control. |
\ *| COLOR_HOTLIGHT | Windows 98, Windows 2000: Color for a hot-tracked item. Single clicking a hot-tracked item executes the item. |
\ *| COLOR_INACTIVEBORDER | Inactive window border. |
\ *| COLOR_INACTIVECAPTION | Inactive window caption. Windows 98, Windows 2000: Specifies the left side color in the color gradient of an inactive window's title bar if the gradient effect is enabled. |
\ *| COLOR_INACTIVECAPTIONTEXT | Color of text in an inactive caption. |
\ *| COLOR_INFOBK | Background color for tooltip controls. |
\ *| COLOR_INFOTEXT | Text color for tooltip controls. |
\ *| COLOR_MENU | Menu background. |
\ *| COLOR_MENUTEXT | Text in menus. |
\ *| COLOR_SCROLLBAR | Scroll bar gray area. |
\ *| COLOR_WINDOW | Window background. |
\ *| COLOR_WINDOWFRAME | Window frame. |
\ *| COLOR_WINDOWTEXT | Text in windows. |
        call GetSysColor &COLORREF ! ;M

:M GetColor:    ( -- colorref )
\ *G Get the color
        &COLORREF @ ;M

:M SetRGB:      ( r g b -- )
\ *G Set the red, green and blue values of the color
        SetBValue: self SetGValue: self SetRValue: self ;M

\ :M Addr:        ( -- addr )
\ *G Get the address of the COLORREF struct
\         &COLORREF ;M

:M Size:        ( -- size )
\ *G Get the size of the COLORREF struct
        sizeof(COLORREF) ;M

:M Choose:      ( hWnd -- f )
\ *G Open the windows dialog for choosing a color.
        to hwndOwner
        GetColor: self to rgbResult
        &CHOOSECOLOR call ChooseColor
        IF   rgbResult SetColor: self true
        else false
        then ;M

\ return address and length of the user defined custom colors
:M CustomColors:        ( -- addr len )
\ *G Get the address and length (in cells) of the CustomColors array
\ ** used by Choose:
        CustomColors 64 ;M

;class
\ *G End of gdiCOLORREF class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="gdiRGBQUAD"></a>
\ *S gdiRGBQUAD class
\ :class gdiRGBQUAD <super gdiCOLORREF
synonym gdiRGBQUAD gdiCOLORREF
\ *G Wrapper class for a RGBQUAD struct
\ *P The RGBQUAD structure describes a color consisting of relative
\ ** intensities of red, green, and blue.
\ *P The bmiColors member of the BITMAPINFO structure consists of an array
\ ** of RGBQUAD structures.
\ *P Note: This class is a synonym of gdiCOLORREF. For a description
\ ** of the methods see the \i gdiCOLORREF \d class.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ :M ClassInit:   ( -- )
\         ClassInit: super
\         ;M
\
\ ;class
\ *G End of gdiRGBQUAD class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="gdiSIZE"></a>
\ *S gdiSIZE class
:class gdiSIZE <super object
\ *G Wrapper class for a SIZE struct
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Record: &SIZE
        int cx
        int cy
;RecordSize: sizeof(SIZE)

:M ClassInit:   ( -- )
        ClassInit: super

        0 to cx
        0 to cy
        ;M

:M GetX:        ( -- x )
\ *G Get the x value
        cx ;M

:M GetY:        ( -- y )
\ *G Get the y value
        cy ;M

:M SetX:        ( x -- )
\ *G Set the x value
        to cx ;M

:M SetY:        ( y -- )
\ *G Set the y value
        to cy ;M

\ :M Addr:        ( -- addr )
\ *G Get the address of the SIZE struct
\         &SIZE ;M

:M Size:        ( -- size )
\ *G Get the size of the SIZE struct
        sizeof(SIZE) ;M

;class
\ *G End of gdiSIZE class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="gdiTEXTMETRIC"></a>
\ *S gdiTEXTMETRIC class
:class gdiTEXTMETRIC <super object
\ *G Wrapper class for a TEXTMETRIC struct
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Record: &TEXTMETRIC
        int  tmHeight
        int  tmAscent
        int  tmDescent
        int  tmInternalLeading
        int  tmExternalLeading
        int  tmAveCharWidth
        int  tmMaxCharWidth
        int  tmWeight
        int  tmOverhang
        int  tmDigitizedAspectX
        int  tmDigitizedAspectY
        byte tmFirstChar
        byte tmLastChar
        byte tmDefaultChar
        byte tmBreakChar
        byte tmItalic
        byte tmUnderlined
        byte tmStruckOut
        byte tmPitchAndFamily
        byte tmCharSet
;RecordSize: sizeof(TEXTMETRIC)

Class-align

:M ClassInit:   ( -- )
        ClassInit: super
        &TEXTMETRIC sizeof(TEXTMETRIC) erase
        ;M

:M SetHeight:            ( n -- )
\ *G
        to tmHeight ;M

:M SetAscent:            ( n -- )
\ *G
        to tmAscent ;M

:M SetDescent:           ( n -- )
\ *G
        to tmDescent ;M

:M SetInternalLeading:   ( n -- )
\ *G
        to tmInternalLeading ;M

:M SetExternalLeading:   ( n -- )
\ *G
        to tmExternalLeading ;M

:M SetAveCharWidth:      ( n -- )
\ *G
        to tmAveCharWidth ;M

:M SetMaxCharWidth:      ( n -- )
\ *G
        to tmMaxCharWidth ;M

:M SetWeight:            ( n -- )
\ *G
        to tmWeight ;M

:M SetOverhang:          ( n -- )
\ *G
        to tmOverhang ;M

:M SetDigitizedAspectX:  ( n -- )
\ *G
        to tmDigitizedAspectX ;M

:M SetDigitizedAspectY:  ( n -- )
\ *G
        to tmDigitizedAspectY ;M

:M SetFirstChar:         ( n -- )
\ *G
        to tmFirstChar ;M

:M SetLastChar:          ( n -- )
\ *G
        to tmLastChar ;M

:M SetDefaultChar:       ( n -- )
\ *G
        to tmDefaultChar ;M

:M SetBreakChar:         ( n -- )
\ *G
        to tmBreakChar ;M

:M SetItalic:            ( n -- )
\ *G
        to tmItalic ;M

:M SetUnderlined:        ( n -- )
\ *G
        to tmUnderlined ;M

:M SetStruckOut:         ( n -- )
\ *G
        to tmStruckOut ;M

:M SetPitchAndFamily:    ( n -- )
\ *G
        to tmPitchAndFamily ;M

:M SetCharSet:           ( n -- )
\ *G
        to tmCharSet ;M

:M GetHeight:            ( -- n )
\ *G
        tmHeight ;M

:M GetAscent:            ( -- n )
\ *G
        tmAscent ;M

:M GetDescent:           ( -- n )
\ *G
        tmDescent ;M

:M GetInternalLeading:   ( -- n )
\ *G
        tmInternalLeading ;M

:M GetExternalLeading:   ( -- n )
\ *G
        tmExternalLeading ;M

:M GetAveCharWidth:      ( -- n )
\ *G
        tmAveCharWidth ;M

:M GetMaxCharWidth:      ( -- n )
\ *G
        tmMaxCharWidth ;M

:M GetWeight:            ( -- n )
\ *G
        tmWeight ;M

:M GetOverhang:          ( -- n )
\ *G
        tmOverhang ;M

:M GetDigitizedAspectX:  ( -- n )
\ *G
        tmDigitizedAspectX ;M

:M GetDigitizedAspectY:  ( -- n )
\ *G
        tmDigitizedAspectY ;M

:M GetFirstChar:         ( -- n )
\ *G
        tmFirstChar ;M

:M GetLastChar:          ( -- n )
\ *G
        tmLastChar ;M

:M GetDefaultChar:       ( -- n )
\ *G
        tmDefaultChar ;M

:M GetBreakChar:         ( -- n )
\ *G
        tmBreakChar ;M

:M GetItalic:            ( -- n )
\ *G
        tmItalic ;M

:M GetUnderlined:        ( -- n )
\ *G
        tmUnderlined ;M

:M GetStruckOut:         ( -- n )
\ *G
        tmStruckOut ;M

:M GetPitchAndFamily:    ( -- n )
\ *G
        tmPitchAndFamily ;M

:M GetCharSet:           ( -- n )
\ *G
        tmCharSet ;M

\ :M Addr:                 ( -- addr ) &TEXTMETRIC ;M
\ *G Get the address of the TEXTMETRIC struct.

:M Size:                 ( -- size ) sizeof(TEXTMETRIC) ;M
\ *G Get the size of the TEXTMETRIC struct.

;class
\ *G End of gdiTEXTMETRIC class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ The LOGPEN structure defines the style, width, and color of a pen.
\ The CreatePenIndirect function uses the LOGPEN structure.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ :struct LOGPEN
\     UINT     lopnStyle
\     int      lopnWidth
\     int      lopnReserved
\     COLORREF lopnColor
\ ;struct

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ The LOGBRUSH structure defines the style, color, and pattern of a physical
\ brush. It is used by the CreateBrushIndirect and ExtCreatePen functions.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ :struct LOGBRUSH
\   UINT     lbStyle
\   COLORREF lbColor
\   LONG     lbHatch
\ ;struct

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ BITMAP struct
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ :struct BITMAP
\   LONG   bmType         \ Specifies the bitmap type. This member must be zero.
\   LONG   bmWidth        \ Specifies the width, in pixels, of the bitmap.
\                         \ The width must be greater than zero.
\   LONG   bmHeight       \ Specifies the height, in pixels, of the bitmap.
\                         \ The height must be greater than zero.
\   LONG   bmWidthBytes   \ Specifies the number of bytes in each scan line.
\                         \ This value must be divisible by 2, because the system
\                         \ assumes that the bit values of a bitmap form an array
\                         \ that is word aligned.
\   WORD   bmPlanes       \ Specifies the count of color planes.
\   WORD   bmBitsPixel    \ Specifies the number of bits required to indicate the
\                         \ color of a pixel.
\   LPVOID bmBits         \ Pointer to the location of the bit values for the bitmap.
\                         \ The bmBits member must be a long pointer to an array of
\                         \ character (1-byte) values.
\ ;struct

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ BITMAPINFOHEADER struct
\
\ The BITMAPINFOHEADER structure contains information about the dimensions
\ and color format of a DIB.
\
\ Applications developed for Windows NT 4.0 and Windows 95 may use the
\ BITMAPV4HEADER structure. Applications developed for Windows 2000 and
\ Windows 98 may use the BITMAPV5HEADER structure for increased functionality.
\ However, these can be used only in the CreateDIBitmap function.
\
\ NOTE: BITMAPV4HEADER and BITMAPV5HEADER are not supprted !!!
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ :struct BITMAPINFOHEADER
\   DWORD  biSize
\   LONG   biWidth
\   LONG   biHeight
\   WORD   biPlanes
\   WORD   biBitCount
\   DWORD  biCompression
\   DWORD  biSizeImage
\   LONG   biXPelsPerMeter
\   LONG   biYPelsPerMeter
\   DWORD  biClrUsed
\   DWORD  biClrImportant
\ ;struct

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ ENHMETAHEADER struct
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ :struct ENHMETAHEADER
\   DWORD iType
\   DWORD nSize
\   RECTL rclBounds
\   RECTL rclFrame
\   DWORD dSignature
\   DWORD nVersion
\   DWORD nBytes
\   DWORD nRecords
\   WORD  nHandles
\   WORD  sReserved
\   DWORD nDescription
\   DWORD offDescription
\   DWORD nPalEntries
\   SIZEL szlDevice
\   SIZEL szlMillimeters
\   DWORD cbPixelFormat
\   DWORD offPixelFormat
\   DWORD bOpenGL
\   SIZEL szlMicrometers
\ ;struct

module

\ *Z
