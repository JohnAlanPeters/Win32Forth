\ $Id: PVDialogs.f,v 1.3 2008/08/28 01:39:50 camilleforth Exp $

\ PVDialogs.f           Picture Viewer Dialogs by Rod Oakford
\                       July 2006

cr .( Loading PictureViewer Messages and Dialogs)

s" apps\PictureViewer"     "fpath+
s" apps\PictureViewer\res" "fpath+


Needs PVMenu
\- Version$  Create Version$ ," Picture Viewer v6.1"
\- Preload   0 value Preload
\- SingleInstance   0 value SingleInstance
\- CurrentFile   Create CurrentFile 256 allot
\- Continue   0 value Continue
\- PrintWidth   0 value PrintWidth
\- PrintHeight   0 value PrintHeight
\- PrintAspect   true value PrintAspect
\- PrintCentre   true value PrintCentre
\- PrintEnlarge   true value PrintEnlarge
\- CurrentPictureWidth   800 value CurrentPictureWidth
\- CurrentPictureHeight  600 value CurrentPictureHeight
\- Jpeg   Variable Jpeg
\- Tiff   Variable Tiff
\- Bmp   Variable Bmp
\- Time   0 value Time
\- NumberRecentFiles   0 value NumberRecentFiles


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Messages
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: FreeImageError ( -- )
        z" The dynamic link library FreeImage.dll could not be found"
        &prognam count "to-pathend" pad place
        s"  - Unable To Locate DLL " pad +place  pad count asciiz
        MB_ICONSTOP MB_OK or NULL MessageBox drop ;

: RotatePlusError ( Filename$ -- )
        s" Unable to rotate " pad place  count pad +place  pad count asciiz
        z" Rotate Anti-clockwise"  MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;

: RotateMinusError ( Filename$ -- )
        s" Unable to rotate " pad place  count pad +place  pad count asciiz
        z" Rotate Clockwise"  MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;

: LoadPictureError ( Filename$ -- )
        s" Unable to open " pad place  count pad +place  pad count asciiz
        z" Load Picture"  MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;

: SavePictureError ( Filename$ -- )
        s" Unable to save " pad place  count pad +place  pad count asciiz
        z" Save Picture"  MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;

: UninstallMessage ( -- n )   \ IDYES or IDNO
        s" Do you want to remove all Picture Viewer registry settings?" pad place
        s" \nYes will quit this application and all settings will be lost." pad +place
        pad +null
        pad 1+ z" Picture Viewer"  MB_ICONEXCLAMATION MB_YESNO or  NULL  MessageBox ;

: CloseMessage ( -- n )   \ IDYES or IDNO or IDCANCEL
        s" Do you want to close " pad place
        CurrentFile count "to-pathend" pad +place
        s"  ?" pad +place  pad count asciiz
        z" Close Picture" MB_ICONEXCLAMATION  MB_YESNOCANCEL or NULL MessageBox ;

: SizeWarning ( -- )
        z" The size is too large for the paper."
        z" Print Size"
        MB_ICONWARNING MB_OK or MB_TASKMODAL or NULL MessageBox drop ;

: MarginWarning ( a n -- )
        pad place
        s"  margin in Page Setup is less than the minimum margin." pad +place
        pad count asciiz
        z" Margins"
        MB_ICONWARNING MB_OK or MB_TASKMODAL or NULL MessageBox drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Dialogs ( made using MS Visual C++ 6.0 )
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class DialogResource   <Super Dialog

\ :M DialogID: ( -- ID )   0 ;M   \ override

:M Start: { parent -- flag }
        self
        DialogProc
        parent 0 <>                     \ if parent is not zero
        parent conhndl <> and           \ and parent is not the console handle
        if      GetHandle: parent       \ then use the specified parent
        else    conhndl                 \ else use the console for the parent
        then
        DialogID: [ self ]              \ dialogID
        appInst
        Call DialogBoxParam
        ;M

:M GetDlgItemInt: ( id -- n )   0 0 rot hWnd Call GetDlgItemInt  ;M

:M SetDlgItemInt: ( n id -- )   0 -rot hWnd Call SetDlgItemInt drop  ;M

;Class


needs PV.h

WinLibrary FreeImage.dll

: GetVersion ( -- z$ )   Call _FreeImage_GetVersion@0   ;
: GetCopyright ( -- z$ )   Call _FreeImage_GetCopyrightMessage@0   ;
2 CallBack: FreeImageMessage ( FIF Message -- )
          swap
        s" FreeImage Error - FIF: " pad place  (.) pad +place  pad count asciiz
        MB_ICONWARNING MB_OK or MB_TASKMODAL or NULL MessageBox drop ;
: SetOutputMessage ( -- )   &FreeImageMessage     Call _FreeImage_SetOutputMessage@4 drop ;


:Object AboutBox   <Super DialogResource

:M DialogID: ( -- ID )   IDD_ABOUTBOX ;M

:M On_Init: ( -- )
        Version$ count IDC_VERSION SetDlgItemText: self
        GetCopyright zcount IDC_COPYRIGHT_MESSAGE SetDlgItemText: self
        s" FreeImage.dll v" pad place
        GetVersion zcount pad +place  pad +NULL
        pad count IDC_FREEIMAGE_VERSION SetDlgItemText: self
        ;M

;Object


Create Keys  Z," KEYS\n\nCtrl + O\n\nCtrl + D\n\nCtrl + S\n\nCtrl + P\n\n"
            +Z," Ctrl + N\n\nCtrl + C\n\nCtrl + S\n\nCtrl + F\n\nCtrl + R\n\n"
            +Z," Num +\n\nNum -\n\nSpace/Backspace\n\nN\n\nB\n\nM\n\nR (or Shift + R)\n\n"
            +Z," Up arrow\n\nDown arrow\n\nLeft arrow\n\nRight arrow\n\n"
            +Z," Escape\n\nAlt + Enter"
Create Functions  Z," FUNCTIONS\n\nOpens a file\n\nOpens all picture files in a directory"
                 +Z," \n\nSaves the picture as a jpeg, tiff or bitmap"
                 +Z," \n\nPrints the picture"
                 +Z," \n\nSets no picture adjustment"
                 +Z," \n\nCentres picture in window"
                 +Z," \n\nCentres and stretches picture"
                 +Z," \n\nStretches picture to fit window"
                 +Z," \n\nResizes the window to aspect ratio of picture"
                 +Z," \n\nZoom in"
                 +Z," \n\nZoom out"
                 +Z," \n\nShow next/previous image of same type in current directory"
                 +Z," \n\nShow next image in slide show sequence"
                 +Z," \n\nShow previous image in slide show sequence"
                 +Z," \n\nToggles mark picture to ask to confirm before closing it"
                 +Z," \n\nRotates picture 90 degrees clockwise (or anticlockwise)"
                 +Z," \n\nMove picture up"
                 +Z," \n\nMove picture down"
                 +Z," \n\nMove picture left"
                 +Z," \n\nMove picture right"
                 +Z," \n\nStops files loading/returns from full screen"
                 +Z," \n\nToggles full screen mode (or use double click)"

:Object KeyHelpDialog   <Super DialogResource

:M DialogID: ( -- ID )   IDD_KEY_HELP ;M

:M On_Init: ( -- )
        Keys  IDC_KEYS hWnd Call SetDlgItemText drop
        Functions  IDC_FUNCTIONS hWnd Call SetDlgItemText drop
        ;M

;Object


:Object OptionsDialog   <Super DialogResource

:M DialogID: ( -- ID )   IDD_OPTIONS_DIALOG ;M

rtMargin             Constant LeftMargin
rtMargin cell+       Constant TopMargin
rtMargin 2 cells+    Constant RightMargin
rtMargin 3 cells+    Constant BottomMargin
rtMinMargin          Constant LeftMinMargin
rtMinMargin cell+    Constant TopMinMargin
rtMinMargin 2 cells+ Constant RightMinMargin
rtMinMargin 3 cells+ Constant BottomMinMargin

:M SaveValues: ( -- )
        IDC_TIME                GetDlgItemInt: self         to Time
        IDC_RECENT_FILES        GetDlgItemInt: self  9 min  to NumberRecentFiles
        IDC_WIDTH               GetDlgItemInt: self         to PrintWidth
        IDC_HEIGHT              GetDlgItemInt: self         to PrintHeight
        IDC_LEFT                GetDlgItemInt: self         LeftMinMargin !
        IDC_TOP                 GetDlgItemInt: self         TopMinMargin !
        IDC_RIGHT               GetDlgItemInt: self         RightMinMargin !
        IDC_BOTTOM              GetDlgItemInt: self         BottomMinMargin !
        IDC_PRELOAD             IsDlgButtonChecked: self    to Preload
        IDC_INSTANCES           IsDlgButtonChecked: self    0= to SingleInstance
        IDC_ASPECT              IsDlgButtonChecked: self    to PrintAspect
        IDC_CENTRE              IsDlgButtonChecked: self    to PrintCentre
        IDC_ENLARGE             IsDlgButtonChecked: self    to PrintEnlarge
        0x80
        IDC_JPEG_GOOD           IsDlgButtonChecked: self  IF  drop 0x100  THEN
        IDC_JPEG_NORMAL         IsDlgButtonChecked: self  IF  drop 0x200  THEN
        IDC_JPEG_AVERAGE        IsDlgButtonChecked: self  IF  drop 0x400  THEN
        IDC_JPEG_BAD            IsDlgButtonChecked: self  IF  drop 0x800  THEN
        JPEG !
        0x100
        IDC_TIFF_DEFLATE        IsDlgButtonChecked: self  IF  drop 0x200  THEN
        IDC_TIFF_NONE           IsDlgButtonChecked: self  IF  drop 0x800  THEN
\        IDC_TIFF_CCITTFAX3      IsDlgButtonChecked: self  IF  drop 0x1000 THEN
\        IDC_TIFF_CCITTFAX4      IsDlgButtonChecked: self  IF  drop 0x2000 THEN
        IDC_TIFF_LZW            IsDlgButtonChecked: self  IF  drop 0x4000 THEN
        TIFF !
        IDC_BMP_RLE             IsDlgButtonChecked: self  IF  1  ELSE  0  THEN  BMP !
        ;M

: ConstrainWidth ( -- )
        IDC_ASPECT IsDlgButtonChecked: self 0= ?exit         \ only if maintain aspect ratio
        IDC_HEIGHT GetDlgItem: self Call GetFocus <> ?exit    \ only if PrintHeight has focus
        IDC_HEIGHT GetDlgItemInt: self  CurrentPictureWidth *
        CurrentPictureHeight 2/ +  CurrentPictureHeight  /
        IDC_WIDTH SetDlgItemInt: self ;

: ConstrainHeight ( -- )
        IDC_ASPECT IsDlgButtonChecked: self 0= ?exit         \ only if maintain aspect ratio
        IDC_WIDTH GetDlgItem: self Call GetFocus <> ?exit     \ only if PrintWidth has focus
        IDC_WIDTH GetDlgItemInt: self  CurrentPictureHeight *
        CurrentPictureWidth 2/ +  CurrentPictureWidth  /
        IDC_HEIGHT SetDlgItemInt: self ;

: CorrectAspectRatio ( w1 h1 -- w2 h2 )   \ reduces width or height as necesssary
        2dup  CurrentPictureWidth *  swap CurrentPictureHeight *  >
        IF
            drop  dup CurrentPictureHeight *
            CurrentPictureWidth 2/ +  CurrentPictureWidth  /
        ELSE
            nip  dup CurrentPictureWidth *
            CurrentPictureHeight 2/ +  CurrentPictureHeight /
            swap
        THEN ;

: CheckLeft ( -- f )   IDC_LEFT   GetDlgItemInt: self  LeftMargin @ >
        dup IF  s" Left" MarginWarning  THEN ;
: CheckTop ( -- f )   IDC_TOP   GetDlgItemInt: self  TopMargin @ >
        dup IF  s" Top" MarginWarning  THEN ;
: CheckRight ( -- f )   IDC_RIGHT   GetDlgItemInt: self  RightMargin @ >
        dup IF  s" Right" MarginWarning  THEN ;
: CheckBottom ( -- f )   IDC_BOTTOM   GetDlgItemInt: self  BottomMargin @ >
        dup IF  s" Bottom" MarginWarning  THEN ;

: CheckMargins ( -- f )
        CheckLeft CheckTop CheckRight CheckBottom or or or ;

: CheckSize ( -- f )
        IDC_WIDTH GetDlgItemInt: self  IDC_HEIGHT GetDlgItemInt: self
        IDC_CENTRE IsDlgButtonChecked: self
        IF  ptPaperSize @  rot - 0<  ptPaperSize cell+ @  rot - 0<  or
        ELSE  ptPaperSize @  rot -  LeftMargin @ LeftMinMargin @ min - 0<  ptPaperSize cell+ @  rot -  TopMargin @ TopMinMargin @ min - 0<  or
        THEN
        dup IF  SizeWarning  THEN  0=
        ;

: RightBottomMargins ( w h -- r b )
        LeftMargin @ LeftMinMargin @ max LeftMargin !
        TopMargin @ TopMinMargin @ max TopMargin !
        ptPaperSize @  rot -  LeftMargin @ -  RightMinMargin @ max
        ptPaperSize cell+ @  rot -  TopMargin @ -  BottomMinMargin @ max
        ;

: CentredMargins ( w h -- l t )
        ptPaperSize @  rot -  2 /  LeftMinMargin @ max  RightMinMargin @ max
        ptPaperSize cell+ @  rot -  2 /  TopMinMargin @ max  BottomMinMargin @ max
        ;

: AdjustMargins ( -- )
        PrintWidth  PrintHeight
        PrintCentre
        IF  CentredMargins  swap  2dup rtMargin 2!  ELSE  RightBottomMargins  swap  THEN
        rtMargin 2 cells+ 2! ;

: PageAdjust ( -- )   \ used after PageSetup dialog has changed
        false to PrintEnlarge
        ptPaperSize @  LeftMargin @ -  RightMargin @ -
        ptPaperSize cell+ @  TopMargin @ -  BottomMargin @ -
        PrintAspect IF  CorrectAspectRatio  THEN  to PrintHeight to PrintWidth
        AdjustMargins
        ;   IDM_PAGE_ADJUST SetCommand    \ [cdo] replaced SetMenu by SetCommand

: PrintSize ( -- w h )   \ from current min margins in dialog
        IDC_ENLARGE IsDlgButtonChecked: self
        IF
              ptPaperSize @  IDC_LEFT GetDlgItemInt: self -  IDC_RIGHT GetDlgItemInt: self -
              ptPaperSize cell+ @  IDC_TOP GetDlgItemInt: self -  IDC_BOTTOM GetDlgItemInt: self -
        ELSE  PrintWidth PrintHeight
        THEN
        ;

: SetPrintSize ( -- )
        PrintSize  IDC_ASPECT IsDlgButtonChecked: self  IF  CorrectAspectRatio  THEN
        IDC_HEIGHT SetDlgItemInt: self  IDC_WIDTH  SetDlgItemInt: self   \ update Width and Height
        IDC_ENLARGE IsDlgButtonChecked: self  0= dup   \ enable/disable Width and Height
        IDC_WIDTH EnableDlgItem: self  IDC_HEIGHT EnableDlgItem: self
        CheckSize drop ;

: AdjSize   \ adjust width and height to allow for margins less than MinMargins
        PrintCentre
        IF
        ptPaperSize @  LeftMargin @  RightMargin @ max  2* -  0 max to PrintWidth
        ptPaperSize cell+ @  TopMargin @  BottomMargin @  max  2* -  0 max to PrintHeight
        ELSE
        ptPaperSize @  LeftMargin @ -  RightMargin @ -  0max to PrintWidth
        ptPaperSize cell+ @  TopMargin @ -  BottomMargin @ -  0max to PrintHeight
        THEN
        ;

:M On_Command: ( hCtrl code ID -- f )
        Case
            IDC_WIDTH    Of  EN_CHANGE = IF  ConstrainHeight THEN                 false  EndOf
            IDC_HEIGHT   Of  EN_CHANGE = IF  ConstrainWidth  THEN                 false  EndOf
            IDC_ENLARGE  Of  CheckMargins drop SetPrintSize                       false  EndOf
            IDC_ASPECT   Of  CheckMargins drop SetPrintSize                       false  EndOf
            IDC_LEFT     Of  EN_CHANGE = IF  CheckLeft   drop SetPrintSize  THEN  false  EndOf
            IDC_TOP      Of  EN_CHANGE = IF  CheckTop    drop SetPrintSize  THEN  false  EndOf
            IDC_RIGHT    Of  EN_CHANGE = IF  CheckRight  drop SetPrintSize  THEN  false  EndOf
            IDC_BOTTOM   Of  EN_CHANGE = IF  CheckBottom drop SetPrintSize  THEN  false  EndOf
            IDCANCEL     Of  0 end-dialog                                                EndOf
            IDOK         Of  CheckSize  IF  SaveValues: self  AdjustMargins
                                           AdjSize  1 end-dialog  THEN                   EndOf
            false swap ( default result )
        Endcase
        ;M

:M On_Init: ( -- )
        Time               IDC_TIME                SetDlgItemInt: self
        NumberRecentFiles  IDC_RECENT_FILES        SetDlgItemInt: self
        LeftMinMargin @    IDC_LEFT                SetDlgItemInt: self
        TopMinMargin @     IDC_TOP                 SetDlgItemInt: self
        RightMinMargin @   IDC_RIGHT               SetDlgItemInt: self
        BottomMinMargin @  IDC_BOTTOM              SetDlgItemInt: self
        Preload            IDC_PRELOAD             CheckDlgButton: self
        SingleInstance 0=  IDC_INSTANCES           CheckDlgButton: self
        PrintAspect        IDC_ASPECT              CheckDlgButton: self
        PrintCentre        IDC_CENTRE              CheckDlgButton: self
        PrintEnlarge       IDC_ENLARGE             CheckDlgButton: self
        SetPrintSize
        JPEG @
        Case
            0x80   of      IDC_JPEG_SUPERB         CheckDlgButton: self   Endof
            0x100  of      IDC_JPEG_GOOD           CheckDlgButton: self   Endof
            0x200  of      IDC_JPEG_NORMAL         CheckDlgButton: self   Endof
            0x400  of      IDC_JPEG_AVERAGE        CheckDlgButton: self   Endof
            0x800  of      IDC_JPEG_BAD            CheckDlgButton: self   Endof
        EndCase
        TIFF @
        Case
            0x100  of      IDC_TIFF_PACKBITS       CheckDlgButton: self   Endof
            0x200  of      IDC_TIFF_DEFLATE        CheckDlgButton: self   Endof
            0x800  of      IDC_TIFF_NONE           CheckDlgButton: self   Endof
\            0x1000 of      IDC_TIFF_CCITTFAX3      CheckDlgButton: self   Endof
\            0x2000 of      IDC_TIFF_CCITTFAX4      CheckDlgButton: self   Endof
            0x4000 of      IDC_TIFF_LZW            CheckDlgButton: self   Endof
        EndCase
        BMP @ IF  IDC_BMP_RLE  ELSE  IDC_BMP_NONE  THEN  CheckDlgButton: self
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       FileOpenDialog with multiple file selections
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WinLibrary COMDLG32.DLL

Create OFN  19 cells , 18 cells allot
    OFN    cell+       Constant hWindow
    OFN  3 cells+      Constant lpstrFilter
\    OFN  4 cells+      Constant lpstrCustomFilter
\    OFN  5 cells+      Constant nMaxCustFilter
    OFN  6 cells+      Constant nFilterIndex
    OFN  7 cells+      Constant lpstrFile
    OFN  8 cells+      Constant nMaxFile
\    OFN  9 cells+      Constant lpstrFileTitle
\    OFN 10 cells+      Constant nMaxFileTitle
    OFN 11 cells+      Constant lpstrInitialDir
\    OFN 12 cells+      Constant lpstrTitle
    OFN 13 cells+      Constant Flags
    OFN 14 cells+      Constant nFileOffset
\    OFN 14 cells+ 2 +  Constant nFileExtension
\    OFN 15 cells+      Constant lpstrDefExt

Create FileTypes
        ," *.bmp;*.jpg;*.ico;*.pcd;*.psd;*.pcx;*.ppm;*.pgm;*.pbm;*.png;*.ras;*.tga;*.tif;*.gif"

Create OpenFilter  z," Picture Files" -null, 0 c,  FileTypes count z",  -null, 0 c,
        z," All Files" -null, 0 c,  z," *.*" 0 w,

Create SaveFilter  z," Jpeg (*.jpg)" -null, 0 c, z," *.jpg" -null, 0 c,
        z," Tiff (*.tif)" -null, 0 c, z," *.tif" -null, 0 c, z," Bitmap (*.bmp)" -null, 0 c, z," *.bmp" -null, 0 c,
        z," All Files" -null, 0 c,  z," *.*" 0 w,

Create FileNames 1024 allot
Create Directory 256 allot


: OpenDialog ( hWindow -- f )
        hWindow !
        OpenFilter  lpstrFilter !
        1 nFilterIndex !
        FileNames 1+  lpstrFile !
        1024 nMaxFile !
        Directory 1+  lpstrInitialDir !
        [ OFN_ALLOWMULTISELECT OFN_EXPLORER or OFN_PATHMUSTEXIST or OFN_SHAREAWARE or OFN_HIDEREADONLY or ] literal Flags !
        OFN  call GetOpenFileName
        ;

: GetNumberOfFiles ( -- n )
        0  Filenames 1+  dup c@
        IF  nFileOffset w@ +  BEGIN  swap 1+ swap  zcount  + 1+  dup c@ 0= UNTIL
        THEN drop ;

: SaveDirectory ( -- )   \ place directory selected in Directory ready for next time dialog is opened
        FileNames 1+  nFileOffset w@ 1- 0max  Directory place  Directory +null ;

: GetNextFile ( -- File$ )   \ place next file in FileNames ready for next time dialog is opened
        FileNames 1+ nFileOffset w@ + zcount  dup 1+ nFileOffset w+!
        dup IF  FileNames place  0 FileNames count + w!  FileNames  ELSE  nip  0 nFileOffset w!  THEN ;

Create FindFile 256 allot
Create NextFile 256 allot
Create PrevFile 256 allot
true value forwards

: MakeNextFile ( -- )   \ put full filename from _win32-find-data structure into NextFile
        11 cells+ zcount
        FindFile count "path-only" NextFile place  NextFile ?+\  NextFile +place ;

: SetNextFile ( -- )   \ wrap round to first file
        find-next-file  0=
        IF  MakeNextFile
        ELSE
            find-close 2drop  FindFile count find-first-file 0=
            IF  MakeNextFile  ELSE  drop 0 NextFile c!  THEN
        THEN ;

: GNextFile ( -- FileName$ )
        CurrentFile  dup count "path-only" FindFile place FindFile ?+\
        s" *" FindFile +place  count ".ext-only" FindFile +place  \ findfile count type
        FindFile count find-first-file  0=  CurrentFile c@ 0= not and
        IF
            MakeNextFile
            BEGIN  NextFile count CurrentFile count Caps-Compare  NextFile c@ 0= not and
            WHILE  SetNextFile
            REPEAT  SetNextFile
        ELSE  drop 0 NextFile c! ( ." fail" ) THEN
        find-close drop  NextFile ;

: GPrevFile ( -- FileName$ )
        CurrentFile  dup count "path-only" FindFile place FindFile ?+\
        s" *" FindFile +place  count ".ext-only" FindFile +place
        FindFile count find-first-file  0=  CurrentFile c@ 0= not and
        IF
            MakeNextFile
            NextFile count PrevFile place SetNextFile
            BEGIN  NextFile count CurrentFile count Caps-Compare  NextFile c@ 0= not and
            WHILE  NextFile count PrevFile place SetNextFile
            REPEAT
        ELSE  drop 0 NextFile c!  THEN
        find-close drop  PrevFile ;

: FullPath ( a n -- FullFileName$ )   Directory count pad place  pad ?+\  pad +place  pad ;

: OpenFiles ( -- )
        True to Continue
        SaveDirectory
        BEGIN  GetNextFile  Continue and  ?dup
        WHILE  count FullPath IDM_OPEN_FILE DoCommand
        REPEAT ;

: GetFileType ( n -- a n )   6 *  dup FileTypes count rot  < IF nip 0  ELSE  +  5  THEN ;

: OpenAllPictureFiles ( -- )
        True to Continue
        0 BEGIN  dup GetFileType dup WHILE
            FullPath count find-first-file BEGIN  0= Continue and  WHILE
                11 cells+  zcount FullPath IDM_OPEN_FILE DoCommand find-next-file REPEAT
            find-close  2drop 1+
        REPEAT 3drop ;

: OpenDirectory ( -- )   SaveDirectory  OpenAllPictureFiles ;

: OpenCurrentDirectory ( -- )   CurrentFile count "path-only" Directory place  OpenAllPictureFiles ;

: AllPictureFiles? ( -- f )
        FileNames 1+ nFileOffset w@ + zcount s" All Picture Files" compare 0= ;

: SaveDialog ( hWindow -- f )
        hWindow !
        SaveFilter  lpstrFilter !
        1 nFilterIndex !
        FileNames 1+  lpstrFile !
        512 nMaxFile !
        Directory 1+  lpstrInitialDir !
        [ OFN_PATHMUSTEXIST OFN_SHAREAWARE or OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT or ] literal Flags !
        OFN  call GetSaveFileName
        ;
