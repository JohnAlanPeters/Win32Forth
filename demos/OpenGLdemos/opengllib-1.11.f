\ ===================================================================
\           File: opengllib-1.11.fs
\         Author: Bosco
\  Linux Version: Ti Leggett
\ gForth Version: Timothy Trussell, 07/25/2010
\    Description: Flag effect (waving texture)
\   Forth System: gforth-0.7.0
\   Linux System: Ubuntu v10.04 LTS i386, kernel 2.6.31-23
\   C++ Compiler: gcc version 4.4.3 (Ubuntu 4.4.3-4ubuntu5)
\ ===================================================================
\                       NeHe Productions
\                    http://nehe.gamedev.net/
\ ===================================================================
\                   OpenGL Tutorial Lesson 11
\ ===================================================================
\ This code was created by Bosco
\ ported to Linux/SDL by Ti Leggett
\ March, 2013 adapted for Win32Forth by Jos v.d.Ven
\ Visit Jeff at http://nehe.gamedev.net/
\ ===================================================================

s" src\lib\OpenGl" "fpath+ \ For OpenGL support

needs opengl.f             \ The OpenGl wrapper and many tools

menubar Openglmenu         \ Define a menu for the OpenGL window
  popup "&File"     menuitem   "E&xit"  ExitScene bye ;
endbar

needs oglwin.f              \ The OpenGL window
needs Helpform.f            \ For the help window
needs OpenGlLessons.f       \ To support this lesson

vocabulary Lesson11  also Lesson11 definitions

\ ---[ Variable Declarations ]---------------------------------------

-1e facos fconstant pi

PI 2e F* fconstant 2PI                                  \ common calc

fvariable x-rot
fvariable y-rot
fvariable z-rot

0 value wiggle-count                    \ how fast the flag waves

\ Need to create a [45][45][3] fp array here
\ These can be fixed as 8-byte fp values, as they are sent to the
\ OpenGL system via the gl-vertex-3f call, not by passing the address
\ of the array.

\ One way of thinking of this is as (3) (45x45) arrays
\ So, x and y have a range of [0..44], and z has a range of [0..2]

\       +-------+               |---x ---|
\       |       |-+             +--------+ -+-
\       |       | |-+           |        |  |
\       |    z=0| | |           |        |  y
\       +-------+1| |           |        |  |
\         +-------+2|           +--------+ -+-
\           +-------+

create points[] here 45 floats 45 * 3 * dup allot 0 fill

\ ---[ Array Index Functions ]---------------------------------------
\ Index functions to access the arrays

: points-ndx { _x _y _z -- *points[x][y][z] }
  points[]                      \ *points[]
  \ calculate row of the y coordinate
  _y 45 floats *                \ *points[] yofs
  \ calculate column of the x coordinate
  _x floats +                   \ *points[] yofs+xofs
  \ calculate page of the z coordinate
  _z 45 floats 45 * * +         \ *points[] yofs+xofs+zofs
  +                             \ *points[yofs+xofs+zofs]
;

\ ---[ LoadGLTextures ]----------------------------------------------

 : LoadGLTextures ( -- status )
  \ create variables for storing surface pointers and return flag
  1 MallocTextures      \ MallocTextures allocates only when not done
  NumTextures texture[] gl-gen-textures         \ create the textures
  \ Attempt to load the texture images by using a mapping
  s" tim.bmp"  0 ahndl LoadGLTexture                       \ ndx = 0
  true                         \ exit -1=ok OR abort in LoadGLTexture
;


\ ---[ HandleKeyPress ]----------------------------------------------
\ function to handle key press events:
:long$ h11$
$| About lesson 11:
$|
$| Key-list for the available functions in this lesson:
$|
$| ESC      exits the lesson
$| w        toggles between fullscreen and windowed modes
  ;long$

\ ---[ HandleKeyPress ]----------------------------------------------
\ function to handle key press events

: HandleKeyPress ( VK_key  -- )
    ascii W =
      if     start/end-fullscreen       \ Starts of end the full screen
      else   h11$ ShowHelp         \ Show the help text for this lesson
      then
;


\ ---[ Set the viewpoint ]-------------------------------------------

: set-viewpoint ( -- )   \ the call to glViewport is done in Opengl.f
  GL_PROJECTION gl-matrix-mode
  \ Reset the matrix
  gl-load-identity
  \ Set our perspective - the F/ calcs the aspect ratio of w/h
  45e widthViewport  S>F heightViewport  S>F F/ 0.1e 100e glu-perspective
  \ Make sure we are changing the model view and not the projection
  GL_MODELVIEW gl-matrix-mode
;


\ ---[ InitGL ]------------------------------------------------------
\ general OpenGL initialization function

: InitGL ( -- )
    \ Load in the texture
    LoadGLTextures drop
    \ Enable texture mapping
    GL_TEXTURE_2D gl-enable
    \ Enable smooth shading
    GL_SMOOTH gl-shade-model
    \ Set the background black
    0e 0e 0e 0.5e gl-clear-color
    \ Depth buffer setup
    1e gl-clear-depth
    \ Enable depth testing
    GL_DEPTH_TEST gl-enable
    \ Type of depth test to do
    GL_LEQUAL gl-depth-func
    \ Really nice perspective calculations
    GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST gl-hint
    \ Fill the back with texture; the front will only be wireline
    GL_BACK GL_FILL gl-polygon-mode
    GL_FRONT GL_LINE gl-polygon-mode
    \ Apply the wave to our mesh array
    45 0 do
      45 0 do
        j S>F 5e F/ 4.5e F-                    j i 0 points-ndx F!
        i S>F 5e F/ 4.5e F-                    j i 1 points-ndx F!
        j S>F 5e F/ 40e F* 360e F/ 2PI F* FSIN j i 2 points-ndx F!
      loop
    loop
;


\ ---[ DrawGLScene ]-------------------------------------------------
\ Here goes our drawing code

fvariable f-x                 \ use to break the flag into tiny quads
fvariable f-y
fvariable f-xb
fvariable f-yb

: DrawGLScene ( -- )
  \ Clear the screen and the depth buffer
  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR gl-clear
  gl-load-identity                                   \ restore matrix
  \ Translate 17 units into the screen
  0e 0e -17e gl-translate-f
  \ Rotate on the x/y/z axes
  x-rot F@ 1e 0e 0e gl-rotate-f
  y-rot F@ 0e 1e 0e gl-rotate-f
  z-rot F@ 0e 0e 1e gl-rotate-f
  \ Select our texture
  GL_TEXTURE_2D 0 texture-ndx @ gl-bind-texture
  \ Start drawing our quads
  GL_QUADS gl-begin
    44 0 do
      44 0 do
        j S>F 44e F/ f-x F!                     \ Create a fp x value
        i S>F 44e F/ f-y F!                     \ Create a fp y value
        j 1+ S>F 44e F/ f-xb F!              \ Create x+0.0227e value
        i 1+ S>F 44e F/ f-yb F!              \ Create y+0.0227e value
        \ Bottom Left texture coordinate
        f-x F@ f-y F@ gl-tex-coord-2f
        j i 0 points-ndx F@
        j i 1 points-ndx F@
        j i 2 points-ndx F@ gl-vertex-3f
        \ Top left texture coordinate
        f-x F@ f-yb F@ gl-tex-coord-2f
        j i 1+ 0 points-ndx F@
        j i 1+ 1 points-ndx F@
        j i 1+ 2 points-ndx F@ gl-vertex-3f
        \ Top Right texture coordinate
        f-xb F@ f-yb F@ gl-tex-coord-2f
        j 1+ i 1+ 0 points-ndx F@
        j 1+ i 1+ 1 points-ndx F@
        j 1+ i 1+ 2 points-ndx F@ gl-vertex-3f
        \ Bottom Right texture coordinate
        f-xb F@ f-y F@ gl-tex-coord-2f
        j 1+ i 0 points-ndx F@
        j 1+ i 1 points-ndx F@
        j 1+ i 2 points-ndx F@ gl-vertex-3f
      loop
    loop
  gl-end

  \ Used to slow down the wave (every 2nd frame only)
  wiggle-count 1 > if
    45 0 do
      0 i 2 points-ndx F@
      44 0 do
        i 1+ j 2 points-ndx F@ i j 2 points-ndx F!
      loop
      44 i 2 points-ndx F!
    loop
    0 to wiggle-count                              \ set back to zero
  then
  wiggle-count 1+ to wiggle-count

  \ Draw it to the screen
  sdl-gl-swap-buffers

  x-rot F@ 0.3e F+ x-rot F!                    \ increment x rotation
  y-rot F@ 0.2e F+ y-rot F!                    \ increment y rotation
  z-rot F@ 0.4e F+ z-rot F!                    \ increment z rotation
;

: _exitLesson  ( -- )         \ For a clean start in the next drawing
  DeleteTextures
  true to resizing?
 ;

' _exitLesson is ExitScene

: ResetLesson  ( -- )              \ For a clean start in this lesson
    ResetOpenGL                      \ Cleanup from a previous lesson
    InitGL                   \ Enable some features and load textures
    set-viewpoint                                 \ Set the viewpoint
    false to resizing?
 ;


also Forth definitions


: DrawGLLesson11  ( -- )                          \ Handles ONE frame
   LessonChanged?
      if  false to LessonChanged?
          ['] HandleKeyPress is KeyboardAction \ Use the keystrokes for this lesson only
          ['] _ExitLesson is ExitLesson    \ Specify ExitLesson to free allocated memory
          Reset-request-to-stop
      then
   resizing?
     if  ResetLesson
     then
   DrawGLScene           \ Redraw only the changes in the lesson
   ProcesKeyAndRelease                \ HandleKeyPress only here
 ;

: StartGLLesson11 ( -- )
   Start: OpenGLWindow
   DrawGLLesson11
   ['] DrawGLScene  is painting
   begin  DrawGLLesson11 request-to-stop  until
 ;

   StartGLLesson11
\s
