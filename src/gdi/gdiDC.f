\ *D doc\classes\
\ *! gdiDC
\ *T gdiDC -- Base device context class
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

\ Missing: - WorldTransform support

cr .( Loading GDI class library - Device context...)

needs gdiBase.f

internal
external

 8 value CHAR-WIDTH  \ Width of each character in pixels
14 value CHAR-HEIGHT \ Height of each character in pixels

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
:class gdiDC <super gdiObject
\ *G Base device context class

gdiSIZE         SIZE
gdiTEXTMETRIC   TEXTMETRIC
gdiPOINT        POINT
rectangle       RECT

: GetObjectColor { colorref -- colorref }
        colorref ?IsGdiObject
        if   GetColor: colorref
        else colorref
        then ;

:M SelectObject: ( hGdiObject -- hOldObject )
\ *G The SelectObject method selects an object into the device context.
\ ** The new object replaces the previous object of the same type.
\ *P If the selected object is not a region and the method succeeds, the
\ ** return value is a handle to the object being replaced. If the selected
\ ** object is a region and the method succeeds, the return value is one
\ ** of the following values:
\ *L
\ *| SIMPLEREGION  | Region consists of a single rectangle. |
\ *| COMPLEXREGION | Region consists of more than one rectangle. |
\ *| NULLREGION    | Region is empty. |
\ *P If an error occurs and the selected object is not a region, the return
\ ** value is NULL. Otherwise, it is GDI_ERROR.
\ *P Note: \i hGdiObject \d can be a valid GDI object handle or the address of a
\ ** GdiObject class !
        GetGdiObjectHandle hObject call SelectObject ;M

:M GetCurrentObject: ( ObjectType -- hObject )
\ *G The GetCurrentObject method retrieves a handle to an object of the
\ ** specified type that has been selected into the specified device context.
\ *P \i ObjectType \d Specifies the object type to be queried. This parameter can be
\ ** one of the following values.
\ *L
\ *| OBJ_BITMAP     | Returns the current selected bitmap. |
\ *| OBJ_BRUSH      | Returns the current selected brush. |
\ *| OBJ_COLORSPACE | Returns the current color space. |
\ *| OBJ_FONT       | Returns the current selected font. |
\ *| OBJ_PAL        | Returns the current selected palette. |
\ *| OBJ_PEN        | Returns the current selected pen. |
        hObject call GetCurrentObject ;M

:M GetStockObject:      ( nObject -- hObject )
\ *G The GetStockObject method retrieves a handle to one of the stock pens, brushes,
\ ** fonts, or palettes.
\ ** \i nObject \d Specifies the type of stock object. This parameter can be one of the following
\ ** values:
\ *L
\ *| BLACK_BRUSH      | Black brush. |
\ *| DKGRAY_BRUSH     | Dark gray brush. |
\ *| DC_BRUSH         | Windows 98, Windows 2000: Solid color brush. The default color is white. The color can be changed by using the SetDCBrushColor method. |
\ *| GRAY_BRUSH       | Gray brush. |
\ *| HOLLOW_BRUSH     | Hollow brush (equivalent to NULL_BRUSH). |
\ *| LTGRAY_BRUSH     | Light gray brush. |
\ *| NULL_BRUSH       | Null brush (equivalent to HOLLOW_BRUSH). |
\ *| WHITE_BRUSH      | White brush. |
\ *| BLACK_PEN        | Black pen. |
\ *| DC_PEN           | Windows 98, Windows 2000: Solid pen color. The default color is white. The color can be changed by using the SetDCPenColor method. |
\ *| WHITE_PEN        | White pen. |
\ *| ANSI_FIXED_FONT  | Windows fixed-pitch (monospace) system font. |
\ *| ANSI_VAR_FONT    | Windows variable-pitch (proportional space) system font. |
\ *| DEVICE_DEFAULT_FONT | Windows NT/2000: Device-dependent font. |
\ *| DEFAULT_GUI_FONT | Default font for user interface objects such as menus and dialog boxes. This is MS Sans Serif. Compare this with SYSTEM_FONT. |
\ *| OEM_FIXED_FONT   | Original equipment manufacturer (OEM) dependent fixed-pitch (monospace) font. |
\ *| SYSTEM_FONT      | System font. By default, the system uses the system font to draw menus, dialog box controls, and text. Windows 95/98 and NT: The system font is MS Sans Serif. Windows 2000: The system font is Tahoma |
\ *| SYSTEM_FIXED_FONT | Fixed-pitch (monospace) system font. This stock object is provided only for compatibility with 16-bit Windows versions earlier than 3.0. |
\ *| DEFAULT_PALETTE  | Default palette. This palette consists of the static colors in the system palette. |
        call GetStockObject ;M

:M SelectStockObject: ( nObject -- hOldObject )
\ *G The SelectStockObject method selects one of the stock pens, brushes, fonts, or
\ ** palettes into the the device context.
\ *P \i nObject \d Specifies the type of stock object. This parameter can be one of the following
\ ** values. (see GetStockObject:)
        GetStockObject: self SelectObject: self ;M

winver win2k >= [IF] \ only w2k or later

:M SetPenColor: ( colorref -- previous-colorref )
\ *G SetPenColor method sets the current device context pen color to the
\ ** specified color value. If the device cannot represent the specified color value,
\ ** the color is set to the nearest physical color.
\ ** If the method succeeds, the return value specifies the previous DC pen color
\ ** as a COLORREF value. If the method fails, the return value is CLR_INVALID.
\ *P Only for Windows 2000 and later
        hObject call SetDCPenColor ;M

:M GetPenColor: ( -- colorref )
\ *G The GetPenColor method retrieves the current pen color for the specified
\ ** device context.
\ *P Only for Windows 2000 and later
        hObject call GetDCPenColor ;M

:M SetBrushColor: ( colorref -- previous-colorref )
\ *G SetBrushColor method sets the current device context brush color to the
\ ** specified color value. If the device cannot represent the specified color value,
\ ** the color is set to the nearest physical color.
\ ** If the method succeeds, the return value specifies the previous DC brush color
\ ** as a COLORREF value. If the method fails, the return value is CLR_INVALID.
\ *P Only for Windows 2000 and later
        hObject call SetDCBrushColor ;M

:M GetBrushColor: ( -- colorref )
\ *G The GetBrushColor method retrieves the current brush color for the specified
\ ** device context.
\ *P Only for Windows 2000 and later
        hObject call GetDCBrushColor ;M

[THEN]

:M Save:        ( -- SavedState )
\ *G The Save method saves the current state of the device context by copying
\ ** data describing selected objects and graphic modes (such as the bitmap,
\ ** brush, palette, font, pen, region, drawing mode, and mapping mode) to a
\ ** context stack.
        hObject call SaveDC ;M

:M Restore:     ( SavedState -- )
\ *G The Restore method restores the device context to the specified state.
\ ** The DC is restored by popping state information off a stack created by
\ ** earlier calls to the Save method.
        hObject call RestoreDC ?win-error ;M

:M Cancel:      ( -- )
\ *G The Cancel method cancels any pending operation on the specified device
\ ** context. \n
\ ** The Cancel method is used by multithreaded applications to cancel lengthy
\ ** drawing operations. If thread A initiates a lengthy drawing operation,
\ ** thread B may cancel that operation by calling this method.
        hObject call CancelDC drop ;M

:M GetDeviceCaps: ( Index -- n )
\ *G The GetDeviceCaps method retrieves device-specific information for the
\ ** specified device.
\ *P \i Index \d Specifies the item to return. This parameter can be one of the
\ ** following values:
\ *P \b DRIVERVERSION \d The device driver version.
\ *P \b TECHNOLOGY \d Device technology. It can be any one of the following values.
\ *L
\ *| DT_PLOTTER    | Vector plotter |
\ *| DT_RASDISPLAY | Raster display |
\ *| DT_RASPRINTER | Raster printer |
\ *| DT_RASCAMERA  | Raster camera |
\ *| DT_CHARSTREAM | Character stream |
\ *| DT_METAFILE   | Metafile |
\ *| DT_DISPFILE   | Display file |
\ *P If the DC is the DC of an enhanced metafile,
\ ** the device technology is that of the referenced device as specified
\ ** to the CreateEnhMetaFile method. To determine whether it is an
\ ** enhanced metafile DC, use the GetObjectType method.
\ *P \b HORZSIZE \d Width, in millimeters, of the physical screen.
\ *P \b VERTSIZE \d Height, in millimeters, of the physical screen.
\ *P \b HORZRES \d Width, in pixels, of the screen.
\ *P \b VERTRES \d Height, in raster lines, of the screen.
\ *P \b LOGPIXELSX \d Number of pixels per logical inch along the screen width. In a system
\ ** with multiple display monitors, this value is the same for all monitors.
\ *P \b LOGPIXELSY \d Number of pixels per logical inch along the screen height. In a system
\ ** with multiple display monitors, this value is the same for all monitors.
\ *P \b BITSPIXEL \d Number of adjacent color bits for each pixel.
\ *P \b PLANES \d Number of color planes.
\ *P \b NUMBRUSHES \d Number of device-specific brushes.
\ *P \b NUMPENS \d Number of device-specific pens.
\ *P \b NUMFONTS \d Number of device-specific fonts.
\ *P \b NUMCOLORS \d Number of entries in the device's color table, if the device has a color
\ ** depth of no more than 8 bits per pixel. For devices with greater color depths,
\ ** 1 is returned.
\ *P \b ASPECTX \d Relative width of a device pixel used for line drawing.
\ *P \b ASPECTY \d Relative height of a device pixel used for line drawing.
\ *P \b ASPECTXY \d Diagonal width of the device pixel used for line drawing.
\ *P \b PDEVICESIZE \d Reserved.
\ *P \b CLIPCAPS \d Flag that indicates the clipping capabilities of the device. If the device
\ ** can clip to a rectangle, it is 1. Otherwise, it is 0.
\ *P \b SIZEPALETTE \d Number of entries in the system palette. This index is valid only if the
\ ** device driver sets the RC_PALETTE bit in the RASTERCAPS index and is available
\ ** only if the driver is compatible with 16-bit Windows.
\ *P \b NUMRESERVED \d Number of reserved entries in the system palette. This index is valid only if
\ ** the device driver sets the RC_PALETTE bit in the RASTERCAPS index and is
\ ** available only if the driver is compatible with 16-bit Windows.
\ *P \b COLORRES \d Actual color resolution of the device, in bits per pixel. This index is valid
\ ** only if the device driver sets the RC_PALETTE bit in the RASTERCAPS index and
\ ** is available only if the driver is compatible with 16-bit Windows.
\ *P \b PHYSICALWIDTH \d For printing devices: the width of the physical page, in device units. For
\ ** example, a printer set to print at 600 dpi on 8.5-x11-inch paper has a physical
\ ** width value of 5100 device units. Note that the physical page is almost always
\ ** greater than the printable area of the page, and never smaller.
\ *P \b PHYSICALHEIGHT \d For printing devices: the height of the physical page, in device units. For
\ ** example, a printer set to print at 600 dpi on 8.5-by-11-inch paper has a physical
\ ** height value of 6600 device units. Note that the physical page is almost always
\ ** greater than the printable area of the page, and never smaller.
\ *P \b PHYSICALOFFSETX \d For printing devices: the distance from the left edge of the physical page to the
\ ** left edge of the printable area, in device units. For example, a printer set to
\ ** print at 600 dpi on 8.5-by-11-inch paper, that cannot print on the leftmost
\ ** 0.25-inch of paper, has a horizontal physical offset of 150 device units.
\ *P \b PHYSICALOFFSETY \d For printing devices: the distance from the top edge of the physical page to the
\ ** top edge of the printable area, in device units. For example, a printer set to
\ ** print at 600 dpi on 8.5-by-11-inch paper, that cannot print on the topmost 0.5-inch
\ ** of paper, has a vertical physical offset of 300 device units.
\ *P \b VREFRESH \d Windows NT/2000: For display devices: the current vertical refresh rate of the device,
\ ** in cycles per second (Hz).
\ ** A vertical refresh rate value of 0 or 1 represents the display hardware's default
\ ** refresh rate. This default rate is typically set by switches on a display card or
\ ** computer motherboard, or by a configuration program that does not use Win32 display
\ ** methods such as ChangeDisplaySettings.
\ *P \b SCALINGFACTORX \d Scaling factor for the x-axis of the printer.
\ *P \b SCALINGFACTORY \d Scaling factor for the y-axis of the printer.
\ *P \b BLTALIGNMENT \d Windows NT/2000: Preferred horizontal drawing alignment, expressed as a multiple of
\ ** pixels. For best drawing performance, windows should be horizontally aligned to a
\ ** multiple of this value. A value of zero indicates that the device is accelerated,
\ ** and any alignment may be used.
\ *P \b SHADEBLENDCAPS \d Windows 98, Windows 2000: Value that indicates the shading and blending capabilities
\ ** of the device.
\ *P \b SB_CONST_ALPHA \d Handles the SourceConstantAlpha member of the BLENDFUNCTION structure,
\ ** which is referenced by the blendFunction parameter of the AlphaBlend method.
\ *L
\ *| SB_GRAD_RECT     | Capable of doing GradientFill rectangles. |
\ *| SB_GRAD_TRI      | Capable of doing GradientFill triangles. |
\ *| SB_NONE          | Device does not support any of these capabilities. |
\ *| SB_PIXEL_ALPHA   | Capable of handling per-pixel alpha in AlphaBlend. |
\ *| SB_PREMULT_ALPHA | Capable of handling premultiplied alpha in AlphaBlend. |
\ *P \b RASTERCAPS \d Value that indicates the raster capabilities of the device,
\ ** as shown in the following table.
\ *L
\ *| RC_BANDING      | Requires banding support. |
\ *| RC_BITBLT       | Capable of transferring bitmaps. |
\ *| RC_BITMAP64     | Capable of supporting bitmaps larger than 64 KB. |
\ *| RC_DI_BITMAP    | Capable of supporting the SetDIBits and GetDIBits methods. |
\ *| RC_DIBTODEV     | Capable of supporting the SetDIBitsToDevice method. |
\ *| RC_FLOODFILL    | Capable of performing flood fills. |
\ *| RC_GDI20_OUTPUT | Capable of supporting features of 16-bit Windows 2.0. |
\ *| RC_PALETTE      | Specifies a palette-based device. |
\ *| RC_SCALING      | Capable of scaling. |
\ *| RC_STRETCHBLT   | Capable of performing the StretchBlt method. |
\ *| RC_STRETCHDIB   | Capable of performing the StretchDIBits method. |
\ *P \b CURVECAPS \d Value that indicates the curve capabilities of the device, as shown
\ ** in the following table:
\ *L
\ *| CC_NONE       | Device does not support curves. |
\ *| CC_CHORD      | Device can draw chord arcs. |
\ *| CC_CIRCLES    | Device can draw circles. |
\ *| CC_ELLIPSES   | Device can draw ellipses. |
\ *| CC_INTERIORS  | Device can draw interiors. |
\ *| CC_PIE        | Device can draw pie wedges. |
\ *| CC_ROUNDRECT  | Device can draw rounded rectangles. |
\ *| CC_STYLED     | Device can draw styled borders. |
\ *| CC_WIDE       | Device can draw wide borders. |
\ *| CC_WIDESTYLED | Device can draw borders that are wide and styled. |
\ *P \b LINECAPS \d Value that indicates the line capabilities of the device, as
\ ** shown in the following table:
\ *L
\ *| LC_NONE       | Device does not support lines. |
\ *| LC_INTERIORS  | Device can draw interiors. |
\ *| LC_MARKER     | Device can draw a marker. |
\ *| LC_POLYLINE   | Device can draw a polyline. |
\ *| LC_POLYMARKER | Device can draw multiple markers. |
\ *| LC_STYLED     | Device can draw styled lines. |
\ *| LC_WIDE       | Device can draw wide lines. |
\ *| LC_WIDESTYLED | Device can draw lines that are wide and styled. |
\ *P \b POLYGONALCAPS \d Value that indicates the polygon capabilities of the device, as
\ ** shown in the following table.
\ *L
\ *| PC_NONE        | Device does not support polygons. |
\ *| PC_INTERIORS   | Device can draw interiors. |
\ *| PC_POLYGON     | Device can draw alternate-fill polygons. |
\ *| PC_RECTANGLE   | Device can draw rectangles. |
\ *| PC_SCANLINE    | Device can draw a single scanline. |
\ *| PC_STYLED      | Device can draw styled borders. |
\ *| PC_WIDE        | Device can draw wide borders. |
\ *| PC_WIDESTYLED  | Device can draw borders that are wide and styled. |
\ *| PC_WINDPOLYGON | Device can draw winding-fill polygons. |
\ *P \b TEXTCAPS \d Value that indicates the text capabilities of the device, as shown
\ ** in the following table.
\ *L
\ *| TC_OP_CHARACTER | Device is capable of character output precision. |
\ *| TC_OP_STROKE    | Device is capable of stroke output precision. |
\ *| TC_CP_STROKE    | Device is capable of stroke clip precision. |
\ *| TC_CR_90        | Device is capable of 90-degree character rotation. |
\ *| TC_CR_ANY       | Device is capable of any character rotation. |
\ *| TC_SF_X_YINDEP  | Device can scale independently in the x- and y-directions. |
\ *| TC_SA_DOUBLE    | Device is capable of doubled character for scaling. |
\ *| TC_SA_INTEGER   | Device uses integer multiples only for character scaling. |
\ *| TC_SA_CONTIN    | Device uses any multiples for exact character scaling. |
\ *| TC_EA_DOUBLE    | Device can draw double-weight characters. |
\ *| TC_IA_ABLE      | Device can italicize. |
\ *| TC_UA_ABLE      | Device can underline. |
\ *| TC_SO_ABLE      | Device can draw strikeouts. |
\ *| TC_RA_ABLE      | Device can draw raster fonts. |
\ *| TC_VA_ABLE      | Device can draw vector fonts. |
\ *| TC_RESERVED     | Reserved; must be zero. |
\ *| TC_SCROLLBLT    | Device cannot scroll using a bit-block transfer. Note that this meaning may be the opposite of what you expect. |
\ *P \b COLORMGMTCAPS \d Windows 2000: Value that indicates the color management capabilities of the device.
\ *L
\ *| CM_CMYK_COLOR | Device can accept CMYK color space ICC color profile. |
\ *| CM_DEVICE_ICM | Device can perform ICM on either the device driver or the device itself. |
\ *| CM_GAMMA_RAMP | Device supports GetDeviceGammaRamp and SetDeviceGammaRamp |
\ *| CM_NONE       | Device does not support ICM. |
        hObject call GetDeviceCaps ;M

\ ----------------------------------------------------------------------
\ *s
\ ----------------------------------------------------------------------

:M SetBackgroundMode: ( fMode -- fPreviousMode )
\ *G The SetBackgroundMode method sets the background mix mode of the specified
\ ** device context. The background mix mode is used with text, hatched brushes,
\ ** and pen styles that are not solid lines. Possible values for \i fMode \d are:
\ *L
\ *| OPAQUE      | Background is filled with the current background color before the text, hatched brush, or pen is drawn. |
\ *| TRANSPARENT | Background remains untouched. |
        hObject call SetBkMode ;M

:M GetBackgroundMode: ( -- fMode )
\ *G The GetBackgroundMode method returns the current background mix mode for a
\ ** specified device context. The background mix mode of a device context affects
\ ** text, hatched brushes, and pen styles that are not solid lines.
        hObject call GetBkMode ;M

:M SetBackgroundColor: ( colorref -- PreviousColorref )
\ *G The SetBackgroundColor method sets the current background color to the
\ ** specified color value, or to the nearest physical color if the device cannot
\ ** represent the specified color value.
\ *P Note: \i colorref \d can be a 'simple' colorref or the address of a pPen Object class !
        GetObjectColor hObject call SetBkColor ;M

:M GetBackgroundColor: ( -- colorref )
\ *G The GetBackgroundColor method returns the current background color for the
\ ** specified device context.
        hObject call GetBkColor ;M

:M SetROP:       ( nDrawMode -- nPreviousDrawMode )
\ *G The SetROP method sets the current foreground mix mode. GDI uses the foreground
\ ** mix mode to combine pens and interiors of filled objects with the colors already
\ ** on the screen. The foreground mix mode defines how colors from the brush or pen
\ ** and the colors in the existing image are to be combined.
\ *P \i nDrawMode \d Specifies the mix mode. This parameter can be one of the following values. Mix mode Description
\ *L
\ *| R2_BLACK       | Pixel is always 0. |
\ *| R2_COPYPEN     | Pixel is the pen color. |
\ *| R2_MASKNOTPEN  | Pixel is a combination of the colors common to both the screen and the inverse of the pen. |
\ *| R2_MASKPEN     | Pixel is a combination of the colors common to both the pen and the screen. |
\ *| R2_MASKPENNOT  | Pixel is a combination of the colors common to both the pen and the inverse of the screen. |
\ *| R2_MERGENOTPEN | Pixel is a combination of the screen color and the inverse of the pen color. |
\ *| R2_MERGEPEN    | Pixel is a combination of the pen color and the screen color. |
\ *| R2_MERGEPENNOT | Pixel is a combination of the pen color and the inverse of the screen color. |
\ *| R2_NOP         | Pixel remains unchanged. |
\ *| R2_NOT         | Pixel is the inverse of the screen color. |
\ *| R2_NOTCOPYPEN  | Pixel is the inverse of the pen color. |
\ *| R2_NOTMASKPEN  | Pixel is the inverse of the R2_MASKPEN color. |
\ *| R2_NOTMERGEPEN | Pixel is the inverse of the R2_MERGEPEN color. |
\ *| R2_NOTXORPEN   | Pixel is the inverse of the R2_XORPEN color. |
\ *| R2_WHITE       | Pixel is always 1. |
\ *| R2_XORPEN      | Pixel is a combination of the colors in the pen and in the screen, but not in both. |
        hObject call SetROP2 ;M

:M GetROP:       ( -- nDrawMode )
\ *G The GetROP method retrieves the foreground mix mode of the specified device context.
\ ** The mix mode specifies how the pen or interior color and the color already on the screen
\ ** are combined to yield a new color.
        hObject call GetROP2 ;M

winver 1 > [if] \ only Win98 and better

:M SetArcDirection: ( Direction -- OldDirection )
\ *G SetArcDirection sets the drawing direction to be used for arc and
\ ** rectangle methods. Possible value for \i Direction \d are:
\ *L
\ *| AD_COUNTERCLOCKWISE | Figures drawn counterclockwise. |
\ *| AD_CLOCKWISE        | Figures drawn clockwise. |
\ *P Only for Windows 98 and better.
        hObject call SetArcDirection ;M

:M GetArcDirection: ( -- Direction )
\ *G The GetArcDirection method retrieves the current arc direction for the
\ ** specified device context. Arc and rectangle methods use the arc direction.
\ *P Only for Windows 98 and better.
        hObject call GetArcDirection ;M

[then]

\ ----------------------------------------------------------------------
\ *S Coordinate Space and Transformation
\ ----------------------------------------------------------------------

:M DPtoLP:      ( lpPoints nCount -- )
\ *G The DPtoLP method converts device coordinates into logical coordinates.
\ ** The conversion depends on the mapping mode of the device context, the settings
\ ** of the origins and extents for the window and viewport, and the world transformation.
\ *P \i lpPoints \d [in/out] Pointer to an array of POINT structures. The x- and y-coordinates
\ ** contained in each POINT structure will be transformed.
\ *P \i nCount \d [in] Specifies the number of points in the array.
\ *P The DPtoLP method fails if the device coordinates exceed 27 bits, or if the
\ ** converted logical coordinates exceed 32 bits. In the case of such an overflow,
\ ** the results for all the points are undefined.
        swap hObject call DPtoLP ?win-error ;M

:M LPtoDP:      ( lpPoints nCount -- )
\ *G The LPtoDP method converts logical coordinates into device coordinates. The
\ ** conversion depends on the mapping mode of the device context, the settings of the
\ ** origins and extents for the window and viewport, and the world transformation.
\ *P \i lpPoints \d [in/out] Pointer to an array of POINT structures. The x- and y-coordinates
\ ** contained in each POINT structure will be transformed.
\ *P \i nCount \d [in] Specifies the number of points in the array.
\ *P This method fails if the logical coordinates exceed 32 bits, or if the converted
\ ** device coordinates exceed 27 bits. In the case of such an overflow, the results for
\ ** all the points are undefined.
        swap hObject call LPtoDP ?win-error ;M

:M SetGraphicsMode: ( Mode -- PreviousMode )
\ *G The SetGraphicsMode method sets the graphics mode for the specified device context.
\ ** Possible Values for Mode:
\ *P \b GM_COMPATIBLE \d Sets the graphics mode that is compatible with 16-bit Windows. This is
\ ** the default mode. If this value is specified, the application can only
\ ** modify the world-to-device transform by calling methods that set window
\ ** and viewport extents and origins, but not by using SetWorldTransform or
\ ** ModifyWorldTransform; calls to those methods will fail. Examples of
\ ** methods that set window and viewport extents and origins are SetViewportExtEx
\ ** and SetWindowExt.
\ *P \b GM_ADVANCED \d Windows NT/ 2000: Sets the advanced graphics mode that allows world
\ ** transformations. This value must be specified if the application will set
\ ** or modify the world transformation for the specified device context. In
\ ** this mode all graphics, including text output, fully conform to the
\ ** world-to-device transformation specified in the device context.
\ ** Windows 95/98: The GM_ADVANCED value is not supported. When playing enhanced
\ ** metafiles, Windows 95/98 attempts to make enhanced metafiles on Windows 95/98
\ ** look the same as they do on Windows NT/Windows 2000. To accomplish this, Windows
\ ** 95/98 may simulate GM_ADVANCED mode when playing specific enhanced metafile records.
\ *P NOTE: Currently this class libary doesn't support wold transformation for the DC !
\ ** That means: CombineTransform(), GetWorldTransform(), ModifyWorldTransform() and
\ ** SetWorldTransform() are not supported at the moment.
        hObject call SetGraphicsMode ;M

:M GetGraphicsMode: ( -- mode )
\ *G The GetGraphicsMode method retrieves the current graphics mode for the
\ ** specified device context.
        hObject call GetGraphicsMode ;M

:M SetMapMode:  ( MapMode -- PerviousMapMode )
\ *G The SetMapMode method sets the mapping mode of the specified device context.
\ ** The mapping mode defines the unit of measure used to transform page-space units
\ ** into device-space units, and also defines the orientation of the device's x and y
\ ** axes. Possible Values for MapMode are:
\ *P \b MM_ANISOTROPIC \d Logical units are mapped to arbitrary units with arbitrarily scaled
\ ** axes. Use the SetWindowExt and SetViewportExt methods to specify
\ ** the units, orientation, and scaling.
\ *P \b MM_HIENGLISH \d Each logical unit is mapped to 0.001 inch. Positive x is to the right;
\ ** positive y is up.
\ *P \b MM_HIMETRIC \d Each logical unit is mapped to 0.01 millimeter. Positive x is to the
\ ** right; positive y is up.
\ *P \b MM_ISOTROPIC \d Logical units are mapped to arbitrary units with equally scaled axes;
\ ** that is, one unit along the x-axis is equal to one unit along the y-axis.
\ ** Use the SetWindowExt and SetViewportExt methods to specify the units
\ ** and the orientation of the axes. Graphics device interface (GDI) makes
\ ** adjustments as necessary to ensure the x and y units remain the same size
\ ** (When the window extent is set, the viewport will be adjusted to keep the
\ ** units isotropic).
\ *P \b MM_LOENGLISH \d Each logical unit is mapped to 0.01 inch. Positive x is to the right;
\ ** positive y is up.
\ *P \b MM_LOMETRIC \d Each logical unit is mapped to 0.1 millimeter. Positive x is to the right;
\ ** positive y is up.
\ *P \b MM_TEXT \d Each logical unit is mapped to one device pixel. Positive x is to the right;
\ ** positive y is down.
\ *P \b MM_TWIPS \d Each logical unit is mapped to one twentieth of a printer's point (1/1440 inch,
\ ** also called a twip). Positive x is to the right; positive y is up.
        hObject call SetMapMode ;M

:M GetMapMode:  ( -- MapMode )
\ *G The GetMapMode method retrieves the current mapping mode.
        hObject call GetMapMode ;M

:M SetWindowOrg:  ( x y -- x1 y1 )
\ *G The SetWindowOrg method specifies which window point maps to the viewport origin (0,0).
\ *P This helps define the mapping from the logical coordinate space (also known as a window) to
\ ** the device coordinate space (the viewport). SetWindowOrg specifies which logical point maps
\ ** to the device point (0,0). It has the effect of shifting the axes so that the logical point
\ ** (0,0) no longer refers to the upper-left corner.
\ *P This is related to the SetViewportOrg method. Generally, you will use one method or the
\ ** other, but not both. Regardless of your use of SetWindowOrg and SetViewportOrg, the device
\ ** point (0,0) is always the upper-left corner.
        Addr: POINT 3reverse hObject call SetWindowOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

:M GetWindowOrg:  ( -- x y )
\ *G The GetWindowOrg method retrieves the x-coordinates and y-coordinates of the window
\ ** origin for the specified device context.
        Addr: POINT hObject call GetWindowOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

:M SetViewportOrg: ( x y - x1 y1 )
\ *G The SetViewportOrg method specifies which device point maps to the window origin (0,0).
\ *P This method (along with SetViewportExt and SetWindowExt) helps define the mapping from
\ ** the logical coordinate space (also known as a window) to the device coordinate space (the
\ ** viewport). SetViewportOrg specifies which device point maps to the logical point (0,0).
\ ** It has the effect of shifting the axes so that the logical point (0,0) no longer refers to
\ ** the upper-left corner.
\ *P This is related to the SetViewportOrg method. Generally, you will use one method or the
\ ** other, but not both. Regardless of your use of SetWindowOrg and SetViewportOrg, the device
\ ** point (0,0) is always the upper-left corner.
        Addr: POINT 3reverse hObject call SetViewportOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

:M GetViewportOrg: ( -- x y )
\ *G The GetViewportOrg method retrieves the x-coordinates and y-coordinates of the viewport
\ ** origin for the specified device context.
        Addr: POINT hObject call GetViewportOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

:M OffsetViewportOrg: ( xOffest yOffset - xOffset1 yOffset1 )
\ *G The OffsetViewportOrg method modifies the viewport origin for a device context using
\ ** the specified horizontal and vertical offsets.
\ ** The new origin is the sum of the current origin and the horizontal and vertical offsets.
\ *P \i xOffset \d Specifies the horizontal offset, in device units.
\ *P \i YOffset \d Specifies the vertical offset, in device units.
        Addr: POINT 3reverse hObject call OffsetViewportOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

:M OffsetWindowOrg: ( xOffest yOffset - xOffset1 yOffset1 )
\ *G The OffsetWindowOrg method modifies the window origin for a device context using the
\ ** specified horizontal and vertical offsets.
\ *P \i XOffset \d Specifies the horizontal offset, in logical units.
\ *P \i YOffset \d Specifies the vertical offset, in logical units.
        Addr: POINT 3reverse hObject call OffsetWindowOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

:M ScaleViewportExt: ( Xnum Xdenom Ynum Ydenom -- x y )
\ *G The ScaleViewportExt method modifies the viewport for a device context using the
\ ** ratios formed by the specified multiplicands and divisors.
\ ** It returns the the previous viewport extents, in device units.
\ *P The viewport extents are modified as follows:
\ **       xNewVE = (xOldVE * Xnum) / Xdenom
\ **       yNewVE = (yOldVE * Ynum) / Ydenom
        Addr: SIZE 5reverse hObject call ScaleViewportExtEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M ScaleWindowExtEx: ( Xnum Xdenom Ynum Ydenom -- x y )
\ *G The ScaleWindowExt method modifies the window for a device context using the ratios
\ ** formed by the specified multiplicands and divisors.
\ ** It returns the the previous window extents, in logical units.
\ *P The window extents are modified as follows:
\ **       xNewWE = (xOldWE * Xnum) / Xdenom
\ **       yNewWE = (yOldWE * Ynum) / Ydenom
        Addr: SIZE 5reverse hObject call ScaleWindowExtEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M SetViewportExt: ( XExtent yExtent -- XExtent1 yExtent1 )
\ *G The SetViewportExt method sets the horizontal and vertical extents of the viewport
\ ** for a device context by using the specified values.
        Addr: SIZE 3reverse hObject call SetViewportExtEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M GetViewportExt: ( -- x y )
\ *G The GetViewportExt method retrieves the x-extent and y-extent of the current viewport
\ ** for the specified device context.
        Addr: SIZE hObject call GetViewportExtEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M SetWindowExt: ( XExtent YExtent -- XExtent1 YExtent1 )
\ *G The SetWindowExt method sets the horizontal and vertical extents of the window for
\ ** a device context by using the specified values.
\ *P \i XExtent \d Specifies the window's horizontal extent in logical units.
\ *P \i YExtent \d Specifies the window's vertical extent in logical units.
        Addr: SIZE 3reverse hObject call SetWindowExtEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M GetWindowExt: ( -- x y )
\ This method retrieves the x-extent and y-extent of the window for the specified
\ device context.
        Addr: SIZE hObject call GetWindowExtEx ?win-error
        GetX: SIZE GetY: SIZE ;M

\ ----------------------------------------------------------------------
\ *S Drawing
\ ----------------------------------------------------------------------

:M InvertRect:  ( left top right bottom  -- )
\ *G The InvertRect method inverts a rectangle in a window by performing a
\ ** logical NOT operation on the color values for each pixel in the rectangle's
\ ** interior.
        SetRect: RECT
        RECT hObject Call InvertRect ?win-error ;M

\ ----------------------------------------------------------------------
\ *P \b Filled Shapes \d
\ ** Filled shapes are geometric forms that are outlined by using the
\ ** current pen and filled by using the current brush.
\ ----------------------------------------------------------------------

:M Chord:       ( nLeftRect nTopRect nRightRect nBottomRect nXRadial1 nXRadial1 nYRadial1 nXRadial2 nYRadial2 -- )
\ *G The Chord method draws a chord (a region bounded by the intersection of
\ ** an ellipse and a line segment, called a secant).
\ *P \i nLeftRect \d x-coord of upper-left corner of rectangle
\ *P \i nTopRect \d y-coord of upper-left corner of rectangle
\ *P \i nRightRect \d x-coord of lower-right corner of rectangle
\ *P \i nBottomRect \d y-coord of lower-right corner of rectangle
\ *P \i nXRadial1 \d x-coord of first radial's endpoint
\ *P \i nYRadial1 \d y-coord of first radial's endpoint
\ *P \i nXRadial2 \d x-coord of second radial's endpoint
\ *P \i nYRadial2 \d y-coord of second radial's endpoint
        8reverse hObject call Chord ?win-error ;M

:M Ellipse:     ( nLeftRect nTopRect nRightRect nBottomRect -- )
\ *G The Ellipse method draws an ellipse. The center of the ellipse is the
\ ** center of the specified bounding rectangle.
\ *P \i nLeftRect \d x-coord of upper-left corner of rectangle
\ *P \i nTopRect \d y-coord of upper-left corner of rectangle
\ *P \i nRightRect \d x-coord of lower-right corner of rectangle
\ *P \i nBottomRect \d y-coord of lower-right corner of rectangle
        4reverse hObject call Ellipse ?win-error ;M

:M Pie:         ( nLeftRect nTopRect nRightRect nBottomRect nXRadial1 nYRadial1 nXRadial2 nYRadial2 -- )
\ *G The Pie method draws a pie-shaped wedge bounded by the intersection of
\ ** an ellipse and two radials.
\ *P \i nLeftRect \d x-coord of upper-left corner of rectangle
\ *P \i nTopRect \d y-coord of upper-left corner of rectangle
\ *P \i nRightRect \d x-coord of lower-right corner of rectangle
\ *P \i nBottomRect \d y-coord of lower-right corner of rectangle
\ *P \i nXRadial1 \d x-coord of first radial's endpoint
\ *P \i nYRadial1 \d y-coord of first radial's endpoint
\ *P \i nXRadial2 \d x-coord of second radial's endpoint
\ *P \i nYRadial2 \d y-coord of second radial's endpoint
        8reverse hObject call Pie ?win-error ;M

:M Rectangle:   ( nLeftRect nTopRect nRightRect nBottomRect -- )
\ *G The Rectangle method draws a rectangle.
\ *P \i nLeftRect \d x-coord of upper-left corner of rectangle
\ *P \i nTopRect \d y-coord of upper-left corner of rectangle
\ *P \i nRightRect \d x-coord of lower-right corner of rectangle
\ *P \i nBottomRect \d y-coord of lower-right corner of rectangle
        4reverse hObject call Rectangle ?win-error ;M

:M RoundRect:   ( nLeftRect nTopRect nRightRect nBottomRect nWidth nHeight -- )
\ *G The RoundRect method draws a rectangle with rounded corners.
\ *P \i nLeftRect \d x-coord of upper-left corner of rectangle
\ *P \i nTopRect \d y-coord of upper-left corner of rectangle
\ *P \i nRightRect \d x-coord of lower-right corner of rectangle
\ *P \i nBottomRect \d y-coord of lower-right corner of rectangle
\ *P \i nWidth \d width of ellipse
\ *P \i nHeight \d height of ellipse
        6reverse hObject call RoundRect ?win-error ;M

:M SetPolyFillMode: ( iPolyFillMode -- )
\ *G The SetPolyFillMode method sets the polygon fill mode for methods
\ ** that fill polygons.
\ *P \i iPolyFillMode \d Specifies the new fill mode. This parameter can be one
\ ** of the following values.
\ *L
\ *| ALTERNATE | Selects alternate mode (fills the area between odd-numbered and even-numbered polygon sides on each scan line). |
\ *| WINDING   | Selects winding mode (fills any region with a nonzero winding value). |
        hObject call SetPolyFillMode ?win-error ;M

:M GetPolyFillMode: ( -- iPolyFillMode )
\ *G The GetPolyFillMode method retrieves the current polygon fill mode.
\ *P If the method succeeds, the return value specifies the polygon fill mode,
\ ** which can be one of the following values.
\ *L
\ *| ALTERNATE | Selects alternate mode (fills the area between odd-numbered and even-numbered polygon sides on each scan line). |
\ *| WINDING   | Selects winding mode (fills any region with a nonzero winding value). |
\ *P If an error occurs, the return value is zero.
        hObject call GetPolyFillMode ;M

:M Polygon:     ( lpPoints nCount -- )
\ *G The Polygon method draws a polygon consisting of two or more vertices
\ ** connected by straight lines. The polygon is outlined by using the current
\ ** pen and filled by using the current brush and polygon fill mode.
\ *P \i lpPoints \d polygon vertices
\ *P \i nCount \d count of polygon vertices
        dup 2 >=
        if   swap hObject call Polygon ?win-error
        else 2drop
        then ;M

:M PolyPolygon: ( lpPoints lpPolyCounts nCount -- )
\ *G The PolyPolygon method draws a series of closed polygons. Each polygon
\ ** is outlined by using the current pen and filled by using the current brush
\ ** and polygon fill mode. The polygons drawn by this method can overlap.
\ *P \i lpPoints \d array of vertices
\ *P \i lpPolyCounts \d array of count of vertices
\ *P \i nCount \d count of polygons
        3reverse hObject call PolyPolygon ?win-error ;M

\ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
\ *P \b The following methods are using an extra hBrush for filling \d
\ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

: InitRect      ( left top right bottom hBrush -- hBrush &rect )
        GetGdiObjectHandle >r SetRect: RECT r> RECT ;

:M FillRect:    ( left top right bottom hBrush -- )
\ *G The FillRect method fills a rectangle by using the specified brush.
\ ** This method includes the left and top borders, but excludes the right
\ ** and bottom borders of the rectangle.
\ *P Note: \i hBrush \d can be a valid brush handle or the address of a GdiBrush class !
        InitRect hObject Call FillRect ?win-error ;M

:M FrameRect:   ( left top right bottom hBrush -- )
\ *G The FrameRect method draws a border around the specified rectangle
\ ** by using the specified brush. The width and height of the border are
\ ** always one logical unit.
\ *P Note: \i hBrush \d can be a valid brush handle or the address of a GdiBrush class !
        InitRect hObject Call FrameRect ?win-error ;M

\ ----------------------------------------------------------------------
\ *P \b Text output \d
\ ----------------------------------------------------------------------

:M SetTextAlign: ( fMode -- fPreviousMode )
\ *G The SetTextAlign method sets the text-alignment flags for the
\ ** device context.
\ *P \i fMode \d Specifies the text alignment by using a mask of the values in the
\ ** following list. Only one flag can be chosen from those that affect horizontal
\ ** and vertical alignment. In addition, only one of the two flags that alter
\ ** the current position can be chosen.
\ *L
\ *| TA_BASELINE   | The reference point will be on the base line of the text. |
\ *| TA_BOTTOM     | The reference point will be on the bottom edge of the bounding rectangle. |
\ *| TA_TOP        | The reference point will be on the top edge of the bounding rectangle. |
\ *| TA_CENTER     | The reference point will be aligned horizontally with the center of the bounding rectangle. |
\ *| TA_LEFT       | The reference point will be on the left edge of the bounding rectangle. |
\ *| TA_RIGHT      | The reference point will be on the right edge of the bounding rectangle. |
\ *| TA_NOUPDATECP | The current position is not updated after each text output call. The reference point is passed to the text output method. |
\ *| TA_RTLREADING | Middle-Eastern Windows: The text is laid out in right to left reading order, as opposed to the default left to right order. This applies only when the font selected into the device context is either Hebrew or Arabic. |
\ *| TA_UPDATECP   | The current position is updated after each text output call. The current position is used as the reference point. |
\ *P When the current font has a vertical default base line, as with Kanji, the following
\ ** values must be used instead of TA_BASELINE and TA_CENTER.
\ *L
\ *| VTA_BASELINE | The reference point will be on the base line of the text. |
\ *| VTA_CENTER   | The reference point will be aligned vertically with the center of the bounding rectangle. |
\ *P The default values are TA_LEFT, TA_TOP, and TA_NOUPDATECP.
\ *P If the method fails, the return value is GDI_ERROR.
        hObject Call SetTextAlign ;M

:M GetTextAlign: ( -- fMode )
\ *G The GetTextAlign method retrieves the text-alignment setting for the specified
\ ** device context. If the method fails, the return value is GDI_ERROR.
        hObject Call GetTextAlign ;M

:M SetTextColor: ( colorref -- PreviousColorref )
\ *G The SetTextColor method sets the text color for the specified device context
\ ** to the specified color.
\ *P Note: \i colorref \d can be a 'simple' colorref or the address of a pPen Object class !
        GetObjectColor hObject call SetTextColor ;M

:M GetTextColor: ( -- colorref )
\ *G The GetTextColor method retrieves the current text color for the specified
\ ** device context.
        hObject call GetTextColor ;M

:M SetTextCharacterExtra: ( CharExtra -- OldCharExtra )
\ *G The SetTextCharacterExtra method sets the intercharacter spacing. Intercharacter
\ ** spacing is added to each character, including break characters, when the system
\ ** writes a line of text.
\ *P \i CharExtra \d Specifies the amount of extra space, in logical units, to be added to
\ ** each character. If the current mapping mode is not MM_TEXT, the nCharExtra parameter
\ ** is transformed and rounded to the nearest pixel.
        hObject call SetTextCharacterExtra ;M

:M GetTextCharacterExtra: ( -- CharExtra )
\ *G The GetTextCharacterExtra method retrieves the current intercharacter spacing
\ ** for the specified device context.
        hObject call GetTextCharacterExtra ;M

:M GetTextExtent: ( addr len -- width height )
\ *G The GetTextExtent method computes the width and height of the specified
\ ** string of text.
        Addr: SIZE 3reverse hObject call GetTextExtentPoint32 ?win-error
        GetX: SIZE GetY: SIZE ;M

:M GetTextMetrics: ( -- addr len )
\ *G The GetTextMetrics method fills the specified buffer with the metrics for the
\ ** currently selected font.
\ ** Returns the address and length of the textmetric struct.
        Addr: TEXTMETRIC hObject call GetTextMetrics ?win-error
        Addr: TEXTMETRIC Size: TEXTMETRIC ;M

:M TextOut:     ( x y addr len -- )
\ *G The TextOut method writes a character string at the specified location,
\ ** using the currently selected font, background color, and text color.
        4reverse hObject Call TextOut ?win-error ;M

:M DrawText:    ( addr len rect format -- )
\ *G The DrawText method draws formatted text in the specified rectangle.
\ ** It formats the text according to the specified method (expanding tabs,
\ ** justifying characters, breaking lines, and so forth).
\ *P Possible values for \i Format \d are:
\ *P \b DT_BOTTOM \d Justifies the text to the bottom of the rectangle. This
\ ** value is used only with the DT_SINGLELINE value.
\ *P \b DT_CALCRECT \d Determines the width and height of the rectangle. If there
\ ** are multiple lines of text, DrawText uses the width of the
\ ** rectangle pointed to by the lpRect parameter and extends the
\ ** base of the rectangle to bound the last line of text. If there
\ ** is only one line of text, DrawText modifies the right side of
\ ** the rectangle so that it bounds the last character in the line.
\ ** In either case, DrawText returns the height of the formatted
\ ** text but does not draw the text.
\ *P \b DT_CENTER \d Centers text horizontally in the rectangle.
\ *P \b DT_EDITCONTROL \d Duplicates the text-displaying characteristics of a multiline
\ ** edit control. Specifically, the average character width is
\ ** calculated in the same manner as for an edit control, and the
\ ** method does not display a partially visible last line.
\ *P \b DT_END_ELLIPSIS \d For displayed text, if the end of a string does not fit in the
\ ** rectangle, it is truncated and ellipses are added. If a word that
\ ** is not at the end of the string goes beyond the limits of the
\ ** rectangle, it is truncated without ellipses.
\ ** The string is not modified unless the DT_MODIFYSTRING flag is
\ ** specified. Compare with DT_PATH_ELLIPSIS and DT_WORD_ELLIPSIS.
\ *P \b DT_EXPANDTABS \d Expands tab characters. The default number of characters per
\ ** tab is eight. The DT_WORD_ELLIPSIS, DT_PATH_ELLIPSIS, and
\ ** DT_END_ELLIPSIS values cannot be used with the DT_EXPANDTABS value.
\ *P \b DT_EXTERNALLEADING \d Includes the font external leading in line height. Normally,
\ ** external leading is not included in the height of a line of text.
\ *P \b DT_HIDEPREFIX \d Windows 2000: Ignores the ampersand (&) prefix character in the
\ ** text. The letter that follows will not be underlined, but other
\ ** mnemonic-prefix characters are still processed. For example: \n
\ ** input string:    "A&bc&&d" \n
\ ** normal:          "Abc&d"   \n
\ ** DT_HIDEPREFIX:   "Abc&d"
\ *P Compare with DT_NOPREFIX and DT_PREFIXONLY.
\ *P \b DT_INTERNAL \d Uses the system font to calculate text metrics.
\ ** \b DT_LEFT \d Aligns text to the left.
\ *P \b DT_MODIFYSTRING \d Modifies the specified string to match the displayed text.
\ ** This value has no effect unless DT_END_ELLIPSIS or DT_PATH_ELLIPSIS
\ ** is specified.
\ *P \b DT_NOCLIP \d Draws without clipping. DrawText is somewhat faster when DT_NOCLIP
\ ** is used.
\ *P \b DT_NOFULLWIDTHCHARBREAK \d Windows 98, Windows 2000: Prevents a line break at a DBCS
\ ** (double-wide character string), so that the line breaking rule is
\ ** equivalent to SBCS strings. For example, this can be used in Korean
\ ** windows, for more readability of icon labels. This value has no effect
\ ** unless DT_WORDBREAK is specified.
\ *P \b DT_NOPREFIX \d Turns off processing of prefix characters. Normally, DrawText interprets
\ ** the mnemonic-prefix character & as a directive to underscore the character
\ ** that follows, and the mnemonic-prefix characters && as a directive to
\ ** print a single &. By specifying DT_NOPREFIX, this processing is turned
\ ** off. For example, \n
\ ** input string:   "A&bc&&d"  \n
\ ** normal:         "Abc&d"    \n
\ ** DT_NOPREFIX:    "A&bc&&d"
\ *P Compare with DT_HIDEPREFIX and DT_PREFIXONLY.
\ *P \b DT_PATH_ELLIPSIS \d For displayed text, replaces characters in the middle of the string with
\ ** ellipses so that the result fits in the specified rectangle. If the string
\ ** contains backslash (\) characters, DT_PATH_ELLIPSIS preserves as much as
\ ** possible of the text after the last backslash. The string is not modified
\ ** unless the DT_MODIFYSTRING flag is specified.
\ ** Compare with DT_END_ELLIPSIS and DT_WORD_ELLIPSIS.
\ *P \b DT_PREFIXONLY \d   Windows 2000: Draws only an underline at the position of the character
\ ** following the ampersand (&) prefix character. Does not draw any other
\ ** characters in the string. For example, \n
\ ** input string:    "A&bc&&d" \n
\ ** normal:          "Abc&d"   \n
\ ** DT_PREFIXONLY:   " _   "
\ *P Compare with DT_HIDEPREFIX and DT_NOPREFIX.
\ *P \b DT_RIGHT \d Aligns text to the right.
\ *P \b DT_RTLREADING \d Layout in right-to-left reading order for bi-directional text when the font
\ ** selected into the hdc is a Hebrew or Arabic font. The default reading order
\ ** for all text is left-to-right.
\ *P \b DT_SINGLELINE \d Displays text on a single line only. Carriage returns and line feeds do not
\ ** break the line.
\ *P \b DT_TABSTOP \d Sets tab stops. Bits 15–8 (high-order byte of the low-order word) of the
\ ** uFormat parameter specify the number of characters for each tab. The default
\ ** number of characters per tab is eight.The DT_CALCRECT, DT_EXTERNALLEADING,
\ ** DT_INTERNAL, DT_NOCLIP, and DT_NOPREFIX values cannot be used with the
\ ** DT_TABSTOP value.
\ *P \b DT_TOP \d Justifies the text to the top of the rectangle.
\ *P \b DT_VCENTER \d Centers text vertically. This value is used only with the DT_SINGLELINE value.
\ *P \b DT_WORDBREAK \d Breaks words. Lines are automatically broken between words if a word would
\ ** extend past the edge of the rectangle specified by the lpRect parameter. A
\ ** carriage return-line feed sequence also breaks the line.
\ *P \b DT_WORD_ELLIPSIS \d Truncates any word that does not fit in the rectangle and adds ellipses.
\ ** Compare with DT_END_ELLIPSIS and DT_PATH_ELLIPSIS.
        4reverse hObject Call DrawText ?win-error ;M

int tabbuf
int tabcnt
int tabwidth
40 constant deftabs
deftabs cells bytes tabarray

:M DefaultTabs: ( -- )
        deftabs 0
        ?DO  i 1+ tabwidth * CHAR-WIDTH *
             tabarray i cells+ !  \ fill default tabs
        LOOP
        tabarray to tabbuf
        deftabs  to tabcnt
        ;M

:M SetTabs:     ( a1 n1 -- )
\ *G Set tab positions. a1 is array of cells with offsets
        to tabcnt to tabbuf ;M

:M SetTabSize:  ( n1 -- n2 )
\ *G Set the width of a tab. Returns the old width.
        tabwidth swap
        to tabwidth DefaultTabs: self ;M

:M GetTabSize:  ( -- n1 )
\ *G Get the width of a tab.
        tabwidth ;M

:M TabbedTextOut: ( x y addr len -- width height )
\ *G The TabbedTextOut method writes a character string at a specified
\ ** location, expanding tabs to the values specified in an array of tab-stop
\ ** positions. Text is written in the currently selected font, background
\ ** color, and text color.
\ *P If the method succeeds, the return value is the dimensions, in logical
\ ** units, of the string.
        2>r 2>r 0 tabbuf tabcnt 2r> 2r>
        4reverse hObject call TabbedTextOut word-split ;M

\ ----------------------------------------------------------------------
\ *P \b Line and Curve methods \d
\ ----------------------------------------------------------------------

:M Arc:         ( nLeftRect nTopRect nRightRect nBottomRect nXStartArc nYStartArc nXEndArc nYEndArc -- )
\ *G The Arc method draws an elliptical arc.
\ *P The arc is drawn using the current pen; it is not filled.
\ *P The current position is neither used nor updated by Arc.
\ *P Windows 95/98: The drawing direction is always counterclockwise.
\ *P Windows NT/2000: Use the GetArcDirection: and SetArcDirection: methods
\ ** to get and set the current drawing direction for a device
\ ** context. The default drawing direction is counterclockwise.
\ *P \i nLeftRect \d x-coord of rectangle's upper-left corner
\ *P \i nTopRect \d y-coord of rectangle's upper-left corner
\ *P \i nRightRect \d x-coord of rectangle's lower-right corner
\ *P \i nBottomRect \d y-coord of rectangle's lower-right corner
\ *P \i nXStartArc \d x-coord of first radial ending point
\ *P \i nYStartArc \d y-coord of first radial ending point
\ *P \i nXEndArc \d x-coord of second radial ending point
\ *P \i nYEndArc \d y-coord of second radial ending point
        8reverse hObject call Arc ?win-error ;M

:M ArcTo:       ( nLeftRect nTopRect nRightRect nBottomRect nXRadial1 nYRadial1 nXRadial2 nYRadial2 -- )
\ *G The ArcTo method draws an elliptical arc.
\ ** ArcTo is similar to the Arc method, except that the current position is
\ ** updated.
\ *P The points (\i nLeftRect \d, \i nTopRect \d) and (\i nRightRect \d, \i nBottomRect \d)
\ ** specify the bounding rectangle. An ellipse formed by the specified bounding
\ ** rectangle defines the curve of the arc. The arc extends counterclockwise from
\ ** the point where it intersects the radial line from the center of the bounding
\ ** rectangle to the (\i nXRadial1 \d, \i nYRadial1 \d) point. The arc ends where it
\ ** intersects the radial line from the center of the bounding rectangle to the
\ ** (\i nXRadial2, \d \i nYRadial2 \d) point. If the starting point and ending point are the
\ ** same, a complete ellipse is drawn.
\ *P A line is drawn from the current position to the starting point of the arc.
\ *P If no error occurs, the current position is set to the ending point of the arc.
\ *P The arc is drawn using the current pen; it is not filled.
\ *P \i nLeftRect \d x-coord of rectangle's upper-left corner
\ *P \i nTopRect \d y-coord of rectangle's upper-left corner
\ *P \i nRightRect \d x-coord of rectangle's lower-right corner
\ *P \i nBottomRect \d y-coord of rectangle's lower-right corner
\ *P \i nXRadial1 \d x-coord of first radial ending point
\ *P \i nYRadial1 \d y-coord of first radial ending point
\ *P \i nXRadial2 \d x-coord of second radial ending point
\ *P \i nYRadial2 \d y-coord of second radial ending point
        8reverse hObject call ArcTo ?win-error ;M

:M LineTo:      ( nXEnd nYEnd -- )
\ *G The LineTo method draws a line from the current position up to, but not
\ ** including, the specified point.
\ *P The coordinates of the line's ending point are specified in logical units.
\ *P The line is drawn by using the current pen and, if the pen is a geometric pen,
\ ** the current brush.
\ *P If LineTo succeeds, the current position is set to the specified ending point.
        swap hObject call LineTo ?win-error ;M

:M MoveTo:      ( x y -- x1 x2 )
\ *G The MoveTo method updates the current position to the specified point and
\ ** returns the previous position.
        Addr: POINT 3reverse hObject call MoveToEx ?win-error
        GetX: POINT GetY: POINT ;M

:M GetCurrentPosition: ( -- x y )
\ *G The GetCurrentPosition method retrieves the current position in logical
\ ** coordinates.
        Addr: POINT hObject call GetCurrentPositionEx ?win-error
        GetX: POINT GetY: POINT ;M

:M PolyBezier:  ( pPoints cPoints -- )
\ *G The PolyBezier method draws one or more Bézier curves.
\ *P \i pPoints \d Pointer to an array of POINT structures that contain the endpoints
\ ** and control points of the curve(s).
\ *P \i cPoints \d Specifies the number of points in the pPoints array. This value must
\ ** be one more than three times the number of curves to be drawn, because each
\ ** Bézier curve requires two control points and an endpoint, and the initial
\ ** curve requires an additional starting point.
\ *P The Polybezier method draws cubic Bézier curves by using the endpoints and
\ ** control points specified by the pPoints parameter. The first curve is drawn from
\ ** the first point to the fourth point by using the second and third points as
\ ** control points. Each subsequent curve in the sequence needs exactly three more
\ ** points: the ending point of the previous curve is used as the starting point,
\ ** the next two points in the sequence are control points, and the third is the
\ ** ending point.
\ *P The current position is neither used nor updated by the PolyBezier method.
\ ** The figure is not filled. This method draws lines by using the current pen.
        swap hObject call PolyBezier ?win-error ;M

:M PolyBezierTo: ( pPoints cPoints -- )
\ *G The PolyBezierTo method draws one or more Bézier curves.
\ *P \i pPoints \d Pointer to an array of POINT structures that contains the endpoints
\ ** and control points.
\ *P \i cPoints \d Specifies the number of points in the pPoints array. This value must be
\ ** three times the number of curves to be drawn, because each Bézier curve requires
\ ** two control points and an ending point.
\ *P This method draws cubic Bézier curves by using the control points specified by
\ ** the pPoints parameter. The first curve is drawn from the current position to the
\ ** third point by using the first two points as control points. For each subsequent
\ ** curve, the method needs exactly three more points, and uses the ending point
\ ** of the previous curve as the starting point for the next.
\ *P PolyBezierTo moves the current position to the ending point of the last Bézier curve.
\ ** The figure is not filled. This method draws lines by using the current pen.
        swap hObject call PolyBezierTo ?win-error ;M

:M Polyline:    ( pPoints cPoints -- )
\ *G The Polyline method draws a series of line segments by connecting the points
\ ** in the specified array.
\ *P \i pPoints \d Pointer to an array of POINT structures. Each structure in the array
\ ** identifies a point in logical space.
\ *P \i cPoints \d Specifies the number of points in the array. This number must be greater
\ ** than or equal to two.
\ *P The lines are drawn from the first point through subsequent points by using the
\ ** current pen. Unlike the LineTo method, the Polyline method neither uses nor
\ ** updates the current position.
        swap hObject call Polyline ?win-error ;M

:M PolylineTo:  ( pPoints cPoints -- )
\ *G The PolylineTo method draws one or more straight lines.
\ *P \i pPoints \d Pointer to an array of POINT structures that contains the vertices of
\ ** the line.
\ *P \i cCount \d Specifies the number of points in the array.
\ *P A line is drawn from the current position to the first point specified by the
\ ** pPoints parameter by using the current pen. For each additional line, the method
\ ** draws from the ending point of the previous line to the next point specified by
\ ** pPoints.
\ *P PolylineTo moves the current position to the ending point of the last line.
\ ** If the line segments drawn by this method form a closed figure, the figure is
\ ** not filled.
        swap hObject call PolylineTo ?win-error ;M

\ ----------------------------------------------------------------------
\ *P \b Bitmap support \d
\ ----------------------------------------------------------------------

:M CreateCompatibleDC: ( -- hDC )
\ *G The CreateCompatibleDC method creates a memory device context compatible
\ ** with the device.
        hObject call CreateCompatibleDC ;M

:M CreateCompatibleBitmap: ( width height -- hBitmap )
\ *G The CreateCompatibleBitmap method creates a bitmap compatible with the
\ ** device that is associated with the device context.
        swap hObject call CreateCompatibleBitmap ;M

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------

:M BitBlt:      ( nXDest nYDest nWidth nHeight hdcSrc nXSrc nYSrc dwRop -- )
\ *G The BitBlt method performs a bit-block transfer of the color data corresponding
\ ** to a rectangle of pixels from the specified source device context into a
\ ** destination device context.
\ *P \i nXDest \d x-coord of destination upper-left corner
\ *P \i nYDest \d y-coord of destination upper-left corner
\ *P \i nWidth \d width of destination rectangle
\ *P \i nHeight \d height of destination rectangle
\ *P \i hdcSrc \d source DC
\ *P \i nXSrc \d x-coordinate of source upper-left corner
\ *P \i nYSrc \d y-coordinate of source upper-left corner
\ *P \i dwRop \d
        >r >r >r GetGdiObjectHandle r> r> r>
        8reverse hObject call BitBlt ?win-error ;M

:M SetDIBColorTable: ( uStartIndex cEntries pColors -- )
\ *G The SetDIBColorTable method sets RGB (red, green, blue) color values in a range
\ ** of entries in the color table of the DIB that is currently selected into a specified
\ ** device context.
\ *P \i uStartIndex \d A zero-based color table index that specifies the first color table
\ ** entry to set.
\ *P \i cEntries \d Specifies the number of color table entries to set.
\ *P \i pColors \d Pointer to an array of RGBQUAD structures containing new color information
\ ** for the DIB's color table.
        3reverse hObject call SetDIBColorTable ?win-error ;M

:M GetDIBColorTable: ( uStartIndex cEntries pColors -- )
\ *G The GetDIBColorTable method retrieves RGB (red, green, blue) color values from
\ ** a range of entries in the color table of the DIB section bitmap that is currently
\ ** selected into a specified device context.
\ *P \i uStartIndex \d A zero-based color table index that specifies the first color table
\ ** entry to retrieve.
\ *P \i cEntries \d Specifies the number of color table entries to retrieve.
\ *P \i pColors \d Pointer to a buffer that receives an array of RGBQUAD data structures
\ ** containing color information from the DIB's color table. The buffer must be large
\ ** enough to contain as many RGBQUAD data structures as the value of cEntries.
\ *P The GetDIBColorTable method should be called to retrieve the color table for DIB
\ ** section bitmaps that use 1, 4, or 8 bpp. The biBitCount member of a bitmap's associated
\ ** BITMAPINFOHEADER structure specifies the number of bits-per-pixel. DIB section bitmaps
\ ** with a biBitCount value greater than eight do not have a color table, but they do have
\ ** associated color masks. Use the GetObject method to retrieve those color masks.
        3reverse hObject call GetDIBColorTable ?win-error ;M

:M ExtFloodFill: ( nXStart nYStart crColor fuFillType -- )
\ *G The ExtFloodFill method fills an area of the display surface with the current brush.
\ *P \i nXStart \d Specifies the logical x-coordinate of the point where filling is to start.
\ *P \i nYStart \d Specifies the logical y-coordinate of the point where filling is to start.
\ *P \i crColor \d Specifies the color of the boundary or of the area to be filled. The
\ ** interpretation of crColor depends on the value of the fuFillType parameter.
\ *P \i fuFillType \d Specifies the type of fill operation to be performed. This parameter must
\ ** be one of the following values.
\ *P \b FLOODFILLBORDER \d The fill area is bounded by the color specified by the crColor parameter.
\ ** This style is identical to the filling performed by the FloodFill method.
\ *P \b FLOODFILLSURFACE \d The fill area is defined by the color that is specified by
\ ** crColor. Filling continues outward in all directions as long as the color is
\ ** encountered. This style is useful for filling areas with multicolored boundaries.
        swap GetObjectColor swap
        4reverse hObject call  ExtFloodFill ?win-error ;M

\ ----------------------------------------------------------------------
\ *P \b Path methods \d
\ ** A path is one or more figures (or shapes) that are filled, outlined, or both filled and
\ ** outlined. Win32-based applications use paths in many ways. Paths are used in drawing and
\ ** painting applications. Computer-aided design (CAD) applications use paths to create unique
\ ** clipping regions, to draw outlines of irregular shapes, and to fill the interiors of
\ ** irregular shapes. An irregular shape is a shape composed of Bézier curves and straight
\ ** lines. (A regular shape is an ellipse, a circle, a rectangle, or a polygon.)
\ ----------------------------------------------------------------------

:M BeginPath:   ( -- )
\ *G The BeginPath method opens a path bracket in the specified device context
\ ** After a path bracket is open, an application can begin calling GDI drawing
\ ** functions to define the points that lie in the path. An application can close
\ ** an open path bracket by calling the EndPath method.
        hObject Call BeginPath ?win-error ;M

:M EndPath:     ( -- )
\ *G The EndPath method closes a path bracket and selects the path defined by the
\ ** bracket into the specified device context.
        hObject Call EndPath ?win-error ;M

:M AbortPath:     ( -- )
\ *G The AbortPath method closes and discards any paths in the specified device context.
\ ** If there is an open path bracket in the given device context, the path bracket
\ ** is closed and the path is discarded. If there is a closed path in the device context,
\ ** the path is discarded.
        hObject Call AbortPath ?win-error ;M

:M CloseFigure:     ( -- )
\ *G The CloseFigure method closes an open figure in a path.
\ *P The CloseFigure method closes the figure by drawing a line from the current position
\ ** to the first point of the figure (usually, the point specified by the most recent call
\ ** to the MoveToEx function) and then connects the lines by using the line join style.
\ ** If a figure is closed by using the LineTo function instead of CloseFigure, end caps are
\ ** used to create the corner instead of a join.
\ *P The CloseFigure function should only be called if there is an open path bracket in the
\ ** specified device context.
\ *P A figure in a path is open unless it is explicitly closed by using this function. (A
\ ** figure can be open even if the current point and the starting point of the figure are the
\ ** same.)
\ *P After a call to CloseFigure, adding a line or curve to the path starts a new figure.
        hObject Call CloseFigure ?win-error ;M

:M FillPath:    ( -- )
\ *G The FillPath method closes any open figures in the current path and fills the path's
\ ** interior by using the current brush and polygon-filling mode.
\ ** After its interior is filled, the path is discarded from the DC
        hObject Call FillPath ?win-error ;M

:M FlattenPath: ( -- )
\ *G The FlattenPath method transforms any curves in the path that is selected into the
\ ** current device context (DC), turning each curve into a sequence of lines.
        hObject Call FlattenPath ?win-error ;M

:M GetPath:     ( lpPoints lpTypes nSize -- n )
\ *G The GetPath method retrieves the coordinates defining the endpoints of lines and the
\ ** control points of curves found in the path that is selected into the device context.
\ ** \i lpPoints \d Pointer to an array of POINT structures that receives the line endpoints and
\ ** curve control points.
\ *P \i lpTypes \d Pointer to an array of bytes that receives the vertex types.
\ ** This parameter can be one of the following values.
\ *P \b PT_MOVETO \d Specifies that the corresponding point in the lpPoints parameter
\ ** starts a disjoint figure.
\ *P \b PT_LINETO \d Specifies that the previous point and the corresponding point in
\ ** lpPoints are the endpoints of a line.
\ *P \b PT_BEZIERTO \d Specifies that the corresponding point in lpPoints is a control
\ ** point or ending point for a Bézier curve.
\ ** PT_BEZIERTO values always occur in sets of three. The point in the path
\ ** immediately preceding them defines the starting point for the Bézier curve.
\ ** The first two PT_BEZIERTO points are the control points, and the third PT_BEZIERTO
\ ** point is the ending (if hard-coded) point.
\ *P A PT_LINETO or PT_BEZIERTO value may be combined with the following value (by
\ ** using the bitwise operator OR) to indicate that the corresponding point is the
\ ** last point in a figure and the figure should be closed. Flag Description
\ ** PT_CLOSEFIGURE Specifies that the figure is automatically closed after the
\ ** corresponding line or curve is drawn. The figure is closed by drawing a line
\ ** from the line or curve endpoint to the point corresponding to the last PT_MOVETO.
\ *P \i nSize \d Specifies the total number of POINT structures that can be stored in the array pointed to
\ ** by lpPoints. This value must be the same as the number of bytes that can be placed in the
\ ** array pointed to by lpTypes.
\ *P If the nSize parameter is nonzero, the return value is the number of points enumerated. If nSize
\ ** is 0, the return value is the total number of points in the path (and GetPath writes nothing to
\ ** the buffers). If nSize is nonzero and is less than the number of points in the path, the return
\ ** value is -1.
        3reverse hObject Call GetPath ;M

:M PathToRegion:  ( -- )
\ *G The PathToRegion method creates a region from the path that is selected into the specified
\ ** device context. The resulting region uses device coordinates.
\ ** After PathToRegion converts a path into a region, the system discards the closed path from the
\ ** device context.
        hObject Call PathToRegion ?win-error ;M

:M StrokePath:  ( -- )
\ *G The StrokePath method renders the specified path by using the current pen.
        hObject Call StrokePath  ?win-error ;M

:M StrokeAndFillPath:    ( -- )
\ *G The StrokeAndFillPath method closes any open figures in a path, strokes the outline of the
\ ** path by using the current pen, and fills its interior by using the current brush.
\ ** The StrokeAndFillPath method has the same effect as closing all the open figures in the path,
\ ** and stroking and filling the path separately, except that the filled region will not overlap the
\ ** stroked region even if the pen is wide.
        hObject Call StrokeAndFillPath ?win-error ;M

:M WidenPath:   ( -- )
\ *G The WidenPath function redefines the current path as the area that would be painted if the path
\ ** were stroked using the pen currently selected into the given device context.
\ ** The WidenPath function is successful only if the current pen is a geometric pen created by the
\ ** ExtCreatePen function, or if the pen is created with the CreatePen function and has a width, in
\ ** device units, of more than one.
\ ** The device context must contain a closed path.
\ ** Any Bézier curves in the path are converted to sequences of straight lines approximating the
\ ** widened curves. As such, no Bézier curves remain in the path after WidenPath is called.
        hObject Call WidenPath ?win-error ;M

\ *P \b Missing methods: \d
\ ** SetPixel \n
\ ** GetPixel \n
\ ** GetStretchBltMode \n
\ ** AlphaBlend    W98 and w2k or later \n
\ ** GradientFill  W98 and w2k or later \n
\ ** SetDIBitsToDevice \n
\ ** SetStretchBltMode \n
\ ** StretchBlt \n
\ ** StretchDIBits \n
\ ** TransparentBlt W98 and w2k or later \n
\ ** PatBlt \n
\ ** AngleArc \n
\ ** SetMiterLimit \n
\ ** GetMiterLimit \n

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------

:M ClassInit:   ( -- )
        ClassInit: super
        8 to tabwidth
        DefaultTabs: self
        ;M

;class
\ *G End of gdiDC class

module

\ *Z
