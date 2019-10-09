\ $Id: HelpStruct.f,v 1.4 2011/11/18 22:40:00 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008


\ ------------------------------------------------------------------------------
\ Data Types and Data Structures
\ ------------------------------------------------------------------------------

\ *S Presentation
\ *P This package implements :
\ *B Basic data types
\ *B Record structure, any level of imbrication
\ *B Arrays of any dimensions and any datatype, including records

\ *N Basic data types
\ *L |c||l|
\ *| Definer   | Data type                                         |
\ *| Byte=     | char, or 1 byte integer                           |
\ *| Word=     | 2 bytes integer                                   |
\ *| DWord=    | cell, or 4 bytes integer                          |
\ *| Double=   | 8 bytes integer                                   |
\ *| String=   | counted string, max length 255 chars              |
\ *| ZString=  | null terminated string, max length 255 chars      |
\ *| ZUnicode= | null terminated unicode string ( 2 bytes by char) |
\ *| Float=    | 8 bytes floating point numbers                    |
\ *P Theese words are defining words for variables of different data types :
\ *E Examples :
\ **         DWord= adword
\ **     20 String= astring      \ astring is a 21 bytes (including count) string
\ **   30 ZUnicode= azunicode    \ azunicode string (storage size 62 bytes)
\ *P adword, astring and azunicode are called "instances". Althought using a syntax
\ ** similar to the usual Forth style (ie "var @" ), the words created as instances
\ ** of data types don't behave like usual Forth variables. They don't push on stack
\ ** a storage address. Instead they push a handle (actually their pfa). That means
\ ** that we need special words for getting their addresses. Theese words can be
\ ** considered as "methods" in that they know the type of the variable and act
\ ** accordingly. The "methods" names begin with the character "v", standing for
\ ** "variant" or "generalized variables". The same "v???" word is thus used with any
\ ** data type.
\ *E Examples :
\ **    adword v@              \ @ the contents of adword
\ **    c" forth" astring v!   \ store "forth" in astring
\ **    adword vaddr           \ gives the top adrress storage of adword
\ **    adword vaddr @         \ @ the contents of adword
\ *P New basic data types can be defined with the word BASICDATATYPE . If you do so,
\ ** have a look at the source before in order to understand how to define methods
\ ** for them.

\ *N Records
\ *P Records are defined using the words :DATATYPE ... ;DATATYPE as in:
\ *E    :DataType Foo=
\ **           word= aword
\ **           byte= abyte
\ **    ;DataType
\ **    foo= afoo              \ create an instance of foo=
\ **    afoo abyte vaddr       \ give the address of abyte
\ *P As a syntax rule, append "=" to every new datatype (basic or record) you define.
\ ** Records can be imbricated without limitations.

\ *N Arrays
\ *P Arrays are defined with the following syntax :
\ *E    Array[ 9 ]Of dword= darray[]         \ an array of 10 dword
\ **    Array[ 3 ]Of 30 string= sarray[]     \ an array of 4 31-bytes-long strings
\ **    Array[ 10 8 ]Of float= matrix[]      \ two dimensions array
\ **    Array[ 5 ]Of foo= fooarray[]         \ is legal
\ *P As a syntax rule, append "[]" to every array you define. Arrays can be of any number
\ ** of dimensions. Every dimension is 0 based. Arrays can be defined inside records and
\ ** arrays of records too. Array indexes are prefixed :
\ *E    1 2 matrix[] v@                      \ get contents from 2nd row and 3rd column
\
\ *N Words WITH( .. )WITH .. END-WITH :
\ *P If you have to work on several fields deeply imbricated in a structure, you can
\ ** avoid repeating the long path every time ( With( ... End-With sequences cannot be
\ ** imbricated however). Example :
\ *E    :DataType Date=
\ **             dWord= Year
\ **              Byte= Month
\ **              Byte= Day
\ **    ;DataType
\ **
\ **    :DataType Person=
\ **           30 string= FirstName
\ **           50 string= Address
\ **                Byte= Age
\ **                Byte= Sex
\ **                Date= DateOfBirth
\ **    ;DataType
\ **
\ **    :DataType Company=
\ **                   20 String= Name
\ **         Array[ 9 ]Of Person= Employee[]
\ **    ;DataType
\ **
\ **    company= aLittleCompany                     \ create instance
\ **
\ **    aLittleCompany vinit                        \ initialize
\ **
\ **    With(  aLittleCompany 2 Employee[]  )With   \ set some values
\ **    28            Age        v!
\ **    'M'           sex        v!
\ **    1980          DateofBirth Year  v!
\ **    1             DateofBirth Day   v!
\ **    end-with
\ *P
\ *P You can also handle parts of the path as a whole such as in :
\ *E    aLittleCompany 2 Employee[] vaddr          \ copy employee(2)
\ **    aLittleCompany 1 Employee[] vaddr          \ in employee(1)
\ **    Employee[] SizeofElt        cmove
\ *P The job of vaddr is to deduce a storage address from the possibly many parameters
\ ** on stack (pfas and array indexes). Hence the "..manyparams.." used in stack comments
\ ** in the glossary.
\
\ *N Data allocation
\ *P By default, all instances are affected a data storage area in the dictionary. To
\ ** allow dynamic allocation, use the directive DYNAMIC and words VALLOC and VFREE. Only
\ ** terminal instances should be dynamically allocated (eg aLittleCompany).
\ *E    Dynamic foo= afoo
\ **    afoo valloc
\ **    ...
\ **    afoo vfree
\ *P Similarly vmap and vunmap allow access to memory mapped files.
\
\ *N More info
\ *B Data storage for fields in a record is contiguous.
\ *B There is no encapsulation, all defined types, structures and instances are global.
\ *B Syntax and error checking is leveled to a very minimum - be careful. Moreover, some
\ ** mistakes can be misleading. For instance, if you intend to mean "afoo aword v@ " but
\ ** you type "afoo adword v@" you will get the value of adword (which is not a field of
\ ** afoo but another, standalone, one) and the unused pfa of afoo on stack. This
\ ** behaviour is normal.
\ *B Candidate methods are v. atov (ascii to v).

\ *S Glossary


anew -DataStruct.f



\ ------------------------------------------------------------------------------
\ Some primers
\ ------------------------------------------------------------------------------

false value Array?              \ true while array definition or indexing
false value Nested?             \ true while nested data type definition
false value Dynamic?            \ true while unallocated data type definition
false value With?               \ while a With( )With : storage address
Create WithInstance             \ dummy instance built by )With
       6 cells allot

: ResetDataTyping ( -- )
               false to Array?
               false to Nested?
               false to Dynamic?
               false to With?
               WithInstance 6 cells erase ;

Reset-Stack-Chain chain-add ResetDataTyping      \ reset on error


\ ------------------------------------------------------------------------------
\ Some primitives
\ ------------------------------------------------------------------------------

\ access body of basic data type definers

0       offset bdSize                        ( pfa -- AddrOfDatasize )
  cell  offset bdxt                          ( pfa -- AddrOfFirstxt )

\ access body of data type instances (standalone or nested) and records

0       offset diSize                        ( pfa -- AddrOfEltDataSize )
  cell  offset diLink                        ( pfa -- AddrOfLink )
2 cells offset diOff                         ( pfa -- AddrOfStorageOrOffset )
3 cells offset diDef                         ( pfa -- AdrOfpfaDefiner )
4 cells offset diPar                         ( pfa -- AdrOfpfaParent )
5 cells offset diTotalSize                   ( pfa -- AdrOfTotalDataSize )
6 cells offset di#Dims                       ( pfa -- topaddrcell )
7 cells offset (diDim)                       ( pfa -- AddrDim0 )

: diDim                                      ( n0dim pfa -- AddrDim )
        (diDim) swap cells + ;               ( 0 <= n0dim <= nbdims-1 )


: Isarray?       ( pfainstance -- flag )
\ *G Gives a true flag if the data type instance is an array
                 diTotalSize @ 0<> ;


\ ------------------------------------------------------------------------------
\ basic data type definer
\ ------------------------------------------------------------------------------

\ to use the addresses of string basic data types before they are defined
0 Value 'String=
0 Value 'ZString=
0 Value 'ZUnicode=

: CreateInstance \ stack effect :
                 \ if standalone instance :
                 \ ( [arrayinfo] [stringlength] pfaDefiner -- )
                 \ if nested instance :
                 \ ( pfaParent pfaWhereStoreLink curroffset [arrayinfo] [stringlength]
                 \   pfaDataTypeDefiner  -- pfaParent newpfaWhereStoreLink newcurroffset )
                >r                           \ R: pfaDefiner
                CREATE
                here                         \ pfaInstance
                r@ bdsize @ ?dup             \ basic data type = string ?
                if   ,                       \ no : get size from basic data type
                else swap                    \ yes: stringsize should be on stack
                     r@
                     case
                       'String=   of 1+ endof
                       'ZString=  of 1+ endof
                       'ZUnicode= of 1+ 2* endof
                     endcase
                     ,
                then                         \ (was to be done before array handling)
                0 ,                          \ init link to 0
                0 ,                          \ transient offset/PtrToStorage
                r> ,                         \ pfaDataTypeDefiner
                0 ,                          \ transient pfaParent if nested (else remains 0)
                Array?
                if   >r                      \ save pfaInstance, so: ( dim1..dimn #dims -- )
                     0 ,                     \ transient total data size
                     dup ,                   \ compile #dims
                     0 do , loop             \ and dims
                     r>                      \ compute #elts :
                     1 over di#dims @        \ ( pfainstance #elts currdim -- )
                     begin
                       dup 0> while
                       dup 1- 3 pick didim @ 1+ \ #elts of this dim
                       rot * swap            \ current total #elts
                       1-                    \ do next dim
                     repeat
                     drop                    \ ( pfainstance #elts -- )
                     over disize @ *         \ compute total size
                     over diTotalSize over swap !
                else 0 ,                     \ not an array : Totaldatasize = 0
                     dup disize @            \ and size = basic datatype size
                then                         \ ( pfaInstance datasizetoallot -- )
                Nested?
                if   >r 2dup diOff ! r>      \ store current offset
                     rot + swap              \ set current offset for next field
                     3 pick over diPar !     \ set parent
                     rot diLink over swap !  \ update previous link
                     swap
                     0 to Array?             \ reset only array flag
                else Dynamic?                \ only unnesteds can be unallocated
                     if   2drop                      \ drop pfaInstance & size
                     else swap diOff here swap !     \ set storage address
                          here swap dup allot erase  \ allocate in dictionnary
                     then
                     ResetDataTyping         \ reset everything
                then ;


: BasicDataType
\ *G Compilation ( xt6 xt5 xt4 xt3 xt2 xtv! xtv@ SizeOfDataType -<name=>- -- ) \n
\ **    Defines a new basic data type. Syntax rule : append a "=" to name. \n
\ ** Execution of defined word -<name=> : ( [arrayinfo] [string size] -<aname>- -- ) \n
\ **    Creates an instance of -<name=>- \n
\ ** Execution of defined word -<aname>- : ( -- itspfa )
         CREATE                                 \ compile basic data type definer
                ,                               \ datatype size (0 if string)
                , , , , , , ,                   \ execution xts of methods
                \
         DOES>  \ Execute: ( [arraydims] [stringLength] -<name>- -- [pfaInstance] )
                \          Create an instance of the basic datatype
                \          If nested instance, more complex data stack handling to
                \          handle subtypes chaining and offsets (see CreateInstance)
                CreateInstance
                DOES> ;          \ at execution the created instance gives its pfa



\ ------------------------------------------------------------------------------
\ Basic data types definition
\ ------------------------------------------------------------------------------

\ dummy xts for now

  0 0 0 0 0 0 0  1 chars  BasicDataType Byte=
  0 0 0 0 0 0 0  cell 2/  BasicDataType Word=
  0 0 0 0 0 0 0  cell     BasicDataType DWord=
  0 0 0 0 0 0 0  cell 2*  BasicDataType Double=
  0 0 0 0 0 0 0  0        BasicDataType String=
  0 0 0 0 0 0 0  0        BasicDataType ZString=
  0 0 0 0 0 0 0  0        BasicDataType ZUnicode=
\ 0 0 0 0 0 0 0  b/float  BasicDataType Float=       \ extension, see below
\                                       Bit=         \ extension, candidate ?
\                                       DateTime=    \ extension, candidate ?

\ now we can set the addresses of string basic data types
' String=   >body to 'String=
' ZString=  >body to 'ZString=
' ZUnicode= >body to 'ZUnicode=



\ ------------------------------------------------------------------------------
\ Arrays word set (array indexes are 0 based)
\ ------------------------------------------------------------------------------

: Array[        ( dim1 .. dimn -- dim1 .. dimn depth )
\ *G Start an array definition, as in : Array[ 2 3 ]Of dword= adArray[ \n
\ ** Dimensions are 0 based
                depth to Array? ;

: ]Of           ( dim1 ... dimn -- dim1 .. dimn #dims )
\ *G Ends an array definition, as in : Array[ 2 3 ]Of dword= adArray[
                depth Array? -
                dup 0= Abort" Array with no dimension"
                true to Array? ;

: Dim           ( pfaInstance i -- dimi )
\ *G Gives the size of the ith dimension of an array (i is 1 based, dimension is 0 based)
                over diTotalSize @ 0= abort" Not an array"
                over di#dims @ dup >r over <
                over 0 <= or abort" No such dimension in this array"
                r> swap -                 \ dims are stored in reverse order
                swap diDim @ ;


\ ------------------------------------------------------------------------------
\ Complex data types (ie records) definer
\ ------------------------------------------------------------------------------

: :DataType
\ *G Compilation ( -<name=>- -- ) \n
\ **    Start definition of a new record. Syntax rule : append a "=" to name. \n
\ ** Execution of defined word -<name=> : ( [arrayinfo] -<aname>- -- ) \n
\ **    Creates an instance of -<name=>- \n
\ ** Execution of defined word -<aname>- : ( -- itspfa )
         CREATE \ Create a complex data type definer (record) - Part One -
                true to Nested?
                here                       \ pfaParent
                dup                        \ pfa where to store next link
                0                          \ current subtype offset
                0 ,                        \ transient data size
                0 ,                        \ link to sybtypes, dummy for now
                \ ( pfaParent pfaWhereStoreLink CurrentOffset -- )
                \
CheckStack DOES>  \ the data type definer creates an instance of it
                CreateInstance
                  DOES>  ;                 \ the created instance gives its pfa


: ;DataType     ( pfaParent pfaWhereStoreLink Offset -- ) \ don't mind
\ *G End definition of a new record.
                \ Create a complex data type definer (record) - Part Two -
                nip swap diSize !          \ set totalsize of record
                ResetDataTyping ;          \ (last field link remains 0)


: vAddr        ( ..manyparams.. -- AddressOfInstance[elt] )
\ *G Get the storage address of an instance, following, on the stack, the path of
\ ** previous instances. For array instances vAddr also needs indexes to give the
\ ** address of storage of the right element. \n
\ ** Example: COMPANY 3 EMPLOYEE[] BIRTHDATE DAY vAddr
               0 >r                       \ init storage address
               begin                      \ we have at least a pfaInstance on stack
                 dup diOff @ r> + >r      \ update offset|addr from instance
                 dup IsArray?
                 if   dup di#dims @       \ number of dims
                      0 swap              \ init offset inside array
                      1 swap              \ init *coeff
                      0 do                ( ..pars.. indexes pfa arroff *coeff -- )
                        3 roll            ( ..pars.. indexes pfa arroff *coeff index -- )
                        i 4 pick didim @ over <          \ ---- array index range...
                        over 0< or                       \ ---- ...checking, comment...
                        abort" Array index out of range" \ ---- ...out for speed
                        over *            ( ..pars.. indexes pfa arroff *coeff *coeff*index -- )
                        rot + swap        ( ..pars.. indexes pfa newarroff *coeff -- )
                        i 3 pick diDim @ 1+ ( dims are 0 based)
                        *                 ( ..pars.. indexes pfa newarroff new*coeff -- )
                      loop
                      drop                ( ..pars.. indexes pfa arroff -- )
                      over diSize @       ( ..pars.. indexes pfa arroff eltsize -- )
                      *                   \ displacement in array
                      r> + >r             \ add to current offset
                 then                     \ now, array indexes, if any, are consumed
                 dup diPar @ 0<>          \ follow up while parent exists
                 while
                 With?                    \ if with( active and we reached sum-up path
                 if   dup diPar @         \ then insert WithInstance in path
                      WithInstance diDef @ =
                      if WithInstance swap then
                 then                     \ ( [..manyparams..] pfaParent pfaCurrent -- )
                 over diDef @
                 swap diPar @ <> Abort" Illegal parent"
               repeat
               diOff @ 0= abort" Unallocated dynamic instance" \ check on last parent
               r> ;


: With(        ( -- )
\ *G Start a path definition as in :   With( Company 3 Employee[]  )With
               With? abort" can't imbricate With( .. )With" ;

: )With        ( ..manyparams.. -- )
\ *G End a path definition as in :   With( Company 3 Employee[]  )With \n
\ ** The path can be used until END-WITH
               dup diDef @ WithInstance diDef !  \ copy last definer in WithInstance
               vaddr                             \ compute partial address from path
               WithInstance diOff !
               true to With? ;

: End-With     ( -- )
\ *G Cancel the path currently defined as in :  With( Company 3 Employee[]  )With
               ResetDataTyping ;


\ ------------------------------------------------------------------------------
\ Some utilities
\ ------------------------------------------------------------------------------

: SizeOf         ( pfaInstance -- totalsizeofdata )
\ *G Gives the total size of a data type instance
                 dup IsArray?
                 if   diTotalsize
                 else diSize
                 then @ ;

: SizeOfElt      ( pfaInstance -- sizeofdata )
\ *G If the instance is an array, gives the size of one element. \n
\ ** If the instance is not an array, gives its total size (same as SizeOf)
                 diSize @ ;

: vInit         ( ..manyparams.. -- )
\ *G Init instance to nulls \n
\ ** Use this only on "terminal" instances.
                dup IsArray?
                if dup di#Dims @ 0 do 0 swap loop then    \ if array, set 0 indexes
                dup SizeOf >r
                vaddr                  \ will abort if unallocated
                ?dup
                if r> erase else r> 2drop then ;

: vInitElt      ( ..manyparams.. -- )
\ *G If the instance is an array, initialize one element. \n
\ ** If the instance is not an array, initialize all (same as vInit)
                dup IsArray? not Abort" Not an array"
                dup diSize @ >r
                vaddr                  \ will abort if unallocated
                ?dup
                if r> erase else r> 2drop then ;

\ ------------------------------------------------------------------------------
\ The "methods" v@ v!
\ ------------------------------------------------------------------------------

: vcmpn    2dup          ( n1 n2 -- flag ) \ signed compare
           = if 2drop 0 exit then
           > if -1 else 1 then ;
: vcmpd    2over 2over   ( d1 d2 -- flag ) \ signed compare
           d= if 2drop 2drop 0 exit then
           d> if -1 else 1 then ;

: v@1      vaddr c@ ;    ( ..manyparams.. -- n )   \ @ an instance of Byte=
: v!1      vaddr c! ;    ( n ..manyparams.. -- )   \ ! in instance of Byte=
: vcmp1    vaddr c@      ( addr ..manyparams.. -- flag )
           swap c@ vcmpn ;

: v@2      vaddr w@ ;    ( ..manyparams.. -- n )   \ Word=
: v!2      vaddr w! ;    ( n ..manyparams.. -- )
: vcmp2    vaddr w@      ( addr ..manyparams.. -- flag )
           swap w@ vcmpn ;

: v@4      vaddr @ ;     ( ..manyparams.. -- n )   \ DWord=
: v!4      vaddr ! ;     ( n ..manyparams.. -- )
: vcmp4    vaddr @       ( addr ..manyparams.. -- flag )
           swap @ vcmpn ;

: v@8      vaddr 2@ ;    ( ..manyparams.. -- n )   \ Double=
: v!8      vaddr 2! ;    ( n ..manyparams.. -- )
: vcmp8    vaddr 2@      ( addr ..manyparams.. -- flag )
           swap 2@ vcmpd ;

: v@s      vaddr ;               ( ..manyparams.. -- countedstringaddr )
: v!s      dup SizeOfElt 1- >r   ( countedstringaddr ..manyparams.. --  )
           vaddr
           swap count r> min
           rot 2dup c! 1+ swap cmove ;
: vcmps    vaddr swap count            ( addr ..manyparams.. -- flag )
           rot count compare ;

: v@z      vaddr ;               ( ..manyparams.. -- nullterminatedstringaddr )
: v!z      dup SizeOfElt 1- >r   ( addr ..manyparams.. --  )
           vaddr
           swap dup 0 begin over c@ while 1 1 d+ repeat nip r> min >r
           over r@ cmove
           0 swap r> + c! ;
: vcmpz    abort" not yet implemented" ;

: v@u      vaddr ;               ( ..manyparams.. -- unicodestringaddr )
: v!u      dup SizeOfElt 1- 2/ >r   ( addr ..manyparams.. --  )
           vaddr
           swap   dup 0 begin over w@ while 2 1 d+ repeat nip   r> min
           0 ?do 2dup w@ swap w! 2 2 d+ loop
           drop 0 swap w! ;
: vcmpu    abort" not yet implemented" ;

\ now set the xts for defined basic data types
' byte=     >body bdxt    ' v@1 over !  ' v!1 over cell+ !  ' vcmp1 over 2 cells + !   drop
' word=     >body bdxt    ' v@2 over !  ' v!2 over cell+ !  ' vcmp2 over 2 cells + !   drop
' dword=    >body bdxt    ' v@4 over !  ' v!4 over cell+ !  ' vcmp4 over 2 cells + !   drop
' double=   >body bdxt    ' v@8 over !  ' v!8 over cell+ !  ' vcmp8 over 2 cells + !   drop
' string=   >body bdxt    ' v@s over !  ' v!s over cell+ !  ' vcmps over 2 cells + !   drop
' zstring=  >body bdxt    ' v@z over !  ' v!z over cell+ !  ' vcmpz over 2 cells + !   drop
' zunicode= >body bdxt    ' v@u over !  ' v!z over cell+ !  ' vcmpu over 2 cells + !   drop

: TypeExec      ( ..manyparams.. xtrank -- )
                over diDef @ bdxt swap cells + @ execute ;


: v@            ( ..manyparams.. -- x )
\ *G Get the contents of an instance, following, on the stack, the link of
\ ** previous instances. For array instances v@ also needs indexes to give the
\ ** address of storage of the right element. \n
\ ** Example: COMPANY 3 EMPLOYEE[] BIRTHDATE DAY v@
                0 TypeExec ;

: v!            ( x ..manyparams.. -- )
\ *G Set the contents of an instance, following, on the stack, the link of
\ ** previous instances. For array instances v! also needs indexes to give the
\ ** address of storage of the right element. \n
\ ** Example: 9 COMPANY 3 EMPLOYEE[] BIRTHDATE DAY v!
                1 TypeExec ;

: vcmp          ( addr ..manyparams.. -- flag ) \ unsigned compare
\ *G Compare addr contents with the contents of an instance.
\ ** Flag: -1 if [addr]<[instance] ; 0 if = ; 1 if [addr]>[instance]
\ ** Example: 9 COMPANY 3 EMPLOYEE[] BIRTHDATE DAY vcmp  "compare day and 9"
                2 TypeExec ;


\ ------------------------------------------------------------------------------
\ Basic datatype extension : 8 bytes floating point data type
\ ------------------------------------------------------------------------------

\ Also shows how to define a new basic data type from scratch

: v@f    vaddr f@ ;    ( ..manyparams.. -- ) ( F: -- f )
: v!f    vaddr f! ;    ( F: f -- ) ( ..manyparams.. -- )
: vcmpf  vaddr f@      ( addr ..manyparams.. -- flag )
         swap f@
         f2dup
         f= if f2drop 0 exit then
         f> if -1 else 1 then ;

0 0 0 0 ' vcmpf ' v!f ' v@f  b/float  BasicDataType Float=



\ ------------------------------------------------------------------------------
\ Dynamic allocation
\ ------------------------------------------------------------------------------

: Unallocated   ( -- )
\ *G Dynamic memory allocation directive such as in :  Unallocated dword= adword \n
\ ** Use this only on "terminal" instances.
                Nested? abort" Illegal in :DataType definition"
                true to Dynamic? ;

: vAlloc        ( pfaInstance -- )
\ *G Allocate memory for an Unallocated instance such as in :  adword valloc
                dup SizeOf malloc
                swap diOff ! ;

: vFree         ( pfaInstance -- )
\ *G Free memory of a dynamic instance such as in :  adword vfree
                dup diOff @ Free drop
                0 swap diOff ! ;

: vReAlloc      ( ??? -- ??? )
                \ vReAlloc if dynamically allocated (don't loose existing data)
                \ illegal on statically dictionary allocated (but no check ?)
                ;

: vMap          ( MapAddress pfaInstance -- )
\ *G Set a file memory mapping address in an unallocated instance
                diOff ! ;

: vUnMap        ( pfaInstance -- )
\ *G Free a file memory mapped instance
                0 swap diOff ! ;


: vResize       ( NewArrayDim pfaInstance pfaFieldToResize -- )
                \ redim array indexes or string sizes
                \ (consider a string as an array of characters)
                \ illegal on statically dictionary allocated (but no check ?)
                \ illegal on dynamically allocated (or do vReAlloc after ???)
\ ** Example: COMPANY new#Employees EMPLOYEE[] BIRTHDATE 12 (newlenghtofday) DAYOFWEEK vReSize
                3drop ;
\ Avec la syntaxe de l'exemple ci-dessus, on ne peut pas faire un truc automatique
\ car il nécessiterait de remonter d'un field jusqu'au premier field du record afin
\ de monter traiter la fin de record parent et ainsi de suite. On ne peut pas le faire
\ parce qu'on n'a pas de lien rétrograde.
\ Une autre solution serait de définir des mots :ResizeType ;ResizeType et
\ ResizeArray qui, en répétant la séquence de la définition initiale de la structure
\ permettrait une mise à jour progressive des tailles et offsets sur la base des
\ mots de fields et structures déjà existant. Mais cela revient en quelque sorte à
\ "redéfinir" l'ensemble et on a aussi vite fait de la dupliquer.
\ Par contre il reste intéressant de travailler sur vRealloc des array terminales, à
\ condition bien entendu de pouvoir conserver leur ancien contenu.



\ ------------------------------------------------------------------------------
\ Utilities (debugging)
\ ------------------------------------------------------------------------------


: .Instance     ( pfaInstance -- )
\ *G Print an instance, ex:   afoo .instance
\in-system-ok   cr ." Instance " dup cell - .name ." at : " dup .
                cr ."    Off/Sto = " dup diOff @ .
                cr ."    Link    = " dup diLink @ .
                cr ."    EltSize = " dup diSize @ .
                cr ."    Definer = " dup diDef @ .
                cr ."    Parent  = " dup diPar @ .
                dup diTotalSize @ 0=
                if   cr ."       - not an array -"
                else cr ."       Array : total data size = " dup diTotalSize @ .
                     cr ."               # dims = " dup di#dims @ dup .
                     0 do
                       cr ."               dim " i 1+ . ." = " i over didim @ .
                     loop
                then
                drop
                cr ;

: .record       ( xt -- )
\ *G Print a record structure, ex:   ' foo= .record
\in-system-ok   cr ." Definer : " dup .name
                >body     ( pfadefiner -- )
                cr ." Data size = " dup diSize @ .
                cr dup
                begin
                  diLink @ dup While
                  cr ." pfaField in link = " dup .
                  dup .instance
                repeat drop
                cr ." datasize " dup disize @ .
                drop
                cr ;


\s


\ ------------------------------------------------------------------------------
\ Test
\ ------------------------------------------------------------------------------

\ ------------------- test : dummy

dword= Mydword                      Mydword .instance

Unallocated dword= Mydword2             Mydword2 .instance

Array[ 2 3 ]Of dword= MyArray[]      MyArray[] .instance

12 string= astring                  aString .instance

:DataType Test=
    dword= sDword
    Array[ 3 2 ]Of dword= sArray[]
;DataType


Test= atest                         aTest .instance

:DataType TwoLevels=
    dword= tdword
    test= Mytest
;DataType

TwoLevels= 2levels                  2levels .instance

Array[ 5 ]Of TwoLevels= ArrLevels[]  ArrLevels[] .instance

With( 2levels mytest )With
    sdword vaddr cr .
    0 0 sArray[] vaddr cr .
    3 2 sArray[] vaddr cr .
End-With


\ ------------------- Demo : management style

:DataType Date=
         dWord= Year
          Byte= Month
          Byte= Day
;DataType

:DataType Person=
       30 string= FirstName
       50 string= Address
            Byte= Age
            Byte= Sex
            Date= DateOfBirth
;DataType

:DataType Company=
               20 String= Name
     Array[ 9 ]Of Person= Employee[]  \ arrays 0 based ==> 10 employees
;DataType



company= aLittleCompany   \ create instance, allocate in dictionary (default)

aLittleCompany vinit      \ initialize



create str1 ," aname"     \ pseudo vars to get some counted strings for demo
create str2 ," aaddress"

With(  aLittleCompany 2 Employee[]  )With
str1            FirstName  v!
str2            Address    v!
28              Age        v!
'M'             sex        v!
1980            DateofBirth Year  v!
1               DateofBirth Month v!
1               DateofBirth Day   v!
end-with

aLittleCompany .instance

aLittleCompany 2 Employee[] vaddr
aLittleCompany 1 Employee[] vaddr
Employee[] SizeofElt          cmove     \ you can handle structure parts as a whole


aLittleCompany 1 Employee[] vaddr   Employee[] SizeofElt   dump
aLittleCompany 2 Employee[] vaddr   Employee[] SizeofElt   dump

cr .( year = ) aLittleCompany 2 Employee[] DateOfBirth Year v@ .




((
Unallocated company= blittlecompany
blittlecompany valloc
bLittleCompany vinit      \ initialize

With(  bLittleCompany 2 Employee[]  )With
str1            FirstName  v!
str2            Address    v!
28              Age        v!
'M'             sex        v!
1980            DateofBirth Year  v!
1               DateofBirth Month v!
1               DateofBirth Day   v!
end-with
bLittleCompany 2 Employee[] vaddr   Employee[] SizeofElt   dump
blittlecompany vfree
))


\ ------------------- Demo : transpose a matrix

Unallocated Array[ 2 3 ]Of dword= ArrayO[]
Unallocated Array[ 3 2 ]Of dword= ArrayT[]

: Transpose     ( -- )
                ArrayO[] valloc
                ArrayT[] valloc
                2 0 do                      \ fill original matrix with some data
                  3 0 do
                    i 1+ j 2 + *   j i ArrayO[]  v!
                  loop
                loop
                cr                          \ print original matrix
                ArrayO[] 1 Dim 0 do
                  cr
                  ArrayO[] 2 Dim 0 do        \ if needed we can get array's dims
                    j i ArrayO[] v@ 6 .r
                  loop
                loop
                2 0 do                      \ transpose
                  cr
                  3 0 do
                    j i ArrayO[] v@  i j ArrayT[] v!
                  loop
                loop
                3 0 do                      \ print transposed matrix
                  cr
                  2 0 do
                    j i ArrayT[] v@ 6 .r
                  loop
                loop
                ArrayT[] vfree
                ArrayO[] vfree ;
transpose

\s

\ ------------------------------------------------------------------------------
\ ***** Technical Info *****
\ ------------------------------------------------------------------------------

How the data structures are compiled in dictionary
--------------------------------------------------

Suppose we define the complex data structure definer BAR= as follows

:DataType  foo=                 \ define definer foo=
    20 string= astring          \ embedded instances of basic datatypes
    Array[ 5 ]Of byte= abarray[]
;DataType

:DataType bar=                  \ define definer bar=
    word= aword
    foo=  afoo                  \ embedded instance of complex datatype
;DataType

bar= abar                       \ an instance of bar= (could be an array)

Here is what we get in the dictionnary (the names are not given in the order
of their creation in dictionnary)

        bar=
  *---> - size = 28
  | *-- - link
  | |
  | |   aword
  | |   - size = 2                                                         Storage
  | *-> - link = afoo
  | |   - offset = 0 .......................................................> *
  | |   - definer = aword= --------------------------------> word=            *
  *-|-- - parent = bar=                                      - size = 2 ....> *
  | |   - totalsize = 0 (not an array)                       - xts      . .   *
  | |                                                                   . .   *
  | |   afoo                                                            . .   *
  | |   - size = 26                                                     . .   *
  | *-> - link = 0                                                      . .   *
  |     - offset = 2 .................................................... .   *
  |     - definer = foo= ------> foo=                                     .   *
  *---- - parent = bar=    *---> - size = 26                              .   *
        - totalsize=0      | *-- - link = astring                         .   *
                           | |                                            .   *
                           | |   astring                                  .   *
                           | |   - size = 21 (20 char + cnt)              .   *
                           | *-> - link = abarray                         .   *
                           | |   - offset = 0 .............................   *
                           | |   - definer = string= ------> string=          *
                           *-|-- - parent = foo=             - size = 0       *
                           | |   - totalsize=0               - xts            *
                           | |                                                *
                           | |   abarray[]                                    *
                           | |   - size = 1                                   *
                           | *-> - link = 0                               ..> *
                           |     - offset = 21 ............................   *
                           |     - definer = byte= --------> byte=            *
                           *---- - parent = foo=             - size = 1       *
                                 - totalsize = 5             - xt for v@      *
                                 - #dims = 1                 - xt for v!
                                 - dim1 = 5                  - xt for vcmp
                                                             - xt for vucmp
The instance of bar= is :                                    - xt for v.
                                                             - xt for vatov
abar                                                         - xt for reserved
- size = 28
- link = 0
- offset = address of storagearea
- definer = bar=
- parent = 0
- totalsize = 0
- storagearea (if static)



There are 3 header types :
- the basic data types definers : size & xts of execution for a few methods
- the record, which holds its size and is primarily a link of fields
- the instance, which share the size cell with the 2 others and the link cell
  with the record.

The link, definer and parent cells are self explanatory. Notice that the link
field is actually not used. The offset cell can contain either an offset (in
intermediate nested instances) or a storage address (in "terminal" instances).
Dynamic terminal instances have a null storage address until allocated.
The size cell is more complex. In a basic datatype definer it contains the type
size or 0 for strings. In instances of strings, it contains the actual string size
(including count byte or null or 2 bytes chars). In records, it contains the
total size of the record. If the instance is an array, size is the size of a
single element. The cell totalsize then contains the total size of the array.
A totalsize of 0 means "not an array".

Notice that there are no links from definers to instances. This is not possible
because there can be any number of instances for a given definer.


How do we get the address of a field : vaddr
--------------------------------------------

In the following sequence, COMPANY is an instance of a complex datatype
defining a path EMPLOYEE BIRTHDATE DAY, EMPLOYEE being an array, we want
to store 9 in the day of birth of the 32th employee of the company.

9 COMPANY 3 EMPLOYEE[] DATEOFBIRTH DAY v!

Such a sequence will have the following data stack effect:

   9     COMPANY      3    EMPLOYEE[]  BIRTHDATE   DAY        v!
                                                 pfaday
                                       pfaBirth  pfaBirth
                             pfaEmpl   pfaEmpl   pfaEmpl
                      3         3         3         3
         pfaComp   pfaComp   pfaComp   pfaComp   pfaComp
   9        9         9         9         9         9
 Data--  -------   -------   -------   -------   -------   -------


The job of vaddr is to deduce a storage address from the possibly many parameters
on stack (pfas and array indexes). Hence the "..manyparams.." in stack comments.

The sequence With( ... )With ... End-With is used to avoid repeating the same
beginning path for a set of possibly intermediate fields. The word )With achieves
this by setting a pseudo instance wich is a "sum-up" of the beginning path.



