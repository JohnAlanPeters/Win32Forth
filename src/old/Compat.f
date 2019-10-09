\ Compat.f
\ Here you'll find Words which were removed from Win32Forth for some reason

only forth also definitions

in-system

\ cd was removed because it's a valid HEX number
\ September 23rd, 2003 - 10:44 dbu
synonym cd chdir

\ B was removed because it's a valid HEX number
\ September 23rd, 2003 - 10:44 dbu
also hidden

: b             ( -- )          \ show the previous bunch of lines
\in-system-ok   cur-line @ locate-height 4 - - 0 max cur-file $locate ;

previous

\ E was removed because it's a valid HEX number
\ September 23rd, 2003 - 10:44 dbu
synonym e ed

in-application
