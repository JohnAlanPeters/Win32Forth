\ $Id: 586ASMCM.f,v 1.13 2015/11/09 13:46:28 jos_ven Exp $
\ arm conditional move macros for 586+
\ Also floating-point extensions for P6 or better gah
\ Januari 2015, Added SSE instructions for SIMD.
\ Note: Not all possible syntax errors are recognized of the SSE instructions.

also assembler also asm-hidden definitions

in-hidden in-system

( cmovcc instructions )
: cmovcc-compile ( compile CMOVcc instructions )
        ( param -- | x \ param -- )
        ?inst-pre register generic-entry2 ?noimmed ?reg,r/m 0x0f code-c, code-c,
        compile-fields ;

: xmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	0x0F code-c, (xmm-compile) ;

: dxmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	0x66 code-c, xmm-compile ;

: pre-xmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	0xF3 code-c, xmm-compile ;

: pre-dxmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	code-c,  xmm-compile ;

: F2-dxmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	0xF2 pre-dxmm-compile  ;

: 66-dxmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	0x66 pre-dxmm-compile  ;

: dpp-compile ( param -- | x \ param -- | x \ x \ param -- )
	0x66 code-c,  0x0F code-c, 0x3A code-c, true no-do-disp data-!
        true has-xmm-offset? data-! (xmm-compile)  ;

: movd-compile ( param -- | x \ param -- | x \ x \ param -- )
	0x66 code-c, 0x0F code-c,  (movd-compile) ;

: F3-dxmm-compile ( param -- | x \ param -- | x \ x \ param -- )
	0xF3 pre-dxmm-compile  ;


: pf-compile1 ( param -- | x \ param -- | x \ x \ param -- )
        (mmx-dir?)
	xmm/mmx-prefix data-@ 2 =
           if   xmm-dir?
                   if  1+
                   endif
           endif
	?noimmed code-c, compile-fields ;

: 66-pf-compile1 ( param -- | x \ param -- | x \ x \ param -- )
        0x66 code-c, 0x0F code-c, pf-compile1 ;

: 0f-compile1 ( param -- | x \ param -- | x \ x \ param -- )
        0x0F code-c, pf-compile1 ;

: xmm-compile-no-disp ( param -- | x \ param -- | x \ x \ param -- )
	0x0F code-c, true no-do-disp data-! (xmm-compile) ;

: dxmm-compile-no-disp ( param -- | x \ param -- | x \ x \ param -- )
	0x66 code-c, true no-do-disp data-! xmm-compile ;

: shufps-compile ( param -- | x \ param -- | x \ x \ param -- )
	true has-xmm-offset? data-! xmm-compile-no-disp ;

: shufpd-compile ( param -- | x \ param -- | x \ x \ param -- )
	true has-xmm-offset? data-! dxmm-compile-no-disp ;


also forth

: split-imm-opcode ( code-imm - imm code )
	dup 0xff and swap 8 rshift  ;

previous

: ?include-0-immed ( immed - )
    0=
      if   0 code-c,
      then  ;

: cmpps-compile ( param --  )
     split-imm-opcode over >r xmm-compile-no-disp r> ?include-0-immed ;

: cmppd-compile ( param --  )
     split-imm-opcode over >r dxmm-compile-no-disp r> ?include-0-immed ;

: cmpsd-compile ( param --  )
     split-imm-opcode over >r true no-do-disp data-! F2-dxmm-compile r> ?include-0-immed ;

: cmpss-compile ( param --  )
     split-imm-opcode over >r true no-do-disp data-!  F3-dxmm-compile r> ?include-0-immed ;

in-asm
dup-warning-off

     0x47 '    cmovcc-compile opcode cmova
     0x43 '    cmovcc-compile opcode cmovae
     0x42 '    cmovcc-compile opcode cmovb
     0x46 '    cmovcc-compile opcode cmovbe
     0x42 '    cmovcc-compile opcode cmovc
     0x44 '    cmovcc-compile opcode cmove
     0x4f '    cmovcc-compile opcode cmovg
     0x4d '    cmovcc-compile opcode cmovge
     0x4c '    cmovcc-compile opcode cmovl
     0x4e '    cmovcc-compile opcode cmovle
     0x46 '    cmovcc-compile opcode cmovna
     0x42 '    cmovcc-compile opcode cmovnae
     0x43 '    cmovcc-compile opcode cmovnb
     0x47 '    cmovcc-compile opcode cmovnbe
     0x43 '    cmovcc-compile opcode cmovnc
     0x45 '    cmovcc-compile opcode cmovne
     0x4e '    cmovcc-compile opcode cmovng
     0x4c '    cmovcc-compile opcode cmovnge
     0x4d '    cmovcc-compile opcode cmovnl
     0x4f '    cmovcc-compile opcode cmovnle
     0x41 '    cmovcc-compile opcode cmovno
     0x4b '    cmovcc-compile opcode cmovnp
     0x49 '    cmovcc-compile opcode cmovns
     0x45 '    cmovcc-compile opcode cmovnz
     0x40 '    cmovcc-compile opcode cmovo
     0x4a '    cmovcc-compile opcode cmovp
     0x4a '    cmovcc-compile opcode cmovpe
     0x4b '    cmovcc-compile opcode cmovpo
     0x48 '    cmovcc-compile opcode cmovs
     0x44 '    cmovcc-compile opcode cmovz

   0xf0db '    fmisc-compile  opcode fcomi
   0xf0df '    fmisc-compile  opcode fcomip
   0xe8db '    fmisc-compile  opcode fucomi
   0xe8df '    fmisc-compile  opcode fucomip

   0xc0da '    fmisc-compile  opcode fcmovb
   0xc8da '    fmisc-compile  opcode fcmove
   0xd0da '    fmisc-compile  opcode fcmovbe
   0xd8da '    fmisc-compile  opcode fcmovu
   0xc0db '    fmisc-compile  opcode fcmovnb
   0xc8db '    fmisc-compile  opcode fcmovne
   0xd0db '    fmisc-compile  opcode fcmovnbe
   0xd8db '    fmisc-compile  opcode fcmovnu

   0xc0df '    fmisc-compile  opcode ffreep

\  xmm instructions
dup-warning-on
     0x10 '      xmm-compile opcode movups
     0x10 '  66-dxmm-compile opcode movupd
     0x10 '  pre-xmm-compile opcode movss

dup-warning-off
     0x10 '  F2-dxmm-compile opcode movsd
dup-warning-on

     0x12 '     dxmm-compile opcode movlpd

     0x14 '      xmm-compile opcode unpcklps
     0x14 '     dxmm-compile opcode unpcklpd
     0x15 '      xmm-compile opcode unpckhps
     0x15 '     dxmm-compile opcode unpckhpd

     0x16 '     dxmm-compile opcode movhpd

     0x28 '      0f-compile1 opcode movaps
     0x28 '   66-pf-compile1 opcode movapd

     0x2A '      xmm-compile opcode cvtpi2ps
     0x2A '  pre-xmm-compile opcode cvtsi2ss
     0x2A '  F2-dxmm-compile opcode cvtsi2sd

     0x2E '      xmm-compile opcode ucomiss
     0x2E '     dxmm-compile opcode ucomisd

     0x2F '      xmm-compile opcode comiss
     0x2F '     dxmm-compile opcode comisd

     0x51 '      xmm-compile opcode sqrtps
     0x51 '     dxmm-compile opcode sqrtpd
     0x51 '  pre-xmm-compile opcode sqrtss
     0x51 '  F2-dxmm-compile opcode sqrtsd

     0x52 '      xmm-compile opcode rsqrtps
     0x52 '  pre-xmm-compile opcode rsqrtss
     0x52 '  F2-dxmm-compile opcode rsqrtsd

     0x53 '      xmm-compile opcode rcpps
     0x53 '  pre-xmm-compile opcode rcpss
     0x53 '  F2-dxmm-compile opcode rcpds

     0x54 '      xmm-compile opcode andps
     0x54 '     dxmm-compile opcode andpd
     0x55 '      xmm-compile opcode andnps
     0x55 '     dxmm-compile opcode andnpd
     0x56 '      xmm-compile opcode orps
     0x56 '     dxmm-compile opcode orpd
     0x57 '      xmm-compile opcode xorps
     0x57 '     dxmm-compile opcode xorpd

     0x58 '      xmm-compile opcode addps
     0x58 '     dxmm-compile opcode addpd
     0x58 '  pre-xmm-compile opcode addss
     0x58 '  F2-dxmm-compile opcode addsd

     0x59 '      xmm-compile opcode mulps
     0x59 '     dxmm-compile opcode mulpd
     0x59 '  pre-xmm-compile opcode mulss
     0x59 '  F2-dxmm-compile opcode mulsd

     0x5A '      xmm-compile opcode cvtps2pd
     0x5A '  66-dxmm-compile opcode cvtpd2ps
     0x5A '  F2-dxmm-compile opcode cvtsd2ss
     0x5A '  F3-dxmm-compile opcode cvtss2sd

     0x5B '      xmm-compile opcode cvtdq2ps
     0x5B '  66-dxmm-compile opcode cvtps2dq
     0x5B '  F3-dxmm-compile opcode cvttps2dq

     0x5C '      xmm-compile opcode subps
     0x5C '     dxmm-compile opcode subpd
     0x5C '  pre-xmm-compile opcode subss
     0x5C '  F2-dxmm-compile opcode subsd

     0x5D '      xmm-compile opcode minps
     0x5D '     dxmm-compile opcode minpd
     0x5D '  pre-xmm-compile opcode minss
     0x5D '  F2-dxmm-compile opcode minsd

     0x5E '      xmm-compile opcode divps
     0x5E '     dxmm-compile opcode divpd
     0x5E '  pre-xmm-compile opcode divss
     0x5E '  F2-dxmm-compile opcode divsd

     0x5F '      xmm-compile opcode maxps
     0x5F '     dxmm-compile opcode maxpd
     0x5F '  pre-xmm-compile opcode maxss
     0x5F '  F2-dxmm-compile opcode maxsd

     0x6E '     dxmm-compile opcode cvttpd2dq
     0x6E '   movd-compile opcode movd
     0x6F '  66-dxmm-compile opcode movdqa
     0x6F '  F3-dxmm-compile opcode movdqu


   0xC200 '    cmpps-compile opcode cmpeqps
   0xC201 '    cmpps-compile opcode cmpltps
   0xC202 '    cmpps-compile opcode cmpleps
   0xC203 '    cmpps-compile opcode cmpunordps
   0xC204 '    cmpps-compile opcode cmpneqps
   0xC205 '    cmpps-compile opcode cmpnltps
   0xC206 '    cmpps-compile opcode cmpnleps
   0xC207 '    cmpps-compile opcode cmpordps

   0xC200 '    cmppd-compile opcode cmpeqpd
   0xC201 '    cmppd-compile opcode cmpltpd
   0xC202 '    cmppd-compile opcode cmplepd
   0xC203 '    cmppd-compile opcode cmpunordpd
   0xC204 '    cmppd-compile opcode cmpneqpd
   0xC205 '    cmppd-compile opcode cmpnltpd
   0xC206 '    cmppd-compile opcode cmpnlepd
   0xC207 '    cmppd-compile opcode cmpordpd

   0xC200 '    cmpss-compile opcode cmpeqss
   0xC201 '    cmpss-compile opcode cmpltss
   0xC202 '    cmpss-compile opcode cmpless
   0xC203 '    cmpss-compile opcode cmpunordss
   0xC204 '    cmpss-compile opcode cmpneqss
   0xC205 '    cmpss-compile opcode cmpnltss
   0xC206 '    cmpss-compile opcode cmpnless
   0xC207 '    cmpss-compile opcode cmpordss

   0xC200 '    cmpsd-compile opcode cmpeqsd
   0xC201 '    cmpsd-compile opcode cmpltsd
   0xC202 '    cmpsd-compile opcode cmplesd
   0xC203 '    cmpsd-compile opcode cmpunordsd
   0xC204 '    cmpsd-compile opcode cmpneqsd
   0xC205 '    cmpsd-compile opcode cmpnltsd
   0xC206 '    cmpsd-compile opcode cmpnlesd
   0xC207 '    cmpsd-compile opcode cmpordsd

     0xC6 '  shufps-compile opcode shufps
     0xC6 '  shufpd-compile opcode shufpd

     0xD7 '  66-dxmm-compile opcode pmovmskb

     0xE6 '  pre-xmm-compile opcode cvtdq2pd
     0xE6 '  F2-dxmm-compile opcode cvtpd2dq

     0x40 '  dpp-compile     opcode dpps
     0x41 '  dpp-compile     opcode dppd

in-previous only forth also forth definitions

\s
