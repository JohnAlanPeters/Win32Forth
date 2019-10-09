\ $Id: Class.f,v 1.48 2014/04/16 17:57:05 georgeahubert Exp $

\ CLASS.F       Version 1.1 1994/04/01 07:52:15         by Andrew McKewan
\ -rbs Added ClassRoot for <Super ... so that classes that do not include records
\ do not have to include undefined methods.  Was crashing for methods get:,
\ put: etc. when no record was used.  Now use "<Super ClassRoot" for those
\ classes.
\ class.f 4.9C 2003/01/29 rbs changed class string to inherit class root
\ class.f 5.01A 2003/04/14 arm Changed _msgfind to check that object is really an object

cr .( Loading Class.f : Primitive Object Class...)

REQUIRE CLASS-ERRS.F

true value ?win-error-enabled   \ initially errors are enabled

cell newuser  (NewObject)           \ Newest object being created
: NewObject (NewObject) @ ;

IN-SYSTEM

-4105 constant warn_clash

throw_msgs link, warn_clash , ," has a hash value that is already recognised by this class."

: @word         ( -<word>- addr )
                bl word uppercase ;

: hash>         ( -<word>- hash )       \ rls
                @word count method-hash ;

: [[            ( "code to evaluate< ]]>" -- ) \ W32F          Class   In-System Forth
\ *G \b Interpretation: \d When preceeded by a selector, parses the input stream up to a
\ ** terminating ]] evaluates the code and then executes the method for the object
\ ** address on the stack. An error will occur if "code to evaluate" does not produce
\ ** a valid object address. \n
\ ** An error also occurs if [[ isn't preceeded by a selector.
\ *P \b Compilation: \d When preceeded by a selector, compiles the input stream up to a
\ ** terminating ]] and then compiles a late-bound call to the method selector
\ ** address on the stack. A run-time error will occur if "code to evaluate" does not
\ ** produce a valid object address. \n
\ ** An compile-time error also occurs if [[ isn't preceeded by a selector.
                THROW_NEED_SEL THROW   ; IMMEDIATE

: **            ( -- )
                THROW_NEED_SEL THROW   ; immediate

private classes internal

\ -------------------- Selectors --------------------

: ?isSel        ( str -- str f1 )       \ f1 = true if it's a selector
                dup ':' endchar? ;      \ ends in ':'

: >selector     ( str -- SelID )        \ get a selector from the input stream
                ?isSel 0= THROW_NOT_SEL ?THROW count method-hash ;

: getSelect     ( -- SelID )            \ get a selector from the input stream
                @word >selector ;

\ -------------------- Class Structure --------------------

0 value ^Class          \ pointer to class being defined

\ references are from class pfa

in-previous

voc-pfa-size nostack1
#mlists cells field+ MFA        \ method dictionary
        cell  field+ IFA        \ instance variable dictionary
        cell  field+ DFA        \ data area size in bytes
        cell  field+ XFA        \ width of indexed items
        cell  field+ SFA        \ pointer to superclass
constant class-size    \ size of class pfa

: ClassPointer? ( class -- f )  XFA @ -1 <> ;

:               obj>Class     (    'obj -- 'class  )      CELL- @ ;

in-system

0        offset WFA
2  cells offset >obj          (  objCfa -- 'obj    )
-2 cells offset obj>          (    'obj -- objCfa  )
   cell  offset Class>Obj     ( ^'Class -- 'obj    )
-1 cells offset Class>        ( ^'Class -- objCfa  )
   cell  offset >Class        (  objCfa -- ^'Class )

: class-allot   ( n -- )  ^class DFA +! ;

: Class-align   ( -- ) ^class dfa dup @ aligned swap ! ;

0 value bitcnt
0 value bitmaxval

: >mask         ( n1 -- mask )
                1 swap lshift 1- ;

: class-bitallot ( n -- )
                bitmaxval 0=
                THROW_NO_BITS ?throw
                dup 0=
                THROW_ZERO_BITS ?throw
                bitcnt bitmaxval =
                if      0 to bitcnt
                then
                bitcnt ,                  \ save the bit offset into data item
                dup >mask bitcnt lshift , \ save bit mask of data in item
                dup bitcnt + bitmaxval >
                THROW_BIG_BITS ?throw
                +to bitcnt ;

: bitmax        ( n1 -- )       \ set max bits for any following bit fields
                bitcnt bitmaxval <>
                if      cr ." WARNING: Bit fields weren't completely filled"
                then
                dup to bitcnt
                    to bitmaxval ;

\ -------------------- Find Methods --------------------

\ code ((findm))  ( SelID addr -- 0cfa t OR f )

in-previous

named-new$ tempmsg$

: (FINDM)   ( SelID ^class -- m0cfa )   \ find method in a class
        2dup
        MFA ((findm)) if nip nip EXIT then
        s"  --> " tempmsg$ +place swap unhash tempmsg$ +place  \ replaces nip
        S"  not understood by class " tempmsg$ +place
        turnkeyed? \ Sonntag, März 13 2005 dbu
        if   drop s" [UNKNOWN]" tempmsg$ +place
        else body> >name nfa-count tempmsg$ +place
        then tempmsg$ msg !  -2 throw ;

: FIND-METHOD   ( SelID ^obj -- ^obj m0cfa )   \ find method in object
                -if  tuck obj>Class (findm) EXIT  then drop
                ?win-error-enabled TURNKEYED? 0= AND
                if      false to ?win-error-enabled
\+ forth-io             forth-io
                        cr cr unhash  type ."  NULL"
\IN-SYSTEM-OK           .rstack
                        ABORT
                else    MAXSTRING LocalAlloc >r
                        unhash          r@  place
                        s"   NULL"      r@ +place
                                        r@ +NULL
                        [ MB_ICONSTOP MB_OK or MB_TASKMODAL or ] literal
                        z" Find Method Error!"
                        r> 1+ NULL Call MessageBox drop
                        BYE
                then    ;

: (Defer)       ( ^obj -- )   \ look up SelID at IP and run the method
                @(ip) swap  ( SelID ^obj )
                Find-Method execute ;

IN-SYSTEM

LOADED? debug.f [if] \ debug support

also bug

: dbg-next-cell-class ( ip cfa -- ip' cfa )
                dup ['] (Defer) =
                if      swap cell+ swap
                then    ;

dbg-next-cell chain-add dbg-next-cell-class \ link into the debugger

: dbg-nest-class ( top-of-user-stack cfa flag -- cfa false | true )
                dup ?exit                       \ leave if already found
                over ['] (Defer) =
                if      2drop cr .s
\ !!! USES A COPY OF THE ADDRESS ON TOP OF THE STACK TO LOCATE THE METHOD !!!
                        ip @ cell+ @ over Find-Method nip 3 cells+ ip !
                        2 nesting +!
                        true
                then    ;

dbg-nest-chain chain-add dbg-nest-class

previous

[then]

LOADED? see.f [if] \ decompiler support
: .word-type-class      ( cfa flag -- cfa false | true )
        dup ?exit
        over ['] (Defer) =
        if      2drop
                ." Late: "
                true
        then    ;

.word-type-chain chain-add .word-type-class

: .execution-class-class ( ip cfa flag -- ip' cfa flag )
                dup ?EXIT                       \ leave if non-zero flag
                over ['] (Defer) =              \ is it a late bound method
                if      drop                    \ discard original flag
                        ." [ " swap cell+
                        dup @ unhash type
                        cell+ swap ."  ] "
                        true                    \ return true if we handled it
                then    ;

.execution-class-chain chain-add .execution-class-class
[then]

in-previous

   0 Value  ^Self
   0 Value  ^Super              \ nfa of SUPER pseudo-Ivar

in-system


: [self]        ( -- )
                THROW_NOT_SELF throw ; immediate

: ?isObj        ( cfa -- f )
                @ doObj = ;
: ?isValue      ( cfa -- f )
                @ doValue = ;
: ?isLocal      ( cfa -- f )
                @ doLocal = ;
: ?isVect       ( cfa -- f )
                @ dup doValue =
                over doDefer = or
                swap (iv@)   = or ;

: ?isParen      ( cfa -- f )
\                >name nfa-count drop c@ [char] [ = ;
                dup ['] [ = swap ['] [[ = or ;

: ?is**         ( cfa -- f )
                ['] ** = ;

: ?is[self]     ( cfa -- f )
                ['] [self] = ;

\ ERROR if not compiling a new class definition
: ?Class        ( -- )
                ^class   0= THROW_NOT_IN_CLASS ?throw ;

: (vfind)       ( str hash ^class -- str f | ^iclass t  )
                 IFA ((findv)) -if  rot drop  then ;

\ Determine if next word is an instance var.
\ Return pointer to class field in ivar structure.
: VFIND         ( str -- str f OR ^iclass t )
                ^class
                IF      dup count method-hash ^class (vfind)
                ELSE    0
                THEN ;

: classVFIND    ( str ^class -- str f OR ^iclass t )
                >r dup count method-hash r> (vfind)  ;

: IDX-HDR       ( #elems ^class OR ^class -- indlen )
                XFA @ dup 0>    \ if XFA holds -1 then its a non-classpointer class
                                \ if XFA holds 0> then its the indexed data width
                if      2dup ( width ) w, ( #elems ) w, *
                then    0max ;

( ** special handling for XFA=-1 ** )

\ -------------------- Initialize Instance Variables --------------------
((
Instance variable consists of five 4-byte fields.  A sixth field is
used for indexed ivars only.

    Offset   Name      Description
    ------   ----      ---------------------------------------
       0 0   link      points to link of next ivar in chain
       4 1   name      32-bit hash value of name
       8 2   class     pointer to class pfa
      12 3
      16 4   offset    offset in object to start of ivar data
      20 5   #elem     number of elemens (indexed ivars only)

In the stack diagrams, "ivar" refers to the starting address of this
structure.  The IFA field of a class points to the first ivar.
))

in-previous

2 cells offset iclass     ( ivar -- 'class )

: @IvarOffs  ( ivar -- offset )   3 cells+ @ ;

: @IvarCPtr  ( ivar -- flag )     4 cells+ @ ;

: @IvarElems ( ivar -- #elems )   5 cells+ @ ;

\ send ClassInit: message to ivar on stack
: InitIvar  ( ivar offset -- )
                over @IvarOffs + newObject +            ( ivar addr )
                [ getSelect ClassInit: ] literal
                rot iclass @ (findm) execute ;

\ ITRAV traverses the tree of nested ivar definitions in a class,
\ building necessary indexed area headers.
: ITRAV   { ivar offset -- }
        Begin
                ivar ^Self <>
        While
                ivar iclass @ IFA @
                ivar @IVarOffs offset + RECURSE

                ivar iclass @ ?dup      ( Why would an Ivar have no class ?? )
                if      dup ClassPointer?       \ is this a classpointer class
                        ivar @IvarCPtr 0= and   \ and not contiguous data flag
                        if      newObject offset + ivar @IvarOffs +
                                                                ( ^class ivarAddr )
                                2dup cell- !                    \ store class pointer
                                over XFA @
                                if over DFA @ +                 \ addr of indexed area
                                        swap XFA @ over W!      \ Index width
                                        ivar @IvarElems swap 2 + w! \ #elems
                                else 2drop
                                then
                        else    drop
                        then
                        ivar offset initIvar                    \ send ClassInit:
                then
                ivar @ to ivar                                  \ next ivar in chain
        Repeat ;


defer ClassInit  ( -- ) \ send ClassInit: to newObject
' NOOP is ClassInit

in-system

0 value contiguous-data?

defer ivar-name
' noop is ivar-name

\ Compile an instance variable dictionary entry
: <VAR          ( #elems ^class OR ^class -- )
                dup XFA @ >r dup>r              \ save XFA contents and class ptr
                >in @
                @word Vfind THROW_IVAR_EXISTS ?throw
                swap >in !
                contiguous-data?                \ if contiguous flag non zero
                if      -1 r@ XFA !             \ set XFA to -1
                then

                dup count 2dup method-hash add-hash

                ^Class IFA link,                \ link
                count method-hash ,             \ name hash
                dup ,                           \ class
                dup ClassPointer?               \ is this a classpointer class
                if      4 class-allot           \ then indexed, save 4 for class ptr
                then
                ^class DFA @ ,                  \ offset
                contiguous-data? ,              \ contiguous data flag
                dup XFA @ dup 0>                ( ** special handling for XFA=-1 ** )
                if      rot dup , * 4 +
                then    0max                    \ #elems
                ivar-name
                swap DFA @ +                    \ Account for named ivar lengths
                class-allot
                r> r> swap XFA ! ;              \ restore XFA contents

: <Building>    ( #elems ^class OR ^class -- )
                dup ,                   \ class
                here (newObject) !
                dup DFA @ reserve       \ allot space for ivars
                dup>r IDX-HDR reserve   \ allot space for indexed data
                r> IFA @ 0 ITRAV        \ init instance variables
                ClassInit ;             \ send CLASSINIT: message

: (Building)    ( #elems ^class OR ^class -- )
                doObj ,  <Building> ;               \ cfa

: (|Build)      ( #elems ^class OR ^class -- )  \ Build an instance of a class
                ^class
                IF      <Var                    \ build an ivar
                ELSE    (Building)
                THEN ;

: (Build)       ( #elems ^class OR ^class -- )  \ Build an instance of a class
                ^class
                IF      <Var                    \ build an ivar
                ELSE    header
                        (Building)
                THEN ;

MAXSTRING Buffer: obj-buf

: (Obj-Build)   ( #elems ^class OR ^class -- )  \ Build an instance of a class
                obj-buf count "header (Building) ;


\ -------------------- Heap Objects --------------------

\ build a new object on the heap for class. Use: New> className
\ gets heap, and returns ptr.

in-previous

\           ( <number_of_elements> theClass -- )
: (heapObj) { theClass \ dLen obAddr idWid #els -- addr }
        0 to #els
        theClass DFA @ to dLen
        theClass XFA @ dup 1+ 0= - to idWid
        idWid
        IF      to #els                 \ save the optional number of elements
                                        \ from stack, if it's an array of objects
        THEN
        dLen ( cell+ )
        idWid
        IF      idWid #els * ( cell+ ) +    \ get total length of obj
        THEN
        malloc
        theClass over cell- !                 \ create the class ptr
        ( cell+ ) to obAddr                 \ get nonReloc heap, save ptr to cfa
        idWid
        IF      obAddr dLen + idWid over w! 2 + #els swap w!
        THEN
        obAddr (newObject) !
        theClass IFA @ 0 Itrav classinit obAddr ;

in-system

external

\ The following definition is executed at compile time so as long as its run-time (heapobj) is
\ in application space it can go in system space

: New>          ( -<class>- -- addr )     \ W32F                 Class
\ *G Allocate memory for an object of -<class>- on the heap, initialise the object
\ ** and return the object address.
                '  dup ?isClass not THROW_NEW> ?throw
                >body
                STATE @
                IF      POSTPONE literal
                        POSTPONE (heapObj)
                ELSE    (heapObj)
                THEN    ; IMMEDIATE

\ See " Dispose " later for releasing dynamic objects

internal

cfa-code        DoUserObj
                push  ebx
                mov   ecx, 4 [eax]
                add   ecx, edx           \ ecx is now address of pointer in user area.
                mov   ebx, 0 [ecx]
                cmp   ebx, # 0
                jne   short @@3
                mov   ebx, useroffs negate [edx]
                and   ebx, # Main-Task
                test  ebx, # Main-Task
                je    short  @@1
                lea   ebx, 12 [eax]
                jmp   short @@2
           @@1: mov   ebx, 8 [eax]
                push  ecx
                fcall (heapObj)
                pop   ecx
                mov   eax, UserObjectList [UP]
                mov   -4 [ecx], eax
                lea   eax, -4 [ecx]
                mov   UserObjectList [UP] , eax
           @@2: mov   0 [ecx], ebx
           @@3: next
                ;c

: ?isUserObj        ( cfa -- f )
                @ doUserObj = ;

get-current also hidden definitions

: .USEROBJECT:         ( cfa -- )
                ." USEROBJECT: " dup 2 cells+ @ body> .name .name ;

: _.USEROBJECT:        ( cfa -- cfa|0 )
                 -if dup ?isUserObj if .USEROBJECT: 0 then then ;

\in-system-ok .other-class-chain chain-add _.USEROBJECT:

previous set-current

external

: UserObject:    ( Define: "class" "name" -- Child: -- addr )
\ *G Create a new user variable that is a pointer to either the object following object ( for the main task only )
\ ** or to a dynamic object on the heap ( for other tasks ). The dynamic object is only created the first time it's
\ ** referenced. The pointer is set for the main task at compile time or the first usage for a saved program.
              ' dup ?isClass not THROW_NOT_CLASS ?throw >body  Header DoUserObj compile,
              NEXT-USER @ dup 2 cells+ NEXT-USER ! cell+ ( dup ) ,
              ( here cell+ swap ! ) <building> ;

internal

\ --------------- Build SUPER and SELF pseudo ivars ---------------

S" SUPER" hash> SUPER add-hash

Here to ^Super
        0 ,             \ link
        hash> SUPER ,   \ name
        0 ,             \ class
        0 ,             \ offset (was -1)
        0 ,             \ contiguous flag

S" SELF" hash> SELF add-hash

Here to ^Self
        ^Super ,        \ link
        hash> SELF ,    \ name
        0 ,             \ class
        0 ,             \ offset (was -1)
        0 ,             \ contiguous flag

^Self   ' classes >Class IFA !      \ latest ivar


\ -------------------- Create a new Class --------------------

0 value oldcurrent

external

0 value Obj-CLASS

internal

\ Build a class header with its superclass pointer
: inherit       ( pfa -- )
                here 2dup class-size dup allot move  \ copy class data
                body> vcfa>voc voc>vlink
                voc-link @ over !
                voc-link !

                dup ^Class SFA !                \ store pointer to superclass
                ^Super iclass !                 \ store superclass in SUPER
                ^Class ^Self iclass !           \ store my class in SELF
                                                \ add to search order
                ^Class XFA dup @ 0max swap !    \ inherit indexing
                also ^class WFA body> vcfa>voc context ! definitions
                obj-class 0= if reveal then ;

external

       0 value Obj-LOADLINE


: :Object       ( -<object-name>- )
\ *G Create an object with a nameless class,
\ ** useful for creating unique objects that are not similar to other objects,
\ ** and where there will only ever be one object of this nameless class.
\ ** Additional objects or classes can be created with an object as their
\ ** superclass.
                bl word count "CLIP" obj-buf place
                current @ to oldcurrent         \ save context for later restoral
                false to ?:M
                doClass ,                       \ dummy filler to fool the system
                                                \ into thinking this is a definition
                here to Obj-CLASS
                here to ^Class
                0 op!                           \ for error checking in runIvarRef
                loading?
                if      loadline @
                else    -1
                then    to Obj-LOADLINE ;

: (class)       ( -- )
                        hide
                        0    to Obj-CLASS
                        here to ^Class
                        0 op! ;                 \ for error checking in runIvarRef

: Build:Class   ( -- )
                does>
                        [ code-here 12 - to doClass ] \ a dirty trick!
                        (Build) ;


: :Class        ( -<class-name>- )
\ *G Define a class for creating a group of similar objects.
                current @ to oldcurrent         \ save context for later restoral
                false to ?:M
                create
                        (class)
                sys-warning? sys-warning-off Build:Class to sys-warning? ;

: <Super        ( -- )        \ W32F     Class
\ *G Allow inheriting from a class or an object
\ *E Specify the superclass of the class or object being created. Used as follows;
\ **       :Class  <newclassname> <Super <superclassname>
\ **       ;Class
\ **
\ **        - or -
\ **
\ **       :Object <newobjectname> <Super <superclassname>
\ **       :Object
                ' dup  ?isClass
                if      >Class inherit
                else    dup ?isObj 0= THROW_NOT_CLASS_OR_OBJ ?throw
                        >Class @ inherit
                then    ;


: Clone         ( CfaOfObject  'newobject' -- ) \ clone a static object
\ Create an identical copy (clone) of an existing object
\ Use the following syntax:  ' ExistingObject Clone NameOfNewObject
                dup @ doobj =                   \ must be cfa of object
                0= THROW_NO_CLONE ?throw
                >body @ (build) ;               \ build the object

\ Obsolete way to create a clone of an existing object;
\       Clone: anObject NewObject
\ : Clone:        ( 'object' 'newobject' -- )
\                 ' Clone ;

: Build|Class   ( -- )
                does>
                        [ code-here 12 - to do|Class ] \ a dirty trick!
                        (|Build) ;

: |Class        ( -- )
\ *G Defines a class that creates headerless objects.
\ ** |Class objects should be linked in the ClassInit: method
\ ** Used primarily for defining menus, where the names of objects are not needed,
\ ** and where the objects are only accessed through a linked list, built using
\ ** the ClassInit: method.
                current @ to oldcurrent         \ save context for later restoral
                false to ?:M
                create
                        (class)
                sys-warning? sys-warning-off Build|Class to sys-warning? ;

internal

variable new-method

module

classes definitions

internal

: (;ClObj)      ( -- )
                new-method off
                0 ^Super iclass !
                0 ^Self  iclass !
                0 to ^Class
                forth definitions previous
                oldcurrent ?dup
                if      current !
                        0 to oldcurrent
                then    ;

external

: ;Class        ( -- )
                Obj-CLASS THROW_NOT_CLASS ?throw
                (;ClObj) ;

: ;Object       ( -- )
                Obj-CLASS 0= THROW_NOT_OBJ ?throw
                (;ClObj)
                Obj-CLASS (Obj-Build)
                Obj-LOADLINE last @ name> >view ! ;

\ -------------------- Method Compiler --------------------

: method        ( SelID -- )   \ Build a methods dictionary entry for selector
                ?Class ?Exec
                dup pocket count rot new-method on add-hash
                ^Class MFA over [ #mlists 1- cells ] literal and +
                link,        \ link
                ,                       \ name is selector's hashed value
                m0cfa ,                 \ build methods cfas
                m1cfa ,
                0 ,                     \ #locals & #args
                !csp ] ;                \ start compiler

: _clash        ( hash-val -- )
                new-method @ warning @ and ^Class and if
                  ^Class mfa ((findm)) if
                    drop warn_clash warnmsg then
                  else drop
                then new-method off ;

' _clash is clash

\ For Windows messages, we would like the selector to be a constant
\ defined as the Window message number.  :M will support both types of
\ selectors.

2024 constant unres-len

create unres-methods unres-len allot
       unres-methods unres-len erase

\ :M creates a method for the current Class or Object being defined.
\ Method names always end in a ':' (colon), or in the case of Windows messages,
\ are Windows constants like WM_PAINT.
: :M            ( -- )
                unres-methods unres-len erase   \ pre-clear unresolved methods array
                @word IsWinConstant 0=          \ a windows constant
                if      dup find                        \ if its defined
                        if      dup @ doCon =           \ and a constant
                                if      nip execute     \ then use its value
                                else    drop >selector  \ else get selector
                                then
                        else    drop >selector          \ or a selector
                        then
                then    method
                ['] unnestm to ?:M     ; immediate     \ mark as making a new method

: ;M            ( -- )
                ?:M 0= THROW_NOT_METHOD ?throw
                false to ?:M
                ?csp
                postpone unnestm
                postpone [
                0 to Parms
                semicolon-chain do-chain
                voc-also                        \ don't add to hash table
                ; IMMEDIATE

: resolve-methods ( -- )
                unres-methods
                begin   count dup
                while   2dup
                        2dup method-hash add-hash
                        +
                repeat  2drop
                unres-methods unres-len erase ;

\ -------------------- Object Compiler --------------------

\ Key to instantiation actions
\ 0 = notFnd            -not previously defined (not used)
\ 1 = objTyp            -defined as an object
\ 2 = classTyp          -as a class
\ 3 = vecTyp            -as an object vector (value or defer)
\ 4 = parmTyp           -as a named parm
\ 5 = parenType         -open paren for defer group
\ 6 = defer             -late bound call to object address on stack
\ 7 = [self]            -as a late bound call to self

\ in-application

: refToken      ( str -- cfa tokenID )  \ Determine type of token referenced
                                        \ by str.
                parmfind ?missing
                dup ?IsObj     if  1 exit  then
                dup ?IsClass   if  2 exit  then
                dup ?IsLocal   if  4 exit  then
                dup ?IsParen   if  5 exit  then   \ needs to preceed next line,
                dup ?IsVect    if  3 exit  then   \ because [ is a deferred word
                dup ?Is**      if  6 exit  then
                dup ?Is[self]  if  7 exit  then
                dup ?isUserObj if  8 exit  then
                1 THROW_INVALID_OBJ_REF ?throw ;

\ -------------------- Late Binding --------------------

\ Force late binding of method to object, as in SmallTalk
\ compiles a defer: selID.  This will build a deferred reference to the
\ parenthesized group.

: LateBound     ( SelId -- ) \ Compile or execute a deferred message send
                >R
                [CHAR] ] PARSE  EVALUATE
                source >in @ /string drop c@ ']' =      \ skip extra ']'
                IF      1 >in +!
                THEN
                State @
                IF      POSTPONE (Defer)  R> ,
                ELSE    R> swap Find-Method execute
                THEN    ;

create met_hstring name-max-chars 2 + allot
create obj_hstring name-max-chars 2 + allot

0 value &(IVB@)

: VarFind       { Class -- CfaObj } ( argument is a class )
                obj_hstring count       \ -- a1,n1
                Class body> vcfa>voc search-wordlist
                0=  THROW_NO_FIND_VAR ?throw
                dup  @  (IV@)  =
                over @ &(IVB@) = or
                over @  (IVC@) = or
                over @  (IVW@) = or
                over @  (IVD@) = or
                over @  (&IV)  = or
                0= THROW_INVALID_IVAR ?throw
                ;

: NestedObject { Obj \ rem$ -- class 'Obj } ( returns obj AND class, rewritten )
                MAXSTRING LocalAlloc: rem$
                Obj obj>class ( class )
                begin obj_hstring count 2dup '.' scan ?dup
                while 2dup 1 /string                    \ remove decimal point
                        name-max-chars min              \ clip to legal max
                        rem$ place                      \ lay remainder into temp buf
                        nip - name-max-chars min        \ calc & clip to legal max
                        obj_hstring c!                  \ lay down object name
                                                        ( class obj_hstring+1 )
                        1- swap classVFIND 0= THROW_NO_FIND_OBJ ?throw
                        2@ swap +to obj
                        rem$ count obj_hstring place    \ recover remainder of string
                repeat                    ( class obj_hstring+1 count obj_hstring+1 )
                2drop 1- over classVFIND            ( class str f | class ^iclass t )
                if      nip 2@ swap +to Obj             \ accumulate object
                        obj_hstring off                 \ no remaining string
                else drop
                then Obj ;                              \ then return the object

: NestedIVar { Class offset \ rem$ -- 'Class 'offset }
( argument is class and class is returned, word is rewritten )
                MAXSTRING LocalAlloc: rem$
                begin   obj_hstring count 2dup '.' scan ?dup
                while   2dup 1 /string                  \ remove decimal point?
                        name-max-chars min              \ clip to legal max
                        rem$ place                      \ lay remainder into temp buf
                        nip - name-max-chars min        \ calc & clip to legal max
                        obj_hstring c!                  \ lay down object name
                        1- Class classVFIND 0= THROW_NO_FIND_OBJ ?throw
                        2@ to Class +to offset
                        rem$ count obj_hstring place    \ recover remainder of string
                repeat
                2drop 1- Class classVFIND
                if      2@ to Class +to offset
                        obj_hstring off                 \ no remaining string
                else    drop
                then    class offset ;                  \ then return the object

: Obj.Var,      { selID ObjCfa \ Obj Class -- }
                ObjCfa >obj NestedObject to Obj to Class obj_hstring c@
                if      Class VarFind POSTPONE LITERAL
                then
                Obj POSTPONE LITERAL
                selID Class (findm) compile, ;

: UserObj.Var,      { selID ObjCfa \ Obj Class -- }
                ObjCfa 3 cells+ dup NestedObject to Obj to Class obj_hstring c@
                if      Class VarFind POSTPONE LITERAL
                then
                ObjCfa compile, Obj swap - ?dup if POSTPONE LITERAL postpone + then
                selID Class (findm) compile, ;

0 value varCfa

: RunObj.Var    { selID ObjCfa \ Obj Class -- ^obj m0cfa }
                ObjCfa >obj NestedObject to Obj to Class obj_hstring c@
                if      Class VarFind to varCfa
                else    0 to varCfa
                then Obj selID Class (findm) ;

: ivarRef       { selID ^iclass \ Class offset -- } \ compile ivar reference
                ^iclass 2@ swap NestedIVar to offset to Class obj_hstring c@
                if      Class VarFind POSTPONE LITERAL
                then
                selID Class (findm) cell+ ( m1cfa ) COMPILE, offset , ;

: runIvarRef { selID ^iclass \ Obj Class -- } \ run ivar reference (DEBUG ONLY!!)
                ^base 0= THROW_OBJ_EXPOSED ?throw
                ^iclass dup @ to Class Class>Obj to Obj
                obj_hstring count '.' scan nip
                if      Obj NestedObject to Obj to Class
                then
                obj_hstring c@
                if      Class VarFind
                then selID Obj Find-Method
                swap @ ( offset ) ^base + swap execute ;

: getIvarRef    { selID ^iclass -- ^obj m0cfa }
                ^base 0= THROW_OBJ_EXPOSED ?throw
                selID ^iclass Class>Obj Find-Method
                swap @ ( offset ) ^base + swap ;

: objRef        ( selID $str -- )  \ Build a reference to an object or vector
                Case refToken
                  0 ( ?           ) of  abort                                  endof
                  1 ( object      ) of  Obj.Var,                               endof
                  2 ( class       ) of  >Class (findm) ,                       endof
                  3 ( vector      ) of  compile,  POSTPONE (defer) ,           endof
                  4 ( parm        ) of  compile,  POSTPONE (defer) ,           endof
                  5 ( paren       ) of  drop LateBound                         endof
                  6 ( **          ) of  drop postpone (defer) ,                endof
                  7 ( [self]      ) of  drop postpone ^base postpone (defer) , endof
                  8 ( User Object ) of  UserObj.Var,                           endof
                Endcase ;

: getRef        ( selPfa $str -- ^obj m0cfa )
                0 to varCfa
                Case refToken
                  0 ( ?           ) of  abort                                  endof
                  1 ( object      ) of  RunObj.Var                             endof
                  2 ( class       ) of  >Class (findm)                         endof
                  3 ( vector      ) of  execute Find-Method                    endof
                  4 ( parm        ) of  abort                                  endof
                  5 ( paren       ) of  drop LateBound ['] noop                endof
                  6 ( **          ) of  drop swap Find-Method                  endof
                  7 ( [self]      ) of  abort                                  endof
                  8 ( User Object ) of  dup execute -rot 2 cells+ @ (findm)    endof
                Endcase ;

: runRef        ( selPfa $str -- )  \ Execute using token in stream
                getRef
                varCfa ?dup
                if      -rot
                then    execute ( executes m0cfa ) ;

\ ================= Selector support ==========================

0 value get-reference?

: _do_message   ( val string -- )               \ normal stack format
                ( val string -- ^obj m0cfa )    \ if 'get-reference?' is ON
                \ this second stack picture provided for debugger/decompiler
        STATE @
        IF      false to get-reference?         \ ignore get reference flag
                VFIND           \ instance variable?
                IF    ivarRef   \ ivar reference
                ELSE   objRef   \ compile object/vector reference
                THEN
        ELSE    get-reference?
                IF      false to get-reference? \ just this once
                        VFIND
                        IF      getIvarRef
                        ELSE    getRef
                        THEN
                ELSE    VFIND
                        IF      runIvarRef      ( Debug only )
                        ELSE    runRef  \ run state - execute object/vector ref
                        THEN
                THEN
        THEN    ;

: WM:           ( WM_MESSAGE -<object>- )       \  WM_CLOSE WM: Super
                here 2 cells - @ ['] LIT <>
                THROW_NO_WM ?throw
                here cell - @                   \ get the literal
                -2 cells allot                  \ release the space
                obj_hstring off
                @word _do_message ; immediate

create x.buf name-max-chars 1+ allot
       x.buf off

-1 value method_hval

: (do_message)  ( addr -- )
                count 2dup '.' scan             \ find decimal point?
                2dup 1 /string                  \ strip it off
                name-max-chars min              \ clip to legal max
                obj_hstring place               \ lay remainder into var buf
                nip - name-max-chars min        \ calc & clip to legal max
                met_hstring place               \ lay down object name
                method_hval met_hstring _do_message ;


: x.do_message  ( -- ) \ Not normally used directly
                x.buf (do_message) ; IMMEDIATE

\ message is the message compiler invoked by using a selector
: do_message    ( -- )
                @word (do_message) ; IMMEDIATE

: _msgFind      { addr \ temp$ -- addr false | cfa true }
                addr ?isSel
                if      count name-max-chars min
                        2dup tempmsg$ place     \ in case there is an error
                        2dup hash-wid Search-Wordlist
                        if      execute nip nip
                        else    2dup method-hash >r unres-methods
                                begin   dup c@
                                while   count +
                                repeat  2dup + 1+            \ end of string
                                unres-methods unres-len + >  \ beyond end?
                                THROW_METH_BUFF_OVERFLOW ?throw
                                place
                                r>
                        then    to method_hval ['] do_message
                        1 EXIT
                else    dup count
                        is-number? 0=                   \ must NOT be a number! arm 25/04/2005 23:41:47
                    if  dup  count s" '.'" compare 0<>     \ ignore '.'
                        over count s" ':'" compare 0<> and \ ignore ':'
                        over                               \ and
                        dup  count '.' scan nip    0<>     \ contains either a DOT
                        swap count ':' scan nip    0<> or  \ or contains a COLON
                                                       and
                        over 1+  c@ '.'             <> and \ no start '.'
                        if      dup>r count 2dup '.' scan nip - x.buf place
                                r@    count 2dup ':' scan nip - dup x.buf c@ <
                                if      x.buf place
                                else    2drop
                                then
                                x.buf   find
 ( check it is obj )     ( arm) -if drop dup ?isObj over ?isUserObj or
                                then ( arm)
                                nip ?dup 0=
                                if      x.buf vfind nip
                                then
                                if      r@ count ':' scan nip
                                        if [ name-max-chars 1+ ] literal LocalAlloc: temp$
                                                r@ count ':' scan 1 /string
                                                temp$ place
                                                ':' temp$ c+place
                                                temp$ count method-hash to method_hval
                                                r> count 2dup ':' scan nip -
                                                x.buf place
                                        else    s" GET:" method-hash to method_hval
                                                r> count x.buf place
                                        then    ['] x.do_message
                                        1
                                else    r> 0
                                then    EXIT
                        then
                    then
                then
                0 ;

\ msgFind is the new action for find.  We look in the following order:
\ 1. Local variables
\ 2. Forth Dictionary (full search order)
\ 3. If word ends in ":" treat it as a selector

: msgFind       ( addr -- addr false | cfa true )
                PARMFIND ?DUP 0=
                IF   _MSGFIND
                     (dprwarn) \ warn if deprecated selector is found (Sonntag, März 13 2005 dbu)
                THEN ;

\ If FIND is used in a TURNKEYed application it must be reset to PARMFIND
\in-system-ok ' msgfind is find

in-previous

\ The following definition is used to initialize dynamic classes ( those created with
\ NEW> ) so must go into the application space

: _classInit  ( -- )    CLASSINIT: [ newObject ]  ;
' _classInit is ClassInit

\ double left bracket has no meaning unless preceded by a selector.

in-system

: <noClassPointer ( -- )
\ *G Set a class to suppress the class pointer when used for IVARs.
\ ** Not inherited by subclasses.
\ XFA is -1 when no class pointer is reserved for IVARs.
        -1 ^class XFA ! ;

: <Indexed  ( width -- )
\ *G Set a class and its subclasses to indexed.
        ?Class  ^Class XFA ! ( <ClassPointer ) ;

: Self  ( -- addr )
\ *G Compile a self reference so we can send ourself late-bound messages, but
\ ** only if the class is guaranteed to have a class pointer.
\ ** with the syntax:   Msg: [ self ].
        POSTPONE ^base ; IMMEDIATE

\ ----------- Instance Variable Contiguous Control -----------

0 value BeginningOfRecordAddress

: Record:       ( -"name"- )  \ W32F             Class
\ *G Define a word that returns the starting address of a group of data fields that
\ ** need to be contiguous. Object IVARS have their class pointer suppressed if used
\ ** in a Record: so only objects that don't use late binding can be used.
                -1 to contiguous-data?
                Class-align
                header
                (&iv) ,         \ return address of array of bytes
                ^Class DFA @ dup , to BeginningOfRecordAddress
                (iv!) ,         \ store integer into first cell of array ??
                (iv+!) , ;      \ add integer to first cell of array     ??

: ;Record       ( -- )        \ W32F             Class
\ *G End a group of data fields that need to be contiguous.
                0 to contiguous-data? ;

: ;RecordSize:  ( -"name"- )  \ W32F             Class
\ *G End a group of data fields that need to be contiguous and create a name with the
\ ** size of the record.
                ;Record ^Class DFA @ BeginningOfRecordAddress - CONSTANT ;

\ -------------------- Instance Variables --------------------

: bytes         ( n -"name"- )         \ W32F          Class
\ *G n-Bytes instance variable (array of bytes)
                header
                (&iv) ,                 \ return address of array of bytes
                ^Class DFA @ ,
                -1 ,                    \ Can't store integer into array
                -1 ,                    \ Can't add integer to array
                0 bitmax                \ verify & set bit field finished & new max
                class-allot ;

:noname 0 bytes ; is ivar-name

: byte          ( -"name"- )           \ W32F          Class
\ *G Byte (8bit) size instance variable.
                header
                (ivc@) ,
                ^Class DFA @ ,
                (ivc!) ,
                (ivc+!) ,
                8 bitmax                \ verify & set bit field finished & new max
                1 class-allot ;

in-previous

cfa-func (ivb@) ( pfa -- bitfield_contents )
                dup>r       @ ^base + @         \ get 32bit contents
                r@ 4 cells+ @ and               \ mask out all other bits
                r> 3 cells+ @ rshift ;          \ shift down to low bits

(ivb@) to &(ivb@)       \ so we can verify data type

cfa-func (ivb!) ( bits_to_store pfa+2*cells -- )
                >r
                r@ 1 cells+  @ lshift           \ scale up to proper bits
                r@ 2 cells+  @ and              \ mask out other bits
                r@ 2 cells - @ ^base + @        \ get existing field contents
                r@ 2 cells+  @ invert and       \ mask out OUR bits
                or                              \ mask in new value of bits
                r> 2 cells - @ ^base + ! ;      \ store field back

cfa-func (ivb+!) ( bits_to_add pfa+2*cells -- )
                0 0
                LOCALS| mask data fld bits |    \ use locals to simplify
                fld 1 cells+  @ to mask         \ get valid bit mask for field
                bits fld @ lshift               \ scale up to proper bits
                mask and to bits                \ mask out other bits and save
                fld 3 cells - @ ^base + @ to data \ get existing field contents
                data mask invert and            \ mask OUT OUR bits
                data mask and                   \ leave ONLY OUR bits
                bits +                          \ add in new value of bits
                mask and                        \ clear out any bit overflow
                or                              \ or into remaining bits
                fld 3 cells - @ ^base + ! ;     \ store field back

in-system

: bits          { nbits -- -"name"- }   \ W32F          Class
\ *G Define an 'nbits' bit field in prev data item.
\ *E Example:
\ **         int   BinaryBits        \ a 32bit cell of bit fields
\ **       1 bits  fBinary           \ define the bit fields
\ **       1 bits  fParity
\ **       1 bits  fOutxCtsFlow
\ **       1 bits  fOutxDsrFlow
\ **       2 bits  fDtrControl
\ **       1 bits  fDtrSensitivity
\ **       1 bits  fTXContinueOnXoff
\ **       1 bits  fOutX
\ **       1 bits  fInx
\ **       1 bits  fErrorChar
\ **       1 bits  fNull
\ **       2 bits  fRtsControl
\ **       1 bits  fAbortOnError
\ **      17 bits  fDummy
                header
                (ivb@) ,
                ^Class DFA @ bitmaxval 8 / - ,  \ bits are in previous data item
                (ivb!) ,
                (ivb+!) ,
                nbits class-bitallot ;

: short         ( -"name"- )             \ W32F          Class
\ *G Word integer (16bit) instance variable. When -"name"- is executed the value of -"name"-
\ ** is zero-extended before pushing onto the stack.
                header
                (ivw@) ,
                ^Class DFA @ ,
                (ivw!) ,
                (ivw+!) ,
                16 bitmax               \ verify & set bit field finished & new max
                2 class-allot ;

: int           ( -"name"- )              \ W32F          Class
\ *G Long integer (32bit) instance variable. When used as an object variable has the same
\ ** behaviour as VALUEs.
                contiguous-data? 0= if Class-align then
                header
                (iv@) ,
                ^Class DFA @ ,
                (iv!) ,
                (iv+!) ,
                32 bitmax               \ verify & set bit field finished & new max
                cell class-allot ;

: dint          ( -"name"- )              \ W32F          Class
\ *G Double (64bit) instance variable.
                contiguous-data? 0= if Class-align then
                header
                (ivd@) ,
                ^Class DFA @ ,
                (ivd!) ,
                (ivd+!) ,
                0 bitmax                \ verify & set bit field finished & new max
                2 cells class-allot ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Primatives for cell sized objects.
\ Ported from Doug Hoffman's Class11 for compatibility
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: M@  ( -- n )
\ *G Fetch the contents of the first cell of the object. Designed for use with VAR.
                POSTPONE ^base  POSTPONE @ ; IMMEDIATE

: M!  ( n -- )
\ *G Store the TOS into the first cell of the object. Designed for use with VAR.
                POSTPONE ^base  POSTPONE ! ; IMMEDIATE

in-application

: @width  ( ^class -- elWidth )  \ return the indexed element width for a class
 XFA @  0 MAX ;

\ =====================================================================
\ Indexed primitives. These should be in code for best performance.

: idxBase  ( -- addr )  \ get base of idx data area
 ^base  DUP obj>class DFA @ +  CELL+ ;

: limit    ( -- n )  \ get idx limit (#elems)
 ^base  DUP obj>class DFA @ + 2 + w@ ;

: #width    ( -- n )  \ width of an idx element
 ^base obj>class XFA @ ;

: ^elem   ( index -- addr ) \ get addr of idx element
 #width *  idxBase + ;

\ Fast access to byte and cell arrays.
: At1  ( index -- char )   idxBase + C@ ;
: At4  ( index -- cell )   CELLS idxBase + @ ;

: To1  ( char index -- )   idxBase + C! ;
: To4  ( cell index -- )   CELLS idxBase + ! ;

: ++1  ( char index -- )   idxBase + C+! ;
: ++4  ( cell index -- )   CELLS idxBase + +! ;

\ Compute total length of object.
\ The length does not include class pointer.
: objlen  ( -- objlen )
 ^base obj>class DUP DFA @  ( non-indexed data )
 SWAP @width ?DUP
 IF  idxBase 2 - w@ ( #elems ) * +  CELL+  THEN ;

\ ====================================================================
\ Support for 2 dimensional arrays

cell newuser ColDim
cell newuser RowDim

\ =====================================================================
\ Runtime indexed range checking. Use +range and -range to turn range
\ checking on and off.

defer ?idx

internal

: ?range  ( index -- index )  \ range check
 DUP idxBase CELL - 2 + w@ ( #elems )  U< IF EXIT THEN
 THROW_INDEX_OFR throw ;

\ : int-array    ( size -"name"- )
\                header
\                (iv[]@) ,
\                ^Class DFA @ ,
\                (iv[]!) ,
\                (iv[]+!) ,
\                cells class-allot ;

module

previous definitions also classes also hidden

: +range  ['] ?range is ?idx ;  +range
: -range  ['] NOOP   is ?idx ;

initialization-chain chain-add +range

previous

: Dimension     ( Rows Cols -- Size )
\ *G Set the dimensions for the next 2 dimensional array to be created (either at compile
\ ** time, or at run-time using NEW>) and return the size (Rows*Cols). \n
\ ** For dynamic object DIMENSION applies to the next 2 dimensional array in the same task.
          ColDim ! RowDim !  ColDim  RowDim  *  ;


: Dispose       ( addr -- )
\ *G Dispose of a dynamically allocated object.
                ~: [ dup>r ] r> ( cell- ) Free THROW_DISPOSE_ERR ?throw ;

: ?Dispose      ( addr -- )
\ *G Dispose of a dynamically allocated object if address is non-zero. Allows storing either
\ ** 0 or an object address in a value.
                ?dup if Dispose then ;

\ --------------------------------------------------------------------
\ ------------- Support for windows procedures etc -------------------
\ --------------------------------------------------------------------

\ ' execute alias Methodexecute         \ made a colon def - [cdo-2008May13]
\ ' catch   alias Methodcatch           \ made a colon def - [cdo-2008May13]
: MethodExecute \ synonym of execute
                execute ;
: MethodCatch   \ synonym of catch
                catch ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\                   The Base Class "Object"
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ :Class object   ' classes >Class classes inherit

\ Revised by -rbs July 9th, 2002

\ *P Since ClassRoot inherits from the pseudo class consisting of the classes
\ ** Vocabulary plus the five added vectors MFA IFA DFA XFA and SFA ( see primhash.f
\ ** for more details ) DO NOT add any more definitions to CLASSES from here on.

\ *P Generic Classes ( those that are created SOLELY for other classes to inherit
\ ** from and therefore have no instances ) can have the info compiled by :CLASS
\ ** and <SUPER ( or INHERIT ) placed IN-SYSTEM. All Method and
\ ** IVARs must be placed IN-APPLICATION. Ordinary definitions can go into either
\ ** space according to whether or not they are needed in a TURNKEYed application

in-system

:Class ClassRoot   ' classes >Class inherit
\ *G Use this class if you have no ivars in your class.
\ ** It will trap undefined methods that might slip through otherwise.
\ ** Note: Class String SHOULD use this as its Super.  Not changed
\ ** at this time.  There are only (expected default) methods defined
\ ** here.

in-application

\ -rbs Adding a true Base Class that has no default methods for record types.



        :M ClassInit:   ;M
\ *G Initialise the object. This method is called implicitly when an object is created,
\ ** either at compile time (for objects in the dictionary) or at run-time (for dynamically
\ ** created objects). Ivars are initialised when the object containing them is initialised.
\ ** Default does nothing.
        :M ~:           ;M
\ *G De-initialise the object. This method is called implicitly when a dynamic object is
\ ** disposed of, before the memory is freed. Ivars are not implicitly de-initialised so
\ ** objects and classes that have ivars that need de-initialising should explicitly send
\ ** this message to them.
        :M Addr:        ( -- addr )     ^base  ;M
\ *G Return the address of the object. Since executing the object returns the address anyway
\ ** this method is obsolescent. Versions prior to V6.11 needed to use this for object ivars.
        :M Print:       ( -- )          ." Object@" ^base .  ;M
\ *G Print the address of the object. Used for debugging purposes only.

;Class

hashed definitions

' Addr: alias AddrOf:

previous also definitions



in-system

\ Use "<Super OBJECT" for classes that have ivars
:Class object   <Super ClassRoot
\ *G Generic class for objects that contain non-object ivars.

in-application

\ *P The following methods are for use with the dotted notation which compiles code to place
\ ** the CFA of the non-object IVAR on the stack and then the object address

:M Get:         ( -- n1 )                execute ;M
\ *G Get the value of the ivar. This is the default method automatically compiled if at ivar
\ ** is referenced with dotted notation without a preceeding method.

:M Put:         ( n/d -- )       2 cells+ execute ;M
\ *G Put the value on the stack (dints expect a double number/other ivars expect a single
\ ** number) into the ivar.

:M Add:         ( n/d -- )       3 cells+ execute ;M
\ *G Add the value on the stack (dints expect a double number/other ivars expect a single
\ ** number) to the ivar.

:M And:         ( n1 -- )
\ *G Perform a bitwise AND on the contents of the ivar and n1 storing the result in the
\ ** ivar. Note dints perform the AND on the 2 cells of the ivar storing the result as the
\ ** most significant cell, with n1 as the least.
                dup>r Get: self AND r> put: self ;M

:M Or:          ( n1 -- )
\ *G Perform a bitwise OR on the contents of the ivar and n1 storing the result in the
\ ** ivar. Note dints perform the OR on the 2 cells of the ivar storing the result as the
\ ** most significant cell, with n1 as the least.
                dup>r Get: self OR r> put: self ;M
:M Xor:         ( n1 -- )
\ *G Perform a bitwise XOR on the contents of the ivar and n1 storing the result in the
\ ** ivar. Note dints perform the XOR on the 2 cells of the ivar storing the result as the
\ ** most significant cell, with n1 as the least.
                dup>r Get: self XOR r> put: self ;M
:M &OF:         ( -- addr )
\ *G Return the address of the ivar.
                >body @ self + ;M

;Class
\ *G End of class

also classes

unres-methods unres-len erase

semicolon-chain chain-add resolve-methods
\ link into definition completion

previous

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\               Define data type class for strings
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class String   <Super ClassRoot

MAXSTRING bytes theBuffer

:M Get:         ( -- a1 n1 ) theBuffer  count ;M
:M Put:         ( a1 n1 -- ) theBuffer  place thebuffer +null ;M
:M Add:         ( a1 n1 -- ) theBuffer +place thebuffer +null ;M
:M Append:      ( a1 n1 -- ) theBuffer +place thebuffer +null ;M

;Class

:Class Rectangle  <Super Object
\ *G Class for rectangles for passing to the OS.

Record: AddrOf
        int Left
        int Top
        int Right
        int Bottom
;Record

:M SetRect:     ( left top right bottom -- )
\ *G Set coordinates
                to Bottom
                to Right
                to Top
                to Left
                ;M

:M EraseRect:   ( -- )
\ *G Set all coordinates to zero.
                0 0 0 0 SetRect: self ;M

:M ClassInit:   ( -- )
\ *G Initialise the object. The coordinates are set to zero.
                ClassInit: super
                EraseRect: self ;M

:M Left:        ( -- n1 )       Left   ;M
:M Top:         ( -- n1 )       Top    ;M
:M Right:       ( -- n1 )       Right  ;M
:M Bottom:      ( -- n1 )       Bottom ;M

:M Width:       ( -- n1 )
                right left - ;M
:M Height:      ( -- n1 )
                bottom top - ;M \ cordinates are relative to the top of the screen.

:M .Rect:       ( -- )
                cr ." Rect: " Left . Top . Right . Bottom .
                ;M

;Class

UserObject: RECTANGLE temprect      \ a sample rectangle object, used by the system sometimes


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ display all classes in the system
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-SYSTEM

: .CLASSES      ( -- )          \ W32F        Class
\ *G Display all classes in the system.
\ Should really be in classdbg.
                cr              \ classes are really vocabularies
                voc-link @
                BEGIN   dup vlink>voc
                        voc>vcfa dup ?isClass
                        IF      dup >name name>
                                ['] [UNKNOWN] =         \ if not found
                                IF      drop            \ then discard the class
                                ELSE    .name
                                        20 #tab 20 ?cr
                                THEN
                        ELSE    drop
                        THEN
                        @ dup 0=
                UNTIL   drop  ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ return xt of method
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

also classes also hidden

: GetMethod     { \ m0cfa -- -<method: object>- m0cfa }  \ W32F        Class
\ *G Return the xt of method. Used in interpretive mode or to create parsing words.
                @word _msgFind 1 <>  THROW_UNDEF_METH ?throw
                TRUE to get-reference?  \ tell do_message to return method
                depth >r
                execute to m0cfa        \ execute do_message
                depth r> <
                if      0               \ if it was a class, object is NULL
                then    to obj-save m0cfa ;

: [GetMethod]   ( compiling:- -<method: object>- -- ) ( runtime:-  -- m0cfa ) \ W32F Class
\ *G Compile the xt of the method as a literal into the current definition. Compile only.
                state @ >r postpone [
                GetMethod r> if ] then
                Postpone Literal ; Immediate

previous previous

IN-APPLICATION

