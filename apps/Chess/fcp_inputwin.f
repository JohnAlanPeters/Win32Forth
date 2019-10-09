anew  fcp_inputwin.f   \ Game window   September 20th, 2002 - 21:28

needs FCP131wf32.f \ The chess engine from http://www.quirkster.com/iano/forth/FCP.html
needs opengl.f     \ Basic OpenGL binding to Win32Forth. Includes a brief explanation
needs fcp3d.f      \ OpenGL Graphics for the game
needs fullscreen.f \ Switch to fullscreen or window


true value mbook-on/off
1 value test

: ogl-new       ( - )
        cls newGame mbook-on/off not
                if    bookoff
                then
       move-board-to-3D-board
;

: .ok           ( - )            ."  ok" ;

menubar Openglmenu              \ Customize the menu
 needs MenuFileChess.f               \ Load the menu file
 needs MenuOgl.f                \ Load the other menus
endbar

needs oglwin.f     \ OpenGL window

true value tscp-black-on/off
defer refresh-cmd-window

0 value thinking
: .stop-box   { \ title$ message$ -- }  ( adr2 len2 adr1 len1  - )
 [ MB_OK MB_ICONHAND or MB_TASKMODAL or ] literal msgbox&title drop ;

: .bad-move    ( adr count - )
  s" Fcp3D:" 2swap .stop-box   0 to thinking  refresh-cmd-window  abort ;

: str>mv-ogl ( str count -- str' count' mv )
  OVER str>sq 0= IF  s" Malformed move." .bad-move  THEN
  >R 2 /STRING OVER str>sq 0= IF  s" Malformed move." .bad-move THEN
  R> findFromTo DUP 0= IF s" Illegal move." .bad-move THEN
  >R 2 /STRING R> ?promoteMv @ ;

: domove-ogl ( "e2e4" -- )  \ for forcing a sequence of moves
  str>mv-ogl ?dup IF
    makeBookMove makeMove IF .board .result? DROP
    ELSE CR ." Can't move there." THEN
  THEN ;


: _whoseTurn-ogl ( turn - turn )
    dup not to tscp-black-on/off refresh-cmd-window ;

' _whoseTurn-ogl is .whoseTurn-ogl

: random-first-move-white ( - adr cnt )
   9 random-wf32
     case
     1  of    s" b2b3"  endof
     2  of    s" c2c4"  endof
     3  of    s" d2d4"  endof
     4  of    s" f2f4"  endof
     5  of    s" g2g3"  endof
     6  of    s" b1c3"  endof
     7  of    s" g1f3"  endof
        s" e2e4"  rot
     endcase
     domove-ogl
 ;

: random-first-move-black ( - adr cnt )
   8 random-wf32
     case
     1  of    s" b7b6"  endof
     2  of    s" c7c5"  endof
     3  of    s" d7d5"  endof
     4  of    s" f7f5"  endof
     5  of    s" g7g6"  endof
     6  of    s" b8c6"  endof
     7  of    s" g8f6"  endof
        s" e7e5"  rot
     endcase
     domove-ogl
 ;

1 value m#1black-random-on/off
1 value m#Enable-random-move-on/off
1 value mEndless-autoplay-on/off
5 value ply-black
5 value ply-white
10 value sec-black
10 value sec-white

: mv_ogl ( move$ count -- )    \ for alternating turns with the computer
   str>mv-ogl ?dup
      if  makeBookMove makemove            \ if promoting:  "a7a8q"
            if  .board .result? 0=
                  if   wtm?
                           if     ply-white
                           else   ply-black
                           then
                       sd go
                  then
            else cr ." can't move there."
       then
  then
 ;

: white-move ( move$ count -- )  \ for forcing a sequence of moves
   str>mv-ogl ?dup
        if  makemove
              if    .board .result? drop  ply-white sd go
              else  cr ." can't move there."
              then
  then ;

: tscp-plays-white
    wtm? not
          if    white-move
          then
 ;


: move-from-window ( adr count - adr )
   dup 0=
      if 2drop
      else    tscp-black-on/off
              if     mv_ogl
              else   tscp-plays-white
              then
     then
 ;

: ply-black-or-white ( - ply )
   wtm?
     if ply-white
     else ply-white
     then
 ;

: y/n-box  ( adr2 len2 adr1 len1  - button )
    [ MB_YESNO MB_ICONQUESTION or MB_TASKMODAL or ] literal msgbox&title ;

: hint
   ply-black-or-white sd go
   s" Hint completed" s" Do you agree ? " y/n-box  IDNO =
     if   undo
     else  ply-black-or-white sd go
     then
 ;

: ?resume ( seconds -- true/false )
                true swap 30 min 1 max 10 * 0
                ?do     100 ms
                        key?
                        if
                                key   k_ESC =
                                if    drop  false
                                then
                        then
                loop    ;


: auto-ogl ( by-depth- - )
   locals| by-depth- |
     begin
       first-move?
          if  m#Enable-random-move-on/off
                   if random-first-move-white
                   then
              m#1black-random-on/off
                   if  1000 ms random-first-move-black
                   then
          then
      true to thinking refresh-cmd-window
      by-depth-
         if    65000 st ply-white 2 max ply-black 2 max autodepth
         else  MAX_PLY sd sec-white sec-black autoTime
         then
       mEndless-autoplay-on/off
       if   21 ?resume dup
             if    ogl-new
             then  not
       else true
       then
     until
   false to thinking refresh-cmd-window
     wtm? inCheck? reps 3 = or fifty 50moveCount = or not
       if   wtm? not tscp-black-on/off and undo
       then
   true to mbook-on/off

 ;

\ Bigger values are possible.
NewEditDialog dialog-ply-black "Ply depth black" "Enter a number between 2 and 16" "Ok"   ""  ""
NewEditDialog dialog-ply-white "Ply depth white" "Enter a number between 2 and 16" "Ok"   ""  ""

: enter-ply  ( ply color  - value )
    >r buffer dup rot val>$ oglwin-base r>
          if     Start: dialog-ply-white
          else   Start: dialog-ply-black
         then not
    abort" Stop. The ply depth is not changed."
    buffer count number? not
    abort" Bad number.  No change of the ply depth." d>s
 ;


NewEditDialog dialog-sec-black "Maximum seconds for black" "Enter a number > 1" "Ok"   ""  ""
NewEditDialog dialog-sec-white "Maximum seconds for white" "Enter a number > 1" "Ok"   ""  ""

: enter-sec  ( ply color  - value )
    >r buffer dup rot val>$ oglwin-base r>
          if     Start: dialog-sec-white
          else   Start: dialog-sec-black
         then not
    abort" Stop. The timel imit is not changed."
    buffer count number? not
    abort" Bad number.  No change of the time limit." d>s
 ;


: interrupt-autoplay ( - )
    ascii q to keyHit
    false to mEndless-autoplay-on/off
 ;

: generate-move ( - )
    first-move?
      if    random-first-move-white
      else  ply-black-or-white sd go
      then
 ;


MenuBar chess_menu
 popup "Chess"
                  :menuitem mnew  "A new game"          ogl-new ;
   MENUSEPARATOR
                  :menuitem mhint "Hint"                hint ;
                  :menuitem mundo "Undo"                undo2 ;
   MENUSEPARATOR
                  :menuitem mauto-s "Start auto play limited by play-depth"  true auto-ogl ;
                  :menuitem mauto-d "Start auto play limited by time" false  auto-ogl ;
                   menuitem       "Interrupt auto play" interrupt-autoplay ;
   MENUSEPARATOR
                   menuitem       "Exit"                bye ;

popup "Options"
       :menuitem mblack  "Tscp plays black"
             tscp-black-on/off not to tscp-black-on/off generate-move ;
       :menuitem mrotateBoard "Rotate Board" rotateBoard  ;
   MENUSEPARATOR
       :menuitem mply-white  "Ply depth for white"
             ply-white true enter-ply to ply-white  ;
       :menuitem mply-black  "Ply depth for black"
             ply-black false enter-ply to ply-black ;

       :menuitem msec-white  "Time limit for white"
             sec-white true enter-sec to sec-white  ;
       :menuitem msec-black  "Time limit for black"
              sec-black false enter-sec to sec-black ;

   MENUSEPARATOR
   :menuitem mbook  "Opening book"
              mbook-on/off not to mbook-on/off ;

       :menuitem m#1black-random  "Random first move black"
             m#1black-random-on/off not to m#1black-random-on/off  ;

       :menuitem m#Enable-random-move  "Random first move white"
             m#Enable-random-move-on/off not to m#Enable-random-move-on/off  ;

       :menuitem mEndless-autoplay  "Endless autoplay"
             mEndless-autoplay-on/off not to mEndless-autoplay-on/off  ;
 endbar



:OBJECT inputwindow <Super DialogWindow

  EditControl Edit_1     \ an edit window
StaticControl Text_1     \ a static text window
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button

:M WindowHasMenu: ( -- flag )    TRUE            ;M
:M WindowTitle: ( -- title )  z" Chess commands" ;M

:M StartSize:   ( -- width height )
                230 60 ;M

:M StartPos:    ( -- x y )
                3 3 ;M

:M On_Init:     ( -- )
                On_Init: super
                self               Start: Edit_1
                3 22  60 25         Move: Edit_1
                s" "             SetText: Edit_1
                IDOK               SetID: Button_1
                self               Start: Button_1
                110 22 36 25        Move: Button_1
                s" OK"           SetText: Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                SetStyle: Button_1
                 chess_menu  SetMenuBar: self
                ;M

:M On_Paint:    ( -- )
                tscp-black-on/off        Check: mblack
                m#1black-random-on/off   Check: m#1black-random
                mbook-on/off             Check: mbook
                m#Enable-random-move-on/off Check: m#Enable-random-move
                mEndless-autoplay-on/off Check: mEndless-autoplay
                        thinking 0= dup enable: mnew
                                    dup enable: mhint
                                    dup enable: mundo
                                    dup enable: mauto-d
                                    dup enable: mauto-s
                                    dup enable: mply-white
                                    dup enable: mply-black
                                    dup enable: msec-white
                                    dup enable: msec-black
                                    dup enable: mrotateBoard
                                        enable: mblack
                ;M

:M Close:       ( -- )
                 Close: SUPER
                 bye
                ;M

:M Refresh: ( - )
                ReDrawMenu: CurrentMenu
                self paint: self
                drop
                  ;M

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )
                over LOWORD ( ID )
                IDOK =
                   if    true to thinking
                         GetText: Edit_1
                         move-from-window
                         s" " SetText: Edit_1           \ Clear Edit_1
                         .last-move
                         false to thinking
                   else   swap dup   DoMenu: CurrentMenu
                   then
                paint: self
                drop
                0 ;M

;OBJECT

: start-opengl-chess  ( - )  load-bitmaps Start: OpenGLWindow  Start: inputwindow newGame ;
: close-OpenGLWindow  ( - )  Close: OpenGLWindow ;
: _refresh-cmd-window ( - )  Refresh: inputwindow ; \ updates the menu + window

' _refresh-cmd-window is refresh-cmd-window
