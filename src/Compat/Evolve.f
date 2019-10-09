\ $Id: Evolve.f,v 1.15 2013/12/09 21:25:16 georgeahubert Exp $

cr .( Loading Evolve.f : compatibility with previous release ...)


           \ ******************************************************\
           \ This file is specific to the changes between releases \
           \                 6.12.00 and 6.14.00                   \
           \ ******************************************************\


\ ***************************** IMPORTANT NOTE ******************************** \
\                                                                               \
\  This file contains words which will be removed from the next Win32Forth      \
\  release (they may be obsolete, have a better counterpart, or reflect an      \
\  evolution to better features)                                                \
\                                                                               \
\  This file, and thus these words, are still included in the system but they   \
\  are all flagged "deprecated" and a message will warn you if any of your      \
\  sources is using one of them.                                                \
\                                                                               \
\  When you get such a message, you are strongly encouraged to make any needed  \
\  conversion to your sources because they will no longer be present in the     \
\  next win32Forth release.                                                     \
\                                                                               \
\  For each affected word, you will find in this file (usually as the first     \
\  comments about the word) all needed instructions to make the conversion.     \
\                                                                               \
\  Win32For developements systems contain words that have been deprecated but   \
\  haven't yet been moved to this file (though unless problems arise they will  \
\  be moved here before the next stable release.                                \
\                                                                               \
\ ***************************************************************************** \


only Forth also definitions

warning off dpr-warning-off

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\            words removed from the system (ie win32for.exe)
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ from src\comment.f
\ ------------------

in-system

: /*            \ up to */  replace by ( ... ) or (( ... ))
                \in-system-ok   s" */"       "comment ; immediate
                deprecated \ june 27 2008

: (*            \ up to *) replace by ( ... ) or (( ... ))
                \in-system-ok   s" *)"       "comment ; immediate
                deprecated \ june 27 2008

: DOC           \ up to ENDDOC replace by ( ... ) or (( ... ))
                \in-system-ok   s" ENDDOC"   "comment ; immediate
                deprecated \ june 27 2008

: --            \ replace by \ NOTE this refers to -- outside of { and } ; it is still part of the
                \ LOCALS syntax
                postpone \ ; immediate
                deprecated \ june 27 2008

: <A            \ replace by \
                postpone \ ; immediate
                deprecated \ june 27 2008


\ from src\class.f
\ ----------------

: Heap>         \ replace by NEW>
\in-system-ok   postpone New> ; immediate
                deprecated \ june 27 2008

: <Object       \ replace by <SUPER
\in-system-ok   <super ;
                deprecated \ june 27 2008

: <Class        \ replace by <SUPER
\in-system-ok   <super ;
                deprecated \ june 27 2008


\ from src\imageman.f
\ -------------------

: WITH-IMG      \ replace by nothing (was a NOOP). No longer needed since the 'c' wrapper was removed.
                ; IMMEDIATE
                deprecated \ since late 2003


\ from src\primutil.f
\ -------------------

version# ((version)) 0. 2swap >number 3drop 7 <  [if]  \ For V6.xx.xx supporting older OSs

: NT?           \ replace by WINVER WINNT351 >=
                ( -- fl )
                WinVer WINNT351 >= ;   \ NT3.51 or above
                deprecated \ since a long time
: Win95?        \ replace by WINVER WIN95 =
                ( -- f1 )
                winver win95 = ;
                deprecated \ since a long time
: Win98?        \ replace by WINVER WIN98 WINME BETWEEN
                ( -- f1 )
                winver win98 winme between ;
                deprecated \ since a long time
: Win32s?       \ replace by FALSE (win32s is no longer supported)
                ( -- f1 )
                false ;
                deprecated \ since a long time

[else]

: nt?     ( -- f ) true ; deprecated
: Win95?  ( -- f ) false ; deprecated
: Win98?  ( -- f ) false ; deprecated
: Win32s? ( -- f ) false ; deprecated

[then]

\ rel>abs and abs>rel are deprecated since version 6.10
\ They are still in primutil.f to support old code


\ from src\shell.f
\ ----------------
: .editor       \ replace by .SHELL
\in-system-ok   .shell ;
                deprecated \ since a long time
: .dos          \ replace by .SHELL
\in-system-ok   .shell ;
                deprecated \ since a long time
: .browse       \ replace by .SHELL
\in-system-ok   .shell ;
                deprecated \ since a long time
: zEXEC         \ replace by zEXEC-CMD or zEXEC-CMD-WAIT depending on your needs
                ( a1 -- f1 ) \ execute a command line
                count ((CreateProcess)) ;
                deprecated \ since a long time
: `             \ replace by SHELL
                \ synonym of SHELL
                shell ;
                deprecated \ since a long time
: sys           \ replace by SHELL
                \ synonym of SHELL
                shell ;
                deprecated \ since a long time


\ from src\utils.f
\ ----------------
: _of-range     \ see of-range next
                ( n1 n2 n3 -- n1 f1 )
                2 pick -rot between ;
                deprecated \ August 3 2008
: of-range      \ is bugged, use RangeOf instead (defined in lib\fcases.f)
                ( n1 n2 n3 -- n1 )      \ extension to CASE for a range
\in-system-ok   ?comp POSTPONE _of-range POSTPONE ?branch >mark 4 ; immediate
                deprecated \ August 3 2008


\ from src\ansfile.f
\ ------------------
: asciiz->asc-len \ replace by ZCOUNT
                ( adrz -- sadr slen )
                zcount ;
                deprecated \ August 3 2008


\ from src\kernel\fkernel.f
\ -------------------------
: ?UPPERCASE    \ replace by UPPERCASE
                UPPERCASE ;
                deprecated \ August 3 2008


\ removed from src\float.f
\ ------------------------

' FLOATSTACK >body @ checkstack
constant FSTACK	\ don't use        ( equivalent to FLOATSTACK UP@ - )
                deprecated \ since July 4 2005
' FLOATSP >body @ checkstack
constant FSP    \ don't use        ( equivalent to FLOATSP UP@ - )
                deprecated \ since July 4 2005

( the following words were for moving floats between the floating point stack and the return
stack, but were not used by the system or any programs.)

: r>f           \ don't use
                r> rp@ f@ b/float rp@ + rp! >r ;
                deprecated \ since July 4 2005

: f>r           \ don't use
                r> rp@ b/float - rp! rp@ f! >r ;
                deprecated \ since July 4 2005
: fdup>r        \ don't use
                r> fdup rp@ b/float - rp! rp@ f! >r ;
                deprecated \ since July 4 2005
: fr@           \ don't use
                r> r@ f@ >r ;
                deprecated \ since July 4 2005

\ ---------------------------------------------------------------------------------------

code (f@)       \ don't use
                ( addr -- ; fpu: --r ) \ Fetch float to FPU stack (not the simulated FP stack)
                fld     FSIZE DATASTACK_MEMORY
                pop     tos
                float;
                deprecated \ since July 4 2005

code fpush      \ don't use
                ( fpu: r -- )  ( fs: -- r )   \ move from FPU stack to simulated FP stack
                FPU>
                float;
                deprecated \ since July 4 2005
code fpop       \ don't use
                ( fpu: -- r )   ( fs: r -- )  \ move from simulated FP stack to FPU stack
                fstack-check_1
                >FPU
                float;
                deprecated \ since July 4 2005

: f^x           \ replace by F**
                \ synonym of f**
                f** ;
                deprecated \ since July 4 2005


\ removed from src\console\console1.f
\ -----------------------------------
: NOTE          \ replace by TONE
                ( frequency duration-ms -- ) \ synonym of TONE
                swap call Beep drop ;
                deprecated \ since a long time
1 PROC SetCursor
2 PROC LoadCursor
: set-pointer   \ replace by nothing  (is used by words removed from scrnctrl.f)
                ( pointer-identifier -- )       \ set the pointer shape
                0 call LoadCursor call SetCursor drop ;
                deprecated \ since a long time
: SP>COL        \ replace by COL
                COL ;
                deprecated \ since a long time


\ removed from src\scrnctrl.f
\ ---------------------------
: new-pointer   \ replace by  0 MAKE-CURSOR
                ( a1 -- )
                create ,
                does>   @ set-pointer ;
                deprecated \ since a long time

IDC_ARROW   new-pointer arrow-pointer
                \ replace by ARROW-CURSOR
                deprecated \ since a long time
IDC_CROSS   new-pointer cross-pointer
                \ replace by CROSS-CURSOR
                deprecated \ since a long time
IDC_IBEAM   new-pointer ibeam-pointer
                \ replace by IBEAM-CURSOR
                deprecated \ since a long time
IDC_ICON    new-pointer icon-pointer
                \ replace by ???
                deprecated \ since a long time
IDC_NO      new-pointer noway-pointer
                \ replace by NOWAY-CURSOR
                deprecated \ since a long time
IDC_WAIT    new-pointer wait-pointer
                \ replace by WAIT-CURSOR
                deprecated \ since a long time
IDC_UPARROW new-pointer uparrow-pointer
                \ replace by UPARROW-CURSOR
                deprecated \ since a long time
IDC_SIZE    new-pointer size-pointer
                \ replace by SIZEALL-CURSOR
                deprecated \ since a long time


\ removed from src\colors.f
\ ------------------------

: FOREGROUND    \ replace by FGBG! (takes color objects) as in: black BG@ FGBG!
                { color_object \ theDC -- } \ set foreground text color
                color_object ?ColorCheck drop
                Color: color_object BG@ FGBG! ;
                deprecated \ since a long time

: BACKGROUND    \ replace by FGBG! (takes color objects) as in: FG@ white FGBG!
                { color_object \ theDC -- } \ set background text color
                color_object ?ColorCheck drop
                FG@ Color: color_object FGBG! ;
                deprecated \ since a long time

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\            older deprecated words waiting for a replacement
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
((
\ removed from src\ansfile.f
\ --------------------------
.DIR->FILE-NAME   --> ???
_PRINT-DIR-FILES  --> ???    why is "deprecated" warning disabled here ?

\ removed from src\console1.f
\ --------------------------
>BOLD             --> ???
>NORM             --> ???

\ removed from src\console2.f
\ ---------------------------
SET-FONT          --> ???

There is also TempRect & Wrect to settle.
))



\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\            words removed from the libraries, applications, etc.
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ from lib\fcases.f
\ ----------------
: ("of-compare) \ see "OF-COMPARE next
                ( counted-source a1 c1 -- counted-source ff | tf )
                2>r dup count 2r> compare 0= -if nip then ;
                deprecated \ August 3 2008
: "of-compare	\ replace by "of (defined in lib\fcases.f)
                \ synonym of "of
\in-system-ok   ?comp POSTPONE ("of-compare) POSTPONE ?branch >mark 4 ; immediate
                deprecated \ August 3 2008

: ("of-include) \ see "OF-INCLUDE next
                2>r dup count 2r> compare 1 = -if nip then ;
                deprecated \ August 3 2008
: "of-include   \ replace by "of-begin (defined in lib\fcases.f)
                ( n1 n2 n3 -- n1 ) \ extension to CASE for a string
\in-system-ok   ?comp POSTPONE ("of-include) POSTPONE ?branch >mark 4 ; immediate
                deprecated \ August 3 2008


\ from apps\setup\com01.f
\ -----------------------
: abs@          \ replace by @
                \ was used when win32Forth had relative or absolute addresses
                @ ;
                deprecated \ August 3 2008


\ from src\lib\MessageLoop.f
\ --------------------------
\ Message-Loop  \ replace by MessageLoop

in-previous

dpr-warning-on warning on

\s

\ ------------------------------------------------------------------------------
\ Comments for Win32Forth developpers
\ ------------------------------------------------------------------------------

\ To check for sure that every word moved to Evolve.f is no longer used in the
\ win32forth CVS , transiently comment out the line :
\              FLOAD src\compat\Evolve.f
\ in the file src\extend.f and rebuild win32forth.


\ REMINDERS :
\ When some words are definitively removed, this allows some changes :
\ - all words: change source colorization :
\   - apps\wined\ed_colorize.f
\   - src\lib\scintillalexer.f
\ - all words: change hyperlinkers
\   - apps\wined\Ed_EditWindowObj.f
\ - comments: change source parsers :
\   - lib\enums.f
\   - apps\win32forthIDE\projecttree.f & navigator.f
\   - help\fileparser.f
\ - ...



\ ------------------------------------------------------------------------------
\ candidates to be removed
\ ------------------------------------------------------------------------------

\ from src\comment.f
\ ------------------
// and //{{NO_DEPENDENCIES}} (once I have replaced res dialogs by forthform ones)


\ miscellaneous
\ -------------

c;                --> ;c          \ in src\asmwin32.f
end-code          --> ;c          \ in meta-compiler.f     cf compatibility.f
UNNESTM           --> EXITM       \ in src\primhash.f
UNNESTP           --> EXITP       \ in kernel.f
z                 --> edit        \ in src\editor-io.f
?KeyPause         --> start/stop  \ in utils.f
flist             --> ftype       \ in utils.f






