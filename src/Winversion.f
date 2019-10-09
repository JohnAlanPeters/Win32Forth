\ $Id: Winversion.f,v 1.3 2015/09/02 12:30:11 jos_ven Exp $

\ *D doc
\ *! p-winversion  W32F winversion
\ *T Operating System Checking

\ *P Untill windows 8 a call to GetVersionEx could be used to get the version information. \n
\ ** To check for a version, say Win2K or greater, try WINVER WIN2K >= \n
\ ** NOTE: The future V7.xx.xx and later will only support WIN2K or greater anyway.

\ *S Glossary

\ Moved here from PrimUtil.f

1 PROC GetVersionEx
version# ((version)) 0. 2swap >number 3drop 7 <  [if]  \ For V6.xx.xx suporting older OSs
1  constant win95
2  constant win98
3  constant winme
4  constant winnt351
5  constant winnt4

[then]

6  constant win2k
7  constant winxp
8  constant win2003   \ Windows Server 2003 R2
9  constant winvista  \ Windows Vista
10 constant win2008   \ Windows Server 2008
11 constant win2008r2 \ Windows Server 2008 R2
12 constant win7      \ Windows 7
13 constant win8      \ Windows 8
14 constant win10     \ Windows 10

also hidden

: GetRegistryEntry   ( vadr vlen root-key Zsection samDesired -- dadr dlen|0 )
\ *G Retrieves the data of any registry key.
\ ** Parameters:
\ ** vadr,vlen  = the registry key value string to read.
\ ** root-key   = One of the first predefined keys EG: HKEY_CLASSES_ROOT
\ ** Zsection   = 0 terminated registry key section string.
\ ** samDesired = security access mask.
\ ** dadr,dlen  = returns the data and size.
     0 0 locals| reglen regtype |  ReturnedKey$ off
     (RegCreateKey) dup -1 =
        if    drop  ReturnedKey$ count exit \ return on error, empty data
        then  >r  drop >r
     MAXCOUNTED to reglen            \ init max length of string
     &of reglen
     ReturnedKey$ 1+
     &of regtype
     0
     r>
     r@
     Call RegQueryValueEx
        if    ReturnedKey$ off              \ Can not access the registry-key
        else  reglen 0max ReturnedKey$ c!   \ Includes the 0 for REG_SZ types
        then
     ReturnedKey$ count r> Call RegCloseKey drop ;

previous internal

: WNT\Version   ( - hklm Zsection samDesired )
     HKEY_LOCAL_MACHINE z" SOFTWARE\Microsoft\Windows NT\CurrentVersion" KEY_EXECUTE ;

: GetVersionWin8+ ( -- winver )
     s" CurrentMajorVersionNumber" WNT\Version
     GetRegistryEntry 0>  if  @ 4 +  else  drop WIN8  then  ;

external

0 value winver

: winver-init ( -- )
\ *G Gets the windows version and stores it in winver.
            156 dup _localalloc dup>r ! \ set length of OSVERSIONINFOEX structure
            r@ call GetVersionEx \ call os for version
[ version# ((version)) 0. 2swap >number 3drop 7 < ] [if]  \ For V6.xx.xx suporting older OSs
            dup 0= if drop 148 r@ ! r@ call GetVersionEx then  \ try lower size for win98FE (and possibly win95)
[then]      0= abort" call failed"
            r@ 4 cells+ @        \ get osplatformid
            case
[ version# ((version)) 0. 2swap >number 3drop 7 < ] [if]  \ For V6.xx.xx suporting older OSs
              1 of                  \ 95, 98, and me
                r@ 2 cells+ @       \ minorversion
                case
                  0  of win95 endof \ 95
                  10 of win98 endof \ 98
                  90 of winme endof \ me
                endcase
              endof
[then]
              2 of                  \ nt, 2k, xp
                r@ cell+ @          \ majorversion
                case
[ version# ((version)) 0. 2swap >number 3drop 7 < ] [if]  \ For V6.xx.xx suporting older OSs
                  3  of winnt351 endof \ nt351
                  4  of winnt4 endof \ nt4
[then]            5  of
                     r@ 2 cells+ @  \ minor version
                     case
                       0 of win2k endof \ win2k
                       1 of winxp endof \ winxp
                       2 of win2003 endof \ 2003
                     endcase
                  endof
                  6  of
                    r@ 2 cells+ @  \ minor version
                     case
                       0 of r@ 154 + c@ \ Product Type
                            VER_NT_WORKSTATION = if winvista    \ Windows Vista
                                                 else win2008   \ Windows Server 2008
                                                 then
                       endof
                       1 of r@ 154 + c@ \ Product Type
                            VER_NT_WORKSTATION = if win7        \ Windows 7
                                                 else win2008r2 \ Windows Server 2008 R2
                                                 then
                       endof

                       2 of r@ 154 + c@ \ Product Type
                            VER_NT_WORKSTATION = if GetVersionWin8+ \ Windows 8 or better
                                                 else win2008r2     \ Windows Server 2008 R2
                                                 then
                       endof
                     drop -2 dup   \ unknown product Type
                     endcase
                  endof
                drop -1 dup   \ unknown windows version
                endcase
              endof
            endcase to winver
            rdrop _localfree
            ;

previous
initialization-chain chain-add winver-init
winver-init

\S
\ *Z
