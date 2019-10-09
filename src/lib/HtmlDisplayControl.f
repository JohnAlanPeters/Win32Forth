\    File: HtmlDisplayControl.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Samstag, Juli 24 2004 - dbu
\ Updated: Samstag, Juli 31 2004 - dbu
\
\ Display HTML pages in a Window.

cr .( Loading Html Display Control...)

anew -HtmlDisplayControl.f

needs HtmlControl.f

INTERNAL
EXTERNAL

\ --------------------------------------------------------------------------------
\ HtmlDisplayControl class
\ --------------------------------------------------------------------------------

:class HtmlDisplayControl  <super HTMLControl DEPRECATED
\ *G This class was completly replaced by the HTMLControl class. \n
\ ** So use the HTMLControl instead.

;Class

: InitHtmlControl ( -- ) \ Init the Html Control, must be called once at startup
        ; DEPRECATED

: ExitHtmlControl ( -- ) \ Deinit the Html Control, must be called once at exit
        ; DEPRECATED

MODULE
