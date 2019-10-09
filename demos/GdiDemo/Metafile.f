\ File:         GdiDemo.f
\ Purpose:      Demo application for the GDI class library
\ Written:      Sonntag, Oktober 30 2005 by Dirk Busch
\ Licence:      Public Domain

cr .( Loading GDI class library demo - Main...)

anew -gdidemo.f

needs gdi/gdi.f \ the GDI class library

0 value create-tunkey?

\ ----------------------------------------------------------------------
\ the Main window
\ ----------------------------------------------------------------------
:object GdiDemoWindow <super WINDOW

gdiPen          tPen
gdiSolidBrush   tSolidBrush
gdiHatchBrush   tHatchBrush
gdiFont         tFont
gdiWindowDC     tDC
gdiMetafileDC   tMetaDC

\ Create a metafile and store it on disk.
\ This metafile will be displayed during repaint
create FileName ," Metafile.emf"
create Text1    ," This is a Text"
create Text2    ,"TEXT" "This is a Text with a\TTAB"
int Created?

winver 1 > [if] \ sorry only Win98 and better
:M SetArcDirection: ( Direction -- OldDirection )
        SetArcDirection: tMetaDC ;M
[else]
:M SetArcDirection: ( Direction -- OldDirection )
        ;M
[then]

: CreateIt      ( -- )
        hWnd GetDC: tDC
        if
                \ Start recording a metafile for this window
                0 0 Width Height tDC CalcMetaRect: tMetaDC
                tDC StartRecording: tMetaDC
                if
                        \ setup the MetafileDC
                        MM_TEXT SetMapMode: tMetaDC
                        0 0 SetWindowOrg: tMetaDC

                        \ draw something into the metafile
                        tPen SelectObject: tMetaDC
                        tHatchBrush SelectObject: tMetaDC

                         50  50 100 125 Rectangle: tMetaDC
                        125 125 150 175 Ellipse: tMetaDC

                        AD_COUNTERCLOCKWISE SetArcDirection: tMetaDC
                        190 60 120 140 200 240 120 70 Pie: tMetaDC
                        290 160 120 140 200 240 120 70 Chord: tMetaDC
                        SetArcDirection: tMetaDC drop

                        SelectObject: tMetaDC drop \ tHatchBrush

                        tSolidBrush SelectObject: tMetaDC

                        AD_CLOCKWISE SetArcDirection: tMetaDC
                        190 60 120 140 200 240 120 70 Pie: tMetaDC
                        290 160 120 140 200 240 120 70 Chord: tMetaDC
                        SetArcDirection: tMetaDC drop

                        SelectObject: tMetaDC drop \ tSolidBrush
                        SelectObject: tDC drop \ tPen

                         20 300 120 350 tHatchBrush FillRect: tMetaDC
                        120 300 220 350 tHatchBrush FrameRect: tMetaDC

                        tFont SelectObject: tMetaDC
                        20 350 Text1 count TextOut: tMetaDC

                        20 SetTabSize: tMetaDC
                        20 400 Text2 count TabbedTextOut: tMetaDC 2drop
                        SetTabSize: tMetaDC drop \ TabSize

                        SelectObject: tMetaDC drop \ tFont

                        \ cleanup the MetafileDC
                        SetMapMode: tMetaDC drop
                        SetWindowOrg: tMetaDC 2drop

                        \ stop recording
                        StopRecording: tMetaDC
                        if   \ save it
                             FileName count Save: tMetaDC drop
                             true to Created?
                        then
                        Destroy: tMetaDC
                then
                Release: tDC
        then ;

\ Load the Metafile and draw it
: LoadAndDrawIt ( -- )
        FileName count Load: tMetaDC \ load the metafile from disk
        if   0 0 Width Height tDC Draw: tMetaDC \ and draw it in our window
             Destroy: tMetaDC \ clean up
        then ;

:M On_Paint:    ( -- )
        Created?
        if   hWnd GetDC: tDC
             if   LoadAndDrawIt
                  Release: tDC
             then
        then ;M

:M Start:       ( -- )

        FALSE to Created? \ we don't have a Metafile to display yet

        \ create a Pen
        hWnd ChooseColor: tPen 0=
        if 255 SetRValue: tPen then
        PS_DASHDOTDOT SetStyle: tPen
        Create: tPen drop

        \ create a solid brush
        hWnd ChooseColor: tSolidBrush 0=
        if 255 SetGValue: tSolidBrush then
        Create: tSolidBrush drop

        \ create a hatch brush
        hWnd ChooseColor: tHatchBrush 0=
        if 255 SetBValue: tHatchBrush then
        HS_DIAGCROSS SetStyle: tHatchBrush
        Create: tHatchBrush drop

        \ let the user choose a font
        hWnd Choose: tFont 0=
        if      \ create a font
                s" Times New Roman" SetFaceName: tFont
                true SetUnderline: tFont
                true SetItalic: tFont
                20 SetHeight: tFont
                Create: tFont drop
        then


        Start: super    \ display our window
        CreateIt        \ create our metafile
        Paint: super    \ and force a repaint
        ;M

:M On_Done:     ( -- )
        On_Done: super
        turnkeyed? if bye then
        ;M

;object

\ ----------------------------------------------------------------------
\ Start the demo or create a turnkey application
\ ----------------------------------------------------------------------

: GdiDemo ( -- )
        Start: GdiDemoWindow ;

create-tunkey? [if]
        ' GdiDemo turnkey Metafile.exe
[else]
        GdiDemo
[then]
