\ $Id: AxConInfo.f,v 1.2 2011/08/10 16:55:58 georgeahubert Exp $

\ AxConInfo.f
\ Get information about an ActiveX control from the registry and
\ display it.
\ Written by Dirk Busch

cr .( Loading ActiveX control info tool)

anew -AxConInfo.f

needs fcom

internal

in-system

create org_BaseReg 260 allot
create org_ProgReg 260 allot
0 value org_regBaseKey
0 value org_regAccessMask

: SaveReg       ( -- )
        BaseReg count org_BaseReg place
        ProgReg count org_ProgReg place
        regBaseKey to org_regBaseKey
        regAccessMask to org_regAccessMask
        ;

: RestoreReg    ( -- )
        org_BaseReg count BaseReg place
        org_ProgReg count ProgReg place
        org_regBaseKey to regBaseKey
        org_regAccessMask to regAccessMask
        ;

: tab-type      ( addr len -- )
        tab-size >r 32 to tab-size
        tab type
        r> to tab-size
        ;

: RegGetAxInfoValue     ( addr1 len1 addr2 len2 -- addr3 len3 )
        s" CLSID\" BaseReg place
        2swap BaseReg +place \ guid
        s" \" BaseReg +place
        BaseReg +place \ section
        ProgReg off
        s" "  s" " RegGetString ;

: (.AxInfoValue) ( addr len -- )
        2dup type ." : "
        RegGetAxInfoValue
        tab-type ;

: (.AxInfo)     ( addr len -- )
        cr ." GUID: " 2dup tab-type
        cr 2dup ." ClassName" s" " (.AxInfoValue)
        cr 2dup s" ProgID"  (.AxInfoValue)
        cr 2dup s" TypeLib" (.AxInfoValue)
        cr 2dup s" Version" (.AxInfoValue)
        cr      s" VersionIndependentProgID" (.AxInfoValue)
        cr ;

: AxInitReg     ( -- )
        SaveReg
        HKEY_CLASSES_ROOT to regBaseKey
        KEY_READ          to regAccessMask ;

: AxRestoreReg  ( -- )
        RestoreReg ;

: /get  { str len char \ str1 len1 -- str len str1 len1 } \ search for char in string, return string till char and rest of string after char
        str len char scan  to len1 to str1
        len1 0>
        if   len len1 - to len
             str1 1+ to str1
             len1 1- ?dup if to len1 then
        then str len str1 len1 ;

: guid>version ( addr len -- major minor )
        s" Version" RegGetAxInfoValue ?dup
        if   [char] . /get number? drop d>s >r number? drop d>s r>
        else drop 1 0
        then ;

: guid>typelib ( addr len -- addr len )
        s" TypeLib" RegGetAxInfoValue ;

external

: GetAxVersion  ( "GUID" -- major minor )
        AxInitReg
        parse-word ?dup if guid>version else drop 0 0 then
        RestoreReg ;

: GetAxTypeLib  ( "GUID" -- addr len )
        AxInitReg
        parse-word ?dup if guid>typelib else drop s" " then
        RestoreReg ;

internal

[undefined] (Guid,) [if]
: (Guid,)       ( addr len -- ) \ comments in a guid
        Base @ >r HEX dup 38 <> abort" Invalid Guid Length"
        1 /string  2dup ascii - scan 2dup >r >r nip - hatoi ,
        r> r> ascii - skip 2dup ascii - scan 2dup >r >r nip - hatoi w,
        r> r> ascii - skip 2dup ascii - scan 2dup >r >r nip - hatoi w,
        r> r> ascii - skip 2dup drop 2 0 do dup i 2 * + 2 hatoi c, loop drop
        ascii - scan ascii - skip drop 6 0 do dup i 2 * + 2 hatoi c, loop drop r> base ! ;
[then]

: (guid_typelib) ( major minor addr len -- ) \ load a type library for given GUID into the list
        2>r here typelibhead dup @ , !
        here dup >r 0 , here 0 , 2swap swap here r> 2r> rot >r (Guid,) LoadRegTypeLib
        abort" Error Loading Type Library"
        r> dup cell+ swap UCOM ITypeLib GetTypeComp abort" Error Getting TypeComp" ;

external

: guid_typelib  ( "GUID" -- ) \ load a type library for given GUID into the list
        parse-word ?dup
        if   AxInitReg
             2dup guid>version 2swap guid>typelib (guid_typelib)
             RestoreReg
        else drop abort" GUID missing"
        then ;

: .AxInfo       ( "GUID" -- )
        cr cr ." ActiveX Control info"
        parse-word
        ?dup
        if   AxInitReg
             2dup (.AxInfo)
             2dup guid>version 2swap guid>typelib (guid_typelib)
             cr ." CoClasses:"  tab CoClasses
             cr cr ." Interfaces:" tab Interfaces
             cr cr ." Structures:" tab Structures
             cr cr ." ComConsts:"  tab ComConsts
             AxRestoreReg
        else drop
        then cr ;

module

in-application

cr .( Usage:   .axinfo <guid>)
cr .( Example: .axinfo {0002DF01-0000-0000-C000-000000000046})
