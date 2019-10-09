\ $Id: Volinfo.f,v 1.4 2011/08/19 21:23:24 georgeahubert Exp $

cr .( Loading Volinfo.f : drive information...)


anew -Volinfo.f


string: RootPathName            \ root directory of the file system
string: VolumeNameBuffer        \ name of the volume
\ 0 value nVolumeNameSize       \ length of lpVolumeNameBuffer
0 value VolumeSerialNumber      \ serial number
0 value MaximumComponentLength  \ maximum filename length
0 value FileSystemFlags         \ file system flags
string: FileSystemNameBuffer    \ file system
\ 0 value nFileSystemNameSize   \ FileSystemNameBuffer

\ nFileSystemNameSize  nVolumeNameSize are not filled


:  DriveType$    ( DriveType - DriveType$ cnt )
        case
        DRIVE_UNKNOWN           of      s" Unknown"                     endof
        DRIVE_NO_ROOT_DIR       of      s" Invalid, or not mounted"     endof
        DRIVE_REMOVABLE         of      s" Removable"                   endof
        DRIVE_FIXED             of      s" Fixed"                       endof
        DRIVE_REMOTE            of      s" Remote"                      endof
        DRIVE_CDROM             of      s" Cd/Dvd"                      endof
        DRIVE_RAMDISK           of      s" Ram"                         endof
        s" unknown" rot
        endcase
  ;

\ Not yet implemented:
\ To determine whether a drive is a USB-type drive,
\ call SetupDiGetDeviceRegistryProperty and
\ specify the SPDRP_REMOVAL_POLICY property.

: GetVolumeInformation  ( RootPath count - DriveType$ flag )
   RootPathName place RootPathName +null  \ A UNC name (ROOTpath) should still be possible
   RootPathName 2 + 2 s" :\" compare 0=
        if   0 RootPathName 4 + !  3 RootPathName c!  \ Change a full path into a ROOTpath
        then
   0 to FileSystemFlags  0 to MaximumComponentLength
   RootPathName 1+ dup>r call GetDriveType
   FileSystemNameBuffer erase$  VolumeNameBuffer erase$  0 to VolumeSerialNumber
   pad FileSystemNameBuffer
   [ &of FileSystemFlags  ]   literal   [ &of MaximumComponentLength ] literal
   [ &of VolumeSerialNumber ] literal
   pad cell+  VolumeNameBuffer
   r> call GetVolumeInformation
 ;

: y/n-box  ( szText szTitle  - button )
    [ MB_YESNO MB_ICONQUESTION or MB_TASKMODAL or ] literal
    NULL MessageBox ;

:  RetrieveVolumeInformation ( RootPath count - DriveType$  )
        begin   2dup GetVolumeInformation dup 0=
        while   nip (?WinError)  z" Continue ? "
                z" Error while retrieving information"  y/n-box  IDNO =
                if    2drop DRIVE_UNKNOWN exit
                then
        repeat
    drop nip nip
 ;

: VolumeLabel ( RootPath count - DriveType adr cnt  )
   RetrieveVolumeInformation  VolumeNameBuffer zcount
 ;

: .Volume  ( RootPath count - )
    RetrieveVolumeInformation
    cr
    cr ." Volume information of "  RootPathName  count type
    cr  ." Type: " DriveType$ type
       ."  Serialnumber: " VolumeSerialNumber  .
    cr ." File system: " FileSystemNameBuffer   zcount type
       ."  Maximum length of a filename: "  MaximumComponentLength  .
    cr ." System flags: " FileSystemFlags dup .
       ." Filecompression is by windows is "  FS_FILE_COMPRESSION and 0=
                if   ." not "
                then ." possible"
    cr ." Label: " VolumeNameBuffer   zcount type
 ;

\s Use:
current-dir$ count .Volume
s" c:\" VolumeLabel type .

\s

