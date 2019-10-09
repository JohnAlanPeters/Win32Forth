\ $Id: WinBase.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $

\    File: WinBase.f
\  Author: Jeff Kelm
\ Created: 27-Aug-1998
\ Updated: August 17th, 2003 dbu
\ Extensions and defines for Win32For

Comment:  Revision History (most recent first)

September 17th, 2003 dbu
 - removed old Win32s support
August 17th, 2003 dbu
 - Changed to use in WinEd 2.21.05 and later
19990601
 - Uncommented the constants which don't show up on my NT machine (running older
   version of Win32forth).
19990520
 - Removed the class name string definitions since these are now
   handled in the ChildWindow DefClassName: method.
 - Commented out most of the constant declarations since they
   now appear to work (at least on Win98, Win32Forth v4.2).
19990519
 - Added stack frame code.
19990422
 - Eliminated the 990413 changes.  Didn't work.
19990413
 - Eliminated "WinLibrary COMCTL32.DLL" initialization.  Moved to
   BasicWin.f in Create: for ChildWindow.  This will hopefully clear up
   issues with turnkeying if that DLL isn't already loaded.
19990315
 - Changed DefinedAbort, to correct a problem in ?WinError
   ?WinError didn't compile the right stuff if the source was from the
   keyboard (or pasted from the clipboard) but inside a definition.
   The definition:
      : DrawAxes ...  hdc GetHandle: wnd1 Call ReleaseDC  ?WinError ;
   generated this when typed in by hand (or pasted):
      : DrawAxes ... HDC lit O:WND1 M0:GETHANDLE: Call ReleaseDC
         DUP (?WINERROR) 0= ;   \ leaves a flag on the stack!
   and generated this when read in from file:
      : DrawAxes ... HDC lit O:WND1 M0:GETHANDLE: Call ReleaseDC
         DUP (?WINERROR) 0= ABORT" Defined in file: popup.f -- Line: 80" ;
   corrected version generates:
      : DrawAxes ... HDC lit O:WND1 M0:GETHANDLE: Call ReleaseDC
         DUP (?WINERROR) 0= DROP ;
 - eliminated redundant IF...ELSE...THEN clause in DefinedAbort, since
   the only way DefinedAbort, is executed is when STATE is true.
19981120
 - added UPDOWN_CLASS definition
19981118
 - added TTM_UPDATETIPTEXT, TTM_ENUMTOOLS & TTM_GETTEXT
19981117
 - separated window classes into their own file (BasicWin.f)
 - Simplified definitions for zCount and MAKELONG
 - Factored ?WinError, but it still looks too complicated
Comment;



CR  .( Loading Extensions...)



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ Extensions to Win32For
\

in-application

\ MAKELONG macro creates an unsigned 32-bit by concatenating two 16-bit values
: MAKELONG ( hi lo -- n)   SWAP word-join ;



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ Redefined ?WinError to give more debugging information
\
: (GetLastError) ( -- n)   GetLastWinErr ;

: (FormatSystemMessage) ( error -- a n)
   GetLastWinErrMsg count ;

: (?WinError) ( f)   \ show an error dialog box if f=FALSE/0
   0= IF  (GetLastError) (FormatSystemMessage)
          2DUP  2 - ( to drop CRLF pair)  CR TYPE CR  ( echo to console)
          DROP >R
          MB_OK MB_ICONWARNING OR  Z" Error"
             R> NULL  Call MessageBox drop
    THEN ;


TRUE [IF]   \ add more debugging information to ?WinError

   : DefinedAbort,   \ compiles an ABORT" with the file name and line where defined
        LOADING?
        IF  S" Defined in file: "    TEMP$ PLACE
              LOADFILE COUNT         TEMP$ +PLACE
              S"  -- Line: "         TEMP$ +PLACE
              LOADLINE @ (.)         TEMP$ +PLACE
              POSTPONE (ABORT")
              TEMP$ COUNT ", 0 c, align
        ELSE  POSTPONE DROP
        THEN
        ;

   : ?WinError ( f)
      STATE @ IF  POSTPONE DUP  POSTPONE (?WinError)  POSTPONE 0= DefinedAbort,
            ELSE  (?WinError)
            THEN ; IMMEDIATE

[ELSE]   \ just give messagebox as an alert, don't abort

   : ?WinError ( f)   (?WinError) ;

[THEN]

: CreateNewID ( -- id)   \ create a new id number (hopefully unique, but not guaranteed)
	NextId ;



WinLibrary COMCTL32.DLL   \ Add the advanced control library.
                          \ Needed for CreateToolbar, CreateStatusWindow, etc.


\ defines not in Win32for WINCON.DLL
\ TTN_GETDISPINFOA   CONSTANT TTN_NEEDTEXT       \ ANSI version
\ TBN_GETBUTTONINFOA CONSTANT TBN_GETBUTTONINFO  \ ANSI version
\ TTM_ADDTOOLA       CONSTANT TTM_ADDTOOL        \ ANSI version
\ SB_SETTEXTA        CONSTANT SB_SETTEXT         \ ANSI version
\ SB_GETTEXTA        CONSTANT SB_GETTEXT         \ ANSI version
\ TTM_UPDATETIPTEXTA CONSTANT TTM_UPDATETIPTEXT  \ ANSI version
\ TTM_GETTEXTA       CONSTANT TTM_GETTEXT        \ ANSI version
\ TTM_ENUMTOOLSA     CONSTANT TTM_ENUMTOOLS      \ ANSI version

   \ Strings not defined in Win32for
\   : STATUSCLASSNAME   Z" msctls_statusbar32" ;
\   : TOOLBARCLASSNAME  Z" ToolbarWindow32"    ;
\   : WC_TREEVIEW       Z" SysTreeView32"      ;
\   : TOOLTIPS_CLASS    Z" tooltips_class32"   ;
\   : PROGRESS_CLASS    Z" msctls_progress32"  ;
\   : TRACKBAR_CLASS    Z" msctls_trackbar32"  ;
\   : UPDOWN_CLASS      Z" msctls_updown32"    ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ Load Resources
\
\ LR_LOADFROMFILE is not claimed to work on NT, but the documentation
\ appears to be out of date since it works on my NT machine.
\    For icons, the alternative would be:
\       0 Z" Toolbar.ico"  appInst
\       Call ExtractIcon  DUP VALUE hIcon  ?WinError
\    Couldn't find a simple alternative for bitmaps and didn't look
\    for one for cursors.

\ a is a relative address of a zString for file name,
\ f is resource type (IMAGE_ICON, IMAGE_BITMAP, or IMAGE_CURSOR)
\ returns handle to resource
: GetResource ( a f -- handle)
   2>R  LR_LOADFROMFILE 0 0 R> R>
   NULL  Call LoadImage  DUP ?WinError ;

\ create an icon resource from file
: GetIconResource ( a -- handle)
   IMAGE_ICON  GetResource ;

\ create a bitmap resource from file
: GetBmpResource ( a -- handle)
   IMAGE_BITMAP  GetResource ;

\ create a cursor resource from file
: GetCurResource ( a -- handle)
   IMAGE_CURSOR  GetResource ;



Comment:  ------------------------------------------------------
                Stack Frame Code

To address concerns raised by Tom Zimmer regarding storage and
reentrancy in my routines I have adopted an approach similar
to the way MASM handles it.  In MASM the directive LOCAL
generates a stack frame with enough room for the structure
being declared.

My initial attempts at this are admittedly crude, but will give
me something to play with for a now.  After experimenting a
while, I may come up with a more elegant approach.
------------------------------------------------------  Comment;

\ create a stack frame on the parameter stack for u cells, addr
\ is to top-of-stack item, x1.  Since stack grows down in
\ Win32Forth, this is the address to the start of the structure.
: sFrame ( u -- xn .. x2 x1 addr)   \ u<=100
   100 MIN 0 MAX  0 ?DO  0  LOOP  sp@ ;



\ for creating an initialized stack frame

0 VALUE OldStackPtr

: StartFrame ( -- )   \ start creating an initialized stack frame
   OldStackPtr ABORT" Can't nest initialized stack frames"
   sp@ TO OldStackPtr ;

: EndFrame ( -- addr)   \ end an initialized stack frame,
                        \ returning address of start of structure
   OldStackPtr 0= ABORT" No initialized stack frame started"
   sp@ ;

: ReclaimFrame ( xn ... x2 x1 -- )   \ return stack to state
                                     \ prior to stack frame
   OldStackPtr sp!  0 TO OldStackPtr ;


Comment:  ------------------------------------------------------

Usage
   StartFrame  ICC_DATE_CLASSES 8  EndFrame
      Call InitCommonControlsEx  ?WinError  ReclaimFrame

Could also try something like putting the stack frame on the return stack

Before              After    return address of a routine that cleans up the
xt2                 xt3  <== return stack before dropping through to xt2
xt1                 u    <== number of items to remove from the return stack
                    x1
                    x2
                    ...
                    xn
                    xt2
                    xt1

This would allow several frames to be created and kept around and they
would automagically delete themselves when the word that created them
return to the word that called it.
------------------------------------------------------  Comment;
