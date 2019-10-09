\    File: HtmlDisplay.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Samstag, Juli 24 2004 - dbu
\ Updated: Samstag, Juli 31 2004 - dbu
\
\ Display HTML pages in a Window.

cr .( Loading Html Display Demo...)

anew -HtmlDisplay.f
needs HtmlDisplayWindow.f

:object MainWindow1 <super HtmlDisplayWindow

:M WindowTitle: ( -- sztitle )
                z" The simple WebBrowser 1" ;M

:M StartSize:   ( -- w h )
                800 600 ;M

;object

:object MainWindow2 <super HtmlDisplayWindow

:M WindowTitle: ( -- sztitle )
                z" The simple WebBrowser 2" ;M

:M StartSize:   ( -- w h )
                700 500 ;M
;object

Start: MainWindow1
s" Help\html\dpans\dpans.htm" Prepend<home>\ PAD place PAD +null PAD 1+ SetURL: MainWindow1

Start: MainWindow2
s" Help\html\Guides\primer_Noble.htm" Prepend<home>\ PAD place PAD +null PAD 1+ SetURL: MainWindow2
