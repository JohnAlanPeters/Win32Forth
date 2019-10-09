\ $Id: eStruct.f,v 1.6 2008/06/29 05:12:40 camilleforth Exp $

cr .( Loading estruc.f : structures...)

\ November 9th, 2000 - added CELL and  B/FLOAT
\ January 28th, 2001 - by Ezra Boyce to allow static and dynamic structures.
\ August   7th, 2002 - Extensively modified  to allow true nesting of structures
\                      and structure specific data fetch and store words i.e get, put.
\ August  13th, 2003 - improved documentation of code.
\                      Added char(), word() and int() vector arrays
\ May       15, 2004 - rename to eStruct.f to avoid conflicts.
\ June      18, 2004 - rename vocabulary to avoid conflicts


\ only forth also definitions

anew -estruct.f

vocabulary struct-voc \ avoids conflicts. eg word

\ forth definitions

code @+ ( n adr - adr@+n )
     mov     ebx, 0 [ebx] [edi] \ @
     pop     eax                \ +
     add     ebx, eax
     next    c;

create struct-msg 64 allot
true value .struct-msg?
also struct-voc definitions


1 value struct-id
0 value member-id
false value def-struct \ true if already defining a structure
false value sub-id    \ identifies a sub structure
0 value member-list
0 value member-size
false value with?
0 value withaddr
0 value sub-memberlist  \ pointer to linked list for sub structures


: zeroID        ( -- )   \ reset structure mechanism
                0 to member-id
                0 to member-size
                0 to sub-memberlist
                with? ?exit
                0 to member-list
                false to sub-id ;

: ?abort        { f addr cnt -- }  \ catch errors
                f
                if      addr cnt struct-msg place
                        .struct-msg?
                        if      cr struct-msg count type
                        then    zeroid
                        1 throw
                then    ;

: link-member   ( link addr cnt member -- link+ addr cnt )
                3 roll ! here 0 , -rot ;

\ search linked list beginning at addr for member, f =true if found
: verify-member { member \ addr -- f }
                0       \ default flag
                sub-memberlist     \ priority to sub-instances
                if      sub-memberlist
                else    member-list
                then    dup to addr 0= ?exit
                begin   addr @ ?dup
                while   member = or dup ?exit
                        addr @ 4 cells+ to addr
                repeat  ;

: resolve-member { member-addr -- offset }
                 \ no structure specified or expecting member function e.g get, put
                 member-id 0 <= with? 0= and s" Improper use of member!" ?abort
                 member-addr verify-member 0= s" Function not a member of specified structure!" ?abort
                 member-addr 2 cells+ @ to member-id
                 member-addr cell+ @ to member-size
                 \ if sub-instance not specified get main address
                 \ if specified, address will already be on stack
                 with? sub-memberlist 0= and
                 if      withaddr
                 then   ( struct | addr ) sub-id 0=
                 if  @ dup 0= s" Structure not initialized!" ?abort
                 then  member-addr @+ ;

: resolve-instance { me \ myID link-pointer -- addr }
                me cell+ @ 2 cells+ to link-pointer  \ set pointer to children
                me 3 cells+ @ to myID                \ get structure id
                me 2 cells+ @                        \ non-zero if main instance
                if      \ abort if we are already doing multiple operations on a structure
                        with? s" Use END-WITH first to use another structure!" ?abort
                        \ member operation expected e.g get, put - so abort
                        member-id 0<> s" Invalid use of structure instance!" ?abort
                        \ structure ids will always be greater than zero
                        myID ( struct-id ) to member-id
                        \ set member-list to point to children
                        link-pointer to member-list
                        \ put address of structure on stack for further operations
                        me  ( -- addr-of-structure )
                else    \ instance is a member of a structure
                        \ parent structure not specified or member operation expected
                        \ therefore abort
                        member-id 0 <= with? 0= and
                        s" Improper use of structure instance!" ?abort
                        \ make sure instance is a child of specified parent
                        me verify-member 0=
                        s" Not a member of specified structure!" ?abort
                        with?
                        if      sub-memberlist 0=   \ if sub-structure not specified
                                if      withaddr  \ get main address
                                then    \ search me instead for children
                                link-pointer to sub-memberlist
                        else    link-pointer to member-list
                        then    ( struct | addr -- ) sub-id 0=
                        \ if no sub-instance specified ensure parent was initialized
                        if      @ dup 0= s" Parent structure not initialized!" ?Abort
                        then    me @+   ( -- offset-address )
                        true to sub-id
                then    ;

\ Cells are not necessary for the following but...
\ Structure of member function
\ 0       offset address in structure
\ 4       size of member
\ 8       member id      - always less than zero
\ 12      structure id
\ 16      pointer to other member or zero = end of list

: define-member ( id size -- )
                create , ,
                does>   { \ linkaddr mysize -- }
                >r create ( link addr cnt <size?> - link+ addr cnt+size-of-member )
                here to linkaddr
                r@ @ ( size ) dup
                case    \ array and string members have size on stack
                        0       of drop dup       to mysize  endof  \ array, string, stringz
                        \ char() size is same as number of elements
                       -1       of drop dup       to mysize  endof  \ char()
                        \ word() size is twice number of elements
                       -2       of drop dup 2*    to mysize  endof  \ word()
                        \ int() size is 4 * number of elements
                       -3       of drop dup cells to mysize  endof  \ int()
                        \ all others as is
                                   dup to mysize
                endcase over , ( offset ) , ( size )
                r> cell+ @ , ( member-id ) struct-id ,
                \ update count on stack and link
                mysize + linkaddr link-member
\in-system-ok       does> { myself -- member-addr }
                    myself resolve-member ;

\  ID SIZE
  -1   1       define-member byte
  -2   2       define-member word
  -3   4       define-member dword
  -4   0       define-member array
  -5   b/float define-member float
  -6   0       define-member string
  -7   8       define-member double
  -8   0       define-member stringz
 -10  -1       define-member char()  \ character vector
 -11  -2       define-member word()  \ word vector
 -12  -3       define-member int()   \ integer ( cell ) vector

\ ' byte  alias  char              \ made colon definitions - [cdo-2008May13]
\ ' dword alias  int
\ ' word  alias  short
\ ' dword alias  long  \ 4
\ ' dword alias  langid
\ ' dword alias  lpvoid
\ ' dword alias  lpstr
\ ' dword alias  lpfunc  \ pointer to function e.g callback
\ ' double alias dint
\ ' noop alias unsigned  \ 0 can be ignored when allocating
  -1   1       define-member char	   \ synonym of byte
  -3   4       define-member int           \ synonym of dword
  -2   2       define-member short         \ synonym of word
  -3   4       define-member long          \ synonym of dword  \ 4
  -3   4       define-member langid        \ synonym of dword
  -3   4       define-member lpvoid        \ synonym of dword
  -3   4       define-member lpstr         \ synonym of dword
  -3   4       define-member lpfunc        \ synonym of dword  \ pointer to function e.g callback
  -7   8       define-member dint          \ synonym of double
: unsigned      \ synonym of noop   \ 0 can be ignored when allocating
                noop ;

also forth definitions
\ structure of parent structure class
\ offset          id
\ 0               total size of structure members
\ 4               structure id     - greater than zero
\ 8               link to children structures
\ ******************************************************************************
\ structure of struct instance
\
\ 0               offset in parent structure | memory address for structure
\ 4               pointer to parent
\ 8               marker  0 = substructure instance, -1 = main instance
\ 12              structure id     -  greater than zero


warning off
: :struct   ( <name> -- addr n )
   [ warning on ]
   \in-system-ok also struct-voc
   def-struct abort" :STRUCT missing an ;STRUCT'"
   true to def-struct
   align
   create       \ structure name
   here 0 ,     \ total size of structure will be stored here
   0            \ running count
   struct-id ,
   here 0 , -rot        \ beginning link pointer
   nostack1     \ do not stack check
   does>  { myself \ linkaddr -- }
          create        \ create instance
          here to linkaddr
          def-struct    \ are we defining a structure?
          if    ( link addr cnt -- )
                dup ,                   \ offset in main structure
                myself ,                \ pointer to parent
                0 ,                     \ marker, indicates substructure
                struct-id ,             \ should have id of current structure
                myself @+  ( addr cnt+sizeof-structure )
                linkaddr link-member
          else  0 ,                     \ address of structure memory
                myself ,                \ pointer to parent class
                -1 ,                    \ marker, indicates main structure
                myself cell+ @ ,        \ struct-id
          then
\in-system-ok   does> { myaddr -- }
                def-struct abort" Can't use instance in structure definition!"
                myaddr resolve-instance ;

: ;struct      ( link addr cnt -- )
   def-struct 0= abort" ;STRUCT missing a :STRUCT!"
   \in-system-ok previous
   swap ! drop align
   1 +to struct-id
   false to def-struct ;

: make-dynamic       { structure -- }   \ create a dynamic structure
         structure @ ?exit              \ non-zero means already allocated
         structure cell+ @ @ dup>r      \ sizeof structure + count cell
         malloc                         \ create structure
         dup r> erase                   \ initialize
         structure !
         zeroID ;

: make-static        { structure -- }
         structure @ ?exit              \ non-zero means already allocated
         structure cell+ @ @ >r       \ sizeof structure
         here dup structure ! r@ erase r> allot    \ create & initialize structure
         zeroID ;


: free-struct   { structure -- }
                structure @ 0= ?exit    \ not initialized
                app-origin here structure @ between ?exit  \ static structure
                structure @ release
                0 structure ! zeroID ;

: sizeof()      ( struct -- addr size-of-structure )
                dup @ swap cell+ @ @ over 0=
                s" Structure not initialized!" ?abort
                zeroID ;

: size>         ( <name> -- n )
                ' >body cell+ @ @
                state @
\in-system-ok   if      POSTPONE Literal
                then    ; immediate

: addrof>       ( <name> -- addr )
                ' >body  @
                state @
\in-system-ok   if      POSTPONE Literal
                then    ; immediate

: }with         ( addr -- ) \ allow multiple member access on a structure
                member-id 0 <= s" Multiple operations on structures only!" ?abort
                to withaddr
                true to with?
                zeroID ;

: with{         ( -- )
                noop ;

: end-with      ( -- )
                false to with?
                zeroID ;

: get           ( addr -- data | struc )
                member-id 0 >= s" Needs member function!" ?abort
                member-id
                case
                        -1      of      c@      endof  \ char
                        -2      of      w@      endof  \ word
                        -3      of       @      endof  \ int
                        -4      of      noop    endof  \ array
                        -5      of      f@      endof  \ float
                        -6      of      count   endof  \ string
                        -7      of      2@      endof  \ dint
                        -8      of      noop    endof  \ stringz
\ syntax for vector arrays = ( struc index -- value )
                        \ char()
                       -10      of      ( index ) dup 0 member-size within
                                        if      + c@
                                        else    s" Get-Index out of bounds in char()!" ?abort
                                        then    endof
                        \ word()
                       -11      of      ( index ) dup 0 member-size within
                                        if      2* + w@
                                        else    s" Get-Index out of bounds in word()!" ?abort
                                        then    endof
                        \ int()
                       -12      of      ( index ) dup 0 member-size within
                                        if      cells + @
                                        else    s" Get-Index out of bounds in int()!" ?abort
                                        then    endof
                        true s" Invalid member function!" ?abort
                endcase zeroID ;

\ ' get alias s@                 \ made a colon def - [cdo-2008May13]
: s@            \ synonym of get
                get ;

\ : @   ( addr -- n )   \ @ can be redefined if desired
\       member-id 0=
\       if      @
\       else    get
\       then    ;

: &get          ( addr -- addr ) \ allow accessing structure or member directly
                member-id 0>
                if      @ dup 0= s" Structure not initialised!" ?abort
                then    zeroID ;

: %get		( addr -- addr ) \ pointer to structure, allow setting structure memory block
		member-id 0> not abort" Structures only!" ;

: put           ( n1 n2 addr -- )     ( f:   n -- )
                member-id 0 >= s" Needs member function!" ?abort
                member-id
                case
                        -1      of      c!      endof   \ char
                        -2      of      w!      endof   \ word
                        -3      of       !      endof   \ int
                        -4      of      noop    endof   \ array
                        -5      of      f!      endof   \ float
                        -6      of      -rot member-size 1- min 0max
                                        rot place endof \ string
                        -7      of      2!      endof   \ dint
                        -8      of      dup member-size erase
                                        swap member-size 1- min 0max move
                                                endof   \ stringz
\ syntax for vector arrays = ( value struc index -- )
                        \ char()
                       -10      of      ( index ) dup 0 member-size within
                                        if      + c!
                                        else    s" Put-Index out of bounds in char()!" ?abort
                                        then    endof
                        \ word()
                       -11      of      ( index ) dup 0 member-size within
                                        if      2* + w!
                                        else    s" Put-Index out of bounds in word()!" ?abort
                                        then    endof
                        \ int()
                       -12      of      ( index ) dup 0 member-size within
                                        if      cells + !
                                        else    s" Put-Index out of bounds in int()!" ?abort
                                        then    endof
                                              s" Invalid member function!" ?abort
                endcase zeroID ;

\ ' put alias s!           \ made a colon def - [cdo-2008May13]
: s!           \ synonym of put
               put ;

\ : !   ( n addr -- )   \ ! can be redefined if desired
\       member-id 0=
\       if      !
\       else    put
\       then    ;

: put>  ( data <name> -- ) \ single member access only!
               ' state @
\in-system-ok  if      POSTPONE LITERAL POSTPONE EXECUTE POSTPONE PUT
               else    execute put
               then    ; immediate

: get>  ( <name> -- )  \ single member access only!
               ' state @
\in-system-ok  if      POSTPONE LITERAL POSTPONE EXECUTE POSTPONE GET
               else    execute get
               then    ; immediate

previous previous definitions
\ only forth also  definitions
\s
\ Demo words to test stuctures

cr .( Loading demo structures.....)
struct-voc also

: .struct      { structure -- }
   cr ." Pointer ---> " structure ?
   cr ." Size    ---> " structure cell+ @ ?
   cr ." ID      ---> " structure cell+ @ cell+ ?
   structure @ ?dup
        if      cr structure cell+ @ @ dump
        then    zeroID ;

:struct Date
              int Year
             byte Month
             byte Day
;struct

:struct Person
        33 string FirstName
        33 string LastName
             char MiddleInitial
        33 string Address1
        33 string Address2
        33 string Address3
        21 string TelephoneNumber
             byte Age
             char Sex           \ M,F
             char MaritalStatus \ M,S,W,D
             Date DateOfBirth
;struct

:struct Company
         Person  Employee
           Date  StartOfEmployment
      21 String  Title
      21 String  Department
      21 String  EmailAddress
           char  Valid

;struct
company EBES    \ create instance
: test EBES make-static        \ initialize
with{ EBES employee }with
s" Ezra"                put> firstname
s" Boyce"               put> lastname
s" 1st Avenue Jackson"  put> address1
s" St. Michael"         put> address2
s" Barbados W.I"        put> address3
s" 246-425-4699"        put> telephonenumber
36                      put> age
'M'                     put> sex
1966                    DateofBirth year put
1                       DateofBirth month put
14                      DateofBirth day put
end-with ;
only forth also
\s
:struct tst()
 5  char() achar()
10  word() aword()
15  int()  aint()
;struct

tst() dum()
