\ $Id: Setup_dtop_lnk.f,v 1.4 2016/01/11 20:06:49 jos_ven Exp $
\
\    File: Setup_dtop_lnk.f
\  Author: Dirk Busch (dbu)
\ Created: Sonntag, April 04 2004 - dbu
\ Updated: Samstag, Oktober 02 2004 - dbu

anew -Setup_dtop_lnk.f

needs dtop_lnk.f

: set-icon ( a1 n1 a2 n2 -- )  $concat set_icon_link ;

string: link-location$

: save-link-in-location { "Description"  lnk$  -- }
        link-location$ count  lnk$ PLACE
        lnk$ ?+\ "Description" count lnk$ +PLACE s" .lnk" lnk$ +PLACE
        lnk$ count save_link
 ;

: prepare-link { "FileName" "Description" "IconFileName" lnk$  \ dir$ path$  -- }
        1024 LocalAlloc: dir$
        1024 LocalAlloc: path$

        &FORTHDIR COUNT dir$ PLACE dir$ ?+\

        dir$ COUNT path$ PLACE "FileName" COUNT path$ +PLACE path$ +NULL
        "Description" COUNT lnk$ PLACE lnk$ +NULL

        lnk$ COUNT DROP path$ COUNT make_link
        dir$ COUNT "IconFileName" COUNT set-icon
        dir$ COUNT set_dir_link
 ;

: create_link_in_location  ( "FileName" "Description" "IconFileName" lnk$ -- ) { lnk$ -- }
        lnk$ 1024 LocalAlloc: lnk$  over >r lnk$ prepare-link
        r> lnk$ save-link-in-location
 ;

: create_links_in_location
        c" Win32for.exe"        c" Win32Forth"       c" src\res\Win32for.ico"   create_link_in_location
        c" WinEd.exe"           c" WinEd"            c" src\res\WinEd.ico"      create_link_in_location
\       c" Forthform.exe"       c" Forth Form"       c" src\res\ForthForm.ico"  create_link_in_location
        c" Setup.exe"           c" Win32Forth Setup" c" src\res\Win32for.ico"   create_link_in_location
\       c" Project.exe"         c" Forth Project"    c" src\res\Project.ico"    create_link_in_location
\       c" SciEditMdi.exe"      c" SciEditMdi"       c" src\res\SciEditMdi.ico" create_link_in_location
        c" Win32forthIDE.exe"   c" Win32forthIDE"    c" src\res\SciEditMdi.ico" create_link_in_location
 ;

: Set_desktop_location    ( -- )
        CSIDL_DESKTOPDIRECTORY GetSpecialFolderLocation  link-location$ place
 ;

: create_links_on_desktop ( -- )
        init_dtop_for_link   Set_desktop_location
        create_links_in_location CoUninitialize
 ;

\s

