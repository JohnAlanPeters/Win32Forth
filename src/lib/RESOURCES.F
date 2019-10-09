\ $Id: RESOURCES.F,v 1.11 2013/12/09 19:42:00 georgeahubert Exp $
\                       Utilities to copy, add and enumerate resources in .dll and .exe files.
\                       Rod Oakford Feb 2005  ****Does not work in Win98, need NT, Win2k or later****
\
\                       s" Filename" ListResources enumerates all the resources
\                       e.g. s" w32fconsole.dll" ListResources will show the resources in w32fconsole.dll
\
\                       s" Filename" SourceFile sets the file to copy resources from
\                       s" Filename" ReplaceFile sets the file to replace resources into
\                       s" Filename" AddToFile sets the file to add resources into
\
\                       UpdateFile will add/replace the resources having used:
\
\                       CopyResource (need correct ID's)
\                       CopyIcon
\                       CopyCursor
\                       AddResource (putting all of the file data into the resource)
\                       AddIcon
\                       AddCursor
\                       AddBitmap
\
\                       EXAMPLES:
\
\                       s" Kernel.bin" SourceFile
\                       s" Win32For.exe" ReplaceFile
\                       100 CopyIcon
\                       UpdateFile
\                       will copy the icon (old Win32For.ico) from Kernel.bin into Win32For.exe
\
\                       s" Win32For.exe" ReplaceFile
\                       100 s" Win32For.ico" AddIcon
\                       UpdateFile
\                       will add the icon file Win32For.ico to Win32For.exe with ID 100
\
\                       s" Win32For.exe" ReplaceFile
\                       UpdateFile
\                       will remove all resources from Win32For.exe
\
\                       use s" Win32For.exe" AddToFile to add to the resources rather than delete exixting resources
\
\                       the Language identifier can be set in LanguageID, eg. 2057 to LanguageID for English (UK)
\
\ Changes:
\ Samstag, Juni 04 2005 dbu - Check of the Windows version added
\                           - AddAppIcon and LoadAppIcon added
\                           - ReadFile renamed to ReadResFile
\                           - moved most of the code into system space

cr .( Loading Resources Utility...)

anew -Resources.f

in-system
internal

version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then]
[if]  \ For V6.xx.xx older OSs

cr .( Sorry the Resources Utility requires Windows NT4, 2K or better.)

[else] \ For future V7.xx.xx and above made conditional for now.

5 proc EnumResourceLanguages
4 proc EnumResourceNames
3 proc EnumResourceTypes
1 proc LoadLibrary
1 proc FreeLibrary
2 proc EndUpdateResource
3 proc FindResource
2 proc LoadResource
1 proc LockResource
2 proc SizeofResource
6 proc UpdateResource
2 proc BeginUpdateResource
6 proc LoadImage
2 proc LoadIcon

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Accessing the resource structures \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Create SourceFileName 256 allot
Create UpdateFileName 256 allot
Create ResourceFileName 256 allot
0 value (NextResID)   \ first resource ID will be 1 unless otherwise set
: NextResID ( -- n )   (NextResID) 1+ dup to (NextResID) ;
0 value LanguageID     \ Language identifier
0 value hExe      \ handle of file to copy resources from
0 value ResData   \ pointer to resource data
0 value ResSize   \ size of resource
0 value hUpdate   \ handle of file to update resources in
0 value GroupResData   \ pointer to resource data for GroupIcon or GroupCursor
: DirEntries ( -- a )   GroupResData 6 + ;   \ address of Group Directory entries
: Entries ( -- n )   DirEntries 2 - w@ ;   \ number of entries in group directory
: nDirEntry ( i -- a )   14 * DirEntries + ;   \ address of directory entry for nth resource in group
: nPlanes ( i -- a )   nDirEntry 4 + ;   \ address of Color Planes (and Bits per pixel) for icons or HotSpot for cursors
: nBytesInRes ( i -- a )   nDirEntry 8 + ;   \ address of size of nth resource in group
: nImageOffset ( i -- a )   nDirEntry 12 + ;   \ address of offset for data of nth resource in file or ID
: nHotSpot ( i -- n )   nPlanes @ ;   \ HotSpot for nth cursor in group
: nSize ( i -- n )   nBytesInRes @ ;   \ size of nth resource in group
: nID ( i -- ID )   nImageOffset w@ ;   \ ID of nth resource in group
: GroupResSize ( -- n )   Entries 14 * 6 + ;   \ size of Group Resource data
0 value FileData
0 value FileSize
: nImageAddress ( i -- a )   8 * FileData FileSize + + ;   \ to store HotSpots and ImageAddresses at end of file data


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Messages \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

[UNDEFINED] Messagebox [IF]
4 proc MessageBox
: MessageBox  ( szText szTitle style hOwnerWindow -- result )
        >r  3reverse r>
        Call MessageBox ;   [THEN]

: ResourceString ( n -- a n )   dup word-split nip if zcount else (.) then ;

: UpdateMessage ( File$ -- n )   \ IDYES or IDNO
        s" Do you want to save the resources into:\n" pad place
        count pad +place  s" ?" pad +place  pad count asciiz
        z" Update Resources"  MB_ICONEXCLAMATION MB_YESNO or  NULL  MessageBox ;
: SourceFileError ( File$ -- )
        s" Unable to open:\n" pad place  count pad +place  pad count asciiz
        z" Source File" MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;
: ResourceFileError ( File$ -- )
        s" Invalid data in:\n" pad place  count pad +place  pad count asciiz
        z" Resource File" MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;
: UpdateFileError ( File$" -- )
        s" Unable to open:\n" pad place  count pad +place  pad count asciiz
        z" Update File" MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;
: UpdateResourceError ( ID -- )
        s" Failed to update resource " pad place  ResourceString pad +place  pad count asciiz
        z" Update Resource" MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;
: LoadResourceError ( ID -- )
        s" Failed to load resource " pad place  ResourceString pad +place  pad count asciiz
        z" Load Resource" MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Enumerating resources in .exe and .dll files \\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: .ResourceType ( n -- )
        Case
            RT_ACCELERATOR   of  s" RT_ACCELERATOR"  ( Accelerator table )                      Endof
            RT_ANICURSOR     of  s" RT_ANICURSOR"  ( Animated cursor )                          Endof
            RT_ANIICON       of  s" RT_ANIICON"  ( Animated icon )                              Endof
            RT_BITMAP        of  s" RT_BITMAP"  ( Bitmap resource )                             Endof
            RT_CURSOR        of  s" RT_CURSOR"  ( Hardware-dependent cursor resource )          Endof
            RT_DIALOG        of  s" RT_DIALOG"  ( Dialog box )                                  Endof
            RT_FONT          of  s" RT_FONT"  ( Font resource )                                 Endof
            RT_FONTDIR       of  s" RT_FONTDIR"  ( Font directory resource )                    Endof
            RT_GROUP_CURSOR  of  s" RT_GROUP_CURSOR"  ( Hardware-independent cursor resource )  Endof
            RT_GROUP_ICON    of  s" RT_GROUP_ICON"  ( Hardware-independent icon resource )      Endof
            RT_ICON          of  s" RT_ICON"  ( Hardware-dependent icon resource )              Endof
            RT_MENU          of  s" RT_MENU"  ( Menu resource )                                 Endof
            RT_MESSAGETABLE  of  s" RT_MESSAGETABLE"  ( Message-table entry )                   Endof
            RT_RCDATA        of  s" RT_RCDATA"  ( Application-defined resource {raw data} )     Endof
            RT_STRING        of  s" RT_STRING"  ( String-table entry )                          Endof
            RT_VERSION       of  s" RT_VERSION"  ( Version resource )                           Endof
            ( default )      dup ResourceString rot
        EndCase
        Type ;

: .ResourceName ( n -- )   ResourceString type ;

: .Language ( n -- )
        Case
            4105  of s" English (Canada)"   Endof
            1033  of s" English (U.S.)"     Endof
            2057  of s" English (U.K.)"     Endof
            1024  of s" Neutral (Default)"  Endof
            1031  of s" German (Germany)"   Endof
            0     of s" Neutral"            Endof
            ( default )  dup (.) rot
        EndCase
        Type ;

5 CallBack: GetResLang { hExe ResourceType ResourceName Language l  -- f }   Language to LanguageID  false ;
: ResourceLanguage ( ResourceName ResourceType -- )
        2>r 0 &GetResLang 2r> hExe call EnumResourceLanguages drop LanguageID ;

5 CallBack: EnumResLang { hExe ResourceType ResourceName Language l  -- f }
        ."   Language: "  Language .Language  true ;
: EnumResourceLanguages ( ResourceName ResourceType -- )
        2>r 0 &EnumResLang 2r> hExe call EnumResourceLanguages drop ;

4 CallBack: EnumResName { hExe ResourceType ResourceName l  -- f }
        cr ." ID: "  ResourceName .ResourceName  ResourceName ResourceType EnumResourceLanguages  true ;
: EnumResourceNames ( ResourceType -- )
        >r 0 &EnumResName r> hExe call EnumResourceNames drop ;

0 value ResourceNumber
3 CallBack: EnumResType { hExe ResourceType l  -- f }   1 +to ResourceNumber
        cr cr  ResourceType dup  .ResourceType  EnumResourceNames  true ;
: EnumResources ( -- )
        0 &EnumResType hExe call EnumResourceTypes drop ;

: CloseSourceFile ( -- )   hExe call FreeLibrary drop  0 to hExe ;

external

: SourceFile ( s" Filename" -- )
        2dup SourceFileName place  asciiz call LoadLibrary to hExe
        hExe 0= IF  SourceFileName SourceFileError  abort  THEN ;

: ListResources ( s" Filename" -- )
        SourceFile
        0 to ResourceNumber
        cr ." Enumerating resources in "  SourceFileName count type
        EnumResources
        CloseSourceFile
        cr  ResourceNumber 0= IF  ." No resources" cr  THEN ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Copying resources from .exe and .dll files \\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: EndUpdate ( f -- )   \ TRUE=no changes are made to the executable file, FALSE=the changes are made
        hUpdate call EndUpdateResource drop
        CloseSourceFile ;

: UpdateFile ( -- )   \ ask whether to update resources
        UpdateFileName UpdateMessage  IDYES =
        IF  cr ." Resources updated in " UpdateFileName count type  cr  false
        ELSE  cr ." Update abandoned" cr  true
        THEN EndUpdate ;

: LoadResource ( ID ResourceType -- )
        hExe 0= IF  cr ." No source file to copy from"  abort  THEN
        over hExe call FindResource
        dup hExe call LoadResource call LockResource to ResData
        dup hExe call SizeofResource to ResSize
        IF  drop
        ELSE  LoadResourceError  true EndUpdate  abort
        THEN ;

: UpdateResource ( ID ResourceType -- )
        2dup 2>r ResSize ResData LanguageID
        2r> hUpdate call UpdateResource
        IF    cr .ResourceType  cr  ." ID: " .ResourceName  ."   Size: " ResSize .  cr
        ELSE  UpdateResourceError  true EndUpdate  abort
        THEN  ( ResData ResSize 64 min dump cr ) ;

: BeginUpdate ( s" UpdateFileName" flag -- )   \ TRUE=existing resources are deleted,
        >r  UpdateFileName place  r>           \ FALSE=the updated executable file includes existing resources
        UpdateFileName count asciiz call BeginUpdateResource to hUpdate
        hUpdate 0= IF  UpdateFileName UpdateFileError  CloseSourceFile  abort  THEN ;

: ReplaceFile ( s" Filename" -- )   TRUE BeginUpdate ;   \ TRUE=existing resources are deleted

: AddToFile ( s" Filename" -- )   FALSE BeginUpdate ;   \ FALSE=existing resources are kept

: CopyResource ( ID ResourceType -- )
        2dup ResourceLanguage drop  2dup LoadResource  UpdateResource ;

: CopyIcon ( ID -- )
        RT_GROUP_ICON CopyResource
        ResData to GroupResData
        Entries 0 DO  i nID  RT_ICON  CopyResource  LOOP ;

: CopyCursor ( ID -- )
        RT_GROUP_CURSOR CopyResource
        ResData to GroupResData
        Entries 0 DO  i nID  RT_CURSOR  CopyResource  LOOP ;

: CopyBitmap ( ID -- )   RT_BITMAP CopyResource ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Adding resources from .bmp, .ico and .cur files \\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: ReadResFile ( s" filename" -- )
        2dup ResourceFileName place
        r/o open-file IF  ResourceFileName SourceFileError true EndUpdate  abort  THEN  >r
        r@ file-size 2drop to FileSize          \ the bmp length
        Here to FileData
        FileData FileSize r@ read-file 2drop    \ read the bmp file
        r> close-file drop ;                    \ close file

: AddResource ( ID ResourceType s" filename" -- )
        ReadResFile
        FileData to ResData
        FileSize to ResSize
        0 to LanguageID
        UpdateResource
        ;

: AddBitmap ( ID s" filename" -- )
        ReadResFile
        FileData w@ 19778 <> IF  ResourceFileName ResourceFileError  true EndUpdate  abort  THEN
        FileData 14 + to ResData
        FileSize 14 - to ResSize
        0 to LanguageID
        RT_BITMAP UpdateResource
        ;

: IconFileData>ResData ( -- )   \ move group directory data truncating to 14 bytes per entry rather than 16
        Entries 0 DO
            i nDirEntry i 2* +  i nDirEntry 16 move
            i nImageOffset @ GroupResData + i nHotSpot  i nImageAddress 2!   \ store HotSpots and ImageOffsets temporarily at end of file data
            i nImageOffset @ DirEntries + 6 + @  i nPlanes !   \ add Color Planes and Bits per pixel to dir entry
            NextResID i nImageOffset w!   \ replace ImageOffset with ID
        LOOP ;

: CursorFileData>ResData ( -- )   \ move group directory data truncating to 14 bytes per entry rather than 16
        Entries 0 DO
            i nDirEntry i 2* +  i nDirEntry 16 move
            i nImageOffset @ 4 - GroupResData + i nHotSpot  i nImageAddress 2!   \ store HotSpots and ImageOffsets temporarily at end of file data
            i nDirEntry c@  i nDirEntry 1+ c@  i nDirEntry 2 + w!  i nDirEntry w!   \ width and height change to 2 bytes each
            i nImageOffset @ DirEntries + 6 + @  i nPlanes !   \ add Color Planes and Bits per pixel to dir entry
            NextResID i nImageOffset w!   \ replace ImageOffset with ID
            4  i nBytesInRes  +!   \ add 4 to ResSize to allow for Hotspot
        LOOP ;

: AddIcon ( ID s" filename" -- )
        ReadResFile
        FileData @ 65536 <> IF  ResourceFileName ResourceFileError  true EndUpdate  abort  THEN
        FileData to GroupResData
        IconFileData>ResData
        GroupResData to ResData
        GroupResSize to ResSize
        0 to LanguageID
        RT_GROUP_ICON UpdateResource
        Entries 0 DO  i nSize to ResSize  i nImageAddress 2@ swap to ResData drop
            i nID RT_ICON UpdateResource  LOOP ;

: AddCursor ( ID s" filename" -- )
        ReadResFile
        FileData @ 131072 <> IF  ResourceFileName ResourceFileError  true EndUpdate  abort  THEN
        FileData to GroupResData
        CursorFileData>ResData
        GroupResData to ResData
        GroupResSize to ResSize
        0 to LanguageID
        RT_GROUP_CURSOR UpdateResource
        Entries 0 DO  i nSize to ResSize  i nID  i nImageAddress 2@ swap to ResData ResData !
            RT_CURSOR UpdateResource  LOOP ;

[then]

\ ------------------------------------------------------------------------------
\ Some helper words for adding the Icon for a Application
\ ------------------------------------------------------------------------------

in-application

create AppIcon max-path allot

in-system
external

version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then]
[if]  \ For V6.xx.xx older OSs
\ Add the Icon filename1 to the Application filename2
: AddAppIcon    ( s" filename1" s" filename2" -- )
        2drop AppIcon place ;

[else]

\ returns true if we can add the icon to the file
: AddAppIcon?   ( addr len -- f )
        r/w open-file 0= dup
        if   swap close-file drop
        else nip
        then ;

\ Add the Icon filename1 to the Application filename2
: AddAppIcon    ( s" filename1" s" filename2" -- )
	2swap "path-file drop 2swap \ look in the Forth-search-path for the icon-file
        2dup AddAppIcon?
        if   ReplaceFile
             2dup 101 -rot AddIcon
             false EndUpdate
        else 2drop
        then AppIcon place ;

[then]

in-application

[undefined] LoadIconFile [if]
: LoadIconFile  ( adr len -- hIcon ) \ load an icon from a ico-file
                asciiz >r LR_LOADFROMFILE 0 0 IMAGE_ICON r> NULL call LoadImage ;
[then]

\ Load the Icon for the application
: LoadAppIcon   ( -- hIcon )
        101 appinst call LoadIcon ?dup 0=
        if   AppIcon count LoadIconFile
        then ;

module

\s \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Examples \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ If you want to add resources to Win32For.exe make a copy of it first then run the copy to
\ fload this file because you can't add resources into Win32For.exe while it is running.

: L1    s" Win32For.exe" ListResources ;
: L2    s" zip32.dll" ListResources ;
: L3    s" w32fconsole.dll" ListResources ;
: L4    s" w32fHtmlDisplay.dll" ListResources ;
: L5    s" w32fScintilla.dll" ListResources ;
: L6    s" Wincon.dll" ListResources ;
: L7    s" Kernel.bin" ListResources ;

: C0    \ add WinEd.ico to Win32For.exe, deleting all other resources
        s" Win32For.exe" ReplaceFile
        101 s" src\res\WinEd.ico" AddIcon
        UpdateFile
        L1
        ;

: C1    \ add Win32For.ico to Win32For.exe, see the icon in explorer change
        s" Win32For.exe" AddToFile
        100 s" src\res\Win32For.ico" AddIcon
        UpdateFile
        L1
        ;

: D1    \ remove all resources from Win32For.exe
        s" Win32For.exe" ReplaceFile
        UpdateFile
        L1 ;

: C2    \ copy all PictureViewer resources
        s" Kernel.bin" SourceFile
        s" PictureViewer.exe" ReplaceFile
        100 CopyIcon
        101 CopyIcon
        139 CopyIcon
        140 CopyIcon
        141 CopyIcon
        142 CopyIcon
        143 CopyIcon
        144 CopyIcon
        145 CopyIcon
        146 CopyIcon
        147 CopyIcon
        148 CopyIcon
        114 CopyCursor
        115 CopyCursor
        116 CopyCursor
        119 CopyCursor
        120 CopyCursor
        149 CopyCursor
        150 CopyCursor
        151 CopyCursor
        UpdateFile
        s" PictureViewer.exe" ListResources
        ;

: D2    \ remove all resources from PictureViewer.exe
        s" PictureViewer.exe" ReplaceFile
        UpdateFile
        s" PictureViewer.exe" ListResources
        ;
