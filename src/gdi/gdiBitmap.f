\ *D doc\classes\
\ *! gdiBitmap
\ *T gdiBitmap -- GDI Bitmap class.
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

cr .( Loading GDI class library - Bitmap...)

needs gdiBase.f

internal
external

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Bitmap class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ *W <a name="gdiBitmap"></a>
:class gdiBitmap <super gdiObject
\ *G Bitmap class

gdiSize SIZE

:M ClassInit:   ( -- )
        ClassInit: super
        ;M

:M CreateBitmap: ( Width Height Planes BitsPerPel pBits -- f )
\ *G The CreateBitmap function creates a bitmap with the specified width, height,
\ ** and color format (color planes and bits-per-pixel). \n
\ ** \n
\ ** Width  Specifies the bitmap width, in pixels.      \n
\ ** Height Specifies the bitmap height, in pixels.     \n
\ ** Planes Specifies the number of color planes used by the device.    \n
\ ** BitsPerPel Specifies the number of bits required to identify the color of a
\ ** single pixel. \n
\ ** pBits Pointer to an array of color data used to set the colors in a rectangle
\ ** of pixels. Each scan line in the rectangle must be word aligned (scan
\ ** lines that are not word aligned must be padded with zeros). If this
\ ** parameter is NULL, the contents of the new bitmap is undefined. \n
\ ** \n
\ ** After a bitmap is created, it can be selected into a device context by calling
\ ** the SelectObject function. The CreateBitmap function can be used to create color
\ ** bitmaps. However, for performance reasons applications should use CreateBitmap
\ ** to create monochrome bitmaps and CreateCompatibleBitmap to create color bitmaps.
\ ** When a color bitmap returned from CreateBitmap is selected into a device context,
\ ** the system must ensure that the bitmap matches the format of the device context
\ ** it is being selected into. Since CreateCompatibleBitmap takes a device context,
\ ** it returns a bitmap that has the same format as the specified device context.
\ ** Because of this, subsequent calls to SelectObject are faster than with a color
\ ** bitmap returned from CreateBitmap. \n
\ ** \n
\ ** If the bitmap is monochrome, zeros represent the foreground color and ones represent
\ ** the background color for the destination device context. \n
\ ** \n
\ ** If an application sets the nWidth or nHeight parameters to zero, CreateBitmap
\ ** returns the handle to a 1-by-1 pixel, monochrome bitmap. \n
\ ** \n
\ ** When you no longer need the bitmap, call the Destroy: method to delete it. \n
\ ** \n
\ ** Windows 95/98: The created bitmap cannot exceed 16MB in size
        5reverse call CreateBitmap SetHandle: super
        Valid?: super ;M

:M CreateBitmapIndirect: ( pBitmap -- f )
\ *G The CreateBitmapIndirect function creates a bitmap with the specified width,
\ ** height, and color format (color planes and bits-per-pixel).
\ ** pBitmap Pointer to a BITMAP structure that contains information about the
\ ** bitmap. If an application sets the bmWidth or bmHeight members to zero,
\ ** CreateBitmapIndirect returns the handle to a 1-by-1 pixel, monochrome bitmap.
        call CreateBitmapIndirect SetHandle: super
        Valid?: super ;M

:M CreateCompatibleBitmap: ( Width Height hDC -- f )
\ *G The CreateCompatibleBitmap function creates a bitmap compatible with the device
\ ** that is associated with the specified device context. \n
\ ** \n
\ ** The color format of the bitmap created by the CreateCompatibleBitmap function
\ ** matches the color format of the device identified by the hdc parameter. This
\ ** bitmap can be selected into any memory device context that is compatible with
\ ** the original device. \n
\ ** \n
\ ** Because memory device contexts allow both color and monochrome bitmaps, the format
\ ** of the bitmap returned by the CreateCompatibleBitmap function differs when the
\ ** specified device context is a memory device context. However, a compatible bitmap
\ ** that was created for a nonmemory device context always possesses the same color
\ ** format and uses the same color palette as the specified device context. \n
\ ** \n
\ ** Note: When a memory device context is created, it initially has a 1-by-1 monochrome
\ ** bitmap selected into it. If this memory device context is used in CreateCompatibleBitmap,
\ ** the bitmap that is created is a monochrome bitmap. To create a color bitmap, use the
\ ** hDC that was used to create the memory device context, as shown in the following code: \n
\ ** \n
\ **     HDC memDC = CreateCompatibleDC ( hDC ); \n
\ **     HBITMAP memBM = CreateCompatibleBitmap ( hDC ); \n
\ **     SelectObject ( memDC, memBM ); \n
\ ** \n
\ ** If an application sets the nWidth or nHeight parameters to zero, CreateCompatibleBitmap
\ ** returns the handle to a 1-by-1 pixel, monochrome bitmap. \n
\ ** \n
\ ** If a DIB section, which is a bitmap created by the CreateDIBSection function, is selected
\ ** into the device context identified by the hdc parameter, CreateCompatibleBitmap creates a
\ ** DIB section. \n
\ ** \n
\ ** When you no longer need the bitmap, call the DeleteObject function to delete it. \n
\ ** \n
\ ** Windows 95/98: The created bitmap cannot exceed 16MB in size.
        GetGdiObjectHandle >r swap r> call CreateCompatibleBitmap SetHandle: super
        Valid?: super ;M

:M CreateDIBitmap: ( pbmih fdwInit pbInit pbmi fuUsage hdc -- f )
\ *G The CreateDIBitmap function creates a device-dependent bitmap (DDB) from a DIB and,
\ ** optionally, sets the bitmap bits. \n
\ ** lpbmih Pointer to a bitmap information header structure, which may be one of those
\ ** shown in the following table.
\ *L
\ *| Operating system              | Bitmap information header
\ *| Windows NT 3.51 and earlier   | BITMAPINFOHEADER |
\ *| Windows NT 4.0 and Windows 95 | BITMAPV4HEADER (NOT SUPPORTED !!!) |
\ *| Windows 2000 and Windows 98   | BITMAPV5HEADER (NOT SUPPORTED !!!) |
\ *P If fdwInit is CBM_INIT, the function uses the bitmap information header structure to
\ ** obtain the desired width and height of the bitmap as well as other information. Note
\ ** that a positive value for the height indicates a bottom-up DIB while a negative value
\ ** for the height indicates a top-down DIB. Calling CreateDIBitmap with fdwInit as CBM_INIT
\ ** is equivalent to calling the CreateCompatibleBitmap function to create a DDB in the format
\ ** of the device and then calling the SetDIBits function to translate the DIB bits to the DDB. \n
\ ** fdwInit Specifies how the system initializes the bitmap bits. The following values is defined.
\ ** Value Meaning CBM_INIT If this flag is set, the system uses the data pointed to by the lpbInit
\ ** and lpbmi parameters to initialize the bitmap's bits. If this flag is clear, the data pointed
\ ** to by those parameters is not used. \n
\ ** If fdwInit is zero, the system does not initialize the bitmap's bits. \n
\ ** lpbInit Pointer to an array of bytes containing the initial bitmap data. The format of the data
\ ** depends on the biBitCount member of the BITMAPINFO structure to which the lpbmi parameter points. \n
\ ** lpbmi Pointer to a BITMAPINFO structure that describes the dimensions and color format of the
\ ** array pointed to by the lpbInit parameter. \n
\ ** fuUsage Specifies whether the bmiColors member of the BITMAPINFO structure was initialized and,
\ ** if so, whether bmiColors contains explicit red, green, blue (RGB) values or palette indexes.
\ ** The fuUsage parameter must be one of the following values.
\ *L
\ *| DIB_PAL_COLORS | A color table is provided and consists of an array of 16-bit indexes into the logical palette of the device context into which the bitmap is to be selected. |
\ *| DIB_RGB_COLORS | A color table is provided and contains literal RGB values. |
        GetGdiObjectHandle >r 5reverse r> call CreateDIBitmap SetHandle: super
        Valid?: super ;M

:M CreateDIBSection: ( pbmi iUsage ppvBits hSection dwOffset hdc -- f )
\ *G The CreateDIBSection function creates a DIB that applications can write to directly. The function
\ ** gives you a pointer to the location of the bitmap's bit values. You can supply a handle to a
\ ** file-mapping object that the function will use to create the bitmap, or you can let the system
\ ** allocate the memory for the bitmap. \n
\ ** hdc Handle to a device context. If the value of iUsage is DIB_PAL_COLORS, the function uses
\ ** this device context's logical palette to initialize the DIB's colors. \n
\ ** pbmi Pointer to a BITMAPINFO structure that specifies various attributes of the DIB, including
\ ** the bitmap's dimensions and colors. \n
\ ** iUsage Specifies the type of data contained in the bmiColors array member of the BITMAPINFO
\ ** structure pointed to by pbmi (either logical palette indexes or literal RGB values). The
\ ** following values are defined.
\ *L
\ *| DIB_PAL_COLORS | The bmiColors member is an array of 16-bit indexes into the logical palette of the device context specified by hdc. |
\ *| DIB_RGB_COLORS | The BITMAPINFO structure contains an array of literal RGB values. |
\ *P ppvBits Pointer to a variable that receives a pointer to the location of the DIB's bit values. \n
\ ** hSection Handle to a file-mapping object that the function will use to create the DIB. This
\ ** parameter can be NULL. If hSection is not NULL, it must be a handle to a file-mapping object
\ ** created by calling the CreateFileMapping function with the PAGE_READWRITE or PAGE_WRITECOPY flag.
\ ** Read-only DIB sections are not supported. Handles created by other means will cause CreateDIBSection
\ ** to fail. If hSection is not NULL, the CreateDIBSection function locates the bitmap's bit values at
\ ** offset dwOffset in the file-mapping object referred to by hSection. An application can later retrieve
\ ** the hSection handle by calling the GetObject function with the HBITMAP returned by CreateDIBSection.
\ ** If hSection is NULL, the system allocates memory for the DIB. In this case, the CreateDIBSection
\ ** function ignores the dwOffset parameter. An application cannot later obtain a handle to this memory.
\ ** The dshSection member of the DIBSECTION structure filled in by calling the GetObject function will
\ ** be NULL. \n
\ ** dwOffset Specifies the offset from the beginning of the file-mapping object referenced by hSection
\ ** where storage for the bitmap's bit values is to begin. This value is ignored if hSection is NULL.
\ ** The bitmap's bit values are aligned on doubleword boundaries, so dwOffset must be a multiple of the
\ ** size of a DWORD.
        GetGdiObjectHandle >r 5reverse r> call CreateDIBSection SetHandle: super
        Valid?: super ;M

:M SetBitmapDimension: ( width height -- oldwidth oldheight )
\ *G The SetBitmapDimension function assigns preferred dimensions to a bitmap. These dimensions can be
\ ** used by applications; however, they are not used by the system. \n
\ ** Width Specifies the width, in 0.1-millimeter units, of the bitmap. \n
\ ** Height Specifies the height, in 0.1-millimeter units, of the bitmap. \n
\ ** An application can retrieve the dimensions assigned to a bitmap with the SetBitmapDimensionEx function
\ ** by calling the GetBitmapDimension function. \n
\ ** The bitmap identified by hBitmap cannot be a DIB section, which is a bitmap created by the
\ ** CreateDIBSection function. If the bitmap is a DIB section, the SetBitmapDimension function fails.
        Addr: SIZE 3reverse hObject call SetBitmapDimensionEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M GetBitmapDimension: ( -- width height )
\ *G The GetBitmapDimension function retrieves the dimensions of a bitmap. The retrieved dimensions must
\ ** have been set by the SetBitmapDimension function.
\ ** The function returns the height and width of the bitmap, in .01-mm units.
        Addr: SIZE hObject call GetBitmapDimensionEx ?win-error
        GetX: SIZE GetY: SIZE ;M

:M SetDIBits:   ;M
\ *G not implemented, yet.
:M GetDIBits:   ;M
\ *G not implemented, yet.
:M LoadBitmap:  ;M
\ *G not implemented, yet.
:M MaskBlt:     ;M
\ *G not implemented, yet.
:M PlgBlt:      ;M
\ *G not implemented, yet.

;class
\ *G End of Bitmap class

module

\ *Z
