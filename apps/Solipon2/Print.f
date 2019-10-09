\ $Id: Print.f,v 1.1 2008/04/30 15:58:01 dbu_de Exp $

\ ---------------------------------------------------------------
\               Print the Positions of the Game (text)
\ ---------------------------------------------------------------

        create ligne$ 256 allot

: #moves" { nmoves \  -- adr len }
                ligne$ 256 blank
                moves-table nmoves cells+
                s"    "                   ligne$  place
                dup     c@ 0 <# # # #>    ligne$ +place
                s"      "                 ligne$ +place
                dup 1 + c@ 0 <# # # #>    ligne$ +place
                s"     "                  ligne$ +place
                dup 2 + c@ 0 <# # #>      ligne$ +place
                s"      "                 ligne$ +place
                    3 + c@ 0 <# # #>      ligne$ +place
                                          ligne$ count

;


: print-game  { \ message$ -- }

                MAXSTRING localAlloc: message$
                screen-width    >r 680 to screen-width
                screen-height   >r 484 to screen-height
                char-height     >r  12 to char-height
                char-width      >r   9 to char-width



                #pages-up ?dup
                IF      2 =
                        IF      two-page
                        ELSE    four-page
                        THEN
                THEN
                start-scaled

        IF

                s" Courier New" SetPrinterFont: ThePrinter
             s"    Score : "                   message$  place
                counter 0 (ud,.)               message$ +place

                           message$ count Type: ThePrinter
                                            Cr: ThePrinter

    s"    Row   Line   Rank   Direction"  Type: ThePrinter
                                            Cr: ThePrinter
                counter 0
                DO     i #moves"

                                          Type: ThePrinter
                                            Cr: ThePrinter
                LOOP
                print-scaled
                single-page
        THEN    r> to char-width
                r> to char-height
                r> to screen-height
                r> to screen-width
        ;

\ ---------------------------------------------------------------
\               Print the Bitmap of the Game
\ ---------------------------------------------------------------

        DECIMAL
        4 constant sizeof(RGBQUAD)
       14 constant sizeof(BitmapFileHeader)
       40 constant sizeof(BitmapInfoHeader)

        0 constant biSize
        4 constant biWidth
        8 constant biHeight
       12 constant biPlanes
       14 constant biBitCount
       16 constant biCompression
       20 constant biSizeImage
       24 constant biXPelsPerMeter
       28 constant biYPelsPerMeter
       32 constant biClrUsed
       36 constant biClrImportant

: print-demo-bmp { nBits \  pbmi lpBits hbm  hdcMem    -- }
             Open: ThePrinter
        GetHandle: ThePrinter 0= ?EXIT
        LandScape: ThePrinter
            Start: ThePrinter

             sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + malloc to pbmi
        pbmi sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + erase

        sizeof(BitmapInfoHeader) pbmi biSize + !
        SCREEN-WIDTH pbmi biWidth + !
        SCREEN-HEIGHT pbmi biHeight + !
        1 pbmi biPlanes + w!
        nBits pbmi biBitCount + w!
        BI_RGB pbmi biCompression + !

        SCREEN-HEIGHT
        SCREEN-WIDTH
        GetHandle: solipion-dc
        Call CreateCompatibleBitmap to hbm

        GetHandle: solipion-dc
        Call CreateCompatibleDC to hdcMem
        hbm hdcMem Call SelectObject drop

        SRCCOPY
        0 0
        GetHandle: solipion-dc
        SCREEN-HEIGHT
        SCREEN-WIDTH
        0 0
        hdcMem
        Call BitBlt ?win-error

        DIB_RGB_COLORS
        pbmi
        NULL
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 1st GetDIBits"

        pbmi biSizeImage + @ malloc to lpBits
        lpBits pbmi biSizeImage + @ erase

        DIB_RGB_COLORS
        pbmi
        lpBits
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 2nd GetDIBits"

        SRCCOPY
        DIB_RGB_COLORS
        pbmi
        lpBits
        SCREEN-HEIGHT
        SCREEN-WIDTH
        0
        0
        Height: ThePrinter  80 100 */
        Width: ThePrinter   80 100 */
        Height: ThePrinter  10 100 */
        Width: ThePrinter   10 100 */
        GetHandle: ThePrinter
        Call StretchDIBits GDI_ERROR = ABORT" StretchDIBits"

      5 0 do

         Width: ThePrinter  8 100 */ i -
        Height: ThePrinter  8 100 */ i -  MoveTo: ThePrinter

         Width: ThePrinter 92 100 */ i +
        Height: ThePrinter  8 100 */ i -  LineTo: ThePrinter

         Width: ThePrinter 92 100 */ i +
        Height: ThePrinter 92 100 */ i +  LineTo: ThePrinter

         Width: ThePrinter  8 100 */ i -
        Height: ThePrinter 92 100 */ i +  LineTo: ThePrinter

         Width: ThePrinter  8 100 */ i -
        Height: ThePrinter  8 100 */ i -  LineTo: ThePrinter

          loop

        End: ThePrinter
        Portrait: ThePrinter
        Close: ThePrinter
        hdcMem call DeleteDC ?win-error
        hbm call DeleteObject ?win-error

        lpBits release
        pbmi release
        ;

