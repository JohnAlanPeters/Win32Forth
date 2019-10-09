\ $Id: EdImageWindow.f,v 1.5 2011/08/19 12:59:47 georgeahubert Exp $

cr .( Loading Image Viewer...)

needs imagewindow.f

create imagefiles       \ image files that can be viewed
z," *.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.ico;*.pcd;*.psd;*.pcx;*.ppm;*.pgm;"
+z," *.pbm;*.png;*.ras;*.tga;*.tif;*.gif"

: is-image-file?    ( addr cnt -- f )
                    ".ext-only" dup       \ must have an extension
                    if      imagefiles zcount 2swap caps-search nip nip
                    else    2drop  false
                    then    ;

:Class ImageViewChild   <Super MDIChild

:M GetTextLength: ( -- n )
                0 ;M

:M Start:       ( parent -- )
                New> FreeImageWindow to ChildWindow
                self to ChildParent
                Start: super
                ;M

:M On_Close:    ( -- )
                On_Close: super
                self ActiveChild = if 0 to ActiveChild then
                UpdateStatusBar
                EnableToolbar
                ;M

:M GetFileName: ( -- addr )
                ImageFileName: ChildWindow new$ dup>r place
                r> ;M

:M SetWindowTitle: ( -- )
                GetFileName: self count SetText: super ;M

:M SetFileName: ( addr len -- )
                SetImageFile: ChildWindow
                SetWindowTitle: self
                UpdateFileName: super
                ;M

:M ?Modified:   ( -- f )
                false ;M

:M GetFileType: ( -- n )
                FT_BITMAP ;M

:M Update:      ( -- )
                ;M

;Class

: NewImageViewWnd  ( -- )
                New> ImageViewChild to ActiveChild
                MDIClientWindow: Frame Start: ActiveChild ;
