\ $Id: PVPrinting.f,v 1.2 2008/08/30 10:59:48 camilleforth Exp $

\ PVPrinting.f          Page Setup and Print dialogs for PictureViewer
\                       February 2006 Rod Oakford

Needs PVMenu

\- ActiveChild  0 value ActiveChild
\- PrintAspect   true value PrintAspect
\- PrintCentre   true value PrintCentre
\- PrintEnlarge  true value PrintEnlarge
\- PrintWidth   4000 value PrintWidth
\- PrintHeight  3000 value PrintHeight
\- PSD  Needs PrintSupport

1 value Pages

cr .( Loading PVPrinting)

: OnPageSetup ( -- )
        [ PSD_MARGINS PSD_MINMARGINS or PSD_INTHOUSANDTHSOFINCHES or ] literal PSDFlags !
        PageSetupDlg IF  IDM_PAGE_ADJUST DoCommand  THEN
        ;   IDM_PAGE_SETUP SetCommand

: >DevicePixels ( h v x y -- x y )   >r >r  swap r> 1000 */  swap r> 1000 */  ;

: OnPrint ( -- )
        ActiveChild 0= ?Exit
        GetHandle: ActiveChild hwndOwner !
        1 nFromPage w!  1 nMinPage w!  Pages nMaxPage w!
        True
        [ PD_NOSELECTION  ( PD_HIDEPRINTTOFILE or )  PD_RETURNDC or PD_PAGENUMS or ] literal
        Pages
        Print-init2 ?dup  PauseForMessages
        IF
            PutHandle: ThePrinter
            SaveDC: ThePrinter
            HALFTONE SetStretchBltMode: ThePrinter
            Print-start
            DPI: ThePrinter  PrintWidth PrintHeight  >DevicePixels
            DPI: ThePrinter  rtMargin 2@ swap  >DevicePixels
            ( w h x y ) Print: ActiveChild
            Print-end
            RestoreDC: ThePrinter
            Print-close
        THEN
        ;   IDM_PRINT SetCommand
