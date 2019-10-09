\ $Id: Win32Help.f,v 1.4 2008/05/15 04:51:23 camilleforth Exp $

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  Win32  Help system interface words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

cr .( Loading Win32 Help system interface... )

anew -Win32Help.f

internal
external

4 proc WinHelp

create help_file$ ," doc\hlp\win32.hlp" MAXSTRING allot-to

: $help-file    ( a1 -- )                \ set the name of the current help file
                help_file$ 256 erase     \ pre-clear help filename
                count help_file$ place ; \ lay in new filename

: .help         ( -- )                  \ display the current help file string
                cr ." HELP file: " help_file$ count type
                cr ." Use: 'HELP-FILE <filename>' to select another help file. " ;

: help-file     ( -<filename>- )        \ specify a new help filename
                /parse-s$ $help-file ;

\ synonym set-help help-file          \ made a colon def - [cdo-2008May13]
: set-help      \ synonym of HELP-FILE
                help-file ;

: $help         ( a1 -- )               \ help on a string
                1+                      \ help subject word
                HELP_PARTIALKEY         \ the command to the help system
                                        \ pointer to a help file string
                help_file$ 1+           \ the help file to use
                conHndl                 \ tell help its from our window
                call WinHelp drop ;

: #help         ( n1 -- )               \ help on a help context index number
                HELP_CONTEXT            \ the command to the help system
                help_file$ 1+           \ the help file to use
                conHndl                 \ tell help its from our window
                call WinHelp drop ;

: help          ( -<word>- )
                bl word $help ;         \ help subject word

: help-index    ( -- )
                0
                HELP_INDEX
                help_file$ 1+           \ the help file to use
                conHndl                 \ tell help its from our window
                call WinHelp drop ;

: help-on-help  ( -- )                  \ get help on windows help
                0
                HELP_HELPONHELP
                help_file$ 1+           \ the help file to use
                conHndl                 \ tell help its from our window
                call WinHelp drop ;

INTERNAL

: _help-release ( -- )                  \ release our marker to help system
                0                       \ NULL
                HELP_QUIT               \ the command to the help system
                0                       \ NULL pointer to a help file string
                conHndl
                call WinHelp drop ;

UNLOAD-CHAIN CHAIN-ADD-BEFORE _HELP-RELEASE       \ add to termination chain

EXTERNAL

MODULE


