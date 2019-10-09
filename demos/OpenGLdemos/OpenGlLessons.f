\ OpenGlLessons.f \ Adaptations for NeHeLessons

aNew -OpenGlLessons.f

synonym gl-shade-model          glShadeModel
synonym gl-clear-depth          glClearDepth
synonym gl-enable               glEnable
synonym gl-hint                 glHint
synonym gl-depth-func           glDepthFunc
synonym gl-clear-color          glClearColor
synonym gl-clear                glClear
synonym gl-load-identity        glLoadIdentity
synonym gl-translate-f          glTranslatef
synonym gl-begin                glBegin
synonym gl-vertex-3f            glVertex3f
synonym gl-end                  glEnd
synonym gl-color-3f             glColor3f
synonym gl-rotate-f             glRotatef
synonym gl-tex-image-2d         glTexImage2D
synonym gl-gen-textures         glGenTextures
synonym gl-bind-texture         glBindTexture
synonym gl-tex-parameter-i      glTexParameteri
synonym gl-tex-coord-2f         glTexCoord2f
synonym glu-build-2d-mipmaps    gluBuild2DMipmaps
synonym gl-light-fv             glLightfv
synonym gl-normal-3f            glNormal3f
synonym gl-color-4f             glColor4f
synonym gl-blend-func           glBlendFunc
synonym gl-color-4ub            glColor4ub
synonym gl-polygon-mode         glPolygonMode
synonym gl-gen-lists            glGenLists
synonym gl-new-list             glNewList
synonym gl-end-list             glEndList
synonym gl-color-3fv            glColor3fv
synonym gl-call-list            glCallList
synonym gl-delete-lists         glDeleteLists
synonym gl-fog-i                glFogi
synonym gl-fog-fv               glFogfv
synonym gl-fog-f                glFogf
synonym gl-vertex-2i            glVertex2i
synonym gl-translate-d          glTranslated
synonym gl-disable              glDisable
synonym gl-matrix-mode          glMatrixMode
synonym gl-push-matrix          glPushMatrix
synonym gl-ortho                glOrtho
synonym gl-list-base            glListBase
synonym gl-call-lists           glCallLists
synonym gl-pop-matrix           glPopMatrix
synonym gl-vertex-2f            glVertex2f
synonym glu-new-quadric         gluNewQuadric
synonym glu-quadric-normals     gluQuadricNormals
synonym glu-quadric-texture     gluQuadricTexture
synonym glu-cylinder            gluCylinder
synonym glu-disk                gluDisk
synonym glu-sphere              gluSphere
synonym glu-partial-disk        gluPartialDisk
synonym gl-depth-mask           glDepthMask
synonym gl-color-mask           glColorMask
synonym gl-stencil-func         glStencilFunc
synonym gl-front-face           glFrontFace
synonym gl-stencil-op           glStencilOp
synonym gl-clear-stencil        glClearStencil
synonym gl-material-fv          glMaterialfv
synonym gl-cull-face            glCullFace
synonym gl-get-float-v          glGetFloatv
synonym gl-flush                glFlush
synonym gl-scale-f              glScalef
synonym gl-color-3ub            glColor3ub
synonym gl-vertex-2d            glVertex2d
synonym gl-line-width           glLineWidth
synonym gl-get-string           glGetString
synonym gl-scissor              glScissor
synonym gl-get-integer-v        glGetIntegerv
synonym gl-tex-gen-i            glTexGeni
synonym gl-clip-plane           glClipPlane
synonym gl-pixel-transfer-f     glpixeltransferf
synonym gl-tex-env-f            gltexenvf
synonym gl-push-attrib          glPushAttrib
synonym gl-pop-attrib           glPopAttrib
synonym gl-raster-pos-2f        glRasterPos2f
synonym glu-perspective         gluPerspective
synonym gl-delete-textures      glDeleteTextures
synonym glu-delete-quadric      gluDeleteQuadric



defer ExitLesson    ' noop is ExitLesson
synonym sdl-gl-swap-buffers     show-frame

-1e facos fconstant pi
synonym =:                      constant
true value LessonChanged?

: clrTitle$ ( - ) title$ 50 erase ;

: NeHe>title     ( - )
   clrTitle$ s" NeHe lessons in Win32Forth. " title$ place ogl-hwnd retitle-window ;

: StaticScene  ( - )  NeHe>title true  to static-scene  ;

: DynamicScene ( - )
    clrTitle$ s" NeHe lessons in Win32Forth. Fps:  " FpsStart$ place
    false to static-scene
 ;

: SF, ( r -- )   here 1 sfloats allot SF! ;
: F-! ( f: fval -- ) ( *fvar -- ) FNEGATE F+! ;
: rnd ( -- rnd ) 0xfffffff random ;

: set-viewpoint-wf32 ( -- )     \ Needed for the Win32Forth window
  GL_PROJECTION glMatrixMode    \ set viewing to the projection matrix
  85e    .5e   0.1e  200.0e   fref4PersP  floatsf@+ gluPerspective
  1.1e 2.0e 1.5e               fref3ScaleS floatsf@+ glscalef   \ To fit it into the window
  GL_MODELVIEW glMatrixMode     \ set viewing to the model matrix  \ 2
 ;


#define  VK_NUMPAD+ 107
#define  VK_NUMPAD- 109

\s
