\ December 25th, 2001 - 15:33  by J.v.d.Ven.  ( http://home.planet.nl/~josv )
\ Now it can be used with werror.f
\
\ Sonntag, April 04 2004 - dbu
\ - Made this source independent of toolset.f

needs struct.f

\ needs werror.f  \ load it when you need it
anew -com01.f   \ for Win32Forth

INTERNAL  WinLibrary OLE32.dll  EXTERNAL

only forth definitions decimal
#define CLSCTX_INPROC_SERVER     0x1
#define CLSCTX_INPROC_HANDLER    0x2
#define CLSCTX_LOCAL_SERVER      0x4
#define CLSCTX_INPROC_SERVER16   0x8
#define CLSCTX_REMOTE_SERVER     0x10
#define CLSCTX_INPROC_HANDLER16  0x20
#define CLSCTX_INPROC_SERVERX86  0x40
#define CLSCTX_INPROC_HANDLERX86 0x80
#define CLSCTX_ESERVER_HANDLER   0x100
#define CLSCTX_RESERVED          0x200
#define CLSCTX_NO_CODE_DOWNLOAD  0x400

: number-       ( <number-> - n )     ascii - word number drop ;

: iid:          ( <name> <2 spaces> <{guid}> - )
   create base @ hex       \ create seems to steal 1 character from word.
   ascii { word dup c@ + c@ bl <> abort" Need 2 spaces between name and guid"
   number- ,
   2 0 do number- w, loop
   number- dup 8 rshift c, 0x00ff and c,
  ascii } word count drop
   0xc 0
        do   dup i + 2 number? not abort" Error in guid." drop c, 2
        +loop
   drop base !
;

\ Note:  Minimal 2 spaces are needed between the name and the GUID-string
iid: IID_IUnknown        {00000000-0000-0000-C000-000000000046}

defined .werror-name nip not [IF]  \ define when werror.f is not loaded

defer .werror-name
' drop is .werror-name
: last,          ( - )  \IN-SYSTEM-OK last @  postpone literal ;
: .werror ( weror - ) cr  base @ over hex u. base ! .werror-name ;
: .failed        ( failed last - )
      over 0<>
      if    cr swap .werror ." Error: " nfa-count type
           ."  FAILED. "
\in-system-ok .s
           abort
      else 2drop
      then  ;
\ nonzero aborts in .failed
: ?failed        ( -- )   last, postpone .failed ; immediate

[THEN]

1 PROC CoInitialize
0 PROC CoUninitialize
: coinitialize   ( -- )   NULL call CoInitialize ?failed ;
: CoUninitialize ( -- )      call CoUninitialize ?failed ;

5 PROC CoCreateInstance
: connect       (  ppv clsid -- ) \ ^^vtable in ppv
   >r IID_IUnknown CLSCTX_ALL NULL r>
   call CoCreateInstance ;      ( ppv iid  grfContext pUnkOuter clsid - )

also Structs definitions

in-system

: stdmethodcalltype                   \ compile-time: ( -- )
   1 _struct constant +to _struct ;   \ run-time: ( offset -- offset )

in-application

forth definitions

struct{ \ IUnknownVtbl
        stdmethodcalltype *QueryInterface
        stdmethodcalltype *AddRef
        stdmethodcalltype *Release
}struct IUnknownVtbl

also Structs definitions

in-system

\ Will allocates IUnknown inside a structure
: interface_IUnknown  ( -- )  sizeof IUnknownVtbl _add-struct  ;

in-application

forth definitions

\ I_method should be able to call any method of an interface.
\ Just put the stack right. Each interface needs other parameters.

: I_method  ( /..depend on which../ abs-interface imethod - hresult|n )
  over @ swap cells+ @ call-proc ;

: std_imethod  ( -- ) \ compiles : I_method ?failed
   postpone I_method last, postpone .failed ; immediate

\ interface = absolute address of COM interface
\ riid = relative address of UUID
\ ppv = relative address of variable for result
                                       \ (p, a, b)
: IUnknown::QueryInterface ( abs-interface riid ppv -- ) \ riid ppv are relative
   3reverse ( 'ppv 'riid abs-interface ) \ made riid ppv absolute
   *QueryInterface i_method ?failed ;

: IUnknown::AddRef     ( abs-interface -- refs )  *AddRef   i_method ;
: IUnknown::ReleaseRef ( abs-interface -- refs )  *Release  i_method ;

variable this          variable ppv

\s
