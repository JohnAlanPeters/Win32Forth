\ $Id: MdiDialog.f,v 1.3 2006/01/13 12:07:28 georgeahubert Exp $

\ G.Hubert Saturday, July 17 2004 - 21:07

\ *D doc\classes\
\ *! MdiDialog W32F MdiDialog
\ *T MdiDialog -- Class for MDI windows containing controls.

\ *P MdiDialogWindows can be designed with ForthForm.

\ *P The file MdiDialog.f in the src\lib folder is not loaded by default. The file Mdi.f
\ ** is automatically loaded with this file if not already included.

needs mdi.f

\ *S Glossary

:CLASS MdiDialogWindow   <Super MdiChildWindow
\ *G Base class for Multi-document interface (MDI) child windows that contain controls.

:M ClassInit: ( -- )
\ *G Initialise the class.
        ClassInit: super +dialoglist ;M

:M ~:    ( -- )
\ *G Destructor method called when a dynamic object is freed by DISPOSE.
       -dialoglist ~: super ;M

;Class

\ *Z
