\ GCLOCK.SEQ  A simple Graphic Clock program  by Tom Zimmer & Robert Smith
\
\ Mostly rewritten by Dirk Busch (Sonntag, April 20 2008)

only forth also definitions

needs Resources.f
needs lib\BitmapDC.f
needs lib\TimerWindow.f

false value turnkey?

\ ---------------------------------------------------------------
\ line-dc - Device context class for simple line drawing
\ ---------------------------------------------------------------

:class line-dc <super bitmap-dc
\ *G Bitmap device context class for easy line drawing.

int prev-x
int prev-y

:M ClassInit:   ( -- )
                ClassInit: super
                -1 to prev-x -1 to prev-x ;M

: point-clip    ( x1 y1 -- x2 y2 )
                0 max bitmap-height min swap
                0 max bitmap-width  min swap
                ;

: new-point-chk ( x y -- x y true | false )
                point-clip
                over prev-x = over prev-y = and
                if   2drop false ( don't draw )
                else 2dup to prev-y
                     to prev-x true ( do draw )
                then ;

: moveto        ( x y -- )
                new-point-chk if MoveTo: super then ;

: lineto        ( x y -- )
                new-point-chk if LineTo: super then ;

:m Line:        ( x1 y1 x2 y2 -- )
\ *G Draw a line from x1,y1 to x2,y2.
                Valid?: super
                if   2swap moveto lineto
                else 4drop
                then ;m

:m LineColor:   ( color_object -- )
\ *G Set the color for the next line.
                Valid?: super if LineColor: super else drop then ;m

;class

\ ---------------------------------------------------------------
\ Define the AnalogClock child window class
\ ---------------------------------------------------------------

:Class AnalogClockChildWindow  <super child-window

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

  line-dc Circle-DC
  line-dc Clock-DC
bitmap-dc Paint-DC

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

create sintbl
          0 ,    25 ,    49 ,    74 ,    97 ,   120 ,   141 ,   160 ,
        178 ,   194 ,   207 ,   219 ,   228 ,   234 ,   238 ,   240 ,
        238 ,   234 ,   228 ,   219 ,   207 ,   194 ,   178 ,   160 ,
        141 ,   119 ,    97 ,    74 ,    49 ,    25 ,     0 ,   -25 ,
        -49 ,   -74 ,   -97 ,  -120 ,  -141 ,  -160 ,  -178 ,  -194 ,
       -207 ,  -219 ,  -228 ,  -234 ,  -238 ,  -240 ,  -238 ,  -234 ,
       -228 ,  -219 ,  -207 ,  -194 ,  -178 ,  -160 ,  -141 ,  -119 ,
        -97 ,   -74 ,   -49 ,   -25 ,     0 ,    25 ,    49 ,    74 ,
         97 ,   120 ,   141 ,   160 ,   178 ,   194 ,   207 ,   219 ,
        228 ,   234 ,   238 ,   240 ,   238 ,

: sin           ( deg -- x )
                60 mod sintbl +CELLS @ ;

: cos           ( deg -- y )
                15 + sin negate ;

0 value center-x
0 value center-y
0 value scale-y

:M SetCenter-x: ( n -- )
                to center-x ;M

:M SetCenter-y: ( n -- )
                to center-y ;M

: >screenx      ( n1 -- n2 )
                Width: super 480 */ ;

: >screeny      ( n1 -- n2 )
                Width: super 480 */ ;

: roundup       ( x sx -- x' )
                swap 1 and + ;

: xy-scale      ( 6deg scale -- x1 y1 )
                >r
                dup  sin >screenx dup r@  center-x */ roundup center-x +
                swap cos >screeny dup r>   scale-y */ roundup center-y + ;

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

 0 value this-hour
 0 value this-minute
 0 value this-second

: cxy           center-x center-y ;
: inner         20 xy-scale ;
: outer         center-x 20 - xy-scale ;
: innersc       center-x  3 / xy-scale ;
: outermin      center-x dup 10 / - xy-scale ;
: outerhr       center-x  2/  xy-scale ;

: .sec          ( sec -- )
                >r
                cxy r@ outer line: Clock-DC
                r@ 1-  inner r@ outer line: Clock-DC
                r@ 1+  inner r@ outer line: Clock-DC
                cxy r@ 1- inner line: Clock-DC
                cxy r@ 1+ inner line: Clock-DC
                r>drop ;

: .min          ( min -- )
                >r
                cxy r@ outermin line: Clock-DC
                r@ 1-  innersc r@ outermin line: Clock-DC
                r@ 1+  innersc r@ outermin line: Clock-DC
                cxy r@ 1- innersc line: Clock-DC
                cxy r@ 1+ innersc line: Clock-DC
                r>drop ;

: .hr           ( hr -- )
                >r
                cxy r@ outerhr line: Clock-DC
                r@ 2 -  innersc r@  outerhr line: Clock-DC
                r@ 2 +  innersc r@  outerhr line: Clock-DC
                cxy r@ 2 - innersc line: Clock-DC
                cxy r@ 2 + innersc line: Clock-DC
                r>drop ;

: .second       ( -- )          \ draw second display
                white LineColor: Clock-DC
                this-second 60 mod .sec ;

: .minute       ( -- )          \ draw minute display
                ltgreen LineColor: Clock-DC
                this-minute 60 mod .min ;

: .hour         ( -- )          \ draw hour  display
                ltblue LineColor: Clock-DC
                this-hour 5 * this-minute 12 / + 60 mod .hr ;

: GetCurrenTime ( -- )
                get-local-time
                time-buf 12 + w@ TO this-second \ seconds
                time-buf 10 + w@ TO this-minute \ minutes
                time-buf  8 + w@ TO this-hour   \ hours
                ;

: show-hms      ( -- )
                BLACK Fill: Clock-DC \ erase the display bitmap
                .second         \ draw second
                .minute         \ draw minute
                .hour           \ draw hour
                ;

: show-time     ( -- )
                GetCurrenTime show-hms ;

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

16 value cdiam
 0 value ccolor

create colors
        DKGRAY ,        RED ,           LTRED ,         GREEN ,
        LTGREEN ,       BLUE ,          LTBLUE ,        YELLOW ,
        LTYELLOW ,      MAGENTA ,       LTMAGENTA ,     CYAN ,
        LTCYAN ,        GRAY ,          WHITE ,         LTGRAY ,

: >color        ( n1 -- color_object )
                15 and colors +cells @ ;

: next-color    ( -- color_object )
                1 +TO ccolor ccolor >color ;

: show-circle   ( -- )
                next-color LineColor: Circle-DC

                60 0
                DO   \ draws dots (lines 1 pixel long)
                     I cdiam xy-scale 2dup 1+ swap 1+ swap line: Circle-DC
                LOOP 5 +TO cdiam

                cdiam center-x 30 - >
                IF   16 TO cdiam
                THEN ;

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

: show-border   ( -- )
                60 0
                do   white LineColor: Circle-DC
                     i center-x  1-  xy-scale i 1+ center-x  1-  xy-scale line: Circle-DC
                     i center-x 12 - xy-scale i 1+ center-x 12 - xy-scale line: Circle-DC
                     i 5 mod
                     if   ltcyan LineColor: Circle-DC \ 1 second markers
                          i center-x 12 - xy-scale i center-x 1- xy-scale line: Circle-DC
                     else yellow LineColor: Circle-DC \ 5 second markers
                          i center-x 20 - xy-scale i center-x 1- xy-scale line: Circle-DC
                     then
                loop ;

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

: ReInitDC      ( -- )
                get-dc

                GetSize: super dc Init: Circle-DC
                GetSize: super dc Init: Clock-DC

                release-dc

                white LineColor: Circle-DC \ default color=white
                white LineColor: Clock-DC  \ default color=white
                ;

:m On_Size:     ( -- )

                16 to cdiam
                 0 to ccolor

                Width:  super 2/ 1- TO center-x
                Height: super 2/ 1- TO center-y          \ calibrate screen center
                center-x center-x center-y */ TO scale-y \ calibrate aspect ratio

                ReInitDC

                show-border \ draw the border
                ;M

:m Refresh:     ( -- )
                IsVisible?: super
                if   show-circle
                     show-time
                     Paint: self
                then ;M

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------

:M On_EraseBackground: ( hwnd msg wparam lparam -- res )
                4drop 0 ;M \ let the On_Paint: Method redraw the background

:M On_Paint:    ( -- )

                \ first init our paint device
                \ (DC is the current device context of this window)
                GetSize: super DC Init: Paint-DC

                \ draw the background
                SRCCOPY                 \ blitmode
                ps_left ps_top          \ sourcex,y
                Circle-DC               \ sourcedc
                ps_right ps_bottom      \ sizex,y
                ps_left ps_top          \ destinationx,y
                BitBlt: Paint-DC

                \ and the foreground
                SRCPAINT                \ blitmode
                ps_left ps_top          \ sourcex,y
                Clock-DC                \ sourcedc
                ps_right ps_bottom      \ sizex,y
                ps_left ps_top          \ destinationx,y
                BitBlt: Paint-DC

                \ than draw both into our window
                ps_left ps_top
                ps_right ps_bottom
                DC Paint: Paint-DC

                \ don't forget to destroy our paint device
                Destroy: Paint-DC
                ;M

:M On_Done:     ( -- )
                Destroy: Circle-DC
                Destroy: Clock-DC
                On_Done: super
                ;M

;Class

\ ---------------------------------------------------------------
\ Define the main window class
\ ---------------------------------------------------------------

:Object WinClock  <super timer-window

AnalogClockChildWindow ClockWindow

:M StartSize:   ( -- width height )     \ starting window size
                360 360 ;M

:M StartPos:    ( -- x y )              \ starting postion on screen
                CenterWindow: Self ;M

:M MinSize:     ( -- width height )     \ minimum window size
                100 100 ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" WinClock" ;M

:M On_Init:     ( -- )                  \ initialize the class
                On_Init: super               \ first init super class
                2    SetId: ClockWindow      \ then the child window
                self Start: ClockWindow      \ then startup child window
                ;M

:M On_Done:     ( -- )          \ things to do before program termination
                On_Done: super
                turnkey? if 0 call PostQuitMessage drop then
                ;M

:M Start:       ( -- )
                Start: super
                200 CreateTimer: super \ init timer to a 200 ms rate
                ;m

:M On_Size:     ( -- )                  \ handle resize message
                0 0 Width Height Move: ClockWindow ;M

:M On_Timer:    ( -- )                  \ handle the timer events
                Refresh: ClockWindow ;M

;Object

\ ---------------------------------------------------------------
\ Top Level program starts here
\ ---------------------------------------------------------------

: Main          ( -- )
                Start: WinClock
                turnkey? if MessageLoop bye then ;

turnkey? [if]

        \ Create the exe-file
        &forthdir count &appdir place
        ' Main turnkey WinClock.exe

        \ add the Application icon to the EXE file
        s" src\res\Win32For.ico" s" WinClock.exe" Prepend<home>\ AddAppIcon

        1 pause-seconds bye
[else]
        s" src\res\Win32For.ico" s" WinClock.exe" Prepend<home>\ AddAppIcon
        Main
[then]
