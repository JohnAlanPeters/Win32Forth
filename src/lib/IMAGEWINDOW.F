\ $Id: IMAGEWINDOW.F,v 1.4 2011/08/18 15:34:40 georgeahubert Exp $

\ Routines to define object class for viewing bitmaps in a window
\ Some code extracted from 4FreeImage.f by J.v.d.Ven

\ August     31, 2004 - updated to use DrawDibDraw function for displaying bitmaps
\ November 22nd, 2003 - updated to be more versatile with image handling &
\                       manipulation. Added functions from FreeImage.dll version 3.0
\ September 8th, 2003 - added Wipe: to imagewindow class to allow just blanking a window.

cr .( Loading ImageWindow.f : viewing bitmaps in a window...)


\ only forth also definitions
WinLibrary FreeImage.dll
WINLIBRARY msvfw32.dll
0x0004 constant DDF_SAME_HDC

needs enum.f        \ enumerated constants
\- as >SYSTEM : AS WINPROC-LAST @ PROC>CFA ALIAS ; SYSTEM>

\- ?exitm macro ?exitm " if exitm then"

INTERNAL
\ FreeImage Load / Save flag constants
#define BMP_DEFAULT         0
#define BMP_SAVE_RLE        1
#define CUT_DEFAULT         0
#define ICO_DEFAULT         0
#define ICO_FIRST           0
#define ICO_SECOND          0
#define ICO_THIRD           0
#define IFF_DEFAULT         0
#define JPEG_DEFAULT        0
#define JPEG_FAST           1
#define JPEG_ACCURATE       2
#define JPEG_QUALITYSUPERB  0x80
#define JPEG_QUALITYGOOD    0x100
#define JPEG_QUALITYNORMAL  0x200
#define JPEG_QUALITYAVERAGE 0x400
#define JPEG_QUALITYBAD     0x800
#define KOALA_DEFAULT       0
#define LBM_DEFAULT         0
#define MNG_DEFAULT         0
#define PCD_DEFAULT         0
#define PCD_BASE            1
#define PCD_BASEDIV4        2
#define PCD_BASEDIV16       3
#define PCX_DEFAULT         0
#define PNG_DEFAULT         0
#define PNG_IGNOREGAMMA     1       \ avoid gamma correction
#define PNM_DEFAULT         0
#define PNM_SAVE_RAW        0       \ If set the writer saves in RAW format (i.e. P4, P5 or P6)
#define PNM_SAVE_ASCII      1       \ If set the writer saves in ASCII format (i.e. P1, P2 or P3)
#define PSD_DEFAULT         0
#define RAS_DEFAULT         0
#define TARGA_DEFAULT       0
#define TARGA_LOAD_RGB888   1       \ If set the loader converts RGB555 and ARGB8888 -> RGB888.
#define TARGA_LOAD_RGB555   2       \ This flag is obsolete
#define TIFF_DEFAULT        0
#define TIFF_CMYK           0x0001  \ reads/stores tags for separated CMYK (use | to combine with compression flags)
#define TIFF_PACKBITS       0x0100  \ save using PACKBITS compression
#define TIFF_DEFLATE        0x0200  \ save using DEFLATE compression
#define TIFF_ADOBE_DEFLATE  0x0400  \ save using ADOBE DEFLATE compression
#define TIFF_NONE           0x0800  \ save without any compression
#define WBMP_DEFAULT        0
#define XBM_DEFAULT         0
#define XPM_DEFAULT         0

\ possible FreeImage file types
-1 to enum-value
1 to increment
enum:   FIF_UNKNOWN
        FIF_BMP
        FIF_ICO
        FIF_JPEG
        FIF_JNG
        FIF_KOALA
        FIF_LBM
        FIF_MNG
        FIF_PBM
        FIF_PBMRAW
        FIF_PCD
        FIF_PCX
        FIF_PGM
        FIF_PGMRAW
        FIF_PNG
        FIF_PPM
        FIF_PPMRAW
        FIF_RAS
        FIF_TARGA
        FIF_TIFF
        FIF_WBMP
        FIF_PSD
        FIF_CUT
        FIF_XBM
        FIF_XPM
        FIF_GIF ;
FIF_LBM Constant FIF_IFF

\ Image type used in FreeImage.
0  to enum-value
enum:
    FIT_UNKNOWN     \ unknown type
    FIT_BITMAP      \ standard image           : 1-, 4-, 8-, 16-, 24-, 32-bit
    FIT_UINT16      \ array of unsigned short  : unsigned 16-bit
    FIT_INT16       \ array of short           : signed 16-bit
    FIT_UINT32      \ array of unsigned long   : unsigned 32-bit
    FIT_INT32       \ array of long            : signed 32-bit
    FIT_FLOAT       \ array of float           : 32-bit IEEE floating point
    FIT_DOUBLE      \ array of double          : 64-bit IEEE floating point
    FIT_COMPLEX     \ array of FICOMPLEX       : 2 x 64-bit IEEE floating point
;

\ Image color type used in FreeImage.
0 to enum-value
enum:
    FIC_MINISWHITE      \ min value is white
    FIC_MINISBLACK      \ min value is black
    FIC_RGB             \ RGB color model
    FIC_PALETTE         \ color map indexed
    FIC_RGBALPHA        \ RGB color model with alpha channel
    FIC_CMYK            \ CMYK color model
;

\ Color quantization algorithms.
\ Constants used in FreeImage_ColorQuantize.
0 to enum-value
enum:
    FIQ_WUQUANT         \ Xiaolin Wu color quantization algorithm
    FIQ_NNQUANT         \ NeuQuant neural-net quantization algorithm by Anthony Dekker
;

\ Dithering algorithms.
\ Constants used FreeImage_Dither.
0 to enum-value
enum:
    FID_FS              \ Floyd & Steinberg error diffusion
    FID_BAYER4x4        \ Bayer ordered dispersed dot dithering (order 2 dithering matrix)
    FID_BAYER8x8        \ Bayer ordered dispersed dot dithering (order 3 dithering matrix)
    FID_CLUSTER6x6      \ Ordered clustered dot dithering (order 3 - 6x6 matrix)
    FID_CLUSTER8x8      \ Ordered clustered dot dithering (order 4 - 8x8 matrix)
    FID_CLUSTER16x16    \ Ordered clustered dot dithering (order 8 - 16x16 matrix)
;

\ Upsampling / downsampling filters.
\ Constants used in FreeImage_Rescale.
0 to enum-value
enum:
    FILTER_BOX          \ Box, pulse, Fourier window, 1st order (constant) b-spline
    FILTER_BICUBIC      \ Mitchell & Netravali's two-param cubic filter
    FILTER_BILINEAR     \ Bilinear filter
    FILTER_BSPLINE      \ 4th order (cubic) b-spline
    FILTER_CATMULLROM   \ Catmull-Rom spline, Overhauser spline
    FILTER_LANCZOS3     \ Lanczos3 filter
;

\ Color channels.
\ Constants used in color manipulation routines.
0 to enum-value
enum:
    FICC_RGB            \ Use red, green and blue channels
    FICC_RED            \ Use red channel
    FICC_GREEN          \ Use green channel
    FICC_BLUE           \ Use blue channel
    FICC_ALPHA          \ Use alpha channel
    FICC_BLACK          \ Use black channel
    FICC_REAL           \ Complex images: use real part
    FICC_IMAG           \ Complex images: use imaginary part
    FICC_MAG            \ Complex images: use magnitude
    FICC_PHASE          \ Complex images: use phase

;

EXTERNAL
1 proc _FreeImage_GetWidth@4            as FIGetWidth
1 proc _FreeImage_GetHeight@4           as FIGetHeight
4 proc _FreeImage_Save@16               as FISave
1 proc _FreeImage_GetInfo@4             as FIGetInfo
1 proc _FreeImage_GetBits@4             as FIGetBits
1 proc _FreeImage_Unload@4              as FIUnload
3 proc _FreeImage_Load@12               as FILoad
1 proc _FreeImage_GetFIFFromFilename@4  as FIGetInfoFromFilename
9 proc _FreeImage_ConvertFromRawBits@36 as FIConvertFromRawBits
2 proc _FreeImage_GetFileType@8         as FIGetFileType
0 proc _FreeImage_GetVersion@0          as FIGetVersion
1 proc _FreeImage_FlipVertical@4        as FIFlipVertical
1 proc _FreeImage_FlipHorizontal@4      as FIFlipHorizontal
1 proc _FreeImage_ConvertTo8Bits@4      as FIConvertTo8Bits
1 proc _FreeImage_ConvertTo16Bits565@4  as FIConvertTo16Bits
1 proc _FreeImage_ConvertTo24Bits@4     as FIConvertTo24Bits
1 proc _FreeImage_ConvertTo32Bits@4     as FIConvertTo32Bits
2 proc _FreeImage_RotateClassic@12      as FIRotate
2 proc _FreeImage_AdjustBrightness@12   as FIAdjustBrightness
2 proc _FreeImage_AdjustContrast@12     as FIAdjustContrast
0 proc _FreeImage_Invert@4              as FIInvert
1 proc _FreeImage_Clone@4               as FIClone
1 proc _FreeImage_GetBPP@4              as FIBitsPerPixel
4 proc _FreeImage_Rescale@16            as FIReScale
2 proc _FreeImage_AdjustGamma@12        as FIAdjustGamma
4 proc _FreeImage_LoadFromHandle@16     as FILoadFromHandle

1 to enum-value
enum:   NORMAL_FIT
        BEST_FIT
        FIT_SIZE ;

INTERNAL
0 value ThisImage  \ allow forward referencing for right click
0 value wincnt     \ count of open image windows

PopUpBar ImagePopupBar

PopUp ""
         MenuItem "Open image file"             OpenImageFile: ThisImage ;
         MenuItem "Erase image"                          Wipe: ThisImage ;
         MenuItem "Restore original image"             Reload: ThisImage ;
         MenuSeparator
         SubMenu  "Save image as"
                MenuItem "Bitmap"                SaveAsBitmap: ThisImage ;
                MenuItem "Jpeg"                    SaveAsJpeg: ThisImage ;
                MenuItem "Png"                      SaveAsPng: ThisImage ;
         EndSubMenu
         MenuSeparator
   false MENUMESSAGE     "Action"
         MenuSeparator
         MenuItem "Invert image"                 InvertImage: ThisImage ;
         SubMenu "Flip"
            MenuItem "Horizontal"  FlipHorizontal: ThisImage ;
            MenuItem "Vertical"      FlipVertical: ThisImage ;
         EndSubMenu
         SubMenu "Rotate"
            MenuItem "90 degrees" 90.0e RotateImage: ThisImage ;
            MenuItem "180 degrees" 180.0e RotateImage: ThisImage ;
            MenuItem "270 degrees" 270.0e RotateImage: ThisImage ;
        EndSubMenu
         SubMenu  "Convert image to"
            :MenuItem mnu8  "8 bits"              ConvertTo8Bits: ThisImage ;
            :MenuItem mnu16 "16 bits"            ConvertTo16Bits: ThisImage ;
            :MenuItem mnu24 "24 bits"            ConvertTo24Bits: ThisImage ;
            :MenuItem mnu32 "32 bits"            ConvertTo32Bits: ThisImage ;
         EndSubmenu
         MenuSeparator
         SubMenu "View Mode"
            :MenuItem mnunorm  "Normal"       NORMAL_FIT       SetViewMode: ThisImage ;
            :MenuItem mnuscale "Best Fit"     BEST_FIT         SetViewMode: ThisImage ;
            :MenuItem mnufit   "Fit to size"  FIT_SIZE         SetViewMode: ThisImage ;
         EndSubMenu
         MenuSeparator
         SubMenu "BackGround"
            :MenuItem mnublack "BLACK" BLACK SetBackGroundColor: ThisImage ;
            :MenuItem mnuwhite "WHITE" WHITE SetBackGroundColor: ThisImage ;
         EndSubMenu
Endbar

EXTERNAL

FileOpenDialog GetImageFile "Select Image File" "Image Files|*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.ico;*.pcd;*.psd;*.pcx;*.ppm;*.pgm;*.pbm;*.png;*.ras;*.tga;*.tif;*.gif|All Files (*.*)|*.*|"
FileSaveDialog SaveAsBitmapDlg "Save Image File:" "Bitmap|*.bmp;*.dib|Jpeg|*.jpg;*.jpeg|Png|*.png|All Image Files|*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.ico;*.pcd;*.psd;*.pcx;*.ppm;*.pgm;*.pbm;*.png;*.ras;*.tga;*.tif;*.gif|All Files (*.*)|*.*|"


:Class FreeImageWindow          <Super Child-Window

WinDC ImageDC
int FIBITMAP      \ pointer to FreeImage bitmap structure
int BackGroundColor
int ViewMode
int dopopup?
max-path bytes ImageFileName
256 value image-id
int &bitmap
int >&bitmap
int DrawDibDC

4 CallBack: FIReadProc  { &buffer size cnt fihandle -- cnt }
                fihandle &bitmap <> abort" Attempted read from wrong bitmap!"
                cnt 0
                do      >&bitmap &buffer size move
                        size +to >&bitmap
                        size +to &buffer
                loop    cnt ;

4 CallBack: FIWriteProc { &buffer size cnt fihandle -- size }
                size ;

3 CallBack: FISeekProc { fihandle offset origin -- 0 }
                fihandle &bitmap <> abort" Attempted seek from wrong bitmap!"
                origin
                case
                        SEEK_SET of fihandle offset + to >&bitmap endof
                        SEEK_END of abort" Invalid seek"          endof
                        offset +to >&bitmap
                endcase 0 ;

1 CallBack: FITellProc { fihandle -- res }
                fihandle &bitmap <> abort" Attempted query from wrong bitmap!"
                fihandle >&bitmap > abort" Invalid handle!"
                >&bitmap fihandle - ;

create IOProcs
&FIReadProc ,
&FIWriteProc ,
&FISeekProc ,
&FITellProc ,

:M LoadFromHandle:  { FIF_FORMAT addr -- FIBITMP }
                addr to &bitmap addr to >&bitmap
                0
                &bitmap
                IOProcs
                FIF_FORMAT
                FILoadFromHandle ;M

: gen-id        ( -- id )
                image-id
                1 +to image-id ;

: ValidImage?  ( -- f )
                FIBITMAP 0<> hwnd 0<> and ;

:M ImageWidth:  ( -- w )
                FIBITMAP FIGetWidth
                ;M

:M ImageHeight: ( -- h )
                FIBITMAP FIGetHeight
                ;M

:M SaveImage:   { imgtype imgparam -- } \ At the same size
                ValidImage? not ?exitm
                hwnd Start: SaveAsBitmapDlg dup c@ 0=
                if   drop exitm
                then count new$ dup>r place
                r@  count ".ext-only" nip 0=
                if      imgtype
                        case
                            FIF_BMP     of  s" .bmp"    endof
                            FIF_JPEG    of  s" .jpg"    endof
                            FIF_PNG     of  s" .png"    endof
                       \     FIF_BMP to imgtype s" .bmp" rot
                            s" .img" rot   \ default extension
                        endcase r@ +place
                then   imgparam r> 1+ FIBITMAP imgtype FISave drop
                ;M

: CalcImageSize  { \ cxDib cyDib - wDib hDib }

        ImageWidth: self to cxDib
        ImageHeight: self to cyDib

        \ calc scale factor
        Width  s>f cxDib s>f f/                 \ dxScale
        Height s>f cyDib s>f f/                 \ dyScale
        fmin                                    \ dScale

        \ remove this line, if the Image should be scaled to max window size
 \      fdup f1.0 f> if fdrop f1.0 then         \ dScale

        \ calc bitmap size
        cyDib s>f fover f* f0.5 f+              \ dScale dHeight
        cxDib s>f frot f* f0.5 f+               \ dHeight dWidth
        f>s f>s  ;                              \ wWidth hHeight


: ErasePartOfWindow  ( left top right bottom )
                     BackGroundColor FillArea: ImageDC ;

: wipe-window   ( -- )
                winRect GetClientRect: self
                0 0 Right: winRect Bottom: winRect ErasePartOfWindow ;

: ShowScaledImage ( --)    \ load and draw Image; keep aspect ratio
               DDF_SAME_HDC
               ImageHeight: self                  \ nSrcHeight
               ImageWidth: self                   \ nSrcWidth
               0                                  \ y-coord of source upper-left corner
               0                                  \ x-coord of source upper-left corner
               FIBITMAP FIGetBits                 \ *lpBits
               FIBITMAP FIGetInfo                 \ *lpBitsInfo
               CalcImageSize swap                 \ nDestHeight nDestWidth

               \ center bitmap in window
               2dup Height rot - 2/  dup 0>                             \ YDest
               if   0   0   Width 3 pick   ErasePartOfWindow            \ top
                    0 Height 2 pick - 1- Width Height ErasePartOfWindow \ bottom
               then Width rot - 2/  dup 0>                              \ XDest
               if   0   0     2 pick Height  ErasePartOfWindow          \ left
                    Width over - 1- 0  Width Height  ErasePartOfWindow  \ right
               then
               ImageDC.hdc
               DrawDIBDC Call DrawDibDraw drop ;

: ShowImageInFixedWindow  ( -- ) \ load and draw Image; fit to window
        DDF_SAME_HDC
        ImageHeight: self                               \ cScanlines
        ImageWidth: self                                \ dwWidth
        0                                               \ Ysrc
        0                                               \ Xsrc
        FIBITMAP  FIGetBits                             \ *lpvBits
        FIBITMAP  FIGetInfo                             \ *lpBmi
        Height
        Width
        0     ( y-coord of dest upper-left corner )     \ ydest
        0     ( x-coord of dest upper-left corner )     \ xdest
        ImageDC.hdc
        DrawDIBDC
        Call DrawDibDraw drop ;

: ShowImage  ( -- ) \ load and draw Image; keep Image size
        wipe-window
        DDF_SAME_HDC
        ImageHeight: self                               \ cScanlines
        ImageWidth: self                                \ dwWidth
        0                                               \ Ysrc
        0                                               \ Xsrc
        FIBITMAP  FIGetBits                             \ *lpvBits
        FIBITMAP  FIGetInfo                             \ *lpBmi
        -1                                              \ use
        -1                                              \ image size
        0     ( y-coord of dest upper-left corner )     \ ydest
        0     ( x-coord of dest upper-left corner )     \ xdest
        ImageDC.hdc                                     \ hdc
        DrawDIBDC
        Call DrawDibDraw drop ;

: check-bits    ( -- )
                BitsPerPixel: [ self ]
                case
                    8       of  true      Check: mnu8
                                false    Enable: mnu8
                                false     Check: mnu16
                                false     Check: mnu24
                                false     Check: mnu32
                                true     Enable: mnu16
                                true     Enable: mnu24
                                true     Enable: mnu32
                            endof
                    16       of true     Check: mnu16
                                false    Enable: mnu16
                                false     Check: mnu8
                                false     Check: mnu24
                                false     Check: mnu32
                                true     Enable: mnu8
                                true     Enable: mnu24
                                true     Enable: mnu32
                            endof
                    24       of true      Check: mnu24
                                false    Enable: mnu24
                                false     Check: mnu8
                                false     Check: mnu16
                                false     Check: mnu32
                                true     Enable: mnu8
                                true     Enable: mnu16
                                true     Enable: mnu32
                            endof
                    32       of true     Check: mnu32
                                false    Enable: mnu32
                                false     Check: mnu8
                                false     Check: mnu16
                                false     Check: mnu24
                                true     Enable: mnu8
                                true     Enable: mnu16
                                true     Enable: mnu24
                            endof
                ( default )     false     Check: mnu8
                                false     Check: mnu16
                                false     Check: mnu24
                                false     Check: mnu32
                                true     Enable: mnu8
                                true     Enable: mnu16
                                true     Enable: mnu24
                                true     Enable: mnu32
                endcase ;

: check-mode    (  -- )
                ViewMode
                case
                    NORMAL_FIT  of  true  Check: mnunorm
                                    false Check: mnuscale
                                    false Check: mnufit
                                endof
                    BEST_FIT    of  false Check: mnunorm
                                    true  Check: mnuscale
                                    false Check: mnufit
                                endof
                    FIT_SIZE    of  false Check: mnunorm
                                    false Check: mnuscale
                                    true  Check: mnufit
                                endof
                    ( default )     false Check: mnunorm
                                    false Check: mnuscale
                                    false Check: mnufit
                endcase
                BackGroundColor WHITE = dup not Check: mnuBlack Check: mnuWhite
                check-bits
                ;

: DisplayImage  ( -- )
                ValidImage? not
                if      wipe-window exit
                then    ViewMode
                case    NORMAL_FIT      of      ShowImage              endof
                        BEST_FIT        of      ShowScaledImage        endof
                        FIT_SIZE        of      ShowImageInFixedWindow endof
                endcase check-mode ;

:M SetViewMode: ( f -- )
                to ViewMode
                hwnd
                if      DisplayImage
                then    ;M

:M SetBackGroundColor:  ( color_object -- )
                to BackGroundColor
                hwnd
                if      DisplayImage
                then    ;M

:M UnLoadImage: ( -- )
                ValidImage?
                if      FIBITMAP FIUnload drop
                        0 to FIBITMAP
                then    ;M

: LoadImage    ( -- )
        UnLoadImage: self
        ImageFileName c@ 0<>
        if      \ get filetype
                0 ImageFileName 1+ dup>r FIGetFileType
                dup FIF_UNKNOWN =
                if      \ on some filetype's _FreeImage_GetFileType fails, so
                        \ try to get the filetype from the filename
                        drop r@ FIGetInfoFromFilename
                then    dup FIF_UNKNOWN <>
                if      \ open file
                        0 r@ rot FILoad to FIBITMAP
                else    drop
                then    r>drop
        then    ;

:M SetImageFile: ( addr cnt -- )   \ filename for image
                ImageFileName dup>r place
                r> +null
                LoadImage
                DisplayImage
                ;M

:M Wipe:        ( -- )  \ clear any image from window
                UnLoadImage: self
                DisplayImage
                ;M

:M ImageFileName: ( -- addr cnt )       \ return name of image file
                  FIBITMAP
                  if    ImageFileName count
                  else  pad 0
                  then  ;M

:M OpenImageFile: ( -- )
                hwnd ?dup
                if      Start: GetImageFile dup c@
                        if      count SetImageFile: self
                        else    drop
                        then
                then    ;M

:M SetImageFromMemory:  ( flag blue green red depth pitch height width lpvbits -- )
                FIConvertFromRawBits
                dup FIF_UNKNOWN <>
                if      UnLoadImage: self
                        to FIBITMAP
                        DisplayImage
                else    drop
                then    ;M

:M LoadMemoryBitmap:    ( &bitmap -- )
                FIF_BMP swap LoadFromHandle: self
                dup FIF_UNKNOWN <>
                if      UnLoadImage: self
                        to FIBITMAP
                        DisplayImage
                else    drop
                then    ;M

:M ReLoad:      ( -- )  \ redraw using earlier set image
                LoadImage
                DisplayImage
                ;M

:M Refresh:      ( -- )
                 DisplayImage
                 ;M

: open-image    ( -- )
                OpenImageFile: self ;

:M ClassInit:   ( -- )
                ClassInit: Super
                0 to FIBITMAP
                WHITE to BackGroundColor
                NORMAL_FIT to ViewMode
                ImageFileName max-path erase
                true to dopopup?
                gen-id to id
                ['] open-image SetDblClickFunc: self   \ double click opens file
                0 to DrawDibDC
                ;M

:M On_Paint:    ( -- )
                Refresh: self
                ;M

:M On_Init:     ( -- )
                On_Init: super
                ImagePopupBar SetPopupBar: self
                GetDc: self dup Puthandle: ImageDC
                HALFTONE swap Call SetStretchBltMode drop  \ better image quality
                Call DrawDibOpen to DrawDIBDC
                ;M

:M On_Done:     ( -- )
                GetHandle: ImageDC ReleaseDC: self
                DrawDIBDC Call DrawDibClose drop
                UnLoadImage: self
                On_Done: super
                ;M

:M WM_RBUTTONDOWN ( h m w l -- )
                dopopup?
                if      self to ThisImage check-mode    \ for popup menu
                        WM_RBUTTONDOWN WM: Super
                else    DefWindowProc: self
                then    ;M

:M WM_LBUTTONDBLCLK  ( h w m l -- )
                dopopup?
                if      WM_LBUTTONDBLCLK WM: Super
                else    DefWindowProc: self
                then    ;M

:M EnablePopup: ( -- )
                true to dopopup?
                ;M

:M DisablePopup: ( -- )
                false to dopopup?
                ;M
: ?version3+    ( -- f )
                FIGetVersion c@ '0' - 3 >= dup 0=
                s" Version 3.xx of FreeImage library required for this function"
                ?MessageBox ;

:M FlipVertical: ( -- )
                ValidImage? not ?exitm
                ?version3+ not ?exitm
                FIBITMAP FIFlipVertical drop
                Refresh: self ;M

:M FlipHorizontal: ( -- )
                ValidImage? not ?exitm
                ?version3+ not ?exitm
                FIBITMAP FIFlipHorizontal drop
                Refresh: self ;M

:M SaveAsJpeg: ( -- )
               FIF_JPEG JPEG_QUALITYGOOD SaveImage: self ;M

:M SaveAsBmp: ( -- )
              FIF_BMP BMP_DEFAULT SaveImage: self ;M

:M SaveAsPng: ( -- )
              FIF_PNG PNG_DEFAULT SaveImage: self ;M

:M BitsPerPixel: ( -- n )
            ValidImage?
            if     FIBITMAP FIBitsPerPixel
            else    0
            then    ;M

:M ConvertTo8Bits: ( -- )
             ValidImage? not ?exitm
             BitsPerPixel: self 8 = ?exitm
             FIBITMAP FIConvertTo8Bits
             UnLoadImage: self to FIBITMAP
             Refresh: self ;M

:M ConvertTo16Bits: ( -- )
            ValidImage? not ?exitm
            BitsPerPixel: self 16 = ?exitm
            FIBITMAP FIConvertTo16Bits
            UnLoadImage: self to FIBITMAP
            Refresh: self ;M

:M ConvertTo24Bits: ( -- )
            ValidImage? not ?exitm
            BitsPerPixel: self 24 = ?exitm
            FIBITMAP FIConvertTo24Bits
            UnLoadImage: self to FIBITMAP
            Refresh: self ;M

:M ConvertTo32Bits: ( -- )
            ValidImage? not ?exitm
            BitsPerPixel: self 32 = ?exitm
            FIBITMAP FIConvertTo32Bits
            UnLoadImage: self to FIBITMAP
            Refresh: self ;M

\ the following routines require floating point parameters
:M RotateImage: ( fs: degrees -- ) \ float
                fdepth 0= abort" Floating point parameter missing!"
                fs>ds   \ move float to data stack
                ValidImage? not ?version3+ not or
                if      2drop exitm
                then    FIBITMAP FiRotate
                UnLoadImage: self to FIBITMAP
                Refresh: self ;M

:M AdjustBrightness: ( fs: percentage -- ) \ float
                fdepth 0= abort" Floating point parameter missing!"
                fs>ds       \ move float to data stack
                ValidImage? not ?version3+ not or
                if      2drop exitm
                then    FIBITMAP FIAdjustBrightness drop
                Refresh: self ;M

:M AdjustContrast: ( fs: percentage -- ) \ float
                fdepth 0= abort" Floating point parameter missing!"
                fs>ds   \ move float to data stack
                ValidImage? not ?version3+ not or
                if      2drop exitm
                then    FIBITMAP FIAdjustContrast drop
                Refresh: self ;M

:M InvertImage: ( -- )
                ValidImage? not ?exitm
                ?version3+ not ?exitm
                FIBITMAP FIInvert drop
                Refresh: self ;M

:M ImageHandle: ( -- fibitmap )
                FIBITMAP ;M

:M SetImageHandle: ( fibitmap -- )
                UnLoadImage: self
                to FIBITMAP ;M

:M Clone:       ( -- fibitmap )
                ValidImage?
                if      FIBITMAP FIClone
                else    0
                then    ;M

:M Zoom:        { w h -- }
                ValidImage? not ?exitm
                ?version3+ not ?exitm
                BitsPerPixel: self 32 <>
                if      ConvertTo32Bits: self
                then    FILTER_BILINEAR h w FIBITMAP FIReScale
                UnLoadImage: self
                to FIBITMAP Refresh: self ;M

\ Performs gamma correction on a 8-, 24- or 32-bit image. The gamma parameter
\ represents the gamma value to use (gamma > 0). A value of 1.0 leaves the image
\ alone, less than one darkens it, and greater than one lightens it.
:M AdjustGamma: ( fs: gamma -- ) \ float
                fdepth 0= abort" Floating point parameter missing!"
                fs>ds       \ move float to data stack
                ValidImage? not ?version3+ not or
                if      2drop exitm
                then    BitsPerPixel: self 8 <
                if      2drop exitm
                then    FIBITMAP FIAdjustGamma drop
                Refresh: self ;M
;Class
MODULE
\s
>SYSTEM : AS WINPROC-LAST @ PROC>CFA ALIAS ; SYSTEM>
\ Usage 1 proc ExitThread as EXIT-TASK
\ creates a Word that compiles or executes the Function call

All exported functions from FreeImage.dll version 3.xx+
_FreeImage_AdjustBrightness@12
_FreeImage_AdjustContrast@12
_FreeImage_AdjustCurve@12
_FreeImage_AdjustGamma@12
_FreeImage_Allocate@24
_FreeImage_AppendPage@8
_FreeImage_Clone@4
_FreeImage_CloseMultiBitmap@8
_FreeImage_ColorQuantize@8
_FreeImage_ConvertFromRawBits@36
_FreeImage_ConvertLine16To24_555@12
_FreeImage_ConvertLine16To24_565@12
_FreeImage_ConvertLine16To32_555@12
_FreeImage_ConvertLine16To32_565@12
_FreeImage_ConvertLine16To8_555@12
_FreeImage_ConvertLine16To8_565@12
_FreeImage_ConvertLine16_555_To16_565@12
_FreeImage_ConvertLine16_565_To16_555@12
_FreeImage_ConvertLine1To16_555@16
_FreeImage_ConvertLine1To16_565@16
_FreeImage_ConvertLine1To24@16
_FreeImage_ConvertLine1To32@16
_FreeImage_ConvertLine1To8@12
_FreeImage_ConvertLine24To16_555@12
_FreeImage_ConvertLine24To16_565@12
_FreeImage_ConvertLine24To32@12
_FreeImage_ConvertLine24To8@12
_FreeImage_ConvertLine32To16_555@12
_FreeImage_ConvertLine32To16_565@12
_FreeImage_ConvertLine32To24@12
_FreeImage_ConvertLine32To8@12
_FreeImage_ConvertLine4To16_555@16
_FreeImage_ConvertLine4To16_565@16
_FreeImage_ConvertLine4To24@16
_FreeImage_ConvertLine4To32@16
_FreeImage_ConvertLine4To8@12
_FreeImage_ConvertLine8To16_555@16
_FreeImage_ConvertLine8To16_565@16
_FreeImage_ConvertLine8To24@16
_FreeImage_ConvertLine8To32@16
_FreeImage_ConvertTo16Bits555@4
_FreeImage_ConvertTo16Bits565@4
_FreeImage_ConvertTo24Bits@4
_FreeImage_ConvertTo32Bits@4
_FreeImage_ConvertTo8Bits@4
_FreeImage_ConvertToRawBits@32
_FreeImage_Copy@20
_FreeImage_CreateICCProfile@12
_FreeImage_DeInitialise@0
_FreeImage_DeletePage@8
_FreeImage_DestroyICCProfile@4
_FreeImage_Dither@8
_FreeImage_FIFSupportsExportBPP@8
_FreeImage_FIFSupportsICCProfiles@4
_FreeImage_FIFSupportsReading@4
_FreeImage_FIFSupportsWriting@4
_FreeImage_FlipHorizontal@4
_FreeImage_FlipVertical@4
_FreeImage_GetBPP@4
_FreeImage_GetBits@4
_FreeImage_GetBlueMask@4
_FreeImage_GetChannel@8
_FreeImage_GetColorType@4
_FreeImage_GetColorsUsed@4
_FreeImage_GetCopyrightMessage@0
_FreeImage_GetDIBSize@4
_FreeImage_GetDotsPerMeterX@4
_FreeImage_GetDotsPerMeterY@4
_FreeImage_GetFIFCount@0
_FreeImage_GetFIFDescription@4
_FreeImage_GetFIFExtensionList@4
_FreeImage_GetFIFFromFilename@4
_FreeImage_GetFIFFromFormat@4
_FreeImage_GetFIFFromMime@4
_FreeImage_GetFIFRegExpr@4
_FreeImage_GetFileType@8
_FreeImage_GetFileTypeFromHandle@12
_FreeImage_GetFormatFromFIF@4
_FreeImage_GetGreenMask@4
_FreeImage_GetHeight@4
_FreeImage_GetHistogram@12
_FreeImage_GetICCProfile@4
_FreeImage_GetInfo@4
_FreeImage_GetInfoHeader@4
_FreeImage_GetLine@4
_FreeImage_GetLockedPageNumbers@12
_FreeImage_GetPageCount@4
_FreeImage_GetPalette@4
_FreeImage_GetPitch@4
_FreeImage_GetRedMask@4
_FreeImage_GetScanLine@8
_FreeImage_GetTransparencyCount@4
_FreeImage_GetTransparencyTable@4
_FreeImage_GetVersion@0
_FreeImage_GetWidth@4
_FreeImage_Initialise@4
_FreeImage_InsertPage@12
_FreeImage_Invert@4
_FreeImage_IsLittleEndian@0
_FreeImage_IsPluginEnabled@4
_FreeImage_IsTransparent@4
_FreeImage_Load@12
_FreeImage_LoadFromHandle@16
_FreeImage_LockPage@8
_FreeImage_MovePage@12
_FreeImage_OpenMultiBitmap@20
_FreeImage_OutputMessageProc
_FreeImage_Paste@20
_FreeImage_RegisterExternalPlugin@20
_FreeImage_RegisterLocalPlugin@20
_FreeImage_Rescale@16
_FreeImage_RotateClassic@12
_FreeImage_RotateEx@48
_FreeImage_Save@16
_FreeImage_SaveToHandle@20
_FreeImage_SetChannel@12
_FreeImage_SetOutputMessage@4
_FreeImage_SetPluginEnabled@8
_FreeImage_SetTransparencyTable@12
_FreeImage_SetTransparent@8
_FreeImage_Threshold@8
_FreeImage_Unload@4
_FreeImage_UnlockPage@12
_FreeImage_ZLibCompress@16
_FreeImage_ZLibUncompress@16

