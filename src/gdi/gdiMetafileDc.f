\ *D doc\classes\
\ *! gdiMetafileDC
\ *T gdiMetafileDC -- Metafile device context class
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

cr .( Loading GDI class library - Metafile device context...)

needs gdiDC.f
needs gdiMetafile.f

internal
external

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
:class gdiMetafileDC <super gdiDC
\ *G Metafile device context class

RECTANGLE   MetaRect
gdiMetafile Metafile

:M SetRect:     ( left top right bottom -- )
\ *G Specify the dimensions (in .01-millimeter units) of the picture to be
\ ** stored in the enhanced metafile.
        SetRect: MetaRect ;M

:M ClassInit:   ( -- )
        ClassInit: super
        0 0 10000 10000 SetRect: self
        ;M

:M CalcMetaRect: { left top right bottom hDC \ iWidthMM iHeightMM iWidthPels iHeightPels -- }
\ *G Calc the dimensions (in .01-millimeter units) of the picture to be
\ ** stored in the enhanced metafile.
        hDC GetGdiObjectHandle to hDC

        \ Determine the picture frame dimensions.
        \ iWidthMM    is the display width in millimeters.
        \ iHeightMM   is the display height in millimeters.
        \ iWidthPels  is the display width in pixels.
        \ iHeightPels is the display height in pixels
        HORZSIZE hDC call GetDeviceCaps to iWidthMM
        HORZRES  hDC call GetDeviceCaps to iWidthPels
        VERTSIZE hDC call GetDeviceCaps to iHeightMM
        VERTRES  hDC call GetDeviceCaps to iHeightPels

        \ Convert client coordinates to .01-mm units.
        \ Use iWidthMM, iWidthPels, iHeightMM, and  iHeightPels to
        \ determine the number of  .01-millimeter units per pixel in
        \ the x- and y-directions.
        left   iWidthMM  * 100 * iWidthPels  /
        top    iHeightMM * 100 * iHeightPels /
        right  iWidthMM  * 100 * iWidthPels  /
        bottom iHeightMM * 100 * iHeightPels /
        SetRect: MetaRect
        ;M

:M StartRecording: ( hRefDC -- f )
\ *G Start recording of a Metafile
        GetGdiObjectHandle >r

        0       \ lpDescription
        MetaRect \ bounding rectangle
        0       \ lpstrFileName
        r>      \ hRefDC
        call CreateEnhMetaFile dup SetHandle: self 0<>
        ;M

:M StopRecording:  ( -- f )
\ *G Stop recording of a Metafile
        hObject ?dup
        if   call CloseEnhMetaFile dup SetHandle: Metafile 0<>
             0 SetHandle: self
        else false
        then ;M

:M Load:        ( addr len -- f )
\ *G Load a metafile from a file
        StopRecording: self drop
        Load: Metafile ;M

:M Save:        ( addr len -- f )
\ *G Save the metafile in a file
        StopRecording: self drop
        Save: Metafile ;M

:M Destroy:     ( -- )
\ *G Destroy the metafile.
        StopRecording: self drop
        Destroy: Metafile ;M

:M Draw:        ( left top right bottom hDestDC -- )
\ *G Play the metafile in a rectangle
        PlayInRect: Metafile ;M

:M GetMetafile: ( -- MetafileObject )
\ *G Return the address of the metafile object used by this class
        Metafile ;M
;class
\ *G End of gdiMetafileDC class

module

\ *Z
