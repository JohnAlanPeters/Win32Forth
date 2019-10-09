\ $Id: ConsoleStatbar.f,v 1.12 2013/07/21 00:08:50 georgeahubert Exp $

\ ConsoleStatbar.f     (was ConsoleStabarNew.f)

\  Author: Dirk Busch
\ Created: September 26th, 2003 - 10:30 dbu
\ Updated: January 22nd, 2004 - 10:43 dbu
\ Statusbar for the Win32Forth console window
\ Uses class from Statusbar.f

Needs Statusbar.f


INTERNAL

\ *****************************************************************************
\  window class for the status bar
\ *****************************************************************************

:Object ConsoleStatusbar  <Super MultiStatusbar

create MultiWidth 80 , -1 , \ width of statusbar parts

0 value forth-sp
0 value forth-depth
0 value forth-base

8 value display-depth       \ # of stack entries that are displayed

:M Start:      ( hParent -- )
                Start: super
                GetHandle: self
                if   MultiWidth 2 SetParts: self
\                     Show: self
                then ;M

:M SetSP:       ( n -- )
                to forth-sp ;M

:M SetDepth:    ( n -- )
                to forth-depth ;M

:M SetBase:     ( n -- )
                to forth-base ;M

:M SetDisplayDepth:     ( n -- )
                to display-depth ;M

:M SetText:     ( a n -- ) \ set text a for part n
                swap dup +null 1+ swap SetText: super ;M

:M Update:      { \ buf$ buf1$ pad$ -- }
                MAXSTRING LocalAlloc: buf$  \ temp string buffer
                MAXSTRING LocalAlloc: buf1$ \ temp string buffer
                MAXSTRING LocalAlloc: pad$  \ a place to save PAD
                pad pad$ MAXSTRING move \ save PAD, (.) not reentrant
                hld @ >r                \ save HLD, (.) not reentrant

                \ print base
                s"  Base: " buf$ place
                forth-base
                case        2 of s" binary"  buf$ +place endof
                            8 of s" octal"   buf$ +place endof
                           10 of s" decimal" buf$ +place endof
                           16 of s" hex"     buf$ +place endof
                           ( default )  decimal forth-base (.) buf$ +place forth-base base !
                endcase
                buf$ 0 SetText: self

                \ print stack from left to right (right is TOS)
                s"  Stack: " buf$ place
                forth-depth 0=
                if   s"  empty " buf$ +place
                else \ display stack depth
                     BASE @ >R DECIMAL
                     s" {" buf$ +place forth-depth (.) buf$ +place s" } " buf$ +place
                     R> BASE !

                     \ display stack entries
                     0  forth-depth 1- display-depth 1- min
                     do  i cells forth-sp + @ (.) buf$ +place
                         s"  " buf$ +place
                     -1 +loop
                then

                \ print Floating point stack from left to right (right is TOS)
                s" | Floating point stack: " buf$ +place
                fdepth 0=
                if   s"  empty" buf$ +place
                else \ display Stack depth
                     BASE @ >R DECIMAL
                     s" {" buf$ +place fdepth (.) buf$ +place s" } " buf$ +place
                     R> BASE !

                     \ display stack entries
                     display-depth fdepth umin dup 1- swap 0
                     DO   dup i - fpick buf1$ (g.) buf1$ count buf$ +place
                          s"  " buf$ +place  \ JvdV, July 26th, 2004 added a seperator
                     LOOP drop
                then
                buf$ 1 SetText: self    \ update status bar

                r> hld !                \ restore HLD
                pad$ pad MAXSTRING move \ restore PAD
                ;M

;Object

\ *****************************************************************************
\  hook's for the interpreter
\ *****************************************************************************

in-system

: Update-Console-Statusbar ( -- ) \ update the status bar
                GetHandle: ConsoleStatusbar
                if   depth SetDepth: ConsoleStatusbar
                     sp@      SetSP: ConsoleStatusbar
                     base @ SetBase: ConsoleStatusbar
                     source-id 0=
                     if Update: ConsoleStatusbar then
                then ;

: Console-Statusbar-interpret ( -- ) \ hook for INTERPRET
                _interpret
                Update-Console-Statusbar ;

\ changed to use the reset-stack-chain
\ January 22nd, 2004 - 13:53 dbu
: Console-Statusbar-reset-stacks ( ?? -- ) \ hook for RESET-STACKS
                 Update-Console-Statusbar ;

\in-system-ok reset-stack-chain chain-add CONSOLE-STATUSBAR-RESET-STACKS

in-application

((
INTERNAL

\ *****************************************************************************
\ set number of stack entries that are displayed in the status bar
\ *****************************************************************************

: Console-SetDisplayDepth ( n -- )
                SetDisplayDepth: ConsoleStatusbar ;
))

MODULE

