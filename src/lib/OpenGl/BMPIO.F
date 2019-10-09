\ April 27th, 2002 - 14:22

anew  bmpio.f
needs bmpdot.f

forth

\ In normal cases I would like to pass parameters over the stack.
\ That does not work if a program aborts or when it is started by an event and
\ needs parameters from an other event


\ create save$  MAXSTRING allot
string: save$
sizeof BitmapFileHeader mkstruct: bmfh

\ 0 value nrgbquad

: fill-pbmi  ( nbits - nrgbquad )
        >r
        pbmi sizeof bitmapinfo    erase         \ (1) DON'T DELETE THIS LINE
        sizeof BitmapInfoHeader   pbmi biSize          !
        width @                   pbmi biWidth         !
        height @                  pbmi biHeight        !
        1                         pbmi biPlanes       w!
        r@                        pbmi biBitCount     w!
        r> \ nBits
           CASE
               1 OF BI_RGB    2   ENDOF
               4 OF BI_RLE4  16   ENDOF \ Could also be BI_RGB for
               8 OF BI_RLE8 256   ENDOF \ uncompressed format
              16 OF BI_RGB    0   ENDOF
              24 OF BI_RGB    0   ENDOF
              32 OF BI_RGB    0   ENDOF
            ENDCASE
        swap pbmi biCompression !

      \  0    pbmi biSizeImage          !       NOT NEEDED            (1)
      \  0    pbmi biXPelsPerMeter      !       SINCE
      \  0    pbmi biYPelsPerMeter      !       pbmi IS ERASED
      \  0    pbmi biClrUsed            !       ABOVE
      \  0    pbmi biClrImportant       !

 ;

0 value lpBits
0 value ghdc


: create-dc  ( w h - hbm hdcMem )
        swap ghdc  Call CreateCompatibleBitmap  dup ?win-error \ hbm
        ghdc  Call CreateCompatibleDC  dup ?win-error         \ hdcMem
        2dup  Call SelectObject  ?win-error

 ;

: copy-bitmap (  dc-source hdcMem  xdest ydest -  )  \ or ( source dest xdest ydest - )
        2>r >r >r
        SRCCOPY
        0 0                            \ y,x origin
        r>       \ GetHandle: demo-dc  \ from screen dc
        height @                       \ height of dest rect
        width @                        \ width of dest rect
        2r>                            \ y,x dest
        r> -rot   \ hdcMem             \ to memory dc
        Call BitBlt ?win-error \ ?win-error
 ;


CODE 4>R        ( n1 n2 n3 n4 -- )    \ push a 4 items onto the returnstack
                pop     eax
                sub     ebp, # 16            \ Return Pointer, Forth's subroutine stac
                mov     0 CELLS [ebp], ebx
                mov     1 CELLS [ebp], eax
                pop     eax
                mov     2 CELLS [ebp], eax
                pop     eax
                mov     3 CELLS [ebp], eax
                pop     ebx                 \ tos
                next    c;

CODE 4R>        ( -- n1 n2 n3 n4 )    \ pop a 4 items off the return stack
                push    ebx
                mov     ebx, 0 CELLS [ebp]
                mov     eax, 3 CELLS [ebp]
                push    eax
                mov     eax, 2 CELLS [ebp]
                push    eax
                mov     eax, 1 CELLS [ebp]
                add     ebp, # 16
                push    eax
                next    c;

CODE 4R@        ( -- n1 n2 n3 n4 )    \ get a copy of the top 4 items on the return stack
                push    ebx
                mov     ebx, 0 CELLS [ebp]
                mov     eax, 3 CELLS [ebp]
                push    eax
                mov     eax, 2 CELLS [ebp]
                push    eax
                mov     eax, 1 CELLS [ebp]
                push    eax
                next    c;

: get-bitmap  \ get-color-array ( hbm hdcMem #ScanLines - )
     -rot 0 -rot 4>r DIB_RGB_COLORS pbmi NULL 4r@      \ hbm hdcMem
    Call GetDIBits  ?win-error \ ) 0= abort" 1st GetDIBits"

\   pbmi .BitmapInfoHeader

    pbmi biSizeImage @ malloc to lpBits
\   lpBits pbmi biSizeImage @ erase  \ not needed

    DIB_RGB_COLORS pbmi lpBits 4r>
    Call GetDIBits 0= abort" 2nd GetDIBits"
    4724 pbmi biXPelsPerMeter !  \ for paint
    4724 pbmi biYPelsPerMeter !
 ;

: create-bitmap-file ( nrgbquad - vadr )
    >r save$ count pbmi dup>r bi-wh@ r> bytes/pixel? r> gen-Win3DIBfile
    >r 3drop r>
 ;

: save-hdr-in-bitmap-file ( vadr nrgbquad - )
    >r
    0x4d42 bmfh bfType  w!      \ hdr.bfType
    0 >color-array r@ sizeof RGBQUAD * + dup
      pbmi biSizeImage @  +
      bmfh bfSize       !       \ hdr.bfSize
    0 bmfh bfReserved1 w!       \ hdr.bfReserved1
    0 bmfh bfReserved2 w!       \ hdr.bfReserved2
      bmfh bfOffsetBits !       \ hdr.bfOffBits
    bmfh over sizeof BitmapFileHeader cmove
    pbmi swap >BitmapInfoHeader sizeof BitmapInfoHeader r> sizeof RGBQUAD * + cmove
 ;

: release-bitmap ( hbm hdcmem - )
     call DeleteDC     ?win-error
     call DeleteObject ?win-error
 ;

: release-bitmap-resources ( hbm hdcmem ahndl - )
     close-map-file drop release-bitmap
     lpBits release
 ;


\ save-to-bitmap is copy of windemo.f with a number of changes
\ conditions for this save-to-bitmap:
\ 1. ghdc  should be filled with the DC of the window. ( getDC: self in a Window )
\ 2. save$ should be filled with the file-name of the bitmap-file
\ Note: GetDIBits is not able to write to a mapped file.

: save-to-bitmap  ( dc-source nBits - )
   ogl-hwnd call UpdateWindow drop    \ for w2k
   fill-pbmi dup>r                  (   dc-source nBits - dc-source nrgbquad            )
   width @ height @ create-dc       ( dc-source nrgbquad - dc-source nrgbquad hbm hdcMem )
   3 roll over 0 0 copy-bitmap      ( dc-source nrgbquad hbm hdcMem - nrgbquad hbm hdcMem )
   2dup height @ get-bitmap
   r> create-bitmap-file   >r    \ vadr
   rot r@ swap save-hdr-in-bitmap-file   ( nrgbquad hbm hdcMem - hbm hdcMem )
   lpBits r> >color-array pbmi biSizeImage @  cmove      \ color array to bitmap
   ahndl release-bitmap-resources
 ;

: _load-bitmap  ( - flag )   \ save$ should be set
   LR_LOADFROMFILE LR_CREATEDIBSECTION or
   height @ width @
   IMAGE_BITMAP save$ dup +NULL 1+
   NULL  Call LoadImage dup  0<> dup>r
     if   dup>r ghdc  Call CreateCompatibleDC dup>r ( - hdc-image )
          Call SelectObject
          SRCCOPY 0 0  r@ height @  width @ 0 0 ghdc call BitBlt ?win-error  \ on screen
          r> Call SelectObject drop       \ reselect the old selected object
          r> call DeleteObject ?win-error
   else drop
   then r>
 ;

defer show-buffer  \ allows redirection of a buffer to a bitmap

0 value #frames-to-do
0 value #frames-done
0 value #turns

string: #frames-to-do$
string: init-save$

: +bmp ( str$ - )    dup s" .bmp" rot +place +null  ;

: msgbox&title    { \ title$ message$ -- } ( adr2 len2 adr1 len1 type  - button )
    MAXSTRING localAlloc: message$
    MAXSTRING localAlloc: title$
    >r
    message$ place message$ +NULL
    title$   place title$   +NULL
    r>
    title$ 1+ message$ 1+
    NULL call MessageBox
 ;

: infobox   { \ title$ message$ -- }  ( adr2 len2 adr1 len1  - )
    [ MB_OK MB_ICONINFORMATION or MB_TASKMODAL or ] literal msgbox&title ;


FileSaveDialog SaveBitmap "Bitmaps to save start with: " "Bitmap Files (*.bmp)|*.bmp|All Files (*.*)|*.*|"

FileSaveDialog SaveBitmapAs "Save bitmap as: " "Bitmap Files (*.bmp)|*.bmp|All Files (*.*)|*.*|"

: extension> ( str.x..xx -  )  \ deletes .x..xx
   count dup 0= abort" Bad filename" "minus-ext" swap 1- c! ;

: save-as  ( dc-source - )
   ogl-hwnd Start: SaveBitmapAs dup c@ 0 = abort" Bad name. Bitmap not saved"
   count save$ place save$ extension> save$ +bmp
   wait-cursor
   _limit-bpps  save-to-bitmap
   arrow-cursor
 ;

\s
