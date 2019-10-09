\ $Id: FCOM.F,v 1.9 2013/11/28 21:19:29 georgeahubert Exp $

\ Component Object Module Interface for Win32forth
\ Tom Dixon

needs Unicode

anew -FCOM.f

winlibrary oleaut32.dll

1 proc CoInitialize
5 proc CoCreateInstance
2 proc CLSIDFromProgID
2 proc StringFromCLSID
2 proc CLSIDFromString
5 proc LoadRegTypeLib
2 proc LoadTypeLib
1 proc CreateErrorInfo
2 proc GetErrorInfo
2 proc SetErrorInfo
3 proc LHashValOfNameSys

[UNDEFINED] ISTR= [IF] synonym  ISTR= STR(NC)= [THEN]

\ Defining GUIDs

 in-system

internal

: hatoi number? 2drop ;

external

: (Guid,) ( addr len -- ) \ comments in a guid
  Base @ >r HEX dup 38 <> abort" Invalid Guid Length"
  1 /string  2dup ascii - scan 2dup >r >r nip - hatoi ,
  r> r> ascii - skip 2dup ascii - scan 2dup >r >r nip - hatoi w,
  r> r> ascii - skip 2dup ascii - scan 2dup >r >r nip - hatoi w,
  r> r> ascii - skip 2dup drop 2 0 do dup i 2 * + 2 hatoi c, loop drop
  ascii - scan ascii - skip drop 6 0 do dup i 2 * + 2 hatoi c, loop drop r> base ! ;

: Guid, ( -- ) \ comments in a guid
  BL Word count (Guid,) ;

: CLSID>Str ( addr -- str len )
  pad swap StringFromCLSID abort" Not a CLSID!" pad @ 0
  begin over w@ while 2 2 d+ repeat nip pad @ swap ;

internal

\ simple interface defining words

: interface-call ( n1 n2 n3 ... nx a indx ) \ vtable call
  >r @ dup @ r> cells+ @ call-proc ;

: RUN-INTERFACE ( pointer imethod -- ) \ runtime interface call
  cell+ @ interface-call ;

: COMPILE-INTERFACE ( pointer imethod -- ) \ fast compile interface call
  POSTPONE @ POSTPONE dup POSTPONE @
  cell+ @ cells POSTPONE lit , POSTPONE + POSTPONE @ POSTPONE call-proc ;

: search-iface ( str len interface -- addr -1 | 0 )
  over if
  begin @ ?dup while
    3dup 3 cells + count istr= if nip nip true exit then
  repeat 2drop false
  else 2drop drop false then ;

external

\ Simple parsing words
: peek >in @ parse-word rot >in ! ;
: skip-word parse-word 2drop ;

\ defines a component interface
: ComIFace ( interface -- ) create 0 , 16 + , IMMEDIATE
  does> state @ if dup POSTPONE lit , then
  dup peek rot cell+ @ search-iface
  if state @ if COMPILE-INTERFACE else RUN-INTERFACE then skip-word then
  state @ if drop then ;

internal

0 value openiface

external

: IMethod ( n -- ) \ n is vtable index
  >System here openiface 16 + @ , openiface 16 + ! , ,
  here parse-word dup 1+ allot rot place System> ;

: UCOM ( pointer -- ) \ call using an interface
  bl word find if execute else count type abort" Not an interface!" then
  peek rot 16 + search-iface
    if state @ if COMPILE-INTERFACE else RUN-INTERFACE then skip-word then
  ; IMMEDIATE

: UUID ( |guid -- ) create guid, ;

: INTERFACE ( interface |guid -- )
    ?dup if create guid, 16 + here over @ , swap !
    else create guid, 0 , then ;

: Open-Interface ( interface -- ) to openiface ;
: Close-Interface ( -- ) 0 to openiface ;

\ define the unknown interface

0 Interface IUnknown    {00000000-0000-0000-C000-000000000046}
IUnknown Open-Interface
  3 0  IMethod IQueryInterface ( ppv riid -- hres )
  1 1  IMethod IAddRef ( -- refs )
  1 2  IMethod IReleaseRef (  -- refs )
Close-Interface

 in-previous

\ dispatch interface. IDispatch must be in application space because it's used by AX controls.

IUnknown Interface IDispatch     {00020400-0000-0000-C000-000000000046}
IDispatch Open-Interface
  2 3  IMethod GetTypeInfoCount ( pctinfo -- hres )
  4 4  IMethod GetTypeInfo ( ppTInfo lcid iTInfo -- hres )
  6 5  IMethod GetIDsOfNames ( dispid lcid cnt uNames riid -- hres )
  9 6  IMethod Invoke ( argerr exinfo vres dispparams wflags lcid riid Idmem -- hres )
Close-Interface

UUID GUID_NULL {00000000-0000-0000-0000-000000000000}

in-system

\ **** AUTOMATION ****
\ this is the point where automation tries to control the rigors of
\ defining interfaces and types.

\ These are the three main type library interfaces
\ ITypeComp is the one we use most.

IUnknown Interface ITypeLib      {00020402-0000-0000-C000-000000000046}
IUnknown Interface ITypeInfo     {00020401-0000-0000-C000-000000000046}
IUnknown Interface ITypeComp     {00020403-0000-0000-C000-000000000046}

ITypeInfo Open-Interface \ define the interface
  2 3  IMethod GetTypeAttr ( TypeAttr -- hres )
  2 4  IMethod GetTypeComp ( ITypeComp -- hres )
  3 5  IMethod GetFuncDesc ( FuncDesc index -- hres )
  3 6  IMethod GetVarDesc  ( VarDesc index -- hres )
  5 7  IMethod GetNames ( pnames maxnames bstr memid -- hres )
  3 8  IMethod GetRefTypeOfImplType ( Hreftype index -- hres )
  3 9  IMethod GetImplTypeFlags ( flags index -- hres )
  4 10 IMethod GetIDsOfNames ( memid n bstr -- hres )
  8 11 IMethod Invoke ( argerr exceptinfo res DispParams flags memid pInst -- hres )
  6 12 IMethod GetDocumentation ( strfile context strdoc strname memid -- hres )
  6 13 IMethod GetDllEntry ( ordinal bstrname bstrdllname Kind memid -- hres )
  3 14 IMethod GetRefTypeInfo ( ITypeInfo Hreftype -- hres )
  4 15 IMethod AddressOfMember ( addr kind memid -- hres )
  4 16 IMethod CreateInstance ( pointer interface IUnknown -- hres )
  3 17 IMethod GetMops ( bstrmops memid -- hres )
  3 18 IMethod GetContainingTypeLib ( addr ITypelib -- hres )
  2 19 IMethod ReleaseTypeAttr ( TypeAttr -- n )
  2 20 IMethod ReleaseFuncDesc ( funcdesc -- n )
  2 21 IMethod ReleaseVarDesc ( vardesc -- n )
Close-Interface

ITypeLib Open-Interface \ define the typelib interface
  1 3  IMethod GetTypeInfoCount ( -- n )
  3 4  IMethod GetTypeInfo ( ITypeInfo index-- hres )
  3 5  IMethod GetTypeInfoType ( typekind index -- hres )
  3 6  IMethod GetTypeInfoOfGuid ( ITypeInfo guid -- hres )
  2 7  IMethod GetLibAttr ( TLibAttr -- hres )
  2 8  IMethod GetTypeComp ( ITypeComp -- hres )
  6 9  IMethod GetDocumentation ( bstrfile context bstrdoc bstrname index -- hres )
  4 10 IMethod IsName ( flag hashval bstrname -- hres )
  6 11 IMethod FindName ( found memid ITypeInfo hashval bstrname -- hres )
  2 12 IMethod ReleaseTLibAttr ( TlibAttr -- n )
Close-Interface

ITypeComp Open-Interface \ define the typecomp interface
  7 3  IMethod Bind ( bindptr desckind ptypeinfo wflags Hash uName -- hres )
  5 4  IMethod BindType ( ptypecomp ptypeinfo Hash uName -- hres )
Close-Interface


\ Error Handling Interfaces

IDispatch Interface ISupportErrorInfo   {DF0B3D60-548F-101B-8E65-08002B2BD119}
IUnknown  Interface IErrorInfo          {1CF2B120-547D-101B-8E65-08002B2BD119}
IUnknown  Interface ICreateErrorInfo    {22F03340-547D-101B-8E65-08002B2BD119}


ISupportErrorInfo Open-Interface
  2 7  IMethod InterfaceSupportErrorInfo ( riid -- hres )
Close-Interface

IErrorInfo Open-Interface
  2 3  IMethod GetGUID ( *GUID -- hres )
  2 4  IMethod GetSource ( bstrsource -- hres )
  2 5  IMethod GetDescription ( bstrdesc -- hres )
  2 6  IMethod GetHelpFile ( bstrfile -- hres )
  2 7  IMethod GetHelpContext ( n -- hres )
Close-Interface

ICreateErrorInfo Open-Interface
  2 3  IMethod SetGUID ( *GUID -- hres )
  2 4  IMethod SetSource ( bstrsource -- hres )
  2 5  IMethod SetDescription ( bstrdesc -- hres )
  2 6  IMethod SetHelpFile ( bstrfile -- hres )
  2 7  IMethod SetHelpContext ( n -- hres )
Close-Interface

internal

\ Quick Structures - Not very usefull for anything but working with
\ Com Interface structures, I wanted something simple that would allow
\ levels of unions and stuff, so I made a quick structure thing.

\ structure type
: StructType ( size -- ) create , 0 , ;

: StructSize ( structtype -- size ) @ ;

: search-struct ( str len structtype -- addr -1 | 0 )
  over if
  begin @ ?dup while
    3dup 4 cells + count istr= if nip nip true exit then
  repeat 2drop false
  else 2drop drop false then ;

external

\ defines a structure
: Struct ( structtype -- )  create dup cell+ , @ allot IMMEDIATE
  Suppress-system
  does> dup peek rot @ search-struct
    if skip-word dup 3 cells + @ execute + cell+
      state @ if POSTPONE lit , then
    else cell+ state @ if POSTPONE lit , then then ;

\ opens the structtype on any address
: USEStruct ( addr |structtype -- addr ) \ works like "using"
  bl word find if execute else type abort"  Not a valid structure!" then
  peek rot cell+ search-struct
    if skip-word dup 3 cells + @ execute
      state @ if POSTPONE lit , POSTPONE + else + then
    else state @ if POSTPONE lit , then then ;  IMMEDIATE

internal

0 value openstruct

: field-xt ( addr -- n ) cell+ @ ;

: struct-xt ( addr -- n ) dup cell+ @ swap 2 cells + @
  peek rot cell+ search-struct
  if skip-word dup 3 cells + @ execute + then ;

external

warning @ warning off checkstack

: Field: ( offset |name -- ) \ makes an offset
  here openstruct cell+ @ , openstruct cell+ ! , 0 , ['] field-xt ,
  here parse-word dup 1+ allot rot place ;

warning !

: Struct: ( offset structtype |name -- )
  here openstruct cell+ @ , openstruct cell+ ! swap , , ['] struct-xt ,
  here parse-word dup 1+ allot rot place ;

: Open-Struct ( interface -- ) to openstruct ;
: Close-Struct ( -- ) 0 to openstruct ;

\ Automation structures

\ VARIANT and VARIANTARG
16 StructType VARIANT  VARIANT open-struct
  0 field: vt
  2 field: wreserved1
  4 field: wreserved2
  6 field: wreserved3
  8 field: val  \ there are a Zillion different unions, just use val
close-struct

\ TYPEDESC structure
8 StructType TypeDesc  Typedesc open-struct
  0 field: lptdesc
  0 field: lpadesc
  0 field: hreftype
  4 field: vt
close-struct

\ IDLDESC structure
8 StructType IDLDESC  IDLDESC open-struct
  0 field: dwreserved
  4 field: wIDLFlags
close-struct

\ PARAMDESCEX structure
32 StructType PARAMDESCEX  ParamdescEx open-struct
  0 VARIANT struct: cbyte
  16 VARIANT struct: varDefaultValue
close-struct

8 StructType PARAMDESC  PARAMDESC open-struct
  0 field: pPARAMDescEx
  4 field: wPARAMFlags
close-struct


\ ELEMDESC structure
16 StructType elemdesc  elemdesc open-struct
  0 TypeDesc struct: tdesc
  8 IDLDESC  struct: idldesc
  8 PARAMDESC struct: paramdesc
close-struct

\ FUNCDESC structure
60 StructType FuncDesc  Funcdesc open-struct
  0 field: memid
  4 field: lprgscode
  8 field: lprgelemdescParam
  12 field: funckind
  16 field: invkind
  20 field: callconv
  24 field: cparams
  26 field: vparamsopt
  28 field: ovft
  30 field: cscodes
  32 ELEMDESC struct: elemdescFunc
  58 field: funcflags
close-struct

\ VARDESC structure
36 StructType VARDESC  vardesc open-struct
  0 field: memid
  4 field: lpstrSchema
  8 field: oInst
  8 field: lpvarValue
  12 ELEMDESC struct: elemdescVar
  28 field: wVarFlags
  32 field: varkind
close-struct

\ TYPEATTR structure
76 StructType TYPEATTR  TYPEATTR open-struct
  0 Field: guid
  16 field: lcid
  20 field: dwreserved
  24 field: memidConstructor
  28 field: memidDestructor
  32 field: lpstrSchema
  36 field: cbSizeInstance
  40 field: typekind
  44 field: cFuncs
  46 field: cVars
  48 field: cImplTypes
  50 field: cbSizeVft
  52 field: cbAlignment
  54 field: wTypeFlags
  56 field: wMajorVerNum
  58 field: wMinorVerNum
  60 TYPEDESC struct: tdescAlias
  68 IDLDESC struct: idldescType
close-struct

\ DISPPARAMS Structure
16 StructType DISPPARAMS  DISPPARAMS open-struct
   0 field: rgvarg		\ Array of arguments.
   4 field: rgdispidNamedArgs	\ Dispatch IDs of named arguments.
   8 field: cArgs		\ Number of arguments.
   12 field: cNamedArgs		\ Number of named arguments.
close-struct

in-previous

\ FuncKind enumeration
0 constant FUNC_VIRTUAL
1 constant FUNC_PUREVIRTUAL
2 constant FUNC_NONVIRTUAL
3 constant FUNC_STATIC
4 constant FUNC_DISPATCH

\ typekind enumeration
0 constant TKIND_ENUM
1 constant TKIND_RECORD
2 constant TKIND_MODULE
3 constant TKIND_INTERFACE
4 constant TKIND_DISPATCH
5 constant TKIND_COCLASS
6 constant TKIND_ALIAS
7 constant TKIND_UNION
8 constant TKIND_MAX

\ VarKind enumeration
0 constant VAR_PERINSTANCE
1 constant VAR_STATIC
2 constant VAR_CONST
3 constant VAR_DISPATCH

\ Invoke Kind
1 constant INVOKE_FUNC
2 constant INVOKE_PROPERTYGET
4 constant INVOKE_PROPERTYPUT
8 constant INVOKE_PROPERTYPUTREF

\ Desckind enumeration
0 constant DESCKIND_NONE
1 constant DESCKIND_FUNCDESC
2 constant DESCKIND_VARDESC
3 constant DESCKIND_TYPECOMP
4 constant DESCKIND_IMPLICITAPPOBJ
5 constant DESCKIND_MAX

\ pre-defined data types used by COM interface descriptors:
0    constant VT_EMPTY      \ no data associated with this
1    constant VT_NULL       \ same as a regular NULL
16   constant VT_I1         \ 1 byte signed integer
17   constant VT_UI1        \ 1 byte unsigned integer
2    constant VT_I2         \ 2 bytes signed integer
18   constant VT_UI2        \ 2 bytes unsigned integer
3    constant VT_I4         \ 4 bytes signed integer
22   constant VT_INT        \ same as VT_I4 but with a different code (?? what on earth are these people thinking!!?!)
19   constant VT_UI4        \ 4 bytes unsigned integer
23   constant VT_UINT       \ same as VT_UI4 but with a different code (I can only suppose for clarity....)
20   constant VT_I8         \ 8 bytes signed integer
21   constant VT_UI8        \ 8 bytes unsigned integer
4    constant VT_R4         \ IEEE 32-bit floating-point number
5    constant VT_R8         \ IEEE 64-bit floating-point number
6    constant VT_CY         \ 8 byte two's complement integer (scaled by 10000, used for currency)
7    constant VT_DATE       \ 64-bit floating-point number representing the days since Dec. 31, 1899
8    constant VT_BSTR       \ pointer to Null-terminated unicode string--see unicode notes above
9    constant VT_DISPATCH   \ pointer to a IDispatch interface
11   constant VT_BOOL       \ boolean value
10   constant VT_ERROR      \ 32-bit number containing status code
13   constant VT_UNKNOWN    \ pointer to a IUnknown interface
64   constant VT_FILETIME   \ 64-bit FileTime structure (see win32 api)
30   constant VT_LPSTR      \ pointer to Null-terminated ansi string
31   constant VT_LPWSTR     \ pointer to Null-terminated unicode string
72   constant VT_CLSID      \ pointer to guid (or a clsid, or what-have-you)
71   constant VT_CF         \ pointer to a clip structure
65   constant VT_BLOB       \ 32-bit count of bytes followed by that number of bytes
70   constant VT_BLOBOBJECT \ a blob containing a serialize object
66   constant VT_STREAM     \ pointer to an IStream interface
68   constant VT_STREAMED_OBJECT \ same as stream, but contains an object
67   constant VT_STORAGE    \ pointer to an IStorage interface
69   constant VT_STORED_OBJECT   \ same as storage, but contains an object
14   constant VT_DECIMAL    \ a decimal structure
24   constant VT_VOID       \ void (results I suppose)
25   constant VT_HRESULT    \ standard return code
26   constant VT_PTR        \ pointer to something
27   constant VT_SAFEARRAY  \ safearray
28   constant VT_CARRAY     \ normal array type
29   constant VT_USERDEFINED \ user defined type
$1000 constant VT_VECTOR     \ array of types, pointer to count, then pointer to the array
$2000 constant VT_ARRAY      \ pointer to safearray
$4000 constant VT_BYREF      \ value is a reference
$8000 constant VT_RESERVED   \ reserved type
$FFFF constant VT_ILLEGAL    \ illigal variant
12    constant VT_VARIANT    \ type indicator followed by corresponding value
$FFF  constant VT_ILLEGALMASK \ Illegal variant mask.
$FFF  constant VT_TYPEMASK   \ used as a mask for vt_vector, array and what-not

internal

in-system

: vt>Str ( vt -- str len )  \ for type to string conversion
  case
  0 of s" empty" endof
  1 of s" null" endof
  2 of s" h" endof
  3 of s" n" endof
  4 of s" f32" endof
  5 of s" f64" endof
  6 of s" d" endof
  7 of s" date-d" endof
  8 of s" bstr" endof
  9 of s" IDispatch" endof
  10 of s" error" endof
  11 of s" bool" endof
  12 of s" variant" endof
  13 of s" IUnknown" endof
  14 of s" decimal" endof
  15 of s" 15" endof
  16 of s" c" endof
  17 of s" c" endof
  18 of s" h" endof
  19 of s" n" endof
  20 of s" d" endof
  21 of s" d" endof
  22 of s" n" endof
  23 of s" n" endof
  24 of s" void" endof
  25 of s" hres" endof
  26 of s" ptr" endof
  27 of s" safearray" endof
  28 of s" carray" endof
  29 of s" udef" endof
  30 of s" lpstr" endof
  31 of s" lpwstr" endof
  64 of s" filetime-d" endof
  65 of s" blob" endof
  66 of s" IStream" endof
  67 of s" IStorage" endof
  68 of s" Streamedobj" endof
  69 of s" Storedobj" endof
  70 of s" Blobobj" endof
  71 of s" clip" endof
  72 of s" clsid" endof
  $1000 of s" Vector" endof
  $2000 of s" Array" endof
  $4000 of s" byref" endof
  $8000 of s" Reserved" endof
  dup (.) rot
 endcase ;

in-previous

: argcells ( VT -- #cells ) \ returns the number of cells needed for a vtype
  dup 5 = if drop 2 exit then
  dup 6 = if drop 2 exit then
  dup 7 = if drop 2 exit then
  dup 20 = if drop 2 exit then
  dup 21 = if drop 2 exit then
  dup 64 = if drop 2 exit then
  dup VT_VARIANT = if drop 4 exit then drop 1 ;

\ typeinfo attributes
: tattr-allot ( itypeinfo -- typeattr ) \ allocates a typeattr structure from tinfo
  0 >r rp@ swap UCOM ITypeInfo GetTypeAttr drop r> ;

: tattr-free ( itypeinfo typeattr -- ) \ frees a typeattr struct
  swap UCOM ItypeInfo ReleaseTypeAttr drop ;

: tinfo>kind ( itypeinfo -- typekind ) \ returns a typekind constant
  dup tattr-allot dup UseStruct TYPEATTR typekind @ -rot tattr-free ;

: tinfo>nfunc ( itypeinfo -- typekind ) \ returns number of functions
  dup tattr-allot dup UseStruct TYPEATTR cFuncs w@ -rot tattr-free ;

: tinfo>nvars ( itypeinfo -- typekind ) \ returns number of variables
  dup tattr-allot dup UseStruct TYPEATTR cVars w@ -rot tattr-free ;

: tinfo>size ( itypeinfo -- size ) \ returns structure size
  dup tattr-allot dup UseStruct TYPEATTR cbSizeInstance @ -rot tattr-free ;

in-system

\ function stuff
: arg>vt ( funcdesc n -- vt ) \ returns argument type
  swap usestruct funcdesc lprgelemdescParam @ swap
  elemdesc structsize * + usestruct elemdesc tdesc vt w@ ;

: Typedesc>n  ( typedesc -- vt n  ) \ returns type and how many times its "pointed"
  0 over usestruct typedesc vt w@
  dup VT_PTR = if drop 1+ swap
    usestruct typedesc lptdesc @ recurse rot +
  else swap rot drop then ;

: arg. ( funcdesc n -- ) \ prints an argument
  swap usestruct funcdesc lprgelemdescParam @ swap elemdesc structsize * +
  usestruct elemdesc tdesc typedesc>n 0 ?do 42 emit loop vt>str type ;

: argsize ( funcdesc -- n ) \ returns size (in cells) of arguments
  dup UseStruct FuncDesc cparams w@ 0 swap 0
  ?do over i arg>vt argcells + loop nip ;

: funcoff ( funcdesc -- offset ) \ returns offset into vtable ( bytes )
  UseStruct FuncDesc oVft w@ ;

\ constant stuff
: varinst ( vardesc -- n ) \ returns constant or (if its a structure) an offset
  dup UseStruct VarDesc varkind @ case
  VAR_CONST of UseStruct VarDesc oInst @ UseStruct Variant Val @ endof
  VAR_PERINSTANCE of UseStruct VarDesc oInst @ endof
  drop -1 endcase ;


: >bindtype ( ustr tcomp -- tinfo) \ returns the ITypeinfo of ustr
  0 >r rp@ 0 >r rp@ 2swap 0 -rot UCOM ITypeComp BindType abort" Invalid Bind Type!"
  r> r> ?dup if >r rp@ UCOM ITypeComp IReleaseref drop r> drop then ;

: >bind ( ustr tcomp -- buf tinfo kind ) \ returns a typeinfo, desckind, and a buffer
  0 >r rp@ 0 >r rp@ 2swap 0 >r rp@ 0 2swap 0 -rot UCOM ITypeComp Bind
  abort" Unable to Bind to type!" r> r> r> -rot ;

: >bindf ( ustr tcomp -- buf tinfo kind ) \ returns a typeinfo, desckind, and a buffer
  0 >r rp@ 0 >r rp@ 2swap 0 >r rp@ INVOKE_FUNC 2swap 0 -rot UCOM ITypeComp Bind
  abort" Unable to Bind to type!" r> r> r> -rot ;

: >bindg ( ustr tcomp -- buf tinfo kind ) \ returns a typeinfo, desckind, and a buffer
  0 >r rp@ 0 >r rp@ 2swap 0 >r rp@ INVOKE_PROPERTYGET 2swap 0 -rot UCOM ITypeComp Bind
  abort" Unable to Bind to type!" r> r> r> -rot ;

: >bindp ( ustr tcomp -- buf tinfo kind ) \ returns a typeinfo, desckind, and a buffer
  0 >r rp@ 0 >r rp@ 2swap 0 >r rp@ INVOKE_PROPERTYPUT 2swap 0 -rot UCOM ITypeComp Bind
  abort" Unable to Bind to type!" r> r> r> -rot ;

: >bindpr ( ustr tcomp -- buf tinfo kind ) \ returns a typeinfo, desckind, and a buffer
  0 >r rp@ 0 >r rp@ 2swap 0 >r rp@ INVOKE_PROPERTYPUTREF 2swap 0 -rot UCOM ITypeComp Bind
  abort" Unable to Bind to type!" r> r> r> -rot ;

\ These words are for "dumping" interfaces and structures so you don't have
\ to look at documentation as much while your programming
\ They aren't as "thread-safe" as everything else in this Module, but I don't
\ think they need to be just to see what an interface has got.

create tbuf 256 allot
0 value vargs
0 value argtypei

: Typedesc>type ( typedesc -- ) \ prints a typedesc var to the screen
  dup typedesc>n over VT_USERDEFINED <> argtypei 0= or
  if 0 ?do 42 emit loop vt>str type drop
  else dup 0 ?do 42 emit loop nip 0 ?do usestruct typedesc lptdesc @ loop 0 >r rp@
    swap usestruct typedesc hreftype @ argtypei UCOM ITypeinfo Getreftypeinfo drop
    0 0 0 rp@ 0 >r rp@ -1 rot UCOM ITypeinfo GetDocumentation drop
    r@ zunicount unitype r> drop rp@ UCOM ITypeinfo ireleaseref drop
    r> drop 0 to argtypei then ;

: arg>str ( funcdesc n -- ) \ prints an argument to the screen
  swap usestruct funcdesc lprgelemdescParam @ swap
  elemdesc structsize * + usestruct elemdesc tdesc typedesc>type ;

: .methods ( typeinfo -- )  0 tbuf !
  dup tbuf 0 rot UCOM ITypeinfo GetRefTypeofImplType drop
  tbuf @ if 0 >r
    dup rp@ tbuf @ rot UCOM ITypeinfo GetRefTypeinfo drop
    rp@ recurse rp@ UCOM Itypeinfo Ireleaseref drop r> drop else drop exit then
  dup tinfo>nfunc
  0 ?do 2 spaces 0 to vargs
    dup tbuf i rot UCOM ITypeInfo getfuncdesc drop
    tbuf @ usestruct funcdesc cparams w@
    0 ?do tbuf @ i arg>vt argcells +to vargs loop 1 +to vargs
    vargs . tbuf @ usestruct funcdesc oVft w@ 4 / . ."  IMethod "
    tbuf @ usestruct funcdesc invkind @ INVOKE_PROPERTYGET = if ." Get" then
    tbuf @ usestruct funcdesc invkind @ INVOKE_PROPERTYPUT = if ." Put" then
    tbuf @ usestruct funcdesc invkind @ INVOKE_PROPERTYPUTREF = if ." PutRef" then
    dup 0 0 rot 0 tbuf 4 + rot tbuf @ @ swap UCOM ITypeinfo getdocumentation drop
    tbuf 4 + @ zunicount unitype space ." ( "
    tbuf @ usestruct funcdesc cparams w@
    0 ?do dup to argtypei tbuf @ dup usestruct funcdesc cparams w@ i - 1-
          arg>str space loop ." -- "
    tbuf @ usestruct funcdesc elemdescfunc tdesc vt w@ vt>str type ."  )" cr
    tbuf over UCOM Itypeinfo releasefuncdesc drop
  loop drop ;

: .sfield ( typeinfo -- ) \ types the fields in a structure
  tbuf over UCOM ITypeinfo gettypeattr drop
  tbuf @ usestruct typeattr cvars @
  over tbuf swap UCOM ITypeinfo releasetypeattr drop
  0 ?do
    dup tbuf i rot UCOM ITypeinfo getvardesc drop
    tbuf @ usestruct vardesc varkind @ VAR_PERINSTANCE =
    if 2 spaces
      tbuf @ usestruct vardesc elemdescvar tdesc vt w@ VT_USERDEFINED =
      if tbuf @ usestruct vardesc oInst @ .
        dup tbuf @ usestruct vardesc elemdescvar tdesc hreftype @
        tbuf 4 + swap rot UCOM ITypeinfo GetRefTypeinfo drop
        0 0 0 tbuf 8 + -1 tbuf 4 + UCOM ITypeinfo GetDocumentation drop
        tbuf 12 + tbuf 4 + UCOM Itypeinfo gettypeattr drop
        tbuf 12 + @ usestruct typeattr cbSizeInstance @
        tbuf 12 + @ tbuf 4 + UCOM Itypeinfo releasetypeattr drop
        4 > if
          tbuf 8 + @ zunicount unitype tbuf 4 + UCOM ITypeinfo ireleaseref drop
          ."  Struct: " else
          ." Field: " tbuf 4 + UCOM ITypeinfo ireleaseref drop then
        dup >r tbuf 4 + dup 4 + dup 4 + dup 4 + tbuf @ @ r>
        UCOM Itypeinfo getdocumentation drop
        tbuf 16 + @ zunicount unitype space ." \ ("  dup to argtypei
        tbuf @ usestruct vardesc elemdescvar tdesc typedesc>type ." ) "
        tbuf 12 + @ ?dup if zunicount unitype then
      else
        tbuf @ usestruct vardesc oInst @ . ." Field: "
        dup >r tbuf 4 + dup 4 + dup 4 + dup 4 + tbuf @ @ r>
        UCOM Itypeinfo getdocumentation drop
        tbuf 16 + @ zunicount unitype space ." \ ("  dup to argtypei
        tbuf @ usestruct vardesc elemdescvar tdesc typedesc>type ." ) "
        tbuf 12 + @ ?dup if zunicount unitype then then cr
      tbuf over UCOM ITypeinfo releasevardesc drop
  then loop drop ;

: .consts ( typeinfo -- ) \ list all constants in an Enumeration
  tbuf over Ucom ITypeinfo gettypeattr drop
  tbuf @ usestruct typeattr cvars w@
  over tbuf swap Ucom ITypeinfo releasetypeattr drop
  0 ?do
    dup tbuf i rot Ucom ITypeinfo getvardesc drop
    tbuf @ usestruct vardesc varkind @ VAR_CONST =
    if dup >r 0 0 0 tbuf 4 + tbuf @ @ r> UCOM ITypeInfo GetDocumentation drop
      tbuf 4 + @ zunicount unitype space
      tbuf over Ucom ITypeinfo releasevardesc drop
    then loop drop ;

: globaltype ( type typelib -- )
  dup UCOM ITypeLib GetTypeInfoCount 0 ?do
    2dup tbuf i rot UCOM ITypeLib GetTypeInfoType abort" Unable to get type info"
    tbuf @ = if dup 0 0 rot 0 tbuf rot i swap UCOM ITypeLib GetDocumentation
      abort" Unable to get Documentation!" tbuf @ zunicount unitype space
    then
  loop 2drop ;

create typelibhead 0 ,

external

: typelib ( major minor | guid -- ) \ load a type library into the list
  here typelibhead dup @ , !
  here dup >r 0 , here 0 , 2swap swap here guid, LoadRegTypeLib
  abort" Error Loading Type Library"
  r> dup cell+ swap UCOM ITypeLib GetTypeComp abort" Error Getting TypeComp" ;

: typelibfile ( ustr len -- ) \ load a type library from a file
  drop here typelibhead dup @ , !
  here dup >r 0 , 0 , swap LoadTypeLib
   abort" Error Loading Type Library"
  r> dup cell+ swap UCOM ITypeLib GetTypeComp
   abort" Error Getting TypeComp" ;

: CoClasses ( -- ) \ print a list of all available coclasses
  typelibhead begin @ dup while
  dup cell+ TKIND_COCLASS swap globaltype repeat drop ;

: Interfaces ( -- ) \ print a list of all available interfaces
  typelibhead begin @ dup while
  dup cell+ TKIND_INTERFACE swap globaltype
  dup cell+ TKIND_DISPATCH swap globaltype repeat drop ;

: Structures ( -- ) \ print a list of all available structures
  typelibhead begin @ dup while
  dup cell+ TKIND_RECORD swap globaltype repeat drop ;

: ComConsts ( -- ) \ print a list of all constants
  typelibhead begin @ dup while
  dup cell+ TKIND_ENUM swap globaltype repeat drop ;

internal

create tfind 256 allot

: get-next ( tcomp -- buf tinfo kind ) \ if kind = -1, then tinfo is a nested struct
  tfind count >unicode drop
  2dup swap >bind ?dup if >r 2swap 2drop r> parse-word tfind place exit then
  2drop swap >bindtype ?dup if 0 swap -1 parse-word tfind place exit then
  0 0 0 ;

: constbind ( vardesc tinfo -- ) \ constants
  >r rp@ UCOM ITypeInfo IReleaseref drop r> drop dup varinst swap CoTaskMemFree drop ;

: structbind ( vardesc tinfo -- offset ) \ structures
  >r rp@ UCOM ITypeInfo IReleaseref drop r> drop
  dup varinst swap CoTaskMemFree drop ;

: varbind ( vardesc tinfo -- n ) \ both structures and constants
  over UseStruct VarDesc varkind @ case
  VAR_CONST of constbind endof
  VAR_PERINSTANCE of structbind endof
  >r rp@ UCOM ITypeInfo IReleaseref drop r> drop CoTaskMemFree drop 0 endcase ;

: funcbind ( obj funcdesc tinfo -- ) \ function
  >r rp@ UCOM ITypeInfo IReleaseref drop r> drop
  dup funcoff swap CoTaskMemFree drop
  state @ if POSTPONE @ POSTPONE dup POSTPONE @ POSTPONE lit ,
             POSTPONE + POSTPONE @ POSTPONE call-proc
          else swap @ dup @ rot + @ call-proc then ;

: >allbind ( tcomp -- buf tinfo kind )
  dup peek >unicode drop swap >bindf ?dup if 2swap nip -rot exit else 2drop then
  peek drop 3 s" Get" istr= if peek 3 /string >unicode drop swap >bindg exit then
  peek drop 6 s" PutRef" istr= if peek 6 /string >unicode drop swap >bindpr exit then
  peek drop 3 s" Put" istr= if peek 3 /string >unicode drop swap >bindp exit then
  drop 0 0 0 ;

: do-ciface ( ptr itypecomp -- )
  >allbind DESCKIND_FUNCDESC = if bl word drop funcbind exit then
  ?dup if >r rp@ UCOM ITypeInfo IReleaseref drop r> drop then
  ?dup if CoTaskMemFree drop then ;

: ciface ( tinfo -- ) \ creates an interface pointer object
  create 0 , here 0 , swap >r rp@ UCOM ITypeinfo GetTypeComp drop
  rp@ UCOM ITypeInfo IReleaseRef drop r> drop IMMEDIATE
  Does> dup state @ if POSTPONE lit , then cell+ do-ciface ;

: nested-struc? ( vardesc -- htyperef )
  dup usestruct vardesc elemdescvar tdesc vt w@ VT_USERDEFINED = if
  usestruct vardesc elemdescvar tdesc hreftype @ else drop 0 then ;

: do-struct ( offset itypecomp -- offset )
  peek >unicode drop swap >bind
  DESCKIND_VARDESC = if bl word drop
  over nested-struc? ?dup if
    0 >r rp@ swap rot >r rp@ UCOM ITypeInfo GetRefTypeInfo drop
    rp@ UCOM ITypeInfo IReleaseref drop r> drop
    dup varinst swap CoTaskMemFree drop +
    rp@ 0 >r rp@ swap UCOM ITypeInfo GetTypeComp drop
    rp@ recurse
    rp@ UCOM ITypeComp IReleaseref drop r> drop
    rp@ UCOM ITypeInfo IReleaseref drop r> drop exit
  else structbind + exit then then
  ?dup if >r rp@ UCOM ITypeInfo IReleaseref drop r> drop then
  ?dup if CoTaskMemFree drop then ;

: CStruct ( tinfo -- ) \ creates a structure from a com typeinfo iface
  peek s" Words" istr= if bl word drop >r rp@ .sfield
        rp@ UCOM ITypeInfo IReleaseref drop r> drop exit then
  create here 0 , swap >r rp@ UCOM ITypeInfo GetTypeComp drop
  rp@ tinfo>size allot rp@ UCOM ITypeInfo IReleaseref drop r> drop IMMEDIATE
  Does> dup cell+ 0 rot do-struct + state @ if POSTPONE lit , then ;

: cguid ( tinfo -- ) \ compiles a guid
  >r rp@ tattr-allot dup UseStruct TYPEATTR guid
\in-system-ok state @ if 16 POSTPONE SLITERAL POSTPONE DROP
          else 16 new$ dup >r place r> 1+ then
  rp@ swap tattr-free rp@ UCOM ITypeInfo IReleaseref drop r> drop ;

: do-tinterface ( tinfo -- )
  peek s" ComIFace" istr= if bl word drop ciface exit then
  peek s" Words" istr= if bl word drop >r rp@ .methods
        rp@ UCOM ITypeInfo IReleaseref drop r> drop exit then
  cguid ;

: do-tdispatch ( tinfo -- )
  0 >r rp@ swap >r -1 rp@ UCOM ITypeInfo GetRefTypeOfImplType abort" No Virtual Interface!"
  r> r> swap 0 >r rp@ -rot >r rp@ UCOM ITypeInfo GetRefTypeInfo abort" No Virtual Interface!"
  rp@ UCOM ITypeInfo IReleaseRef drop r> drop
  rp@ tattr-allot dup UseStruct TYPEATTR wTypeFlags w@ $40 and
  swap rp@ swap tattr-free r> swap if
  peek s" ComIFace" istr= if bl word drop ciface exit then
  peek s" Words" istr= if bl word drop >r rp@ .methods
        rp@ UCOM ITypeInfo IReleaseref drop r> drop exit then
  cguid else cguid then ;

: Do-TypeLib ( tcomp -- flag ) \ performs the function of the typelib stuff
  tfind count >unicode drop swap 2dup >bind
  DESCKIND_VARDESC = if 2swap 2drop constbind
     state @ if POSTPONE lit , then true exit then
  ?dup if >r rp@ UCOM ITypeInfo IReleaseref drop r> drop then
  ?dup if CoTaskMemFree drop then
  >bindtype ?dup if >r rp@ tinfo>kind r> swap case
  TKIND_INTERFACE of do-tinterface true endof
  TKIND_DISPATCH of do-tdispatch true endof
  TKIND_COCLASS of cguid true endof
  TKIND_RECORD of cstruct true endof
  TKIND_ENUM of >r rp@ .consts rp@ UCOM ITypeInfo IReleaseref drop r> drop true endof
  drop ?dup if >r rp@ UCOM ITypeInfo IReleaseref drop r> drop then false exit
  endcase else false then  ;

\ Here is where we make the typelibraries appear "global"

: backup ( -- ) >in @ dup tib + swap bl -scan >in ! drop ;

: istype? ( str len tcomp -- flag )
  -rot >unicode drop 2dup swap >bind -rot
  ?dup if >r rp@ UCOM ITypeInfo IReleaseref drop r> drop then
  ?dup if CoTaskMemFree drop then
  ?dup if dup DESCKIND_VARDESC = swap DESCKIND_TYPECOMP = or
          if 2drop true exit else 2drop false exit then then
  swap >bindtype ?dup if
  >r rp@ UCOM ITypeInfo IReleaseref drop r> drop true else false then ;

variable typelibraries

: ?typelib ( c-addr len flag -- c-addr len flag )
   typelibraries @ 0= if EXIT then ?DUP ?EXIT
   typelibhead begin @ dup while
   dup 2 cells + 2over rot istype? if 2 cells + -rot tfind place do-typelib exit then
   repeat ;

: comfind ( str -- str 0 | cfa flag )
  [ action-of find compile, ]  \ call previous find word
  ?dup 0= if count 0 ?typelib if ['] noop 1 else drop 1- 0 then
  then ;

\in-system-ok  ' comfind is find

\ Late-Binding for Types in typelibraries (needed only for interfaces and structures)

: do-late-tcomp ( ptr typecomp kind -- )
  case TKIND_INTERFACE of do-ciface endof
  TKIND_DISPATCH of do-ciface endof
  TKIND_RECORD of 0 swap do-struct state @ if POSTPONE LIT , POSTPONE + else + then endof
  2drop endcase ;

: do-late ( tinfo -- )
  dup >r rp@ tinfo>kind r> drop TKIND_DISPATCH = if
  0 >r rp@ swap >r -1 rp@ UCOM ITypeInfo GetRefTypeOfImplType abort" No Virtual Interface!"
  r> r> swap 0 >r rp@ swap >r swap rp@ UCOM ITypeInfo GetRefTypeInfo abort" No Virtual Interface!"
  rp@ UCOM ITypeInfo IReleaseRef drop r> drop r> then
  >r rp@ 0 >r rp@ swap dup tinfo>kind -rot UCOM ITypeInfo GetTypeComp drop
  rp@ swap do-late-tcomp
  rp@ UCOM ITypeComp IReleaseref drop r> drop
  rp@ UCOM ITypeInfo IReleaseref drop r> drop ;

external

: COM ( | name -- ... ) \ followed by Interface or structure
  peek tfind place tfind parmfind if  \ old style interface
    execute bl word drop peek rot 16 + search-iface
    if state @ if COMPILE-INTERFACE else RUN-INTERFACE then bl word drop then
  else          \ automated interface
    drop typelibhead begin @ dup while
    dup 2 cells + peek rot istype? if 2 cells + parse-word 2dup tfind place >unicode drop swap >bindtype
      do-late exit then
    repeat 0= abort" Not An Interface!"
  then ; IMMEDIATE

typelibraries on

: free-lasttypelib ( -- ) \ frees the last type library
  typelibhead @ ?dup if
    dup @ typelibhead !
    dup cell+ UCOM ITypeComp IReleaseref drop
    2 cells + UCOM ITypeLib IReleaseref drop then ;

: freetypelibs ( -- )
  typelibhead begin @ dup while
    dup cell+ UCOM ITypeComp IReleaseref drop
    dup 2 cells + UCOM ITypeLib IReleaseref drop repeat
  drop 0 typelibhead ! ;

in-previous

: com_init 0 CoInitialize drop ;

Initialization-Chain Chain-Add Com_init
com_init

\in-system-ok unload-chain chain-add-before freetypelibs

internal

\ IDispatch Calling Interface
\ This is for calling methods in the IDispatch Interface.
\ It is a nasty calling convention that uses run-time type checking, passes arguments
\ through a bloated structure, and is slow.  Avoid these interfaces if possible.

\ The way to deal with it here is to pass argments on to a typed stack

16 CONSTANT maxvt \ Height of Stack

create VTstack  16 maxvt * allot \ stack
create VTNStack DISPID_PROPERTYPUT ,

DISPPARAMS Struct DispCall \ calling structure
  vtstack  DispCall rgvarg !
  vtnstack Dispcall rgdispidNamedArgs !

VARIANT Struct RetVT \ return value - only one allowed :-(

external

: vt@ ( addr -- n VT )
  dup w@ swap 8 + over argcells 2 = if 2@ rot else @ swap then ;
: vt! ( n VT addr -- )
  2dup w! 8 + swap argcells 2 = if 2! else ! then ;

: VT> ( -- n VT ) \ pop virtual type off stack
  DispCall cargs @ ?dup if 1- dup DispCall cargs !
    16 * DispCall rgvarg @ + vt@
  else 0 VT_EMPTY then ;

: >VT ( n VT -- ) \ push Virtual Type onto Stack
  DispCall cargs @ dup maxvt < if
    16 * DispCall rgvarg @ + vt! 1 DispCall cargs +!
  else abort" Variant Stack Full!" then ;

in-system

: .vt ( -- ) DispCall cargs @ 0 ?do
     DispCall rgvarg @ i 16 * + vt@ dup vt>str type ." : "
     argcells 2 = if d. else . then loop ;

in-previous

: retVT@ ( -- n VT ) RetVT vt@ ;

internal

variable disperr

: DispatchCall ( type ID Interface -- hres ) \ Call IDispatch Invoke method
  2>r >r disperr 0 RetVT DispCall r> 0 GUID_NULL 2r> UCOM IDispatch Invoke
  0 DispCall cargs ! 0 DispCall cnamedargs ! ;

: GetDispID ( ustr Interface -- ID ) \ Get Dispatch ID
  swap >r rp@ swap disperr 0 2swap 1 -rot GUID_NULL swap
  UCOM IDispatch GetIDsOfNames r> drop if 0 else disperr @ then ;

: methkind ( str len -- ustr kind )
  over 6 s" PutRef" Istr= if 3 /string >unicode drop INVOKE_PROPERTYPUTREF
			     1 DispCall cnamedargs ! exit then
  over 3 s" Put" Istr= if 3 /string >unicode drop INVOKE_PROPERTYPUT
			  DISPID_PROPERTYPUT VTNStack !
			  1 DispCall cnamedargs ! exit then
  over 3 s" Get" Istr= if 3 /string >unicode drop INVOKE_PROPERTYGET exit then
  >unicode drop INVOKE_FUNC ;

in-system

: .dispwords ( interface -- )
  0 >r rp@ 0 rot 0 swap UCOM IDispatch GetTypeInfo abort" Unable to Call Dispatch!"
  rp@ .methods rp@ UCOM ITypeLib IReleaseref drop r> drop ;

external

in-previous

: do-displate ( interface interface str len -- hres ) \ bind by string, not by ID
  methkind swap rot getdispID rot DispatchCall ;

in-system

: Do-Disp ( interface -- hres ) \ behavior of a dispatcher
  peek s" Words" Istr= if .dispwords skip-word exit then
  dup peek methkind swap rot
  getdispID dup 0= if 2drop state @ if POSTPONE lit , then exit else rot skip-word then
  state @ if swap POSTPONE lit , POSTPONE lit , POSTPONE DispatchCall
    else DispatchCall then ;

: Dispatcher ( <name> <progID> -- )
  create here 0 , here dup parse-word >unicode drop CLSIDFromProgID
  abort" Unable to Find ProgID!"
  IDispatch swap CLSCTX_SERVER 0 rot CoCreateInstance abort" Unable to Get IUnknown!"
  IMMEDIATE does> Do-Disp ;

: DispLate" ( interface "method"" -- hres ) \ late-late bound dispatch
  state @ if postpone dup postpone (s") ," postpone do-displate
   else dup [CHAR] " parse do-displate then ; IMMEDIATE

in-previous

module

((
 \ To use COM components, you must load the type library.  The type libraries
 \ installed on your machine can be found in HKEY_CLASSES_ROOT\TypeLib of the
 \ system registry.  Load your library with "TypeLib" command

  5 0 typelib {C866CA3A-32F7-11D2-9602-00C04F8EE628}  \ SAPI typelibrary

 \ 5 is the major version number and 0 is the minor version number.  The ugly
 \ string at the end is the GUID (globally unique identifier).  When you've
 \ loaded it up, all constants, interfaces, and structures can be called on
 \ your machine as if part of the forth system.
 \ To define an interface, use the word "ComIface" with the interface as the
 \ argument, like so:

  ISpVoice ComIFace voice

 \ Don't try to call any interface methods just yet, this only defined "voice".
 \ To Start up a component, you need to call CoCreateInstance (part of OLE32.DLL)

  voice ISpVoice 1 0 SpVoice CoCreateInstance [IF] ." Can't Load SPVoice!" [THEN]

 \ Now "voice" can be called as if it were an object.  If called
 \ with no method after it, it only returns a pointer to the Interface.

  0 0 u" Hello World!" drop voice Speak .

 \ if working properly, your computer should have said "Hello World!" through
 \ the speech API.  Congrats.  If all you have is a pointer to an interface,
 \ you can use "COM" to call it as an interface

  voice value igor
  0 0 u" I really DO speak Forth!" drop igor COM ISpVoice Speak .

 \ Constants work just like windows constants.  Structures are defining words
 \ by themselfs.  Here is an example of a structure SPPHRASE

  SPPHRASE phrase                \ define the structure phrase
  phrase cbsize @                \ fetch the size
  phrase rule ulID .             \ example of nested structure (gives address)

 \ There are some helper tools to make programming with COM easier.  if you
 \ call "words" right after an interface or a structure, it will generate the
 \ methods and fields contained within them.  Very useful for checking parameters.

  ISpVoice Words  \ lists all methods of the interface (except IUnknown methods)
  SPPHRASE Words  \ lists all fields of the structure.

 \ if, for one reason or another, you don't want to use the type libraries, you
 \ can define it yourself as shown below.

\  0 Interface IUnknown    {00000000-0000-0000-C000-000000000046}
\  IUnknown Open-Interface
\    3 0  IMethod IQueryInterface ( ppv riid -- hres )
\    1 1  IMethod IAddRef ( -- refs )
\    1 2  IMethod IReleaseRef (  -- refs )
\  Close-Interface

 \ you can do the same with structures, but there are better ways to do
 \ structures.

 \ My primary purpose in writing this was to make interfacing to COM just as
 \ easy as using a dll (if not more so).  I tried to make it fast, which may
 \ have lost some of the readability.  This only supports early-binding.  This
 \ shouldn't be a problem, because nearly every component out there has a "dual"
 \ interface anyway.
))

