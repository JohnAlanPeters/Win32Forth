\ *D doc\classes\
\ *! gdiMetafile
\ *T gdiMetafile -- Metafile class
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

cr .( Loading GDI class library - Metafile...)

needs gdiBase.f
needs gdiDC.f

internal
external

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ *W <a name="gdiMetafile"></a>
:class gdiMetafile <super gdiObject
\ *G Metafile class. This class only support's enhanced metafiles (emf) !

rectangle RECT

:M ClassInit: ( -- )
        ClassInit: super
        ;M

:M Destroy:     ( -- )
\ *G Destroy the metafile.
        hObject ?dup
        if   call DeleteEnhMetaFile ?win-error
             0 to hObject
        then ;M

:M SetHandle: ( hMF -- )
\ *G Set the handle of the metafile.
        Destroy: self to hObject ;M

:M Copy:        ( -- hCopy )
\ *G Create a copy of the metafile in memory
        hObject
        if   0 hObject call CopyEnhMetaFile
        else null
        then ;M

: FileName      ( addr len -- addr1 )
        pad place pad +null pad 1+ ;

:M Load:        ( addr len -- f )
\ *G Load a metafile from a file
        FileName call GetEnhMetaFile SetHandle: self
        Valid?: super ;M

:M Save:        ( addr len -- f )
\ *G Save the metafile in a file
        hObject
        if   FileName hObject call CopyEnhMetaFile dup
             if   call DeleteEnhMetaFile ?win-error true
             else false
             then
        else 2drop false
        then ;M

:M PlayInRect:  ( left top right bottom hDestDC -- )
\ *G Play the metafile in a rectangle
        GetGdiObjectHandle >r SetRect: RECT
        RECT hObject r>
        call PlayEnhMetaFile drop ;M

:M CopyToClipboard: ( -- )
\ *G Copy the metafile to the clipboard
        hObject
        if   null call OpenClipboard ?win-error
             call EmptyClipboard ?win-error
             null hObject call CopyEnhMetaFile
             CF_ENHMETAFILE call SetClipboardData ?win-error
             call CloseClipboard ?win-error
        then ;M

:M GetFromClipboard: ( -- )
\ *G Get a metafile from the clipboard
        null call OpenClipboard ?win-error
        CF_ENHMETAFILE call GetClipboardData
        call CloseClipboard ?win-error
        ?dup
        if   null swap call CopyEnhMetaFile
             SetHandle: self
        then ;M

:M GetFileHeader:       ( pemh size -- n )
\ *G The GetFileHeader: method retrieves the record containing the header
\ ** for the specified enhanced-format metafile. \n
\ ** pemh  Pointer to an ENHMETAHEADER structure that receives the header record.
\ ** If this parameter is NULL, the function returns the size of the header record. \n
\ ** size Specifies the size, in bytes, of the buffer to receive the data. Only this
\ ** many bytes will be copied.
        hObject call GetEnhMetaFileHeader ;M

:M GetPaletteEntries:   ( cEntries lppe -- n )
\ *G The GetPaletteEntries: methods retrieves optional palette entries from the
\ ** specified enhanced metafile. \n
\ ** cEntries  Specifies the number of entries to be retrieved from the optional
\ ** palette. \n
\ ** lppe Pointer to an array of PALETTEENTRY structures that receives the palette
\ ** colors. The array must contain at least as many structures as there are entries
\ ** specified by the cEntries parameter.
\ ** If the array pointer is NULL and the enhanced metafile contains an optional palette,
\ ** the return value is the number of entries in the enhanced metafile's palette; if
\ ** the array pointer is a valid pointer and the enhanced metafile contains an optional
\ ** palette, the return value is the number of entries copied; if the metafile does not
\ ** contain an optional palette, the return value is zero. Otherwise, the return value
\ ** is GDI_ERROR.
        swap hObject call GetEnhMetaFilePaletteEntries ;M

;class
\ *G End of gdiMetafile class

module

\ *Z
