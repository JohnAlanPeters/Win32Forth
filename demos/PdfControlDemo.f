\ $Id: PdfControlDemo.f,v 1.2 2008/08/16 15:18:30 jos_ven Exp $

\ Demo for the Acrobat PDF Control
\ Thomas Dixon

cr .( Loading PDF Control Demo...)

anew -PdfControlDemo.f

needs PdfControl.f

\ Create a simple pdf window
:class PDFwin <super window
  PDFControl pdf

  :M On_Init: ( -- )
     On_Init: super
     self Start: pdf ;M

  :M On_Size: ( h m w -- ) 2drop drop autosize: pdf ;M

  :M LoadFile: ( str len -- flag ) LoadFile: pdf ;M
  :M SetPage: ( n -- ) SetPage: pdf ;M
  :M gotoFirstPage: ( -- ) gotoFirstPage: pdf ;M
  :M gotoLastPage: ( -- ) gotoLastPage: pdf ;M
  :M gotoNextPage: ( -- ) gotoNextPage: pdf ;M
  :M gotoPreviousPage: ( -- ) gotoPreviousPage: pdf ;M
  :M goForward: ( -- ) goForward: pdf ;M
  :M goBack: ( -- ) goBack: pdf ;M

  :M Print: ( -- ) Print: pdf ;M
  :M PrintWithDialog: ( -- ) PrintWithDialog: pdf ;M
  :M PrintPages: ( n n -- ) PrintPages: pdf ;M
  :M PrintPagesFit: ( flag n n -- ) PrintPagesFit: pdf ;M
  :M PrintAll: ( -- ) PrintAll: pdf ;M
  :M PrintAllFit: ( bool -- ) PrintAllFit: pdf ;M

  :M SetZoom: ( float -- ) SetZoom: pdf ;M
  :M SetZoomScroll: ( float float float -- ) SetZoomScroll: pdf ;M
  :M SetViewRect: ( float float float float -- ) SetViewRect: pdf ;M

  :M SetPageMode: ( str len -- ) SetPageMode: pdf ;M
  :M SetLayoutMode: ( str len -- ) SetLayoutMode: pdf ;M
  :M SetNamedDest: ( str len -- ) SetNamedDest: pdf ;M

  :M SetShowToolbar: ( flag -- ) SetShowToolbar: pdf ;M
  :M SetShowScrollbars: ( flag -- ) SetShowScrollbars: pdf ;M

  :M Aboutbox: ( -- ) Aboutbox: pdf ;M
;class


\ This should load a pdf file and display it in a window
pdfwin pwin
start: pwin
s" Help\html\Guides\And_so_Forth.pdf" Prepend<home>\ loadfile: pwin drop


\ I don't think the PDF viewer was ever ment to be used as an embedded control
\ It only supports the dispatch interface and updates (such as resizing) are rather slow


