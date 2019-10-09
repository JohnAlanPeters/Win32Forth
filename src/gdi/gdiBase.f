\ $Id: gdiBase.f,v 1.11 2009/01/01 18:36:50 georgeahubert Exp $

\ *D doc\classes\
\ *! gdiBase
\ *T gdiObject -- Base class for GDI objects
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch

\ *P gdiObject is the base class for all GDI objects.  This class
\ ** contains a single ivar, hObject, that is the (MS Windows) handle for the
\ ** GDI object. Since GdiObject is a generic class it should not be used to create
\ ** any instances. There will be the following subclasses of gdiObject:

\ *W <ul>
\ *W <li><a href="clas-gdiPen.htm#gdiPen">gdiPen</a> Class for cosmetic pen's</li>
\ *W <li><a href="clas-gdiPen.htm#gdiGeometricPen">gdiGeometricPen</a> Class for geometric pen's</li>

\ *W <li><a href="clas-gdiBrush.htm#gdiSolidBrush">gdiSolidBrush</a> Solid brush class</li>
\ *W <li><a href="clas-gdiBrush.htm#gdiHatchBrush">gdiHatchBrush</a> Hatch brush class</li>
\ *W <li><a href="clas-gdiBrush.htm#gdiPatternBrush">gdiPatternBrush</a> Pattern brush class</li>
\ *W <li><a href="clas-gdiBrush.htm#gdiDIBPatternBrush">gdiDIBPatternBrush</a> DIBPattern brush class</li>

\ *W <li><a href="clas-gdiFont.htm">gdiFont</a> Class for windows fonts</li>

\ *W <li><a href="clas-gdiBitmap.htm">gdiBitmap</a> Class for bitmaps</li>
\ *W <li><a href="clas-gdiMetafile.htm">gdiMetafile</a> Class for enhanced metafiles</li>

\ *W <li><a href="clas-gdiDC.htm">gdiDC</a> Base device context class</li>
\ *W <li><a href="clas-gdiWindowDC.htm">gdiWindowDC</a> Device context class for windows</li>
\ *W <li><a href="clas-gdiMetafileDC.htm">gdiMetafileDC</a> Device context class for enhanced metafiles</li>

\ *W </ul>

\ *P There are some other (old) classes in Win32Forth that are dealing with the GDI:
\ *L
\ *| ColorObject        | Class for color objects           |
\ *| ExtColorObject     | Class for extended color objects  |
\ *| HatchColorObject   | Class for hatch color objects     |
\ *| Font               | Class for fonts                   |
\ *| WinDC              | Device context class for windows  |
\ *| WinPrinter         | Device context class for printing |

\ *P All old classes are rewritten to use the GDI class library.

\ *S Glossary

cr .( Loading GDI class library - Base...)

needs gdiStruct.f
needs gdiTools.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Global linked list of gdi objects
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

internal

\ List of all GDI objects that are currently defined in the system.
VARIABLE gdi-object-link
         gdi-object-link OFF

external

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Base class for all GDI Objects
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:class gdiObject <super object
\ *G gdiObject is the base class for all GDI Object classes.

int hObject \ handle of the GDI object

int mylink

:M ZeroHandle:  ( -- )
\ *G Clear the handle of the object. \n
\ ** If the current handle of the object is valid it will not be destroyed.
        0 to hObject ;M

:M ClassInit:   ( -- )
\ Init the class
        ClassInit: super

        ZeroHandle: self                 \ zero handle
        (gdilock)
        gdi-object-link link,            \ link into list so we
        self ,                           \ can send ourself messages
        gdi-object-link @ to mylink
        (gdiunlock) ;M

:M GetType:     ( -- n )
\ *G Get the type of the object.  \n
\ ** Possible return values are:
\ *L
\ *| OBJ_BITMAP         | Bitmap |
\ *| OBJ_BRUSH          | Brush |
\ *| OBJ_COLORSPACE     | Color space |
\ *| OBJ_DC             | Device context |
\ *| OBJ_ENHMETADC      | Enhanced metafile DC |
\ *| OBJ_ENHMETAFILE    | Enhanced metafile |
\ *| OBJ_EXTPEN         | Extended pen |
\ *| OBJ_FONT           | Font |
\ *| OBJ_MEMDC          | Memory DC |
\ *| OBJ_METAFILE       | Metafile |
\ *| OBJ_METADC         | Metafile DC |
\ *| OBJ_PAL            | Palette |
\ *| OBJ_PEN            | Pen |
\ *| OBJ_REGION         | Region |
        hObject call GetObjectType ;M

:M GetObject:   ( cbBuffer lpvObject -- n )
\ *G Get information for the object.      \n
\ ** If the function succeeds, and lpvObject is a valid pointer, the return value is
\ ** the number of bytes stored into the buffer. \n
\ ** If the function succeeds, and lpvObject is NULL, the return value is the number
\ ** of bytes required to hold the information the function would store into the buffer.
\ ** If the function fails, the return value is zero.
        hObject 3reverse call GetObject ;M

\ check if it's save to destroy the object
: Destroy?      ( -- f )
        GetType: self
             dup OBJ_PEN     =
        swap dup OBJ_EXTPEN  =
        swap dup OBJ_BRUSH   =
        swap dup OBJ_FONT    =
        swap dup OBJ_BITMAP  =
        swap dup OBJ_REGION  =
        swap     OBJ_PAL     =
        or or or or or or ;

:M Destroy:     ( -- )
\ *G Destroy the object.
        Destroy?
        if   hObject call DeleteObject ?win-error
        then 0 to hObject
        ;M

: Unchain-gdi-object ( -- )
        (gdilock) mylink gdi-object-link un-link drop (gdiunlock) ;

:M ~:           ( -- )
        Destroy: self Unchain-gdi-object ;M

:M GetHandle:   ( -- hObject )
\ *G Get the handle of the object.
        hObject ;M

:M SetHandle:   ( hObject -- )
\ *G Set the handle of the object.      \n
\ ** If the current handle of the object is valid it will be destroyed.
        Destroy: self
        to hObject ;M

:M Valid?:      ( -- f )
\ *G Check if this object is valid.
        hObject 0<> ;M

\ ---------------- INTERNAL SYSTEM FUNCTIONS FOLLOW ----------------
\ The following functions and methods make sure that any gdi objects
\ created in your application get reset at system startup, and deleted
\ when Win32Forth closes.

in-system

: trim-gdi-objects ( nfa -- nfa )
        dup gdi-object-link full-trim ;

forget-chain chain-add trim-gdi-objects

in-application

: do-objects    { method -- }
        gdi-object-link @
        begin  dup
        while  dup cell+ @
               method Methodexecute
               @
        repeat drop ;

: init-gdi-objects      ( -- ) \ clear all handles
        [getmethod] ZeroHandle: GdiObject do-objects ;

:M destroy-gdi-objects: ( -- ) \ destroy this object
        0 SetHandle: self ;M

: destroy-gdi-objects   ( -- ) \ destroy all GDI objects
        [getmethod] destroy-gdi-objects: GdiObject do-objects ;

initialization-chain chain-add init-gdi-objects
unload-chain         chain-add destroy-gdi-objects

: Unchain-gdi-dynamic-object ( addr -- )
        cell+ @ dup app-origin sys-here between if drop else Unchain-gdi-object then ;

: Unchain-gdi-dynamic-objects ( -- )
        ['] Unchain-gdi-dynamic-object gdi-object-link do-link ;

\ unload-chain         chain-add dispose-gdi-dynamic-objects
initialization-chain         chain-add-before Unchain-gdi-dynamic-objects

;class
\ *G End of gdiBase class

\ *S Helper words outside the gdiBase class

: ?IsGdiObject  ( a1 -- f )                     \ w32f
\ *G Check if a1 is the address of a GdiObject.
        >r gdi-object-link @
        begin  dup
        while  dup cell+ @ r@ =  \ match this gdi object?
               if   drop rdrop true EXIT \ leave test, passed
               then @
        repeat drop
        rdrop false ;

: GetGdiObjectHandle  { GdiObject -- handle }   \ w32f
\ *G Check if GdiObject is the address of a valid GdiObject.
\ ** If so return the handle of the object.
        GdiObject ?IsGdiObject
        if   GetHandle: GdiObject
        else GdiObject
        then ;

: UnLinkGdiObject ( -- )   \ remove the GdiObject at the head of the gdi-object-link list
        (gdilock) gdi-object-link @ gdi-object-link un-link drop (gdiunlock) ;

in-system

: .gdi-objects  ( -- )                          \ w32f sys
\ *G Display GDI objects which are currently defined.
        gdi-object-link @
        begin  dup
        while  dup cell+ @
               cell - body> .NAME
               12 #tab space 12 ?cr
               @
        repeat drop ;

in-application

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ A utility word to check that an operation about to be performed is really
\ being done on a gdi object, helps prevent horrible crashes
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: (?GdiCheck)   ( a1 -- a1 )                    \ w32f sys internal
\ *G Verify if a1 is the address of a GdiObject.
\ ** If a1 isn't the address of a GdiObject the application will be aborted.
        dup ?IsGdiObject 0=
        if   forth-io .rstack
             true Abort" This is not a GDI Object!"
        then ;

in-application

: ?GdiCheck     ( a1 -- a1 )                    \ w32f
\ *G Verify if a1 is the address of a GdiObject.
\ *P If a1 isn't the address of a GdiObject and the error checking is enabled
\ ** the application will be aborted.
\ *P NOTE: \i ?GdiCheck \d does nothing in turnkey applications, it's for debugging only.
        TURNKEYED? ?win-error-enabled 0= or ?EXIT \ leave if error checking is not enabled
\in-system-ok   (?GdiCheck) ;

module

\ *Z

