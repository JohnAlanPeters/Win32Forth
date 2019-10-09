\ $Id: EX_DDRAW.F,v 1.3 2007/05/19 09:10:07 jos_ven Exp $

\ Example of using Direct Draw (Directx)
\ Thomas Dixon

needs fcom

1 0 typelib {E1211242-8E94-11D1-8808-00C04FC2C602} \ Load Directx7


\ Interfaces
IDirectx7 ComIFace dx7
DirectDraw7 ComIFace dd7
DirectDrawSurface7 ComIFace primary

\ Structures
DDSURFACEDESC2 ddsdl \ define a surface structure
Rect winrect


: window-mode ( -- )
  DDSCL_NORMAL conhndl dd7 SetCooperativeLevel abort" SetCooperativelevel failed!" ;

: full-screen ( color width height -- )
  DDSCL_FULLSCREEN DDSCL_ALLOWMODEX DDSCL_EXCLUSIVE or or conhndl
  dd7 setCooperativeLevel abort" SetCooperativeLevel failed!"
  >r 2>r DDSDM_DEFAULT 0 2r> r> dd7 setdisplaymode
  abort" Unable to set display mode!" ;

: setup-ddraw ( -- )
  dx7 IDirectx7 1 0 Directx7 Call CoCreateInstance abort" Unable to get Directx!"
  dd7 0 dx7 DirectDrawCreate abort" DirectDrawCreate failed!"
  16 480 640 full-screen \ set screen resolutuion (use window-mode to work from a window)

  DDSD_CAPS ddsdl lFlags !
  DDSCAPS_PRIMARYSURFACE ddsdl ddsCaps lCaps !
  primary ddsdl dd7 CreateSurface abort" Primary surface failed!" ;

: get-rect ( -- ) winrect conhndl dx7 getwindowrect drop ;

: rand-circle ( -- )
  $FF random 16 lshift $FF random 8 lshift $FF random + +
  primary setforecolor drop
  200 random 480 random 640 random primary drawcircle drop ;

: test get-rect 0 do rand-circle loop ;

((
\  This is a simple example using directdraw.  DirectDraw is optimized for blitting
\  in 2D.  It is also fast, fairly low-level, and supports hardware acceleration.
\  In this example, we don't blit at all, we just draw lots of random circles.
))

setup-ddraw
10000 test




