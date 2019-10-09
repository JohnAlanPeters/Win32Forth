anew -opengl.f   \

: OldVersion?   ( version# - )
     61401 < abort" You need Win32Forth version 6.14.01 or better." ;

version# OldVersion?

((

To make openGL available for Win32Forth with a number of additional functions.
Not all functions are used in the NeHe lessons.


History so far:
October 2nd, 2000, changes:
- Solved the flickering screen in windows98 by using CreateDIBSection and BitBlt.
- OpenGl is executed in a separated window.
- Turn-key applications are possible.
- Added a study to see the impact when things are changed in a simple scene.

April 29th, 2001, Changes:
- Added an egg which changes while you are moving or rotating it.
- The light can be changed in the egg.
- The title in the window shows frames/second (Fps).
- Using a displaylist to speedup the bouncing ball.
- Added sounds on/off.
- Reorganized and extended the menus.
- Replaced load-array with GLfloat
- Added GLfloat!
- Changed the stack of most used OpenGL calls.
  Now they should act according the red book including the stackorder.
- Deleted some duplicate words.
- Using CreateWindowEx

June 2nd, 2001, Changes:
- Converted 3f' and 2f' to assembler.
- init-pfd uses limit-bpps.
  This increases speed of the 3D bouncing ball from 20 to 30 Fps.
  (on my P400 full screen no sound)
- Added a cube, 3dtriangle, full screen mode and glDeleteLists
- Made the title in the window easy to handle.
- Added a 3D projection of a mandelbrot using 32 bpps.
  It appears after 17,576,000 3D points are calculated.

July 5th, 2001, Changes:
- Replaced wglSetPixelFormat by SetPixelFormat
  Now the program also runs under Windows2000 and NT

August 23st, 2001, Changes:
- Moved glViewport to init-DIBsection
- Added 3 threads, multitasking and a number of events to make FPS constant.
  It works fine in W98. The timing is bad in W2k but not disturbing.
- Now you can:
      1.Zoom while a scene is rotating.
      2.Change FPS and rotation speed.
      3.Save your scene as a bitmap.
      4.Save a number of frames as several bitmaps and see them later.
        E.G. calculate a for of a few days different 3D mandelbrot projections
             which rotate and play them back later in a few minutes.
             Note: The speed will depend on FPS. ( and your PC )
- Added the Mandelbrot stone. This is a very weird object with an inner stone.
  It changes while it is rotating. It will open when you zoom into it.
- The bouncing ball-scene is able to rotate while it is bouncing.
- A better fullscreen.
- struct.f is able to handle memory structures in a better way.
  added OFFSET  ( saves calculations ) and
        >STRUCT ( saves runtime ).
- Rotating is changed. Try the bouncing ball and hit the <Z> then
  wait for 720 degrees.
- When <Esc> is pressed the interface will not abort anymore but will
  activate request-to-stop.

May 17th, 2008 Changes:
- Adapted the system for Win32Forth version 6.12 or better.
- Removed the toolset.
- Changed the color blue in the crude square universe.
- Menus can now be customized. See _Study.f for an example.
- Better factoring. Compile _AllScenes.f or _Study.f to get started.

April 26th, 2013 most important changes:
- Added the missing functions for the NeHe lessons.
- Changed gluCylinder so it follows the standard.
  The old one is still there under the name OldgluCylinder
- Changed gluPartialDisk so it follows the standard.
  The old one is still there under the name  OldgluPartialDisk
- Added switchToDC for a hardware-accelerated rendering context.
- Stablized dynamic scenes to +/- 60 FPS by using a waitable
- Added KeyboardAction so each scene can handle it's own keystrokes
- Added >screen for different pixelformats

May 6th, 2013
- Added: Functions for OpenGL extensions

December 3rd, 2015
- Added 3D turtle extensions.
- Changed the WaitableTimer into a class.
))

needs Resources.f
needs AcceleratorTables.f
needs struct.f          \ For the use of C-like structures.
needs Ext_classes\WaitableTimer.f \ A class for high resolution waitable timers.
needs AskIntWindow.f    \ To ask for a number in a window.
needs oglevts.f         \ Defines the threads and events
needs bmpdot.f          \ Header definitions for bmpio.f
needs palette.f         \ Defines a palette. Needed when 256 colors are used.
needs glext.h           \ Adding Opengl constants.
needs gldefs.f          \ More Opengl constants.

0 value ogl-hwnd
0 value hdc-pixmap

needs bmpio.f           \ Bitmap support
needs ReformatStrings.f \ To show a long string in short lines
needs w_search.f        \ Simple wilcard search

\ -------------------------------------------------------------------------------
\ Basic OpenGL binding for Win32Forth
\ -------------------------------------------------------------------------------

\ linking to the needed standard openGL  Dll's
 winlibrary opengl32.dll
 winlibrary glu32.dll

\ -------------------------------------------------------------------------------
\ code words to pass the floating numbers to data stack
\ -------------------------------------------------------------------------------

' FS>DS alias DF>STACK   ( -- double )  ( fs: r -- )
' SFS>DS alias  SF>STACK  ( -- float )  ( fs: r -- )

\ copy result of c function from the hw float stack
\ to the Win32Forth float stack
code FRESULT    ( x -- )  ( FS: -- r )
                mov     ecx, FLOATSP [up]
                fstp    FSIZE FLOATSTACK [ecx] [up]
                add     ecx, # B/FLOAT
                mov     FLOATSP [up], ecx
                pop     ebx
                next,
                end-code

B/FLOAT 8 <> [if] cr .( B/FLOAT needs to be 8.) abort  [then]
synonym fsqr   fsqrt


: val>+$,. ( str$ val -  )  s>d (ud,.) rot +place  ;

' sf>stack  alias f'

\ The order of the values are also reversed

code  2f'  ( f: f1 f0 - ) ( - 32bfloat0 32bfloat1 )
                mov     ecx, FSP_MEMORY
                sub     ecx, # B/FLOAT
                js      L$3
                fld     FSIZE FSTACK_MEMORY
                mov     FSP_MEMORY , ecx
                push    ebx
                push    ebx
                fstp    float 0 [esp]
                pop     ebx
L$2:            mov     ecx, FSP_MEMORY
                sub     ecx, # B/FLOAT
                js      L$3
                fld     FSIZE FSTACK_MEMORY
                mov     FSP_MEMORY , ecx
                push    ebx
                push    ebx
                fstp    float 0 [esp]
                fwait
                pop     ebx
                jmp     L$4
L$3:            mov     esi, # ' FSTKUFLO >body
                add     esi, edi
                pop     ebx
L$4:            next,
                end-code


code  3f'  ( f: f2 f1 f0 - ) ( - 32bfloat0 32bfloat1 32bfloat2 )
                mov     ecx, FSP_MEMORY
                sub     ecx, # B/FLOAT
                js      L$5
                fld     FSIZE FSTACK_MEMORY
                mov     FSP_MEMORY , ecx
                push    ebx
                push    ebx
                fstp    float 0 [esp]
                pop     ebx
L$2:            mov     ecx, FSP_MEMORY
                sub     ecx, # B/FLOAT
                js      L$5
                fld     FSIZE FSTACK_MEMORY
                mov     FSP_MEMORY , ecx
                push    ebx
                push    ebx
                fstp    float 0 [esp]
                pop     ebx
                sub     ecx, # B/FLOAT
                js      L$5
                fld     FSIZE FSTACK_MEMORY
                mov     FSP_MEMORY , ecx
                push    ebx
                push    ebx
                fstp    float 0 [esp]
                fwait
                pop     ebx
                jmp     L$6
L$5:            mov     esi, # ' FSTKUFLO >body
                add     esi, edi
                pop     ebx
L$6:            next,
                end-code


: 4f' ( f: f3 f2 f1 f0 - ) ( - 32bfloat0 32bfloat1 32bfloat2 32bfloat3 )
        s" 2f' 2f' " evaluate ; immediate

: nf' ( f: fx..f0 - )  ( k - 32bfloat0..32bfloatx  )
        0 do sf>stack loop ;

' FS>DS alias d'

: 2d' ( f: f1 f0 - ) ( - d0 d1 )
         s" df>stack df>stack                   " evaluate ; immediate

: 3d' ( f: f2 f1 f0 - ) ( - d0 d1 d2 )
         s" df>stack df>stack df>stack          " evaluate ; immediate

: 4d' ( f: f3 f2 f1 f0 - ) ( - d0 d1 d2 d3 )
         s" df>stack df>stack df>stack df>stack " evaluate ; immediate

: nd' ( f: fx..f0 - )  ( k - dt0..dx  )
        0 do df>stack loop ;

0 value hbitmap
0 value qobj
0 value oglwin-base

include pixelfrm.f  \ PIXELFORMATDESCRIPTOR

\ : swap_rot ( n1 n2 n3 - n3 n2 n1 )   swap rot  ;

' 3reverse alias swap_rot

\ -------------------------------------------------------------------------------
\ OpenGL functions.
\ -------------------------------------------------------------------------------

: wglCreateContext ( hdc - hdrc )                   call wglCreateContext       ;
: wglMakeCurrent   ( hdc hrc - flag )          swap call wglMakeCurrent         ;
: wglDeleteContext ( hrc - flag )                   call wglDeleteContext       ;
: glLineWidth      ( f: width - )                f' call glLineWidth       drop ;
: glFinish         ( - )                            call glFinish          drop ;
: SwapBuffers      ( hdc - )                        call SwapBuffers       drop ;
: glRotatef        ( f: deg x y z - )           4f' call glRotatef         drop ;
: glTranslatef     ( f: x y z  - )              3f' call glTranslatef      drop ;
: glTranslated     ( f: x y z - )               3d' call glTranslated      drop ;
: glScalef         ( f: x y z  - )              3f' call glScalef          drop ;
: glPushMatrix     ( - )                            call glPushMatrix      drop ;
: glPopMatrix      ( - )                            call glPopMatrix       drop ;
: glClear          ( mask - )                       call glClear           drop ;
: glClearDepth     ( F: depth - )                d' call glClearDepth      drop ;
: glDepthFunc      ( dunc - )                       call glDepthFunc       drop ;
: glDepthMask      ( flag - )                       call glDepthMask       drop ;
: glColorMask      ( red green blue alpha - ) 4reverse call glColorMask    drop ;
: glStencilFunc    ( func ref mask - )     3reverse call glStencilFunc     drop ;
: glStencilMask    ( mask - ) 			    call glStencilMask 	   drop ;
: glFrontFace      ( mode - )                       call glFrontFace       drop ;
: glStencilOp      ( fail zfail zpass - )  3reverse call glStencilOp       drop ;
: glClearStencil   ( s - )                          call glClearStencil    drop ;
: glCullFace       ( mode - )                       call glCullFace        drop ;
: glColor3f        ( f: red green blue - )      3f' call glColor3f         drop ;
: glColor3fv       ( AdrRGB - )                     call glColor3fv        drop ;
: glColor3ub       ( red green blue - )    3reverse call glColor3ub        drop ;
: glColor4f        ( f: red green blue alpha - ) 4f' call glColor4f        drop ;
: glColor4ub       ( f: red green blue alpha - ) 4reverse call glColor4ub  drop ;
: glMatrixMode     ( mode - )                       call glMatrixMode      drop ;
: glLoadIdentity   ( - )                            call glLoadIdentity    drop ;
: glBegin          ( mode - )                       call glBegin           drop ;
: glVertex2f       ( f: x y - )                 2f' call glVertex2f        drop ;
: glVertex2d       ( f: x y - )                 2d' call glVertex2d        drop ;
: glVertex2i       ( x y - )                   swap call glVertex2i        drop ;
: glVertex3f       ( f: x y z - )               3f' call glVertex3f        drop ;
: glrectf          ( f: x1 y1 x2 y2 - )         4f' call glRectf           drop ;
: glTexGeni        ( coord pname param - ) 3reverse call glTexGeni         drop ;
: glEnd            ( - )                            call glEnd             drop ;
: glEndList        ( - )                            call glEndList         drop ;
: glNewList        ( list mode - )             swap call glNewList         drop ;
: glListBase       ( base - )                       call glListBase        drop ;
: glGenLists       ( range - lists )                call glGenLists             ;
: glCallList       ( list - )                       call glCallList        drop ;
: glCallLists      ( n type lists - )      swap_rot call glCallLists       drop ;
: glDeleteLists    ( list range )              swap call glDeleteLists     drop ;
: glClipPlane      ( plane *equation - )       swap call glClipPlane       drop ;
: glGetString      ( name - string$ )               call glGetString            ;
: glPushAttrib     ( mask - )                       call glPushAttrib      drop ;
: glPopAttrib      ( - )                            call glPopAttrib       drop ;
: glRasterPos2f    ( f: x y - )                 2f' call glRasterPos2f     drop ;
: glScissor        ( x y width height - )  4reverse call glScissor         drop ;
: glFlush          ( - )                            call glFlush           drop ;
: glNormal3f       ( nx ny nz - )               3f' call glNormal3f        drop ;
: glEnable         ( cap - )                        call glEnable          drop ;
: glDisable        ( cap - )                        call glDisable         drop ;
: glViewport       ( x y width height - )  4reverse call glViewport        drop ;
: glGetFloatv      ( pname *params - )         swap call glGetFloatv       drop ;
: glShadeModel     ( mode - )                       call glShadeModel      drop ;
: glLightModelfv   ( pname param - )           swap call glLightModelfv    drop ;
: glLightfv        ( light pname param - ) swap_rot call glLightfv         drop ;
: glPolygonMode    ( face mode - )             swap call glPolygonMode     drop ;
: glColorMaterial  ( face mode - )             swap call glColorMaterial   drop ;
: glFogi           ( pname  parm - )           swap call glFogi            drop ;
: glFogf           ( f: parm )  ( pname - ) f' swap call glFogf            drop ;
: glFogfv          ( pname parm - )            swap call glFogfv           drop ;
: glHint           ( target mode - )           swap call glHint            drop ;
: glBlendFunc      ( sfactor dfactor - )       swap call glBlendFunc       drop ;
: glMaterialfv     ( face pname param - ) swap_rot  call glMaterialfv      drop ;
: gluNewQuadric    ( - qobj )                       call gluNewQuadric          ;
: gluQuadricDrawStyle ( qobj style - )       swap call gluQuadricDrawStyle drop ;
: gluQuadricTexture ( *quadObject textureCoords - ) swap call gluQuadricTexture drop ;
: gluQuadricNormals   ( qobj normals - )       swap call gluQuadricNormals drop ;
: gluBeginCurve       ( *nobj - )                   call gluBeginCurve     drop ;
: gluEndCurve         ( *nobj - )                   call gluEndCurve       drop ;
: gluNewNurbsRenderer ( - *nobj )                   call gluNewNurbsRenderer    ;
: glSelectBuffer      ( size buffer -- )       swap call glSelectBuffer    drop ;
: glRenderMode        ( mode -- 0|#sel|val )        call glRenderMode           ;
: glInitNames         ( -- )                        call glInitNames       drop ;
: glLoadName          ( name -- )                   call glLoadName        drop ;
: glPushName          ( name -- )                   call glPushName        drop ;
: glPopName           ( -- )                        call glPopName         drop ;
: glGetIntegerv       ( pname *params -- )     swap call glGetIntegerv     drop ;
: gluBuild2DMipmaps ( target components width height format type *data -- )
                                        7 s-reverse call gluBuild2DMipmaps drop ;
: gluPickMatrix  ( f: x y width height -- ) ( viewport -- )
                                                4d' call gluPickMatrix     drop ;
: glReadPixels   ( f: x y width height -- ) ( format type  *pixels -- )
                             3reverse 2>r >r 4f' r> 2r> call glReadPixels  drop ;
: glPixelStorei  ( pname param -- )                swap call glPixelStorei drop ;
: glDepthRange   ( f: near far -- )                 2d' call glDepthRange  drop ;
: gluDeleteQuadric ( qobj -- )                       call gluDeleteQuadric drop ;
: wglUseFontBitmaps   ( ghdc 1st_char #chars baselist -- )
                                           4reverse call wglUseFontBitmaps drop ;
: glBindTexture    ( target name -- )           swap call glBindTexture    drop ;
: glGenTextures    ( n *textures -- )           swap call glGenTextures    drop ;
: glDeleteTextures ( n *textures -- )           swap call glDeleteTextures drop ;
: glTexParameteri ( target pname param -- ) 3reverse call glTexParameteri  drop ;
: glTexImage2D ( target level components width height border format type *pixels -- )
                                            9 s-reverse call glTexImage2D  drop ;
: glTexCoord2f    ( f: x y - )                      2f' call glTexCoord2f  drop ;
: glTexEnvi       ( target pname param -- )        3reverse call glTexEnvi drop ;
: glTexEnvf ( target pname - ) ( f: param -- ) swap f' -rot call glTexEnvf drop ;

: glPixelTransferf ( pname - ) ( f: param - )
                                             f' swap call glPixelTransferf drop ;

: clear-buffer ( - )         GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR glClear ;

struct{ \ _GLYPHMETRICSFLOAT
    FLOAT       gmfBlackBoxX
    FLOAT       gmfBlackBoxY
    FLOAT       gmfptGlyphOriginX
    FLOAT       gmfptGlyphOriginY
    FLOAT       gmfCellIncX
    FLOAT       gmfCellIncY
}struct glyphmetricsfloat

0 value lpgmf_buffer

: wglUseFontOutlines { ghdc first count listBase format lpgmf } (  f:  deviation extrusion - )
     lpgmf format f' f' listBase count first ghdc
     call wglUseFontOutlines drop ;

: glType  ( addr count base - )
     glListBase GL_UNSIGNED_BYTE rot glCallLists  ;

: gluNurbsProperty ( *nobj property - ) ( f: value - )
      f' swap_rot call gluNurbsProperty drop ;

: glClearColor   ( f: GLclampf_red GLclampf_green GLclampf_blue GLclampf_alpha - )
     4f'   call glClearColor       drop ;

: glOrtho        ( f: left right bottom top near far - )
     6 nd' call glOrtho drop ;

: glFrustum      (  f: left right bottom top near far -- )
     6 nd' call glFrustum drop ;

: gluPerspective (  f: fovy aspect near far-- )
   4d' call gluPerspective drop ;

: OldgluCylinder    ( *qobj stacks slices  - ) ( f: height topRadius baseRadius - )
       >r swap 3d' r> call gluCylinder drop ;

: gluCylinder    { *qobj stacks slices  -- } ( f: height topRadius baseRadius - )
      stacks slices 3d'  *qobj call gluCylinder drop ;


: OldgluDisk    ( *qobj -   ) ( f: innerRadius outerRadius stacks loops - )
       >r  f>s f>s 2d'  r> call gluDisk drop ;

: gluDisk    { *qobj slices loops -- } ( f: innerRadius outerRadius  - )
        loops slices  2d' *qobj call gluDisk drop ;

: gluSphere ( *qobj slices stacks - ) ( f: radius - )
       3reverse >r d' r> call gluSphere drop ;

: OldgluPartialDisk    ( *qobj -   ) ( f: innerRadius outerRadius stacks loops startAngle sweepAngle - )
       >r 2d' f>s f>s 2d'  r> call gluPartialDisk drop ;

: gluPartialDisk    { *qobj slices loops -- } ( f: innerRadius  loops startAngle sweepAngle - )
       2d' loops slices 2d' *qobj call gluPartialDisk drop ;

: gluLookAt      ( f: eyex eyey eyez  centerx centery centerz upx upy upz -- )
      9 nd' call gluLookAt drop ;

\ ------  The following part is not tested  -------

: gluNurbsCurve ( *nobj nknots  *knot  stride *ctlarray order type - )
  swap_rot 3 roll 4 roll 5 roll 6 roll call gluNurbsCurve drop ;

1 CallBack: nurbsError  ( arg -- f )  ( return ) 1  ;

: gluNurbsCallback ( *nobj which nurbsError - errorcode )
       swap_rot call gluNurbsCallback ;

: .gluerror ( *nobj -  )   GLU_ERROR &nurbsError gluNurbsCallback . ;


\ ------- End untested part -------


: PROJECTION   GL_PROJECTION  glMatrixMode  ;
: MODELVIEW    GL_MODELVIEW   glMatrixMode  ;

synonym  lid        glLoadIdentity
synonym  push       glPushMatrix
synonym  pop        glPopMatrix
synonym  translatef glTranslatef
synonym  scalef     glScalef
synonym  Rotatef    glRotatef

\ -------------------------------------------------------------------------------
\ Setup
\ -------------------------------------------------------------------------------

: GetClientRect ( - w h )
   &InfoRect ogl-hwnd
   Call GetClientRect drop
   width @ height @
 ;

: GetWindowRect ( - x y )
   &InfoRect ogl-hwnd
   Call GetWindowRect drop
   window_x @ window_y @
 ;

0 value ghrc

: get-context  ( hdc-pixmap - )
   dup wglCreateContext
   dup 0= abort" wglCreateContext failed." dup to ghrc
   wglMakeCurrent   0= abort" Not current(2)
   gluNewQuadric to qobj
 ;

200 value widthViewport
100 value heightViewport
0 value xViewport
0 value yViewport
false value scaledDIB? \ BitBltMode
variable Stretchwidth  variable Stretchheight

: SetWhViewport
     GetClientRect scaledDIB?
        if  2drop Stretchwidth @ Stretchheight @
        then
   to heightViewport to widthViewport
 ;

: glin ( - )
   hdc-pixmap  get-context SetWhViewport
   xViewport yViewport widthViewport heightViewport
   glViewport  \ set viewport to cover the window
;


\ Fill bitmapinfo.pbmiColors with a 3-3-2 palette
pbmi pbmiColors 0 332palette
\ Is used when bits-per-pixel = 8

variable ppvbits
1 value hdc-old-obj


\ ----- GL exit & release DC contexts when valid
: release-context ( - )
    0 0 wglMakeCurrent ghrc wglDeleteContext 2drop 0 to ghrc
 ;

: glout ( - )
    ghrc 0 <>
       if   release-context
       then
     hbitmap 0 <>
       if   hbitmap  Call DeleteObject drop
            hdc-pixmap call DeleteDC drop 0 to hbitmap
       then
 ;

: init-DIBsection ( - )  \ For swaping buffers into a DIBsection
     glout init-pfd-Dibsection
     0  Call CreateCompatibleDC to hdc-pixmap        \ hdcMem
     sizeof BitmapInfoHeader >struct pbmi biSize !   \ 40
      scaledDIB?
      if    Stretchwidth @ Stretchheight @
      else  width @ height @
      then
                   >struct pbmi biHeight  !
                   >struct pbmi biWidth   !
     1             >struct pbmi biPlanes w!
\ 1 4 8 16 24 32 for bpps
\  When 8, a colortable filled with a 332palette is used.
     ghdc  max-bits-per-pixel ( - bpps )
     dup 8 < abort" Need to be able to use at least 256 colors."
     dup           >struct pbmi biBitCount     w!
                   >struct pfd  cColorBits     c!
     BI_RGB        >struct pbmi biCompression   !
     0             >struct pbmi biSizeImage     !
     0             >struct pbmi biXPelsPerMeter !
     0             >struct pbmi biYPelsPerMeter !
     0             >struct pbmi biClrUsed       !
     0             >struct pbmi biClrImportant  !

\ dwOffset hSection ppvBits         iUsage         lpbmih             hdc
  0         0       ppvbits DIB_RGB_COLORS pbmi hdc-pixmap
     call CreateDIBSection dup to hbitmap 0= abort" DIBSection failed"
     hbitmap hdc-pixmap Call SelectObject to hdc-old-obj
     call GdiFlush drop
     hdc-pixmap setuppixelformat
        if     glin
        else   true call ShowCursor drop
               pbmi biHeight @  ghdc ogl-hwnd call ReleaseDC drop
               true abort" Pixelformat failed "  cr
        then
 ;

: Init-Window ( - ) \ For swaping buffers to a window
   glout
   ghdc dup dup to hdc-pixmap
   init-pfd-Window
   SetupPixelFormat 0= abort" SetupPixelFormat failed"
   get-context SetWhViewport
 ;

defer InitOpenGL  \ Window or DIBsection

' Init-Window is InitOpenGL

synonym GLfloats cells \ in Win32Forth

also hidden definitions

synonym { fdepth


\ Map GLfloat : #floats, GLfloats

: };  \  compiletime: ( >GLfloat fdepth - )   ( f: ffdepth_x..ffdepth_0 -- )
  \in-system-ok previous
  here cell+ dup>r 0 , rot ! fdepth swap -
  dup r@ cell- !
  dup GLfloats allot
  r> swap 0 do dup sf!    cell+ loop drop
  ; immediate

only forth definitions forth

: also_hidden \in-system-ok also hidden ;

: GLfloat           \ compiletime: ( - >GLfloat ) runtime: ( - ABS-adr.first-GLfloat )
   create  here dup , also_hidden   \ map: pointer to k-floats
   does>  @ ; immediate

: GLfloat! ( a1 -- ) ( f: f1..f0 - ) \ The number of floats are in the cell before a1
    dup cell- @ 0
        do   dup sf! cell+
        loop
    drop ;

: dump-farray  ( a -- )  dup cell- @ 0 do dup sf@ f. cell+ loop drop ;

\ Use:
\ GLfloat front_emission  { 1e 2e 3e 4e };
\ 21e 22e 23e 24e  front_emission GLfloat!
\ front_emission dump-farray abort

GLfloat matshininess  { 0.0e 0.0e 0.0e   0.0e  };
GLfloat lmatspecular  { 1.0e 0.0e 0.0e   0.0e  };
GLfloat lmatambient   { 1.0e 1.0e 1.0e   1.0e  };
GLfloat lmatdiffuse   { 1.0e 1.0e 1.0e   1.0e  };
GLfloat lightPosition { 1.0e 0.0e 0.0e 400.0e  };
GLfloat lightDiffuse  { 1.0e 1.0e 1.0e   1.0e  };
GLfloat lightSpecular { 1.0e 0.0e 0.0e   0.0e  };
GLfloat model-ambient { 1.0e 0.3e 0.3e   0.3e0 };
GLfloat objectcolor   { 0.0e 1.0e 0.0e   0.0e  };
GLfloat fogcolor      { 0.0e 1.0e 0.0e   0.0e  };

GLfloat spotdirection { 1.0e 0.0e 0.0e };

: objectcolor!  ( f: ?? r g b -- )   objectcolor GLfloat! ;

.2e fvalue distance

defer painting

: no-painting ( - ) ['] abort is painting ;

no-painting

: f? ( adr - )  f@ f. ;
: f3dup ( f3 f2 f1  - f3 f2 f1 f3 f2 f1 )  2 fpick 2 fpick 2 fpick  ;

: 3fliteral ( f: f f f - )
\in-system-ok frot postpone fliteral fswap postpone fliteral postpone fliteral ; immediate

\ froll: Rotate k value on the floating point stack, bringing the deepest to
\ the top.
\ Note: zero is the first element and leaves the floating point stack unchanged

: froll         ( k -- ) ( f: fk fx..f0 -- fx..f0 fk )
   B/FLOAT * dup>r FLOATSTACK  FLOATSP @ + B/FLOAT - swap - dup>r f@
   r@ float+ r> r> cmove fswap fdrop  ;

: >f   ( adr - adrFloat) ( f: - f )  floats + ;
: >f@  ( adr which - )   ( f: - f )  floats + f@ ;
: >f!  ( adr which - )   ( f: f - )  floats + f! ;

b/float 2* offset 2floats+        ( addr1 -- addr2 )
\ : >3f! ( adr - ) ( f: fx fy fz  - )  dup 2floats+ f! dup float+ f! f! ;


\ adr = adres to fetch from      k = number of floats to fetch
: floats@ ( adr k - ) ( FS: - fk..f0  )
    0
      do    dup i >f@
      loop  drop  ;

: floats!  ( adr k - ) ( FS: fk..f0 - ) \ Does not reverse the floats in the array anymore \ *** juni 13 2014
   dup 1- swap 0
      do   2dup i - >f!
      loop 2drop ;

: fmove  ( &src &dest #floats - )
   floats cmove
 ;

defer fref3D ( - adr k )    \  when deferred
: is-fref3D  ( 'frefxD - )   is fref3D  ;

create   title$ MAXSTRING allot
create     fps$ MAXSTRING allot
create fparams$ MAXSTRING allot

0 value fl-fullscreen

: retitle-window ( hwnd - )  \ for use outside the object
    fl-fullscreen
      if   drop
      else title$ 1+ swap call SetWindowText ?win-error
      then
     ;

: +value$>fparams$ \ f: ( n -  )
   fdup fabs 1000000e f>
        if  s" ..."
            else   fdup fabs 1000e f>
                if    7
                else  4
                then  sigdigits !
            pad (f.) s" e " pad
            +place pad count
        then
   fparams$ +place ;

0 value #frames
0 value title$changed
0 value static-scene

string: titleStart$ s" 4th "   title$    place
string: FpsStart$   s" Fps:  " FpsStart$ place

: 4th>title     ( - )           titleStart$ count title$ place ;
: +title        ( adr count - ) title$ +place  ;
: spaces>title  ( n - )         0  do   s"  " +title  loop ;
: fps>title     ( - )           fps$ count +title ;
: fparams>title ( - )           fparams$ count +title ;

: +fps ( - )
  FpsStart$ count fps$ place  #frames  0 (d.) fps$  +place s"   " fps$ +place
 ;

: save-fps$     ( - )
  static-scene
     if    0 fps$ !
     else  +fps
     then
 ;

: save-fref3D-calc  ( adr k - ) ( f: fk..f0 - fk..f0 - )
  drop fref3D drop =
   if 0 fparams$ !
      sigdigits @  fref3D dup 1- -rot 7 min 0
           do    over i - fpick +value$>fparams$
           loop  14 spaces>title
      true to title$changed
      rot sigdigits ! 2drop
   then
;

: floatsf@+ ( adr k - ) ( f: fk..f0 - fk+floatsk..f0+floats0 )
    dup  0
      do  over  i >f@   dup  froll f+
      loop save-fref3D-calc  ;

: floatsf@* ( adr k - ) ( f: fk..f0 - fk*floatsk..f0*floats0 )
   dup  0
      do   over i >f@   dup  froll f*
      loop save-fref3D-calc  ;

: fref:           \ compiletime: ( k - ) runtime: ( - adr.first-float k )
   create dup , floats allot  \ map: Cell k-floats
   does>  dup cell+ swap @ ; immediate

\ example of this consept:
3 fref: fref3A   \ make reference to a floating point array with 3 floats
' fref3A   is-fref3D  \ activate it when needed

\ fref3A  returns the adres of the first float and
\         the number of its floats in runtime.

\ : test    ( f: -- 33e 22e 11e )
\   3e 2e 1e     fref3A floats!   \ fill fref3A with 3e  2e  1e
\   30e 20e 10e  fref3A floatsf@+ \         add     30e 20e 10e
\   f.s                           \              so 33e 22e 11e will be on the
\ ;                               \              floating point stack

\ fref3A  floats@ abort \ puts all the floats from fref3A on the floating point stack

\ The name fref3upF constructed is as follows:
\ fref  Means it was made by fref3A
\    3  Means it uses 3 floats
\   up  Just a name to remind me to its function
\    F  Means the letter F is used in the keystroke interpreter change-scene

 3 fref: fref3upF
 3 fref: fref3CenterC
 3 fref: fref3eyeE
 4 fref: fref4PersP
 4 fref: fref4LambientN
 4 fref: fref4DiffuseV
 3 fref: fref3TransT
 3 fref: fref3TransI
 3 fref: fref3LpositionL
 4 fref: fref4RotR
 4 fref: fref4RotD
 4 fref: fref4RotG
 4 fref: fref4RotX
 3 fref: fref3SizeH
 3 fref: fref3ScaleS

' fref3CenterC is-fref3D

: fm+ ( adr-floats-to-add addr-floats-result - )
  dup>r rot = 0= abort" The number of floats not equal."
  swap r@ floats@ dup r@ floatsf@+ r> floats!
 ;

: mut:           \ compiletime: ( k - ) runtime: ( - adr.first-float k )
   create  0 , dup , 2* floats allot  \ map: how count k2*-floats
   does>  cell+ dup cell+ swap @ ; immediate

fref4PersP  nip mut: Mut4PersP \ map: how cnt fmut fmut fmut fmut fmex fmex fmex fmex
fref4RotR   nip mut: Mut4RotR  \ map: how cnt fmut fmut fmut      fmex fmex fmex
fref4RotX   nip mut: Mut4RotX
fref3TransT nip mut: Mut3TransT

((
: test    ( f: -- 33e 22e 11e )
    4e 3e   2e  1e  fref4PersP floats! \ fill fref4PersP with  4e  3e  2e  1e
  400e 30e 20e 10e  Mut4PersP  floats! \ fill Mut4PersP with 400e 30e 20e 10e
  Mut4PersP fref4PersP fm+             \ add Mut4PersP to fref4PersP
  fref4PersP floats@ f.s               \ fetch and see them
 ; test abort ))


: #floats+ ( adr kmax k - adr.float)
    dup>r <= abort" Floating point reference out of range."   r> floats + ;

\ return the adres and float
: addr#floats+@  (  adr kmax k - adr ) ( F: - fk )     #floats+ dup f@ ;

1.0e fvalue rdistance
0 value FirstTime

: reset-opengl  ( - ) release-context  glin  ;
: display-it    ( - ) reset-opengl ( winpause ) painting ;

: fref3D-fref4D-x ( - adr fref n ) fref3D dup 4 = abs ;
: fref3D-fref4D-y ( - adr fref n ) fref3D dup 3 = abs ;

:  zx ( - adr-flookat ) ( F: - f ) fref3D-fref4D-x addr#floats+@ distance  f+ ;
: -zx ( - adr-flookat ) ( F: - f ) fref3D-fref4D-x addr#floats+@ distance  f- ;
:  zy ( - adr-flookat ) ( F: - f ) fref3D-fref4D-y addr#floats+@ distance  f+ ;
: -zy ( - adr-flookat ) ( F: - f ) fref3D-fref4D-y addr#floats+@ distance  f- ;

:  zz ( - adr-flookat ) ( F: - f ) fref3D 2 addr#floats+@ distance  f+ ;
: -zz ( - adr-flookat ) ( F: - f ) fref3D 2 addr#floats+@ distance  f- ;

:  zr  ( - adr-flookat flag ) ( F: zoom - )
     fref3D 3 2dup <=
       if     2drop false
       else   addr#floats+@  rdistance  f+ true
       then
 ;

: -zr  ( - adr-flookat flag ) ( F: zoom - )
       fref3D 3 2dup <=
        if    2drop  false
        else  addr#floats+@  rdistance  f- true
        then
 ;

33  constant VK_PGUP
34  constant VK_PGDN
46  constant VK_DEL
112 constant VK_F1
190 constant VK_.
188 constant VK_,

189 constant VK_-
187 constant VK_=

' fref3TransT is-fref3D

: 0floats!   ( adr k - )
    0  do 0e  dup i >f!
       loop drop ;

: clear-all-offsets      ( - )
   fref4RotG       0floats!   fref3eyeE     0floats!
   fref4DiffuseV   0floats!   fref3upF      0floats!
   fref3CenterC    0floats!   fref4RotR     0floats!
   fref3TransI     0floats!   fref3SizeH    0floats!
   fref4PersP      0floats!   fref3ScaleS   0floats!
   fref3LpositionL 0floats!   fref3TransT   0floats!
   fref4RotX       0floats!   fref4RotD     0floats!
   fref4LambientN  0floats!
   0e here f!
 ;

: fto-distance ( f: f - )   fto distance ;

: reset-active-function ( - )    fref3D 0floats! 0e here f! ;

0e fvalue _eyeD    3 fref: fref3r-dir

: f/0    ( f: f1 f2 -- f1/f2 ) \ Note: nan and infinity will be 0
   f/ fexam 256 and
      if   fdrop 0e
      then  ;

0 value resizing?
true value key-ready?
0 value request-to-stop    \ true = freeze a changing scene
rdistance -1e 2e 1e  Mut4RotR floats!

: dist_f*_fref3r-dir ( - fref3r-dir )  ( f: f - f*dist )
   distance f* fref3r-dir drop  ;

: frot_eyeD  ( f: f1 f2 f3 - f2 f3 f1 _eyeD )   frot _eyeD ;
: frad       ( fs: deg - rad )           fpi f* 180 s>f f/ ;
: roll-fref4RotR ( - ) 1 +to #turns Mut4RotR fref4RotR fm+ ;
: rotate-dynamic-scene  ( - )               roll-fref4RotR ;
: Reset-request-to-stop ( - )     false to request-to-stop ;

unload-chain chain-add Reset-request-to-stop

: rotate-static-scene  ( - )
   static-scene
      if  NestingDisplay? if exit then
          true to NestingDisplay?
          begin   roll-fref4RotR display-it
                  true  to key-ready? request-to-stop not
          while   wait/restart-timer-slow-action
          repeat  Reset-request-to-stop
           false to NestingDisplay?
      then
    ;

defer start/end-fullscreen

: fullscreen-to-window  ( - )
    fl-fullscreen
      if   start/end-fullscreen
      then
 ;

: stop-request ( - )
    h_ev_slow-action event-reset true to request-to-stop 20 ms ;

: stop_get_params  ( - )
    stop-request winpause title$ count type cr -1 to #turns abort ;

: leave-on-stop ( - )
    s" request-to-stop  if leave then "  evaluate ; immediate

: exit-on-stop  ( - )
    s" request-to-stop  if Reset-request-to-stop exit then "  evaluate ; immediate


: incr_interval    ( - )    distance 1.5e f* fto-distance  ;
: decr_interval    ( - )    distance 1.5e f/ fto-distance  ;

: start/stop-slow-action   ( - )
   -1 to #turns
    h_ev_slow-action dup event-set?
        if    static-scene
               if    drop  stop-request
               else  event-reset
               then  false to slow-action?
        else   Reset-request-to-stop
               event-set static-scene
               if   rotate-static-scene
               then
        then
 ;


: .change-scene  ( adr-flookat - ) ( f: n - )  f! painting ;

defer KeyboardAction

: (change-scene   ( VK_key - )  \ Does not work in the NeHe lessons
    case                                                 \ movements:
     VK_RIGHT   of  zx .change-scene              endof  \ right
     VK_LEFT    of -zx .change-scene              endof  \ left
     VK_UP      of  zy .change-scene              endof  \ up
     VK_DOWN    of -zy .change-scene              endof  \ down
     VK_PGUP    of -zz .change-scene              endof  \ zoom-
     VK_PGDN    of  zz .change-scene endof \ zoom. Forwards is DOWN on the negative z-axis!  117
     VK_HOME    of reset-active-function painting endof  \ use defaults
     VK_.       of -zr  if  .change-scene  then   endof  \ rotate-
     VK_,       of  zr  if  .change-scene  then   endof  \ rotate
     VK_DEL     of  clear-all-offsets painting    endof
     VK_-       of  decr_interval                 endof  \ decr
     VK_=       of  incr_interval                 endof  \ incr
     VK_F1      of  fl-fullscreen
                        if   fullscreen-to-window
                        else beep
                        then
                                                  endof
     upc \ Uppercase characters only

\     ascii A    of ['] fref3TransT is-fref3D
\                   fref4RotD fref3TransT move_forward  endof  \ move forwards reserved
\     ascii B    of ['] fref3TransT is-fref3D
\             fref4RotD fref3TransT move_backward endof \ move backwards reserved

     ascii C    of ['] fref3CenterC    is-fref3D  endof \ center-offset of the eye
     ascii D    of ['] fref4RotD       is-fref3D  endof \ direction of the eye
     ascii E    of ['] fref3eyeE       is-fref3D  endof \ viewpoint of the eye
     ascii F    of ['] fref3upF        is-fref3D  endof \ up-offset of the eye
     ascii G    of ['] fref4RotG       is-fref3D  endof \ rotate cylinder
     ascii H    of ['] fref3SizeH      is-fref3D  endof \ size of the outlined cube
     ascii I    of ['] fref3TransI     is-fref3D  endof \ move cylinder
     ascii L    of ['] fref3LpositionL is-fref3D  endof \ move light
     ascii N    of ['] fref4LambientN  is-fref3D  endof \ ambient
     ascii P    of ['] fref4PersP      is-fref3D  endof \ perspective
     ascii R    of ['] fref4RotR       is-fref3D  endof \ rotate all objects
     ascii T    of ['] fref3TransT     is-fref3D  endof \ move a scene
     ascii S    of ['] fref3ScaleS     is-fref3D  endof \ the scale
     ascii V    of ['] fref4DiffuseV   is-fref3D  endof \ diffuse
     ascii X    of ['] fref4RotX       is-fref3D  endof \ rotate around the center
     ascii W    of start/end-fullscreen           endof
     ascii Z    of start/stop-slow-action         endof
    endcase
  ;

' (change-scene is KeyboardAction \ For the default keys

: .text-line  ( str$ count  - )
      swap 0 0  ghdc call TextOut drop  ;
false value ignore_esc

0 value LastKeyIn

: GetLastKey ( VK_Key - )
    to LastKeyIn key? if key drop then  \ Store the key to process it later
 ;

: ProcesKeyAndRelease ( - )
    LastKeyIn
      if    LastKeyIn KeyboardAction 0 to LastKeyIn
      then
 ;

: lowerc ( upc - lowc )
   1 temp$ c!   temp$ 1+ dup>r c! temp$ count lower r> c@
 ;


: showing-bitmap(s)?  ( - flag )
  ['] _load-bitmap ['] painting >body @  =  ;

: key-event ( VK_key - )  \ From the window
    dup K_ESC =
      if    ignore_esc
              if   exit
              else true dup to static-scene to key-ready? stop_get_params
              then
      else  showing-bitmap(s)?
            if  fl-fullscreen
                if    s" Key stroke can not be used. Press F1 " .text-line
                else  s" Key stroke can not be used."
                      s" Choose a scene to activate it." infobox
                then  drop exit
            else
            key-ready?    \ prevents nesting of a key-event
              if   false to key-ready?
                ?shift not
                    if lowerc
                then
                   KeyboardAction
                   true to key-ready?
              else drop
              then
           then
      then KeyBufferEmpty: cmd
 ;

\ -------------------------------------------------------------------------------
\ buffer management
\ -------------------------------------------------------------------------------

\ clear the drawing buffer

: WIPE GL_COLOR_BUFFER_BIT  GL_DEPTH_BUFFER_BIT OR  glClear ;

: DIB>screen   ( - )
   \ hdc-pixmap SwapBuffers    \ Not needed rendering is directly done into the DIBsection
    glFinish SRCCOPY scaledDIB?
      if    Stretchheight @  Stretchwidth @  0 0 hdc-pixmap height @ width @  0 0 ghdc call StretchBlt
      else  0 0 hdc-pixmap height @ width @  0 0 ghdc call BitBlt
      then
     drop
 ;

: DC>screen   ( - )  \ Renderes the DC directly to a window.
  hdc-pixmap SwapBuffers
 ;


defer >screen \ Use a DIBsection or a DC only or another pixelformat.

: StableBuffer>Screen ( - )
   1 +to #frames >screen
 ;

' StableBuffer>Screen is show-buffer
100 value Old%rate

defer MenuScaleDibsection ( false/true - )

: switchToDib ( - )
  true MenuScaleDibsection
  Old%rate 100 < to scaledDIB?  \ <> 100%
  ['] DIB>screen is >screen
  ['] init-DIBsection is InitOpenGL
  InitOpenGL
 ;

: switchToDC ( - )
  false MenuScaleDibsection
  false to scaledDIB?
  ['] Init-Window is InitOpenGL
  ['] DC>screen is >screen
  InitOpenGL
 ;

  false to scaledDIB?
  ' Init-Window is InitOpenGL
  ' DC>screen is >screen

: ScaleSize ( n - scaled ) ( f: ScaleRate - ScaleRate ) s>f fover f* f>s 5 max ;

: ScaleDib ( f: Rate - )
   glout width @ ScaleSize height @ ScaleSize 2dup Stretchheight ! Stretchwidth !
   to heightViewport to widthViewport
   true  to scaledDIB? fdrop
   InitOpenGL glin
 ;

: show-and-save-buffers ( - ) \ init-save$ #frames-done and #frames-to-do must be set
   >screen                            \ get an image from OpenGL and put it on screen
   init-save$ count  save$ place    \ reset file-name
    1 +to #frames-done
    #frames-done  0 <# # # # # #> save$ +place save$ +bmp  \ add a number to the name
    #frames-done  #frames-to-do >
       if  ['] >screen is show-buffer                         \ stop saving when done
            -1 to #turns
            s" Ready:" s" All frames have been saved." infobox
       else hdc-pixmap _limit-bpps save-to-bitmap                    \ save one frame
       then
 ;

NewEditDialog MaxFrames "Maximum frames" "Number of frames to do:" "Ok"   ""  ""

: max-frames? ( - #frames-to-do )
    #frames-to-do$ dup s" 10" rot place oglwin-base Start: MaxFrames not
       abort" Stop. No frames will be saved."
    #frames-to-do$ count number? not
       abort" Bad number  No frames will be saved." d>s abs
 ;

: save#frames
   ogl-hwnd Start: SaveBitmap dup c@ 0 = abort" Bad name. No savings will be made"
   count init-save$ place    init-save$ extension>
   max-frames? to #frames-to-do 0 to #frames-done
   ['] show-and-save-buffers is show-buffer
 ;

defer PrepareNextFrame
' noop is PrepareNextFrame

\ show-frame and prevent an overflow of the keybuffer
: show-frame  ( - )
   show-buffer
   ns-time-out-done StartTimer: RefreshTimer
   key?
     if  key drop
     then
   PrepareNextFrame \ winpause
   Wait: RefreshTimer
 ;

' show-frame alias ';

0 fps$ !

: .changed-fps>title ( - )
   title$changed    \ can be changed in time or by a key-event
      if  4th>title fps>title fparams>title ogl-hwnd retitle-window
          false  to title$changed
      then
 ;

: (.fps  ( - )
   static-scene
     if  exit
     then
   save-fps$ 0 to #frames
   4th>title fps>title fparams>title true to title$changed .changed-fps>title
 ;

' (.fps is .fps

\ -------------------------------------------------------------------------------
\ OpenGL drawing commands...
\ -------------------------------------------------------------------------------

\ draw a line in 3d space
\ like this : x1 y1 z1 x0 y0 z0 line3f
: LINE3f    ( fs:  x1 y1 z1 x0 y0 z0 - )
        GL_LINES glBegin
                3f' call glVertex3f drop
                3f' call glVertex3f drop
        glEnd
;

\ like this : x1 y1 z1 x0 y0 z0 line3d
\ glVertex3d(double x, double y, double z)
: LINE3d      ( fs:  x1 y1 z1 x0 y0 z0 - )
        GL_LINES glBegin drop
                3d' call glVertex3d drop
                3d' call glVertex3d drop
        glEnd drop
;

\ -------------------------------------------------------------------------------
\ OpenGL color words
\ -------------------------------------------------------------------------------

\ colors using color3f
\ here order ends up 1 0 0
: GLRED  0.0e0 f' 0.0e0 f' 1.0e0 f' call glColor3f drop ;
: GLRED3 1.0e0 0.0e0 0.0e0 3f'      call glColor3f drop ;

: GLGREEN 0.0e0 f' 1.0e0 f' 0.0e0 f' call glColor3f drop ;
: GLBLUE  1.0e0 f' 0.0e0 f' 0.0e0 f' call glColor3f drop ;

: GLPURPLE  1.0e0 f' 0.0e0 f' 1.0e0 f' call glColor3f drop ;
: GLYELLOW  0.0e0 f' 1.0e0 f' 1.0e0 f' call glColor3f drop ;
: GLMAGENTA 1.0e0 f' 1.0e0 f' 0.0e0 f' call glColor3f drop ;

\ colors using shading and lighting
GLfloat lred     { 1.0e0 0.0e0 0.0e0 1.0e0  };
GLfloat lblue    { 1.0e0 1.0e0 0.0e0 0.0e0  };
GLfloat lgreen   { 1.0e0 0.0e0 1.0e0 0.0e0  };
GLfloat lpurple  { 1.0e0 1.0e0 0.0e0 1.0e0  };
GLfloat lyellow  { 1.0e0 0.0e0 1.0e0 1.0e0  };
GLfloat lmagenta { 1.0e0 1.0e0 1.0e0 0.0e0  };
GLfloat lwhite   { 1.0e0 1.0e0 1.0e0 1.0e0  };

\ -------------------------------------------------------------------------------
\ OpenGL lighting words
\ -------------------------------------------------------------------------------

    \ setup quadric stuff
: init-lighting
   GL_FRONT  GL_AMBIENT   lmatambient   glMaterialfv
   GL_FRONT  GL_SPECULAR  lmatspecular  glMaterialfv
   GL_FRONT  GL_SHININESS matshininess  glMaterialfv
   GL_LIGHT0 GL_POSITION  lightPosition glLightfv
   GL_LIGHT_MODEL_AMBIENT model-ambient glLightModelfv
 ;

\ begin a quadric object
: [QUAD
    GL_LIGHTING  glEnable
    GL_LIGHT0    glEnable
    GL_FRONT   GL_DIFFUSE objectcolor glMaterialfv
    GL_FRONT   GL_AMBIENT objectcolor glMaterialfv
    qobj  GLU_FILL   gluQuadricDrawStyle
    qobj  GLU_SMOOTH gluQuadricNormals
 ;

\ finish a quadric object
: QUAD]
    GL_FRONT GL_DIFFUSE lmatdiffuse glMaterialfv
    GL_FRONT GL_AMBIENT lmatambient glMaterialfv
    GL_LIGHTING  glDisable
    GL_LIGHT0    glDisable
 ;

: sphere ( stacks slices - ) ( f: wide - )
        [quad
       d' qobj call gluSphere drop
        quad]
 ;

: glPushMatrix_glTranslatef ( f: xt yt zt -- )  glPushMatrix glTranslatef ;

: [quad_object              ( -- )           [quad  glBegin ; \ glPushMatrix first
: object]                   ( -- )           glEnd quad] glPopMatrix ;

: [object  ( fill -- )   ( f: xt yt zt -- )
    glPushMatrix_glTranslatef  [quad_object ;

: [scaled-object   ( fill -- )   ( f:  xs ys zs  xt yt zt -- )
    glPushMatrix_glTranslatef glscalef [quad_object  ;

: [rot-scaled-object  ( fill -- )   ( f: deg xg yg zg   xs ys zs   xt yt zt -- )
    glPushMatrix_glTranslatef  glscalef glRotatef [quad_object  ;

: [rot-scaled-object-inline  ( fill -- )   ( f: deg xg yg zg   xs ys zs   xt yt zt -- )
    glTranslatef  glscalef glRotatef  [quad_object ;

: [rot-object  ( fill -- )   ( f: deg xg yg zg    xt yt zt -- )
    glPushMatrix_glTranslatef glRotatef [quad_object  ;


: cylinder ( stacks slices basef topf heightf - )
        [quad
          3f' qobj call gluCylinder drop
        quad]
;

\ -------------------------------------------------------------------------------
\ Array Index Functions for textures
\ -------------------------------------------------------------------------------

0 value NumTextures                    \ Total number of all textures
0 value Texture[]             \ The adres of all allocated texture(s)

: FreeTextures ( - )                   \ Free the memory of the array
    Texture[] 0<>            \ to the indexed textures when allocated
      if  Texture[] free 0 to Texture[]
      then
 ;

unload-chain chain-add FreeTextures
0 value Texture#

: MallocTextures ( NumTextures - )         \ Initialize the number of
   dup to NumTextures                                  \ new textures
   NumTextures over <
      if  FreeTextures       \ when more is needed free the old onces
      then                        \ before allocating the new Texture
   Texture[] 0=                    \ Allocate also when Texture[] = 0
       if    cells malloc to Texture[]                     \ Allocate
       else  drop                                 \ Already allocated
       then
   0 to Texture#
 ;

: Create-Textures ( NumTextures - )
   dup MallocTextures texture[] glGenTextures
 ;

: texture-ndx ( ndx -- *texture[n] ) \ Returns the adres of the texture
    cells Texture[] + ;                 \ depending on the value of ndx

\ -------------------------------------------------------------------------------
\ LoadGLTextures
\ -------------------------------------------------------------------------------
\ Functions to load in bitmap as a GL texture

: Generate-Texture { *src -- }
  GL_TEXTURE_2D 0 3
  *src >biWidth  @                           \ width of texture image
  *src >biHeight @                          \ height of texture image
  0 GL_BGR                                \ pixel mapping orientation
  GL_UNSIGNED_BYTE
  *src >color-array                         \ address of texture data
  glTexImage2D                                  \ finally generate it
 ;

: Generate-MipMapped-Texture { *src -- }
  GL_TEXTURE_2D 3
  *src >biWidth  @                           \ width of texture image
  *src >biHeight @                          \ height of texture image
  GL_BGR                                  \ pixel mapping orientation
  GL_UNSIGNED_BYTE
  *src >color-array                         \ address of texture data
  gluBuild2DMipmaps                             \ finally generate it
;

: LinearFiltering ( - )
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
 ;

: NearestFiltering ( - )
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
 ;

: MipMappedFiltering ( - )
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR_MIPMAP_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
 ;

: BindTexture-ndx ( ndx - )
   GL_TEXTURE_2D swap texture-ndx @ glBindTexture
 ;

: Bind2DTexture ( name - ) GL_TEXTURE_2D swap glBindTexture ;

: _LoadGLTexture ( name$ cnt ndx map-handle - ) \ with linear filtering do NOT unmap yet
    locals| map-hndle ndx |                \ Use MallocTextures before LoadGLTexture !!
  \ map-bitmap will abort and show a message when it does not succeed
    map-hndle _map-bitmap         \ map-bitmap retuns the adres of the BitmapFileHeader
  \ Load the image to a texture.
    ndx  BindTexture-ndx                                                  \ texture[ndx]
    Generate-Texture                                                  \ Generate texture
    LinearFiltering    						 \ with linear filtering
 ;

: LoadGLTexture  ( name$ cnt ndx map-handle - ) \
    dup>r _LoadGLTexture                                         \ With linear filtering
    r>    _un-map-bitmap                                              \ And UNMAP it now
 ;

: LoadTexture  ( name$ cnt - name )  			       \ Without specifing an index
    Texture# ahndl
    LoadGLTexture						    \ with linear filtering
    Texture# texture-ndx @                                                \ Return the name
    1 +to Texture#                                         \ incr the position in the index
 ;

: DeleteTextures  ( -- )
    NumTextures Texture[] glDeleteTextures                  \ clean up textures in OpenGL
    0 to Texture#
 ;

\ -------------------------------------------------------------------------------
\ Functions for gl-extensions
\ -------------------------------------------------------------------------------

: Getextension ( -- adr cnt )                   GL_EXTENSIONS glGetString zcount ;
: supported?   ( extensionname count -- flag )  Getextension false *search nip nip ;
: .extensions  ( -- )                           Getextension ListWords ;

variable lastflag

: name, ( - )  here last @ count dup 1+ allot rot place ;

: GLExtension: \  CompileTime: ( -- <name-extension> )
  create here >r lastflag @ , r> lastflag ! name, \ Map: lastflag extension-upper-cased$
 ;

variable lastext

vocabulary GLFunctions \ To avoid duplicate names in the same vocabulary

: +GLFunctions ( -- )  \ Also search in the vocabulary GLFunctions
   \in-system-ok current @ also GLFunctions current !
 ;

: -GLFunctions ( -- )  \ Restore the previous used context and current
   \in-system-ok current @  previous  current !
 ;

: SaveFunctionName ( -- )
    \in-system-ok also GLFunctions definitions bl nextword
       if    count 2dup temp$ place          \ Save the function as a case sensitive string
       else  ." Need a function name."
       then
 ;
: InitFunction  ( -- )
    0 ,                                      \ address of proc pointer
    here lastext @ , lastext !               \ address of a previous extension
    here temp$  count dup 1+ allot rot place \ Add the name of the function
    previous
 ;

: GLFunction: \ CompileTime: (  -- <name> )  \ Map: ProcPointer lastext FunctionName ( case sensitive )
   current @ >r SaveFunctionName             \ Save it in temp$
\in-system-ok  "header dovar compile,        \ Create a header from the input stream in uppercase
   InitFunction r> current !
   does>  @ call-proc    \ Runtime: Executes the function. the stack depends on the used function
 ;

: VoidGLFunction: \ CompileTime: (  -- <name> ) \ Map: ProcPointer lastext FunctionName ( case sensitive )
   current @ >r  SaveFunctionName               \ Save it in temp$
\in-system-ok   "header dovar compile,          \ Create a header from the input stream in uppercase
   InitFunction  r> current !
   does>  @ call-proc drop  \ Runtime: Executes the function. the stack depends on the used function
 ;                          \ One returned item will be dropped from the stack

: >extname            ( cfa - adr cnt )              2 cells+ count ;
: lastflag>extname    ( lastflag -- >extname count ) cell+ count ;

: >procname           ( cfa - adr cnt )              3 cells+ count ;
: >(procaddr)         ( cfa - adr )                  cell+ @ ;
: lastExt>procname    ( lastExt -- AddrSupported? )  cell+ count ;
: lastflag>procaddr   ( lastflag -- Adrprocaddr )    cell- ;

: get-proc-address ( procname count - addr ) \ NOTE: Only works AFTER a valid context
   asciiz call wglGetProcAddress             \ in which init-pfd-Window is used in the pixelformat
 ;

: gl-extensions-supported? ( -- f ) \ True when all defined extensions are
  true lastflag @                   \ available
     begin   dup
     while   dup  lastflag>extname supported? \ Check with OpenGL
             rot and swap @
     repeat  drop
 ;

: load-gl-extensions ( -- )
  lastext @
     begin   dup
     while   dup  lastExt>procname get-proc-address
             over lastflag>procaddr ! @
     repeat drop
  ;

: verify-gl-extensions ( -- )
   lastflag @
      begin  ?dup
      while  dup lastflag>extname supported? 0=
                if   cr dup lastflag>extname type s"  not supported" type
                then  @
       repeat
    lastext @
      begin  ?dup
      while  dup lastExt>procname get-proc-address 0=
                if  cr dup lastExt>procname type s"  function not found" type
                then  @
      repeat
  ;

\ -------------------------------------------------------------------------------
\ handy set of 3D axes
\ -------------------------------------------------------------------------------

FVARIABLE DIM           \ DIM is 1\2 the total axis length
: DIM! DIM F! ;
: DIM? DIM F@ ;


\ draw a set of axes in current frame, set DIM to desired scale
\ useful for testing rotations and translations in new routines

\ using line3f
: f-AXES ( - )
( z ) glblue  0.0e0 0.0e0 DIM? -2.0e0 f*  0.0e0 0.0e0 DIM? 2.0e0 f* line3f
( y ) glgreen 0.0e0 DIM? -2.0e0 f* 0.0e0 0.0e0 DIM? 2.0e0 f* 0.0e0 line3f
( x ) glred   DIM? -2.0e0 f* 0.0e0 0.0e0 DIM? 2.0e0 f* 0.0e0 0.0e0 line3f
;

\ using line3d
: d-AXES ( - )
( z ) glblue     0.0e0 0.0e0 DIM? -2.0e0 f*  0.0e0 0.0e0 DIM? 2.0e0 f* line3d
( y ) glgreen     0.0e0 DIM? -2.0e0 f* 0.0e0 0.0e0 DIM? 2.0e0 f* 0.0e0 line3d
( x ) glred       DIM? -2.0e0 f* 0.0e0 0.0e0 DIM? 2.0e0 f* 0.0e0 0.0e0 line3d
;

: _.opengl_error ( error - )
  case
        GL_NO_ERROR             of       endof
        GL_INVALID_ENUM         of ." GL_INVALID_ENUM "      endof
        GL_INVALID_VALUE        of ." GL_INVALID_VALUE "     endof
        GL_INVALID_OPERATION    of ." GL_INVALID_OPERATION " endof
        GL_STACK_OVERFLOW       of ." GL_STACK_OVERFLOW "    endof
        GL_STACK_UNDERFLOW      of ." GL_STACK_UNDERFLOW "   endof
        GL_OUT_OF_MEMORY        of ." GL_OUT_OF_MEMORY "     endof
        abort" Unknown OpenGL error "
     endcase
 ;

defer .opengl_error
' _.opengl_error is .opengl_error

#define GLUT_RGB                        0
#define GLUT_RGBA                       GLUT_RGB
#define GLUT_INDEX                      1
#define GLUT_SINGLE                     0
#define GLUT_DOUBLE                     2
#define GLUT_ACCUM                      4
#define GLUT_ALPHA                      8
#define GLUT_DEPTH                      16
#define GLUT_STENCIL                    32
#define GLUT_MULTISAMPLE                128
#define GLUT_STEREO                     256
#define GLUT_LUMINANCE                  512

: cls-openGL  ( - )
   true to static-scene    \ needed when resizing
   1.0e 1.0e 1.0e 0.0e glClearColor clear-buffer show-buffer  ;

: openGL-black  ( - )
   true to static-scene    \ needed when resizing
   0e 0e 0e 0e glClearColor clear-buffer show-buffer  ;

0e fvalue c1
0e fvalue c2
0e fvalue c3

: 3fdups        ( f: f - f f f ) fdup fdup fdup  ;

: 2fdups        ( f: f - f f )   fdup fdup  ;

\  The following objects are default around 0 use glTranslatef to move them

: _3dtriangle  ( size - )
( 1)     0.0e       1.0e     0.0e  glNormal3f  \ top
         3fdups                    glVertex3f
         3fdups fnegate            glVertex3f
          fdup fnegate fover fdup  glVertex3f

( 2)     1.0e       0.0e     0.0e  glNormal3f  \ rside
         3fdups                    glVertex3f
          fdup fover fnegate fover glVertex3f
         3fdups fnegate            glVertex3f

( 3)     0.0e       0.0e     1.0e  glNormal3f  \ front
         3fdups                    glVertex3f
         2fdups fnegate fover      glVertex3f
          fdup fnegate fover fdup  glVertex3f

( 4)    -1.0e     -1.0e     -1.0e  glNormal3f  \ lside
          fdup fnegate fover fdup  glVertex3f
         2fdups fnegate fover      glVertex3f
         2fdups fnegate            glVertex3f
 ;

: 3dtriangle   ( f: size - )    2e f/  _3dtriangle  ;

: 3Ddot   ( f: 2*size - )
         3fdups                     glVertex3f
         fdup fnegate fover        glVertex3f  ;


: _outlined   \  init c1 c2 and c3 first
( 1)     0.0e       0.0e       1.0e       glNormal3f
         c1         c2         c3         glVertex3f
         c1 fnegate c2         c3         glVertex3f
         c1 fnegate c2 fnegate c3         glVertex3f
         c1         c2 fnegate c3         glVertex3f
 ;

: init_c1-3 ( f: width height depth - ) 2e f/ fto c3 2e f/ fto c2 2e f/ fto c1 ;
: outlined  ( f: width height depth - ) init_c1-3  _outlined ;

: _box     ( - )  \  init c1 c2 and c3 first
         _outlined
( 2)     0.0e       0.0e      -1.0e  glNormal3f
         c1 fnegate c2 fnegate c3 fnegate glVertex3f
         c1 fnegate c2         c3 fnegate glVertex3f
         c1         c2         c3 fnegate glVertex3f
         c1         c2 fnegate c3 fnegate glVertex3f

( 3)     0.0e       1.0e       0.0e       glNormal3f
         c1         c2         c3         glVertex3f
         c1         c2         c3 fnegate glVertex3f
         c1 fnegate c2         c3 fnegate glVertex3f
         c1 fnegate c2         c3         glVertex3f

( 4)     0.0e      -1.0e       0.0e       glNormal3f
         c1 fnegate c2 fnegate c3 fnegate glVertex3f
         c1         c2 fnegate c3 fnegate glVertex3f
         c1         c2 fnegate c3         glVertex3f
         c1 fnegate c2 fnegate c3         glVertex3f

( 5)     1.0e       0.0e       0.0e       glNormal3f
         c1         c2         c3         glVertex3f
         c1         c2 fnegate c3         glVertex3f
         c1         c2 fnegate c3 fnegate glVertex3f
         c1         c2         c3 fnegate glVertex3f

( 6)     -1.0e      0.0e       0.0e       glNormal3f
         c1 fnegate c2 fnegate c3 fnegate glVertex3f
         c1 fnegate c2 fnegate c3         glVertex3f
         c1 fnegate c2         c3         glVertex3f
         c1 fnegate c2         c3 fnegate glVertex3f
 ;

: box    ( f: width height depth - )    init_c1-3 _box  ;


: rectangle-obj     ( f: width height depth - ) \ Note: The sizes will be 2*
    fto c3  fto c2  fto c1  _box ;

: cube    ( f: size - )
    2e f/ 2fdups rectangle-obj ;


struct{ \ BoxList
    int ListID
    b/float  fwidthBox
    b/float  fheightBox
    b/float  fdepthBox
}struct BoxList
sizeof BoxList constant /BoxList

0 value  lists                         \ Starting of the display lists
0 value  #list                         \ #list to be used.

: NewList ( - list )  lists #list + 1 +to #list ;
: CompileList ( list - ) GL_COMPILE glNewList ;
: CompileNewList ( list - list )
   dup NewList dup>r swap !  r> CompileList
;

(( About glNormal3f:
The normal value of the top face is the unit vector pointing up (0,1,0) over the Y axe
The normal to the bottom face is the unit vector pointing down (0,-1,0) etc.

About glTexCoord2f:
Texture coordinates of glTexCoord2f range from (0, 0) to (1, 1) for a single copy of the texture
The first value of glTexCoord2f is the X coordinate. 0.0f is the left side of the texture.
0.5f is the middle of the texture, and 1.0f is the right side of the texture.

The second value of glTexCoord2f is the Y coordinate.
0.0f is the bottom of the texture. 0.5f is the middle of the texture,
and 1.0f is the top of the texture. ))

: CompileBox ( f: width height depth - ) ( listStruct - )
    init_c1-3			\ Set the relative sizes
    CompileNewList		\ Prepair for compiling and set ListID
    c1 2e f* dup fwidthBox  f! 	\ Store the actual width
    c2 2e f* dup fheightBox f!	\ Store the actual height
    c3 2e f*     fdepthBox  f!	\ Store the actual depth
    GL_QUADS glBegin
	0.0e -1.0e 0.0e glNormal3f
	1e 1e glTexCoord2f c1 fnegate	c2 fnegate	c3 fnegate	glVertex3f     \ Bottom face
	0e 1e glTexCoord2f c1 	 	c2 fnegate	c3 fnegate 	glVertex3f
	0e 0e glTexCoord2f c1 		c2 fnegate	c3 		glVertex3f
	1e 0e glTexCoord2f c1 fnegate 	c2 fnegate	c3 		glVertex3f

	0.0e 0.0e 1.0e glNormal3f
	0e 0e glTexCoord2f c1 fnegate 	c2 fnegate	c3 		glVertex3f     \ Front face
	1e 0e glTexCoord2f c1 		c2 fnegate	c3 		glVertex3f
	1e 1e glTexCoord2f c1		c2		c3 		glVertex3f
	0e 1e glTexCoord2f c1 fnegate  	c2   		c3 		glVertex3f

	0.0e 0.0e -1.0e glNormal3f
	1e 0e glTexCoord2f c1 fnegate	c2 fnegate 	c3 fnegate 	glVertex3f     \ Back face
	1e 1e glTexCoord2f c1 fnegate 	c2 		c3 fnegate 	glVertex3f
	0e 1e glTexCoord2f c1  		c2 		c3 fnegate 	glVertex3f
	0e 0e glTexCoord2f c1 		c2 fnegate 	c3 fnegate 	glVertex3f

	1.0e 0.0e 0.0e glNormal3f
	1e 0e glTexCoord2f c1 		c2 fnegate 	c3 fnegate	glVertex3f     \ Right face
	1e 1e glTexCoord2f c1  		c2 		c3 fnegate	glVertex3f
	0e 1e glTexCoord2f c1  		c2  		c3 		glVertex3f
	0e 0e glTexCoord2f c1		c2 fnegate	c3 		glVertex3f

	-1.0e 0.0e 0.0e glNormal3f
	0e 0e glTexCoord2f c1 fnegate 	c2 fnegate 	c3 fnegate 	glVertex3f     \ Left face
	1e 0e glTexCoord2f c1 fnegate	c2 fnegate	c3		glVertex3f
	1e 1e glTexCoord2f c1 fnegate	c2		c3		glVertex3f
	0e 1e glTexCoord2f c1 fnegate	c2		c3 fnegate	glVertex3f

	0.0e 1.0e 0.0e glNormal3f
	0e 1e glTexCoord2f c1 fnegate	c2 		c3 fnegate	glVertex3f     \ Top face
	0e 0e glTexCoord2f c1 fnegate	c2		c3		glVertex3f
	1e 0e glTexCoord2f c1		c2		c3 		glVertex3f
	1e 1e glTexCoord2f c1  		c2		c3 fnegate	glVertex3f
    glEnd
  glEndList
 ;

struct{ \ 3dRoot
Offset Direction
    b/float  fmx       \ distance to move
    b/float  fmy
    b/float  fmz
    cell     id
}struct 3dRoot

struct{ \ box_dyn
    sizeof 3dRoot _add-struct
Offset OrgPosition
    b/float  ftx
    b/float  fty
    b/float  ftz
    cell     idegrees
    b/float  frx       \ Rotatef
    b/float  fry
    b/float  frz
    b/float  fbox_x    \ size
    b/float  fbox_y
    b/float  fbox_z
    b/float  fbox_hx   \ sizes in relative matrix ( 2/ )
    b/float  fbox_hy
    b/float  fbox_hz
}struct box_dyn

0 idegrees constant sizeof.position

: floats!@     ( adr k - ) ( f:  fk..f0 - fk..f0 )
   2dup floats! floats@  ;

: box_sizes!    ( adr-struct-box - ) ( f: width height depth -  )
   dup fbox_x 3 2dup floats! floats@
   2e f/ dup fbox_hz f!  2e f/ dup fbox_hy f!  2e f/ fbox_hx f! ;

: move!    ( adr-struct-box - ) ( f: width height depth -  )
   fmx 3 floats! ;

: position!   ( adr-struct-obj - ) ( f: x y z - )
   OrgPosition 3 floats! ;

: position@   ( adr-struct-obj - ) ( f: - x y z )
   dup ftx f@  dup fty f@  ftz f@ ;

: move-it  ( adr-dyn - )
   dup fmx 3 floats@  ftx 3 2dup floatsf@+  floats! ;

: box_sizes@    ( adr-struct-box - ) ( f: - width height depth )
  dup fbox_x f@  dup fbox_y f@  fbox_z f@ ;

: rotatef!     ( degrees adr-struct-obj - degrees ) ( f:  x y z - )
   2dup idegrees ! frx 3 floats!  ;


GLfloat lightcolor      { 0.e 1.0e 0.0e   0.0e  };
GLfloat lightdirection  { 0.0e 0.0e 0.0e  };

struct{ \ ball_dyn
  sizeof.position _add-struct \ includes 3dRoot ftx, fty and ftz
  b/float  fball_size         \ size
  b/float  fball_hsize
}struct ball_dyn

: ball_size! ( ball fball_size - )
   dup fdup fball_size  f!  2e f/ fball_hsize f!  ;

: val>$    ( str$ val -  )  s>d (d.)   rot  place  ;

\ 3D turtle extensions

 4 fref: frefT4RotR
 3 fref: frefT3Color
 3 fref: frefT3Elements
 3 fref: frefT3MoveM
 3 fref: frefT3RotS
 3 fref: frefT3MoveX

: joint  ( f: deg xg yg zg    xt yt zt -- )	\ Set the position and angle of a joint
   glTranslatef  glRotatef
;

: Orbit  ( f: x y z   degrees xr yr zr - )	\ To orbit around a position
   frefT4RotR  floatsf@+ glRotatef		\ Angle in orbit x y z
   frefT3MoveM floatsf@+ glTranslatef		\ Distance from the center x y z
 ;


0 value element  0 value #elements

: IncrColor ( n - )  s>f 1e f+ .035e f* ;

: DrawReposition
   element @			glCallList     \ Draw an element at the current position
   element fwidthBox f@  0e 0e	glTranslatef   \ and move to the next position (incremental)
 ;

: AddNewElements ( - )
   #elements s>f  0e 0e frefT3Elements floatsf@+  frot	   \ #elements fref1???
   f>s  1 max 0
     do
          i  IncrColor   fdup fdup  frefT3Color floatsf@+ glColor3f    \ Color r g b
           DrawReposition
    loop fdrop fdrop
 ;

: NewPart ( f: deg xg yg zg    xt yt zt -- )
   glPushMatrix joint
 ;

: :Part \ Runtime: ( f: deg xg yg zg    xt yt zt -- )	\ Set the position and angle of a joint of a new part
\in-system-ok : postpone NewPart
 ;


\ For interactive changes when frefT4RotR and frefT3MoveM are in the KeyboardAction:
: xOrbit  ( f: x y z   degrees xr yr zr - )	\ To orbit around a position
   frefT4RotR  floatsf@+ glRotatef		\ Angle in orbit x y z
   frefT3MoveM floatsf@+ glTranslatef		\ Distance from the center x y z
 ;

: xJoint  ( f: deg xg yg zg    xt yt zt -- )	\ Set the position and angle of a joint
   frefT3MoveM floatsf@+ glTranslatef		\ Can be changed with the key m
   frefT4RotR floatsf@+  glRotatef		\ Can be changed with the key r
 ;

: Add3dTurtle ( -- )
   0e 0e  0e 0.0e         \ Angle x y z
   0e 0e 0e xjoint        \ move x y z
   10 to #Elements AddNewElements
 ;

: xNewPart  ( f: deg xg yg zg    xt yt zt -- )
   glPushMatrix xjoint
 ;

: :xPart  \ Runtime: ( f: deg xg yg zg    xt yt zt -- )	\ Set the position and angle of a joint of a new part
\in-system-ok : postpone xNewPart
 ;

\ End of the interactive definitions

: ;Part ( - ) \in-system-ok postpone glPopMatrix  postpone ; ; immediate

ns-time-out-done f>s time-1-period  1000e f* f>s value old-ms-time-out-done

: ChangeTheSpeed-fps ( fps - )
       dup 0=
         if  drop 9999
         then
       dup to old-ms-time-out-done
       dup 0>
         if time-1-period
         else abs 10000 * f>s
         then fto ns-time-out-done
  ;


: set-speed-fps ( - )
     oglwin-base s" Enter the desired framespeed:"
     old-ms-time-out-done  ['] ChangeTheSpeed-fps ForAskedInteger
 ;

: ChangeScaleDibsection ( %rate - )
  true to request-to-stop
  0 max 100 min dup to Old%rate s>f 100e f/
  ScaleDib painting
 ;

: ScaleDibsection ( - )
     oglwin-base s" Enter the %:"
     Old%rate  ['] ChangeScaleDibsection ForAskedInteger
 ;

: ResetOpenGL ( - )
   InitOpenGL SetWhViewport
 ;

NewEditDialog Degree/sec "Speed of 1 degree " "Degrees / second:" "Ok"   ""  ""

: set-speed-degrees ( - )
    #frames-to-do$ dup ms-slow-action ms-1-period val>$
    oglwin-base Start: Degree/sec not
       abort" Stop. Maximum degrees / second is not changed."
    #frames-to-do$ count number? not
       abort" Bad number. No change of speed." d>s abs
       ms-1-period to ms-slow-action
 ;

: qbox    ( adr2 len2 adr1 len1  - button )
    [ MB_YESNOCANCEL MB_ICONQUESTION or MB_TASKMODAL or ] literal msgbox  ;

: full-screen? ( - flag )
   s" Window mode. "
   s" Switch to full screen?   Note: The key functions can still be used. " qbox
     case
     IDYES  of  start/end-fullscreen true endof
     IDNO   of  false                     endof
            ['] abort is painting abort
     endcase
 ;
FileOpenDialog LoadBitmap "Load bitmap: " "Bitmap Files (*.bmp)|*.bmp|All Files (*.*)|*.*|"

: showing-bitmap(s) ( - )   ['] _load-bitmap is painting glout  ;

: load-bitmap
   ogl-hwnd Start: LoadBitmap dup c@ 0 = abort" Bad name. Bitmap not loaded"
   wait-cursor
   showing-bitmap(s) count save$ place _load-bitmap drop
   arrow-cursor
 ;

FileOpenDialog FirstBitmap "First bitmap: " "Bitmap Files (*.bmp)|*.bmp|All Files (*.*)|*.*|"

: show-#bitmaps
   ogl-hwnd Start: FirstBitmap dup c@ 0 = abort" Bad name. Bitmap not loaded"
   showing-bitmap(s)
   dup extension> dup count nip 4 - over c!
   count init-save$ place    \ reset file-name
   max-frames? 1+ 1
     do
       init-save$ count  save$ place
       i 0 <# # # # # #> save$ +place save$ +bmp  \ add a number to the name
       _load-bitmap
           if  4th>title save$ count +title ogl-hwnd retitle-window  \ update the title of the window
               winpause
               leave-on-stop
           then
     loop
  Reset-request-to-stop
 ;
9 value NOmenu-hmnu
9 value menu-hmnu

true value OtherScene?
defer ExitScene

: AnewScene s" Anew Scene" evaluate ; immediate

needs fullscreen.f \ Switch to fullscreen or to a indow

\s
