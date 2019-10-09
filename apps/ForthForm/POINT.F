\ Point.f

anew -point.f

\ define point class
:Class ffPoint    <Super Object

Record: xy
        int x
        int y
;Record

:M Erase:       ( -- )
                0 to x
                0 to y
                ;M

:M ClassInit:   ( -- )
                ClassInit: super
                Erase: self
                ;M

:M SetPoint:    ( x y -- )
                to y to x
                ;M

:M GetPoint:    ( -- x y )
                x y
                ;M

:M AddrOf:      ( -- xy )
                xy ;M

;Class
\s
