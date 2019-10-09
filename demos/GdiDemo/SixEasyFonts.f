\ SixEasyFonts.F
\ Written by David R. Pochin
\ Changed to use the GDI class library by Dirk Busch

\ Using Windows Stock Fonts

ANEW -SixEasyFonts.F

needs gdi/gdi.f

\ Define an Object that is a child object of the Class "Window".
:OBJECT Fontdemo <SUPER WINDOW

gdiWindowDC tDC

:M WindowTitle: ( -- title )         \ Title for the window.
                z" Six Easy Fonts      One example only"
                ;M

:M StartSize:   ( -- width height )  \ Set width and height of window
                500 200
                ;M

:M StartPos:    ( -- x y )           \ Set the screen origin.
                100 100
                ;M

:M Close:       ( -- )               \ Do anything the class needs.
                Destroy: tDC
                Close: SUPER
                ;M

:M On_Paint:  ( -- )                 \ screen redraw procedure

        GetHandle: self GetDC: tDC
        if
             DEVICE_DEFAULT_FONT SelectStockObject: tDC
             20 30 s" DEVICE_DEFAULT_FONT AaBbCc¹º1/41/23/4¿HhIiJjKkLl" TextOut: tDC

             SYSTEM_FONT SelectStockObject: tDC drop
             20 50 s" SYSTEM_FONT AaBbCc¹º1/41/23/4¿HhIiJjKkLl" TextOut: tDC

             SYSTEM_FIXED_FONT SelectStockObject: tDC drop
             20 70 s" SYSTEM_FIXED_FONT AaBbCc¹º1/41/23/4¿HhIiJjKkLl" TextOut: tDC

             OEM_FIXED_FONT SelectStockObject: tDC drop
             20 90 s" OEM_FIXED_FONT AaBbCc¹º1/41/23/4¿HhIiJjKkLl" TextOut: tDC

             ANSI_FIXED_FONT SelectStockObject: tDC drop
             20 110 s" ANSI_FIXED_FONT AaBbCc¹º1/41/23/4¿HhIiJjKkLl" TextOut: tDC

             ANSI_VAR_FONT SelectStockObject: tDC drop
             20 130 s" ANSI_VAR_FONT AaBbCc¹º1/41/23/4¿HhIiJjKkLl" TextOut: tDC

             SelectObject: tDC drop \ clean up
             Release: tDC
        then ;M

;OBJECT \ Complete the definition of the new object.

: FONTS ( -- )
        Start: Fontdemo ;

FONTS

\ END OF LISTING.


