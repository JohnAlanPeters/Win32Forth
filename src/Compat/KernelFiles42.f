\ $Id: KernelFiles42.f,v 1.1 2006/08/17 12:00:29 georgeahubert Exp $

\ G.Hubert Thursday, August 12 2004
\ Public Domain

\ These implementations of the original file words from the V4.2 Kernel
\ are provided for use in testing legacy code. The words are rarely
\ used, even in older applications (since the ANSI words are available).

: FOPEN-FILE    ( addr len fam -- fileid ior )
                  if r/w else r/o then open-file ;

: FMAKE-FILE    ( addr len -- fileid ior )
                  r/w create-file ;

' close-file alias Fclose-file

' read-line alias Fread-line


: FREAD-FILE    ( addr len fileid -- len )
                  read-file drop ;

: FSEEK-FILE    ( offset origin fileid -- ior )
                  2>R s>d r> r> case
                  0 of reposition-file endof
                  1 of advance-file    endof
                  2 of dup file-append >r advance-file r> or endof
                  3drop -1 swap endcase ;

' reposition-file alias FREPOSITION-FILE

\ this function only returns a single precision position, so high part is
\ always zero, and it can't fail, so error is always zero

' file-position alias FFILE-POSITION
