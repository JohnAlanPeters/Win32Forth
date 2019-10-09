\ $Id: file.f,v 1.9 2010/07/11 02:34:01 ezraboyce Exp $

\ *D doc\classes\
\ *! File
\ *T Classes for File I/O

anew -File.f

#ifndef ?exitm
macro ?exitm " if exitm then"
#then

INTERNAL
EXTERNAL

\ -----------------------------------------------------------------------------
\ *W <a name="File"></a>
\ *S File I/O class
\ -----------------------------------------------------------------------------
:Class File     <Super Object
\ *G File I/O class

int errorcode
int hfile       \ file handle
int mode        \ file access mode
int doerror?
int #bytesread
max-path bytes filename
32 bytes msgtext

:M ClassInit:   ( -- )
                ClassInit: super
                0 to errorcode
                0 to hfile
                r/w to mode     \ default
                true to doerror?
                0 to #bytesread
                msgtext off
                filename max-path erase
                ;M

: ?fileerror    { \ msg$ -- }
                maxstring LocalAlloc: msg$
                doerror? 0= ?exit
                errorcode 0= ?exit
                msgtext count msg$ place
                s"  error - File: " msg$ +place
                filename count msg$ +place
                msg$ +null
                MB_OK MB_ICONSTOP or MB_TASKMODAL or
                z" Warning!"  ( title )
                msg$ 1+       ( message )
                NULL Call MessageBox drop
                msgtext off ;

: ismsgtext      ( addr cnt -- )
                msgtext place ;

:M Close:       ( -- )
\ *G Close the file.
                hfile
                if      hfile close-file to errorcode
                        0 to hfile
                        s" Close" ismsgtext
                        ?fileerror
                then    ;M

:M Open:        ( -- f )
\ *G Open the file
                Close: self
                filename count mode open-file dup to errorcode
                if      drop
                else    to hfile
                then    s" Open" ismsgtext ?fileerror
                errorcode ;M

:M Read:        { addr cnt -- f }
\ *G Read cnt bytes from the file into memory
                hfile
                if      addr cnt hfile read-file
                else    0 true
                then    to errorcode to #bytesread
                s" Read" ismsgtext ?fileerror
                errorcode ;M

:M Write:       { addr cnt -- f }
\ *G Write cnt bytes from memory into the file.
                hfile
                if      addr cnt hfile write-file
                else    true
                then    to errorcode
                s" Write" ismsgtext ?fileerror
                errorcode ;M

:M Create:      ( -- f )
\ *G Create the file.
                Close: self
                filename count mode create-file dup to errorcode
                if      drop
                else    to hfile
                then    s" Create" ismsgtext ?fileerror
                errorcode ;M

:M Delete:      ( -- )
\ *G Delete the file
                Close: self
                filename count delete-file to errorcode
                s" Delete" ismsgtext ?fileerror ;M

:M Rename:      { addr cnt -- }
\ *G Rename the file.
                Close: self
                filename count addr cnt rename-file to errorcode
                addr cnt maxcounted min 0max filename place
                filename +NULL
                s" Rename" ismsgtext ?fileerror ;M

:M GetPosition: ( -- ud )
\ *G Get the position of the file pointer
                hfile
                if      hfile file-position to errorcode
                else    -1.     \ error
                then    ;M

:M RePosition:  ( ud -- )
\ *G Set the position of the file pointer
                hfile
                -if     reposition-file to errorcode
                else    3drop
                then    ;M

:M FileSize:    ( -- ud )
\ *G Get the size of the file
                hfile
                if      hfile file-size to errorcode
                else    -1.
                then    ;M

:M Append:      ( -- )
\ *G Set append mode
                hfile
                if      hfile file-append to errorcode
                then    ;M

:M Flush:       ( -- )
\ *G Flush the file
                hfile
                if      hfile flush-file to errorcode
                        s" Flush" ismsgtext ?fileerror
                then    ;M

:M ReadLine:    ( addr len -- len eof )
\ *G Read a line from the file.
                hfile ?dup
                if      read-line to errorcode
                        s" Read Line" ismsgtext ?fileerror
                else    2drop 0 -1
                then    ;M

:M WriteLine:   ( addr len -- )
\ *G Write a line to the file
                hfile
                -if     write-line to errorcode
                        s" Write Line" ismsgtext ?fileerror
                else    3drop
                then    ;M

:M Resize:      ( ud -- )
\ *G Resize the file
                hfile ?dup
                if      resize-file to errorcode
                        s" Resize" ismsgtext ?fileerror
                else    2drop
                then    ;M

:M Exist?:      ( -- f )
\ *G Check if the file exist
                filename count file-status nip 0= ;M

:M SetName:     ( addr cnt -- )
\ *G Set the file name
                maxcounted min 0max filename place
                filename +NULL ;M

:M GetName:     ( -- addr )
\ *G Get the file name
                filename ;M

:M ClearName:   ( -- )
\ *G Clear the file name
                filename max-path erase ;M

:M SetMode:     ( mode -- )
\ *G Set the I/O mode
                to mode ;M

:M ErrorCode:   ( -- n )
\ *G Get the error code of the previous file I/O
                errorcode ;M

;Class
\ *G End of File class

\ -----------------------------------------------------------------------------
\ *W <a name="ReadFile"></a>
\ *S Class for loading/saving a complete file from/to memory
\ -----------------------------------------------------------------------------

:Class ReadFile <Super File
\ *G ReadFile class for loading/saving a complete file from/to memory.

int FileBuffer

:M ClassInit:   ( -- )
                ClassInit: super
                0 to FileBuffer ;M

:M ReleaseBuffer: ( -- )
\ *G Free the memory of the file-buffer
                FileBuffer ?dup
                if   release 0 to FileBuffer
                then ;M

:M GetBuffer:   ( -- addr len )
\ *G Fet the address and len of the file-buffer
                FileBuffer ?dup
                if   lcount
                else 0 0
                then ;M

:M GetLength:   ( -- len )
\ *G Get the length of the file-buffer
                FileBuffer ?dup
                if   @
                else 0
                then ;M

:M SetLength:   ( len -- )
\ *G Set the length of the file-buffer.
\ *P NOTE: with this method you can set the length behind the
\ ** allocated memory of the file-buffer! So take care.
                FileBuffer ?dup
                if   !
                else drop
                then ;M

:M SetBuffer:   ( addr len -- )
\ *G Set the address and length of the file-buffer
                ReleaseBuffer: self
                swap dup to FileBuffer ! ;M

:M AllocBuffer: ( len -- )
\ *G Allocate memory for the file-buffer
                dup 2 cells+ malloc swap SetBuffer: self ;M

:M LoadFile:    ( addr len -- f )
\ *G load a file into the file-buffer, f=true on success
                Setname: self
                mode >r		\ save current mode
                r/o SetMode: self
                Open: self
                r> SetMode: self	\ restore mode
                if      false exitm
                then    FileSize: self drop  dup [ 32 1024 1024 * * ] LITERAL >
                to errorcode s" File size too large" ismsgtext ?fileerror    \ only warn
                AllocBuffer: self               \ still allocate and read
                FileBuffer dup 0= ?exitm
                drop GetBuffer: self Read: self
                if      ReleaseBuffer: self false
                else    true
                then    Close: self ;M

:M SaveFile:    ( -- )
\ *G Save the file-buffer to the file
                FileBuffer 0= ?exitm
                r/w SetMode: self
                Create: self ?exitm
                GetBuffer: self Write: self drop
                Close: self ;M

:m ~:           ( -- )
                ReleaseBuffer: self
                Close: self ;m

;Class
\ *G End of ReadFile class

module

\s

\ *S Example
\ *+

ReadFile MyDumpFile

: DumpFile  ( addr len -- )

        \ Load the file into memory
        LoadFile: MyDumpFile
        if   \ get the address and length of the file buffer
             GetBuffer: MyDumpFile ( addr len )

             \ do something with the file data
             dump

             \ don't forget to close the file
             Close: MyDumpFile
        else abort" Can't read file."
        then ;

s" temp.f" DumpFile

\ *-
\ *Z
