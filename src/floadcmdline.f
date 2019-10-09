\ $Id: floadcmdline.f,v 1.8 2011/11/18 14:19:06 georgeahubert Exp $

Anew -FloadCmdLine

\ *D doc\
\ *! FloadCmdLine
\ *T Experimental shell integration for Win32Forth

\ ** \nFloadCmdLine allows compiling from the context menu.
\ ** \nUse CMenuExtender v1.2.1.2 to create a new context entry.
\ ** \nThe CMenuExtender can be downloaded from:
\ *W <a href="http://www.monctoncomputerservice.com/revenger_inc/download.html">here.</a>

\ *P \bHow it works when Win32Forth is in c:\win32forth :\d

\ ** \n1.Start CMExtEd.
\ ** \n2.Create a New item for Win32Forth using the Custom Command option.
\ ** \n3.Caption: Win32Forth.
\ ** \n4.Command: c:\win32forth\Win32for.exe
\ ** \n5.commandline: FloadCmdLine
\ ** \n6.Activate: Append file.
\ ** \n7.Icon: Choose a nice Icon and Click op OK
\ ** \n8.Use change to check it.
\ ** \n9.Fload c:win32forth\src\FloadCmdLine.f
\ ** \n10.Copy c:\win32forth\src\Win32for.exe  to  c:\win32forth\Win32for.exe
\ ** \n11.Overwrite the orginal version.
\ ** \n12.Then start the explorer and click right on a *.f file.
\ ** \n13.Choose Win32Forth.

\ *P \bNotes:\d
\ ** \n1.Only testet under XP.
\ ** \n2.It is also possible to add WinEd to the context menu.
\ ** Then leave the commandline in CMExtEd empty and activate: Append file.

in-system

: FloadCmdLine ( - )
\ *G  Compiles the file in the command line.

    cmdline ascii " scan 1 - swap 1+ swap 2dup
    "path-only" temp$ place
    temp$ +null  temp$ count 2dup "chdir type
    cr cmdline type cr
    1 - "fload ok quit
 ;

in-application

fsave Win32for
fload lib\Resources.f
s" src\res\Win32For.ico" s" Win32for.exe" AddAppIcon

1 pause-seconds
bye

\ *Z
