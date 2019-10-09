\ $Id: Meta.f,v 1.3 2008/08/09 23:13:08 camilleforth Exp $
\ Convenience loader for meta compiler.


\ *********************** THIS IS THE MAIN LOAD FILE ***************************
\
\ Usage: win32for.exe fload src\kernel\meta.f [ SetSize ] bye
\ ( SetSize is used to change app, sys and code sizes)
\
\ meta.f does the following :
\  - set filenames to load
\  - loads version.f
\  - loads metadlg.f
\  - if SetSize was used in commandline, run the metadlg
\  - loads meta-compiler.f
\  - loads fkernext.f
\  - loads fkernel.f (the kernel source)
\  - resolve kernel words
\ ******************************************************************************


cr .( Loading FKERNEL compiler...)

ANEW -META.F

ONLY FORTH ALSO DEFINITIONS ALSO VIMAGE

\ Default files for meta-compile
\ to permit dialog to change

DEFER KERN-NAME HERE DOVAR , ," FKERNEL.EXE" IS KERN-NAME
DEFER KERN-SRC  HERE DOVAR , ," SRC\KERNEL\FKERNEL.F"   IS KERN-SRC
DEFER KERN-NEXT HERE DOVAR , ," SRC\KERNEL\FKERNEXT.F"  IS KERN-NEXT
DEFER KERN-VER  HERE DOVAR , ," SRC\KERNEL\VERSION.F"   IS KERN-VER
DEFER KERN-DLG  HERE DOVAR , ," SRC\KERNEL\METADLG.F"   IS KERN-DLG
DEFER KERN-CMP  HERE DOVAR , ," SRC\KERNEL\META-COMPILER.F" IS KERN-CMP

0x400000 TO IMAGE-ORIGIN   \ where target image will run
GUI      TO EXETYPE        \ default is a gui
TRUE VALUE IMAGE-SAVE      \ we want to save the image

FPATH+ SRC\KERNEL

fload meta-fkernel         \ compile the kernel

