\ $Id: imagehds.f,v 1.3 2013/03/05 20:46:01 georgeahubert Exp $
\
cr .( Loading Image Headers)

: FLD        ( basevar offset len -<name>- -- basevar offset+len )  \ definer for fields
             create
             3dup + 2>R               \ n1 n2 n3 r: n1 n2+n3
             drop                     \ n1 n2 r: n1 n2+n3
             , , 2R> nostack1         \ build n2 n1
             DOES>  ( -- baseaddr )
               dup @                  \ fetch n2
               swap cell+ @ @ + ;     \ fetch n1 value, add

: FLDBASE    ( -<name>- )         \ set field base name (starts field)
             CREATE here 0 , 0 NOSTACK1 ;  \ base of record

\ ----------------------- PECOFF structure ------------------------

FLDBASE BASE-DOSH
((
         2 FLD         DOSH-MZ          \ "MZ"
         2 FLD         DOSH-CBLP        \ Bytes on last page of file
         2 FLD         DOSH-CP          \ Pages in file
         2 FLD         DOSH-CRLC        \ Relocations
         2 FLD         DOSH-CPARHDR     \ Size of header in paragraphs
         2 FLD         DOSH-MINALLOC    \ Minimum extra paragraphs needed
         2 FLD         DOSH-MAXALLOC    \ Maximum extra paragraphs needed
         2 FLD         DOSH-SS          \ Initial (relative) SS value
         2 FLD         DOSH-SP          \ Initial SP value
         2 FLD         DOSH-CSUM        \ Checksum
         2 FLD         DOSH-IP          \ Initial IP value
         2 FLD         DOSH-CS          \ Initial (relative) CS value
         2 FLD         DOSH-LFARLC      \ File address of relocation table
         2 FLD         DOSH-OVNO        \ Overlay number
         8 FLD         DOSH-RES         \ Reserved words
         2 FLD         DOSH-OEMID       \ OEM identifier (for e_oeminfo)
         2 FLD         DOSH-OEMINFO     \ OEM information; e_oemid specific
        20 FLD         DOSH-RES2        \ Reserved words
         4 FLD         DOSH-FP-PEHEAD   \ pointer to PE section at offset 0x3c
         0 FLD         DOSH-CODE        \ area for code
     0x80 NALIGNED VALUE LEN-DOSH DROP  \ length may be modified
))
     0x80 CONSTANT LEN-DOSH 2DROP       \ prebuilt; length is fixed

FLDBASE BASE-EXEH
4 +   \         4 FLD         EXEH-PE00        \ "PE\0\0"

2 +   \         2 FLD         EXEH-CPUTYPE     \ 0x14c, x86
         2 FLD         EXEH-#SECTS      \ count of sections
         4 FLD         EXEH-TIMEDATE    \ seconds since December 31st, 1969, at 4:00 P.M.
4 +   \         4 FLD         EXEH-FP-SYMB     \ ptr to symbol table
4 +   \         4 FLD         EXEH-#SYMBS      \ number of symbols
2 +   \         2 FLD         EXEH-OPTHEADSIZE \ size of "optional" header
         2 FLD         EXEH-CHARACTER   \ characteristics, 0x10F
2 +   \         2 FLD         EXEH-MAGIC       \ 0x10B (PE32)
1 +   \         1 FLD         EXEH-MAJLINKVER  \ we set to kernel ver (4)
1 +   \         1 FLD         EXEH-MINLINKVER  \ we set to kernel .rev (2)
         4 FLD         EXEH-CODESIZE    \ size of all code sections
         4 FLD         EXEH-INITSIZE    \ size of all initialised
         4 FLD         EXEH-UNINITSIZE  \ size of all uninitialised
         4 FLD         EXEH-RVA-EP      \ entry point
         4 FLD         EXEH-RVA-CODEBASE    \ base of code
         4 FLD         EXEH-RVA-DATABASE    \ base of data
         4 FLD         EXEH-VA-IMAGE    \ base of image
         4 FLD         EXEH-SECTALIGN   \ section alignment
         4 FLD         EXEH-FILEALIGN   \ file alignment
2 +   \         2 FLD         EXEH-MAJOS       \ major os (4)
2 +   \         2 FLD         EXEH-MINOS       \ minor os (0)
         2 FLD         EXEH-MAJIMAGEVER \ major image ver (6.03)
         2 FLD         EXEH-MINIMAGEVER \ minor image ver (build)
2 +   \         2 FLD         EXEH-MAJSUBSYSVER \ major subsys ver (4)
2 +   \         2 FLD         EXEH-MINSUBSYSVER \ minor subsys ver (0)
    4 +  4 FLD         EXEH-IMAGESIZE   \ image size
         4 FLD         EXEH-HEADSIZE    \ headersize
         4 FLD         EXEH-CHECKSUM    \ checksum
         2 FLD         EXEH-SUBSYS      \ subsystem, GUI=2
         2 FLD         EXEH-DLLSYS      \ dll sys, 0
         4 FLD         EXEH-RESSTACK    \ reserve stack
         4 FLD         EXEH-COMSTACK    \ commit stack
         4 FLD         EXEH-RESHEAP     \ reserve heap
         4 FLD         EXEH-COMHEAP     \ commit heap
8 +   \    4 +  4 FLD         EXEH-#DDICT      \ number of dict entries (16)
         8 FLD         EXED-EXPORT      \ addr & len pairs
         8 FLD         EXED-IMPORT      \ set by endimports word
         8 FLD         EXED-RESOURCE
8 +   \         8 FLD         EXED-EXCEPTION
8 +   \         8 FLD         EXED-SECURITY
         8 FLD         EXED-FIXUP
8 +   \         8 FLD         EXED-DEBUG
8 +   \         8 FLD         EXED-ARCHITECTURE
8 +   \         8 FLD         EXED-GLOBALPTR
8 +   \         8 FLD         EXED-TLS
8 +   \         8 FLD         EXED-LOADCONFIG
8 +   \         8 FLD         EXED-BOUNDIMPORT
         8 FLD         EXED-IAT         \ set by endimport word
8 +   \         8 FLD         EXED-DELAYIMPORT
8 +   \         8 FLD         EXED-COM+
8 +   \         8 FLD         EXED-RESERVED
   CONSTANT LEN-EXEH DROP

1 CONSTANT EXE
1 CONSTANT GUI
1 CONSTANT GRAPHICAL
2 CONSTANT DLL
3 CONSTANT CUI

FLDBASE BASE-SECT
         8 FLD         SECT-NAME        \ name, null terminated (if not= 8)
         4 FLD         SECT-VIRTSIZE    \ size in memory
         4 FLD         SECT-RVA         \ address in memory
         4 FLD         SECT-DATASIZE    \ size of data
         4 FLD         SECT-FP-DATA     \ file pointer to data
         4 FLD         SECT-FP-RELOCS   \ file pointer to relocs (0)
         4 FLD         SECT-FP-LINE#    \ fp to linenums
         2 FLD         SECT-#RELOCS     \ set to zero for exe
         2 FLD         SECT-#LINE#      \ set to zero
         4 FLD         SECT-CHARACTER   \ characteristics, see SECTIONTYPE
   CONSTANT LEN-SECT DROP

0x00000020 CONSTANT S-CODE                            \ section constants
0X00000040 CONSTANT S-INIT
0X00000080 CONSTANT S-UNINIT
0X02000000 CONSTANT S-DISCARD
0X10000000 CONSTANT S-SHARE
0X20000000 CONSTANT S-EXECUTE
0X40000000 CONSTANT S-READ
0X80000000 CONSTANT S-WRITE
S-CODE S-EXECUTE S-READ OR OR     CONSTANT STD-CODE \ abbreviation
S-READ S-WRITE   S-INIT OR OR     CONSTANT STD-DATA \ abbreviation

FLDBASE BASE-IID
         4 FLD         IID-RVA-ILT      \ import lookup table
         4 FLD         IID-TIMEDATE     \ time date of binding
         4 FLD         IID-FORWARDER    \ forwarder index
         4 FLD         IID-RVA-NAME     \ RVA to name
         4 FLD         IID-RVA-IAT      \ import address table
   CONSTANT LEN-IID DROP

\ FLDBASE BASE-HINT                       \ not currently used
\          2 FLD         HINT-INDEX       \ hint index
\          0 FLD         HINT-NAME        \ import name
\    VALUE LEN-HINT DROP                  \ modifiable

FLDBASE BASE-EDT                        \ export dictionary table
         4 FLD         EDT-FLAGS        \ EXPORT FLAGS
         4 FLD         EDT-TIMEDATE     \ time date of binding
         4 FLD         EDT-VERSION      \ VERSION
         4 FLD         EDT-DLLNAME      \ NAME RVA
         4 FLD         EDT-ORDBASE      \ ORDINAL BASE
         4 FLD         EDT-#EAT         \ # EAT ENTRIES
         4 FLD         EDT-#NAMES       \ # NAME POINTERS
         4 FLD         EDT-RVA-ADDR     \ ADDRESS TABLE RVA
         4 FLD         EDT-RVA-NAME     \ NAME POINTER TABLE RVA
         4 FLD         EDT-RVA-ORD      \ ORDINAL TABLE RVA
   CONSTANT LEN-EDT DROP

FLDBASE BASE-RELOC                      \ relocation
         4 FLD         RELOC-RVA-PAGE   \ rva of page for relocation table
         4 FLD         RELOC-BLOCKLEN   \ length of the reloc section (from RELOC-RVA-PAGE)
         2 FLD         RELOC-FIXUP      \ 4 bit type, 12 bit offset
   VALUE RELOC-LEN DROP                 \ length, variable

0x0000 CONSTANT RELOC-ABS               \ absolute (a noop)
0x3000 CONSTANT RELOC-HILO              \ high/low relocation (32 bit relocation)

APPINST    VALUE STD-EXELOAD                     \ standard .EXE loadpoint
0x1000     VALUE STD-HEADLEN                     \ .code sectuion starts here



