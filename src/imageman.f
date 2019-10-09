\ $Id: imageman.f,v 1.33 2013/08/14 19:02:37 georgeahubert Exp $

cr .( Loading Imageman.f : Image Manager...)

((

IMAGEMAN builds Windows EXE images.

For documentation on the PECOFF format, see
http://www.microsoft.com/hwdev/hardware/PECOFF.asp. Note: not included because of
copyright restrictions, but freely downloadable. Also see "Peering Inside the PE: A Tour
of the Win32 Portable Executable File Format" by Matt Pietrek, and "An In-Depth Look
into the Win32 Portable Executable File Format", same author, both findable on
http://msdn.microsoft.com.

There is very little documentation on the loader. An exception is "What Goes On Inside
Windows 2000: Solving the Mysteries of the Loader" by Russ Osterlund, also from MSDN.

This quite complex code has 6 major parts.

1. Field definitions using FLDBASE and FLD words.
2. File handling for both .IMG and .EXE file words
3. Section building and writing words
4. Import library building and writing words
5. Header building and writing words
[ 6. Resource copying from module to module (not yet written) ]

Example:
--------

See STD-IMG2EXE for an example at the foot of this code

Commentary:
-----------

VIMAGE                   IMAGEMAN has its own dictionary (because of possible name collisions)
                         so a separate dictionary is used.
COMPACT                  Standard file is built with 4096 (4KBYTE) file sections. COMPACT
                         specifies 512 (0x200) file sections, which builds a smaller EXE file
                         at possibly the expense of slightly longer load times.
s" name" BUILD           Identifies the new image name.
X SUBSYSTEM              where X is CUI (DOS application) or GUI | GRAPHICAL | EXE
                         (Windows), or DLL (Windows DLL)
n LOADPOINT              The loadpoint of the program (default is 0x400000). Must be aligned to
                         a 64K boundary.
n ENTRYPOINT             The (relative) entrypoint address in the section declared CODE
N M STACKSIZE            The reserved and committed stack size. Default is 1Mb, 4K
N M HEAPSIZE             The reserved and committed heap size. Default is 1Mb, 4K
s" name" SECTION         The name of the section, case sensitive and 8 chars max.
n SECTIONTYPE            Section characterisics: S-CODE S-EXECUTE S-READ S-WRITE
                                                 S-INIT S-UNINIT S-DISCARD S-SHARE
                         S-CODE S-EXECUTE: section contains executable code
                         S-READ: section can be read
                         S-WRITE: section can be written
                         S-INIT: section contains initialised data
                         Default is none
                         Can appear multiple times for one section
                         STD-CODE is S-INIT S-CODE S-EXECUTE OR OR
                         STD-DATA is S-INIT S-READ S-WRITE OR OR
N M SECTIONDATA          Address and length of the section
N SECTIONRVA             Not normally used, but can set the (relative) address of the section
N SECTIONSIZE            Size of section. Must be equal to or longer than the sectiondata. When
                         loaded, the section will zeroed and padded out to this length with zeros.
                         Optional, set to size of the section data
ENDSECTION               Required to end a section
s" implib" IMPLIB        Import library name
N s" name" IMPORT        Import the procedure <-name-> with a hint of N. N can be zero, but the
                         correct hint will speed (marginally) load time.
ENDIMPORTS ( -- N M )    Required to end the imports sections, follow with SECTIONDATA
ENDBUILD                 Creates the image from the information given above.

s" name" IMAGE-LOAD      Loads a .IMG file for subsequent conversion. Sets the following
                         words as a side effect;
                           IMAGE-PTR       pointer to the loaded image
                           IMAGE-CODEPTR   pointer to the code section
                           IMAGE-CACTUAL   real size of code section
                           IMAGE-CSIZE     virtual size of code section
                           IMAGE-APPPTR IMAGE-AACTUAL IMAGE-ASIZE ditto APP values
                           IMAGE-SYSPTR IMAGE-SACTUAL IMAGE-SSIZE and SYS values
                           IMAGE-ENTRY     relative offset of entry point

Requirements/restrictions:
--------------------------

Keyword order is important. The following MUST appear in the following order:

  BUILD SECTION ENDBUILD

  SECTION / ENDSECTION must enclose SECTIONDATA and optionally
  SECTIONTYPE and SECTIONRVA keywords.

  SECTION / ENDSECTION must enclose IMPLIB and IMPORT

  ENDIMPORTS must terminate IMPLIB and IMPORT, and must be followed by SECTIONDATA

Other keywords can appear in any order anywhere between BUILD and ENDBUILD.

Sections are always aligned in memory on 4K boundaries. Each section follows the next in
memory. So, the following sections:

                 SECTION .code
        a 0x1234 SECTIONDATA
                 ENDSECTION
                 SECTION .extra
        a 0x1120 SECTIONDATA
                 ENDSECTION

The first section always starts on 0x1000. Section #1 will start at 0x1000, and be
0x1234 bytes padded out to the next 4K boundary (out to 0x2FFF). Section #2 will start
at 0x3000, be 0x1120 bytes padded out to 0x4FFF, etc. The .idata section should be
written last.

The entry point is calculated from the start of the last section marked as S-CODE or
S-EXECUTE .

No resource section is built (section .rsrc). To be addressed. (Tough one, as the format
isn't documented properly.)

The DLL type is currently ignored.

WATCH OUT! for name collisions. Only specify VIMAGE as a vocabulary if you're not
compiling code, please.


Defaults:
---------
             BUILD
             GUI SUBSYSTEM
             0x400000 LOADPOINT
             0x100000 4KBYTE STACKSIZE
             0x100000 4KBYTE HEAPSIZE

             n SECTIONRVA
             n SECTIONSIZE

))

IN-APPLICATION

WINLIBRARY IMAGEHLP.DLL
3 PROC MapFileAndCheckSum             \ helper; checksum for PE
2 PROC SystemTimeToFileTime
1 PROC GetSystemTimeAsFileTime

IN-SYSTEM

BASE @ DECIMAL NOSTACK1

\ Moved the 2 values to the Forth Vocabulary to be Findable.

\ TRUE  VALUE CONSOLE-DLL?      \ W32F       Forth System Imageman
\ *G Set to true if your app needs the w32fConsole.dll.
\ *G No longer used since w32fconsole.dll is useless now that we have new console
FALSE VALUE SCINTILLA-DLL?    \ W32F       Forth System Imageman
\ *G Set to true if your app needs the w32fScintilla.dll.

VOCABULARY VIMAGE
PRIVATE VIMAGE INTERNAL

SYS-FLOAD SRC\IMAGEHDS.F                      \ image header file

\ ---------------- File handling PE image --------------------------

CREATE PEIMG-NAME MAXSTRING ALLOT

-1 VALUE PEIMG-HNDL

: ?PEIMG-FERROR  ( flag -- )
                 if
                 cr ." File '"
                 PEIMG-NAME count type ." ' : "
                   WinErrMsg ON GetLastWinErr
                 then ;

: PEIMG-FCREATE  ( -- )
                 PEIMG-NAME COUNT r/w create-file ?PEIMG-FERROR
                 to PEIMG-HNDL ;

: PEIMG-FOPEN    ( -- )
                 PEIMG-NAME COUNT r/w open-file ?PEIMG-FERROR
                 to PEIMG-HNDL ;

: PEIMG-FCLOSE   ( -- )
                 PEIMG-HNDL CLOSE-FILE ?PEIMG-FERROR
                 -1 to PEIMG-HNDL ;

: PEIMG-FWRITE   ( addr len -- )
                 PEIMG-HNDL WRITE-FILE ?PEIMG-FERROR ;

: PEIMG-FREPOS   ( n -- )                            \ reposition file
                 s>d PEIMG-HNDL REPOSITION-FILE ?PEIMG-FERROR ;

: PEIMG-FPOS     ( -- n )                            \ file position
                 PEIMG-HNDL FILE-POSITION ?PEIMG-FERROR
                 d>s ;

0x1000   CONSTANT 4KBYTE
0x100000 CONSTANT 1MBYTE

4KBYTE VALUE LEN-HEAD                               \ header length, see compact
4KBYTE VALUE FILE-ALIGN                             \ file alignment, see compact
0 VALUE HEAD-BUFF                                   \ header buffer
0 VALUE ZERO-BUFF                                   \ binary zeros for padding
0 VALUE IMPS-BUFF                                   \ import section buffer

: PEIMG-PADWRITE ( addr len -- )                     \ write zero padded block
                 DUP>R PEIMG-FWRITE
                 ZERO-BUFF
                 R@ EXEH-FILEALIGN @ NALIGNED        \ align to image file alignment
                 R> - PEIMG-FWRITE                   \ what's left to write
                 ;

0 VALUE IMAGE-PTR
0 VALUE IMAGE-CODEPTR
0 VALUE IMAGE-APPPTR
0 VALUE IMAGE-SYSPTR
0 VALUE IMAGE-CACTUAL
0 VALUE IMAGE-AACTUAL
0 VALUE IMAGE-SACTUAL
0 VALUE IMAGE-CSIZE
0 VALUE IMAGE-ASIZE
0 VALUE IMAGE-SSIZE
0 VALUE IMAGE-CSEP
0 VALUE IMAGE-ASEP
0 VALUE IMAGE-SSEP
0 VALUE IMAGE-ENTRY
0 VALUE IMAGE-ORIGIN

((

\ ------------------------- Resource file  ------------------------

CREATE RES-NAME MAXCOUNTED ALLOT
-1 VALUE RES-HNDL
0 VALUE RES-PTR
0 VALUE RES-LEN

\ ------------------------- Resource building ------------------------

: RES-FOPEN      ( -- )
                 RES-NAME COUNT r/w open-file ?PEIMG-FERROR
                 to RES-HNDL ;

: RES-FSIZE      ( -- n )
                 RES-HNDL file-size ?PEIMG-FERROR
                 abort" File too large to process"
                 ;

: RES-LOAD       ( addr len -- )                        \ read IMAGE
                 RES-NAME PLACE                        \ image name
                 cr ." Resource: " RES-NAME count type
                 RES-FOPEN                               \ open it
                 RES-FSIZE                               \ get file size
                 dup TO RES-LEN                          \ save as length
                 dup malloc dup to RES-PTR               \ allocate storage
                 swap RES-HNDL read-file abort" Error reading file"
                 drop RES-HNDL close-file drop
                 ;

: RESOURCE       ( assr len -- addr len )               \ add resource to .exe
                 RES-LOAD                               \ .res name before this
                 RES-PTR RES-LEN ;

))

\ ------------------------- Section building --------------------------

\ INTERNAL

0 VALUE HEAD-BASESECT                                 \ base of section ptr
0 VALUE PREV-SECTRVA                                  \ previous section's RVA

: SECTINIT   ( -- )                                   \ initialise
             0 EXEH-#SECTS W!                         \ no sections
             4KBYTE to PREV-SECTRVA                   \ previous RVA
             ;

: SECTIONTYPE ( n -- )                                \ section characteristics
             SECT-CHARACTER @ OR SECT-CHARACTER ! ;   \ or them in

: SECTION    ( addr len -- )                          \ section name code
             EXEH-#SECTS W@ LEN-SECT *                \ offset for this section
             HEAD-BASESECT + BASE-SECT !              \ set as section base
             EXEH-#SECTS W@ 1+ EXEH-#SECTS W!         \ current section number
             8 MIN 2DUP LOWER                         \ parse out the string
             SECT-NAME SWAP CMOVE                     \ and move to dest
             PREV-SECTRVA SECT-RVA !                  \ in case no rva specified
             ;

: SECTIONRVA ( n -- ) SECT-RVA ! ;                    \ RVA of section

: SECTIONSIZE ( n -- )                                \ section virtual size
             SECT-VIRTSIZE @ NEGATE +TO PREV-SECTRVA  \ remove existing length
             4KBYTE NALIGNED DUP SECT-VIRTSIZE !      \ align to 4k boundary
             +TO PREV-SECTRVA                         \ add in to length
             ;

: SECTIONDATA ( addr len -- )                         \ section data, some fields get filled later
             DUP SECT-DATASIZE !                      \ length of real data
             SECTIONSIZE                              \ and it's the default section size too
             SECT-FP-DATA !                           \ will become file ptr when written
             ;

: ENDSECTION ( -- )                                   \ tidy up section
             SECT-DATASIZE @ EXEH-SECTALIGN @ NALIGNED >R \ put aligned datasize on rstack
             SECT-CHARACTER @ DUP
             S-CODE S-EXECUTE OR AND
             IF                                       \ is section code?
               R@ EXEH-CODESIZE +!                    \ add to code size
               SECT-RVA @ EXEH-RVA-CODEBASE !         \ set codebase rva
             THEN DUP
             S-INIT AND
             IF                                       \ is section init?
               R@ EXEH-INITSIZE +!                    \ add to init size
               SECT-RVA @ EXEH-RVA-DATABASE !         \ set database rva
             THEN DUP
             S-UNINIT AND
             IF                                       \ is this uninited?
               R@ EXEH-UNINITSIZE +!                  \ add to uninit size
             THEN
             drop R>DROP

             BASE-SECT @ LEN-SECT + BASE-DOSH @ -     \ max address in header
             FILE-ALIGN NALIGNED TO LEN-HEAD          \ adjust the length of the header

             ;

: SECTWRITE  ( -- )                                   \ write out sections
             EXEH-#SECTS W@ 0 ?DO                     \ now each section
               HEAD-BASESECT I LEN-SECT * + BASE-SECT ! \ set as section base
               PEIMG-FPOS                             \ get where we are
               SECT-FP-DATA @                         \ address of data
               SECT-DATASIZE @ DUP>R                  \ len to write, save on rstack
               PEIMG-PADWRITE                         \ write out the section padded
               SECT-FP-DATA !                         \ update header where we wrote the data
               R> FILE-ALIGN NALIGNED SECT-DATASIZE ! \ adjust header
             LOOP
             SECT-VIRTSIZE @ SECT-RVA @ + EXEH-IMAGESIZE ! \ imagesize is max address when loaded
             ;

\ -------------------------- RVA calculation -------------------------

0 VALUE  RVA-BUFF
: ->RVA      ( n -- n' )                              \ convert to RVA
             RVA-BUFF SECT-RVA @ - - ;               \ from start of header

\ -----------------------Import Function building --------------------

((

   IMPLIB-LINK --> | next | func |      | .... | library name

 "next" pointer points to a list of all libraries (IMPLIBs)
 "func" pointer points to a list of functions in this library (IMPORTs in IMPLIB)

   IMPFUNC-LINK -> | next | func |      | .... | function name

 "next" pointer points to a list of all functions (IMPORT)
 "func" pointer points to a list of functions in this library (IMPORTs in IMPLIB)

 Uses structure based on BASE-IMPSTR

))

VARIABLE IMPLIB-LINK                                  \ head of IMPLIBs
VARIABLE IMPFUNC-LINK                                 \ head of IMPORTS
0 VALUE  IMPLIB-COUNT                                 \ count of IMPLIBS
0 VALUE  IMPFUNC-COUNT                                \ count of IMPORTS
0 VALUE  IMPSTR-BUFF                                  \ temp buffer

FLDBASE BASE-IMPSTR
      CELL FLD IMP-NEXT                               \ next ptr
      CELL FLD IMP-FUNC                               \ func ptr *must be second*
      CELL FLD IMP-RVA                                \ RVA of field
        4  FLD IMP-HINT                               \ hint, only for functions
       33  FLD IMP-NAME                               \ name counted string, max id length is 33
   ALIGNED CONSTANT IMP-LEN DROP                      \ length


: IMPINIT    ( -- )                                   \ initialise import
             IMPLIB-LINK OFF
             IMPFUNC-LINK OFF
             0 TO IMPLIB-COUNT
             0 TO IMPFUNC-COUNT
             ;

: IMPSTR     ( addr len link -- )                     \ scan, allocate string
             >R IMPSTR-BUFF BASE-IMPSTR !             \ save link, allocate and set base
             IMP-LEN +TO IMPSTR-BUFF
             IMP-NEXT R> add-link                     \ add as link
             IMP-NAME PLACE                           \ point at name, move it
             ;

: IMPLIB     ( addr len -- )                          \ define library name
             IMPLIB-LINK IMPSTR                       \ allocate the string
             1 +TO IMPLIB-COUNT
             ;

: IMPORT     ( n addr len -- )                        \ define proc in the above library
             IMPFUNC-LINK IMPSTR                      \ allocate the procname
             IMP-HINT !                               \ save the hint
             IMP-FUNC IMPLIB-LINK @ CELL+ add-link    \ point at last library func link, add link
             1 +TO IMPFUNC-COUNT
             ;

((

 Add imports a stand-alone section normally called .idata. Section must be declared.

 Steps:

 Build a dummy IAT (import address table)
 Build an ILT (import lookup table). Identical to IAT.
 Build the IIDs, one per library
 Build the lib names, remember where we put them (write into the linked list at IMP-RVA)
 Build the hint/func names, remember where we put them

 If section isn't big enough, make it larger (we haven't written it yet)

 End result is this:

 IID1:                      ILT          FUNCS              IAT
   IID-RVA-ILT ----------> |   | ---> | hint | func | <--- |   |  <--1
   IID-TIMEDATE            | 0 |                           | 0 |
   IID-FORWARDER      +--> |   | ---> | hint | func | <--- |   |  <--+
   IID-RVA-NAME --... |    |   | ---> | hint | func | <--- |   |     |
   IID-RVA-IAT -->1   |    | 0 |                           | 0 |     |
 IID2:                |     ...                             ...      |
   IID-RVA-ILT -------+                                              |
   IID-TIMEDATE                                                      |
   IID-FORWARDER                                                     |
   IID-RVA-NAME ---> libname                                         |
   IID-RVA-IAT ------------------------------------------------------+
 ...

 # of IIDs = IMPLIB-COUNT + 1
 # of ILT entries = IMPLIB-COUNT + IMPFUNC-COUNT (same for IAT)

 IAT is built first, and is the table modified by the loader to contain load addresses.
 Note that the entries are built back-to-front from the declaration order -- the last function
 in the last library appears first, and the first appears last.

))

((
0 VALUE  CURR-IID                                     \ current IID
0 VALUE  CURR-ILT                                     \ current ILT section
0 VALUE  CURR-FUNCS                                   \ current funcs section
0 VALUE  CURR-IAT                                     \ current IAT section
0 VALUE  LEN-IAT                                      \ length of IAT
0 VALUE  LEN-ALLIIDS                                  \ length of all IIDs
))
\

: MOVE-NAME { src dest -- len }
      SRC COUNT 1+ ALIGNED >R DEST R@ CMOVE           \ copy the library name
      R> ;                                            \ length of target

: ENDIMPORTS ( -- addr len )                          \ build import words, return buffer
    { \ CURR-IID CURR-ILT CURR-FUNCS
        CURR-IAT LEN-IAT LEN-ALLIIDS }                \ temporaries

    IMPS-BUFF TO RVA-BUFF                             \ so RVA calculation is correct
    IMPLIB-COUNT 1+ LEN-IID * TO LEN-ALLIIDS          \ length of all IIDs
    IMPLIB-COUNT IMPFUNC-COUNT + CELLS TO LEN-IAT     \ length of IAT

    IMPS-BUFF TO CURR-IAT                             \ base of import stuff in header id IID
    CURR-IAT LEN-IAT + TO CURR-ILT                    \ pointer to IAT
    CURR-ILT LEN-IAT + TO CURR-IID                    \ pointer to funcs
    CURR-IID LEN-ALLIIDS + TO CURR-FUNCS              \ pointer to ILT

    CURR-IID ->RVA EXED-IMPORT !                      \ point at imports
    LEN-ALLIIDS EXED-IMPORT CELL+ !                   \ length of IIDs

    CURR-IAT ->RVA EXED-IAT !                         \ point at IAT
    LEN-IAT EXED-IAT CELL+ !                          \ length of IAT

    IMPLIB-LINK                                       \ loop through the libraries
    BEGIN @ ?DUP WHILE
      DUP BASE-IMPSTR !                               \ point at IMPSTR with lib name in it
      CURR-IID BASE-IID !                             \ set base of IID to current
      CURR-ILT ->RVA IID-RVA-ILT !                    \ point at ILT
      CURR-IAT ->RVA IID-RVA-IAT !                    \ point at IAT

      CURR-FUNCS ->RVA IID-RVA-NAME !                 \ point as RVA from header to lib
      IMP-NAME CURR-FUNCS MOVE-NAME +TO CURR-FUNCS    \ copy the library name (padded)

      BEGIN IMP-FUNC @ ?DUP WHILE
         CELL- BASE-IMPSTR !                          \ point at func impstr
         CURR-FUNCS ->RVA DUP CURR-ILT ! CURR-IAT !   \ point ILT and IAT at func
         IMP-HINT @ CURR-FUNCS W! 2 +TO CURR-FUNCS    \ save hint, move on two bytes
         IMP-NAME CURR-FUNCS MOVE-NAME +TO CURR-FUNCS \ copy the function name (padded)
         CELL +TO CURR-ILT CELL +TO CURR-IAT          \ update ILT/IAT pointers
      REPEAT

      CELL +TO CURR-ILT CELL +TO CURR-IAT             \ update ILT/IAT pointers (zero entry)
      LEN-IID +TO CURR-IID                            \ next IID
    REPEAT

    IMPS-BUFF CURR-FUNCS ->RVA SECT-RVA @ -           \ calculate addr & length
    ;

\ ------------------------- Resource building --------------------------

: RESOURCES  ( addr len -- )                          \ build resource
                                                      \ dummy right now
        2DROP                                         \ filename
        ZERO-BUFF 1                  SECTIONDATA
        SECT-RVA @ EXED-RESOURCE !
        ;

\ ------------------------- Header building --------------------------

CREATE BDT                              \ base date struct for FileTimeToSystemTime
        1970 W,                         \ +0  wYear   WED 1ST JAN 1970 AT 00:00:00 HRs
        1    W,                         \ +2  wMonth
        4    W,                         \ +4  wDayOfWeek
        1    W,                         \ +6  wDayOfMonth
        0    W,                         \ +8  wHour
        0    W,                         \ +10 wMinute
        0    W,                         \ +12 wSecond
        0    W,                         \ +14 wMilliseconds

: LINKTIME  ( -- n )                                \ secs since date above
             0 0 SP@ CALL GetSystemTimeAsFileTime DROP SWAP \ get current time
             0 0 SP@ BDT CALL SystemTimeToFileTime DROP SWAP \ get Wed 1st Jan 1970
             D- 1 10000000 M*/ D>S                   \ adjust as # secs (was 100ns)
             ;

: CHECKSUM   ( -- n )
             0 SP@ >R                       \ pass two dwords
             0 SP@ R>
             PEIMG-NAME 1+                  \ name of file
             CALL MapFileAndCheckSum 0<> ABORT" Failed to checksum file"
             nip ;

((
CREATE DOSCODE HERE 0 C, NOSTACK1                   \ dos code stub as counted string
             0x0E C, 0x1F C, 0xBA C, 0x0E C,
             0x00 C, 0xB4 C, 0x09 C, 0xCD C,
             0x21 C, 0xB8 C, 0x01 C, 0x4C C,
             0xCD C, 0x21 C,
             HERE OVER - 1- SWAP C!                 \ save length

CREATE DOSMESG HERE NOSTACK1
             ," This program cannot be run in DOS mode"
             -null,
             0x0D C, 0x0D C, 0x0A C, CHAR $ C,
             HERE OVER - 1- SWAP C!                 \ save length
))

0 VALUE BUILDTYPE                                   \ EXE or DLL

: SUBSYSTEM  ( m -- )                                 \ declare subsystem
             CASE
             DLL OF
                0x210F EXEH-CHARACTER W! ENDOF        \ DLL
             CUI OF
                3 EXEH-SUBSYS W! ENDOF                \ CUI
             ENDCASE
             ;

: LOADPOINT  ( n -- ) EXEH-VA-IMAGE ! ;               \ declare loadpoint
: ENTRYPOINT ( n -- ) EXEH-RVA-EP ! ;                 \ declare entrypoint
: STACKSIZE  ( r c -- ) EXEH-COMSTACK ! EXEH-RESSTACK ! ; \ declare stack
: HEAPSIZE   ( r c -- ) EXEH-COMHEAP ! EXEH-RESHEAP ! ; \ declare heap
: COMPACT    ( -- ) 0x200 DUP TO FILE-ALIGN TO LEN-HEAD ; \ build a compact header

: BUILD      ( addr len -- )                          \ declare new image
             PEIMG-NAME MAXSTRING ERASE               \ clear image name
             PEIMG-NAME PLACE                         \ image name
             [ 4KBYTE 4 * ] LITERAL DUP>R MALLOC DUP R> ERASE \ temp buffers
                               DUP TO HEAD-BUFF
               4KBYTE +        DUP TO ZERO-BUFF
               4KBYTE +        DUP TO IMPS-BUFF
               4KBYTE +            TO IMPSTR-BUFF
             HEAD-BUFF DUP  BASE-DOSH !               \ set base DOS header address
             LEN-DOSH + dup BASE-EXEH !               \ base image
             LEN-EXEH + dup BASE-SECT !               \ base section headers
                            TO HEAD-BASESECT          \ and the save ptr

             appInst HEAD-BUFF LEN-DOSH LEN-EXEH + CMOVE \ copy my own exe header
((
     ( MZ )  0x5A4D      DOSH-MZ W!                   \ set MZ
             0x90        DOSH-CBLP     W!             \ fill out dos header
             0x3         DOSH-CP       W!
             0x4         DOSH-CPARHDR  W!
             0xFFFF      DOSH-MAXALLOC W!
             0xB8        DOSH-SP       W!
             0x40        DOSH-LFARLC   W!
             LEN-DOSH    DOSH-FP-PEHEAD !             \ set PE ptr
             DOSCODE COUNT DUP>R DOSH-CODE SWAP CMOVE \ set code
             DOSMESG COUNT DOSH-CODE R> + SWAP CMOVE  \ add on message

    ( PE00 ) 0x4550      EXEH-PE00 !                  \ PE\0\0
             0x014C      EXEH-CPUTYPE W!              \ CPU type = 80386
             0x00E0      EXEH-OPTHEADSIZE W!          \ opt header size

             0x010B      EXEH-MAGIC      W!           \ PE32
             0x0         EXEH-MAJLINKVER C!           \ link ver 0.91
             0x91        EXEH-MINLINKVER C!
             4KBYTE      EXEH-SECTALIGN    !          \ 4k section align
             0x4         EXEH-MAJOS        W!
             0x0         EXEH-MINOS        w!
             0x4         EXEH-MAJSUBSYSVER W!
             0x0         EXEH-MINSUBSYSVER W!
             0x10        EXEH-#DDICT       !          \ 16 dict entries
))
             0           EXEH-CODESIZE    !
             0           EXEH-INITSIZE    !
             2           EXEH-SUBSYS      W!          \ EXE subsystem
             0x010F      EXEH-CHARACTER   W!          \ No relocs|linenums|symbols|32 bit app
             LINKTIME    EXEH-TIMEDATE !              \ time

             FILE-ALIGN  EXEH-FILEALIGN    !          \ n BYTE file align (mult of 512 bytes)
             version# 0 10000 sm/rem                  \ derive major/minor from version#
                         EXEH-MAJIMAGEVER  W!
                         EXEH-MINIMAGEVER  W!
             LEN-HEAD    EXEH-HEADSIZE     !          \ n byte header size (mult of filealign)

             APPINST LOADPOINT
             1MBYTE 4KBYTE STACKSIZE
             1MBYTE 4KBYTE HEAPSIZE

             IMPINIT                                  \ initialise
             SECTINIT
             ;

: ENDBUILD   ( -- )                                   \ fixup all the missing info
             cr ." Building image " PEIMG-NAME COUNT TYPE
             PEIMG-FCREATE                            \ create the file

             FILE-ALIGN  EXEH-FILEALIGN    !          \ n BYTE file align (mult of 512 bytes)
             LEN-HEAD    EXEH-HEADSIZE     !          \ n byte header size (mult of filealign)
             ZERO-BUFF LEN-HEAD PEIMG-PADWRITE        \ write out a dummy header

             SECTWRITE                                \ write out sections
             PEIMG-FPOS >R                            \ get file position
             0 PEIMG-FREPOS                           \ position to 0

             HEAD-BUFF LEN-HEAD PEIMG-PADWRITE        \ rewrite corrected header
             PEIMG-FCLOSE

             cr ." Generating checksum "
             CHECKSUM DUP h.
             PEIMG-FOPEN                              \ re-open file
             EXEH-CHECKSUM BASE-EXEH @ - LEN-DOSH +   \ offset of checksum field in file
             PEIMG-FREPOS                             \ position to the checksum
             SP@ 4 PEIMG-FWRITE DROP                  \ write out changed checksum
             PEIMG-FCLOSE

             R> cr ." Built length " dup . ." (" 1 H.R ." h) bytes"

             HEAD-BUFF release                        \ release storage

             ;


\ ------------------ Standard EXE build from .IMG --------------------------

GUI VALUE EXETYPE

: std-IMG2EXE ( addr len -- )            \ compose STD image, addr/len is name

      COMPACT                            \ compact header
      BUILD                              \ exe name

        EXETYPE          SUBSYSTEM       \ normally GUI
        STD-EXELOAD      LOADPOINT
        1MBYTE 0xA000    STACKSIZE
        1MBYTE 0x8000    HEAPSIZE
        IMAGE-ENTRY      ENTRYPOINT

        s" .code"                  SECTION
        STD-CODE S-WRITE or           SECTIONTYPE
        IMAGE-CODEPTR IMAGE-CACTUAL   SECTIONDATA
        IMAGE-CSIZE                   SECTIONSIZE
                                   ENDSECTION

        s" .app"                   SECTION
        STD-DATA                     SECTIONTYPE
        IMAGE-APPPTR IMAGE-AACTUAL   SECTIONDATA
        IMAGE-ASIZE                  SECTIONSIZE
                                   ENDSECTION

      IMAGE-SACTUAL IF                   \ might be a TURNKEY, so don't write section
        s" .sys"                   SECTION
        STD-DATA                     SECTIONTYPE
        IMAGE-SYSPTR IMAGE-SACTUAL   SECTIONDATA
        IMAGE-SSIZE                  SECTIONSIZE
                                   ENDSECTION
      THEN

        s" .idata"                 SECTION
        S-INIT S-READ OR             SECTIONTYPE
\         EXETYPE CUI <> CONSOLE-DLL? and IF         \ if not a DOS app
\           s" W32FCONSOLE.DLL"        IMPLIB        \ force load of the DLL, required
\           0 s" c_initconsole"          IMPORT
\         THEN
\ [cdo] Aug 2008 - w32fconsole.dll no longer used since we have new console
        SCINTILLA-DLL? IF
          s" w32fScintilla.dll"      IMPLIB        \ force load of the DLL, required
          0 s" Scintilla_DirectFunction@16" IMPORT
        THEN

        s" KERNEL32.DLL"             IMPLIB
          0 s" GetProcAddress"         IMPORT
          0 s" LoadLibraryA"           IMPORT
                                     ENDIMPORTS    \ ( -- addr len)
                                     SECTIONDATA
                                   ENDSECTION

        s" .rsrc"                  SECTION
        S-INIT S-READ OR             SECTIONTYPE
        s" DUMMY"                    RESOURCES
                                   ENDSECTION

      ENDBUILD
      ;

External


\ ---------------- In memory image handling ---------------------

: PTABL          ( -- )
                 cr ." -------" tab ." ---------" tab ."  ------" tab ." -------"
                 ;

: PORIG          ( n -- )
                 tab IMAGE-ORIGIN + 8 H.R ." h" ;

: PSIZE          ( n -- )
                 tab 7 .r ;

: IMAGE-STATS    ( -- )                                  \ image statistics
                 tab-size 10 to tab-size
                 cr ." Entry point at " IMAGE-ENTRY dup 1 H.r ." h (" IMAGE-ORIGIN + 1 H.r ." h)"
                 cr ." Segment" tab ."  Origin" tab   ."   Size" tab  ."  Alloc"

                 PTABL

                 CR ." CODE  " IMAGE-CSEP PORIG
                               IMAGE-CACTUAL PSIZE IMAGE-CSIZE PSIZE
                 CR ." APP   " IMAGE-ASEP PORIG
                               IMAGE-AACTUAL PSIZE IMAGE-ASIZE PSIZE
                 CR ." SYSTEM" IMAGE-SSEP PORIG
                               IMAGE-SACTUAL PSIZE IMAGE-SSIZE PSIZE

                 PTABL

                 cr ." Total" tab IMAGE-AACTUAL IMAGE-SACTUAL IMAGE-CACTUAL + + PSIZE
                 cr to tab-size
                 ;

CREATE ZERO-WORDS  \ words to be zeroed on image-copy
                   \ these must be IN-APPLICATION!
\                &EXCEPT           ,            \ zero last exception
                 ' INH >BODY       ,            \ zero stdin  DOS console
                 ' OUTH >BODY      ,            \ zero stdout DOS console
                 >IN               ,            \ zero >in
                 ' SOURCE-ID >BODY ,            \ and source-id
                 0                 ,            \ end of list


: IMAGE-COPY     ( -- )                         \ copy & adjust the current image
((

  IMAGE-COPY takes a copy of the currently running exececutable, and builds an image suitable for
  FSAVEing. There are some things that can't be saved;
    - the state of any files or their file handles
    - any dynamically allocated areas
    - transient areas
    - and there may be others

  Once the image is copied, some variables (see ZER-WORDS above) are cleared out so that the
  image will properly initialise next time it's loaded. More initialisation is done in the
  kernel (see MAIN in the kernel). It's debatable where this should be done; this method
  currently works, and keeps some of the junk out of the kernel.

))
                 TURNKEYED? IF
                   0                             \ not saving sys header, set zero
                 ELSE
                   SYS-HERE SYS-ORIGIN - THEN    \ else current sys/header size
                 CODE-HERE CODE-ORIGIN -         \ current code size
                 APP-HERE  APP-ORIGIN  -         \ current app size
                 3DUP                            \ move to actuals
                 TO IMAGE-AACTUAL
                 TO IMAGE-CACTUAL
                 TO IMAGE-SACTUAL
                 3DUP + + MALLOC TO IMAGE-PTR    \ allocate buffer

                 APP-ORIGIN  IMAGE-PTR ROT 2DUP + >R CMOVE \ move the app part, save next addr
                 CODE-ORIGIN        R> ROT 2DUP + >R CMOVE \ move the code part, save next addr
                 SYS-ORIGIN         R> ROT           CMOVE \ move the system part (could be zero)

                 IMAGE-PTR           DUP TO IMAGE-APPPTR   \ odd due to way built (app is at front)
                     IMAGE-AACTUAL + DUP TO IMAGE-CODEPTR
                     IMAGE-CACTUAL +     TO IMAGE-SYSPTR

                 APP-SIZE  TO IMAGE-ASIZE        \ copy constants we need to write image
                 CODE-SIZE TO IMAGE-CSIZE
                 SYS-SIZE  TO IMAGE-SSIZE
                 APP-OFFS  TO IMAGE-ASEP
                 CODE-OFFS TO IMAGE-CSEP
                 SYS-OFFS  TO IMAGE-SSEP
                 IMG-ENTRY TO IMAGE-ENTRY
                 STD-EXELOAD TO IMAGE-ORIGIN
                 IMAGE-PTR APP-ORIGIN - >R       \ adjust to app origin

                 ZERO-WORDS                      \ list of app words to zero
                 BEGIN DUP CELL+ SWAP @ ?DUP
                 WHILE
                   R@ SWAP + OFF                 \ zero in the copy, not the executing image
                 REPEAT R>DROP DROP

                 pre-save-image-chain do-chain   \ do any extra manipulations

                 IMAGE-STATS
                 ;


Internal

\ ------------------------------------------------------------------------------
\ Helper words for Image manipulation
\ ------------------------------------------------------------------------------

: >IMAGE-APP    ( Addr1 -- Addr2 )
                APP-ORIGIN - IMAGE-APPPTR + ;

: >IMAGE-SYS    ( Addr1 -- Addr2 )
                SYS-ORIGIN - IMAGE-SYSPTR + ;

: >IMAGE-CODE   ( Addr1 -- Addr2 )
                CODE-ORIGIN - IMAGE-CODEPTR + ;

EXTERNAL

: >IMAGE        ( Addr1 -- Addr2|false )
                dup in-app-space? if >image-app else
                dup in-sys-space? if >image-sys else
                dup in-code-space? if >image-code else
                drop false then then then ;

: IN-IMAGE?     ( Addr1 -- flag )
                dup in-app-space? over in-sys-space? or swap in-code-space? or ;

: is-image      ( xt "name" -- ) \ preset a defer to xt
                ?comp ' >body postpone literal postpone >image postpone ! ; immediate

\ ------------------------------------------------------------------------------
\ General boot words
\ ------------------------------------------------------------------------------

IN-APPLICATION

Defer Default-application ' bye  is default-application
Defer DoConsoleBoot       ' noop is DoConsoleBoot
0 Value ConsoleMode

4 proc MessageBox

: MsgBox        ( addr len -- ) \ display a message + OK (needs no console)
                [ MB_OK MB_TASKMODAL or ] literal
                z" Notice!"
                2swap asciiz
                0
                Call MessageBox drop ;

: GeneralBoot   ( -- ) \ boot word to be used with any program other than Forth itself
                initialization-chain do-chain

                StopLaunching
                if   s" Multiple instances are not allowed\nIf no instance seems to be running :\n- Either check for any minimized instance in task bar\n- Or kill any ghost instance in task manager (Ctrl+Alt+Del)" MsgBox
                     bye
                then

                DoConsoleBoot

                exception@
                if   Empty-command-line               \ reset commandline
                     s" Exception occured in Forth initialization" MsgBox
                     \ .exception ?
                else ?EnableConsoleMessages

                     action-of default-application catch
                     if s" Exception occured in program" MsgBox bye then

                     action-of key                  \ start a message loop if no
                     ['] k_noop1 =                  \ console message loop
                     if MessageLoop then
                then
                bye ;

\ Note: the kernel's MAIN does the following :
\       - crucial initializations
\       - run defered BOOT  (which, in kernel, is merely init DOS console)
\       - evaluate the commandline
\       - runs QUIT
\       Once a program (including win32for.exe) is SAVEd or TURNKEYed, the word
\       BOOT is redefined (as GeneralBoot) in such a way that its following code
\       in kernel (evaluate commandline and QUIT) will never be executed.
\       However win32For.exe itself is built with DEFAULT-APPLICATION = ForthBoot
\       and this later word evaluates the commandline too.
\ Note: INITIALIZATION-CHAIN must be done first and should not contain words
\       executing defered i/o. The Windows system call are initialized before, in
\       the kernel.
\ Note: The MessageLoop must be started only if no message loop is present in
\       the SAVEd or TURNKEYED programm. This is the case when there is no
\       console in it, hence the test for current KEY defer contents.
\       Some cases may still need to launch a MessageLoop in the program's main,
\       eg: win32forthIDE with ConsoleHiddenBoot and SAVE
\       This could be solved once the Console itself uses MessageLoop.

IN-SYSTEM

\ ------------------------------------------------------------------------------
\ PresetConsole Defers in image
\ ------------------------------------------------------------------------------

: PresetDosConsole    ( -- ) \ Preset DOS console functions in Image
                ['] _interpret     is-image interpret
                ['] NOOP           IS-IMAGE CONSOLE
                ['] d_Init-Console IS-IMAGE INIT-CONSOLE
                ['] NOOP           IS-IMAGE INIT-SCREEN
                ['] d_KEY          IS-IMAGE KEY
                ['] d_KEY?         IS-IMAGE KEY?
                ['] d_ACCEPT       IS-IMAGE ACCEPT
                ['] DROP           IS-IMAGE PUSHKEY
                ['] 2DROP          IS-IMAGE "PUSHKEYS
                ['] NOOP           IS-IMAGE CLS
                ['] d_EMIT         IS-IMAGE EMIT
                ['] d_TYPE         IS-IMAGE TYPE
                ['] d_CR           IS-IMAGE CR
                ['] DROP           IS-IMAGE ?CR
                ['] 2DROP          IS-IMAGE GOTOXY
                ['] K_NOOP2        IS-IMAGE GETXY
                ['] 2DROP          IS-IMAGE FGBG!
                ['] K_NOOP1        IS-IMAGE FG@
                ['] K_NOOP1        IS-IMAGE BG@
                ['] 2DROP          IS-IMAGE SETCHARWH
                ['] K_NOOP2        IS-IMAGE CHARWH
                ['] DROP           IS-IMAGE SET-CURSOR
                ['] K_NOOP1        IS-IMAGE GET-CURSOR
                ['] K_NOOP2        IS-IMAGE GETCOLROW
                ['] K_NOOP1        IS-IMAGE GETROWOFF
                ['] K_NOOP1        IS-IMAGE &THE-SCREEN
                ['] NOOP           IS-IMAGE SCROLLTOVIEW
                \ preset BYE to default ( although should have never changed)
                ['] k_bye          IS-IMAGE bye ;

: PresetNoConsoleIO   ( -- )  \ Preset all defered I/O words to noop's.
                ['] _interpret     is-image interpret
                ['] NOOP           IS-IMAGE CONSOLE
                ['] K_NOOP1        IS-IMAGE INIT-CONSOLE
                ['] NOOP           IS-IMAGE INIT-SCREEN
                ['] K_NOOP1        IS-IMAGE KEY
                ['] K_NOOP1        IS-IMAGE KEY?
                ['] K_NOOP0        IS-IMAGE ACCEPT
                ['] DROP           IS-IMAGE PUSHKEY
                ['] 2DROP          IS-IMAGE "PUSHKEYS
                ['] NOOP           IS-IMAGE CLS
                ['] DROP           IS-IMAGE EMIT
                ['] 2DROP          IS-IMAGE TYPE
                ['] NOOP           IS-IMAGE CR
                ['] DROP           IS-IMAGE ?CR
                ['] 2DROP          IS-IMAGE GOTOXY
                ['] K_NOOP2        IS-IMAGE GETXY
                ['] 2DROP          IS-IMAGE FGBG!
                ['] K_NOOP1        IS-IMAGE FG@
                ['] K_NOOP1        IS-IMAGE BG@
                ['] 2DROP          IS-IMAGE SETCHARWH
                ['] K_NOOP2        IS-IMAGE CHARWH
                ['] DROP           IS-IMAGE SET-CURSOR
                ['] K_NOOP1        IS-IMAGE GET-CURSOR
                ['] K_NOOP2        IS-IMAGE GETCOLROW
                ['] K_NOOP1        IS-IMAGE GETROWOFF
                ['] K_NOOP1        IS-IMAGE &THE-SCREEN
                ['] NOOP           IS-IMAGE SCROLLTOVIEW
                \ preset BYE to default ( although should have never changed)
                ['] k_bye          IS-IMAGE bye ;

\ ------------------------------------------------------------------------------
\ SAVE & TURNKEY
\ ------------------------------------------------------------------------------

CREATE &appdir MAXCOUNTED 1+ ALLOT \ static application directory
       &appdir OFF

: .appdir       ( -- ) \ type application directory
                &appdir COUNT ?dup if TYPE else drop ." not set" then ;


: NoConsoleBoot     ( -- ) \ directive used to override SAVE or TURNKEY default
                           \ the image will have no console
                    1 to ConsoleMode ;

: DosConsoleBoot    ( -- ) \ directive used to override SAVE or TURNKEY default
                           \ the image will have a DOS console
                    2 to ConsoleMode ;

: ConsoleBoot       ( -- ) \ directive used to override SAVE or TURNKEY default
                           \ the image will have a full Forth console
                    4 to ConsoleMode ;

: ConsoleHiddenBoot ( -- ) \ directive used to override SAVE or TURNKEY default
                           \ the image will have a hidden Console console
                    8 to ConsoleMode ;

\ Note: when handling the console modes we have to make sure that no dust is
\       remaining in the defered i/o words while saving the image, hence the
\       various save/restore/set defered i/o words.


\ : ((SAVE))      { addr len \ $name -- }         \ build .exe
\                 MAXSTRING localAlloc: $name
\                 z" .EXE"                        \ .exe extension
\                 addr len $name ascii-z dup>r    \ z-string the name
\                 call PathAddExtension drop      \ add extension
\                 r> zcount &appdir count         \ add application directory
\                 MakeAbsolutePath count          \ if needed
\
\                 STD-IMG2EXE                     \ make image
\                 IMAGE-PTR release ;             \ free image-copy buffer
\

: (SAVE)        { addr len | $name -- } \ use current image & build .exe



                ConsoleMode
                case
                     1  of [']       (NoConsoleBoot)     ['] PresetNoConsoleIO endof
                     2  of [']       (DosConsoleBoot)    ['] PresetDosConsole endof
                     4  of action-of (ConsoleBoot)       ['] noop endof
                     8  of action-of (ConsoleHiddenBoot) ['] noop endof
                     true Abort" Illegal console mode"
                endcase
                is PresetConsoleIO              \ set to preset IO in image
                is DoConsoleBoot                \ set SAVEd console mode
                0 to ConsoleMode                \ reset default (saver & image)


                IMAGE-COPY                      \ create memory .img
                MAXSTRING localAlloc: $name
                z" .EXE"                        \ .exe extension
                addr len $name ascii-z dup>r    \ z-string the name
                call PathAddExtension drop      \ add extension
                r> zcount &appdir count         \ add application directory
                MakeAbsolutePath count          \ if needed

                STD-IMG2EXE                     \ make image
                IMAGE-PTR release ;             \ free image-copy buffer


\ Note: no need to preserve BOOT and DEFAULT-APPLICATION because they are both
\       set each time SAVE is used and used only once when the SAVEd is launched.


: "SAVE         ( cfa addr len -- ) \ save as Forth
                depth 3 < abort" Needs an application cfa"
                2>r >r                            \ preserve cfa

                ConsoleMode 0=
                if 4 to ConsoleMode then          \ defaults to ConsoleBoot
                ['] GeneralBoot is BOOT
                r> is default-application
                &except off                       \ no previous exceptions...
                2r> (SAVE) ;

: SAVE          ( cfa -<exename>- -- ) \ create application "exename" that runs the
                \ forth definition specified by 'cfa'. Forth interpreter, headers
                \ and system space are still available. Defaulft console mode is
                \ full Forth console.
                \ Usage: ' myApp SAVE myfile.exe
                /parse-s$ count "SAVE ;

: TURNKEY       ( cfa -<exename>- -- )  \ create application "exename" that runs the
                \ forth definition specified by 'cfa'. Destroy headers, interpreter
                \ and system space. Defaulft console mode is no console.
                \ Usage: ' myApp TURNKEY myfile.exe
                /parse-s$ count
                2>r dup>r                        \ preserve cfa & filename
                sys-addr? abort" Can't TURNKEY a system word!"
                with-source?                     \ save current state
                FALSE to with-source?            \ no source level debugging
                SYS-SIZE                         \ save current state
                0 ['] SYS-SIZE >BODY !           \ no system space
                ignore-missing-procs?            \ save current state
                true to ignore-missing-procs?    \ WHEN TURNKEYING, IGNORE MISSING PROCEDURE WARNINGS !

                ConsoleMode 0=
                if 1 to ConsoleMode then         \ defaults to NoConsoleBoot
                ['] GeneralBoot is BOOT
                r> is default-application
                &except off                      \ no previous exceptions...
                2r> ['] (SAVE) catch >r

                to ignore-missing-procs?         \ restore previous state
                ['] SYS-SIZE >BODY !             \ "
                to with-source?                  \ "
                r> throw ;                       \ throw error after restore

MODULE

BASE !

Require pre-save.f

IN-APPLICATION
