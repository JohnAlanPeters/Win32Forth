\ $Id: CalendarDemo.f,v 1.2 2013/11/29 14:43:29 georgeahubert Exp $

\ Simple calendar G.Hubert Tuesday, May 08 2007

Require calendar.f

anew -CalendarDemo

:Object DemoWindow <super window

MonthCalendar MyCalendar

:m On_Init: ( -- )
         self Start: MyCalendar
           AutoSize: MyCalendar ;m \ Make Calendar fill window

:M MinSize:     ( -- width height )
           MinSize: MyCalendar ;m \ Limit minimum size to 1 month

:m On_Size:      ( -- )
           AutoSize: MyCalendar ;m \ Resize Calendar to window

:m On_Done:  ( -- )
           TURNKEYED? if 0 call PostQuitMessage drop then
           On_Done: Super ;

;object

: Demo ( -- )  Start: DemoWindow  ;

: Undemo ( -- ) Close: DemoWindow ;

Demo

