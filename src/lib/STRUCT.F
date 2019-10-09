\ $Id: STRUCT.F,v 1.10 2006/08/04 09:45:53 georgeahubert Exp $

\ For C like structures.

needs ExtStruct.f

\ Added ulong ushort
\ renamed @+ to n+adr@

\ August 22nd, 2001 - 19:23
\    added OFFSET    saves calculations
\          >STRUCT   saves runtime
\  changed }STRUCT for better cloning

\ January 15th, 2002 - 16:46 removed a bug from _add-struct
\ July 13th, 2002 - 16:26 Added Field:
\ Donnerstag, Mai 26 2005 dbu - changed mkstruct: to fill the struct with zero's
\ May 28th, 2005 - Jos: Adapted for ExtStruct.f

cr .( Loading simple C like structures..)
cr .(  Members of a structure are not in a separate vocabulary.)

anew -struct.f   \ for Win32Forth

in-system

also structs

\  Members of a structure are not in a separate vocabulary, when  struct{ }struct are used.

internal

: (}struct)
      previous create  forth-wordlist , _struct ,  \ store the offset/size
      does> cell+ @ add-struct ;       \ get the offset and create a field with it that is itself that offsetword

external

: }struct
      sys-warning? >r sys-warning-off (}struct) r> to sys-warning? ;

module

\ >struct compiles the adress and offset as 1 adress inside a definition
: >struct (  -<name-struct>- -<member>- -  )
     ' execute ' execute  postpone literal  ; immediate

: struct{      ( -- )
   also structs  0 to _struct ;

previous

in-application


\ July 13th, 2002 - 13:17
\ Note: next-offset is Forth dependent
\ 12 offset next-offset ( 'adr -- next-offset )

\s

\ Examples:

struct{ \ language
   LANGID  language.LanguageID
   CHAR    language.szDialect[LANG_LEN]
   }struct language

\ There is nothing allocated yet only the positions in memory are defined
\ Now it is going to be allocated in two different locations.

sizeof language mkstruct: languageTemp1
sizeof language mkstruct: languageTemp2

\ Change language.szDialect[LANG_LEN] of languageTemp1 as follows:
1 languageTemp1 language.szDialect[LANG_LEN] c!

cr cr .( The value of languageTemp1 is: )
 languageTemp1 language.szDialect[LANG_LEN] c@ .

\ The names are a bit longer, this is needed to avoid duplicate names.

struct{  \ BitmapFileHeader
        WORD   bfType
        LONG   bfSize
        WORD   bfReserved1
        WORD   bfReserved2
        DWORD  bfOffsetBits
        OFFSET >BitmapInfoHeader
}struct BitmapFileHeader

struct{ \  BITMAPINFOHEADER
        DWORD      biSize
        LONG       biWidth
        LONG       biHeight
        WORD       biPlanes
        WORD       biBitCount
        DWORD      biCompression
        DWORD      biSizeImage
        LONG       biXPelsPerMeter
        LONG       biYPelsPerMeter
        DWORD      biClrUsed
        DWORD      biClrImportant
 }struct BITMAPINFOHEADER

struct{ \ RGBQUAD
        BYTE    rgbBlue
        BYTE    rgbGreen
        BYTE    rgbRed
        BYTE    rgbReserved
}struct RGBQUAD

struct{ \ BITMAPINFO
    BitmapInfoHeader  pbmiBitmapInfoHeader
    offset pbmiColors
    sizeof RGBQUAD 256 * _add-struct
}struct bitmapinfo

sizeof bitmapinfo mkstruct: pbmi
cr .( The size of bitmapinfo is: ) sizeof bitmapinfo .

: test
    cr ." A member can be compiled as an adress."
    2 >struct pbmi biWidth !
    cr ." The color array starts at: " >struct pbmi pbmiColors .
    cr >struct pbmi biWidth @ .
 ;
cr see test test

\s


