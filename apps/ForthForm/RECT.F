\ Rect.f
\ Define general purpose object for drawing and erasing rectangles (boxes).

comment:
These routines to draw and erase a rectangle makes use of the Xor function.
The results look better on hi-color systems. An array could be used to store
the pixels for the drawing and erasing, which would work good on any color
system. But...

September 9th, 2003 - 22:18- Why didn't somebody tell me about the WinAPI
SetROP2 function? That function makes drawing rectangles on an image sooo
simple.

Comment;

anew -rect.f

:Class Rect             <Super Rectangle

int linewidth
int thedc
int drawmode
int drawcolor
ColorObject DotColor


:M ClassInit:   ( -- )
                ClassInit: super
                0 to thedc
                BLACK to drawcolor
                R2_NOT to drawmode      \ inverse drawing by default
                Color: BLACK NewColor: DotColor
                PS_DOT Put: DotColor.PenStyle
                InitColor: DotColor
                ;M

:M SetDrawColor: ( color -- )
                 to drawcolor ;M

:M GetDrawColor: ( -- color )
                 drawcolor ;M

:M SetDrawMode:  ( mode -- )
                to drawmode ;M

:M GetDrawMode: ( -- mode )
                drawmode ;M

:M SetDC:       ( dc -- )
                to thedc
                drawmode SetRop2: TheDC drop  \ set inverse line mode
                ;M

: drawrectangle ( -- )
                left top     Moveto: thedc
                right top    Lineto: thedc
                right bottom Lineto: thedc
                left bottom  Lineto: thedc
                left top     Lineto: thedc ;

:M DrawNormal:       ( -- )
               thedc
               if      drawcolor LineColor: thedc
                       drawrectangle
               then    ;M
               
:M DrawDotted: ( -- )
               drawcolor drawmode   2>r
               R2_COPYPEN  	( R2_NOTCOPYPEN	) SetRop2: thedc drop
               Addr: DotColor to drawcolor
               DrawNormal: self
               2r> to drawmode to drawcolor
               ;M

:M Sunken:      { color1 color2 -- }
                thedc
                if      R2_COPYPEN SetROP2: TheDC to drawmode
                        color1       LineColor: thedc
                        Left Bottom    MoveTo: thedc       \ dc must be valid
                        Left Top       LineTo: thedc
                        Right Top      LineTo: thedc
                        color2      LineColor: thedc
                        Right Bottom   LineTo: thedc
                        Left Bottom    LineTo: thedc
                        drawmode SetROP2: TheDC drop    \ restore
                then    ;M

:M PushButton:  ( -- )
                WHITE BLACK Sunken: self
                Left 1+ Top 1+ Right 1- Bottom 1- LTGRAY FillArea: thedc
                ;M

:M DrawFilled:  { fillcolor -- }
                Left Top Right Bottom fillcolor FillArea: thedc
                DrawNormal: self
                ;M

:M NoBorderFilled:      { fillcolor -- }
                        drawcolor       \ save
                        fillcolor to drawcolor
                        fillcolor DrawFilled: self
                        to drawcolor    \ restore
                        ;M
;Class
\ Rect Box        \ create instance

\s
