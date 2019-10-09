\ $Id: AcceleratorTables.f,v 1.7 2011/09/14 13:35:09 georgeahubert Exp $

\                    Windows Accelerator Table support for Win32Forth
\                               October 2004  Rod Oakford

\ *D doc
\ *! p-AcceleratorTables
\ *T Windows Accelerator Table support

\ *P To use Accelerator Tables in an application:
\ *P Define the Accelerator Tables required using:  AcceleratorTable <name>
\ *P Start the entries for each table with:  <name> table
\ *P Add entries with: ( flags key-code command-id )  AccelEntry
\ *P End the table with: ( Window ) HandlesThem
\ ** This will add code to process the Accelerator Keys in the message chain.
\ *P Use:  <name> EnableAccelerators to enable the accelerator commands
\ ** and send them to the window used with HandlesThem.
\ *P These accelerator commands are handled in the window's OnWmCommand: method.
\ *P Use: <name> DisableAccelerators to disable the accelerator commands for this table.
\ ** Always disable (destroy) every table before the application closes to prevent memory leaks.

\ *S Glossary

cr .( Windows Accelerator Table support...)

anew -AcceleratorTables.f

INTERNAL
In-system
0 value CurrentTable   \ current named accelerator table

EXTERNAL
: Dump-Accelerator-Key-Table ( a -- )                   \ W32F sys
\ *G Dump an Accelerator Table to the console window-
        cr dup BODY> .name  ." Table:"
        cr ." Address Flags Key ID"
        cell+ 2@ 6 * bounds DO
            cr  i 6 h.R  i w@ 5 h.R  i 2 + w@ 5 h.R  i 4 + w@ 4 h.R
        6 +LOOP  cr ;

: AcceleratorTable ( <name> -- )
\ *G Create a new named Accelerator Table
        Create  here to CurrentTable
        ( Handle ) 0 ,  ( AccelEntries ) 0 ,  ( AccelTable ) here ,  ;

: Table         ( a -- )                                \ W32F sys
\ *G Start a table of entries in the dictionary
        dup to CurrentTable  here 0  rot cell+ 2! ;

: AccelEntry    ( flags key-code command-id -- )        \ W32F sys
\ *G Add an entry to the current table
        rot 3 ( FVIRTKEY FNOINVERT or ) or w,
        swap w, w,  CurrentTable cell+ incr ;

In-application

Sys-warning-off
: HandlesThem   ( Window -- )                           \ W32F
\ *G Close a table and assign it to the given window.
        \ adds the code in #DOES> to the message chain

        \ Changed to add it on the start of the chain instead of the end, because
        \ accelerator keys bust be handled before any other things happen in the
        \ massage loop, to work correctly (Sonntag, Mai 21 2006 dbu).
        here  DOVAR ,  CurrentTable ,  swap ( Window ) ,  dup  msg-chain noop-chain-add-before !

        #DOES> ( pMsg f pfa -- pMsg f )
        2@ @ swap @ 2>r   \ handle of table and handle of Window that will process the commands
        dup  2r@ * and    \ only when accelerators are enabled and Window has a handle
        IF  drop dup 2r@ Call TranslateAccelerator 0=
        THEN  2r> 2drop ;
Sys-warning-on

: DisableAccelerators   ( a -- )                        \ W32F
\ *G Destroys the Windows Accelerator Table.
        \ It does not matter trying to destroy a table more than once.
        dup @ Call DestroyAcceleratorTable drop  off ;

: EnableAccelerators    ( a -- )                        \ W32F
\ *G Creates the Windows Accelerator Table.
        \ It does not matter creating the same table again as long as it is destroyed first.
        dup DisableAccelerators
        dup cell+ 2@ swap Call CreateAcceleratorTable  swap ! ;

MODULE

\ ---------------------------------------------------------------------------------------------


\s
\ *S Example
\ *+

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define some accelerator tables
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AcceleratorTable FunctionKeys
AcceleratorTable CharKeys
AcceleratorTable NumKeys


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define a small window that will receive the accelerator commands
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object TEST   <Super Window

:M StartSize:   220 50 ;M

:M On_Init: ( -- )
        NumKeys EnableAccelerators
        FunctionKeys EnableAccelerators
        CharKeys EnableAccelerators ;M

:M OnWmCommand:  ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        over LOWORD ( Command ID )
        cr ." Accelerator command ID: " .
        ;M

:M On_Done: ( -- )
        NumKeys DisableAccelerators
        FunctionKeys DisableAccelerators
        CharKeys DisableAccelerators ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Accelerator table entries
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

NumKeys table
\   Flags            Key Code      Command ID
    FCONTROL         VK_NUMPAD0    0           AccelEntry
    FCONTROL         VK_NUMPAD1    1           AccelEntry
    FCONTROL         VK_NUMPAD2    2           AccelEntry
    FCONTROL         VK_NUMPAD3    3           AccelEntry
    FCONTROL         VK_NUMPAD4    4           AccelEntry
    FCONTROL         VK_NUMPAD5    5           AccelEntry
    FCONTROL         VK_NUMPAD6    6           AccelEntry
    FCONTROL         VK_NUMPAD7    7           AccelEntry
    FCONTROL         VK_NUMPAD8    8           AccelEntry
    FCONTROL         VK_NUMPAD9    9           AccelEntry
    FCONTROL         VK_DECIMAL    16          AccelEntry
    FCONTROL         VK_RETURN     17          AccelEntry
    FCONTROL         VK_ADD        18          AccelEntry
    FCONTROL         VK_SUBTRACT   19          AccelEntry

TEST HandlesThem


FunctionKeys table
\   Flags            Key Code      Command ID
    FSHIFT           VK_F1         65          AccelEntry
    FSHIFT           VK_F2         66          AccelEntry
    FSHIFT           VK_F3         67          AccelEntry
    FSHIFT           VK_F4         68          AccelEntry

TEST HandlesThem


CharKeys table
\   Flags            Key Code      Command ID
    0                'Z'           129         AccelEntry
    0                'X'           130         AccelEntry
    0                'C'           131         AccelEntry
    0                'V'           132         AccelEntry
    0                'B'           133         AccelEntry
    0                'N'           134         AccelEntry
    0                'M'           135         AccelEntry

TEST HandlesThem


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Instructions
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

cr
NumKeys       Dump-Accelerator-Key-Table
FunctionKeys  Dump-Accelerator-Key-Table
CharKeys      Dump-Accelerator-Key-Table

start: test

cr .( Make sure the test window has the focus.)
cr .( Press some of the accelerator keys to see the IDs in the console window.)
cr .( In this example NumPad keys need Ctrl [Num Lock needs to be on].)
cr .( Function keys work with Shift, Char keys work without Shift, Ctrl or Alt.)
cr .( All combinations of Shift, Ctrl, Alt or nothing are possible.)
cr .( CharKeys DisableAccelerators will disable the CharKeys accelerators.)
cr .( CharKeys EnableAccelerators will enable them again.)
cr .( Closing the Test window will disable all the accelerators)

\ *-
\ *Z

