\ $Id: bitmap.f,v 1.12 2014/04/16 17:57:06 georgeahubert Exp $

\ Routines to allow loading and displaying a bitmap in any window
\ including pushbuttons...June 9th, 1999 - 1:01 - E. Boyce

\ July 19th, 2003 - 16:19 - updated with support for FreeImage.dll
\
\  BitMap data structures
\  create BMPheader
\          here                            nostack1
\          0 w,    \ bftype        +0
\          0 ,     \ bfsize        +2
\          0 w,    \ reserved      +6
\          0 w,    \ reserved      +8
\          0 ,     \ bfOffBits     +10
\          here swap - constant sizeof(BMPheader)
\  create BMPinfoheader
\          here                            nostack1
\          0 ,     \ biSize            +0
\          0 ,     \ biWidth           +4
\          0 ,     \ biHeight          +8
\          0 w,    \ biPlanes          +12
\          0 w,    \ biBitCount        +14
\          0 ,     \ biCompression     +16
\          0 ,     \ biSizeImage       +20
\          0 ,     \ biXPelsPerMeter   +24
\          0 ,     \ biYPelsPerMeter   +28
\          0 ,     \ biClrUsed         +32
\          0 ,     \ biClrImportant    +36
\          here over - swap !
\  BMPinfoheader @ constant sizeof(BMPinfoheader)
\  create BMPrect
\          0 ,     \ left
\          0 ,     \ top
\          0 ,     \ right
\          0 ,     \ bottom
\  4 constant sizeof(RGBQUAD)
\  24 constant sizeof(BMPbitmap)
\              create BMPbitmap sizeof(BMPbitmap) allot


anew -bitmap.f

internal
external

0 value currentbitmap

: usebitmap     ( <bitmap addr> -- )    \ set bitmap to be used
                to currentbitmap ;

: ?bitmaperror  ( -- )  \ abort on bitmap not set
                currentbitmap 0= abort" No bitmap set" ;

: isbitmap?     ( -- f ) \ verify valid bitmap
                ?bitmaperror
                currentbitmap @ s" BM" drop @ = ?dup ?exit
                currentbitmap @ s" BA" drop @ = ?dup ?exit
                currentbitmap @ s" CI" drop @ = ?dup ?exit
                currentbitmap @ s" CP" drop @ = ?dup ?exit
                currentbitmap @ s" IC" drop @ = ?dup ?exit
                currentbitmap @ s" PT" drop @ =  ;

: dib.filesize  ( -- n ) \ total size of file
                ?bitmaperror
                currentbitmap 2 + @ ;

: dib.bits   ( -- addr )     \ address of bitmap bits
                ?bitmaperror
                currentbitmap 10 + @ currentbitmap + ;

14 constant sizeof(fileheader)

: dib.infoheader     ( -- addr ) \ address of bitmapinfoheader
                ?bitmaperror
                currentbitmap sizeof(fileheader) + ;

: dib.infoheadersize ( -- n )      \ size of infoheader
                dib.infoheader @ ;

: dib.RGBQUAD ( -- addr )  \ return address of RGBQUAD array
                dib.infoheader dib.infoheadersize + ;

: dib.width  ( -- n )      \ width of bitmap in pixels
                dib.infoheader cell+ @ ;

: dib.height ( -- n )   \ height of bitmap in pixels
                dib.infoheader 2 cells+  @ ;

: dib.planes         ( -- n )
                dib.infoheader 3 cells+ w@ ;

: dib.bits/pixel ( -- n )  \ bits per pixel
                dib.infoheader 14 + w@ ;

: dib.compression    ( -- n )     \ type of compression
                dib.infoheader 4 cells+ @ ;

: dib.imagesize  ( -- n )  \ size of image in bytes
                dib.infoheader 5 cells+ @ ;

: dib.xpixels        ( -- n )    \ xpixels per metre
                dib.infoheader 6 cells+ @ ;

: dib.ypixels        ( -- n ) \ y pixels per metre
                dib.infoheader 7 cells+ @ ;

: dib.colors    ( -- n )        \ colors in bitmap
                dib.infoheader 8 cells+ @ ;

: dib.clrimp    ( -- n )    \ important colors
                dib.infoheader 9 cells+ @ ;

: dib.bytes/line ( -- n )   \ number of bytes required for one scan line
                dib.width dib.bits/pixel *      \ number of bits in a line
                8 /mod swap
                if      1+
                then    ;

: dib.pitch     ( -- n ) \ width of bitmap in bytes, rounded to 32-bit boundary
                dib.bytes/line dup cell mod ?dup
                if      cell swap - +
                then    ;

: "load-bitmap   ( fname cnt -- ) \ load bitmap file to here, search fpath
                { \ bmpaddr fileid filelength -- }
                "path-file  abort" File not found!"  \ search for file
                r/o open-file abort" Couldn't open the bitmap file"
                to fileid
                here cell+ to bmpaddr fileid file-size 2drop to filelength
                filelength dup , allot                 \ allocate the space
                bmpaddr filelength fileid read-file nip  \ read bitmap
                abort" File read error"
                fileid close-file drop align ;  \ close file

: load-bitmap   ( <name> "file" -- )
                create /parse-word count "load-bitmap
                does> cell+ ;

: "mem-loadbitmap   { fname cnt \ fileid filelength bmpaddr -- addr }
\ load bitmap filename fname,cnt to memory, return address
                 fname cnt "path-file abort" File not found!"
                 r/o open-file abort" Couldn't open the bitmap file!"
                 to fileid
                 fileid file-size 2drop to filelength
                 filelength cell+ ['] malloc catch
                 if     fileid close-file drop true abort" Memory error!"
                 then   to bmpaddr
                 filelength bmpaddr !
                 bmpaddr lcount fileid read-file nip
                 fileid close-file drop
                 if     bmpaddr release
                        true abort" Read error!"
                 then   bmpaddr ;   \ lcount address of bitmap, remember to release memory!

: CreateDIBitmap        { hdc \ -- hbitmap }
                \ return a bitmap handle for image in memory compatible with hdc
                DIB_RGB_COLORS
                dib.infoheader
                dib.bits
                CBM_INIT
                dib.infoheader
                hdc Call CreateDIBitmap ;


\ BLUE  = MSB in RGB value, LSB in RGBQUAd cell
\ GREEN = NMSB in RGB value, NMSB in RGBQUAD cell
\ RED   = LSB in RGB value, MSB in RGBQUAD cell

: >rgb  { colorref -- r g b }
        colorref 0xFF and               \ red
        colorref 8 RShift 0xFF and      \ green
        colorref 16 RShift 0xFF and ;   \ blue

: rgb>rgbquad   { rgbquad r g b -- }   \ save rgb color refernce to RGBQUAD cell
                b rgbquad c!
                g rgbquad 1+ c!
                r rgbquad 2 + c! ;

: map-3Dcolors  { \ #colors -- }
\ simulates WIN32 APi (LR_LOADMAP3DCOLORS) in mapping values in color table
              dib.colors dup to #colors 256 > ?exit    \ 256 or less colors
              #colors 0=
              if        dib.bits/pixel 4 LShift dup to #colors 256 > ?exit
              then      dib.rgbquad #colors 0x808080 ( DKGRAY ) lscan
              if        COLOR_3DSHADOW Call GetSysColor >rgb rgb>rgbquad
              else      drop
              then      dib.rgbquad #colors 0xC0C0C0 ( GRAY ) lscan
              if        COLOR_3DFACE Call GetSysColor >rgb rgb>rgbquad
              else      drop
              then      dib.rgbquad #colors 0xDFDFDF ( LTGRAY ) lscan
              if        COLOR_3DLIGHT Call GetSysColor >rgb rgb>rgbquad
              else      drop
              then      ;

0 value map-color   \ opportunity to set own color

: map-transparent   ( -- )
\ simulates WIN32 API ( LR_LOADTRANSPARENT ), changes background color of bitmap
            dib.colors 256 > ?exit
            dib.colors 0=
            if      dib.bits/pixel 4 LShift 256 > ?exit
            then    dib.bits c@ \ get the ( first or last ?) pixel
            dib.bits/pixel 4 =
            if      0x0F and
            then    dib.rgbquad +cells  \ address in array of color value
            map-color dup 0=
            if      drop COLOR_BTNFACE Call GetSysColor
            then    >rgb rgb>rgbquad ;

\ Bitmap class will encapsulate methods for displaying
\ a bitmap in any window

:Class BitmapObject     <super Child-Window

int &bitmap
int BackGroundColor
int xpos
int ypos
WinDC bitmap-dc

int sprite-bitmap

int SpriteWidth
int SpriteHeight
int OffsetY

int  ParentDC

:M SetXY:       ( x y -- )
                to ypos to xpos ;M

:M ClassInit:   ( -- )
                ClassInit: super
                0 to &bitmap
                WHITE to BackGroundColor
                0 0 SetXY: self
		0 to OffsetY
		16 to SpriteWidth
		15 to SpriteHeight
		0 to parentdc
                ;M

:M SetBitmap:   ( <addr of bitmap> -- )
                to &bitmap
                ;M

:M ShowBitmap:  { x y hdc -- } \ display bitmap at &bitmap in DC at handle hdc
                            \ full size of bitmap will allways be shown
                &bitmap 0= abort" Bitmap not yet set!"
                &bitmap to currentbitmap
                DIB_RGB_COLORS
                dib.infoheader
                dib.bits
                dib.height 0         \ all scan lines
                0 0 dib.height dib.width
                y x         \ upper left corner of dest
                hdc        \ hdc
                HALFTONE over Call SetStretchBltMode drop  \ better image quality
                call SetDIBitsToDevice drop
                ;M

:M ShowFittedBitmap:  { width height hdc -- } \ load and draw Image; fit to window of size w h
                &bitmap 0= abort" Bitmap not yet set!"   \ continue only if object has a bitmap
                &bitmap to currentbitmap
                SRCCOPY
                DIB_RGB_COLORS
                dib.infoheader
                dib.bits
                dib.height dib.width
                0 0         \ ysrc xsrc
                height width
                ypos xpos         \ upper left corner of dest
                hdc        \ hdc
                HALFTONE over Call SetStretchBltMode drop  \ better image quality
                call StretchDIBits drop
                ;M

: CalcImageSize  { width height -- wDib hDib } \ adapted from imagewindow.f

        \ calc scale factor
        Width  s>f dib.width s>f f/                 \ dxScale
        Height s>f dib.height s>f f/                 \ dyScale
        fmin                                    \ dScale

        \ remove this line, if the Image should be scaled to max window size
 \      fdup f1.0 f> if fdrop f1.0 then         \ dScale

        \ calc bitmap size
        dib.height s>f fover f* f0.5 f+              \ dScale dHeight
        dib.width s>f frot f* f0.5 f+               \ dHeight dWidth
        f>s f>s  ;                              \ wWidth hHeight


:M ShowScaledBitmap: { width height hdc -- }    \ load and draw Image; keep aspect ratio
               &bitmap 0= abort" Bitmap not yet set!"
               &bitmap to currentbitmap
               SRCCOPY                            \ raster operation code
               DIB_RGB_COLORS                     \ usage options
               dib.infoheader                     \ *lpBitsInfo
               dib.bits                           \ *lpBits
               dib.height                         \ nSrcHeight
               dib.width                          \ nSrcWidth
               0                                  \ y-coord of source upper-left corner
               0                                  \ x-coord of source upper-left corner
               width height CalcImageSize swap    \ nDestHeight nDestWidth

               \ erase window first, white background
               0 0 Width Height Setrect: winRect
               Brush: BackGroundColor winRect hdc Call FillRect drop

               \ center bitmap in window
               width 2/ over 2/ - >r
               over height 2/ swap 2/ - r>            \ ydest xdest
               hdc
               HALFTONE over Call SetStretchBltMode drop  \ better image quality
               call StretchDIBits drop ;M

:M SetBackGroundColor:  ( color_object -- )
               to BackGroundColor ;M

\ The following adapted from Mike Kemper's bitmap routines

:M Start: 	{ \ hdcMem hbm --  }
                &bitmap 0= abort" Bitmap not yet set!"   \ continue only if object has a bitmap
                &bitmap to currentbitmap
		GetDC: self  PutHandle: dc
		0 call CreateCompatibleDC PutHandle: bitmap-dc

         dib.width dib.height CreateCompatibleBitmap: dc to sprite-bitmap
         sprite-bitmap SelectObject: bitmap-dc
         GetHandle: dc  ReleaseDC: self

         GetHandle: bitmap-dc                   \ device context
         CreateDIBitmap to hbm

         GetHandle: bitmap-dc  call CreateCompatibleDC to hdcMem
         hbm hdcMem call SelectObject drop


         SRCCOPY 0 0
         hdcMem
         dib.height                            \ image height
         dib.width                             \ image width
         0 0 GetHandle: bitmap-dc
         call BitBlt ?WinError
         hdcMem call DeleteDC ?WinError
         hbm call DeleteObject ?WinError
      ;M

:M SetParentDC: ( dc --  )
      to ParentDC ;M

:M GetParentDC: (  -- dc )
      ParentDC ;M

:M GetWinDC: (  -- dc )
      GetHandle: bitmap-dc ;M

:M SetSpriteSize: ( width height --  )
      to SpriteHeight  to SpriteWidth ;M

:M GetSpriteSize: (  -- width height )
      SpriteWidth SpriteHeight ;M

:M SetOffsetY: ( y --  )
      to OffsetY ;M

:M GetOffsetY: (  -- y )
      OffsetY ;M

\ -------------------------------------------------------------------------
\ ----- Draw a sized image at x, y within the parent's DC
\ -------------------------------------------------------------------------
:M PutImage: { sprite# x y --  }
      SRCCOPY                                \ direct copy
      OffsetY sprite# SpriteWidth *          \ source y x
      GetHandle: bitmap-dc                   \ source DC
      SpriteHeight SpriteWidth y x           \ height width y x
      ParentDC                               \ dest DC
      call BitBlt drop ;M                    \ draw it

   \ -------------------------------------------------------------------------
   \ ----- Copy a sized image from a parent's DC at x, y to our bitmap image
   \ -------------------------------------------------------------------------
   :M GetImage: { sprite# x y --  }
      SRCCOPY                                \ direct copy
      y x                                    \ source y x
      ParentDC                               \ source DC
      SpriteHeight SpriteWidth               \ height width
      OffsetY sprite# SpriteWidth *          \ dest y x
      GetHandle: bitmap-dc                   \ dest DC
      call BitBlt drop ;M                    \ copy it

   \ -------------------------------------------------------------------------
   \ ----- Logically AND's a sized image with the parent's DC at x, y
   \ -------------------------------------------------------------------------
   :M AndBlit: { sprite# x y  --  }
      SRCAND
      OffsetY sprite# SpriteWidth *
      GetHandle: bitmap-dc
      SpriteHeight SpriteWidth
      y x
      ParentDC
      call BitBlt drop ;M

   \ -------------------------------------------------------------------------
   \ ----- Logically OR's a sized image with the parent's DC at x, y
   \ -------------------------------------------------------------------------
   :M OrBlit: { sprite# x y --  }
      SRCPAINT
      OffsetY sprite# SpriteWidth *
      GetHandle: bitmap-dc
      SpriteHeight SpriteWidth
      y x
      ParentDC
      call BitBlt drop ;M

   \ -------------------------------------------------------------------------
   \ ----- Draw a sized, masked image at x, y within the parent's DC
   \ -------------------------------------------------------------------------
   :M PutImageMasked: { sprite# x y --  }
      sprite# y x AndBlit: self
      sprite# y x OrBlit: self ;M

   \ -------------------------------------------------------------------------
   \ ----- Draws the entire bitmap on the parent's DC at x, y
   \ -------------------------------------------------------------------------
   :M PutBMP: { x y --  }
      &bitmap to currentbitmap	\ in case it was changed
      SRCCOPY
      0 0
      GetHandle: bitmap-dc
      dib.height dib.Width
      y x
      ParentDC
      call BitBlt drop ;M

   :M Close: (  --  )
      GetHandle: bitmap-dc ?dup
      if Call DeleteDC ?WinError
         0 PutHandle: bitmap-dc
      then
      sprite-bitmap ?dup
      if  Call DeleteObject drop
         0 to sprite-bitmap
      then	0 to &bitmap
      Close: super ;M

;Class

0 value loadflags

: LoadBitmap    ( z" string" -- hbitmap )
                >r
                LR_LOADFROMFILE LR_CREATEDIBSECTION or loadflags or
                NULL NULL
                IMAGE_BITMAP
                r>
                NULL
                Call LoadImage
                null to loadflags ;

: LoadIcon      ( z"string" -- hbitmap )
                >r
                LR_LOADFROMFILE LR_DEFAULTSIZE or loadflags or
                NULL NULL
                IMAGE_ICON
                r>
                NULL
                Call LoadImage
                null to loadflags ;

\ Slightly different type of bitmap button, uses memory bitmap info
:Class ImageButton        <Super ButtonControl

int bitmap#1
int bitmap#2
int iflag
int ifont
int imagedc
int textcolor
max-path bytes buttontext
BitmapObject TheImage
10 Constant IMAGE_TIMER

:M ClassInit:   ( -- )
                ClassInit: Super
                0 to bitmap#1
                0 to bitmap#2
                0 to iflag
                0 to ifont
                Color: BLACK to textcolor   \ background will always be COLOR_BTNFACE..for now
                2 2 SetXY: TheImage
                buttontext off
                ;M

: paintbutton   ( -- )
                GetDC: self to imageDC
                winRect GetClientRect: self
                buttontext c@         \ if we have text show image and text
                \ icons are usually 32x32
                \ text will be shown a little off center of the button
                \ at any rate button must be big enough for both text and image
                if         2 2 imagedc ShowBitmap: TheImage     \ image in upper corner
                           COLOR_BTNFACE Call GetSysColor imageDC Call SetBkColor drop
                           textcolor imageDC Call SetTextColor drop
                           ifont ?dup       \ set font if we have one
                           if       imageDC Call SelectObject drop
                           then     DT_VCENTER DT_SINGLELINE or ( format )
                           winRect.right 2/ cell-  ( x )    \ from center of button
                           0
                           winRect.right 2 - winRect.bottom 2 - ( x y right bottom )
                           SetRect: winRect
                           winRect
                           buttontext count swap
                           imagedc Call DrawText drop
                \ if no text show  full image in button
                else       winRect.right cell- winRect.bottom cell-
                           imagedc ShowFittedBitmap: TheImage
                then       imageDC ReleaseDC: self ;


:M WM_PAINT         ( h m w l -- res )
                    old-wndproc CallWindowProc
                    paintbutton
                    ;M

:M SetImage:        ( &bitmap -- )
                    to bitmap#1
                    bitmap#1 SetBitmap: TheImage     \ default
                    hwnd
                    if      Paint: self
                    then
                    ;M

:M SetImage#2:      ( &bitmap -- )
                    to  bitmap#2
                    ;M

:M WM_LBUTTONDOWN   ( h w m l -- res )
                    old-wndproc CallWindowProc
                    Paint: self
                    0 ;M

:M SetText:         ( addr cnt -- )
                    buttontext place
                    hwnd
                    if      Paint: self
                    then    ;M

:M SetFont:         ( fonthndl -- )
                    to ifont ;M

:M WM_LBUTTONUP     ( h w m l -- )
                    WM_LBUTTONUP WM: Super
                    \ make sure it is a valid window before try painting
                    \ in case button is used to close parent
                    hwnd  Call IsWindow
                    if    Paint: self
                    else  false to iflag     \ reset in button flag
                    then  ;M

:M WM_LBUTTONDBLCLK ( h m w l -- )
                    old-wndproc CallWindowProc
                    Paint: self
                    0 ;M

:M Enable:      ( f -- )
                ID EnableDlgItem: parent
                Paint: self
                ;M

:M Disable:     ( -- )
                false Enable: self
                ;M

:M WM_MOUSEMOVE     ( h m w l -- res )
                    WM_MOUSEMOVE WM: Super
                    hwnd get-mouse-xy hwnd in-button?
                    bitmap#2 0<> and        \ using dual images
                    if      iflag 0=
                            if      bitmap#2 SetBitmap: TheImage
                                    Paint: self
                                    true to iflag
                                    NULL 100 IMAGE_TIMER hwnd Call SetTimer drop
                            then
                    then    0 ;M

:M WM_TIMER         ( h m w l -- )
                    over IMAGE_TIMER =
                    if      hwnd get-mouse-xy hwnd in-button? not iflag and
                            if      bitmap#1 SetBitmap: TheImage
                                    Paint: self
                                    false to iflag
                                    IMAGE_TIMER hwnd Call KillTimer drop
                                    0
                            then
                    else    WM_TIMER WM: Super
                    then    0 ;M

;Class

MODULE
\s


