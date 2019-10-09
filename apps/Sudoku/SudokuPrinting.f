\ $Id: SudokuPrinting.f,v 1.2 2006/08/03 20:37:27 rodoakford Exp $
\ SudokuPrinting.f      Page setup and printing for Sudoku game
\                       September 2005  Rod Oakford

cr .( Loading Printing...)

: OnPageSetup ( -- )
        GetHandle: Frame  PSD cell+ !
        PSD_MARGINS PSD_MINMARGINS or PSD_INTHOUSANDTHSOFINCHES or  PSDFlags !
        PageSetupDlg
        IF
            ptPaperSize 2@  Resolution 1000 */ swap
            Resolution 1000 */ to PaperSize
\            Redraw: Frame
            Autosize: Frame
        THEN
        ;   IDM_PAGE_SETUP SetCommand

: OnPrint ( -- )
        GetHandle: Frame  PD cell+ !
        1 nFromPage w!  1 nMinPage w!  1 nMaxPage w!
        True  PD_NOSELECTION  ( PD_HIDEPRINTTOFILE or ) PD_RETURNDC or PD_PAGENUMS or 1
        Print-init2 ?dup
        IF
            True to Printing
            GetHandle: mdc   \ save Handle of memory DC for screen on stack
            swap PutHandle: mdc   \ use mdc as Print DC
            SaveDC: mdc   \ save Print DC
            size LeftMargin TopMargin   \ save on stack
            Resolution    \ save Resolution of screen on stack
\            DPI: ThePrinter drop to Resolution
            LOGPIXELSX hDC @ Call GetDeviceCaps to Resolution   \ Resolution of printer
\            Quality-print to Resolution
            Resolution over size swap */  to size
            Resolution over FactorFontSize   \ increase FontSize in ratio of printer res to screen res 
\            rtMargin 2@ to LeftMargin to TopMargin
            Print-start
            Get-copies 0
            DO
                Start-page 
                PrepareDC: Frame
                End-page
            LOOP
            Print-end
            ChangeFontSize   \ restore FontHeight
            to Resolution   \ restore Resolution of screen ( used in margins )
            to TopMargin to LeftMargin to size
            RestoreDC: mdc   \ restore Print DC
            PutHandle: mdc   \ restore Handle for screen in mdc
            Print-close
            False to Printing
        THEN
        ;   IDM_PRINT SetCommand

