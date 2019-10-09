\ $Id: numconv.f,v 1.7 2006/01/14 12:30:17 dbu_de Exp $

\ Alex Mcdonald 25/04/2005 23:13:45
\ public domain, based on work by Tom Zimmer

\ Each number conversion routine on the "number?-chain" chain is sent a string
\ ( addr len) and can attempt to convert the number. If the conversion fails
\ the routine performs a -1 THROW to indicate that it can't convert the string;
\ the next routine is then tried until success or the chain is exhausted. If
\ the chain is exhausted, then a -13 THROW (undefined) is executed.

\ If conversion succeeds, then a double number must be returned. If the number
\ is truly a double, then set the DOUBLE? flag to true, otherwise the number will
\ be considered a single, and the high order cell will be discarded.

\ For numbers with a decimal point, the value DP-LOCATION can be set to indicate
\ where it's located in the input string.

\ If desired, the flag -ve-num? can be set to true; the number will be negated
\ before it is used. This is to avoid keeping flags to indicate that the sign
\ has been detected in each routine separately.

\ Floating point numbers are returned in the floating point stack; there is
\ no return value, and the variable FLOAT? is set. See FLOAT.F for details;
\ the code is in that file, not here. NOTE - even floating point routines must
\ return a double value; it's ignored if FLOAT? is set.

\ The chain number conversion technique allow number conversion to be easily
\ extended to support additional forms of number conversion. This code is
\ added very early, so you can normally only use words in the kernel here.

\ [Historical note] Earlier versions of W32F used a similar chain technique, but
\ carried a flag that was checked to see if the preceding routine had done the
\ conversion. Performing a THROW on failure is much easier, hence the change.

\ following defined in kernel;
\ 0  VALUE DOUBLE?                                \ double value
\ -1 VALUE DP-LOCATION                            \ decimal point location
\ 0  value -ve-num?                               \ negate value flag

new-chain       number?-chain

: -ifzerothrow  ( n -- n )
                dup 0= throw            \ -1 throw if zero length
                ;

: -ve-test      ( addr len -- addr' len' ) \ skip possible - sign, set -ve-num?
                -ifzerothrow            \ stop if nothing to convert
                over c@ [char] - =      \ check for sign
                if -ve-num? throw       \ if already negative, throw
                  true to -ve-num?
                  1 /string             \ bump past
                  -ifzerothrow          \ nothing left is error
                then
                ;

: run-numchain  ( addr len -- d1 )      \ run number chain;
                                        \ d1 is number, or -13 throw (undefined)
                2>r                     \ save string on rstack
                number?-chain           \ run the number chain
                begin @ dup
                while
                  num-init              \ clear the flags
                  dup 2r@ rot           \ string xt
                  cell+ @ catch         \ do the xt
                  0= if                 \ leave if no error
                    2r> 2drop           \ clean the rstack
                    rot drop            \ drop the address
                    -ve-num? if dnegate then \ make negative if asked to
                    exit
                  then
                2drop                   \ clear out failed conversion
                repeat

                -13 throw               \ failed to convert
                ;

\ ------------------------ dotted number --------------------------------------

: dotted-number? ( addr len -- d1 )
                -ve-test
                0 0 2SWAP >NUMBER       \ convert number
                dup if OVER C@ [CHAR] . =  \ next char is a '.' ?
                  if
                    dup 1- to dp-location
                    true to double?
                    1 /string
                    >number             \ convert the rest
                  then
                  dup 0<> throw         \ check no string
                then
                2drop                 \ otherwise, drop string
                ;

\ ------------------------ based-number $&% -----------------------------------

\ Can be used to force number recognition in any base
\ $ -- hex prefix
\ & -- decimal
\ # -- decimal  \ new Samstag, Januar 14 2006 dbu
\ % -- binary

: base-tonum    ( addr len base -- d1 )
                base @ >r base !        \ save base, set base
                ['] dotted-number? catch \ convert
                r> base !               \ restore base
                throw                   \ throw if in error
                ;

: xbase-convert ( addr len base -- d1 )
                >r 1 /string r>         \ past base char
                base-tonum
                ;

: base-number?  ( addr len -- d1 )      \ [-][$&%'][-]n[n*][.n*]
                -ve-test                \ might start with -
                over c@
                case
                  [char] $ of  16 xbase-convert endof
                  [char] & of  10 xbase-convert endof
                  [char] # of  10 xbase-convert endof
                  [char] % of   2 xbase-convert endof
                  drop dotted-number? dup
                endcase
                ;

number?-chain chain-add base-number?

: new-number    ( str -- d1 )           \ d1 is number, or -13 throw (undefined)
                uppercase count run-numchain ;

' new-number is number                  \ replace normal number conversion
                                        \ with the new chain scheme

\ ------------------------ 0x[L] hex number -----------------------------------

: lastchar      ( addr len -- addr len char )
                2dup 1- + c@ ;

: 0xL-number?    ( addr len -- d1 )
                -ve-test                     \ might start with -
                over 2 s" 0X" str= 0= throw  \ start with 0X?
                2 /string                    \ bump past 0x
                -ifzerothrow                 \ throw if too short
                lastchar [char] L = +        \ end in L? trim off if so
                16 base-tonum                \ convert hex string
                ;

number?-chain chain-add 0xL-number?

\ -------------------------- xH hex number ------------------------------------

: hex-number?   ( addr len -- d1 )           \ xxxxH type numbers
                -ifzerothrow                 \ throw if too short
                lastchar [char] H <> throw   \ end in H?
                1- 16 base-tonum             \ trim off, convert
                ;

number?-chain chain-add hex-number?

\ --------------------------- '.' number --------------------------------------

: quoted-number? ( addr len -- d1 )          \ 'x' type numbers
                -ve-test                     \ might be negative
                3 <> throw                   \ not 3 chars 'x'
                dup dup c@ swap 2 + c@       \ fetch first and third chars
                over = swap [char] ' =
                and invert throw             \ equal and ', otherwise error
                1+ c@ 0                      \ fetch the character
                ;

number?-chain chain-add quoted-number?

\ ------------------------ Windows Constant Server ----------------------------

WinLibrary WINCON.DLL
winlib-last @ constant WinConLib
3 proc wcFindWin32Constant
winproc-last @ constant WinConPtr      \ for **WORDS.F**
3 proc wcEnumWin32Constants
winproc-last @ constant WinEnumPtr      \ for **WORDS.F**

: wincon-call   ( a1 n1 -- n f )             \ call to find constant
                2>r 0 sp@ 2r> swap           \ point at result on stack
                Call wcFindWin32Constant     \ find it
                ;

: wincon-number? ( a1 n1 -- d )
                { \ con$ -- }
                2dup wincon-call             \ find constant
                if nip nip                   \ found, drop string
                else
                  drop                        \ drop returned value
                  MAXSTRING LocalAlloc: con$  \ allocate a buffer the con name
                  con$ place                  \ lay string in buffer
                  s" A" con$ +place           \ append an 'A'
                  con$ count wincon-call      \ find it
                  0= throw                    \ can't find it
                then 0                        \ make a double
                ;

number?-chain chain-add wincon-number?          \ windows constant server

\ ------------------- Dotted IP notation (a.b.c.d) ------------------------------

: ip-seg        ( addr len -- addr' len' n ) \ IP segment before .
                dup >r                       \ save length
                0 0 2swap >number            \ convert to number
                2swap d>s                    \ save string & convert to single
                over r> <>                   \ check lengths differ before & after
                over 0 256 within            \ and range check it
                and 0= throw                 \ flag; true=error
                ;

: ip-number?    ( addr len -- d )            \ convert ip address
                8 24 do                      \ 3 dotted segments
                  ip-seg                     \ convert up to dot
                  i lshift                   \ shift the value,
                  -rot                       \ addr string to top
                  -ifzerothrow               \ string too short?
                  over c@ '.' <> throw       \ check for a dot, error if not
                  1 /string                  \ move past .
                -8 +loop                     \ next shift
                ip-seg                       \ convert what's left
                -rot throw                   \ should be nothing left
                drop or or or 0              \ or in to get result, make double
                ;

number?-chain chain-add ip-number?           \ dotted IP notation

\ ------------------- Compatability layer --------------------------------------

defer discard-number
   ' 2drop is discard-number                 \ for doubles; see float.f for floats

\ fixed to be compatible with w32f Version 6.10
\ Samstag, August 27 2005 dbu
: NUMBER?       ( addr len -- d f )
                num-init
                ['] dotted-number? catch 0= ;

: IS-NUMBER?    ( addr len -- f )            \ number check
                ['] run-numchain catch >r discard-number r> 0= ;

: SUPER-NUMBER? ( addr len -- d f1 )
                ['] run-numchain catch 0= ;
