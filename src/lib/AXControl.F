\ $Id: AXControl.F,v 1.5 2006/06/29 10:14:14 georgeahubert Exp $

\ ActiveX Control Class
\ Thomas Dixon

\ *D doc\classes\
\ *! AXControl
\ *T AXControl -- Base class for ActiveX controls

\ *P AXControl is a class that can be treated like any other control in
\ ** win32forth, except it is enabled to host an activex component. A short
\ ** example of it's usage:

\ *P window win         \n
\ ** start: win         \n
\ ** axcontrol ax       \n
\ ** win start: ax      \n
\ ** s" MSCAL.Calendar" axcreate: ax    \n
\ ** autosize: ax

\ *P The example here hosts a calandar control by it's progid.
\ ** In order to see this work properly, you need to have that activex
\ ** control installed on your machine.  ProgID's may also have some
\ ** version control to them. "MSCAL.Calendar.7" as the progid would
\ ** only host version 7 of the caladar control.
\ *P You may also use the string of the clsid that you want to use instead of
\ ** the progid, if it suits your purposes better.  Ex:
\ *P s" {8E27C92B-1264-101C-8A2F-040224009C02}" axcreate: ax    \n
\ ** autosize: ax
\ *P You may also use a url if you want:                        \n
\ ** s" http://www.google.com" axcreate: ax                     \n
\ ** autosize: ax
\ *P You may also give it html code, if it is proceeded by "MSHTML:"  Ex:  \n
\ ** s" MSHTML:<HTML><BODY>Hello World!</BODY></HTML>" axcreate: ax   \n
\ ** autosize: ax  \n
\ *P Just having the control there is nice, but the REAL trick is to
\ ** communicate with it and exchange data back and forth.  The way that
\ ** this is done is by  getting the control's interface and using it.

\ *S Glossary

anew -AXControl.F

needs fcom

winlibrary atl.dll

4 proc AtlAxCreateControl
2 proc AtlAxGetControl


:CLASS AXControl                <SUPER CHILD-WINDOW
\ *G AXControl Base class for ActiveX controls

:M AXUCreate: ( ustr -- )
\ *G calls unicode creation function
        0 0 rot hwnd swap AtlAxCreateControl abort" Unable to Create ActiveX Control!"
        ;M

:M AXCreate:  ( str len -- )
\ *G Initialize the ActiveX control
        1+ asc>uni over + 0 swap 2 - w!  dup>r
        AXUCreate: self
        r> free drop
        ;M

:M QueryInterface:    ( ppv riid -- flag )
\ *G flag is true on error
        0 >r rp@ hwnd AtlAxGetControl if r>drop true exitm then
        rp@ COM IUnknown IQueryInterface
        rp@ COM IUnknown IReleaseRef drop r>drop
        ;M

;CLASS
\ *G End of AXControl class

\ *Z
