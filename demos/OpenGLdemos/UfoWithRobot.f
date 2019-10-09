Anew UfoWithRobot          \ To demonstrate the new 3D turtle.

s" src\lib\OpenGl" "fpath+ \ For OpenGL support

needs opengl.f             \ The OpenGl wrapper and many tools

menubar Openglmenu         \ Define a menu for the OpenGL window
  popup "&File"     menuitem   "E&xit"  ExitScene bye ;
endbar

needs oglwin.f              \ The OpenGL window
needs Helpform.f            \ For the help window

\ ---[ DrawGLScene ]-------------------------------------------------
\ Here goes our drawing code


\ Define the various display lists
/BoxList mkstruct: SmallBox
/BoxList mkstruct: floor
/BoxList mkstruct: Body
/BoxList mkstruct: NodeUnit

: BuildLists ( #lists -- )
  glGenLists to lists	\ Compile the lists and specify the width height and depth (xyz)
  .32e  .32e  .32e	SmallBox	CompileBox
   14e  .2e    4e	Floor		CompileBox
  .3e   .85e   .3e	Body		CompileBox
  .05e  .15e   .15e	NodeUnit	CompileBox
 ;

\ Define and load various textures

0 value Texture-Ufo
0 value Texture-Floor
0 value Texture-Body

: LoadGLTextures ( -- )
	3 Create-Textures				\ Create the all the needed textures
	s" cube.bmp"  LoadTexture to Texture-Ufo	\ Load the texture and save the name
	s" floor.bmp" LoadTexture to Texture-Floor	\ Load the texture and save the name
	s" Body.bmp"  LoadTexture to Texture-Body	\ Load the texture and save the name
 ;

: SetupLight
	GL_LIGHT0	glEnable			\ enable light0
	GL_LIGHTING	glEnable			\ enable lighting
\  gray  blue   green  red
	4.50000e 4.5e 4.5e 4.5e  fref4LambientN floatsf@+ model-ambient GLfloat!
	GL_LIGHT_MODEL_AMBIENT model-ambient  glLightModelfv

\  gray  blue   green  red
\	1e 1e 1e 1e fref4DiffuseV floatsf@+ lightcolor GLfloat!
\	GL_LIGHT0  GL_DIFFUSE   lightcolor    glLightfv

\   ???     y    z      x
	1e   .9900e 1.478e 0.021e  fref3LpositionL floatsf@+ lightPosition GLfloat!
	GL_LIGHT0  GL_POSITION  lightPosition  glLightfv
 ;

\ Initialization OpenGL

0 value 0quadratic
: InitGL ( -- boolean )
    	LoadGLTextures					\ Load in the texture
	GL_TEXTURE_2D		glEnable		\ Enable texture mapping
	GL_SMOOTH		glShadeModel 		\ Enable smooth shading
	.2e .2e .5e 0.5e 	glClearColor 		\ A blue background
	1e			glClearDepth		\ Depth buffer setup
	GL_DEPTH_TEST		glEnable 		\ Enable depth testing
	GL_LEQUAL		glDepthFunc 		\ Type of depth test to do
	GL_COLOR_MATERIAL 	glEnable		\ enable material coloring
        GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST glHint \ Really nice perspective calculations
	4 BuildLists 					\ Build the display lists
	SetupLight
 ;


\ Set the viewpoint

: set-viewpoint ( -- )   				\ The call to glViewport is done in Opengl.f
	GL_PROJECTION 	glMatrixMode 			\ Switch to the projection view
  \ Set our perspective - the F/ calcs the aspect ratio of w/h
  100e widthViewport  S>F heightViewport  S>F F/   0.1e 100e  GluPerspective \ (  f: fovy aspect near far-- )
	GL_MODELVIEW 	glMatrixMode 			\ Switch to the model view
;

create 0colors 1e F, 0e F, 0e F,

: Save#elements		( n - n )	dup to #elements ;

: AddElement ( f: red green blue - )
   glColor3f  DrawReposition
 ;

\ Various parts for the round Ufo

: AddGreenElements ( n - )
  Save#elements 0
     do   0e    i  IncrColor  0e AddElement  loop ; \ Adding a colored element

: AddRedElements ( n - )
   Save#elements 0
     do   i  IncrColor  0e  0e   AddElement  loop ;

: AddBlueElements ( n - )
   Save#elements 0
     do   0e  0e i  IncrColor    AddElement  loop ;

: AddYelloElements ( n - )
   Save#elements 0
     do  i  IncrColor  fdup 0e   AddElement  loop ;

\ For the robot body
: AddBodyElements ( n - )
   Save#elements 0
     do  .175e  fdup 0e          AddElement  loop ;


: AddWhiteElements ( n - )
   Save#elements 0
     do i  IncrColor  fdup fdup  AddElement  loop ;

\ Various parts in the drawing

:Part .Floor ( f: deg xg yg zg    xt yt zt -- )
	Floor to element		\ Using the display list of the floor which contains the sizes
	Texture-Floor Bind2DTexture	\ Select it's texture
	0.08e  fdup fdup  glColor3f	\ Select a color
	DrawReposition			\ It consists of 1 element and contains no additional elements
 ;Part


:Part .Ufo ( f: deg xg yg zg    xt yt zt -- )
   SmallBox to element   \ Each element is a SmallBox
   Texture-Ufo Bind2DTexture		\ Select it's texture
   5 AddGreenElements			\ Add a number of green cubes
	 60 0 do			\ Repeat
		90e 0e 0e 1e glRotatef	\ Turn Z ( up)
		5 AddRedElements

		90e 0e 1e 1e glRotatef	\ Turn Y and Z ( down + left )
		5 AddBlueElements	\ Add blue cubes

		90e 0e 0e 1e glRotatef	\ Turn Z
		9 AddYelloElements	\ Add yello cubes

		90e 0e 1e 1e glRotatef	\ Turn Y and Z
		9 AddWhiteElements	\ Add white cubes
	loop
 ;Part

\ All parts are attached to .Body, so keep the body in the starting matrix
\ Do not use glPushMatrix or :Part here.
: .Body  ( -- )
   body to element		\ Use body as the element for expanding
   .175e fdup 0.09e  glColor3f	\ Select a color
   DrawReposition		\ The body has 1 element and contains no additional elements
 ;

:Part .RightArm ( f: deg xg yg zg    xt yt zt -- )	\ :Part also takes care for the joint
	7 AddWhiteElements 				\ Draw the upper right arm
	-29.00e .0000e .0000e 1.600e	0e 0e 0e joint	\ The joint for the lower right arm
	8 AddWhiteElements				\ Draw the lower right arm
 ;Part

:Part .LeftArm ( f: deg xg yg zg    xt yt zt -- )
	7 AddWhiteElements				\ The upper arm
	97.00e .0000e .0000e 1.600e	0e 0e 0e joint	\ The Lower left arm
	8 AddWhiteElements
 ;Part

:Part .head ( f: deg xg yg zg    xt yt zt -- )
	3 AddWhiteElements				\ The neck
	90.00e .0000e -.0593e 1.600e 	.0403e -.1139e .0000e  joint
	5 AddWhiteElements 				\ The head
 ;Part

:Part .LeftLeg ( f: deg xg yg zg    xt yt zt -- )
	11 AddWhiteElements 				\ The upper left leg
	-23.00e .4000e .0000e -1.200e	-.0173e -.0025e .0000e joint
	12 AddWhiteElements				\ The lower left leg
 ;Part

:Part .RightLeg ( f: deg xg yg zg    xt yt zt -- )
	11 AddWhiteElements 				\ The upper right leg
	25.00e .0000e .0000e -.6000e	-.0173e -.0025e .0000e  joint
	12 AddWhiteElements				\ The lower right leg
 ;Part

:xPart .Robot ( f: deg xg yg zg    xt yt zt -- )  \ :xPart activates also the m and r key functions
	Texture-Body Bind2DTexture	\ Select the texture for the body
	.Body				\ The next parts are attached to the body
	Texture-Ufo Bind2DTexture	\ Select the texture for the other parts
	NodeUnit to element		\ Use the NodeUnit for expanding the other parts
	180.0e  .1580e .1580e  .0000e 	-.3168e .4529e  .0185e	.head
	184.0e  .0000e .1709e  .0000e	-.47e   .3535e  .0185e	.LeftArm
	-4.000e .0000e -.8000e -1.400e	-.1717e .3535e  .0185e	.RightArm
	114.0e  .0000e .0000e  -.6000e	-.3705e -.4376e .0185e	.LeftLeg
	65.00e  .0000e .0000e  -.6000e	-.2134e -.4376e .0185e	.RightLeg
 ;Part

: .Scene ( -- )
	GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR  glClear	\ Clear the screen
	\ glLoadIdentity
	0e 0e 0e 0e		.0000e  -5.00e  -7.600e	.Floor
	-.000e .00e 0.100e 00e  fref4RotG   floatsf@+
	-1.200e .4000e  -7.000e	fref3TransI floatsf@+ .Ufo \ The keys g and i can be used
	-47.e .20e .800e .0e  	4.007e  -3.163e -6.430e	.Robot
 ;

: DrawGLScene ( -- )
  .Scene .changed-fps>title  show-frame
 ;


\ ---[ Help text available Keys ]----------------------------------------------

:long$ h12$
$| General key functions for the ufo and the robot:
$| <Del>    Resets the active function
$| <Home>   Resets the whole scene
$| <w>      toggles between fullscreen and windowed modes
$|
$| Activate one of the following functions:
$| <i>      To move the ufo
$| <g>      To rotate the ufo
$| <m>      To move the robot
$| <r>      To rotate the robot
$|
$| Then use:
$| <Left> <Right> <Up> <Down> <PageUp> <PageDown>
$| to change the offset of the active function.
$|
$| Extra:
$| <,>      Decrement rotation after a rotation function
$| <.>      Increment rotation after a rotation function
$| <->      Decrement the amount to change
$| <=>      Increment the amount to change
  ;long$

: .change-Turtle  ( adr-flookat - ) ( f: n - )  f! ( DrawGLScene) ;

: HandleKeyPress ( &event -- )
  case
     VK_RIGHT   of  zx .change-Turtle			endof  \ right
     VK_LEFT    of -zx .change-Turtle			endof  \ left
     VK_UP      of  zy .change-Turtle			endof  \ up
     VK_DOWN    of -zy .change-Turtle			endof  \ down
     VK_PGUP    of -zz .change-Turtle			endof  \ zoom-
     VK_PGDN    of  zz .change-Turtle endof \ zoom. Forwards is DOWN on the negative z-axis!  117
     VK_HOME    of reset-active-function painting	endof  \ use defaults
     VK_.       of -zr  if  .change-Turtle  then	endof  \ rotate-
     VK_,       of  zr  if  .change-Turtle  then	endof  \ rotate
     VK_DEL     of  clear-all-offsets painting		endof
     VK_-       of  decr_interval			endof  \ decr
     VK_=       of  incr_interval			endof  \ incr
   ascii w      of start/end-fullscreen                 endof

   ascii i      of ['] fref3TransI 	is-fref3D  endof  \ move ufo
   ascii g      of ['] fref4RotG    	is-fref3D  endof  \ rotate ufo
   ascii m      of ['] frefT3MoveM	is-fref3D  endof  \ move robot
   ascii r      of ['] frefT4RotR	is-fref3D  endof  \ rotate robot

\ Only active when the source is changed:
   ascii c      of ['] frefT3Color	is-fref3D  endof  \ color turtle
   ascii s      of ['] frefT3RotS	is-fref3D  endof  \ scale the elements
   ascii n      of ['] frefT3Elements	is-fref3D  endof  \ #elements turtle
   ascii x      of ['] frefT3MoveX	is-fref3D  endof  \ orbit araound a turnpoint
   ascii z      of start/stop-slow-action          endof

  h12$ ShowHelp \ Show help when an inactive key is pressed
  endcase
  DrawGLScene
 ;

: _exitdrawing  ( -- )               \ For a clean start of the next drawing
  DeleteTextures
  true to resizing?
 ;

' _exitdrawing is ExitScene

: DrawUfoWithRobot  ( -- )           \ (R)edraw of the scene.
    ResetOpenGL                      \ Cleanup from a previous drawing
    InitGL                           \ Enable some features and load textures
    set-viewpoint                    \ Set the viewpoint
    DrawGLScene                      \ Draw the scene
 ;


: InitUfoWithRobot  ( -- )               \ The startup
    ['] HandleKeyPress is KeyboardAction \ Use the keystrokes for this drawing only
    ['] _Exitdrawing is ExitScene        \ Specify Exitdrawing to free allocated memory
    Start: OpenGLWindow
    DrawUfoWithRobot
 ;

true to static-scene                     \ No automatic scene change

InitUfoWithRobot
'  DrawUfoWithRobot is painting

\s
