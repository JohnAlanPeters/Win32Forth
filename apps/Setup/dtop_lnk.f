\ $Id: dtop_lnk.f,v 1.4 2008/08/03 10:56:41 camilleforth Exp $
\
\    File: dtop_lnk.f
\  Author: Jos v.d. Ven
\ Created: ??.??.2004 - jos
\ Updated: Montag, April 05 2004 - dbu
\
\ Sonntag, April 04 2004 - dbu
\ - Made this source independed from toolset.f
\ - Changed to use in Setup.exe
\ - fixed a bug in make_link
\ - replaced count-0 by zcount
\
\ Montag, April 05 2004 - dbu
\ - changed BUF+NULL and MAKE_LINK to match Jos bugfix

anew -dtop_lnk.f

\ From toolset.f
[UNDEFINED] toolset.f [IF]

: -dup  ( n1 n2    - n1 n1 n2 )    >r dup r>  ;

: 0term ( $ count - ) + 0 swap c!  ;

: wnum?         ( - d flag )      bl word uppercase count number? not ;

: th            ( n - )
   base @  >r  hex wnum?
   abort" <- Not a hex number" drop state @
\IN-SYSTEM-OK if      [compile] literal
        then    r>  base !
 ; immediate

: c>unicode! ( dest char - dest+2 )   over w! 2 chars + ;

: ansi>unicode  ( caddrSrc u addrDestUnicode -- )
    -rot over + swap
    ?DO i c@ c>unicode! LOOP
    0 swap w! ;

: drop-count    ( adr len - adr-counted-string )
   drop 1- ;

\ string concatenation:  $1 + $2 -> $1+$2 in pad
: $concat ( $1 n $2 n - pad n1+2 )
    temp$ place             \ Save old $2. It might be in pad.
    pad   place             \ Put $1 in place.
    temp$ count pad +place  \ Add old $2.
    pad count
 ;

[THEN]

string: tmp$

[UNDEFINED] zCount [IF]
: zCount    ( a1 -- a2 len )
        TRUE 2dup 0 scan nip - ;
[THEN]

needs com01.f

variable &pLink
variable &pPersistFile
variable &DesktopPidl

iid: CLSID_ShellLink   {00021401-0000-0000-C000-000000000046}
iid: IID_IShellLink    {000214EE-0000-0000-C000-000000000046}
iid: IID_IPersistFile  {0000010b-0000-0000-C000-000000000046}

#define CSIDL_DESKTOPDIRECTORY      0x0010

struct{  \ IShellLinkA
\ STDMETHODCALLTYPE QueryInterface
\ STDMETHODCALLTYPE AddRef
\ STDMETHODCALLTYPE Release
interface_IUnknown
        STDMETHODCALLTYPE *GetPath
        STDMETHODCALLTYPE *GetIDList
        STDMETHODCALLTYPE *SetIDList
        STDMETHODCALLTYPE *GetDescription
        STDMETHODCALLTYPE *SetDescription
        STDMETHODCALLTYPE *GetWorkingDirectory
        STDMETHODCALLTYPE *SetWorkingDirectory
        STDMETHODCALLTYPE *GetArguments
        STDMETHODCALLTYPE *SetArguments
        STDMETHODCALLTYPE *GetHotkey
        STDMETHODCALLTYPE *SetHotkey
        STDMETHODCALLTYPE *GetShowCmd
        STDMETHODCALLTYPE *SetShowCmd
        STDMETHODCALLTYPE *GetIconLocation
        STDMETHODCALLTYPE *SetIconLocation
        STDMETHODCALLTYPE *SetRelativePath
        STDMETHODCALLTYPE *Resolve
        STDMETHODCALLTYPE *SetPath
 }struct IShellLinkA

: ->plink  ( /..~../ interface - )   &pLink @ swap std_imethod ;

3 PROC SHGetSpecialFolderLocation
2 PROC SHGetPathFromIDList
: GetSpecialFolderLocation   ( nFolder - adr count )
    &DesktopPidl swap NULL call SHGetSpecialFolderLocation drop
    tmp$ &DesktopPidl @ call SHGetPathFromIDList drop
    tmp$ zcount
 ;

: init_dtop_for_link
   CoInitialize
   &pLink IID_IShellLink CLSCTX_INPROC_SERVER
   NULL CLSID_ShellLink call CoCreateInstance ?failed
   &pPersistFile IID_IPersistFile *QueryInterface ->pLink
 ;

struct{  \ IPersistFile
\ STDMETHODCALLTYPE QueryInterface
\ STDMETHODCALLTYPE AddRef
\ STDMETHODCALLTYPE Release
interface_IUnknown
        STDMETHODCALLTYPE  *GetClassID
        STDMETHODCALLTYPE  *IsDirty
        STDMETHODCALLTYPE  *Load
        STDMETHODCALLTYPE  *Save
        STDMETHODCALLTYPE  *SaveCompleted
        STDMETHODCALLTYPE  *GetCurFile
 }struct IPersistFile

: ->pPersistFile  ( /..~../ interface - )   &pPersistFile @ swap std_imethod ;

: buf+null ( buf$ n - abs_adr$incl_0 )
   pad ascii-z
 ;

: make_link   ( z"description" s"full-path+file-name" count - )
   buf+null *SetPath        ->plink
   SW_SHOW  *SetShowCmd     ->plink
            *SetDescription ->pLink
 ;

: save_link  ( adr n - )
             { \ buffer -- }
   1024 LocalAlloc: buffer \ dbu
   buffer ansi>unicode true buffer *Save ->pPersistFile
 ;

: set_icon_link   ( adr n - )  0 -rot buf+null *SetIconLocation ->plink ;
: set_dir_link    ( adr n - )  buf+null *SetWorkingDirectory ->plink ;


defined toolset.f nip [IF]

: write-installer ( adr n - )  s" installer.log" drop-count file type eof ;

\ link/start performs the installation actions when installer.log does not exist
\ or when the current directory is not the same as the one in installer.log
\ The result is an auto-installer which runs when needed.

: link/start ( 'start 'installation - )
    s" installer.log" read open-file drop
    >r buffer maxstring r@ read-line 2drop 1 max
    r> close-file drop
    buffer swap current-dir$ count compareia     \ Checks if the current path is right
        if    execute                            \ Install actions when the path is not right
              current-dir$ count write-installer \ Writes the path in installer.log
        else  drop
        then
    execute     \ Starts the application
 ;

[then]

