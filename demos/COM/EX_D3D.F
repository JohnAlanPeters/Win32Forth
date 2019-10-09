\ $Id: EX_D3D.F,v 1.2 2005/09/18 11:10:30 dbu_de Exp $

\ Example of using Direct3d (Directx 8.1)
\ Thomas Dixon

needs fcom

1 0 typelib {E1211242-8E94-11D1-8808-00C04FC2C603} \ Load Directx 8.1

winlibrary dx8vb.dll

\ Interfaces
IDirectx8 ComIFace dx8
Direct3D8 ComIFace d3d
Direct3DDevice8 ComIFace d3dev
ID3dx8 Comiface d3dhelper
D3DXBuffer ComIFace meshbuf
D3DXMesh COMIFace mesh

\ Structures
D3DDISPLAYMODE d3dmode
D3DPRESENT_PARAMETERS d3dpp
D3DMATRIX matworld
D3DMATERIAL8 meshmat
D3DLIGHT8 dlight

: setup-d3d ( -- )
  dx8 IDirectx8 1 0 Directx8 CoCreateInstance abort" Unable to get Directx!"
  d3d dx8 Direct3dCreate abort" Direct3dCreate Failed!"
  d3dmode D3DADAPTER_DEFAULT d3d GetAdapterDisplayMode abort" Unable to get Mode!"
  1 d3dpp windowed !
  D3DSWAPEFFECT_COPY_VSYNC d3dpp swapeffect !
  d3dmode format @ d3dpp BackBufferFormat !
  d3dev d3dpp D3DCREATE_SOFTWARE_VERTEXPROCESSING ( Change "software" to "hardware" for speed)
   conhndl D3DDEVTYPE_HAL D3DADAPTER_DEFAULT d3d CreateDevice abort" Unable to create device!"
  d3dhelper ID3DX8 1 0 D3DX8 CoCreateInstance abort" Unable to get d3dx8!" ;

: free-d3d ( -- )
  d3dev release drop
  d3d release drop
  dx8 release drop ;

variable nummat 0 nummat !
D3DVECTOR v1
D3DVECTOR v2
D3DVECTOR v3

: v! ( fz fy fx v -- ) dup sf! dup 4 + sf! 8 + sf! ;

: color>cstruct ( fr fg fb fa addr -- )
  dup COM D3DCOLORVALUE a sf!
  dup COM D3DCOLORVALUE b sf!
  dup COM D3DCOLORVALUE g sf!
  COM D3DCOLORVALUE r sf! ;


: load-demo ( -- )
  setup-d3d
  \ Setup the World Matrix
  matworld call VB_D3DXMatrixIdentity drop
  matworld D3DTS_WORLD d3dev SetTransform drop
  \ Setup the View Matrix
  -5e0 3e0 0e0 v1 v! \ eye
    0e0 0e0 0e0 v2 v! \ at
    0e0 1e0 0e0 v3 v! \ look
  v3 v2 v1 matworld call VB_D3DXMatrixLookAtLH drop
  matworld D3DTS_VIEW d3dev SetTransform drop
  \ Setup the Projection Matrix
  1000e0 sfs>ds 1e0 sfs>ds dup .785398e0 sfs>ds matworld call VB_D3DXMatrixPerspectiveFovLH drop
  matworld D3DTS_PROJECTION d3dev SetTransform drop

  \ Render States (initial)
  D3DFILL_WIREFRAME D3DRS_FILLMODE d3dev SetRenderState drop
  1 D3DRS_CLIPPING d3dev SetRenderState drop
  D3DCULL_CCW D3DRS_CULLMODE d3dev setRenderState drop

  \ Setup the Light Source (directional from above)
  D3DLIGHT_DIRECTIONAL dlight Type !
  1e0 1e0 1e0 0e0 dlight diffuse color>cstruct
  0.5e0 dlight Direction x sf!
  -3e0 dlight Direction y sf!
  0.5e0 dlight Direction z sf!
  1000e0 dlight Range sf!
  dlight 0 d3dev setlight abort" Unable to set light source!"
  1 D3DRS_LIGHTING d3dev SetRenderState drop
  1 0 d3dev LightEnable abort" No Light Sources Supported!"
  $202020 D3DRS_AMBIENT d3dev setrenderstate drop
  D3DSHADE_GOURAUD D3DRS_SHADEMODE d3dev SetRenderState drop
;

\ Words to load various mesh shapes
: load-teapot ( --)
  mesh @ if mesh release drop then
  mesh meshbuf d3dev @ d3dhelper CreateTeapot abort" Unable to Load Teapot!" ;

: load-sphere ( --)
  mesh @ if mesh release drop then
  mesh meshbuf 20 20 1e0 sfs>ds d3dev @
  d3dhelper CreateSphere abort" Unable to Load Sphere!" ;

: load-torus ( --)
  mesh @ if mesh release drop then
  mesh meshbuf 20 20 1e0 sfs>ds .5e0 sfs>ds d3dev @
  d3dhelper CreateTorus abort" Unable to Load Sphere!" ;

: load-box ( --)
  mesh @ if mesh release drop then
  mesh meshbuf 1.0e0 sfs>ds dup dup d3dev @
  d3dhelper CreateBox abort" Unable to Load Sphere!" ;


\ Matrix!
: m! ( f1 f2 ... f16 mat -- ) 0 15 do dup i cells + sf! -1 +loop drop ;

\ Rotate (matrix multiply)
0e0 fvalue angle
: rotate ( -- )
  angle fcos  0e0  angle fsin -1e0 f* 0e0
  0e0         1e0  0e0                0e0
  angle fsin  0e0  angle fcos         0e0
  0e0         0e0  0e0                1e0 matworld m!
  matworld D3DTS_WORLD d3dev SetTransform drop ;

: vclear ( -- ) 0 1e0 sfs>ds $FFFFFF D3DCLEAR_TARGET 0 0 d3dev Clear drop ;
: beginScene ( -- ) d3dev beginScene drop ;
: endScene ( -- ) d3dev endscene drop ;
: Present ( -- ) 0 0 0 0 d3dev Present drop ;

\ special effects

: wire ( -- ) D3DFILL_WIREFRAME D3DRS_FILLMODE d3dev setrenderstate drop ;

: setred ( -- )
  D3DFILL_SOLID D3DRS_FILLMODE d3dev SetRenderState drop
  1e0 0e0 0e0 1e0 meshmat ambient color>cstruct
  1e0 0e0 0e0 1e0 meshmat diffuse color>cstruct
  meshmat d3dev SetMaterial drop ;

: setgreen ( -- )
  D3DFILL_SOLID D3DRS_FILLMODE d3dev SetRenderState drop
  0e0 1e0 0e0 1e0 meshmat ambient color>cstruct
  0e0 1e0 0e0 1e0 meshmat diffuse color>cstruct
  meshmat d3dev SetMaterial drop ;

: setblue ( -- )
  D3DFILL_SOLID D3DRS_FILLMODE d3dev SetRenderState drop
  0e0 0e0 1e0 1e0 meshmat ambient color>cstruct
  0e0 0e0 1e0 1e0 meshmat diffuse color>cstruct
  meshmat d3dev SetMaterial drop ;

: demo ( -- )
  load-demo load-teapot
  begin vclear rotate beginscene
    0 mesh drawsubset drop
    0.05e0 angle f+ fdup 6.28319e0 f> if 6.28319e0 f- then fto angle
    key? if false key case
      49 of wire endof
      50 of setred endof
      51 of setgreen endof
      52 of setblue endof
      53 of load-teapot endof
      54 of load-sphere endof
      55 of load-torus endof
      56 of load-box endof
      27 of drop true endof
    endcase else false then
  endscene present until free-d3d ;

demo

(( Instructions for the demo:
  just run "demo" and you find a rotating teapot in the window.
  some keys will change the way this demo works.
    1 = Wire frame rendering
    2 = red filling
    3 = green filling
    4 = blue filling
    5 = teapot shape
    6 = sphere shape
    7 = torus shape
    8 = box shape
    esc = end demo
))
