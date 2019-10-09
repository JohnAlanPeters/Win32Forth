\ $Id: PrintSupport.f,v 1.3 2011/11/18 14:19:06 georgeahubert Exp $

\ PrintSupport     Rod Oakford  June 28th, 2004

cr .( Loading Print Support...)

WINLIBRARY COMDLG32.DLL
1 PROC PrintDlg
1 PROC PageSetupDlg

\ WINLIBRARY GDI32.DLL
2 PROC StartDoc
1 PROC EndDoc
1 PROC StartPage
1 PROC EndPage
1 PROC DeleteDC
2 PROC GetDeviceCaps

\ WINLIBRARY KERNEL32.DLL
1 PROC GlobalLock
1 PROC GlobalUnlock

\ WINLIBRARY USER32.dll
4 PROC MessageBox

Create PSD   21 cells , 20 cells allot
    PSD cell+     Constant hOwner
    PSD 4 cells+  Constant PSDFlags
    PSD 5 cells+  Constant ptPaperSize
    PSD 7 cells+  Constant rtMinMargin
    PSD 11 cells+ Constant rtMargin

Create PD   16 cells 2 + , 16 cells allot
    PD cell+      Constant hwndOwner
    PD 2 cells+   Constant hDevMode
    PD 3 cells+   Constant hDevNames
    PD 4 cells+   Constant hDC
    PD 5 cells+   Constant PDFlags
    PD 6 cells+   Constant nFromPage   1  nFromPage w!
    PD 26 +       Constant nToPage     999  nToPage w!
    PD 7 cells+   Constant nMinPage    1   nMinPage w!
    PD 30 +       Constant nMaxPage    999 nMaxPage w!
    PD 8 cells+   Constant nCopies

Create DI   5 cells , 4 cells allot
    DI cell+      Constant DocName
    0 value Job


: PageSetupDlg ( -- f )   \ display the new Page Setup dialog
        PSD Call PageSetupDlg
        hOwner hwndOwner 12 move   \ copy hwndOwner, hDevMode
        ;                          \ and hDevNames to PD

: PrintDlg ( -- f )   \ display the Print dialog
        PD Call PrintDlg
        hwndOwner hOwner 12 move   \ copy hwndOwner, hDevMode
        ;                          \ and hDevNames to PSD
            \ Win2K: unless hwndOwner is 0, PrintDlg displays
            \ the new Print Property Sheet instead.

: Print-close ( -- )
        hDC @ Call DeleteDC drop
        0 hDC !
        ;   \ close the printer

: Print-init2 ( Bitmapped Flags Topage -- PrintDC )
        1 max nToPage w!
        nToPage w@ nFromPage w@ < IF  1 nFromPage w!  THEN
        PD_RETURNDC or PDFlags !
        PrintDlg
        IF
            hDC @  swap
            IF   \ Bitmapped
                RASTERCAPS hDC @ Call GetDeviceCaps  RC_BITBLT and not
                IF
                     MB_OK  Z" Device Error"
                     Z" Printer cannot display bitmaps."
                     0 Call MessageBox drop
                     Print-close  drop 0  EXIT
                THEN
            THEN
            DocName 16 erase   \ document name can be changed before Print-Start
            Z" Document" DocName !
        ELSE  drop 0
        THEN
        ;   \ initialize the printer, return DC
            \ unless the default values will do set nFromPage,
            \ nMinPage and nMaxPage before calling Print-init2

: Print-init ( -- PrintDC )
        True   \ selected printer must be able to display bitmaps
        [ PD_HIDEPRINTTOFILE PD_PAGENUMS or PD_NOSELECTION or PD_USEDEVMODECOPIES or ] literal
        nToPage w@
        Print-init2
        ;   \ initialize the printer, return DC
            \ for backward compatability

: Print-setup ( window_handle -- PrintDC )
        hwndOwner !
        False
        PD_PRINTSETUP
        nToPage w@
        Print-init2
        ;   \ display the Print Setup dialog, return DC
            \ better to use PageSetupDlg having set up PSD

: Auto-print-init ( -- PrintDC )
        hDevMode 8 erase   \ set hDevMode and hDevNames to null
        True   \ default printer must be able to display bitmaps
        PD_RETURNDEFAULT
        nToPage w@
        Print-init2
        ;   \ initialize the default printer, return DC

: Print-start ( -- )
        DI hDC @ Call StartDoc to Job   \ <=0 means error
        hDC @ Call StartPage drop       \ and job won't print
        ;    \ start printing a new page for new doc

: Start-page ( -- )
        hDC @ Call StartPage drop
        ;   \ start a new printed page

: End-page ( -- )
        hDC @ Call EndPage drop
        ;   \ finish a printed page

: Print-page ( -- )
        End-Page  Start-Page
        ;   \ finish current page start new page

: Print-end ( -- )
        hDC @ Call EndPage drop
        hDC @ Call EndDoc drop
        ;   \ finish printing page and doc

: Get-frompage ( -- n1 )
        PDFlags @ PD_PAGENUMS and
        IF  nFromPage  ELSE  nMinPage  THEN  w@
        ;

: Get-topage ( -- n1 )
        PDFlags @ PD_PAGENUMS and
        IF  nToPage  ELSE  nMaxPage  THEN  w@
        ;

: Get-copies ( -- n )
        nCopies w@
        ;

: Print-flags ( -- flag )
        PDFlags @
        ;   \ flags returned depend on user selection

: DefaultPrinter ( -- )
        hDevMode 8 erase   \ set hDevMode and hDevNames to null
        PD_RETURNDEFAULT  PDFlags !
        PrintDlg drop
        ;   \ get hDevMode and hDevNames for the default printer

: LockDevMode ( -- a )
        hDevMode @ Call GlobalLock
        ;

: UnlockDevMode ( -- )
        hDevMode @ Call GlobalUnlock drop
        ;

: Quality-print ( -- n )
        LockDevMode dup
        IF  58 + w@  UnlockDevMode  THEN
        ;   \ return the print quality, usually in DPI, dmPrintQuality

: Paper-size ( -- w h )
        LockDevMode dup dup
        IF  drop 48 + @ word-split swap  UnlockDevMode  THEN
        ;   \ return the paper size dmPaperWidth and dmPaperLength

: Print-Orientation ( f -- PrintDC )
        IF  DMORIENT_LANDSCAPE  ELSE  DMORIENT_PORTRAIT  THEN
        Auto-print-init swap
        LockDevMode ?dup
        IF  44 + w!  UnlockDevMode  ELSE  drop  THEN   \ set dmOrientation
        ;   \ initialize the default printer and set the orientation
