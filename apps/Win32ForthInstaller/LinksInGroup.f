Anew -LinksInGroup.f

s" apps\Setup" "fpath+

needs Setup_dtop_lnk.f
needs Mkdir.f

#define CSIDL_PROGRAMS	0x0002	\ <user name>\Start Menu\Programs

: create_link_group       ( name$ cnt -- dirSpec cnt )
        CSIDL_PROGRAMS GetSpecialFolderLocation link-location$ place
        s" \" link-location$ +place  link-location$ +place
        link-location$ count mkdir
 ;

: create_links_in_group   ( -- )
        init_dtop_for_link s" Win32Forth"   create_link_group
        create_links_in_location CoUninitialize
 ;

\s
