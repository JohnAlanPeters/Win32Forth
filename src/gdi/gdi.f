\ gdi.f
\
\ Written: Sonntag, Oktober 09 2005 by Dirk Busch
\ Changed: Samstag, Oktober 29 2005 by Dirk Busch
\
\ Licence: Public Domain
\
\ Missing:      Clipping support
\               Colors (Pallette) support
\               Region support
\               Printing support

cr .( Loading GDI class library...)

needs gdi/gdiBase.f
needs gdi/gdiPen.f
needs gdi/gdiBrush.f
needs gdi/gdiFont.f
needs gdi/gdiBitmap.f
needs gdi/gdiMetafile.f
needs gdi/gdiDc.f
needs gdi/gdiWindowDc.f
needs gdi/gdiMetafileDC.f
