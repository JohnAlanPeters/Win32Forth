\ $Id: REGISTRY.F,v 1.9 2008/08/19 12:47:52 rodoakford Exp $
\
\ registry.f   The Registry Interface for Win32Forth            by Tom Zimmer
\
\         Andrew implemented the functionality in C, and I translated it
\         into Forth
\
\ 2002/08/31 arm (minor) use ANS file words replaceing FXXX-FILE
\ 2002/09/24 arm release for testing
\ 2002/10/08 arm Consolidation
\ 2003/09/08 dbu removed the registry entries 'Directory' and 'Version'
\ Sonntag, Dezember 26 2004 dbu mostly rewritten
\ Dienstag, Mai 24 2005 dbu
\   - Changed to work with Rod's RegistrySupport.f
\   - fixed a bug in (RegQueryValue)
\   - removed the deprecated words .REGISTRY and RE-REGISTER
\   - Expanded TAB's into spaces
\ Mittwoch, Mai 25 2005 dbu
\   - Some more changes to work with Rod's RegistrySupport.f

cr .( Loading Windows Registry...)

in-application

INTERNAL

5 proc RegOpenKeyEx
9 proc RegCreateKeyEx
1 proc RegCloseKey
6 proc RegQueryValueEx
6 proc RegSetValueEx

\ ************************************************************************************
\ Low level Registry words
\
\ With these words the complete registry can be accessed
\ ************************************************************************************

external

\ RegOpenKey opens the specified registry key
: (RegOpenKey)  { hKey lpSubKey samDesired \ hkResult -- hkResult }
                &OF hkResult samDesired 0 lpSubKey hKey
                call RegOpenKeyEx ERROR_SUCCESS =
                if hkResult else INVALID_HANDLE_VALUE then ;

\ RegCreateKey creates the specified registry key.
\ If the key already exists, it is opened.
: (RegCreateKey) { hKey lpSubKey samDesired \ Class Disposition hkResult -- hkResult }
                0 to Class
                0 to Disposition

                &OF Disposition         \ disposition value buffer
                &OF hkResult            \ key handle
                0                       \ inheritance
                samDesired              \ desired security access
                REG_OPTION_NON_VOLATILE \ special options
                &OF Class               \ class string
                0                       \ reserved
                lpSubKey                \ subkey name
                hKey                    \ handle to open key

                call RegCreateKeyEx ERROR_SUCCESS =
                if hkResult else INVALID_HANDLE_VALUE then ;

\ RegCloseKey releases a handle to the specified registry key
: (RegCloseKey) ( hKey -- f )
                call RegCloseKey ERROR_SUCCESS = ;

\ RegQueryValue retrieves the type and data for a specified value name
\ associated with an open registry key
: (RegQueryValue) { hKey lpValueName rType lpData lpcbData \ -- f }
                lpcbData lpData rType null
                lpValueName hKey call RegQueryValueEx ERROR_SUCCESS = ;

\ RegSetValue sets the data and type of a specified value under a registry key.
: (RegSetValue) { hKey lpValueName rType lpData cbData \ -- f }
                cbData lpData rType null
                lpValueName hKey call RegSetValueEx ERROR_SUCCESS = ;

\ ************************************************************************************
\ High level Registry words...
\ ************************************************************************************

\ Default registry key.  Change this string to put your programs registry
\ information in a place other than "Win32For\". Look for PROGREG in WinEd
\ for an example of how to change the program base registry key to a value
\ that will be specific not only to your program, but to the particular
\ directory instance of your program that is running.
create BaseReg ," SOFTWARE\" MAXSTRING allot-to
create ProgReg MAXSTRING allot

HKEY_CURRENT_USER value regBaseKey
KEY_ALL_ACCESS    value regAccessMask

: PROGREG-SET-BASE-PATH ( -- )
                s" Win32Forth " ProgReg place
                version# ((version)) ProgReg +place
                s" \" ProgReg +place ;

: PROGREG-INIT  ( -- )
                PROGREG-SET-BASE-PATH s" Win32For\" ProgReg +place
		HKEY_CURRENT_USER to regBaseKey
		KEY_ALL_ACCESS    to regAccessMask
		;

initialization-chain chain-add PROGREG-INIT
PROGREG-INIT

INTERNAL

variable regLen
variable regType
named-new$ ReturnedKey$

: BuildSection  ( sadr slen adr -- adr1 )
                >R
                BaseReg count r@  place
                ProgReg count r@ +place
                              r@ +place
                              r@ +NULL
                r> 1+ ;

\ sadr,slen = the registry section to get the key of  (for read accesss)
\ return -1 if we could not get the key
: RegGetKeyRead { sadr slen \ section$ -- regkey }  \ read the key of a section
                MAXSTRING 2 + LocalAlloc: section$
                regBaseKey
                sadr slen section$ BuildSection
                regAccessMask (RegOpenKey) ;

external

\ read registry key value string 'vadr,vlen'
\ from            section string 'sadr,slen'
\ return             data string 'dadr,dlen'

\ sadr,slen = the registry key section string
\ vadr,vlen = the registry key value string to read
\ dadr,dlen = the registry key data string returned
: RegGetString  { vadr vlen sadr slen -- dadr dlen }
                ReturnedKey$ off                \ initially clear return buffer

                sadr slen RegGetKeyRead dup INVALID_HANDLE_VALUE =
                if   drop ReturnedKey$ count regLen off regType off
                     EXIT \ return on error, empty data
                then

                dup
                vadr
                regType                   \ we get it, but we don't need it
                ReturnedKey$ 1+
                MAXCOUNTED regLen !             \ init max length of string
                regLen
                (RegQueryValue)

                if   regLen @ 1- 0max ReturnedKey$ c! \ make counted string
                else ReturnedKey$ off \ return empty data on error
                then (RegCloseKey) drop

                ReturnedKey$ count ;

internal

\ sadr,slen = the registry section to get the key of (for write accesss)
\ return -1 if we could not get the key
: RegGetKey     { sadr slen \ section$ -- regkey }  \ read the key of a section
                MAXSTRING 2 + LocalAlloc: section$
                regBaseKey
                sadr slen section$ BuildSection
                regAccessMask (RegCreateKey) ;

external

\ Write to the registry, a key value string 'vadr,vlen'
\ in                         section string 'sadr,slen'
\ the                           data string 'dadr,dlen'
: RegSetString  { dadr dlen vadr vlen sadr slen \ val$ khdl -- }

                sadr slen RegGetKey to khdl
                khdl INVALID_HANDLE_VALUE =
                if exit then \ just return, ignore error

                dlen 2 + LocalAlloc: val$    \ allocate a dynamic string
                dadr dlen val$ place
                          val$ +NULL

                khdl
                vadr
                REG_SZ                       \ type
                val$ 1+                      \ null terminated data string
                dlen 1+                      \ data length including NULL
                (RegSetValue) drop

                khdl (RegCloseKey) drop ;

: SetSetting    ( a1 n1 a2 n2 -- )      \ a1,n1=value string, a2,n2=key string
                s" Settings" RegSetString ;

: GetSetting    ( a1,n1 -- a2 n2 )      \ a1,n1-key string, a2,n2=value string
                s" Settings" RegGetString ;

INTERNAL
((
:noname         ( -- ) \ Write the current version into the registry.
                       \ Needed by the w32fConsole.dll to find the right
                       \ place to read/write from/into the registry
                s" Win32Forth" PROGREG place
                version# ((version)) s" CurrentVersion" s" "
                RegSetString \ dadr dlen vadr vlen sadr slen
                PROGREG-INIT ; is INIT-CONSOLE-REG
))
MODULE

\s      Example code for registry use

\ The following word is executed at compile time to setup the
\ current programs base registry key.

: app-key-init  ( -- )  \ intialize the program base registry key
                s" MyApplication\" progreg place

app-key-init

: test          ( -- )
                s" WindowPosition" GetSetting type ;

\ Write the 'WindowPosition" value in section 'Settins'
\ to a data string of '5,9' which would presumably be the x,y coordinate
\ of where the window should be placed next time the application starts up.

: test!         ( -- )
                s" 5,9" s" WindowPosition" SetSetting ;
