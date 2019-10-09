anew bmpdot.f  \ March 26th, 2013

\ From the project julia.
\ Writes a pixel to a bmp-file.
\ Changed it a bit for the use with OpenGL.

 needs Struct.f


map-handle ahndl

: _map-bitmap  ( name count map-hndl - vadr )
  dup>r open-map-file
   if cr ." open-map-file error."  true abort" Can't map bitmap."
   then
  r> >hfileAddress @  ;

: _un-map-bitmap ( map-hndl - )  close-map-file drop ;

: map-bitmap     ( name count - vadr ) ahndl _map-bitmap  ;
: un-map-bitmap  ( - )                 ahndl _un-map-bitmap ;


struct{  \ BitmapFileHeader
        WORD   bfType       \ 19778
        LONG   bfSize       \ 3118  2128014
        WORD   bfReserved1  \ 0
        WORD   bfReserved2  \ 0
        DWORD  bfOffsetBits \ 118  54
        OFFSET >BitmapInfoHeader
}struct BitmapFileHeader

struct{ \  BITMAPINFOHEADER
        DWORD      biSize
        LONG       biWidth
        LONG       biHeight
        WORD       biPlanes
        WORD       biBitCount
        DWORD      biCompression
        DWORD      biSizeImage
        LONG       biXPelsPerMeter
        LONG       biYPelsPerMeter
        DWORD      biClrUsed
        DWORD      biClrImportant
 }struct BITMAPINFOHEADER

struct{ \ RGBTRIPLE
        BYTE    rgbtBlue
        BYTE    rgbtGreen
        BYTE    rgbtRed
}struct RGBTRIPLE

sizeof RGBTRIPLE value #bytes/pixel

struct{ \ Win3DIBFile
    BITMAPFILEHEADER bmfh.BitmapFileHeader
    BITMAPINFOHEADER bmfh.BitmapInfoHeader
    OFFSET           >color-array
}struct Win3DIBFile  \ 54

struct{ \ RGBQUAD
        BYTE    rgbBlue
        BYTE    rgbGreen
        BYTE    rgbRed
        BYTE    rgbReserved
}struct RGBQUAD

\ sizeof RGBQUAD value #bytes/pixel

struct{ \ BITMAPINFO
    BitmapInfoHeader  pbmiBitmapInfoHeader
    offset pbmiColors
    sizeof RGBQUAD 256 * _add-struct
}struct bitmapinfo

: .cr ( n - ) . cr ;

sizeof bitmapinfo mkstruct: pbmi
: .BitmapFileHeader ( BitmapFileHeader -)
     dup>r
            bfType       w@ .cr \ 19778
         r@ bfSize       ?   cr \ 589878 h
         r@ bfReserved1  w@ .cr \ 0
         r@ bfReserved2  w@ .cr \ 0
         r> bfOffsetBits ?   cr \ 54
 ;

: >biWidth  ( BitmapFileHeader - adrWidth  )   >BitmapInfoHeader biWidth   ;
: >biHeight ( BitmapFileHeader - adrbiHeight)  >BitmapInfoHeader biHeight  ;

: bi-wh@ ( BitmapInfoHeader - w h )    dup biWidth @ swap biHeight @  ;

: bytes/pixel?  ( BitmapInfoHeader - #bytes/pixel )
     dup biSizeImage @ swap bi-wh@ * /  ;

: .BitmapInfoHeader  ( BitmapInfoHeader - )
     dup>r  cr
                biSize          ?   cr  \ 40
        r@      biWidth         ?   cr  \ 512       1028
        r@      biHeight        ?   cr  \ 384       690
        r@      biPlanes        w@ .cr  \ 1
        r@      biBitCount      w@ .cr  \ 24
        r@      biCompression   ?   cr  \ 0
        r@      biSizeImage     ?   cr  \ 589824 l
        r@      biXPelsPerMeter ?   cr  \ 4724
        r@      biYPelsPerMeter ?   cr  \ 4724
        r@      biClrUsed       ?   cr  \ 0
        r@      biClrImportant  ?   cr  \ 0
        r>      ." bytes/pixel: " bytes/pixel? .cr  \ #bytes/pixel
 ;

: gen-Win3DIBfile ( name count width height #bytes/pixel nrgbquad - width height total-file-size vadr  )
   >r to #bytes/pixel
   2swap 2over swap #bytes/pixel * * r> +
   -rot 2dup r/w create-file abort" Can't create DIBheader" >r
   rot sizeof Win3DIBFile +
   dup s>d r@ resize-file abort" Can't resize DIBheader"
   r> close-file abort" Can't close DIBheader"
   -rot map-bitmap 2dup swap erase
 ;

0 value end-adres-bitmap

: fill-24-bits-header  ( w h total-file-size vadr - )
    2dup + to end-adres-bitmap
    2dup dup>r  bfSize !
    54 dup rot  bfOffsetBits !
    - r@ >BitmapInfoHeader biSizeImage !
    19778  r@   bfType w!
    r> >BitmapInfoHeader
      40   over biSize !
      1    over biPlanes w!
      24   over biBitCount w!
      4724 over biXPelsPerMeter !
      4724 over biYPelsPerMeter !
      swap over biHeight !
      biWidth !
 ;

\  0 value x1 0 value y1
\ debug >bmp x1 y1 1 dot>bmp

: >bmp  ( x y >BitmapInfoHeader - adr>bmp )
\  2 pick to x1 over to y1
  dup>r biWidth @ * swap - r> biWidth @ + #bytes/pixel *
  end-adres-bitmap swap -
 ;

: dot>bmp  ( x y rgb - )  \ bitmap must be mapped  x and y must point in a vallid area
   >r ahndl >hfileAddress @  >BitmapInfoHeader >bmp
   r@ 0x10 rshift over c!    1+ r@ 8 rshift over c!  1+ r> swap c!
 ;

 ((
: .test
      s" font16.bmp" map-bitmap
      ahndl >hfileAddress @
     \ cr dup 500 dump
      cr dup .BitmapFileHeader
      cr >BitmapInfoHeader .bitmapinfoheader
  ;
\ debug .test
.test
abort ))

defined set-dot nip [IF]   \ not defined when graphics.f is not loaded

: dot>bmp? ( - flag )
  ['] dot>bmp ['] set-dot >body @ = ;


[THEN]

\s
\ Use:
: .test
      s" test.bmp" map-bitmap
      ahndl >hfileAddress @
      cr dup 500 dump
      cr dup .BitmapFileHeader
      cr >BitmapInfoHeader .bitmapinfoheader
  ;

\s

\ .test abort

: test
  s" test.bmp" 400 200 0 #bytes/pixel gen-Win3DIBfile
  dup>r  fill-24-bits-header
  r@ >color-array r> >BitmapInfoHeader biSizeImage @ 0 fill  \ make it black
                   \  0 b g r
  200 0 do 399 i   th 000000ff  dot>bmp  loop    \ x=399      y=0->199  \ right
  400 0 do i   0   th 000000ff  dot>bmp  loop    \ x=1->399   y=0       \ top
  400 0 do i   199 th 000000ff  dot>bmp  loop    \ x=0->399   y=199     \ bottom
  200 0 do 0   i   th 000000ff  dot>bmp  loop    \ x=0      y=0->199    \ left
 s" test.bmp"  .test
   ahndl close-map-file drop
  ;

: test2
  s" test.bmp" 400 200 #bytes/pixel 0 gen-Win3DIBfile
  dup>r  fill-24-bits-header
  r@ >color-array r> >BitmapInfoHeader biSizeImage @ th ff fill  \ make it white
                  \  0 b g r

  150 50 do  50 i  0  dot>bmp  loop
  350 50 do  i 50  0  dot>bmp  loop

  160 40 do  40 i  0  dot>bmp  loop
  360 40 do  i 40  0  dot>bmp  loop

  170 30 do  30 i  0  dot>bmp  loop
  370 30 do  i 30  0  dot>bmp  loop

  180 20 do  20 i  0  dot>bmp  loop
  380 20 do  i 20  0  dot>bmp  loop

  190 10 do  10 i  0  dot>bmp  loop
  390 10 do  i 10  0  dot>bmp  loop

  200 0 do   0  i  0  dot>bmp  loop
  400 0 do   i  0  0  dot>bmp  loop

\ s" test.bmp"  .test
   ahndl close-map-file drop
  ;

   test2
   cd
   dir test.bmp
   .( View it in paint)
\s
