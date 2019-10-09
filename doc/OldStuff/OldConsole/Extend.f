\ $Id: Extend.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $
\ extend the kernel

cr .( -- META EXTEND.F ) cr

sys-FLOAD src\comment.f
    FLOAD src\numconv.f         \ general number conversions
    FLOAD src\console\console.f \ Console I/O part 1
    FLOAD src\primutil.f        \ primitive utilities
sys-FLOAD src\nforget.f
sys-FLOAD src\order.f           \ vocabulary support
sys-FLOAD src\module.f          \ scoping support for modules
sys-FLOAD src\interpif.f        \ interpretive conditionals
    FLOAD src\paths.f           \ multi path support words

sys-FLOAD src\486asm.f          \ Jim's 486 assembler
sys-FLOAD src\asmmac.f          \ Jim's 486 macros
sys-FLOAD src\asmwin32.f        \ NEXT for Win32forth

    FLOAD src\pointer.f
    FLOAD src\callback.f        \ windows callback support
    FLOAD src\primhash.f        \ primitive hash functions for OOP later

8 constant B/FLOAT      \ default to 8 byte floating point numbers
    FLOAD src\float.f           \ floating point support

sys-FLOAD src\see.f
sys-FLOAD src\dis486.f          \ load the disassembler
sys-FLOAD src\dthread.f         \ display threads
sys-FLOAD src\winlib.f          \ windows proc and memory debug words
sys-FLOAD src\words.f
    FLOAD src\tools\dump.f      \ HEX dump

    FLOAD src\console\console2.f \ Console I/O part 2
sys-FLOAD src\debug.f

    FLOAD src\class.f           \ ***** Object Oriented Programming Support *****

    FLOAD src\scrnctrl.f        \ screen control words
    FLOAD src\registry.f        \ Win32 Registry support
    FLOAD src\ansfile.f         \ ansi file words
    FLOAD src\keyboard.f        \ function and special key constants
    FLOAD src\mapfile.f         \ Windows32 file into memory mapping words
sys-FLOAD src\environ.f         \ environment? support

    FLOAD src\console\lineedit.f \ a line editor utility

    FLOAD src\utils.f           \ load other misc utility words
    FLOAD src\exceptio.f        \ utility words to support windows exception handling

    FLOAD src\w32fmsglist.f     \ win32forth applications & messages IDs
    FLOAD src\w32fmsg.f         \ w32f application messaging
                                \ needs to be after exceptio.f
                                \ don't know why, but related to initialization-chain
    FLOAD src\Shell.f           \ load SHELL utility words
    FLOAD src\editor_io.f       \ Communication between the editor and the console
sys-fload src\imageman.f        \ fsave, application & turnkey words

sys-FLOAD src\dbgsrc1.f         \ source level debugging support part one
sys-FLOAD src\dbgsrc2.f         \ source level debugging support part two
sys-FLOAD src\classdbg.f        \ Object Debugging

    FLOAD src\colors.f
    FLOAD src\fonts.f           \ font class
    fload src\xfiledlg.f        \ xcall replacements for open dialogs
    FLOAD src\PrintSupport.f    \ replacement for the w32fPrint.dll
    FLOAD src\dc.f              \ device context class
    FLOAD src\generic.f         \ generic window class
    FLOAD src\window.f
    FLOAD src\childwnd.f        \ child windows
    FLOAD src\winmsg.f
    FLOAD src\control.f
    FLOAD src\controls.f
    FLOAD src\button.f
    FLOAD src\dialog.f
    FLOAD src\menu.f
    FLOAD src\lib\BROWSEFLD.F   \ SHBrowseForFolder() support

    FLOAD src\console\forthdlg.f       \ some dialogs for the console
    FLOAD src\keysave.f                \ keyboard macro recording
    FLOAD src\tools\tools.f            \ load various tool's when they are needed
    FLOAD src\lib\LoadProject.f        \ Loads the latest known project
    FLOAD src\console\ConsoleMenu.f    \ menu bar for the console
sys-FLOAD src\console\ConsoleStatBar.f \ status bar for the console window

    FLOAD src\compat\Evolve.f          \ win2forth evolution between 2 releases

    FLOAD src\boot.f                   \ win32forth boot


in-application

here fence !

mark empty

cur-file off            \ clear the default file
cur-line off            \ clear the current line

cr cr .( Extensions Loaded, )
count-words . .( words in dictionary)
cr


w32fForth to NewAppID   \ init shared memory for communication [cdo]
false to RunUnique

\+ SaveInfo  SaveInfo WIN32FOR.DBG \ save debugger information
fsave Win32for        \ save Win32For.EXE
fload lib\Resources.f
s" src\res\Win32For.ico" s" Win32for.exe" AddAppIcon


1 pause-seconds

