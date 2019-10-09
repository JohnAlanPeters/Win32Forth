\ $Id: ExtDC.f,v 1.1 2008/04/30 15:51:09 dbu_de Exp $

\ *D doc\classes\
\ *! ExtDC
\ *T ext-windc -- Extended WinDC class.
\ *S Glossary

cr .( Loading Extended device context class... )

only forth also definitions

in-application

require DC.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ ext-windc class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:class ext-windc <super windc
\ *G Extended version of the WinDC class.

int SavedState

:M ClassInit:   ( -- )
\ *G Init the class
                ClassInit: super
                0 to SavedState
                ;m

:M Destroy:     ( -- )
\ *G Destroy the device context.
                Valid?: super
                if   \ First we restore the state of the device context.
                     \ After that all gdi objects that are currently selected
                     \ into this dc can be saftly destroyd later!
                     SavedState Restore: self

                     GetHandle: super call DeleteDC ?win-error
                     0 PutHandle: super
                then ;M

:M SetHandle:   ( hObject -- )
\ *G Set the handle of the object.      \n
\ ** If the current handle of the object is valid it will be destroyed.
                Destroy: self
                PutHandle: super

                \ we save the state of the device contect here, so we
                \ can restore it later.
                Save: super to SavedState
                ;M

:M PutHandle:   ( hObject -- )
\ *G Set the handle of the object.      \n
\ ** If the current handle of the object is valid it will be destroyed.
                SetHandle: self ;m

:m ~:           ( -- )
\ *G Clean up on dispose.
                Destroy: self ;m

;class
\ *G End of ext-windc class

\ *Z
