(( WINSTACK.F                                   7/26/96 BNE

Subject: w32f contribution
Date: Fri, 26 Jul 1996 23:36:13 -0700 (MST)
From: di44539@goodnet.com (Brad Eckert)
To: zforth@ix.netcom.com

Here's a real small program that displays the stack contents in a window
after each interpret and shows the depth and base in the title bar.  The
only problem with it is that you can't have it active while floading a file.
I tried skipping the paint: stack-window when source-id <> 0, but that
wasn't enough to avoid an error.  Maybe you have some ideas.

-- Brad

Displays the contents of the data stack after each INTERPRET.

July 29th, 1996 - 9:54 tjz
Modified On_Paint: to preserve PAD and HLD, which (.) uses for number
conversion, but which are global variables that may already be in use by other
parts of the program.

Minor cosmetic modifications to display stack right justified.

September 13th, 2003 - 14:39 dbu
changed to display the right stack content after an error during interpret

))

only forth also definitions decimal


defer (win-interpret)    ' noop is (win-interpret)
defer (win-reset-stacks) ' noop is (win-reset-stacks)


:Object STACK-WINDOW <super window

Font stkFont

   8 value maxcells             \ # of displayable cells
  13 value cellwidth            \ width in characters of each cell
   9 value char-width           \ character size in pixels
  14 value char-height
   4 value margin
   3 value offset               \ offset of not-shown stack junk
   0 value forth-sp
   0 value forth-depth

:M ClassInit:   ( -- )
                ClassInit: Super
                s" Fixedsys" SetFaceName: stkFont
                ;M

:M On_Paint:    { \ stack$ pad$ -- }    \ screen redraw procedure
                MAXSTRING LocalAlloc: stack$    \ temp string buffer
                MAXSTRING LocalAlloc: pad$      \ a place to save PAD
                pad pad$ MAXSTRING move         \ save PAD, (.) not reentrant
                hld @ >r                        \ save HLD, (.) not reentrant
                SaveDC: dc                      \ save device context
                Handle: stkFont SetFont: dc     \ set the font to be used

                maxcells 0
                do      i maxcells forth-depth - -
                        dup 0<
                        if      drop s" "
                        else    forth-depth maxcells - 0 max - \ push down
                                cells forth-sp + @ (.)         \ display
                        then
                        stack$ 21 blank
                        cellwidth over - 0max spcs swap stack$ place \ leading blanks
                        stack$ +place                                \ place string
                        margin char-height i *
                        stack$ 1+ 20 TextOut: dc
                loop

                RestoreDC: dc

                s" Stack: ["      stack$  place
                base @ decimal
                forth-depth (.)   stack$ +place
                s" :"             stack$ +place
                dup (.)           stack$ +place
                base !  s" ]"     stack$ +place
                stack$ count SetTitle: self

                r> hld !                        \ restore HLD
                pad$ pad MAXSTRING move         \ restore PAD
                ;M

:M On_Init:     ( -- )
                On_Init: super
                s" Fixedsys" SetFaceName: stkFont
                Create: stkFont
                ['] (win-interpret)    is interpret
                ['] (win-reset-stacks) is reset-stacks
                ;M

:M On_Done:     ( -- )
                ['] _interpret    is interpret
                ['] _reset-stacks is reset-stacks
                Delete: stkFont
                On_Done: super
                ;M

:M StartSize:   ( -- width height )     \ starting window size
                cellwidth char-width  *
                margin 2* +
                maxcells char-height  *
                ;M

:M MaxSize:     StartSize: self ;M
:M MinSize:     StartSize: self ;M
:M StartPos:    400 100 ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" Stack"
                ;M

:M WindowStyle: ( -- style )
                WS_CAPTION
                WS_THICKFRAME or
                WS_SYSMENU or
                ;M

:M ExWindowStyle: ( -- style )
                WS_EX_TOPMOST ;M

:M SetSP:       ( n -- )
                to forth-sp ;M

:M SetDepth:    ( n -- )
                to forth-depth ;M

;Object


: win-interpret  ( -- ) \ hook into the interpreter
                _interpret

                depth SetDepth: stack-window
                sp@   SetSP: stack-window

                source-id 0=
                if      Paint: stack-window
                then    ;

: win-reset-stacks ( ?? -- ) \ hook into reset-stacks
                _reset-stacks

                depth SetDepth: stack-window
                sp@   SetSP: stack-window

                Paint: stack-window ;

' win-interpret    is (win-interpret)
' win-reset-stacks is (win-reset-stacks)


: stack-on      ( -- )          \ start the stack window
                Start: stack-window

                depth SetDepth: stack-window
                sp@   SetSP: stack-window

                Paint: stack-window

                focus-console ;

: stack-off     ( -- )          \ close the stack window
                Close: stack-window ;

stack-on        \ open the stack window initially


