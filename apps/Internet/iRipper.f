anew iRipper.f  \ Copies files from the internet.

INTERNAL WinLibrary URLMON.DLL  EXTERNAL PREVIOUS

string: CollectFile$    s" 20070613.htm" CollectFile$ place

: $CreateFile ( Filename$ - fid )
    count r/w create-file abort" Can't create file" ;

: CreateCollectFile  ( - )
    CollectFile$ $createFile  close-file abort" close error"  ;

create site$ LMAXCOUNTED allot
create long$ LMAXCOUNTED allot
: .long$ ( - )   cr long$ lcount 100 min type   ;

: UrlDownloadToFile ( z"url" - )
    CollectFile$ count drop swap 0 0 2swap  0 call URLDownloadToFile drop ;

\ Rip will copy the specified file from the internet to the current
\ directory using the same name.

: rip ( name-file cnt -)
    2dup
    current-dir$ count CollectFile$ place s" \"  CollectFile$ +place
    CollectFile$ +place  CollectFile$ +NULL .long$  CreateCollectFile
    site$  lcount long$ lplace
    long$ +lplace
    long$ +LNULL
    long$ lcount drop UrlDownloadToFile
 ;

\ SetSite: To target the internetsite. It must end with a "/" !
: SetSite ( adr count - )  site$  lplace  ;

\s Disable this line to run the demo.

\ It will copy Forth Dimensions from http://www.forth.org/fd/contents.html
\ That might take some time

s" http://www.forth.org/fd/" SetSite
\ chdir F:\Development\FORTH\4th_dimensions \ Sets the target directory on the local PC

cr cr .date space .time

 s" FD-V01N1.pdf" rip
 s" FD-V01N2.pdf" rip
 s" FD-V01N3.pdf" rip
 s" FD-V01N4.pdf" rip
 s" FD-V01N5.pdf" rip
 s" FD-V01N6.pdf" rip

 s" FD-V02N1.pdf" rip
 s" FD-V02N2.pdf" rip
 s" FD-V02N3.pdf" rip
 s" FD-V02N4.pdf" rip
 s" FD-V02N5.pdf" rip
 s" FD-V02N6.pdf" rip

 s" FD-V03N1.pdf" rip
 s" FD-V03N2.pdf" rip
 s" FD-V03N3.pdf" rip
 s" FD-V03N4.pdf" rip
 s" FD-V03N5.pdf" rip
 s" FD-V03N6.pdf" rip

 s" FD-V04N1.pdf" rip
 s" FD-V04N2.pdf" rip
 s" FD-V04N3.pdf" rip
 s" FD-V04N4.pdf" rip
 s" FD-V04N5.pdf" rip
 s" FD-V04N6.pdf" rip

 s" FD-V05N1.pdf" rip
 s" FD-V05N2.pdf" rip
 s" FD-V05N3.pdf" rip
 s" FD-V05N4.pdf" rip
 s" FD-V05N5.pdf" rip
 s" FD-V05N6.pdf" rip

 s" FD-V06N1.pdf" rip
 s" FD-V06N2.pdf" rip
 s" FD-V06N3.pdf" rip
 s" FD-V06N4.pdf" rip
 s" FD-V06N5.pdf" rip
 s" FD-V06N6.pdf" rip

 s" FD-V07N1.pdf" rip
 s" FD-V07N2.pdf" rip
 s" FD-V07N3.pdf" rip
 s" FD-V07N4.pdf" rip
 s" FD-V07N5.pdf" rip
 s" FD-V07N6.pdf" rip

 s" FD-V08N1.pdf" rip
 s" FD-V08N2.pdf" rip
 s" FD-V08N3.pdf" rip
 s" FD-V08N4.pdf" rip
 s" FD-V08N5.pdf" rip
 s" FD-V08N6.pdf" rip

 s" FD-V09N1.pdf" rip
 s" FD-V09N2.pdf" rip
 s" FD-V09N3.pdf" rip
 s" FD-V09N4.pdf" rip
 s" FD-V09N5.pdf" rip
 s" FD-V09N6.pdf" rip

 s" FD-V10N1.pdf" rip
 s" FD-V10N2.pdf" rip
 s" FD-V10N3.pdf" rip
 s" FD-V10N4.pdf" rip
 s" FD-V10N5.pdf" rip
 s" FD-V10N6.pdf" rip

 s" FD-V11N1.pdf" rip
 s" FD-V11N2.pdf" rip
 s" FD-V11N3.pdf" rip
 s" FD-V11N4.pdf" rip
 s" FD-V11N5.pdf" rip
 s" FD-V11N6.pdf" rip

 s" FD-V12N1.pdf" rip
 s" FD-V12N2.pdf" rip
 s" FD-V12N3.pdf" rip
 s" FD-V12N4.pdf" rip
 s" FD-V12N5.pdf" rip
 s" FD-V12N6.pdf" rip

 s" FD-V13N1.pdf" rip
 s" FD-V13N2.pdf" rip
 s" FD-V13N3.pdf" rip
 s" FD-V13N4.pdf" rip
 s" FD-V13N5.pdf" rip
 s" FD-V13N6.pdf" rip

 s" FD-V14N1.pdf" rip
 s" FD-V14N2.pdf" rip
 s" FD-V14N3.pdf" rip
 s" FD-V14N4.pdf" rip
 s" FD-V14N5.pdf" rip
 s" FD-V14N6.pdf" rip

 s" FD-V15N1.pdf" rip
 s" FD-V15N2.pdf" rip
 s" FD-V15N3.pdf" rip
 s" FD-V15N4.pdf" rip
 s" FD-V15N5.pdf" rip
 s" FD-V15N6.pdf" rip

 s" FD-V16N1.pdf" rip
 s" FD-V16N2.pdf" rip
 s" FD-V16N3.pdf" rip
 s" FD-V16N4.pdf" rip
 s" FD-V16N5.pdf" rip
 s" FD-V16N6.pdf" rip

 s" FD-V17N1.pdf" rip
 s" FD-V17N2.pdf" rip
 s" FD-V17N3.pdf" rip
 s" FD-V17N4.pdf" rip
 s" FD-V17N5.pdf" rip
 s" FD-V17N6.pdf" rip

 s" FD-V18N1.pdf" rip
 s" FD-V18N2.pdf" rip
 s" FD-V18N3.pdf" rip
 s" FD-V18N4.pdf" rip
 s" FD-V18N5.pdf" rip
 s" FD-V18N6.pdf" rip

 s" FD-V19N1.pdf" rip
 s" FD-V19N2.pdf" rip
 s" FD-V19N3.pdf" rip
 s" FD-V19N4.pdf" rip
 s" FD-V19N5.pdf" rip
 s" FD-V19N6.pdf" rip

 s" FD-V20N1.pdf" rip
 s" FD-V20N2.pdf" rip
 s" FD-V20N3.pdf" rip
 s" FD-V20N4.pdf" rip
 s" FD-V20N5.pdf" rip
 s" FD-V20N6.pdf" rip

 s" FD-V20N1,2.pdf" rip

\s  Note: The coding of the demo could be better.
