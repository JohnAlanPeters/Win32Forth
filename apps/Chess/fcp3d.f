\ December 2nd, 2002  for Win32Forth by J.v.d.Ven
\ Changed in this version: removed .last-move_ogl from labels left

anew  tscpogl.f

: set-viewpoint2 ( f: -- eyex eyey eyez  centerx centery centerz upx upy upz  )
\  eyex      eyey     eyez
\   .00000e  .43000e  4.1300e
   .0000e .2300e 4.130e         fref3eyeE    floatsf@+
\ centerx  centery   centerz
  .0000e .1900e 3.340e          fref3CenterC floatsf@+
\ upx        upy      upz
   00000e   .000e    -.02000e   fref3UpF     floatsf@+
 ;

1 value #objects-around

struct{ \ all static objects around
  sizeof box_dyn #objects-around * _add-struct
}struct statics

struct{ \  element-selectbuf
  long #sel_names
  long sel_min_depth
  long sel_max_depth
  long sel_name
}struct element-selectbuf

32 constant #pieces
#pieces 1 + constant  #selectable-objects

#selectable-objects sizeof element-selectbuf * mkstruct: name-stack

: new-matrix
    rdistance 0.e 1e 0.25e  Mut4RotR floats! \ Tell it how to rotate
     0.4e  0.5e  9.5e  0.5e  glClearColor  \ r g b a   background

\ clear buffers
     GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR glClear
     0.0e0  0.0e0  .0e0                         glColor3f

     0.0e  1.0e  0.0e  0.0e  objectcolor GLfloat!

     GL_DEPTH_TEST glEnable
     GL_PROJECTION glMatrixMode
     glLoadIdentity
 ;

: b_bouncing-environment

\ define a viewing volume 126

(  f: fovy   aspect  near  far -- )
     47.00e 1.000e .0100e 15.00e  fref4PersP floatsf@+ gluPerspective
      0.00e .00e -.200e .000e     fref4RotD  floatsf@+ glRotatef  \ deg x y z rotate eye

     set-viewpoint2 gluLookAt        \ Set a viewpoint

     glInitNames  0 glPushName

     .1700e .1700e .1700e  fref3ScaleS floatsf@+ glscalef   \ to get 1 meter nice on screen

      0.00e .00e -.200e .000e fref4RotX   floatsf@+ glRotatef  \ deg x y z  Rotate around the center
      -.0351e .6200e 18.01e fref3TransT floatsf@+ glTranslatef  \ x y z move scene
    35.00e 19.50e .9400e -.6030e   \ front
\     184.0e -1.003e 93.56e 36.65e  \ backside
     fref4RotR floatsf@+ glRotatef \ deg x y z  Rotate all objects
     GL_MODELVIEW glMatrixMode  \ set viewing to the model matrix ( object(s) )
 ;


\ 3D-board is needed to remember the last position while TSCP is thinking
CREATE 3D-board 64 ALLOT

: dark?  dark and ;

: piece>3dBoard ( n p - n1 p )
   dup>r ?rotate bd@
   DUP piece CELLS symbols + @       \ symbol for piece
  SWAP dark? IF tolower THEN
   over 3D-board + c! 1+ r>

   ;

: move-board-to-3D-board ( - )   \ board 3D-board $80 move
  0 ['] piece>3dBoard forEverySq drop  ;

: black_piece   ( - ) 0.0e  .4596e .4385e .3800e   objectcolor!  ;
: white_piece   ( - ) 0.0e   1.000e .7333e .6519e  objectcolor!  ;
: black_square  ( - ) 0.0e  .1660e .0624e -.0251e  objectcolor!  ;
: white_square  ( - ) 0.0e  .9974e .9242e .4617e   objectcolor!  ;
: white_letters ( - ) 0.0e  .9184e .8057e .4222e   objectcolor!  ;

0.43e fconstant square-size

: .square  ( f: x y - )
   GL_QUADS   0e fswap [object
   square-size  .14e square-size  box
   object]
 ;
: square-position ( n - )  ( f: - position )   s>f square-size f*  ;
: glload_name ( id - )   glLoadName GL_LINES glBegin glEnd ;

(( \ Some tests for the pick interface which is not right yet
100 constant bl_king
101 constant bl_queen
102 constant bl_rook

: test-square    \ supose it is a black queen
   black_piece
   bl_queen  glload_name  \ enables it to detect by the pick interface
   -.6000e .000e  .square
  ;

: test-square2   \ supose it is a black rook
  black_piece
  bl_rook  glload_name
  3.800e .8000e   .square
  ;

\ ))

: .ogl_king  ( - )
   GL_POLYGON .0000e .000e .400e   [object
     30 9  qobj  0.15e  0.0158e  .3e  OldgluCylinder
   object]
   GL_POLYGON .0000e .000e .5979e  [object
     30 9  qobj   .0419e .0089e .4179e   OldgluCylinder
   object]
   GL_POLYGON .0000e .0000e .9226e [object
     .06e 8 8 sphere
   object]
   GL_QUADS .0000e .00e 1.031e  [object
      .04e .02e .2e  box
   object]
   GL_QUADS .0000e .00e 1.032e  [object
      .2e .04e  .03e  box
   object]
 ;

: .ogl_queen  ( - )
   GL_POLYGON  180.000e 1.0000e  .0000e 0e
    .0027e .0000e .6823e   [rot-object
     30 9  qobj .0183e .1475e .2883e  OldgluCylinder
   object]
   GL_POLYGON .0000e .000e .5875e  [object
     30 9  qobj   .0419e .0089e .4179e    OldgluCylinder
   object]
   GL_POLYGON 180.000e 1.0000e  .0000e 0e
    .0000e .0000e 1.010e  [rot-object
     30 9  qobj .0983e .0158e .1420e   OldgluCylinder
   object]
 ;

: .ogl_bishop  ( - )
   GL_POLYGON  180.000e 1.0000e  .0000e 0e
    .0027e .0000e .5968e   [rot-object
     30 9  qobj .0183e .1475e .2005e  OldgluCylinder
   object]
   GL_POLYGON  .0000e .0000e .5147e  [object
     30 9  qobj   .0419e .0089e .4179e    OldgluCylinder
   object]
   GL_POLYGON .0000e .0000e .7382e  [object
   .06e 64 16 sphere
   object]
   GL_POLYGON .0000e .0000e .8203e  [object
   .03e 64 16 sphere
   object]
 ;

: .ogl_knight  ( - )
   GL_POLYGON  180.000e 1.0000e  .0000e  0e
    .0027e .0000e .5968e   [rot-object
     30 9  qobj .0183e .1475e .2005e  OldgluCylinder
   object]
   GL_QUADS  -30e .000e -1.09e 0e
    .0644e .0000e .6462e   [rot-object
    .0576e .0576e .2527e  box
   object]
   GL_QUADS  -105.1e .0000e 1.948e 0e
    .0381e .0000e .7120e  [rot-object
    .0576e .0576e .2000e  box
   object]
 ;

: .ogl_rook  ( - )
   GL_POLYGON  180.000e 1.0000e  .0000e  0e
    .0027e .0000e .5968e   [rot-object
     30 9  qobj .0183e .1475e .2005e  OldgluCylinder
   object]
   GL_POLYGON 180.000e 1.0000e  .0000e 0e
    .0027e .0000e .8341e [rot-object
     4 4  qobj .0515e .0397e .3836e   OldgluCylinder
   object]
 ;

: .ogl_pawn  ( - )
   GL_POLYGON  180.000e 1.0000e  .0000e 0e
    .0027e .0000e .5421e  [rot-object
     30 9  qobj .0000e .2046e .2487e   OldgluCylinder
   object]
   GL_POLYGON  .0000e .0000e .3812e  [object
     30 9  qobj .0630e .0132e .2576e  OldgluCylinder
   object]
   GL_POLYGON .0000e .0000e .6979e  [object
   .06e 64 16 sphere
   object]
 ;


Font vFont

\ Define an outlined font for a 3d Font ( use a true type font )
\ Create 256 display lists. One for each glyph. 0 thru 255
\ The display list numbering starts at 1, an arbitrary choice

: init-3Dfont  ( - )
    s" Comic Sans MS" SetFaceName: vFont
    Create: vFont ( drop ) \ removed the invalid DROP Montag, Mai 29 2006 dbu
    Handle: vFont ghdc call SelectObject drop
   ghdc 1 255 1 .0200e .0880e  WGL_FONT_POLYGONS lpgmf_buffer wglUseFontOutlines
 ;

0e fvalue vspace
0e fvalue hspace
0e fvalue charcnt_ogl
0e fvalue #lines_ogl

 3 fref: fref3TransEmit

: new_line ( - ) 0e fto charcnt_ogl 1e +fto #lines_ogl  ;

string: buffer

: _emit_ogl ( char - )    0 buffer dup>r ! 1 r@ c! r@ 1+ c! r> count 1 glType ;

:  decode_piece ( char - )
    dup upc  2dup =
       if    white_piece
       else  black_piece
       then
     dup glload_name \ Perhaps future use. It has an impact on the graphics
     GL_TEXTURE_2D glEnable
    case
     ascii B   of     drop  .ogl_bishop  endof
     ascii K   of     drop  .ogl_king    endof
     ascii N   of     drop  .ogl_knight  endof
     ascii P   of     drop  .ogl_pawn    endof
     ascii Q   of     drop  .ogl_queen   endof
     ascii R   of     drop  .ogl_rook    endof
    drop
    endcase
    GL_TEXTURE_2D glDisable
 ;

13 constant carret

: piece-position
    dup carret =
      if   new_line  drop
      else   GL_QUADS
           -90e 0.5e 0e 0e
           1e 1e 1e
           fref3TransEmit floats@
           2 froll hspace charcnt_ogl f* f+
           frot frot vspace #lines_ogl f* f+
              [rot-scaled-object
                 decode_piece
              object]
           1e +fto charcnt_ogl
      then
;

: emit_ogl ( char - )
    dup carret =
      if   new_line  drop
      else GL_QUADS
           -90e 0.5e 0e 0e
           .1654e .0429e .0972e
           fref3TransEmit floats@
           2 froll hspace charcnt_ogl f* f+
           frot frot vspace #lines_ogl f* f+
              [rot-scaled-object
              0 buffer dup>r ! 1 r@ c! r@ 1+ c! r> count 1 glType
              object]
           1e +fto charcnt_ogl
      then
 ;

: 3D-bd@ ( sq -- piece ) s" 3D-board + c@" evaluate ; immediate

: .aSq_ogl (  -- )
    64 0
       do    i 8 /mod drop 0=
                  if   carret piece-position
                  then
             i 3D-board + c@  piece-position

       loop  ;

: type_ogl ( adr count - )
  dup 0>
     if  bounds
         do     i c@ emit_ogl
         loop
     else 2drop
  then
 ;

: emit$  ( char adr$ - )   >r sp@ 1 r@ +place r> +null drop ;

: 0.$sq ( adr$ sq -- )
  swap >r DUP file [CHAR] a + r@ emit$
  rank [CHAR] 8 SWAP - r> emit$ ;

: .$sq ( sq $ -- ) >r DUP cFile r@ emit$ cRank r> emit$ ;

: .last-wtm$ ( wtm $adr - )
   swap
     if    s" Black: "
     else  s" White: "
     then  rot place
 ;

: .$move ( adr$ mv -- )
  swap dup>r off
  wtm? r@ .last-wtm$
  DUP mvFrom r@ .$sq
  DUP captureBit AND IF [CHAR] x ELSE [CHAR] - THEN r@ emit$
  DUP mvTo r@ .$sq
  DUP promoteBit AND IF
    [CHAR] = r@ emit$  DUP mvPromote drop \ .piece
  THEN
  epBit AND IF s"  ep" r@ +place THEN \ Jos: Oct. 20th, 2003
  r>drop ;

: first-move?  ( - flag )     histTop histStack = ;

string: $last-move

: .last-move   ( - )
   first-move?
       if    0 $last-move !
       else  histTop 8 - @ $last-move swap .$move
       then
 ;

: clr-ascii-ogl ( - )    0e fto charcnt_ogl 0e fto #lines_ogl ;

: .last-move_ogl
   .last-move
       GL_QUADS
      -20.76e 1.500e .0000e 0e
      .2394e .3041e .2017e
      .9326e .0133e 3.681e  [rot-scaled-object
         $last-move count 1 gltype
        object]
 ;


: cr_ogl ( - )   carret emit_ogl ;

: emit-index ( n - )   ascii 0 + emit_ogl cr_ogl  ;

: .labels_left  ( - )
    clr-ascii-ogl square-size fto vspace
   -.3214e .0408e -.0225e  fref3TransEmit floats!
    blackAtBottom?
      if    9 1 do    i   emit-index loop
      else  8 0 do  8 i - emit-index loop
      then
 ;

: .labels_bot  ( - )
    clr-ascii-ogl square-size fto hspace
    0e .0361e 3.318e fref3TransEmit floats!
    blackAtBottom?
       if    s" hgfedcba"
       else  s" abcdefgh"
       then
   type_ogl
 ;

:inline odd?  ( n - flag )   1 and  ;
: even?          ( n - flag )   odd? not ;

action-of cr value SavedCr

: .squares
     -1.501e .4429e -1.110e  glTranslatef \  position first square
\      test-square test-square2   \ tests for the pick interface
     GL_CULL_FACE   glEnable
      white_letters .labels_bot .last-move_ogl .labels_left
      GL_CULL_FACE   glDisable
      clr-ascii-ogl
   -.0042e -.3284e -.4283e fref3TransEmit floats! \ position first piece
      ['] cr_ogl is cr

          GL_SMOOTH  glShadeModel
      .aSq_ogl
          GL_FLAT     glShadeModel
      SavedCr is cr
      8 0 do
          8 0 do i dup j + even?
                   if    white_square
                   else  black_square
                   then
                   square-position j square-position .square
              loop
         loop
;


: .ogl_board        ( - )
   glPushMatrix
      0000e 0000e  .0000e 0000e  glRotatef
      0000e 0000e 0000e  glTranslatef
      black_square
          GL_QUADS .0000e .4000e .400e  [object
          3.66e .14e 3.66e   box
          object]
      .squares
   glPopMatrix
 ;


: set-spot0
    .0000e .4521e .5701e .6370e fref4LambientN floatsf@+  model-ambient GLfloat!
    GL_LIGHT_MODEL_AMBIENT model-ambient  glLightModelfv

\  gray  blue   green  red
  .0000e 1.681e .7630e .9778e fref4DiffuseV floatsf@+  lightcolor GLfloat!
    GL_LIGHT0  GL_DIFFUSE   lightcolor    glLightfv

\   ???     y    z      x
    0e 1670.513e 856.7e -569.1e
     fref3LpositionL floatsf@+  lightPosition GLfloat!
    GL_LIGHT0  GL_POSITION  lightPosition  glLightfv
 ;

GLfloat model-ambient1   { .20e 0.3e 0.3e   0.3e0 };
GLfloat lightcolor1      { 0.e 1.0e 0.0e    0.0e  };
GLfloat lightPosition1   { -2.0e 0.0e 0.0e 400.0e  };
GLfloat specular1        { -2.0e 0.0e 0.0e 400.0e  };
GLfloat spotdirection1       { -1.0e -1.0e 0.0e   };


: changed-view      ( - )     new-matrix init-3Dfont  ;

variable *texture


: texture ( name *id - )
   >r  GL_UNPACK_ALIGNMENT over glPixelStorei
   r@ glGenTextures
   GL_TEXTURE_2D  r> @ glBindTexture
   GL_TEXTURE_2D  GL_TEXTURE_MIN_FILTER   GL_NEAREST  glTexParameteri
   GL_TEXTURE_GEN_S glEnable
   GL_TEXTURE_GEN_T glEnable
   GL_TEXTURE_2D  0  3  64 8  0  GL_RGB  GL_UNSIGNED_BYTE
 ;

0 value file-header-bmp-white        \ gluBuild2DMipmaps ?
: load-bitmaps ( - ) \ 1 time when the window is created
  s" t1600017.bmp"  map-bitmap to file-header-bmp-white
 ;

:Inline  2+  ( n - n+2 ) 2 + ;

: swap-red-blue-bitmap3 ( filename count - ) \ 3 bytes/pixel
    map-bitmap dup>r >color-array \ to file-header-bmp-white
  r@ bfSize @ r> bfOffsetBits @ - 3 / 0
   do i   3 * over +
      dup c@ over 2+ dup c@
      -rot c! swap c!
   loop
    drop
 ;

\   s" t1600017.bmp" swap-red-blue-bitmap3

\ t160006.bmp was created by the program julia42.exe

: init_scene  ( - )  glout init-DIBsection changed-view false to resizing?  ;

: _.board_ogl
    b_bouncing-environment
    set-spot0
    clear-buffer
    1 *texture texture
    GL_FLAT     glShadeModel
    file-header-bmp-white >color-array  glTexImage2D
    .ogl_board  \ Builds the chessboard
    show-frame            \ And catch an event, params and switch task
 ;


: .board_ogl       ( - )
     false to slow-action?            \ Do not rotate until <z> is pressed
     true to static-scene             \ This scene does not change
     false to request-to-stop         \ Do not stop until ESC is pressed
     changed-view
   _.board_ogl
     ;

5 to maxDepth        \ to start

\ ' .board_ogl

: >3d.board ( - )   move-board-to-3D-board .board_ogl  ;

' >3d.board is .board           \ use OpenGl

\s

\ The following part in not compiled and has many problems

0 variable depth_component


\ detect-selected-itmes is not right at all.
\ It has scaling and Z-buffer problems

: detect-selected-itmes ( mx my -   )
\ 2drop exit
   #selectable-objects name-stack glSelectBuffer  \ selection buffer for ID's
   GL_VIEWPORT &viewportCoords glGetIntegerv   \ Get the current viewport coord
   GL_MODELVIEW glMatrixMode       \ GL_MODELVIEW for a check mx my ( mouse ) against 3D
     glPushMatrix                    \ protects the displayed projection

\ The following line is disabled.
\ This allows you to see what the selection buffer sees.
\ GL_SELECT glRenderMode drop   \ use the SelectBuffer not the framebuffer
      GL_DEPTH_BUFFER_BIT  glClear
       glLoadIdentity

       swap
      \  &viewportCoords vp_bot @ s>f s>f f- 1e  f* \ y
        s>f  1e  f*   \ left when increased

\       s>f 1e f*                                  \ x
       &viewportCoords vp_right @ s>f s>f f- 3e f*   \ 3  down when increased

\       fdup &viewportCoords vp_right @  s>f 2e f/  1e f* f+  \ w


       &viewportCoords vp_right @ s>f 2e f/   \ w2   2 strech when increased
       &viewportCoords vp_bot   @ s>f 2.25e f/ \ h  2.25 down when increased

\        GL_UNPACK_ALIGNMENT 4e glPixelStorei
\        GL_FLOAT GL_DEPTH_COMPONENT depth_component glReadPixels
\        depth_component ? abort

        \ gluUnProject
        cr f.s &viewportCoords gluPickMatrix
       .board_ogl                     \ rerender scene in selective mode
       GL_RENDER  glRenderMode cr .    \ #selected-items
       GL_PROJECTION glMatrixMode     \ projection matrix back to normal
     glPopMatrix                      \ Stop effecting the projection matrix
     GL_MODELVIEW glMatrixMode
      cr name-stack sel_min_depth w@ . name-stack sel_max_depth w@ .
     cr name-stack 65 dump     ;

\s


