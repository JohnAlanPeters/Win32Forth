\ $Id: D3Dtest.f,v 1.2 2005/09/18 11:10:30 dbu_de Exp $

\ Example of drawing one triangle using Direct3d (Directx 8.1)
\ Thomas Dixon

needs fcom

1 0 typelib {E1211242-8E94-11D1-8808-00C04FC2C603} \ Load Directx 8.1

\ Interfaces
IDirectx8 ComIFace dx8
Direct3D8 ComIFace d3d
Direct3DDevice8 ComIFace d3dev

\ Structures
D3DDISPLAYMODE d3dmode
D3DPRESENT_PARAMETERS d3dpp

\ custom vertex
D3DFVF_XYZRHW D3DFVF_DIFFUSE or value FVF_Custom
20 value vertsize
: vertarray ( n -- ) create vertsize * allot does> swap vertsize * + ;


: setup-d3d ( -- )
  dx8 IDirectx8 1 0 Directx8 CoCreateInstance abort" Unable to get Directx!"
  d3d dx8 Direct3dCreate abort" Direct3dCreate Failed!"
  d3dmode D3DADAPTER_DEFAULT d3d GetAdapterDisplayMode abort" Unable to get Mode!"
  1 d3dpp windowed !
  D3DSWAPEFFECT_COPY_VSYNC d3dpp swapeffect !
  d3dmode format @ d3dpp BackBufferFormat !
  d3dev d3dpp D3DCREATE_SOFTWARE_VERTEXPROCESSING ( Change "software" to "hardware" for speed)
   conhndl D3DDEVTYPE_HAL D3DADAPTER_DEFAULT d3d CreateDevice abort" Unable to create device!" ;

: free-d3d ( -- )
  d3dev release drop
  d3d release drop
  dx8 release drop  ;

\ Initialize the vertext buffer
3 vertarray vert

: vert! ( color rhw fz fy fx vert -- )
  4 0 do dup i cells + sf! loop 4 cells + ! ;

$ffff0000 1e0 0.5e0 50.0e0 150.0e0 0 vert vert!
$ff00ff00 1e0 0.5e0 250.0e0 250.0e0 1 vert vert!
$ff00ffff 1e0 0.5e0 250.0e0 50.0e0 2 vert vert!

: tri-list ( listarray n -- )
  FVF_Custom d3dev SetVertexShader drop
  vertsize -rot D3DPT_TRIANGLELIST d3dev DrawPrimitiveUP drop ;

: vclear ( -- ) 0 1e0 sfs>ds $FF D3DCLEAR_TARGET 0 0 d3dev Clear drop ;
: beginScene ( -- ) d3dev beginScene drop ;
: endScene ( -- ) d3dev endscene drop ;
: Present ( -- ) 0 0 0 0 d3dev Present drop ;

setup-d3d
vclear beginscene
0 vert 3 tri-list
endscene
present
free-d3d
