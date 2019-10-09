\ $Id: version.f,v 1.25 2016/01/09 14:54:11 jos_ven Exp $

cr .( Loading META version info)

 61504     VALUE #VERSION#
\ 70000     VALUE #VERSION# \ For future V7.xx.xx testing

\ Change only the version number above; the build number is automatically assigned.
\ After changing the version number you must rebuild your complete Win32Forth
\ system (including WinEd and SciEdit). Because this Version number is used in
\ wm_win32for-init to create a unique message name.

VERSION# #VERSION# = [IF]
  build# 1+ VALUE #BUILD#
[ELSE]
  1         VALUE #BUILD#
[THEN]

\s <--- remember, this is code -- needed to stop!


Version numbers: v.ww.rr

v   Major version
ww  Minor version
rr  Release

Odd minor version numbers are possibly unstable beta test code.

--------------------------------  Change Log ----------------------------------------

changed in 6.09.02 to 6.09.13

a Lot of changes were made...

changed in 6.09.01

dbu October 25th, 2003   (various)  [ ------ ] renamed:
                                               console.dll to w32fConsole.dll
                                               print.dll to w32fPrint.dll
dbu October 24th, 2003   (various)  [ ------ ] Moved the cursors from the c-wrapper into
                                               the console.dll

changed in 6.09.00

dbu September 27th, 2003 (various)  [ ------ ] defered all 'console' related words
dbu September 28th, 2003 (various)  [ ------ ] moved the console from the c-wrapper
                                               into console.dll, and removed all
                                               xcalls for the console from the wrapper
dbu September 28th, 2003 (various)  [ ------ ] moved the print support from the c-wrapper
                                               into print.dll, and removed all
                                               xcalls for printing from the wrapper
dbu September 28th, 2003 (various)  [ ------ ] removed the last xcall for exit


changed in 6.08.00

changed in 6.07.15

dbu September 26th, 2003 (various)  [ ------ ] Added a status bar to the console window.
                                               It displays the current base and the stack
                                               contents. It's updated after each interpret.
                                               If you don't like it remove
                                               'FLOAD src\ConsoleStatBar.f' from extend.f
                                               and recompile w32f.
changed in 6.07.14

arm 25/09/2003 13:50:08  primhash.f [ ------ ] minor changes to speed up locals
arm 24/09/2003 22:31:28  fkernel.f  [ ------ ] minor changes to speed up locals
arm 24/09/2003 22:30:13  meta.f     [ ------ ] corrected ;CODE which was forcing a DROP
                                               in FKERNEL.F

dbu September 23rd, 2003 paths.f,
                         fkernel.f  [ ------ ] changed LINKFILE to store the file
                                               name's with full qualified paths
dbu September 23rd, 2003 paths.f,
                         fkernel.f  [ ------ ] moved current-dir$ and $current-dir!
                                               into the kernel
dbu September 23rd, 2003 paths.f,
                         utils.f    [ ------ ] removed the words CD E and B from
                                               the system, because they are valid
                                               HEX numbers.
                                               If you realy need them you'll find
                                               them in Compat.f
dbu September 22nd, 2003 paths.f,
                         fkernel.f  [ ------ ] changed LINKFILE to store the file
                                               name's relative to the current directrory
                                               (not vaild any longer September 23rd, 2003 - 10:43 dbu)
dbu September 22nd, 2003 paths.f,
                         fkernel.f  [ ------ ] fixed Prepend<home>\ and "LOADED? witch
                                               I broke in 6.07.13

arm September 21st, 2003 ASMWIN32.F [ ------ ] fixed FVALUE bug

changed in 6.07.13
dbu September 21st, 2003 (various)  [ ------ ] much work on the 'path and folder stuff'
                                               Now there is only one path list.
                         (various)  [ ------ ] added ForthForm to the CVS
                         setup.cfg  [ ------ ] added compilation of ForthForm
                         (various)  [ ------ ] moved WinEd related source files to 'src\wined\res'

changed in 6.07.12
dbu September 20th, 2003 button.f   [ ------ ] changed ClassInit: of the ToolBar class to use
                                               "open instead of open-file to open the toolbar
                                               bitmap. So it's using the search path to find
                                               the bitmap now.
dbu September 17th, 2003 (various)  [ ------ ] removed old Win32s support
arm September 16th, 2003 fkernel.f  [ ------ ] S" " gave a parse error rather than ( addr 0 )
                                               in non-compile state.

changed in 6.07.11
dbu September 16th, 2003 fkernel.f,
                         primutil.f [ ------ ] a better fix for the 'Record:' bug
dbu September 15th, 2003 fkernel.f,
                         primutil.f [ ------ ] fixed 'Record:' bug
arm 15/09/2003 00:41:38  meta.f     [ ------ ] reorganised source to support removal
                                               of wrapper, and meta compile of other source
dbu September 13th, 2003 debug.f    [ ------ ] added handling of EXITM wich was lost
                                               in Version 6.07.00
dbu September 13th, 2003 taskdemo.f [ ------ ] fixed a bug in Demo2 wish crashed Win32Forth
dbu September 13th, 2003 (various)  [ ------ ] new Version (2.21.06) of WinEd
                                               (see WinEd_Version.f for details)
dbu September 13th, 2003 term.c     [ ------ ] added Wheelmouse support for the console window

fixed in 6.07.10
arm 12/09/2003 23:52:54 fkernel.f   [ ------ ] comments removed from header; this file
                                               is now the authoratative source for change
                                               documentation.
arm 12/09/2003 23:44:39 (various)   [ ------ ] corrected erroneous use of &origin instead of
                                               app-origin (base of app area) or
                                               &origin @ (lowest address, the build address)
arm 12/09/2003 21:35:01 fkernel.f   [ ------ ] support for multiple vocabularies in kernel
arm 12/09/2003 21:33:44 utils.f,
           "            forth.c     [ ------ ] corrected error in resource image save that
                                               caused errors reading the resource from the
                                               exe resource image.
fixed in 6.07.09
dbu September 6th, 2003 dc.c       [ 745382 ] allow Filenames and path's not only in uppercase
dbu September 6th, 2003 extend.f   [ 778673 ] Blue Title Line - corrected info
dbu September 6th, 2003 (various)  [ ------ ] fixed some bug's in accelerator table support
                                              and new demo 'AccelDemo.f'
dbu September 8th, 2003 primhash.f [ ------ ] added EXITM wich was lost in Version 6.07.00
dbu September 8th, 2003 (various)  [ ------ ] removed registry entries 'Directory'
                                              and 'Version'
dbu September 9th, 2003 utils.f    [ ------ ] fixed a bug in $locate witch broke locate and linelist
dbu September 9th, 2003 utils.f    [ ------ ] changed [$edit] to work with blanks in the filename
dbu September 9th, 2003 wincon.dll [ ------ ] switch back to old wincon.dll because of
                                              missing constants in the new one
dbu September 9th, 2003 fkernel.f  [ ------ ] changed NAME-MAX-CHARS to 0xff; because
                                              filenames are compiled into the dictionary (see LINKFILE)

fixed in 6.07.08
31/08/2003 17:46:33 setup.*    [ ------ ] new setup program 0.3
31/08/2003 17:46:33 paths.f    [ ------ ] move most path functions here for further work
31/08/2003 17:46:33 wincon.dll [ ------ ] new wincon.dll; set extsources for source

fixed in 6.07.07
26/08/2003 20:47:08 term.c     [ 762961 ] regressed from 6.07.01
26/08/2003 20:47:59 setup.*    [ ------ ] new setup program

fixed in 6.07.06
24/08/2003 21:14:33 (various)  [ ------ ] support for accelerator tables
24/08/2003 18:31:48 (various)  [ ------ ] code in new separate code section
18/08/2003 00:06:31 (various)  [ ------ ] corrected load address of code section
18/08/2003 00:04:53 asmwin32.f [ 790284 ] 6.07.01 fvalue bug

jp 6.07.05a
jp 6.07.04
no 6.07.02, 6.07.03

fixed in 6.07.01
29/07/2003 22:00:16 (various)  [ ------ ] moved DOES> code into code-only section
07/07/2003 21:10:55 fkernel.f  [ 745385 ] Bug in "Find Text in Files" Dialog
07/07/2003 20:58:54 registry.f [ 766420 ] .registry displays version number in wrong format
07/07/2003 20:49:59 wined.res  [ 766252 ] "WinEd Preferences" Dialog not changed
04/07/2003 23:40:07 term.c     [ 762961 ] Win32for.exe 6.07.00 window disappears off screen
01/07/2003 20:26:14 window.f   [ 743879 ] bug in "SetClassName:"
01/07/2003 20:22:24 generic.f  [ 748990 ] bug in SetForegroundWindow:
01/07/2003 20:22:20 generic.f  [ 748991 ] bug in SetActiveWindow:
--------------------------------  Change Log ----------------------------------------

Changes between V4.2 Build 671 (TJZ's last release) and 6.07.06 (any
build, this is no longer part of the version/release specification).

-------------------------------------- 6.07.16 ------------------------------------

End-user changes
----------------

All existing code continues to work:


Architectural changes
---------------------

We don't use XCALL's into the c-wrapper any longer. The c-wrapper is only used
to load and run our forth image now. The console is moved into console.dll, and
the print support is moved into print.dll.

-------------------------------------- 6.07.08 ------------------------------------

End-user changes
----------------

All existing code continues to work:

1. New SETUP program in Forth to simplify installation for novices. Run SETUP.BAT
   to build new system. Can be run at any time; builds kernel, win32for and wined.
   _MAKEALL.BAT, MAKEWINED.BAT, EXTEND.BAT, META.BAT now point at new version of
   SETUP program. Unused modifiaction batch files (ADDMODS etc) now removed.

2. PATHS.F now contains much of the code that works with paths/directories. Will
   be used as a new base for fixing existing path problems.

3. WINCON.DLL updated to WindowsXP level; now contains some 13,000 constants.

-------------------------------------- 6.07.07 ------------------------------------

End-user changes
----------------

All existing code continues to work:

1. New SETUP program in Forth to simplify installation for novices. Run _MAKEALL.BAT
   to build new system. Can be run at any time; builds kernel, win32for and wined

-------------------------------------- 6.07.06 ------------------------------------

End-user changes
----------------

All existing code continues to work:

1. Multitasking
   MULTITHR.F has been updated, and all old code that depends on it will now
   work again (thanks to George Hubert for this) using the new TASK.F.

2. Changes to WIN32FOR.CFG to enable better tailoring.

Architectural changes
---------------------

1. Code section is complete. All of the following words
     CODE        assembler code words
     NCODE       assembler that the optimiser should not optimise
     ;CODE       run-time after CREATE code
     DOES>       stub for DOES> run-time execution
     CFA-CODE    primitive code words
     CLASS (BUILD) thunks
   generate code in a new CODE section, both in META compile and user code.
   .FREE now produces (sample)

          .free
          Section Address        Total      Used      Free
          ------- ---------  --------- --------- ---------
          CODE    00000000h     40,960    15,119    25,841
          APP     0000A000h    761,856   241,488   520,368
          SYSTEM  000C4000h    512,000   203,360   308,640
          Malloc/Pointer:       19,916 ok

   There are no end user changes to user code UNLESS you are building an ITC code
   section (very unusual, normally used by internal code). The changes are:
   --was--
   CFA-CODE MYNAME
         HERE CELL+ ,           \ build an ITC called MYNAME
         HERE CELL+ ,
         ...
   --now--
   NCODE MYNAME
         CODE-HERE CELL+ CODE-, \ build ITC
         ...

   One exception to this new code area is the thunk built for subclassing Windows;
   the thunk is built in the data section of the class, and that
   hasn't (and won't be) changed.

   Because of the Code section the optimizer (optimize.f) doesn't work.
   It need's to be rewritten.

2. Support for accelerator tables (thanks to Dirk Busch). Not all the code has been
   taken exactly as supplied by Dirk, and there is only currently skeleton support.
   Changes to CALLBACK.F and WINDOWS.F introduce new variables;

   ACCEL-HNDL  Handle of the accelerator table
   ACCEL-PTR   Pointer to accelerator table
   ACCEL-KEY   Deferred word for handler for key entries, currently a NOOP

   Further work will be needed to take Dirk's work and integrate, particularly into
   WINED and other menu-based apps.

-------------------------------------- 6.07.01 ------------------------------------

End-user changes
----------------

All existing code continues to work, with the following exceptions:

1. Multitasking
   MULTITHR.F is now obsolete, and has been replaced by TASK.F.
   Impact: Jos vd Ven uses MULTITHR.F in many of his programs. Any code that
   uses MULTITHR.F will not work.

2. WINCLOCK.F
   This had a subtle bug in it. Fixed in this release.

----------------------------- 6.07.00 & previous versions -------------------------

Architectural changes
---------------------

-- Multiple directories
   . addition of multiple directories to store documentation and
     applications
   . simplifies maintenance and identification of files used over a flat
     all-in-one-directory structure
   . supports separation of application from system code

-- Fixed loadpoint images can optionally be built
   . performance improvements of up to 30% for fixed loadpoint images over
     standard relocatable images

-- Performance improvements
   . Words rewritten to improve performance. Conditional jumps eliminated
     from much of the code, stack juggling reduced to a minimum.
   . Code moved out of the kernel that required the assembler, reduces size
     of the kernel
   . Better use of the stack to support USER variables and large static
     allocations of memory, allows simplified multitask support.

-- CALL mechanism simplified and moved to the kernel from WINLIB.F
   . allows the kernel to call Windows API without using XCALLs (calls to
     the C wrapper).
   . permits libraries & procedures to be specified during development &
     runtime that do not exist. All CALL errors can optionally be deferred
     to run-time, rather than compile time.

-- ANS file words moved to the kernel from ANSFILE.F
   . allows the kernel to perfrom I/O without using XCALLs.
   . some improved performance
   . read-line now supports DOS (CR|LF), UNIX (LF) and MAC (CR) newlines
   . I/O supported in multitasking

-- Memory words moved to the kernel from PRIMUTIL.F
   . better performance by using heap API calls rather than Win32S
     compatability calls
   . allows locking during allocation to support multitasking

-- Exception handling improved
   . diagnostics improved to allow better determination of the error
   . integrated into CATCH/THROW

-- Multitasking support improved
   . simplification of requirements for supporting multiple tasks
   . USER variables rationalised and unique per-task.
   . Still in progress, subject to some changes.

-- Better FORGET support
   . correctly forgets all types of entries including libraries, files,
     procedure definitions

-- CALLBACKs rationalised
   . Callbacks rationalised to support Windows callbacks with a single word
   . Efficency improved, standardised use of the stack
   . Supported in multitasking

-- File interdependencies reduced
   . allows more flexibility about the order of FLOADs in EXTEND.F
   . permits assembler to be loaded early if required

-- CLASS changes
   . new root class allows simplified and smaller classes that don't require
     RECORD: support

-- Disassembler improvements
   . better text output identifies labels by name rather than by hex offset
   . bug fixes

-- Hidden words in kernel support
   . Internal words in the kernel are now hidden, reduces size of the
     dictionary.

Bugs fixed
----------

  . SEE was generating errors on optimised code in ;CODE sections
  . FORGET wasn't forgetting properly certain classes of items, such as
    PROCs, WINLIBRARYs and CALLs
  . META compile was miscalculating the size of the generated image
  . Dialog loading was miscalculating the offsets inside a RES file causing
    spurious errors.
  . FIND with class support was finding words of the form x.y, even though x
    did not exist, or x was not an object.
  . Optimiser was generating invalid code and/or generating an exception
    for a non-zero origin kernel
  . Optimiser assumed that all code ended with NEXT, and generated incorrect
    code if not.
  . Cosmetic tidy up, some spelling corrected in messages
  . FLOAD wouldn't load a file with blanks in its name. Changed to support
    quoted filenames
  . Disassembler was not recognising some instruction encodings

Known Problems
--------------

  . File and folder support is not consistent across all words
  . FIND x.y if y is not a method of x returns found
  . SEE may overrun code if it doesn't terminate with NEXT
  . Communication between WINED (the editor) and a Forth instance is
    not good. Depends on the version of Windows in use.
  . probably lots of others...

>>>>>>> 1.2


