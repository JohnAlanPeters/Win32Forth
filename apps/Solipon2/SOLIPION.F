\ $Id: SOLIPION.F,v 1.17 2013/12/17 19:25:21 georgeahubert Exp $

only forth also definitions

\ needs NoConsole.f
needs Resources.f

true value turnkey?

           0    value smallstring
           0    value stamper
           0    value string-player-name
           0    value nRaw
           0    value nLine
           0    value univers
           0    value univers1
           0    value univers2
           0    value univers3
           0    value univers4
           0    value moves-table
           0    value moves
           0    value counter
           0    value max-counter
           0    value best
           0    value bests-table
           0    value tempo
          32    value step
           0    value direction
           0    value rank
           0    value busy?
           0    value flag-1
           0    value flag0
           0    value flag1
           0    value flagx
           0    value table-of-possibilities
           0    value how-many?
           0    value gamebusy?
           0    value empty-handed?
          50    value best3
          20    value best10
           0    value bests-in?
       FALSE    value size?
        TRUE    value winpause?
        TRUE    value music?
       FALSE    value in-memory?
       FALSE    value yahoo-already?
           0    value auto?
        TRUE    value put-by?
           0    value hypothesis?
           0    value show?
           0    value unroll-busy?
           0    value shift-x
           0    value shift-y
           0    value dx
           0    value dy
       FALSE    value auto-save?
        TRUE    value best?
         500    value startsize
       FALSE    value same-thing?
       FALSE    value random-board? \ get a random board each time you start the game :)
          72    value max-pawns

\ ---------------------------------------------------------------
\       Define the BIT-WINDOW window class
\ ---------------------------------------------------------------

needs BitmapDC.f

bitmap-dc solipion-dc

:Class bit-window  <super child-window

:M On_EraseBackground: ( hwnd msg wparam lparam -- res )
        4drop 0 ;M \ let the On_Paint: Method redraw the background

:M On_Paint:    ( -- )
        ps_left ps_top ps_right ps_bottom DC Paint: solipion-dc ;M

:m On_Size:     ( -- )
        get-dc GetSize: super dc Init: solipion-dc release-dc ;M

:M On_Done:     ( -- )
        Destroy: solipion-dc
        On_Done: super
        ;M

:M WM_MOUSEMOVE ( h m w l -- res )
        set-mousexy
        MK_LBUTTON and
        IF   track-func null-check execute
        THEN 0
        ;M

;Class

\ ------------------------------------------------------------------------------
\       Menu, Popup, Toolbar ...
\ ------------------------------------------------------------------------------

needs menu.f

\ ------------------------------------------------------------------------------
\ ----- Sounds inspired of the famous quadrix of mike kemper
\ ------------------------------------------------------------------------------

needs sound.f

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

defer save-game
defer re-open-game
defer Unroll

\ ------------------------------------------------------------------------------
\ the main window
\ ------------------------------------------------------------------------------

:Object SOLIPIONW  <super window

bit-window vga-bit-window
Rectangle  DemoRect

:M Classinit:   ( -- )          \ static initialization goes here, IF needed
        ClassInit: super ;M

:M On_Init:     ( -- )          \ initialize the class
        On_Init: super                  \ first init super class

        2    SetId: vga-bit-window      \ then the child window
        self Start: vga-bit-window      \ then startup child window

        3 SetId: Solipion-Tool-Bar1
        self Start: Solipion-Tool-Bar1

        Solipion-menu-bar  SetMenuBar:  self
        Solipion-popup-Bar SetPopupBar: vga-bit-window
        ;M

:M On_Done:     ( h m w l -- res )
        0 call PostQuitMessage drop
        On_Done: super 0 ;M

:M WM_CLOSE     ( h m w l -- res )
        WM_CLOSE WM: Super bye 0 ;M

:M Refresh:     ( -- )
        Paint: vga-bit-window
        ;M

:M MinSize:     ( -- width height )     \ minimum window size
        StartSize: Solipion-Tool-bar1 >r StartSize max r> StartSize + ;M

:M StartSize:   ( -- width height )
        MinSize: self ;m

:M Start:       ( -- )
        CenterWindow: super SetOrigin: super
        Start: super
        ;m

:M WindowTitle: ( -- Zstring )          \ window caption
        z" SoliPion" ;M

:M ReTitle:     { \ title$ pad$ -- }
        MAXSTRING localAlloc: title$
        32 localAlloc: pad$
        pad 32 - pad$ 32 move           \ save PAD
        s" Solipion "                   title$  place
        s"         Score :  "           title$ +place
        counter  0 <# # # # #>          title$ +place
        s"         Best Score  :  "     title$ +place
        best     0 (ud,.)               title$ +place
        title$
        title$ count 255 min SetTitle: self
        pad$ pad 32 - 32 move           \ restore PAD
        ;M

:M On_EraseBackground: ( hwnd msg wparam lparam -- res )
        4drop 0 ;M \ let the On_Paint: Method redraw the background

:M On_Paint:    ( -- )

        On_Paint: super

        LTGRAY_BRUSH Call GetStockObject
        0 0
        StartSize: self drop width max
        StartSize: Solipion-Tool-bar1 nip SetRect: DemoRect
        DemoRect GetHandle: dc call FillRect ?win-error
        EraseRect: DemoRect


        StartSize: Solipion-Tool-bar1 swap 1+ swap  MoveTo: dc
        StartSize: Solipion-Tool-bar1 drop 1+ 0     LineTo: dc
        BLACK                                    LineColor: dc
        0 StartSize: Solipion-Tool-bar1 nip dup>r   MoveTo: dc
        StartSize: self drop width max r>           LineTo: dc
        StartSize: Solipion-Tool-bar1 over 0        MoveTo: dc

                                                    LineTo: dc
        ;M


\ the l parameter has already been removed by WINDOW.F, and put
\ into Height and Width

:M On_Size:     ( h m w -- )                  \ handle resize message

        0 0 StartSize: Solipion-Tool-bar1 Move: Solipion-Tool-bar1

        0 StartSize: Solipion-Tool-bar1 nip
        Width                                         dup to screen-width
        Height StartSize: Solipion-Tool-bar1 nip - 1- dup to screen-height

        Move: vga-bit-window

        Height Width min 20 / ( 128 min ) 8 max to step
        TRUE  to in-memory?
        TRUE  to size?
        FALSE to show?

        save-game re-open-game Unroll
        ;M

\ Mouse support connections from the applications window to the bitmapped
\ window that will actually receive the mouse clicks
:M SetClickFunc: ( cfa -- )
        SetClickFunc: vga-bit-window ;M

:M SetUnClickFunc: ( cfa -- )
        SetUnClickFunc: vga-bit-window ;M

:M SetDblClickFunc: ( cfa -- )
        SetDblClickFunc: vga-bit-window ;M

:M SetTrackFunc: ( cfa -- )
        SetTrackFunc: vga-bit-window ;M

\ All SC_xxxx command types always have the high nibble set to 0xF
:M WM_SYSCOMMAND ( hwnd msg wparam lparam -- res )
        over 0xF000 and 0xF000 <>
        IF   over LOWORD
             DoMenu: CurrentMenu 0
        ELSE DefWindowProc: [ self ]
        THEN ;M

;Object


\ ---------------------------------------------------------------
\ Demo about dialog, copied from the Forth About Dialog
\ ---------------------------------------------------------------

needs About.f

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

: temporizing ( -- )
        winpause?
        if   winpause
             tempo ms
        then ;

\ ---------------------------------------------------------------
\               New Game
\ ---------------------------------------------------------------

create coords
decimal
 8 c,  5 c,  9 c,  5 c, 10 c,  5 c, 11 c,  5 c,
11 c,  6 c, 11 c,  7 c, 11 c,  8 c, 12 c,  8 c,
13 c,  8 c, 14 c,  8 c, 14 c,  9 c, 14 c, 10 c,
14 c, 11 c, 13 c, 11 c, 12 c, 11 c, 11 c, 11 c,
11 c, 12 c, 11 c, 13 c, 11 c, 14 c, 10 c, 14 c,
 9 c, 14 c,  8 c, 14 c,  8 c, 13 c,  8 c, 12 c,
 8 c, 11 c,  7 c, 11 c,  6 c, 11 c,  5 c, 11 c,
 5 c, 10 c,  5 c,  9 c,  5 c,  8 c,  6 c,  8 c,
 7 c,  8 c,  8 c,  8 c,  8 c,  7 c,  8 c,  6 c,

create coords2 72 allot     \ for the thing

needs FileIO.f

font vfont
create string4$ cell allot

: TheSmallsDots  ( -- )

        LTGRAY  FillArea: solipion-dc          \
        BLACK  LineColor: solipion-dc
        BLACK   PenColor: solipion-dc          \
        WHITE BrushColor: solipion-dc          \

        step 3 / width: vfont
        step 3 / height: vfont
        s"  Courier " SetFaceName: vFont

        Create: vFont
        Handle: vFont SetFont: solipion-dc
        20 0
        do   i step * 1 - dx + step negate dy + 2 -  step 2 / FillCircle: solipion-dc
             i step * 1 - dx + step 4 / - step negate dy + 2 - step 4 / -
             1 string4$ c! ascii A i + string4$ 1 + c!
             string4$ count
             TexTout: solipion-dc

             step negate 2 - dx + i step * 1 - dy + step 2 / FillCircle: solipion-dc

             step negate 2 - dx + step 4 / -  i step * 1 - step 4 / - dy +
             i  1 + 0 <# #s #> TextOut: solipion-dc
        loop
        BLACK BrushColor: solipion-dc
        20 step * 1
        do   20 step * 1
             do   i 2 - dx + j 2 - dy + 2 FillCircle: solipion-dc                \ the smalls dots on the screen
             step +loop
        step +loop
        delete: vfont
        ;

TRUE  value showing?

: Couleur ( direction first last i -- )

        showing?                                                               \ if showing :

        if                                                                       \ color
             dup rot   = if 3drop
                                      LTGRAY LineColor: solipion-dc              \ Light side


                       else = if drop     BLACK LineColor: solipion-dc           \ Dark side

                              else
                               hypothesis?
                                  if      drop
                                         \ DKGRAY LineColor: solipion-dc          \  if hypothesis  DKGRAY
                                          LTYELLOW LineColor: solipion-dc
                                  else
                                        case                                     \  else case :
                                        1 of \ LTGREEN LineColor: solipion-dc             \ horizontal : LTGREEN
                                               LTBLUE  LineColor: solipion-dc             \ horizontal : LTBLUE
                                          endof
                                        2 of LTRED LineColor: solipion-dc               \ oblique : LTRED

                                          endof
                                        3 of \ LTGREEN LineColor: solipion-dc             \ vertical : LTGREEN
                                               LTBLUE  LineColor: solipion-dc             \ vertical : LTBLUE
                                          endof
                                        4 of  LTRED LineColor: solipion-dc               \ oblique  : LTRED

                                         endof
                                        endcase
                                  then
                              then
                       then
                                                                                \ IFNOT
        else 4drop                    LTGRAY LineColor: solipion-dc             \ LTGRAY (the color of the background)

        then
;

: Pawn  (  -- )
        TRUE to showing?

        tempo 0<> if 5 else 1 then                                                   \ within a loop
        0                                                                       \ to produce a blinking
        do                                                                      \
                showing?
                hypothesis?  or
                             if BLACK BrushColor: solipion-dc                   \ BLACK PAWN
                                  BLACK PenColor: solipion-dc

                             else
                                LTGRAY BrushColor: solipion-dc                   \ LTGRAY PAWN
                                LTGRAY PenColor: solipion-dc

                             then

                nRaw step * dx + nLine step * dy + step 4 /  1-  FillCircle: solipion-dc                                    \
                showing?
                IF
                        WHITE BrushColor: solipion-dc
                                                                                 \ the white reflect on the pawn
                        nRaw step * step 12 /  1 max -  dx +
                        nLine   step * step 12 /  1 max -  dy +
                        step 12 / 1 max FillCircle: solipion-dc
                        BLACK BrushColor: solipion-dc




                THEN
                Refresh: SOLIPIONW
                temporizing
                showing? 0= to showing?
        loop
        ;

: Cross       ( -- )

        tempo >r 0 to tempo
        72 0
        do
                 coords i    + c@ shift-x  +  to nRaw
                 coords i 1+ + c@ shift-y  + to nLine
                pawn

                -1 univers nLine 20 *  nRaw +  + c!
                2
                +loop
                r> to tempo
        ;

: Thing   ( -- )
        tempo >r 0 to tempo
        max-pawns 0
        do Same-Thing?
           if   coords2 i    + c@ to nRaw
                coords2 i 1+ + c@ to nLine
           else 8 random 6 + dup coords2 i    +  c! to nRaw
                8 random 6 + dup coords2 i 1+ +  c! to nLine
           then
           pawn
           -1 univers nLine 20 * nRaw + + c!
        2 +loop

        r> to tempo
        true to Same-Thing?
        ;


\ rank ( 1st,2nd,3rd,4th,5th pawn of the -line-  )
\ direction (  1 = west->east    2 = north-west->south-west
\              3 = north->south  4 = south-west->north-east  )
0 value clean?

: -LINE- {  row# line# rank# direction# \ last first -- }
    rank# 1- to rank#

    FALSE to showing?
    tempo 0<> if 5 else 1 then
    0 do
        showing? 0= to showing?
    4 0 do

    direction#
    case
    1 of
        step 8 / 1 max dup dup 1- to last negate dup to first
        do
            direction# last first i couleur
            row# rank# - j +    step * step i abs - 4 / + 1+ dx + line# step * i + dy + MoveTo: solipion-dc
            row# rank# - j + 1+ step * step i abs - 4 / - 1- dx + line# step * i + dy + LineTo: solipion-dc
        loop

    endof

    2 of
        step 4 / 5 max dup dup 1- to last 2 / dup to first
        do
            direction# last first i couleur
            row# rank# - j +     step *           i   + dx + line# rank# - j +    step * step 3 / i - +  dy + MoveTo: solipion-dc
            row# rank# - j +  1+ step * step 3 /  i - - dx + line# rank# - j + 1+ step *          i -    dy + LineTo: solipion-dc
        loop

    endof
    3 of
        step 8 / 2 max dup dup 1- to last negate dup to first
        do
            direction# last first i couleur
            row# step * i + dx + line# rank# - j +     step *  step i abs - 4 / + 1+ dy + MoveTo: solipion-dc
            row# step * i + dx + line# rank# - j + 1+  step *  step i abs - 4 / - 1- dy + LineTo: solipion-dc
        loop

        endof
    4 of
        step 4 / 5 max  dup dup 1- to last 2 / dup to first
        do
            direction# first last i couleur
            row# rank# - j +    step * step 3 / i - + dx + line# rank# + j -    step *          i -   dy + MoveTo: solipion-dc
            row# rank# - j + 1+ step * i -            dx + line# rank# + j - 1- step * step 3 / i - + dy + LineTo: solipion-dc
        loop

    endof
    endcase
    loop
        Refresh: SOLIPIONW
        temporizing
    loop
        ;

: (random)      ( u1 u2 -- u3 )
\ *G Returns a random number beetween u1 and u2 (including u1 and u2).
         over - random + 1+ ;

: New-Game (  --  )

        univers  400 erase
        univers1 400 erase
        univers2 400 erase
        univers3 400 erase
        univers4 400 erase

        0 to counter
        true to best?
        hypothesis? 0= if ReTitle: solipionw then
        TheSmallsDots

        random-board?
        if   Same-Thing? 0= if 36 72 (random) to max-pawns then Thing
        else Cross
        then ;

: 0max19min
        0 max 19 min ;

: @line { rank# direction# \ -- flag }
        5 0
        do
        direction#
        case
        1 of univers1 univers nLine                       20 *  nRaw rank# - i + 0max19min + dup  endof
        2 of univers2 univers nLine rank# - i + 0max19min 20 *  nRaw rank# - i + 0max19min + dup  endof
        3 of univers3 univers nLine rank# - i + 0max19min 20 *  nRaw                       + dup  endof
        4 of univers4 univers nLine rank# + i - 0max19min 20 *  nRaw rank# - i + 0max19min + dup  endof
        endcase
        rot + c@
        case

               -1 of 1 +to flag-1 endof
                0 of 1 +to flag0  endof
        endcase
            + c@
        case
                1 of 1 +to flag1  endof
                5 of 1 +to flagx  endof
        endcase
        loop

        flag-1 5 <            \ the pawns of the starting Cross are figured by : -1
        flag0  1 =     and    \ an empty cell (the pawn is not yet put)
        flag1  3 <     and    \ 0 , 1 or 2 pawns of ends of line , no more
        flagx  0 =     and    \ 0 pawn of middle
                              \ a -LINE- is showns in univers_x by   1 5 5 5 1
;                             \

: !line { rank# direction# \ -- }
        5 0
        do

        direction#
        case
                1 of univers nLine                       20 * nRaw rank# - i + 0max19min + +  endof
                2 of univers nLine rank# - i + 0max19min 20 * nRaw rank# - i + 0max19min + +  endof
                3 of univers nLine rank# - i + 0max19min 20 * nRaw                       + +  endof
                4 of univers nLine rank# + i - 0max19min 20 * nRaw rank# - i + 0max19min + +  endof
        endcase
        dup c@ dup -1 = swap 0= or
        over univers dup 400 + between and if direction# over c! then drop
        i 0 = i 4 = or if 1 else 5 then
        direction#
        case
                1 of univers1 dup nLine                       20 * nRaw rank# - i + + +  endof
                2 of univers2 dup nLine rank# - i + 0max19min 20 * nRaw rank# - i + + +  endof
                3 of univers3 dup nLine rank# - i + 0max19min 20 * nRaw             + +  endof
                4 of univers4 dup nLine rank# + i - 0max19min 20 * nRaw rank# - i + + +  endof
        endcase
        2dup swap dup 400 + between
        if   nip c!
        else 3drop
        then

        loop

;

: Playable? { \ rank# direction# ppointer  --  }
        busy? ?exit
        true to busy?

        table-of-possibilities to ppointer
        ppointer  40 erase
        0 to how-many?
        1 to direction#

        begin 0 to rank#
                begin
                        0 to flag-1 0 to flag0 0 to flag1 0 to flagx
                        rank# direction# @line
                if

                        rank#    1+  ppointer      c!
                        direction#   ppointer  1+  c!
                        2 +to ppointer

                then

                        1 +to rank# rank# 5 =

                until

                1 +to direction# direction# 5 =
        until

        ppointer  table-of-possibilities =
        if    false
        else  ppointer  table-of-possibilities - 2 / to how-many?
              true
        then
        false to busy?
;

: (Unroll) ( -- )
        unroll-busy?  ?exit
        true to unroll-busy?
        tempo >r size? if  0 to tempo false to winpause?
                       else show? dup if   false to in-memory? 100 to tempo
                                      then to winpause?
                       then
        New-Game

        moves 1- 0
        ?do
                size? if 0 to tempo false to winpause? then

                moves-table i cells+ dup    c@   to nRaw
                                         1+ c@   to nLine

                univers nLine 20 * + nRaw + c@ 0=
                if
                        moves-table i cells+ 2 + c@
                        moves-table i cells+ 3 + c@
                        2dup  swap 1- swap

                        !line
                        to direction
                        to rank
                        pawn
                        nRaw
                        nLine
                        moves-table i cells+ 2 + c@
                        moves-table i cells+ 3 + c@ dup
                        univers nLine 20 * + nRaw + c!
                        -LINE-
                        1 +to counter
                then

                moves 2 - i =
                if
                        hypothesis?  0= if ReTitle: solipionw  then
                        Refresh: SOLIPIONW
                        temporizing
                then
        loop
        r> to tempo
        0 to size?
        TRUE  to winpause?
        FALSE to show?
        false to unroll-busy?
        ;

' (Unroll) is Unroll

fload solidial

: .table-bests-scores  ( -- )
        dial-busy? ?exit
        true to dial-busy?
        true to rank-in-dial
        Start: solipion-dial

;

: (!bests) { \ rank# finish? safe-put-by?  -- }

        0 to rank#
        false to finish?
        put-by? to safe-put-by?

        begin
                counter bests-table rank# 22 * + 20 + w@ >

              if        bests-table rank# 22 * + dup 22 + 10 rank# - 22 * cmove>
                counter bests-table rank# 22 * + 20 + w!
                        bests-table 218 + w@ to best10
                        bests-table  64 + w@ to best3
                        best
                        bests-table  20 + w@ to best


            safe-put-by?
                        if
                          \ |------------------|
                         s"     SoliPion 2.0    " bests-table rank#  22 * + swap  cmove

                                false to put-by?

                        else    gameloaded? if drop exit then
                                rank# 1+ to rank-in-dial
                                Start: solipion-dial

                                best <
                                music?  and
                                if <<<applause>>>
                                then
                        then


                 0 to counter
                 TRUE to finish?
              then
              1 +to rank# rank# 10 =
              finish?  or
        until

        gameloaded? 0= if save-bests  then

;

' (!bests) is !bests

        0 value this-one?
        0 value oldx
        0 value oldy

: Game   { \  !there! safe-row safe-line -- }
        gamebusy? ?exit
        true to gamebusy?
        0 to this-one?

        auto?
        if      20 random to nRaw 20 random to nLine  true to put-by?
                TRUE
        else    StartPos: solipionw                     \ ( -- x y )
                solipion-dc  get-mouse-xy               \ ( -- x y x' y' )
                rot -                                   \ For the height needs to
                SM_CYMENU call GetSystemMetrics -       \ remove menu height
                SM_CYCAPTION call GetSystemMetrics -    \ remove caption height
                StartSize: solipion-tool-bar1 nip -     \ remove toolbar height
                dy - dup step / 0max 19 min dup to nLine
                step *  dup  step 2 / dup>r - swap  r@ + between ( -- x x' flag )
                -rot swap -  dx - dup step / 0max 19 min dup to nRaw
                step *  dup  r@                - swap  r> + between ( -- flag flag ) and
                false to put-by?
        then
        univers nLine 20 *  nRaw + + c@ 0=  and
        if
           Playable?
                if
                        nRaw to safe-row
                        nLine   to safe-line
                        0 to !there!
                        begin
                                how-many? 1 <> to hypothesis?

                                safe-row to nRaw
                                safe-line   to nLine
                                table-of-possibilities !there! 2* +     c@ to rank
                                table-of-possibilities !there! 2* + 1 + c@ to direction
                                pawn
                                safe-row safe-line rank direction -LINE-
                                music?  if <<<hypothesis>>> then
                                how-many? 1 <>
                                if
                                   tempo 100 + 0
                                     begin
                                        1 ms 1+ 2dup =

                                           key? if key 13 = dup if true to this-one?       false to auto? then  ( -- flag )

                                                else
                                                   auto? if \ tempo dup 2 + 5 * random swap 1+ = dup if true to this-one?       then  ( -- flag )
                                                            how-many? 1+ random 0= dup to this-one?
                                                         else false
                                                         then
                                                then
                                     or
                                     until
                                  2drop
                                else   true to this-one?

                                then

                                 this-one?
                                 if
                                        rank 1- direction !line
                                        false to hypothesis?
                                        tempo >r 0 to tempo
                                        pawn
                                        r> to tempo
                                        nRaw       moves-table counter cells+     c!
                                        nLine      moves-table counter cells+ 1 + c!
                                        rank       moves-table counter cells+ 2 + c!
                                        direction  moves-table counter cells+ 3 + c!
                                        counter 1+ to counter



                                        tempo >r 0 to tempo
                                        safe-row safe-line rank direction -LINE-
                                        r> to tempo
                                else
                                        true   to in-memory?
                                        false  to show?
                                        tempo >r 0 to tempo
                                        save-game
                                        false to hypothesis?
                                        re-open-game
                                        Unroll
                                        r> to tempo
                                        true to hypothesis?
                                        false to in-memory?
                                then

                                !there! 1+ to !there! !there! how-many? = if 0 to !there! then
                        this-one?
                        until

                                counter max-counter  max to max-counter



                        music?  if
                                        counter best3 >
                                        best?   and   if  yahoo-already? 0= if <<<yahoo>>>
                                                                               true to yahoo-already?
                                                                            then
                                                      else <<<ding>>>
                                                      then
                                 then

                        0 to empty-handed?
                        ReTitle: solipionw

                else auto? if 1 +to empty-handed?
                              empty-handed?  1000 >   if !bests
                                                      counter 50 >
                                                      if true to auto-save?
                                                        save-game-as
                                                        10 ms
                                                        false to auto-save?
                                                      then
                                                      0 to empty-handed?  'N' +k_Control pushkey
                                                      0 to max-counter
                                                      FALSE to auto?   'A' +k_Control pushkey
                                                   then

                           then
                then
        then

        false to gamebusy?

        ;

\ ---------------------------------------------------------------
\               Print the Positions of the Game (text)
\               Print the Bitmap of the Game
\ ---------------------------------------------------------------

needs Print.f

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

: ok_there!  ( --  )
        13 pushkey ;

: load-table-bests { \ best$ hfile -- }
        max-path LocalAlloc: best$
        S" solipion.dat" best$ place
        best$ count r/w open-file 0=
        if   to hfile
             smallstring 3 hfile read-file 2drop
             smallstring 3 s" SOL" compare 0=
             if
                   stamper  16 hfile read-file 2drop
               bests-table 220 hfile read-file 2drop
                               hfile close-file drop
               true to bests-in?
             else

               false to bests-in?

               bests-table 220 erase
             then
        else drop
             false to bests-in?
             bests-table 220 erase
        then
;


: initialisations       ( -- )
        cursor-off
        RANDOM-INIT

        256 malloc to smallstring
        256 malloc to string-player-name
                      string-player-name 20 blank
         16 malloc to stamper
        400 malloc to univers
        400 malloc to univers1
        400 malloc to univers2
        400 malloc to univers3
        400 malloc to univers4
       1000 malloc to moves-table
        242 malloc to bests-table
         40 malloc to table-of-possibilities


         0 to shift-x
         0 to shift-y
        10 to dx
        10 to dy
        TRUE to winpause?
        100  to tempo
        TRUE to music?
        0 to dial-busy?
        load-table-bests
        bests-table 20 + w@ to best
        bests-table 64 + w@ to best3
        false to auto?
        True to best?


        Start: SOLIPIONW
        StartPos: SOLIPIONW 50 + swap 50 + swap message-origin

        ['] ok_there! SetClickFunc: SOLIPIONW     \ execute ok_there! if left-klick
        ['] ok_there! SetDblClickFunc: SOLIPIONW  \ execute ok_there! if double-klick

        StartPos: SOLIPIONW StartSize: SOLIPIONW Move: SOLIPIONW
        ;

\ ---------------------------------------------------------------
\       The Beginning
\ ---------------------------------------------------------------

: SOLIPION       ( -- )
        initialisations

        BEGIN
                size? if save-game re-open-game then

                auto? if ekey? if    ekey
                               else  13
                               then
                      else ekey
                      then

                case
                                    13  of                           Game  endof
                'A'         +k_control  of                   <<<bleep1>>>
                                                        auto? 0= to auto?
                                                       auto? 0= to music?
                                                                           endof
                'W'         +k_control  of                   <<<bleep1>>>
                                                     music?  0= to music?  endof
                'N'         +k_control  of                   <<<bleep1>>>
                                                                   !bests
                                            false to Same-Thing? New-Game

                                                                           endof
                'O'         +k_control  of                   <<<bleep1>>>
                                                                open-game
                                                                   Unroll  endof
                'R'         +k_control  of                   <<<bleep1>>>
                                                             re-open-game
                                                                   Unroll  endof
                'E'         +k_control  of                   <<<bleep1>>>
                                                                save-game  endof
                'S'         +k_control  of                   save-game-as  endof
                'Q'         +k_control  of            <<<bleep1>>> !bests
                                                                      BYE  endof
                k_F1        +k_control  of                   <<<bleep1>>>
                                                           about-solipion  endof
                k_esc                   of                   <<<bleep1>>>
                                                                 New-Game  endof
                k_esc       +k_control  of                   <<<bleep1>>>
                                                                      BYE  endof
               'P' +k_control +k_shift  of                   <<<bleep1>>>
                                                     GetHandle: SOLIPIONW
                                                        Setup: ThePrinter  endof
                'T'         +k_control  of                     print-game  endof
                'B'         +k_control  of                   <<<bleep1>>>
                                                        16 print-demo-bmp  endof
                k_left      +k_control  of                   <<<bleep1>>>
                                                       true to in-memory?
                                                  step 8 - 8 max to step
                                                            true to size?

                                                   'E' +k_control pushkey
                                                   'R' +k_control pushkey  endof

                k_right     +k_control  of                   <<<bleep1>>>
                                                       true to in-memory?
                                                         step 8 + to step
                                                            true to size?
                                                   'E' +k_control pushkey
                                                   'R' +k_control pushkey  endof

                k_scroll    +k_control  of counter  1-    0 max to counter
                                                        true to in-memory?
                                                        tempo
                                                    'E' +k_control pushkey
                                                    'R' +k_control pushkey
                                                        to tempo           endof

                k_pgdn      +k_control  of counter 1+     max-counter  min       \ no more than max-counter
                                                                   364 min       \ max  to ( 20 20 * 36 pions - )
                                                                to counter
                                                        true to in-memory?
                                                        tempo
                                                    'E' +k_control pushkey
                                                    'R' +k_control pushkey
                                                        to tempo           endof

                k_up        +k_control  of                    <<<bleep1>>>
                                              tempo 50 +  200 min to tempo endof
                k_down      +k_control  of                    <<<bleep1>>>
                                              tempo 50 -    0 max to tempo endof
                 'H'        +k_control  of                    <<<bleep1>>>
                                                      true to rank-in-dial
                                                      Start: solipion-dial endof
                k_left      +k_shift    of    -8 +to dx
                                              'E' +k_control pushkey
                                              'R' +k_control pushkey       endof

                k_right     +k_shift    of     8 +to dx
                                               'E' +k_control pushkey
                                               'R' +k_control pushkey      endof
                k_up        +k_shift    of    -8 +to dy
                                              'E' +k_control pushkey
                                              'R' +k_control pushkey       endof
                k_down      +k_shift    of     8 +to dy
                                              'E' +k_control pushkey
                                              'R' +k_control pushkey       endof
                endcase

        AGAIN
        ;


: solipon-main ( -- )  \ do further custom console initialization
         \ do further custom console initialization
         menu-off                        \ close menubar
         HideStatusBar: ConsoleWindow    \ close the statusbar
         \ init-screen                   \ show console

         SOLIPION ;                      \ and run our app


turnkey? [if]  \ ekey and pushkey can only be used in SAVEd progamms

        \ Create the exe-file
        &forthdir count &appdir place
        ConsoleHiddenBoot  \ Hide the console
	' solipion SAVE Solipion.exe

        \ add the resources to the exe file
version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]
                &forthdir count pad place
                s" Solipion.exe" pad +place
                pad count "path-file drop AddToFile

                CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST s" Solipion.exe.manifest" "path-file drop  AddResource
                101 s" src\res\Win32For.ico" "path-file drop AddIcon

                false EndUpdate

        [else]  \ For V6.xx.xx older OSs
                s" src\res\Win32For.ico" s" Solipion.exe" Prepend<home>\ AddAppIcon
        [then]
        Require Checksum.f
        s" Solipion.exe" prepend<home>\ (AddCheckSum)

        1 pause-seconds bye
[else]
        s" src\res\Win32For.ico" s" Solipion.exe" Prepend<home>\ AddAppIcon
        solipion
[then]

