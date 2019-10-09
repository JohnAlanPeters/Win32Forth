\ HexViewer.F    Adapted from FileDump.f

cr .( Loading Hex Viewer...)

fload apps\promgr\hexviewer.f

: is-binary-file?   ( -- f )
                true       \ default
                GetBuffer: viewerfile 1000 min 0max     \ check first 1000 bytes
                bounds
                ?do     i c@ bl <
                        if      i c@ dup 0x0A <> over 0x0D <> and   \ not cr or lf
                                swap 0x09 <> and                    \ not tab char
                                if      unloop exit
                                then
                        then
                loop    not ;

:Class HexViewChild   <Super MDIChild

max-path 2 + bytes FileName

:M GetTextLength: ( -- n )
                0 ;M

:M Start:       ( parent -- )
                New> HexViewer to ChildWindow
                self to ChildParent
                0 FileName !
                Start: super
                ;M

:M On_Close:    ( -- )
                On_Close: super
                self ActiveChild = if 0 to ActiveChild then
                UpdateStatusBar
                EnableToolbar
                ;M

:M SetFileName: ( addr len -- )
                FileName place FileName +null
                UpdateFileName: super
                ;M

:M GetFileName: ( -- addr )
                FileName ;M

:M SetWindowTitle: ( -- )
                GetFileName: self count SetText: super ;M

:M ?Modified:   ( -- f )
                false ;M

:M GetFileType: ( -- n )
                FT_BINARY ;M

:M Update:      ( -- )
                ;M

:M Dump:        ( addr cnt -- )
                Dump: ChildWindow
                SetWindowTitle: self ;M

;Class

: NewHexViewWnd  ( -- )
    New> HexViewChild to ActiveChild
		MDIClientWindow: Frame Start: ActiveChild ;

\s
