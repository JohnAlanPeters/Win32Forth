\ September 28th, 2000 - 15:53  changed init-pfd to use DIBsection
\ September 26th, 1999 - 16:50  removed the duplicate definitions and changed

needs struct.f
anew pixelfrm.f

\  PIXELFORMATDESCRIPTOR flags */
#define PFD_DOUBLEBUFFER            0x00000001
#define PFD_STEREO                  0x00000002
#define PFD_DRAW_TO_WINDOW          0x00000004
#define PFD_DRAW_TO_BITMAP          0x00000008
#define PFD_SUPPORT_GDI             0x00000010
#define PFD_SUPPORT_OPENGL          0x00000020
#define PFD_GENERIC_FORMAT          0x00000040
#define PFD_NEED_PALETTE            0x00000080
#define PFD_NEED_SYSTEM_PALETTE     0x00000100
#define PFD_SWAP_EXCHANGE           0x00000200
#define PFD_SWAP_COPY               0x00000400
#define PFD_SWAP_LAYER_BUFFERS      0x00000800
#define PFD_GENERIC_ACCELERATED     0x00001000
#define PFD_SUPPORT_DIRECTDRAW      0x00002000
#define PFD_SUPPORT_COMPOSITION     0x00008000 \ For the vista

\ PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only */
#define PFD_DEPTH_DONTCARE          0x20000000
#define PFD_DOUBLEBUFFER_DONTCARE   0x40000000
#define PFD_STEREO_DONTCARE         0x80000000


\ pixel types */
#define PFD_TYPE_RGBA        0
#define PFD_TYPE_COLORINDEX  1

\ layer types */
#define PFD_MAIN_PLANE       0
#define PFD_OVERLAY_PLANE    1
#define PFD_UNDERLAY_PLANE   -1

struct{ \ PIXELFORMATDESCRIPTOR
    WORD  nSize
    WORD  nVersion
    DWORD dwFlags
    BYTE  iPixelType
    BYTE  cColorBits
    BYTE  cRedBits
    BYTE  cRedShift
    BYTE  cGreenBits
    BYTE  cGreenShift
    BYTE  cBlueBits
    BYTE  cBlueShift
    BYTE  cAlphaBits
    BYTE  cAlphaShift
    BYTE  cAccumBits
    BYTE  cAccumRedBits
    BYTE  cAccumGreenBits
    BYTE  cAccumBlueBits
    BYTE  cAccumAlphaBits
    BYTE  cDepthBits
    BYTE  cStencilBits
    BYTE  cAuxBuffers
    BYTE  iLayerType
    BYTE  bReserved
    DWORD dwLayerMask
    DWORD dwVisibleMask
    DWORD dwDamageMask
   }struct PIXELFORMATDESCRIPTOR  \ sizeof.pfd sizeof.pfd mkstruct: pfd

sizeof PIXELFORMATDESCRIPTOR mkstruct: pfd


: init-pfd-Dibsection ( - )
    pfd sizeof pfd erase
    sizeof pfd  >struct pfd nSize  w!  \ pfd nSize compiled as a literal (fastest way)
              1 >struct pfd nVersion w!
    PFD_DRAW_TO_BITMAP      >struct pfd dwFlags !
    PFD_TYPE_RGBA           >struct pfd iPixelType c!
    ghdc max-bits-per-pixel >struct pfd cDepthBits c!
    PFD_MAIN_PLANE          >struct pfd iLayerType c!
  ;

: init-pfd-Window ( - )
    pfd sizeof pfd erase
    sizeof pfd  >struct pfd nSize  w!  \ pfd nSize compiled as a literal (fastest way)
              1 >struct pfd nVersion w!
    PFD_SUPPORT_OPENGL
    PFD_DRAW_TO_WINDOW      or
    PFD_DOUBLEBUFFER        or
                            >struct pfd dwFlags !
    PFD_TYPE_RGBA           >struct pfd iPixelType c!
    ghdc max-bits-per-pixel >struct pfd cDepthBits c!
    16                      >struct pfd cColorBits c!
    PFD_MAIN_PLANE          >struct pfd iLayerType c!
  ;


4 value pixelformat

: .pfd  ( - )
    pfd  nSize            ." nSize "           w@ .cr
    pfd  nVersion         ." nVersion "        w@ .cr
    pfd  dwFlags          ." dwFlags "         ?   cr
    pfd  iPixelType       ." iPixelType "      c@ .cr
    pfd  cColorBits       ." cColorBits "      c@ .cr
    pfd  cRedBits         ." cRedBits "        c@ .cr
    pfd  cRedShift        ." cRedShift "       c@ .cr
    pfd  cGreenBits       ." cGreenBits "      c@ .cr
    pfd  cGreenShift      ." cGreenShift "     c@ .cr
    pfd  cBlueBits        ." cBlueBits "       c@ .cr
    pfd  cBlueShift       ." cBlueShift "      c@ .cr
    pfd  cAlphaBits       ." cAlphaBits "      c@ .cr
    pfd  cAlphaShift      ." cAlphaShift "     c@ .cr
    pfd  cAccumBits       ." cAccumBits "      c@ .cr
    pfd  cAccumRedBits    ." cAccumRedBits "   c@ .cr
    pfd  cAccumGreenBits ." cAccumGreenBits "  c@ .cr
    pfd  cAccumBlueBits   ." cAccumBlueBits "  c@ .cr
    pfd  cAccumAlphaBits  ." cAccumAlphaBits " c@ .cr
    pfd  cDepthBits       ." cDepthBits "      c@ .cr
    pfd  cStencilBits     ." cStencilBits "    c@ .cr
    pfd  cAuxBuffers      ." cAuxBuffers "     c@ .cr
    pfd  iLayerType       ." iLayerType "      c@ .cr
    pfd  bReserved        ." bReserved "       c@ .cr
    pfd dwLayerMask       ." dwLayerMask "     ?   cr
    pfd dwVisibleMask     ." dwVisibleMask "   ?   cr
    pfd dwDamageMask      ." dwDamageMask "    ?   cr
 ;

0 value _dwflags


: GetpixelFormat ( abs-pfd hdc - flag )
    0
   (( PFD_DRAW_TO_WINDOW  or
    PFD_SUPPORT_OPENGL or
    PFD_SUPPORT_GDI or
    PFD_NEED_PALETTE or ))

\    PFD_DOUBLEBUFFER or
\    PFD_GENERIC_FORMAT or
\    PFD_GENERIC_ACCELERATED or
    PFD_DRAW_TO_BITMAP or
     to _dwflags
    124 0
       do   2dup sizeof pfd i rot call DescribePixelFormat
            pfd dwFlags c@ _dwflags and not
            _limit-bpps pfd cDepthBits c@ = and
            if leave then
            drop
       loop
       if    false
       else  true
       then
    -rot 2drop
 ;


: SetupPixelFormat  ( hdc - flag)
   >r
\  pfd r@ getpixelformat abort" Invalid pixel format "
\  pfd sizeof pfd 1 r@ call DescribePixelFormat drop
   pfd r@             call ChoosePixelFormat to pixelformat
   pfd pixelformat r>  call SetPixelFormat
 ;

\s

