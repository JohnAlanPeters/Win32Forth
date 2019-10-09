\ $Id: ExtStruct.f,v 1.11 2011/08/19 21:23:24 georgeahubert Exp $


\ C like structures.
\ Written by Jos v.d. Ven and Dirk Busch.
\ Based on a previous Struct.f by Jos.

cr .( Loading Extended C like structures... )

anew -ExtStruct.f

in-system

\ The following memory allocation words allow nesting and cloning
\ of a memory structure. Definitions made in C can be used with
\ small modifications. Use mkstruct: to allocate memory.

vocabulary Structs \ all vocabularies for the struct's go in this one
private    Structs \ and avoids name conflicts. e.g. word

internal

0 value  _struct

: _add-struct   ( sizeof.struct -- )  \ compile current offset and increment
    _struct , +to _struct ;

: add-struct    ( sizeof.struct "name" -- )  \ compiling: store current offset and increment
    _struct offset +to _struct ; \ run-time: ( addr -- addr+offset )

: byte          ( -- )       \ compiling: store offset and increment _struct by 1
   1 add-struct ;            \ run-time: ( offset - offset+dword ) immediate

: word          ( -- )       \ compiling: store offset and increment _struct by 2
   2 add-struct  ;           \ run-time: ( offset - offset+dword ) immediate

: dword         ( -- )       \ compiling: store offset and increment _struct by 4
   4 add-struct ;            \ run-time: ( offset - offset+dword ) immediate

: double        ( -- )       \ compiling: store offset and increment _struct by 8
   8 add-struct ;            \ run-time: ( offset - offset+dword ) immediate

: long_double   ( -- )       \ compiling: store offset and increment _struct by 10
   10 add-struct ;           \ run-time: ( offset - offset+dword ) immediate

: guid          ( -- )       \ compiling: store offset and increment _struct by 16
   16 add-struct ;           \ run-time: ( offset - offset+dword ) immediate

: qword         ( -- )       \ compiling: store offset and increment _struct by 32
   32 add-struct ;           \ run-time: ( offset - offset+dword ) immediate

: unsigned ;                 \ 0 can be ignored when allocating

' byte  alias char  \ 1 byte

\ Note: Changed INT and UINT to 4 bytes, because INT's are 32 Bit's long
\ under Windows (Samstag, Mai 29 2004 - 20:13 dbu)
' word  alias short \ 2 bytes
' word  alias ushort
' word  alias wchar

' dword alias long  \ 4 bytes
' dword alias int
' dword alias uint
' dword alias FOURCC   \ for storing four ASCII bytes in a 32-bit field
' dword alias ulong
' dword alias langid
' dword alias lpvoid
' dword alias float

' add-struct alias field:

\ Not standard in C
' dword alias HWND     \ 4 bytes
' dword alias HICON    \ 4 bytes
' dword alias COLORREF \ 4 bytes (added Samstag, Oktober 22 2005 dbu)
' word  alias ATOM     \ 2 bytes (added Montag, Mai 01 2006)


[DEFINED] b/float [IF]

: b/float                       \ compile-time: ( - )   \ 8 or 10
        b/float add-struct ;    \ run-time: ( offset - offset+dword )

[THEN]

: cell                          \ compile-time: ( - )  \ Forth depended
        cell add-struct ;       \ run-time: ( offset - offset+dword )

: offset                        \ compile-time: ( - ) It is a kind of label
        _struct offset ;        \ run-time: ( offset - offset+dword )

0 value current-voc

\ Close a struct definiton.

: ;struct       ( ptr-size -- )
        previous  _struct swap !  \ Store the size
        previous
        current-voc set-current
        -1 +to olddepth
        ;

: struct-voc[   ( -<name-struct>- -- wid )
       also structs get-current also ' execute ;

: ]struct-voc   ( wid -- )
        previous previous set-current ;

: getsize-struct    ( adr-struct - n )
        2 cells+ @ ;

external


\ return the size of <name-struct> in bytes

: sizeof        ( -<name-struct>- -- size )
   ' getsize-struct state @
        if   postpone literal
        then
        ; immediate

\ compiles the adress and offset as one adress inside a definition
: struct, ( -<Struct>- -<name-struct>- -<member>- -- )
        ' execute          \ struct_adress

        struct-voc[
          swap
          ' execute        \ struct_adress + offset_in_structure
          postpone literal
        ]struct-voc

        ; immediate

internal


: create-struct-voc ( addr len -- wid )
        get-current >r also Structs definitions
        ['] vocabulary execute-parsing
        voc-link @ cell+ ( wid )
        previous r> set-current ;

: create-struct ( addr len wid -- ptr-size ) \ Map: WID size
        -rot ['] create execute-parsing , immediate
        here -2 ,
        does> @ +order state @
              if   interpret \ Compile the offset+ part inside a definition
                   previous  \ and restore the order
              then
        ;

external

\ Open a struct definition.
\ A vocabulary <name-struct> is created.
\ All words for the struct members will be compiled into this vocabulary.
: :struct       ( -<name-struct>- -- ptr-size )
        /parse-word count ( addr len )

        \ create the vocabulary for the struct in the 'structs' vocabulary
        2dup create-struct-voc ( addr len wid )

        \ create a immediate word in current dict. That compiles the
        \ offset + part inside a definition at runtime
        dup>r sys-warning? >r sys-warning-off
        create-struct r> to sys-warning? r> ( wid )

        get-current to current-voc
        also set-current ( -- )
        also Structs

        0 to _struct
        1 +to olddepth
        ;

\ create a struct in the dictionary and fill it with zero's
\ Note create aligns the memory structures.
: mkstruct:     ( size-struct <-name-> -- )
     create here over allot swap erase ;

in-application

module

\s ----------------------------------------------------------------------------
\ Test
\ -----------------------------------------------------------------------------
hex

order

cr .( def: s1)
:struct s1
        byte b1
        word w1
        long l1
;struct

cr .( def: s2)
:struct s2
        long l1
        byte b1
        word w1
        int  i1
;struct

order

0 constant relative

cr .( Testing: s1)
cr .( sizeof: ) sizeof s1 .
cr .( makestruct: ) sizeof s1 mkstruct: struct1
struct1 sizeof s1 dump
order

s1
order

cr .( rel. positions and adresses: )
cr relative b1 . struct1 b1 .
cr relative w1 . struct1 w1 .
cr relative l1 . struct1 l1 .

cr .( fill-struct: )
11       struct1 b1 c!
2222     struct1 w1 w!
33333333 struct1 l1 !
struct1 sizeof s1 dump

previous
order

cr .( Testing: s2)
cr .( sizeof: ) sizeof s2 .
cr .( makestruct: ) sizeof s2 mkstruct: struct2
struct2 sizeof s2 dump
order

s2
order

cr .( rel. positions and adresses: )
cr relative l1 . struct2 l1 .
cr relative b1 . struct2 b1 .
cr relative w1 . struct2 w1 .
cr relative i1 . struct2 i1 .

cr .( fill-struct: )
33333333 struct2 l1 !
11       struct2 b1 c!
2222     struct2 w1 w!
44444444 struct2 i1 !
struct2 sizeof s2 dump

previous
order

cr .( Test compiling of struct-member-offsets )
: test
    55       struct1 s1 b1 c!
    6666     struct1 s1 w1 w!
    77777777 struct1 s1 l1  !

    77777777 struct2 s2 l1  !
    55       struct2 s2 b1 c!
    6666     struct2 s2 w1 w!
    88888888 struct2 s2 i1  !
;

see test
test
struct1 sizeof s1 dump
struct2 sizeof s2 dump

cr .( Test compiling of struct-member-offsets )
: test1
    11       struct, struct1 s1 b1 c!
    2222     struct, struct1 s1 w1 w!
    33333333 struct, struct1 s1 l1  !

    33333333 struct, struct2 s2 l1  !
    11       struct, struct2 s2 b1 c!
    2222     struct, struct2 s2 w1 w!
    44444444 struct, struct2 s2 i1  !
;

see test1
test1
struct1 sizeof s1 dump
struct2 sizeof s2 dump

cr .( Test sizeof inside a definition )
: test-sizeof
        cr ." sizeof s1: " [ sizeof s1 ] literal .
        cr ." sizeof s2: " [ sizeof s2 ] literal .
        ;
test-sizeof

: test-sizeof1
        cr ." sizeof s1: " sizeof s1 .
        cr ." sizeof s2: " sizeof s2 .
        ;
test-sizeof1

cr order

decimal
