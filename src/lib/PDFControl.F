\ $Id: PDFControl.F,v 1.2 2005/09/18 11:10:31 dbu_de Exp $

\ Acrobat PDF Control
\ Thomas Dixon

anew -PdfControl.f

needs AXControl

\ We Build off the Generic ActiveX Control
:CLASS PDFControl           <SUPER AXControl
  CELL bytes PDF        \ pointer to Dispatch Interface
  16 bytes xtra         \ xtra space for api calls

  :M Start: ( Parent -- )
        Start: super
          \ You can use PDF.PdfCtrl.6 instead of the ugly clsid string, but this
          \ way we aren't dependent on the vertion of adobe acrobat
        s" {CA8A9780-280D-11CF-A24D-444553540000}" AXCreate: self
        PDF IDispatch QueryInterface: self
          abort" Unable to get the Dispatch Interface!"
        ;M

  :M On_Done: ( -- )
        PDF @ if
          PDF COM IDispatch IReleaseref drop 0 PDF ! then ;M

  :M LoadFile: ( str len -- flag ) \ flag is true on error
        >unicode drop VT_BSTR >vt
        PDF displate" LoadFile" ;M

  :M SetPage: ( n -- )
        VT_I4 >vt
        PDF displate" setCurrentPage" drop ;M
  :M gotoFirstPage: ( -- )
        PDF displate" gotoFirstPage" drop ;M
  :M gotoLastPage: ( -- )
        PDF displate" gotoLastPage" drop ;M
  :M gotoNextPage: ( -- )
        PDF displate" gotoNextPage" drop ;M
  :M gotoPreviousPage: ( -- )
        PDF displate" gotoPreviousPage" drop ;M
  :M goForward: ( -- )
        PDF displate" goForwardStack" drop ;M
  :M goBack: ( -- )
        PDF displate" goBackwardStack" drop ;M

  :M Print: ( -- )
        PDF displate" Print" drop ;M
  :M PrintWithDialog: ( -- )
        PDF displate" PrintWithDialog" drop ;M
  :M PrintPages: ( n n -- )
        swap VT_I4 >vt VT_I4 >vt
        PDF displate" PrintPages" drop ;M
  :M PrintPagesFit: ( flag n n -- )
        rot VT_BOOL >vt swap VT_I4 >vt VT_I4 >vt
        PDF displate" PrintPagesFit" drop ;M
  :M PrintAll: ( -- )
        PDF displate" PrintAll" drop ;M
  :M PrintAllFit: ( bool -- )
        VT_BOOL >vt
        PDF displate" PrintAllFit" drop ;M

  :M SetZoom: ( float -- ) \ 100e0 is 100%
        sfs>ds VT_R4 >vt
        PDF displate" SetZoom" drop ;M
  :M SetZoomScroll: ( float float float -- )
        3 0 do sfs>ds VT_R4 loop   3 0 do >vt loop
        PDF displate" SetZoomScroll" drop ;M
  :M SetViewRect: ( float float float float -- )
        4 0 do sfs>ds VT_R4 loop   4 0 do >vt loop
        PDF displate" SetViewRect" drop ;M

  :M SetPageMode: ( str len -- )
        >unicode drop VT_BSTR >vt
        PDF displate" SetPageMode" drop ;M
  :M SetLayoutMode: ( str len -- )
        >unicode drop VT_BSTR >vt
        PDF displate" SetLayoutMode" drop ;M
  :M SetNamedDest: ( str len -- )
        >unicode drop VT_BSTR >vt
        PDF displate" SetNamedDest" drop ;M

  :M SetShowToolbar: ( flag -- )
        VT_BOOL >vt
        PDF displate" SetShowToolbar" drop ;M
  :M SetShowScrollbars: ( flag -- )
        VT_BOOL >vt
        PDF displate" SetShowScrollbars" drop ;M

  :M Aboutbox: ( -- )
        PDF displate" AboutBox" drop ;M

;CLASS

\ I don't think the PDF viewer was ever ment to be used as an embedded control
\ It only supports the dispatch interface and updates (such as resizing) are rather slow

\s
\ Example: see demos/PdfControlDemo.f
