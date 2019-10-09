\ $Id: RegistryWindowPos.f,v 1.4 2010/02/14 23:26:15 georgeahubert Exp $
\    File: RegistryWindowPos.f
\  Author: Dirk Busch
\ Created: Samstag, Mai 29 2004 - 11:25 - dbu
\ Updated: Sonntag, Juli 04 2004 - 13:42 - dbu

ANEW -RegistryWindowPos.f

needs GetWindowPlacment.f

INTERNAL

: "GetDefault   ( a1 n1 -- a2 n2 )
                s" Settings" RegGetString ;

: "SetDefault   ( a1 n1 a2 n2 -- )
                s" Settings" RegSetString ;

: "GetDefaultValue ( addr n -- n1 flag ) \ read a value from registry
                "GetDefault dup
                if   number? >r d>s r>
                else 2drop 0 false
                then ;

: GetWindowRect ( hWnd -- x y w h )
                EraseRect: tempRect
                tempRect swap Call GetWindowRect ?win-error
                Left:  tempRect Top:    tempRect
                Right: tempRect Bottom: tempRect ;

create progreg$ MAX-PATH allot

: SaveRegistryPath ( -- )
                progreg count progreg$ place ;

: RestoreRegistryPath ( -- )
                progreg$ count progreg place ;

: SetRegistryPath ( a1 -- )
                SaveRegistryPath
                PROGREG-SET-BASE-PATH
                count progreg +place ;

EXTERNAL

: SaveWindowPos ( hWnd regpath$ \ -- )
                SetRegistryPath

                dup GetWindowPlacment
                showCmd @ SW_MINIMIZE and 0=
                IF   GetWindowRect ( l t r b )
                      2over       s>d (d.) s" WindowTop"    "SetDefault
                                  s>d (d.) s" WindowLeft"   "SetDefault

\ Added correction for height and width. I'm not shure why this is needed
\ and if it's correct for all windows versions but it works for me under w2k.
\ Sonntag, Juli 04 2004 - 13:42 dbu
                      rot -
                      SM_CYCAPTION   call GetSystemMetrics
                      SM_CYSIZEFRAME call GetSystemMetrics 2* + -
                      s>d (d.) s" WindowHeight" "SetDefault

                      swap -
                      SM_CXSIZEFRAME call GetSystemMetrics 2* -
                      s>d (d.) s" WindowWidth"  "SetDefault
                THEN

                RestoreRegistryPath ;

: LoadWindowPos ( regpath$ -- x y w h )
                SetRegistryPath

                s" WindowLeft"   "GetDefaultValue not IF drop 100 THEN
                s" WindowTop"    "GetDefaultValue not IF drop 200 THEN
                s" WindowWidth"  "GetDefaultValue not IF drop 400 THEN
                s" WindowHeight" "GetDefaultValue not IF drop 400 THEN

                RestoreRegistryPath ;

MODULE
