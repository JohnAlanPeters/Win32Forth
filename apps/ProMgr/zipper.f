\ Zipper.f
\
\ ZIP interface routines for Info-Zip's Zip32.dll
\ see http://www.info-zip.org/pub/infozip/Zip.html for details
\
\ August 13th, 2003 - 13:01 - Ezra Boyce
\ July 23, 2005 - corrected error in zip options structure. The first three entries should
\ be pointers to strings as opposed to being actual strings. Excluding path names from
\ zipped files now works.

Comment:
Specific documentation on using the Zip32.dll is hard to come by. Sample code in
Visual Basic and C is most what can be found. So these routines are based on
such code.
NOTE!! The structure passed to ZPArchive as specified in the example code is
incorrect. Three separate parameters are passed to the DLL function as stated
in the Visual Basic example.
Go to the end of the file to read how to use this utility.
Comment;

anew -zipper.f

needs eStruct.f
needs enum.f

internal
external

WinLibrary Zip32.dll

defer doZip32Print
defer doZip32Service
defer doZip32Password
defer doZip32Comment
0 value zcode   \ return code

\ ZOpt Is Used To Set The Options In The ZIP32.DLL
:struct ZPOPT
    lpstr  Date          \ US Date (8 Bytes Long) "12/31/98"?
    lpstr  szRootDir     \ Root Directory Pathname (Up To 256 Bytes Long)
    lpstr  szTempDir     \ Temp Directory Pathname (Up To 256 Bytes Long)
               int    fTempdir       \ 1 If Temp dir Wanted, Else 0
               int    fSuffix        \ Include Suffixes (Not Yet Implemented!)
               int    fEncrypt       \ 1 If Encryption Wanted, Else 0
               int    fSystem        \ 1 To Include System/Hidden Files, Else 0
               int    fVolume        \ 1 If Storing Volume Label, Else 0
               int    fExtra         \ 1 If Excluding Extra Attributes, Else 0
               int    fNoDirEntries  \ 1 If Ignoring Directory Entries, Else 0
               int    fExcludeDate   \ 1 If Excluding Files Earlier Than Specified Date, Else 0
               int    fIncludeDate   \ 1 If Including Files Earlier Than Specified Date, Else 0
               int    fVerbose       \ 1 If Full Messages Wanted, Else 0
    int    fzQuiet        \ 1 If Minimum Messages Wanted, Else 0
               int    fCRLF_LF       \ 1 If Translate CR/LF To LF, Else 0
               int    fLF_CRLF       \ 1 If Translate LF To CR/LF, Else 0
    int    fJunkDir       \ 1 If stripping path from filename, Else 0
               int    fGrow          \ 1 If Allow Appending To Zip File, Else 0
               int    fForce         \ 1 If Making Entries Using DOS File Names, Else 0
               int    fMove          \ 1 If Deleting Files Added Or Updated, Else 0
               int    fDeleteEntries \ 1 If Files Passed Have To Be Deleted, Else 0
               int    fUpdate        \ 1 If Updating Zip File-Overwrite Only If Newer, Else 0
               int    fFreshen       \ 1 If Freshing Zip File-Overwrite Only, Else 0
               int    fJunkSFX       \ 1 If Junking SFX Prefix, Else 0
               int    fLatestTime    \ 1 If Setting Zip File Time To Time Of Latest File In Archive, Else 0
               int    fComment       \ 1 If Putting Comment In Zip File, Else 0
               int    fOffsets       \ 1 If Updating Archive Offsets For SFX Files, Else 0
    int    fzPrivilege    \ 1 If Not Saving Privileges, Else 0
               int    fEncryption    \ Read Only Property!!!
               int    fRecurse       \ 1 (-r), 2 (-R) If Recursing Into Sub-Directories, Else 0
               int    fRepair        \ 1 = Fix Archive, 2 = Try Harder To Fix, Else 0
              byte    flevel         \ Compression Level - 0 = Stored 6 = Default 9 = Max
;struct

ZPOPT ZipOptions        \ create instance
ZipOptions make-static

1 proc ZpInit As Init-ZIP32
1 proc ZpSetOptions As DoSetZipOptions
0 proc ZpGetOptions As GetZipOptions
3 proc ZpArchive As Zip

0 to enum-value
enum:   ZE_OK
        ZE_UNKNOWN
        ZE_EOF
        ZE_FORM
        ZE_MEM
        ZE_LOGIC
        ZE_BIG
        ZE_NOTE
        ZE_TEST
        ZE_ABORT
        ZE_TEMP
        ZE_READ
        ZE_NONE
        ZE_NAME
        ZE_WRITE
        ZE_CREAT
        ZE_PARMS
        ZE_UNKNOWN2
        ZE_OPEN  ;

: ?zip-error    { err# -- }
                err# ZE_OK = ?exit
                err#
                case
                ( 1 )   ZE_UNKNOWN      of      s" Unknown error #1"                    endof
                        ZE_EOF          of      s" Unexpected End Of Zip Error"         endof
                        ZE_FORM         of      s" Zip File Structure Error"            endof
                        ZE_MEM          of      s" Out Of Memory Error"                 endof
                        ZE_LOGIC        of      s" Internal logic error"                endof
                        ZE_BIG          of      s" Entry to large to split error"       endof
                        ZE_NOTE         of      s" Invalid comment format"              endof
                        ZE_TEST         of      s" Zip test failed"                     endof
                        ZE_ABORT        of      s" User interrupted error"              endof
                        ZE_TEMP         of      s" Error using a temp file"             endof
                        ZE_READ         of      s" Read or seek error"                  endof
                        ZE_NONE         of      s" Nothing to do!"                      endof
                        ZE_NAME         of      s" Missing or empty zip file"           endof
                        ZE_WRITE        of      s" Error writing to a file"             endof
                        ZE_CREAT        of      s" Couldn't open to write error"        endof
                        ZE_PARMS        of      s" Bad command line argument"           endof
                        ZE_UNKNOWN2     of      s" Unknown error #17"                   endof
                 ( 18 ) ZE_OPEN         of      s" Could not open specified file"       endof
                        s" Unknown error!" rot
                endcase true -rot ?MessageBox ;

internal
\ Zip32Print is e.g adding: filename, (deflated x%)
: defprint      ( addr cnt -- )
                ?dup if cr type else drop then ;
' defprint is doZip32Print
' defprint is-default doZip32Print

2 CallBack: Zip32Print ( addr n -- res )
                       drop zcount 2dup + 1- c@ 0x0A =
                       if       1-                  \ remove trailing linefeed
                       then     -trailing doZip32Print
                       0 ;

\ Zip32Service seems to pass essentially the name of file being zipped, so operation
\ can be cancelled if necessary
: defservice    ( addr cnt -- res )
                ?dup if cr ." Done - " type else drop then 0 ;
' defservice is doZip32Service
' defservice is-default doZip32Service

2 CallBack: Zip32Service  ( addr n  -- res ) \ if res = 1 zip will abort
                        drop zcount 2dup + 1- c@ 0x0A =
                        if      1-                \ remove trailing linefeed
                        then    -trailing doZip32Service ;
' 4drop is doZip32Password
' 4drop is-default doZip32Password

4 CallBack: Zip32Password { addr1 addr2 n addr3 -- res }
                        addr1 addr2 n addr3
                        doZip32Password
                        0 ;
' drop is doZip32Comment
' drop is-default doZip32Comment

1 CallBack: Zip32Comment  ( addr -- )
                          doZip32Comment
                          1 ;

0 value zset?

create &ZipCallBacks
&Zip32Print ,
&Zip32Comment ,
&Zip32Password ,
&Zip32Service ,

: SetZipCallBacks       ( --  )
                        zset? ?exit      \ already set
                        &ZipCallBacks Init-Zip32 to zcode
                        true to zset? ;


1024 64 * constant ZipBufferSize  \ 64k pointer
ZipBufferSize Pointer ZipBuffer
0 value #FilesAdded
0 value NextAddress
0 value #FilesToBeZipped

: SetZipOptions         ( -- )
                        addrof> ZipOptions DoSetZipOptions to zcode ;

external

: DefaultZipOptions     ( -- )
                        ZipOptions sizeof() erase ;

: Set#FilesTobeZipped   ( n -- )
                        to #FilesTobeZipped
                        0 to #FilesAdded
                        #FilesToBeZipped cells ZipBuffer + to NextAddress ;
' Set#FilesToBeZipped alias #zipfiles

\ The beginning of the buffer is a vector which stores the pointers to each
\ null terminated file name to be added
: AddFileToBeZipped  { faddr fcnt -- }
                #FilesAdded #FilesToBeZipped >= abort" Too many files!"
                NextAddress fcnt 1+ + ZipBuffer ZipBufferSize + u< not abort" Buffer full!"
                faddr NextAddress fcnt move
                NextAddress #FilesAdded cells ZipBuffer + !
                NextAddress fcnt + 0 over c!    \ null terminate
                1+ to NextAddress 1 +to #FilesAdded ;
' AddFileToBeZipped alias +zfile   \ save typing!


: GoZip!        { zname zcnt -- }  \ zname zcnt = name of zip file to create
\ zip options should already be set and files added to zip buffer
                #FilesToBeZipped 0= ?exit
                #FilesAdded #FilesToBeZipped < abort" Files not set!"
                SetZipCallBacks
                SetZipOptions
                ZipBuffer
                zname zcnt asciiz
                #FilesToBeZipped Zip dup to zcode ?zip-error ;

MODULE
\s
To use -
set any zip options desired (optional)
        e.g  with{ ZipOptions }with
             9 put> flevel   \ set compression to maximum
             1 put> fupdate  \ updating archive
             1 put> fjunkdir \ strip path name from file
             end-with
             or DefaultZipOptions
set the number of files that will be zipped
        e.g  5 Set#FilesTobeZipped
add each file name to be zipped
        e.g  s" Win32For.exe" +zfile
             s" WinEd.exe"    +zfile
             etc.
call the zip routine with the name of the desired zip file
        e.g  s" Win32For.zip" GoZip!
test zcode if desired for result

N.B You can write your own handler for the DLL messages if desired. See the
default routines for examples.

That all folks!
